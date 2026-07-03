`include "game_defs.vh"

module hud_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,
    input  wire [19:0] score,
    input  wire [7:0]  kills,
    input  wire [2:0]  lives,
    input  wire [1:0]  difficulty,
    input  wire        mode,
    output wire        hit,
    output wire [11:0] color
);

    wire [7:0] char_bitmap;
    ROM_f u_font_rom (
        .a  ({char_code[5:0], sy[2:0]}),
        .spo(char_bitmap)
    );

    wire [5:0] char_code;

    wire [9:0] score_base_x = 10'd400;
    wire [9:0] score_base_y = 10'd456;

    wire [9:0] score_rel_x = sx - score_base_x;
    wire [3:0] score_chi = score_rel_x[6:3];
    wire [2:0] score_col = score_rel_x[2:0];

    wire in_score_box = (game_state == `STATE_PLAYING || game_state == `STATE_PAUSED) &&
                        (sx >= score_base_x) && (sx < score_base_x + 10'd112) &&
                        (sy >= score_base_y) && (sy < score_base_y + 10'd8);

    wire [3:0] sc_digit7 = score[19:16];
    wire [3:0] sc_digit6 = score[15:12];
    wire [3:0] sc_digit5 = score[11:8];
    wire [3:0] sc_digit4 = score[7:4];
    wire [3:0] sc_digit3 = {2'd0, score[3:2]};
    wire [3:0] sc_digit2 = score[3:0];
    wire [3:0] sc_digit1 = 4'd0;
    wire [3:0] sc_digit0 = 4'd0;

    reg [5:0] score_char;
    always @* begin
        case (score_chi)
            4'd0:  score_char = 6'd18;
            4'd1:  score_char = 6'd2;
            4'd2:  score_char = 6'd14;
            4'd3:  score_char = 6'd17;
            4'd4:  score_char = 6'd4;
            4'd5:  score_char = 6'd37;
            4'd6:  score_char = 6'd26 + {1'b0, sc_digit7};
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

    wire [9:0] pause_base_x = 10'd600;
    wire [9:0] pause_base_y = 10'd456;
    wire [9:0] pause_rel_x = sx - pause_base_x;
    wire in_pause_box = (game_state == `STATE_PAUSED) &&
                        (sx >= pause_base_x) && (sx < pause_base_x + 10'd8) &&
                        (sy >= pause_base_y) && (sy < pause_base_y + 10'd8);
    wire [2:0] pause_col = pause_rel_x[2:0];
    wire pause_hit = in_pause_box && char_bitmap[3'd7 - pause_col];

    wire [5:0] pause_char = 6'd39;

    wire [9:0] go1_base_x = 10'd272;
    wire [9:0] go1_base_y = 10'd200;
    wire [9:0] go2_base_x = 10'd272;
    wire [9:0] go2_base_y = 10'd216;

    wire in_go1 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go1_base_x) && (sx < go1_base_x + 10'd32) &&
                  (sy >= go1_base_y) && (sy < go1_base_y + 10'd8);

    wire in_go2 = (game_state == `STATE_GAMEOVER) &&
                  (sx >= go2_base_x) && (sx < go2_base_x + 10'd32) &&
                  (sy >= go2_base_y) && (sy < go2_base_y + 10'd8);

    // Robust: derive char index and glyph column from the SAME relative-x value.
    wire [9:0] go1_rel_x = sx - go1_base_x;
    wire [9:0] go2_rel_x = sx - go2_base_x;
    wire [1:0] go1_chi = go1_rel_x[4:3];
    wire [1:0] go2_chi = go2_rel_x[4:3];
    wire [2:0] go1_col = go1_rel_x[2:0];
    wire [2:0] go2_col = go2_rel_x[2:0];

    reg [5:0] go1_char, go2_char;
    always @* begin
        case (go1_chi)
            2'd0: go1_char = 6'd6;
            2'd1: go1_char = 6'd0;
            2'd2: go1_char = 6'd12;
            2'd3: go1_char = 6'd4;
        endcase
        case (go2_chi)
            2'd0: go2_char = 6'd14;
            2'd1: go2_char = 6'd21;
            2'd2: go2_char = 6'd4;
            2'd3: go2_char = 6'd17;
        endcase
    end

    wire go1_hit = in_go1 && char_bitmap[3'd7 - go1_col];
    wire go2_hit = in_go2 && char_bitmap[3'd7 - go2_col];

    wire go_any = go1_hit || go2_hit;

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

    wire [9:0] yw1_rel_x = sx - yw1_base_x;
    wire [9:0] yw2_rel_x = sx - yw2_base_x;
    wire [1:0] yw1_chi = yw1_rel_x[4:3];
    wire [1:0] yw2_chi = yw2_rel_x[4:3];
    wire [2:0] yw1_col = yw1_rel_x[2:0];
    wire [2:0] yw2_col = yw2_rel_x[2:0];

    reg [5:0] yw1_char, yw2_char;
    always @* begin
        case (yw1_chi)
            2'd0: yw1_char = 6'd24;
            2'd1: yw1_char = 6'd14;
            2'd2: yw1_char = 6'd20;
            default: yw1_char = 6'd36;
        endcase
        case (yw2_chi)
            2'd0: yw2_char = 6'd22;
            2'd1: yw2_char = 6'd8;
            2'd2: yw2_char = 6'd13;
            default: yw2_char = 6'd36;
        endcase
    end

    wire yw1_hit = in_yw1 && char_bitmap[3'd7 - yw1_col];
    wire yw2_hit = in_yw2 && char_bitmap[3'd7 - yw2_col];
    wire yw_any = yw1_hit || yw2_hit;

    wire [9:0] hp_base_x = 10'd8;
    wire [9:0] hp_base_y = 10'd8;
    wire in_hp_box = (game_state == `STATE_PLAYING || game_state == `STATE_PAUSED) &&
                     (sx >= hp_base_x) && (sx < hp_base_x + 10'd32) &&
                     (sy >= hp_base_y) && (sy < hp_base_y + 10'd8);
    wire [9:0] hp_rel_x = sx - hp_base_x;
    wire [1:0] hp_chi = hp_rel_x[4:3];
    wire [2:0] hp_col = hp_rel_x[2:0];

    reg [5:0] hp_char;
    always @* begin
        case (hp_chi)
            2'd0: hp_char = 6'd7;
            2'd1: hp_char = 6'd15;
            2'd2: hp_char = 6'd37;
            2'd3: hp_char = 6'd26 + {2'd0, lives};
        endcase
    end
    wire hp_hit = in_hp_box && char_bitmap[3'd7 - hp_col];

    wire is_hit = score_hit || pause_hit || go_any || yw_any || hp_hit;

    assign hit = is_hit;
    assign color = go_any                  ? `COL_RED    :
                   yw_any                  ? `COL_GREEN  :
                   (pause_hit && !score_hit) ? `COL_YELLOW :
                   `COL_WHITE;

    assign char_code = in_score_box ? score_char :
                       in_pause_box ? (pause_char) :
                       in_go1       ? go1_char   :
                       in_go2       ? go2_char   :
                       in_yw1       ? yw1_char   :
                       in_yw2       ? yw2_char   :
                       in_hp_box    ? hp_char    : 6'd36;
endmodule
