#!/usr/bin/env python

# public modules -----------------------------------------------------------------------------------------------------------------------
import random
import subprocess

# private modules ----------------------------------------------------------------------------------------------------------------------
import memory

# constants ----------------------------------------------------------------------------------------------------------------------------
simulation_project = "AvalonMM_to_SSRAM"
stimuli_file = "AvalonMM_to_SSRAM_stimuli.txt"
output_file = "AvalonMM_to_SSRAM_readValues.txt"
expected_file = "AvalonMM_to_SSRAM_expectedReadValues.txt"
simulation_file = "AvalonMM_to_SSRAM_simulation.do"
tb_file = "../tb/AvalonMM_to_SSRAM_testbench.vhd"
vsim_path = '~/intelFPGA/20.1/modelsim_ase/bin/vsim'
ssram_valid_time = ["5 ns", "15 ns", "25 ns"]
clock = "10 ns"
virtual_address_binary_size = 32    # the memory virtually has 32 addressing bits, but only the 8 less significant bits are considered
real_address_binary_size = 8
word_binary_size = 16
read_opcode = '0'
write_opcode = '1'

# environment preparation --------------------------------------------------------------------------------------------------------------
subprocess.run( "rm -r sim_*ns", shell=True )
subprocess.run( "rm vsim_log_*", shell=True )

# information printing -----------------------------------------------------------------------------------------------------------------
print( "VSIM path:", vsim_path )
print( "Project:",  simulation_project)
print( "File", tb_file, "must contain the following line:", '\"constant ssram_valid_time: time := [0123456789]* ns\"')
print( "Tested SSRAM valid times:", ssram_valid_time)
print( "..." )

# virtual memory creation --------------------------------------------------------------------------------------------------------------
mem = memory.memory( address_binary_size = real_address_binary_size, word_binary_size = word_binary_size )
mem.reset()

# stimuli and expected results generation ----------------------------------------------------------------------------------------------
# at first, all memory locations are written with a random writedata
# later, the value of each memory location is read
try:
    stimuli = open( stimuli_file, "w" )
    expected = open( expected_file, "w" )
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

err = False
for time in ssram_valid_time:
    cmd = 'sed \'s/constant ssram_valid_time: time := [0123456789]* ns/constant ssram_valid_time: time := ' + time + '/\' ' + tb_file + " > a.vhd"
    subprocess.run( cmd, shell=True )
    subprocess.run( 'rm ' + tb_file, shell=True )
    subprocess.run( 'mv a.vhd ' + tb_file, shell=True )
    # simulation ----------------------------------------------------------------------------------------------------------------------
    print ("Starting simulation for SSRAM valid time equal to " + time + "...")
    subprocess.run( vsim_path + " -c -do " + simulation_file + " > vsim_log_" + time.replace(" ", "") + ".txt", shell=True )
    print ("Simulation completed")
    subprocess.run( 'mkdir sim_' + time.replace(" ", ""), shell=True )
    subprocess.run( 'mv ' + output_file + ' ./sim_' + time.replace(" ", "") + '/', shell=True )
    # output verification -------------------------------------------------------------------------------------------------------------
    cmd = "diff " + expected_file + " ./sim_" + time.replace(" ", "") + "/" + output_file + " -y --suppress-common-lines | wc -l"
    verification_process = subprocess.run( cmd, shell = True, capture_output = True )
    diff = verification_process.stdout.decode( "utf-8" ).replace("\n", "")
    if ( diff == '0' ):
        print( "DUT is working correctly" )
    else:
        print( "DUT is not working as expected" )
        print( diff, "errors detected" )
        err = True

if ( err == True ):
    print( "Verification failed" )
else:
    print( "Verification passed" )
