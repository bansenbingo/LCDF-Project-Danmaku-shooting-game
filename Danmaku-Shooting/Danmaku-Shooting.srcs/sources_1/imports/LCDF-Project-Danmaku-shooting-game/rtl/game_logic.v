//==============================================================================
// game_logic.v — Core game state machine, entity management, collision detection
// 60Hz frame_tick driven gameplay. Coordinates follow ZJU VGA: X=0..639, Y=0..479.
//==============================================================================
`include "game_defs.vh"

module game_logic (
    input  wire        clk,
    input  wire        rstn,
    input  wire        frame_tick,

    input  wire [4:0]  btn,         // {BTNX4, BTN[3:0]}
    input  wire [7:0]  ps2_scan,
    input  wire        ps2_ready,
    input  wire [15:0] sw,

    output reg  [9:0]  pl_x,
    output reg  [8:0]  pl_y,
    output reg         pl_active,
    output reg         pl_flash,

    output reg  [2:0]  game_state,
    output reg  [19:0] score,
    output reg  [7:0]  kills,
    output wire [2:0]  lives,
    output reg  [1:0]  difficulty,
    output reg         mode,

    output reg  [7:0]  en_active,
    output reg  [79:0] en_x,
    output reg  [71:0] en_y,
    output reg  [15:0] en_hp,

    output reg  [15:0]  pb_active,
    output reg  [159:0] pb_x,
    output reg  [143:0] pb_y,
    output reg  [31:0]  pb_type,

    output reg  [63:0]  eb_active,
    output reg  [639:0] eb_x,
    output reg  [575:0] eb_y,
    output reg  [127:0] eb_type,

    output reg  [7:0]  ob_active,
    output reg  [79:0] ob_x,
    output reg  [71:0] ob_y,
    output reg  [15:0] ob_size,
    output reg  [15:0] ob_shape,

    output reg  [15:0] seg_data,
    output reg  [1:0]  seg_mode,
    output reg  [7:0]  led
);
    // Frame tick edge in 100MHz domain
    reg ft_d;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) ft_d <= 1'b0;
        else       ft_d <= frame_tick;
    end
    wire tick = frame_tick && !ft_d;

    // PS/2 event synchronizer and held key state. ps2_keyboard marks break by scan_code[7]=1.
    reg ps2_ready_d;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) ps2_ready_d <= 1'b0;
        else       ps2_ready_d <= ps2_ready;
    end
    wire ps2_evt = ps2_ready && !ps2_ready_d;
    wire ps2_break = ps2_scan[7];
    wire [7:0] ps2_code = {1'b0, ps2_scan[6:0]};
    wire ps2_make = ps2_evt && !ps2_break;

    reg key_w, key_a, key_s, key_d, key_j, key_spc, key_ent, key_k, key_p;
    reg key_1, key_2, key_3, key_4;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            key_w <= 0; key_a <= 0; key_s <= 0; key_d <= 0;
            key_j <= 0; key_spc <= 0; key_ent <= 0; key_k <= 0; key_p <= 0;
            key_1 <= 0; key_2 <= 0; key_3 <= 0; key_4 <= 0;
        end else if (ps2_evt) begin
            case (ps2_code)
                8'h1D: key_w   <= !ps2_break; // W
                8'h1C: key_a   <= !ps2_break; // A
                8'h1B: key_s   <= !ps2_break; // S
                8'h23: key_d   <= !ps2_break; // D
                8'h3B: key_j   <= !ps2_break; // J
                8'h29: key_spc <= !ps2_break; // Space
                8'h5A: key_ent <= !ps2_break; // Enter
                8'h42: key_k   <= !ps2_break; // K
                8'h4D: key_p   <= !ps2_break; // P
                8'h16: key_1   <= !ps2_break; // 1
                8'h1E: key_2   <= !ps2_break; // 2
                8'h26: key_3   <= !ps2_break; // 3
                8'h25: key_4   <= !ps2_break; // 4
                default: ;
            endcase
        end
    end

    wire btn_up    = btn[0];
    wire btn_down  = btn[1];
    wire btn_left  = btn[2];
    wire btn_right = btn[3];
    wire btn_fire  = btn[4];

    wire move_up    = btn_up    | key_w;
    wire move_down  = btn_down  | key_s;
    wire move_left  = btn_left  | key_a;
    wire move_right = btn_right | key_d;
    wire fire_key   = btn_fire  | key_j | key_spc | key_ent;
    wire start_key  = btn_fire  | key_j | key_spc | key_ent;
    wire pause_key  = key_p;
    wire cycle_key  = key_k;

    reg btn_fire_d, key_p_d, key_k_d;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            btn_fire_d <= 0; key_p_d <= 0; key_k_d <= 0;
        end else begin
            btn_fire_d <= btn_fire;
            key_p_d    <= key_p;
            key_k_d    <= key_k;
        end
    end
    wire fire_pulse  = (btn_fire & !btn_fire_d) | (ps2_make && (ps2_code == 8'h3B || ps2_code == 8'h29 || ps2_code == 8'h5A));
    wire start_pulse = fire_pulse;
    wire pause_pulse = (key_p & !key_p_d) | (ps2_make && ps2_code == 8'h4D);
    wire cycle_pulse = (key_k & !key_k_d) | (ps2_make && ps2_code == 8'h42);

    wire cheat_ok = sw[2] && sw[3] && sw[5] && sw[7] && sw[11] && sw[13] &&
                    !sw[0] && !sw[1] && !sw[4] && !sw[6] && !sw[8] && !sw[9] &&
                    !sw[10] && !sw[12] && !sw[14] && !sw[15];

    reg [2:0]  state;
    reg [10:0] state_timer, game_time;
    reg [8:0]  en_spawn_timer, ob_spawn_timer;
    reg [2:0]  en_spawn_idx, ob_spawn_idx;
    reg [7:0]  pause_cooldown, surv_cnt;
    reg [1:0]  sel_diff, sel_mode_dummy;
    reg        sel_mode;
    reg [2:0]  pl_hp;
    reg [1:0]  pl_weapon;
    reg [7:0]  pl_inv;
    reg [4:0]  pl_fire_cd;
    reg        pl_alive;
    reg [19:0] total_score;
    reg [7:0]  total_kills;
    reg [15:0] lfsr;
    reg [1:0]  seg_cycle;

    reg [7:0]   en_act;
    reg [79:0]  en_x_r;
    reg [71:0]  en_y_r;
    reg [15:0]  en_hp_r;
    reg [7:0]   en_dir;
    reg [63:0]  en_fire_cd;
    reg [15:0]  pb_act;
    reg [159:0] pb_x_r;
    reg [143:0] pb_y_r;
    reg [63:0]  eb_act;
    reg [639:0] eb_x_r;
    reg [575:0] eb_y_r;
    reg [7:0]   ob_act;
    reg [79:0]  ob_x_r;
    reg [71:0]  ob_y_r;
    reg [15:0]  ob_size_r, ob_shape_r, ob_hp_r;

    integer i, j, k, bi;
    reg fired_left, fired_right, fired_center;
    reg hit_player;
    reg [9:0] tmpx;
    reg [8:0] tmpy;
    reg [1:0] diff_fire_bonus;

    task reset_entities;
    begin
        en_act <= 8'd0; pb_act <= 16'd0; eb_act <= 64'd0; ob_act <= 8'd0;
        en_x_r <= 80'd0; en_y_r <= 72'd0; en_hp_r <= 16'd0; en_fire_cd <= 64'd0;
        pb_x_r <= 160'd0; pb_y_r <= 144'd0;
        eb_x_r <= 640'd0; eb_y_r <= 576'd0;
        ob_x_r <= 80'd0; ob_y_r <= 72'd0; ob_size_r <= 16'd0; ob_shape_r <= 16'd0; ob_hp_r <= 16'd0;
    end
    endtask

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= `STATE_MENU;
            state_timer <= 0; game_time <= 0; pause_cooldown <= 0;
            sel_diff <= `DIFF_NORMAL; sel_mode <= 1'b0;
            difficulty <= `DIFF_NORMAL; mode <= 1'b0;
            pl_x <= 10'd320; pl_y <= 9'd432; pl_hp <= 3'd3; pl_weapon <= 0;
            pl_inv <= 0; pl_fire_cd <= 0; pl_alive <= 1'b1; pl_flash <= 1'b1;
            total_score <= 0; total_kills <= 0; surv_cnt <= 0;
            en_spawn_timer <= 0; ob_spawn_timer <= 0; en_spawn_idx <= 0; ob_spawn_idx <= 0;
            lfsr <= 16'hACE1; seg_cycle <= `SEGMODE_KILLS;
            reset_entities();
            game_state <= `STATE_MENU; score <= 0; kills <= 0;
            pl_active <= 1'b1; seg_data <= 0; seg_mode <= 0; led <= 0;
            en_active <= 0; en_x <= 0; en_y <= 0; en_hp <= 0;
            pb_active <= 0; pb_x <= 0; pb_y <= 0; pb_type <= 0;
            eb_active <= 0; eb_x <= 0; eb_y <= 0; eb_type <= 0;
            ob_active <= 0; ob_x <= 0; ob_y <= 0; ob_size <= 0; ob_shape <= 0;
        end else begin
            if (tick) begin
                lfsr <= {lfsr[14:0], 1'b0} ^ ({16{lfsr[15]}} & 16'hB400);
                if (pause_cooldown != 0) pause_cooldown <= pause_cooldown - 8'd1;
                if (cycle_pulse) seg_cycle <= (seg_cycle == `SEGMODE_SCORE) ? `SEGMODE_KILLS : seg_cycle + 2'd1;

                case (state)
                `STATE_MENU: begin
                    reset_entities();
                    pl_alive <= 1'b1;
                    pl_x <= 10'd320; pl_y <= 9'd432; pl_flash <= 1'b1; pl_inv <= 0;
                    total_score <= 0; total_kills <= 0; surv_cnt <= 0; game_time <= 0;
                    en_spawn_timer <= 0; ob_spawn_timer <= 0; en_spawn_idx <= 0; ob_spawn_idx <= 0;
                    pl_weapon <= 0; pl_fire_cd <= 0;
                    if (key_1) sel_diff <= `DIFF_EASY;
                    if (key_2) sel_diff <= `DIFF_NORMAL;
                    if (key_3) sel_diff <= `DIFF_HARD;
                    if (key_4) sel_diff <= `DIFF_HELL;
                    sel_mode <= sw[0];
                    pl_hp <= cheat_ok ? 3'd7 : 3'd3;
                    if (start_pulse || start_key) begin
                        state <= `STATE_PLAYING;
                        state_timer <= `GRACE_PERIOD;
                        difficulty <= sel_diff;
                        mode <= sel_mode;
                        pl_hp <= cheat_ok ? 3'd7 : (sel_diff == `DIFF_HELL ? 3'd2 : 3'd3);
                    end
                end

                `STATE_PLAYING: begin
                    if (state_timer != 0) state_timer <= state_timer - 11'd1;
                    game_time <= game_time + 11'd1;

                    if (pause_pulse && pause_cooldown == 0) begin
                        state <= `STATE_PAUSED;
                        pause_cooldown <= 8'd240;
                    end

                    // 玩家移动：持续按键生效，限制在可见区内，避免贴边看不完整。
                    if (pl_alive) begin
                        if (move_up    && pl_y > 9'd28)  pl_y <= pl_y - `PLAYER_SPEED;
                        if (move_down  && pl_y < 9'd456) pl_y <= pl_y + `PLAYER_SPEED;
                        if (move_left  && pl_x > 10'd20) pl_x <= pl_x - `PLAYER_SPEED;
                        if (move_right && pl_x < 10'd620)pl_x <= pl_x + `PLAYER_SPEED;
                    end

                    if (pl_inv != 0) begin
                        pl_inv <= pl_inv - 8'd1;
                        pl_flash <= pl_inv[4];
                    end else begin
                        pl_flash <= 1'b1;
                    end

                    // 发射：在 16 个槽位中寻找空闲槽，双发不会因槽0/1未回收而卡死。
                    if (pl_fire_cd != 0) pl_fire_cd <= pl_fire_cd - 5'd1;
                    if (fire_key && pl_fire_cd == 0 && pl_alive) begin
                        fired_left = 1'b0; fired_right = 1'b0; fired_center = 1'b0;
                        for (i = 0; i < 16; i = i + 1) begin
                            if (!pb_act[i] && !fired_left) begin
                                pb_act[i] <= 1'b1;
                                pb_x_r[i*10 +: 10] <= pl_x - 10'd7;
                                pb_y_r[i*9 +: 9] <= pl_y - 9'd18;
                                fired_left = 1'b1;
                            end else if (!pb_act[i] && !fired_right) begin
                                pb_act[i] <= 1'b1;
                                pb_x_r[i*10 +: 10] <= pl_x + 10'd7;
                                pb_y_r[i*9 +: 9] <= pl_y - 9'd18;
                                fired_right = 1'b1;
                            end else if (pl_weapon >= 2'd2 && !pb_act[i] && !fired_center) begin
                                pb_act[i] <= 1'b1;
                                pb_x_r[i*10 +: 10] <= pl_x;
                                pb_y_r[i*9 +: 9] <= pl_y - 9'd22;
                                fired_center = 1'b1;
                            end
                        end
                        pl_fire_cd <= (`PLAYER_FIRE_RATE > {3'd0, pl_weapon}) ? (`PLAYER_FIRE_RATE - {3'd0, pl_weapon}) : 5'd3;
                    end

                    for (i = 0; i < 16; i = i + 1) begin
                        if (pb_act[i]) begin
                            if (pb_y_r[i*9 +: 9] <= 9'd8) pb_act[i] <= 1'b0;
                            else pb_y_r[i*9 +: 9] <= pb_y_r[i*9 +: 9] - `PLAYER_BULLET_SPD;
                        end
                    end

                    // 敌机生成：X 坐标限制在 [32, 608]，不再随机贴边导致显示不完整。
                    if (state_timer == 0) begin
                        if (en_spawn_timer != 0) en_spawn_timer <= en_spawn_timer - 9'd1;
                        else begin
                            if (!en_act[en_spawn_idx]) begin
                                en_act[en_spawn_idx] <= 1'b1;
                                en_x_r[en_spawn_idx*10 +: 10] <= 10'd32 + ({4'd0, lfsr[5:0]} * 10'd9);
                                en_y_r[en_spawn_idx*9 +: 9] <= 9'd18;
                                en_hp_r[en_spawn_idx*2 +: 2] <= (difficulty >= `DIFF_HARD) ? 2'd2 : 2'd1;
                                en_fire_cd[en_spawn_idx*8 +: 8] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[5:0]};
                                en_dir[en_spawn_idx] <= lfsr[6];
                            end
                            en_spawn_idx <= en_spawn_idx + 3'd1;
                            en_spawn_timer <= (difficulty == `DIFF_EASY) ? 9'd130 :
                                              (difficulty == `DIFF_NORMAL) ? 9'd100 :
                                              (difficulty == `DIFF_HARD) ? 9'd75 : 9'd55;
                        end
                    end

                    // 所有敌机都更新位置和开火，不再只有前3架有效。
                    diff_fire_bonus = (difficulty == `DIFF_EASY) ? 2'd0 :
                                      (difficulty == `DIFF_NORMAL) ? 2'd1 : 2'd2;
                    for (i = 0; i < 8; i = i + 1) begin
                        if (en_act[i]) begin
                            if (en_y_r[i*9 +: 9] < 9'd105) en_y_r[i*9 +: 9] <= en_y_r[i*9 +: 9] + 9'd1;
                            if (game_time[3:0] == i[3:0]) begin
                                if (en_dir[i]) begin
                                    if (en_x_r[i*10 +: 10] < 10'd608) en_x_r[i*10 +: 10] <= en_x_r[i*10 +: 10] + 10'd2;
                                    else en_dir[i] <= 1'b0;
                                end else begin
                                    if (en_x_r[i*10 +: 10] > 10'd32) en_x_r[i*10 +: 10] <= en_x_r[i*10 +: 10] - 10'd2;
                                    else en_dir[i] <= 1'b1;
                                end
                            end

                            if (en_fire_cd[i*8 +: 8] != 0) begin
                                en_fire_cd[i*8 +: 8] <= en_fire_cd[i*8 +: 8] - 8'd1;
                            end else begin
                                for (j = 0; j < 8; j = j + 1) begin
                                    bi = i*8 + j;
                                    if (!eb_act[bi] && j <= (1 + diff_fire_bonus)) begin
                                        eb_act[bi] <= 1'b1;
                                        eb_x_r[bi*10 +: 10] <= en_x_r[i*10 +: 10] + ({7'd0, j[2:0]} * 10'd6) - 10'd9;
                                        eb_y_r[bi*9 +: 9] <= en_y_r[i*9 +: 9] + 9'd10;
                                    end
                                end
                                en_fire_cd[i*8 +: 8] <= (difficulty == `DIFF_EASY) ? 8'd80 :
                                                         (difficulty == `DIFF_NORMAL) ? 8'd62 :
                                                         (difficulty == `DIFF_HARD) ? 8'd48 : 8'd36;
                            end
                        end
                    end

                    for (i = 0; i < 64; i = i + 1) begin
                        if (eb_act[i]) begin
                            if (eb_y_r[i*9 +: 9] >= 9'd474) eb_act[i] <= 1'b0;
                            else eb_y_r[i*9 +: 9] <= eb_y_r[i*9 +: 9] + (`ENEMY_BULLET_SPD + {7'd0, difficulty[0]});
                        end
                    end

                    // 障碍物生成/移动
                    if (state_timer == 0) begin
                        if (ob_spawn_timer != 0) ob_spawn_timer <= ob_spawn_timer - 9'd1;
                        else begin
                            if (!ob_act[ob_spawn_idx]) begin
                                ob_act[ob_spawn_idx] <= 1'b1;
                                ob_x_r[ob_spawn_idx*10 +: 10] <= 10'd30 + ({4'd0, lfsr[11:6]} * 10'd9);
                                ob_y_r[ob_spawn_idx*9 +: 9] <= 9'd28;
                                ob_size_r[ob_spawn_idx*2 +: 2] <= (difficulty == `DIFF_EASY) ? 2'd0 : lfsr[15:14];
                                ob_shape_r[ob_spawn_idx*2 +: 2] <= lfsr[1:0];
                                ob_hp_r[ob_spawn_idx*2 +: 2] <= 2'd1 + lfsr[13:12];
                            end
                            ob_spawn_idx <= ob_spawn_idx + 3'd1;
                            ob_spawn_timer <= (difficulty >= `DIFF_HARD) ? 9'd180 : 9'd260;
                        end
                    end
                    if (game_time[4:0] == 0) begin
                        for (i = 0; i < 8; i = i + 1) begin
                            if (ob_act[i]) begin
                                if (ob_y_r[i*9 +: 9] >= 9'd468) ob_act[i] <= 1'b0;
                                else ob_y_r[i*9 +: 9] <= ob_y_r[i*9 +: 9] + 9'd1;
                            end
                        end
                    end

                    // 碰撞：玩家子弹 vs 所有敌机/障碍物。
                    for (i = 0; i < 16; i = i + 1) begin
                        if (pb_act[i]) begin
                            for (j = 0; j < 8; j = j + 1) begin
                                if (en_act[j] &&
                                    pb_x_r[i*10 +: 10] >= en_x_r[j*10 +: 10] - 10'd16 &&
                                    pb_x_r[i*10 +: 10] <= en_x_r[j*10 +: 10] + 10'd16 &&
                                    pb_y_r[i*9 +: 9]  >= en_y_r[j*9 +: 9] - 9'd12 &&
                                    pb_y_r[i*9 +: 9]  <= en_y_r[j*9 +: 9] + 9'd12) begin
                                    pb_act[i] <= 1'b0;
                                    if (en_hp_r[j*2 +: 2] <= 2'd1) begin
                                        en_act[j] <= 1'b0;
                                        total_score <= total_score + 20'd5;
                                        total_kills <= total_kills + 8'd1;
                                    end else begin
                                        en_hp_r[j*2 +: 2] <= en_hp_r[j*2 +: 2] - 2'd1;
                                    end
                                end
                                if (ob_act[j] &&
                                    pb_x_r[i*10 +: 10] >= ob_x_r[j*10 +: 10] - 10'd20 &&
                                    pb_x_r[i*10 +: 10] <= ob_x_r[j*10 +: 10] + 10'd20 &&
                                    pb_y_r[i*9 +: 9]  >= ob_y_r[j*9 +: 9] - 9'd20 &&
                                    pb_y_r[i*9 +: 9]  <= ob_y_r[j*9 +: 9] + 9'd20) begin
                                    pb_act[i] <= 1'b0;
                                    if (ob_hp_r[j*2 +: 2] <= 2'd1) ob_act[j] <= 1'b0;
                                    else ob_hp_r[j*2 +: 2] <= ob_hp_r[j*2 +: 2] - 2'd1;
                                end
                            end
                        end
                    end

                    // 敌弹/敌机/障碍物 vs 玩家。
                    hit_player = 1'b0;
                    if (pl_alive && pl_inv == 0 && !cheat_ok) begin
                        for (i = 0; i < 64; i = i + 1) begin
                            if (eb_act[i] && eb_x_r[i*10 +: 10] >= pl_x - 10'd10 && eb_x_r[i*10 +: 10] <= pl_x + 10'd10 &&
                                eb_y_r[i*9 +: 9] >= pl_y - 9'd14 && eb_y_r[i*9 +: 9] <= pl_y + 9'd14) begin
                                eb_act[i] <= 1'b0;
                                hit_player = 1'b1;
                            end
                        end
                        for (i = 0; i < 8; i = i + 1) begin
                            if ((en_act[i] && pl_x >= en_x_r[i*10 +: 10] - 10'd16 && pl_x <= en_x_r[i*10 +: 10] + 10'd16 &&
                                             pl_y >= en_y_r[i*9 +: 9] - 9'd12 && pl_y <= en_y_r[i*9 +: 9] + 9'd12) ||
                                (ob_act[i] && pl_x >= ob_x_r[i*10 +: 10] - 10'd20 && pl_x <= ob_x_r[i*10 +: 10] + 10'd20 &&
                                             pl_y >= ob_y_r[i*9 +: 9] - 9'd20 && pl_y <= ob_y_r[i*9 +: 9] + 9'd20)) begin
                                hit_player = 1'b1;
                                if (ob_act[i]) ob_act[i] <= 1'b0;
                            end
                        end
                    end
                    if (hit_player) begin
                        if (pl_hp <= 3'd1) begin
                            pl_hp <= 3'd0; pl_alive <= 1'b0;
                            state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                            pb_act <= 16'd0; eb_act <= 64'd0; en_act <= 8'd0; ob_act <= 8'd0;
                        end else begin
                            pl_hp <= pl_hp - 3'd1;
                            pl_x <= 10'd320; pl_y <= 9'd432;
                            pl_inv <= `PLAYER_INV_TIME;
                            eb_act <= 64'd0;
                        end
                    end

                    // 生存得分与自动升级
                    surv_cnt <= surv_cnt + 8'd1;
                    if (surv_cnt == 8'd59) begin
                        surv_cnt <= 8'd0;
                        total_score <= total_score + 20'd1;
                    end
                    if (total_kills >= 8'd10 && pl_weapon < 2'd1) pl_weapon <= 2'd1;
                    else if (total_kills >= 8'd25 && pl_weapon < 2'd2) pl_weapon <= 2'd2;
                    else if (total_kills >= 8'd50 && pl_weapon < 2'd3) pl_weapon <= 2'd3;

                    if (!mode && total_score >= `SCORE_WIN_TARGET && pl_alive) begin
                        state <= `STATE_WIN;
                        state_timer <= `WIN_DISPLAY;
                        pb_act <= 16'd0; eb_act <= 64'd0; en_act <= 8'd0; ob_act <= 8'd0;
                    end
                end

                `STATE_PAUSED: begin
                    if ((pause_pulse || fire_pulse) && pause_cooldown == 0) begin
                        state <= `STATE_PLAYING;
                        pause_cooldown <= 8'd120;
                    end
                end

                `STATE_GAMEOVER: begin
                    if (state_timer != 0) state_timer <= state_timer - 11'd1;
                    else state <= `STATE_MENU;
                end

                `STATE_WIN: begin
                    if (state_timer != 0) state_timer <= state_timer - 11'd1;
                    else state <= `STATE_MENU;
                end

                default: state <= `STATE_MENU;
                endcase
            end

            // Outputs and displays
            game_state <= state;
            score      <= total_score;
            kills      <= total_kills;
            pl_active  <= pl_alive;
            seg_mode   <= seg_cycle;
            difficulty <= (state == `STATE_MENU) ? sel_diff : difficulty;
            mode       <= (state == `STATE_MENU) ? sw[0] : mode;

            en_active <= en_act; en_x <= en_x_r; en_y <= en_y_r; en_hp <= en_hp_r;
            pb_active <= pb_act; pb_x <= pb_x_r; pb_y <= pb_y_r; pb_type <= 32'd0;
            eb_active <= eb_act; eb_x <= eb_x_r; eb_y <= eb_y_r; eb_type <= 128'd0;
            ob_active <= ob_act; ob_x <= ob_x_r; ob_y <= ob_y_r; ob_size <= ob_size_r; ob_shape <= ob_shape_r;

            case (seg_cycle)
                `SEGMODE_KILLS: seg_data <= {8'd0, total_kills};
                `SEGMODE_LIVES: seg_data <= {13'd0, pl_hp};
                default:        seg_data <= total_score[15:0];
            endcase
            if (seg_cycle == `SEGMODE_SCORE && total_score > 20'd9999) led <= total_score[19:12];
            else led <= 8'd0;
        end
    end

    assign lives = pl_hp;
endmodule
