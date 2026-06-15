# ZJU-VGA 接口文档

本工程使用 ZJU 实验框架提供的 `vgac` 控制器（位于 `DEMO/VGAdemo/vgac.v`，也可参考
`DEMO/FrameVGA/VGAC.v`）。本文档是项目内**唯一**的 VGA 编程依据，所有
渲染模块（`*_render`）和 VGA 顶层都必须严格遵守这里给出的端口、时序和坐标
约定。

> 之后如果还需要新写或修改任何与 VGA 相关的模块，先翻这一页，**不要**自己
> 重新发明计数器或同步信号。

---

## 1. 模块端口

```verilog
module vgac (
    input             vga_clk,    // 25 MHz 像素时钟（由 100MHz 4 分频）
    input             clrn,       // 低有效复位 (active-low clear)
    input      [11:0] d_in,       // 像素颜色数据 {B[3:0], G[3:0], R[3:0]}

    output reg [8:0]  row_addr,   // 当前像素行地址 0..479
    output reg [9:0]  col_addr,   // 当前像素列地址 0..639
    output reg        rdn,        // 像素 RAM 读使能（低有效）= 当前是否在可见区
    output reg [3:0]  r, g, b,    // 实际驱动到 VGA 接口的 RGB
    output reg        hs, vs      // 行/场同步
);
```

实例化（Vivado/K7 推荐写法，与 `DEMO/VGAdemo/Top.v` 一致）：

```verilog
// 100MHz -> 25MHz：取 clkdiv[1] (即 ÷4)
reg [31:0] clkdiv;
always @(posedge clk_100mhz) clkdiv <= clkdiv + 1'b1;

vgac u_vgac (
    .vga_clk (clkdiv[1]),
    .clrn    (rstn),
    .d_in    (vga_data),     // 注意：{B,G,R}
    .row_addr(row_addr),
    .col_addr(col_addr),
    .rdn     (rdn),
    .r       (r),
    .g       (g),
    .b       (b),
    .hs      (hs),
    .vs      (vs)
);
```

---

## 2. 显示规格

| 项目          | 取值                          |
| ----------- | --------------------------- |
| 分辨率         | 640 × 480 @ 60Hz           |
| 像素时钟        | 25 MHz                      |
| 行总周期 (htotal) | 800（96 同步 + 48 后沿 + 640 + 16 前沿） |
| 场总周期 (vtotal) | 525（2 同步 + 33 后沿 + 480 + 10 前沿） |
| 同步极性        | hs/vs **均为正极性**（同步段输出 0，其余 1）|
| 颜色深度        | 4:4:4 = 12 bit              |

`vgac` 内部按上述时序计数，因此**外部不要再做 hsync/vsync 修正**。

---

## 3. 关键约定（务必牢记）

### 3.1 坐标系
- `col_addr ∈ [0, 639]`：屏幕水平坐标 X，0 在最左
- `row_addr ∈ [0, 479]`：屏幕垂直坐标 Y，0 在最上
- 渲染模块统一用 `(sx, sy) = (col_addr, row_addr)` 与实体中心 `(px, py)` 比较

> ⚠️ `vgac` 内部用减法生成 `col`/`row`，在消隐区会产生**回绕的大值**。
> 渲染模块**只在 `rdn==0` 时**使用 `col_addr` / `row_addr`，否则当作"屏外"。

### 3.2 颜色位序：`{B, G, R}`，不是 RGB

```text
d_in[ 3: 0] = R
d_in[ 7: 4] = G
d_in[11: 8] = B
```

因此 12 bit 字面量：

| 颜色   | d_in     | 含义       |
| ---- | -------- | -------- |
| 黑    | 12'h000  | 全 0      |
| 红    | 12'h00F  | R=F      |
| 绿    | 12'h0F0  | G=F      |
| 蓝    | 12'hF00  | B=F      |
| 黄    | 12'h0FF  | R+G      |
| 青    | 12'hFF0  | G+B      |
| 品红   | 12'hF0F  | R+B      |
| 白    | 12'hFFF  | R+G+B    |

**所有颜色宏必须按这个位序来写**，否则上板后红蓝会互换。
本工程的 `rtl/game_defs.vh` 已经按此约定定义，新增颜色时请保持一致。

### 3.3 消隐与默认色
- `rdn=1` 表示当前像素**不在 640×480 可见区内**（消隐期）
- `vgac` 已经在 `rdn=1` 时把 `r/g/b` 强制清零，**外部 `d_in` 在消隐期可以为任意值**
- 但渲染模块仍建议把 `rdn=1` 时的 `vga_data` 输出设为 `12'h000`，便于仿真观察

### 3.4 时序边界（隐形坑）
1. `row_addr` / `col_addr` 是 `vga_clk` 锁存的**寄存输出**，从地址出现到 `r/g/b` 实际呈现有 1 拍 `vga_clk` 的延迟。
   - 简单实体（直接组合判定的 `*_render`）这一拍可以忽略
   - 若使用块 RAM 存图，需要把地址提前 1 拍（在 `col_addr` 上加 1 后再访问 RAM）
