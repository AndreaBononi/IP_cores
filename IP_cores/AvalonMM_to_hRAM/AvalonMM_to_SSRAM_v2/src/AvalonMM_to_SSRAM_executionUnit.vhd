-- AvalonMM_to_SSRAM_executionUnit.vhd ---------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_executionUnit is
	generic
	(
		burst_lenght									: std_logic_vector(1 downto 0) := "11";
		hybrid_burst_enable						: std_logic := '1';
		initial_latency								: std_logic_vector(3 downto 0) := "0001";
		drive_strength								: std_logic_vector(2 downto 0) := "000";
		distributed_refresh_interval	: std_logic_vector(1 downto 0) := "10"
	);
	port
	(
		-- clock and reset
		clk		          				: in    std_logic;
		rst_n			        			: in    std_logic;
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
		ssram_address_space			: out		std_logic;
		ssram_busy							: in		std_logic;
		ssram_clear_n						: out		std_logic;
		-- status signals:
		mem_validout						: out		std_logic;
		mem_busy								: out		std_logic;
		mem_avail								: out		std_logic;
		fifo4_full							: out		std_logic;
		fifo4_almost_full				: out		std_logic;
		fifo4_empty							: out		std_logic;
		dpd_mode								: out 	std_logic;
		op_req									: out		std_logic;
		previous_op_req					: out		std_logic;
		write_op								: out 	std_logic;
		config_reg_access				: out 	std_logic;
		-- control signals:
		waitrequest							: in		std_logic;
		readdatavalid						: in		std_logic;
		readdata_enable					: in		std_logic;
		command_enable					: in		std_logic;
		virtual_config_enable		: in		std_logic;
		virtual_config_clear_n	: in		std_logic;
		out_sel									: in		std_logic;
		config_sel							: in		std_logic;
		mem_input_sel						: in		std_logic;
		address_space_sel				: in		std_logic;
		por_enable							: in		std_logic;
		por_clear_n							: in		std_logic;
		tgl_clear_n							: in		std_logic;
		mem_enable							: in		std_logic;
		force_write							: in		std_logic;
		fifo4_push							: in		std_logic;
		fifo4_pop								: in		std_logic;
		fifo4_clear_n						: in		std_logic
	);
end AvalonMM_to_SSRAM_executionUnit;

