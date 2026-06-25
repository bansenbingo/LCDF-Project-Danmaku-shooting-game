//==============================================================================
// text_render.v — Pure combinational character ROM and text renderer
// 8x8 font, BGR color. Used by HUD and menu renderers.
// ZJU VGA rules: combinational only
//==============================================================================
`include "game_defs.vh"

module text_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  tx,         // text block base X
    input  wire [9:0]  ty,         // text block base Y
    input  wire [4:0]  char_code,  // character to render (A-Z=0-25, 0-9=26-35, space=36, :=37, /=38, |=39, -=40, >=41, .=42, !=43)
    input  wire        enable,     // text module enable
    output wire        hit,
    output wire [11:0] color
);
    // Character position within 8x8 grid
    wire [2:0] cx = sx[2:0] - tx[2:0];  // column within char (0-7)
    wire [2:0] cy = sy[2:0] - ty[2:0];  // row within char (0-7)

    // Check if (sx, sy) is within this character's 8x8 bounding box
    wire in_char_box = enable &&
                       (sx >= tx) && (sx < tx + 10'd8) &&
                       (sy >= ty) && (sy < ty + 10'd8);

    // Character ROM: 8 rows × 8 bits per character
    // Font data stored as 8 bytes per character. Bit 7 = leftmost pixel.
    reg [7:0] char_row;
    always @* begin
        case ({char_code, cy})
            //--- A (0) ---
            {5'd0,  3'd0}: char_row = 8'b00111000;
            {5'd0,  3'd1}: char_row = 8'b01101100;
            {5'd0,  3'd2}: char_row = 8'b11000110;
            {5'd0,  3'd3}: char_row = 8'b11000110;
            {5'd0,  3'd4}: char_row = 8'b11111110;
            {5'd0,  3'd5}: char_row = 8'b11000110;
            {5'd0,  3'd6}: char_row = 8'b11000110;
            {5'd0,  3'd7}: char_row = 8'b00000000;
            //--- B (1) ---
            {5'd1,  3'd0}: char_row = 8'b11111100;
            {5'd1,  3'd1}: char_row = 8'b11000110;
            {5'd1,  3'd2}: char_row = 8'b11000110;
            {5'd1,  3'd3}: char_row = 8'b11111100;
            {5'd1,  3'd4}: char_row = 8'b11000110;
            {5'd1,  3'd5}: char_row = 8'b11000110;
            {5'd1,  3'd6}: char_row = 8'b11111100;
            {5'd1,  3'd7}: char_row = 8'b00000000;
            //--- C (2) ---
            {5'd2,  3'd0}: char_row = 8'b00111100;
            {5'd2,  3'd1}: char_row = 8'b01100110;
            {5'd2,  3'd2}: char_row = 8'b11000000;
            {5'd2,  3'd3}: char_row = 8'b11000000;
            {5'd2,  3'd4}: char_row = 8'b11000000;
            {5'd2,  3'd5}: char_row = 8'b01100110;
            {5'd2,  3'd6}: char_row = 8'b00111100;
            {5'd2,  3'd7}: char_row = 8'b00000000;
            //--- D (3) ---
            {5'd3,  3'd0}: char_row = 8'b11111000;
            {5'd3,  3'd1}: char_row = 8'b11001100;
            {5'd3,  3'd2}: char_row = 8'b11000110;
            {5'd3,  3'd3}: char_row = 8'b11000110;
            {5'd3,  3'd4}: char_row = 8'b11000110;
            {5'd3,  3'd5}: char_row = 8'b11001100;
            {5'd3,  3'd6}: char_row = 8'b11111000;
            {5'd3,  3'd7}: char_row = 8'b00000000;
            //--- E (4) ---
            {5'd4,  3'd0}: char_row = 8'b11111110;
            {5'd4,  3'd1}: char_row = 8'b11000000;
            {5'd4,  3'd2}: char_row = 8'b11000000;
            {5'd4,  3'd3}: char_row = 8'b11111100;
            {5'd4,  3'd4}: char_row = 8'b11000000;
            {5'd4,  3'd5}: char_row = 8'b11000000;
            {5'd4,  3'd6}: char_row = 8'b11111110;
            {5'd4,  3'd7}: char_row = 8'b00000000;
            //--- F (5) ---
            {5'd5,  3'd0}: char_row = 8'b11111110;
            {5'd5,  3'd1}: char_row = 8'b11000000;
            {5'd5,  3'd2}: char_row = 8'b11000000;
            {5'd5,  3'd3}: char_row = 8'b11111100;
            {5'd5,  3'd4}: char_row = 8'b11000000;
            {5'd5,  3'd5}: char_row = 8'b11000000;
            {5'd5,  3'd6}: char_row = 8'b11000000;
            {5'd5,  3'd7}: char_row = 8'b00000000;
            //--- G (6) ---
            {5'd6,  3'd0}: char_row = 8'b00111100;
            {5'd6,  3'd1}: char_row = 8'b01100110;
            {5'd6,  3'd2}: char_row = 8'b11000000;
            {5'd6,  3'd3}: char_row = 8'b11001110;
            {5'd6,  3'd4}: char_row = 8'b11000110;
            {5'd6,  3'd5}: char_row = 8'b01100110;
            {5'd6,  3'd6}: char_row = 8'b00111100;
            {5'd6,  3'd7}: char_row = 8'b00000000;
            //--- H (7) ---
            {5'd7,  3'd0}: char_row = 8'b11000110;
            {5'd7,  3'd1}: char_row = 8'b11000110;
            {5'd7,  3'd2}: char_row = 8'b11000110;
            {5'd7,  3'd3}: char_row = 8'b11111110;
            {5'd7,  3'd4}: char_row = 8'b11000110;
            {5'd7,  3'd5}: char_row = 8'b11000110;
            {5'd7,  3'd6}: char_row = 8'b11000110;
            {5'd7,  3'd7}: char_row = 8'b00000000;
            //--- I (8) ---
            {5'd8,  3'd0}: char_row = 8'b01111100;
            {5'd8,  3'd1}: char_row = 8'b00010000;
            {5'd8,  3'd2}: char_row = 8'b00010000;
            {5'd8,  3'd3}: char_row = 8'b00010000;
            {5'd8,  3'd4}: char_row = 8'b00010000;
            {5'd8,  3'd5}: char_row = 8'b00010000;
            {5'd8,  3'd6}: char_row = 8'b01111100;
            {5'd8,  3'd7}: char_row = 8'b00000000;
            //--- J (9) ---
            {5'd9,  3'd0}: char_row = 8'b00011110;
            {5'd9,  3'd1}: char_row = 8'b00000110;
            {5'd9,  3'd2}: char_row = 8'b00000110;
            {5'd9,  3'd3}: char_row = 8'b00000110;
            {5'd9,  3'd4}: char_row = 8'b11000110;
            {5'd9,  3'd5}: char_row = 8'b11000110;
            {5'd9,  3'd6}: char_row = 8'b01111100;
            {5'd9,  3'd7}: char_row = 8'b00000000;
            //--- K (10) ---
            {5'd10, 3'd0}: char_row = 8'b11000110;
            {5'd10, 3'd1}: char_row = 8'b11001100;
            {5'd10, 3'd2}: char_row = 8'b11011000;
            {5'd10, 3'd3}: char_row = 8'b11110000;
            {5'd10, 3'd4}: char_row = 8'b11011000;
            {5'd10, 3'd5}: char_row = 8'b11001100;
            {5'd10, 3'd6}: char_row = 8'b11000110;
            {5'd10, 3'd7}: char_row = 8'b00000000;
            //--- L (11) ---
            {5'd11, 3'd0}: char_row = 8'b11000000;
            {5'd11, 3'd1}: char_row = 8'b11000000;
            {5'd11, 3'd2}: char_row = 8'b11000000;
            {5'd11, 3'd3}: char_row = 8'b11000000;
            {5'd11, 3'd4}: char_row = 8'b11000000;
            {5'd11, 3'd5}: char_row = 8'b11000000;
            {5'd11, 3'd6}: char_row = 8'b11111110;
            {5'd11, 3'd7}: char_row = 8'b00000000;
            //--- M (12) ---
            {5'd12, 3'd0}: char_row = 8'b10000010;
            {5'd12, 3'd1}: char_row = 8'b11000110;
            {5'd12, 3'd2}: char_row = 8'b11101110;
            {5'd12, 3'd3}: char_row = 8'b10111010;
            {5'd12, 3'd4}: char_row = 8'b10010010;
            {5'd12, 3'd5}: char_row = 8'b10000010;
            {5'd12, 3'd6}: char_row = 8'b10000010;
            {5'd12, 3'd7}: char_row = 8'b00000000;
            //--- N (13) ---
            {5'd13, 3'd0}: char_row = 8'b11000110;
            {5'd13, 3'd1}: char_row = 8'b11100110;
            {5'd13, 3'd2}: char_row = 8'b11110110;
            {5'd13, 3'd3}: char_row = 8'b11011110;
            {5'd13, 3'd4}: char_row = 8'b11001110;
            {5'd13, 3'd5}: char_row = 8'b11000110;
            {5'd13, 3'd6}: char_row = 8'b11000110;
            {5'd13, 3'd7}: char_row = 8'b00000000;
            //--- O (14) ---
            {5'd14, 3'd0}: char_row = 8'b00111000;
            {5'd14, 3'd1}: char_row = 8'b01101100;
            {5'd14, 3'd2}: char_row = 8'b11000110;
            {5'd14, 3'd3}: char_row = 8'b11000110;
            {5'd14, 3'd4}: char_row = 8'b11000110;
            {5'd14, 3'd5}: char_row = 8'b01101100;
            {5'd14, 3'd6}: char_row = 8'b00111000;
            {5'd14, 3'd7}: char_row = 8'b00000000;
            //--- P (15) ---
            {5'd15, 3'd0}: char_row = 8'b11111100;
            {5'd15, 3'd1}: char_row = 8'b11000110;
            {5'd15, 3'd2}: char_row = 8'b11000110;
            {5'd15, 3'd3}: char_row = 8'b11111100;
            {5'd15, 3'd4}: char_row = 8'b11000000;
            {5'd15, 3'd5}: char_row = 8'b11000000;
            {5'd15, 3'd6}: char_row = 8'b11000000;
            {5'd15, 3'd7}: char_row = 8'b00000000;
            //--- Q (16) ---
            {5'd16, 3'd0}: char_row = 8'b00111000;
            {5'd16, 3'd1}: char_row = 8'b01101100;
            {5'd16, 3'd2}: char_row = 8'b11000110;
            {5'd16, 3'd3}: char_row = 8'b11000110;
            {5'd16, 3'd4}: char_row = 8'b11010110;
            {5'd16, 3'd5}: char_row = 8'b01101100;
            {5'd16, 3'd6}: char_row = 8'b00110110;
            {5'd16, 3'd7}: char_row = 8'b00000000;
            //--- R (17) ---
            {5'd17, 3'd0}: char_row = 8'b11111100;
            {5'd17, 3'd1}: char_row = 8'b11000110;
            {5'd17, 3'd2}: char_row = 8'b11000110;
            {5'd17, 3'd3}: char_row = 8'b11111100;
            {5'd17, 3'd4}: char_row = 8'b11011000;
            {5'd17, 3'd5}: char_row = 8'b11001100;
            {5'd17, 3'd6}: char_row = 8'b11000110;
            {5'd17, 3'd7}: char_row = 8'b00000000;
            //--- S (18) ---
            {5'd18, 3'd0}: char_row = 8'b01111100;
            {5'd18, 3'd1}: char_row = 8'b11000110;
            {5'd18, 3'd2}: char_row = 8'b11000000;
            {5'd18, 3'd3}: char_row = 8'b01111100;
            {5'd18, 3'd4}: char_row = 8'b00000110;
            {5'd18, 3'd5}: char_row = 8'b11000110;
            {5'd18, 3'd6}: char_row = 8'b01111100;
            {5'd18, 3'd7}: char_row = 8'b00000000;
            //--- T (19) ---
            {5'd19, 3'd0}: char_row = 8'b11111110;
            {5'd19, 3'd1}: char_row = 8'b00010000;
            {5'd19, 3'd2}: char_row = 8'b00010000;
            {5'd19, 3'd3}: char_row = 8'b00010000;
            {5'd19, 3'd4}: char_row = 8'b00010000;
            {5'd19, 3'd5}: char_row = 8'b00010000;
            {5'd19, 3'd6}: char_row = 8'b00010000;
            {5'd19, 3'd7}: char_row = 8'b00000000;
            //--- U (20) ---
            {5'd20, 3'd0}: char_row = 8'b11000110;
            {5'd20, 3'd1}: char_row = 8'b11000110;
            {5'd20, 3'd2}: char_row = 8'b11000110;
            {5'd20, 3'd3}: char_row = 8'b11000110;
            {5'd20, 3'd4}: char_row = 8'b11000110;
            {5'd20, 3'd5}: char_row = 8'b11000110;
            {5'd20, 3'd6}: char_row = 8'b01111100;
            {5'd20, 3'd7}: char_row = 8'b00000000;
            //--- V (21) ---
            {5'd21, 3'd0}: char_row = 8'b11000110;
            {5'd21, 3'd1}: char_row = 8'b11000110;
            {5'd21, 3'd2}: char_row = 8'b11000110;
            {5'd21, 3'd3}: char_row = 8'b01101100;
            {5'd21, 3'd4}: char_row = 8'b01101100;
            {5'd21, 3'd5}: char_row = 8'b00111000;
            {5'd21, 3'd6}: char_row = 8'b00010000;
            {5'd21, 3'd7}: char_row = 8'b00000000;
            //--- W (22) ---
            {5'd22, 3'd0}: char_row = 8'b10000010;
            {5'd22, 3'd1}: char_row = 8'b10000010;
            {5'd22, 3'd2}: char_row = 8'b10010010;
            {5'd22, 3'd3}: char_row = 8'b10111010;
            {5'd22, 3'd4}: char_row = 8'b11101110;
            {5'd22, 3'd5}: char_row = 8'b11000110;
            {5'd22, 3'd6}: char_row = 8'b10000010;
            {5'd22, 3'd7}: char_row = 8'b00000000;
            //--- X (23) ---
            {5'd23, 3'd0}: char_row = 8'b11000110;
            {5'd23, 3'd1}: char_row = 8'b01101100;
            {5'd23, 3'd2}: char_row = 8'b00111000;
            {5'd23, 3'd3}: char_row = 8'b00010000;
            {5'd23, 3'd4}: char_row = 8'b00111000;
            {5'd23, 3'd5}: char_row = 8'b01101100;
            {5'd23, 3'd6}: char_row = 8'b11000110;
            {5'd23, 3'd7}: char_row = 8'b00000000;
            //--- Y (24) ---
            {5'd24, 3'd0}: char_row = 8'b11000110;
            {5'd24, 3'd1}: char_row = 8'b01101100;
            {5'd24, 3'd2}: char_row = 8'b00111000;
            {5'd24, 3'd3}: char_row = 8'b00010000;
            {5'd24, 3'd4}: char_row = 8'b00010000;
            {5'd24, 3'd5}: char_row = 8'b00010000;
            {5'd24, 3'd6}: char_row = 8'b00010000;
            {5'd24, 3'd7}: char_row = 8'b00000000;
            //--- Z (25) ---
            {5'd25, 3'd0}: char_row = 8'b11111110;
            {5'd25, 3'd1}: char_row = 8'b00000110;
            {5'd25, 3'd2}: char_row = 8'b00001100;
            {5'd25, 3'd3}: char_row = 8'b00011000;
            {5'd25, 3'd4}: char_row = 8'b00110000;
            {5'd25, 3'd5}: char_row = 8'b01100000;
            {5'd25, 3'd6}: char_row = 8'b11111110;
            {5'd25, 3'd7}: char_row = 8'b00000000;
            //--- 0 (26) ---
            {5'd26, 3'd0}: char_row = 8'b00111000;
            {5'd26, 3'd1}: char_row = 8'b01101100;
            {5'd26, 3'd2}: char_row = 8'b11000110;
            {5'd26, 3'd3}: char_row = 8'b11010110;
            {5'd26, 3'd4}: char_row = 8'b11010110;
            {5'd26, 3'd5}: char_row = 8'b11000110;
            {5'd26, 3'd6}: char_row = 8'b01111100;
            {5'd26, 3'd7}: char_row = 8'b00000000;
            //--- 1 (27) ---
            {5'd27, 3'd0}: char_row = 8'b00010000;
            {5'd27, 3'd1}: char_row = 8'b00110000;
            {5'd27, 3'd2}: char_row = 8'b00010000;
            {5'd27, 3'd3}: char_row = 8'b00010000;
            {5'd27, 3'd4}: char_row = 8'b00010000;
            {5'd27, 3'd5}: char_row = 8'b00010000;
            {5'd27, 3'd6}: char_row = 8'b01111100;
            {5'd27, 3'd7}: char_row = 8'b00000000;
            //--- 2 (28) ---
            {5'd28, 3'd0}: char_row = 8'b01111100;
            {5'd28, 3'd1}: char_row = 8'b11000110;
            {5'd28, 3'd2}: char_row = 8'b00000110;
            {5'd28, 3'd3}: char_row = 8'b00011100;
            {5'd28, 3'd4}: char_row = 8'b01110000;
            {5'd28, 3'd5}: char_row = 8'b11000000;
            {5'd28, 3'd6}: char_row = 8'b11111110;
            {5'd28, 3'd7}: char_row = 8'b00000000;
            //--- 3 (29) ---
            {5'd29, 3'd0}: char_row = 8'b01111100;
            {5'd29, 3'd1}: char_row = 8'b11000110;
            {5'd29, 3'd2}: char_row = 8'b00000110;
            {5'd29, 3'd3}: char_row = 8'b00111100;
            {5'd29, 3'd4}: char_row = 8'b00000110;
            {5'd29, 3'd5}: char_row = 8'b11000110;
            {5'd29, 3'd6}: char_row = 8'b01111100;
            {5'd29, 3'd7}: char_row = 8'b00000000;
            //--- 4 (30) ---
            {5'd30, 3'd0}: char_row = 8'b00001100;
            {5'd30, 3'd1}: char_row = 8'b00011100;
            {5'd30, 3'd2}: char_row = 8'b00101100;
            {5'd30, 3'd3}: char_row = 8'b01001100;
            {5'd30, 3'd4}: char_row = 8'b11111110;
            {5'd30, 3'd5}: char_row = 8'b00001100;
            {5'd30, 3'd6}: char_row = 8'b00001100;
            {5'd30, 3'd7}: char_row = 8'b00000000;
            //--- 5 (31) ---
            {5'd31, 3'd0}: char_row = 8'b11111110;
            {5'd31, 3'd1}: char_row = 8'b11000000;
            {5'd31, 3'd2}: char_row = 8'b11111100;
            {5'd31, 3'd3}: char_row = 8'b00000110;
            {5'd31, 3'd4}: char_row = 8'b00000110;
            {5'd31, 3'd5}: char_row = 8'b11000110;
            {5'd31, 3'd6}: char_row = 8'b01111100;
            {5'd31, 3'd7}: char_row = 8'b00000000;
            //--- 6 (32) ---
            {5'd32, 3'd0}: char_row = 8'b00111100;
            {5'd32, 3'd1}: char_row = 8'b01100000;
            {5'd32, 3'd2}: char_row = 8'b11000000;
            {5'd32, 3'd3}: char_row = 8'b11111100;
            {5'd32, 3'd4}: char_row = 8'b11000110;
            {5'd32, 3'd5}: char_row = 8'b11000110;
            {5'd32, 3'd6}: char_row = 8'b01111100;
            {5'd32, 3'd7}: char_row = 8'b00000000;
            //--- 7 (33) ---
            {5'd33, 3'd0}: char_row = 8'b11111110;
            {5'd33, 3'd1}: char_row = 8'b00000110;
            {5'd33, 3'd2}: char_row = 8'b00001100;
            {5'd33, 3'd3}: char_row = 8'b00011000;
            {5'd33, 3'd4}: char_row = 8'b00110000;
            {5'd33, 3'd5}: char_row = 8'b01100000;
            {5'd33, 3'd6}: char_row = 8'b11000000;
            {5'd33, 3'd7}: char_row = 8'b00000000;
            //--- 8 (34) ---
            {5'd34, 3'd0}: char_row = 8'b01111100;
            {5'd34, 3'd1}: char_row = 8'b11000110;
            {5'd34, 3'd2}: char_row = 8'b11000110;
            {5'd34, 3'd3}: char_row = 8'b01111100;
            {5'd34, 3'd4}: char_row = 8'b11000110;
            {5'd34, 3'd5}: char_row = 8'b11000110;
            {5'd34, 3'd6}: char_row = 8'b01111100;
            {5'd34, 3'd7}: char_row = 8'b00000000;
            //--- 9 (35) ---
            {5'd35, 3'd0}: char_row = 8'b01111100;
            {5'd35, 3'd1}: char_row = 8'b11000110;
            {5'd35, 3'd2}: char_row = 8'b11000110;
            {5'd35, 3'd3}: char_row = 8'b01111110;
            {5'd35, 3'd4}: char_row = 8'b00000110;
            {5'd35, 3'd5}: char_row = 8'b00001100;
            {5'd35, 3'd6}: char_row = 8'b01111000;
            {5'd35, 3'd7}: char_row = 8'b00000000;

            //--- Space (36) ---
            {5'd36, 3'd0}: char_row = 8'b00000000;
            {5'd36, 3'd1}: char_row = 8'b00000000;
            {5'd36, 3'd2}: char_row = 8'b00000000;
            {5'd36, 3'd3}: char_row = 8'b00000000;
            {5'd36, 3'd4}: char_row = 8'b00000000;
            {5'd36, 3'd5}: char_row = 8'b00000000;
            {5'd36, 3'd6}: char_row = 8'b00000000;
            {5'd36, 3'd7}: char_row = 8'b00000000;
            //--- : (37) ---
            {5'd37, 3'd0}: char_row = 8'b00000000;
            {5'd37, 3'd1}: char_row = 8'b00011000;
            {5'd37, 3'd2}: char_row = 8'b00011000;
            {5'd37, 3'd3}: char_row = 8'b00000000;
            {5'd37, 3'd4}: char_row = 8'b00011000;
            {5'd37, 3'd5}: char_row = 8'b00011000;
            {5'd37, 3'd6}: char_row = 8'b00000000;
            {5'd37, 3'd7}: char_row = 8'b00000000;
            //--- / (38) ---
            {5'd38, 3'd0}: char_row = 8'b00000110;
            {5'd38, 3'd1}: char_row = 8'b00001100;
            {5'd38, 3'd2}: char_row = 8'b00011000;
            {5'd38, 3'd3}: char_row = 8'b00110000;
            {5'd38, 3'd4}: char_row = 8'b01100000;
            {5'd38, 3'd5}: char_row = 8'b11000000;
            {5'd38, 3'd6}: char_row = 8'b10000000;
            {5'd38, 3'd7}: char_row = 8'b00000000;
            //--- | (39) ---
            {5'd39, 3'd0}: char_row = 8'b00010000;
            {5'd39, 3'd1}: char_row = 8'b00010000;
            {5'd39, 3'd2}: char_row = 8'b00010000;
            {5'd39, 3'd3}: char_row = 8'b00010000;
            {5'd39, 3'd4}: char_row = 8'b00010000;
            {5'd39, 3'd5}: char_row = 8'b00010000;
            {5'd39, 3'd6}: char_row = 8'b00010000;
            {5'd39, 3'd7}: char_row = 8'b00000000;
            //--- - (40) ---
            {5'd40, 3'd0}: char_row = 8'b00000000;
            {5'd40, 3'd1}: char_row = 8'b00000000;
            {5'd40, 3'd2}: char_row = 8'b00000000;
            {5'd40, 3'd3}: char_row = 8'b11111110;
            {5'd40, 3'd4}: char_row = 8'b00000000;
            {5'd40, 3'd5}: char_row = 8'b00000000;
            {5'd40, 3'd6}: char_row = 8'b00000000;
            {5'd40, 3'd7}: char_row = 8'b00000000;
            //--- > (41) ---
            {5'd41, 3'd0}: char_row = 8'b11000000;
            {5'd41, 3'd1}: char_row = 8'b01100000;
            {5'd41, 3'd2}: char_row = 8'b00110000;
            {5'd41, 3'd3}: char_row = 8'b00011000;
            {5'd41, 3'd4}: char_row = 8'b00110000;
            {5'd41, 3'd5}: char_row = 8'b01100000;
            {5'd41, 3'd6}: char_row = 8'b11000000;
            {5'd41, 3'd7}: char_row = 8'b00000000;
            //--- . (42) ---
            {5'd42, 3'd0}: char_row = 8'b00000000;
            {5'd42, 3'd1}: char_row = 8'b00000000;
            {5'd42, 3'd2}: char_row = 8'b00000000;
            {5'd42, 3'd3}: char_row = 8'b00000000;
            {5'd42, 3'd4}: char_row = 8'b00011000;
            {5'd42, 3'd5}: char_row = 8'b00011000;
            {5'd42, 3'd6}: char_row = 8'b00000000;
            {5'd42, 3'd7}: char_row = 8'b00000000;
            //--- ! (43) ---
            {5'd43, 3'd0}: char_row = 8'b00010000;
            {5'd43, 3'd1}: char_row = 8'b00010000;
            {5'd43, 3'd2}: char_row = 8'b00010000;
            {5'd43, 3'd3}: char_row = 8'b00010000;
            {5'd43, 3'd4}: char_row = 8'b00010000;
            {5'd43, 3'd5}: char_row = 8'b00000000;
            {5'd43, 3'd6}: char_row = 8'b00010000;
            {5'd43, 3'd7}: char_row = 8'b00000000;

            default: char_row = 8'b00000000;
        endcase
    end

    // Pixel within character
    wire pixel_on = in_char_box && char_row[3'd7 - cx];

    assign hit   = pixel_on;
    assign color = `COL_WHITE;  // color is set by parent module via priority MUX
endmodule
