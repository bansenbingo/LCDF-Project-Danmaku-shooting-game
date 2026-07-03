`include "game_defs.vh"

module bullet_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  bx,
    input  wire [8:0]  by,
    input  wire        active,
    input  wire        is_player,
    input  wire [1:0]  btype,
    output wire        hit,
    output wire [11:0] color
);
    wire signed [10:0] dx = {1'b0, sx} - {1'b0, bx};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, by};
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    wire in_diamond = (adx + ady) <= 11'd2;
    wire in_square  = (adx <= 11'd1) && (ady <= 11'd1);

    assign hit = active && (is_player ? in_diamond : in_square);

    wire [11:0] player_bullet_col = `COL_CYAN;
    wire [11:0] enemy_bullet_col  = `COL_RED;

    assign color = is_player ? player_bullet_col : enemy_bullet_col;
endmodule
