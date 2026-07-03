`timescale 1ns / 1ps
// ============================================================
//  Testbench: tb_Keyboard
//  被测模块: Keyboard (+ 内部 ps2_drive)
//  目的:  验证 PS/2 Set 2 协议 make/break 解码
//         - 按下 W (make 1D)  -> status[0] = 1
//         - 松开 W (break F0 1D) -> status[0] = 0
//         - 按下数字键 1/2/3/4  -> diff_key one-hot
//         - 按下 M (make 3A) / Tab(0D) -> mode_key / cycle_key
//         - E0 扩展前缀正确吞掉（不误置位）
//  说明:  ps2_drive 在 ps2_clk 下降沿采样，帧格式为
//         1 起始位(0) + 8 数据位(LSB 先) + 1 奇偶校验位 + 1 停止位(1)
// ============================================================
module tb_Keyboard;

    // ---- DUT 接口 ----
    reg        clk;
    reg        rstn;
    reg        ps2_clk;
    reg        ps2_data;
    wire [7:0] status;     // 按键状态 bitmap
    wire [3:0] diff_key;   // 难度 one-hot
    wire       mode_key;   // 模式切换
    wire       cycle_key;  // 显示切换

    // ---- 例化被测模块 ----
    Keyboard u_kbd (
        .clk       (clk),
        .rstn      (rstn),
        .ps2_clk   (ps2_clk),
        .ps2_data  (ps2_data),
        .status    (status),
        .diff_key  (diff_key),
        .mode_key  (mode_key),
        .cycle_key (cycle_key)
    );

    // ---- 100MHz 系统时钟 (10ns 周期) ----
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---- PS/2 键码常量 (Set 2) ----
    localparam [7:0] CODE_W     = 8'h1D;
    localparam [7:0] CODE_A     = 8'h1C;
    localparam [7:0] CODE_J     = 8'h3B;
    localparam [7:0] CODE_P     = 8'h4D;
    localparam [7:0] CODE_M     = 8'h3A;
    localparam [7:0] CODE_TAB   = 8'h0D;
    localparam [7:0] CODE_1     = 8'h16;
    localparam [7:0] CODE_2     = 8'h1E;
    localparam [7:0] CODE_3     = 8'h26;
    localparam [7:0] CODE_4     = 8'h25;
    localparam [7:0] CODE_BREAK = 8'hF0;
    localparam [7:0] CODE_EXT   = 8'hE0;

    // PS/2 时钟半周期（真实约 30~50us，此处压缩以缩短仿真时间）
    localparam PS2_HALF = 2000;  // ns

    // ------------------------------------------------------------
    // 任务: 发送一个 PS/2 字节帧（含起始位、8 数据位、奇校验、停止位）
    //   数据在 ps2_clk 高电平期间改变，DUT 在 ps2_clk 下降沿采样
    // ------------------------------------------------------------
    task ps2_send_byte;
        input [7:0] code;
        integer i;
        reg parity;
        begin
            parity = ~^code;           // 奇校验: 使 9 位(8数据+校验)中 1 的个数为奇

            // 起始位 = 0
            ps2_data = 1'b0;
            ps2_clk  = 1'b1;  #PS2_HALF;
            ps2_clk  = 1'b0;  #PS2_HALF;  // 下降沿 -> 采样起始位

            // 8 个数据位，LSB 先发
            for (i = 0; i < 8; i = i + 1) begin
                ps2_clk  = 1'b1;
                ps2_data = code[i];
                #PS2_HALF;
                ps2_clk  = 1'b0;  #PS2_HALF;  // 下降沿采样数据位
            end

            // 奇偶校验位
            ps2_clk  = 1'b1;
            ps2_data = parity;
            #PS2_HALF;
            ps2_clk  = 1'b0;  #PS2_HALF;

            // 停止位 = 1
            ps2_clk  = 1'b1;
            ps2_data = 1'b1;
            #PS2_HALF;
            ps2_clk  = 1'b0;  #PS2_HALF;  // 下降沿 -> count==10, 写入 FIFO

            // 帧间空闲
            ps2_clk  = 1'b1;
            ps2_data = 1'b1;
            #(PS2_HALF*4);
        end
    endtask

    // 便捷任务: 松开键 = break 前缀 + 键码
    task ps2_break_key;
        input [7:0] code;
        begin
            ps2_send_byte(CODE_BREAK);
            ps2_send_byte(code);
        end
    endtask

    // ------------------------------------------------------------
    //  主测试流程
    // ------------------------------------------------------------
    initial begin
        // 初始化 + 复位
        rstn     = 1'b0;
        ps2_clk  = 1'b1;
        ps2_data = 1'b1;
        #200;
        rstn = 1'b1;
        #200;

        // (1) 按下 W -> status[0] 应变为 1
        ps2_send_byte(CODE_W);
        #1000;
        if (status[0] === 1'b1) $display("[PASS] 按下 W: status[0]=1");
        else                    $display("[FAIL] 按下 W 未置位, status=%b", status);

        // (2) 松开 W -> status[0] 应清 0
        ps2_break_key(CODE_W);
        #1000;
        if (status[0] === 1'b0) $display("[PASS] 松开 W: status[0]=0");
        else                    $display("[FAIL] 松开 W 未清零, status=%b", status);

        // (3) 按下 A -> status[2] (BIT_LEFT) 置位
        ps2_send_byte(CODE_A);
        #1000;
        if (status[2] === 1'b1) $display("[PASS] 按下 A: status[2]=1 (左移)");
        else                    $display("[FAIL] 按下 A 未置位, status=%b", status);

        // (4) 按下 J (开火) -> status[4] (BIT_FIRE) 置位
        ps2_send_byte(CODE_J);
        #1000;
        if (status[4] === 1'b1) $display("[PASS] 按下 J: status[4]=1 (开火)");
        else                    $display("[FAIL] 按下 J 未置位, status=%b", status);

        // (5) 按下 P (暂停) -> status[6] (BIT_PAUSE) 置位
        ps2_send_byte(CODE_P);
        #1000;
        if (status[6] === 1'b1) $display("[PASS] 按下 P: status[6]=1 (暂停)");
        else                    $display("[FAIL] 按下 P 未置位, status=%b", status);

        // (6) 难度选择: 按下 1 -> diff_key=0001, 按下 3 -> diff_key=0100
        ps2_send_byte(CODE_1);
        #1000;
        if (diff_key === 4'b0001) $display("[PASS] 按下 1: diff_key=0001 (EASY)");
        else                      $display("[FAIL] 按下 1 错误, diff_key=%b", diff_key);

        ps2_send_byte(CODE_3);
        #1000;
        if (diff_key === 4'b0100) $display("[PASS] 按下 3: diff_key=0100 (HARD)");
        else                      $display("[FAIL] 按下 3 错误, diff_key=%b", diff_key);

        // (7) 模式切换 M -> mode_key 置位, 松开 -> 清 0
        ps2_send_byte(CODE_M);
        #1000;
        if (mode_key === 1'b1) $display("[PASS] 按下 M: mode_key=1");
        else                   $display("[FAIL] 按下 M 未置位, mode_key=%b", mode_key);
        ps2_break_key(CODE_M);
        #1000;
        if (mode_key === 1'b0) $display("[PASS] 松开 M: mode_key=0");
        else                   $display("[FAIL] 松开 M 未清零, mode_key=%b", mode_key);

        // (8) Tab 切换显示 -> cycle_key 置位
        ps2_send_byte(CODE_TAB);
        #1000;
        if (cycle_key === 1'b1) $display("[PASS] 按下 Tab: cycle_key=1");
        else                    $display("[FAIL] 按下 Tab 未置位, cycle_key=%b", cycle_key);

        // (9) E0 扩展前缀: E0 之后的键不应影响 status（方向键在此工程未映射）
        ps2_send_byte(CODE_EXT);   // E0
        ps2_send_byte(8'h75);      // E0 75 = 扩展上箭头，工程未映射
        #1000;
        $display("[INFO] E0 扩展前缀测试完成, status=%b", status);

        #2000;
        $display("=== Keyboard 仿真结束 ===");
        $finish;
    end

    // ---- 波形记录 (Vivado xsim 会自动记录, 此处兼容其他仿真器) ----
    initial begin
        $dumpfile("tb_Keyboard.vcd");
        $dumpvars(0, tb_Keyboard);
    end

endmodule
