transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/dist_mem_gen_v8_0_17
vlib riviera/xil_defaultlib

vmap dist_mem_gen_v8_0_17 riviera/dist_mem_gen_v8_0_17
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work dist_mem_gen_v8_0_17  -incr -v2k5 "+incdir+../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l dist_mem_gen_v8_0_17 -l xil_defaultlib \
"../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l dist_mem_gen_v8_0_17 -l xil_defaultlib \
"../../../../Danmaku-Shooting.gen/sources_1/ip/font_rom/sim/font_rom.v" \


vlog -work xil_defaultlib \
"glbl.v"

