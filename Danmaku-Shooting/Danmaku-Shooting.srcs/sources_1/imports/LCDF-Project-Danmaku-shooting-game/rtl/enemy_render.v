//==============================================================================
// enemy_render.v — Pure combinational renderer for enemy UFO (ellipse)
// ZJU VGA rules: combinational only, BGR colors
//==============================================================================
`include "game_defs.vh"

module enemy_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  ex,         // enemy center X
    input  wire [8:0]  ey,         // enemy center Y
    input  wire        active,
    input  wire [1:0]  hp,         // 1-3 HP (affects color intensity)
    input  wire        flash,      // hit-flash (turns enemy white briefly)
    output wire        hit,
    output wire [11:0] color
);
    wire signed [10:0] dx = {1'b0, sx} - {1'b0, ex};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, ey};
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    // Main body: ellipse x²/a² + y²/b² <= 1 with a=14, b=10
    // => (adx*10)² + (ady*14)² <= (14*10)² = 19600
    // Use smaller multiplies: adx/14 and ady/10
    // => adx²*100 + ady²*196 <= 19600
    // Approximate: adx²*100 + ady²*200 <= 20000, divide by 100
    // => adx² + 2*ady² <= 200

    wire [21:0] adx2 = adx * adx;
    wire [21:0] ady2 = ady * ady;
    wire [22:0] dist2 = {1'b0, adx2} + {ady2, 1'b0};  // adx² + 2*ady²

    wire in_body = active && (dist2 <= 23'd200);

    // Cockpit dome: small ellipse on top half
    // Ellipse: x²/64 + y²/36 <= 1 => 36*x² + 64*y² <= 2304 => 9*x² + 16*y² <= 576
    wire in_dome_proper = active && (dy < 11'sd0) && (ady <= 11'd6) && (adx <= 11'd8)
                          && (adx2 * 23'd9 + ady2 * 23'd16 <= 23'd576);

    // Rim detail: thin ellipse border
    wire in_rim = active && (dist2 >= 23'd170) && (dist2 <= 23'd200);

    // Eye/window dot
    wire in_eye = active && (dy <= -2) && (dy >= -6) && (adx >= 11'd2) && (adx <= 11'd6);

    // HP determines color: higher HP = brighter / more red
    // HP=3: Magenta (strong), HP=2: Purple (medium), HP=1: Dark Red (weak)
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
