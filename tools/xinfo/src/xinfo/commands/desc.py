'''
Describe X$ tables.
'''
import logging

import xinfo.x.kqftab as kqftab
import xinfo.x.kqftap as kqftap
import xinfo.x.columns as xcolumns

from xinfo.formatter import get_formatter

LOGGER = logging.getLogger(__name__)

def _add_desc_args(p):
    '''
    argparse arguments.
    '''
    p.add_argument('table', help='An X$ table to describe')

def describe_table(args):
    '''
    Describe an X$ table.
    '''
    LOGGER.debug(args)

    indx = kqftab.get_index(args.table)
    kqftap_map = kqftap.get_kqftap()
    xstruct = kqftap_map[indx]['xstruct']
    LOGGER.debug(xstruct)

    xdesc = xcolumns.get_xstruct(xstruct)
    LOGGER.debug(xdesc)

    formatter = get_formatter(args.output)
    output = formatter('desc', xdesc)
    print(output)

def get_cmd_args():
    '''
    argparse setup.
    '''
    return  ('desc', (describe_table, _add_desc_args, 'Describe X$ tables'))
