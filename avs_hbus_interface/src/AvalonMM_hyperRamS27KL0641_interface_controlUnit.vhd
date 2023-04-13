-- AvalonMM_hyperRamS27KL0641_interface_controlUnit.vhd ---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_hyperRamS27KL0641_interface_controlUnit is
	port
	(
		-- clock and reset -----------------------------------------------------------------------------------------------------------
		clk						: in std_logic;
		rst_n						: in std_logic;
		-- status signals ---------------------------------------------------------------------------------------------------------------
		ssram32_valid 			: in std_logic;
		avs_s0_write			: in std_logic;
		avs_s0_read				: in std_logic;
		-- control signals -----------------------------------------------------------------------------------------------------------
		ssram32_write			: out std_logic;
		ssram32_read			: out std_logic;
		ssram32_clear_n		: out std_logic;
		data_sel					: out std_logic;
		data_enable				: out std_logic;
		data_clear_n			: out std_logic;
		address_enable			: out std_logic;
		address_clear_n		: out std_logic;
		avs_s0_waitrequest	: out std_logic;
		avs_s0_readdatavalid	: out std_logic		-- ANCORA DA DEFINIRE NELL'ARCHITETTURA
	);
end entity AvalonMM_hyperRamS27KL0641_interface_controlUnit;

------------------------------------------------------------------------------------------------------------------------------------

architecture fsm of AvalonMM_hyperRamS27KL0641_interface_controlUnit is

	-- states definition -----------------------------------------------------------------------------------------------------------
	type state is
	(
		reset,
		idle,
		reading,
		wait_reading,
		store_reading,
		writing,
		wait_writing
	);

	-- states declaration ----------------------------------------------------------------------------------------------------------
	signal present_state		: state;
	signal next_state			: state;

	begin

		-- evaluation of the next state ---------------------------------------------------------------------------------------------
		next_state_evaluation: process (rst_n, present_state, ssram32_valid, avs_s0_write, avs_s0_read)
		begin
			if (rst_n = '0') then
				next_state <= reset;
			else
				case present_state is
					when reset =>
						next_state <= idle;
					when idle =>
						if (avs_s0_read = '1') then
							next_state <= reading;
						else
							if (avs_s0_write = '1') then
								next_state <= writing;
							else
								next_state <= idle;
							end if;
						end if;
					when reading =>
						if (ssram32_valid = '1') then
							next_state <= store_reading;
						else
							next_state <= wait_reading;
						end if;
					when wait_reading =>
						if (ssram32_valid = '1') then
							next_state <= store_reading;
						else
							next_state <= wait_reading;
						end if;
					when store_reading =>
						next_state <= idle;
					when writing =>
						if (ssram32_valid = '1') then
							next_state <= idle;
						else
							next_state <= wait_writing;
						end if;
					when wait_writing =>
						if (ssram32_valid = '1') then
							next_state <= idle;
						else
							next_state <= wait_writing;
						end if;
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
			data_sel					<= '0';
			ssram32_write			<= '0';
			ssram32_read				<= '0';
			ssram32_clear_n			<= '1';
			data_enable				<= '0';
			data_clear_n			<= '1';
			address_enable			<= '0';
			address_clear_n		<= '1';
			avs_s0_waitrequest	<= '0';
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is
				when reset =>
					address_clear_n <= '0';
					ssram32_clear_n	<= '0';
					data_clear_n <= '0';
				when idle =>
					address_enable <= '1';
					data_enable <= '1';
				when reading =>
					avs_s0_waitrequest <= '1';
					ssram32_read <= '1';
				when wait_reading =>
					avs_s0_waitrequest <= '1';
				when store_reading =>
					avs_s0_waitrequest <= '1';
					data_enable <= '1';
					data_sel <= '1';
				when writing =>
					avs_s0_waitrequest <= '1';
					ssram32_write <= '1';
				when wait_writing =>
					avs_s0_waitrequest <= '1';
			end case;
		end process control_signals_definition;

end architecture fsm;

-------------------------------------------------------------------------------------------------------------------------------------
