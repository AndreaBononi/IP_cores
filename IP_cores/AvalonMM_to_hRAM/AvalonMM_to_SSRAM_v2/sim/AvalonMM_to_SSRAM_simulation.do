vlib work

# source files
vcom ../src/d_flipflop.vhd
vcom ../src/t_flip_flop.vhd
vcom ../src/reg.vhd
vcom ../src/mux_2to1.vhd
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

add wave -position insertpoint  \
sim:/avalonmm_to_ssram_testbench/clk \
sim:/avalonmm_to_ssram_testbench/DUT/CU/present_state \
sim:/avalonmm_to_ssram_testbench/avs_s0_address \
sim:/avalonmm_to_ssram_testbench/ssram_address_space \
sim:/avalonmm_to_ssram_testbench/avs_s0_read \
sim:/avalonmm_to_ssram_testbench/avs_s0_write \
sim:/avalonmm_to_ssram_testbench/avs_s0_writedata \
sim:/avalonmm_to_ssram_testbench/avs_s0_readdata \
sim:/avalonmm_to_ssram_testbench/avs_s0_readdatavalid \
sim:/avalonmm_to_ssram_testbench/avs_s0_waitrequest \
sim:/avalonmm_to_ssram_testbench/ssram_out \
sim:/avalonmm_to_ssram_testbench/ssram_in \
sim:/avalonmm_to_ssram_testbench/ssram_address \
sim:/avalonmm_to_ssram_testbench/ssram_OE \
sim:/avalonmm_to_ssram_testbench/ssram_WE \
sim:/avalonmm_to_ssram_testbench/ssram_validout \
sim:/avalonmm_to_ssram_testbench/ssram_busy \
sim:/avalonmm_to_ssram_testbench/ssram_clear_n \
sim:/avalonmm_to_ssram_testbench/start_sim \
sim:/avalonmm_to_ssram_testbench/stop_sim \
sim:/avalonmm_to_ssram_testbench/driver_stop \
sim:/avalonmm_to_ssram_testbench/init \
sim:/avalonmm_to_ssram_testbench/preliminary_check \
sim:/avalonmm_to_ssram_testbench/force_read \
sim:/avalonmm_to_ssram_testbench/force_config_space \
sim:/avalonmm_to_ssram_testbench/controlled_ssram_OE \
sim:/avalonmm_to_ssram_testbench/controlled_ssram_spacing \
sim:/avalonmm_to_ssram_testbench/controlled_ssram_address \
sim:/avalonmm_to_ssram_testbench/custom_address \
sim:/avalonmm_to_ssram_testbench/DUT/CU/dpd_mode \
sim:/avalonmm_to_ssram_testbench/DUT/CU/write_op \
sim:/avalonmm_to_ssram_testbench/DUT/CU/config_reg_access \
sim:/avalonmm_to_ssram_testbench/DUT/CU/command_enable \
sim:/avalonmm_to_ssram_testbench/DUT/CU/virtual_config_enable \
sim:/avalonmm_to_ssram_testbench/DUT/CU/out_sel \
sim:/avalonmm_to_ssram_testbench/DUT/CU/config_sel \
sim:/avalonmm_to_ssram_testbench/DUT/CU/mem_input_sel \
sim:/avalonmm_to_ssram_testbench/DUT/CU/address_space_sel \
sim:/avalonmm_to_ssram_testbench/DUT/CU/mem_enable \
sim:/avalonmm_to_ssram_testbench/DUT/CU/force_write \
sim:/avalonmm_to_ssram_testbench/DUT/EU/virtual_config_out \
sim:/avalonmm_to_ssram_testbench/DUT/EU/virtual_config_in \
sim:/avalonmm_to_ssram_testbench/driver/pending
run 30us
quit -f
