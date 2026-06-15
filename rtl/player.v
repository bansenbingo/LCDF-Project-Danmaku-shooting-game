// =============================================================================
//  player.v
//  玩家飞机实例
//   - 外形：三角形机身 + 中线机翼细节
//   - 移动：上下左右四向，按键有效时按帧速度位移，限制在屏幕内
//   - 武器：双条对称弹幕，等级 0..3，等级越高冷却越短/可双发
//   - 生命：初始随难度配置，命中扣血；为 0 触发 dead
//   - 复活：在底线中点出现，闪烁 3 秒（reviving=1 期间无敌）
//   - 作弊：cheat=1 时无敌
// =============================================================================
`include "game_defs.vh"

module player (
    input  wire                   clk,           // 100MHz
    input  wire                   rstn,          // 低有效复位
    input  wire                   frame_tick,    // 每帧一拍
    input  wire                   game_run,      // 游戏进行中（暂停/菜单时为 0）

    // 控制输入（已去抖的脉冲/电平）
    input  wire                   btn_up,        // BTNX3Y2
    input  wire                   btn_down,      // BTNX3Y0
    input  wire                   btn_left,      // BTNX2Y1
    input  wire                   btn_right,     // BTNX4Y1
    input  wire                   btn_fire,      // BTNX4Y3 (电平)
    input  wire                   btn_upgrade,   // 升级按键脉冲（满足击杀条件后有效）

    // 难度 / 作弊 / 击杀计数
    input  wire [1:0]             difficulty,
    input  wire                   cheat,
    input  wire [15:0]            kills,         // 当前累计击杀数

    // 受击与障碍碰撞 (来自碰撞模块)
    input  wire                   hit_bullet,    // 被敌弹击中（单帧脉冲）
    input  wire [1:0]             hit_obstacle,  // 撞石头：00 无, 01 -1, 10 -2, 11 直接坠毁

    // 输出：位置 / 状态
    output reg  [`X_BITS-1:0]     px,            // 中心 X
    output reg  [`Y_BITS-1:0]     py,            // 中心 Y
    output reg  [3:0]             lives,
    output reg                    alive,         // 生命 > 0
    output reg                    reviving,      // 复活无敌期
    output reg                    visible,       // 闪烁渲染开关
    output reg  [1:0]             weapon_lvl,    // 0..3
    output wire                   fire_pulse,    // 单帧脉冲：本帧请求发射
    output wire signed [`X_BITS:0] muzzle_lx,    // 左/右炮口 (有符号便于偏移)
    output wire signed [`X_BITS:0] muzzle_rx,
    output wire        [`Y_BITS-1:0] muzzle_y
);

    // ----------------- 难度 -> 初始生命 -----------------
    function [3:0] init_lives(input [1:0] d);
        case (d)
            `DIFF_EASY  : init_lives = 4'd5;
            `DIFF_NORMAL: init_lives = 4'd3;
            `DIFF_HARD  : init_lives = 4'd2;
            `DIFF_HELL  : init_lives = 4'd1;
            default     : init_lives = 4'd3;
        endcase
    endfunction

    // ----------------- 武器等级 -> 开火冷却 -----------------
    function [5:0] fire_cd(input [1:0] lvl);
        case (lvl)
            2'd0: fire_cd = 6'd16;
            2'd1: fire_cd = 6'd12;
            2'd2: fire_cd = 6'd8;
            2'd3: fire_cd = 6'd5;
            default: fire_cd = 6'd16;
        endcase
    endfunction

    // ============== 出生 / 复活位置 ==============
    localparam [`X_BITS-1:0] SPAWN_X = `SCREEN_W/2;
    localparam [`Y_BITS-1:0] SPAWN_Y = `SCREEN_H - `PLAYER_H - 4;

    // ============== 内部寄存器 ==============
    reg [7:0] revive_cnt;     // 复活计时
    reg [5:0] fire_cnt;       // 开火冷却计数
    reg       fire_req;       // 本帧待发射

    // ============== 初始化 / 复位 ==============
    // 注：顶层在 game_start 时也应给一个 rstn 脉冲或外部清零信号
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            px         <= SPAWN_X;
            py         <= SPAWN_Y;
            lives      <= init_lives(difficulty);
            alive      <= 1'b1;
            reviving   <= 1'b0;
            visible    <= 1'b1;
            weapon_lvl <= 2'd0;
            revive_cnt <= 8'd0;
            fire_cnt   <= 6'd0;
            fire_req   <= 1'b0;
        end else if (frame_tick && game_run) begin
            // ---------- 1. 复活闪烁倒计时 ----------
            if (reviving) begin
                if (revive_cnt == `PLAYER_REVIVE_FR - 1) begin
                    reviving   <= 1'b0;
                    visible    <= 1'b1;
                    revive_cnt <= 8'd0;
                end else begin
                    revive_cnt <= revive_cnt + 1'b1;
                    // 每 PLAYER_BLINK_FR 帧翻转一次可见性
                    if (revive_cnt[4:0] == 5'd0) visible <= ~visible;
                end
            end

            // ---------- 2. 移动（仅在存活时） ----------
            if (alive) begin
                // 横向
                if (btn_left  && px > `PLAYER_W/2 + `PLAYER_SPEED_BASE)
                    px <= px - `PLAYER_SPEED_BASE;
                else if (btn_right && px + `PLAYER_W/2 + `PLAYER_SPEED_BASE < `SCREEN_W)
                    px <= px + `PLAYER_SPEED_BASE;
                // 纵向
                if (btn_up   && py > `PLAYER_H/2 + `PLAYER_SPEED_BASE)
                    py <= py - `PLAYER_SPEED_BASE;
                else if (btn_down && py + `PLAYER_H/2 + `PLAYER_SPEED_BASE < `SCREEN_H)
                    py <= py + `PLAYER_SPEED_BASE;
            end

            // ---------- 3. 受击处理 ----------
            // 作弊 / 复活无敌时忽略伤害
            if (alive && !cheat && !reviving) begin
                if (hit_obstacle == 2'b11) begin
                    // 直接坠毁
                    lives <= 4'd0;
                end else if (hit_obstacle == 2'b10) begin
                    lives <= (lives > 4'd2) ? lives - 4'd2 : 4'd0;
                end else if (hit_obstacle == 2'b01 || hit_bullet) begin
                    lives <= (lives > 4'd1) ? lives - 4'd1 : 4'd0;
                end

                // 触发复活 / 死亡
                if ((hit_bullet || hit_obstacle != 2'b00)) begin
                    if (lives <= 4'd1 ||
                        (hit_obstacle == 2'b10 && lives <= 4'd2) ||
                         hit_obstacle == 2'b11) begin
                        alive <= 1'b0;     // 由顶层在 alive=0 时判定 GAME OVER
                    end else begin
                        // 还有命：复活到底线中央，进入闪烁无敌
                        px         <= SPAWN_X;
                        py         <= SPAWN_Y;
                        reviving   <= 1'b1;
                        revive_cnt <= 8'd0;
                        visible    <= 1'b1;
                    end
                end
            end

            // ---------- 4. 武器升级 ----------
            // 每达成 UPGRADE_KILL_STEP 倍数允许升级；按键到来才真正升
            if (btn_upgrade && weapon_lvl < `WEAPON_LEVEL_MAX
                && kills >= ((weapon_lvl + 1) * `UPGRADE_KILL_STEP))
                weapon_lvl <= weapon_lvl + 1'b1;

            // ---------- 5. 开火冷却与请求 ----------
            if (fire_cnt != 6'd0) begin
                fire_cnt <= fire_cnt - 1'b1;
                fire_req <= 1'b0;
            end else if (btn_fire && alive && !reviving) begin
                fire_req <= 1'b1;
                fire_cnt <= fire_cd(weapon_lvl);
            end else begin
                fire_req <= 1'b0;
            end
        end
    end

    // 炮口位置 = 机身左右两侧（双条对称弹幕）
    assign muzzle_lx = $signed({1'b0, px}) - $signed(`PLAYER_W/2 - 2);
    assign muzzle_rx = $signed({1'b0, px}) + $signed(`PLAYER_W/2 - 2);
    assign muzzle_y  = py - `PLAYER_H/2;
    assign fire_pulse = fire_req;

endmodule


// =============================================================================
//  player_render
//  根据当前扫描像素 (sx,sy) 与玩家位置判定是否落在三角形飞机内，并给出颜色
//  采用整数判定：机身为底边在下、顶点在上的三角形 + 中线纵条
// =============================================================================
module player_render (
    input  wire [`X_BITS-1:0] sx,
    input  wire [`Y_BITS-1:0] sy,
    input  wire [`X_BITS-1:0] px,
    input  wire [`Y_BITS-1:0] py,
    input  wire               visible,
    output wire               hit,
    output wire [11:0]        color
);
    // 局部坐标 (相对中心)
    wire signed [`X_BITS:0] dx = $signed({1'b0, sx}) - $signed({1'b0, px});
    wire signed [`Y_BITS:0] dy = $signed({1'b0, sy}) - $signed({1'b0, py});

    // 三角形：顶点在 (0, -H/2)，底边 y=+H/2 ，宽度 W
    // 整数判定（粗化）：在 dy ∈ [-H/2,+H/2] 时 |dx| <= W/2 * (dy + H/2) / H
    // 取 W=32,H=24 ⇒ 3*|dx| <= 2*(dy + H/2)
    wire signed [`X_BITS:0] adx = (dx < 0) ? -dx : dx;
    wire in_y    = (dy >= -(`PLAYER_H/2)) && (dy <= (`PLAYER_H/2));
    wire signed [`Y_BITS+1:0] dy_plus = dy + (`PLAYER_H/2);          // 始终 >= 0（被 in_y 守卫）
    wire in_tri  = in_y && ( (adx + adx + adx) <= (dy_plus + dy_plus) );

    // 中线机翼细节：竖直窄条
    wire detail = in_tri && (adx <= 2);

    assign hit   = visible && in_tri;
    assign color = detail ? `COL_PLAYER_TRIM : `COL_PLAYER;
endmodule
