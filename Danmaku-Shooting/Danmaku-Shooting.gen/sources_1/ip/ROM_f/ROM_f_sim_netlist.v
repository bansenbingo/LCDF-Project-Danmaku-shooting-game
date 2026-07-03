// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jul  2 18:35:47 2026
// Host        : LAPTOP-6STAFKCC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               z:/LCDF-Project-Danmaku-shooting-game/Danmaku-Shooting/Danmaku-Shooting.gen/sources_1/ip/ROM_f/ROM_f_sim_netlist.v
// Design      : ROM_f
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ROM_f,dist_mem_gen_v8_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module ROM_f
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
  (* c_mem_init_file = "ROM_f.mif" *) 
  (* c_parser_type = "1" *) 
  (* c_read_mif = "1" *) 
  (* c_reg_a_d_inputs = "0" *) 
  (* c_sync_enable = "1" *) 
  (* c_width = "8" *) 
  (* is_du_within_envelope = "true" *) 
  ROM_f_dist_mem_gen_v8_0_17 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 16992)
`pragma protect data_block
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
XDgy3l74
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
