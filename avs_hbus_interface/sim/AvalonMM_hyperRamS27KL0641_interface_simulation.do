vlib work

vcom ../src/mux_2to1.vhd
vcom ../src/reg.vhd
vcom ../src/ssram32.vhd
vcom ../src/AvalonMM_hyperRamS27KL0641_interface_controlUnit.vhd
vcom ../src/AvalonMM_hyperRamS27KL0641_interface.vhd

vcom ../tb/clk_rst_generator.vhd
vcom ../tb/input_output_generator.vhd
vcom ../src/AvalonMM_hyperRamS27KL0641_interface_testbench.vhd

vsim -c -t 100ps work.AvalonMM_hyperRamS27KL0641_interface_testbench -voptargs=+acc

# change time
# run 10ms

# quit -f