-----------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_to_SSRAM_executionUnit is

	constant config0_addr: std_logic_vector(31 downto 0) := "00000000000000000000100000000000";
	constant config1_addr: std_logic_vector(31 downto 0) := "00000000000000000000100000000001";

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

	-- multiplexer 2 inputs --------------------------------------------------------------------------------------------------------
	component mux_2to1 is
		generic
		(
			N : integer := 1
		);
		port
		(
			mux_in_0		: in		std_logic_vector((N-1) downto 0);
			mux_in_1		: in		std_logic_vector((N-1) downto 0);
			sel					: in 		std_logic;
			out_mux			: out 	std_logic_vector((N-1) downto 0)
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
	signal cmd_in									: std_logic_vector(49 downto 0);
	signal cmd_out								: std_logic_vector(49 downto 0);
	signal virtual_config_in			: std_logic_vector(15 downto 0);
	signal virtual_config_out			: std_logic_vector(15 downto 0);
	signal config_mux_in0					: std_logic_vector(15 downto 0);
	signal config_mux_in1					: std_logic_vector(15 downto 0);
	signal config_mux_out					: std_logic_vector(15 downto 0);
	signal config_addr_mux_out		: std_logic_vector(31 downto 0);
	signal address_space_mux_out	: std_logic_vector(31 downto 0);
	signal out_mux_in0						: std_logic_vector(15 downto 0);
	signal fifo4_out							: std_logic_vector(49 downto 0);
	signal fifo4_empty_local			: std_logic;
	signal tgl_in									: std_logic;
	signal por_out								: std_logic;
	signal op											: std_logic;

	begin

		cmd_in(49) 						<= avs_s0_write;
		cmd_in(48) 						<= avs_s0_read;
		cmd_in(47 downto 32) 	<= avs_s0_writedata;
		cmd_in(31 downto 0) 	<= avs_s0_address;

		COMMAND: reg generic map (50) port map (clk, command_enable, '1', cmd_in, cmd_out);

		write_op <= cmd_out(49);

		op <= avs_s0_read or avs_s0_write;
		op_req <= op;
		previous_op_req <= por_out;

		POR: d_flipflop port map (clk, por_enable, por_clear_n, op, por_out);

		config_reg_access <=
			avs_s0_address(22) and (not avs_s0_address(21)) and (not avs_s0_address(20)) and (not avs_s0_address(19))
			and (not avs_s0_address(18)) and (not avs_s0_address(17)) and (not avs_s0_address(16)) and (not avs_s0_address(15))
			and (not avs_s0_address(14)) and (not avs_s0_address(13)) and (not avs_s0_address(12)) and (not avs_s0_address(11))
			and (not avs_s0_address(10)) and (not avs_s0_address(9)) and (not avs_s0_address(8)) and (not avs_s0_address(7))
			and (not avs_s0_address(6)) and (not avs_s0_address(5)) and (not avs_s0_address(4)) and (not avs_s0_address(3))
			and (not avs_s0_address(2)) and (not avs_s0_address(1)) and (not avs_s0_address(0))
		;

		virtual_config_in(15 downto 2) 	<= "00000000000000";
		virtual_config_in(1 downto 0) 	<= cmd_out(33 downto 32);

		VIRTUAL_CONFIG: reg generic map (16) port map (clk, virtual_config_enable, virtual_config_clear_n, virtual_config_in, virtual_config_out);

		config_mux_in0(15)						<= not(virtual_config_out(0));
		config_mux_in0(14 downto 12)	<= drive_strength;
		config_mux_in0(11 downto 8)		<= "1111";
		config_mux_in0(7 downto 4) 		<= initial_latency;
		config_mux_in0(3)							<= not(virtual_config_out(1));
		config_mux_in0(2) 						<= hybrid_burst_enable;
		config_mux_in0(1 downto 0) 		<= burst_lenght;

		config_mux_in1(1 downto 0)		<= distributed_refresh_interval;
		config_mux_in1(15 downto 2)		<= "00000000000000";

		CONFIG_MUX: mux_2to1 generic map (16) port map (config_mux_in0, config_mux_in1, config_sel, config_mux_out);

		OUT_MUX: mux_2to1 generic map (16) port map (out_mux_in0, virtual_config_out, out_sel, avs_s0_readdata);

		READDATA: reg generic map (16) port map (clk, readdata_enable, '1', ssram_out, out_mux_in0);

		LOCAL_FIFO: fifo4 generic map (50)
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
		ssram_OE <= fifo4_out(48) and mem_enable;
		ssram_WE <= (fifo4_out(49) and mem_enable) or force_write;
		ssram_clear_n <= rst_n;
		mem_busy <= ssram_busy;

		CONFIG_ADDR_MUX: mux_2to1 generic map (32) port map (config0_addr, config1_addr, config_sel, config_addr_mux_out);

		ADDRESS_SPACE_MUX: mux_2to1 generic map (32) port map (fifo4_out(31 downto 0), config_addr_mux_out, address_space_sel, ssram_address);

		MEM_INPUT_MUX: mux_2to1 generic map (16) port map (fifo4_out(47 downto 32), config_mux_out, mem_input_sel, ssram_in);

		TGL: t_flip_flop port map (clk, '1', tgl_clear_n, tgl_in, mem_avail);

		avs_s0_readdatavalid <= readdatavalid;
		avs_s0_waitrequest <= waitrequest;
		mem_validout <= ssram_validout;
		ssram_address_space <= address_space_sel;
		dpd_mode <= virtual_config_out(0);

end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------------------
