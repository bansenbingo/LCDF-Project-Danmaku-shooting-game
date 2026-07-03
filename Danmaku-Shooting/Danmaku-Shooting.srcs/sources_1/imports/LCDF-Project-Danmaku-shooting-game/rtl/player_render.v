`include "game_defs.vh"

module player_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  px,
    input  wire [8:0]  py,
    input  wire        alive,
    input  wire        flash,
    output wire        hit,
    output wire [11:0] color
);

    wire signed [10:0] dx = {1'b0, sx} - {1'b0, px};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, py};

    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    wire signed [10:0] hh = 11'd12;

    wire inside_v = (dy >= -hh) && (dy <= hh);

    wire signed [11:0] el = 12'sd3 * dx + {dx[10], dx[10:1]} + 12'sd24;

    wire signed [12:0] e1 = {dx[10], dx, 4'd0} + {dx[10], dx, 4'd0} + {dx[10], dx, 5'd0}
                           + {dy[10], dy, 5'd0}
                           + 13'sd192;

    wire signed [12:0] e2 = {5'd0, dy[10] ? (~(12'sd12 - dy) + 1'b1) : (12'sd12 - dy), 5'd0};

    wire signed [12:0] e2_s = 13'sd384 - {dy, 6'd0};

    wire signed [12:0] e3 = {dx[10], 6'd0} + {dx[10], dx, 5'd0}
                           + {dy[10], dy, 5'd0}
                           + 13'sd192;
    wire signed [12:0] e3_n = 13'sd192 + {dy[10], dy, 5'd0} - {dx[10], dx, 5'd0} - {dx[10], dx, 4'd0};

    wire [11:0] w_check = adx * 11'd3;
    wire signed [10:0] dy12 = dy + 11'sd12;
    wire [12:0] w_limit = {dy12[10], dy12, 1'b0};

    wire in_body = inside_v && (w_check <= w_limit);

    wire signed [10:0] dy_cockpit = dy + 11'sd12;
    wire inside_cockpit_v = (dy >= -12) && (dy <= -2);
    wire [11:0] w_cockpit_check = adx * 11'd6;
    wire [11:0] w_cockpit_limit = {1'b0, dy_cockpit, 1'b0};
    wire in_cockpit = inside_cockpit_v && (w_cockpit_check <= w_cockpit_limit) && (ady > 11'd1);

    wire wing_zone = (dy >= 11'sd5) && (dy <= 11'sd11);
    wire in_wing = wing_zone && (adx >= 11'd14) && (adx <= 11'd18);

    wire engine_zone = (dy >= 11'sd8) && (dy <= 11'sd11);
    wire in_engine = engine_zone && (adx >= 11'd5) && (adx <= 11'd8);

    wire is_player = alive && flash && (in_body || in_wing);

    wire [11:0] body_color = `COL_CYAN;
    wire [11:0] cockpit_color = `COL_DKBLUE;
    wire [11:0] wing_color = `COL_WHITE;
    wire [11:0] engine_color = `COL_ORANGE;

    assign hit   = is_player;
    assign color = in_engine    ? engine_color  :
                   in_cockpit   ? cockpit_color :
                   in_wing      ? wing_color    :
                   body_color;
endmodule
