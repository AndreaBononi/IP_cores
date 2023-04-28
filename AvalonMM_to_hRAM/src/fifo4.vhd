-- fifo4.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- a push operation saves the input at the top the fifo
-- a pop operation removes the data at the bottom of the fifo, which represents the fifo output

-- a push operation required when fifo4_full = '1' is ignored, unless it is required together with a pop
-- a pop operation required when fifo4_empty = '1' is ignored, unless it is required together with a push

-- fifo4_almost_full is set when at least 3 out of 4 locations contain a valid data 

--------------------------------------------------------------------------------------------------

entity fifo4 is
	generic
	(
		N: integer := 16
	);
	port
	(
		fifo4_clk						: in 	std_logic;
		fifo4_clear_n				: in 	std_logic;
		fifo4_push					: in 	std_logic;
		fifo4_pop						: in 	std_logic;
		fifo4_full					: out	std_logic;
		fifo4_almost_full		: out	std_logic;
		fifo4_empty					: out std_logic;
		fifo4_in						: in 	std_logic_vector(N-1 downto 0);
		fifo4_out						: out std_logic_vector(N-1 downto 0)
	);
end fifo4;

--------------------------------------------------------------------------------------------------

architecture behavior of fifo4 is
	
	signal word0		: std_logic_vector(N-1 downto 0);
	signal word1		: std_logic_vector(N-1 downto 0);
	signal word2		: std_logic_vector(N-1 downto 0);
	signal word3		: std_logic_vector(N-1 downto 0);
	signal s0				: std_logic;
	signal s1				: std_logic;
	signal s2				: std_logic;
	signal s3				: std_logic;
	
	begin
	
		fifo_cycle: process (fifo4_clk, fifo4_clear_n, fifo4_push, fifo4_pop)
		begin
			if (rising_edge(fifo4_clk)) then
				if (fifo4_clear_n = '0') then
					s0 <= '0';
					s1 <= '0';
					s2 <= '0';
					s3 <= '0';
					word0 <= (others => '0');
					word1 <= (others => '0');
					word2 <= (others => '0');
					word3 <= (others => '0');
				else
					-- pop -------------------------------------------------------------------------------
					if (fifo4_pop = '1' and fifo4_push = '0') then
						word3 <= word2;
						word2 <= word1;
						word1 <= word0;
						word0 <= (others => '0');
						s3 <= s2;
						s2 <= s1;
						s1 <= s0;
						s0 <= '0';
					-- push ------------------------------------------------------------------------------
					elsif (fifo4_pop = '0' and fifo4_push = '1') then
						if (s3 = '0') then
							word3 <= fifo4_in;
							s3 <= '1';
						elsif (s2 = '0') then
							word2 <= fifo4_in;
							s2 <= '1';
						elsif (s1 = '0') then
							word1 <= fifo4_in;
							s1 <= '1';
						elsif (s0 = '0') then
							word0 <= fifo4_in;
							s0 <= '1';
						end if;
					-- pop and push ----------------------------------------------------------------------
					elsif (fifo4_pop = '1' and fifo4_push = '1') then
						if (s3 = '0') then
							word3 <= fifo4_in;
							s3 <= '1';
						elsif (s2 = '0') then
							word3 <= fifo4_in;
						elsif (s1 = '0') then
							word3 <= word2;
							word2 <= fifo4_in;
						elsif (s0 = '0') then
							word3 <= word2;
							word2 <= word1;
							word1 <= fifo4_in;
						else
							word3 <= word2;
							word2 <= word1;
							word1 <= word0;
							word0 <= fifo4_in;
						end if;
					end if;
				end if;
			end if;
		end process fifo_cycle;
		
		fifo4_out <= word3;
		fifo4_full <= s0;
		fifo4_almost_full <= s1;
		fifo4_empty <= not s3;
	
end behavior;

--------------------------------------------------------------------------------------------------