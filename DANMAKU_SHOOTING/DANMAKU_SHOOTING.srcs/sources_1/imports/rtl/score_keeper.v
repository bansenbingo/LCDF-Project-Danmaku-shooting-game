// =============================================================================
//  score_keeper.v
//  计分 / 计时模块
//   - 击杀敌机加分：score += 5 × enemy_hp
//   - 生存计分：每秒（每 60 帧 game_run）+1 分
//   - 统计累计击杀数 kills、累计摧毁障碍物数 obstacles_destroyed
//   - 计时 play_time_sec（用于难度随时间增长）
//   - 积分模式达到目标分（>=500）置 target_reached
//   - 复位（rstn 低 / 回到 MENU / GAMEOVER）由顶层拉低 rstn 清零
// =============================================================================
`include "game_defs.vh"

`define SCORE_TARGET 16'd500

module score_keeper (
    input  wire          clk,
    input  wire          rstn,
    input  wire          frame_tick,
    input  wire          game_run,       // PLAY 状态下为 1

    // --- 击杀 / 摧毁输入 ---
    input  wire          enemy_killed,   // 单帧脉冲
    input  wire [1:0]    enemy_hp,       // 被击杀敌机的 HP，用于 5×HP 加分
    input  wire          obstacle_killed,// 摧毁障碍物脉冲（不加分，仅统计）

    // --- 输出 ---
    output reg  [15:0]   score,          // 当前总分
    output reg  [15:0]   kills,          // 累计击杀数
    output reg  [15:0]   obstacles_destroyed,
    output wire          target_reached, // 积分模式达到目标 (>=500)
    output reg  [31:0]   play_time_sec   // 游戏进行秒数
);

    // ---------- 生存计分 / 计时的秒分频计数 ----------
    reg [5:0] frame_cnt;     // 0..59 计满一秒

    // 每帧加分增量：5 × enemy_hp（HP 范围 1..3）
    wire [15:0] kill_bonus = enemy_killed ? (16'd5 * {14'd0, enemy_hp}) : 16'd0;

    // 满一秒的标志（在 game_run 下每 60 个 frame_tick）
    wire sec_tick = frame_tick & game_run & (frame_cnt == (`ONE_SEC_FRAMES - 1));

    // 目标分达成（仅依据积分，模式判定由上层 game_fsm 结合 score_mode 处理）
    assign target_reached = (score >= `SCORE_TARGET);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            score               <= 16'd0;
            kills               <= 16'd0;
            obstacles_destroyed <= 16'd0;
            play_time_sec       <= 32'd0;
            frame_cnt           <= 6'd0;
        end else begin
            // ---- 秒计数器 ----
            if (frame_tick) begin
                if (game_run) begin
                    if (frame_cnt == (`ONE_SEC_FRAMES - 1))
                        frame_cnt <= 6'd0;
                    else
                        frame_cnt <= frame_cnt + 6'd1;
                end
                // game_run 关闭（暂停）时冻结秒计数，不清零
            end

            // ---- 计时累加 ----
            if (sec_tick)
                play_time_sec <= play_time_sec + 32'd1;

            // ---- 击杀计数 ----
            if (enemy_killed)
                kills <= kills + 16'd1;

            // ---- 障碍物摧毁计数 ----
            if (obstacle_killed)
                obstacles_destroyed <= obstacles_destroyed + 16'd1;

            // ---- 积分累加：击杀加分 + 每秒生存分 ----
            score <= score + kill_bonus + (sec_tick ? 16'd1 : 16'd0);
        end
    end

endmodule
