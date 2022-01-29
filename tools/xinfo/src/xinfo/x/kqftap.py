'''
kqftap structure parsing.
'''
import logging
import struct

from collections import OrderedDict
from pprint import pformat

import xinfo.cache as cache
import xinfo.binutils as binutils
import xinfo.config.settings as settings

LOGGER = logging.getLogger(__name__)

def _get_kqftap_from_binary():
    kqftap = binutils.objdump_symbol('kqftap')

    kqftap_map = OrderedDict()

    fmt = '4L'
    offset = struct.calcsize(fmt)

    for i, (_, xstruct_ptr, cb1_ptr, cb2_ptr) in\
            enumerate(struct.iter_unpack(fmt, kqftap[:-offset]), 1):
        v = OrderedDict({'xstruct_ptr': xstruct_ptr})
        if cb1_ptr:
            v['cb1_ptr'] = cb1_ptr
        if cb2_ptr:
            v['cb2_ptr'] = cb2_ptr
        kqftap_map[i] = v

    ptr_list = [v2 for v1 in kqftap_map.values() \
                   for v2 in v1.values() if v2 > 0]
    symbols = binutils.get_symbols(ptr_list)

    for v in kqftap_map.values():
        for ptr in v.copy():
            if ptr.endswith('_ptr'):
                deref = ptr[:-len('_ptr')]
                v[deref] = symbols[v[ptr]]

    return kqftap_map


def get_kqftap():
    '''
    Return kqftap structure.
    '''
    kqftap_map = cache.lazy_load('kqftap.data',
                                 settings.force,
                                 _get_kqftap_from_binary)
    LOGGER.debug(pformat(kqftap_map))
    return kqftap_map
