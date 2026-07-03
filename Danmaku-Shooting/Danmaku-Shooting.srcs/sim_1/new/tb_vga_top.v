`timescale 1ns / 1ps
// ============================================================
//  Testbench: tb_vga_top
//  被测模块: vga_top (+ vgac + 各 render + ROM_f 字库 IP)
//  目的:  验证 VGA 渲染管线时序与像素输出
//         - 100MHz -> 25MHz vga_clk (4 分频) 驱动 vgac
//         - row_addr[8:0]/col_addr[9:0] 扫描坐标递进
//         - rdn 有效区为低、消隐区为高
//         - hs/vs 行/场同步脉冲
//         - r/g/b 像素数据 (消隐期强制为 0)
//         - vs 下降沿 -> frame_tick 约 60Hz 脉冲
//  注意:  hud_render / menu_render 例化了 ROM_f (Distributed Memory
//         ROM IP)。运行本仿真前需保证工程已生成该 IP (i.coe 初始化)，
//         否则请在 Vivado 中先 Generate Output Products。
// ============================================================
module tb_vga_top;

    // ---- 时钟/复位 ----
    reg         clk_100m;
    reg         rstn;

    // ---- 游戏状态输入 (给定一组静态测试场景) ----
    reg  [2:0]  game_state;
    reg  [19:0] score;
    reg  [7:0]  kills;
    reg  [2:0]  lives;
    reg  [1:0]  difficulty;
    reg         mode;

    // ---- 玩家 ----
    reg  [9:0]  pl_x;
    reg  [8:0]  pl_y;
    reg         pl_active;
    reg         pl_flash;

    // ---- 敌机 ----
    reg  [7:0]  en_active;
    reg  [79:0] en_x;
    reg  [71:0] en_y;
    reg  [15:0] en_hp;
    reg  [7:0]  en_flash;

    // ---- 玩家子弹 ----
    reg  [15:0]  pb_active;
    reg  [159:0] pb_x;
    reg  [143:0] pb_y;
    reg  [31:0]  pb_type;

    // ---- 敌方子弹 ----
    reg  [63:0]  eb_active;
    reg  [639:0] eb_x;
    reg  [575:0] eb_y;
    reg  [127:0] eb_type;

    // ---- VGA 输出 ----
    wire [3:0]  r, g, b;
    wire        hs, vs;
    wire        frame_tick;

    // 状态编码
    localparam ST_MENU    = 3'd0;
    localparam ST_PLAYING = 3'd1;

    // ---- 例化被测模块 ----
    vga_top u_vga (
        .clk_100m   (clk_100m),
        .rstn       (rstn),
        .game_state (game_state),
        .score      (score),
        .kills      (kills),
        .lives      (lives),
        .difficulty (difficulty),
        .mode       (mode),
        .pl_x       (pl_x),
        .pl_y       (pl_y),
        .pl_active  (pl_active),
        .pl_flash   (pl_flash),
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
        .r(r), .g(g), .b(b),
        .hs(hs), .vs(vs),
        .frame_tick (frame_tick)
    );

    // ---- 100MHz 时钟 (10ns) ----
    initial clk_100m = 1'b0;
    always #5 clk_100m = ~clk_100m;

    // 观测: vgac 内部扫描坐标 / rdn (层次化引用, xsim 支持)
    wire [8:0] row_addr = u_vga.row_addr;
    wire [9:0] col_addr = u_vga.col_addr;
    wire       rdn      = u_vga.rdn;

    // ---- frame_tick 计数, 用于验证约 60Hz 帧脉冲 ----
    integer ft_count;
    always @(posedge clk_100m or negedge rstn) begin
        if (!rstn) ft_count <= 0;
        else if (frame_tick) ft_count <= ft_count + 1;
    end

    // ---- 检测 hs/vs 是否产生跳变 ----
    integer hs_edges, vs_edges;
    reg hs_d, vs_d;
    always @(posedge clk_100m) begin
        hs_d <= hs; vs_d <= vs;
        if (hs ^ hs_d) hs_edges = hs_edges + 1;
        if (vs ^ vs_d) vs_edges = vs_edges + 1;
    end

    // ------------------------------------------------------------
    //  主测试流程
    // ------------------------------------------------------------
    initial begin
        // 初始化所有输入
        rstn       = 1'b0;
        game_state = ST_PLAYING;
        score      = 20'd1234;
        kills      = 8'd7;
        lives      = 3'd3;
        difficulty = 2'd1;      // NORMAL
        mode       = 1'b0;      // 积分模式
        pl_x       = 10'd320;
        pl_y       = 9'd400;
        pl_active  = 1'b1;
        pl_flash   = 1'b1;

        // 放置一架敌机 (槽 0) 在屏幕中部
        en_active  = 8'b0000_0001;
        en_x       = 80'd0;  en_x[9:0]  = 10'd320;
        en_y       = 72'd0;  en_y[8:0]  = 9'd120;
        en_hp      = 16'd0;  en_hp[1:0] = 2'd2;
        en_flash   = 8'd0;

        // 放置一颗玩家子弹 (槽 0)
        pb_active  = 16'b0000_0000_0000_0001;
        pb_x       = 160'd0; pb_x[9:0] = 10'd320;
        pb_y       = 144'd0; pb_y[8:0] = 9'd300;
        pb_type    = 32'd0;

        // 放置一颗敌方子弹 (槽 0)
        eb_active  = 64'd1;
        eb_x       = 640'd0; eb_x[9:0] = 10'd200;
        eb_y       = 576'd0; eb_y[8:0] = 9'd200;
        eb_type    = 128'd0;

        hs_edges = 0; vs_edges = 0;
        hs_d = 0; vs_d = 0;

        #200;
        rstn = 1'b1;

        // 运行足够长时间覆盖至少一整帧 (525 行 * 800 像素 * 4 (100MHz/25MHz) * 10ns)
        // 一帧约 = 525*800*40ns = 16.8 ms; 这里跑约 1.2 帧
        #20_000_000;   // 20 ms

        // ---- 检查项 ----
        if (hs_edges > 100) $display("[PASS] hs 行同步持续跳变 (edges=%0d)", hs_edges);
        else                $display("[FAIL] hs 跳变过少 (edges=%0d)", hs_edges);

        if (vs_edges >= 2)  $display("[PASS] vs 场同步产生跳变 (edges=%0d)", vs_edges);
        else                $display("[FAIL] vs 跳变过少 (edges=%0d)", vs_edges);

        if (ft_count >= 1)  $display("[PASS] frame_tick 帧脉冲产生 (count=%0d)", ft_count);
        else                $display("[FAIL] 未检测到 frame_tick");

        $display("[INFO] 当前 row_addr=%0d col_addr=%0d rdn=%b rgb=%h%h%h",
                 row_addr, col_addr, rdn, r, g, b);

        $display("=== vga_top 仿真结束 ===");
        $finish;
    end

    // ---- 监视: 采样到有效显示区时打印一次非黑像素 ----
    integer nonblack_seen;
    initial nonblack_seen = 0;
    always @(posedge clk_100m) begin
        if (rstn && !rdn && (r != 4'h0 || g != 4'h0 || b != 4'h0) && nonblack_seen < 5) begin
            $display("[INFO] 有效像素输出 @row=%0d col=%0d  r=%h g=%h b=%h",
                     row_addr, col_addr, r, g, b);
            nonblack_seen = nonblack_seen + 1;
        end
    end

    // ---- 波形记录 ----
    initial begin
        $dumpfile("tb_vga_top.vcd");
        $dumpvars(0, tb_vga_top);
    end

endmodule
