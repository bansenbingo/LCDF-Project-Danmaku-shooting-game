// =============================================================================
//  vga_top.v
//  ZJU VGA controller plus combinational render priority pipeline.
// =============================================================================
`include "game_defs.vh"

module vga_top #(
    parameter MAX_BULLETS = 64,
    parameter MAX_ENEMIES = 16,
    parameter MAX_OBS = 16
) (
    input  wire        clk_100m,
    input  wire        rstn,
    input  wire [2:0]  game_state,
    input  wire [1:0]  difficulty_sel,
    input  wire        score_mode,
    input  wire [15:0] score,
    input  wire [3:0]  lives,
    input  wire [15:0] kills,
    input  wire [15:0] play_time_sec,
    input  wire [`X_BITS-1:0] player_px,
    input  wire [`Y_BITS-1:0] player_py,
    input  wire        player_visible,
    input  wire [MAX_ENEMIES-1:0] en_active,
    input  wire [9:0]  en_x[MAX_ENEMIES-1:0],
    input  wire [9:0]  en_y[MAX_ENEMIES-1:0],
    input  wire [MAX_OBS-1:0] obs_active,
    input  wire [9:0]  obs_x[MAX_OBS-1:0],
    input  wire [9:0]  obs_y[MAX_OBS-1:0],
    input  wire [9:0]  obs_rad[MAX_OBS-1:0],
    input  wire [MAX_BULLETS-1:0] bul_active,
    input  wire [9:0]  bul_x[MAX_BULLETS-1:0],
    input  wire [9:0]  bul_y[MAX_BULLETS-1:0],
    input  wire [11:0] bul_color[MAX_BULLETS-1:0],
    output wire        frame_tick,
    output wire [3:0]  r,
    output wire [3:0]  g,
    output wire [3:0]  b,
    output wire        hs,
    output wire        vs
);

    reg [1:0] cdiv;
    always @(posedge clk_100m or negedge rstn) begin
        if (!rstn) cdiv <= 2'd0;
        else       cdiv <= cdiv + 2'd1;
    end
    wire vga_clk = cdiv[1];

    wire [8:0] row_addr;
    wire [9:0] col_addr;
    wire rdn;
    reg [11:0] vga_data;

    vgac u_vgac (
        .vga_clk(vga_clk),
        .clrn(rstn),
        .d_in(vga_data),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .rdn(rdn),
        .r(r), .g(g), .b(b), .hs(hs), .vs(vs)
    );

    reg vs_d;
    always @(posedge vga_clk or negedge rstn) begin
        if (!rstn) vs_d <= 1'b1;
        else       vs_d <= vs;
    end
    assign frame_tick = vs_d & ~vs;

    wire [`Y_BITS-1:0] sy = {1'b0, row_addr};
    wire player_hit;
    wire [11:0] player_color;
    player_render u_player_render (
        .sx(col_addr), .sy(sy), .px(player_px), .py(player_py),
        .visible(player_visible), .hit(player_hit), .color(player_color)
    );

    wire bullet_hit;
    wire [11:0] bullet_color;
    bullet_render #(.MAX_BULLETS(MAX_BULLETS)) u_bullet_render (
        .sx(col_addr), .sy(sy), .bul_active(bul_active), .bul_x(bul_x), .bul_y(bul_y),
        .bul_color(bul_color), .hit(bullet_hit), .color(bullet_color)
    );

    wire [MAX_ENEMIES-1:0] enemy_hit;
    wire [11:0] enemy_color_w [0:MAX_ENEMIES-1];
    wire enemy_hit_any = |enemy_hit;
    reg [11:0] enemy_color;
    integer ei;
    always @* begin
        enemy_color = `COL_BLACK;
        for (ei = 0; ei < MAX_ENEMIES; ei = ei + 1)
            if (enemy_hit[ei]) enemy_color = enemy_color_w[ei];
    end

    wire [MAX_OBS-1:0] obs_hit;
    wire [11:0] obs_color_w [0:MAX_OBS-1];
    wire obs_hit_any = |obs_hit;
    reg [11:0] obs_color;
    integer oi;
    always @* begin
        obs_color = `COL_BLACK;
        for (oi = 0; oi < MAX_OBS; oi = oi + 1)
            if (obs_hit[oi]) obs_color = obs_color_w[oi];
    end

    genvar gi;
    generate
        for (gi = 0; gi < MAX_ENEMIES; gi = gi + 1) begin : g_enemy_render
            enemy_render u_enemy_render (
                .sx(col_addr), .sy(sy), .ex(en_x[gi]), .ey(en_y[gi]),
                .active(en_active[gi]), .hit(enemy_hit[gi]), .color(enemy_color_w[gi])
            );
        end
        for (gi = 0; gi < MAX_OBS; gi = gi + 1) begin : g_obs_render
            obstacle_render u_obstacle_render (
                .sx(col_addr), .sy(sy), .ox(obs_x[gi]), .oy(obs_y[gi]), .radius(obs_rad[gi]),
                .active(obs_active[gi]), .hit(obs_hit[gi]), .color(obs_color_w[gi])
            );
        end
    endgenerate

    wire hud_hit;
    wire [11:0] hud_color;
    hud_render u_hud_render (
        .sx(col_addr), .sy(sy), .game_state(game_state), .difficulty_sel(difficulty_sel),
        .score_mode(score_mode), .score(score), .lives(lives), .kills(kills),
        .play_time_sec(play_time_sec), .hit(hud_hit), .color(hud_color)
    );

    wire bg_hit;
    wire [11:0] bg_color;
    bg_render u_bg_render (.sx(col_addr), .sy(sy), .game_state(game_state), .hit(bg_hit), .color(bg_color));

    always @* begin
        if (rdn)                 vga_data = 12'h000;
        else if (hud_hit)        vga_data = hud_color;
        else if (player_hit)     vga_data = player_color;
        else if (bullet_hit)     vga_data = bullet_color;
        else if (enemy_hit_any)  vga_data = enemy_color;
        else if (obs_hit_any)    vga_data = obs_color;
        else if (bg_hit)         vga_data = bg_color;
        else                     vga_data = `COL_BLACK;
    end

endmodule

module bullet_render #(
    parameter MAX_BULLETS = 64
) (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [MAX_BULLETS-1:0] bul_active,
    input  wire [9:0]  bul_x[MAX_BULLETS-1:0],
    input  wire [9:0]  bul_y[MAX_BULLETS-1:0],
    input  wire [11:0] bul_color[MAX_BULLETS-1:0],
    output reg         hit,
    output reg  [11:0] color
);
    integer i;
    always @* begin
        hit = 1'b0;
        color = `COL_BLACK;
        for (i = 0; i < MAX_BULLETS; i = i + 1) begin
            if (bul_active[i] && sx >= bul_x[i] && sx < bul_x[i] + `BULLET_W &&
                sy >= bul_y[i] && sy < bul_y[i] + `BULLET_H) begin
                hit = 1'b1;
                color = bul_color[i];
            end
        end
    end
