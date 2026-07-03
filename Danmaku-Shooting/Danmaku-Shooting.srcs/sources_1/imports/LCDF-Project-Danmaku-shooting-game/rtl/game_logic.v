`include "game_defs.vh"

module game_logic (
    input  wire        clk,
    input  wire        rstn,
    input  wire        frame_tick,

    input  wire [7:0]  key_data,

    input  wire [3:0]  key_diff,
    input  wire        key_mode,
    input  wire        key_cycle,

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
    output reg  [7:0]  en_flash,

    output reg  [15:0] pb_active,
    output reg  [159:0] pb_x,
    output reg  [143:0] pb_y,
    output reg  [31:0]  pb_type,

    output reg  [63:0] eb_active,
    output reg  [639:0] eb_x,
    output reg  [575:0] eb_y,
    output reg  [127:0] eb_type,

    output reg  [15:0] seg_data,
    output reg  [1:0]  seg_mode,
    output reg  [7:0]  led
);

    reg keyP_d, keyK_d, keyM_d, keyC_d;
    always @(posedge clk) begin
        keyP_d <= key_data[6];
        keyK_d <= key_data[5];
        keyM_d <= key_mode;
        keyC_d <= key_cycle;
    end
    wire keyP_pos = key_data[6] && !keyP_d;
    wire keyK_pos = key_data[5] && !keyK_d;
    wire keyM_pos = key_mode   && !keyM_d;
    wire keyC_pos = key_cycle  && !keyC_d;

    reg ft_d; always @(posedge clk) ft_d <= frame_tick;
    wire tick = frame_tick && !ft_d;

    reg key_pause_latch, key_upg_latch, key_mode_latch, key_cyc_latch;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            key_pause_latch <= 1'b0;
            key_upg_latch   <= 1'b0;
            key_mode_latch  <= 1'b0;
            key_cyc_latch   <= 1'b0;
        end else begin
            if (keyP_pos)      key_pause_latch <= 1'b1; else if (tick) key_pause_latch <= 1'b0;
            if (keyK_pos)      key_upg_latch   <= 1'b1; else if (tick) key_upg_latch   <= 1'b0;
            if (keyM_pos)      key_mode_latch  <= 1'b1; else if (tick) key_mode_latch  <= 1'b0;
            if (keyC_pos)      key_cyc_latch   <= 1'b1; else if (tick) key_cyc_latch   <= 1'b0;
        end
    end

    wire move_up    = key_data[0];
    wire move_down  = key_data[1];
    wire move_left  = key_data[2];
    wire move_right = key_data[3];
    wire fire_key   = key_data[4];
    wire start_key  = key_data[4];
    wire slow_key   = key_data[7];

    wire pause_key   = key_pause_latch;
    wire upgrade_key = key_upg_latch;
    wire mode_toggle = key_mode_latch;
    wire cyc_toggle  = key_cyc_latch;

    reg [2:0]  state;
    reg [10:0] state_timer;
    reg [10:0] game_time;
    reg [7:0]  pause_cooldown;
    reg [1:0]  sel_diff;
    reg        sel_mode;
    reg [2:0]  pl_hp;
    reg [1:0]  pl_weapon;
    reg [7:0]  pl_inv;
    reg [4:0]  pl_fire_cd;
    reg        pl_alive;
    reg [19:0] total_score;
    reg [7:0]  total_kills;
    reg [7:0]  surv_cnt;
    reg [7:0]  next_kills_upg;
    reg [8:0]  en_spawn_timer;
    reg [2:0]  en_spawn_idx;
    reg [15:0] lfsr;
    reg [1:0]  seg_cycle;

    reg [7:0]  en_act;
    reg [79:0] en_x_r;
    reg [71:0] en_y_r;
    reg [15:0] en_hp_r;
    reg [7:0]  en_flash_r;
    reg [7:0]  en_dir;
    reg [63:0] en_fire_cd;
    reg [63:0] en_phase;

    reg [15:0] pb_act;
    reg [159:0] pb_x_r;
    reg [143:0] pb_y_r;

    reg [63:0] eb_act;
    reg [639:0] eb_x_r;
    reg [575:0] eb_y_r;

    function [9:0] get_en_x; input [2:0] i; begin get_en_x = en_x_r[i*10 +: 10]; end endfunction
    function [8:0] get_en_y; input [2:0] i; begin get_en_y = en_y_r[i*9 +: 9]; end endfunction

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state         <= `STATE_MENU;
            state_timer   <= 11'd0;
            game_time     <= 11'd0;
            pause_cooldown<= 8'd0;
            sel_diff      <= `DIFF_NORMAL;
            sel_mode      <= 1'b0;
            difficulty    <= `DIFF_NORMAL;
            mode          <= 1'b0;
            pl_x          <= 10'd320;
            pl_y          <= 9'd400;
            pl_hp         <= 3'd3;
            pl_weapon     <= 2'd0;
            pl_inv        <= 8'd0;
            pl_fire_cd    <= 5'd0;
            pl_alive      <= 1'b1;
            pl_flash      <= 1'b1;
            total_score   <= 20'd0;
            total_kills   <= 8'd0;
            surv_cnt      <= 8'd0;
            next_kills_upg<= 8'd10;
            en_spawn_timer<= 9'd0;
            en_spawn_idx  <= 3'd0;
            lfsr          <= 16'hACE1;
            seg_cycle     <= 2'd0;

            en_act        <= 8'd0;
            en_x_r        <= 80'd0;
            en_y_r        <= 72'd0;
            en_hp_r       <= 16'd0;
            en_flash_r     <= 8'd0;
            en_dir        <= 8'd0;
            en_fire_cd    <= 64'd0;
            en_phase      <= 64'd0;

            pb_act        <= 16'd0;
            pb_x_r        <= 160'd0;
            pb_y_r        <= 144'd0;

            eb_act        <= 64'd0;
            eb_x_r        <= 640'd0;
            eb_y_r        <= 576'd0;

            seg_data      <= 16'd0;
            seg_mode      <= 2'd0;
            led           <= 8'd0;
        end else begin

            if (tick)
                lfsr <= {lfsr[14:0], 1'b0} ^ ({16{lfsr[15]}} & 16'hB400);

            if (tick && game_time[0]) en_flash_r <= 8'd0;

            if (cyc_toggle && tick) seg_cycle <= seg_cycle + 2'd1;

            if (tick) begin
                if (pause_cooldown > 0) pause_cooldown <= pause_cooldown - 8'd1;

                case (state)

                `STATE_MENU: begin
                    pl_alive   <= 1'b1;
                    pl_hp      <= (sel_diff == `DIFF_EASY)  ? 3'd3 :
                                  (sel_diff == `DIFF_HELL)  ? 3'd2 : 3'd3;
                    pl_inv     <= 8'd0;
                    pl_fire_cd <= 5'd0;
                    total_score<= 20'd0;
                    total_kills<= 8'd0;
                    game_time  <= 11'd0;
                    surv_cnt   <= 8'd0;
                    en_act     <= 8'd0;
                    pb_act     <= 16'd0;
                    eb_act     <= 64'd0;
                    pl_x       <= 10'd320;
                    pl_y       <= 9'd400;
                    pl_flash   <= 1'b1;
                    en_spawn_timer <= 9'd0;
                    en_spawn_idx   <= 3'd0;
                    pl_weapon      <= 2'd0;
                    next_kills_upg <= 8'd10;

                    if (key_diff[0]) begin sel_diff <= `DIFF_EASY;  difficulty <= `DIFF_EASY;  end
                    if (key_diff[1]) begin sel_diff <= `DIFF_NORMAL; difficulty <= `DIFF_NORMAL; end
                    if (key_diff[2]) begin sel_diff <= `DIFF_HARD;   difficulty <= `DIFF_HARD;   end
                    if (key_diff[3]) begin sel_diff <= `DIFF_HELL;   difficulty <= `DIFF_HELL;   end

                    if (mode_toggle) begin sel_mode <= ~sel_mode; mode <= ~mode; end

                    if (start_key) begin
                        state       <= `STATE_PLAYING;
                        state_timer <= `GRACE_PERIOD;
                        difficulty  <= sel_diff;
                        mode        <= sel_mode;
                        pl_hp       <= (sel_diff == `DIFF_EASY)  ? 3'd3 :
                                       (sel_diff == `DIFF_HELL)  ? 3'd2 : 3'd3;
                    end
                end

                `STATE_PLAYING: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    game_time <= game_time + 11'd1;

                    surv_cnt <= surv_cnt + 8'd1;
                    if (surv_cnt == 8'd59) begin
                        surv_cnt <= 8'd0;
                        total_score <= total_score + 20'd1;
                    end

                    if (pause_key && pause_cooldown == 8'd0) begin
                        state <= `STATE_PAUSED;
                        pause_cooldown <= 8'd250;
                    end

                    if (pl_alive) begin
                        if (move_up    && pl_y > 9'd40)  pl_y <= pl_y - `PLAYER_SPEED;
                        if (move_down  && pl_y < 9'd430) pl_y <= pl_y + `PLAYER_SPEED;
                        if (move_left  && pl_x > 10'd40) pl_x <= pl_x - `PLAYER_SPEED;
                        if (move_right && pl_x < 10'd600)pl_x <= pl_x + `PLAYER_SPEED;
                    end

                    if (pl_inv > 0) begin
                        pl_inv <= pl_inv - 8'd1;
                        pl_flash <= (pl_inv[2:1] != 2'b00);
                    end else begin
                        pl_flash <= 1'b1;
                    end

                    if (pl_fire_cd > 0) pl_fire_cd <= pl_fire_cd - 5'd1;
                    if (fire_key && pl_fire_cd == 5'd0 && pl_alive && pl_inv == 8'd0) begin
                        if (!pb_act[0]) begin
                            pb_act[0]  <= 1'b1;
                            pb_x_r[9:0] <= pl_x - 10'd5;
                            pb_y_r[8:0] <= pl_y - 9'd14;
                        end
                        if (!pb_act[1]) begin
                            pb_act[1]   <= 1'b1;
                            pb_x_r[19:10] <= pl_x + 10'd5;
                            pb_y_r[17:9]  <= pl_y - 9'd14;
                        end
                        if (pl_weapon >= 2'd2 && !pb_act[2]) begin
                            pb_act[2]   <= 1'b1;
                            pb_x_r[29:20] <= pl_x;
                            pb_y_r[26:18] <= pl_y - 9'd16;
                        end
                        pl_fire_cd <= (`PLAYER_FIRE_RATE - {3'd0, pl_weapon});
                    end

                    if (pb_act[0]) begin
                        if (pb_y_r[8:0] <= 9'd10) pb_act[0] <= 1'b0;
                        else pb_y_r[8:0] <= pb_y_r[8:0] - `PLAYER_BULLET_SPD;
                    end
                    if (pb_act[1]) begin
                        if (pb_y_r[17:9] <= 9'd10) pb_act[1] <= 1'b0;
                        else pb_y_r[17:9] <= pb_y_r[17:9] - `PLAYER_BULLET_SPD;
                    end
                    if (pb_act[2]) begin
                        if (pb_y_r[26:18] <= 9'd10) pb_act[2] <= 1'b0;
                        else pb_y_r[26:18] <= pb_y_r[26:18] - `PLAYER_BULLET_SPD;
                    end
                    if (pb_act[3])  begin if (pb_y_r[35:27]<=9'd10) pb_act[3]<=0; else pb_y_r[35:27]<=pb_y_r[35:27]-`PLAYER_BULLET_SPD; end
                    if (pb_act[4])  begin if (pb_y_r[44:36]<=9'd10) pb_act[4]<=0; else pb_y_r[44:36]<=pb_y_r[44:36]-`PLAYER_BULLET_SPD; end
                    if (pb_act[5])  begin if (pb_y_r[53:45]<=9'd10) pb_act[5]<=0; else pb_y_r[53:45]<=pb_y_r[53:45]-`PLAYER_BULLET_SPD; end
                    if (pb_act[6])  begin if (pb_y_r[62:54]<=9'd10) pb_act[6]<=0; else pb_y_r[62:54]<=pb_y_r[62:54]-`PLAYER_BULLET_SPD; end
                    if (pb_act[7])  begin if (pb_y_r[71:63]<=9'd10) pb_act[7]<=0; else pb_y_r[71:63]<=pb_y_r[71:63]-`PLAYER_BULLET_SPD; end

                    if (state_timer == 11'd0) begin
                        if (en_spawn_timer > 0) begin
                            en_spawn_timer <= en_spawn_timer - 9'd1;
                        end else begin
                            if (!en_act[en_spawn_idx]) begin
                                en_act[en_spawn_idx] <= 1'b1;
                                en_x_r[en_spawn_idx*10 +: 10] <= (lfsr[9:0] < 10'd20) ? 10'd20 :
                                                                     (lfsr[9:0] > 10'd620) ? 10'd620 : lfsr[9:0];
                                en_y_r[en_spawn_idx*9 +: 9]   <= 9'd15;

                                en_hp_r[en_spawn_idx*2 +: 2]  <=
                                    (difficulty == `DIFF_EASY)  ? 2'd1 :
                                    (difficulty == `DIFF_NORMAL)? 2'd1 :
                                    (difficulty == `DIFF_HARD)  ? (lfsr[5] ? 2'd2 : 2'd1) :
                                    (lfsr[4:3] == 2'd0 ? 2'd3 : 2'd2);
                                en_fire_cd[en_spawn_idx*8 +: 8] <= `ENEMY_FIRE_BASE + {3'd0, lfsr[11:7]};
                                en_dir[en_spawn_idx] <= lfsr[6];
                                en_phase[en_spawn_idx*8 +: 8] <= lfsr[7:0];
                            end
                            en_spawn_idx <= en_spawn_idx + 3'd1;
                            en_spawn_timer <= `ENEMY_SPAWN_BASE;
                        end
                    end

                    if (game_time[1:0] == 2'd0) begin
                        if (en_act[0]) en_phase[ 7: 0] <= en_phase[ 7: 0] + 8'd1;
                        if (en_act[1]) en_phase[15: 8] <= en_phase[15: 8] + 8'd3;
                        if (en_act[2]) en_phase[23:16] <= en_phase[23:16] + 8'd2;
                        if (en_act[3]) en_phase[31:24] <= en_phase[31:24] + 8'd1;
                        if (en_act[4]) en_phase[39:32] <= en_phase[39:32] + 8'd2;
                        if (en_act[5]) en_phase[47:40] <= en_phase[47:40] + 8'd3;
                        if (en_act[6]) en_phase[55:48] <= en_phase[55:48] + 8'd1;
                        if (en_act[7]) en_phase[63:56] <= en_phase[63:56] + 8'd2;
                    end

                    if (en_act[0]) begin
                        en_y_r[8:0] <= en_y_r[8:0] + (game_time[0] ? 9'd1 : 9'd0);
                        if (en_y_r[8:0] < 9'd80) begin
                            en_x_r[9:0] <= en_phase[7] ?
                                (en_x_r[9:0] - 10'd1) : (en_x_r[9:0] + 10'd1);
                        end else begin
                            en_x_r[9:0] <= en_phase[7] ?
                                (en_x_r[9:0] - {9'd0, en_phase[6]}) : (en_x_r[9:0] + {9'd0, en_phase[6]});
                        end
                        if (en_x_r[9:0] <= 10'd32)  en_x_r[9:0] <= 10'd33;
                        if (en_x_r[9:0] >= 10'd608) en_x_r[9:0] <= 10'd607;
                        if (en_y_r[8:0] > 9'd470) en_act[0] <= 1'b0;

                        if (en_fire_cd[7:0] > 0) en_fire_cd[7:0] <= en_fire_cd[7:0] - 8'd1;
                        else begin
                            if (!eb_act[0]) begin eb_act[0]<=1; eb_x_r[9:0]<=en_x_r[9:0]-6; eb_y_r[8:0]<=en_y_r[8:0]; end
                            if (!eb_act[1]) begin eb_act[1]<=1; eb_x_r[19:10]<=en_x_r[9:0];   eb_y_r[17:9]<=en_y_r[8:0]; end
                            if (!eb_act[2]) begin eb_act[2]<=1; eb_x_r[29:20]<=en_x_r[9:0]+6; eb_y_r[26:18]<=en_y_r[8:0]; end
                            en_fire_cd[7:0] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[5:0]};
                        end
                    end

                    if (en_act[1]) begin
                        if (en_y_r[17:9] < 9'd80 && game_time[0]) en_y_r[17:9] <= en_y_r[17:9] + 9'd1;
                        en_x_r[19:10] <= en_phase[15] ?
                            (en_x_r[19:10] - {9'd0, en_phase[13]}) : (en_x_r[19:10] + {9'd0, en_phase[13]});
                        if (en_x_r[19:10] <= 10'd32)  en_x_r[19:10] <= 10'd33;
                        if (en_x_r[19:10] >= 10'd608) en_x_r[19:10] <= 10'd607;
                        if (game_time[9:0] > 10'd600) en_act[1] <= 1'b0;
                        if (en_fire_cd[15:8] > 0) en_fire_cd[15:8] <= en_fire_cd[15:8] - 8'd1;
                        else begin
                            if (!eb_act[8])  begin eb_act[8]<=1;  eb_x_r[89:80]<=en_x_r[19:10]-4; eb_y_r[80:72]<=en_y_r[17:9]; end
                            if (!eb_act[9])  begin eb_act[9]<=1;  eb_x_r[99:90]<=en_x_r[19:10]+4; eb_y_r[89:81]<=en_y_r[17:9]; end
                            if (!eb_act[10]) begin eb_act[10]<=1; eb_x_r[109:100]<=en_x_r[19:10];  eb_y_r[98:90]<=en_y_r[17:9]; end
                            en_fire_cd[15:8] <= `ENEMY_FIRE_BASE - 10 + {2'd0, lfsr[7:2]};
                        end
                    end

                    if (en_act[2]) begin
                        if (en_y_r[26:18] < 9'd60 && game_time[0]) en_y_r[26:18] <= en_y_r[26:18] + 9'd1;
                        if (game_time[3:0] == 4'd0) begin
                            if (en_x_r[29:20] > pl_x + 10'd20) en_x_r[29:20] <= en_x_r[29:20] - 10'd1;
                            else if (en_x_r[29:20] < pl_x - 10'd20) en_x_r[29:20] <= en_x_r[29:20] + 10'd1;
                            else en_x_r[29:20] <= en_phase[23] ?
                                (en_x_r[29:20] - 10'd1) : (en_x_r[29:20] + 10'd1);
                        end
                        if (game_time[9:0] > 10'd550) en_act[2] <= 1'b0;
                        if (en_fire_cd[23:16] > 0) en_fire_cd[23:16] <= en_fire_cd[23:16] - 8'd1;
                        else begin

                            if (!eb_act[16]) begin eb_act[16]<=1; eb_x_r[169:160]<=en_x_r[29:20]; eb_y_r[152:144]<=en_y_r[26:18]; end
                            if (!eb_act[17]) begin
                                eb_act[17]<=1;
                                eb_x_r[179:170]<= (pl_x > en_x_r[29:20]) ? (en_x_r[29:20] + 10'd10) : (en_x_r[29:20] - 10'd10);
                                eb_y_r[161:153]<=en_y_r[26:18];
                            end
                            if (!eb_act[18]) begin
                                eb_act[18]<=1;
                                eb_x_r[189:180]<= (pl_x > en_x_r[29:20]) ? (en_x_r[29:20] - 10'd6) : (en_x_r[29:20] + 10'd6);
                                eb_y_r[170:162]<=en_y_r[26:18];
                            end
                            en_fire_cd[23:16] <= `ENEMY_FIRE_BASE - 16 + {2'd0, lfsr[7:2]};
                        end
                    end

                    if (en_act[3]) begin
                        en_y_r[35:27] <= en_y_r[35:27] + (game_time[0] ? 9'd1 : 9'd0);
                        if (en_y_r[35:27] < 9'd60) begin
                            en_x_r[39:30] <= en_dir[3] ? (en_x_r[39:30] + 10'd1) : (en_x_r[39:30] - 10'd1);
                        end else begin
                            en_x_r[39:30] <= en_phase[31] ?
                                (en_x_r[39:30] - {9'd0, en_phase[30]}) : (en_x_r[39:30] + {9'd0, en_phase[30]});
                        end
                        if (en_x_r[39:30] <= 10'd32)  en_x_r[39:30] <= 10'd33;
                        if (en_x_r[39:30] >= 10'd608) en_x_r[39:30] <= 10'd607;
                        if (en_y_r[35:27] > 9'd470) en_act[3] <= 1'b0;
                        if (en_fire_cd[31:24] > 0) en_fire_cd[31:24] <= en_fire_cd[31:24] - 8'd1;
                        else begin
                            if (!eb_act[24]) begin eb_act[24]<=1; eb_x_r[249:240]<=en_x_r[39:30]-6; eb_y_r[224:216]<=en_y_r[35:27]; end
                            if (!eb_act[25]) begin eb_act[25]<=1; eb_x_r[259:250]<=en_x_r[39:30]+6; eb_y_r[233:225]<=en_y_r[35:27]; end
                            en_fire_cd[31:24] <= `ENEMY_FIRE_BASE - 10 + {2'd0, lfsr[9:4]};
                        end
                    end

                    if (en_act[4]) begin
                        en_y_r[44:36] <= en_y_r[44:36] + (game_time[0] ? 9'd1 : 9'd0);
                        en_x_r[49:40] <= en_phase[7] ?
                            (en_x_r[49:40] - {9'd0, en_phase[5]}) : (en_x_r[49:40] + {9'd0, en_phase[5]});
                        if (en_x_r[49:40] <= 10'd32)  en_x_r[49:40] <= 10'd33;
                        if (en_x_r[49:40] >= 10'd608) en_x_r[49:40] <= 10'd607;
                        if (en_y_r[44:36] > 9'd470) en_act[4] <= 1'b0;
                        if (en_fire_cd[39:32] > 0) en_fire_cd[39:32] <= en_fire_cd[39:32] - 8'd1;
                        else begin
                            if (!eb_act[32]) begin eb_act[32]<=1; eb_x_r[329:320]<=en_x_r[49:40]-6; eb_y_r[296:288]<=en_y_r[44:36]; end
                            if (!eb_act[33]) begin eb_act[33]<=1; eb_x_r[339:330]<=en_x_r[49:40];   eb_y_r[305:297]<=en_y_r[44:36]; end
                            if (!eb_act[34]) begin eb_act[34]<=1; eb_x_r[349:340]<=en_x_r[49:40]+6; eb_y_r[314:306]<=en_y_r[44:36]; end
                            en_fire_cd[39:32] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[5:0]};
                        end
                    end

                    if (en_act[5]) begin
                        en_y_r[53:45] <= en_y_r[53:45] + (game_time[0] ? 9'd1 : 9'd0);
                        if (game_time[3:0] == 4'd5) begin
                            en_x_r[59:50] <= en_dir[5] ? (en_x_r[59:50] + 10'd1) : (en_x_r[59:50] - 10'd1);
                        end
                        if (en_x_r[59:50] <= 10'd32)  en_x_r[59:50] <= 10'd33;
                        if (en_x_r[59:50] >= 10'd608) en_x_r[59:50] <= 10'd607;
                        if (en_y_r[53:45] > 9'd470) en_act[5] <= 1'b0;
                        if (en_fire_cd[47:40] > 0) en_fire_cd[47:40] <= en_fire_cd[47:40] - 8'd1;
                        else begin
                            if (!eb_act[40]) begin eb_act[40]<=1; eb_x_r[409:400]<=en_x_r[59:50]+3; eb_y_r[368:360]<=en_y_r[53:45]; end
                            if (!eb_act[41]) begin eb_act[41]<=1; eb_x_r[419:410]<=en_x_r[59:50]-3; eb_y_r[377:369]<=en_y_r[53:45]; end
                            en_fire_cd[47:40] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[9:4]};
                        end
                    end

                    if (en_act[6]) begin
                        en_y_r[62:54] <= en_y_r[62:54] + (game_time[0] ? 9'd1 : 9'd0);
                        en_x_r[69:60] <= en_phase[15] ?
                            (en_x_r[69:60] - {9'd0, en_phase[13]}) : (en_x_r[69:60] + {9'd0, en_phase[13]});
                        if (en_x_r[69:60] <= 10'd32)  en_x_r[69:60] <= 10'd33;
                        if (en_x_r[69:60] >= 10'd608) en_x_r[69:60] <= 10'd607;
                        if (en_y_r[62:54] > 9'd470) en_act[6] <= 1'b0;
                        if (en_fire_cd[55:48] > 0) en_fire_cd[55:48] <= en_fire_cd[55:48] - 8'd1;
                        else begin
                            if (!eb_act[48]) begin eb_act[48]<=1; eb_x_r[489:480]<=en_x_r[69:60]-3; eb_y_r[440:432]<=en_y_r[62:54]; end
                            if (!eb_act[49]) begin eb_act[49]<=1; eb_x_r[499:490]<=en_x_r[69:60]+3; eb_y_r[449:441]<=en_y_r[62:54]; end
                            en_fire_cd[55:48] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[11:6]};
                        end
                    end

                    if (en_act[7]) begin
                        en_y_r[71:63] <= en_y_r[71:63] + (game_time[0] ? 9'd1 : 9'd0);
                        if (en_y_r[71:63] < 9'd80) begin
                            en_x_r[79:70] <= en_dir[7] ? (en_x_r[79:70] - 10'd1) : (en_x_r[79:70] + 10'd1);
                        end else begin
                            en_x_r[79:70] <= en_dir[7] ? (en_x_r[79:70] + 10'd1) : (en_x_r[79:70] - 10'd1);
                        end
                        if (en_x_r[79:70] <= 10'd32)  en_x_r[79:70] <= 10'd33;
                        if (en_x_r[79:70] >= 10'd608) en_x_r[79:70] <= 10'd607;
                        if (en_y_r[71:63] > 9'd470) en_act[7] <= 1'b0;
                        if (en_fire_cd[63:56] > 0) en_fire_cd[63:56] <= en_fire_cd[63:56] - 8'd1;
                        else begin
                            if (!eb_act[56]) begin eb_act[56]<=1; eb_x_r[569:560]<=en_x_r[79:70]; eb_y_r[512:504]<=en_y_r[71:63]; end
                            if (!eb_act[57]) begin eb_act[57]<=1; eb_x_r[579:570]<=en_x_r[79:70]+6; eb_y_r[521:513]<=en_y_r[71:63]; end
                            en_fire_cd[63:56] <= `ENEMY_FIRE_BASE - 8 + {2'd0, lfsr[9:4]};
                        end
                    end

                    if (eb_act[0])  begin if (eb_y_r[8:0]  >9'd470) eb_act[0]<=0;  else eb_y_r[8:0]  <=eb_y_r[8:0] +2; end
                    if (eb_act[1])  begin if (eb_y_r[17:9] >9'd470) eb_act[1]<=0;  else eb_y_r[17:9] <=eb_y_r[17:9]+2; end
                    if (eb_act[2])  begin if (eb_y_r[26:18]>9'd470) eb_act[2]<=0;  else eb_y_r[26:18]<=eb_y_r[26:18]+2; end
                    if (eb_act[8])  begin if (eb_y_r[80:72]>9'd470) eb_act[8]<=0;  else eb_y_r[80:72]<=eb_y_r[80:72]+2; end
                    if (eb_act[9])  begin if (eb_y_r[89:81]>9'd470) eb_act[9]<=0;  else eb_y_r[89:81]<=eb_y_r[89:81]+2; end
                    if (eb_act[10]) begin if (eb_y_r[98:90]>9'd470) eb_act[10]<=0; else eb_y_r[98:90]<=eb_y_r[98:90]+2; end
                    if (eb_act[16]) begin if (eb_y_r[152:144]>9'd470) eb_act[16]<=0; else eb_y_r[152:144]<=eb_y_r[152:144]+2; end
                    if (eb_act[17]) begin if (eb_y_r[161:153]>9'd470) eb_act[17]<=0; else eb_y_r[161:153]<=eb_y_r[161:153]+2; end
                    if (eb_act[18]) begin if (eb_y_r[170:162]>9'd470) eb_act[18]<=0; else eb_y_r[170:162]<=eb_y_r[170:162]+2; end
                    if (eb_act[24]) begin if (eb_y_r[224:216]>9'd470) eb_act[24]<=0; else eb_y_r[224:216]<=eb_y_r[224:216]+2; end
                    if (eb_act[25]) begin if (eb_y_r[233:225]>9'd470) eb_act[25]<=0; else eb_y_r[233:225]<=eb_y_r[233:225]+2; end
                    if (eb_act[32]) begin if (eb_y_r[296:288]>9'd470) eb_act[32]<=0; else eb_y_r[296:288]<=eb_y_r[296:288]+2; end
                    if (eb_act[33]) begin if (eb_y_r[305:297]>9'd470) eb_act[33]<=0; else eb_y_r[305:297]<=eb_y_r[305:297]+2; end
                    if (eb_act[34]) begin if (eb_y_r[314:306]>9'd470) eb_act[34]<=0; else eb_y_r[314:306]<=eb_y_r[314:306]+2; end
                    if (eb_act[40]) begin if (eb_y_r[368:360]>9'd470) eb_act[40]<=0; else eb_y_r[368:360]<=eb_y_r[368:360]+2; end
                    if (eb_act[41]) begin if (eb_y_r[377:369]>9'd470) eb_act[41]<=0; else eb_y_r[377:369]<=eb_y_r[377:369]+2; end
                    if (eb_act[48]) begin if (eb_y_r[440:432]>9'd470) eb_act[48]<=0; else eb_y_r[440:432]<=eb_y_r[440:432]+2; end
                    if (eb_act[49]) begin if (eb_y_r[449:441]>9'd470) eb_act[49]<=0; else eb_y_r[449:441]<=eb_y_r[449:441]+2; end
                    if (eb_act[56]) begin if (eb_y_r[512:504]>9'd470) eb_act[56]<=0; else eb_y_r[512:504]<=eb_y_r[512:504]+2; end
                    if (eb_act[57]) begin if (eb_y_r[521:513]>9'd470) eb_act[57]<=0; else eb_y_r[521:513]<=eb_y_r[521:513]+2; end

                    if (pb_act[0] && en_act[0] &&
                        pb_x_r[9:0] >= en_x_r[9:0]-14 && pb_x_r[9:0] <= en_x_r[9:0]+14 &&
                        pb_y_r[8:0] >= en_y_r[8:0]-10 && pb_y_r[8:0] <= en_y_r[8:0]+10) begin
                        pb_act[0]<=0;
                        if (en_hp_r[1:0] <= 2'd1) begin
                            en_act[0]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[1:0] <= en_hp_r[1:0] - 2'd1; en_flash_r[0] <= 1'b1;
                        end
                    end

                    if (pb_act[0] && en_act[1] &&
                        pb_x_r[9:0] >= en_x_r[19:10]-14 && pb_x_r[9:0] <= en_x_r[19:10]+14 &&
                        pb_y_r[8:0] >= en_y_r[17:9]-10 && pb_y_r[8:0] <= en_y_r[17:9]+10) begin
                        pb_act[0]<=0;
                        if (en_hp_r[3:2] <= 2'd1) begin
                            en_act[1]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[3:2] <= en_hp_r[3:2] - 2'd1; en_flash_r[1] <= 1'b1;
                        end
                    end

                    if (pb_act[0] && en_act[2] &&
                        pb_x_r[9:0] >= en_x_r[29:20]-14 && pb_x_r[9:0] <= en_x_r[29:20]+14 &&
                        pb_y_r[8:0] >= en_y_r[26:18]-10 && pb_y_r[8:0] <= en_y_r[26:18]+10) begin
                        pb_act[0]<=0;
                        if (en_hp_r[5:4] <= 2'd1) begin
                            en_act[2]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[5:4] <= en_hp_r[5:4] - 2'd1; en_flash_r[2] <= 1'b1;
                        end
                    end

                    if (pb_act[1] && en_act[0] &&
                        pb_x_r[19:10] >= en_x_r[9:0]-14 && pb_x_r[19:10] <= en_x_r[9:0]+14 &&
                        pb_y_r[17:9] >= en_y_r[8:0]-10 && pb_y_r[17:9] <= en_y_r[8:0]+10) begin
                        pb_act[1]<=0;
                        if (en_hp_r[1:0] <= 2'd1) begin
                            en_act[0]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[1:0] <= en_hp_r[1:0] - 2'd1; en_flash_r[0] <= 1'b1;
                        end
                    end

                    if (pb_act[1] && en_act[1] &&
                        pb_x_r[19:10] >= en_x_r[19:10]-14 && pb_x_r[19:10] <= en_x_r[19:10]+14 &&
                        pb_y_r[17:9] >= en_y_r[17:9]-10 && pb_y_r[17:9] <= en_y_r[17:9]+10) begin
                        pb_act[1]<=0;
                        if (en_hp_r[3:2] <= 2'd1) begin
                            en_act[1]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[3:2] <= en_hp_r[3:2] - 2'd1; en_flash_r[1] <= 1'b1;
                        end
                    end

                    if (pb_act[2] && en_act[0] &&
                        pb_x_r[29:20] >= en_x_r[9:0]-14 && pb_x_r[29:20] <= en_x_r[9:0]+14 &&
                        pb_y_r[26:18] >= en_y_r[8:0]-10 && pb_y_r[26:18] <= en_y_r[8:0]+10) begin
                        pb_act[2]<=0;
                        if (en_hp_r[1:0] <= 2'd1) begin
                            en_act[0]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[1:0] <= en_hp_r[1:0] - 2'd1; en_flash_r[0] <= 1'b1;
                        end
                    end

                    if (pb_act[0] && en_act[3] &&
                        pb_x_r[9:0] >= en_x_r[39:30]-14 && pb_x_r[9:0] <= en_x_r[39:30]+14 &&
                        pb_y_r[8:0] >= en_y_r[35:27]-10 && pb_y_r[8:0] <= en_y_r[35:27]+10) begin
                        pb_act[0]<=0;
                        if (en_hp_r[7:6] <= 2'd1) begin
                            en_act[3]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[7:6] <= en_hp_r[7:6] - 2'd1; en_flash_r[3] <= 1'b1;
                        end
                    end

                    if (pb_act[0] && en_act[4] &&
                        pb_x_r[9:0] >= en_x_r[49:40]-14 && pb_x_r[9:0] <= en_x_r[49:40]+14 &&
                        pb_y_r[8:0] >= en_y_r[44:36]-10 && pb_y_r[8:0] <= en_y_r[44:36]+10) begin
                        pb_act[0]<=0;
                        if (en_hp_r[9:8] <= 2'd1) begin
                            en_act[4]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[9:8] <= en_hp_r[9:8] - 2'd1; en_flash_r[4] <= 1'b1;
                        end
                    end

                    if (pb_act[1] && en_act[2] &&
                        pb_x_r[19:10] >= en_x_r[29:20]-14 && pb_x_r[19:10] <= en_x_r[29:20]+14 &&
                        pb_y_r[17:9] >= en_y_r[26:18]-10 && pb_y_r[17:9] <= en_y_r[26:18]+10) begin
                        pb_act[1]<=0;
                        if (en_hp_r[5:4] <= 2'd1) begin
                            en_act[2]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                        end else begin
                            en_hp_r[5:4] <= en_hp_r[5:4] - 2'd1; en_flash_r[2] <= 1'b1;
                        end
                    end

                    if (pb_act[0] && en_act[5] &&
                        pb_x_r[9:0] >= en_x_r[59:50]-14 && pb_x_r[9:0] <= en_x_r[59:50]+14 &&
                        pb_y_r[8:0] >= en_y_r[53:45]-10 && pb_y_r[8:0] <= en_y_r[53:45]+10) begin
                        pb_act[0]<=0; en_act[5]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[0] && en_act[6] &&
                        pb_x_r[9:0] >= en_x_r[69:60]-14 && pb_x_r[9:0] <= en_x_r[69:60]+14 &&
                        pb_y_r[8:0] >= en_y_r[62:54]-10 && pb_y_r[8:0] <= en_y_r[62:54]+10) begin
                        pb_act[0]<=0; en_act[6]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[0] && en_act[7] &&
                        pb_x_r[9:0] >= en_x_r[79:70]-14 && pb_x_r[9:0] <= en_x_r[79:70]+14 &&
                        pb_y_r[8:0] >= en_y_r[71:63]-10 && pb_y_r[8:0] <= en_y_r[71:63]+10) begin
                        pb_act[0]<=0; en_act[7]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[1] && en_act[3] &&
                        pb_x_r[19:10] >= en_x_r[39:30]-14 && pb_x_r[19:10] <= en_x_r[39:30]+14 &&
                        pb_y_r[17:9] >= en_y_r[35:27]-10 && pb_y_r[17:9] <= en_y_r[35:27]+10) begin
                        pb_act[1]<=0; en_act[3]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[1] && en_act[4] &&
                        pb_x_r[19:10] >= en_x_r[49:40]-14 && pb_x_r[19:10] <= en_x_r[49:40]+14 &&
                        pb_y_r[17:9] >= en_y_r[44:36]-10 && pb_y_r[17:9] <= en_y_r[44:36]+10) begin
                        pb_act[1]<=0; en_act[4]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[2] && en_act[1] &&
                        pb_x_r[29:20] >= en_x_r[19:10]-14 && pb_x_r[29:20] <= en_x_r[19:10]+14 &&
                        pb_y_r[26:18] >= en_y_r[17:9]-10 && pb_y_r[26:18] <= en_y_r[17:9]+10) begin
                        pb_act[2]<=0; en_act[1]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pb_act[2] && en_act[2] &&
                        pb_x_r[29:20] >= en_x_r[29:20]-14 && pb_x_r[29:20] <= en_x_r[29:20]+14 &&
                        pb_y_r[26:18] >= en_y_r[26:18]-10 && pb_y_r[26:18] <= en_y_r[26:18]+10) begin
                        pb_act[2]<=0; en_act[2]<=0; total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    if (pl_alive && pl_inv==0) begin
                        if ((eb_act[0] && eb_x_r[9:0]>=pl_x-8 && eb_x_r[9:0]<=pl_x+8 &&
                             eb_y_r[8:0]>=pl_y-10 && eb_y_r[8:0]<=pl_y+10) ||
                            (eb_act[1] && eb_x_r[19:10]>=pl_x-8 && eb_x_r[19:10]<=pl_x+8 &&
                             eb_y_r[17:9]>=pl_y-10 && eb_y_r[17:9]<=pl_y+10) ||
                            (eb_act[2] && eb_x_r[29:20]>=pl_x-8 && eb_x_r[29:20]<=pl_x+8 &&
                             eb_y_r[26:18]>=pl_y-10 && eb_y_r[26:18]<=pl_y+10) ||
                            (eb_act[8] && eb_x_r[89:80]>=pl_x-8 && eb_x_r[89:80]<=pl_x+8 &&
                             eb_y_r[80:72]>=pl_y-10 && eb_y_r[80:72]<=pl_y+10) ||
                            (eb_act[9] && eb_x_r[99:90]>=pl_x-8 && eb_x_r[99:90]<=pl_x+8 &&
                             eb_y_r[89:81]>=pl_y-10 && eb_y_r[89:81]<=pl_y+10) ||
                            (eb_act[10]&& eb_x_r[109:100]>=pl_x-8 && eb_x_r[109:100]<=pl_x+8 &&
                             eb_y_r[98:90]>=pl_y-10 && eb_y_r[98:90]<=pl_y+10) ||
                            (eb_act[16]&& eb_x_r[169:160]>=pl_x-8 && eb_x_r[169:160]<=pl_x+8 &&
                             eb_y_r[152:144]>=pl_y-10 && eb_y_r[152:144]<=pl_y+10) ||
                            (eb_act[17]&& eb_x_r[179:170]>=pl_x-8 && eb_x_r[179:170]<=pl_x+8 &&
                             eb_y_r[161:153]>=pl_y-10 && eb_y_r[161:153]<=pl_y+10) ||
                            (eb_act[18]&& eb_x_r[189:180]>=pl_x-8 && eb_x_r[189:180]<=pl_x+8 &&
                             eb_y_r[170:162]>=pl_y-10 && eb_y_r[170:162]<=pl_y+10) ||
                            (eb_act[24]&& eb_x_r[249:240]>=pl_x-8 && eb_x_r[249:240]<=pl_x+8 &&
                             eb_y_r[224:216]>=pl_y-10 && eb_y_r[224:216]<=pl_y+10) ||
                            (eb_act[25]&& eb_x_r[259:250]>=pl_x-8 && eb_x_r[259:250]<=pl_x+8 &&
                             eb_y_r[233:225]>=pl_y-10 && eb_y_r[233:225]<=pl_y+10) ||
                            (eb_act[32]&& eb_x_r[329:320]>=pl_x-8 && eb_x_r[329:320]<=pl_x+8 &&
                             eb_y_r[296:288]>=pl_y-10 && eb_y_r[296:288]<=pl_y+10) ||
                            (eb_act[33]&& eb_x_r[339:330]>=pl_x-8 && eb_x_r[339:330]<=pl_x+8 &&
                             eb_y_r[305:297]>=pl_y-10 && eb_y_r[305:297]<=pl_y+10) ||
                            (eb_act[34]&& eb_x_r[349:340]>=pl_x-8 && eb_x_r[349:340]<=pl_x+8 &&
                             eb_y_r[314:306]>=pl_y-10 && eb_y_r[314:306]<=pl_y+10) ||
                            (eb_act[40]&& eb_x_r[409:400]>=pl_x-8 && eb_x_r[409:400]<=pl_x+8 &&
                             eb_y_r[368:360]>=pl_y-10 && eb_y_r[368:360]<=pl_y+10) ||
                            (eb_act[41]&& eb_x_r[419:410]>=pl_x-8 && eb_x_r[419:410]<=pl_x+8 &&
                             eb_y_r[377:369]>=pl_y-10 && eb_y_r[377:369]<=pl_y+10) ||
                            (eb_act[48]&& eb_x_r[489:480]>=pl_x-8 && eb_x_r[489:480]<=pl_x+8 &&
                             eb_y_r[440:432]>=pl_y-10 && eb_y_r[440:432]<=pl_y+10) ||
                            (eb_act[49]&& eb_x_r[499:490]>=pl_x-8 && eb_x_r[499:490]<=pl_x+8 &&
                             eb_y_r[449:441]>=pl_y-10 && eb_y_r[449:441]<=pl_y+10) ||
                            (eb_act[56]&& eb_x_r[569:560]>=pl_x-8 && eb_x_r[569:560]<=pl_x+8 &&
                             eb_y_r[512:504]>=pl_y-10 && eb_y_r[512:504]<=pl_y+10) ||
                            (eb_act[57]&& eb_x_r[579:570]>=pl_x-8 && eb_x_r[579:570]<=pl_x+8 &&
                             eb_y_r[521:513]>=pl_y-10 && eb_y_r[521:513]<=pl_y+10)) begin
                            if (pl_hp <= 3'd1) begin
                                pl_hp <= 3'd0; pl_alive <= 1'b0;
                                state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                            end else begin
                                pl_hp <= pl_hp - 3'd1; pl_x <= 10'd320; pl_y <= 9'd400;
                                pl_inv <= `PLAYER_INV_TIME; eb_act <= 64'd0;
                            end
                        end
                    end

                    if (pl_alive && pl_inv==0) begin
                        if ((en_act[0] && pl_x>=en_x_r[9:0]-12 && pl_x<=en_x_r[9:0]+12 &&
                             pl_y>=en_y_r[8:0]-8 && pl_y<=en_y_r[8:0]+8) ||
                            (en_act[1] && pl_x>=en_x_r[19:10]-12 && pl_x<=en_x_r[19:10]+12 &&
                             pl_y>=en_y_r[17:9]-8 && pl_y<=en_y_r[17:9]+8) ||
                            (en_act[2] && pl_x>=en_x_r[29:20]-12 && pl_x<=en_x_r[29:20]+12 &&
                             pl_y>=en_y_r[26:18]-8 && pl_y<=en_y_r[26:18]+8) ||
                            (en_act[3] && pl_x>=en_x_r[39:30]-12 && pl_x<=en_x_r[39:30]+12 &&
                             pl_y>=en_y_r[35:27]-8 && pl_y<=en_y_r[35:27]+8) ||
                            (en_act[4] && pl_x>=en_x_r[49:40]-12 && pl_x<=en_x_r[49:40]+12 &&
                             pl_y>=en_y_r[44:36]-8 && pl_y<=en_y_r[44:36]+8)) begin
                            if (pl_hp <= 3'd1) begin
                                pl_hp <= 3'd0; pl_alive <= 1'b0;
                                state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                            end else begin
                                pl_hp <= pl_hp - 3'd1; pl_x <= 10'd320; pl_y <= 9'd400;
                                pl_inv <= `PLAYER_INV_TIME; eb_act <= 64'd0;
                            end
                        end
                    end

                    if (total_kills >= next_kills_upg && pl_weapon < 2'd3) begin
                        pl_weapon <= pl_weapon + 2'd1;
                        next_kills_upg <= next_kills_upg << 1;
                    end

                    if (!mode && total_score >= `SCORE_WIN_TARGET && pl_alive) begin
                        state <= `STATE_WIN; state_timer <= `WIN_DISPLAY;
                    end
                end

                `STATE_PAUSED: begin
                    if ((pause_key || fire_key) && pause_cooldown == 8'd0) begin
                        state <= `STATE_PLAYING;
                        pause_cooldown <= 8'd250;
                    end
                end

                `STATE_GAMEOVER: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    else begin
                        state <= `STATE_MENU;
                        en_act <= 8'd0; eb_act <= 64'd0; pb_act <= 16'd0;
                    end
                end

                `STATE_WIN: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    else begin
                        state <= `STATE_MENU;
                        en_act <= 8'd0; eb_act <= 64'd0; pb_act <= 16'd0;
                    end
                end

                default: state <= `STATE_MENU;
                endcase
            end

            case (seg_cycle)
                `SEGMODE_KILLS: seg_data <= {8'd0, total_kills};
                `SEGMODE_LIVES: seg_data <= {13'd0, pl_hp};
                `SEGMODE_SCORE: seg_data <= total_score[15:0];
                default:        seg_data <= total_score[15:0];
            endcase

            if (seg_cycle == `SEGMODE_SCORE && total_score > 20'd9999)
                led <= total_score[19:12];
            else if (seg_cycle == `SEGMODE_KILLS && total_kills > 8'd99)
                led <= {6'd0, total_kills[7:6]};
            else
                led <= 8'd0;
        end
    end

    assign lives = pl_hp;

    always @* begin
        game_state = state;
        score      = total_score;
        kills      = total_kills;
        seg_mode   = seg_cycle;
        pl_active  = pl_alive;
        en_active  = en_act;
        en_x       = en_x_r;
        en_y       = en_y_r;
        en_hp      = en_hp_r;
        en_flash   = en_flash_r;
        pb_active  = pb_act;
        pb_x       = pb_x_r;
        pb_y       = pb_y_r;
        pb_type    = 32'd0;
        eb_active  = eb_act;
        eb_x       = eb_x_r;
        eb_y       = eb_y_r;
        eb_type    = 128'd0;
    end
endmodule
