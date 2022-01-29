'''
kqftab structure parsing.
'''
import logging
import struct

from collections import OrderedDict
from pprint import pformat

import xinfo.cache as cache
import xinfo.binutils as binutils
import xinfo.config.settings as settings

LOGGER = logging.getLogger(__name__)

def _get_kqftab_from_binary():
    kqftab = binutils.objdump_symbol('kqftab')

    kqftab_map = OrderedDict()

    fmt = '4L2H1I2L4I1L'
    offset = struct.calcsize(fmt)

    for i, (_, nam_ptr, _, xstruct_nam_ptr, typ, flg, _, rsz, _, coc, _, obj,
            ver, _) in enumerate(struct.iter_unpack(fmt, kqftab[:-offset]), 1):
        LOGGER.debug('%x ' * 8, nam_ptr, xstruct_nam_ptr, typ, flg, rsz, coc,
                     obj, ver)
        kqftab_map[i] = OrderedDict({'obj': obj,
                                     'ver': ver,
                                     'nam_ptr': nam_ptr,
                                     'nam': binutils.get_str_from_addr(nam_ptr, 30),
                                     'xstruct_nam_ptr': xstruct_nam_ptr,
                                     'xstruct': binutils.get_str_from_addr(xstruct_nam_ptr, 30),
                                     'typ': typ,
                                     'flg': flg,
                                     'rsz': rsz,
                                     'coc': coc,
                                    })
    return kqftab_map

def get_kqftab():
    '''
    Return kqftab structure.
    '''
    kqftab_map = cache.lazy_load('kqftab.data',
                                 settings.force,
                                 _get_kqftab_from_binary)
    LOGGER.debug(pformat(kqftab_map))
    return kqftab_map

def get_index(table):
    '''
    Get an X$ table index for a given table name.
    '''
    kqftab_map = get_kqftab()
    for k, v in kqftab_map.items():
        if v['nam'] == table:
            return k
    raise ValueError('Table %s not found' % table)
