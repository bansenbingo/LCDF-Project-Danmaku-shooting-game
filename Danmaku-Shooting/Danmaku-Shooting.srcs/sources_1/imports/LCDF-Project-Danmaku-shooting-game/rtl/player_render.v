//==============================================================================
// player_render.v — Pure combinational renderer for player aircraft (triangle)
// ZJU VGA rules: combinational only, sx=col_addr, sy=row_addr, BGR colors
//==============================================================================
`include "game_defs.vh"

module player_render (
    input  wire [9:0]  sx,         // col_addr (X coordinate)
    input  wire [9:0]  sy,         // {1'b0, row_addr} (Y coordinate, extended to 10 bits)
    input  wire [9:0]  px,         // player center X
    input  wire [8:0]  py,         // player center Y
    input  wire        alive,      // player is alive
    input  wire        flash,      // invincibility flash (1 = render, 0 = hide)
    output wire        hit,        // this pixel belongs to player
    output wire [11:0] color       // BGR-ordered color
);
    // Triangle pointing UP, centered at (px, py):
    //   Top vertex:  (px,       py - H)
    //   Left vertex: (px - W,   py + H/2)
    //   Right vertex:(px + W,   py + H/2)
    // Base line from left to right vertex.
    // Nose detail: small triangle at top

    wire signed [10:0] dx = {1'b0, sx} - {1'b0, px};
    wire signed [10:0] dy = {1'b0, sy} - {2'b0, py};

    // Unsigned absolute values for geometry tests
    wire [10:0] adx = dx[10] ? (~dx + 1'b1) : dx;
    wire [10:0] ady = dy[10] ? (~dy + 1'b1) : dy;

    // Body triangle: y from -12 (top) to +12 (bottom+half)
    // Left edge:  x >= -16 + (y+12)*16/24 =>  x >= (2y - 24)/3  approx
    // Right edge: x <= +16 - (y+12)*16/24 =>  x <= (24 - 2y)/3  approx
    // Simpler: check if point is within triangle using barycentric / edge tests
    // Left edge:   line from top(0,-12) to bottom-left(-16,+12)
    // Right edge:  line from top(0,-12) to bottom-right(+16,+12)
    // Bottom edge: line from (-16,+12) to (+16,+12)

    wire signed [10:0] hh = 11'd12;  // half height

    wire inside_v = (dy >= -hh) && (dy <= hh);

    // Left edge test: point is to the right of line from (0,-hh) to (-W, +hh)
    // Line equation: x >= (dx_left/dy_left) * (y - y0) + x0
    // Left edge: (-16 - 0) / (12 - (-12)) * (y + 12) + 0 = -16/24 * (y+12) = -(2/3)*(y+12)
    //           approx: -3*(y+12)/4  or more precisely: -(2y+24)/3
    // Use integer math: x*3 >= -2*(y+12)  =>  3*x + 2*y + 24 >= 0
    wire signed [11:0] el = 12'sd3 * dx + {dx[10], dx[10:1]} + 12'sd24; // 3*dx + 2*(dy+12)

    // Hmm let me use a simpler approach: cross products
    // For triangle ABC, point P is inside if it's on same side of all three edges
    // Edge vectors: AB=(B-A), BC=(C-B), CA=(A-C)
    // Cross product sign determines which side of edge
    // A=(0,-12), B=(-16,12), C=(16,12)

    // Edge AB: from A(0,-12) to B(-16,12) — vector (-16, 24)
    // Cross: (px-ax)*(by-ay) - (py-ay)*(bx-ax)
    // = dx * 24 - (dy+12) * (-16) = 24*dx + 16*dy + 192
    wire signed [12:0] e1 = {dx[10], dx, 4'd0} + {dx[10], dx, 4'd0} + {dx[10], dx, 5'd0}  // 24*dx
                           + {dy[10], dy, 5'd0}                                             // 16*dy
                           + 13'sd192;

    // Edge BC: from B(-16,12) to C(16,12) — vector (32, 0)
    // Cross: (px+16)*(0) - (py-12)*(32) = -32*(dy-12) = 32*(12-dy)
    wire signed [12:0] e2 = {5'd0, dy[10] ? (~(12'sd12 - dy) + 1'b1) : (12'sd12 - dy), 5'd0};
    // Simplified: e2 = 32 * (12 - dy)
    wire signed [12:0] e2_s = 13'sd384 - {dy, 6'd0};  // 32*12 - 32*dy

    // Edge CA: from C(16,12) to A(0,-12) — vector (-16, -24)
    // Cross: (px-16)*(-24) - (py-12)*(-16) = -24*dx + 384 + 16*dy - 192
    // = -24*dx + 16*dy + 192
    wire signed [12:0] e3 = {dx[10], 6'd0} + {dx[10], dx, 5'd0}  // 24*dx (negated later)
                           + {dy[10], dy, 5'd0}                   // 16*dy
                           + 13'sd192;
    wire signed [12:0] e3_n = 13'sd192 + {dy[10], dy, 5'd0} - {dx[10], dx, 5'd0} - {dx[10], dx, 4'd0};

    // Actually let me simplify drastically. Just use distance from a line.
    // The body is an isosceles triangle from y=-12 to y=+12
    // At each y, the half-width is: w(y) = 16 * (12+y)/24 for y in [-12, 0] (top half)
    //                                w(y) = 16 * (12-y)/24 for y in [0, 12]  (bottom half)
    // For top half (y <= 0): w = 16*(12+y)/24 = 2*(12+y)/3
    // For bottom half (y > 0): w = 16*(12-y)/24 = 2*(12-y)/3

    // Actually the nose is at y=-12 and base is at y=+12.
    // The half-width goes linearly from 0 at y=-12 to 16 at y=+12:
    //   w(y) = 16 * (y+12) / 24 = 2*(y+12)/3
    // So: adx * 3 <= 2 * (dy+12) when dy in [-12, 12]
    //     3*adx <= 2*dy + 24
    //     3*adx - 2*dy <= 24

    wire [11:0] w_check = adx * 11'd3;  // 3*|dx|
    wire signed [10:0] dy12 = dy + 11'sd12;  // dy + 12
    wire [12:0] w_limit = {dy12[10], dy12, 1'b0};  // 2*(dy+12)

    // Point is inside body triangle
    wire in_body = inside_v && (w_check <= w_limit);

    // Cockpit (small darker triangle inside the top part)
    // Top cockpit: smaller triangle at top
    wire signed [10:0] dy_cockpit = dy + 11'sd12;  // shift dy: 0 at nose, 24 at base
    wire inside_cockpit_v = (dy >= -12) && (dy <= -2);
    wire [11:0] w_cockpit_check = adx * 11'd6;  // 6*|dx|
    wire [11:0] w_cockpit_limit = {1'b0, dy_cockpit, 1'b0}; // 2*(dy+12)
    wire in_cockpit = inside_cockpit_v && (w_cockpit_check <= w_cockpit_limit) && (ady > 11'd1);

    // Wing detail: add small horizontal extensions near base
    wire wing_zone = (dy >= 11'sd5) && (dy <= 11'sd11);
    wire in_wing = wing_zone && (adx >= 11'd14) && (adx <= 11'd18);

    // Engine glow: small bright dots near wing roots
    wire engine_zone = (dy >= 11'sd8) && (dy <= 11'sd11);
    wire in_engine = engine_zone && (adx >= 11'd5) && (adx <= 11'd8);

    wire is_player = alive && flash && (in_body || in_wing);

    // Color selection
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
