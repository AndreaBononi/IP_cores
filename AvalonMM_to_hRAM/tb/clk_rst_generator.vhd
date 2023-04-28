-- clk_rst_generator.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- clock and reset signals generator
-- custom clock period
-- custom reset time
-- active LOW reset
-- the clock is stopped when stop_sim goes low and when start_sim is not high

-------------------------------------------------------------------------------------------------------------

entity clk_rst_generator is
	generic	
	(
		clockperiod	: time	:= 10 ns;		-- clock period
		resetStop		: time	:= 15 ns			-- initial time interval during which the reset signal is set
	);		
	port 	
	(
		clk 				: out std_logic;
		rstN	 			: out std_logic;
		start_sim		: in 	std_logic;
		stop_sim		: in	std_logic
	);
end clk_rst_generator;

-------------------------------------------------------------------------------------------------------------

architecture behavior of clk_rst_generator is

	signal local_clk: std_logic := '0';
	
	begin
		
		-- clock generation process ---------------------------------------------------------------------------
		clockGen: process
		begin
			local_clk <= not local_clk;
			wait for clockPeriod/2;
		end process clockGen;
		clk <= local_clk and not stop_sim and start_sim;
		
		-- reset generation process ---------------------------------------------------------------------------
		resetGen: process
		begin
			rstN <= '0';
			wait for resetStop;
			rstN <= '1';
			wait;
		end process resetGen;
		
end behavior;

-------------------------------------------------------------------------------------------------------------
