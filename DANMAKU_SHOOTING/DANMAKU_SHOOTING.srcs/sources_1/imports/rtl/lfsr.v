// =============================================================================
//  lfsr.v
//  16-bit Galois LFSR, stepped once per requested tick.
// =============================================================================

module lfsr (
    input  wire        clk,
    input  wire        rstn,
    input  wire        step,
    output wire [15:0] rng
);

    reg [15:0] state;
    wire feedback = state[0];
    wire [15:0] next_state = (state >> 1) ^ (feedback ? 16'hB400 : 16'h0000);

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            state <= 16'hACE1;
        else if (step)
            state <= (next_state == 16'h0000) ? 16'hACE1 : next_state;
    end

    assign rng = state;

endmodule
