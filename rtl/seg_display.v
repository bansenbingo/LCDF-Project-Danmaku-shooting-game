// =============================================================================
//  seg_display.v
//  Four-digit seven-segment display wrapper.
// =============================================================================

module seg_display (
    input  wire          clk,
    input  wire          rstn,
    input  wire [15:0]   score,
    input  wire [15:0]   kills,
    input  wire [3:0]    lives,
    input  wire [2:0]    game_state,
    input  wire [19:0]   btn_pulse,
    output wire [7:0]    SEGMENT,
    output wire [3:0]    AN,
    output wire [7:0]    LED
);

    reg [1:0] mode;
    reg [15:0] scan_div;
    wire [1:0] scan = scan_div[15:14];
    reg [15:0] value;
    reg [7:0] led_r;
    reg special;
    reg [7:0] special_seg;

    wire [3:0] disp_an;
    wire [7:0] disp_segment;

    DispNum u_dispnum (
        .scan(scan),
        .HEXS(value),
        .point(4'b0000),
        .LES(4'b0000),
        .AN(disp_an),
        .SEGMENT(disp_segment)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mode <= 2'd0;
            scan_div <= 16'd0;
        end else begin
            scan_div <= scan_div + 16'd1;
            if (btn_pulse[7])
                mode <= (mode == 2'd2) ? 2'd0 : mode + 2'd1;
        end
    end

    always @* begin
        case (mode)
            2'd0: value = kills;
            2'd1: value = {12'd0, lives};
            default: value = score;
        endcase

        led_r = value[15:8];
        special = (game_state != 3'd1) && (game_state != 3'd2);
        case (game_state)
            3'd0: special_seg = 8'b10111111;
            3'd3: begin
                case (scan)
                    2'd0: special_seg = 8'b11000000; // O/0
                    2'd1: special_seg = 8'b11000001; // V-like U
                    2'd2: special_seg = 8'b10000110; // E
                    default: special_seg = 8'b10001110; // r-like F
                endcase
            end
            3'd4: begin
                case (scan)
                    2'd0: special_seg = 8'b11111111;
                    2'd1: special_seg = 8'b11000001; // W-like U
                    2'd2: special_seg = 8'b11111001; // I/1
                    default: special_seg = 8'b11001000; // n-like
                endcase
            end
            default: special_seg = disp_segment;
        endcase
    end

    assign AN = disp_an;
    assign SEGMENT = special ? special_seg : disp_segment;
    assign LED = led_r;

endmodule
