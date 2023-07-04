-- synchronizer_testbench.vhd -----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- testbench file for synchronizer
-- the driver (input application) and the monitor (output storage) are created locally
-- the sequencer (input generation) and the scoreboard (output verification) are implemented in Python

-- the driver is able to read an input file (containing the data) and to send them to the DUT together with the strobe
-- the strobe is sent to the DUT with a configurable shift with respect to the rising edge of the clock
-- the data is sent to the DUT so that the strobe is center-aligned with it

----------------------------------------------------------------------------------------------------------------------

entity synchronizer_testbench is
end synchronizer_testbench;

----------------------------------------------------------------------------------------------------------------------

architecture behavior of synchronizer_testbench is

	-- constants ------------------------------------------------------------------------------------------------------
	constant N_burstcount 				: integer := 4;
	constant burstcount 					: std_logic_vector((N_burstcount-1) downto 0) := "1000";
	constant clock_period					: time	:= 10 ns;
	constant reset_stop						: time	:= 15 ns;
	constant strobe_shift					: time	:= 5 ns;

	-- clock and reset signals -----------------------------------------------------------------------------------------
	signal clk		          			: std_logic;
	signal rst_n			        		: std_logic;

	-- DUT signals -----------------------------------------------------------------------------------------------------

	-- simulation signals ----------------------------------------------------------------------------------------------
	signal start_sim							: std_logic;
	signal stop_sim								: std_logic;

	-- DUT -------------------------------------------------------------------------------------------------------------
	component synchronizer is
		generic
	  (
	    N_burstcount              : integer := 11
	  );
		port
		(
			clk                       : in    std_logic;
			synch_enable              : in		std_logic;
			synch_clear_n             : in		std_logic;
			burstcount                : in		std_logic_vector((N_burstcount-1) downto 0);
			din_strobe                : in		std_logic;
			din                       : in		std_logic_vector(15 downto 0);
			dout                      : out		std_logic_vector(15 downto 0);
			synch_validout            : out		std_logic;
			synch_busy                : out		std_logic
		);
	end component;

	-- clock and reset generator --------------------------------------------------------------------------------------
	component clk_rst_generator is
	generic
	(
		clockperiod	: time	:= 10 ns;			-- clock period
		resetStop		: time	:= 15 ns			-- initial time interval during which the reset signal is set
	);
	port
	(
		clk 				: out std_logic;
		rstN	 			: out std_logic;
		start_sim		: in 	std_logic;
		stop_sim		: in	std_logic
	);
	end component;

	-- monitor ------------------------------------------------------------------------------------------------------
	component synchronizer_monitor is
	port
	(
		clk											: in		std_logic;
		dout										: in		std_logic_vector(15 downto 0);
		synch_validout					: in		std_logic;
		start_sim								: in		std_logic;
		stop_sim								: in		std_logic
	);
	end component;

	-- driver --------------------------------------------------------------------------------------------------------
	component synchronizer_driver is
	generic
	(
		strobe_shift					: time := 0 ns;
		clock_period					: time := 10 ns
	);
	port
	(
		clk										: in		std_logic;
		rst_n									: in  	std_logic;
		synch_enable          : out		std_logic;
		synch_clear_n         : out		std_logic;
		din_strobe            : out		std_logic;
		din                   : out		std_logic_vector(15 downto 0);
		synch_busy            : in		std_logic
	);
	end component;

	begin

		DUT: synchronizer

end behavior;

----------------------------------------------------------------------------------------------------------------------
