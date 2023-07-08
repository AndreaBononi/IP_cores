-- sr_flipflop.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- set reset flip flop

-------------------------------------------------------------------------------------------------------

entity sr_flipflop is
	port
	(
		clk				: in std_logic;
		set				: in std_logic;
		clear_n		: in std_logic;
		rst_n			: in std_logic;
		sr_out		: out std_logic
	);
end sr_flipflop;

-------------------------------------------------------------------------------------------------------

architecture behavior of sr_flipflop is

	begin

		sr: process (clk, clear_n, set)
		begin
			if (rst_n = '0') then
				sr_out <= '0';
			else
				if (rising_edge(clk)) then
					if (clear_n = '0') then
						sr_out <= '0';
					elsif (set = '1') then
						sr_out <= '1';
	            end if;
				end if;
			end if;
		end process sr;

end behavior;

-------------------------------------------------------------------------------------------------------
