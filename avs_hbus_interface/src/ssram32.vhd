-- ssram32.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SSRAM
-- N bit words
-- 32 bit addressing (VIRTUALMENTE, in realta solo gli 8 bit meno significativi vengono considerati e gli altri sono scartati)

--------------------------------------------------------------------------------------------------

entity ssram32 is
	generic
	(
		N 					: integer 	:= 32;
		valid_time		: time 		:= 5 ns
	);
	port
	(
		ssram32_clk			: in 	std_logic;
		ssram32_clear_n	: in 	std_logic;
		ssram32_read		: in 	std_logic;
		ssram32_write		: in 	std_logic;
		ssram32_address	: in 	std_logic_vector(31 downto 0);
		ssram32_in			: in 	std_logic_vector(N-1 downto 0);
		ssram32_out			: out std_logic_vector(N-1 downto 0);
		ssram32_valid		: out std_logic
	);
end ssram32;

--------------------------------------------------------------------------------------------------

architecture behavior of ssram32 is

   type matrix is array(0 to 255) of std_logic_vector(N-1 downto 0);
	
	-- internal signals
   signal 	mem				: matrix;
	signal 	dummy_address	: integer;
	signal 	dummy_out		: std_logic_vector (N-1 downto 0);
	signal	valid				: std_logic;

   begin

		dummy_address <= to_integer(unsigned(ssram32_address));

		memory_cycle: process (ssram32_clk, ssram32_clear_n, ssram32_write, ssram32_read, ssram32_in, dummy_address)
			begin
            if (rising_edge(ssram32_clk)) then
					if (valid = '1') then
						valid <= '0';
					end if;
               if (ssram32_clear_n = '0') then
                  mem <= (others => (others => '0'));
						valid <= '0';
               elsif (ssram32_write = '1') then
                  mem(dummy_address) <= ssram32_in after valid_time;
						valid <= '1' after valid_time;
               end if;
               if (ssram32_read = '1') then
                  dummy_out <= mem(dummy_address) after valid_time;
						valid <= '1' after valid_time;
               end if;
            end if;
		end process memory_cycle;

		ssram32_out <= dummy_out;
		ssram32_valid <= valid;

end behavior;

--------------------------------------------------------------------------------------------------