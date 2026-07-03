//==============================================================================
// Keyboard.v — PS/2 keyboard interface for Aeroplane Danmaku Shooting
// Based on reference FPGA-STG-main danmaku keyboard module.
// Key mapping: W=Up A=Left S=Down D=Right  J/Space/Enter=Fire/Start
//              K=WeaponUpgrade  P=Pause  Shift=Slow  1-4=difficulty
//              M=ModeToggle  Tab=CycleDisplay
//==============================================================================
module Keyboard (
    input  wire        clk,
    input  wire        rstn,
    input  wire        ps2_clk,
    input  wire        ps2_data,
    output wire [7:0]  status,       // [0]=Up [1]=Down [2]=Left [3]=Right
                                     // [4]=Fire [5]=Upgrade [6]=Pause [7]=Shift
    output wire [3:0]  diff_key,     // one-hot: diff_key[0]=Easy(1), [1]=Normal(2),
                                     //           [2]=Hard(3), [3]=Hell(4)
    output wire        mode_key,     // M key held = mode toggle
    output wire        cycle_key     // Tab key held = display cycle
);

    reg rdn = 1'b1;
    wire rdy, overflow;
    wire [7:0] data;
    ps2_drive keyboard_drv (
        .clk(clk), .clrn(rstn),
        .ps2_clk(ps2_clk), .ps2_data(ps2_data),
        .rdn(rdn), .data(data), .ready(rdy), .overflow(overflow)
    );

    localparam STATE_RESET      = 3'b000;
    localparam STATE_READ       = 3'b001;
    localparam STATE_BREAK      = 3'b010;
    localparam STATE_EXT        = 3'b011;   // Extended key (E0 prefix)
    localparam STATE_EXT_BREAK  = 3'b100;   // Extended break (E0 F0)

    localparam BREAK_CODE = 8'hF0;
    localparam EXT_CODE   = 8'hE0;

    //--- Normal key scan codes (PS/2 Set 2) ---
    localparam KEY_W     = 8'h1D;
    localparam KEY_A     = 8'h1C;
    localparam KEY_S     = 8'h1B;
    localparam KEY_D     = 8'h23;
    localparam KEY_J     = 8'h3B;
    localparam KEY_K     = 8'h42;
    localparam KEY_P     = 8'h4D;
    localparam KEY_SPACE = 8'h29;
    localparam KEY_ENTER = 8'h5A;
    localparam KEY_SHIFT = 8'h12;
    localparam KEY_1     = 8'h16;
    localparam KEY_2     = 8'h1E;
    localparam KEY_3     = 8'h26;
    localparam KEY_4     = 8'h25;
    localparam KEY_M     = 8'h3A;
    localparam KEY_TAB   = 8'h0D;

    //--- Key status bitmap indices ---
    localparam BIT_UP      = 4'd0;
    localparam BIT_DOWN    = 4'd1;
    localparam BIT_LEFT    = 4'd2;
    localparam BIT_RIGHT   = 4'd3;
    localparam BIT_FIRE    = 4'd4;
    localparam BIT_UPGRADE = 4'd5;
    localparam BIT_PAUSE   = 4'd6;
    localparam BIT_SHIFT   = 4'd7;

    reg [2:0] state;
    reg [7:0] key_pressed;
    reg [3:0] diff_sel;
    reg       mode_pressed;
    reg       cycle_pressed;

    assign status    = key_pressed;
    assign diff_key  = diff_sel;
    assign mode_key  = mode_pressed;
    assign cycle_key = cycle_pressed;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rdn          <= 1'b1;
            state        <= STATE_RESET;
            key_pressed  <= 8'h00;
            diff_sel     <= 4'b0000;
            mode_pressed <= 1'b0;
            cycle_pressed<= 1'b0;
        end else begin
            case (state)
                STATE_RESET: begin
                    rdn   <= 1'b0;
                    state <= STATE_READ;
                    key_pressed <= key_pressed;
                    diff_sel    <= diff_sel;
                end

                STATE_READ: begin
                    if (rdy) begin
                        //--- Process normal key make codes ---
                        case (data)
                            KEY_W:     key_pressed[BIT_UP]      <= 1'b1;
                            KEY_S:     key_pressed[BIT_DOWN]    <= 1'b1;
                            KEY_A:     key_pressed[BIT_LEFT]    <= 1'b1;
                            KEY_D:     key_pressed[BIT_RIGHT]   <= 1'b1;
                            KEY_J, KEY_SPACE, KEY_ENTER:
                                       key_pressed[BIT_FIRE]    <= 1'b1;
                            KEY_K:     key_pressed[BIT_UPGRADE] <= 1'b1;
                            KEY_P:     key_pressed[BIT_PAUSE]   <= 1'b1;
                            KEY_SHIFT: key_pressed[BIT_SHIFT]   <= 1'b1;
                            KEY_1:     diff_sel <= 4'b0001;
                            KEY_2:     diff_sel <= 4'b0010;
                            KEY_3:     diff_sel <= 4'b0100;
                            KEY_4:     diff_sel <= 4'b1000;
                            KEY_M:     mode_pressed  <= 1'b1;
                            KEY_TAB:   cycle_pressed <= 1'b1;
                            default:   begin end
                        endcase
                        //--- State transitions ---
                        case (data)
                            BREAK_CODE: state <= STATE_BREAK;
                            EXT_CODE:   state <= STATE_EXT;
                            default:    state <= state;
                        endcase
                    end else begin
                        rdn         <= rdn;
                        state       <= state;
                        key_pressed <= key_pressed;
                        diff_sel    <= diff_sel;
                    end
                end

                STATE_BREAK: begin
                    if (rdy) begin
                        case (data)
                            KEY_W:     key_pressed[BIT_UP]      <= 1'b0;
                            KEY_S:     key_pressed[BIT_DOWN]    <= 1'b0;
                            KEY_A:     key_pressed[BIT_LEFT]    <= 1'b0;
                            KEY_D:     key_pressed[BIT_RIGHT]   <= 1'b0;
                            KEY_J, KEY_SPACE, KEY_ENTER:
                                       key_pressed[BIT_FIRE]    <= 1'b0;
                            KEY_K:     key_pressed[BIT_UPGRADE] <= 1'b0;
                            KEY_P:     key_pressed[BIT_PAUSE]   <= 1'b0;
                            KEY_SHIFT: key_pressed[BIT_SHIFT]   <= 1'b0;
                            KEY_M:     mode_pressed  <= 1'b0;
                            KEY_TAB:   cycle_pressed <= 1'b0;
                            default:   begin end
                        endcase
                        state <= STATE_READ;
                    end else begin
                        rdn         <= rdn;
                        state       <= state;
                        key_pressed <= key_pressed;
                        diff_sel    <= diff_sel;
                    end
                end

                STATE_EXT: begin
                    if (rdy) begin
                        case (data)
                            BREAK_CODE: state <= STATE_EXT_BREAK;
                            default:    state <= STATE_READ;
                        endcase
                    end else begin
                        rdn         <= rdn;
                        state       <= state;
                        key_pressed <= key_pressed;
                        diff_sel    <= diff_sel;
                    end
                end

                STATE_EXT_BREAK: begin
                    if (rdy) begin
                        state <= STATE_READ;
                    end else begin
                        rdn         <= rdn;
                        state       <= state;
                        key_pressed <= key_pressed;
                        diff_sel    <= diff_sel;
                    end
                end

                default: begin
                    state <= STATE_RESET;
                end
            endcase
        end
    end

