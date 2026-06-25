# COE 文件说明

本文件夹存放 Vivado Block Memory Generator / Distributed Memory Generator 所需的 COE 初始化文件。

| 文件名 | 类型 | 地址宽度 | 数据宽度 | 深度 | 用途 |
|--------|------|----------|----------|------|------|
| `font_ROM.coe` | ROM | 9 bit | 8 bit | 512 | 8×8 字符字库 (A-Z, 0-9, 标点共 44 字符) |

## font_ROM.coe

用于 HUD / 菜单的 8×8 ASCII 字体渲染。
地址结构：`{char_code[5:0], row[2:0]}`
- char_code 0-25: A-Z
- char_code 26-35: 0-9
- char_code 36: 空格
- char_code 37-43: : / | - > . !
- char_code 44-63: 保留 (全0)

在 Vivado 中使用时，IP 选 **ROM** 类型，加载此文件即可。
