'''
Collection of binary utilities similar to Linux binutils RPM.
'''
import logging
import os
import subprocess
import tempfile

import xinfo.config.settings as settings

LOGGER = logging.getLogger(__name__)

def get_addr_len(symbol):
    '''
    Return address and length of the given symbol.
    '''
    _cmd = '''
readelf -s %(ora_binary)s |
grep -w %(symbol)s |
head -1 |
awk '{print $2, $3}'
'''
    _cmd = _cmd % dict(ora_binary=settings.ora_binary, symbol=symbol)
    LOGGER.debug(_cmd)

    output = subprocess.getoutput(_cmd)
    LOGGER.debug('step1')
    LOGGER.debug(output)
    LOGGER.debug('step2')

    if not output:
        raise ValueError('%s symbol not found' % (symbol))

    #return (int(output.split()[0], 16), int(output.split()[1]))
    return (int(output.split()[0], 16), int(output.split()[1], 0))

def objdump(start_addr, len_):
    '''
    Return a byte-array from the Oracle binary for the given parameters.
    '''
    _cmd = '''
objdump -s --start-address=%(start_addr)d --stop-address=%(stop_addr)d %(ora_binary)s |
awk '/Contents/{m=1;next;} m {OFS=""; print substr($0, 1+length($1)+2, 8),substr($0, 1+length($1)+11, 8), substr($0, 1+length($1)+20, 8), substr($0, 1+length($1)+29, 8);}' |
sed 's/\.//g'
'''
    _cmd = _cmd % dict(ora_binary=settings.ora_binary,
                       start_addr=start_addr,
                       stop_addr=start_addr + len_
                       )
    LOGGER.debug(_cmd)

    output = subprocess.getoutput(_cmd)
    LOGGER.debug(output)

    dump = bytearray()

    for line in output.split('\n'):
        dump.extend(bytes.fromhex(line))

    return dump

def get_str_from_addr(addr, max_len):
    '''
    Get a string for the address.
    '''
    dump = objdump(addr, max_len)
    nam = dump[:dump.index(b'\x00')].decode('utf-8')
    return nam

def objdump_symbol(symbol):
    '''
    Call objdump for a given symbol.
    '''
    return objdump(*get_addr_len(symbol))

def get_symbols(addr_list):
    '''
    Get symbols for a list of addresses.
    '''
    with tempfile.NamedTemporaryFile(mode='w') as fp:
        LOGGER.debug(fp.name)
        for addr in addr_list:
            print(format(addr, 'x'), file=fp)
        fp.flush()

        _cmd = 'nm %(ora_binary)s | grep -f %(file_name)s' % \
                   dict(ora_binary=settings.ora_binary,
                        file_name=fp.name)
        output = subprocess.getoutput(_cmd)

        symbols = dict()
        for line in output.split('\n'):
            LOGGER.debug(line)
            addr, _, symbol = line.split()
            func_ptr = int.from_bytes(bytes.fromhex(addr), byteorder='big')
            symbols[func_ptr] = symbol

    return symbols
