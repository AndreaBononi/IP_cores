-- AvalonMM_to_SSRAM_executionUnit.vhd --------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-----------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_executionUnit is
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
end entity AvalonMM_to_SSRAM_executionUnit;

----------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_SSRAM_executionUnit is

	-- register -------------------------------------------------------------------------------------------------------------------
	component reg is
		generic
		(
			N : integer := 8
		);
		port
		(
			clk		: in 	std_logic;
			enable	: in 	std_logic;
			clear_n	: in 	std_logic;
			reg_in	: in 	std_logic_vector(N-1 downto 0);
			reg_out	: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	-- set reset flip flop --------------------------------------------------------------------------------------------------------
	component sr_flipflop is
		port 
		(
			clk			: in std_logic;
			set			: in std_logic;
			clear_n		: in std_logic;
			sr_out		: out std_logic
		);
	end component;
	
	-- multiplexer 2-to-1 ---------------------------------------------------------------------------------------------------------
	component mux_2to1 is
		generic
		(
			N : integer := 1
		);
		port
		(
			mux_in_0		: in		std_logic_vector((N-1) downto 0);
			mux_in_1		: in		std_logic_vector((N-1) downto 0);
			sel			: in 		std_logic;
			out_mux		: out 	std_logic_vector((N-1) downto 0)
		);
	end component;

	-- internal signals ------------------------------------------------------------------------------------------------------------
	signal cmd_in			: std_logic_vector(49 downto 0);
	signal cmd_out			: std_logic_vector(49 downto 0);
	signal append3_in		: std_logic_vector(49 downto 0);
	signal append2_in		: std_logic_vector(49 downto 0);
	signal append1_in		: std_logic_vector(49 downto 0);
	signal append0_in		: std_logic_vector(49 downto 0);
	signal append3_out	: std_logic_vector(49 downto 0);
	signal append2_out	: std_logic_vector(49 downto 0);
	signal append1_out	: std_logic_vector(49 downto 0);
	signal append0_out	: std_logic_vector(49 downto 0);

	begin

		cmd_in(31 downto 0) <= avs_s0_address;
		cmd_in(47 downto 32) <= avs_s0_writedata;
		cmd_in(48) <= avs_s0_read;
		cmd_in(49) <= avs_s0_write;
		cmd_out <= append3_in;
		
		-- command register ----------------------------------------------------------------------------------------------------------
		command: reg
		generic map
		(
			50
		)
		port map
		(
			clk,
			command_enable,
			'1',
			cmd_in,
			cmd_out
		);
		
		-- 
		
		avs_s0_readdatavalid <= readdatavalid;
		avs_s0_waitrequest <= waitrequest;
		op_req <= avs_s0_read and avs_s0_write;
		ssram_CS <= mem_enable;
		mem_validout <= ssram_validout;
		mem_busy <= ssram_busy;

end architecture rtl;

-------------------------------------------------------------------------------------------------------------------------------------
