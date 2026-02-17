transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/blk_mem_gen_v8_4_11
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap blk_mem_gen_v8_4_11 riviera/blk_mem_gen_v8_4_11
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../../../../../../software/xilinx-2025.1/2025.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"/software/xilinx-2025.1/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"/software/xilinx-2025.1/2025.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_11  -incr -v2k5 "+incdir+../../../../../../../../../software/xilinx-2025.1/2025.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../../../../software/xilinx-2025.1/2025.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"../../../../risc-v.gen/sources_1/ip/blk_mem_gen_0/sim/blk_mem_gen_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

