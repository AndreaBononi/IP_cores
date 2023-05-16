vlib work

# source files
vcom ../src/reg.vhd
vcom ../src/d_flipflop.vhd
vcom ../src/t_flip_flop.vhd
vcom ../src/fifo4.vhd
vcom ../src/AvalonMM_to_SSRAM_controlUnit.vhd
vcom ../src/AvalonMM_to_SSRAM_executionUnit.vhd
vcom ../src/AvalonMM_to_SSRAM.vhd

# testbench files
vcom ../tb/clk_rst_generator.vhd
vcom ../tb/ssram32.vhd
vcom ../tb/AvalonMM_to_SSRAM_monitor.vhd
vcom ../tb/AvalonMM_to_SSRAM_driver.vhd
vcom ../tb/AvalonMM_to_SSRAM_testbench.vhd

# simulation options
vsim -c -t 1ns work.AvalonMM_to_SSRAM_testbench -voptargs=+acc

run 30us
quit -f