endmodule

module hud_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,
    input  wire [1:0]  difficulty_sel,
    input  wire        score_mode,
    input  wire [15:0] score,
    input  wire [3:0]  lives,
    input  wire [15:0] kills,
    input  wire [15:0] play_time_sec,
    output reg         hit,
    output reg  [11:0] color
);
    wire in_menu_box = (sx >= 10'd120 && sx <= 10'd520 && sy >= 10'd80 && sy <= 10'd400);
    wire menu_border = in_menu_box && (sx < 10'd128 || sx > 10'd512 || sy < 10'd88 || sy > 10'd392);
    wire start_box = (sx >= 10'd260 && sx <= 10'd380 && sy >= 10'd300 && sy <= 10'd340);
    wire play_hud = (sx >= 10'd500 && sy >= 10'd440);
    wire result_box = (sx >= 10'd200 && sx <= 10'd440 && sy >= 10'd180 && sy <= 10'd300);
    wire pause_mark = (sx >= 10'd580 && sx <= 10'd610 && sy >= 10'd420 && sy <= 10'd455 && (sx[3:2] == 2'd0 || sx[3:2] == 2'd3));

    always @* begin
        hit = 1'b0;
        color = `COL_WHITE;
        case (game_state)
            3'd0: begin
                hit = menu_border || start_box || (sx >= 10'd180 && sx <= 10'd460 && sy >= 10'd140 && sy <= 10'd180);
                color = start_box ? `COL_GREEN : (difficulty_sel == `DIFF_HELL ? `COL_RED : `COL_CYAN);
            end
            3'd1: begin
                hit = play_hud && ((sx[4] ^ sy[4]) || score[0] || lives[0] || kills[0] || play_time_sec[0]);
                color = score_mode ? `COL_CYAN : `COL_YELLOW;
            end
            3'd2: begin
                hit = pause_mark;
                color = `COL_WHITE;
            end
            3'd3: begin
                hit = result_box;
                color = `COL_RED;
            end
            3'd4: begin
                hit = result_box;
                color = `COL_GREEN;
            end
            default: begin
                hit = 1'b0;
                color = `COL_BLACK;
            end
        endcase
    end
endmodule

module bg_render (
    input  wire [9:0]  sx,
    input  wire [9:0]  sy,
    input  wire [2:0]  game_state,
    output wire        hit,
    output wire [11:0] color
);
    assign hit = (game_state == 3'd0) && ((sx[5] ^ sy[5]) && (sx < 10'd20 || sx > 10'd619 || sy < 10'd20 || sy > 10'd459));
    assign color = hit ? `COL_BLUE : `COL_BLACK;
endmodule
