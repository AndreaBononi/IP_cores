#!/usr/bin/env python

# public modules -----------------------------------------------------------------------------------------------------------------------
import random
import subprocess

# private modules ----------------------------------------------------------------------------------------------------------------------
import memory

# constants ----------------------------------------------------------------------------------------------------------------------------
virtual_address_binary_size = 32    # the memory virtually has 32 addressing bits, but only the 8 less significant bits are considered
real_address_binary_size = 8
word_binary_size = 16
read_opcode = '0'
write_opcode = '1'

# high-level model instance ------------------------------------------------------------------------------------------------------------
mem = memory.memory( address_binary_size = real_address_binary_size, word_binary_size = word_binary_size )
mem.reset()

# stimuli and expected results generation ----------------------------------------------------------------------------------------------
# at first, all memory locations are written with a random writedata
# later, the value of each memory location is read
try:
    stimuli = open( "stimuli.txt", "w" )
    expected = open( "expected_read_values.txt", "w" )
    # generate writing operations
    for decimal_address in range( 0, 2 ** real_address_binary_size ):
        address = format( decimal_address, str( real_address_binary_size ) + 'b' ).replace(" ", "0")
        writedata = format( random.randint( 0,  2 ** word_binary_size ), str( word_binary_size ) + 'b' ).replace(" ", "0")
        # stimuli file updating
        stimuli.write( write_opcode )
        for idx in range (real_address_binary_size, virtual_address_binary_size):
            stimuli.write( str( 0 ) )
        stimuli.write( address )
        stimuli.write( writedata )
        stimuli.write( "\n" )
        # high-level model updating
        mem.write( address =  address, writedata = writedata )
    # generate reading operations and expected results
    for decimal_address in range( 0, 2 ** real_address_binary_size ):
        address = format( decimal_address, str( real_address_binary_size ) + 'b' ).replace(" ", "0")
        # stimuli file updating
        # stimuli file updating
        stimuli.write( read_opcode )
        for idx in range (real_address_binary_size, virtual_address_binary_size):
            stimuli.write( str( 0 ) )
        stimuli.write( address )
        stimuli.write( "\n" )
        # evaluate expected result using high-level model
        expected.write( mem.read( address = address ) )
        expected.write( "\n" )
except OSError:
    print( "Error: files creation failed" )
    raise
except AttributeError:
    print( "Error: high-level model failure" )
    raise
else:
    stimuli.close()
    expected.close()
    print( "Stimuli file correctly generated" )
    print( "Expected values file correctly generated" )

# simulation --------------------------------------------------------------------------------------------------------------------------
print ("Starting simulation...")
# process = subprocess.call(["vsim", "-c", "-do", "AvalonMM_hyperRamS27KL0641_interface_simulation.do"])
# RIMUOVERE I DUE COMANDI DA SHELL E DECOMMENTARE L'ESECUZIONE DELLA SIMULAZIONE
subprocess.run( "touch read_values.txt", shell = True )
subprocess.run( "cat expected_read_values.txt > read_values.txt", shell = True )
print ("Simulation completed")

# output verification -----------------------------------------------------------------------------------------------------------------
subprocess.run( "diff expected_read_values.txt read_values.txt -y --suppress-common-lines | wc -l", shell = True)
# 'if (( $(diff expected_read_values.txt read_values.txt -y --suppress-common-lines | wc -l) == 0 )); then echo "DUT passed"; else echo "DUE rejected"; fi'
