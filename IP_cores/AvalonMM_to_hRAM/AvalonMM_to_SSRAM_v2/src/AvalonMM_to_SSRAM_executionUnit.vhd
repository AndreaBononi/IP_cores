-- AvalonMM_to_SSRAM_executionUnit.vhd ---------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_executionUnit is
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
		mem_avail								: out		std_logic;
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
end AvalonMM_to_SSRAM_executionUnit;

-----------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_SSRAM_executionUnit is

	-- register --------------------------------------------------------------------------------------------------------------------
	component reg is
		generic
		(
			N : integer := 8
		);
		port
		(
			clk				: in 	std_logic;
			enable		: in 	std_logic;
			clear_n		: in 	std_logic;
			reg_in		: in 	std_logic_vector(N-1 downto 0);
			reg_out		: out std_logic_vector(N-1 downto 0)
		);
	end component;

	-- flip flop type D ------------------------------------------------------------------------------------------------------------
	component d_flipflop is
		port
		(
			clk				: in std_logic;
			enable		: in std_logic;
			clear_n		: in std_logic;
			dff_in		: in std_logic;
			dff_out		: out std_logic
		);
	end component;

	-- flip flop type T ------------------------------------------------------------------------------------------------------------
	component t_flip_flop is
		port
		(
			clk				: in 	std_logic;
			enable		: in 	std_logic;
			clear_n		: in 	std_logic;
			tff_in		: in 	std_logic;
			tff_out		: out std_logic
		);
	end component;

	-- fifo4 -----------------------------------------------------------------------------------------------------------------------
	component fifo4 is
		generic
		(
			N: integer := 16
		);
		port
		(
			fifo4_clk						: in 	std_logic;
			fifo4_clear_n				: in 	std_logic;
			fifo4_push					: in 	std_logic;
			fifo4_pop						: in 	std_logic;
			fifo4_full					: out	std_logic;
			fifo4_almost_full		: out	std_logic;
			fifo4_empty					: out std_logic;
			fifo4_in						: in 	std_logic_vector(N-1 downto 0);
			fifo4_out						: out std_logic_vector(N-1 downto 0)
		);
	end component;

	-- internal signals ------------------------------------------------------------------------------------------------------------
	signal cmd_in							: std_logic_vector(49 downto 0);
	signal cmd_out						: std_logic_vector(49 downto 0);
	signal fifo4_out					: std_logic_vector(49 downto 0);
	signal fifo4_empty_local	: std_logic;
	signal tgl_in							: std_logic;
	signal por_out						: std_logic;
	signal op									: std_logic;

	begin

		cmd_in(31 downto 0) <= avs_s0_address;
		cmd_in(47 downto 32) <= avs_s0_writedata;
		cmd_in(48) <= avs_s0_read;
		cmd_in(49) <= avs_s0_write;

		-- command register ----------------------------------------------------------------------------------------------------------
		command: reg generic map (50) port map (clk, command_enable, '1', cmd_in, cmd_out);

		-- fifo4 ---------------------------------------------------------------------------------------------------------------------
		local_fifo: fifo4 generic map (50)
		port map
		(
			clk, 								-- fifo4_clk
			fifo4_clear_n, 			-- fifo4_clear_n
			fifo4_push, 				-- fifo4_push
			fifo4_pop,					-- fifo4_pop
			fifo4_full, 				-- fifo4_full
			fifo4_almost_full, 	-- fifo4_almost_full
			fifo4_empty_local,	-- fifo4_empty
			cmd_out, 						-- fifo4_in
			fifo4_out						-- fifo4_out
		);

		fifo4_empty <= fifo4_empty_local;
		tgl_in <= ssram_busy nor fifo4_empty_local;
		ssram_address <= fifo4_out(31 downto 0);
		ssram_in <= fifo4_out(47 downto 32);
		ssram_OE <= fifo4_out(48) and mem_enable;
		ssram_WE <= fifo4_out(49) and mem_enable;
		ssram_clear_n <= rst_n;
		mem_busy <= ssram_busy;

		-- TGL flip flop -------------------------------------------------------------------------------------------------------------
		tgl: t_flip_flop port map (clk, '1', tgl_clear_n, tgl_in, mem_avail);

		avs_s0_readdatavalid <= readdatavalid;
		avs_s0_waitrequest <= waitrequest;
		mem_validout <= ssram_validout;

		op <= avs_s0_read or avs_s0_write;
		op_req <= op;
		previous_op_req <= por_out;

		-- POR flip flop -------------------------------------------------------------------------------------------------------------
		por: d_flipflop port map (clk, por_enable, por_clear_n, op, por_out);

		-- readdata register ----------------------------------------------------------------------------------------------------------
		readdata: reg generic map (16) port map (clk, readdata_enable, '1', ssram_out, avs_s0_readdata);

end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------------------
