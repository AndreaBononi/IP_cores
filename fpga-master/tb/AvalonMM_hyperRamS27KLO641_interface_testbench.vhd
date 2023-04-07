-- AvalonMM_hyperRamS27KL0641_interface_testbench.vhd ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------------------------

entity AvalonMM_hyperRamS27KL0641_interface_testbench is
end AvalonMM_hyperRamS27KL0641_interface_testbench;

----------------------------------------------------------------------------------------------------------------------

architecture behavior of AvalonMM_hyperRamS27KL0641_interface_testbench is

	-- local constants ------------------------------------------------------------------------------------------------
	constant		clock_period			: time := 10 ns;
	constant		reset_time				: time := 15 ns;
	constant 	custom_delay			: time := 1 ns;
	
	-- local signals --------------------------------------------------------------------------------------------------
	signal 		clk						: std_logic;
	signal		rstN						: std_logic;
	signal 		avs_s0_waitrequest 	: std_logic;
	signal		avs_s0_readdata	 	: std_logic_vector(15 downto 0)
	signal		avs_s0_address			: std_logic_vector(31 downto 0); 
	signal		avs_s0_read       	: std_logic;                                 
	signal		avs_s0_write      	: std_logic;             
	signal		avs_s0_writedata  	: std_logic_vector(15 downto 0);
	signal 		hbus_d					: std_logic_vector(7 downto 0);
	signal		hbus_rwds				: std_logic;         
	signal		hbus_cs					: std_logic; 
	signal		hbus_rst					: std_logic; 
	signal		hbus_ck					: std_logic;   
	
	-- DUT ------------------------------------------------------------------------------------------------------------
	component AvalonMM_hyperRamS27KL0641_interface is
		port 
		(
			-- IP - avalon
			avs_s0_address     : in    std_logic_vector(31 downto 0) := (others => '0'); 
			avs_s0_read        : in    std_logic                     := '0';                                 
			avs_s0_write       : in    std_logic                     := '0';             
			avs_s0_writedata   : in    std_logic_vector(15 downto 0) := (others => '0');
			avs_s0_readdata    : out   std_logic_vector(15 downto 0)	;	
			avs_s0_waitrequest : out   std_logic							;
			-- clock and reset
			clock_clk          : in    std_logic                     := '0';             
			reset_reset        : in    std_logic                     := '0';
			-- IP - hyperbus
			hbus_d             : inout std_logic_vector(7 downto 0)  := (others => '0'); 
			hbus_rwds          : inout std_logic                     := '0';             
			hbus_cs            : out   std_logic							;                                        
			hbus_rst           : out   std_logic                    	;             
			hbus_ck            : out   std_logic                                         
		);
	end component;
		
	-- clock and reset generator --------------------------------------------------------------------------------------
	component clk_rst_generator is
		generic	
		(
			clockperiod		: time	:= 10 ns;		-- clock period
			resetStop		: time	:= 15 ns			-- initial time interval during which the reset signal is set
		);		
		port 	
		(
			clk 				: out std_logic;
			rstN	 			: out std_logic
		);
	end component;
		
	-- input generation and output storing ----------------------------------------------------------------------------
	component input_output_generator is
		generic	
		(
			custom_delay			: time := 0 ns
		);	
		port 
		(
			clk						: in		std_logic;
			rstN						: in  	std_logic;
			avs_s0_waitrequest 	: in		std_logic;
			avs_s0_readdata	 	: in 		std_logic_vector(15 downto 0)
			avs_s0_address			: out		std_logic_vector(31 downto 0); 
			avs_s0_read       	: out 	std_logic;                                 
			avs_s0_write      	: out 	std_logic;             
			avs_s0_writedata  	: out 	std_logic_vector(15 downto 0)
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
			rstN
		);
		
		-- input generation and output storing instance ----------------------------------------------------------------
		inout_generator: input_output_generator
		generic map
		(
			custom_delay
		)
		port map
		(
			clk,
			rstN,
			avs_s0_waitrequest,
			avs_s0_readdata,
			avs_s0_address, 
			avs_s0_read,                                 
			avs_s0_write,             
			avs_s0_writedata 
		);
		
		-- DUT instance ------------------------------------------------------------------------------------------------
		DUT: AvalonMM_hyperRamS27KL0641_interface
		port map
		(
			avs_s0_address,
			avs_s0_read,                                
			avs_s0_write,            
			avs_s0_writedata,
			avs_s0_readdata,
			avs_s0_waitrequest,
			clk,            
			rstN,
			hbus_d,
			hbus_rwds,          
			hbus_cs,
			hbus_rst,            
			hbus_ck                                      
		);
			
end behavior;

----------------------------------------------------------------------------------------------------------------------