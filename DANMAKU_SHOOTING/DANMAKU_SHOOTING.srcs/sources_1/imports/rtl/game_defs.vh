// =============================================================================
//  game_defs.vh
//  弹幕射击游戏全局参数 / 颜色 / 实体尺寸 / 难度宏
//  约定：
//    - VGA 分辨率 640×480, 12bit RGB444
//    - 帧节拍 frame_tick 由顶层 VGA 控制器在 vsync 下降沿产生（约 60Hz）
//    - 难度 difficulty[1:0]: 0=Easy 1=Normal 2=Hard 3=Hell
//    - 模式 mode: 0=Score 1=Endless
// =============================================================================
`ifndef GAME_DEFS_VH
`define GAME_DEFS_VH

// ---------------- 屏幕 ----------------
`define SCREEN_W   640
`define SCREEN_H   480
`define X_BITS     10        // 0..1023 足够覆盖 640
`define Y_BITS     10

// ---------------- 帧节拍 ----------------
`define FPS               60
`define ONE_SEC_FRAMES    `FPS

// ---------------- 难度 / 模式 ----------------
`define DIFF_EASY    2'd0
`define DIFF_NORMAL  2'd1
`define DIFF_HARD    2'd2
`define DIFF_HELL    2'd3

`define MODE_SCORE   1'b0
`define MODE_ENDLESS 1'b1

// ---------------- 玩家 ----------------
`define PLAYER_W           32
`define PLAYER_H           24
`define PLAYER_SPEED_BASE  2     // 每帧像素位移
`define PLAYER_FIRE_CD     8     // 默认开火冷却帧数（L0）
`define PLAYER_LIVES_MAX   5
`define PLAYER_REVIVE_FR   180   // 复活闪烁 3s = 180 帧
`define PLAYER_BLINK_FR    30    // 0.5s 翻转一次（=> 1Hz 闪烁）
`define UPGRADE_KILL_STEP  10    // 每击毁 10 架升级一档
`define WEAPON_LEVEL_MAX   3     // L0..L3

// ---------------- 敌方 UFO ----------------
`define ENEMY_W            40
`define ENEMY_H            20
`define ENEMY_HP_MAX       3
`define ENEMY_FIRE_CD_BASE 60    // 1s 间隔为基线，会被难度缩放

// ---------------- 子弹 ----------------
`define BULLET_W           4
`define BULLET_H           10
`define PBULLET_SPEED      6     // 玩家子弹竖直速度
`define EBULLET_SPEED_BASE 3     // 敌弹基础速度

// 弹道类型 (敌弹)
`define TRAJ_LINE  2'd0          // 直线
`define TRAJ_CIRC  2'd1          // 圆周
`define TRAJ_PARA  2'd2          // 抛物线

// ---------------- 障碍物（石头）----------------
`define OBS_NONE 2'd0
`define OBS_S    2'd1   // 小：1 发摧毁，撞击 -1 生命
`define OBS_M    2'd2   // 中：2 发摧毁，撞击 -2 生命
`define OBS_L    2'd3   // 大：3 发摧毁，撞击直接坠毁
`define OBS_S_R  8       // 半径 (近似)
`define OBS_M_R  14
`define OBS_L_R  22
`define OBS_FALL_SPEED 1

// ---------------- 颜色 (12bit, ZJU vgac d_in = {B[3:0],G[3:0],R[3:0]}) ----------------
// 详见 Settings/ZJUVGA.md §3.2：位序为 BGR，不是 RGB
`define COL_BLACK    12'h000
`define COL_WHITE    12'hFFF
`define COL_RED      12'h00F   // R=F
`define COL_GREEN    12'h0F0   // G=F
`define COL_BLUE     12'hF00   // B=F
`define COL_YELLOW   12'h0FF   // R+G
`define COL_CYAN     12'hFF0   // G+B
`define COL_MAGENTA  12'hF0F   // R+B
`define COL_ORANGE   12'h08F   // R=F, G=8
`define COL_GRAY     12'h888
`define COL_DKGRAY   12'h444
`define COL_BROWN    12'h369   // R=9, G=6, B=3

// 实体配色
`define COL_PLAYER       `COL_CYAN
`define COL_PLAYER_TRIM  `COL_WHITE
`define COL_PBULLET      `COL_YELLOW
`define COL_ENEMY_BODY   `COL_MAGENTA
`define COL_ENEMY_DOME   `COL_CYAN
`define COL_EBULLET      `COL_RED
`define COL_OBS          `COL_BROWN
`define COL_OBS_HI       `COL_ORANGE

`endif
