//==============================================================================
// ps2_keyboard.v — PS/2 keyboard receiver
// Decodes PS/2 Set 2 scan codes. Outputs make-code byte on key press.
//==============================================================================
module ps2_keyboard (
    input  wire       clk,         // system clock (use clkdiv[8] ~ 390kHz for sampling)
    input  wire       rstn,
    input  wire       ps2_clk,     // PS/2 clock from keyboard (~10-16 kHz)
    input  wire       ps2_data,    // PS/2 data from keyboard
    output reg  [7:0] scan_code,   // last received make code (key press)
    output reg        key_ready    // pulsed high for one cycle on new key press
);
    // Synchronize PS/2 inputs
    reg [2:0] ps2_clk_sync;
    reg [2:0] ps2_data_sync;
    always @(posedge clk) begin
        ps2_clk_sync  <= {ps2_clk_sync[1:0], ps2_clk};
        ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
    end

    wire ps2_clk_fall = ps2_clk_sync[2] && !ps2_clk_sync[1];

    // Shift register: 11 bits (start=0, 8 data LSB first, parity odd, stop=1)
    reg [3:0]  bit_cnt;
    reg [10:0] shift_reg;
    reg        receiving;
    reg        has_extended;  // 0xE0 prefix received
    reg [7:0]  timeout_cnt;   // receive timeout (≈1.3ms at 195kHz)

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt      <= 4'd0;
            shift_reg    <= 11'd0;
            receiving    <= 1'b0;
            has_extended <= 1'b0;
            scan_code    <= 8'd0;
            key_ready    <= 1'b0;
            timeout_cnt  <= 8'd0;
        end else begin
            key_ready <= 1'b0;  // default: pulse only one cycle

            if (ps2_clk_fall) begin
                timeout_cnt <= 8'd0;  // reset timeout on activity
                if (!receiving) begin
                    // Start bit (should be 0)
                    if (ps2_data_sync[1] == 1'b0) begin
                        receiving <= 1'b1;
                        bit_cnt   <= 4'd0;
                        shift_reg <= 11'd0;
                    end
                end else begin
                    shift_reg <= {ps2_data_sync[1], shift_reg[10:1]};
                    if (bit_cnt == 4'd10) begin
                        // Full 11-bit frame received
                        receiving <= 1'b0;
                        // Check start bit (should be 0) and stop bit (should be 1)
                        if (shift_reg[0] == 1'b0 && shift_reg[10] == 1'b1) begin
                            if (shift_reg[9:2] == 8'hE0) begin
                                has_extended <= 1'b1;
                            end else if (shift_reg[9:2] == 8'hF0) begin
                                // Break code prefix: next byte is the released key
                                // Ignore it (we only report make codes)
                            end else begin
                                scan_code <= shift_reg[9:2];
                                key_ready <= 1'b1;
                                has_extended <= 1'b0;
                            end
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 4'd1;
                    end
                end
            end else if (receiving) begin
                // Timeout: if no clock edge after ~1.3ms, abort and reset
                if (timeout_cnt == 8'd255) begin
                    receiving   <= 1'b0;
                    timeout_cnt <= 8'd0;
                end else begin
                    timeout_cnt <= timeout_cnt + 8'd1;
                end
            end
        end
    end
endmodule
