`include "game_defs.vh"

module vga_top (
    input  wire        clk_100m,
    input  wire        rstn,

    input  wire [2:0]  game_state,
    input  wire [19:0] score,
    input  wire [7:0]  kills,
    input  wire [2:0]  lives,
    input  wire [1:0]  difficulty,
    input  wire        mode,

    input  wire [9:0]  pl_x,
    input  wire [8:0]  pl_y,
    input  wire        pl_active,
    input  wire        pl_flash,

    input  wire [7:0]  en_active,
    input  wire [79:0] en_x,
    input  wire [71:0] en_y,
    input  wire [15:0] en_hp,
    input  wire [7:0]  en_flash,

    input  wire [15:0] pb_active,
    input  wire [159:0] pb_x,
    input  wire [143:0] pb_y,
    input  wire [31:0]  pb_type,

    input  wire [63:0] eb_active,
    input  wire [639:0] eb_x,
    input  wire [575:0] eb_y,
    input  wire [127:0] eb_type,

    output wire [3:0]  r, g, b,
    output wire        hs, vs,

    output reg         frame_tick
);

    reg [1:0] cdiv;
    always @(posedge clk_100m) cdiv <= cdiv + 1'b1;
    wire vga_clk = cdiv[1];

    wire [8:0]  row_addr;
    wire [9:0]  col_addr;
    wire        rdn;
    reg  [11:0] vga_data;

    vgac u_vgac (
        .vga_clk (vga_clk),
        .clrn    (rstn),
        .d_in    (vga_data),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .rdn     (rdn),
        .r(r), .g(g), .b(b),
        .hs(hs), .vs(vs)
    );

    reg [2:0] vs_sync;
    always @(posedge clk_100m) vs_sync <= {vs_sync[1:0], vs};
    wire vs_fall = vs_sync[2] && !vs_sync[1];

    always @(posedge clk_100m or negedge rstn) begin
        if (!rstn) begin
            frame_tick <= 1'b0;
        end else begin
            frame_tick <= vs_fall;
        end
    end

    wire [9:0] sx = col_addr;
    wire [9:0] sy = {1'b0, row_addr};

    wire        hit_pl;
    wire [11:0] col_pl;
    player_render u_pr (
        .sx(sx), .sy(sy), .px(pl_x), .py(pl_y),
        .alive(pl_active), .flash(pl_flash),
        .hit(hit_pl), .color(col_pl)
    );

    wire [7:0]  hit_en;
    wire [95:0] col_en_packed;

    genvar ei;
    generate
        for (ei = 0; ei < 8; ei = ei + 1) begin : gen_enemy
            enemy_render u_er (
                .sx(sx), .sy(sy),
                .ex(en_x[ei*10 +: 10]),
                .ey(en_y[ei*9 +: 9]),
                .active(en_active[ei]),
                .hp(en_hp[ei*2 +: 2]),
                .flash(en_flash[ei]),
                .hit(hit_en[ei]),
                .color(col_en_packed[ei*12 +: 12])
            );
        end
    endgenerate

    wire [11:0] col_en = hit_en[0] ? col_en_packed[0*12 +: 12] :
                         hit_en[1] ? col_en_packed[1*12 +: 12] :
                         hit_en[2] ? col_en_packed[2*12 +: 12] :
                         hit_en[3] ? col_en_packed[3*12 +: 12] :
                         hit_en[4] ? col_en_packed[4*12 +: 12] :
                         hit_en[5] ? col_en_packed[5*12 +: 12] :
                         hit_en[6] ? col_en_packed[6*12 +: 12] :
                         col_en_packed[7*12 +: 12];
    wire hit_en_any = |hit_en;

    wire [15:0] hit_pb;
    wire [191:0] col_pb_packed;

    genvar pbi;
    generate
        for (pbi = 0; pbi < 16; pbi = pbi + 1) begin : gen_pbullet
            bullet_render u_pbr (
                .sx(sx), .sy(sy),
                .bx(pb_x[pbi*10 +: 10]),
                .by(pb_y[pbi*9 +: 9]),
                .active(pb_active[pbi]),
                .is_player(1'b1),
                .btype(pb_type[pbi*2 +: 2]),
                .hit(hit_pb[pbi]),
                .color(col_pb_packed[pbi*12 +: 12])
            );
        end
    endgenerate

    wire [11:0] col_pb;
    wire hit_pb_any = |hit_pb;

    assign col_pb = hit_pb[0]  ? col_pb_packed[0*12 +: 12]  :
                    hit_pb[1]  ? col_pb_packed[1*12 +: 12]  :
                    hit_pb[2]  ? col_pb_packed[2*12 +: 12]  :
                    hit_pb[3]  ? col_pb_packed[3*12 +: 12]  :
                    hit_pb[4]  ? col_pb_packed[4*12 +: 12]  :
                    hit_pb[5]  ? col_pb_packed[5*12 +: 12]  :
                    hit_pb[6]  ? col_pb_packed[6*12 +: 12]  :
                    hit_pb[7]  ? col_pb_packed[7*12 +: 12]  :
                    hit_pb[8]  ? col_pb_packed[8*12 +: 12]  :
                    hit_pb[9]  ? col_pb_packed[9*12 +: 12]  :
                    hit_pb[10] ? col_pb_packed[10*12 +: 12] :
                    hit_pb[11] ? col_pb_packed[11*12 +: 12] :
                    hit_pb[12] ? col_pb_packed[12*12 +: 12] :
                    hit_pb[13] ? col_pb_packed[13*12 +: 12] :
                    hit_pb[14] ? col_pb_packed[14*12 +: 12] :
                                 col_pb_packed[15*12 +: 12];

    wire [63:0] hit_eb;
    wire [767:0] col_eb_packed;

    genvar ebi;
    generate
        for (ebi = 0; ebi < 64; ebi = ebi + 1) begin : gen_ebullet
            bullet_render u_ebr (
                .sx(sx), .sy(sy),
                .bx(eb_x[ebi*10 +: 10]),
                .by(eb_y[ebi*9 +: 9]),
                .active(eb_active[ebi]),
                .is_player(1'b0),
                .btype(eb_type[ebi*2 +: 2]),
                .hit(hit_eb[ebi]),
                .color(col_eb_packed[ebi*12 +: 12])
            );
        end
    endgenerate

    wire hit_eb_any = |hit_eb;

    wire [11:0] col_eb;
    assign col_eb = hit_eb[0]  ? col_eb_packed[0*12 +: 12]  :
                    hit_eb[1]  ? col_eb_packed[1*12 +: 12]  :
                    hit_eb[2]  ? col_eb_packed[2*12 +: 12]  :
                    hit_eb[3]  ? col_eb_packed[3*12 +: 12]  :
                    hit_eb[4]  ? col_eb_packed[4*12 +: 12]  :
                    hit_eb[5]  ? col_eb_packed[5*12 +: 12]  :
                    hit_eb[6]  ? col_eb_packed[6*12 +: 12]  :
                    hit_eb[7]  ? col_eb_packed[7*12 +: 12]  :
                    hit_eb[8]  ? col_eb_packed[8*12 +: 12]  :
                    hit_eb[9]  ? col_eb_packed[9*12 +: 12]  :
                    hit_eb[10] ? col_eb_packed[10*12 +: 12] :
                    hit_eb[11] ? col_eb_packed[11*12 +: 12] :
                    hit_eb[12] ? col_eb_packed[12*12 +: 12] :
                    hit_eb[13] ? col_eb_packed[13*12 +: 12] :
                    hit_eb[14] ? col_eb_packed[14*12 +: 12] :
                    hit_eb[15] ? col_eb_packed[15*12 +: 12] :
                    hit_eb[16] ? col_eb_packed[16*12 +: 12] :
                    hit_eb[17] ? col_eb_packed[17*12 +: 12] :
                    hit_eb[18] ? col_eb_packed[18*12 +: 12] :
                    hit_eb[19] ? col_eb_packed[19*12 +: 12] :
                    hit_eb[20] ? col_eb_packed[20*12 +: 12] :
                    hit_eb[21] ? col_eb_packed[21*12 +: 12] :
                    hit_eb[22] ? col_eb_packed[22*12 +: 12] :
                    hit_eb[23] ? col_eb_packed[23*12 +: 12] :
                    hit_eb[24] ? col_eb_packed[24*12 +: 12] :
                    hit_eb[25] ? col_eb_packed[25*12 +: 12] :
                    hit_eb[26] ? col_eb_packed[26*12 +: 12] :
                    hit_eb[27] ? col_eb_packed[27*12 +: 12] :
                    hit_eb[28] ? col_eb_packed[28*12 +: 12] :
                    hit_eb[29] ? col_eb_packed[29*12 +: 12] :
                    hit_eb[30] ? col_eb_packed[30*12 +: 12] :
                    hit_eb[31] ? col_eb_packed[31*12 +: 12] :
                    hit_eb[32] ? col_eb_packed[32*12 +: 12] :
                    hit_eb[33] ? col_eb_packed[33*12 +: 12] :
                    hit_eb[34] ? col_eb_packed[34*12 +: 12] :
                    hit_eb[35] ? col_eb_packed[35*12 +: 12] :
                    hit_eb[36] ? col_eb_packed[36*12 +: 12] :
                    hit_eb[37] ? col_eb_packed[37*12 +: 12] :
                    hit_eb[38] ? col_eb_packed[38*12 +: 12] :
                    hit_eb[39] ? col_eb_packed[39*12 +: 12] :
                    hit_eb[40] ? col_eb_packed[40*12 +: 12] :
                    hit_eb[41] ? col_eb_packed[41*12 +: 12] :
                    hit_eb[42] ? col_eb_packed[42*12 +: 12] :
                    hit_eb[43] ? col_eb_packed[43*12 +: 12] :
                    hit_eb[44] ? col_eb_packed[44*12 +: 12] :
                    hit_eb[45] ? col_eb_packed[45*12 +: 12] :
                    hit_eb[46] ? col_eb_packed[46*12 +: 12] :
                    hit_eb[47] ? col_eb_packed[47*12 +: 12] :
                    hit_eb[48] ? col_eb_packed[48*12 +: 12] :
                    hit_eb[49] ? col_eb_packed[49*12 +: 12] :
                    hit_eb[50] ? col_eb_packed[50*12 +: 12] :
                    hit_eb[51] ? col_eb_packed[51*12 +: 12] :
                    hit_eb[52] ? col_eb_packed[52*12 +: 12] :
                    hit_eb[53] ? col_eb_packed[53*12 +: 12] :
                    hit_eb[54] ? col_eb_packed[54*12 +: 12] :
                    hit_eb[55] ? col_eb_packed[55*12 +: 12] :
                    hit_eb[56] ? col_eb_packed[56*12 +: 12] :
                    hit_eb[57] ? col_eb_packed[57*12 +: 12] :
                    hit_eb[58] ? col_eb_packed[58*12 +: 12] :
                    hit_eb[59] ? col_eb_packed[59*12 +: 12] :
                    hit_eb[60] ? col_eb_packed[60*12 +: 12] :
                    hit_eb[61] ? col_eb_packed[61*12 +: 12] :
                    hit_eb[62] ? col_eb_packed[62*12 +: 12] :
                                 col_eb_packed[63*12 +: 12];

    wire        hit_hud;
    wire [11:0] col_hud;
    hud_render u_hr (
        .sx(sx), .sy(sy),
        .game_state(game_state),
        .score(score), .kills(kills), .lives(lives),
        .difficulty(difficulty), .mode(mode),
        .hit(hit_hud), .color(col_hud)
    );

    wire        hit_menu;
    wire [11:0] col_menu;
    menu_render u_mr (
        .sx(sx), .sy(sy),
        .game_state(game_state),
        .difficulty(difficulty), .mode(mode),
        .hit(hit_menu), .color(col_menu)
    );

    always @* begin
        if (rdn)
            vga_data = 12'h000;
        else if (game_state == `STATE_MENU && hit_menu)
            vga_data = col_menu;
        else if (hit_hud)
            vga_data = col_hud;
        else if (hit_pl)
            vga_data = col_pl;
        else if (hit_pb_any)
            vga_data = col_pb;
        else if (hit_eb_any)
            vga_data = col_eb;
        else if (hit_en_any)
            vga_data = col_en;
        else
            vga_data = `COL_BLACK;
    end
endmodule
