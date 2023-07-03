-- decoder_2bit.vhd ------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- DECODER with 2 bit input (i.e. 4 decoded outputs)

-----------------------------------------------------------------------------

entity decoder_2bit is
	port
	(
		code				: in		std_logic_vector(1 downto 0);
		dec00				: out 	std_logic;
		dec01				: out 	std_logic;
		dec10				: out 	std_logic;
		dec11				: out 	std_logic
	);
end decoder_2bit;

-----------------------------------------------------------------------------

architecture behavior of decoder_2bit is

	begin
		output_evaluation: process (code)
		begin
			case code is
				when "00" =>
					dec00 <= '1';
					dec01 <= '0';
					dec10 <= '0';
					dec11 <= '0';
				when "01" =>
					dec00 <= '0';
					dec01 <= '1';
					dec10 <= '0';
					dec11 <= '0';
				when "10" =>
					dec00 <= '0';
					dec01 <= '0';
					dec10 <= '1';
					dec11 <= '0';
				when others =>
					dec00 <= '0';
					dec01 <= '0';
					dec10 <= '0';
					dec11 <= '1';
			end case;
		end process output_evaluation;

end behavior;

-----------------------------------------------------------------------------
