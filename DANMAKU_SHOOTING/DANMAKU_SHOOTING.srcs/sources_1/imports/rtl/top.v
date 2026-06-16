// =============================================================================
//  top.v
//  Complete game integration top level.
// =============================================================================
`include "game_defs.vh"

module top (
    input  wire         clk,
    input  wire         rstn,
    input  wire [3:0]   BTNX0Y0,
    input  wire [3:0]   BTNX0Y1,
    input  wire [3:0]   BTNX0Y2,
    input  wire [3:0]   BTNX0Y3,
    input  wire [3:0]   BTNX1,
    input  wire [3:0]   BTNX2,
    input  wire [3:0]   BTNX3,
    input  wire [3:0]   BTNX4,
    input  wire [15:0]  SW,
    output wire [3:0]   r,
    output wire [3:0]   g,
    output wire [3:0]   b,
    output wire         hs,
    output wire         vs,
    output wire [7:0]   SEGMENT,
    output wire [3:0]   AN,
    output wire [7:0]   LED
);

    wire [19:0] btn_raw = {BTNX4, BTNX3, BTNX2, BTNX1, BTNX0Y0};
    wire [19:0] btn_out;
    wire [19:0] btn_pulse;

    btn_debounce #(.N(20)) u_btn_debounce (
        .clk(clk), .rstn(rstn), .btn_in(btn_raw), .btn_out(btn_out), .btn_pulse(btn_pulse)
    );

    wire frame_tick;
    wire [2:0] game_state;
    wire game_run;
    wire entity_update;
    wire menu_active;
    wire [1:0] difficulty_sel;
    wire cheat;
    wire pause_5s_lock;
    wire player_dead;
    wire target_reached;
    wire [15:0] score;
    wire [15:0] kills;
    wire [15:0] obstacles_destroyed;
    wire [31:0] play_time_sec;
    wire score_mode = SW[0];

    game_fsm u_game_fsm (
        .clk(clk), .rstn(rstn), .frame_tick(frame_tick),
        .btn_out(btn_out), .btn_pulse(btn_pulse), .sw(SW),
        .player_dead(player_dead), .target_reached(target_reached), .score_mode({1'b0, score_mode}),
        .state(game_state), .game_run(game_run), .entity_update(entity_update), .menu_active(menu_active),
        .difficulty_sel(difficulty_sel), .cheat(cheat), .pause_5s_lock(pause_5s_lock)
    );

    wire game_rstn = rstn && ((game_state == 3'd1) || (game_state == 3'd2));

    wire [15:0] rng;
    lfsr u_lfsr (.clk(clk), .rstn(rstn), .step(frame_tick), .rng(rng));

    wire [`X_BITS-1:0] player_px;
    wire [`Y_BITS-1:0] player_py;
    wire [3:0] lives;
    wire player_alive;
    wire player_reviving;
    wire player_visible;
    wire [1:0] weapon_lvl;
    wire player_fire;
    wire signed [`X_BITS:0] muzzle_lx_s;
    wire signed [`X_BITS:0] muzzle_rx_s;
    wire [`Y_BITS-1:0] muzzle_y;
    wire player_hit_bullet;
    wire player_hit_obstacle;
    wire [1:0] player_obs_damage;

    assign player_dead = !player_alive;

    player u_player (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .btn_up(btn_out[14]), .btn_down(btn_out[12]), .btn_left(btn_out[9]), .btn_right(btn_out[17]),
        .btn_fire(btn_out[19]), .btn_upgrade(btn_pulse[18]),
        .difficulty(difficulty_sel), .cheat(cheat), .kills(kills),
        .hit_bullet(player_hit_bullet), .hit_obstacle(player_obs_damage),
        .px(player_px), .py(player_py), .lives(lives), .alive(player_alive),
        .reviving(player_reviving), .visible(player_visible), .weapon_lvl(weapon_lvl),
        .fire_pulse(player_fire), .muzzle_lx(muzzle_lx_s), .muzzle_rx(muzzle_rx_s), .muzzle_y(muzzle_y)
    );

    wire [15:0] en_active;
    wire [9:0] en_x[15:0];
    wire [9:0] en_y[15:0];
    wire any_enemy_killed;
    wire [1:0] killed_hp;
    wire e_fire_req;
    wire [9:0] e_fire_x;
    wire [9:0] e_fire_y;
    wire [1:0] e_fire_traj;
    wire [2:0] e_fire_count;
    wire e_fire_dual;
    wire [15:0] en_hit;

    enemy_pool u_enemy_pool (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .difficulty(difficulty_sel), .rng(rng), .play_time_sec(play_time_sec[15:0]), .en_hit(en_hit),
        .en_active(en_active), .en_x(en_x), .en_y(en_y), .any_killed(any_enemy_killed), .killed_hp(killed_hp),
        .e_fire_req(e_fire_req), .e_fire_x(e_fire_x), .e_fire_y(e_fire_y), .e_fire_traj(e_fire_traj),
        .e_fire_count(e_fire_count), .e_fire_dual(e_fire_dual)
    );

    wire [15:0] obs_active;
    wire [9:0] obs_x[15:0];
    wire [9:0] obs_y[15:0];
    wire [9:0] obs_rad[15:0];
    wire [15:0] obs_hit_pbullet;
    wire [15:0] obs_hit_player;
    wire obs_hit_player_any;
    wire [1:0] obs_pool_damage;
    wire obs_destroyed_any;

    obstacle_pool u_obstacle_pool (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .difficulty(difficulty_sel), .rng(rng), .play_time_sec(play_time_sec[15:0]),
        .obs_hit_pbullet(obs_hit_pbullet), .obs_hit_player(obs_hit_player),
        .obs_active(obs_active), .obs_x(obs_x), .obs_y(obs_y), .obs_rad(obs_rad),
        .obs_hit_player_any(obs_hit_player_any), .obs_player_damage(obs_pool_damage),
        .obs_destroyed_any(obs_destroyed_any)
    );

    wire [63:0] bul_active;
    wire [11:0] bul_color[63:0];
    wire [9:0] bul_x[63:0];
    wire [9:0] bul_y[63:0];
    wire [`X_BITS-1:0] bul_w[63:0];
    wire [`Y_BITS-1:0] bul_h[63:0];
    wire bul_is_pbullet[63:0];
    wire [63:0] bul_kill;

    bullet_pool u_bullet_pool (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .clear_ebullets(player_hit_bullet || player_hit_obstacle), .bul_kill(bul_kill),
        .p_fire_pulse(player_fire), .p_muzzle_lx(muzzle_lx_s[9:0]), .p_muzzle_rx(muzzle_rx_s[9:0]), .p_muzzle_y(muzzle_y[9:0]),
        .e_fire_req(e_fire_req), .e_fire_x(e_fire_x), .e_fire_y(e_fire_y), .e_fire_traj(e_fire_traj),
        .e_fire_count(e_fire_count), .e_fire_dual(e_fire_dual), .difficulty(difficulty_sel),
        .bul_active(bul_active), .bul_color(bul_color), .bul_x(bul_x), .bul_y(bul_y),
        .bul_w(bul_w), .bul_h(bul_h), .bul_is_pbullet(bul_is_pbullet)
    );

    collision u_collision (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .player_px(player_px[9:0]), .player_py(player_py[9:0]), .player_w(`PLAYER_W), .player_h(`PLAYER_H),
        .player_alive(player_alive), .player_reviving(player_reviving),
        .bul_active(bul_active), .bul_x(bul_x), .bul_y(bul_y), .bul_is_pbullet(bul_is_pbullet),
        .en_active(en_active), .en_x(en_x), .en_y(en_y),
        .obs_active(obs_active), .obs_x(obs_x), .obs_y(obs_y), .obs_rad(obs_rad),
        .player_hit_bullet(player_hit_bullet), .player_hit_obstacle(player_hit_obstacle),
        .player_obs_damage(player_obs_damage), .en_hit(en_hit), .obs_hit_pbullet(obs_hit_pbullet),
        .obs_hit_player(obs_hit_player), .bul_kill(bul_kill)
    );

    score_keeper u_score_keeper (
        .clk(clk), .rstn(game_rstn), .frame_tick(frame_tick), .game_run(entity_update),
        .enemy_killed(any_enemy_killed), .enemy_hp(killed_hp), .obstacle_killed(obs_destroyed_any),
        .score(score), .kills(kills), .obstacles_destroyed(obstacles_destroyed),
        .target_reached(target_reached), .play_time_sec(play_time_sec)
    );

    vga_top u_vga_top (
        .clk_100m(clk), .rstn(rstn), .game_state(game_state), .difficulty_sel(difficulty_sel),
        .score_mode(score_mode), .score(score), .lives(lives), .kills(kills), .play_time_sec(play_time_sec[15:0]),
        .player_px(player_px), .player_py(player_py), .player_visible(player_visible),
        .en_active(en_active), .en_x(en_x), .en_y(en_y),
        .obs_active(obs_active), .obs_x(obs_x), .obs_y(obs_y), .obs_rad(obs_rad),
        .bul_active(bul_active), .bul_x(bul_x), .bul_y(bul_y), .bul_color(bul_color),
        .frame_tick(frame_tick), .r(r), .g(g), .b(b), .hs(hs), .vs(vs)
    );

    seg_display u_seg_display (
        .clk(clk), .rstn(rstn), .score(score), .kills(kills), .lives(lives),
        .game_state(game_state), .btn_pulse(btn_pulse), .SEGMENT(SEGMENT), .AN(AN), .LED(LED)
    );

endmodule
