'''
kqfcop structure parsing.
'''
import logging
import struct

from collections import OrderedDict
from pprint import pformat

import xinfo.cache as cache
import xinfo.binutils as binutils
import xinfo.config.settings as settings

LOGGER = logging.getLogger(__name__)

KQFCOP_TYP_OFFSET_MAP = {
    7: 1,
    8: 2,
    11: 1,
    19: 1,
    20: 3,
    33: 3,
    43: 3,
}

def _get_kqfcop_from_binary():
    kqfcop = binutils.objdump_symbol('kqfcop')

    kqfcop_map = OrderedDict()

    for i, (func_ptr,) in enumerate(struct.iter_unpack('l', kqfcop), 1):
        kqfcop_map[i] = {'func_ptr': func_ptr}

    ptr_list = [v2 for v1 in kqfcop_map.values()
                   for v2 in v1.values() if v2 > 0]
    symbols = binutils.get_symbols(ptr_list)

    for v in kqfcop_map.values():
        func_ptr = v['func_ptr']
        if func_ptr > 0:
            v['func'] = symbols[func_ptr]
    LOGGER.debug(pformat(kqfcop_map))

    return kqfcop_map

def _get_kqfcop():
    kqfcop_map = cache.lazy_load('kqfcop.data',
                                 settings.force,
                                 _get_kqfcop_from_binary)
    LOGGER.debug(pformat(kqfcop_map))
    return kqfcop_map

def get_func(indx, typ):
    '''
    Get a function from kqfcop.
    '''
    if not typ in KQFCOP_TYP_OFFSET_MAP:
        raise ValueError('Unhandled kqfcop typ = %d' % typ)

    offset = KQFCOP_TYP_OFFSET_MAP[typ]
    kqfcop_map = _get_kqfcop()
    func = kqfcop_map[offset + indx*3]['func']

    return func
