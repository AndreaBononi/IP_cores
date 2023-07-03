-- comparator_Nbit.vhd ------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- COMPARATOR between 2 inputs (N bit)

-----------------------------------------------------------------------------

entity comparator_Nbit is
	generic
	(
		N : integer := 1
	);
	port
	(
		cmp_in_0		: in		std_logic_vector((N-1) downto 0);
		cmp_in_1		: in		std_logic_vector((N-1) downto 0);
		equal 			: out 	std_logic
	);
end comparator_Nbit;

-----------------------------------------------------------------------------

architecture behavior of comparator_Nbit is

  signal bitwise_and, intra_and : std_logic_vector(N-1 downto 0);

	begin

    g1: for i in 0 to N-1 generate
			 bitwise_and(i) <= cmp_in_0(i-1) and cmp_in_1(i-1);
		end generate;

    intra_and(0) <= bitwise_and(0);

    g2: for j in 0 to N-1 generate
			 intra_and(i) <= intra_and(i-1) and bitwise_and(i-1);
		end generate;

    equal <= intra_and(N-1);

end behavior;

-----------------------------------------------------------------------------
