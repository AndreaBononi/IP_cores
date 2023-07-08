vlib work

# source files
vcom ../src/d_flipflop.vhd
vcom ../src/t_flip_flop.vhd
vcom ../src/sr_flipflop.vhd
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

add wave -position insertpoint  \
sim:/synchronizer_testbench/DUT/CU/present_state \
sim:/synchronizer_testbench/clk \
sim:/synchronizer_testbench/rst_n \
sim:/synchronizer_testbench/start_sim \
sim:/synchronizer_testbench/stop_sim \
sim:/synchronizer_testbench/synch_clear_n \
sim:/synchronizer_testbench/synch_busy \
sim:/synchronizer_testbench/din \
sim:/synchronizer_testbench/din_strobe \
sim:/synchronizer_testbench/DUT/EU/code_counter_out \
sim:/synchronizer_testbench/DUT/EU/readdata00_out \
sim:/synchronizer_testbench/DUT/EU/readdata01_out \
sim:/synchronizer_testbench/DUT/EU/readdata10_out \
sim:/synchronizer_testbench/DUT/EU/readdata11_out \
sim:/synchronizer_testbench/DUT/CU/start_sampling \
sim:/synchronizer_testbench/DUT/EU/datamux_sel \
sim:/synchronizer_testbench/DUT/EU/data_counter_enable \
sim:/synchronizer_testbench/DUT/EU/dataout_enable \
sim:/synchronizer_testbench/synch_validout \
sim:/synchronizer_testbench/dout \
sim:/synchronizer_testbench/DUT/EU/burstlen_counter_enable \
sim:/synchronizer_testbench/DUT/EU/burstlen_counter_out \
sim:/synchronizer_testbench/DUT/CU/burst_end \
sim:/synchronizer_testbench/DUT/EU/system_clear_n

run 250ns
quit -f
