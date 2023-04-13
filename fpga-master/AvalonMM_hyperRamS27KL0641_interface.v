// AvalonMM_hyperRamS27KL0641_interface.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module AvalonMM_hyperRamS27KL0641_interface (
		input  wire [31:0] avs_s0_address,       // avs_s0.address
		input  wire        avs_s0_read,          //       .read
		output wire [15:0] avs_s0_readdata,      //       .readdata
		input  wire        avs_s0_write,         //       .write
		input  wire [15:0] avs_s0_writedata,     //       .writedata
		output wire        avs_s0_waitrequest,   //       .waitrequest
		output wire        avs_s0_readdatavalid, //       .readdatavalid
		input  wire        clock_clk,            //  clock.clk
		input  wire        reset_reset,          //  reset.reset
		inout  wire [7:0]  hbus_d,               //   hbus.command_address_data
		inout  wire        hbus_rwds,            //       .read_write_data_strobe
		output wire        hbus_cs,              //       .chip_select
		output wire        hbus_rst,             //       .reset
		output wire        hbus_ck               //       .clock
	);

	// TODO: Auto-generated HDL template

	assign avs_s0_readdata = 16'b0000000000000000;

	assign avs_s0_waitrequest = 1'b0;

	assign avs_s0_readdatavalid = 1'b0;

	assign hbus_cs = 1'b0;

	assign hbus_rst = 1'b0;

	assign hbus_ck = 1'b0;

endmodule
