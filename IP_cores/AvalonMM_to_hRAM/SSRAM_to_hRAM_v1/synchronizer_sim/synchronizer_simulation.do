vlib work

# source files
vcom ../src/d_flipflop.vhd
vcom ../src/t_flip_flop.vhd
vcom ../src/sr_flip_flop.vhd
vcom ../src/reg.vhd
vcom ../src/mux_4to1.vhd
vcom ../src/counter_Nbit.vhd
vcom ../src/comparator_Nbit.vhd
vcom ../src/decoder_2bit.vhd
vcom ../src/synchronizer_EU.vhd
vcom ../src/synchronizer_CU.vhd
vcom ../src/synchronizer.vhd

# testbench files
vcom ../synchronizer_tb/clk_rst_generator.vhd
vcom ../synchronizer_tb/synchronizer_monitor.vhd
vcom ../synchronizer_tb/synchronizer_driver.vhd
vcom ../synchronizer_tb/synchronizer_testbench.vhd

# simulation options
vsim -c -t 1ns work.synchronizer_testbench -voptargs=+acc

run 300ns
quit -f
