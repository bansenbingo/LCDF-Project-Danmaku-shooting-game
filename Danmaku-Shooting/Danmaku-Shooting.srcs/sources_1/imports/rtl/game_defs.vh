`define SCREEN_W        640
`define SCREEN_H        480
`define X_BITS          10
`define Y_BITS          9


`define COL_BLACK       12'h000
`define COL_WHITE       12'hFFF
`define COL_RED         12'h00F
`define COL_GREEN       12'h0F0
`define COL_BLUE        12'hF00
`define COL_YELLOW      12'h0FF
`define COL_CYAN        12'hFF0
`define COL_MAGENTA     12'hF0F
`define COL_GRAY        12'h888
`define COL_DKGRAY      12'h444
`define COL_LTGRAY      12'hCCC
`define COL_ORANGE      12'h05F
`define COL_BROWN       12'h084
`define COL_PURPLE      12'hA0A
`define COL_PINK        12'hF6F
`define COL_DKRED       12'h008
`define COL_DKGREEN     12'h080
`define COL_DKBLUE      12'h800


`define STATE_MENU       3'd0
`define STATE_PLAYING    3'd1
`define STATE_PAUSED     3'd2
`define STATE_GAMEOVER   3'd3
`define STATE_WIN        3'd4


`define DIFF_EASY        2'd0
`define DIFF_NORMAL      2'd1
`define DIFF_HARD         2'd2
`define DIFF_HELL         2'd3


`define MAX_ENEMIES        8
`define MAX_PLAYER_BULLETS 16
`define MAX_ENEMY_BULLETS  64
`define MAX_OBSTACLES      8


`define PLAYER_W          16
`define PLAYER_H          24
`define PLAYER_SPEED       2
`define PLAYER_HP_DEFAULT  3
`define PLAYER_FIRE_RATE   4
`define PLAYER_INV_TIME   180
`define PLAYER_BULLET_SPD  8


`define ENEMY_SPAWN_BASE  120
`define ENEMY_FIRE_BASE    60
`define ENEMY_BULLET_SPD    2
`define ENEMY_W            14
`define ENEMY_H            10


`define BULLET_W            2
`define BTYPE_STRAIGHT      2'd0
`define BTYPE_PARABOLA      2'd1
`define BTYPE_CIRCLE_CW     2'd2
`define BTYPE_CIRCLE_CCW    2'd3


`define SCORE_WIN_TARGET    500
`define GRACE_PERIOD        300
`define GAMEOVER_DISPLAY    300
`define WIN_DISPLAY         300
`define PAUSE_COOLDOWN      300


`define SEGMODE_KILLS       2'd0
`define SEGMODE_LIVES       2'd1
`define SEGMODE_SCORE       2'd2



`define DMUL_EASY           16'h100
`define DMUL_NORMAL         16'h180
`define DMUL_HARD            16'h200
`define DMUL_HELL            16'h300
