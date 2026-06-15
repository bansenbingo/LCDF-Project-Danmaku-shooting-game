// =============================================================================
//  collision.v
//  Frame-locked collision detector for bullets, enemies, obstacles and player.
// =============================================================================
`include "game_defs.vh"

module collision (
    input  wire          clk,
    input  wire          rstn,
    input  wire          frame_tick,
    input  wire          game_run,

    input  wire [9:0]    player_px,
    input  wire [9:0]    player_py,
    input  wire [4:0]    player_w,
    input  wire [4:0]    player_h,
    input  wire          player_alive,
    input  wire          player_reviving,

    input  wire [63:0]   bul_active,
    input  wire [9:0]    bul_x[63:0],
    input  wire [9:0]    bul_y[63:0],
    input  wire          bul_is_pbullet[63:0],

    input  wire [15:0]   en_active,
    input  wire [9:0]    en_x[15:0],
    input  wire [9:0]    en_y[15:0],

    input  wire [15:0]   obs_active,
    input  wire [9:0]    obs_x[15:0],
    input  wire [9:0]    obs_y[15:0],
    input  wire [9:0]    obs_rad[15:0],

    output reg           player_hit_bullet,
    output reg           player_hit_obstacle,
    output reg  [1:0]    player_obs_damage,
    output reg  [15:0]   en_hit,
    output reg  [15:0]   obs_hit_pbullet,
    output reg  [15:0]   obs_hit_player,
    output reg  [63:0]   bul_kill
);

    integer bi;
    integer ei;
    integer oi;

    reg          c_player_hit_bullet;
    reg          c_player_hit_obstacle;
    reg [1:0]    c_player_obs_damage;
    reg [15:0]   c_en_hit;
    reg [15:0]   c_obs_hit_pbullet;
    reg [15:0]   c_obs_hit_player;
    reg [63:0]   c_bul_kill;

    function rect_hit;
        input [9:0] ax;
        input [9:0] ay;
        input [9:0] aw;
        input [9:0] ah;
        input [9:0] bx;
        input [9:0] by;
        input [9:0] bw;
        input [9:0] bh;
        begin
            rect_hit = (ax + aw > bx) && (bx + bw > ax) &&
                       (ay + ah > by) && (by + bh > ay);
        end
    endfunction

    function circle_rect_hit;
        input [9:0] cx;
        input [9:0] cy;
        input [9:0] cr;
        input [9:0] rx;
        input [9:0] ry;
        input [9:0] rw;
        input [9:0] rh;
        reg [9:0] near_x;
        reg [9:0] near_y;
        reg signed [10:0] dx;
        reg signed [10:0] dy;
        reg [31:0] dist2;
        begin
            near_x = (cx < rx) ? rx : ((cx > rx + rw) ? (rx + rw) : cx);
            near_y = (cy < ry) ? ry : ((cy > ry + rh) ? (ry + rh) : cy);
            dx = $signed({1'b0, cx}) - $signed({1'b0, near_x});
            dy = $signed({1'b0, cy}) - $signed({1'b0, near_y});
            dist2 = dx * dx + dy * dy;
            circle_rect_hit = (dist2 <= cr * cr);
        end
    endfunction

    function [1:0] damage_from_radius;
        input [9:0] radius;
        begin
            if (radius <= `OBS_S_R)
                damage_from_radius = 2'b01;
            else if (radius <= `OBS_M_R)
                damage_from_radius = 2'b10;
            else
                damage_from_radius = 2'b11;
        end
    endfunction

    always @* begin
        c_player_hit_bullet   = 1'b0;
        c_player_hit_obstacle = 1'b0;
        c_player_obs_damage   = 2'b00;
        c_en_hit              = 16'd0;
        c_obs_hit_pbullet     = 16'd0;
        c_obs_hit_player      = 16'd0;
        c_bul_kill            = 64'd0;

        if (game_run) begin
            for (bi = 0; bi < 64; bi = bi + 1) begin
                if (bul_active[bi]) begin
                    if (bul_is_pbullet[bi]) begin
                        for (ei = 0; ei < 16; ei = ei + 1) begin
                            if (en_active[ei] && !c_bul_kill[bi] &&
                                rect_hit(bul_x[bi], bul_y[bi], `BULLET_W, `BULLET_H,
                                         en_x[ei] - (`ENEMY_W/2), en_y[ei] - (`ENEMY_H/2), `ENEMY_W, `ENEMY_H)) begin
                                c_en_hit[ei] = 1'b1;
                                c_bul_kill[bi] = 1'b1;
                            end
                        end

                        for (oi = 0; oi < 16; oi = oi + 1) begin
                            if (obs_active[oi] && !c_bul_kill[bi] &&
                                circle_rect_hit(obs_x[oi], obs_y[oi], obs_rad[oi],
                                                bul_x[bi], bul_y[bi], `BULLET_W, `BULLET_H)) begin
                                c_obs_hit_pbullet[oi] = 1'b1;
                                c_bul_kill[bi] = 1'b1;
                            end
                        end
                    end else if (player_alive && !player_reviving &&
                                 rect_hit(bul_x[bi], bul_y[bi], `BULLET_W, `BULLET_H,
                                          player_px - (player_w/2), player_py - (player_h/2), player_w, player_h)) begin
                        c_player_hit_bullet = 1'b1;
                        c_bul_kill[bi] = 1'b1;
                    end
                end
            end

            if (player_alive && !player_reviving) begin
                for (oi = 0; oi < 16; oi = oi + 1) begin
                    if (obs_active[oi] && circle_rect_hit(obs_x[oi], obs_y[oi], obs_rad[oi],
                                                          player_px - (player_w/2), player_py - (player_h/2), player_w, player_h)) begin
                        c_player_hit_obstacle = 1'b1;
                        c_obs_hit_player[oi] = 1'b1;
                        c_player_obs_damage = damage_from_radius(obs_rad[oi]);
                    end
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            player_hit_bullet   <= 1'b0;
            player_hit_obstacle <= 1'b0;
            player_obs_damage   <= 2'b00;
            en_hit              <= 16'd0;
            obs_hit_pbullet     <= 16'd0;
            obs_hit_player      <= 16'd0;
            bul_kill            <= 64'd0;
        end else if (frame_tick) begin
            player_hit_bullet   <= c_player_hit_bullet;
            player_hit_obstacle <= c_player_hit_obstacle;
            player_obs_damage   <= c_player_obs_damage;
            en_hit              <= c_en_hit;
            obs_hit_pbullet     <= c_obs_hit_pbullet;
            obs_hit_player      <= c_obs_hit_player;
            bul_kill            <= c_bul_kill;
        end else begin
            player_hit_bullet   <= 1'b0;
            player_hit_obstacle <= 1'b0;
            player_obs_damage   <= 2'b00;
            en_hit              <= 16'd0;
            obs_hit_pbullet     <= 16'd0;
            obs_hit_player      <= 16'd0;
            bul_kill            <= 64'd0;
        end
    end

endmodule
