#!/usr/bin/env python

# public modules -----------------------------------------------------------------------------------------------------------------------
import random
import subprocess

# files and directories ----------------------------------------------------------------------------------------------------------------
simulation_project = "synchronizer"
log_file = "synchronizer_log.txt"
input_file = "synchronizer_in.txt"
output_file = "synchronizer_out.txt"
simulation_file = "synchronizer_simulation.do"
vsim_path = '~/intelFPGA/20.1/modelsim_ase/bin/vsim'

# constants ----------------------------------------------------------------------------------------------------------------------------
burstcount = 8
data_size = 16
clock = "10 ns"

# environment preparation --------------------------------------------------------------------------------------------------------------
subprocess.run( "rm -r " + log_file, shell=True )
subprocess.run( "rm " + output_file, shell=True )
subprocess.run( "rm " + input_file, shell=True )

# log file opening ---------------------------------------------------------------------------------------------------------------------
try:
    log = open( log_file, "w" )
except OSError:
    print( "An error has been encontered while creating the log file, the simulation has been shut down" )
    raise

# information printing -----------------------------------------------------------------------------------------------------------------
print( "--------------------------------------------------------------------------------------------------------------" )
print( "INFO" )
print( "VSIM path:", vsim_path )
print( "Project:",  simulation_project)
print( "Clock period:", clock )
print( "Burst lenght:", burstcount )
print( "--------------------------------------------------------------------------------------------------------------" )

# information writing (log file) -------------------------------------------------------------------------------------------------------
log.write( "--------------------------------------------------------------------------------------------------------------" )
log.write( "\n" )
log.write( "INFO" )
log.write( "\n" )
log.write( "VSIM path: " )
log.write( vsim_path )
log.write( "\n" )
log.write( "Project: ")
log.write( simulation_project )
log.write( "\n" )
log.write( "Clock period: ")
log.write( clock )
log.write( "\n" )
log.write( "Burst lenght: ")
log.write( str( burstcount ) )
log.write( "\n" )
log.write( "--------------------------------------------------------------------------------------------------------------" )
log.write( "\n" )

# stimuli generation ------------------------------------------------------------------------------------------------------------------
# at first, all memory locations are written with a random writedata
# later, the value of each memory location is read
try:
    stimuli = open( input_file, "w" )
    for burst_idx in range( 0, burstcount ):
        data = format( random.randint( 0,  2 ** data_size ), str( data_size ) + 'b' ).replace(" ", "0")
        stimuli.write( data )
        stimuli.write( "\n" )
except OSError:
    print( "Error: files creation failed" )
    log.write( "Error: files creation failed" )
    raise
else:
    stimuli.close()

# simulation ---------------------------------------------------------------------------------------------------------------------------
print( "Start simulation..." )
log.write( "Start simulation... \n" )
cmd = vsim_path + " -c -do " + simulation_file + " > " + log_file
subprocess.run( cmd, shell=True )
print ("Simulation completed")
log.write( "Simulation completed \n" )

# verification -------------------------------------------------------------------------------------------------------------------------
cmd = "diff " + input_file + " " + output_file + " -y --suppress-common-lines -N | wc -l"
verification_process = subprocess.run( cmd, shell = True, capture_output = True )
diff = verification_process.stdout.decode( "utf-8" ).replace("\n", "")
if ( diff == '0' ):
    print( "DUT is working correctly" )
    print( "Verification result: PASSED" )
    log.write( "DUT is working correctly \n" )
    log.write( "Verification result: PASSED \n" )
else:
    print( "DUT is not working as expected" )
    print( diff, "errors detected" )
    print( "Verification result: FAILED" )
    log.write( "DUT is not working as expected \n" )
    log.write( diff )
    log.write( " errors detected \n" )
    log.write( "Verification result: FAILED \n" )

log.close()
subprocess.run( "rm -r transcript work/", shell=True )
