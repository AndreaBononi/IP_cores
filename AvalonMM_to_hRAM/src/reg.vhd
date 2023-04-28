-- reg.vhd ------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- N bit register with enable and synchronous clear signals

-----------------------------------------------------------------------------

entity reg is
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
end reg;

-----------------------------------------------------------------------------

architecture behavior of reg is
	begin
		process (clk, clear_n, enable)
		begin
			if (rising_edge(clk)) then 
				if (clear_n = '0') then 
					reg_out <= (others => '0');
				elsif (enable = '1') then 
					reg_out <= reg_in;
            end if;
			end if;
		end process;
end behavior;

-----------------------------------------------------------------------------