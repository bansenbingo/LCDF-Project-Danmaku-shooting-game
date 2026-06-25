//==============================================================================
// menu_render.v — Pure combinational menu/title screen renderer
// ZJU VGA rules: combinational only, BGR colors
//==============================================================================
`include "game_defs.vh"

module menu_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,
    input  wire [1:0]  difficulty,
    input  wire        mode,        // 0=score, 1=endless
    output wire        hit,
    output wire [11:0] color
);
    //---------- Font ROM ----------
    reg [7:0] char_bitmap;
    wire [4:0] char_code;

    // Abbreviated font for menu: only characters we need
    // A-Z (0-25), space (36), : (37), / (38), - (40), . (42)
    always @* begin
        case ({char_code, sy[2:0]})
            // A (0)
            {5'd0,  3'd0}: char_bitmap = 8'b00111000;
            {5'd0,  3'd1}: char_bitmap = 8'b01101100;
            {5'd0,  3'd2}: char_bitmap = 8'b11000110;
            {5'd0,  3'd3}: char_bitmap = 8'b11000110;
            {5'd0,  3'd4}: char_bitmap = 8'b11111110;
            {5'd0,  3'd5}: char_bitmap = 8'b11000110;
            {5'd0,  3'd6}: char_bitmap = 8'b11000110;
            {5'd0,  3'd7}: char_bitmap = 8'b00000000;
            // B (1)
            {5'd1,  3'd0}: char_bitmap = 8'b11111100;
            {5'd1,  3'd1}: char_bitmap = 8'b11000110;
            {5'd1,  3'd2}: char_bitmap = 8'b11000110;
            {5'd1,  3'd3}: char_bitmap = 8'b11111100;
            {5'd1,  3'd4}: char_bitmap = 8'b11000110;
            {5'd1,  3'd5}: char_bitmap = 8'b11000110;
            {5'd1,  3'd6}: char_bitmap = 8'b11111100;
            {5'd1,  3'd7}: char_bitmap = 8'b00000000;
            // C (2)
            {5'd2,  3'd0}: char_bitmap = 8'b00111100;
            {5'd2,  3'd1}: char_bitmap = 8'b01100110;
            {5'd2,  3'd2}: char_bitmap = 8'b11000000;
            {5'd2,  3'd3}: char_bitmap = 8'b11000000;
            {5'd2,  3'd4}: char_bitmap = 8'b11000000;
            {5'd2,  3'd5}: char_bitmap = 8'b01100110;
            {5'd2,  3'd6}: char_bitmap = 8'b00111100;
            {5'd2,  3'd7}: char_bitmap = 8'b00000000;
            // D (3)
            {5'd3,  3'd0}: char_bitmap = 8'b11111000;
            {5'd3,  3'd1}: char_bitmap = 8'b11001100;
            {5'd3,  3'd2}: char_bitmap = 8'b11000110;
            {5'd3,  3'd3}: char_bitmap = 8'b11000110;
            {5'd3,  3'd4}: char_bitmap = 8'b11000110;
            {5'd3,  3'd5}: char_bitmap = 8'b11001100;
            {5'd3,  3'd6}: char_bitmap = 8'b11111000;
            {5'd3,  3'd7}: char_bitmap = 8'b00000000;
            // E (4)
            {5'd4,  3'd0}: char_bitmap = 8'b11111110;
            {5'd4,  3'd1}: char_bitmap = 8'b11000000;
            {5'd4,  3'd2}: char_bitmap = 8'b11000000;
            {5'd4,  3'd3}: char_bitmap = 8'b11111100;
            {5'd4,  3'd4}: char_bitmap = 8'b11000000;
            {5'd4,  3'd5}: char_bitmap = 8'b11000000;
            {5'd4,  3'd6}: char_bitmap = 8'b11111110;
            {5'd4,  3'd7}: char_bitmap = 8'b00000000;
            // F (5)
            {5'd5,  3'd0}: char_bitmap = 8'b11111110;
            {5'd5,  3'd1}: char_bitmap = 8'b11000000;
            {5'd5,  3'd2}: char_bitmap = 8'b11000000;
            {5'd5,  3'd3}: char_bitmap = 8'b11111100;
            {5'd5,  3'd4}: char_bitmap = 8'b11000000;
            {5'd5,  3'd5}: char_bitmap = 8'b11000000;
            {5'd5,  3'd6}: char_bitmap = 8'b11000000;
            {5'd5,  3'd7}: char_bitmap = 8'b00000000;
            // H (7)
            {5'd7,  3'd0}: char_bitmap = 8'b11000110;
            {5'd7,  3'd1}: char_bitmap = 8'b11000110;
            {5'd7,  3'd2}: char_bitmap = 8'b11000110;
            {5'd7,  3'd3}: char_bitmap = 8'b11111110;
            {5'd7,  3'd4}: char_bitmap = 8'b11000110;
            {5'd7,  3'd5}: char_bitmap = 8'b11000110;
            {5'd7,  3'd6}: char_bitmap = 8'b11000110;
            {5'd7,  3'd7}: char_bitmap = 8'b00000000;
            // I (8)
            {5'd8,  3'd0}: char_bitmap = 8'b01111100;
            {5'd8,  3'd1}: char_bitmap = 8'b00010000;
            {5'd8,  3'd2}: char_bitmap = 8'b00010000;
            {5'd8,  3'd3}: char_bitmap = 8'b00010000;
            {5'd8,  3'd4}: char_bitmap = 8'b00010000;
            {5'd8,  3'd5}: char_bitmap = 8'b00010000;
            {5'd8,  3'd6}: char_bitmap = 8'b01111100;
            {5'd8,  3'd7}: char_bitmap = 8'b00000000;
            // K (10)
            {5'd10, 3'd0}: char_bitmap = 8'b11000110;
            {5'd10, 3'd1}: char_bitmap = 8'b11001100;
            {5'd10, 3'd2}: char_bitmap = 8'b11011000;
            {5'd10, 3'd3}: char_bitmap = 8'b11110000;
            {5'd10, 3'd4}: char_bitmap = 8'b11011000;
            {5'd10, 3'd5}: char_bitmap = 8'b11001100;
            {5'd10, 3'd6}: char_bitmap = 8'b11000110;
            {5'd10, 3'd7}: char_bitmap = 8'b00000000;
            // L (11)
            {5'd11, 3'd0}: char_bitmap = 8'b11000000;
            {5'd11, 3'd1}: char_bitmap = 8'b11000000;
            {5'd11, 3'd2}: char_bitmap = 8'b11000000;
            {5'd11, 3'd3}: char_bitmap = 8'b11000000;
            {5'd11, 3'd4}: char_bitmap = 8'b11000000;
            {5'd11, 3'd5}: char_bitmap = 8'b11000000;
            {5'd11, 3'd6}: char_bitmap = 8'b11111110;
            {5'd11, 3'd7}: char_bitmap = 8'b00000000;
            // M (12)
            {5'd12, 3'd0}: char_bitmap = 8'b10000010;
            {5'd12, 3'd1}: char_bitmap = 8'b11000110;
            {5'd12, 3'd2}: char_bitmap = 8'b11101110;
            {5'd12, 3'd3}: char_bitmap = 8'b10111010;
            {5'd12, 3'd4}: char_bitmap = 8'b10010010;
            {5'd12, 3'd5}: char_bitmap = 8'b10000010;
            {5'd12, 3'd6}: char_bitmap = 8'b10000010;
            {5'd12, 3'd7}: char_bitmap = 8'b00000000;
            // N (13)
            {5'd13, 3'd0}: char_bitmap = 8'b11000110;
            {5'd13, 3'd1}: char_bitmap = 8'b11100110;
            {5'd13, 3'd2}: char_bitmap = 8'b11110110;
            {5'd13, 3'd3}: char_bitmap = 8'b11011110;
            {5'd13, 3'd4}: char_bitmap = 8'b11001110;
            {5'd13, 3'd5}: char_bitmap = 8'b11000110;
            {5'd13, 3'd6}: char_bitmap = 8'b11000110;
            {5'd13, 3'd7}: char_bitmap = 8'b00000000;
            // O (14)
            {5'd14, 3'd0}: char_bitmap = 8'b00111000;
            {5'd14, 3'd1}: char_bitmap = 8'b01101100;
            {5'd14, 3'd2}: char_bitmap = 8'b11000110;
            {5'd14, 3'd3}: char_bitmap = 8'b11000110;
            {5'd14, 3'd4}: char_bitmap = 8'b11000110;
            {5'd14, 3'd5}: char_bitmap = 8'b01101100;
            {5'd14, 3'd6}: char_bitmap = 8'b00111000;
            {5'd14, 3'd7}: char_bitmap = 8'b00000000;
            // P (15)
            {5'd15, 3'd0}: char_bitmap = 8'b11111100;
            {5'd15, 3'd1}: char_bitmap = 8'b11000110;
            {5'd15, 3'd2}: char_bitmap = 8'b11000110;
            {5'd15, 3'd3}: char_bitmap = 8'b11111100;
            {5'd15, 3'd4}: char_bitmap = 8'b11000000;
            {5'd15, 3'd5}: char_bitmap = 8'b11000000;
            {5'd15, 3'd6}: char_bitmap = 8'b11000000;
            {5'd15, 3'd7}: char_bitmap = 8'b00000000;
            // R (17)
            {5'd17, 3'd0}: char_bitmap = 8'b11111100;
            {5'd17, 3'd1}: char_bitmap = 8'b11000110;
            {5'd17, 3'd2}: char_bitmap = 8'b11000110;
            {5'd17, 3'd3}: char_bitmap = 8'b11111100;
            {5'd17, 3'd4}: char_bitmap = 8'b11011000;
            {5'd17, 3'd5}: char_bitmap = 8'b11001100;
            {5'd17, 3'd6}: char_bitmap = 8'b11000110;
            {5'd17, 3'd7}: char_bitmap = 8'b00000000;
            // S (18)
            {5'd18, 3'd0}: char_bitmap = 8'b01111100;
            {5'd18, 3'd1}: char_bitmap = 8'b11000110;
            {5'd18, 3'd2}: char_bitmap = 8'b11000000;
            {5'd18, 3'd3}: char_bitmap = 8'b01111100;
            {5'd18, 3'd4}: char_bitmap = 8'b00000110;
            {5'd18, 3'd5}: char_bitmap = 8'b11000110;
            {5'd18, 3'd6}: char_bitmap = 8'b01111100;
            {5'd18, 3'd7}: char_bitmap = 8'b00000000;
            // T (19)
            {5'd19, 3'd0}: char_bitmap = 8'b11111110;
            {5'd19, 3'd1}: char_bitmap = 8'b00010000;
            {5'd19, 3'd2}: char_bitmap = 8'b00010000;
            {5'd19, 3'd3}: char_bitmap = 8'b00010000;
            {5'd19, 3'd4}: char_bitmap = 8'b00010000;
            {5'd19, 3'd5}: char_bitmap = 8'b00010000;
            {5'd19, 3'd6}: char_bitmap = 8'b00010000;
            {5'd19, 3'd7}: char_bitmap = 8'b00000000;
            // U (20)
            {5'd20, 3'd0}: char_bitmap = 8'b11000110;
            {5'd20, 3'd1}: char_bitmap = 8'b11000110;
            {5'd20, 3'd2}: char_bitmap = 8'b11000110;
            {5'd20, 3'd3}: char_bitmap = 8'b11000110;
            {5'd20, 3'd4}: char_bitmap = 8'b11000110;
            {5'd20, 3'd5}: char_bitmap = 8'b11000110;
            {5'd20, 3'd6}: char_bitmap = 8'b01111100;
            {5'd20, 3'd7}: char_bitmap = 8'b00000000;
            // Y (24)
            {5'd24, 3'd0}: char_bitmap = 8'b11000110;
            {5'd24, 3'd1}: char_bitmap = 8'b01101100;
            {5'd24, 3'd2}: char_bitmap = 8'b00111000;
            {5'd24, 3'd3}: char_bitmap = 8'b00010000;
            {5'd24, 3'd4}: char_bitmap = 8'b00010000;
            {5'd24, 3'd5}: char_bitmap = 8'b00010000;
            {5'd24, 3'd6}: char_bitmap = 8'b00010000;
            {5'd24, 3'd7}: char_bitmap = 8'b00000000;
            // Numbers 0-9 (26-35)
            {5'd26, 3'd0}: char_bitmap = 8'b00111000;
            {5'd26, 3'd1}: char_bitmap = 8'b01101100;
            {5'd26, 3'd2}: char_bitmap = 8'b11000110;
            {5'd26, 3'd3}: char_bitmap = 8'b11010110;
            {5'd26, 3'd4}: char_bitmap = 8'b11010110;
            {5'd26, 3'd5}: char_bitmap = 8'b11000110;
            {5'd26, 3'd6}: char_bitmap = 8'b01111100;
            {5'd26, 3'd7}: char_bitmap = 8'b00000000;
            {5'd27, 3'd0}: char_bitmap = 8'b00010000;
            {5'd27, 3'd1}: char_bitmap = 8'b00110000;
            {5'd27, 3'd2}: char_bitmap = 8'b00010000;
            {5'd27, 3'd3}: char_bitmap = 8'b00010000;
            {5'd27, 3'd4}: char_bitmap = 8'b00010000;
            {5'd27, 3'd5}: char_bitmap = 8'b00010000;
            {5'd27, 3'd6}: char_bitmap = 8'b01111100;
            {5'd27, 3'd7}: char_bitmap = 8'b00000000;
            {5'd28, 3'd0}: char_bitmap = 8'b01111100;
            {5'd28, 3'd1}: char_bitmap = 8'b11000110;
            {5'd28, 3'd2}: char_bitmap = 8'b00000110;
            {5'd28, 3'd3}: char_bitmap = 8'b00011100;
            {5'd28, 3'd4}: char_bitmap = 8'b01110000;
            {5'd28, 3'd5}: char_bitmap = 8'b11000000;
            {5'd28, 3'd6}: char_bitmap = 8'b11111110;
            {5'd28, 3'd7}: char_bitmap = 8'b00000000;
            {5'd29, 3'd0}: char_bitmap = 8'b01111100;
            {5'd29, 3'd1}: char_bitmap = 8'b11000110;
            {5'd29, 3'd2}: char_bitmap = 8'b00000110;
            {5'd29, 3'd3}: char_bitmap = 8'b00111100;
            {5'd29, 3'd4}: char_bitmap = 8'b00000110;
            {5'd29, 3'd5}: char_bitmap = 8'b11000110;
            {5'd29, 3'd6}: char_bitmap = 8'b01111100;
            {5'd29, 3'd7}: char_bitmap = 8'b00000000;
            {5'd30, 3'd0}: char_bitmap = 8'b00001100;
            {5'd30, 3'd1}: char_bitmap = 8'b00011100;
            {5'd30, 3'd2}: char_bitmap = 8'b00101100;
            {5'd30, 3'd3}: char_bitmap = 8'b01001100;
            {5'd30, 3'd4}: char_bitmap = 8'b11111110;
            {5'd30, 3'd5}: char_bitmap = 8'b00001100;
            {5'd30, 3'd6}: char_bitmap = 8'b00001100;
            {5'd30, 3'd7}: char_bitmap = 8'b00000000;
            // space (36)
            {5'd36, 3'd0}: char_bitmap = 8'b00000000;
            {5'd36, 3'd1}: char_bitmap = 8'b00000000;
            {5'd36, 3'd2}: char_bitmap = 8'b00000000;
            {5'd36, 3'd3}: char_bitmap = 8'b00000000;
            {5'd36, 3'd4}: char_bitmap = 8'b00000000;
            {5'd36, 3'd5}: char_bitmap = 8'b00000000;
            {5'd36, 3'd6}: char_bitmap = 8'b00000000;
            {5'd36, 3'd7}: char_bitmap = 8'b00000000;
            // : (37)
            {5'd37, 3'd0}: char_bitmap = 8'b00000000;
            {5'd37, 3'd1}: char_bitmap = 8'b00011000;
            {5'd37, 3'd2}: char_bitmap = 8'b00011000;
            {5'd37, 3'd3}: char_bitmap = 8'b00000000;
            {5'd37, 3'd4}: char_bitmap = 8'b00011000;
            {5'd37, 3'd5}: char_bitmap = 8'b00011000;
            {5'd37, 3'd6}: char_bitmap = 8'b00000000;
            {5'd37, 3'd7}: char_bitmap = 8'b00000000;
            // - (40)
            {5'd40, 3'd0}: char_bitmap = 8'b00000000;
            {5'd40, 3'd1}: char_bitmap = 8'b00000000;
            {5'd40, 3'd2}: char_bitmap = 8'b00000000;
            {5'd40, 3'd3}: char_bitmap = 8'b11111110;
            {5'd40, 3'd4}: char_bitmap = 8'b00000000;
            {5'd40, 3'd5}: char_bitmap = 8'b00000000;
            {5'd40, 3'd6}: char_bitmap = 8'b00000000;
            {5'd40, 3'd7}: char_bitmap = 8'b00000000;
            // . (42)
            {5'd42, 3'd0}: char_bitmap = 8'b00000000;
            {5'd42, 3'd1}: char_bitmap = 8'b00000000;
            {5'd42, 3'd2}: char_bitmap = 8'b00000000;
            {5'd42, 3'd3}: char_bitmap = 8'b00000000;
            {5'd42, 3'd4}: char_bitmap = 8'b00011000;
            {5'd42, 3'd5}: char_bitmap = 8'b00011000;
            {5'd42, 3'd6}: char_bitmap = 8'b00000000;
            {5'd42, 3'd7}: char_bitmap = 8'b00000000;
            default: char_bitmap = 8'b00000000;
        endcase
    end

    //---------- Menu Border Box ----------
    // Colored border rectangle around the center area
    wire border_h = (sx >= 10'd80) && (sx < 10'd560) && (sy >= 10'd40) && (sy < 10'd440);
    wire border_edge_h = (sx >= 10'd80) && (sx < 10'd84) ||   // left
                         (sx >= 10'd556) && (sx < 10'd560) ||  // right
                         (sy >= 10'd40) && (sy < 10'd44) ||    // top
                         (sy >= 10'd436) && (sy < 10'd440);    // bottom

    // Colorful border: alternating colors every few pixels
    wire [2:0] border_phase = sx[5:3] + sy[5:3];
    wire [11:0] border_color = (border_phase[0]) ? `COL_CYAN  :
                               (border_phase[1]) ? `COL_MAGENTA : `COL_YELLOW;

    // Inner decorative line
    wire inner_edge_h = (sx >= 10'd84) && (sx < 10'd88) ||
                        (sx >= 10'd552) && (sx < 10'd556) ||
                        (sy >= 10'd44) && (sy < 10'd48) ||
                        (sy >= 10'd432) && (sy < 10'd436);

    //---------- Title: "AEROPLANE DANMAKU SHOOTING" ----------
    // Title at y=100, centered. 26 characters, start at x=112
    wire [9:0] title_base_x = 10'd112;  // (640 - 26*8) / 2 ≈ 112
    wire [9:0] title_base_y = 10'd100;

    wire in_title = (game_state == `STATE_MENU) &&
                    (sx >= title_base_x) && (sx < title_base_x + 10'd208) &&
                    (sy >= title_base_y) && (sy < title_base_y + 10'd16);

    // Character index for title (2 rows: "AEROPLANE" + "DANMAKU SHOOTING")
    // Actually "AEROPLANE DANMAKU SHOOTING" = 26 chars, put it as one long line
    // or two lines. Let's do two lines:
    // Line 1: "AEROPLANE" (9 chars, offset 0)
    // Line 2: "DANMAKU" (7 chars) + space + "SHOOTING" (8 chars)
    wire in_title_line1 = in_title && (sy < title_base_y + 10'd8);
    wire in_title_line2 = in_title && (sy >= title_base_y + 10'd8);

    wire [4:0] title_chi_line1 = sx[7:3] - title_base_x[7:3];  // ÷8
    wire [4:0] title_chi_line2 = sx[7:3] - title_base_x[7:3];

    reg [4:0] title_char1, title_char2;
    always @* begin
        // "AEROPLANE" (9 chars)
        case (title_chi_line1)
            5'd0: title_char1 = 5'd0;   // A
            5'd1: title_char1 = 5'd4;   // E
            5'd2: title_char1 = 5'd17;  // R
            5'd3: title_char1 = 5'd14;  // O
            5'd4: title_char1 = 5'd15;  // P
            5'd5: title_char1 = 5'd11;  // L
            5'd6: title_char1 = 5'd0;   // A
            5'd7: title_char1 = 5'd13;  // N
            5'd8: title_char1 = 5'd4;   // E
            default: title_char1 = 5'd36; // space
        endcase
        // "DANMAKU SHOOTING" (16 chars)
        case (title_chi_line2)
            5'd0:  title_char2 = 5'd3;   // D
            5'd1:  title_char2 = 5'd0;   // A
            5'd2:  title_char2 = 5'd13;  // N
            5'd3:  title_char2 = 5'd12;  // M
            5'd4:  title_char2 = 5'd0;   // A
            5'd5:  title_char2 = 5'd10;  // K
            5'd6:  title_char2 = 5'd20;  // U
            5'd7:  title_char2 = 5'd36;  // space
            5'd8:  title_char2 = 5'd18;  // S
            5'd9:  title_char2 = 5'd7;   // H
            5'd10: title_char2 = 5'd14;  // O
            5'd11: title_char2 = 5'd14;  // O
            5'd12: title_char2 = 5'd19;  // T
            5'd13: title_char2 = 5'd8;   // I
            5'd14: title_char2 = 5'd13;  // N
            5'd15: title_char2 = 5'd6;   // G
            default: title_char2 = 5'd36;
        endcase
    end

    wire title_hit1 = in_title_line1 && char_bitmap[3'd7 - sx[2:0]];
    wire title_hit2 = in_title_line2 && char_bitmap[3'd7 - sx[2:0]];
    wire title_hit = title_hit1 || title_hit2;

    //---------- START box ----------
    // Rectangle with "START" text at y=180
    wire [9:0] start_box_x = 10'd264;
    wire [9:0] start_box_y = 10'd180;
    wire start_box = (sx >= start_box_x) && (sx < start_box_x + 10'd112) &&
                     (sy >= start_box_y) && (sy < start_box_y + 10'd24);
    wire start_box_edge = start_box && (
        (sx < start_box_x + 10'd4) || (sx >= start_box_x + 10'd108) ||
        (sy < start_box_y + 10'd4) || (sy >= start_box_y + 10'd20));
    wire start_box_fill = start_box && !start_box_edge;

    // "START" text centered in box (5 chars * 8 = 40, box is 112)
    wire [9:0] start_text_x = 10'd300;  // 264 + (112-40)/2 ≈ 300
    wire [9:0] start_text_y = 10'd188;  // 180 + (24-8)/2 ≈ 188
    wire in_start_text = (game_state == `STATE_MENU) && start_box &&
                         (sx >= start_text_x) && (sx < start_text_x + 10'd40) &&
                         (sy >= start_text_y) && (sy < start_text_y + 10'd8);
    wire [4:0] start_chi = sx[5:3] - start_text_x[5:3];
    reg [4:0] start_char;
    always @* begin
        case (start_chi)
            5'd0: start_char = 5'd18;  // S
            5'd1: start_char = 5'd19;  // T
            5'd2: start_char = 5'd0;   // A
            5'd3: start_char = 5'd17;  // R
            5'd4: start_char = 5'd19;  // T
            default: start_char = 5'd36;
        endcase
    end
    wire start_text_hit = in_start_text && char_bitmap[3'd7 - sx[2:0]];

    //---------- Difficulty display ----------
    // "DIFFICULTY:EASY" etc. at bottom-right corner area
    wire [9:0] diff_base_x = 10'd360;
    wire [9:0] diff_base_y = 10'd300;
    wire in_diff_label = (game_state == `STATE_MENU) &&
                         (sx >= diff_base_x) && (sx < diff_base_x + 10'd88) &&
                         (sy >= diff_base_y) && (sy < diff_base_y + 10'd8);
    wire [4:0] diff_chi = sx[5:3] - diff_base_x[5:3];

    // "DIFFICULTY:" = 11 chars
    reg [4:0] diff_char;
    always @* begin
        case (diff_chi)
            5'd0:  diff_char = 5'd3;   // D
            5'd1:  diff_char = 5'd8;   // I
            5'd2:  diff_char = 5'd5;   // F
            5'd3:  diff_char = 5'd5;   // F
            5'd4:  diff_char = 5'd8;   // I
            5'd5:  diff_char = 5'd2;   // C
            5'd6:  diff_char = 5'd20;  // U
            5'd7:  diff_char = 5'd11;  // L
            5'd8:  diff_char = 5'd19;  // T
            5'd9:  diff_char = 5'd24;  // Y
            5'd10: diff_char = 5'd37;  // :
            default: diff_char = 5'd36;
        endcase
    end
    wire diff_label_hit = in_diff_label && char_bitmap[3'd7 - sx[2:0]];

    // Difficulty value: "EASY"/"NORMAL"/"HARD"/"HELL"
    wire [9:0] diff_val_x = 10'd448;
    wire [9:0] diff_val_y = 10'd300;
    wire in_diff_val = (game_state == `STATE_MENU) &&
                       (sx >= diff_val_x) && (sx < diff_val_x + 10'd48) &&
                       (sy >= diff_val_y) && (sy < diff_val_y + 10'd8);
    wire [4:0] diffv_chi = sx[5:3] - diff_val_x[5:3];
    reg [4:0] diffv_char;
    always @* begin
        if (difficulty == `DIFF_EASY) begin
            case (diffv_chi)
                5'd0: diffv_char = 5'd4;   // E
                5'd1: diffv_char = 5'd0;   // A
                5'd2: diffv_char = 5'd18;  // S
                5'd3: diffv_char = 5'd24;  // Y
                default: diffv_char = 5'd36;
            endcase
        end else if (difficulty == `DIFF_NORMAL) begin
            case (diffv_chi)
                5'd0: diffv_char = 5'd13;  // N
                5'd1: diffv_char = 5'd14;  // O
                5'd2: diffv_char = 5'd17;  // R
                5'd3: diffv_char = 5'd12;  // M
                5'd4: diffv_char = 5'd0;   // A
                5'd5: diffv_char = 5'd11;  // L
                default: diffv_char = 5'd36;
            endcase
        end else if (difficulty == `DIFF_HARD) begin
            case (diffv_chi)
                5'd0: diffv_char = 5'd7;   // H
                5'd1: diffv_char = 5'd0;   // A
                5'd2: diffv_char = 5'd17;  // R
                5'd3: diffv_char = 5'd3;   // D
                default: diffv_char = 5'd36;
            endcase
        end else begin  // HELL
            case (diffv_chi)
                5'd0: diffv_char = 5'd7;    // H
                5'd1: diffv_char = 5'd4;    // E
                5'd2: diffv_char = 5'd11;   // L
                5'd3: diffv_char = 5'd11;   // L
                default: diffv_char = 5'd36;
            endcase
        end
    end
    wire diff_val_hit = in_diff_val && char_bitmap[3'd7 - sx[2:0]];

    //---------- Mode display ----------
    // "MODE:SCORE" or "MODE:ENDLESS"
    wire [9:0] mode_base_x = 10'd360;
    wire [9:0] mode_base_y = 10'd320;
    wire in_mode_label = (game_state == `STATE_MENU) &&
                         (sx >= mode_base_x) && (sx < mode_base_x + 10'd40) &&
                         (sy >= mode_base_y) && (sy < mode_base_y + 10'd8);
    wire [4:0] mode_chi = sx[5:3] - mode_base_x[5:3];
    reg [4:0] mode_char;
    always @* begin
        case (mode_chi)
            5'd0: mode_char = 5'd12;  // M
            5'd1: mode_char = 5'd14;  // O
            5'd2: mode_char = 5'd3;   // D
            5'd3: mode_char = 5'd4;   // E
            5'd4: mode_char = 5'd37;  // :
            default: mode_char = 5'd36;
        endcase
    end
    wire mode_label_hit = in_mode_label && char_bitmap[3'd7 - sx[2:0]];

    // Mode value
    wire [9:0] mode_val_x = 10'd400;
    wire [9:0] mode_val_y = 10'd320;
    wire in_mode_val = (game_state == `STATE_MENU) &&
                       (sx >= mode_val_x) && (sx < mode_val_x + 10'd64) &&
                       (sy >= mode_val_y) && (sy < mode_val_y + 10'd8);
    wire [4:0] modev_chi = sx[5:3] - mode_val_x[5:3];
    reg [4:0] modev_char;
    always @* begin
        if (!mode) begin  // SCORE
            case (modev_chi)
                5'd0: modev_char = 5'd18;  // S
                5'd1: modev_char = 5'd2;   // C
                5'd2: modev_char = 5'd14;  // O
                5'd3: modev_char = 5'd17;  // R
                5'd4: modev_char = 5'd4;   // E
                default: modev_char = 5'd36;
            endcase
        end else begin  // ENDLESS
            case (modev_chi)
                5'd0: modev_char = 5'd4;   // E
                5'd1: modev_char = 5'd13;  // N
                5'd2: modev_char = 5'd3;   // D
                5'd3: modev_char = 5'd11;  // L
                5'd4: modev_char = 5'd4;   // E
                5'd5: modev_char = 5'd18;  // S
                5'd6: modev_char = 5'd18;  // S
                default: modev_char = 5'd36;
            endcase
        end
    end
    wire mode_val_hit = in_mode_val && char_bitmap[3'd7 - sx[2:0]];

    //---------- Controls hint ----------
    // "PRESS START TO PLAY" at bottom
    wire [9:0] hint_base_x = 10'd200;
    wire [9:0] hint_base_y = 10'd400;
    wire in_hint = (game_state == `STATE_MENU) &&
                   (sx >= hint_base_x) && (sx < hint_base_x + 10'd152) &&
                   (sy >= hint_base_y) && (sy < hint_base_y + 10'd8);
    wire [4:0] hint_chi = sx[7:3] - hint_base_x[7:3];
    reg [4:0] hint_char;
    always @* begin
        // "PRESS START TO PLAY" = 19 chars... too long, trim to "PRESS START"
        case (hint_chi)
            5'd0:  hint_char = 5'd15;  // P
            5'd1:  hint_char = 5'd17;  // R
            5'd2:  hint_char = 5'd4;   // E
            5'd3:  hint_char = 5'd18;  // S
            5'd4:  hint_char = 5'd18;  // S
            5'd5:  hint_char = 5'd36;  //
            5'd6:  hint_char = 5'd18;  // S
            5'd7:  hint_char = 5'd19;  // T
            5'd8:  hint_char = 5'd0;   // A
            5'd9:  hint_char = 5'd17;  // R
            5'd10: hint_char = 5'd19;  // T
            default: hint_char = 5'd36;
        endcase
    end
    wire hint_hit = in_hint && char_bitmap[3'd7 - sx[2:0]];

    //---------- Final hit and color assignment ----------
    wire menu_active = (game_state == `STATE_MENU);
    wire any_text = title_hit || start_text_hit || diff_label_hit ||
                    diff_val_hit || mode_label_hit || mode_val_hit || hint_hit;

    assign hit = menu_active && (border_edge_h || inner_edge_h || any_text);

    // Color: border colorful, text white, START box with highlight
    assign color = border_edge_h    ? border_color :
                   inner_edge_h     ? `COL_LTGRAY  :
                   start_text_hit   ? `COL_YELLOW  :
                   start_box_fill   ? `COL_DKGRAY  :
                   diff_val_hit     ? `COL_CYAN    :
                   mode_val_hit     ? `COL_GREEN   :
                   hint_hit         ? `COL_DKGRAY  :
                   `COL_WHITE;  // title and labels

    // Character code for font lookup
    assign char_code = in_title_line1 ? title_char1  :
                       in_title_line2 ? title_char2  :
                       in_start_text  ? start_char   :
                       in_diff_label  ? diff_char    :
                       in_diff_val    ? diffv_char   :
                       in_mode_label  ? mode_char    :
                       in_mode_val    ? modev_char   :
                       in_hint        ? hint_char    : 5'd36;
endmodule
