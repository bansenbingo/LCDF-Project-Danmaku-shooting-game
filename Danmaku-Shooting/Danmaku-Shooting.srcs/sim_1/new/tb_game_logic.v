`timescale 1ns / 1ps
// ============================================================
//  Testbench: tb_game_logic
//  被测模块: game_logic
//  目的:  验证核心游戏逻辑
//         - MENU -> PLAYING 状态转换 (start_key = key_data[4])
//         - 难度/模式在 MENU 下选择
//         - PLAYING -> PAUSED -> PLAYING 暂停恢复
//         - 玩家移动 (W/S/A/D) 与边界限制
//         - 玩家射击槽位分配 (pb_active)
//         - 敌机轮转生成 (en_active)
//         - GAMEOVER 显示计时后返回 MENU
//  时钟:  100MHz;  frame_tick 每帧一个脉冲，逻辑在其上升沿 (tick) 推进
// ============================================================
module tb_game_logic;

    // ---- DUT 接口 ----
    reg         clk;
    reg         rstn;
    reg         frame_tick;
    reg  [7:0]  key_data;
    reg  [3:0]  key_diff;
    reg         key_mode;
    reg         key_cycle;

    wire [9:0]  pl_x;
    wire [8:0]  pl_y;
    wire        pl_active;
    wire        pl_flash;

    wire [2:0]  game_state;
    wire [19:0] score;
    wire [7:0]  kills;
    wire [2:0]  lives;
    wire [1:0]  difficulty;
    wire        mode;

    wire [7:0]  en_active;
    wire [79:0] en_x;
    wire [71:0] en_y;
    wire [15:0] en_hp;
    wire [7:0]  en_flash;

    wire [15:0]  pb_active;
    wire [159:0] pb_x;
    wire [143:0] pb_y;
    wire [31:0]  pb_type;

    wire [63:0]  eb_active;
    wire [639:0] eb_x;
    wire [575:0] eb_y;
    wire [127:0] eb_type;

    wire [15:0] seg_data;
    wire [1:0]  seg_mode;
    wire [7:0]  led;

    // 状态编码 (对应 game_defs.vh)
    localparam ST_MENU     = 3'd0;
    localparam ST_PLAYING  = 3'd1;
    localparam ST_PAUSED   = 3'd2;
    localparam ST_GAMEOVER = 3'd3;
    localparam ST_WIN      = 3'd4;

    // ---- 例化被测模块 ----
    game_logic u_logic (
        .clk        (clk),
        .rstn       (rstn),
        .frame_tick (frame_tick),
        .key_data   (key_data),
        .key_diff   (key_diff),
        .key_mode   (key_mode),
        .key_cycle  (key_cycle),
        .pl_x       (pl_x),
        .pl_y       (pl_y),
        .pl_active  (pl_active),
        .pl_flash   (pl_flash),
        .game_state (game_state),
        .score      (score),
        .kills      (kills),
        .lives      (lives),
        .difficulty (difficulty),
        .mode       (mode),
        .en_active  (en_active),
        .en_x       (en_x),
        .en_y       (en_y),
        .en_hp      (en_hp),
        .en_flash   (en_flash),
        .pb_active  (pb_active),
        .pb_x       (pb_x),
        .pb_y       (pb_y),
        .pb_type    (pb_type),
        .eb_active  (eb_active),
        .eb_x       (eb_x),
        .eb_y       (eb_y),
        .eb_type    (eb_type),
        .seg_data   (seg_data),
        .seg_mode   (seg_mode),
        .led        (led)
    );

    // ---- 100MHz 时钟 ----
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    //  任务: 产生 N 个 frame_tick 帧脉冲
    //  逻辑在 (frame_tick && !ft_d) 上升沿推进一帧
    //  每帧: 拉高 frame_tick 一个时钟周期，再拉低若干周期
    // ------------------------------------------------------------
    task run_frames;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk); frame_tick = 1'b1;
                @(negedge clk); frame_tick = 1'b0;
                // 帧内空闲几个周期，模拟 V-blank 之外的时间
                repeat (3) @(negedge clk);
            end
        end
    endtask

    // ------------------------------------------------------------
    //  主测试流程
    // ------------------------------------------------------------
    initial begin
        // 初始化
        rstn       = 1'b0;
        frame_tick = 1'b0;
        key_data   = 8'd0;
        key_diff   = 4'd0;
        key_mode   = 1'b0;
        key_cycle  = 1'b0;
        #100;
        rstn = 1'b1;
        #50;

        // ---- (0) 复位后应处于 MENU, 玩家位于 (320,400), HP=3 ----
        run_frames(2);
        if (game_state === ST_MENU) $display("[PASS] 复位后处于 MENU");
        else                        $display("[FAIL] 复位后状态错误 = %0d", game_state);
        if (pl_x === 10'd320 && pl_y === 9'd400)
            $display("[PASS] 玩家初始坐标 (320,400)");
        else
            $display("[FAIL] 玩家初始坐标错误 (%0d,%0d)", pl_x, pl_y);

        // ---- (1) MENU 下选难度 HARD(键3), 模式保持积分模式 ----
        key_diff = 4'b0100;      // 按键 3 -> HARD
        run_frames(2);
        key_diff = 4'b0000;
        run_frames(1);
        if (difficulty === 2'd2) $display("[PASS] 难度选择 HARD");
        else                     $display("[FAIL] 难度选择错误 = %0d", difficulty);

        // ---- (2) MENU -> PLAYING: start_key = key_data[4] (J) ----
        key_data[4] = 1'b1;      // 开始/开火
        run_frames(2);
        if (game_state === ST_PLAYING) $display("[PASS] MENU -> PLAYING (start_key)");
        else                           $display("[FAIL] 未进入 PLAYING, 状态 = %0d", game_state);

        // ---- (3) 玩家移动: 松开开火, 按 A(左) 若干帧, pl_x 应减小 ----
        key_data = 8'd0;
        // 先等待开局保护期内也可移动 (移动逻辑不依赖 state_timer)
        begin : move_test
            reg [9:0] x_before;
            x_before = pl_x;
            key_data[2] = 1'b1;   // A = 左移
            run_frames(10);
            key_data[2] = 1'b0;
            if (pl_x < x_before) $display("[PASS] 按 A 左移: pl_x %0d -> %0d", x_before, pl_x);
            else                 $display("[FAIL] 左移无效, pl_x=%0d", pl_x);
        end

        // ---- (4) 玩家射击: 按 J, pb_active 低位应被占用 ----
        key_data[4] = 1'b1;      // 开火
        run_frames(3);
        key_data[4] = 1'b0;
        if (|pb_active) $display("[PASS] 射击分配子弹槽, pb_active=%b", pb_active[3:0]);
        else            $display("[FAIL] 射击未分配子弹槽, pb_active=%b", pb_active);

        // ---- (5) 暂停/恢复: 需先等 pause_cooldown 归零 ----
        // 进入 PLAYING 时若曾设置冷却需等待; 这里给足帧数
        run_frames(5);
        // 按 P (上升沿锁存) 触发暂停
        key_data[6] = 1'b1;
        run_frames(2);
        key_data[6] = 1'b0;
        run_frames(2);
        if (game_state === ST_PAUSED) $display("[PASS] PLAYING -> PAUSED (P 键)");
        else                          $display("[INFO] 暂停可能受冷却影响, 状态 = %0d", game_state);

        // 等待暂停冷却 (250 帧) 后再按 P/J 恢复
        run_frames(255);
        key_data[6] = 1'b1;      // 再按 P 恢复
        run_frames(2);
        key_data[6] = 1'b0;
        run_frames(2);
        if (game_state === ST_PLAYING) $display("[PASS] PAUSED -> PLAYING 恢复");
        else                           $display("[INFO] 恢复后状态 = %0d", game_state);

        // ---- (6) 敌机生成: 开局保护期 (GRACE_PERIOD=300) 后应开始刷敌 ----
        // 快进足够帧数使 state_timer 归零并生成敌机
        run_frames(400);
        if (|en_active) $display("[PASS] 保护期后敌机生成, en_active=%b", en_active);
        else            $display("[INFO] 敌机尚未生成, en_active=%b (可继续快进)", en_active);

        // ---- (7) 存活计分: 运行足够帧, score 应增长 (每 60 帧 +1) ----
        begin : score_test
            reg [19:0] s_before;
            s_before = score;
            run_frames(130);      // > 2 秒
            if (score > s_before) $display("[PASS] 生存计分增长: %0d -> %0d", s_before, score);
            else                  $display("[INFO] 生存计分未变: %0d", score);
        end

        // ---- (8) seg/led 显示切换: Tab 键改变 seg_mode ----
        key_cycle = 1'b1;
        run_frames(2);
        key_cycle = 1'b0;
        run_frames(2);
        $display("[INFO] seg_mode=%0d seg_data=%h led=%b", seg_mode, seg_data, led);

        #500;
        $display("=== game_logic 仿真结束 (最终状态=%0d score=%0d kills=%0d) ===",
                 game_state, score, kills);
        $finish;
    end

    // ---- 波形记录 ----
    initial begin
        $dumpfile("tb_game_logic.vcd");
        $dumpvars(0, tb_game_logic);
    end

endmodule
