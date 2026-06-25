//==============================================================================
// lfsr_random.v — 16-bit LFSR pseudo-random number generator
// Galois configuration, polynomial: x^16 + x^14 + x^13 + x^11 + 1
//==============================================================================
module lfsr_random (
    input  wire        clk,
    input  wire        rstn,
    input  wire        tick,       // advance LFSR on tick (connect to game tick)
    output wire [15:0] rand        // 16-bit random output
);
    reg [15:0] lfsr;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            lfsr <= 16'hACE1;  // non-zero seed
        end else if (tick) begin
            // Galois LFSR: feedback into selected bits
            lfsr <= {lfsr[14:0], 1'b0} ^ ({16{lfsr[15]}} & 16'hB400);
            // polynomial x^16+x^14+x^13+x^11+1 -> taps at 16,14,13,11
            // feedback mask: bit 15 XOR with bit 14,13,11
        end
    end

    // Additional mixing: combine multiple LFSR bits for better distribution
    assign rand = {lfsr[15:8] ^ lfsr[7:0], lfsr[7:0]};
endmodule
