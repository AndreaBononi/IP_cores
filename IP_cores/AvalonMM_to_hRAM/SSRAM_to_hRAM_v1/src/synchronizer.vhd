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
-- at the end of an operation, the synchronizer must be cleared in order to start a new operation

--------------------------------------------------------------------------------------------------------

entity synchronizer_EU is
	port
	(

	);
end synchronizer_EU;

--------------------------------------------------------------------------------------------------------

architecture behavior of synchronizer_EU is



end behavior;

--------------------------------------------------------------------------------------------------------
