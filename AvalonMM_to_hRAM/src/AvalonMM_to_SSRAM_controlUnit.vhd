-- AvalonMM_to_SSRAM_controlUnit.vhd -----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_controlUnit is
	port
	(
		-- clock and reset
		clk						: in 	std_logic;
		rst_n						: in	std_logic;
		-- status signals
		op_req					: in	std_logic;
		sr3_out					: in	std_logic;
		sr2_out					: in	std_logic;
		sr1_out					: in	std_logic;
		sr0_out					: in	std_logic;
		mem_validout			: in	std_logic;
		mem_busy					: in	std_logic;
		-- control signals
		readdatavalid			: out	std_logic;
		waitrequest				: out	std_logic;
		readdata_enable		: out	std_logic;
		command_enable			: out	std_logic;
		muxcom_sel				: out	std_logic;
		mux0_sel					: out	std_logic;
		mux1_sel					: out	std_logic;
		mux2_sel					: out	std_logic;
		append0_enable			: out	std_logic;
		append1_enable			: out	std_logic;
		append2_enable			: out	std_logic;
		append3_enable			: out	std_logic;
		sr0_set					: out	std_logic;
		sr0_clear_n				: out	std_logic;
		sr1_set					: out	std_logic;
		sr1_clear_n				: out	std_logic;
		sr2_set					: out	std_logic;
		sr2_clear_n				: out	std_logic;
		sr3_set					: out	std_logic;
		sr3_clear_n				: out	std_logic;
		mem_enable				: out	std_logic
	);
end entity AvalonMM_to_SSRAM_controlUnit;

------------------------------------------------------------------------------------------------------------------------------------