2. `clrn` 是异步复位，建议接顶层去抖后的 `rstn`，避免上电闪屏

---

## 4. 标准渲染数据通路

本工程采用**多实体并行渲染 + 优先级合成**的方式，不使用帧缓冲：

```
                ┌──────────────┐
   col_addr ─►  │ player_render│─► hit_p, color_p
   row_addr ─►  └──────────────┘
                ┌──────────────┐
                │ enemy_render │─► hit_e, color_e
                └──────────────┘
                ┌──────────────┐
                │obstacle_rndr │─► hit_o, color_o
                └──────────────┘
                ┌──────────────┐
                │ bullet_rndr  │─► hit_b, color_b
                └──────────────┘
                ┌──────────────┐
                │  hud_rndr    │─► hit_h, color_h  (分数/暂停符)
                └──────────────┘
                          │
                          ▼
                    优先级 MUX            (HUD > player > bullet > enemy > obstacle > BG)
                          │
                          ▼
                       vga_data ─► vgac.d_in
```

每个 `*_render` 必须满足：
- 输入: `sx[9:0], sy[9:0]`（直接来自 `col_addr/row_addr`）+ 实体状态
- 输出: `hit`（1 表示该像素属于本实体）+ `color[11:0]`（**BGR 序**）
- 是**纯组合逻辑**，单 cycle 内必须出结果，不允许时钟、计数

---

## 5. 顶层模板

下面是 VGA 顶层模块的最小骨架，新写 `vga_top.v` 时按此模板填空：

```verilog
`include "game_defs.vh"

module vga_top (
    input  wire        clk_100m,
    input  wire        rstn,
    // ... 游戏内部状态接入 ...
    output wire [3:0]  r, g, b,
    output wire        hs, vs
);
    // 1. 25MHz 像素时钟
    reg [1:0] cdiv;
    always @(posedge clk_100m) cdiv <= cdiv + 1'b1;
    wire vga_clk = cdiv[1];

    // 2. 同步控制器
    wire [8:0] row_addr;
    wire [9:0] col_addr;
    wire       rdn;
    reg  [11:0] vga_data;
    vgac u_vgac (
        .vga_clk(vga_clk), .clrn(rstn), .d_in(vga_data),
        .row_addr(row_addr), .col_addr(col_addr),
        .rdn(rdn), .r(r), .g(g), .b(b), .hs(hs), .vs(vs)
    );

    // 3. 各实体的 *_render 例化（组合逻辑）
    wire hit_p, hit_e, hit_o;
    wire [11:0] col_p, col_e, col_o;
    player_render   u_pr (.sx(col_addr), .sy({1'b0,row_addr}), /*...*/);
    enemy_render    u_er (.sx(col_addr), .sy({1'b0,row_addr}), /*...*/);
    obstacle_render u_or (.sx(col_addr), .sy({1'b0,row_addr}), /*...*/);

    // 4. 优先级合成
    always @* begin
        if (rdn)            vga_data = 12'h000;
        else if (hit_p)     vga_data = col_p;
        else if (hit_e)     vga_data = col_e;
        else if (hit_o)     vga_data = col_o;
        else                vga_data = `COL_BLACK;   // 背景
    end
endmodule
```

---

## 6. K7 引脚约束（已在 `K7.xdc` 中给定）

| 信号       | 引脚       | 备注                      |
| -------- | -------- | ----------------------- |
| `r[3:0]` | N21/N22/R21/P21 | 4-bit 红                |
| `g[3:0]` | R22/R23/T24/T25 | 4-bit 绿                |
| `b[3:0]` | T20/R20/T22/T23 | 4-bit 蓝                |
| `hs`     | M22      | 行同步                     |
| `vs`     | M21      | 场同步                     |
| `rstn`   | W13      | LVCMOS18                |
| `clk`    | AC18     | 100MHz LVCMOS18         |

**`vgac` 的 `r/g/b` 端口直接连接同名顶层端口即可**，因为 `K7.xdc` 用的就是
`r[3:0]/g[3:0]/b[3:0]` 这套命名。

---

## 7. 自检清单（编译前必看）

- [ ] `vga_clk` 接的是 100MHz/4，不是 100MHz 本身
- [ ] `clrn` 是低有效，接 `rstn` 而不是 `~rstn`
- [ ] 颜色字面量按 `{B,G,R}` 写，红色是 `12'h00F`
- [ ] 渲染模块的 `sx` 用 `col_addr`，`sy` 用 `row_addr`（不要交换）
- [ ] `rdn=1` 时 `vga_data` 强制 `12'h000`
- [ ] 所有 `*_render` 是纯组合，不能有 `always @(posedge ...)`
- [ ] `r/g/b/hs/vs` 端口名与 `K7.xdc` 完全一致
