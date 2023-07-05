-- synchronizer.vhd -------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SYNCHRONIZER
-- the rising edge of din_strobe is center aligned with din
-- the delay between din_strobe and the clock is unknown
-- dout is equal to din but synchrononus with the clock
-- burstcount represets the number of data to synchronize
-- burstcount is sampled by din_strobe, thus it must be valid before din_strobe starts oscillating
-- burstcount must be kept constant up to the end of the operation
-- an operation is terminated when busy goes low after going high
-- busy goes low when burstcount is reached, every provided after that is ignored
-- at the end of an operation, the synchronizer must be cleared in order to start a new operation
-- synch_enable must be set to '1' before sending the strobe (otherwise the strobe oscillations are ignored)
-- it is recommended to keep synch_enable set to '1' up to the end of the sycnhronization (although its value does not actually matter)

--------------------------------------------------------------------------------------------------------

entity synchronizer is
	generic
  (
    N_burstcount              : integer := 11
  );
	port
	(
		clk                       : in    std_logic;
		rst_n											: in    std_logic;
		synch_enable              : in		std_logic;
		synch_clear_n             : in		std_logic;
		burstcount                : in		std_logic_vector((N_burstcount-1) downto 0);
		din_strobe                : in		std_logic;
		din                       : in		std_logic_vector(15 downto 0);
		dout                      : out		std_logic_vector(15 downto 0);
		synch_validout            : out		std_logic;
		synch_busy                : out		std_logic
	);
end synchronizer;

--------------------------------------------------------------------------------------------------------

architecture rtl of synchronizer is

	-- execution unit ------------------------------------------------------------------------------------
	component synchronizer_EU is
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
			synch_validout            : out		std_logic;
	    synch_busy                : out		std_logic;
	    -- control signals:
	    system_clear_n            : in		std_logic;
	    system_enable             : in		std_logic;
	    burstlen_enable           : in		std_logic;
	    burstlen_counter_enable   : in		std_logic;
	    dataout_enable            : in		std_logic;
	    data_counter_enable       : in    std_logic;
	    busy                      : in		std_logic;
	    validout                  : in		std_logic;
	    -- status signals:
	    burst_end                 : out		std_logic;
	    start_sampling            : out		std_logic;
	    enable                    : out		std_logic;
	    clear_n                   : out		std_logic
		);
	end component;

	-- control unit --------------------------------------------------------------------------------------
	component synchronizer_CU is
		port
		(
			-- clock and reset:
			clk                       : in    std_logic;
			rst_n											: in    std_logic;
			-- status signals:
	    burst_end                 : in		std_logic;
	    start_sampling            : in		std_logic;
	    enable                    : in		std_logic;
	    clear_n                   : in		std_logic;
			-- control signals:
	    system_clear_n            : out		std_logic;
	    system_enable             : out		std_logic;
	    burstlen_enable           : out		std_logic;
	    burstlen_counter_enable   : out		std_logic;
	    dataout_enable            : out		std_logic;
	    data_counter_enable       : out		std_logic;
	    busy                      : out		std_logic;
	    validout                  : out		std_logic
		);
	end component;

	-- internal signals ----------------------------------------------------------------------------------
	signal burst_end									: std_logic;
	signal start_sampling           	: std_logic;
	signal enable                   	: std_logic;
	signal clear_n                  	: std_logic;
	signal system_clear_n            	: std_logic;
	signal system_enable             	: std_logic;
	signal burstlen_enable           	: std_logic;
	signal burstlen_counter_enable   	: std_logic;
	signal dataout_enable            	: std_logic;
	signal data_counter_enable       	: std_logic;
	signal busy                      	: std_logic;
	signal validout                 	: std_logic;

	begin

		EU: synchronizer_EU
		generic map
		(
			N_burstcount
		)
		port map
		(
			clk,
			synch_enable,
			synch_clear_n
			burstcount,
			din_strobe,
			din,
			dout,
			synch_validout,
			synch_busy,
			system_clear_n,
			system_enable,
			burstlen_enable,
			burstlen_counter_enable,
			dataout_enable,
			data_counter_enable,
			busy,
			validout,
			burst_end,
			start_sampling,
			enable,
			clear_n
		);

		CU: synchronizer_CU
		port map
		(
			clk,
			rst_n,
			burst_end,
			start_sampling,
			enable,
			clear_n,
			system_clear_n,
			system_enable,
			burstlen_enable,
			burstlen_counter_enable,
			dataout_enable,
			data_counter_enable,
			busy,
			validout
		);

end rtl;

--------------------------------------------------------------------------------------------------------
