// =============================================================================
//  btn_debounce.v
//  Multi-button synchronizer and 20ms debounce filter for 100MHz clock.
// =============================================================================

module btn_debounce #(
    parameter N = 20,
    parameter COUNT_MAX = 2000000
) (
    input  wire         clk,
    input  wire         rstn,
    input  wire [N-1:0] btn_in,
    output wire [N-1:0] btn_out,
    output wire [N-1:0] btn_pulse
);

    reg [N-1:0] sync0;
    reg [N-1:0] sync1;
    reg [N-1:0] stable;
    reg [N-1:0] stable_d;
    reg [20:0]  cnt [0:N-1];

    integer i;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sync0    <= {N{1'b0}};
            sync1    <= {N{1'b0}};
            stable   <= {N{1'b0}};
            stable_d <= {N{1'b0}};
            for (i = 0; i < N; i = i + 1)
                cnt[i] <= 21'd0;
        end else begin
            sync0    <= btn_in;
            sync1    <= sync0;
            stable_d <= stable;

            for (i = 0; i < N; i = i + 1) begin
                if (sync1[i] == stable[i]) begin
                    cnt[i] <= 21'd0;
                end else if (cnt[i] >= COUNT_MAX - 1) begin
                    stable[i] <= sync1[i];
                    cnt[i]    <= 21'd0;
                end else begin
                    cnt[i] <= cnt[i] + 21'd1;
                end
            end
        end
    end

    assign btn_out   = stable;
    assign btn_pulse = stable & ~stable_d;

endmodule
