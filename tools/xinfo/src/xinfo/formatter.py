'''
Result formatter.
'''
import json

from collections import OrderedDict
from functools import singledispatch

from prettytable import PrettyTable

@singledispatch
def fmt(value, key):
    '''
    Format different datatypes.
    '''
    return value

@fmt.register(int)
def _(value, key):
    if key.endswith('_ptr'):
        return hex(value)
    return value

@fmt.register(dict)
def _(value, key):
    return {k:fmt(v, k) for k, v in value.items()}

class Formatter(object):
    def __init__(self, args):
        self._args = args
    def __call__(self, command_name, response):
        return self._format_response(command_name, response)

class JSONFormatter(Formatter):
    def _format_response(self, command_name, response):
        return json.dumps(response, indent=2)

class TableFormatter(Formatter):
    def _format_response(self, command_name, response):
        if isinstance(response, dict):
            return self._build_table_from_dict(command_name, response)
        else:
            raise ValueError('Invalid object type: %s' % type(response))

    def _build_table_from_dict(self, command_name, response):
        t = PrettyTable()
        t.field_names = OrderedDict.fromkeys((k for v in response.values()
                                              for k in v.keys()))
        not_aligned_fields = set(t.field_names)
        for v in response.values():
            if not_aligned_fields:
                for f in not_aligned_fields.copy():
                    if f in v.keys():
                        if isinstance(v[f], (dict, str)):
                            t.align[f] = 'l'
                            not_aligned_fields.remove(f)
                        elif isinstance(v[f], int):
                            t.align[f] = 'r'
                            not_aligned_fields.remove(f)
            r = [fmt(v[f], f) if f in v else '' for f in t.field_names]
            t.add_row(r)

        return t

class HTMLFormatter(TableFormatter):
    def _format_response(self, command_name, response):
        t = TableFormatter._format_response(self, command_name, response)
        return t.get_html_string()

def get_formatter(format_type, *args):
    if format_type == 'table':
        return TableFormatter(args)
    elif format_type == 'json':
        return JSONFormatter(args)
    elif format_type == 'html':
        return HTMLFormatter(args)
    raise ValueError('Unknown output type: %s' % format_type)
