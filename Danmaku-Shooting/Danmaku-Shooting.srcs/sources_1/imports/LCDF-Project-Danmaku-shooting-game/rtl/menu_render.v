`include "game_defs.vh"

module menu_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,
    input  wire [1:0]  difficulty,
    input  wire        mode,
    output wire        hit,
    output wire [11:0] color
);

    wire [5:0] char_code;
    wire [7:0] char_bitmap;
    ROM_f u_font_rom (
        .a  ({char_code[5:0], sy[2:0]}),
        .spo(char_bitmap)
    );

    wire border_h = (sx >= 10'd80) && (sx < 10'd560) && (sy >= 10'd40) && (sy < 10'd440);
    wire border_edge_h = (sx >= 10'd80) && (sx < 10'd84) ||
                         (sx >= 10'd556) && (sx < 10'd560) ||
                         (sy >= 10'd40) && (sy < 10'd44) ||
                         (sy >= 10'd436) && (sy < 10'd440);

    wire [2:0] border_phase = sx[5:3] + sy[5:3];
    wire [11:0] border_color = (border_phase[0]) ? `COL_CYAN  :
                               (border_phase[1]) ? `COL_MAGENTA : `COL_YELLOW;

    wire inner_edge_h = (sx >= 10'd84) && (sx < 10'd88) ||
                        (sx >= 10'd552) && (sx < 10'd556) ||
                        (sy >= 10'd44) && (sy < 10'd48) ||
                        (sy >= 10'd432) && (sy < 10'd436);

    wire [9:0] title_base_x = 10'd112;
    wire [9:0] title_base_y = 10'd96;

    wire in_title = (game_state == `STATE_MENU) &&
                    (sx >= title_base_x) && (sx < title_base_x + 10'd208) &&
                    (sy >= title_base_y) && (sy < title_base_y + 10'd16);

    wire in_title_line1 = in_title && (sy < title_base_y + 10'd8);
    wire in_title_line2 = in_title && (sy >= title_base_y + 10'd8);

    // Robust relative-x: derive both char index and glyph column from ONE value.
    wire [9:0] title_rel_x   = sx - title_base_x;
    wire [4:0] title_chi_line1 = title_rel_x[7:3];
    wire [4:0] title_chi_line2 = title_rel_x[7:3];
    wire [2:0] title_col       = title_rel_x[2:0];

    reg [5:0] title_char1, title_char2;
    always @* begin

        case (title_chi_line1)
            5'd0: title_char1 = 6'd0;
            5'd1: title_char1 = 6'd4;
            5'd2: title_char1 = 6'd17;
            5'd3: title_char1 = 6'd14;
            5'd4: title_char1 = 6'd15;
            5'd5: title_char1 = 6'd11;
            5'd6: title_char1 = 6'd0;
            5'd7: title_char1 = 6'd13;
            5'd8: title_char1 = 6'd4;
            default: title_char1 = 6'd36;
        endcase

        case (title_chi_line2)
            5'd0:  title_char2 = 6'd3;
            5'd1:  title_char2 = 6'd0;
            5'd2:  title_char2 = 6'd13;
            5'd3:  title_char2 = 6'd12;
            5'd4:  title_char2 = 6'd0;
            5'd5:  title_char2 = 6'd10;
            5'd6:  title_char2 = 6'd20;
            5'd7:  title_char2 = 6'd36;
            5'd8:  title_char2 = 6'd18;
            5'd9:  title_char2 = 6'd7;
            5'd10: title_char2 = 6'd14;
            5'd11: title_char2 = 6'd14;
            5'd12: title_char2 = 6'd19;
            5'd13: title_char2 = 6'd8;
            5'd14: title_char2 = 6'd13;
            5'd15: title_char2 = 6'd6;
            default: title_char2 = 6'd36;
        endcase
    end

    wire title_hit1 = in_title_line1 && char_bitmap[3'd7 - title_col];
    wire title_hit2 = in_title_line2 && char_bitmap[3'd7 - title_col];
    wire title_hit = title_hit1 || title_hit2;

    wire [9:0] start_box_x = 10'd264;
    wire [9:0] start_box_y = 10'd184;
    wire start_box = (sx >= start_box_x) && (sx < start_box_x + 10'd112) &&
                     (sy >= start_box_y) && (sy < start_box_y + 10'd24);
    wire start_box_edge = start_box && (
        (sx < start_box_x + 10'd4) || (sx >= start_box_x + 10'd108) ||
        (sy < start_box_y + 10'd4) || (sy >= start_box_y + 10'd20));
    wire start_box_fill = start_box && !start_box_edge;

    wire [9:0] start_text_x = 10'd300;
    wire [9:0] start_text_y = 10'd192;
    wire in_start_text = (game_state == `STATE_MENU) && start_box &&
                         (sx >= start_text_x) && (sx < start_text_x + 10'd40) &&
                         (sy >= start_text_y) && (sy < start_text_y + 10'd8);
    wire [9:0] start_rel_x = sx - start_text_x;
    wire [4:0] start_chi = start_rel_x[5:3];
    wire [2:0] start_col = start_rel_x[2:0];
    reg [5:0] start_char;
    always @* begin
        case (start_chi)
            5'd0: start_char = 6'd18;
            5'd1: start_char = 6'd19;
            5'd2: start_char = 6'd0;
            5'd3: start_char = 6'd17;
            5'd4: start_char = 6'd19;
            default: start_char = 6'd36;
        endcase
    end
    wire start_text_hit = in_start_text && char_bitmap[3'd7 - start_col];

    wire [9:0] diff_base_x = 10'd360;
    wire [9:0] diff_base_y = 10'd304;
    wire in_diff_label = (game_state == `STATE_MENU) &&
                         (sx >= diff_base_x) && (sx < diff_base_x + 10'd88) &&
                         (sy >= diff_base_y) && (sy < diff_base_y + 10'd8);
    wire [9:0] diff_rel_x = sx - diff_base_x;
    wire [4:0] diff_chi = diff_rel_x[6:3];
    wire [2:0] diff_col = diff_rel_x[2:0];

    reg [5:0] diff_char;
    always @* begin
        case (diff_chi)
            5'd0:  diff_char = 6'd3;
            5'd1:  diff_char = 6'd8;
            5'd2:  diff_char = 6'd5;
            5'd3:  diff_char = 6'd5;
            5'd4:  diff_char = 6'd8;
            5'd5:  diff_char = 6'd2;
            5'd6:  diff_char = 6'd20;
            5'd7:  diff_char = 6'd11;
            5'd8:  diff_char = 6'd19;
            5'd9:  diff_char = 6'd24;
            5'd10: diff_char = 6'd37;
            default: diff_char = 6'd36;
        endcase
    end
    wire diff_label_hit = in_diff_label && char_bitmap[3'd7 - diff_col];

    wire [9:0] diff_val_x = 10'd448;
    wire [9:0] diff_val_y = 10'd304;
    wire in_diff_val = (game_state == `STATE_MENU) &&
                       (sx >= diff_val_x) && (sx < diff_val_x + 10'd48) &&
                       (sy >= diff_val_y) && (sy < diff_val_y + 10'd8);
    wire [9:0] diffv_rel_x = sx - diff_val_x;
    wire [4:0] diffv_chi = diffv_rel_x[5:3];
    wire [2:0] diffv_col = diffv_rel_x[2:0];
    reg [5:0] diffv_char;
    always @* begin
        if (difficulty == `DIFF_EASY) begin
            case (diffv_chi)
                5'd0: diffv_char = 6'd4;
                5'd1: diffv_char = 6'd0;
                5'd2: diffv_char = 6'd18;
                5'd3: diffv_char = 6'd24;
                default: diffv_char = 6'd36;
            endcase
        end else if (difficulty == `DIFF_NORMAL) begin
            case (diffv_chi)
                5'd0: diffv_char = 6'd13;
                5'd1: diffv_char = 6'd14;
                5'd2: diffv_char = 6'd17;
                5'd3: diffv_char = 6'd12;
                5'd4: diffv_char = 6'd0;
                5'd5: diffv_char = 6'd11;
                default: diffv_char = 6'd36;
            endcase
        end else if (difficulty == `DIFF_HARD) begin
            case (diffv_chi)
                5'd0: diffv_char = 6'd7;
                5'd1: diffv_char = 6'd0;
                5'd2: diffv_char = 6'd17;
                5'd3: diffv_char = 6'd3;
                default: diffv_char = 6'd36;
            endcase
        end else begin
            case (diffv_chi)
                5'd0: diffv_char = 6'd7;
                5'd1: diffv_char = 6'd4;
                5'd2: diffv_char = 6'd11;
                5'd3: diffv_char = 6'd11;
                default: diffv_char = 6'd36;
            endcase
        end
    end
    wire diff_val_hit = in_diff_val && char_bitmap[3'd7 - diffv_col];

    wire [9:0] mode_base_x = 10'd360;
    wire [9:0] mode_base_y = 10'd320;
    wire in_mode_label = (game_state == `STATE_MENU) &&
                         (sx >= mode_base_x) && (sx < mode_base_x + 10'd40) &&
                         (sy >= mode_base_y) && (sy < mode_base_y + 10'd8);
    wire [9:0] mode_rel_x = sx - mode_base_x;
    wire [4:0] mode_chi = mode_rel_x[5:3];
    wire [2:0] mode_col = mode_rel_x[2:0];
    reg [5:0] mode_char;
    always @* begin
        case (mode_chi)
            5'd0: mode_char = 6'd12;
            5'd1: mode_char = 6'd14;
            5'd2: mode_char = 6'd3;
            5'd3: mode_char = 6'd4;
            5'd4: mode_char = 6'd37;
            default: mode_char = 6'd36;
        endcase
    end
    wire mode_label_hit = in_mode_label && char_bitmap[3'd7 - mode_col];

    wire [9:0] mode_val_x = 10'd400;
    wire [9:0] mode_val_y = 10'd320;
    wire in_mode_val = (game_state == `STATE_MENU) &&
                       (sx >= mode_val_x) && (sx < mode_val_x + 10'd64) &&
                       (sy >= mode_val_y) && (sy < mode_val_y + 10'd8);
    wire [9:0] modev_rel_x = sx - mode_val_x;
    wire [4:0] modev_chi = modev_rel_x[5:3];
    wire [2:0] modev_col = modev_rel_x[2:0];
    reg [5:0] modev_char;
    always @* begin
        if (!mode) begin
            case (modev_chi)
                5'd0: modev_char = 6'd18;
                5'd1: modev_char = 6'd2;
                5'd2: modev_char = 6'd14;
                5'd3: modev_char = 6'd17;
                5'd4: modev_char = 6'd4;
                default: modev_char = 6'd36;
            endcase
        end else begin
            case (modev_chi)
                5'd0: modev_char = 6'd4;
                5'd1: modev_char = 6'd13;
                5'd2: modev_char = 6'd3;
                5'd3: modev_char = 6'd11;
                5'd4: modev_char = 6'd4;
                5'd5: modev_char = 6'd18;
                5'd6: modev_char = 6'd18;
                default: modev_char = 6'd36;
            endcase
        end
    end
    wire mode_val_hit = in_mode_val && char_bitmap[3'd7 - modev_col];

    wire [9:0] hint_base_x = 10'd100;
    wire [9:0] hint_y0 = 10'd360;
    wire [9:0] hint_y1 = 10'd376;
    wire [9:0] hint_y2 = 10'd392;
    wire [9:0] hint_y3 = 10'd408;
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
    wire [9:0] hint_rel_x = sx - hint_base_x;
    wire [5:0] hint_chi = hint_rel_x[8:3];
    wire [2:0] hint_col = hint_rel_x[2:0];
    reg [5:0] hint_char;
    always @* begin
        if (in_hint0) begin

            case (hint_chi)
                6'd0:  hint_char = 6'd22;
                6'd1:  hint_char = 6'd0;
                6'd2:  hint_char = 6'd18;
                6'd3:  hint_char = 6'd3;
                6'd4:  hint_char = 6'd37;
                6'd5:  hint_char = 6'd36;
                6'd6:  hint_char = 6'd12;
                6'd7:  hint_char = 6'd14;
                6'd8:  hint_char = 6'd21;
                6'd9:  hint_char = 6'd4;
                6'd10: hint_char = 6'd36;
                6'd11: hint_char = 6'd36;
                6'd12: hint_char = 6'd9;
                6'd13: hint_char = 6'd40;
                6'd14: hint_char = 6'd5;
                6'd15: hint_char = 6'd8;
                6'd16: hint_char = 6'd17;
                6'd17: hint_char = 6'd4;
                6'd18: hint_char = 6'd36;
                6'd19: hint_char = 6'd36;
                6'd20: hint_char = 6'd10;
                6'd21: hint_char = 6'd37;
                6'd22: hint_char = 6'd36;
                6'd23: hint_char = 6'd20;
                6'd24: hint_char = 6'd15;
                6'd25: hint_char = 6'd6;
                6'd26: hint_char = 6'd17;
                6'd27: hint_char = 6'd0;
                6'd28: hint_char = 6'd3;
                6'd29: hint_char = 6'd4;
                default: hint_char = 6'd36;
            endcase
        end else if (in_hint1) begin

            case (hint_chi)
                6'd0:  hint_char = 6'd15;
                6'd1:  hint_char = 6'd37;
                6'd2:  hint_char = 6'd36;
                6'd3:  hint_char = 6'd15;
                6'd4:  hint_char = 6'd0;
                6'd5:  hint_char = 6'd20;
                6'd6:  hint_char = 6'd18;
                6'd7:  hint_char = 6'd4;
                6'd8:  hint_char = 6'd36;
                6'd9:  hint_char = 6'd36;
                6'd10: hint_char = 6'd12;
                6'd11: hint_char = 6'd37;
                6'd12: hint_char = 6'd36;
                6'd13: hint_char = 6'd12;
                6'd14: hint_char = 6'd14;
                6'd15: hint_char = 6'd3;
                6'd16: hint_char = 6'd4;
                6'd17: hint_char = 6'd36;
                6'd18: hint_char = 6'd36;
                6'd19: hint_char = 6'd19;
                6'd20: hint_char = 6'd0;
                6'd21: hint_char = 6'd1;
                6'd22: hint_char = 6'd37;
                6'd23: hint_char = 6'd36;
                6'd24: hint_char = 6'd3;
                6'd25: hint_char = 6'd8;
                6'd26: hint_char = 6'd18;
                6'd27: hint_char = 6'd15;
                6'd28: hint_char = 6'd11;
                6'd29: hint_char = 6'd0;
                6'd30: hint_char = 6'd24;
                default: hint_char = 6'd36;
            endcase
        end else if (in_hint2) begin

            case (hint_chi)
                6'd0:  hint_char = 6'd27;
                6'd1:  hint_char = 6'd40;
                6'd2:  hint_char = 6'd30;
                6'd3:  hint_char = 6'd37;
                6'd4:  hint_char = 6'd36;
                6'd5:  hint_char = 6'd3;
                6'd6:  hint_char = 6'd8;
                6'd7:  hint_char = 6'd5;
                6'd8:  hint_char = 6'd5;
                6'd9:  hint_char = 6'd8;
                6'd10: hint_char = 6'd2;
                6'd11: hint_char = 6'd20;
                6'd12: hint_char = 6'd11;
                6'd13: hint_char = 6'd19;
                6'd14: hint_char = 6'd24;
                6'd15: hint_char = 6'd36;
                6'd16: hint_char = 6'd36;
                6'd17: hint_char = 6'd4;
                6'd18: hint_char = 6'd13;
                6'd19: hint_char = 6'd19;
                6'd20: hint_char = 6'd4;
                6'd21: hint_char = 6'd17;
                6'd22: hint_char = 6'd37;
                6'd23: hint_char = 6'd36;
                6'd24: hint_char = 6'd18;
                6'd25: hint_char = 6'd19;
                6'd26: hint_char = 6'd0;
                6'd27: hint_char = 6'd17;
                6'd28: hint_char = 6'd19;
                default: hint_char = 6'd36;
            endcase
        end else begin

            case (hint_chi)
                6'd0:  hint_char = 6'd15;
                6'd1:  hint_char = 6'd17;
                6'd2:  hint_char = 6'd4;
                6'd3:  hint_char = 6'd18;
                6'd4:  hint_char = 6'd18;
                6'd5:  hint_char = 6'd36;
                6'd6:  hint_char = 6'd4;
                6'd7:  hint_char = 6'd13;
                6'd8:  hint_char = 6'd19;
                6'd9:  hint_char = 6'd4;
                6'd10: hint_char = 6'd17;
                6'd11: hint_char = 6'd36;
                6'd12: hint_char = 6'd19;
                6'd13: hint_char = 6'd14;
                6'd14: hint_char = 6'd36;
                6'd15: hint_char = 6'd18;
                6'd16: hint_char = 6'd19;
                6'd17: hint_char = 6'd0;
                6'd18: hint_char = 6'd17;
                6'd19: hint_char = 6'd19;
                default: hint_char = 6'd36;
            endcase
        end
    end
    wire hint_hit = (in_hint0 || in_hint1 || in_hint2 || in_hint3) && char_bitmap[3'd7 - hint_col];

    wire menu_active = (game_state == `STATE_MENU);
    wire any_text = title_hit || start_text_hit || diff_label_hit ||
                    diff_val_hit || mode_label_hit || mode_val_hit || hint_hit;

    assign hit = menu_active && (border_edge_h || inner_edge_h || any_text);

    assign color = border_edge_h    ? border_color :
                   inner_edge_h     ? `COL_LTGRAY  :
                   start_text_hit   ? `COL_YELLOW  :
                   start_box_fill   ? `COL_DKGRAY  :
                   diff_val_hit     ? `COL_CYAN    :
                   mode_val_hit     ? `COL_GREEN   :
                   hint_hit         ? `COL_DKGRAY  :
                   `COL_WHITE;

    assign char_code = in_title_line1 ? title_char1  :
                       in_title_line2 ? title_char2  :
                       in_start_text  ? start_char   :
                       in_diff_label  ? diff_char    :
                       in_diff_val    ? diffv_char   :
                       in_mode_label  ? mode_char    :
                       in_mode_val    ? modev_char   :
                       (in_hint0 || in_hint1 || in_hint2 || in_hint3) ? hint_char : 6'd36;
endmodule
