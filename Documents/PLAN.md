# 弹幕射击游戏 —— 开发计划书

> 基于 `SETTING.md` 游戏设定、`ZJUVGA.md` 接口规范及已完成实例模块制定。

---

## 一. 当前进度概览

### 已完成模块

| 模块 | 文件 | 说明 |
|------|------|------|
| 全局参数 | `rtl/game_defs.vh` | 屏幕、帧率、难度、实体尺寸、颜色宏等 |
| 玩家飞机 | `rtl/player.v` | 移动/射击/升级/复活/无敌/作弊，含 `player_render` |
| 敌方 UFO | `rtl/enemy.v` | 生成/移动/射击请求/HP/难度缩放，含 `enemy_render` |
| 障碍物石头 | `rtl/obstacle.v` | 三种尺寸/难度概率/碰撞伤害，含 `obstacle_render` |
| 数码管驱动 | `DispNum.v` | 4 位 7 段数码管驱动（Digital 自动生成） |
| 引脚约束 | `K7.xdc` | K7 开发板完整引脚约束 |

### 待完成模块（共 11 个）

| # | 模块 | 优先级 | 依赖 |
|---|------|--------|------|
| 1 | `vgac.v`（复制） | P0 | 无 |
| 2 | `lfsr.v` | P0 | 无 |
| 3 | `btn_debounce.v` | P0 | 无 |
| 4 | `bullet_pool.v` | P0 | game_defs.vh |
| 5 | `collision.v` | P0 | player/enemy/obstacle 接口 |
| 6 | `score_keeper.v` | P1 | game_defs.vh |
| 7 | `game_fsm.v` | P1 | 所有实体模块 |
| 8 | `enemy_pool.v` | P0 | enemy.v, lfsr.v, game_defs.vh |
| 9 | `obstacle_pool.v` | P0 | obstacle.v, lfsr.v, game_defs.vh |
| 10 | `seg_display.v` | P2 | DispNum.v, score_keeper.v |
| 11 | `vga_top.v` | P1 | 所有 render + 状态机 |
| 12 | `top.v` | P1 | 所有模块例化 |

---

## 二. 分步实施计划

### 第 1 步：复制 VGA 控制器 `vgac.v`
**文件**: `rtl/vgac.v`  
**预估工时**: 0.1h（纯复制）  
**来源**: 从 ZJU 实验框架 `DEMO/VGAdemo/vgac.v` 复制到 `rtl/` 目录  
**输出**: vgac 模块就绪，端口参见 `Settings/ZJUVGA.md` §1  
**验证**: 在 Vivado 中添加该文件，语法检查通过

---

### 第 2 步：实现伪随机数发生器 `lfsr.v`
**文件**: `rtl/lfsr.v`  
**预估工时**: 0.3h  

**接口**:
```
module lfsr (
    input  wire        clk,
    input  wire        rstn,
    input  wire        step,       // 每个 frame_tick 产生一个新值
    output wire [15:0] rng
);
```

**实现要点**:
- 16-bit Galois LFSR，抽头多项式建议 `x^16 + x^14 + x^13 + x^11 + 1`
- `step` 有效时移一位产生新随机数
- 复位后种子为非零值（如 `16'hACE1`）
- 不能进入全零死锁状态

**验证**: 仿真观察输出序列无全零，无短周期重复

---

### 第 3 步：实现按键去抖 `btn_debounce.v`
**文件**: `rtl/btn_debounce.v`  
**预估工时**: 0.3h  

**接口**:
```
module btn_debounce #(
    parameter N = 20    // 去抖按键数量
) (
    input  wire          clk,      // 100MHz
    input  wire          rstn,
    input  wire [N-1:0]  btn_in,   // 原始按键（K7 板载按钮，按下为 1）
    output wire [N-1:0]  btn_out,  // 稳定电平
    output wire [N-1:0]  btn_pulse // 单帧上升沿脉冲
);
```

**实现要点**:
- 20ms 去抖窗口（100MHz 下约 2,000,000 个周期）
- 用移位寄存器或饱和计数器检测稳定
- 输出稳定的 `btn_out`（用于移动等电平操作）
- 输出 `btn_pulse`（用于暂停、开始等单次触发操作）

**K7 按键映射**: BTNX0Y0~BTNX4Y3 共 20 个按钮（5 组 × 4 个）

**验证**: 仿真验证去抖延迟和脉冲宽度

---

