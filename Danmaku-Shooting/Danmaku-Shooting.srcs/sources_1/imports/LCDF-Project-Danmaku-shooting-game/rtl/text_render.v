//==============================================================================
// text_render.v — Pure combinational character ROM and text renderer
// 8x8 font, BGR color. Used by HUD and menu renderers.
// ZJU VGA rules: combinational only
//==============================================================================
`include "game_defs.vh"

module text_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [9:0]  tx,         // text block base X
    input  wire [9:0]  ty,         // text block base Y
    input  wire [5:0]  char_code,  // character to render (A-Z=0-25, 0-9=26-35, space=36, :=37, /=38, |=39, -=40, >=41, .=42, !=43)
    input  wire        enable,     // text module enable
    output wire        hit,
    output wire [11:0] color
);
    // Character position within 8x8 grid
    wire [2:0] cx = sx[2:0] - tx[2:0];  // column within char (0-7)
    wire [2:0] cy = sy[2:0] - ty[2:0];  // row within char (0-7)

    // Check if (sx, sy) is within this character's 8x8 bounding box
    wire in_char_box = enable &&
                       (sx >= tx) && (sx < tx + 10'd8) &&
                       (sy >= ty) && (sy < ty + 10'd8);

    // Character ROM: 8 rows × 8 bits per character
    // Font data stored as 8 bytes per character. Bit 7 = leftmost pixel.
    // Font ROM IP (Distributed Memory Generator, 512x8, 9-bit addr)
    wire [7:0] char_row;
    font_rom u_font (.a({char_code, cy}), .spo(char_row));

    // Pixel within character
    wire pixel_on = in_char_box && char_row[3'd7 - cx];

    assign hit   = pixel_on;
    assign color = `COL_WHITE;  // color is set by parent module via priority MUX
endmodule
