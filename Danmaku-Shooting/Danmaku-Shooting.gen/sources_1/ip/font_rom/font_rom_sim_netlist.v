// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jun 25 19:30:13 2026
// Host        : LAPTOP-6STAFKCC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               z:/LCDF-Project-Danmaku-shooting-game/Danmaku-Shooting/Danmaku-Shooting.gen/sources_1/ip/font_rom/font_rom_sim_netlist.v
// Design      : font_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "font_rom,dist_mem_gen_v8_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module font_rom
   (a,
    spo);
  input [8:0]a;
  output [7:0]spo;

  wire \<const0> ;
  wire [8:0]a;
  wire [7:1]\^spo ;
  wire [7:0]NLW_U0_dpo_UNCONNECTED;
  wire [7:0]NLW_U0_qdpo_UNCONNECTED;
  wire [7:0]NLW_U0_qspo_UNCONNECTED;
  wire [0:0]NLW_U0_spo_UNCONNECTED;

  assign spo[7:1] = \^spo [7:1];
  assign spo[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_FAMILY = "kintex7" *) 
  (* C_HAS_D = "0" *) 
  (* C_HAS_DPO = "0" *) 
  (* C_HAS_DPRA = "0" *) 
  (* C_HAS_I_CE = "0" *) 
  (* C_HAS_QDPO = "0" *) 
  (* C_HAS_QDPO_CE = "0" *) 
  (* C_HAS_QDPO_CLK = "0" *) 
  (* C_HAS_QDPO_RST = "0" *) 
  (* C_HAS_QDPO_SRST = "0" *) 
  (* C_HAS_WE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_PIPELINE_STAGES = "0" *) 
  (* C_QCE_JOINED = "0" *) 
  (* C_QUALIFY_WE = "0" *) 
  (* C_REG_DPRA_INPUT = "0" *) 
  (* c_addr_width = "9" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "512" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_clk = "0" *) 
  (* c_has_qspo = "0" *) 
  (* c_has_qspo_ce = "0" *) 
  (* c_has_qspo_rst = "0" *) 
  (* c_has_qspo_srst = "0" *) 
  (* c_has_spo = "1" *) 
  (* c_mem_init_file = "font_rom.mif" *) 
  (* c_parser_type = "1" *) 
  (* c_read_mif = "1" *) 
  (* c_reg_a_d_inputs = "0" *) 
  (* c_sync_enable = "1" *) 
  (* c_width = "8" *) 
  (* is_du_within_envelope = "true" *) 
  font_rom_dist_mem_gen_v8_0_17 U0
       (.a(a),
        .clk(1'b0),
        .d({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dpo(NLW_U0_dpo_UNCONNECTED[7:0]),
        .dpra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_ce(1'b1),
        .qdpo(NLW_U0_qdpo_UNCONNECTED[7:0]),
        .qdpo_ce(1'b1),
        .qdpo_clk(1'b0),
        .qdpo_rst(1'b0),
        .qdpo_srst(1'b0),
        .qspo(NLW_U0_qspo_UNCONNECTED[7:0]),
        .qspo_ce(1'b1),
        .qspo_rst(1'b0),
        .qspo_srst(1'b0),
        .spo({\^spo ,NLW_U0_spo_UNCONNECTED[0]}),
        .we(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FdZ29m26W1vj+Cs/DLJCoTOUz/m7+OJG3sHOgt5s8NEPQ5FHtOFz4fRgqTgyrNzvNq21lk0VjpX9
UMVEbSXbJrC40crYnx5XneHRwr6z9uk6MXgKoH1FHcznnKhevagwuCchTCpQ6oqoMbhzWd2QHx/v
Pkor8V47KvEBnEHja7Q=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DgywwNcpeS8jND8bxEa71yZJ3FJdVEzcLynb64dnb2TzUo3pKSGFBfaFrgTZF3YNHGzuUJ2QQktc
gOS5J0CcVw+n+aerigILzjTclkLc9eUIulkdUapbmj6Staw/UyV8tYP4SZZ8/c285RLhOXD7yU47
aByWm7LmxxWjooRAz26ybpmdt7lpHBQaNTc1Ljp9oCyvtSqxXf5Fzr6NwE9wCWHGozsMntKGlBWq
/Ld4jJ9UVtrIM3FKdUF21rHccua0AApkyY92z4umdT7kj4mZxPKTdC7zYiKWRUq2hGAlbh1z47nC
oAaSpPvOVZY7BQppznHPyLPhJ+OgKj6/rfTVMA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
TpTqgO7LVAmk2RI9B8mgZrp5H21SnS0bmTRlpg9WONkWIeKkOMiqYzKXNi+GTasTvmpRPk/h3m9P
wkWG5aX3dHNZUb1oSMhjGbyAcJpO+SX7mcsmzpt+efdEtPDukAHegpQfvEWKkx2SrrkkgD0X++Oj
CaqCq5FvcRl9RjvTxK4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
sckknZF7xLyHpnPIcxIFLiAYqXW1FY2CS9FWi2Hqz5vcUlh7by0h8yYiwSXxIUNrBJPATd3AyESC
487cvtya2VioL8riKucCJWyqQBG7eDyT0O7JtdZYcpo9uNh6dkN86IV7J1BLYVlk/Z2uc+LRdLiA
I2w8Z4wc+UHp3wx4497iJfYpHaKSPNO+8A8WV/JJ1mzSLBI14cO9CDFly9KlHktwr4HKutMId1R2
VPSy/znW8qx9XUnd0EN31c/9LJnfU1yhBPG9Wx8Hd96IBwI9D/WgN7ZQyH8bSZCcHX+SYoIGPwXn
K5ZKQy1K7ELwUBUUPbGlR+ir3yvvGjob1CTeMg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
T6BTO2RUQcpX9TpJR2JO50hT+cXyiDyIjrO2Ps17SKTmMhVBfSGD2AUMwzKJINBU1/wI4nqsnk0R
B5YRLWXrZfCSjSapre9CmGTRvLCDEK4mm3l4Jo9Ij9iBFg2OvLFfyBLP/fZtLtzCPHtMlTmKn7C3
9Ert7v3yDGnFF+1Msw/UpTjpdSZ4dNE8UGUe5ymCwpDVeCcYuoCTBe5o7BDlcM6cbXMfHvxQkBDH
BQkO5txX5aV2qeKOYfWQucZe9q7aoq4zcNG3roo8G4OrO31xnxdwAQU8tvOCztoGHXLSPEwLy86h
lybMIS19uovvmz2FF0BKAfQmf2zT2kdhs/0E/g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qFdGo2cl1WGkQBqlM3e3YM1+NstrsuheqspzsHjhiEdsfZE7cNV3QtgmcPm0sQ6Ur85Vr+VLP+qi
kfkSBZv/cp96m2VbdU3wKRoyTYzTU2jPpW7sGFFNzWS9+RUl8sTVLht5d4t2CNOGni/aTPg72L/m
EMDSFNr5zmZHrz9ZfvCDtOuBIV7kMLfZPmDdxV5IwsKMxabGnoXOJGz+hfjGo4fS3o0ORBwIVK+l
mvU1GZj8rJVgjjtXmyh6mIw/6PchaANzWFqpNusTs0IG2f3q7OE0VBOM5Am+iaDdeW6TlD3NJO83
Fu/vCJwu/i0r7tthiRGj94Azl8RnEN2KK7tBlA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
g77N+3QvAPAYw+4OcZm63AqmcCkwUoxBBbPDHeq2Nfprvo7Bj7LixjYXj3xyrnR8haey/83rTRib
U8uD29Fgb15vpUc0WthyXJ59GM2fKf1KCeTQtG6TwZDLuOLNJNaeGFe+JU6iYvvLnOQZ3aPsmfcT
4GCJv1sKrMCf5d2VkK5yqBhV9Xik8ugmxG6gW1xkr0ULwrG4CYrZAEPhwUoiL+6RLajwaMyW0fhu
TihpJjKW17O8yAizfvC4zdrTR7abBHMBRX51n0fYXfSNTJZH84wlEZ/uaRGrT3tziopYXWPsmWSq
JJ5Q30ZViY8s/kqmcILk7jzkE5iBk7FfRk2AHw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
KCCTN2ufL/SeejpVpXJmjN/FwrAflQw79fl4pWJPTrncXR+h72Z53BIfG+PPQuyFWo2dT+31hFh2
sUjBKcBwHP9yjxsmRjhWVA4YtsuTiFCa3GwHalwHMC9EJN8EOmcee6T0DD8eKj13S7DJ+LDuhg0a
CAhAdS+Z3c57AAFhfKZ64/xN+dwK+7T+oXbmBDtxKw+D7VXMZLVjJ7ozXveIocAFo9MLpyq0mXPL
m47fmY77h7JdJ8BnZ0qXpublK3I9ahjB6+iTR7hAu417IqmFRnmc0ICovANVgmMBsOU54gzqFRS1
4jIQ7pPGSuMMJ5F+bWiKn1kahxg2JXS+3rf9r5Jyc2Ht4bO62YYec93HOrFxzErn9LzUFSvXe8JC
M/OAkWw+gqiiLbQsh+1Hfn4j9JSiL/n8yCkGXAr8x/vdfzkIBv4QpsSo5rGTuXS2x27KOAsuV7X7
maV86bXDbpBaMN1hZLtFkWNpTJE03j5Hq7cTDh+EySOe2NSwB0potFkw

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DB5hKjvS9FmG+/wPMbBeHe5M88req0CpR1ooQpQHlIx5dQoUMI8l84F0JQ8hAkUaWLkU1VXXMNmW
eRJoUf6rnT4CbNo5SFwNWSXohTyDSupMazp2OYDlVlTgfUyyJ+lVIViRHiC3vIbi1J7fLoZ1Bt9F
cr98l0aF9q+NPMPI9Xs8X4XYYXL9FyHNyb3bAoEI1OPmH5ywFB+fJ73hp3aEXHx9pcl2RKryf1m/
Q98GVV/ZXzQmgGNEdveABCSK3XNXC0Ro6IHFjACUVo3VTsjMMx1k2n+MWq7Zbp5l8ZcvX+F+NHY6
q/Cm8B96kJQ4bGZ0qnzIYoKDGY7YEGWVJFoWQg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19040)
`pragma protect data_block
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
DEI=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
