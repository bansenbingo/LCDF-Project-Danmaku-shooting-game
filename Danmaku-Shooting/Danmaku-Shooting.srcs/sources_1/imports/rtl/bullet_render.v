//==============================================================================
// bullet_render.v — Pure combinational renderer for bullets (small dots)
// Handles one bullet at a time; instantiated per-bullet or used in a loop
// ZJU VGA rules: combinational only, BGR colors
//==============================================================================
`include "game_defs.vh"

module bullet_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  bx,         // bullet X
    input  wire [8:0]  by,         // bullet Y
    input  wire        active,
    input  wire        is_player,  // 1=player bullet, 0=enemy bullet
    input  wire [1:0]  btype,      // bullet type (affects shape)
    output wire        hit,
    output wire [11:0] color
);
    wire signed [10:0] dx = {1'b0, sx} - {1'b0, bx};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, by};
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    // Small 2x2 diamond for player bullets, 2x2 square for enemy bullets
    wire in_bullet;
    if (1) begin  // always block not allowed in pure combinational, use assign
        // Player: diamond shape (manhattan distance <= 2)
        // Enemy: square shape (max distance <= 1)
    end

    // Diamond shape for player bullets, square for enemy
    wire in_diamond = (adx + ady) <= 11'd3;  // diamond, radius 3
    wire in_square  = (adx <= 11'd2) && (ady <= 11'd2);  // 5x5 square

    // Curved bullets glow slightly larger
    wire in_glow = (adx + ady) <= 11'd4;
    wire is_curved = (btype == `BTYPE_CIRCLE_CW) || (btype == `BTYPE_CIRCLE_CCW);

    assign hit = active && (is_player ? in_diamond : (is_curved ? in_glow : in_square));

    // Player bullets: bright cyan/yellow. Enemy bullets: red/orange.
    wire [11:0] player_bullet_col = is_curved ? `COL_YELLOW : `COL_CYAN;
    wire [11:0] enemy_bullet_col  = is_curved ? `COL_ORANGE : `COL_RED;

    assign color = is_player ? player_bullet_col : enemy_bullet_col;
endmodule
