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
    //---------- Character ROM (Block Memory) ----------
    // Address: {char_code[5:0], sy[2:0]} = 9 bits, Data: 8-bit bitmap row
    // Character mapping: A-Z=0-25, 0-9=26-35, space=36, :=37, |=39, -=40, .=42
    wire [7:0] char_bitmap;
    ROM_f u_font_rom (
        .a  ({char_code[5:0], sy[2:0]}),
        .spo(char_bitmap)
    );

    //---------- Utility: character at (base_x, base_y) ----------
    // Returns the character code expected at pixel (sx, sy) given a string layout
    wire [5:0] char_code;  // will be assigned by the active text section

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
    reg [5:0] score_char;
    always @* begin
        case (score_chi)
            4'd0:  score_char = 6'd18;  // S
            4'd1:  score_char = 6'd2;   // C
            4'd2:  score_char = 6'd14;  // O
            4'd3:  score_char = 6'd17;  // R
            4'd4:  score_char = 6'd4;   // E
            4'd5:  score_char = 6'd37;  // :
            4'd6:  score_char = 6'd26 + {1'b0, sc_digit7};  // digit
            4'd7:  score_char = 6'd26 + {1'b0, sc_digit6};
            4'd8:  score_char = 6'd26 + {1'b0, sc_digit5};
            4'd9:  score_char = 6'd26 + {1'b0, sc_digit4};
            4'd10: score_char = 6'd26 + {1'b0, sc_digit3};
            4'd11: score_char = 6'd26 + {1'b0, sc_digit2};
            4'd12: score_char = 6'd26 + {1'b0, sc_digit1};
            4'd13: score_char = 6'd26 + {1'b0, sc_digit0};
            default: score_char = 6'd36;
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
    wire [5:0] pause_char = 6'd39;

    //---------- GAME OVER display ----------
    // "GAME" centered at x=280, y=200; "OVER" centered at x=280, y=216
    wire [9:0] go1_base_x = 10'd272;  // "GAME" 4 chars * 8 = 32, center at ~288
    wire [9:0] go1_base_y = 10'd200;
    wire [9:0] go2_base_x = 10'd272;
    wire [9:0] go2_base_y = 10'd216;

    wire in_go1 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go1_base_x) && (sx < go1_base_x + 10'd32) &&
                  (sy >= go1_base_y) && (sy < go1_base_y + 10'd8);

    wire in_go2 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go2_base_x) && (sx < go2_base_x + 10'd32) &&
                  (sy >= go2_base_y) && (sy < go2_base_y + 10'd8);

    wire [1:0] go1_chi = sx[4:3] - go1_base_x[4:3];
    wire [1:0] go2_chi = sx[4:3] - go2_base_x[4:3];

    reg [5:0] go1_char, go2_char;
    always @* begin
        case (go1_chi)  // G,A,M,E
            2'd0: go1_char = 6'd6;   // G
            2'd1: go1_char = 6'd0;   // A
            2'd2: go1_char = 6'd12;  // M
            2'd3: go1_char = 6'd4;   // E
        endcase
        case (go2_chi)  // O,V,E,R
            2'd0: go2_char = 6'd14;  // O
            2'd1: go2_char = 6'd21;  // V
            2'd2: go2_char = 6'd4;   // E
            2'd3: go2_char = 6'd17;  // R
        endcase
    end

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
                  (sy >= yw1_base_y) && (sy < yw1_base_y + 10'd8);
    wire in_yw2 = (game_state == `STATE_WIN) &&
                  (sx >= yw2_base_x) && (sx < yw2_base_x + 10'd24) &&
                  (sy >= yw2_base_y) && (sy < yw2_base_y + 10'd8);

    wire [1:0] yw1_chi = sx[4:3] - yw1_base_x[4:3];
    wire [1:0] yw2_chi = sx[4:3] - yw2_base_x[4:3];

    reg [5:0] yw1_char, yw2_char;
    always @* begin
        case (yw1_chi)  // Y,O,U
            2'd0: yw1_char = 6'd24;  // Y
            2'd1: yw1_char = 6'd14;  // O
            2'd2: yw1_char = 6'd20;  // U
        endcase
        case (yw2_chi)  // W,I,N
            2'd0: yw2_char = 6'd22;  // W
            2'd1: yw2_char = 6'd8;   // I
            2'd2: yw2_char = 6'd13;  // N
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

    reg [5:0] hp_char;
    always @* begin
        case (hp_chi)
            2'd0: hp_char = 6'd7;   // H
            2'd1: hp_char = 6'd15;  // P
            2'd2: hp_char = 6'd37;  // :
            2'd3: hp_char = 6'd26 + {2'd0, lives};  // digit
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
                       in_hp_box    ? hp_char    : 6'd36;
endmodule
