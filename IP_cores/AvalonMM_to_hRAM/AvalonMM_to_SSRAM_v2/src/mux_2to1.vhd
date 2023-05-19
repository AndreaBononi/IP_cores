-- mux_2to1.vhd ------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- MULTIPLEXER with 2 inputs (N bit)
-- sel = 0 --> out_mux = mux_in_0
-- sel = 1 --> out_mux = mux_in_1

-----------------------------------------------------------------------------

entity mux_2to1 is
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
end mux_2to1;

-----------------------------------------------------------------------------

architecture behavior of mux_2to1 is

	begin

		output_evaluation: process (sel, mux_in_0, mux_in_1)
		begin
			case sel is
				when '0' =>
					out_mux <= mux_in_0;
				when others =>
					out_mux <= mux_in_1;
			end case;
		end process output_evaluation;
		
end behavior;

-----------------------------------------------------------------------------
