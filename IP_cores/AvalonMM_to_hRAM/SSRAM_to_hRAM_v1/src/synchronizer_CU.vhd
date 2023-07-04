-- synchronizer_CU.vhd -----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity synchronizer_CU is
	port
	(
    -- clock:
    clk                       : in    std_logic;
		-- status signals:
    burst_end                 : in		std_logic;
    start_sampling            : in		std_logic;
    enable                    : in		std_logic;
    clear_n                   : in		std_logic;
		-- control signals:
    system_clear_n            : out		std_logic;
    system_enable             : out		std_logic;
    burstlen_enable           : out		std_logic;
    burstlen_counter_enable   : out		std_logic;
    dataout_enable            : out		std_logic;
    data_counter_enable       : out		std_logic;
    busy                      : out		std_logic;
    validout                  : out		std_logic
	);
end entity synchronizer_CU;

------------------------------------------------------------------------------------------------------------------------------------

architecture fsm of synchronizer_CU is

	-- states definition ------------------------------------------------------------------------------------------------------------
	type state is
	(
		reset,
    idle,
    idle_disabled,
    reception_init,
    reception,
    reception_end_1,
    reception_end_2,
    idle_clear
	);

	-- states declaration -----------------------------------------------------------------------------------------------------------
	signal present_state		: state;
	signal next_state				: state;

	begin

		-- evaluation of the next state ----------------------------------------------------------------------------------------------
		next_state_evaluation: process
		(
			-- sensitivity list
      present_state,
      burst_end,
      start_sampling,
      enable
		)
		begin
			case present_state is
				---------------------------------------------------------------------------------------------------------------------
				when reset =>
          if (enable = '1') then
            next_state <= idle;
          else
            next_state <= idle_disabled;
          end if;
				---------------------------------------------------------------------------------------------------------------------
				when idle =>
          if (start_sampling = '1') then
            next_state <= reception_init;
          else
            next_state <= idle;
          end if;
        ---------------------------------------------------------------------------------------------------------------------
				when idle_disabled =>
          if (enable = '1') then
            next_state <= idle;
          else
            next_state <= idle_disabled;
          end if;
        ---------------------------------------------------------------------------------------------------------------------
				when reception_init =>
          next_state <= reception;
        ---------------------------------------------------------------------------------------------------------------------
				when reception =>
          if (burst_end = '1') then
            next_state <= reception_end_1;
          else
            next_state <= reception;
          end if;
        ---------------------------------------------------------------------------------------------------------------------
				when reception_end_1 =>
          next_state <= reception_end_2;
        ---------------------------------------------------------------------------------------------------------------------
				when reception_end_2 =>
          next_state <= idle_clear;
        ---------------------------------------------------------------------------------------------------------------------
				when idle_clear =>
          next_state <= idle_clear;
				---------------------------------------------------------------------------------------------------------------------
				when others =>
					next_state <= reset;
				---------------------------------------------------------------------------------------------------------------------
			end case;
		end process next_state_evaluation;

		-- state transition ----------------------------------------------------------------------------------------------------------
		state_transition: process (clk, rst_n)
		begin
			if (rst_n = '0') then
				present_state <= reset;
			elsif (rising_edge(clk)) then
        if (clear_n = '0') then
          present_state <= reset;
        else
				  present_state <= next_state;
        end if;
			end if;
		end process state_transition;

		-- control signals definition ------------------------------------------------------------------------------------------------
		control_signals_definition: process (present_state)
		begin
			-- default values ---------------------------------------------------------------------------------------------------------
      system_clear_n <= '1';
      system_enable <= '0';
      burstlen_enable <= '0';
      burstlen_counter_enable <= '0';
      dataout_enable <= '0';
      data_counter_enable <= '0';
      busy <= '0';
      validout <= '0';
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is
				------------------------------------------------------------------------------------------------------------------------
        when reset =>
          busy <= '1';
          system_clear_n <= '0';
        ---------------------------------------------------------------------------------------------------------------------
        when idle =>
          system_enable <= '1';
          burstlen_enable <= '1';
        ---------------------------------------------------------------------------------------------------------------------
        when idle_disabled =>

        ---------------------------------------------------------------------------------------------------------------------
        when reception_init =>
          busy <= '1';
          system_enable <= '1';
          dataout_enable <= '1';
          data_counter_enable <= '1';
          burstlen_counter_enable <= '1';
        ---------------------------------------------------------------------------------------------------------------------
        when reception =>
          busy <= '1';
          system_enable <= '1';
          dataout_enable <= '1';
          data_counter_enable <= '1';
          burstlen_counter_enable <= '1';
          validout <= '1';
        ---------------------------------------------------------------------------------------------------------------------
        when reception_end_1 =>
          busy <= '1';
          system_clear_n <= '0';
        ---------------------------------------------------------------------------------------------------------------------
        when reception_end_2 =>
          busy <= '1';
          system_clear_n <= '0';
        ---------------------------------------------------------------------------------------------------------------------
        when idle_clear =>
          system_clear_n <= '0';
        ---------------------------------------------------------------------------------------------------------------------
			end case;
		end process control_signals_definition;

end architecture fsm;

-------------------------------------------------------------------------------------------------------------------------------------
