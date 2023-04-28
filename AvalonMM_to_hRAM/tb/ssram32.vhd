-- ssram32.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SSRAM
-- N bit words

-- 32 bit addressing
-- only the 8 less significant bits of the address are considered, therefore the effective addressing is on 8 bits
-- the 24 more significant bits are discarded

-- after sampling a read operation, the output becomes valid after valid_time is passed (ssram32_validout is set)

-- when ssram32_busy the memory is not able to perform any operation (read and write commands are ignored)

--------------------------------------------------------------------------------------------------

entity ssram32 is
	generic
	(
		N 						: integer 	:= 32;
		valid_time		: time 		:= 5 ns
	);
	port
	(
		ssram32_clk				: in 	std_logic;
		ssram32_clear_n		: in 	std_logic;
		ssram32_OE				: in 	std_logic;
		ssram32_WE				: in 	std_logic;
		ssram32_CS				: in 	std_logic;
		ssram32_address		: in 	std_logic_vector(31 downto 0);
		ssram32_in				: in 	std_logic_vector(N-1 downto 0);
		ssram32_out				: out std_logic_vector(N-1 downto 0);
		ssram32_validout	: out std_logic;
		ssram32_busy			: out std_logic
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
	signal	busy				: std_logic := '0';

   begin

		dummy_address <= to_integer(unsigned(ssram32_address(7 downto 0)));

		memory_cycle: process (ssram32_clk, ssram32_clear_n, ssram32_WE, ssram32_OE, ssram32_CS, dummy_address, busy)
		variable operation_execution: std_logic := '0';
		begin
        if (rising_edge(ssram32_clk)) then
					if (valid = '1') then
						valid <= '0';
					end if;
          if (ssram32_clear_n = '0') then
            mem <= (others => (others => '0'));
						valid <= '0';
          elsif (ssram32_WE = '1' and ssram32_CS = '1' and busy = '0') then
						busy <= '1' after 0 ns, '0' after valid_time;					
            mem(dummy_address) <= ssram32_in after valid_time;
          elsif (ssram32_OE = '1' and ssram32_CS = '1'  and busy = '0') then
						busy <= '1' after 0 ns, '0' after valid_time;
            dummy_out <= mem(dummy_address) after valid_time;
						valid <= '0' after 0 ns, '1' after valid_time;
          end if;
        end if;
		end process memory_cycle;

		ssram32_out <= dummy_out;
		ssram32_validout <= valid;
		ssram32_busy <= busy;

end behavior;

--------------------------------------------------------------------------------------------------
