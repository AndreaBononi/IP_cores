vlib work

vcom ../src/reg.vhd
vcom ../src/d_flipflop.vhd
vcom ../src/fifo4.vhd
vcom ../src/AvalonMM_to_SSRAM_controlUnit.vhd
vcom ../src/AvalonMM_to_SSRAM_executionUnit.vhd
vcom ../src/AvalonMM_to_SSRAM.vhd

vcom ../tb/clk_rst_generator.vhd
vcom ../tb/ssram32.vhd
vcom ../tb/AvalonMM_to_SSRAM_monitor.vhd
vcom ../tb/AvalonMM_to_SSRAM_driver.vhd
vcom ../tb/AvalonMM_to_SSRAM_testbench.vhd

vsim -c -t 1ns work.AvalonMM_to_SSRAM_testbench -voptargs=+acc

run 22us

quit -f
