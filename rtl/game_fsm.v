// =============================================================================
//  game_fsm.v
//  Menu/play/pause/result state controller.
// =============================================================================
`include "game_defs.vh"

module game_fsm (
    input  wire          clk,
    input  wire          rstn,
    input  wire          frame_tick,
    input  wire [19:0]   btn_out,
    input  wire [19:0]   btn_pulse,
    input  wire [15:0]   sw,
    input  wire          player_dead,
    input  wire          target_reached,
    input  wire [1:0]    score_mode,
    output reg  [2:0]    state,
    output wire          game_run,
    output wire          entity_update,
    output wire          menu_active,
    output reg  [1:0]    difficulty_sel,
    output wire          cheat,
    output reg           pause_5s_lock
);

    localparam [2:0] ST_MENU     = 3'd0;
    localparam [2:0] ST_PLAY     = 3'd1;
    localparam [2:0] ST_PAUSE    = 3'd2;
    localparam [2:0] ST_GAMEOVER = 3'd3;
    localparam [2:0] ST_WIN      = 3'd4;

    localparam [8:0] LOCK_FRAMES   = 9'd300;
    localparam [8:0] RESUME_FRAMES = 9'd180;
    localparam [8:0] RESULT_FRAMES = 9'd300;

    reg [8:0] lock_cnt;
    reg [8:0] pause_cnt;
    reg [8:0] result_cnt;

    assign game_run = (state == ST_PLAY);
    assign entity_update = game_run;
    assign menu_active = (state == ST_MENU);
    assign cheat = (sw[14:1] == 14'b01010001010110);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= ST_MENU;
            difficulty_sel <= `DIFF_NORMAL;
            pause_5s_lock <= 1'b0;
            lock_cnt <= 9'd0;
            pause_cnt <= 9'd0;
            result_cnt <= 9'd0;
        end else if (frame_tick) begin
            if (pause_5s_lock) begin
                if (lock_cnt >= LOCK_FRAMES - 1) begin
                    lock_cnt <= 9'd0;
                    pause_5s_lock <= 1'b0;
                end else begin
                    lock_cnt <= lock_cnt + 9'd1;
                end
            end

            case (state)
                ST_MENU: begin
                    result_cnt <= 9'd0;
                    pause_cnt <= 9'd0;
                    if (btn_pulse[0]) difficulty_sel <= `DIFF_EASY;
                    if (btn_pulse[1]) difficulty_sel <= `DIFF_NORMAL;
                    if (btn_pulse[2]) difficulty_sel <= `DIFF_HARD;
                    if (btn_pulse[3]) difficulty_sel <= `DIFF_HELL;
                    if (btn_pulse[19]) state <= ST_PLAY;
                end

                ST_PLAY: begin
                    if (player_dead) begin
                        state <= ST_GAMEOVER;
                        result_cnt <= 9'd0;
                    end else if (target_reached && (score_mode[0] == `MODE_SCORE)) begin
                        state <= ST_WIN;
                        result_cnt <= 9'd0;
                    end else if (btn_pulse[0] && !pause_5s_lock) begin
                        state <= ST_PAUSE;
                        pause_cnt <= 9'd0;
                        pause_5s_lock <= 1'b1;
                        lock_cnt <= 9'd0;
                    end
                end

                ST_PAUSE: begin
                    if (btn_pulse[0] && !pause_5s_lock)
                        pause_cnt <= 9'd1;
                    if (pause_cnt != 9'd0) begin
                        if (pause_cnt >= RESUME_FRAMES - 1) begin
                            pause_cnt <= 9'd0;
                            state <= ST_PLAY;
                            pause_5s_lock <= 1'b1;
                            lock_cnt <= 9'd0;
                        end else begin
                            pause_cnt <= pause_cnt + 9'd1;
                        end
                    end
                end

                ST_GAMEOVER, ST_WIN: begin
                    if (result_cnt >= RESULT_FRAMES - 1) begin
                        state <= ST_MENU;
                        result_cnt <= 9'd0;
                    end else begin
                        result_cnt <= result_cnt + 9'd1;
                    end
                end

                default: state <= ST_MENU;
            endcase
        end
    end

endmodule
