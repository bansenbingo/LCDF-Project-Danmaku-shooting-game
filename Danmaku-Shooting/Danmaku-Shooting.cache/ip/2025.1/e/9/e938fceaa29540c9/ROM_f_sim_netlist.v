// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jul  2 18:35:46 2026
// Host        : LAPTOP-6STAFKCC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ ROM_f_sim_netlist.v
// Design      : ROM_f
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ROM_f,dist_mem_gen_v8_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_dist_mem_gen_v8_0_17 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 17040)
`pragma protect data_block
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
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
