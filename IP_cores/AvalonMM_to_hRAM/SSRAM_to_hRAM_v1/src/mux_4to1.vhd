-- mux_4to1.vhd ------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- MULTIPLEXER with 4 inputs (N bit)
-- sel = 00 --> out_mux = mux_in_00
-- sel = 01 --> out_mux = mux_in_01
-- sel = 10 --> out_mux = mux_in_10
-- sel = 11 --> out_mux = mux_in_11

-----------------------------------------------------------------------------

entity mux_4to1 is
	generic
	(
		N : integer := 1
	);
	port
	(
		mux_in_00		: in		std_logic_vector((N-1) downto 0);
		mux_in_01		: in		std_logic_vector((N-1) downto 0);
		mux_in_10		: in		std_logic_vector((N-1) downto 0);
		mux_in_11		: in		std_logic_vector((N-1) downto 0);
		sel					: in 		std_logic_vector(1 downto 0);
		out_mux			: out 	std_logic_vector((N-1) downto 0)
	);
end mux_4to1;

-----------------------------------------------------------------------------

architecture behavior of mux_4to1 is
	begin
		output_evaluation: process (sel, mux_in_00, mux_in_01, mux_in_10, mux_in_11)
		begin
			case sel is
				when "00" =>
					out_mux <= mux_in_00;
				when "01" =>
					out_mux <= mux_in_01;
				when "10" =>
					out_mux <= mux_in_10;
				when others =>
					out_mux <= mux_in_11;
			end case;
		end process output_evaluation;
end behavior;

-----------------------------------------------------------------------------
