// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jun 25 19:22:38 2026
// Host        : LAPTOP-6STAFKCC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ font_rom_sim_netlist.v
// Design      : font_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "font_rom,dist_mem_gen_v8_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_17,Vivado 2025.1" *) 
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
  (* c_mem_init_file = "font_rom.mif" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19104)
`pragma protect data_block
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
Eo2JfyL/eojX
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
