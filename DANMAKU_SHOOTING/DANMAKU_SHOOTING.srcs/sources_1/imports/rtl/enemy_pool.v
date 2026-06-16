// =============================================================================
//  enemy_pool.v
//  Fixed-size enemy instance pool with spawn scheduler and fire arbitration.
// =============================================================================
`include "game_defs.vh"

module enemy_pool #(
    parameter MAX_ENEMIES = 16
) (
    input  wire          clk,
    input  wire          rstn,
    input  wire          frame_tick,
    input  wire          game_run,
    input  wire [1:0]    difficulty,
    input  wire [15:0]   rng,
    input  wire [15:0]   play_time_sec,
    input  wire [MAX_ENEMIES-1:0] en_hit,

    output wire [MAX_ENEMIES-1:0] en_active,
    output wire [9:0]             en_x[MAX_ENEMIES-1:0],
    output wire [9:0]             en_y[MAX_ENEMIES-1:0],
    output reg                    any_killed,
    output reg  [1:0]             killed_hp,
    output reg                    e_fire_req,
    output reg  [9:0]             e_fire_x,
    output reg  [9:0]             e_fire_y,
    output reg  [1:0]             e_fire_traj,
    output reg  [2:0]             e_fire_count,
    output reg                    e_fire_dual
);

    reg [MAX_ENEMIES-1:0] spawn;
    reg [8:0] spawn_cnt;
    wire [MAX_ENEMIES-1:0] killed;
    wire [MAX_ENEMIES-1:0] fire_req_w;
    wire [1:0] fire_traj_w [0:MAX_ENEMIES-1];
    wire [2:0] fire_count_w [0:MAX_ENEMIES-1];
    wire fire_dual_w [0:MAX_ENEMIES-1];
    wire [9:0] fire_x_w [0:MAX_ENEMIES-1];
    wire [9:0] fire_y_w [0:MAX_ENEMIES-1];

    integer i;
    integer selected;

    function [8:0] spawn_period(input [1:0] d, input [15:0] sec);
        reg [8:0] base;
        begin
            case (d)
                `DIFF_EASY  : base = 9'd150;
                `DIFF_NORMAL: base = 9'd110;
                `DIFF_HARD  : base = 9'd80;
                `DIFF_HELL  : base = 9'd55;
                default     : base = 9'd120;
            endcase
            spawn_period = (base > {2'b00, sec[8:2]}) ? (base - {2'b00, sec[8:2]}) : 9'd25;
        end
    endfunction

    function [1:0] hp_for_score(input [1:0] d);
        case (d)
            `DIFF_HARD  : hp_for_score = 2'd2;
            `DIFF_HELL  : hp_for_score = 2'd3;
            default     : hp_for_score = 2'd1;
        endcase
    endfunction

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            spawn <= {MAX_ENEMIES{1'b0}};
            spawn_cnt <= 9'd0;
            any_killed <= 1'b0;
            killed_hp <= 2'd0;
            e_fire_req <= 1'b0;
            e_fire_x <= 10'd0;
            e_fire_y <= 10'd0;
            e_fire_traj <= `TRAJ_LINE;
            e_fire_count <= 3'd0;
            e_fire_dual <= 1'b0;
        end else begin
            spawn <= {MAX_ENEMIES{1'b0}};
            any_killed <= |killed;
            killed_hp <= (|killed) ? hp_for_score(difficulty) : 2'd0;

            e_fire_req <= 1'b0;
            selected = 0;
            for (i = 0; i < MAX_ENEMIES; i = i + 1) begin
                if (fire_req_w[i] && (selected == 0)) begin
                    e_fire_req   <= 1'b1;
                    e_fire_x     <= fire_x_w[i];
                    e_fire_y     <= fire_y_w[i];
                    e_fire_traj  <= fire_traj_w[i];
                    e_fire_count <= fire_count_w[i];
                    e_fire_dual  <= fire_dual_w[i];
                    selected = 1;
                end
            end

            if (frame_tick && game_run) begin
                if (spawn_cnt >= spawn_period(difficulty, play_time_sec)) begin
                    spawn_cnt <= 9'd0;
                    selected = 0;
                    for (i = 0; i < MAX_ENEMIES; i = i + 1) begin
                        if (!en_active[i] && (selected == 0)) begin
                            spawn[i] <= 1'b1;
                            selected = 1;
                        end
                    end
                end else begin
                    spawn_cnt <= spawn_cnt + 9'd1;
                end
            end
        end
    end

    genvar gi;
    generate
        for (gi = 0; gi < MAX_ENEMIES; gi = gi + 1) begin : g_enemy
            enemy #(.EID(gi)) u_enemy (
                .clk(clk),
                .rstn(rstn),
                .frame_tick(frame_tick),
                .game_run(game_run),
                .difficulty(difficulty),
                .rng(rng ^ gi),
                .spawn(spawn[gi]),
                .spawn_x(10'd32 + ((rng + gi * 16) % 10'd576)),
                .spawn_y(10'd20),
                .hit_by_pbullet(en_hit[gi]),
                .active(en_active[gi]),
                .ex(en_x[gi]),
                .ey(en_y[gi]),
                .hp(),
                .killed(killed[gi]),
                .fire_req(fire_req_w[gi]),
                .fire_traj(fire_traj_w[gi]),
                .fire_count(fire_count_w[gi]),
                .fire_dual(fire_dual_w[gi]),
                .fire_x(fire_x_w[gi]),
                .fire_y(fire_y_w[gi])
            );
        end
    endgenerate

endmodule
