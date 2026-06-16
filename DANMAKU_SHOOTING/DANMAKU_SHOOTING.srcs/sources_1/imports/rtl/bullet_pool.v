// =============================================================================
//  bullet_pool.v
//  Fixed-size player/enemy bullet pool.
// =============================================================================
`include "game_defs.vh"

module bullet_pool #(
    parameter MAX_BULLETS = 64
) (
    input  wire            clk,
    input  wire            rstn,
    input  wire            frame_tick,
    input  wire            game_run,
    input  wire            clear_ebullets,
    input  wire [MAX_BULLETS-1:0] bul_kill,

    input  wire            p_fire_pulse,
    input  wire [9:0]      p_muzzle_lx,
    input  wire [9:0]      p_muzzle_rx,
    input  wire [9:0]      p_muzzle_y,

    input  wire            e_fire_req,
    input  wire [9:0]      e_fire_x,
    input  wire [9:0]      e_fire_y,
    input  wire [1:0]      e_fire_traj,
    input  wire [2:0]      e_fire_count,
    input  wire            e_fire_dual,

    input  wire [1:0]      difficulty,

    output reg  [MAX_BULLETS-1:0]       bul_active,
    output wire [11:0]                  bul_color [MAX_BULLETS-1:0],
    output wire [9:0]                   bul_x     [MAX_BULLETS-1:0],
    output wire [9:0]                   bul_y     [MAX_BULLETS-1:0],
    output wire [`X_BITS-1:0]           bul_w     [MAX_BULLETS-1:0],
    output wire [`Y_BITS-1:0]           bul_h     [MAX_BULLETS-1:0],
    output wire                         bul_is_pbullet [MAX_BULLETS-1:0]
);

    reg signed [11:0] x [0:MAX_BULLETS-1];
    reg signed [11:0] y [0:MAX_BULLETS-1];
    reg signed [5:0]  dx [0:MAX_BULLETS-1];
    reg signed [5:0]  dy [0:MAX_BULLETS-1];
    reg [1:0]         traj [0:MAX_BULLETS-1];
    reg [7:0]         age [0:MAX_BULLETS-1];
    reg               is_pbullet [0:MAX_BULLETS-1];

    integer i;
    integer spawned;

    function signed [5:0] enemy_speed(input [1:0] d);
        case (d)
            `DIFF_EASY  : enemy_speed = 6'sd2;
            `DIFF_NORMAL: enemy_speed = 6'sd3;
            `DIFF_HARD  : enemy_speed = 6'sd4;
            `DIFF_HELL  : enemy_speed = 6'sd5;
            default     : enemy_speed = 6'sd3;
        endcase
    endfunction

    task spawn_bullet;
        input signed [11:0] sx;
        input signed [11:0] sy;
        input signed [5:0]  sdx;
        input signed [5:0]  sdy;
        input [1:0]         straj;
        input               spbullet;
        integer k;
        begin
            for (k = 0; k < MAX_BULLETS; k = k + 1) begin
                if (!bul_active[k] && (spawned == 0)) begin
                    bul_active[k] <= 1'b1;
                    x[k]          <= sx;
                    y[k]          <= sy;
                    dx[k]         <= sdx;
                    dy[k]         <= sdy;
                    traj[k]       <= straj;
                    age[k]        <= 8'd0;
                    is_pbullet[k] <= spbullet;
                    spawned       = 1;
                end
            end
        end
    endtask

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bul_active <= {MAX_BULLETS{1'b0}};
            for (i = 0; i < MAX_BULLETS; i = i + 1) begin
                x[i] <= 12'sd0;
                y[i] <= 12'sd0;
                dx[i] <= 6'sd0;
                dy[i] <= 6'sd0;
                traj[i] <= `TRAJ_LINE;
                age[i] <= 8'd0;
                is_pbullet[i] <= 1'b0;
            end
        end else begin
            for (i = 0; i < MAX_BULLETS; i = i + 1) begin
                if (bul_kill[i] || (clear_ebullets && !is_pbullet[i]))
                    bul_active[i] <= 1'b0;
            end

            if (frame_tick && game_run) begin
                for (i = 0; i < MAX_BULLETS; i = i + 1) begin
                    if (bul_active[i]) begin
                        age[i] <= age[i] + 8'd1;
                        case (traj[i])
                            `TRAJ_CIRC: begin
                                x[i] <= x[i] + ((age[i][4]) ? -dx[i] : dx[i]);
                                y[i] <= y[i] + dy[i];
                            end
                            `TRAJ_PARA: begin
                                x[i] <= x[i] + dx[i];
                                y[i] <= y[i] + dy[i] + {4'd0, age[i][5:4]};
                            end
                            default: begin
                                x[i] <= x[i] + dx[i];
                                y[i] <= y[i] + dy[i];
                            end
                        endcase

                        if ((x[i] < -12'sd16) || (x[i] > 12'sd656) ||
                            (y[i] < -12'sd16) || (y[i] > 12'sd496))
                            bul_active[i] <= 1'b0;
                    end
                end

                if (p_fire_pulse) begin
                    spawned = 0;
                    spawn_bullet({2'b00, p_muzzle_lx}, {2'b00, p_muzzle_y}, 6'sd0, -$signed(`PBULLET_SPEED), `TRAJ_LINE, 1'b1);
                    spawned = 0;
                    spawn_bullet({2'b00, p_muzzle_rx}, {2'b00, p_muzzle_y}, 6'sd0, -$signed(`PBULLET_SPEED), `TRAJ_LINE, 1'b1);
                end

                if (e_fire_req) begin
                    spawned = 0;
                    spawn_bullet({2'b00, e_fire_x}, {2'b00, e_fire_y}, -enemy_speed(difficulty), enemy_speed(difficulty), e_fire_traj, 1'b0);
                    if (e_fire_count > 3'd1) begin spawned = 0; spawn_bullet({2'b00, e_fire_x}, {2'b00, e_fire_y}, 6'sd0, enemy_speed(difficulty), e_fire_traj, 1'b0); end
                    if (e_fire_count > 3'd2) begin spawned = 0; spawn_bullet({2'b00, e_fire_x}, {2'b00, e_fire_y}, enemy_speed(difficulty), enemy_speed(difficulty), e_fire_traj, 1'b0); end
                    if (e_fire_count > 3'd3) begin spawned = 0; spawn_bullet({2'b00, e_fire_x}, {2'b00, e_fire_y}, -6'sd2, enemy_speed(difficulty) + 6'sd1, e_fire_traj, 1'b0); end
                    if (e_fire_count > 3'd4) begin spawned = 0; spawn_bullet({2'b00, e_fire_x}, {2'b00, e_fire_y}, 6'sd2, enemy_speed(difficulty) + 6'sd1, e_fire_traj, 1'b0); end
                    if (e_fire_dual) begin
                        spawned = 0;
                        spawn_bullet({2'b00, e_fire_x} - 12'sd8, {2'b00, e_fire_y}, -enemy_speed(difficulty), enemy_speed(difficulty), e_fire_traj, 1'b0);
                        spawned = 0;
                        spawn_bullet({2'b00, e_fire_x} + 12'sd8, {2'b00, e_fire_y}, enemy_speed(difficulty), enemy_speed(difficulty), e_fire_traj, 1'b0);
                    end
                end
            end
        end
    end

    genvar gi;
    generate
        for (gi = 0; gi < MAX_BULLETS; gi = gi + 1) begin : g_out
            assign bul_x[gi] = x[gi][9:0];
            assign bul_y[gi] = y[gi][9:0];
            assign bul_w[gi] = `BULLET_W;
            assign bul_h[gi] = `BULLET_H;
            assign bul_is_pbullet[gi] = is_pbullet[gi];
            assign bul_color[gi] = is_pbullet[gi] ? `COL_PBULLET : `COL_EBULLET;
        end
    endgenerate

endmodule
