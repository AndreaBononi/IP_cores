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
	
	-- register --------------------------------------------------------
	component reg is
		generic
		(
			N : integer := 8
		);
		port
		(
			clk		: in 	std_logic;
			enable	: in 	std_logic;
			clearn	: in 	std_logic;
			reg_in	: in 	std_logic_vector(N-1 downto 0);
			reg_out	: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	-- multiplexer 2-to-1 ----------------------------------------------
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
	
	-- dummy memory -----------------------------------------------------
	component ssram8 is
		generic
		(
			N : integer := 32
		);
		port
		(
			ssram8_clk			: in 	std_logic;
			ssram8_clear_n		: in 	std_logic;
			ssram8_read			: in 	std_logic;
			ssram8_write		: in 	std_logic;
			ssram8_address		: in 	std_logic_vector(7 downto 0);
			ssram8_in			: in 	std_logic_vector(N-1 downto 0);
			ssram8_out			: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	-- rtl description ----------------------------------------------------------------------
	begin

		-- CREARE MACCHINA A STATI E DATAPATH
	
	
	
		-- at the moment the interface with the hyperbus is not used
		hbus_cs <= '0';
		hbus_ck <= clock_clk;
		hbus_rst <= reset_reset;

end architecture rtl; -- of AvalonMM_hyperRamS27KL0641_interface

-------------------------------------------------------------------------------------------------------------------------------------