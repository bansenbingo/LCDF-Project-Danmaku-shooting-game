//==============================================================================
// ps2_keyboard.v — PS/2 keyboard receiver
// Decodes PS/2 Set 2 scan codes. Emits both make and break events.
// For break events scan_code[7] is set and scan_code[6:0] contains the key code.
//==============================================================================
module ps2_keyboard (
    input  wire       clk,
    input  wire       rstn,
    input  wire       ps2_clk,
    input  wire       ps2_data,
    output reg  [7:0] scan_code,
    output reg        key_ready
);
    reg [2:0] ps2_clk_sync;
    reg [2:0] ps2_data_sync;
    always @(posedge clk) begin
        ps2_clk_sync  <= {ps2_clk_sync[1:0], ps2_clk};
        ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
    end

    wire ps2_clk_fall = ps2_clk_sync[2] && !ps2_clk_sync[1];
    wire ps2_bit      = ps2_data_sync[1];

    reg [3:0] bit_cnt;
    reg [7:0] data_byte;
    reg       parity_bit;
    reg       receiving;
    reg       break_pending;
    reg       ext_pending;
    reg [7:0] timeout_cnt;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt       <= 4'd0;
            data_byte     <= 8'd0;
            parity_bit    <= 1'b0;
            receiving     <= 1'b0;
            break_pending <= 1'b0;
            ext_pending   <= 1'b0;
            timeout_cnt   <= 8'd0;
            scan_code     <= 8'd0;
            key_ready     <= 1'b0;
        end else begin
            key_ready <= 1'b0;

            if (ps2_clk_fall) begin
                timeout_cnt <= 8'd0;

                if (!receiving) begin
                    // Start bit is always 0. Data bits begin on the next falling edge.
                    if (ps2_bit == 1'b0) begin
                        receiving <= 1'b1;
                        bit_cnt   <= 4'd0;
                    end
                end else begin
                    if (bit_cnt < 4'd8) begin
                        data_byte[bit_cnt] <= ps2_bit;
                        bit_cnt <= bit_cnt + 4'd1;
                    end else if (bit_cnt == 4'd8) begin
                        parity_bit <= ps2_bit;
                        bit_cnt <= 4'd9;
                    end else begin
                        // Stop bit. PS/2 uses odd parity across data+parity.
                        receiving <= 1'b0;
                        bit_cnt <= 4'd0;
                        if (ps2_bit == 1'b1 && ((^data_byte) ^ parity_bit) == 1'b1) begin
                            if (data_byte == 8'hE0) begin
                                ext_pending <= 1'b1;
                            end else if (data_byte == 8'hF0) begin
                                break_pending <= 1'b1;
                            end else begin
                                // Used keys are all below 0x80. Mark release by setting bit 7.
                                scan_code <= break_pending ? {1'b1, data_byte[6:0]} : data_byte;
                                key_ready <= 1'b1;
                                break_pending <= 1'b0;
                                ext_pending   <= 1'b0;
                            end
                        end else begin
                            break_pending <= 1'b0;
                            ext_pending   <= 1'b0;
                        end
                    end
                end
            end else if (receiving) begin
                if (timeout_cnt == 8'd255) begin
                    receiving <= 1'b0;
                    bit_cnt <= 4'd0;
                    timeout_cnt <= 8'd0;
                    break_pending <= 1'b0;
                    ext_pending <= 1'b0;
                end else begin
                    timeout_cnt <= timeout_cnt + 8'd1;
                end
            end
        end
    end
endmodule
