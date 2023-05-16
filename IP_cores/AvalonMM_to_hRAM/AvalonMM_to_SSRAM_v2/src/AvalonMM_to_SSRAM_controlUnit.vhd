-- AvalonMM_to_SSRAM_controlUnit.vhd -----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_controlUnit is
	port
	(
		-- clock and reset
		clk											: in 		std_logic;
		rst_n										: in		std_logic;
		-- status signals
		mem_validout						: in		std_logic;
		mem_busy								: in		std_logic;
		mem_avail								: in		std_logic;
		fifo4_full							: in		std_logic;
		fifo4_almost_full				: in		std_logic;
		fifo4_empty							: in		std_logic;
		op_req									: in		std_logic;
		previous_op_req					: in		std_logic;
		-- control signals
		waitrequest							: out		std_logic;
		readdatavalid						: out		std_logic;
		readdata_enable					: out		std_logic;
		command_enable					: out		std_logic;
		por_enable							: out		std_logic;
		por_clear_n							: out		std_logic;
		tgl_clear_n							: out		std_logic;
		mem_enable							: out		std_logic;
		fifo4_push							: out		std_logic;
		fifo4_pop								: out		std_logic;
		fifo4_clear_n						: out		std_logic
	);
end entity AvalonMM_to_SSRAM_controlUnit;

------------------------------------------------------------------------------------------------------------------------------------

architecture fsm of AvalonMM_to_SSRAM_controlUnit is

	-- states definition ------------------------------------------------------------------------------------------------------------
	type state is
	(
		reset,
		idle,
		idle_pop,
		idle_valid,
		idle_pop_valid,
		push,
		push_pop,
		push_valid,
		push_pop_valid,
		waiting,
		waiting_pop,
		waiting_valid,
		waiting_pop_valid,
		push_afterfull,
		push_afterfull_pop,
		push_afterfull_valid,
		push_afterfull_pop_valid
	);

	-- states declaration -----------------------------------------------------------------------------------------------------------
	signal present_state		: state;
	signal next_state				: state;

	begin

		-- evaluation of the next state ----------------------------------------------------------------------------------------------
		next_state_evaluation: process
		(
			-- sensitivity list
			rst_n, present_state,
			mem_validout, mem_busy, mem_avail,
			fifo4_full, fifo4_almost_full, fifo4_empty,
			op_req, previous_op_req
		)
		begin
			if (rst_n = '0') then
				next_state <= reset;
			else
				case present_state is
					---------------------------------------------------------------------------------------------------------------------
					when reset =>
						next_state <= idle;
					---------------------------------------------------------------------------------------------------------------------
					when
						idle | idle_pop | idle_valid | idle_pop_valid | push | push_pop | push_valid | push_pop_valid |
						push_afterfull | push_afterfull_pop | push_afterfull_valid | push_afterfull_pop_valid
						=>
						if (mem_validout = '1') then
							if (op_req = '1') then
								if (previous_op_req = '1') then
									if (fifo4_almost_full = '1') then
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= waiting_pop_valid;
										else
											next_state <= waiting_valid;
										end if;
									else
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= push_pop_valid;
										else
											next_state <= push_valid;
										end if;
									end if;
								else
									if (fifo4_full = '1') then
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= waiting_pop_valid;
										else
											next_state <= waiting_valid;
										end if;
									else
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= push_pop_valid;
										else
											next_state <= push_valid;
										end if;
									end if;
								end if;
							else
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= idle_pop_valid;
								else
									next_state <= idle_valid;
								end if;
							end if;
						else
							if (op_req = '1') then
								if (previous_op_req = '1') then
									if (fifo4_almost_full = '1') then
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= waiting_pop;
										else
											next_state <= waiting;
										end if;
									else
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= push_pop;
										else
											next_state <= push;
										end if;
									end if;
								else
									if (fifo4_full = '1') then
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= waiting_pop;
										else
											next_state <= waiting;
										end if;
									else
										if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
											next_state <= push_pop;
										else
											next_state <= push;
										end if;
									end if;
								end if;
							else
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= idle_pop;
								else
									next_state <= idle;
								end if;
							end if;
						end if;
					---------------------------------------------------------------------------------------------------------------------
					when waiting | waiting_pop | waiting_valid | waiting_pop_valid =>
						if (mem_validout = '1') then
							if (fifo4_full = '1') then
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= waiting_pop_valid;
								else
									next_state <= waiting_valid;
								end if;
							else
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= push_afterfull_pop_valid;
								else
									next_state <= push_afterfull_valid;
								end if;
							end if;
						else
							if (fifo4_full = '1') then
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= waiting_pop;
								else
									next_state <= waiting;
								end if;
							else
								if (mem_busy = '0' and fifo4_empty = '0' and mem_avail = '1') then
									next_state <= push_afterfull_pop;
								else
									next_state <= push_afterfull;
								end if;
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
			waitrequest <= '0';
			readdatavalid <= '0';
			readdata_enable <= '0';
			command_enable <= '0';
			por_enable <= '0';
			por_clear_n <= '1';
			fifo4_push <= '0';
			fifo4_clear_n <= '1';
			tgl_clear_n	<= '1';
			mem_enable <= '0';
			fifo4_pop	<= '0';
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is
				------------------------------------------------------------------------------------------------------------------------
				when reset =>
					waitrequest <= '1';
					fifo4_clear_n <= '0';
					por_clear_n <= '0';
					tgl_clear_n <= '0';
				------------------------------------------------------------------------------------------------------------------------
				when idle =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_pop =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_pop_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_pop =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_pop_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull_pop =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull_pop_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting =>
					waitrequest <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting_pop =>
					waitrequest <= '1';
					readdata_enable <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting_valid =>
					waitrequest <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting_pop_valid =>
					waitrequest <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
					mem_enable <= '1';
					fifo4_pop <= '1';
				------------------------------------------------------------------------------------------------------------------------
			end case;
		end process control_signals_definition;

end architecture fsm;

-------------------------------------------------------------------------------------------------------------------------------------
