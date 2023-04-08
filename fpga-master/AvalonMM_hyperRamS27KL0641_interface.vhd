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

	-- control unit ------------------------------------------------------------------------------------------------------------------
	component AvalonMM_hyperRamS27KL0641_interface_controlUnit is
		port 
		(
			-- clock and reset -----------------------------------------------------------------------------------------------------------
			clk						: in std_logic;
			rst_n						: in std_logic;
			-- status signals ---------------------------------------------------------------------------------------------------------------
			ssram8_valid 			: in std_logic;
			avs_s0_write			: in std_logic;
			avs_s0_read				: in std_logic;
			-- control signals -----------------------------------------------------------------------------------------------------------
			ssram8_write			: out std_logic;
			ssram8_read				: out std_logic;
			ssram8_clear_n			: out std_logic;
			data_sel					: out std_logic;
			data_enable				: out std_logic; 
			data_clear_n			: out std_logic;
			address_enable			: out std_logic; 
			address_clear_n		: out std_logic;
			avs_s0_waitrequest	: out std_logic
		);
	end component;

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
			valid_time		: time 		:= 5 ns
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
	
	-- control signals --------------------------------------------------------------------------------------------------------------
	signal data_sel				: std_logic;
	signal ssram8_write			: std_logic;
	signal ssram8_read			: std_logic;
	signal ssram8_clear_n		: std_logic;
	signal data_enable			: std_logic; 
	signal data_clear_n			: std_logic;
	signal address_enable		: std_logic; 
	signal address_clear_n		: std_logic;
		
	-- status signals ---------------------------------------------------------------------------------------------------------------
	signal ssram8_valid 	: std_logic;
		
	-- local signals ----------------------------------------------------------------------------------------------------------------
	signal muxout				: std_logic_vector(15 downto 0);
	signal ssram8_out			: std_logic_vector(15 downto 0);
	signal ssram8_address	: std_logic_vector(31 downto 0);
	signal data_out			: std_logic_vector(15 downto 0);
	
	begin
	
		-- control unit instance -----------------------------------------------------------------------------------------------------
		cu: AvalonMM_hyperRamS27KL0641_interface_controlUnit
		port map
		(
			clock_clk,
			reset_reset,
			ssram8_valid,
			avs_s0_write,
			avs_s0_read,
			ssram8_write,
			ssram8_read,
			ssram8_clear_n,
			data_sel,
			data_enable,
			data_clear_n,
			address_enable,
			address_clear_n,
			avs_s0_waitrequest
		);
		
		-- execution unit: address register ----------------------------------------------------------------------------------------------
		address_register: reg 
		generic map
		(
			32
		)
		port map
		(
			clock_clk,			-- clk
			address_enable,	-- enable
			address_clear_n,	-- clear_n
			avs_s0_address,	-- reg_in
			ssram8_address		-- reg_out
		);
		
		-- execution unit: data register -------------------------------------------------------------------------------------------------
		data_register: reg 
		generic map
		(
			16
		)
		port map
		(
			clock_clk, 			-- clk
			data_enable,		-- enable
			data_clear_n,		-- clear_n
			muxout,				-- reg_in
			data_out				-- reg_out
		);
		
		-- execution unit: data multiplexing ---------------------------------------------------------------------------------------------
		data_mux: mux_2to1
		generic map
		(
			16
		)
		port map
		(	
			avs_s0_writedata,	-- mux_in_0,
			ssram8_out,			-- mux_in_1,
			data_sel,			-- sel,
			muxout				-- out_mux
		);
		
		-- dummy memory instance ---------------------------------------------------------------------------------------------------------
		memory: ssram8
		generic map
		(
			16,
			35 ns
		)
		port map
		(
			clock_clk,			-- ssram8_clk,
			ssram8_clear_n,	-- ssram8_clear_n,
			ssram8_read,		-- ssram8_read,
			ssram8_write,		-- ssram8_write,
			ssram8_address,	-- ssram8_address,
			data_out,			-- ssram8_in,
			ssram8_out,			-- ssram8_out,
			ssram8_valid		-- ssram8_valid
		);		
	
		avs_s0_readdata <= data_out;
	
		-- at the moment the interface with the hyperbus is not used
		hbus_cs <= '0';
		hbus_ck <= clock_clk;
		hbus_rst <= reset_reset;

end architecture rtl; -- of AvalonMM_hyperRamS27KL0641_interface

-------------------------------------------------------------------------------------------------------------------------------------