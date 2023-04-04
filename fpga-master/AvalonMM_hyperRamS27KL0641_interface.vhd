-- AvalonMM_hyperRamS27KL0641_interface.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AvalonMM_hyperRamS27KL0641_interface is
	port 
	(
		-- IP - avalon
		avs_s0_address     : in    std_logic_vector(31 downto 0) := (others => '0'); 
		avs_s0_read        : in    std_logic                     := '0';             
		avs_s0_readdata    : out   std_logic_vector(15 downto 0)	;                    
		avs_s0_write       : in    std_logic                     := '0';             
		avs_s0_writedata   : in    std_logic_vector(15 downto 0) := (others => '0'); 
		avs_s0_waitrequest : out   std_logic							;
		-- clock and reset
		clock_clk          : in    std_logic                     := '0';             
		reset_reset        : in    std_logic                     := '0';
		-- IP - hyperbus
		hbus_d             : inout std_logic_vector(7 downto 0)  := (others => '0'); 
		hbus_rwds          : inout std_logic                     := '0';             
		hbus_cs            : out   std_logic							;                                        
		hbus_rst           : in    std_logic                     := '0';             
		hbus_ck            : out   std_logic                                         
	);
end entity AvalonMM_hyperRamS27KL0641_interface;

architecture rtl of AvalonMM_hyperRamS27KL0641_interface is
begin

	-- TODO: Auto-generated HDL template

	avs_s0_readdata <= "0000000000000000";

	avs_s0_waitrequest <= '0';

	hbus_cs <= '0';

	hbus_ck <= '0';

end architecture rtl; -- of AvalonMM_hyperRamS27KL0641_interface
