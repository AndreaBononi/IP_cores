-- d_flipflop.vhd -------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- flip flop type D

-------------------------------------------------------------------------------------------------------

entity d_flipflop is
	port
	(
		clk				: in 	std_logic;
		enable		: in 	std_logic;
		clear_n		: in 	std_logic;
		dff_in		: in 	std_logic;
		dff_out		: out std_logic
	);
end d_flipflop;

-------------------------------------------------------------------------------------------------------

architecture behavior of d_flipflop is

	begin

		dff_process: process (clk, clear_n, enable)
		begin
			if (rising_edge(clk)) then
				if (clear_n = '0') then
					dff_out <= '0';
				elsif (enable = '1') then
					dff_out <= dff_in;
            end if;
			end if;
		end process dff_process;

end behavior;

-------------------------------------------------------------------------------------------------------
