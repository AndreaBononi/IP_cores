-- ssram32.vhd ------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SSRAM
-- N bit words
-- 2 configuration registers

-- MEMORY SPACE (ssram_address_space = '0')
-- 32 bit addressing
-- only the 8 less significant bits of the address are considered, therefore the effective addressing is on 8 bits
-- the 24 more significant bits are discarded

-- CONFIGURATION REGISTERS SPACE (ssram_address_space = '1')
-- configuration register 0 address: config0_addr (32 bit)
-- configuration register 1 address: config1_addr (32 bit)
-- every address different from the previous ones is ignored

-- after sampling an operation (reading or writing in memory or configuration registers) ssram32_busy is set
-- after sampling a read operation, the output becomes valid after valid_time is passed (ssram32_validout is set and ssram32_busy is cleared)
-- after sampling a write operation, the memory remains busy for valid_time (after which ssram-busy is cleared)
-- when ssram32_busy the memory is not able to perform any operation (new read and write commands are ignored)

--------------------------------------------------------------------------------------------------

entity ssram32 is
	generic
	(
		N 								: integer := 32;
		valid_time				: time := 5 ns;
		config0_addr			: std_logic_vector(31 downto 0) := "00000000000000000000100000000000";
		config1_addr			: std_logic_vector(31 downto 0) := "00000000000000000000100000000001"
	);
	port
	(
		ssram32_clk							: in 	std_logic;
		ssram32_clear_n					: in 	std_logic;
		ssram32_OE							: in 	std_logic;
		ssram32_WE							: in 	std_logic;
		ssram32_CS							: in 	std_logic;
		ssram32_address_space		: in 	std_logic;
		ssram32_address					: in 	std_logic_vector(31 downto 0);
		ssram32_in							: in 	std_logic_vector(N-1 downto 0);
		ssram32_out							: out std_logic_vector(N-1 downto 0);
		ssram32_validout				: out std_logic;
		ssram32_busy						: out std_logic
	);
end ssram32;

--------------------------------------------------------------------------------------------------

architecture behavior of ssram32 is

	type matrix is array(0 to 255) of std_logic_vector(N-1 downto 0);

	-- internal signals
  signal mem: matrix;
	signal config0_register: std_logic_vector(15 downto 0);
	signal config1_register: std_logic_vector(15 downto 0);
	signal dummy_address: integer;
	signal dummy_out: std_logic_vector (N-1 downto 0);
	signal valid: std_logic;
	signal busy: std_logic := '0';

   begin

		dummy_address <= to_integer(unsigned(ssram32_address(7 downto 0)));

		memory_cycle: process
		(
			-- sensitivity list
			ssram32_clk, ssram32_clear_n, ssram32_WE, ssram32_OE, ssram32_CS,
			ssram32_address, ssram32_address_space, dummy_address, busy
		)
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
						if (ssram32_address_space = '1') then
							-- configuration registers writing
							if (ssram32_address = config0_addr) then
								config0_register <= ssram32_in after valid_time;
							elsif (ssram32_address = config1_addr) then
								config1_register <= ssram32_in after valid_time;
							end if;
						else
							-- memory writing
							mem(dummy_address) <= ssram32_in after valid_time;
						end if;
          elsif (ssram32_OE = '1' and ssram32_CS = '1'  and busy = '0') then
						busy <= '1' after 0 ns, '0' after valid_time;
						valid <= '0' after 0 ns, '1' after valid_time;
						if (ssram32_address_space = '1') then
							-- configuration registers reading
							if (ssram32_address = config0_addr) then
								dummy_out <= config0_register after valid_time;
							elsif (ssram32_address = config1_addr) then
								dummy_out <= config1_register after valid_time;
							end if;
						else
							-- memory reading
							dummy_out <= mem(dummy_address) after valid_time;
						end if;
          end if;
        end if;
		end process memory_cycle;

		ssram32_out <= dummy_out;
		ssram32_validout <= valid;
		ssram32_busy <= busy;

end behavior;

--------------------------------------------------------------------------------------------------
