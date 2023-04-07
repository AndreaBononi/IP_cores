-- AvalonMM_hyperRamS27KL0641_interface.vhd -----------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Component able to interface an Avalon Memory-Mapped bus with a hyperRAM model S27KL0641

-------------------------------------------------------------------------------------------------------------------------------------

entity AvalonMM_hyperRamS27KL0641_interface is
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
end entity AvalonMM_hyperRamS27KL0641_interface;

-------------------------------------------------------------------------------------------------------------------------------------

architecture rtl of AvalonMM_hyperRamS27KL0641_interface is
	
	-- register ----------------------------------------------------------------------------------------------------------------------
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
	
	-- multiplexer 2-to-1 ------------------------------------------------------------------------------------------------------------
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
	
	-- dummy memory ------------------------------------------------------------------------------------------------------------------
	component ssram8 is
		generic
		(
			N 					: integer 	:= 32;
			valid_time		: time 		:= 5 ns;
		);
		port
		(
			ssram8_clk			: in 	std_logic;
			ssram8_clear_n		: in 	std_logic;
			ssram8_read			: in 	std_logic;
			ssram8_write		: in 	std_logic;
			ssram8_address		: in 	std_logic_vector(7 downto 0);
			ssram8_in			: in 	std_logic_vector(N-1 downto 0);
			ssram8_out			: out std_logic_vector(N-1 downto 0);
			ssram8_valid		: out std_logic
		);
	end component;
	
	-- existing states -------------------------------------------------------------------------------------------------------------
	type state is 
	(
		reset,
		idle,
		reading,
		wait_reading,
		store_reading,
		writing,
		wait_writing
	);
	signal present_state		: state;
	signal next_state			: state;
	
	-- control signals --------------------------------------------------------------------------------------------------------------
	signal data_sel				: std_logic;
	signal ssram8_write			: std_logic;
	signal ssram8_read			: std_logic;
	signal ssram8_clear_n		: std_logic;
	signal data_enable			: std_logic; 
	signal data_clear_n			: std_logic;
	signal address_enable		: std_logic; 
	signal address_clear_n		: std_logic;
	signal avs_s0_waitrequest	: std_logic;
		
	-- status signals ---------------------------------------------------------------------------------------------------------------
	signal ssram8_valid 	: std_logic;
		
	-- local signals ----------------------------------------------------------------------------------------------------------------
	signal muxout			: std_logic_vector(15 downto 0);
	signal ssram8_out		: std_logic_vector(15 downto 0);
	
	begin

		-- control unit: evaluation of the next state --------------------------------------------------------------------------------
		next_state_evaluation: process (reset_reset, present_state, ssram8_valid, avs_s0_write, avs_s0_read)
		begin
			if (reset_reset = '0') then
				next_state <= reset;
			else
				case present_state is
					when reset => 
						next_state <= idle;
					when idle => 
						if (avs_s0_read = '1') then
							next_state <= reading;
						else
							if (avs_s0_write = '1') then
								next_state <= writing;
							else
								next_state <= idle;
							end if;
						end if;
					when reading => 
						if (avs_s0_valid = '1') then
							next_state <= store_reading;
						else
							next_state <= wait_reading;
						end if;
					when wait_reading => 
						if (avs_s0_valid = '1') then
							next_state <= store_reading;
						else
							next_state <= wait_reading;
						end if;
					when store_reading => 
						next_state <= idle;
					when writing => 
						if (avs_s0_valid = '1') then
							next_state <= idle;
						else
							next_state <= wait_writing;
						end if;
					when wait_writing => 
						if (avs_s0_valid = '1') then
							next_state <= idle;
						else
							next_state <= wait_writing;
						end if;
				end case;
			end if;
		end process next_state_evaluation;
		
		-- control unit: state transition --------------------------------------------------------------------------------------------
		state_transition: process (clock_clk, reset_reset)
		begin
			if (reset_reset = '0') then
				present_state <= reset;
			elsif (rising_edge(clock_clk)) then 
				present_state <= next_state;
			end if;
		end process state_transition;
		
		-- control unit: control signals definition ---------------------------------------------------------------------------------- 
		control_signals_definition: process (present_state)
		begin
			-- default values ---------------------------------------------------------------------------------------------------------
			data_sel					<= '0';
			ssram8_write			<= '0';
			ssram8_read				<= '0';
			ssram8_clear_n			<= '1';
			data_enable				<= '0';
			data_clear_n			<= '1';
			address_enable			<= '0';
			address_clear_n		<= '1';
			avs_s0_waitrequest	<= '0';
			---------------------------------------------------------------------------------------------------------------------------
			case present_state is:
				when reset =>
					address_clear_n <= '0';
					ssram8_clear_n	<= '0';
					data_clear_n <= '0';
				when idle =>
					address_enable <= '1';
					data_enable <= '1';
				when reading =>
					avs_s0_waitrequest <= '1';
					ssram8_read <= '1';
				when wait_reading =>
					avs_s0_waitrequest <= '1';
				when store_reading =>
					avs_s0_waitrequest <= '1';
					data_enable <= '1';
					data_sel <= '1';
				when writing =>
					avs_s0_waitrequest <= '1';
					ssram8_write <= '1';
				when wait_writing =>
					avs_s0_waitrequest <= '1';
			end case;
		end process control_signals_definition;
		
		-- execution unit: address register ----------------------------------------------------------------------------------------------
		address_register: reg 
		generic map
		(
			32
		)
		port map
		(
			clock_clk 			=> clk,
			address_enable		=> enable,
			address_clear_n	=> clear_n,
			avs_s0_address		=> reg_in,
			ssram8_address		=> reg_out
		);
		
		-- execution unit: data register -------------------------------------------------------------------------------------------------
		data_register: reg 
		generic map
		(
			16
		)
		port map
		(
			clock_clk 			=> clk,
			data_enable			=> enable,
			data_clear_n		=> clear_n,
			muxout				=> reg_in,
			avs_s0_readdata	=> reg_out
		);
		
		-- execution unit: data multiplexing ---------------------------------------------------------------------------------------------
		data_mux: mux_2to1
		generic map
		(
			16
		)
		port map
		(	
			avs_s0_writedata	=> mux_in_0,
			ssram8_out 			=> mux_in_1,
			data_sel				=> sel,
			muxout				=> out_mux
		);
		
		-- dummy memory ------------------------------------------------------------------------------------------------------------------
		memory: ssram8
		generic map
		(
			16			=> N,
			35 ns		=> valid_time
		);
		port
		(
			clock_clk			=> ssram8_clk,
			ssram8_clear_n		=> ssram8_clear_n,
			ssram8_read			=> ssram8_read,
			ssram8_write		=> ssram8_write,
			ssram8_address		=> ssram8_address,
			avs_s0_readdata	=> ssram8_in,
			ssram8_out 			=> ssram8_out,
			ssram8_out			=> ssram8_valid
		);		
	
		-- at the moment the interface with the hyperbus is not used
		hbus_cs <= '0';
		hbus_ck <= clock_clk;
		hbus_rst <= reset_reset;

end architecture rtl; -- of AvalonMM_hyperRamS27KL0641_interface

-------------------------------------------------------------------------------------------------------------------------------------