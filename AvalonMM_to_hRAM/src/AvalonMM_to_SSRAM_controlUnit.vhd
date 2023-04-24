-- AvalonMM_to_SSRAM_controlUnit.vhd -----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_controlUnit is
	port
	(
		-- clock and reset
		clk						: in 		std_logic;
		rst_n						: in		std_logic;
		-- status signals
		mem_validout			: in		std_logic;
		op_req					: in		std_logic;
		previous_op_req		: in		std_logic;
		fifo4_full				: in		std_logic;
		fifo4_almost_full		: in		std_logic;
		-- control signals
		waitrequest				: out		std_logic;
		readdatavalid			: out		std_logic;
		readdata_enable		: out		std_logic;
		command_enable			: out		std_logic;
		por_enable				: out		std_logic;
		por_clear_n				: out		std_logic;
		fifo4_push				: out		std_logic;
		fifo4_clear_n			: out		std_logic
	);
end entity AvalonMM_to_SSRAM_controlUnit;

------------------------------------------------------------------------------------------------------------------------------------

architecture fsm of AvalonMM_to_SSRAM_controlUnit is

	-- states definition ------------------------------------------------------------------------------------------------------------
	type state is
	(
		reset,
		idle,
		idle_valid,
		push,
		push_valid,
		waiting,
		waiting_valid,
		push_afterfull,
		push_afterfull_valid
	);

	-- states declaration -----------------------------------------------------------------------------------------------------------
	signal present_state		: state;
	signal next_state			: state;

	begin

		-- evaluation of the next state ----------------------------------------------------------------------------------------------
		next_state_evaluation: process (rst_n, present_state, mem_validout, op_req, previous_op_req, fifo4_full, fifo4_almost_full)
		begin
			if (rst_n = '0') then
				next_state <= reset;
			else
				case present_state is
					---------------------------------------------------------------------------------------------------------------------
					when reset =>
						next_state <= idle;
					---------------------------------------------------------------------------------------------------------------------
					when idle | idle_valid | push | push_valid | push_afterfull | push_afterfull_valid =>
						if (mem_validout = '1') then
							if (op_req = '1') then
								if (previous_op_req = '1') then
									if (fifo4_almost_full = '1') then
										next_state <= waiting_valid;
									else
										next_state <= push_valid;
									end if;
								else
									if (fifo4_full = '1') then
										next_state <= waiting_valid;
									else
										next_state <= push_valid;
									end if;
								end if;
							else
								next_state <= idle_valid;
							end if;
						else
							if (op_req = '1') then
								if (previous_op_req = '1') then
									if (fifo4_almost_full = '1') then
										next_state <= waiting;
									else
										next_state <= push;
									end if;
								else
									if (fifo4_full = '1') then
										next_state <= waiting;
									else
										next_state <= push;
									end if;
								end if;
							else
								next_state <= idle;
							end if;
						end if;
					---------------------------------------------------------------------------------------------------------------------
					when waiting | waiting_valid =>
						if (mem_validout = '1') then
							if (fifo4_full = '1') then
								next_state <= waiting_valid;
							else
								next_state <= push_afterfull_valid;
							end if;
						else
							if (fifo4_full = '1') then
								next_state <= waiting;
							else
								next_state <= push_afterfull;
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
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is
				------------------------------------------------------------------------------------------------------------------------
				when reset =>
					waitrequest <= '1';
					fifo4_clear_n <= '0';
					por_clear_n <= '0';
				------------------------------------------------------------------------------------------------------------------------
				when idle =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when idle_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when push_afterfull_valid =>
					command_enable <= '1';
					por_enable <= '1';
					readdata_enable <= '1';
					fifo4_push <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting =>
					waitrequest <= '1';
					readdata_enable <= '1';
				------------------------------------------------------------------------------------------------------------------------
				when waiting_valid =>
					waitrequest <= '1';
					readdata_enable <= '1';
					readdatavalid <= '1';
				------------------------------------------------------------------------------------------------------------------------
			end case;
		end process control_signals_definition;

end architecture fsm;

-------------------------------------------------------------------------------------------------------------------------------------
