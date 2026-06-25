//==============================================================================
// obstacle_render.v — Pure combinational renderer for obstacles (rocks)
// Different shapes based on obstacle type/size
// ZJU VGA rules: combinational only, BGR colors
//==============================================================================
`include "game_defs.vh"

module obstacle_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  ox,         // obstacle center X
    input  wire [8:0]  oy,         // obstacle center Y
    input  wire        active,
    input  wire [1:0]  size,       // 0=small, 1=medium, 2=large
    input  wire [1:0]  shape,      // 0=round, 1=diamond, 2=hexagon, 3=irregular
    output wire        hit,
    output wire [11:0] color
);
    wire signed [10:0] dx = {1'b0, sx} - {1'b0, ox};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, oy};
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    // Size determines radius range
    // Small: 6, Medium: 12, Large: 20
    wire [10:0] r;
    assign r = (size == 2'd0) ? 11'd6  :
               (size == 2'd1) ? 11'd12 :
                                11'd20;

    wire [15:0] adx2 = adx * adx;
    wire [15:0] ady2 = ady * ady;
    wire [15:0] r2   = r * r;
    wire [16:0] dsq  = {1'b0, adx2} + {1'b0, ady2};

    // Different shape predicates
    wire in_circle  = (dsq <= {1'b0, r2});
    wire in_diamond = ((adx + ady) <= r);
    wire in_square  = (adx <= r) && (ady <= r);
    wire in_hex     = (adx <= r) && (ady <= r) && ((adx + {1'b0, ady[10:1]}) <= r);  // rough hex

    // Irregular: combine circle with random dents (using XOR pattern for pseudo-random)
    wire [10:0] dist_irreg = adx + ady;
    wire in_irreg = (dsq <= {1'b0, r2}) && (dist_irreg > 11'd2);  // slightly dented

    wire in_shape = (shape == 2'd0) ? in_circle  :
                    (shape == 2'd1) ? in_diamond :
                    (shape == 2'd2) ? in_hex     : in_irreg;

    // Highlight rim
    wire rim = in_shape && (dsq >= {1'b0, r2} - {2'd0, r});

    // Colors: brown/gray rock tones
    wire [11:0] rock_color  = (size == 2'd0) ? `COL_GRAY    :
                              (size == 2'd1) ? `COL_BROWN   : `COL_DKRED;
    wire [11:0] rim_color   = `COL_LTGRAY;
    wire [11:0] speck_color = `COL_WHITE;

    // Speckle pattern (simple)
    wire speckle = ((sx[3:0] ^ sy[3:0]) == 4'h0) && in_shape;

    assign hit   = active && in_shape;
    assign color = speckle ? speck_color :
                   rim     ? rim_color   : rock_color;
endmodule
