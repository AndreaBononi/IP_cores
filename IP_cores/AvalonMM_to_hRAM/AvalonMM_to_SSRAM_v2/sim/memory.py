#!/usr/bin/env python


# MEMORY CLASS
#
# CONFIGURABLE DIMENSION
# after configuring the address size and the word size, the memory dimension is automatically set
#
# OPTIONAL REGISTERS
# it is possible to add some registers to the internal memory
# each register must be assigned to an address, which may be equal to the address of a memory location (the addressing space is not shared)
# the register size is equal to the word size of the memory
# the register address size is equal to the memory address size
#
# ERROR HANDLING
# when an error occours, a specific exception is raised depending on the type of error
# verify the exceptions that can be raised by a certain function reading the function description
#
# LIST OF METHODS
# __init__( self, address_size = 32, word_size = 16 )
# reset( self )
# write( self, address, writedata )
# read( self, address )
# add_register( self, address, value )
# write_register( self, address, value )
# read_register( self, address )
# check_register( self, address )
# get_all_register_addresses( self )
# get_address_size( self )
# get_word_size( self )
# get_memory_size( self )


if( __name__ == '__main__' ):
    print( 'this script is not supposed to be executed directly' )
    print( 'it is a class defining a memory' )
else:

    class memory:

        # PRIVATE ATTRIBUTES ----------------------------------------------------------------------------------------------------------------------------
        __mem = {}
        __registers = {}
        __lenghts = [8, 16, 32, 64]
        __reset = False
        __address_size = 0
        __word_size = 0
        __memory_size = 0

        # CONSTRUCTOR -----------------------------------------------------------------------------------------------------------------------------------
        # "address_size" is the address lenght expressed as number of bits
        # "word_size" is the word lenght expressed as number of bits
        # only standard lenghts are available (8, 16, 32, 64)
        # if address_size and/or word_size cannot be converted in integer numbers, AttributeError is raised
        def __init__( self, address_size = 32, word_size = 16 ):
            try:
                if ( int( address_size ) in self.__lenghts and int( word_size ) in self.__lenghts ):
                    self.__address_size = int( address_size )
                    self.__word_size = int( word_size )
                    self.__memory_size = ( 2 ** ( int( address_size ) ) ) * ( int( word_size ) )
            except:
                raise AttributeError

        # MEMORY RESET ---------------------------------------------------------------------------------------------------------------------------------
        # all locations are cleared to zero
        def reset( self ):
            self.__mem.clear()
            self.__reset = True

        # MEMORY WRITING -------------------------------------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # "writedata" must be provided as a binary string and it should be coherent with "word_size"
        # if "address" and/or "writedata" are not valid, AttributeError is raised
        def write( self, address, writedata ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ) and int( writedata, 2 ) < 2**( self.__word_size ):
                    self.__mem[address] = writedata
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # MEMORY READING ------------------------------------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # if the memory location contains a valid data, that data is returned
        # if the memory location has never been written or cleared, "U" is returned (undefined value)
        # if "address" and/or "writedata" are not valid, AttributeError is raised
        def read( self, address ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ):
                    if address in self.__mem:
                        return self.__mem[address]
                    else:
                        if self.__reset == True:
                            retval = ""
                            for idx in range( 0, self.__word_size ):
                                retval = retval + "0"
                            return retval
                        else:
                            return "U"
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # REGISTER CREATION ----------------------------------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # "value" must be provided as a binary string and it should be coherent with "word_size"
        # if "address" and/or "value" are not valid, AttributeError is raised
        # if "address" has already been used with another register, ValueError is raised
        # use the "check_register" method or the "get_all_register_addresses" method to verify if a certain address has already been used
        def add_register( self, address, value ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ) and int( value, 2 ) < 2**( self.__word_size ):
                    if address in self.__registers:
                        raise ValueError
                    else:
                        self.__registers[address] = value
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # WRITE REGISTER -------------------------------------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # "value" must be provided as a binary string and it should be coherent with "word_size"
        # if "address" and/or "value" are not expressed in a valid format, AttributeError is raised
        # if "address" is not related to any existing register, ValueError is raised
        def write_register( self, address, value ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ) and int( value, 2 ) < 2**( self.__word_size ):
                    if address in self.__registers:
                        self.__registers[address] = value
                    else:
                        raise ValueError
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # READ REGISTER -------------------------------------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # if no errors are detected, the register value is returned
        # if "address" is not expressed in a valid format, AttributeError is raised
        # if "address" is not related to any existing register, ValueError is raised
        def read_register( self, address ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ):
                    if address in self.__registers:
                        return self.__registers[address]
                    else:
                        raise ValueError
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # VERIFY IF A CERTAIN REGISTER ALREADY EXISTS ------------------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_size"
        # if a register identified by "address" already exists, True is returned (False otherwise)
        # if "address" is not expressed in a valid format, AttributeError is raised
        def check_register( self, address ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ):
                    if address in self.__registers:
                        return True
                    else:
                        return False
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # GET THE ADDRESSES OF ALL THE EXISTING registers --------------------------------------------------------------------------------------------
        # a list of all the addresses related to the existing registers is returned
        # if no registers has been created, an emtpy list is returned
        def get_all_register_addresses( self ):
            return list( self.__registers )

        # GET ADDRESS SIZE ---------------------------------------------------------------------------------------------------------------------------
        def get_address_size( self ):
            return self.__address_size

        # GET WORD SIZE ------------------------------------------------------------------------------------------------------------------------------
        def get_word_size( self ):
            return self.__word_size

        # GET MEMORY SIZE ----------------------------------------------------------------------------------------------------------------------------
        def get_memory_size( self ):
            return self.__memory_size
