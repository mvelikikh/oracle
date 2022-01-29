'''
Describe columns of an X$ table.
'''
import logging
import struct

from collections import OrderedDict

import xinfo.binutils as binutils
import xinfo.cache as cache
import xinfo.x.kqfcop as kqfcop
import xinfo.config.settings as settings

LOGGER = logging.getLogger(__name__)

NAM_MAX_LENGTH = 33

def _parse_xdesc(xdesc):
    '''
    Return a parsed X$ structure for the given binary struct.
    '''
    x_col_map = OrderedDict()

    for i, (_, nam_ptr, dty, typ, idx, ipo, max_, _, _, _, lsz, _, _, _, lof,
            siz, off, _, _, kqfcop_indx) in\
            enumerate(struct.iter_unpack('ql12B2qH2Bl', xdesc), 1):
        nam = binutils.get_str_from_addr(nam_ptr, NAM_MAX_LENGTH)
        x_col_map[i] = OrderedDict({'cno': i,
                                    'nam_ptr': nam_ptr,
                                    'nam': nam,
                                    'siz': siz,
                                    'dty': dty,
                                    'typ': typ,
                                    'max': max_,
                                    'lsz': lsz,
                                    'lof': lof,
                                    'off': off,
                                    'idx': idx,
                                    'ipo': ipo,
                                    'kqfcop_indx': kqfcop_indx,
                                   })
        if kqfcop_indx > 0:
            func = kqfcop.get_func(kqfcop_indx, typ)
            x_col_map[i].update({'func': func})
        LOGGER.debug((f'%3d 0x%x %-{NAM_MAX_LENGTH}s %3d %3d %3d %3d %3d %5d'
                      ' %5d %3d %3d %3d'),
                     i, nam_ptr, nam, dty, typ, max_, lsz, lof, siz, off, idx,
                     ipo, kqfcop_indx
                     )
    return x_col_map

def get_xstruct(xstruct):
    '''
    Get a parsed X$ structure from the Oracle binary.
    '''
    LOGGER.debug('Loading xstruct=%s', xstruct)

    addr, len_ = binutils.get_addr_len(xstruct)
    LOGGER.debug('addr=0x%x len=%s', addr, len_)

    if len_ <= 64:
        raise ValueError('Unexpected length = %d. Should be more than 64.' %
                         len_
                         )

    if len_ % 64 != 0:
        raise ValueError('Unexpected length = %d. Should be multiple of 64.' %
                         len_
                         )

    xdesc = binutils.objdump(addr, len_ - 64)

    x_col_map = _parse_xdesc(xdesc)

    return x_col_map
