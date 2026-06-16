// =============================================================================
//  vgac.v
//  ZJU VGA controller for 640x480 @ 60Hz, 12-bit BGR input.
// =============================================================================

module vgac (
    input             vga_clk,
    input             clrn,
    input      [11:0] d_in,

    output reg [8:0]  row_addr,
    output reg [9:0]  col_addr,
    output reg        rdn,
    output reg [3:0]  r,
    output reg [3:0]  g,
    output reg [3:0]  b,
    output reg        hs,
    output reg        vs
);

    reg [9:0] h_count;
    reg [9:0] v_count;

    wire h_visible = (h_count >= 10'd143) && (h_count < 10'd783);
    wire v_visible = (v_count >= 10'd35)  && (v_count < 10'd515);
    wire visible   = h_visible && v_visible;

    always @(posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            h_count  <= 10'd0;
            v_count  <= 10'd0;
            row_addr <= 9'd0;
            col_addr <= 10'd0;
            rdn      <= 1'b1;
            r        <= 4'd0;
            g        <= 4'd0;
            b        <= 4'd0;
            hs       <= 1'b1;
            vs       <= 1'b1;
        end else begin
            if (h_count == 10'd799) begin
                h_count <= 10'd0;
                if (v_count == 10'd524)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end

            hs <= !((h_count >= 10'd0) && (h_count < 10'd96));
            vs <= !((v_count >= 10'd0) && (v_count < 10'd2));

            rdn <= !visible;
            if (visible) begin
                col_addr <= h_count - 10'd143;
                row_addr <= v_count[8:0] - 9'd35;
                r        <= d_in[3:0];
                g        <= d_in[7:4];
                b        <= d_in[11:8];
            end else begin
                col_addr <= 10'd0;
                row_addr <= 9'd0;
                r        <= 4'd0;
                g        <= 4'd0;
                b        <= 4'd0;
            end
        end
    end

endmodule
