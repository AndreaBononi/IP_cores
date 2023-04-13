	component AvalonMM_hyperRamS27KL0641_interface is
		port (
			clk_clk       : in std_logic := 'X'; -- clk
			reset_reset_n : in std_logic := 'X'  -- reset_n
		);
	end component AvalonMM_hyperRamS27KL0641_interface;

	u0 : component AvalonMM_hyperRamS27KL0641_interface
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --   clk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n  -- reset.reset_n
		);

