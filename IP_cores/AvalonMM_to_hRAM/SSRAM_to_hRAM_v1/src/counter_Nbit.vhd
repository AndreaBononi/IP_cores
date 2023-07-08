-- counter_Nbit.vhd -------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- synchronous counter N bit
-- it can count up to (2^N)-1
-- it is implemented as a chain of T flip flop

-------------------------------------------------------------------------------------------------------

entity counter_Nbit is
	generic
	(
		N					: integer := 4
	);
	port
	(
		clk				: in 		std_logic;
		enable		: in 		std_logic;
		clear_n		: in 		std_logic;
		rst_n			: in		std_logic;
		cnt_out		: out 	std_logic_vector(N-1 downto 0)
	);
end counter_Nbit;

-------------------------------------------------------------------------------------------------------

architecture rtl of counter_Nbit is

	-- flip flop type T ---------------------------------------------------------------------------------
	component t_flip_flop is
		port
		(
			clk				: in 	std_logic;
			enable		: in 	std_logic;
			clear_n		: in 	std_logic;
			rst_n			: in 	std_logic;
			tff_in		: in 	std_logic;
			tff_out		: out std_logic
		);
	end component;

	-- internal signals --------------------------------------------------------------------------------
	signal tgl_in, tgl_out: std_logic_vector(N-1 downto 0);

	begin

		tgl_in(0) <= enable;
		entry_tff: t_flip_flop port map (clk, '1', clear_n, rst_n, tgl_in(0), tgl_out(0));
		g1: for i in 1 to N-1 generate
			 tgl_in(i) <= tgl_in(i-1) and tgl_out(i-1);
			 chain_tff: t_flip_flop port map (clk, '1', clear_n, rst_n, tgl_in(i), tgl_out(i));
		end generate;

		cnt_out <= tgl_out;

end rtl;
