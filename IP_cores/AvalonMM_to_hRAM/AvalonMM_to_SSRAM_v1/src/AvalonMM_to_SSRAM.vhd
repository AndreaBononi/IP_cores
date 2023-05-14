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
		avs_s0_address     			: in    	std_logic_vector(31 downto 0);
		avs_s0_read        			: in    	std_logic;
		avs_s0_write       			: in    	std_logic;
		avs_s0_writedata   			: in    	std_logic_vector(15 downto 0);
		avs_s0_readdata    			: out   	std_logic_vector(15 downto 0);
		avs_s0_readdatavalid		: out   	std_logic;
		avs_s0_waitrequest  		: out   	std_logic;
		-- SSRAM signals
		ssram_out             	: in		std_logic_vector(15 downto 0);
		ssram_in             		: out		std_logic_vector(15 downto 0);
		ssram_address         	: out		std_logic_vector(31 downto 0);
		ssram_OE								: out		std_logic;
		ssram_WE								: out		std_logic;
		ssram_validout					: in		std_logic;
		ssram_busy							: in		std_logic;
		ssram_clear_n						: out		std_logic;
		-- clock and reset
		clk		          				: in    	std_logic;
		rst_n			        			: in    	std_logic
	);
end entity AvalonMM_to_SSRAM;

----------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_SSRAM is

	-- execution unit -------------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_executionUnit is
		port
		(
			-- AvalonMM signals
			avs_s0_address     			: in    std_logic_vector(31 downto 0);
			avs_s0_read        			: in    std_logic;
			avs_s0_write       			: in    std_logic;
			avs_s0_writedata   			: in    std_logic_vector(15 downto 0);
			avs_s0_readdata    			: out   std_logic_vector(15 downto 0);
			avs_s0_readdatavalid		: out   std_logic;
			avs_s0_waitrequest  		: out   std_logic;
			-- SSRAM signals
			ssram_out             	: in		std_logic_vector(15 downto 0);
			ssram_in             		: out		std_logic_vector(15 downto 0);
			ssram_address         	: out		std_logic_vector(31 downto 0);
			ssram_OE								: out		std_logic;
			ssram_WE								: out		std_logic;
			ssram_validout					: in		std_logic;
			ssram_busy							: in		std_logic;
			ssram_clear_n						: out		std_logic;
			-- clock and reset
			clk		          				: in    std_logic;
			rst_n			        			: in    std_logic;
			-- status signals:
			mem_validout						: out		std_logic;
			mem_busy								: out		std_logic;
			mem_avail							: out		std_logic;
			fifo4_full							: out		std_logic;
			fifo4_almost_full				: out		std_logic;
			fifo4_empty							: out		std_logic;
			op_req									: out		std_logic;
			previous_op_req					: out		std_logic;
			-- control signals:
			waitrequest							: in		std_logic;
			readdatavalid						: in		std_logic;
			readdata_enable					: in		std_logic;
			command_enable					: in		std_logic;
			por_enable							: in		std_logic;
			por_clear_n							: in		std_logic;
			tgl_clear_n							: in		std_logic;
			mem_enable							: in		std_logic;
			fifo4_push							: in		std_logic;
			fifo4_pop								: in		std_logic;
			fifo4_clear_n						: in		std_logic
		);
	end component;

	-- control unit ---------------------------------------------------------------------------------------------------------------
	component AvalonMM_to_SSRAM_controlUnit is
		port
		(
			-- clock and reset
			clk											: in 		std_logic;
			rst_n										: in		std_logic;
			-- status signals
			mem_validout						: in		std_logic;
			mem_busy								: in		std_logic;
			mem_avail								: in		std_logic;
			fifo4_full							: in		std_logic;
			fifo4_almost_full				: in		std_logic;
			fifo4_empty							: in		std_logic;
			op_req									: in		std_logic;
			previous_op_req					: in		std_logic;
			-- control signals
			waitrequest							: out		std_logic;
			readdatavalid						: out		std_logic;
			readdata_enable					: out		std_logic;
			command_enable					: out		std_logic;
			por_enable							: out		std_logic;
			por_clear_n							: out		std_logic;
			tgl_clear_n							: out		std_logic;
			mem_enable							: out		std_logic;
			fifo4_push							: out		std_logic;
			fifo4_pop								: out		std_logic;
			fifo4_clear_n						: out		std_logic
		);
	end component;

	-- signals ---------------------------------------------------------------------------------------------------------------------
	signal mem_validout							: std_logic;
	signal mem_busy									: std_logic;
	signal mem_avail								: std_logic;
	signal fifo4_full								: std_logic;
	signal fifo4_almost_full				: std_logic;
	signal fifo4_empty							: std_logic;
	signal op_req										: std_logic;
	signal previous_op_req					: std_logic;
	signal waitrequest							: std_logic;
	signal readdatavalid						: std_logic;
	signal readdata_enable					: std_logic;
	signal command_enable						: std_logic;
	signal por_enable								: std_logic;
	signal por_clear_n							: std_logic;
	signal tgl_clear_n							: std_logic;
	signal mem_enable								: std_logic;
	signal fifo4_push								: std_logic;
	signal fifo4_pop								: std_logic;
	signal fifo4_clear_n						: std_logic;

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
			ssram_validout,
			ssram_busy,
			ssram_clear_n,
			clk,
			rst_n,
			mem_validout,
			mem_busy,
			mem_avail,
			fifo4_full,
			fifo4_almost_full,
			fifo4_empty,
			op_req,
			previous_op_req,
			waitrequest,
			readdatavalid,
			readdata_enable,
			command_enable,
			por_enable,
			por_clear_n,
			tgl_clear_n,
			mem_enable,
			fifo4_push,
			fifo4_pop,
			fifo4_clear_n
		);

		CU: AvalonMM_to_SSRAM_controlUnit port map
		(
			clk,
			rst_n,
			mem_validout,
			mem_busy,
			mem_avail,
			fifo4_full,
			fifo4_almost_full,
			fifo4_empty,
			op_req,
			previous_op_req,
			waitrequest,
			readdatavalid,
			readdata_enable,
			command_enable,
			por_enable,
			por_clear_n,
			tgl_clear_n,
			mem_enable,
			fifo4_push,
			fifo4_pop,
			fifo4_clear_n
		);

end architecture rtl;

-------------------------------------------------------------------------------------------------------------------------------------
