-- AvalonMM_to_SSRAM_driver.vhd ----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- driver for AvalonMM_to_SSRAM
-- custom input delay (equal for all the input signals) for functional simulation

-- "AvalonMM_to_SSRAM_stimuli.txt" contains a sequence of operations related to the memory (read or write)
-- "AvalonMM_to_SSRAM_config_stimuli.txt" contains a single writing operation of the config register followed by a single reading operation of the config register
-- each row of the input files is made up by 49 bits (write operation) or 33 bits (read operation)
-- the first bit represents the opcode ('0' to read, '1' to write)
-- the following 32 bits represent the memory address
-- in case of write operation, the final 16 bits represents the data to be written in the memory

------------------------------------------------------------------------------------------------------------------

entity AvalonMM_to_SSRAM_driver is
	generic
	(
		custom_delay					: time := 0 ns
	);
	port
	(
		clk										: in		std_logic;
		rst_n									: in  	std_logic;
		avs_s0_waitrequest 		: in		std_logic;
		avs_s0_readdatavalid	: in		std_logic;
		preliminary_check			: in		std_logic;
		avs_s0_readdata	 			: in 		std_logic_vector(15 downto 0);
		avs_s0_address				: out		std_logic_vector(31 downto 0);
		avs_s0_read       		: out 	std_logic;
		avs_s0_write      		: out 	std_logic;
		avs_s0_writedata  		: out 	std_logic_vector(15 downto 0);
		start_sim							:	out		std_logic := '0';
		driver_stop						: out		std_logic := '0';
		init									: out		std_logic := '1'
	);
end AvalonMM_to_SSRAM_driver;

------------------------------------------------------------------------------------------------------------------

architecture behavior of AvalonMM_to_SSRAM_driver is

	file mem_file: text;
	file config_file: text;

	signal pending: integer; -- RIMUOVERE!!!

	begin
		input_driving								: process (clk, rst_n, avs_s0_waitrequest, avs_s0_readdatavalid, preliminary_check)
		variable inputline					: line;
		variable mem_file_stat			: file_open_status;
		variable config_file_stat		: file_open_status;
		variable opcode							: std_logic;
		variable input_address			: std_logic_vector(31 downto 0);
		variable input_writedata		: std_logic_vector(15 downto 0);
		variable pending_read				: integer := 0;
		variable mem_op_end					: std_logic := '0';
		begin
			file_open(mem_file_stat, mem_file, "../sim/AvalonMM_to_SSRAM_stimuli.txt", read_mode);
			file_open(config_file_stat, config_file, "../sim/AvalonMM_to_SSRAM_config_stimuli.txt", read_mode);
			if (rst_n = '0') then
				avs_s0_read	<= '0';
				avs_s0_write <= '0';
				start_sim <= '1';
			elsif (preliminary_check = '1' and avs_s0_waitrequest = '0') then
				init <= '0';
			else
				if (not endfile(mem_file)) then
					if (rising_edge(clk)) then
						if (avs_s0_waitrequest = '0') then
							readline(mem_file, inputline);
							read(inputline, opcode);
							if (opcode = '0') then
								-- start reading operation --------------------------------------------------------------------
								read(inputline, input_address);
								avs_s0_write <= '0' after custom_delay;
								avs_s0_read <= '1' after custom_delay;
								avs_s0_address <= input_address after custom_delay;
								pending_read := pending_read + 1;
							elsif (opcode = '1') then
								-- start writing operation --------------------------------------------------------------------
								read(inputline, input_address);
								read(inputline, input_writedata);
								avs_s0_read <= '0' after custom_delay;
								avs_s0_write <= '1' after custom_delay;
								avs_s0_address <= input_address after custom_delay;
								avs_s0_writedata <= input_writedata after custom_delay;
							end if;
						end if;
						if (avs_s0_readdatavalid = '1' and pending_read > 0) then
							pending_read := pending_read - 1;
						end if;
					end if;
				else
					if (mem_op_end = '0') then
						-- wait for the completion of all the pending operations ------------------------------------------
						if (rising_edge(clk)) then
							if (pending_read > 0) then
								if (avs_s0_readdatavalid = '1') then
									pending_read := pending_read - 1;
								end if;
							else
								mem_op_end := '1';
							end if;
							if (avs_s0_waitrequest = '0') then
								avs_s0_read <= '0' after custom_delay;
								avs_s0_write <= '0' after custom_delay;
							end if;
						end if;
					else
						-- start configuration register operations --------------------------------------------------------
						if (not endfile(config_file)) then
							if (rising_edge(clk)) then
								if (avs_s0_waitrequest = '0') then
									readline(config_file, inputline);
									read(inputline, opcode);
									if (opcode = '0') then
										-- start reading operation ----------------------------------------------------------------
										read(inputline, input_address);
										avs_s0_write <= '0' after custom_delay;
										avs_s0_read <= '1' after custom_delay;
										avs_s0_address <= input_address after custom_delay;
										pending_read := pending_read + 1;
									elsif (opcode = '1') then
										-- start writing operation ----------------------------------------------------------------
										read(inputline, input_address);
										read(inputline, input_writedata);
										avs_s0_read <= '0' after custom_delay;
										avs_s0_write <= '1' after custom_delay;
										avs_s0_address <= input_address after custom_delay;
										avs_s0_writedata <= input_writedata after custom_delay;
									end if;
								end if;
								if (avs_s0_readdatavalid = '1' and pending_read > 0) then
									pending_read := pending_read - 1;
								end if;
							end if;
						else
							-- wait for completion --------------------------------------------------------------------------
							if (rising_edge(clk)) then
								if (pending_read > 0) then
									if (avs_s0_readdatavalid = '1') then
										pending_read := pending_read - 1;
									end if;
								else
									driver_stop <= '1';
								end if;
								if (avs_s0_waitrequest = '0') then
									avs_s0_read <= '0' after custom_delay;
									avs_s0_write <= '0' after custom_delay;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
			pending <= pending_read;
		end process input_driving;

end behavior;

---------------------------------------------------------------------------------------------------------------
