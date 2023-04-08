-- input_output_generator.vhd ----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- input generation and output storing for AvalonMM_hyperRAMs27KLO641_interface
-- clock and active low reset must be provided
-- custom input delay (equal for all the input signals)

-- the input file contains the operations to be made (read or write in the memory)
-- each row of the input file is made up by 49 bits (write operation) or 33 bits (read operation)
-- the first bit represents the opcode ('0' to read, '1' to write)
-- the following 32 bits represent the memory address
-- in caso of write operation, the final 16 bits represents the data to be written in the memory

-- the output file contains the values read from the memory

------------------------------------------------------------------------------------------------------------------

entity input_output_generator is
	generic	
	(
		custom_delay			: time := 0 ns
	);	
	port 
	(
		clk						: in		std_logic;
		rstN						: in  	std_logic;
		avs_s0_waitrequest 	: in		std_logic;
		avs_s0_readdata	 	: in 		std_logic_vector(15 downto 0);
		avs_s0_address			: out		std_logic_vector(31 downto 0); 
		avs_s0_read       	: out 	std_logic;                                 
		avs_s0_write      	: out 	std_logic;             
		avs_s0_writedata  	: out 	std_logic_vector(15 downto 0)
	);
end input_output_generator;

------------------------------------------------------------------------------------------------------------------

architecture behavior of input_output_generator is

	file 			input_file	: text;
	file 			output_file	: text;
	
	begin
		input_output_generation		: process (clk, rstN)
		variable inputline			: line;
		variable outputline			: line;
		variable input_file_stat	: file_open_status;
		variable output_file_stat	: file_open_status;
		variable opcode				: std_logic;
		variable input_address		: std_logic_vector(31 downto 0);
		variable input_writedata	: std_logic_vector(15 downto 0);
		variable read_flag			: std_logic := '0';
		begin
			-- files opening ----------------------------------------------------------------------------------------
			file_open(input_file_stat, input_file, "stimuli.txt", read_mode);
			file_open(output_file_stat, output_file, "read_values.txt", write_mode);
			-- reset condition --------------------------------------------------------------------------------------
			if (rstN = '0') then      
				avs_s0_read	<= '0' after custom_delay;
				avs_s0_write <= '0' after custom_delay;
			-- operations -------------------------------------------------------------------------------------------
			elsif (rising_edge(clk)) then
				if (not endfile(input_file)) then
					if (avs_s0_waitrequest = '0') then
						if (read_flag = '1') then
							-- reading result available -----------------------------------------------------------------
							write(outputline, avs_s0_readdata);
							writeline(output_file, outputline);
							read_flag := '0';					
						end if;
						readline(input_file, inputline);
						read(inputline, opcode);
						if (opcode = '0') then
							-- start reading ----------------------------------------------------------------------------
							read(inputline, input_address);
							avs_s0_write <= '0';
							avs_s0_read <= '1';
							avs_s0_address <= input_address;
							read_flag := '1';
						elsif (opcode = '1') then
							-- start writing ----------------------------------------------------------------------------
							read(inputline, input_address);
							read(inputline, input_writedata);
							avs_s0_read <= '0';
							avs_s0_write <= '1';
							avs_s0_address <= input_address;
							avs_s0_writedata <= input_writedata;
						end if;
					end if;
				end if;
			end if;
		end process input_output_generation;
  
end behavior;

------------------------------------------------------------------------------------------------------------------