### 第 4 步：实现子弹池 `bullet_pool.v`
**文件**: `rtl/bullet_pool.v`  
**预估工时**: 1.5h  

**接口**:
```
module bullet_pool #(
    parameter MAX_BULLETS = 64     // 最大同时子弹数
) (
    input  wire            clk, rstn,
    input  wire            frame_tick,
    input  wire            game_run,

    // --- 玩家开火请求 ---
    input  wire            p_fire_pulse,
    input  wire [9:0]      p_muzzle_lx, p_muzzle_rx, p_muzzle_y,

    // --- 敌机开火请求（来自 enemy_pool 仲裁后） ---
    input  wire            e_fire_req,
    input  wire [9:0]      e_fire_x, e_fire_y,
    input  wire [1:0]      e_fire_traj,    // TRAJ_LINE/CIRC/PARA
    input  wire [2:0]      e_fire_count,   // 1..5
    input  wire            e_fire_dual,    // 双条弹幕

    // --- 难度 ---
    input  wire [1:0]      difficulty,

    // --- 输出：给碰撞检测和渲染 ---
    output wire [MAX_BULLETS-1:0]       bul_active,
    output wire [11:0]                  bul_color [MAX_BULLETS-1:0],
    output wire [9:0]                   bul_x     [MAX_BULLETS-1:0],
    output wire [9:0]                   bul_y     [MAX_BULLETS-1:0],
    output wire [`X_BITS-1:0]           bul_w     [MAX_BULLETS-1:0],
    output wire [`Y_BITS-1:0]           bul_h     [MAX_BULLETS-1:0],
    output wire                         bul_is_pbullet [MAX_BULLETS-1:0]
);
```

**实现要点**:
- 维护 `MAX_BULLETS` 个槽位，每个槽位有 active 标志
- 玩家子弹: `dy = -PBULLET_SPEED`（向上），`dx = 0`
- 敌弹直线: 按角度计算 `dx/dy`，速度 = `EBULLET_SPEED_BASE × 难度系数`
- 敌弹曲线 (CIRC): 生命周期内以初始位置为圆心做圆周运动
- 敌弹曲线 (PARA): 抛物线轨迹，水平匀速 + 竖直匀加速
- 每帧 `frame_tick` 更新所有 active 子弹的 `(x,y)` 位置
- 越界子弹自动标记 inactive
- 敌弹多颗发射：在 `e_fire_req` 时计算 N 个方向的初始角度均匀分布
- 双条弹幕：左右对称偏移 ±8 像素
- 清除信号：玩家阵亡时清除所有敌弹（保留敌人）

**验证**: 仿真验证子弹运动轨迹、越界回收、多弹生成

---

### 第 5 步：实现碰撞检测 `collision.v`
**文件**: `rtl/collision.v`  
**预估工时**: 1.0h  

**接口**:
```
module collision (
    input  wire          clk, rstn,
    input  wire          frame_tick,
    input  wire          game_run,

    // --- 玩家位置/状态 ---
    input  wire [9:0]    player_px, player_py,
    input  wire [4:0]    player_w, player_h,  // PLAYER_W, PLAYER_H
    input  wire          player_alive, player_reviving,

    // --- 子弹池输出 ---
    input  wire [63:0]   bul_active,
    input  wire [9:0]    bul_x[63:0], bul_y[63:0],
    input  wire          bul_is_pbullet[63:0],

    // --- 敌人池输出 ---
    input  wire [15:0]   en_active,
    input  wire [9:0]    en_x[15:0], en_y[15:0],

    // --- 障碍物池输出 ---
    input  wire [15:0]   obs_active,
    input  wire [9:0]    obs_x[15:0], obs_y[15:0],
    input  wire [9:0]    obs_rad[15:0],

    // --- 碰撞结果 ---
    // 玩家
    output wire          player_hit_bullet,   // 被敌弹击中
    output wire          player_hit_obstacle, // 撞石头
    output wire [1:0]    player_obs_damage,   // 石头伤害编码

    // 敌机
    output wire [15:0]   en_hit,              // 每架敌机被玩家子弹命中

    // 障碍物
    output wire [15:0]   obs_hit_pbullet,     // 被玩家子弹命中
    output wire [15:0]   obs_hit_player,      // 被玩家碰到

    // 消除已碰撞的子弹（防止一弹多判）
    output wire [63:0]   bul_kill             // 需要回收的子弹槽位
);
```

**实现要点**:
- 基于 AABB 矩形碰撞检测（玩家/敌机/子弹是矩形，障碍物用圆近似）
- 圆-矩形碰撞：比较圆心到矩形最近点的距离
- 玩家复活期间 (reviving==1) 不触发任何碰撞
- 玩家子弹击中敌机 → 置对应 `en_hit` 位 + 消除子弹
- 玩家子弹击中障碍物 → 置 `obs_hit_pbullet` 位 + 消除子弹
- 敌弹击中玩家 → 置 `player_hit_bullet`（单脉冲）
- 障碍物碰到玩家 → 置 `obs_hit_player` 位，输出 `player_obs_damage`
- 子弹消除用 `bul_kill` 位掩码通知 bullet_pool
- 均为组合逻辑计算（单 cycle），但结果用寄存器锁存到 frame_tick 时钟域

**验证**: 仿真构造各种碰撞场景逐一验证

---

### 第 6 步：实现计分/计时模块 `score_keeper.v`
**文件**: `rtl/score_keeper.v`  
**预估工时**: 0.5h  

**接口**:
```
module score_keeper (
    input  wire          clk, rstn,
    input  wire          frame_tick,
    input  wire          game_run,       // PLAY 状态下为 1

    // --- 击杀/摧毁输入 ---
    input  wire          enemy_killed,   // 单帧脉冲
    input  wire [1:0]    enemy_hp,       // 被击杀敌机的 HP，用于 5×HP 加分
    input  wire          obstacle_killed,// 摧毁障碍物脉冲（不加分，仅统计）

    // --- 输出 ---
    output wire [15:0]   score,          // 当前总分
    output wire [15:0]   kills,          // 累计击杀数
    output wire [15:0]   obstacles_destroyed,
    output wire          target_reached, // 积分模式达到目标 (>=500)
    output wire [31:0]   play_time_sec   // 游戏进行秒数
);
```

**实现要点**:
- 每收到 `enemy_killed`，`score += 5 × enemy_hp`
- 每秒（每 60 帧）加 1 生存分
- `play_time_sec` 用于难度随时间增长的计算
- 清除：回到 MENU 或 GAMEOVER 状态时全部复位

**验证**: 仿真验证加分和计时逻辑

---

### 第 7 步：实现敌机池 `enemy_pool.v`
**文件**: `rtl/enemy_pool.v`  
**预估工时**: 1.0h  

**接口**:
```
module enemy_pool #(
    parameter MAX_ENEMIES = 16
) (
    input  wire          clk, rstn,
    input  wire          frame_tick,
    input  wire          game_run,

    input  wire [1:0]    difficulty,
    input  wire [15:0]   rng,            // 来自 LFSR
    input  wire [15:0]   play_time_sec,  // 用于难度随时间增长

    // --- 击中信号（来自碰撞模块） ---
    input  wire [MAX_ENEMIES-1:0] en_hit,

    // --- 输出 ---
    output wire [MAX_ENEMIES-1:0] en_active,
    output wire [9:0]             en_x[MAX_ENEMIES-1:0],
    output wire [9:0]             en_y[MAX_ENEMIES-1:0],
    output wire                   any_killed,       // 任意敌机被击杀（脉冲）
    output wire [1:0]             killed_hp,        // 被击杀敌机的 HP

    // --- 发射请求（向 bullet_pool） ---
    output wire                   e_fire_req,
    output wire [9:0]             e_fire_x, e_fire_y,
    output wire [1:0]             e_fire_traj,
    output wire [2:0]             e_fire_count,
    output wire                   e_fire_dual
);
```

**实现要点**:
- 管理 `MAX_ENEMIES` 个 `enemy` 实例（generate 数组例化）
- 刷新逻辑：根据难度和经过时间计算刷新间隔，定时生成新敌机
- 生成位置：X 随机 (32~608)，Y 固定在顶部 (0~40)
- 当所有槽位都 active 时不再生成新敌机
- 每个 frame_tick 将 `frame_tick, game_run, rng` 广播到所有实例
- 多个敌机同时发出发射请求时，按优先级仲裁（EID 小的先发），每帧只发一个
- 被击杀的敌机释放槽位：active 清零
- 障碍物不阻塞敌弹（敌弹可穿透障碍物，参照设定）

**验证**: 仿真验证生成间隔、槽位管理、多敌机并发射击仲裁

---

### 第 8 步：实现障碍物池 `obstacle_pool.v`
**文件**: `rtl/obstacle_pool.v`  
**预估工时**: 0.8h  

**接口**:
```
module obstacle_pool #(
    parameter MAX_OBS = 16
) (
    input  wire          clk, rstn,
    input  wire          frame_tick,
    input  wire          game_run,

    input  wire [1:0]    difficulty,
    input  wire [15:0]   rng,
    input  wire [15:0]   play_time_sec,

    // --- 碰撞信号 ---
    input  wire [MAX_OBS-1:0] obs_hit_pbullet,
    input  wire [MAX_OBS-1:0] obs_hit_player,

    // --- 输出 ---
    output wire [MAX_OBS-1:0] obs_active,
    output wire [9:0]         obs_x[MAX_OBS-1:0],
    output wire [9:0]         obs_y[MAX_OBS-1:0],
    output wire [9:0]         obs_rad[MAX_OBS-1:0],
    output wire               obs_hit_player_any,
    output wire [1:0]         obs_player_damage
);
```

**实现要点**:
- 管理 `MAX_OBS` 个 `obstacle` 实例
- 刷新逻辑：随难度和时间增大刷新率
- 生成位置：X 随机，Y 固定在顶部
- 碰撞后无论是否摧毁都释放槽位（障碍物碰到玩家消失）
- 只响应玩家子弹，敌弹穿透不交互

**验证**: 仿真验证尺寸概率分布、碰撞后销毁

---

### 第 9 步：实现游戏状态机 `game_fsm.v`
**文件**: `rtl/game_fsm.v`  
**预估工时**: 0.8h  

**接口**:
```
module game_fsm (
    input  wire          clk, rstn,
    input  wire          frame_tick,

    // --- 按键输入（已去抖） ---
    input  wire [19:0]   btn_out,        // 20 个稳定电平
    input  wire [19:0]   btn_pulse,      // 20 个单帧脉冲
    input  wire [15:0]   sw,             // 16 个开关

    // --- 游戏信号 ---
    input  wire          player_dead,    // 玩家生命 == 0
    input  wire          target_reached, // 积分达到目标
    input  wire [1:0]    score_mode,     // 积分/无尽模式

    // --- 输出 ---
    output wire [2:0]    state,          // 0:MENU 1:PLAY 2:PAUSE 3:GAMEOVER 4:WIN
    output wire          game_run,       // PLAY 状态且非暂停
    output wire          entity_update,  // 实体可更新（game_run && !paused）
    output wire          menu_active,    // MENU 状态
    output wire [1:0]    difficulty_sel, // BTNX0Y0~Y3 选定的难度
    output wire          cheat,          // 作弊模式激活
    output wire          pause_5s_lock   // 暂停 5 秒锁定
);
```

**实现要点**:
- 状态编码: MENU=0, PLAY=1, PAUSE=2, GAMEOVER=3, WIN=4
- MENU 状态:
  - 读取 SW[0] 决定积分/无尽模式
  - BTNX0Y0~X0Y3 更改 difficulty_sel（循环 Easy/Normal/Hard/Hell）
  - BTNX4Y3 按下 → 转入 PLAY
- PLAY 状态:
  - BTNX0Y0 按下 → PAUSE（5 秒内最多触发一次）
  - player_dead → GAMEOVER
  - target_reached && MODE_SCORE → WIN
- PAUSE 状态:
  - BTNX0Y0 按下 → 3s 倒计时 → PLAY
- GAMEOVER/WIN 状态:
  - 5 秒倒计时 → MENU
- 作弊模式检测:
  - SW[2,3,5,7,11,13] = 1 且其他 SW[1..14] = 0
  - 仅 SW[0] 和 SW[15] 不影响检测

**验证**: 仿真覆盖所有状态转移路径

---

### 第 10 步：实现数码管显示控制 `seg_display.v`
**文件**: `rtl/seg_display.v`  
**预估工时**: 0.5h  

**接口**:
```
module seg_display (
    input  wire          clk, rstn,      // 100MHz

    // --- 游戏数据 ---
    input  wire [15:0]   score,
    input  wire [15:0]   kills,
    input  wire [3:0]    lives,
    input  wire [2:0]    game_state,
    input  wire [19:0]   btn_pulse,      // BTNX1Y3 切换显示内容

    // --- 数码管 ---
    output wire [7:0]    SEGMENT,
    output wire [3:0]    AN,
    output wire [7:0]    LED             // 二进制高位溢出指示
);
```

**实现要点**:
- 例化 `DispNum` 模块驱动数码管
- 三种显示模式循环切换（BTNX1Y3）:
  1. 击毁敌军数 (kills)
  2. 玩家剩余生命 (lives)
  3. 当前积分 (score)
- 超出 9999: 低 4 位数码管显示，高位数由 LED[7:0] 二进制表示
- 超过 255 高位 (LED 也溢出): 全部清零重新显示
- MENU 状态显示 "----"，GAMEOVER 显示 "OVER"，WIN 显示 "WIN "
- 扫描频率 ~1kHz，可用 clkdiv 分频

**验证**: 仿真验证三种模式切换和溢出处理

---

### 第 11 步：实现 VGA 渲染顶层 `vga_top.v`
**文件**: `rtl/vga_top.v`  
**预估工时**: 1.5h  
**依赖**: 步骤 1-10 全部完成

**包含的子模块**:

#### a) `player_render` — 已完成（在 player.v 内）

#### b) `enemy_render[]` — 已完成（在 enemy.v 内）  
需以 generate 数组形式例化 MAX_ENEMIES 个实例

#### c) `obstacle_render[]` — 已完成（在 obstacle.v 内）  
需以 generate 数组形式例化 MAX_OBS 个实例

#### d) `bullet_render` — 需新写

```
module bullet_render (
    input  wire [9:0]    sx, sy,      // VGA 扫描坐标
    input  wire [63:0]   bul_active,
    input  wire [9:0]    bul_x[63:0], bul_y[63:0],
    input  wire [11:0]   bul_color[63:0],
    output wire          hit,
    output wire [11:0]   color
);
```

**实现**: 遍历所有 active 子弹槽位，判断 `(sx,sy)` 是否落在任一子弹矩形范围内。玩家子弹黄色 (`COL_PBULLET`)，敌弹红色 (`COL_EBULLET`)

#### e) `hud_render` — 需新写

```
module hud_render (
    input  wire [9:0]    sx, sy,
    input  wire [2:0]    game_state,   // 0:MENU 1:PLAY 2:PAUSE 3:GAMEOVER 4:WIN
    input  wire [1:0]    difficulty_sel,
    input  wire          score_mode,   // 0:score 1:endless
    input  wire [15:0]   score,
    input  wire [3:0]    lives,
    input  wire [15:0]   kills,
    input  wire [15:0]   play_time_sec,
    output wire          hit,
    output wire [11:0]   color
);
```

**实现要点**:
- **MENU 界面**:
  - 纯黑背景 + 彩色横竖条边框（矩形框，宽约 400×300，居中）
  - 游戏标题 "AEROPLANE DANMAKU SHOOTING"（居中，彩色）
  - "START" 文字框
  - 难度显示 "DIFFICULTY:EASY/NORMAL/HARD/HELL"
  - 模式显示 "MODE:SCORE" 或 "MODE:ENDLESS"
- **PLAY 界面**:
  - 右下角 "SCORE:XXXXXXXX"（8 位数字）
  - 文字使用 8×16 或 5×8 字符 ROM 生成
- **PAUSE 界面**:
  - 叠加半透明遮罩 + 右下角 " || " 符号
  - 恢复前显示三角形 "▶" 3 秒
- **GAMEOVER 界面**:
  - 红色大字 "GAME" + "OVER" 分两行居中
- **WIN 界面**:
  - 绿色大字 "YOU" + "WIN" 分两行居中

**字符生成**: 使用小型字符 ROM（5×8 像素/字符）或直接用组合逻辑绘制简单字母

#### f) `bg_render` — 需新写

```
module bg_render (
    input  wire [9:0]    sx, sy,
    input  wire [2:0]    game_state,
    output wire          hit,
    output wire [11:0]   color
);
```

**实现**: MENU 状态输出彩色边框背景，PLAY 状态输出纯黑 `12'h000`

#### 顶层合成逻辑 (vga_top)

- 实例化 `vgac`，产生 `row_addr/col_addr/rdn`
- 所有 render 模块并行连接 `sx=col_addr, sy=row_addr`
- 优先级 MUX（组合 always @*）:
  1. `rdn==1` → `12'h000`
  2. HUD hit → hud_color
  3. Player hit → player_color
  4. Player bullet hit → bullet_color (仅 is_pbullet)
  5. Enemy bullet hit → bullet_color
  6. Enemy hit → enemy_color（多实例取首个 hit）
  7. Obstacle hit → obstacle_color
  8. BG hit → bg_color
  9. else → `COL_BLACK`

**验证**: 仿真观察优先级合成输出，确认各实体可见

---

### 第 12 步：实现顶层模块 `top.v`
**文件**: `rtl/top.v`  
**预估工时**: 0.8h  
**依赖**: 步骤 1-11 全部完成

**接口**: 与 `K7.xdc` 完全一致
```
module top (
    input  wire         clk,             // 100MHz, AC18
    input  wire         rstn,            // 低有效复位, W13

    // 按钮 (5 组 × 4 个)
    input  wire [3:0]   BTNX0Y0, BTNX0Y1, BTNX0Y2, BTNX0Y3,
    input  wire [3:0]   BTNX1, BTNX2, BTNX3, BTNX4,

    // 开关
    input  wire [15:0]  SW,

    // VGA
    output wire [3:0]   r, g, b,
    output wire         hs, vs,

    // 数码管
    output wire [7:0]   SEGMENT,
    output wire [3:0]   AN,

    // LED
    output wire [7:0]   LED
);
```

**实现要点**:
- 100MHz 时钟输入：直接使用 `clk` 信号，无需 PLL
- `clkdiv` 分频器：`clkdiv <= clkdiv + 1'b1`，产生 `vga_clk = clkdiv[1]`
- 按键去抖前需整理 K7 的按钮信号（20 个独立信号）到一个 `[19:0]` 总线
- 例化所有子模块并互联
- 顶层模块名必须与 Vivado 项目设置一致

**验证**: Vivado 综合 + 上板测试

---

## 三. 依赖关系图

```
game_defs.vh ─────────────────────────────────────────────────
    │                                                         │
    ├── player.v (done) ──────────────────┐                   │
    ├── enemy.v  (done) ─── enemy_pool ───┤                   │
    ├── obstacle.v(done)── obstacle_pool ─┤                   │
    │                                     ├── collision.v     │
    ├── vgac.v   (copy) ─────────────────┤                   │
    ├── lfsr.v   ───────── enemy_pool ───┤                   │
    │                     obstacle_pool ─┤                   │
    ├── bullet_pool.v ──── collision ────┤                   │
    │                     vga_top ───────┤                   │
    ├── btn_debounce.v ─── game_fsm ─────┤                   │
    ├── score_keeper.v ─── game_fsm ─────┤                   │
    │                     seg_display ───┤                   │
    └── DispNum.v ──────── seg_display ──┤                   │
                                          │                   │
                                    vga_top.v                 │
                                    collision ─── top.v       │
                                    game_fsm                    │
                                    seg_display               │
```

## 四. 开发顺序建议

按依赖关系和可测试性，建议按以下顺序实施：

| 阶段 | 步骤 | 模块 | 可独立测试 |
|------|------|------|-----------|
| **一** | 1-3 | vgac.v, lfsr.v, btn_debounce.v | 每个模块单独仿真 |
| **二** | 4-6 | bullet_pool.v, collision.v, score_keeper.v | 联合仿真 |
| **三** | 7-9 | enemy_pool.v, obstacle_pool.v, game_fsm.v | 结合阶段一、二仿真 |
| **四** | 10 | seg_display.v | 可单独上板测试（点位数码管） |
| **五** | 11 | vga_top.v（含 bullet_render, hud_render, bg_render） | 结合前三阶段仿真 + 上板 |
| **六** | 12 | top.v | 全系统上板联调 |

## 五. 验证策略

1. **单元仿真**: 每个模块完成后编写简单 testbench 验证基本功能
2. **集成仿真**: 阶段内模块联合仿真，验证接口交互
3. **Vivado 综合**: 确保无语法错误、无多驱动、时序收敛
4. **上板测试**: 分阶段上板验证：
   - 阶段四后：数码管和 LED 功能
   - 阶段五后：VGA 画面和菜单交互
   - 阶段六后：完整游戏流程

## 六. 参考文件索引

| 文件 | 位置 | 用途 |
|------|------|------|
| 游戏设定 | `./Settings/SETTING.md` | 完整游戏设计规格 |
| VGA 接口 | `./Settings/ZJUVGA.md` | VGA 编程规范 |
| ZJU-VGA Skill | `.opencode/skill/zju-vga/SKILL.md` | AI 辅助编程规则 |
| 全局参数 | `rtl/game_defs.vh` | 宏定义和常量 |
| 引脚约束 | `K7.xdc` | K7 开发板引脚绑定 |
| 数码管驱动 | `DispNum.v` | 7 段数码管底层驱动 |
