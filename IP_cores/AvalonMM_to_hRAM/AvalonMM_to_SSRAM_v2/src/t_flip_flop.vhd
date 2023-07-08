-- d_flipflop.vhd -------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- flip flop type T

-------------------------------------------------------------------------------------------------------

entity t_flip_flop is
	port
	(
		clk				: in 	std_logic;
		enable		: in 	std_logic;
		clear_n		: in 	std_logic;
		rst_n			: in 	std_logic;
		tff_in		: in 	std_logic;
		tff_out		: out std_logic
	);
end t_flip_flop;

-------------------------------------------------------------------------------------------------------

architecture behavior of t_flip_flop is

	signal dummy_out: std_logic;

	begin

		tff_process: process (clk, clear_n, enable)
		begin
			if (rst_n = '0') then
				dummy_out <= '0';
			else
				if (rising_edge(clk)) then
					if (clear_n = '0') then
						dummy_out <= '0';
					elsif (enable = '1') then
						if (tff_in = '0') then
							dummy_out <= dummy_out;
						elsif (tff_in = '1') then
							dummy_out <= not(dummy_out);
					  end if;
					end if;
				end if;
			end if;
		end process tff_process;

	tff_out <= dummy_out;

end behavior;

-------------------------------------------------------------------------------------------------------
