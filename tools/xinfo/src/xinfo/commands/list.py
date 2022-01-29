'''
List X$ tables.
'''
import fnmatch
import logging

from collections import OrderedDict

import xinfo.x.kqftab as kqftab
import xinfo.x.kqftap as kqftap

from xinfo.formatter import get_formatter

LOGGER = logging.getLogger(__name__)

def _add_list_args(p):
    '''
    argparse arguments.
    '''
    p.add_argument('expr', nargs='?',
                   help='An expression for X$ tables to list, e.g. \'X$KSU*\'. Returns all tables if not specified')
    p.add_argument('--with-kqftap', action='store_true',
                   help='Include kqftap structure in output')

def list_tables(args):
    '''
    List X$ tables.
    '''
    LOGGER.debug(args)

    kqftab_map = kqftab.get_kqftab()

    if args.expr:
        kqftab_map = OrderedDict((k, v) for k, v in kqftab_map.items()
                                 if fnmatch.filter([v['nam']], args.expr))

    if args.with_kqftap:
        kqftap_map = kqftap.get_kqftap()
        for k, v in kqftab_map.items():
            v['kqftap'] = kqftap_map[k]

    formatter = get_formatter(args.output)
    output = formatter('desc', kqftab_map)
    print(output)

def get_cmd_args():
    '''
    argparse setup.
    '''
    return  ('list', (list_tables, _add_list_args, 'List X$ tables'))
