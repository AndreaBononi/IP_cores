-- AvalonMM_to_SSRAM_monitor.vhd -----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- monitor (output storage) for AvalonMM_to_SSRAM
-- the output file ("AvalonMM_to_SSRAM_readValues.txt") contains the reading results
-- it is necessary to set the reset signal at least once in order to start storing data

-- start_sim is equal to '0' before starting the simulation, then it remains equal to '1'
-- stop_sim remains equal to '0' up to the moment in which the simulation must be stopped, when it becomes equal to '1'

------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_monitor is
	port
	(
		clk											: in		std_logic;
		rst_n										: in  	std_logic;
		avs_s0_readdatavalid		: in		std_logic;
		avs_s0_readdata	 				: in 		std_logic_vector(15 downto 0);
		start_sim								: in		std_logic;
		stop_sim								: in		std_logic
	);
end AvalonMM_to_SSRAM_monitor;

------------------------------------------------------------------------------------------------------------------

architecture behavior of AvalonMM_to_SSRAM_monitor is

	file output_file: text;

	begin

		output_file_generation			: process (clk, avs_s0_readdatavalid, start_sim, stop_sim)
		variable outputline					: line;
		variable output_file_stat		: file_open_status;
		begin
			file_open(output_file_stat, output_file, "../sim/AvalonMM_to_SSRAM_readValues.txt", write_mode);
			if (stop_sim = '0') then
				if (start_sim = '1') then
					if (rising_edge(clk)) then
						if (avs_s0_readdatavalid = '1') then
							write(outputline, avs_s0_readdata);
							writeline(output_file, outputline);
						end if;
					end if;
				end if;
			end if;
		end process output_file_generation;

end behavior;

------------------------------------------------------------------------------------------------------------------
