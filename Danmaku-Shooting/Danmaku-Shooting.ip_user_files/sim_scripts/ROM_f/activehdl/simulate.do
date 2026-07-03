transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+ROM_f  -L xil_defaultlib -L dist_mem_gen_v8_0_17 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ROM_f xil_defaultlib.glbl

do {ROM_f.udo}

run 1000ns

endsim

quit -force
