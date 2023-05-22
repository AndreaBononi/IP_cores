#!/usr/bin/env python

if( __name__ == '__main__' ):
    print( 'this script is not supposed to be executed directly' )
    print( 'it is a class defining a memory' )
else:

    class memory:

        # private attirbutes -----------------------------------------------------------------------------------
        __mem = {}
        __lenghts = [8, 16, 32, 64]
        __reset = False

        # costructor -------------------------------------------------------------------------------------------
        # "address_size" is the address lenght expressed as number of bits
        # "word_size" is the word lenght expressed as number of bits
        # "config_address_binary_size" is the address lenght expressed as number of bits
        # "config_word_binary_size" is the word lenght expressed as number of bits
        # only standard lenghts are available (8, 16, 32, 64)
        def __init__( self, address_size = 32, word_size = 16 ):
            try:
                if ( int( address_binary_size ) in self.__lenghts and int( word_binary_size ) in self.__lenghts ):
                    self.__address_size = int( address_size )
                    self.__word_size = int( word_size )
            except:
                raise AttributeError

        # memory reset -----------------------------------------------------------------------------------------
        # all locations are cleared to zero
        def reset( self ):
            self.__mem.clear()
            self.__reset = True

        # configuration register creation ----------------------------------------------------------------------
        # 
        #
        def add_configuration_register( self, register_address, register_value =   ):





        # memory writing ---------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_binary_size"
        # "writedata" must be provided as a binary string and it should be coherent with "word_binary_size"
        # if "address" is not valid, an AttributeError exception is raised
        # if "writedata" is not valid, an AttributeError exception is raised
        def write( self, address, writedata ):
            try:
                if int( address, 2 ) < 2**( self.__address_size ) and int( writedata, 2 ) < 2**( self.__word_size ):
                    self.__mem[address] = writedata
                else:
                    raise AttributeError
            except:
                raise AttributeError

        # memory reading --------------------------------------------------------------------------------------
        # "address" must be provided as a binary string and it should be coherent with "address_binary_size"
        # if "address" is not valid, an AttributeError exception is raised
        # if the memory location contains a valid data, that data is returned
        # if the memory location has never been written or cleared, "U" is returned (undefined value)
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
