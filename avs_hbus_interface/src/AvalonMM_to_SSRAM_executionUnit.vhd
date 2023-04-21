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
		avs_s0_waitrequest  		: out   	std_logic;
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
end AvalonMM_to_SSRAM_executionUnit;

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
	signal append2_in		: std_logic_vector(49 downto 0);
	signal append1_in		: std_logic_vector(49 downto 0);
	signal append0_in		: std_logic_vector(49 downto 0);
	signal append3_out	: std_logic_vector(49 downto 0);
	signal append2_out	: std_logic_vector(49 downto 0);
	signal append1_out	: std_logic_vector(49 downto 0);
	signal append0_out	: std_logic_vector(49 downto 0);
	signal muxcom_out		: std_logic_vector(49 downto 0);

	begin

		cmd_in(31 downto 0) <= avs_s0_address;
		cmd_in(47 downto 32) <= avs_s0_writedata;
		cmd_in(48) <= avs_s0_read;
		cmd_in(49) <= avs_s0_write;
		
		-- command register ----------------------------------------------------------------------------------------------------------
		command: reg generic map (50) port map (clk, command_enable, '1', cmd_in, cmd_out);
		
		-- append3 register -----------------------------------------------------------------------------------------------------------
		append3: reg generic map (50) port map (clk, append3_enable, '1', cmd_out, append3_out);
		
		-- append2 register -----------------------------------------------------------------------------------------------------------
		append2: reg generic map (50) port map (clk, append2_enable, '1', append2_in, append2_out);
		
		-- append1 register -----------------------------------------------------------------------------------------------------------
		append1: reg generic map (50) port map (clk, append1_enable, '1', append1_in, append1_out);
		
		-- append0 register -----------------------------------------------------------------------------------------------------------
		append0: reg generic map (50) port map (clk, append0_enable, '1', append0_in, append0_out);
		
		-- mux2 -----------------------------------------------------------------------------------------------------------------------
		mux2: mux_2to1 generic map (50) port map (cmd_out, append3_out, mux2_sel, append2_in);
		
		-- mux1 -----------------------------------------------------------------------------------------------------------------------
		mux1: mux_2to1 generic map (50) port map (cmd_out, append2_out, mux1_sel, append1_in);
		
		-- mux0 -----------------------------------------------------------------------------------------------------------------------
		mux0: mux_2to1 generic map (50) port map (cmd_out, append1_out, mux0_sel, append0_in);
		
		-- muxcom ---------------------------------------------------------------------------------------------------------------------
		muxcom: mux_2to1 generic map (50) port map (append0_out, cmd_out, muxcom_sel, muxcom_out);
		
		ssram_address <= muxcom_out(31 downto 0);
		ssram_in <= muxcom_out(47 downto 32);
		ssram_OE <= muxcom_out(48);
		ssram_WE <= muxcom_out(49);
		
		-- sr3 (set-reset flip-flop related to append3 status) ------------------------------------------------------------------------
		sr3: sr_flipflop port map (clk, sr3_set, sr3_clear_n, sr3_out);
		
		-- sr2 (set-reset flip-flop related to append2 status) ------------------------------------------------------------------------
		sr2: sr_flipflop port map (clk, sr2_set, sr2_clear_n, sr2_out);
		
		-- sr1 (set-reset flip-flop related to append1 status) ------------------------------------------------------------------------
		sr1: sr_flipflop port map (clk, sr1_set, sr1_clear_n, sr1_out);
		
		-- sr0 (set-reset flip-flop related to append0 status) ------------------------------------------------------------------------
		sr0: sr_flipflop port map (clk, sr0_set, sr0_clear_n, sr0_out);
		
		-- readdata register ----------------------------------------------------------------------------------------------------------
		readdata: reg generic map (16) port map (clk, readdata_enable, '1', ssram_out, avs_s0_readdata);
		
		avs_s0_readdatavalid <= readdatavalid;
		avs_s0_waitrequest <= waitrequest;
		op_req <= avs_s0_read and avs_s0_write;
		ssram_CS <= mem_enable;
		mem_validout <= ssram_validout;
		mem_busy <= ssram_busy;

end architecture rtl;

-------------------------------------------------------------------------------------------------------------------------------------
