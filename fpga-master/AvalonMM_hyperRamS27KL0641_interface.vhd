-- AvalonMM_hyperRamS27KL0641_interface.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AvalonMM_hyperRamS27KL0641_interface is
	port (
		avs_s0_address       : in    std_logic_vector(31 downto 0) := (others => '0'); -- avs_s0.address
		avs_s0_read          : in    std_logic                     := '0';             --       .read
		avs_s0_readdata      : out   std_logic_vector(15 downto 0);                    --       .readdata
		avs_s0_write         : in    std_logic                     := '0';             --       .write
		avs_s0_writedata     : in    std_logic_vector(15 downto 0) := (others => '0'); --       .writedata
		avs_s0_waitrequest   : out   std_logic;                                        --       .waitrequest
		avs_s0_readdatavalid : out   std_logic;                                        --       .readdatavalid
		clock_clk            : in    std_logic                     := '0';             --  clock.clk
		reset_reset          : in    std_logic                     := '0';             --  reset.reset
		hbus_d               : inout std_logic_vector(7 downto 0)  := (others => '0'); --   hbus.command_address_data
		hbus_rwds            : inout std_logic                     := '0';             --       .read_write_data_strobe
		hbus_cs              : out   std_logic;                                        --       .chip_select
		hbus_rst             : out   std_logic;                                        --       .reset
		hbus_ck              : out   std_logic                                         --       .clock
	);
end entity AvalonMM_hyperRamS27KL0641_interface;

architecture rtl of AvalonMM_hyperRamS27KL0641_interface is
begin

	-- TODO: Auto-generated HDL template

	avs_s0_readdata <= "0000000000000000";

	avs_s0_waitrequest <= '0';

	avs_s0_readdatavalid <= '0';

	hbus_cs <= '0';

	hbus_rst <= '0';

	hbus_ck <= '0';

end architecture rtl; -- of AvalonMM_hyperRamS27KL0641_interface
