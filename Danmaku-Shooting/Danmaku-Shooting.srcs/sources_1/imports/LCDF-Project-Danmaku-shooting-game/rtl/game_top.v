//==============================================================================
// game_top.v — Top-level FPGA module for Aeroplane Danmaku Shooting
// Integrates VGA, game logic, input, and peripheral I/O for K7 board
// Port names match K7.xdc constraints file exactly
//==============================================================================
`include "game_defs.vh"

module game_top (
    input  wire        clk, rstn,
    output wire [3:0]  r, g, b,
    output wire        hs, vs,
    input  wire [3:0]  BTN,
    input  wire        BTNX4,
    input  wire [15:0] SW,
    inout  wire        ps2_clk, ps2_data,
    output wire [7:0]  SEGMENT,
    output wire [3:0]  AN,
    output wire        SEG_CLK, SEG_CLR, SEG_DT, SEG_EN,
    output wire [7:0]  LED,
    output wire        LED_CLK, LED_CLR, LED_DT, LED_EN
);
    reg [31:0] clkdiv;
    always @(posedge clk) clkdiv <= clkdiv + 1'b1;

    wire [15:0] SW_OK;
    genvar si;
    generate for (si=0; si<16; si=si+1) begin:gs AntiJitter #(4) u(.clk(clkdiv[15]),.I(SW[si]),.O(SW_OK[si])); end endgenerate

    wire [4:0] btn_raw = {BTNX4, BTN};
    wire [4:0] btn_db;
    genvar bi;
    generate for (bi=0; bi<5; bi=bi+1) begin:gb AntiJitter #(4) u(.clk(clkdiv[15]),.I(btn_raw[bi]),.O(btn_db[bi])); end endgenerate

    wire [7:0] ps2_scan_code;
    wire       ps2_key_ready;
    ps2_keyboard u_ps2(.clk(clkdiv[8]),.rstn(rstn),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.scan_code(ps2_scan_code),.key_ready(ps2_key_ready));

    wire [2:0]  game_state;
    wire [19:0] score;
    wire [7:0]  kills;
    wire [2:0]  lives;
    wire [1:0]  difficulty;
    wire        mode;
    wire [9:0]  pl_x;
    wire [8:0]  pl_y;
    wire        pl_active, pl_flash;
    wire [7:0]  en_active;
    wire [79:0] en_x;
    wire [71:0] en_y;
    wire [15:0] en_hp;
    wire [15:0] pb_active;
    wire [159:0] pb_x;
    wire [143:0] pb_y;
    wire [31:0]  pb_type;
    wire [63:0] eb_active;
    wire [639:0] eb_x;
    wire [575:0] eb_y;
    wire [127:0] eb_type;
    wire [7:0]  ob_active;
    wire [79:0] ob_x;
    wire [71:0] ob_y;
    wire [15:0] ob_size, ob_shape;
    wire        frame_tick;

    vga_top u_vga_top(.clk_100m(clk),.rstn(rstn),.game_state(game_state),.score(score),.kills(kills),.lives(lives),.difficulty(difficulty),.mode(mode),.pl_x(pl_x),.pl_y(pl_y),.pl_active(pl_active),.pl_flash(pl_flash),.en_active(en_active),.en_x(en_x),.en_y(en_y),.en_hp(en_hp),.pb_active(pb_active),.pb_x(pb_x),.pb_y(pb_y),.pb_type(pb_type),.eb_active(eb_active),.eb_x(eb_x),.eb_y(eb_y),.eb_type(eb_type),.ob_active(ob_active),.ob_x(ob_x),.ob_y(ob_y),.ob_size(ob_size),.ob_shape(ob_shape),.r(r),.g(g),.b(b),.hs(hs),.vs(vs),.frame_tick(frame_tick));

    wire [15:0] seg_data;
    wire [1:0]  seg_mode;
    wire [7:0]  led_data;

    game_logic u_game_logic(.clk(clk),.rstn(rstn),.frame_tick(frame_tick),.btn(btn_db),.ps2_scan(ps2_scan_code),.ps2_ready(ps2_key_ready),.sw(SW_OK),.pl_x(pl_x),.pl_y(pl_y),.pl_active(pl_active),.pl_flash(pl_flash),.game_state(game_state),.score(score),.kills(kills),.lives(lives),.difficulty(difficulty),.mode(mode),.en_active(en_active),.en_x(en_x),.en_y(en_y),.en_hp(en_hp),.pb_active(pb_active),.pb_x(pb_x),.pb_y(pb_y),.pb_type(pb_type),.eb_active(eb_active),.eb_x(eb_x),.eb_y(eb_y),.eb_type(eb_type),.ob_active(ob_active),.ob_x(ob_x),.ob_y(ob_y),.ob_size(ob_size),.ob_shape(ob_shape),.seg_data(seg_data),.seg_mode(seg_mode),.led(led_data));

    wire [1:0] seg_scan = clkdiv[15:14];
    wire [3:0] seg_point = (seg_mode == `SEGMODE_SCORE) ? 4'b0001 : 4'b0000;
    wire [3:0] seg_les = 4'b1111;
    DispNum u_dispnum(.scan(seg_scan),.HEXS(seg_data),.point(seg_point),.LES(seg_les),.AN(AN),.SEGMENT(SEGMENT));

    wire [31:0] seg32_data = {seg_data, 16'd0};
    wire [3:0]  sout_seg;
    Seg7Device u_seg7(.clkIO(clkdiv[3]),.clkScan(clkdiv[15:14]),.clkBlink(clkdiv[25]),.data(seg32_data),.point(8'h0),.LES(8'h0),.sout(sout_seg),.segment(),.anode());
    assign SEG_CLK = sout_seg[3];
    assign SEG_DT  = sout_seg[2];
    assign SEG_EN  = sout_seg[1];
    assign SEG_CLR = sout_seg[0];

    assign LED = led_data;

    wire [3:0] sout_led;
    ShiftReg #(.WIDTH(16)) u_led(.clk(clkdiv[3]),.pdata({8'd0, led_data}),.sout(sout_led));
    assign LED_CLK = sout_led[3];
    assign LED_DT  = sout_led[2];
    assign LED_EN  = sout_led[1];
    assign LED_CLR = sout_led[0];
endmodule
