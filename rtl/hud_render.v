//==============================================================================
// hud_render.v — Pure combinational HUD overlay (score, lives, pause, gameover)
// ZJU VGA rules: combinational only, BGR colors
// Renders text strings by computing char position from screen coordinates
//==============================================================================
`include "game_defs.vh"

module hud_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,  // current game state
    input  wire [19:0] score,       // player score (20-bit, max ~1M)
    input  wire [7:0]  kills,       // kill count
    input  wire [2:0]  lives,       // player HP
    input  wire [1:0]  difficulty,  // selected difficulty (menu)
    input  wire        mode,        // 0=score, 1=endless
    output wire        hit,
    output wire [11:0] color
);
    //---------- Character ROM lookup ----------
    // Function: given char_code and row, get 8-bit bitmap
    // Character mapping: A-Z=0-25, 0-9=26-35, space=36, :=37, /=38, |=39, -=40, >=41
    reg [7:0] char_bitmap;
    wire [7:0] char_code_7 = {2'd0, char_code};

    always @* begin
        case ({char_code, sy[2:0]})
            // A-Z (0-25), 0-9 (26-35), etc.
            {5'd0,  3'd0}: char_bitmap = 8'b00111000; // A
            {5'd0,  3'd1}: char_bitmap = 8'b01101100;
            {5'd0,  3'd2}: char_bitmap = 8'b11000110;
            {5'd0,  3'd3}: char_bitmap = 8'b11000110;
            {5'd0,  3'd4}: char_bitmap = 8'b11111110;
            {5'd0,  3'd5}: char_bitmap = 8'b11000110;
            {5'd0,  3'd6}: char_bitmap = 8'b11000110;
            {5'd0,  3'd7}: char_bitmap = 8'b00000000;
            {5'd1,  3'd0}: char_bitmap = 8'b11111100; // B
            {5'd1,  3'd1}: char_bitmap = 8'b11000110;
            {5'd1,  3'd2}: char_bitmap = 8'b11000110;
            {5'd1,  3'd3}: char_bitmap = 8'b11111100;
            {5'd1,  3'd4}: char_bitmap = 8'b11000110;
            {5'd1,  3'd5}: char_bitmap = 8'b11000110;
            {5'd1,  3'd6}: char_bitmap = 8'b11111100;
            {5'd1,  3'd7}: char_bitmap = 8'b00000000;
            {5'd2,  3'd0}: char_bitmap = 8'b00111100; // C
            {5'd2,  3'd1}: char_bitmap = 8'b01100110;
            {5'd2,  3'd2}: char_bitmap = 8'b11000000;
            {5'd2,  3'd3}: char_bitmap = 8'b11000000;
            {5'd2,  3'd4}: char_bitmap = 8'b11000000;
            {5'd2,  3'd5}: char_bitmap = 8'b01100110;
            {5'd2,  3'd6}: char_bitmap = 8'b00111100;
            {5'd2,  3'd7}: char_bitmap = 8'b00000000;
            {5'd3,  3'd0}: char_bitmap = 8'b11111000; // D
            {5'd3,  3'd1}: char_bitmap = 8'b11001100;
            {5'd3,  3'd2}: char_bitmap = 8'b11000110;
            {5'd3,  3'd3}: char_bitmap = 8'b11000110;
            {5'd3,  3'd4}: char_bitmap = 8'b11000110;
            {5'd3,  3'd5}: char_bitmap = 8'b11001100;
            {5'd3,  3'd6}: char_bitmap = 8'b11111000;
            {5'd3,  3'd7}: char_bitmap = 8'b00000000;
            {5'd4,  3'd0}: char_bitmap = 8'b11111110; // E
            {5'd4,  3'd1}: char_bitmap = 8'b11000000;
            {5'd4,  3'd2}: char_bitmap = 8'b11000000;
            {5'd4,  3'd3}: char_bitmap = 8'b11111100;
            {5'd4,  3'd4}: char_bitmap = 8'b11000000;
            {5'd4,  3'd5}: char_bitmap = 8'b11000000;
            {5'd4,  3'd6}: char_bitmap = 8'b11111110;
            {5'd4,  3'd7}: char_bitmap = 8'b00000000;
            {5'd5,  3'd0}: char_bitmap = 8'b11111110; // F
            {5'd5,  3'd1}: char_bitmap = 8'b11000000;
            {5'd5,  3'd2}: char_bitmap = 8'b11000000;
            {5'd5,  3'd3}: char_bitmap = 8'b11111100;
            {5'd5,  3'd4}: char_bitmap = 8'b11000000;
            {5'd5,  3'd5}: char_bitmap = 8'b11000000;
            {5'd5,  3'd6}: char_bitmap = 8'b11000000;
            {5'd5,  3'd7}: char_bitmap = 8'b00000000;
            {5'd6,  3'd0}: char_bitmap = 8'b00111100; // G
            {5'd6,  3'd1}: char_bitmap = 8'b01100110;
            {5'd6,  3'd2}: char_bitmap = 8'b11000000;
            {5'd6,  3'd3}: char_bitmap = 8'b11001110;
            {5'd6,  3'd4}: char_bitmap = 8'b11000110;
            {5'd6,  3'd5}: char_bitmap = 8'b01100110;
            {5'd6,  3'd6}: char_bitmap = 8'b00111100;
            {5'd6,  3'd7}: char_bitmap = 8'b00000000;
            {5'd7,  3'd0}: char_bitmap = 8'b11000110; // H
            {5'd7,  3'd1}: char_bitmap = 8'b11000110;
            {5'd7,  3'd2}: char_bitmap = 8'b11000110;
            {5'd7,  3'd3}: char_bitmap = 8'b11111110;
            {5'd7,  3'd4}: char_bitmap = 8'b11000110;
            {5'd7,  3'd5}: char_bitmap = 8'b11000110;
            {5'd7,  3'd6}: char_bitmap = 8'b11000110;
            {5'd7,  3'd7}: char_bitmap = 8'b00000000;
            {5'd8,  3'd0}: char_bitmap = 8'b01111100; // I
            {5'd8,  3'd1}: char_bitmap = 8'b00010000;
            {5'd8,  3'd2}: char_bitmap = 8'b00010000;
            {5'd8,  3'd3}: char_bitmap = 8'b00010000;
            {5'd8,  3'd4}: char_bitmap = 8'b00010000;
            {5'd8,  3'd5}: char_bitmap = 8'b00010000;
            {5'd8,  3'd6}: char_bitmap = 8'b01111100;
            {5'd8,  3'd7}: char_bitmap = 8'b00000000;
            {5'd11, 3'd0}: char_bitmap = 8'b11000000; // L
            {5'd11, 3'd1}: char_bitmap = 8'b11000000;
            {5'd11, 3'd2}: char_bitmap = 8'b11000000;
            {5'd11, 3'd3}: char_bitmap = 8'b11000000;
            {5'd11, 3'd4}: char_bitmap = 8'b11000000;
            {5'd11, 3'd5}: char_bitmap = 8'b11000000;
            {5'd11, 3'd6}: char_bitmap = 8'b11111110;
            {5'd11, 3'd7}: char_bitmap = 8'b00000000;
            {5'd12, 3'd0}: char_bitmap = 8'b10000010; // M
            {5'd12, 3'd1}: char_bitmap = 8'b11000110;
            {5'd12, 3'd2}: char_bitmap = 8'b11101110;
            {5'd12, 3'd3}: char_bitmap = 8'b10111010;
            {5'd12, 3'd4}: char_bitmap = 8'b10010010;
            {5'd12, 3'd5}: char_bitmap = 8'b10000010;
            {5'd12, 3'd6}: char_bitmap = 8'b10000010;
            {5'd12, 3'd7}: char_bitmap = 8'b00000000;
            {5'd13, 3'd0}: char_bitmap = 8'b11000110; // N
            {5'd13, 3'd1}: char_bitmap = 8'b11100110;
            {5'd13, 3'd2}: char_bitmap = 8'b11110110;
            {5'd13, 3'd3}: char_bitmap = 8'b11011110;
            {5'd13, 3'd4}: char_bitmap = 8'b11001110;
            {5'd13, 3'd5}: char_bitmap = 8'b11000110;
            {5'd13, 3'd6}: char_bitmap = 8'b11000110;
            {5'd13, 3'd7}: char_bitmap = 8'b00000000;
            {5'd14, 3'd0}: char_bitmap = 8'b00111000; // O
            {5'd14, 3'd1}: char_bitmap = 8'b01101100;
            {5'd14, 3'd2}: char_bitmap = 8'b11000110;
            {5'd14, 3'd3}: char_bitmap = 8'b11000110;
            {5'd14, 3'd4}: char_bitmap = 8'b11000110;
            {5'd14, 3'd5}: char_bitmap = 8'b01101100;
            {5'd14, 3'd6}: char_bitmap = 8'b00111000;
            {5'd14, 3'd7}: char_bitmap = 8'b00000000;
            {5'd15, 3'd0}: char_bitmap = 8'b11111100; // P
            {5'd15, 3'd1}: char_bitmap = 8'b11000110;
            {5'd15, 3'd2}: char_bitmap = 8'b11000110;
            {5'd15, 3'd3}: char_bitmap = 8'b11111100;
            {5'd15, 3'd4}: char_bitmap = 8'b11000000;
            {5'd15, 3'd5}: char_bitmap = 8'b11000000;
            {5'd15, 3'd6}: char_bitmap = 8'b11000000;
            {5'd15, 3'd7}: char_bitmap = 8'b00000000;
            {5'd17, 3'd0}: char_bitmap = 8'b11111100; // R
            {5'd17, 3'd1}: char_bitmap = 8'b11000110;
            {5'd17, 3'd2}: char_bitmap = 8'b11000110;
            {5'd17, 3'd3}: char_bitmap = 8'b11111100;
            {5'd17, 3'd4}: char_bitmap = 8'b11011000;
            {5'd17, 3'd5}: char_bitmap = 8'b11001100;
            {5'd17, 3'd6}: char_bitmap = 8'b11000110;
            {5'd17, 3'd7}: char_bitmap = 8'b00000000;
            {5'd18, 3'd0}: char_bitmap = 8'b01111100; // S
            {5'd18, 3'd1}: char_bitmap = 8'b11000110;
            {5'd18, 3'd2}: char_bitmap = 8'b11000000;
            {5'd18, 3'd3}: char_bitmap = 8'b01111100;
            {5'd18, 3'd4}: char_bitmap = 8'b00000110;
            {5'd18, 3'd5}: char_bitmap = 8'b11000110;
            {5'd18, 3'd6}: char_bitmap = 8'b01111100;
            {5'd18, 3'd7}: char_bitmap = 8'b00000000;
            {5'd19, 3'd0}: char_bitmap = 8'b11111110; // T
            {5'd19, 3'd1}: char_bitmap = 8'b00010000;
            {5'd19, 3'd2}: char_bitmap = 8'b00010000;
            {5'd19, 3'd3}: char_bitmap = 8'b00010000;
            {5'd19, 3'd4}: char_bitmap = 8'b00010000;
            {5'd19, 3'd5}: char_bitmap = 8'b00010000;
            {5'd19, 3'd6}: char_bitmap = 8'b00010000;
            {5'd19, 3'd7}: char_bitmap = 8'b00000000;
            {5'd20, 3'd0}: char_bitmap = 8'b11000110; // U
            {5'd20, 3'd1}: char_bitmap = 8'b11000110;
            {5'd20, 3'd2}: char_bitmap = 8'b11000110;
            {5'd20, 3'd3}: char_bitmap = 8'b11000110;
            {5'd20, 3'd4}: char_bitmap = 8'b11000110;
            {5'd20, 3'd5}: char_bitmap = 8'b11000110;
            {5'd20, 3'd6}: char_bitmap = 8'b01111100;
            {5'd20, 3'd7}: char_bitmap = 8'b00000000;
            {5'd21, 3'd0}: char_bitmap = 8'b11000110; // V
            {5'd21, 3'd1}: char_bitmap = 8'b11000110;
            {5'd21, 3'd2}: char_bitmap = 8'b11000110;
            {5'd21, 3'd3}: char_bitmap = 8'b01101100;
            {5'd21, 3'd4}: char_bitmap = 8'b01101100;
            {5'd21, 3'd5}: char_bitmap = 8'b00111000;
            {5'd21, 3'd6}: char_bitmap = 8'b00010000;
            {5'd21, 3'd7}: char_bitmap = 8'b00000000;
            {5'd22, 3'd0}: char_bitmap = 8'b10000010; // W
            {5'd22, 3'd1}: char_bitmap = 8'b10000010;
            {5'd22, 3'd2}: char_bitmap = 8'b10010010;
            {5'd22, 3'd3}: char_bitmap = 8'b10111010;
            {5'd22, 3'd4}: char_bitmap = 8'b11101110;
            {5'd22, 3'd5}: char_bitmap = 8'b11000110;
            {5'd22, 3'd6}: char_bitmap = 8'b10000010;
            {5'd22, 3'd7}: char_bitmap = 8'b00000000;
            {5'd24, 3'd0}: char_bitmap = 8'b11000110; // Y
            {5'd24, 3'd1}: char_bitmap = 8'b01101100;
            {5'd24, 3'd2}: char_bitmap = 8'b00111000;
            {5'd24, 3'd3}: char_bitmap = 8'b00010000;
            {5'd24, 3'd4}: char_bitmap = 8'b00010000;
            {5'd24, 3'd5}: char_bitmap = 8'b00010000;
            {5'd24, 3'd6}: char_bitmap = 8'b00010000;
            {5'd24, 3'd7}: char_bitmap = 8'b00000000;
            // Numbers 0-9 (char codes 26-35)
            {5'd26, 3'd0}: char_bitmap = 8'b00111000; // 0
            {5'd26, 3'd1}: char_bitmap = 8'b01101100;
            {5'd26, 3'd2}: char_bitmap = 8'b11000110;
            {5'd26, 3'd3}: char_bitmap = 8'b11010110;
            {5'd26, 3'd4}: char_bitmap = 8'b11010110;
            {5'd26, 3'd5}: char_bitmap = 8'b11000110;
            {5'd26, 3'd6}: char_bitmap = 8'b01111100;
            {5'd26, 3'd7}: char_bitmap = 8'b00000000;
            {5'd27, 3'd0}: char_bitmap = 8'b00010000; // 1
            {5'd27, 3'd1}: char_bitmap = 8'b00110000;
            {5'd27, 3'd2}: char_bitmap = 8'b00010000;
            {5'd27, 3'd3}: char_bitmap = 8'b00010000;
            {5'd27, 3'd4}: char_bitmap = 8'b00010000;
            {5'd27, 3'd5}: char_bitmap = 8'b00010000;
            {5'd27, 3'd6}: char_bitmap = 8'b01111100;
            {5'd27, 3'd7}: char_bitmap = 8'b00000000;
            {5'd28, 3'd0}: char_bitmap = 8'b01111100; // 2
            {5'd28, 3'd1}: char_bitmap = 8'b11000110;
            {5'd28, 3'd2}: char_bitmap = 8'b00000110;
            {5'd28, 3'd3}: char_bitmap = 8'b00011100;
            {5'd28, 3'd4}: char_bitmap = 8'b01110000;
            {5'd28, 3'd5}: char_bitmap = 8'b11000000;
            {5'd28, 3'd6}: char_bitmap = 8'b11111110;
            {5'd28, 3'd7}: char_bitmap = 8'b00000000;
            {5'd29, 3'd0}: char_bitmap = 8'b01111100; // 3
            {5'd29, 3'd1}: char_bitmap = 8'b11000110;
            {5'd29, 3'd2}: char_bitmap = 8'b00000110;
            {5'd29, 3'd3}: char_bitmap = 8'b00111100;
            {5'd29, 3'd4}: char_bitmap = 8'b00000110;
            {5'd29, 3'd5}: char_bitmap = 8'b11000110;
            {5'd29, 3'd6}: char_bitmap = 8'b01111100;
            {5'd29, 3'd7}: char_bitmap = 8'b00000000;
            {5'd30, 3'd0}: char_bitmap = 8'b00001100; // 4
            {5'd30, 3'd1}: char_bitmap = 8'b00011100;
            {5'd30, 3'd2}: char_bitmap = 8'b00101100;
            {5'd30, 3'd3}: char_bitmap = 8'b01001100;
            {5'd30, 3'd4}: char_bitmap = 8'b11111110;
            {5'd30, 3'd5}: char_bitmap = 8'b00001100;
            {5'd30, 3'd6}: char_bitmap = 8'b00001100;
            {5'd30, 3'd7}: char_bitmap = 8'b00000000;
            {5'd31, 3'd0}: char_bitmap = 8'b11111110; // 5
            {5'd31, 3'd1}: char_bitmap = 8'b11000000;
            {5'd31, 3'd2}: char_bitmap = 8'b11111100;
            {5'd31, 3'd3}: char_bitmap = 8'b00000110;
            {5'd31, 3'd4}: char_bitmap = 8'b00000110;
            {5'd31, 3'd5}: char_bitmap = 8'b11000110;
            {5'd31, 3'd6}: char_bitmap = 8'b01111100;
            {5'd31, 3'd7}: char_bitmap = 8'b00000000;
            {5'd32, 3'd0}: char_bitmap = 8'b00111100; // 6
            {5'd32, 3'd1}: char_bitmap = 8'b01100000;
            {5'd32, 3'd2}: char_bitmap = 8'b11000000;
            {5'd32, 3'd3}: char_bitmap = 8'b11111100;
            {5'd32, 3'd4}: char_bitmap = 8'b11000110;
            {5'd32, 3'd5}: char_bitmap = 8'b11000110;
            {5'd32, 3'd6}: char_bitmap = 8'b01111100;
            {5'd32, 3'd7}: char_bitmap = 8'b00000000;
            {5'd33, 3'd0}: char_bitmap = 8'b11111110; // 7
            {5'd33, 3'd1}: char_bitmap = 8'b00000110;
            {5'd33, 3'd2}: char_bitmap = 8'b00001100;
            {5'd33, 3'd3}: char_bitmap = 8'b00011000;
            {5'd33, 3'd4}: char_bitmap = 8'b00110000;
            {5'd33, 3'd5}: char_bitmap = 8'b01100000;
            {5'd33, 3'd6}: char_bitmap = 8'b11000000;
            {5'd33, 3'd7}: char_bitmap = 8'b00000000;
            {5'd34, 3'd0}: char_bitmap = 8'b01111100; // 8
            {5'd34, 3'd1}: char_bitmap = 8'b11000110;
            {5'd34, 3'd2}: char_bitmap = 8'b11000110;
            {5'd34, 3'd3}: char_bitmap = 8'b01111100;
            {5'd34, 3'd4}: char_bitmap = 8'b11000110;
            {5'd34, 3'd5}: char_bitmap = 8'b11000110;
            {5'd34, 3'd6}: char_bitmap = 8'b01111100;
            {5'd34, 3'd7}: char_bitmap = 8'b00000000;
            {5'd35, 3'd0}: char_bitmap = 8'b01111100; // 9
            {5'd35, 3'd1}: char_bitmap = 8'b11000110;
            {5'd35, 3'd2}: char_bitmap = 8'b11000110;
            {5'd35, 3'd3}: char_bitmap = 8'b01111110;
            {5'd35, 3'd4}: char_bitmap = 8'b00000110;
            {5'd35, 3'd5}: char_bitmap = 8'b00001100;
            {5'd35, 3'd6}: char_bitmap = 8'b01111000;
            {5'd35, 3'd7}: char_bitmap = 8'b00000000;
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
            // | (39)
            {5'd39, 3'd0}: char_bitmap = 8'b00010000;
            {5'd39, 3'd1}: char_bitmap = 8'b00010000;
            {5'd39, 3'd2}: char_bitmap = 8'b00010000;
            {5'd39, 3'd3}: char_bitmap = 8'b00010000;
            {5'd39, 3'd4}: char_bitmap = 8'b00010000;
            {5'd39, 3'd5}: char_bitmap = 8'b00010000;
            {5'd39, 3'd6}: char_bitmap = 8'b00010000;
            {5'd39, 3'd7}: char_bitmap = 8'b00000000;
            // X (23) - for "SCORE:X"
            {5'd23, 3'd0}: char_bitmap = 8'b11000110; // X
            {5'd23, 3'd1}: char_bitmap = 8'b01101100;
            {5'd23, 3'd2}: char_bitmap = 8'b00111000;
            {5'd23, 3'd3}: char_bitmap = 8'b00010000;
            {5'd23, 3'd4}: char_bitmap = 8'b00111000;
            {5'd23, 3'd5}: char_bitmap = 8'b01101100;
            {5'd23, 3'd6}: char_bitmap = 8'b11000110;
            {5'd23, 3'd7}: char_bitmap = 8'b00000000;
            default: char_bitmap = 8'b00000000;
        endcase
    end

    //---------- Utility: character at (base_x, base_y) ----------
    // Returns the character code expected at pixel (sx, sy) given a string layout
    wire [4:0] char_code;  // will be assigned by the active text section

    //---------- Score display: "SCORE:" + 8 digits (bottom-right) ----------
    // Base position: (480, 452) — right side, bottom area
    wire [9:0] score_base_x = 10'd400;
    wire [9:0] score_base_y = 10'd456;

    // Compute which character of "SCORE:XXXXXXXX" we're at
    // "SCORE:" = 6 chars + 8 digits = 14 chars total
    // char 0-4: S,C,O,R,E  char 5: :  char 6-13: digits
    wire [9:0] score_rel_x = sx - score_base_x;
    wire [3:0] score_chi = score_rel_x[6:3];  // char index (0-13)
    wire [2:0] score_col = score_rel_x[2:0];   // pixel column within char (0-7)
    wire [2:0] score_row = sy[2:0] - score_base_y[2:0];

    wire in_score_box = (game_state == `STATE_PLAYING || game_state == `STATE_PAUSED) &&
                        (sx >= score_base_x) && (sx < score_base_x + 10'd112) &&
                        (sy >= score_base_y) && (sy < score_base_y + 10'd8);

    // Score digits: break 20-bit score into 8 BCD digits
    // Simple approach: use binary to BCD conversion (just split hex display for now)
    wire [3:0] sc_digit7 = score[19:16];
    wire [3:0] sc_digit6 = score[15:12];
    wire [3:0] sc_digit5 = score[11:8];
    wire [3:0] sc_digit4 = score[7:4];
    wire [3:0] sc_digit3 = {2'd0, score[3:2]};  // approximate BCD
    wire [3:0] sc_digit2 = score[3:0];
    wire [3:0] sc_digit1 = 4'd0;
    wire [3:0] sc_digit0 = 4'd0;

    // Character lookup for score string
    reg [4:0] score_char;
    always @* begin
        case (score_chi)
            4'd0:  score_char = 5'd18;  // S
            4'd1:  score_char = 5'd2;   // C
            4'd2:  score_char = 5'd14;  // O
            4'd3:  score_char = 5'd17;  // R
            4'd4:  score_char = 5'd4;   // E
            4'd5:  score_char = 5'd37;  // :
            4'd6:  score_char = 5'd26 + {1'b0, sc_digit7};  // digit
            4'd7:  score_char = 5'd26 + {1'b0, sc_digit6};
            4'd8:  score_char = 5'd26 + {1'b0, sc_digit5};
            4'd9:  score_char = 5'd26 + {1'b0, sc_digit4};
            4'd10: score_char = 5'd26 + {1'b0, sc_digit3};
            4'd11: score_char = 5'd26 + {1'b0, sc_digit2};
            4'd12: score_char = 5'd26 + {1'b0, sc_digit1};
            4'd13: score_char = 5'd26 + {1'b0, sc_digit0};
            default: score_char = 5'd36;
        endcase
    end

    wire score_hit = in_score_box && char_bitmap[3'd7 - score_col];

    //---------- Pause symbol: "||" ----------
    wire in_pause_box = (game_state == `STATE_PAUSED) &&
                        (sx >= 10'd600) && (sx < 10'd616) &&
                        (sy >= 10'd456) && (sy < 10'd464);
    wire pause_hit = in_pause_box && char_bitmap[3'd7 - sx[2:0]];

    // Character for pause: use '|' (39)
    // The box covers 2 chars at (600,456): "||"
    wire [4:0] pause_char = 5'd39;

    //---------- GAME OVER display ----------
    // "GAME" centered at x=280, y=200; "OVER" centered at x=280, y=216
    wire [9:0] go1_base_x = 10'd272;  // "GAME" 4 chars * 8 = 32, center at ~288
    wire [9:0] go1_base_y = 10'd200;
    wire [9:0] go2_base_x = 10'd272;
    wire [9:0] go2_base_y = 10'd216;

    wire in_go1 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go1_base_x) && (sx < go1_base_x + 10'd32) &&
                  (sy >= go1_base_y) && (sy < go1_base_y + 10'd16);

    wire in_go2 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go2_base_x) && (sx < go2_base_x + 10'd32) &&
                  (sy >= go2_base_y) && (sy < go2_base_y + 10'd16);

    wire [1:0] go1_chi = sx[4:3] - go1_base_x[4:3];
    wire [1:0] go2_chi = sx[4:3] - go2_base_x[4:3];

    reg [4:0] go1_char, go2_char;
    always @* begin
        case (go1_chi)  // G,A,M,E
            2'd0: go1_char = 5'd6;   // G
            2'd1: go1_char = 5'd0;   // A
            2'd2: go1_char = 5'd12;  // M
            2'd3: go1_char = 5'd4;   // E
        endcase
        case (go2_chi)  // O,V,E,R
            2'd0: go2_char = 5'd14;  // O
            2'd1: go2_char = 5'd21;  // V
            2'd2: go2_char = 5'd4;   // E
            2'd3: go2_char = 5'd17;  // R
        endcase
    end

    // Scale up GAME OVER to double height: use every other row
    wire go_row_scaled = sy[0] ? sy[3:1] : sy[3:1];  // each font row drawn 2 pixels tall
    wire go_hit = 0;  // Computed below

    // Simplified: just double-size the font by checking every other pixel
    // For now: regular size text
    wire go1_hit = in_go1 && char_bitmap[3'd7 - sx[2:0]];
    wire go2_hit = in_go2 && char_bitmap[3'd7 - sx[2:0]];

    wire go_any = go1_hit || go2_hit;

    //---------- YOU WIN display ----------
    // "YOU" centered, "WIN" centered
    wire [9:0] yw1_base_x = 10'd280;
    wire [9:0] yw1_base_y = 10'd200;
    wire [9:0] yw2_base_x = 10'd280;
    wire [9:0] yw2_base_y = 10'd216;

    wire in_yw1 = (game_state == `STATE_WIN) &&
                  (sx >= yw1_base_x) && (sx < yw1_base_x + 10'd24) &&
                  (sy >= yw1_base_y) && (sy < yw1_base_y + 10'd16);
    wire in_yw2 = (game_state == `STATE_WIN) &&
                  (sx >= yw2_base_x) && (sx < yw2_base_x + 10'd24) &&
                  (sy >= yw2_base_y) && (sy < yw2_base_y + 10'd16);

    wire [1:0] yw1_chi = sx[4:3] - yw1_base_x[4:3];
    wire [1:0] yw2_chi = sx[4:3] - yw2_base_x[4:3];

    reg [4:0] yw1_char, yw2_char;
    always @* begin
        case (yw1_chi)  // Y,O,U
            2'd0: yw1_char = 5'd24;  // Y
            2'd1: yw1_char = 5'd14;  // O
            2'd2: yw1_char = 5'd20;  // U
        endcase
        case (yw2_chi)  // W,I,N
            2'd0: yw2_char = 5'd22;  // W
            2'd1: yw2_char = 5'd8;   // I
            2'd2: yw2_char = 5'd13;  // N
        endcase
    end

    wire yw1_hit = in_yw1 && char_bitmap[3'd7 - sx[2:0]];
    wire yw2_hit = in_yw2 && char_bitmap[3'd7 - sx[2:0]];
    wire yw_any = yw1_hit || yw2_hit;

    //---------- Lives display: "HP:X" top-left ----------
    wire [9:0] hp_base_x = 10'd8;
    wire [9:0] hp_base_y = 10'd8;
    wire in_hp_box = (game_state == `STATE_PLAYING || game_state == `STATE_PAUSED) &&
                     (sx >= hp_base_x) && (sx < hp_base_x + 10'd32) &&
                     (sy >= hp_base_y) && (sy < hp_base_y + 10'd8);
    wire [1:0] hp_chi = sx[4:3] - hp_base_x[4:3];

    reg [4:0] hp_char;
    always @* begin
        case (hp_chi)
            2'd0: hp_char = 5'd7;   // H
            2'd1: hp_char = 5'd15;  // P
            2'd2: hp_char = 5'd37;  // :
            2'd3: hp_char = 5'd26 + {2'd0, lives};  // digit
        endcase
    end
    wire hp_hit = in_hp_box && char_bitmap[3'd7 - sx[2:0]];

    //---------- Final hit and color ----------
    wire is_hit = score_hit || pause_hit || go_any || yw_any || hp_hit;

    assign hit = is_hit;
    assign color = go_any                  ? `COL_RED    :
                   yw_any                  ? `COL_GREEN  :
                   (pause_hit && !score_hit) ? `COL_YELLOW :
                   `COL_WHITE;

    // Note: char_code drives the font ROM lookup - connect to active context
    assign char_code = in_score_box ? score_char :
                       in_pause_box ? (pause_char) :
                       in_go1       ? go1_char   :
                       in_go2       ? go2_char   :
                       in_yw1       ? yw1_char   :
                       in_yw2       ? yw2_char   :
                       in_hp_box    ? hp_char    : 5'd36;
endmodule
