// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jun 25 19:30:13 2026
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19072)
`pragma protect data_block
ayaj/sm3VgDpSuSDd7tVbbOQi6UdG4DkbMl1bby33GWsYGc7BLgVD8S7gKFvEpw1FYoUzGr7N6nT
Uapo6KqiLZ2THiPF1jS+z/BGramTESFXnLG2N+l3mwJ9OWxDkyM8WOcp7hKl4uU5GQ6CFE6Krr66
jByafXjtUW7iQlKw81eaSqjj6CinIO5zt19qCKXRJEonqcCag43GcODfNGKPtb/socTYWH/ytXIj
T/IHRFLoJ0CTw5Z7a58IfXscIkpllmSrS0FqE5JHz9tHQas0D2zZepQ9PKCIIu3YZmBWVH8KM2xB
/v0UpujOdkfzPwzmh6qXGjMdy0Jh2iK5a80kYZ1v/RsJDlsJ5XYTM+9sQ8QV/BjCqa60uhxnfVJQ
7HpJ+Vzourv+YRUT+1Xm7vyujkJaIgDN4ChxKP1nVjGXBjC7QqjZ74nfVLhm7Ay+Od2lxOuIT4fj
AQY15DzjmhJbJVZMxzfE2YJBp8d0NHRvJqNj/FbHqtAPEKrGf5Ge2PHpaPtKyJxv1rmp7IJ5HeNZ
8YG+1rWglbPdxgAUaFE5izfbL+6awDpXHd8f7xN4TWBi+4hzlaWxENq24J/nHBOe9pK53STGjW9P
89oI1e+qVCTQjAdbDoE0F/DdREtGShamS/ef8f795pfIDXvMNMpkwD4UsIEYlkmNzQt+/5ojcPqh
abXP4qjTf+2XtUZP9SmfC8+jVx1zZeettRCpZH5gtfg7Rb2ZT+yok7vV6uPRlr5Pni+7BPFxFur3
ma47ZCNCZOWprJJE6+tYPIsaYfmnCQDcq3jReKofiaSWIKdGCeXuZJS64dKrw14sTe6+cZT5M4i1
OJoE8C9t70w/c3b8WDMZ+MZL1oQosr7JVZj1K+rKwbckhvMUv6+OYdblMECzRvQOjIw/hluTU750
O+2daEjEqupm0G2oCC+9cF5VXtJ82KEAz31MxAKJlpQ6AHT3vJROqpP/37wepYSHp1MCR0UCrrO5
UEdrJNmowJA1lu4LLyr+xSSZseH94TAQfVAPiYZ4ipsn8zkK8NzLnHToMVknDGP04o7qoNfhX1X7
SVXAcR+t39UXh97JHX2uqesgwoF29u7brYiJMP6wcI5vzyiZIO4IFN5f5d6F+Xk1tTTm4IhhGJ8u
nDYEDL+uqxIi2ZWvc/e5Liw8muRYJfLkRc/hiLN/lNcUfHzkoRI1YmIWSd3vjCn9Drkq9icR0H0X
aicwUO1N35nXTMSydu++T7Lglb9NmtXAny8T6a3X32QaxYycIReibjSN9zwYbYU8sFn0oGpECvnw
SCLJBZaoKKFQctEfxohpUNdGFhDxx2ENQIW+B4yAFVBypNHWB1B/CBdnhV6OioUyimpR6b/pxTnC
sHyyjiI0uphpAftnFwZ23Zt3ecjsGa5TBJlJKq55y4bvjhPsx+G5nU9/v9Kms6iepWxM3HGwfa5X
9sVnM9xDDG3v4at8OUyfvbRD+sEDlJPT3aTUOmjUxyvJBGarVti116ngU8Xdu+MrEZhxipoPcERP
HXEVLbDYVKsk6ad58TE5FFdQen86C8KOweQltkg1EMYhyWKqdimmOUeqMH7iguoPQPrYy2n0665w
/LrPz5pfzizYaNsYbvPBWbfFReZ+/FtL8bOwcv/0RPcPxb5iBN/aVRpgoERLWsIwdwbE7lJkUeRy
izissVS8SwlGOWaMAEPawEocMrv0HGO9PjExJ24mgiQPodXLk1bUBJsl86dvPLbXdxEh8pDb5qSm
dGZd9BsUHWBY+EwiP45WI29e0leMQaVZn8NfKm9+Vz7SQmASw5EWcB/oGcq8fBZe9wAWlkA/OaOj
J7jGLFS0GjH0t50ZkEmpuOFwGqa3PDpo7uVuplJWLcAxQ7mUBdwhJstaEivSSTpGzG6gYp4UYfFx
EVfVDkr56M6G/4iOCWSc3bBgquFIwcezkqfmcHMRJqvwPTsK5f7deri++GFSFQOVLq9tJFg2hWnD
0okndLbpGc43J7rnwhd/HGZd+hGxBBGePP6oZ5w+/XDmtCx15QIdydqz4qhTXSC67YE9nUHxmd7b
LHAWsFSuWhYLQxPLu0BZb7FDZsjHFV/gFBAUq3dGHz1fe3DgqLeQJgyVuVBfKdJn+FCwXzPjFcIq
9yV3BsoOee4t0bm5MFqdQahtWe7flG8XOcpeVMseDMeb3LT1UEz2U0sCwJrFIU2KUR043Jl4B0Jd
1PYwYaH9omCXsD8ZCtTqi5laWReFpbb4neJVFivG3k6IT+gtt1HTlKUKsGw0aRJSPuNu98rRhKGm
XP0rHbrhLFBmYfaUyTOoBjKkLDSNjAK3RDmMA93Y11Ry+QlNGgJwPLNdcKWxG48VqN2l9pJL8B5B
eMT98trMNlhr6+iQSk7fSM49ENeqGmgCliSkzKJ9op4OO4yOL+8kYMV1cSARntOHmH8yjuHplX8a
bRRKh1RnpiJO14SdOlkGUKf8kLK+4wdSdJeUxO05XRoLAvonPMFvHRJrdItyB+1SrNmaChMmsWJ6
nI0G5RNmw3AnNlerqyAm+6euj/hBLQexRXtfHWaTrcxUMqwtJQZ5p3R0wy2Ndap4ynkoCjxb2+nk
euU+NN0WKXnQtaZYpZR9b2zhnR5T8YgHJwtzXrVPQcqhUHvqIzcz2CTly8M/X5eUQO0EQ6cg7ZLm
8rSDSjaaRDanuNAW/M9/EW1dc+FyWQUQJFBqLWY5Vn6r2ZUbcHvZYz+S7gbz1yDdWRyzoYGl5pyH
gadrhKNssIMNES6g92uEb1zym1rfeLCJndtHJHYTbKQDIzw2vLLZXhYQScdjMFcJDQTnWGzoVl1L
pkamkPiGzrfcUu8BgXgEOH6OX8jQWDj0wchBeJDYw8jElXRrYY3Fe44kZhD93mp/n0BHdXZgyfi6
1Pu2Om6fiTAdVO4g5nHKXEeeWOOytp5Qfkfl4JB9rVKdNrilUviiEaI94mRldUpeSGuPr+0dZeZz
OxfPnWHTUzcdqa6EtYwb+3Z4eMjfncqokf+qV+2Y0+SfhgVZtoc9sEU9nFEokyE/RMq1STJIL0Wp
Bh2j4UrjbvwIVPpaFkUlkJBa/hx/wqIgpbz2wbF+Tp0lRBN5cOQ9HWj5K8fuk1xBcpL4GDamHvY+
V7GvEMht58h2Yy8iVbIiLvt6K6hBU+eauujIp+ghaw8N8WxXvu+8XD02C1jNbP3QbsKmsbl51kDW
5LBDRQiyTDWD+O2NSi0cb8Z/bxUMVozwoj9nAPVvBrBlx+HP65Y50lEbwcuOOHzBFlY8PkK+yI4O
QvPx9i8RZ/1/Iy5tbDjMxkyg/WT/ByY6Eqr7MwuOGl0SDGDbhmkW87XiTVqD1enhu4712ErkjByc
+qr1bxiZ3fid0TyZcy4Oc7+UzboONkplZn6K/8bu4nCZlCPNu9u/cdh771VmEsGSe80zYqX+u5kV
NyINM/zkF1vL3LJKfxV5Ntq2bBFM6FfE206m9ZM8MvISU1J9epCUQGG6/odD5An8+qrpsXI8orR6
aDNsnkxiOt8tu+7LKqSYEC8b8QF4yxtGgNOyW8nSLddkNv7ljCK+MUNeTvd58dC2rgYfVqBgtkek
14MhksQhyVX7/xAHWWM9ycU1jWYYWCyO/FTJsh11HwJr0qo6FZBkTPNUtHtv7/hNwwTyvXVGFmBF
9CxSFp1bc6GOM2RzsOFL1Y4f1UjAKSXPdRDKp13XH+Yy2uIxFPPLYl82olXgnCZAekTRkKLnNQpZ
1Q1PcvpLkw+v4r+xzGPRXC1HewC5uFeDa/5TQ3Xpr+7NzWJq9RwdubOhYUG7sEsw7uTWXbinMMCo
sje9sPwAIDqdmiadXhj9/Yf1aNhcMvqB77D8LTlnsFxMCXSpKrOONOnZhtpIaynaSuqS25qLp+08
AGpQgZIqQf7MQAp6u5sLdE1wo4+nQEIqoqDxBluwSXyRyk/HYGlOwvPrZLZ5ph/GqjgxXXfwieSt
1d1qFMChF25g0M63jMHMuQ2m3AUcSv+DT4U4JnbA7Av96peecPZ6Wj0jouBMSVuFZgSe53rfQbEk
voqv8X/3K2MZP9NJH+QpiLDPiAZIFR/k5LZ3BI4YPZ33Nt1YwW4rSJiOrSfBXjFsO+295ZvnI4r2
5gzAa6LcojyiGjqtJgIy7ZxkigfvNeVoaSqasxtkW7l9o6Wpfu92k+B5bYjdC0fMxj5M5Avt/Wrh
xbOK4douGpf9d6YWWXFQW960fwybTfquE0xfzPJs9I47j1jmFczlcmIqlBUyqHA+LsWtp4vjD0R0
8Cw7ouc7ASIGNEZ07Lc9mfXznG2wo4uxzXgQCXZJfE31Dg/CmStOx2jQJlLpaTfzoDE98pD51B7T
6G07YzDrejAoV6sIttdPSY4R8fwelg6twMSCg7CWbexW1HHiAEer4L7e9ypOITRxe6uQtIRoN9bP
8NqN8gj0/gocJqEmjba86MpmaVpT4YhMGhQzzWJsMqoeulqTCX8ntBT8RmUdhybt5GBbp3H37P7b
8p4Uscp8dVTgctQn7lWzl/BtC7v2CafjaqhOgQG9Gr8IToEuooTW4L/OeICIwPOSmwXeq+OfApnN
RmAfi3QmpkFoAdFbhGAQwgJbt+Gz9zmggLihWGxS53OhgyNY46Fo30+0gks2wRihlLXHZM/SlonH
lCULMue4BRKyIOTFdXwtZtz22SjeHaVFsU2pofXtV41YWjeU39M5FogcUg6/kGwyVmwU+SZwrN3h
VgO6kf40thgbkh+SZClQhZfhmzCcsefZcP5hBxh/OSXMuEzTWFtAr0YQR5jcBCYxTI1odW8hjWbw
Skd7LKWX0m4bV8TA/vcViMq/63CYrXwoSV/ltpIvetXcljyD91h6yLhazAH+sqbIS1KVvPWoFL1H
lnbBtoeE5HMfSL+SkOHKD/W9pAGP2b42bYyOYKSMNZcA6hLTA9s/SHG2sEWAlWzv+aD5jXe+vhOl
hSlkwPHDToFWlzpEZ3kiEeD0T+uTYR7XnlqD2MSb7RLp4tLfrLQt9zfF8JT+VzsQPyoqx4TMfUf+
+hPHEgiVhYx9B5itkvjNwapINaZ6WCN41ouc8slYeu42Rvt8Sryn5ZQBusL68AQgSQc+DmokW2Z8
L9YDUEo/UZi1Sm7W4SoxW5F1mrS/pQROAcwcLwBnbAdah5C76w16SwQb7+4Wuq/EzBuxOZeclJuq
1qxPHGNEx09XyLWP3Xv6AZtqW4Y46K8XjGb43dpCNYxV6kPgwrnQAy/KGEPrr67ja3RohSAUgyYa
nagquTAekZcY+NYRd/NyM2z4M4XtkbN0ldmokSS+q5Cv0OBLOl4OJw61uFwftgfIA0b71CKdmaHQ
zpl2MqIkpP+Z6cUtMDjWTiccyJwwiJUJeUNY6XlZCshZkChIcOmKz1dJ6Xsydk3EVpiv9TD5j407
TYtdR/IK8GqObgK3rwkAbxI2QbxRHFqRCmleUvqzlCzEAFbKSXKy5LSI9jCmMC9iFg+yGO40yIA6
hJlQsaSnva/wlSzEz1c8mjZ0zASj/m+PpihLLqjJyIgpZh4i9pXTffiOq8wpkGeCuNrZlpGvm8eO
9d4lTsMAwSMwbDBoBHwtqGdjUEnwIFgBapA9UsAQ2fzAvGkjTjEse9KH+D740a5tcUpr8VDNKjof
iudQi7YlcuxG1S2YSxu02JgZzT2gQKWtcyDyouGe37LUYIsG+/K3AcWJIDwYqi9iyZ0+0k4P0CVS
BveOHXNjS52b7v2LVUZbqsId8w4sViHKg2dNZXzdedXKgqaTNnDKZPq7e2W8GR4XcVEjhXpuZgji
BMaWTc/O6TZTAi1hl4oDNtDdfA4xQqKp0yik/pp1kt5QmSFMDB1DII+DpuRxEjUssJT7nN9xJ8Pg
ItU98mqMpIrg+z1Ic9ZTFAuH6UgPUZf0VVa/1PhC3L7/GbHgjzUr0/HSSbpf/LWeEUcSIBC13VjQ
Ek7PWRSAmGnEQ+wpbm+v8h7iFcaRnvNPvLdACDY9Hr213zv03WegkxyLNAr2gl+r74+vvGUmxZRr
1ul4vn7n96939a4kg2XfkdvWzAZ34KDpAW0jcnb550nJIJ2NG8ju2cjftDsZN6qjagmO6EZsRB4X
wnqN7o081xkeLnqE6yRMQm4a6sHdSsKedeVQc57GHUTgycc6J8jP+ROqiy9ihUrJtXlkVz3U3wis
Q0ul+yaWqckbfzWYcHETSBTBYhrY1E13QcfyIMWvRAeuK/k7bdVcB6iq/KNCjEjDQVJNfhTrkziU
Nx2dSDN6ACdFas1/5StW8QMh8Y6fyJFvPcMgHE5xwmP3ckCXs+cLRu6fNMFLYEeu0pZGaijAt6kb
hCavs+YbWLmXwlI0Upa2OXPbF9/A1bQo8HAbJekCGXnevEWKQTFytSQnSjqYof1SFBgpyHtsPtBc
Vq36uacg9knHSUqHF4/9E+JEMq6x0ycq4MVRGnSIQ59NYTrgq1uB28jNo/dR4E48iDYwGw6Aq2Ef
rU1tTF67ViEDDLGZgqrZNvQJVX7Szzo9Z5smyAAWd5SlFrwYkYGtCfxsc/R64fp5WKAybQzkeF5M
t3lxZMXWcy/HYlPticXMFytjd0Fx99f7aKtP9KXUE8/2+N5Etzlgp11ynCC/TqyBcZTNo/wjO4hC
hUk0vWlguzHfS5kKguAYPgPYaWVzFi9h3lACnwnqOvEZmKfNh/Xaopd2M+ztc4r719BEgY0xsWtV
98Q74wh/G2Jwxx+H1CEFaa1+w3qWACEorGd5BzbYGNg3HqA0H9p5R9PabfKgF/MCuHdM1A/5mNvl
X0RbOU0Bw6hXM5RUhyccd89fNgTbnB4ubWvsw+WtkyalfFte3s/qcCINId+RwpLmuJ8+/+nJpjh6
nOacpJPRiasUuBiVNZOZEPa90WfJKkVyvseKtWehYBjQ7eyQ8950iqF80ocpUHb9lLP/CZfoJSNR
FYEJ9ZRs9JbyBigCOFEaSt5cPiPbiiZn6Xe+c1AMynmxTH74NZxLUmmF/eqjR7dMN+gAhAdSLNUg
36BBX2IBzlZ1eyA8675X+BShxjlQXLDkUMwn9XYvx2WPiKd0euNEQeiUrXD/1EKEKFi8EhXXvhgX
o33cgBz0Pfsh7iSumKn+WvLimtQeBEnLMq+fuyy3eoE2I1uVwyN8NLnqw7KWaF/yX97WUXsezFqY
qzR6ynjnY8mw9jkuH0ZFxqW3ApqxnU2c4PYyA+a7JV/GejjrsRyTUmTdMTCLfKycd91BalyASxxV
omUTULDINgRhA8zG1kwBZwF8N6tGCPe16cHGiDjLX/nsZZdyGq8t7774cq7uy2qikki6zNhMy23Y
kRRcArdRIBwn0wY1dSy5VrdbtibqjsNSzmZdoqm+pcZXcUJFIXxylzuw1J/MvwX3c9HiD5ExErQH
en3uflbkWrs3s/qs8oVKXtuyyyi0evLKFaTFsnSW7dwovdk074+4TexCemiSAt3PMbTLs3u3wmcv
2iLLX/cUhmA3K0GLWjzVz5STcgGW24dT6rjJzpxbIkKwXFOTB0ySoi+ZM/6SBdtl7TnyWr2A+Nfg
KKR7bYalBweO/Fh0fzjDN9KmCE2maHED/B7sjXKs4EPot0h4xHNWsGL9itCPThsNeWqbQ/DuzpeQ
N9k7x3xZ3B6bk8rdaP02ctNrsKAaBixXP18j9GdBVQxwEVbo9XCwodB/6gkFG9fQQuqesVndOX+X
uT+FXSSt6O/JXZfPH87NiEVKBR4dG5psathxlo9Jys0bsZJUOMzTfm+6CdvnhQ94VD+LvSlQRv33
mDlS2kzTAiB5iT5+Lol9YcTKC6U3BTqjlrQRn9ssp+/JdOhXvPUhYo7is51Y0Pret8aOoIZQbPqy
3vMch/+KWi45GAYJYWyN9hGB8o7aeq39D4NSS5MOrDIQsbm7+HGfdQ1Bbb3duRsXp2dS6gwTCP7J
SKoCavr4G1vwttcL68d5Y4mampDvT82IZ/lyO9uRyUjgQyKOeBV/WyMa8ZrBTlJKXz46dNZUTgWY
wtrKF3ejt622l4mEZFqOp7cEWzJ7mYT/QMo2QGEpLPE7HTxN4+Pec3Nszd9PeWu4HFOA/gv2A1wp
q2A1vV8z4+b2eBmtX3f/B75M7J2qA0v1ZY6mTJ3s0vMhKRtQCHKAM2tO/g3wiwHWxSt85uBi8mw3
riaO4YeeIW4sVoT+hvsXBwGPu1MukX/JddJPOzJa5vz6uRWsi3pO+a3yIEJEjpBcriJ/aub3LFzW
d5tM3YocvvODZKXcApZ39l832Qkj7FqLYXmaSXZM81zE9Xn/vx62YyQ210fUYqDK1p2iZUN2wC5R
Iwix8eTG0hJHk5Hfy55xM8y2OZGyQhjFwCQjfCpBpNSiOGX8pOuvLts4a/LYpio9f8jtzCyCkEVZ
dn9hGZKf3yvvlkI1+BxzmBl318m1EjIfq8X3Hm9IwO31/J1KxaCiIRJde6rKbp8DScqhYVSsDYpg
vrh57egoSe2ES+MmYdnQw/ADreTK+k9iUbK7cdTQQnxQPZRi4MaEXCQ3OgVCg3qZgKNjOMRsCcZa
APq5/oT3GVauZfY4bZ1kS/MompMYSHpBCrc0WDzMSgPyhtuwconXP6lotgJOuwmzfZcC5bqwPzNG
EY6u4HHPCFlH/Bytc9F/ZeqgRwkWiZUGo7N19+IpGEo9FrjQY90ilz87JAWwI/7GCvD14pXGApM3
4O1jo/boHpyD2pInpVBgfBKe3JwgzqTHjqkS/yeDXa3o9kqPPk0yjiKA9ah9f4sgVPHTJ3wJ2l19
QdcisahqjItl9vNXja1umQMpsl6GyYxgMlLkWPh1jYy4ugRc3rHgWteRHOaouJZidJsbLUAUxrPI
+tt311WCgz0cdRU/3fkRg36UmMsMmO6KJuEaeof/DP+ihB1VkizNkYP6OuyIQIPDrmJqm8H7AL8d
ffG9hjbBqTMRO4kBibI/YqWp52zahfiKusGYa6PG5Roh5P/FUyjVaxA96XmvQr/ymIINeayubVpD
4saroK6CfDxaw+RMp98DznL8L0LQjMbXKefzpGpCd7Q7TNBZKiB3WgcqYzEdH//liJr0qSfeyWOE
wQwKGLssxlGHfhFP8hXZ9crutCvvKInhMmNFsAQyVHHeRaECVtJLmwCaLLnq36xGHvCcRI+0+E8U
orFhOyV8I76oAYNhr+UHAyyXphEmXiJheNxevLE7JB+J2AeNwYu1mKT+ZLlso1ltArxJPyvfLih7
wTb2sN8w0Bois1yJ7gARUGRfUF8L0gknb4i2RoDWGXm/Zcw7NmypJfMT7gKKPnK6X1zVodhjtE11
M8gbQBqZYExIi32SsZbirs5BpeySIShOwoyoi/jAKGZirrldvGv7+E3nfED5RkWFippn2HFMZCci
if9upKDNtJ4vjVSpXqJnVBNOM32H5Ad/WmBG6SLxFH+B6iNK0r7tdKE3hbhAV6OBXWGIIy5qXTp2
kmZ+ywzoEeYODh/nUTRrp6fGIEmfkWqMAtnqALddo99LBdqtGLWg/OZ1y2l+uhUuO/YGl+QQB9k1
ICaCQg/GHMyFkhvDfcdp7/cEh7jI5IxyT/CGvXB4O6ck5MPSz0fykg/0uZbt3eP1vAda2kHBSU8T
F54OQLZXk4VL/1R0xUvjIYxZe2j1SMKQcm1/zPHS/l5zaWRn3NM/HMAI/Knxl2IaxmLgZ+jxeHgz
Le+E4p+1Us7/3FO0W1FVVnPL0Y203DXAJh/4GPnwsIcUzH9aYVS7PGI/rQ7mUDZzVVqrG05klPJc
XAA5QfzZJ6F/VGmt7JZ1QTrSYgsdVOW9hla4xmywYY1k3OhedXDD0UUbAqVVWr/FecZTB2/8Mlem
lNaP+qahXAUU3OVVk8fnnmuVPFhBycTPmZ8mM8584EedMLhik3iCUbnLfs8lrGLWmvoQUG8dlMW7
mi+kykLiw/I7xT/P5YFjwZ4CTuIFJ5bpuyTIo/DR1qbyCHUvqpT1ra7Op42D/rWYXZTeXY53s86c
EFF3t54kE+pVhPymZcn0bFhSlWKscUI2FchMavjWaCa8SafTuh2D8zyzwuC/9rH0TSl1ElBBO1bx
dYQeD/f9qj54VuGLAxl+i5gtCSFozA0kJYv1498gaCuP2fPBP2Ba3cFcua4dXqNDPSrJ2WT8h2vj
wGDFybS6/iyV0tjC3kG7nUr87A8dWXLPMEdqLw77UFpG+Hk8MMroOIEolpEdLpfz8I6fXhd+1HDF
f5+pq5/suCuchyoEPMG7wDZpnow09NZRWsekNLdl5xmC25zXOanBFIgYuGBPhEB5uHhEIYUr/dGa
Mvoa0gV2yki85Iw+/jzGnl2lGihTB0R7xtuntAN/pqGgosxwGuWq/aHutT4u2wuXZjLAztzJWE1k
O69NVlYbgPrImNauaAniwl+BeQ69cHuGPG5ZBrh0eS2fodpK8zaB8BO3K/W4RP2TpcKhzlQhOtCL
19QmYXxSo+DNF9zqpmn2JNh7gXXWZjvI6v3sXoqJLdBp7TQQbeOO0cEDnXTA+nNOshfCZ5NaDLxG
Kg5cWHOnrOqxYAnY+D4wBVy1jEnS8Dy3qioukeQp5i4PIWPpCG7kskCSGsc83mbRCvn288TNZzaj
mLG+x0H9KAfpS9gRmzRd8xCAbKcBDPejPMiJ7fKXGxsd/i8F2sOWvSzi7naedSy+hwZTGJ/jLgSd
Wkx/VBi5/XVJKG4OZGKl7V7qWQlTIP6lC20b9ZAwnmlWcIFFdjjNTiDClwNfEcng0q6/LSyFlMEa
hDvRMTn2fVVvY8dlAgxV51KD8E7WF2vVMWnUQUTabz1vrE4O/byQ0m/rz8qExUYNqlZpNY5ZrDRw
7pUekGzXn2qKgZHVFhwpMUkHJwLnTrKGl0yFY4EIknimDvtveWlmvbzmoDHViJ5rK9lzMtJxj1lx
O5oHhGVrz4cO6AYAJ+7BWR+2ugO9rvbC/9SV9iWVuvRz3yKAjYUMkU7uxXqC0QabvhcKJT3srsVC
Yt624kmsutAcH237kr00qfSgXZDMuc7rq/BhGourCzij8ttt34nYLVpIOz2jKT7u4vppqHM6Tpfi
dFge94UVK2EPupbSffc8N2DQXzjJoR3akZ8pMx3PfnrDJxBFzG9FijpN7ppAfh+dsta8ptNxIY9Q
8pUW68usB/XjLcoP8iskvmHk2wYpF5dkHwCpAX5o3cinoMk3FlIzmyCDCOiltSVWBgKN3ZZz1RCS
Zv8a4t+nMgWCnTAPFYW93Cy92YLZuU8YAhcRaXTy0OFr/EgvBDfRTDf1Ti8gP8xUT7O36TL0AOlr
jbR5TUA07PvqZQFeHru1/Vs0+LVBlTdrOZHnAQAj8aLfdpe4o62YTMPaWxlo3mdGUhbDbtuVOYSK
bccaTDMvPM3OTpJPgabS5B7gYGjp3Md2869g+3PTZ3Q+XjQ408yow4G7JLDt0H1lhzGtX1AN10iQ
TIDCXZ7zprEE08sX+dfQlxwhD71pDPFskuGO+r74uwghM/oZAcmzgDLzTSIvJAD1l50Kge/qn8ew
1qN1BcWJO/3Q4VxEeORgsmbFo4/iLro9YhAOaB5ObSzAjIAN9rLo22rhoYv7LhBWnMbERRZGRsX/
Zqa4pgAkhFfD+hlFXho7ehTqIJHoCFvUo0r84FmqVml8ZTIwPebCPpWD8WjzTg1AuNIMuZnybLV8
vnAQBEhZJnynaYi+kJ0FraCvxRMe5xRv71376vW2SLsVe/l+mnS7x2ZgVj3Vjt9kw5pIp9iUbdfj
ykmOeSVjCS0Wa5iEoJWFCL7oDEMW1lDxaUfXR7+Gqnm8rONQrLYu5e1rgCw8hLQURGf5s+pgZR9m
w8Nt86m9CkyAjx6iyESkHA5ofSfDAiJLfYGHV+AfntEGItRmDRNFhr6WcKFQ5BRB+nll02/UOsa+
VtQNpE5fhj+7rWwGrPKnnBSJ94AaqgALKQd5T4owBzW9Tb388BSiKJqQmzEmjtXPR8f0sVIbj5hd
SIyXw/LpTUIOgqzkXQZWhxtx+sLzs2yVPybel6m7zvDIBGxauxDcyoPfergpfdGfes5gbsfI4z8Q
elT3Q24UVvBKfTHnIhNYhet0bpKEXBNqch2eaFfovNTFSfCpn9KvjeQo3+nT/wllt1Az4f/obPf5
nqpNSdJuA+oPrWLR6FOwrub0P0dGrE8aEbUkZwFeoMXIdYjbOjBOo1ao9gc0SSVFssHAYSbQ9WZk
UKPwcchMcQ94SvM4oizVP/LaOSjBRF7AEBQP0Jyvv1avxnhjotmm90vUevDKiAAeAahZbKeCb1Zb
NBMEhdqX6WJcPP+tyGDfwhZurAtvJxn77qJ3rzbizqloU5gulZzAfHMht8HulWU/hpQLlPKvzy57
gDP5dvtjQAktEAqL/uwSoe8iiUK5yz04WfZuntdBG5WJTybqvNKTP3njB+b0T1fNAKpgowPHAxde
GJZquDbTTqYSmR8H6gxNq3CQxYdt4RHOU9Z/RVIgut9DyAT6XopuynMzpm9zfiCmOxDDe4ryW+S5
cP8LPyA6WkWaBgBZD6NPnoqDKI4MLUsj50jZK6FGsVO4ONnaXvjdpL0xqIQzZfDsNuMzCGzzLrC2
NtTaeH6ESuENuDA0wwHiiWTgkZOoXm3Sdgz64dw/h0f43s5J7lpur5DlqXc5yuF3dfN9yTeMu8+l
I+vblNBYoF996Dw0wKDIx4s3PAgMDJ3dEyR82AXJTOS8r2PNrtI6FHffudjNuzZbpMVg60fNMYFs
1SiA3LkkN1/jALUCZuJoznryw5fbzjavSugWVe01k49vVCZFE7egWu/3XciCExeGPx+jg3j+7AML
YUz/n7/EQr41GH5/vpBgMh9GFZpIRkzyW1JUsbXBrSkvut2S5BgIX/9Dwcn/bGvEPDFKyh72AykP
HkEI0agGUwkjj0Qy1szUeufb25lCRleAlqnP8dXc8gBrikmLz35aQJvwGRgZtAhy6VJdR4vZcOZS
dAEs5LoH4cq+5hrv/TqRtm0irbGJfaSBaY/N3S0YhFq9GboSR0hw836Hwc1dIrqaxYFtCOaxu7zB
swrdIxTIwNUTT/SJTXA1y31G39W9n8fgiQXzB2CVgyTXLR5yQTWaB6krqMJq6htczZxTfpASlE57
ZeR8QRpaXvroi9DOjpCTYnJhSEJagUlU+UM5NCeuQX7znU56BHFKTgNTARe+ZaVFsR9ZSvY+DaxF
2WaOov6w63/ttBAWhguDjpYZq4q+m1Tx1dH2KR8sB1Pe7J1ZyBx4gZuDmmpr5KM7fh/9znLtzi6U
lcZJJUEQghVETqnOBok+T0nJhutvLIGJeehEnWsb7d2AHTvLhG6SDj3aQEZ0agmL9VTCgv1mAwLJ
cTUaP38V1hsa/IxHukCQiyVI1vEDvHew5TYWhgC1OKOHg9NqoeSYhmE21grA6j5eqSD46En4AxRG
lLb6m4Z89K4ula8tHMSdgQt0eOcRsyZJi6QG0DpmkTik8l0fkN6EmV664PMbiv/+F2PL1oO2Z+jJ
grOvFMAPaOmPza96+5WfEm7hsbY471s5SQq1lNhtXdCSuliUP5EzDfcpR+jNQa18sqj9vk5J8vMn
k4irLIUOryuqo9w4Cw18PKDPtGLE8YiuBPQMMplmWIgA02TZsx6VBhQsHiABOEnP7DeFS/L9zYwc
qvLYS1xy+dB8Fbjpe2DwosXGCQzVNafVU8Q8R3nYONFE64qsJHtb8Ba9+bYa9huN/38M3x6miVdU
e6RCObJhXxUm6BRC1qCfPEKae1x6s8kONkYh5g2TakZ7G8u9tBct6xkne7QWoGTCx2GoUU1CAvHH
cD19Ag7KpKHzOfCedV34Cgo/SSncA7iSMZXlbq4WbBTS/yA1HxnCw4l2wUzEW/Kw+SaOnjqeyQUF
AVMTN3lv1rQPhLrLBnVKRKhBQULHytIOE+2f+lZRg7P5tU7Y/PbJnvLNJETlEuRFMtaCzS2WU7yX
eRmvF8re6AFzpbIKZG3iUM2qTWR5dqizUcAR7iglXg9dL24j9AlNgGxyCLriCrSDX9EyjwfjyMmt
MkbOcqZn7oz7GCaH6qP52a100/8f1iCFkQMHXYyb9esWnFtpmBnVaCha/M+mbG7qTPJ9Bw2D3b9/
rdyTs15JzV+C+uOlCnrLaz6EkCBqeOq8lfEtgr0g+UiDWOgkhhJ0Wuc87NLKJ6GV0/opEEhSfUYQ
aEcfF6C/76SAv8wypGEYzFbXeEjA75DBwnqftCgnMHF3nPycL3T7KQMzx8CgbJUrwIiDyvyR6fyl
LHJhLDmUuK+JGu/C+RFDtfw0FnTFw3vBemHkJhlTyQh1apmgll23XtjseSDePNa8hC8UGqOlp4t7
mqCUDF97Ef5lSXAg3KdsFu8DfFWHauVA6U4ZY4oqM9lBxUFHlzwPu9F5K/7jaYQ3Nn5qTMwd8Pyw
s5ouY03f0g0lq/ulTYmDKPTlyGgBxAStmGQYuZ73+FIIYEKOVbK7Ks+EWeb7Qi7j/nXTdswsDJZo
OAaKzPGUnIG5O/ddVM21SGCJTRGAMXPcrEpkxbCBuKKgslzwqXP/WZMsQhncYTIVT0uRJKjVVLUr
r51LR/fv3enryQhLVPeDN2zoMR7ugCiViZFFKu66XuL0eK89XcI6pFe8/01s9R1RkiKs7FKhlhUO
WRN02DXegB/26GCwz2lA9k2Yp7cq3wjShgjLTEJveTLxzbW1qc7PLZEuc7n1+XVYQGQ9LO6qsvfC
TNfOekB/4xvUdqt9J08lCwwLZlL+XOhKjvr9un5ZpWA/FMRz3G71MmN9m9orRzrVhMUaKNxyOLWc
08gkJDOV6O/wcei/hHuh+p5g/jS0xxdnoPTmY1x/0mN4hHy/9J4ArA2bDq2lVomXoLTmaAqOYScX
40kHRxWkAqd1OiQPkX9kRTjPxmfTp9D9iJkTAJ10TkSw4EsjjGT1JbAthK2HlRpHsEhrHkMheLFc
WnE0pkKeukDKOcmWQF3s+pQwn8g/GWOktdzA6jdpM228BytSrpJKNABudV1FcCKJ/yFaGxz3hHkH
a+xYuUw3aPlnryaw6bw1qZScgwNl7xpVzTpqdXjPET4jAV0ab3JDotk9ECsJFv89qDJWxDybVsZ9
J18qE+Rm3JjpXwrVjpr0KAQNUK0l27xHmqgOBWkeAT1wju33HwLR2wS1lmrlfD3d2XYyN9CRo1aF
YMPU39b+EgmGo7gDu+zcWAeoqvNkEijvt+U3Vz4G2ksGWHlGdfKhF0pEcDSbTpqWOSFHxcXr89oL
6dI11gCMxmz/EpRHrjrJNtjscM5mOlQh3xR0MTxu1LW3PgFavTsqY2Z7GVuOTJ/NDHP24YT6cr6o
GGXlftAzx/qujaHdDsUwlOeNte61v9IOBTpJ93rbDIGRtMGceHn/iow0bSXUsusCULpuDr2TeC40
696+vaAnpUwajUrMxOVeYO11hmud8CkVq7/1tcApJxocv1YsD429WJk0T33Xl8/aC5vYSYTlBNJD
qUrNvvLIZ/DA/+asAneGHPCyd7jEZMvctINl2yYJs8smnYkB+FTe9+jwflAJVRh6399IJzQFkmg/
41Dijlovcfj4vCGdzYeX2CYZpcBvu2PrGE5mGQazgy247cd+sEL0kA15aTdbpPYYP6uYdRZZ7WAn
4URvcJhl7b5YGu2WRv347LFOXM290oXxCogRbEk5ABUg6FYO+Pq2ELB2O+FS6hXfPfQLy45dJrBs
Lnp2MiKeLMegq+vrxkocv2XXZu6D4D/NH8aRfIyRvGpZuFQOebnr0nAO/HLRRPsT9xjptB2bIfJy
+YwSSAajWNqKNZOU/Sm6er64Ac95bHGOYSh55cgWzEcsW7qOAMtYHBS70ZSmIG/humKoZt3ImFEy
CPWgNHOK+EGYBUjyVWMsJnzsh7BWw6SLBWIyS5cEeUOhQtsS0YvNuOrtTuOK1eP+b/MGjQt+fZRo
UJBzAH8pG9nTj20xu9M6R0zXGAjimbHzaB6zaM/MRKPG7xGpaQ1M2lNqR3/Hm37RyCbWNe6VA3B0
aLpAH73OopwZxenm7WRZc7sH1h/Jo8bl5UQEmGRQ/mfjz/VL3rMbIz9gq0+ikzX0s7kdWUX/LhvQ
1M4k+VtkUB9MUXdCo5RIiefiMBE1CuHQEeFOEpXacknQ/2UFbu4XHG4AE/uT3SqQ0+AZQ6IqN9Mt
4OTwE/xjfNXf7rVEM8N18ILMthGVeVFCapmjEs+3Z7vL/4V4tpeCgnNZ5x8nAS33uOo7sg0Iagf3
xTpZa3JFOmTdYJC9iZVi3WfQUBARZ1sKQ/6zEfeoxqUt1LYFaiFiCxjpFie0A+6mzl5UCtBQuDA7
H2ew78gO3Wl7bjcD9K81jDvBvvekqfAjByhxugC6l0ffa2Stw0DNb3YCvnkl3OdtFYcHaKJU9Yvk
3UP/kb8CMegZV9RnyRASDYGcWwnUTt4U2PsE3U6Tn8x/IZWqF9Nk4rKdVtVqrdA9ISP5iKDWngAh
MSUXxK4iX0NtBUSmsuWqUfTisrI26Hs5AEr5GaRko0c9Y3us+64eJ2QveSK+n3RmBAcYFAbAruo2
twa8eIKmU/MVRyN+FTNkB81fluOC1G7q2AvFeCIC5hld8JVjFPX+otsgnX3AgyYyFS53UbRgGYOP
ab7th4kUZ20HdGOkLZ3rGcpjJQQqpadYg4c61Nocb7+8mHzozyFxI+TBDIEuvhxoblStXuUzeXP8
Yta5aauEaFSkeIOhUdjGkuJps2R54JGautAxGlV7ragxcR52m3oK27B/aJhBOPsNQExTEZ/CyLGD
5QAJRb0l8E+DFbMuG7YnSOtbGTiMtc9zL/j5Rkc9PeLuQqLADeKGyB1fYrTZr0mXBABeL1kltxz6
49hVUXQ6PxC5cpDAPxOZN4EVuBaRyr/ikhWkWUvfB6O8IhVM7gseid1DeV3OXXO9m+5GyqeRod4R
5GVr86AuFxWaI1e0gVExFiat8EjBGEBisT4ZIWqBU5N8L/AzIrSIpC1IZlMw97fzT1ogAA8pJAcm
yZUmt/hUmgEuWdMMk5m9CeIrHysPQ2Yx9cbYCOxcZnndkflZi3ov266L1QnhRcqjoWxgEDSAK2+p
TjOtUk1Kl+aIzXs8LG+SVmPtuODI1Q0Nbe1H/gmNhMjcVCCkfBsO/PnFF2zFIqhQ0ge5cB0Snec6
SW9+574t9+H6/d5yP2YAurzm/XXGLTQxw41L2+F0TQGWoCxfdoLVPAebDugQ6XxSH8ujgp3xEWOh
hdUN18rA3H35qdLmgg8uInOIeg9+/XTkk4+MMSSoJe3E5osMM9FVwIrPLJmz32jcgy/P51PFLKQ4
2W+Acj5cXiQBtr6kvocPm8gIkcvbZvqJaTucdEM+rdtyHuImujNP+g5ke6QUusgO8jhxSJHn9jdX
BScoB9oRVEm5e6R3mZLvRkU9021uHKKMxFYrMcBvJ1ehJn4iMqO6AqcNvd4BXuQB1HA1iNTBAjgw
5nDpBAZFK7hPsPxOj2P9O2E5kuvc29pYhCLaNo4SmqFR+yxCCRVS5aqu2u5pabtjF9DgXDXgcxR7
AfuLTagazaafOqv0QJbCKKumeSZagqScOEi2AmGu4dHdDaOazFDLNuovxqoUqvU4qP47ApubnyPa
MD2YwllRWKCG7mrscME89slFOe6+c0CDVAzL9IOYNoSSQn6IDhTC4SuVdxSaDu5Pxg2zyK9u5gfr
Az3KlG+NXCk5ObARBx6O65MAVev7G8HdiT/TPS+CKITPl8W86hcUfMUSoyU5NqdKNuzAq0HYGQAs
5xdPa9EDX6sTgyz9dUasJRyX2rbtt+E4ile7QXejh15WRgZ8JYsPvILL3k0wa89g+Y69YrR7mxrJ
NF1Hyk/TaqNhaozba5K5SzJhyVS7y3QIdOdKEjaonQv2dGoYivNlSJs8TA7vx+hjcIzaojrt+I83
j/qJ6nVMWO4mkX8uUFChE+h50wK4sg8fkMU3P3IsIu2A1RJ0MrfX3kv0+UbCz9YkRJV+l07A/hAS
h2Heet3iSGhQp/dIOCR0yzH87WT5vcC+TuEbQsqA4UsHGSZf/QC62ySQbaa4D4s8foRrm4cMLn3N
ibR6EY8174XxEzGMr8YnBgjZLc/kCXZ4lG3PcxlZfqzZZGH2ysB+c3CGy0HP2vqrbWC2osIpBZ3P
3Dj2tiXwCRKyNo2pboTfRHJLg046SLzRTMgH9/rIkFeML8I07eu4BmZ+HVwMDr4jtn+NjFZBK2hH
OuIsJZIXwArP4bAONmuINll7qCDxXfzYZFLJQWwft6IoHWXkPQvxVvQSsT21BKU3KIQUG8Te/SXh
2JfChnxjGG2njf68hqyCJ+vbAI5A9vcj2RnlOhXZRww7xSTUOzBsqH1PwgIL0ols2z22NPw04bvG
fp0bEQSQIZoMZT9JuOfVmjnxMkK+kKVGGkDg+zxfY9cEyfbtgQ1DaVpstp43hhtOnhGdDRlAtMyn
g9GQ1pBkKnUMBjAPfzyk65gQ1pLTecVYfeWaKdH2FbVZwGmLvz6sAau4tbt/HZC5/P6U946OX8Dk
YjwLNejxwiWtm+lX8Lt2bf0Hci2VAmE2TOsADUDbNyRsWI4wgjbsdgn8Sq5WfIhn5fOMF32fj4+T
9TsAhPsnoDe2ZVyKpgYztAkuh0e5MY82oQIg+8licKDMkWzsLLbLj7eEnT3eJc/iBHtd7XNDtf38
IBLgScbgZK/QFQ/54ktU8J9Y6wfUAvhCiXXKf7D1VV9PCtmv7UCEdheF64SSxWvRW9b5X1CMqRnd
wS6bm2ZYgcglpPILddYh8wdaQUIPBD5SooUoWE0JGElQRlYZrBRDYAwF95T2oF/cCTlWLs9Zw8Sr
I8wkcDoMjUzo3sNWjSbfHT8vuFaecRi3xpXc82ZPyZ1fgfVMhPvz4A8VqGEo0EIsBB6sCLv1u+wg
c49WpK6+kL4B/QDadjc4pZzHlB6lZGEV5uXeC59ksVHLEMyAkoV1E19q7F9ppQtGG7Y4OmcgdoQC
bYxWrfybtXlf0Pa2AS6nuK0/HsFKZhc6U7EbjDDPkZCOjuEO/qa+wPWINZZ62NCWP5aYGISx5VIl
7MVWkQQ+h7Jpe9ITGwiJ+8UbYFhVnbPfzE85ihuKovLlPtENFP9JyrQrNHPnxbSny23/eieZtBn2
s5UiWOxDtC/U6CK4G43XZYvd/kpQRXME7DB9Bi+FTT8VxvETZo1KobxEOWDtQ3ia0wBVNXNt++qF
SHI7zRin4hHaK7FXBXBu38+smG3LrReVhWWUkbqwhX1jNI021d8LxGmeNUTJlrK91YWywROOLcnN
HyBCkH+FfCdlDCQeGvD7y+2HSSeYmcWOpF9Vx+hKr/u6Ura32qYJ2D1qHo+vE+uHGo4vLb4Bt4xJ
ZwT7/9h6oR/ibmpvPf1xnAZ6TfFKNFKVCh9Q1LnTKrVOclTyoQP9xFT7ufey0zQZTIzz4sS4FtQV
cFcMKM8lcHH3yOLHdI17J2WDhUJoM9nEorWZ9/eangmXHm/NquaqqumZnDl706gt1ykRzjxgbFM+
ut5hfwoMgpcFrEHH5IHm/gV2DcoFwawQXD4X/Obu6arUn6wiBRtT7xUFBoO+qZo0zDS8eDwNKNxv
yW/JaqC/VxXY95/9Rq6uI1+OpiOxriso6/6Pp+v9tNqMc5chkqV5uxH3lqm8Vt6ZRgH48AHKCcJH
KEiFVi0e9lfYUrEyQvIR6UTldbRaGbnUaMyr0HBaipoc6hwhVwtvbCvTxgonwOTWouYvxeXAHQuw
hMb8/XPIAj9gO93iBOeyGsdgiCFVU5QMZVRK7weCTMejQK0xhX7o5+4piWQl6CFCIFO1JzO3kuvO
KYIosZDweMDvMou9wqeBkfqa2GgCFqx0Y+N49A+jP8m5y4VPQCmEYbqk9W+k13eh2M5cJDblT1Fa
tWqUqF1pFscaPvaDENAotQ8tw1OuYBUgc4taYcqPAhM3pWtALUHKXBHrsw7Iv2/W5na7HKu/3FKX
9yh7WTg6SQQiybXKDDCETd3eT8u/XZjLdqBGTwNZRIaKQ+/fGiio4JhU1k9XDlvYv4XEpf9eFfrV
ovap/6ncd/R7K9w2jAH1V5xiuuGf6ODMzBcCklb/v2UoGUGRrx9vwQRYDJxe86JHuhH5gHHQncEk
IWSSXMyn2SlQ/Tx0BXK3LnUu3BI7cFNaLKMMy3WpHkrMyU30YXe/kilGGEmYpNO9zqB2JyybKRBY
K3v9fe/D7C6Xx0DIAQUFLVw1AHU/LKCPce520+zRTLy+ZT0w4xiM3BqoJlHlnMR9p5G0atq1cTZi
0Cw/YMD/cif2fYH5VM60Tp/197AVlPcPuglGHJpTCS0Wi3FHSi3l3rEyWzSA6WjSIdAzPL8+LHz3
jhnflBduaGlSFPXvQsEc6rgUdEHayAKSysW7DBa1yoMQuHZcLrQgpn4QW4VvzliGCWQ6Mp0i3cK4
5KGRHBEdoM5IuIOiJ76Za/0jPYWtXh5Kmcz/D1U44dnufhLVCH6vHLvsicf+RSAPQK+kZFEiKKzI
ZCimuOfwn+BeX2LWpCJuthpkf2FPhSVvZDorHVNN4M8bVmWMak7admkiCNyLhKhsr3KjPAYuRENj
B7JQs9ebxCkebIy0/DO0n7bq+g8Tq1l+sFtZv77vEvKlkt2fFh/tUiQNwsbtZxOjpQdHqOPeZ5QH
jOaJrpHR4RHDcP/G1IrcABXE2anXQlLJ2Tfv6xERxBQ3WZinhxGDunHcdmXsuCwfUADMEFq04ZVk
JOPg+sH15z0zRtWXjDJDxwrhrHSSz3o6tYRRsNuX7HvrSepeocBkYDNRkfaVbccu2A6vJnYg/ru9
O5wbVFuEgfH5Elb00dqYI0MzUFQRoSb/jJBKX6NfJMr1uDDveIlu6FHGhRSmiM9ImHLg2OZvj5tr
hkTOyDAqL20QIXR189tzEErtsGUBxT1gSGbZF2Xl8jWvEMBV7vrTChcpws5mbflJLix64yffmlkh
b0QSVA8bxiMlwbKFj+pffSmb1UHqHhKG2m06hh6JLFU0Lv0P3DPHJFm7bQeGnSHECLQvl6gAP2GV
PJq4AewMHi8QW9O09HfL/ls/YqmyXS2H8sOi+j4lh0uvR1c++ODVgxsNWuOTeBzAJ1GCvr+/fHHH
b37ye+cNWt2XKFWaroNCpBBwJXZf5TA1I+JVDj5zg87l9cCeVQhtbyXf86C1cfDJULFf81ykDOcY
Ym+6HibcYctL9wXLjnZFAbmQIh7omKRRcoeMGcWMYE9c7G3qayw4An829bsq1enePZHIYJn/+2Bb
VyGIH/qRMZ/eHGIVbDcal+KrLzpe5mjTvIkSF4XrSpF3uhkcS2dQ5NK/eRUz4Veuo+nK/CmR2jkA
sz2w88v943otbcXMLzHYvSydqMQYbTb3Evz34jtcaK0RQHk9xvgIwY2Go9kVcdbAHam9zjkjRPpB
/aP4p3EFMPzgw5+VP+urwR6nIDDcdZGB4ScmJ7z87pG+uOkD/gzz76fMC90cBOgOXUMQQU4d77W8
/xnLPBee6+22njO93DFkHmaLQObphK0CIprrd/2XvsHTPzaq/us3ZJoZ5eZNrg/X4jDcnzSWPioF
sHyeCaTUHFedZrwP+T8E17D7bHfnLFYSyNaXTXxGiMUAwD5vAZyVcOv/9AL5ullfcqj6smB+4Uy0
5PG1vuiwGYEER2d+l9G+6C5yWPJH0JRFA2X9ukTqiM/wJWp4Me60ETyeMK2y0GqsAbgCi9RVbGAt
qBNeoLj4tOza3NeB4Srqcdl2xVCPyUPSwqxqjGhqkHlVh2DMfMBJFTrQwuRon5Lex5uvV5e0Y/Cl
l+ujaHm9PCaaanniaB9l1Qctws2SuWd/GiyqDbtzSuHOFXnSNEfopFujbLKyBBSP/7p7U0Pse8rB
VShp5z3BnbujoQBs3PXOFc4fRPZkgiFV2iIadHXb3MBPngfnpLrqoz2h8HeIMpW5kABn8Kwg0FdR
Zg9KDmDgp2LuQvxgb1C6h0P3mATbYmP5yHN24LZYQTKoxAIkFOwVsNewU91pogokfBq+qjj8MpcF
vag6CEn1G4is92f3knv6NeG90+h6lWoOXsPwc2IpTSGp3enlHwReiAJDFkkWsVb43X0mkBUCZWJo
EcyLmyUIS4rvH16reT39aCUMzF4sB4LuzGsrl9FMnRGrt72JZ8j7/IBLHU1/IF/strqxgIhkDZ3O
WGXbyeKD9pMuTdHXPsQThbbpVuy71G3ZQKeX2nQpYDrvJ9qtCNWpfrJrFRQyZVHF0ygOCmiCeDBY
RC+YHqrrhr5hK9JuFSK1SJrMGx09WimAfKwms0AFMty5dHmSvkb3C8BoQyeDn+0545k9XxbbmfAe
fQ0GISCKXOmSHY8wKZRhlC25WsULYu7c0Qqk+mlrgT1jDJ24sOKaNruBmYNUF2snb1los5dLIdwa
SLzAtWA8VChJS3ZfxQ/YZZby6Y79AXxcyp/PNOeKxxwKtGQguGjISnJRLacUs7DxH55cOipLJ1+a
akhv1zAy8F3OMT0BjC7N5QojJRgOaZuLI/YMgI0O5/WSVxRZ9R3OY8DTfMn7y5X4AvqF1Wx+n5Ox
TvanRHR4Id0uA3nvjK52rSW7//dfV1R4Wmb59nQS81te0oZXwDlroY+M1CVYsdll017WJcd21Ypt
sxLJeUKOGWEoZPCdzpoDQ+5nE1YdE9Yi4Q0b3oHrKNu2rp8H8wjk9BG+Jf443Cqr7w4qGrQeRXyG
lJCpkCSx4JqQMTWCojrtt8i1rSjBOSgldU4yrdrg870gFxrb2iEpfXm89lCWRT5qFj+9B0McFknU
dcI3a1112GgJiyha8wWJuSQG6FqHO9CZhkFEzGhtXnyVoNcf4Iy7i283PfJ+zqik89mvb6xb2yKH
U2vI0ZKa+KMOskKqGLWwFq1NaiQ3Jqf8ZkQzZuoKI8YH/auh99nfDdx4xE5SgszBGNZsj7nVcQHx
tAmiwHa2NMBO0r/B59zGyKc0mZfAEwIN6sxqoE/+rkj7tysPJp8hRJGLxRqXOPPK667SEheHTeLL
fxJAlRIUPqu93cKIuS4xYK8C2O4VohzKqZAwxQOatPrr9p0C93QqgPahd0oanYmYPSbpoI9eNBuL
WICGgCdfehHVWePWKK8tU3FZYRo/LaG8TN9w/5R5jad9ATndxYjMvle5uAazFmX9yhNBPyP9fWs0
HFQsjuw3VO7aEj+UBzLWglgl8JKQFXvffNMt+KEqm9TH/Xxwj3Tw5tqq3RTYGNuCwep1qg96mx3K
dz+6EouOQRTc4eHwyjWYzOZeAy7UI+jaaiQJLpipCv7vsTphyAhm6NBaB/y4qxXKKjMHcg6UW2QN
vkYxGhAV5W2yu886DnUT/crYS3GWK/+yoa/tJMACAP8ay0FwK476AR8bP/p9jdiqak7N3Im/GU2q
BHVAkkvB3lR0IRfV/Vu01y6w3WD9frE40GiX8Zd2JisGJvXmzJJOrg8fRXDwjueARND3u/hazPC4
QTNWgqpJBHpL6ggMsbsKjpkYrL3OtE4OnCp9F4fzMUK5q0wDktlR9Fl+Cu4ffgDm7sS3abTLpKpd
7uBqGC9ZUgs1gjJbGyz1AJF2MMDvuUsPLvzYAQQn1PgaXp3gh7xEZ9DAq1Q6TjZ/k+ebnjcpDgxa
G4LtTM9bHNrZkIDjzZ5JZd6YSJk8wBP3stbxQbWXp+U45U+S1TQ9ZIr5V496f9DP5F/KpKJa42zz
zxXjxU7aM5FicRo3YoqQaYtIs3CkDy7RhHEKqNe4lJaQwFQX/A28g65167fvOQ8Z8FDa5l0X2Tmy
i0QLFJA3CsSXLm1Z2lJN1xi7dek6xr+nC+x9saA9h1V3xDmRD6QFK17J/PZ81LLVfzYvejJnxICY
kHBucZX5TS3Az1Zl8MPRTRCBx7+XWoLHqgVZ/KGIGRjdCdIP7pXBcmWCXzsQgKaLrarkm1FRCJMP
1aNyPSkzRCf5l5Cmoy/CbtVaIpBTL03PXD0UlkqP9QarfqEpDl+1ZzK+BnLxzTgnxenIeEaY2ddH
kdPy+EDfQk84fTDtVDvvwB1Yz7n3xduSnRJYzWFEpW004HJBXAbURe0rj9WzBz+hANSFN1jAd43O
zzAR1PCay+kWXoYupo9rELCzy1SwuuSHR/jvzmgKKHmppfP1+GtbxmFvSVS8TkQvvKrjpj27lLf9
OLYTalsFpV9c2TIz81cvCsCS4XaTMd4EKNRVO7h+sFBEkVxZCEABgaVnybrnDhc8J1OqPzg3DAL3
aoBcNffO+6YKbon5d9Zl9pc8wTFw5cxz/uVasFNhB+hIu6TLbeg9a3RuMvPHRShm5VND9DSIrHQr
rC7Z2RSkqzNXG+LXsevjKhiQ79DNJvzo6nVs1YcYXD6+cb6wOIK0EFJ1uifn8FCZF8IyBIwxtUn7
nPg4kLsxETw3PWZYrrl3mVBNjZyofx6KlpEi+gMdDKSQLlcXFO2SCcKQsXzkkMMszFi3qhf4kHnh
N87T/nrurzmSryLbuw6gtdp6GD0zEgW3BJVbFr3mQlLyRQxMDK9AytIuEWi8loADKjl3mMJ/LRmI
m106R2KbjI98PKkCWeA47RQ33fLHjmZ9NM0jJsmA9HeOg1kDJbKfSlwk4wuiIR+AhYvEaSIUmYkH
/fHDK6Y+VEvbuUWu7oXYFnNFtTrMsnSCpX3NfZXTyPOJpxLJvVbYb00jMQXEK7yjOKE6/AuKO9xV
kB6AjxUgPcaOtnsBsFJLzqhlUG8zc3L1OumCYOEXyykeQdYAwUniMC8Tn0AV6CpHo3jm4ep7Yemq
VDnS9LHk/UrIi7T75/qXzK5ffSz5DF01oHmEqsXViM1rKcMYz30JzTdphGsTn9IknQLhMlQmQcMB
WUH7OM12OeNWbXUHoIEMr5GpHUk9Fzi2SPdXbi4w47mG8d/3OrjIMbMWFle1n4pU/IWTUH5Pz1VE
jLryOmzM04p8Pds9oOy3at1HIy4N8/pONc3TLqR5VjUw1/ES2kMFwJPzyRDWvjeyYKX0XpVCMFPC
Y8jtIWkaSD0kiQlBt7NTevrjP3SSuIL97Tm81tScjHOCve950b05/dtmC53/RDlOwV/qESV9FWVH
19dcbMx9rCp7vS2187awUDG10/K2ZG6+2mhgLSE//3eXczfE2L5au61FX/iafpprda/vkumV27oG
ccjQSJa/5LzvhUmxXp6U63B9sB/f83zMqFRLZw9wn9bzWykF0p2gPXcRRSp9PArPSCm2sq2IRavu
J1eawwEBEphppHMTdznFfuT8N1ox8gN0GckIlwSswoUsin913sI+R5Dp8azfFFoiDOU2KFN3Do94
wAEeX4rFSl3gjwt6gAQVGWgRxQOGBukvXVxUKgqOADInOa2dXWss/hUpidxnj61WlbCvJTtmn8Y/
s6KLC26wOg/dYqoJvHOqmYUF5rExfGgCGgeGH6t7UNnwsL/R3iQp68vqOAYrRVcktl0RsB9WGRE9
q6AHYWpKRZU+r+pQOQj4XZwZl12G7cakpc9KEOiA9e1HJQ==
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
