----------------------------------------------------------------------------------------------------------------------------------
IP CORE: AvalonMM_to_hRAM 
----------------------------------------------------------------------------------------------------------------------------------
COMPONENT DESCRIPTION:
The component implements the conversion between an Intel Avalon memory-mapped interface and a generic hyperRAM interface.
The component is separated in two different sub-components:
	# AvalonMM_to_SSRAM: conversion between Intel Avalon memory-mapped interface and SSRAM interface
	# SSRAM_to_hRAM: conversion between SSRAM interface and hyperRAM interface
----------------------------------------------------------------------------------------------------------------------------------
DIRECTORIES DESCRIPTION:
	#
	# AvalonMM_to_SSRAM_v1:
		-- First version of the AvalonMM to SSRAM converter
		-- It is able to append different operations
		-- It is NOT able to initialize the hRAM configuration registers
		-- It is NOT able to read/write the hRAM configuration registers
		-- It is NOT able to manage burst operations
		-- It has been completed and succesfully tested
	#
	# AvalonMM_to_SSRAM_v2:
		-- Second version of the AvalonMM to SSRAM converter
		-- It is able to append different operations
		-- It is able to initialize the hRAM configuration registers
		-- It defines a private configuration register to read and write
		-- It is NOT able to manage burst operations
		-- It has been completed and succesfully tested
	#
	# AvalonMM_to_SSRAM_v3:
		-- Final version of the AvalonMM to SSRAM converter
		-- It is able to append different operations
		-- It is able to initialize the hRAM configuration registers
		-- It defines a private configuration register to read and write
		-- It is able to manage burst operations
		-- It is currently under development
	#
	# SSRAM_to_hRAM_v1:
		-- First version of the SSRAM to hRAM converter
		-- It is currently under development
	#
	# AvalonMM_to_hRAM_v1:
		-- First version of the complete AvalonMM to SSRAM converter
		-- It is currently under development
----------------------------------------------------------------------------------------------------------------------------------
	
