// =============================================================================
//  enemy.v
//  敌方外星飞碟实例（单个；多个时由 enemy_pool 例化数组）
//   - 外形：扁椭圆机身 + 顶部半圆穹顶
//   - HP：随难度 1..3
//   - 移动：从顶部下落；HARD/HELL 时主动左右摆动 (sin 近似 = 三角波)
//   - 攻击：每个发射周期发射 1..N 颗子弹，可直线 / 圆 / 抛物线
//          本模块只输出"发射请求 fire_req"+"轨迹参数"，
//          实际子弹生命周期由 bullet_pool 管理
// =============================================================================
`include "game_defs.vh"

module enemy #(
    parameter EID = 0                  // 实例编号，用于扰动随机
) (
    input  wire                       clk,
    input  wire                       rstn,
    input  wire                       frame_tick,
    input  wire                       game_run,

    // 难度 / 全局节拍
    input  wire [1:0]                 difficulty,
    input  wire [15:0]                rng,        // 顶层 LFSR 提供的伪随机数

    // 生成 / 销毁控制
    input  wire                       spawn,      // 单帧脉冲：在 spawn_x/spawn_y 处出生
    input  wire [`X_BITS-1:0]         spawn_x,
    input  wire [`Y_BITS-1:0]         spawn_y,
    input  wire                       hit_by_pbullet, // 被玩家子弹击中（单帧）

    // 状态输出
    output reg                        active,     // 实例存活
    output reg  [`X_BITS-1:0]         ex,
    output reg  [`Y_BITS-1:0]         ey,
    output reg  [1:0]                 hp,
    output wire                       killed,     // 本帧被击毁（用于加分/计数）

    // 发射请求（送给子弹池）
    output reg                        fire_req,
    output reg  [1:0]                 fire_traj,    // TRAJ_LINE / CIRC / PARA
    output reg  [2:0]                 fire_count,   // 单次发射颗数 1..5
    output reg                        fire_dual,    // 是否双条弹幕（左右对称）
    output reg  [`X_BITS-1:0]         fire_x,
    output reg  [`Y_BITS-1:0]         fire_y
);

    // ---------- 难度参数 ----------
    function [1:0] init_hp(input [1:0] d);
        case (d)
            `DIFF_EASY  : init_hp = 2'd1;
            `DIFF_NORMAL: init_hp = 2'd1;
            `DIFF_HARD  : init_hp = 2'd2;
            `DIFF_HELL  : init_hp = 2'd3;
            default     : init_hp = 2'd1;
        endcase
    endfunction

    function [6:0] fire_period(input [1:0] d);
        // 帧间隔：越难越短
        case (d)
            `DIFF_EASY  : fire_period = 7'd90; // 1.5s
            `DIFF_NORMAL: fire_period = 7'd70;
            `DIFF_HARD  : fire_period = 7'd50;
            `DIFF_HELL  : fire_period = 7'd35;
            default     : fire_period = 7'd60;
        endcase
    endfunction

    function [2:0] shot_count(input [1:0] d, input [3:0] r);
        // 难度越高单次颗数上限越大，1..5
        case (d)
            `DIFF_EASY  : shot_count = 3'd1;
            `DIFF_NORMAL: shot_count = (r[0]) ? 3'd2 : 3'd1;
            `DIFF_HARD  : shot_count = 3'd2 + r[0];          // 2..3
            `DIFF_HELL  : shot_count = 3'd3 + r[1:0];        // 3..6 (限到 5)
            default     : shot_count = 3'd1;
        endcase
    endfunction

    function [1:0] choose_traj(input [1:0] d, input [1:0] r);
        // EASY/NORMAL：仅直线；HARD：直线/圆；HELL：全部
        case (d)
            `DIFF_EASY  : choose_traj = `TRAJ_LINE;
            `DIFF_NORMAL: choose_traj = `TRAJ_LINE;
            `DIFF_HARD  : choose_traj = (r[0]) ? `TRAJ_CIRC : `TRAJ_LINE;
            `DIFF_HELL  : choose_traj = r;                   // 0..3，3 当作 LINE
            default     : choose_traj = `TRAJ_LINE;
        endcase
    endfunction

    // ---------- 内部状态 ----------
    reg [6:0] fire_cnt;          // 发射倒计时
    reg       sway_dir;          // 左右摆动方向：0 左 / 1 右
    reg [5:0] sway_cnt;          // 每 32 帧换向一次（约 0.5s）

    wire sway_enable = (difficulty == `DIFF_HARD) || (difficulty == `DIFF_HELL);
    wire [1:0] hp_init = init_hp(difficulty);

    // ---------- 主时序 ----------
    assign killed = hit_by_pbullet && active && (hp == 2'd1);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            active     <= 1'b0;
            ex         <= 0;
            ey         <= 0;
            hp         <= 0;
            fire_cnt   <= 0;
            sway_dir   <= EID[0];
            sway_cnt   <= 0;
            fire_req   <= 1'b0;
            fire_traj  <= 2'd0;
            fire_count <= 3'd0;
            fire_dual  <= 1'b0;
            fire_x     <= 0;
            fire_y     <= 0;
        end else begin
            // 默认每周期清空发射请求
            fire_req <= 1'b0;

            // ---- 出生 ----
            if (spawn && !active) begin
                active   <= 1'b1;
                ex       <= spawn_x;
                ey       <= spawn_y;
                hp       <= hp_init;
                fire_cnt <= fire_period(difficulty) - 7'd10; // 出生后稍延迟开火
                sway_cnt <= 0;
                sway_dir <= rng[0];
            end

            // ---- 帧推进 ----
            if (active && frame_tick && game_run) begin
                // 受击
                if (hit_by_pbullet) begin
                    if (hp <= 2'd1) begin
                        active <= 1'b0;     // 被击毁
                        hp     <= 2'd0;
                    end else begin
                        hp <= hp - 1'b1;
                    end
                end

                // 移动：每帧固定下移 1 像素
                if (ey + (`ENEMY_H/2) < `SCREEN_H) ey <= ey + 1;
                else                              active <= 1'b0;   // 飞出屏幕

                // 难度 >= HARD 主动左右摆动
                if (sway_enable) begin
                    sway_cnt <= sway_cnt + 1;
                    if (sway_cnt == 6'd31) begin
                        sway_cnt <= 0;
                        sway_dir <= ~sway_dir;
                    end
                    if (sway_dir) begin
                        if (ex + `ENEMY_W/2 + 1 < `SCREEN_W) ex <= ex + 1;
                        else                                  sway_dir <= 1'b0;
                    end else begin
                        if (ex > `ENEMY_W/2 + 1) ex <= ex - 1;
                        else                      sway_dir <= 1'b1;
                    end
                end

                // 发射调度
                if (fire_cnt != 7'd0) begin
                    fire_cnt <= fire_cnt - 1'b1;
                end else begin
                    fire_cnt   <= fire_period(difficulty);
                    fire_req   <= 1'b1;
                    fire_traj  <= choose_traj(difficulty, rng[3:2]);
                    fire_count <= shot_count(difficulty, rng[7:4]);
                    // HARD/HELL 偶发双条弹幕
                    fire_dual  <= sway_enable && rng[8];
                    fire_x     <= ex;
                    fire_y     <= ey + `ENEMY_H/2;
                end
            end
        end
    end

endmodule


// =============================================================================
//  enemy_render
//  椭圆机身（高 H、宽 W） + 顶部半圆穹顶
//  椭圆判定: (dx*H)^2 + (dy*W)^2 <= (W*H/2)^2 等价为 dx^2/(W/2)^2 + dy^2/(H/2)^2 <= 1
//  这里使用乘法整数比较，对 K7 资源足够
// =============================================================================
module enemy_render (
    input  wire [`X_BITS-1:0] sx,
    input  wire [`Y_BITS-1:0] sy,
    input  wire [`X_BITS-1:0] ex,
    input  wire [`Y_BITS-1:0] ey,
    input  wire               active,
    output wire               hit,
    output wire [11:0]        color
);
    wire signed [`X_BITS:0] dx_s = $signed({1'b0, sx}) - $signed({1'b0, ex});
    wire signed [`Y_BITS:0] dy_s = $signed({1'b0, sy}) - $signed({1'b0, ey});
    // 取无符号绝对值，扩展到 16 位足够覆盖 (dx*dx 最大约 640^2 = 409600，需 19 bit)
    wire [15:0] adx = (dx_s < 0) ? -dx_s : dx_s;
    wire [15:0] ady = (dy_s < 0) ? -dy_s : dy_s;

    // 椭圆: dx^2 * B^2 + dy^2 * A^2 <= A^2 * B^2
    localparam integer A = `ENEMY_W/2;   // 20
    localparam integer B = `ENEMY_H/2;   // 10
    wire [31:0] lhs = adx*adx*B*B + ady*ady*A*A;
    wire [31:0] rhs = A*A*B*B;
    wire in_body = (lhs <= rhs);

    // 顶部穹顶: 以 (ex, ey - B/2) 为中心、半径 B 的圆，且 dy <= 0
    wire signed [`Y_BITS+1:0] dy_d = dy_s + (B>>1);
    wire [15:0] ady_d = (dy_d < 0) ? -dy_d : dy_d;
    wire [31:0] dome_lhs = adx*adx + ady_d*ady_d;
    wire in_dome = (dy_s <= 0) && (dome_lhs <= (B*B));

    assign hit   = active && (in_body || in_dome);
    assign color = in_dome ? `COL_ENEMY_DOME : `COL_ENEMY_BODY;
endmodule
