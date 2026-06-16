// =============================================================================
//  obstacle.v
//  中立障碍物：石头实例
//   - 三种尺寸 S/M/L (HP=1/2/3，撞击伤害=1/2/坠毁)
//   - 高难度才会出现 M / L
//   - 子弹命中扣 HP，HP=0 摧毁；与玩家碰撞无论尺寸都消失
//   - 障碍物与敌方/敌弹无交互
//   - 形状：用 4 边围成的多边形（"近圆但带尖角"，看起来像石头）
// =============================================================================
`include "game_defs.vh"

module obstacle #(
    parameter OID = 0
) (
    input  wire                       clk,
    input  wire                       rstn,
    input  wire                       frame_tick,
    input  wire                       game_run,

    input  wire [1:0]                 difficulty,
    input  wire [15:0]                rng,

    // 出生
    input  wire                       spawn,
    input  wire [`X_BITS-1:0]         spawn_x,

    // 命中信号（来自碰撞模块，单帧脉冲）
    input  wire                       hit_pbullet,   // 玩家子弹命中
    input  wire                       hit_player,    // 撞到玩家

    // 状态
    output reg                        active,
    output reg  [1:0]                 size,          // OBS_S / M / L
    output reg  [`X_BITS-1:0]         ox,
    output reg  [`Y_BITS-1:0]         oy,
    output reg  [1:0]                 hp,            // 摧毁所需子弹数
    output wire [`X_BITS-1:0]         radius,        // 碰撞半径
    output wire                       destroyed_pulse, // 本帧因子弹被摧毁（用于音效/特效，但不计分）
    output wire [1:0]                 player_damage    // 与玩家碰撞应造成的伤害编码
);

    // ---------- 难度->尺寸抽签 ----------
    // EASY:   只 S
    // NORMAL: S(70%) M(30%)
    // HARD:   S(40%) M(40%) L(20%)
    // HELL:   S(20%) M(40%) L(40%)
    function [1:0] roll_size(input [1:0] d, input [3:0] r);
        case (d)
            `DIFF_EASY  : roll_size = `OBS_S;
            `DIFF_NORMAL: roll_size = (r < 4'd11) ? `OBS_S : `OBS_M;
            `DIFF_HARD  : roll_size = (r < 4'd6)  ? `OBS_S :
                                       (r < 4'd12) ? `OBS_M : `OBS_L;
            `DIFF_HELL  : roll_size = (r < 4'd3)  ? `OBS_S :
                                       (r < 4'd9)  ? `OBS_M : `OBS_L;
            default     : roll_size = `OBS_S;
        endcase
    endfunction

    function [`X_BITS-1:0] size_radius(input [1:0] s);
        case (s)
            `OBS_S : size_radius = `OBS_S_R;
            `OBS_M : size_radius = `OBS_M_R;
            `OBS_L : size_radius = `OBS_L_R;
            default: size_radius = `OBS_S_R;
        endcase
    endfunction

    function [1:0] size_hp(input [1:0] s);
        case (s)
            `OBS_S : size_hp = 2'd1;
            `OBS_M : size_hp = 2'd2;
            `OBS_L : size_hp = 2'd3;
            default: size_hp = 2'd1;
        endcase
    endfunction

    // 与玩家碰撞造成的伤害：S->-1 ; M->-2 ; L->-坠毁(2'b11)
    function [1:0] size_dmg(input [1:0] s);
        case (s)
            `OBS_S : size_dmg = 2'b01;
            `OBS_M : size_dmg = 2'b10;
            `OBS_L : size_dmg = 2'b11;
            default: size_dmg = 2'b01;
        endcase
    endfunction

    assign radius = size_radius(size);
    assign player_damage = size_dmg(size);
    reg destroyed_r;
    assign destroyed_pulse = destroyed_r;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            active      <= 1'b0;
            size        <= `OBS_NONE;
            ox          <= 0;
            oy          <= 0;
            hp          <= 0;
            destroyed_r <= 1'b0;
        end else begin
            destroyed_r <= 1'b0;

            // ---- 出生 ----
            if (spawn && !active) begin
                active <= 1'b1;
                size   <= roll_size(difficulty, rng[3:0]);
                hp     <= size_hp(roll_size(difficulty, rng[3:0]));
                ox     <= spawn_x;
                oy     <= 0;
            end

            // ---- 帧推进 ----
            if (active && frame_tick && game_run) begin
                // 下落
                if (oy + radius < `SCREEN_H) begin
                    oy <= oy + `OBS_FALL_SPEED;
                end else begin
                    active <= 1'b0;     // 飞出屏幕
                    size   <= `OBS_NONE;
                end

                // 玩家子弹命中
                if (hit_pbullet) begin
                    if (hp <= 2'd1) begin
                        active      <= 1'b0;
                        size        <= `OBS_NONE;
                        destroyed_r <= 1'b1;
                    end else begin
                        hp <= hp - 1'b1;
                    end
                end

                // 与玩家碰撞：障碍物总是消失（伤害交给 player.v）
                if (hit_player) begin
                    active <= 1'b0;
                    size   <= `OBS_NONE;
                end
            end
        end
    end

endmodule


// =============================================================================
//  obstacle_render
//  以中心 (ox,oy) 半径 radius 的"近圆"。为体现"石头"的不规则感，
//  用 |dx|+|dy| <= 1.4*r （约等于 7*r/5）做菱形外边界 ∩ 圆形内边界。
//  采用整数近似：内圈用 dx^2+dy^2 <= r^2，外圈对角加亮一圈表现棱角。
// =============================================================================
module obstacle_render (
    input  wire [`X_BITS-1:0] sx,
    input  wire [`Y_BITS-1:0] sy,
    input  wire [`X_BITS-1:0] ox,
    input  wire [`Y_BITS-1:0] oy,
    input  wire [`X_BITS-1:0] radius,
    input  wire               active,
    output wire               hit,
    output wire [11:0]        color
);
    wire signed [`X_BITS:0] dx_s = $signed({1'b0, sx}) - $signed({1'b0, ox});
    wire signed [`Y_BITS:0] dy_s = $signed({1'b0, sy}) - $signed({1'b0, oy});
    wire [15:0] adx = (dx_s < 0) ? -dx_s : dx_s;
    wire [15:0] ady = (dy_s < 0) ? -dy_s : dy_s;

    wire [31:0] r2     = radius * radius;
    wire [31:0] dist2  = adx*adx + ady*ady;
    wire        in_core   = (dist2 <= r2);
    // 高光环：距离接近边缘的一层
    wire [31:0] r_in2  = (radius >= 3) ? (radius-3)*(radius-3) : 32'd0;
    wire        rim    = in_core && (dist2 >= r_in2);

    assign hit   = active && in_core;
    assign color = rim ? `COL_OBS_HI : `COL_OBS;
endmodule
