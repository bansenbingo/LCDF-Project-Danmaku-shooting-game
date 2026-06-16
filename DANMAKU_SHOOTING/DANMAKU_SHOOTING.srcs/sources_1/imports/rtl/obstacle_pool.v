// =============================================================================
//  obstacle_pool.v
//  Fixed-size falling obstacle pool.
// =============================================================================
`include "game_defs.vh"

module obstacle_pool #(
    parameter MAX_OBS = 16
) (
    input  wire          clk,
    input  wire          rstn,
    input  wire          frame_tick,
    input  wire          game_run,
    input  wire [1:0]    difficulty,
    input  wire [15:0]   rng,
    input  wire [15:0]   play_time_sec,
    input  wire [MAX_OBS-1:0] obs_hit_pbullet,
    input  wire [MAX_OBS-1:0] obs_hit_player,

    output wire [MAX_OBS-1:0] obs_active,
    output wire [9:0]         obs_x[MAX_OBS-1:0],
    output wire [9:0]         obs_y[MAX_OBS-1:0],
    output wire [9:0]         obs_rad[MAX_OBS-1:0],
    output reg                obs_hit_player_any,
    output reg  [1:0]         obs_player_damage,
    output wire               obs_destroyed_any
);

    reg [MAX_OBS-1:0] spawn;
    reg [8:0] spawn_cnt;
    wire [MAX_OBS-1:0] destroyed;
    wire [1:0] damage_w [0:MAX_OBS-1];

    integer i;
    integer selected;

    function [8:0] spawn_period(input [1:0] d, input [15:0] sec);
        reg [8:0] base;
        begin
            case (d)
                `DIFF_EASY  : base = 9'd210;
                `DIFF_NORMAL: base = 9'd160;
                `DIFF_HARD  : base = 9'd115;
                `DIFF_HELL  : base = 9'd80;
                default     : base = 9'd180;
            endcase
            spawn_period = (base > {2'b00, sec[8:2]}) ? (base - {2'b00, sec[8:2]}) : 9'd35;
        end
    endfunction

    assign obs_destroyed_any = |destroyed;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            spawn <= {MAX_OBS{1'b0}};
            spawn_cnt <= 9'd0;
            obs_hit_player_any <= 1'b0;
            obs_player_damage <= 2'b00;
        end else begin
            spawn <= {MAX_OBS{1'b0}};
            obs_hit_player_any <= |obs_hit_player;
            obs_player_damage <= 2'b00;
            for (i = 0; i < MAX_OBS; i = i + 1) begin
                if (obs_hit_player[i])
                    obs_player_damage <= damage_w[i];
            end

            if (frame_tick && game_run) begin
                if (spawn_cnt >= spawn_period(difficulty, play_time_sec)) begin
                    spawn_cnt <= 9'd0;
                    selected = 0;
                    for (i = 0; i < MAX_OBS; i = i + 1) begin
                        if (!obs_active[i] && (selected == 0)) begin
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
        for (gi = 0; gi < MAX_OBS; gi = gi + 1) begin : g_obstacle
            obstacle #(.OID(gi)) u_obstacle (
                .clk(clk),
                .rstn(rstn),
                .frame_tick(frame_tick),
                .game_run(game_run),
                .difficulty(difficulty),
                .rng(rng ^ (gi * 16'h0101)),
                .spawn(spawn[gi]),
                .spawn_x(10'd24 + ((rng + gi * 23) % 10'd592)),
                .hit_pbullet(obs_hit_pbullet[gi]),
                .hit_player(obs_hit_player[gi]),
                .active(obs_active[gi]),
                .size(),
                .ox(obs_x[gi]),
                .oy(obs_y[gi]),
                .hp(),
                .radius(obs_rad[gi]),
                .destroyed_pulse(destroyed[gi]),
                .player_damage(damage_w[gi])
            );
        end
    endgenerate

endmodule
