//==============================================================================
// game_logic.v — Core game state machine, entity management, collision detection
// Runs at 60Hz on frame_tick from vga_top. Synthesis-optimized with fixed
// slot allocation to minimize combinational depth.
//==============================================================================
`include "game_defs.vh"

module game_logic (
    input  wire        clk,
    input  wire        rstn,
    input  wire        frame_tick,  // 60Hz game update pulse

    input  wire [4:0]  btn,         // {BTNX4, BTN[3:0]} debounced buttons
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

    output reg  [15:0] pb_active,
    output reg  [159:0] pb_x,
    output reg  [143:0] pb_y,
    output reg  [31:0]  pb_type,

    output reg  [63:0] eb_active,
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
    //==========================================================================
    // SW[] Switch Input Mapping
    //   SW[0]  → UP,        SW[1]  → DOWN
    //   SW[2]  → LEFT,       SW[3]  → RIGHT
    //   SW[4]  → FIRE/START, SW[5]  → PAUSE (edge)
    //   SW[6]  → CYCLE (edge),SW[7] → DIFF EASY
    //   SW[8]  → DIFF NORMAL,SW[9]  → DIFF HARD
    //   SW[10] → DIFF HELL,  SW[11] → MODE (0=survival,1=score)
    //   SW[12:15] → reserved (cheat)
    //   SW=1 held; SW=0 released. Pause/Cycle use posedge->latch->tick.
    //==========================================================================
    reg [15:0] sw_d;
    always @(posedge clk) sw_d <= sw;

    reg sw5_latch, sw6_latch;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sw5_latch <= 1'b0;
            sw6_latch <= 1'b0;
        end else begin
            if (sw[5] && !sw_d[5])
                sw5_latch <= 1'b1;
            else if (tick)
                sw5_latch <= 1'b0;
            if (sw[6] && !sw_d[6])
                sw6_latch <= 1'b1;
            else if (tick)
                sw6_latch <= 1'b0;
        end
    end

    //==========================================================================
    // Button Mapping — 5 direct buttons: {BTNX4, BTN[3:0]} = btn[4:0]
    //   btn[0] (W14): UP,  btn[1] (V14): DOWN,
    //   btn[2] (V19): LEFT, btn[3] (V18): RIGHT,
    //   btn[4] (W16, BTNX4): FIRE / START
    //==========================================================================
    wire btn_up    = btn[0];
    wire btn_down  = btn[1];
    wire btn_left  = btn[2];
    wire btn_right = btn[3];
    wire btn_fire  = btn[4];

    // Combined input (button OR switch)
    wire move_up    = btn_up    || sw[0];
    wire move_down  = btn_down  || sw[1];
    wire move_left  = btn_left  || sw[2];
    wire move_right = btn_right || sw[3];
    wire fire_key   = btn_fire  || sw[4];
    wire start_key  = btn_fire  || sw[4];
    wire pause_key  = sw5_latch;
    wire upgrade_key = sw6_latch;
    wire btn_cyc    = sw6_latch;

    //==========================================================================
    // Cheat Mode: activate when all reserved SW[12:15] are ON
    //==========================================================================
    wire cheat_ok = sw[12] && sw[13] && sw[14] && sw[15];

    //==========================================================================
    // Registers
    //==========================================================================
    reg [2:0]  state;
    reg [10:0] state_timer;     // general purpose frame counter (up to 2047 frames)
    reg [10:0] game_time;       // total game time in frames (60Hz)
    reg [7:0]  pause_cooldown;
    reg [1:0]  sel_diff;
    reg        sel_mode;
    reg [2:0]  pl_hp;
    reg [1:0]  pl_weapon;
    reg [7:0]  pl_inv;          // invincibility timer
    reg [4:0]  pl_fire_cd;
    reg        pl_alive;
    reg [19:0] total_score;
    reg [7:0]  total_kills;
    reg [7:0]  surv_cnt;        // survival score counter (0-59)
    reg [7:0]  next_kills_upg;  // kills needed for next upgrade
    reg [8:0]  en_spawn_timer;  // enemy spawn cooldown
    reg [8:0]  ob_spawn_timer;  // obstacle spawn cooldown
    reg [2:0]  en_spawn_idx;    // round-robin enemy spawn index
    reg [2:0]  ob_spawn_idx;    // round-robin obstacle spawn index
    reg [15:0] lfsr;
    reg [1:0]  seg_cycle;

    // Enemy registers (8 enemies, indexed 0..7)
    reg [7:0]  en_act;
    reg [79:0] en_x_r;
    reg [71:0] en_y_r;
    reg [15:0] en_hp_r;
    reg [7:0]  en_dir;         // 1=right, 0=left
    reg [63:0] en_fire_cd;     // 8 × 8 bits

    // Player bullet registers (16 bullets)
    reg [15:0] pb_act;
    reg [159:0] pb_x_r;
    reg [143:0] pb_y_r;

    // Enemy bullet registers (64 bullets; each enemy owns 8 consecutive slots)
    reg [63:0] eb_act;
    reg [639:0] eb_x_r;
    reg [575:0] eb_y_r;

    // Obstacle registers (8 obstacles)
    reg [7:0]  ob_act;
    reg [79:0] ob_x_r;
    reg [71:0] ob_y_r;
    reg [15:0] ob_size_r;
    reg [15:0] ob_shape_r;
    reg [15:0] ob_hp_r;

    //==========================================================================
    // Frame tick edge detection
    //==========================================================================
    reg ft_d; always @(posedge clk) ft_d <= frame_tick;
    wire tick = frame_tick && !ft_d;

    //==========================================================================
    // Helpers for extracting packed fields
    //==========================================================================
    function [9:0] get_en_x; input [2:0] i; begin get_en_x = en_x_r[i*10 +: 10]; end endfunction
    function [8:0] get_en_y; input [2:0] i; begin get_en_y = en_y_r[i*9 +: 9]; end endfunction

    //==========================================================================
    // Main Game Logic
    //==========================================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state         <= `STATE_MENU;
            state_timer   <= 11'd0;
            game_time     <= 11'd0;
            pause_cooldown<= 8'd0;
            sel_diff      <= `DIFF_EASY;
            sel_mode      <= 1'b0;
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
            ob_spawn_timer<= 9'd0;
            en_spawn_idx  <= 3'd0;
            ob_spawn_idx  <= 3'd0;
            lfsr          <= 16'hACE1;
            seg_cycle     <= 2'd0;

            en_act        <= 8'd0;
            en_x_r        <= 80'd0;
            en_y_r        <= 72'd0;
            en_hp_r       <= 16'd0;
            en_dir        <= 8'd0;
            en_fire_cd    <= 64'd0;

            pb_act        <= 16'd0;
            pb_x_r        <= 160'd0;
            pb_y_r        <= 144'd0;

            eb_act        <= 64'd0;
            eb_x_r        <= 640'd0;
            eb_y_r        <= 576'd0;

            ob_act        <= 8'd0;
            ob_x_r        <= 80'd0;
            ob_y_r        <= 72'd0;
            ob_size_r     <= 16'd0;
            ob_shape_r    <= 16'd0;
            ob_hp_r       <= 16'd0;

            seg_data      <= 16'd0;
            seg_mode      <= 2'd0;
            led           <= 8'd0;
        end else begin
            //==================================================================
            // Per-cycle updates (not gated by tick)
            //==================================================================

            // LFSR advances every game tick
            if (tick)
                lfsr <= {lfsr[14:0], 1'b0} ^ ({16{lfsr[15]}} & 16'hB400);

            // 7-seg cycle
            if (btn_cyc && tick) seg_cycle <= seg_cycle + 2'd1;

            //==================================================================
            // Game tick: all gameplay logic
            //==================================================================
            if (tick) begin

                // Pause cooldown
                if (pause_cooldown > 0) pause_cooldown <= pause_cooldown - 8'd1;

                case (state)
                //==============================================================
                // MENU
                //==============================================================
                `STATE_MENU: begin
                    pl_alive <= 1'b1;
                    pl_hp    <= cheat_ok ? 3'd7 : `PLAYER_HP_DEFAULT;
                    pl_inv   <= 8'd0;
                    pl_fire_cd <= 5'd0;
                    total_score <= 20'd0;
                    total_kills <= 8'd0;
                    game_time   <= 11'd0;
                    surv_cnt    <= 8'd0;
                    en_act      <= 8'd0;
                    pb_act      <= 16'd0;
                    eb_act      <= 64'd0;
                    ob_act      <= 8'd0;
                    pl_x        <= 10'd320;
                    pl_y        <= 9'd400;
                    pl_flash    <= 1'b1;
                    en_spawn_timer <= 9'd0;
                    en_spawn_idx   <= 3'd0;
                    ob_spawn_idx   <= 3'd0;
                    pl_weapon     <= 2'd0;
                    next_kills_upg<= 8'd10;

                    if (sw[7])  sel_diff <= `DIFF_EASY;
                    if (sw[8])  sel_diff <= `DIFF_NORMAL;
                    if (sw[9])  sel_diff <= `DIFF_HARD;
                    if (sw[10]) sel_diff <= `DIFF_HELL;
                    sel_mode <= sw[11];

                    if (start_key) begin
                        state       <= `STATE_PLAYING;
                        state_timer <= `GRACE_PERIOD;
                        difficulty  <= sel_diff;
                        mode        <= sel_mode;
                        pl_hp       <= cheat_ok ? 3'd7 :
                                       (sel_diff == `DIFF_EASY)  ? 3'd3 :
                                       (sel_diff == `DIFF_HELL)  ? 3'd2 : 3'd3;
                    end
                end

                //==============================================================
                // PLAYING
                //==============================================================
                `STATE_PLAYING: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    game_time <= game_time + 11'd1;

                    // Survival score: +1 per second
                    surv_cnt <= surv_cnt + 8'd1;
                    if (surv_cnt == 8'd59) begin
                        surv_cnt <= 8'd0;
                        total_score <= total_score + 20'd1;
                    end

                    //--- Pause ---
                    if (pause_key && pause_cooldown == 8'd0) begin
                        state <= `STATE_PAUSED;
                        pause_cooldown <= 8'd250; // ~4 sec cooldown
                    end

                    //--- Player Movement ---
                    if (pl_alive) begin
                        if (move_up    && pl_y > 9'd20)  pl_y <= pl_y - `PLAYER_SPEED;
                        if (move_down  && pl_y < 9'd455) pl_y <= pl_y + `PLAYER_SPEED;
                        if (move_left  && pl_x > 10'd20) pl_x <= pl_x - `PLAYER_SPEED;
                        if (move_right && pl_x < 10'd620)pl_x <= pl_x + `PLAYER_SPEED;
                    end

                    //--- Invincibility ---
                    if (pl_inv > 0) begin
                        pl_inv <= pl_inv - 8'd1;
                        pl_flash <= (pl_inv[2:1] != 2'b00); // flash on/off
                    end else begin
                        pl_flash <= 1'b1;
                    end

                    //--- Player Shooting ---
                    if (pl_fire_cd > 0) pl_fire_cd <= pl_fire_cd - 5'd1;
                    if (fire_key && pl_fire_cd == 5'd0 && pl_alive && pl_inv == 8'd0) begin
                        // Fire into slots 0 and 1 (dual bullets)
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
                        // Weapon level 2+: additional spread
                        if (pl_weapon >= 2'd2 && !pb_act[2]) begin
                            pb_act[2]   <= 1'b1;
                            pb_x_r[29:20] <= pl_x;
                            pb_y_r[26:18] <= pl_y - 9'd16;
                        end
                        pl_fire_cd <= (`PLAYER_FIRE_RATE - {3'd0, pl_weapon});
                    end

                    //--- Move Player Bullets ---
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
                    // Slots 3-15: simple upward movement
                    if (pb_act[3])  begin if (pb_y_r[35:27]<=9'd10) pb_act[3]<=0; else pb_y_r[35:27]<=pb_y_r[35:27]-`PLAYER_BULLET_SPD; end
                    if (pb_act[4])  begin if (pb_y_r[44:36]<=9'd10) pb_act[4]<=0; else pb_y_r[44:36]<=pb_y_r[44:36]-`PLAYER_BULLET_SPD; end

                    // Remainder handled by simple count for any active bullets in higher slots
                    if (pb_act[5])  begin if (pb_y_r[53:45]<=9'd10) pb_act[5]<=0; else pb_y_r[53:45]<=pb_y_r[53:45]-`PLAYER_BULLET_SPD; end
                    if (pb_act[6])  begin if (pb_y_r[62:54]<=9'd10) pb_act[6]<=0; else pb_y_r[62:54]<=pb_y_r[62:54]-`PLAYER_BULLET_SPD; end
                    if (pb_act[7])  begin if (pb_y_r[71:63]<=9'd10) pb_act[7]<=0; else pb_y_r[71:63]<=pb_y_r[71:63]-`PLAYER_BULLET_SPD; end

                    //--- Enemy Spawning ---
                    if (state_timer == 11'd0) begin
                        if (en_spawn_timer > 0) begin
                            en_spawn_timer <= en_spawn_timer - 9'd1;
                        end else begin
                            // Spawn enemy in round-robin slot
                            if (!en_act[en_spawn_idx]) begin
                                en_act[en_spawn_idx] <= 1'b1;
                                en_x_r[en_spawn_idx*10 +: 10] <= {4'd0, lfsr[5:0]} * 10'd10; // X: 0..630
                                en_y_r[en_spawn_idx*9 +: 9]   <= 9'd15;  // top
                                en_hp_r[en_spawn_idx*2 +: 2]  <= 2'd1;
                                en_fire_cd[en_spawn_idx*8 +: 8] <= `ENEMY_FIRE_BASE + {3'd0, lfsr[11:7]};
                                en_dir[en_spawn_idx] <= lfsr[6];
                            end
                            en_spawn_idx <= en_spawn_idx + 3'd1;
                            en_spawn_timer <= `ENEMY_SPAWN_BASE;
                        end
                    end

                    //--- Enemy Movement ---
                    // Each enemy: move down slowly, jitter left-right
                    // Enemy 0
                    if (en_act[0]) begin
                        if (en_y_r[8:0] < 9'd100) en_y_r[8:0] <= en_y_r[8:0] + 9'd1;
                        if (game_time[3:0] == 4'd0) begin
                            if (en_dir[0]) begin if (en_x_r[9:0] < 10'd620) en_x_r[9:0] <= en_x_r[9:0]+1; end
                            else           begin if (en_x_r[9:0] > 10'd20)  en_x_r[9:0] <= en_x_r[9:0]-1; end
                        end
                        if (en_y_r[8:0] > 9'd470) en_act[0] <= 1'b0;
                        // Enemy firing
                        if (en_fire_cd[7:0] > 0) en_fire_cd[7:0] <= en_fire_cd[7:0] - 8'd1;
                        else begin
                            // Fire into slot 0-7 (enemy 0 owns slots 0-7)
                            if (!eb_act[0]) begin eb_act[0]<=1; eb_x_r[9:0]<=en_x_r[9:0]-2; eb_y_r[8:0]<=en_y_r[8:0]; end
                            else if (!eb_act[1]) begin eb_act[1]<=1; eb_x_r[19:10]<=en_x_r[9:0]+2; eb_y_r[17:9]<=en_y_r[8:0]; end
                            en_fire_cd[7:0] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[5:0]};
                        end
                    end
                    // Enemy 1
                    if (en_act[1]) begin
                        if (en_y_r[17:9] < 9'd100) en_y_r[17:9] <= en_y_r[17:9] + 9'd1;
                        if (game_time[3:0] == 4'd1) begin
                            if (en_dir[1]) begin if (en_x_r[19:10] < 10'd620) en_x_r[19:10] <= en_x_r[19:10]+1; end
                            else           begin if (en_x_r[19:10] > 10'd20)  en_x_r[19:10] <= en_x_r[19:10]-1; end
                        end
                        if (en_y_r[17:9] > 9'd470) en_act[1] <= 1'b0;
                        if (en_fire_cd[15:8] > 0) en_fire_cd[15:8] <= en_fire_cd[15:8] - 8'd1;
                        else begin
                            if (!eb_act[8]) begin eb_act[8]<=1; eb_x_r[89:80]<=en_x_r[19:10]-2; eb_y_r[80:72]<=en_y_r[17:9]; end
                            else if (!eb_act[9]) begin eb_act[9]<=1; eb_x_r[99:90]<=en_x_r[19:10]+2; eb_y_r[89:81]<=en_y_r[17:9]; end
                            en_fire_cd[15:8] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[11:6]};
                        end
                    end
                    // Enemy 2
                    if (en_act[2]) begin
                        if (en_y_r[26:18] < 9'd100) en_y_r[26:18] <= en_y_r[26:18] + 9'd1;
                        if (game_time[3:0] == 4'd2) begin
                            if (en_dir[2]) begin if (en_x_r[29:20] < 10'd620) en_x_r[29:20] <= en_x_r[29:20]+1; end
                            else           begin if (en_x_r[29:20] > 10'd20)  en_x_r[29:20] <= en_x_r[29:20]-1; end
                        end
                        if (en_y_r[26:18] > 9'd470) en_act[2] <= 1'b0;
                        if (en_fire_cd[23:16] > 0) en_fire_cd[23:16] <= en_fire_cd[23:16] - 8'd1;
                        else begin
                            if (!eb_act[16]) begin eb_act[16]<=1; eb_x_r[169:160]<=en_x_r[29:20]-2; eb_y_r[152:144]<=en_y_r[26:18]; end
                            else if (!eb_act[17]) begin eb_act[17]<=1; eb_x_r[179:170]<=en_x_r[29:20]+2; eb_y_r[161:153]<=en_y_r[26:18]; end
                            en_fire_cd[23:16] <= `ENEMY_FIRE_BASE + {2'd0, lfsr[15:10]};
                        end
                    end
                    // Enemy 3
                    if (en_act[3]) begin
                        if (en_y_r[35:27] < 9'd100) en_y_r[35:27] <= en_y_r[35:27] + 9'd1;
                        if (en_y_r[35:27] > 9'd470) en_act[3] <= 1'b0;
                    end
                    // Enemy 4
                    if (en_act[4]) begin
                        if (en_y_r[44:36] < 9'd120) en_y_r[44:36] <= en_y_r[44:36] + 9'd1;
                        if (en_y_r[44:36] > 9'd470) en_act[4] <= 1'b0;
                    end
                    // Enemy 5-7 (simple existence check and removal)
                    if (en_act[5] && en_y_r[53:45] > 9'd470) en_act[5] <= 1'b0;
                    if (en_act[6] && en_y_r[62:54] > 9'd470) en_act[6] <= 1'b0;
                    if (en_act[7] && en_y_r[71:63] > 9'd470) en_act[7] <= 1'b0;

                    //--- Move Enemy Bullets ---
                    // Just move bullets straight down for now
                    if (eb_act[0] ) begin if (eb_y_r[8:0]  >9'd470) eb_act[0] <=0; else eb_y_r[8:0]  <=eb_y_r[8:0] +2; end
                    if (eb_act[1] ) begin if (eb_y_r[17:9] >9'd470) eb_act[1] <=0; else eb_y_r[17:9] <=eb_y_r[17:9]+2; end
                    if (eb_act[8] ) begin if (eb_y_r[80:72]>9'd470) eb_act[8] <=0; else eb_y_r[80:72]<=eb_y_r[80:72]+2; end
                    if (eb_act[9] ) begin if (eb_y_r[89:81]>9'd470) eb_act[9] <=0; else eb_y_r[89:81]<=eb_y_r[89:81]+2; end
                    if (eb_act[16]) begin if (eb_y_r[152:144]>9'd470) eb_act[16]<=0; else eb_y_r[152:144]<=eb_y_r[152:144]+2; end
                    if (eb_act[17]) begin if (eb_y_r[161:153]>9'd470) eb_act[17]<=0; else eb_y_r[161:153]<=eb_y_r[161:153]+2; end
                    // Mass removal for all active bullets that are off screen
                    if (eb_act[24] && eb_y_r[224:216]>9'd470) eb_act[24] <= 0;
                    if (eb_act[25] && eb_y_r[233:225]>9'd470) eb_act[25] <= 0;
                    if (eb_act[32] && eb_y_r[296:288]>9'd470) eb_act[32] <= 0;
                    if (eb_act[33] && eb_y_r[305:297]>9'd470) eb_act[33] <= 0;

                    //--- Obstacle Spawning ---
                    if (state_timer == 11'd0) begin
                        if (ob_spawn_timer > 0) begin
                            ob_spawn_timer <= ob_spawn_timer - 9'd1;
                        end else begin
                            if (!ob_act[ob_spawn_idx]) begin
                                ob_act[ob_spawn_idx] <= 1'b1;
                                ob_x_r[ob_spawn_idx*10 +: 10] <= {4'd0, lfsr[5:0]} * 10'd10 + 10'd5;
                                ob_y_r[ob_spawn_idx*9 +: 9]   <= 9'd25 + {2'd0, lfsr[14:9]};
                                ob_size_r[ob_spawn_idx*2 +: 2] <= lfsr[15:14] > 2'd2 ? 2'd1 : lfsr[15:14];
                                ob_shape_r[ob_spawn_idx*2 +: 2] <= lfsr[1:0];
                                ob_hp_r[ob_spawn_idx*2 +: 2] <= lfsr[13:12] + 2'd1;
                            end
                            ob_spawn_idx <= ob_spawn_idx + 3'd1;
                            ob_spawn_timer <= `OBSTACLE_SPAWN_BASE;
                        end
                    end

                    //--- Obstacle drift ---
                    if (game_time[4:0] == 5'd0) begin
                        if (ob_act[0] && ob_y_r[8:0]  <9'd460) ob_y_r[8:0]  <= ob_y_r[8:0] +1; else if (ob_y_r[8:0]  >9'd470) ob_act[0]<=0;
                        if (ob_act[1] && ob_y_r[17:9] <9'd460) ob_y_r[17:9] <= ob_y_r[17:9]+1; else if (ob_y_r[17:9] >9'd470) ob_act[1]<=0;
                        if (ob_act[2] && ob_y_r[26:18]<9'd460) ob_y_r[26:18]<= ob_y_r[26:18]+1; else if (ob_y_r[26:18]>9'd470) ob_act[2]<=0;
                        if (ob_act[3] && ob_y_r[35:27]<9'd460) ob_y_r[35:27]<= ob_y_r[35:27]+1; else if (ob_y_r[35:27]>9'd470) ob_act[3]<=0;
                    end

                    //==================================================================
                    // COLLISION DETECTION (simplified: check each active pair)
                    //==================================================================

                    //--- Player bullets (slots 0-2) vs enemies (slots 0-3) ---
                    // PB0 vs Enemy 0
                    if (pb_act[0] && en_act[0] &&
                        pb_x_r[9:0] >= en_x_r[9:0]-14 && pb_x_r[9:0] <= en_x_r[9:0]+14 &&
                        pb_y_r[8:0] >= en_y_r[8:0]-10 && pb_y_r[8:0] <= en_y_r[8:0]+10) begin
                        pb_act[0]<=0; en_act[0]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end
                    // PB0 vs Enemy 1
                    if (pb_act[0] && en_act[1] &&
                        pb_x_r[9:0] >= en_x_r[19:10]-14 && pb_x_r[9:0] <= en_x_r[19:10]+14 &&
                        pb_y_r[8:0] >= en_y_r[17:9]-10 && pb_y_r[8:0] <= en_y_r[17:9]+10) begin
                        pb_act[0]<=0; en_act[1]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end
                    // PB0 vs Enemy 2
                    if (pb_act[0] && en_act[2] &&
                        pb_x_r[9:0] >= en_x_r[29:20]-14 && pb_x_r[9:0] <= en_x_r[29:20]+14 &&
                        pb_y_r[8:0] >= en_y_r[26:18]-10 && pb_y_r[8:0] <= en_y_r[26:18]+10) begin
                        pb_act[0]<=0; en_act[2]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end
                    // PB1 vs Enemy 0
                    if (pb_act[1] && en_act[0] &&
                        pb_x_r[19:10] >= en_x_r[9:0]-14 && pb_x_r[19:10] <= en_x_r[9:0]+14 &&
                        pb_y_r[17:9] >= en_y_r[8:0]-10 && pb_y_r[17:9] <= en_y_r[8:0]+10) begin
                        pb_act[1]<=0; en_act[0]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end
                    // PB1 vs Enemy 1
                    if (pb_act[1] && en_act[1] &&
                        pb_x_r[19:10] >= en_x_r[19:10]-14 && pb_x_r[19:10] <= en_x_r[19:10]+14 &&
                        pb_y_r[17:9] >= en_y_r[17:9]-10 && pb_y_r[17:9] <= en_y_r[17:9]+10) begin
                        pb_act[1]<=0; en_act[1]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end
                    // PB2 vs Enemy 0
                    if (pb_act[2] && en_act[0] &&
                        pb_x_r[29:20] >= en_x_r[9:0]-14 && pb_x_r[29:20] <= en_x_r[9:0]+14 &&
                        pb_y_r[26:18] >= en_y_r[8:0]-10 && pb_y_r[26:18] <= en_y_r[8:0]+10) begin
                        pb_act[2]<=0; en_act[0]<=0;
                        total_score<=total_score+5; total_kills<=total_kills+1;
                    end

                    //--- Player bullets vs obstacles (slots 0-2 vs obs 0-3) ---
                    if (pb_act[0] && ob_act[0] &&
                        pb_x_r[9:0]>=ob_x_r[9:0]-20 && pb_x_r[9:0]<=ob_x_r[9:0]+20 &&
                        pb_y_r[8:0]>=ob_y_r[8:0]-20 && pb_y_r[8:0]<=ob_y_r[8:0]+20) begin
                        pb_act[0]<=0; ob_act[0]<=0;
                    end
                    if (pb_act[0] && ob_act[1] &&
                        pb_x_r[9:0]>=ob_x_r[19:10]-20 && pb_x_r[9:0]<=ob_x_r[19:10]+20 &&
                        pb_y_r[8:0]>=ob_y_r[17:9]-20 && pb_y_r[8:0]<=ob_y_r[17:9]+20) begin
                        pb_act[0]<=0; ob_act[1]<=0;
                    end
                    if (pb_act[1] && ob_act[0] &&
                        pb_x_r[19:10]>=ob_x_r[9:0]-20 && pb_x_r[19:10]<=ob_x_r[9:0]+20 &&
                        pb_y_r[17:9]>=ob_y_r[8:0]-20 && pb_y_r[17:9]<=ob_y_r[8:0]+20) begin
                        pb_act[1]<=0; ob_act[0]<=0;
                    end

                    //--- Enemy bullets (slots 0,1,8,9,16,17) vs player ---
                    if (pl_alive && pl_inv==0 && !cheat_ok) begin
                        if ((eb_act[0] && eb_x_r[9:0]>=pl_x-10 && eb_x_r[9:0]<=pl_x+10 &&
                             eb_y_r[8:0]>=pl_y-12 && eb_y_r[8:0]<=pl_y+12) ||
                            (eb_act[1] && eb_x_r[19:10]>=pl_x-10 && eb_x_r[19:10]<=pl_x+10 &&
                             eb_y_r[17:9]>=pl_y-12 && eb_y_r[17:9]<=pl_y+12) ||
                            (eb_act[8] && eb_x_r[89:80]>=pl_x-10 && eb_x_r[89:80]<=pl_x+10 &&
                             eb_y_r[80:72]>=pl_y-12 && eb_y_r[80:72]<=pl_y+12) ||
                            (eb_act[9] && eb_x_r[99:90]>=pl_x-10 && eb_x_r[99:90]<=pl_x+10 &&
                             eb_y_r[89:81]>=pl_y-12 && eb_y_r[89:81]<=pl_y+12)) begin
                            eb_act[3:0] <= 4'b0; eb_act[11:8] <= 4'b0; // clear nearby bullets
                            if (pl_hp <= 3'd1) begin
                                pl_hp <= 3'd0; pl_alive <= 1'b0;
                                state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                            end else begin
                                pl_hp <= pl_hp - 3'd1; pl_x <= 10'd320; pl_y <= 9'd400;
                                pl_inv <= `PLAYER_INV_TIME; eb_act <= 64'd0; // clear all enemy bullets
                            end
                        end
                    end

                    //--- Player vs obstacles ---
                    if (pl_alive && pl_inv==0 && !cheat_ok) begin
                        if ((ob_act[0] && pl_x>=ob_x_r[9:0]-20 && pl_x<=ob_x_r[9:0]+20 &&
                             pl_y>=ob_y_r[8:0]-20 && pl_y<=ob_y_r[8:0]+20) ||
                            (ob_act[1] && pl_x>=ob_x_r[19:10]-20 && pl_x<=ob_x_r[19:10]+20 &&
                             pl_y>=ob_y_r[17:9]-20 && pl_y<=ob_y_r[17:9]+20)) begin
                            ob_act[1:0] <= 2'b0;
                            pl_hp <= 3'd0; pl_alive <= 1'b0;
                            state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                        end
                    end

                    //--- Player vs enemies ---
                    if (pl_alive && pl_inv==0 && !cheat_ok) begin
                        if ((en_act[0] && pl_x>=en_x_r[9:0]-14 && pl_x<=en_x_r[9:0]+14 &&
                             pl_y>=en_y_r[8:0]-10 && pl_y<=en_y_r[8:0]+10) ||
                            (en_act[1] && pl_x>=en_x_r[19:10]-14 && pl_x<=en_x_r[19:10]+14 &&
                             pl_y>=en_y_r[17:9]-10 && pl_y<=en_y_r[17:9]+10)) begin
                            if (pl_hp <= 3'd1) begin
                                pl_hp <= 3'd0; pl_alive <= 1'b0;
                                state <= `STATE_GAMEOVER; state_timer <= `GAMEOVER_DISPLAY;
                            end else begin
                                pl_hp <= pl_hp - 3'd1; pl_x <= 10'd320; pl_y <= 9'd400;
                                pl_inv <= `PLAYER_INV_TIME; eb_act <= 64'd0;
                            end
                        end
                    end

                    //--- Weapon upgrade check ---
                    if (total_kills >= next_kills_upg && pl_weapon < 2'd3) begin
                        pl_weapon <= pl_weapon + 2'd1;
                        next_kills_upg <= next_kills_upg << 1; // double the requirement
                    end

                    //--- Win condition (score mode) ---
                    if (!mode && total_score >= `SCORE_WIN_TARGET && pl_alive) begin
                        state <= `STATE_WIN; state_timer <= `WIN_DISPLAY;
                    end
                end // STATE_PLAYING

                //==============================================================
                // PAUSED
                //==============================================================
                `STATE_PAUSED: begin
                    if ((pause_key || fire_key) && pause_cooldown == 8'd0) begin
                        state <= `STATE_PLAYING;
                        pause_cooldown <= 8'd250;
                    end
                end

                //==============================================================
                // GAME OVER
                //==============================================================
                `STATE_GAMEOVER: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    else begin
                        state <= `STATE_MENU;
                        en_act <= 8'd0; eb_act <= 64'd0; ob_act <= 8'd0; pb_act <= 16'd0;
                    end
                end

                //==============================================================
                // WIN
                //==============================================================
                `STATE_WIN: begin
                    if (state_timer > 0) state_timer <= state_timer - 11'd1;
                    else begin
                        state <= `STATE_MENU;
                        en_act <= 8'd0; eb_act <= 64'd0; ob_act <= 8'd0; pb_act <= 16'd0;
                    end
                end

                default: state <= `STATE_MENU;
                endcase
            end // tick

            //==================================================================
            // 7-Segment display (updated every cycle for scan multiplexing)
            //==================================================================
            case (seg_cycle)
                `SEGMODE_KILLS: seg_data <= {8'd0, total_kills};
                `SEGMODE_LIVES: seg_data <= {13'd0, pl_hp};
                `SEGMODE_SCORE: seg_data <= total_score[15:0];
                default:        seg_data <= total_score[15:0];
            endcase

            // LED overflow: upper bits when > 4 decimal digits
            if (seg_cycle == `SEGMODE_SCORE && total_score > 20'd9999)
                led <= total_score[19:12];
            else if (seg_cycle == `SEGMODE_KILLS && total_kills > 8'd99)
                led <= {6'd0, total_kills[7:6]};
            else
                led <= 8'd0;
        end // !rstn
    end // always

    //==========================================================================
    // Output assignments
    //==========================================================================
    assign lives = pl_hp;

    // State -> outputs
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
        pb_active  = pb_act;
        pb_x       = pb_x_r;
        pb_y       = pb_y_r;
        pb_type    = 32'd0;   // all player bullets are straight type
        eb_active  = eb_act;
        eb_x       = eb_x_r;
        eb_y       = eb_y_r;
        eb_type    = 128'd0;  // simplified: all straight
        ob_active  = ob_act;
        ob_x       = ob_x_r;
        ob_y       = ob_y_r;
        ob_size    = ob_size_r;
        ob_shape   = ob_shape_r;
    end
endmodule
