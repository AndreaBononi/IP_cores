library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity master is
	port
	(
		-- Main clock inputs
		mainClk		: in std_logic;
		slowClk		: in std_logic;
		-- Main reset input
		reset			: in std_logic;
		-- HyperBUS interface
		hBusCk		: out std_logic;
		hBusnCk		: out std_logic;
		hBusCs		: out std_logic;
		hBusRst		: out std_logic;
		hBusD			: inout std_logic_vector( 7 downto 0 );
		hBusRwds		: inout std_logic;
		-- MCU interface (SPI-QSPI)
		mcuSpiCk		: in std_logic;
		mcuSpiCs		: in std_logic;
		mcuSpiIo		: inout std_logic_vector( 3 downto 0 );
		-- MCU interface (UART, I2C)
		mcuUartTx	: in std_logic;
		mcuUartRx	: out std_logic;
		mcuI2cScl	: in std_logic;
		mcuI2cSda	: inout std_logic;
		-- Logic state analyzer/stimulator
		lsasBus		: inout std_logic_vector( 31 downto 0 );
		-- LEDs
		leds			: out std_logic_vector( 3 downto 0 )
	);
end master;

architecture behavioural of master is

	signal clk: std_logic;
	signal pllLock: std_logic;

	signal lsasBusIn: std_logic_vector( 31 downto 0 );
	signal lsasBusOut: std_logic_vector( 31 downto 0 );
	signal lsasBusEn: std_logic_vector( 31 downto 0 ) := ( others => '0' );

	signal hBusDIn: std_logic_vector( 7 downto 0 );
	signal hBusDOut: std_logic_vector( 7 downto 0 );
	signal hBusEn: std_logic := '0';
	
	signal mcuSpiDIn: std_logic_vector( 3 downto 0 );
	signal mcuSpiDOut: std_logic_vector( 3 downto 0 );
	signal mcuSpiEn: std_logic_vector( 3 downto 0 ) := ( others => '0' );	

	signal mcuI2cDIn: std_logic;
	signal mcuI2CDOut: std_logic;
	signal mcuI2cEn: std_logic := '0';	

	component myAltPll
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC ;
			locked		: OUT STD_LOGIC 
		);
	end component;
	
begin

--**********************************************************************************
--* Main clock PLL
--**********************************************************************************

	myAltPll_inst : myAltPll PORT MAP 
	(
		areset	=> reset,
		inclk0	=> mainClk,
		c0	 		=> clk,
		locked	=> pllLock
	);

--**********************************************************************************
--* LEDs
--**********************************************************************************

	leds <= "0001";
	
--**********************************************************************************
--* Logic state analyzer/stimulator dummy process definition
--* Just a simple up counter
--* 		lsasBus	: inout std_logic_vector( 31 downto 0 )
--**********************************************************************************

	lsasBusIn <= lsasBus;

	lsasBus_tristate:
	process( lsasBusEn, lsasBusOut ) is
	begin
		for index in 0 to 31 loop
			if lsasBusEn( index ) = '1'  then
				lsasBus( index ) <= lsasBusOut ( index );
			else
				lsasBus( index ) <= 'Z';
			end if;
		end loop;
	end process;

	-- Dummy counter for lsasBus
	dummy_lsas:
	process( reset, clk ) is 
	begin
		if( reset = '1' ) then
			lsasBusOut <= ( others => '0' );
			lsasBusEn <= ( others => '0' );
		else
			lsasBusEn <= ( others =>'0' );
			if( rising_edge( clk ) ) then
				lsasBusOut <= std_logic_vector( unsigned( lsasBusOut ) + 1 );
			end if;
		end if;
	end process; 

--**********************************************************************************
--* HyperBus interface
--* Just a simple up counter
--*		hBusCk	: out std_logic;
--*		hBusCs	: out std_logic;
--*		hBusRst	: out std_logic;
--*		hBusD		: inout std_logic_vector( 7 downto 0 );
--*		hBusRwds	: inout std_logic;
--**********************************************************************************

	hBusCk <= clk;
	hBusnCk <= not clk;
	hBusCs <= hBusDOut( 2 );
	hBusDIn <= hBusD;
	hBusRst <= hBusDOut( 1 );
	hBusRwDs <= 'Z';

	hBusD_tristate:
	process( hBusEn, hBusDOut ) is
	begin
		if hBusEn = '1'  then
			hBusD <= hBusDOut;
		else
			hBusD <= ( others => 'Z' );
		end if;
	end process;

	-- Dummy counter for hBusD
	dummy_hbus:
	process( reset, clk ) is 
	begin
		if( reset = '1' ) then
			hBusDOut <= ( others => '0' );
			hBusEn <= '0';
		else
			hBusEn <= '1';
			if( rising_edge( clk ) ) then
				hBusDOut <= std_logic_vector( unsigned( hBusDOut ) + 3 );
			end if;
		end if;
	end process; 

--**********************************************************************************
--* MCU interface
--* Get bits from other processes
--*		mcuSpiCk		: in std_logic;
--*		mcuSpiCs		: in std_logic;
--*		mcuSpiIo	   : inout std_logic_vector( 3 downto 0 );
--**********************************************************************************

	mcuSpiDIn <= mcuSpiIo;

	mcuSpiD_tristate:
	process( mcuSpiEn, mcuSpiDOut ) is
	begin
		for index in 0 to 3 loop
			if mcuSpiEn( index ) = '1'  then
				mcuSpiIo( index ) <= mcuSpiDOut ( index );
			else
				mcuSpiIo( index ) <= 'Z';
			end if;
		end loop;
	end process;

	-- Dummy counter for mcuSpiIo
	dummy_mcuspi:
	process( reset, clk ) is 
	begin
		if( reset = '1' ) then
			mcuSpiDout <= ( others => '0' );
			mcuSpiEn <= ( others => '0' );
		else
			mcuSpiEn <= ( others => '1' );
			if( rising_edge( clk ) ) then
				mcuSpiDOut <= std_logic_vector( unsigned( mcuSpiDOut ) + 5 );
			end if;
		end if;
	end process; 

end behavioural;