endmodule

//==============================================================================
// ps2_drive — PS/2 physical layer receiver with 8-entry FIFO buffer
// Reference: https://nju-projectn.github.io/dlco-lecture-note/exp/07.html
//==============================================================================
module ps2_drive (
    input  wire        clk,
    input  wire        clrn,
    input  wire        ps2_clk,
    input  wire        ps2_data,
    input  wire        rdn,
    output wire [7:0]  data,
    output wire        ready,
    output reg         overflow
);
    reg [3:0] count;
    reg [9:0] buffer;
    reg [7:0] fifo[7:0];
    reg [2:0] w_ptr, r_ptr;
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin
            count    <= 0;
            w_ptr    <= 0;
            r_ptr    <= 0;
            overflow <= 0;
        end else if (sampling) begin
            if (count == 4'd10) begin
                if ((buffer[0] == 0) &&
                    (ps2_data) &&
                    (^buffer[9:1])) begin
                    fifo[w_ptr] <= buffer[8:1];
                    w_ptr       <= w_ptr + 3'b1;
                    overflow    <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;
            end else begin
                buffer[count] <= ps2_data;
                count         <= count + 3'b1;
            end
        end
        if (!rdn && ready) begin
            r_ptr    <= r_ptr + 3'b1;
            overflow <= 0;
        end
    end

    assign ready = (w_ptr != r_ptr);
    assign data  = fifo[r_ptr];
endmodule
