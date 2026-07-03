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
    //---------- Font ROM (Block Memory) ----------
    // Address: {char_code[5:0], sy[2:0]} = 9 bits, Data: 8-bit bitmap row
    // Character mapping: A-Z=0-25, space=36, :=37, / unused=38, -=40, .=42
    wire [5:0] char_code;
    wire [7:0] char_bitmap;
    ROM_f u_font_rom (
        .a  ({char_code[5:0], sy[2:0]}),
        .spo(char_bitmap)
    );

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
    // Title at y=96, centered. 26 characters, start at x=112 (Y must be multiple of 8 for text alignment)
    wire [9:0] title_base_x = 10'd112;  // (640 - 26*8) / 2 ≈ 112
    wire [9:0] title_base_y = 10'd96;

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

    reg [5:0] title_char1, title_char2;
    always @* begin
        // "AEROPLANE" (9 chars)
        case (title_chi_line1)
            6'd0: title_char1 = 6'd0;   // A
            6'd1: title_char1 = 6'd4;   // E
            6'd2: title_char1 = 6'd17;  // R
            6'd3: title_char1 = 6'd14;  // O
            6'd4: title_char1 = 6'd15;  // P
            6'd5: title_char1 = 6'd11;  // L
            6'd6: title_char1 = 6'd0;   // A
            6'd7: title_char1 = 6'd13;  // N
            6'd8: title_char1 = 6'd4;   // E
            default: title_char1 = 6'd36; // space
        endcase
        // "DANMAKU SHOOTING" (16 chars)
        case (title_chi_line2)
            6'd0:  title_char2 = 6'd3;   // D
            6'd1:  title_char2 = 6'd0;   // A
            6'd2:  title_char2 = 6'd13;  // N
            6'd3:  title_char2 = 6'd12;  // M
            6'd4:  title_char2 = 6'd0;   // A
            6'd5:  title_char2 = 6'd10;  // K
            6'd6:  title_char2 = 6'd20;  // U
            6'd7:  title_char2 = 6'd36;  // space
            6'd8:  title_char2 = 6'd18;  // S
            6'd9:  title_char2 = 6'd7;   // H
            6'd10: title_char2 = 6'd14;  // O
            6'd11: title_char2 = 6'd14;  // O
            6'd12: title_char2 = 6'd19;  // T
            6'd13: title_char2 = 6'd8;   // I
            6'd14: title_char2 = 6'd13;  // N
            6'd15: title_char2 = 6'd6;   // G
            default: title_char2 = 6'd36;
        endcase
    end

    wire title_hit1 = in_title_line1 && char_bitmap[3'd7 - sx[2:0]];
    wire title_hit2 = in_title_line2 && char_bitmap[3'd7 - sx[2:0]];
    wire title_hit = title_hit1 || title_hit2;

    //---------- START box ----------  (Y must be multiple of 8 for text alignment)
    wire [9:0] start_box_x = 10'd264;
    wire [9:0] start_box_y = 10'd184;
    wire start_box = (sx >= start_box_x) && (sx < start_box_x + 10'd112) &&
                     (sy >= start_box_y) && (sy < start_box_y + 10'd24);
    wire start_box_edge = start_box && (
        (sx < start_box_x + 10'd4) || (sx >= start_box_x + 10'd108) ||
        (sy < start_box_y + 10'd4) || (sy >= start_box_y + 10'd20));
    wire start_box_fill = start_box && !start_box_edge;

    // "START" text centered in box (5 chars * 8 = 40, box is 112)
    wire [9:0] start_text_x = 10'd300;
    wire [9:0] start_text_y = 10'd192;  // Y multiple of 8
    wire in_start_text = (game_state == `STATE_MENU) && start_box &&
                         (sx >= start_text_x) && (sx < start_text_x + 10'd40) &&
                         (sy >= start_text_y) && (sy < start_text_y + 10'd8);
    wire [4:0] start_chi = sx[5:3] - start_text_x[5:3];
    reg [5:0] start_char;
    always @* begin
        case (start_chi)
            6'd0: start_char = 6'd18;  // S
            6'd1: start_char = 6'd19;  // T
            6'd2: start_char = 6'd0;   // A
            6'd3: start_char = 6'd17;  // R
            6'd4: start_char = 6'd19;  // T
            default: start_char = 6'd36;
        endcase
    end
    wire start_text_hit = in_start_text && char_bitmap[3'd7 - sx[2:0]];

    //---------- Difficulty display ----------  (Y must be multiple of 8)
    wire [9:0] diff_base_x = 10'd360;
    wire [9:0] diff_base_y = 10'd304;
    wire in_diff_label = (game_state == `STATE_MENU) &&
                         (sx >= diff_base_x) && (sx < diff_base_x + 10'd88) &&
                         (sy >= diff_base_y) && (sy < diff_base_y + 10'd8);
    wire [4:0] diff_chi = sx[5:3] - diff_base_x[5:3];

    // "DIFFICULTY:" = 11 chars
    reg [5:0] diff_char;
    always @* begin
        case (diff_chi)
            6'd0:  diff_char = 6'd3;   // D
            6'd1:  diff_char = 6'd8;   // I
            6'd2:  diff_char = 6'd5;   // F
            6'd3:  diff_char = 6'd5;   // F
            6'd4:  diff_char = 6'd8;   // I
            6'd5:  diff_char = 6'd2;   // C
            6'd6:  diff_char = 6'd20;  // U
            6'd7:  diff_char = 6'd11;  // L
            6'd8:  diff_char = 6'd19;  // T
            6'd9:  diff_char = 6'd24;  // Y
            6'd10: diff_char = 6'd37;  // :
            default: diff_char = 6'd36;
        endcase
    end
    wire diff_label_hit = in_diff_label && char_bitmap[3'd7 - sx[2:0]];

    // Difficulty value: "EASY"/"NORMAL"/"HARD"/"HELL"
    wire [9:0] diff_val_x = 10'd448;
    wire [9:0] diff_val_y = 10'd304;
    wire in_diff_val = (game_state == `STATE_MENU) &&
                       (sx >= diff_val_x) && (sx < diff_val_x + 10'd48) &&
                       (sy >= diff_val_y) && (sy < diff_val_y + 10'd8);
    wire [4:0] diffv_chi = sx[5:3] - diff_val_x[5:3];
    reg [5:0] diffv_char;
    always @* begin
        if (difficulty == `DIFF_EASY) begin
            case (diffv_chi)
                6'd0: diffv_char = 6'd4;   // E
                6'd1: diffv_char = 6'd0;   // A
                6'd2: diffv_char = 6'd18;  // S
                6'd3: diffv_char = 6'd24;  // Y
                default: diffv_char = 6'd36;
            endcase
        end else if (difficulty == `DIFF_NORMAL) begin
            case (diffv_chi)
                6'd0: diffv_char = 6'd13;  // N
                6'd1: diffv_char = 6'd14;  // O
                6'd2: diffv_char = 6'd17;  // R
                6'd3: diffv_char = 6'd12;  // M
                6'd4: diffv_char = 6'd0;   // A
                6'd5: diffv_char = 6'd11;  // L
                default: diffv_char = 6'd36;
            endcase
        end else if (difficulty == `DIFF_HARD) begin
            case (diffv_chi)
                6'd0: diffv_char = 6'd7;   // H
                6'd1: diffv_char = 6'd0;   // A
                6'd2: diffv_char = 6'd17;  // R
                6'd3: diffv_char = 6'd3;   // D
                default: diffv_char = 6'd36;
            endcase
        end else begin  // HELL
            case (diffv_chi)
                6'd0: diffv_char = 6'd7;    // H
                6'd1: diffv_char = 6'd4;    // E
                6'd2: diffv_char = 6'd11;   // L
                6'd3: diffv_char = 6'd11;   // L
                default: diffv_char = 6'd36;
            endcase
        end
    end
    wire diff_val_hit = in_diff_val && char_bitmap[3'd7 - sx[2:0]];

    //---------- Mode display ----------
    // "MODE:SCORE" or "MODE:ENDLESS"  (Y must be multiple of 8)
    wire [9:0] mode_base_x = 10'd360;
    wire [9:0] mode_base_y = 10'd320;
    wire in_mode_label = (game_state == `STATE_MENU) &&
                         (sx >= mode_base_x) && (sx < mode_base_x + 10'd40) &&
                         (sy >= mode_base_y) && (sy < mode_base_y + 10'd8);
    wire [4:0] mode_chi = sx[5:3] - mode_base_x[5:3];
    reg [5:0] mode_char;
    always @* begin
        case (mode_chi)
            6'd0: mode_char = 6'd12;  // M
            6'd1: mode_char = 6'd14;  // O
            6'd2: mode_char = 6'd3;   // D
            6'd3: mode_char = 6'd4;   // E
            6'd4: mode_char = 6'd37;  // :
            default: mode_char = 6'd36;
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
    reg [5:0] modev_char;
    always @* begin
        if (!mode) begin  // SCORE
            case (modev_chi)
                6'd0: modev_char = 6'd18;  // S
                6'd1: modev_char = 6'd2;   // C
                6'd2: modev_char = 6'd14;  // O
                6'd3: modev_char = 6'd17;  // R
                6'd4: modev_char = 6'd4;   // E
                default: modev_char = 6'd36;
            endcase
        end else begin  // ENDLESS
            case (modev_chi)
                6'd0: modev_char = 6'd4;   // E
                6'd1: modev_char = 6'd13;  // N
                6'd2: modev_char = 6'd3;   // D
                6'd3: modev_char = 6'd11;  // L
                6'd4: modev_char = 6'd4;   // E
                6'd5: modev_char = 6'd18;  // S
                6'd6: modev_char = 6'd18;  // S
                default: modev_char = 6'd36;
            endcase
        end
    end
    wire mode_val_hit = in_mode_val && char_bitmap[3'd7 - sx[2:0]];

    //---------- Controls hint (multi-line, Y must be multiples of 8) ----------
    wire [9:0] hint_base_x = 10'd100;
    wire [9:0] hint_y0 = 10'd360;   // "WASD: Move  J/Space: Fire  K: Upgrade"
    wire [9:0] hint_y1 = 10'd376;   // "P: Pause  M: Mode  Tab: Display"
    wire [9:0] hint_y2 = 10'd392;   // "1-4: Difficulty  Enter: Start"
    wire [9:0] hint_y3 = 10'd408;   // "PRESS ENTER TO START"
    wire in_hint0 = (game_state == `STATE_MENU) &&
                    (sx >= hint_base_x) && (sx < hint_base_x + 10'd360) &&
                    (sy >= hint_y0) && (sy < hint_y0 + 10'd8);
    wire in_hint1 = (game_state == `STATE_MENU) &&
                    (sx >= hint_base_x) && (sx < hint_base_x + 10'd360) &&
                    (sy >= hint_y1) && (sy < hint_y1 + 10'd8);
    wire in_hint2 = (game_state == `STATE_MENU) &&
                    (sx >= hint_base_x) && (sx < hint_base_x + 10'd360) &&
                    (sy >= hint_y2) && (sy < hint_y2 + 10'd8);
    wire in_hint3 = (game_state == `STATE_MENU) &&
                    (sx >= hint_base_x) && (sx < hint_base_x + 10'd360) &&
                    (sy >= hint_y3) && (sy < hint_y3 + 10'd8);
    wire [4:0] hint_chi = sx[5:3] - hint_base_x[5:3];
    reg [5:0] hint_char;
    always @* begin
        if (in_hint0) begin
            // "WASD: MOVE  J/SPACE: FIRE  K: UPGRADE"
            case (hint_chi)
                6'd0:  hint_char = 6'd22;  // W
                6'd1:  hint_char = 6'd0;   // A
                6'd2:  hint_char = 6'd18;  // S
                6'd3:  hint_char = 6'd3;   // D
                6'd4:  hint_char = 6'd37;  // :
                6'd5:  hint_char = 6'd36;  // space
                6'd6:  hint_char = 6'd12;  // M
                6'd7:  hint_char = 6'd14;  // O
                6'd8:  hint_char = 6'd21;  // V
                6'd9:  hint_char = 6'd4;   // E
                6'd10: hint_char = 6'd36;
                6'd11: hint_char = 6'd36;
                6'd12: hint_char = 6'd9;   // J
                6'd13: hint_char = 6'd40;  // -
                6'd14: hint_char = 6'd5;   // F
                6'd15: hint_char = 6'd8;   // I
                6'd16: hint_char = 6'd17;  // R
                6'd17: hint_char = 6'd4;   // E
                6'd18: hint_char = 6'd36;
                6'd19: hint_char = 6'd36;
                6'd20: hint_char = 6'd10;  // K
                6'd21: hint_char = 6'd37;  // :
                6'd22: hint_char = 6'd36;
                6'd23: hint_char = 6'd20;  // U
                6'd24: hint_char = 6'd15;  // P
                6'd25: hint_char = 6'd6;   // G
                6'd26: hint_char = 6'd17;  // R
                6'd27: hint_char = 6'd0;   // A
                6'd28: hint_char = 6'd3;   // D
                6'd29: hint_char = 6'd4;   // E
                default: hint_char = 6'd36;
            endcase
        end else if (in_hint1) begin
            // "P: PAUSE  M: MODE  TAB: DISPLAY"
            case (hint_chi)
                6'd0:  hint_char = 6'd15;  // P
                6'd1:  hint_char = 6'd37;  // :
                6'd2:  hint_char = 6'd36;
                6'd3:  hint_char = 6'd15;  // P
                6'd4:  hint_char = 6'd0;   // A
                6'd5:  hint_char = 6'd20;  // U
                6'd6:  hint_char = 6'd18;  // S
                6'd7:  hint_char = 6'd4;   // E
                6'd8:  hint_char = 6'd36;
                6'd9:  hint_char = 6'd36;
                6'd10: hint_char = 6'd12;  // M
                6'd11: hint_char = 6'd37;  // :
                6'd12: hint_char = 6'd36;
                6'd13: hint_char = 6'd12;  // M
                6'd14: hint_char = 6'd14;  // O
                6'd15: hint_char = 6'd3;   // D
                6'd16: hint_char = 6'd4;   // E
                6'd17: hint_char = 6'd36;
                6'd18: hint_char = 6'd36;
                6'd19: hint_char = 6'd19;  // T
                6'd20: hint_char = 6'd0;   // A
                6'd21: hint_char = 6'd1;   // B
                6'd22: hint_char = 6'd37;  // :
                6'd23: hint_char = 6'd36;
                6'd24: hint_char = 6'd3;   // D
                6'd25: hint_char = 6'd8;   // I
                6'd26: hint_char = 6'd18;  // S
                6'd27: hint_char = 6'd15;  // P
                6'd28: hint_char = 6'd11;  // L
                6'd29: hint_char = 6'd0;   // A
                6'd30: hint_char = 6'd24;  // Y
                default: hint_char = 6'd36;
            endcase
        end else if (in_hint2) begin
            // "1-4: DIFFICULTY  ENTER: START"
            case (hint_chi)
                6'd0:  hint_char = 6'd27;  // 1
                6'd1:  hint_char = 6'd40;  // -
                6'd2:  hint_char = 6'd30;  // 4
                6'd3:  hint_char = 6'd37;  // :
                6'd4:  hint_char = 6'd36;
                6'd5:  hint_char = 6'd3;   // D
                6'd6:  hint_char = 6'd8;   // I
                6'd7:  hint_char = 6'd5;   // F
                6'd8:  hint_char = 6'd5;   // F
                6'd9:  hint_char = 6'd8;   // I
                6'd10: hint_char = 6'd2;   // C
                6'd11: hint_char = 6'd20;  // U
                6'd12: hint_char = 6'd11;  // L
                6'd13: hint_char = 6'd19;  // T
                6'd14: hint_char = 6'd24;  // Y
                6'd15: hint_char = 6'd36;
                6'd16: hint_char = 6'd36;
                6'd17: hint_char = 6'd4;   // E
                6'd18: hint_char = 6'd13;  // N
                6'd19: hint_char = 6'd19;  // T
                6'd20: hint_char = 6'd4;   // E
                6'd21: hint_char = 6'd17;  // R
                6'd22: hint_char = 6'd37;  // :
                6'd23: hint_char = 6'd36;
                6'd24: hint_char = 6'd18;  // S
                6'd25: hint_char = 6'd19;  // T
                6'd26: hint_char = 6'd0;   // A
                6'd27: hint_char = 6'd17;  // R
                6'd28: hint_char = 6'd19;  // T
                default: hint_char = 6'd36;
            endcase
        end else begin
            // "PRESS ENTER TO START"
            case (hint_chi)
                6'd0:  hint_char = 6'd15;  // P
                6'd1:  hint_char = 6'd17;  // R
                6'd2:  hint_char = 6'd4;   // E
                6'd3:  hint_char = 6'd18;  // S
                6'd4:  hint_char = 6'd18;  // S
                6'd5:  hint_char = 6'd36;
                6'd6:  hint_char = 6'd4;   // E
                6'd7:  hint_char = 6'd13;  // N
                6'd8:  hint_char = 6'd19;  // T
                6'd9:  hint_char = 6'd4;   // E
                6'd10: hint_char = 6'd17;  // R
                6'd11: hint_char = 6'd36;
                6'd12: hint_char = 6'd19;  // T
                6'd13: hint_char = 6'd14;  // O
                6'd14: hint_char = 6'd36;
                6'd15: hint_char = 6'd18;  // S
                6'd16: hint_char = 6'd19;  // T
                6'd17: hint_char = 6'd0;   // A
                6'd18: hint_char = 6'd17;  // R
                6'd19: hint_char = 6'd19;  // T
                default: hint_char = 6'd36;
            endcase
        end
    end
    wire hint_hit = (in_hint0 || in_hint1 || in_hint2 || in_hint3) && char_bitmap[3'd7 - sx[2:0]];

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
                       (in_hint0 || in_hint1 || in_hint2 || in_hint3) ? hint_char : 6'd36;
endmodule
