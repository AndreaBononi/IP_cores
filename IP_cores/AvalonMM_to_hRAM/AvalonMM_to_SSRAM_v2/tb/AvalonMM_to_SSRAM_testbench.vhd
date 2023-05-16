-- AvalonMM_to_SSRAM_testbench.vhd -----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- testbench file for Avalon_to_SSRAM
-- only the driver (input application) and the monitor (output storage) are created locally
-- the sequencer (input generation) and the scoreboard (output verification) are implemented in Python

----------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_testbench is
end AvalonMM_to_SSRAM_testbench;

----------------------------------------------------------------------------------------------------------------------

architecture behavior of AvalonMM_to_SSRAM_testbench is

	-- constants ------------------------------------------------------------------------------------------------------
	constant clock_period: time := 10 ns;
	constant reset_time: time := 15 ns;
	constant custom_delay: time := 1 ns;
	constant ssram_valid_time: time := 25 ns;

	-- signals --------------------------------------------------------------------------------------------------------
	signal avs_s0_address     		: std_logic_vector(31 downto 0);
	signal avs_s0_read        		: std_logic;
	signal avs_s0_write       		: std_logic;
	signal avs_s0_writedata   		: std_logic_vector(15 downto 0);
	signal avs_s0_readdata    		: std_logic_vector(15 downto 0);
	signal avs_s0_readdatavalid		: std_logic;
	signal avs_s0_waitrequest  		: std_logic;
	signal ssram_out             	: std_logic_vector(15 downto 0);
	signal ssram_in             	: std_logic_vector(15 downto 0);
	signal ssram_address         	: std_logic_vector(31 downto 0);
	signal ssram_OE								: std_logic;
	signal ssram_WE								: std_logic;
	signal ssram_validout					: std_logic;
	signal ssram_busy							: std_logic;
	signal ssram_clear_n					: std_logic;
	signal clk		          			: std_logic;
	signal rst_n			        		: std_logic;
	signal start_sim          		: std_logic;
	signal stop_sim		        		: std_logic;

	-- DUT ------------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM is
	port
	(
		-- AvalonMM signals
		avs_s0_address     		: in    	std_logic_vector(31 downto 0);
		avs_s0_read        		: in    	std_logic;
		avs_s0_write       		: in    	std_logic;
		avs_s0_writedata   		: in    	std_logic_vector(15 downto 0);
		avs_s0_readdata    		: out   	std_logic_vector(15 downto 0);
		avs_s0_readdatavalid	: out   	std_logic;
		avs_s0_waitrequest  	: out   	std_logic;
		-- SSRAM signals
		ssram_out             : in		std_logic_vector(15 downto 0);
		ssram_in             	: out		std_logic_vector(15 downto 0);
		ssram_address         : out		std_logic_vector(31 downto 0);
		ssram_OE							: out		std_logic;
		ssram_WE							: out		std_logic;
		ssram_validout				: in		std_logic;
		ssram_busy						: in		std_logic;
		ssram_clear_n					: out		std_logic;
		-- clock and reset
		clk		          			: in    	std_logic;
		rst_n			        		: in    	std_logic
	);
	end component;

	-- SSRAM ----------------------------------------------------------------------------------------------------------
	component ssram32 is
	generic
	(
		N 								: integer 	:= 32;
		valid_time				: time 		:= 5 ns
	);
	port
	(
		ssram32_clk				: in 	std_logic;
		ssram32_clear_n		: in 	std_logic;
		ssram32_OE				: in 	std_logic;
		ssram32_WE				: in 	std_logic;
		ssram32_CS				: in 	std_logic;
		ssram32_address		: in 	std_logic_vector(31 downto 0);
		ssram32_in				: in 	std_logic_vector(N-1 downto 0);
		ssram32_out				: out std_logic_vector(N-1 downto 0);
		ssram32_validout	: out std_logic;
		ssram32_busy			: out std_logic
	);
	end component;

	-- clock and reset generator --------------------------------------------------------------------------------------
	component clk_rst_generator is
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
	end component;

	-- monitor ------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_monitor is
	port
	(
		clk											: in		std_logic;
		rst_n										: in  	std_logic;
		avs_s0_readdatavalid		: in		std_logic;
		avs_s0_readdata	 				: in 		std_logic_vector(15 downto 0);
		start_sim								: in		std_logic;
		stop_sim								: in		std_logic
	);
	end component;

	-- driver --------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_driver is
	generic
	(
		custom_delay					: time := 0 ns
	);
	port
	(
		clk										: in		std_logic;
		rst_n									: in  	std_logic;
		avs_s0_waitrequest 		: in		std_logic;
		avs_s0_readdatavalid	: in		std_logic;
		avs_s0_readdata	 			: in 		std_logic_vector(15 downto 0);
		avs_s0_address				: out		std_logic_vector(31 downto 0);
		avs_s0_read       		: out 	std_logic;
		avs_s0_write      		: out 	std_logic;
		avs_s0_writedata  		: out 	std_logic_vector(15 downto 0);
		start_sim							: out		std_logic := '0';
		stop_sim							: out		std_logic := '0'
	);
	end component;

	begin
		-- clock and reset generator instance --------------------------------------------------------------------------
		clock_reset: clk_rst_generator
		generic map
		(
			clock_period,
			reset_time
		)
		port map
		(
			clk,
			rst_n,
			start_sim,
			stop_sim
		);

		-- DUT instance ------------------------------------------------------------------------------------------------
		DUT: AvalonMM_to_SSRAM
		port map
		(
			avs_s0_address,
			avs_s0_read,
			avs_s0_write,
			avs_s0_writedata,
			avs_s0_readdata,
			avs_s0_readdatavalid,
			avs_s0_waitrequest,
			ssram_out,
			ssram_in,
			ssram_address,
			ssram_OE,
			ssram_WE,
			ssram_validout,
			ssram_busy,
			ssram_clear_n,
			clk,
			rst_n
		);

		-- SSRAM instance ----------------------------------------------------------------------------------------------
		mem: ssram32
		generic map
		(
			16,
			ssram_valid_time
		)
		port map
		(
			clk,
			rst_n,
			ssram_OE,
			ssram_WE,
			'1',
			ssram_address,
			ssram_in,
			ssram_out,
			ssram_validout,
			ssram_busy
		);

		-- driver instance ---------------------------------------------------------------------------------------------
		driver: AvalonMM_to_SSRAM_driver
		generic map
		(
			custom_delay
		)
		port map
		(
			clk,
			rst_n,
			avs_s0_waitrequest,
			avs_s0_readdatavalid,
			avs_s0_readdata,
			avs_s0_address,
			avs_s0_read,
			avs_s0_write,
			avs_s0_writedata,
			start_sim,
			stop_sim
		);

		-- monitor instance --------------------------------------------------------------------------------------------
		monitor: AvalonMM_to_SSRAM_monitor
		port map
		(
			clk,
			rst_n,
			avs_s0_readdatavalid,
			avs_s0_readdata,
			start_sim,
			stop_sim
		);

end behavior;

----------------------------------------------------------------------------------------------------------------------
