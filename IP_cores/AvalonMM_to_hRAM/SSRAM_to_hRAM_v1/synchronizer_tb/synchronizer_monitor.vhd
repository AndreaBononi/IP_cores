-- synchronizer_monitor.vhd -----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- synchronizer monitor (output storage)
-- the output file (synchronizer_out.txt") contains the sycnhronized values (thus it should be equal to the file with the input values)
-- it is necessary to set the reset signal at least once in order to start storing data

-- start_sim must be equal to '0' before starting the simulation, then it must remains equal to '1'
-- stop_sim must remain equal to '0' up to the moment in which the simulation ends, when it becomes equal to '1'

------------------------------------------------------------------------------------------------------------------

entity synchronizer_monitor is
	port
	(
		clk											: in		std_logic;
		dout										: in		std_logic_vector(15 downto 0);
		synch_validout					: in		std_logic;
		start_sim								: in		std_logic;
		stop_sim								: in		std_logic
	);
end synchronizer_monitor;

------------------------------------------------------------------------------------------------------------------

architecture tb of synchronizer_monitor is

	file output_file: text;

	begin

		output_file_generation			: process (clk, synch_validout, start_sim, stop_sim)
		variable outputline					: line;
		variable output_file_stat		: file_open_status;
		begin
			file_open(output_file_stat, output_file, "../sim/synchronizer_out.txt", write_mode);
			if (stop_sim = '0') then
				if (start_sim = '1') then
					if (rising_edge(clk)) then
						if (synch_validout = '1') then
							write(outputline, dout);
							writeline(output_file, outputline);
						end if;
					end if;
				end if;
			end if;
		end process output_file_generation;

end tb;

------------------------------------------------------------------------------------------------------------------
