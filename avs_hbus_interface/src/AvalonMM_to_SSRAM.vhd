-- AvalonMM_to_SSRAM.vhd -----------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- component able to interface an AvalonMM bus with an SSRAM

-- avs_s0_address: memory address
-- avs_s0_read: select read operation 
-- avs_s0_write: select write operation
-- avs_s0_readdata: read result
-- avs_s0_writedata: data to be written in the memory

-- if both avs_s0_read and avs_s0_write are active, the operation is interpreted as a read

-- avs_s0_readdata is only available a certain (variable) number of clock cycles after the read command has been provided
-- avs_s0_readdatavalid is asserted when avs_s0_readdata is valid

-- avs_s0_waitrequest is asserted when the component is not able to process any other operation
-- when avs_s0_waitrequest is asserted the value of the input signals provided by the AvalonMM bus must not be changed
-- the component asserts avs_s0_waitrequest after acquiring 5 non-completed operations

-- the SSRAM must be able to notify the component when it is busy and when it provides a valid reading result

-----------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM is
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
end entity AvalonMM_to_SSRAM;

----------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_SSRAM is

	-- execution unit -------------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_executionUnit is
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
		rst_n			        		: in    	std_logic;
		-- status signals:
		op_req						: out		std_logic;
		sr3_out						: out		std_logic;
		sr2_out						: out		std_logic;
		sr1_out						: out		std_logic;
		sr0_out						: out		std_logic;
		mem_validout				: out		std_logic;
		mem_busy						: out		std_logic;
		-- control signals:
		readdatavalid				: in		std_logic;
		waitrequest					: in		std_logic;
		readdata_enable			: in		std_logic;
		command_enable				: in		std_logic;
		muxcom_sel					: in		std_logic;
		mux0_sel						: in		std_logic;
		mux1_sel						: in		std_logic;
		mux2_sel						: in		std_logic;
		append0_enable				: in		std_logic;
		append1_enable				: in		std_logic;
		append2_enable				: in		std_logic;
		append3_enable				: in		std_logic;
		sr0_set						: in		std_logic;
		sr0_clear_n					: in		std_logic;
		sr1_set						: in		std_logic;
		sr1_clear_n					: in		std_logic;
		sr2_set						: in		std_logic;
		sr2_clear_n					: in		std_logic;
		sr3_set						: in		std_logic;
		sr3_clear_n					: in		std_logic;
		mem_enable					: in		std_logic
	);
	end component;
	
	-- control unit ---------------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_controlUnit is
	port
	(
		-- clock and reset
		clk						: in 	std_logic;
		rst_n						: in	std_logic;
		-- status signals
		op_req					: in	std_logic;
		sr3_out					: in	std_logic;
		sr2_out					: in	std_logic;
		sr1_out					: in	std_logic;
		sr0_out					: in	std_logic;
		mem_validout			: in	std_logic;
		mem_busy					: in	std_logic;
		-- control signals
		readdatavalid			: out	std_logic;
		waitrequest				: out	std_logic;
		readdata_enable		: out	std_logic;
		command_enable			: out	std_logic;
		muxcom_sel				: out	std_logic;
		mux0_sel					: out	std_logic;
		mux1_sel					: out	std_logic;
		mux2_sel					: out	std_logic;
		append0_enable			: out	std_logic;
		append1_enable			: out	std_logic;
		append2_enable			: out	std_logic;
		append3_enable			: out	std_logic;
		sr0_set					: out	std_logic;
		sr0_clear_n				: out	std_logic;
		sr1_set					: out	std_logic;
		sr1_clear_n				: out	std_logic;
		sr2_set					: out	std_logic;
		sr2_clear_n				: out	std_logic;
		sr3_set					: out	std_logic;
		sr3_clear_n				: out	std_logic;
		mem_enable				: out	std_logic
	);
	end component;
	
	-- signals ---------------------------------------------------------------------------------------------------------------------
		signal op_req				: std_logic;
		signal sr3_out				: std_logic;
		signal sr2_out				: std_logic;
		signal sr1_out				: std_logic;
		signal sr0_out				: std_logic;
		signal mem_validout		: std_logic;
		signal mem_busy			: std_logic;
		signal readdatavalid		: std_logic;
		signal waitrequest		: std_logic;
		signal readdata_enable	: std_logic;
		signal command_enable	: std_logic;
		signal muxcom_sel			: std_logic;
		signal mux0_sel			: std_logic;
		signal mux1_sel			: std_logic;
		signal mux2_sel			: std_logic;
		signal append0_enable	: std_logic;
		signal append1_enable	: std_logic;
		signal append2_enable	: std_logic;
		signal append3_enable	: std_logic;
		signal sr0_set				: std_logic;
		signal sr0_clear_n		: std_logic;
		signal sr1_set				: std_logic;
		signal sr1_clear_n		: std_logic;
		signal sr2_set				: std_logic;
		signal sr2_clear_n		: std_logic;
		signal sr3_set				: std_logic;
		signal sr3_clear_n		: std_logic;
		signal mem_enable			: std_logic;
	
	begin
	
		EU: AvalonMM_to_SSRAM_executionUnit port map
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
			clk,
			rst_n,
			op_req,
			sr3_out,
			sr2_out,
			sr1_out,
			sr0_out,
			mem_validout,
			mem_busy,
			readdatavalid,
			waitrequest,
			readdata_enable,
			command_enable,
			muxcom_sel,
			mux0_sel,
			mux1_sel,
			mux2_sel,
			append0_enable,
			append1_enable,
			append2_enable,
			append3_enable,
			sr0_set,
			sr0_clear_n,
			sr1_set,
			sr1_clear_n,
			sr2_set,
			sr2_clear_n,
			sr3_set,
			sr3_clear_n,
			mem_enable
		);
		
		CU: AvalonMM_to_SSRAM_controlUnit port map
		(
			clk,
			rst_n,
			op_req,
			sr3_out,
			sr2_out,
			sr1_out,
			sr0_out,
			mem_validout,
			mem_busy,
			readdatavalid,
			waitrequest,
			readdata_enable,
			command_enable,
			muxcom_sel,
			mux0_sel,
			mux1_sel,
			mux2_sel,
			append0_enable,
			append1_enable,
			append2_enable,
			append3_enable,
			sr0_set,
			sr0_clear_n,
			sr1_set,
			sr1_clear_n,
			sr2_set,
			sr2_clear_n,
			sr3_set,
			sr3_clear_n,
			mem_enable
		);

end architecture rtl;

-------------------------------------------------------------------------------------------------------------------------------------
