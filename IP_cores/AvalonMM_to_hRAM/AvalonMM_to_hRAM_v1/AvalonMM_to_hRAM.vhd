-- AvalonMM_to_hyperRamS27KL0641.vhd ------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- component able to interface an Avalon Memory-Mapped bus with a hyperRAM model S27KL0641

-- avs_s0_address: memory address
-- avs_s0_read: select read operation 
-- avs_s0_write: select write operation
-- avs_s0_readdata: read result
-- avs_s0_writedata: data to be written in the memory

-- if both avs_s0_read and avs_s0_write are active, the operation is interpreted as a read

-- avs_s0_readdata is only available a certain (variable) number of clock cycles after the read command
-- avs_s0_readdatavalid is asserted when avs_s0_readdata is valid

-- avs_s0_waitrequest is asserted when the component is not able to process any other operation
-- when avs_s0_waitrequest is asserted the value of the input signals provided by the AvalonMM bus must not be changed
-- the component asserts avs_s0_waitrequest after acquiring 5 non-completed operations

-------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_hyperRamS27KL0641 is
	port
	(
		-- IP - avalon
		avs_s0_address     		: in    std_logic_vector(31 downto 0) 	:= (others => '0');
		avs_s0_read        		: in    std_logic                     	:= '0';
		avs_s0_write       		: in    std_logic                     	:= '0';
		avs_s0_writedata   		: in    std_logic_vector(15 downto 0) 	:= (others => '0');
		avs_s0_readdata    		: out   std_logic_vector(15 downto 0) 	;
		avs_s0_waitrequest 		: out   std_logic								;
		avs_s0_readdatavalid 	: out   std_logic								;
		-- clock and reset
		clock_clk          		: in    std_logic                     	:= '0';
		reset_reset        		: in    std_logic                     	:= '0';
		-- IP - hyperbus
		hbus_d             		: inout std_logic_vector(7 downto 0)  	:= (others => '0');
		hbus_rwds          		: inout std_logic                     	:= '0';
		hbus_cs            		: out   std_logic								;
		hbus_rst           		: out   std_logic								;
		hbus_ck            		: out   std_logic
	);
end entity AvalonMM_to_hyperRamS27KL0641;

-------------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_hyperRamS27KL0641 is

	-- AvalonMM to SSRAM converter ---------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM is
	port
	(
		-- AvalonMM signals
		avs_s0_address     		: in    	std_logic_vector(31 downto 0);
		avs_s0_read        		: in    	std_logic;
		avs_s0_write       		: in    	std_logic;
		avs_s0_writedata   		: in    	std_logic_vector(15 downto 0);
		avs_s0_readdata    		: out   	std_logic_vector(15 downto 0);
		avs_s0_readdatavalid		: out   	std_logic;
		avs_s0_waitrequest  		: in    	std_logic;
		-- SSRAM signals
		ssram_out             	: in		std_logic_vector(15 downto 0);
		ssram_in             	: out		std_logic_vector(15 downto 0);
		ssram_address         	: out		std_logic_vector(31 downto 0);
		ssram_OE						: out		std_logic;
		ssram_WE						: out		std_logic;
		ssram_CS						: out		std_logic;
		ssram_validout				: in		std_logic;
		ssram_busy					: in		std_logic;
		-- clock and reset
		clk		          		: in    	std_logic;
		rst_n			        		: in    	std_logic
	);
	end component;
	
	-- SSRAM to hyperRAM converter ---------------------------------------------------------------------------------------------------
	-- 
	--
	--
	
	-- internal signals --------------------------------------------------------------------------------------------------------------
	signal ssram_out            : std_logic_vector(15 downto 0);
	signal ssram_in             : std_logic_vector(15 downto 0);
	signal ssram_address        : std_logic_vector(31 downto 0);
	signal ssram_OE					: std_logic;
	signal ssram_WE					: std_logic;
	signal ssram_CS					: std_logic;
	signal ssram_validout			: std_logic;
	signal ssram_busy				: std_logic;
	
	begin
	
		avs_ssram: AvalonMM_to_SSRAM port map
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
			ssram_CS,
			ssram_validout,
			ssram_busy,
			clock_clk,
			reset_reset
		);
		
		-- ISTANZIARE CONVERTITORE SSRAM TO HYPERRAM UNA VOLTA CREATO
		--
		--
		--

end architecture rtl;

-------------------------------------------------------------------------------------------------------------------------------------