architecture fsm of AvalonMM_to_SSRAM_controlUnit is

	-- states definition ------------------------------------------------------------------------------------------------------------
	type state is
	(
		reset,
		idle,
		idle_full,
		idle_full_valid,
		shiftall,
		shiftall_valid,
		idle_valid,
		app0,
		app1,
		app2,
		app3,
		app0_valid,
		app1_valid,
		app2_valid,
		app3_valid,
		shift0,
		shift1,
		shift2,
		shift3,
		shift0_cmd,
		shift1_cmd,
		shift2_cmd,
		shift3_cmd,
		cmdonly,
		shift0_valid,
		shift1_valid,
		shift2_valid,
		shift3_valid,
		shift0_cmd_valid,
		shift1_cmd_valid,
		shift2_cmd_valid,
		shift3_cmd_valid,
		cmdonly_valid
	);

	-- states declaration -----------------------------------------------------------------------------------------------------------
	signal present_state		: state;
	signal next_state			: state;

	begin

		-- evaluation of the next state ----------------------------------------------------------------------------------------------
		next_state_evaluation: process (rst_n, present_state, op_req, sr3_out, sr2_out, sr1_out, sr0_out, mem_validout, mem_busy)
		begin
			if (rst_n = '0') then
				next_state <= reset;
			else
				case present_state is
					---------------------------------------------------------------------------------------------------------------------
					when reset =>
						next_state <= idle;
					---------------------------------------------------------------------------------------------------------------------
					when 	idle | shiftall | shiftall_valid | idle_valid | app0 | app1 | app2 | app3 | app0_valid | app1_valid |
							app2_valid | app3_valid | shift0 | shift1 | shift2 | shift3 | shift0_cmd | shift1_cmd | shift2_cmd |
							shift3_cmd | cmdonly | shift0_valid | shift1_valid | shift2_valid | shift3_valid | shift0_cmd_valid |
							shift1_cmd_valid | shift2_cmd_valid | shift3_cmd_valid | cmdonly_valid =>
						if (mem_busy = '1') then
							-- the memory is busy, we cannot start a new read/write operation
							if (mem_validout = '1') then
								-- the memory provides a valid reading result (although it remains busy for some reason)
								if (op_req = '1') then
									-- a valid command (read or write) has been stored in the command register, we must put it in the lowest empty append register
									if (sr0_out = '1') then
										if (sr1_out = '1') then
											if (sr2_out = '1') then
												if (sr3_out = '1') then
													-- all append registers are full, the command must remain in the command register
													next_state <= idle_full_valid;
												else
													-- append3 is the lowest empty append register
													next_state <= app3_valid;
												end if;
											else
												-- append2 is the lowest empty append register
												next_state <= app2_valid;
											end if;
										else
											-- append1 is the lowest empty append register
											next_state <= app1_valid;
										end if;
									else
										-- append0 is the lowest empty append register
										next_state <= app0_valid;
									end if;
								else
									-- the command register does not contain a valid command
									next_state <= idle_valid;
								end if;
							else
								-- the memory output is not a valid reading result, we must perform the same steps as before but without notifying a valid output
								if (op_req = '1') then
									if (sr0_out = '1') then
										if (sr1_out = '1') then
											if (sr2_out = '1') then
												if (sr3_out = '1') then
													next_state <= idle_full;
												else
													next_state <= app3;
												end if;
											else
												next_state <= app2;
											end if;
										else
											next_state <= app1;
										end if;
									else
										next_state <= app0;
									end if;
								else
									next_state <= idle;
								end if;
							end if;
						else
							-- the memory is not busy, we must perform the same steps as before starting also a new read/write operation (if available)
							if (mem_validout = '1') then
								-- the memory provides a valid reading result
								if (op_req = '1') then
									-- a valid command (read or write) has been stored in the command register
									if (sr3_out = '0') then
										if (sr2_out = '0') then
											if (sr1_out = '0') then
												if (sr0_out = '0') then
													-- all the append registers are already empty, we can directly provide the command to the memory
													next_state <= cmdonly_valid;
												else
													-- append0 is the highest full append register, we can pass its content to the memory and write the new command in it
													next_state <= shift0_cmd_valid;
												end if;
											else
												-- append1 is the highest full append register, we can shift the content of the append registers and write the new command in it
												next_state <= shift1_cmd_valid;
											end if;
										else
											-- append2 is the highest full append register, we can shift the content of the append registers and write the new command in it
											next_state <= shift2_cmd_valid;
										end if;
									else
										-- append3 is the highest full append register, we can shift the content of the append registers and write the new command in it
										next_state <= shift3_cmd_valid;
									end if;
								else
									-- the command register does not contain a valid command, we just have to shift the content of the append registers
									if (sr3_out = '0') then
										if (sr2_out = '0') then
											if (sr1_out = '0') then
												if (sr0_out = '0') then
													next_state <= cmdonly_valid;
												else
													next_state <= shift0_valid;
												end if;
											else
												next_state <= shift1_valid;
											end if;
										else
											next_state <= shift2_valid;
										end if;
									else
										next_state <= shift3_valid;
									end if;
								end if;
							else
								-- the memory output is not a valid reading result, we must perform the same steps as before but without notifying a valid output
								if (op_req = '1') then
									-- a valid command (read or write) has been stored in the command register
									if (sr3_out = '0') then
										if (sr2_out = '0') then
											if (sr1_out = '0') then
												if (sr0_out = '0') then
													-- all the append registers are already empty, we can directly provide the command to the memory
													next_state <= cmdonly;
												else
													-- append0 is the highest full append register, we can pass its content to the memory and write the new command in it
													next_state <= shift0_cmd;
												end if;
											else
												-- append1 is the highest full append register, we can shift the content of the append registers and write the new command in it
												next_state <= shift1_cmd;
											end if;
										else
											-- append2 is the highest full append register, we can shift the content of the append registers and write the new command in it
											next_state <= shift2_cmd;
										end if;
									else
										-- append3 is the highest full append register, we can shift the content of the append registers and write the new command in it
										next_state <= shift3_cmd;
									end if;
								else
									-- the command register does not contain a valid command, we just have to shift the content of the append registers
									if (sr3_out = '0') then
										if (sr2_out = '0') then
											if (sr1_out = '0') then
												if (sr0_out = '0') then
													next_state <= idle;
												else
													next_state <= shift0;
												end if;
											else
												next_state <= shift1;
											end if;
										else
											next_state <= shift2;
										end if;
									else
										next_state <= shift3;
									end if;
								end if;
							end if;
						end if;
					---------------------------------------------------------------------------------------------------------------------
					when idle_full | idle_full_valid =>
						if (mem_busy = '1') then
							if (mem_validout = '1') then
								next_state <= idle_full_valid;
							else
								next_state <= idle_full;
							end if;
						else
							if (mem_validout = '1') then
								next_state <= shiftall_valid;
							else
								next_state <= shiftall;
							end if;
						end if;
					---------------------------------------------------------------------------------------------------------------------
					when others =>
						next_state <= reset;
					---------------------------------------------------------------------------------------------------------------------
				end case;
			end if;
		end process next_state_evaluation;

		-- state transition ----------------------------------------------------------------------------------------------------------
		state_transition: process (clk, rst_n)
		begin
			if (rst_n = '0') then
				present_state <= reset;
			elsif (rising_edge(clk)) then
				present_state <= next_state;
			end if;
		end process state_transition;

		-- control signals definition ------------------------------------------------------------------------------------------------
		control_signals_definition: process (present_state)
		begin
			-- default values ---------------------------------------------------------------------------------------------------------
			readdatavalid <= '0';
			waitrequest <= '0';
			readdata_enable <= '0';
			command_enable <= '0';
			muxcom_sel <= '0';
			mux0_sel <= '0';
			mux1_sel <= '0';
			mux2_sel <= '0';
			append0_enable <= '0';
			append1_enable <= '0';
			append2_enable <= '0';
			append3_enable <= '0';
			sr0_set <= '0';
			sr0_clear_n <= '1';
			sr1_set <= '0';
			sr1_clear_n <= '1';
			sr2_set <= '0';
			sr2_clear_n <= '1';
			sr3_set <= '0';
			sr3_clear_n <= '1';
			mem_enable <= '0';
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is
				------------------------------------------------------------------------------------------------------------------------
				when reset =>
					waitrequest <= '1';
					sr0_clear_n <= '0';
					sr1_clear_n <= '0';
					sr2_clear_n <= '0';
					sr3_clear_n <= '0';
				------------------------------------------------------------------------------------------------------------------------
				when idle =>
					command_enable <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_full =>
					waitrequest <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_full_valid =>
					waitrequest <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shiftall =>
					command_enable <= '1';
					readdata_enable <= '1';
					append3_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					mem_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shiftall_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					append3_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					mem_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app0 =>
					command_enable <= '1';
					readdata_enable <= '1';
					append0_enable <= '1';
					sr0_set <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app1 =>
					command_enable <= '1';
					readdata_enable <= '1';
					append1_enable <= '1';
					sr1_set <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app2 =>
					command_enable <= '1';
					readdata_enable <= '1';
					append2_enable <= '1';
					sr2_set <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app3 =>
					command_enable <= '1';
					readdata_enable <= '1';
					append3_enable <= '1';
					sr3_set <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app0_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					append0_enable <= '1';
					sr0_set <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app1_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					append1_enable <= '1';
					sr1_set <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app2_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					append2_enable <= '1';
					sr2_set <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when app3_valid =>
					command_enable <= '1';
					readdata_enable <= '1';
					append3_enable <= '1';
					sr3_set <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift0 =>
					mem_enable <= '1';
					sr0_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift1 =>
					mem_enable <= '1';
					append0_enable <= '1';
					mux0_sel<= '1';
					sr1_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift2 =>
					mem_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					sr2_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift3 =>
					mem_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					sr3_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift0_cmd =>
					mem_enable <= '1';
					append0_enable <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift1_cmd =>
					mem_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift2_cmd =>
					mem_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift3_cmd =>
					mem_enable <= '1';
					append3_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when cmdonly =>
					mem_enable <= '1';
					muxcom_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift0_valid =>
					mem_enable <= '1';
					sr0_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift1_valid =>
					mem_enable <= '1';
					append0_enable <= '1';
					mux0_sel <= '1';
					sr1_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift2_valid =>
					mem_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					sr2_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift3_valid =>
					mem_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					sr3_clear_n <= '0';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift0_cmd_valid =>
					mem_enable <= '1';
					append0_enable <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift1_cmd_valid =>
					mem_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift2_cmd_valid =>
					mem_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when shift3_cmd_valid =>
					mem_enable <= '1';
					append3_enable <= '1';
					append2_enable <= '1';
					append1_enable <= '1';
					append0_enable <= '1';
					mux2_sel <= '1';
					mux1_sel <= '1';
					mux0_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when cmdonly_valid =>
					mem_enable <= '1';
					muxcom_sel <= '1';
					readdata_enable <= '1';
					command_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
			end case;
		end process control_signals_definition;

end architecture fsm;

-------------------------------------------------------------------------------------------------------------------------------------
