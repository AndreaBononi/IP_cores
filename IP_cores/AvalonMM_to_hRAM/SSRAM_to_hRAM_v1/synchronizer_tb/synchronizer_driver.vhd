-- synchronizer_driver.vhd ----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- synchronizer driver
-- "synchronizer_in.txt" contains the sequence of 16-bit data (one per row) to be provided to the synchronizer
-- it provides the strb signal to the DUT with a configurable shift (strb_shift) with respect to the clock
-- it provides the data to the DUT center-aligned with the strb
-- it starts to provide the strb and the sequence of data only after a reset
-- it generates the start_sim signal ('0' at the beginning, '1' after the initial reset)
-- it generates the stop_sim signal ('0' upt to the end of the input file, '1' after)

------------------------------------------------------------------------------------------------------------------

entity synchronizer_driver is
generic
(
	strobe_shift					: time := 0 ns;
	clock_period					: time := 10 ns
);
port
(
	clk										: in		std_logic;
	rst_n									: in  	std_logic;
	synch_enable          : out		std_logic := '1';
	din_strobe            : out		std_logic := '0';
	din                   : out		std_logic_vector(15 downto 0);
	synch_busy            : in		std_logic;
	start_sim							:	out		std_logic := '0';
	stop_sim							: out		std_logic := '0'
);
end synchronizer_driver;

------------------------------------------------------------------------------------------------------------------

architecture tb of synchronizer_driver is

	file 		input_file	: text;
	signal 	strb				:	std_logic := '0';
	signal 	strobe_on		: std_logic := '0';

	begin
		input_driving								: process (clk, rst_n, synch_busy)
		variable inputline					: line;
		variable input_file_stat		: file_open_status;
		variable input_data					: std_logic_vector(15 downto 0);
		begin
			file_open(input_file_stat, input_file, "../synchronizer_sim/synchronizer_in.txt", read_mode);
			if (rst_n = '0') then
				start_sim <= '1';
			else
				if (not endfile(input_file)) then
					if (rising_edge(clk)) then
						readline(input_file, inputline);
						read(inputline, input_data);
						strobe_on <= '1' after (strobe_shift + clock_period/2);
						din <= input_data after (strobe_shift + clock_period/2);
						--strobe_on <= '1' after (clock_period/2);
						--din <= input_data after (clock_period/2);
					end if;
				else
					if (synch_busy = '0') then
						stop_sim <= '1';
					end if;
				end if;
			end if;
		end process input_driving;
		strb <= transport clk after (strobe_shift + clock_period);
		--strb <= transport clk after (clock_period);
		din_strobe <= strb and strobe_on;

end tb;

---------------------------------------------------------------------------------------------------------------
