-- synchronizer_EU.vhd ----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SYNCHRONIZER execution unit

---------------------------------------------------------------------------------------------------------------

entity synchronizer_EU is
  generic
  (
    N_burstcount              : integer := 11
  );
	port
	(
    -- clock:
    clk                       : in    std_logic;
    -- data signals:
    synch_enable              : in		std_logic;
    synch_clear_n             : in		std_logic;
    burstcount                : in		std_logic_vector((N_burstcount-1) downto 0);
    din_strobe                : in		std_logic;
    din                       : in		std_logic_vector(15 downto 0);
    dout                      : out		std_logic_vector(15 downto 0);
		validout                  : out		std_logic;
    busy                      : out		std_logic;
    -- control signals:
    system_clear_n            : in		std_logic;
    system_enable             : in		std_logic;
    burstlen_enable           : in		std_logic;
    burstlen_counter_enable   : in		std_logic;
    datamux_sel               : in		std_logic;
    dataout_enable            : in		std_logic;
    synch_busy                : in		std_logic;
    synch_validout            : in		std_logic;
    -- status signals:
    burst_end                 : out		std_logic;
    start_sampling            : out		std_logic;
    enable                    : out		std_logic;
    clear_n                   : out		std_logic
	);
end synchronizer_EU;

---------------------------------------------------------------------------------------------------------------

architecture behavior of synchronizer_EU is

  -- register -------------------------------------------------------------------------------------------------
  component reg is
  	generic
  	(
  		N : integer := 8
  	);
  	port
  	(
  		clk				: in 	std_logic;
  		enable		: in 	std_logic;
  		clear_n		: in 	std_logic;
  		reg_in		: in 	std_logic_vector(N-1 downto 0);
  		reg_out		: out std_logic_vector(N-1 downto 0)
  	);
  end component;

  -- flip flop set reset -------------------------------------------------------------------------------------
  component sr_flipflop is
  	port
  	(
  		clk			: in std_logic;
  		set			: in std_logic;
  		clear_n		: in std_logic;
  		sr_out		: out std_logic
  	);
  end component;

  -- multiplexer 4 to 1 --------------------------------------------------------------------------------------
  component mux_4to1 is
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
  		sel					: in 		std_logic_vector(2);
  		out_mux			: out 	std_logic_vector((N-1) downto 0)
  	);
  end component;

  -- comparator -----------------------------------------------------------------------------------------------
  component comparator_Nbit is
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
  end component;

  -- decoder -----------------------------------------------------------------------------------------------
  component decoder_2bit is
  	port
  	(
  		code				: in		std_logic_vector(1 downto 0);
  		dec00				: out 	std_logic;
  		dec01				: out 	std_logic;
  		dec10				: out 	std_logic;
  		dec11				: out 	std_logic
  	);
  end component;

  -- counter -----------------------------------------------------------------------------------------------
  component counter_Nbit is
  	generic
  	(
  		N					: integer := 4
  	);
  	port
  	(
  		clk				: in 		std_logic;
  		enable		: in 		std_logic;
  		clear_n		: in 		std_logic;
  		cnt_out		: out 	std_logic_vector(N-1 downto 0)
  	);
  end component;

  -- internal signals --------------------------------------------------------------------------------------
  signal code_counter_out       : std_logic_vector(1 downto 0);
  signal dec00                  : std_logic;
  signal dec01                  : std_logic;
  signal dec10                  : std_logic;
  signal dec11                  : std_logic;
  signal readdata00_out         : std_logic;
  signal readdata01_out         : std_logic;
  signal readdata10_out         : std_logic;
  signal readdata11_out         : std_logic;
  signal readdata00_enable      : std_logic;
  signal datamux_out            : std_logic_vector(15 downto 0);
  signal burstlen_out           : std_logic_vector((N_burstcount-1) downto 0);
  signal burstlen_counter_out   : std_logic_vector((N_burstcount-1) downto 0);

  begin

    code_counter      : counter_Nbit generic map(2) port map(din_strobe, system_enable, system_clear_n, code_counter_out);
    synchronizer      : sr_flipflop port map(din_strobe, system_enable, system_clear_n, start_sampling);
    dec               : decoder_2bit port map(code_counter_out, dec00, dec01, dec10, dec11);
    readdata11        : reg generic map(16) port map(din_strobe, dec11, '1', din, readdata11_out);
    readdata10        : reg generic map(16) port map(din_strobe, dec10, '1', din, readdata10_out);
    readdata01        : reg generic map(16) port map(din_strobe, dec01, '1', din, readdata01_out);
    readdata00        : reg generic map(16) port map(din_strobe, readdata00_enable, '1', din, readdata00_out);
    datamux           : mux_4to1 generic map(16) port map(readdata00_out, readdata01_out, readdata10_out, readdata11_out, datamux_sel, datamux_out);
    dataout           : reg generic map(15) port map(clk, dataout_enable, '1', datamux_out, dout);
    burstlen          : reg generic map(N_burstcount) port map(din_strobe, burstlen_enable, '1', burstcount, burstlen_out);
    burstlen_counter  : counter_Nbit generic map(N_burstcount) port map(clk, burstlen_counter_enable, system_clear_n, burstlen_counter_out);
    burstlen_cmp      : comparator_Nbit generic map(N_burstcount) port map(burstlen_out, burstlen_counter_out, burst_end);

    readdata00_enable <= dec00 and system_enable;

    clear_n <= synch_clear_n;
    enable <= synch_enable;
    synch_busy <= busy;
    synch_validout <= validout;


end behavior;

------------------------------------------------------------------------------------------------------------
