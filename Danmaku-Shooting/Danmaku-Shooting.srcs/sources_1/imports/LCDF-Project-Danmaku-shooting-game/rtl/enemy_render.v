`include "game_defs.vh"

module enemy_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  ex,
    input  wire [8:0]  ey,
    input  wire        active,
    input  wire [1:0]  hp,
    input  wire        flash,
    output wire        hit,
    output wire [11:0] color
);
    wire signed [10:0] dx = {1'b0, sx} - {1'b0, ex};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, ey};
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    wire [21:0] adx2 = adx * adx;
    wire [21:0] ady2 = ady * ady;
    wire [22:0] dist2 = {1'b0, adx2} + {ady2, 1'b0};

    wire in_body = active && (dist2 <= 23'd200);

    // All detail features are strictly gated by in_body so that no pixel outside
    // the solid ellipse can ever be lit. This removes the stray "ghost" specks
    // that appeared when a dome/eye/rim condition was true just outside the body.
    wire in_dome_proper = in_body && (dy < 11'sd0) && (ady <= 11'd6) && (adx <= 11'd8)
                          && (adx2 * 23'd9 + ady2 * 23'd16 <= 23'd576);

    wire in_rim = in_body && (dist2 >= 23'd170) && (dist2 <= 23'd200);

    wire in_eye = in_body && (dy <= -11'sd2) && (dy >= -11'sd6)
                          && (adx >= 11'd2) && (adx <= 11'd6);

    wire [11:0] body_col = (hp == 2'd3) ? `COL_MAGENTA :
                           (hp == 2'd2) ? `COL_PURPLE  : `COL_DKRED;
    wire [11:0] dome_col = (hp == 2'd3) ? `COL_WHITE  :
                           (hp == 2'd2) ? `COL_LTGRAY : `COL_GRAY;
    wire [11:0] rim_col  = (hp == 2'd3) ? `COL_YELLOW :
                           (hp == 2'd2) ? `COL_CYAN   : `COL_DKGREEN;
    wire [11:0] eye_col  = `COL_YELLOW;

    assign hit = in_body;
    assign color = flash       ? `COL_WHITE  :
                   in_eye         ? eye_col  :
                   in_dome_proper ? dome_col :
                   in_rim         ? rim_col  :
                   body_col;
endmodule
