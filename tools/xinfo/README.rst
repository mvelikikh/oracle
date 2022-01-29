xinfo
=====

Command line utility to display X$ table meta-information from the Oracle binary.

Installation
============

Download the directory xinfo and install using pip::

    $ python3 -m pip install xinfo

Usage
=====

::

    xinfo [-h] [--version] [command] ...

    Command line utility to display X$ table meta-information

    optional arguments:
      -h, --help  show this help message and exit
      --version   show program's version number and exit

    subcommands:
      Available commands

      [command]
        desc      Describe X$ tables
        list      List X$ tables

Commands are the following:

list
----

Show meta-information for X$ tables from kqftab. The information is similar to X$KQFTA.

::

    usage: xinfo list [-h] [-b ORA_BINARY] [-f] [-v | -q] [-o {table,json,html}]
                      [--with-kqftap]
                      [expr]
    
    List X$ tables
    
    positional arguments:
      expr                  An expression for X$ tables to list, e.g. 'X$KSU*'.
                            Returns all tables if not specified
    
    optional arguments:
      -h, --help            show this help message and exit
      -b ORA_BINARY, --ora-binary ORA_BINARY
                            Specify the path to Oracle binary. The program will
                            look for $ORACLE_HOME/bin/oracle if no binary is
                            specified
      -f, --force           Set to true to refresh the local cache
      -v, --verbose         Enable verbose output
      -q, --quiet           Enable silent mode (only show warnings and errors)
      -o {table,json,html}, --output {table,json,html}
                            The formatting style for command output
      --with-kqftap         Include kqftap structure in output

**Examples**:

List all X$ tables::

    $ xinfo list
    +------------+-----+------------+-------------------------------+-----------------+---------------------------+-----+------+--------+-----+
    |        obj | ver |    nam_ptr | nam                           | xstruct_nam_ptr | xstruct                   | typ |  flg |    rsz | coc |
    +------------+-----+------------+-------------------------------+-----------------+---------------------------+-----+------+--------+-----+
    | 4294950912 |   6 | 0x16282d00 | X$KQFTA                       |      0x16e33810 | kqftv                     |   4 |    0 |     80 |  11 |
    ..skipped..
    | 4294956225 |   2 | 0x16e3a870 | X$FSDDBFS                     |      0x16e3a87c | fsddbfs                   |   4 |    0 |   1144 |  14 |
    +------------+-----+------------+-------------------------------+-----------------+---------------------------+-----+------+--------+-----+

List 'X$KCCC*' X$ tables and display output as JSON::

    xinfo list 'X$KCCC*' -o json
    {
      "340": {
        "obj": 4294951110,
        "ver": 5,
        "nam_ptr": 383997244,
        "nam": "X$KCCCF",
        "xstruct_nam_ptr": 383997252,
        "xstruct": "kcccf",
        "typ": 4,
        "flg": 0,
        "rsz": 532,
        "coc": 9
      },
      "364": {
        "obj": 4294951215,
        "ver": 4,
        "nam_ptr": 383997564,
        "nam": "X$KCCCC",
        "xstruct_nam_ptr": 383997572,
        "xstruct": "kcccc",
        "typ": 5,
        "flg": 6,
        "rsz": 48,
        "coc": 14
      },
      "457": {
        "obj": 4294951392,
        "ver": 5,
        "nam_ptr": 383999376,
        "nam": "X$KCCCP",
        "xstruct_nam_ptr": 383999384,
        "xstruct": "kctcpx",
        "typ": 5,
        "flg": 0,
        "rsz": 552,
        "coc": 25
      }
    }


desc
----

Describe a given table. The information is similar to X$KQFCO::

    usage: xinfo desc [-h] [-b ORA_BINARY] [-f] [-v | -q] [-o {table,json,html}]
                      table
    
    Describe X$ tables
    
    positional arguments:
      table                 An X$ table to describe
    
    optional arguments:
      -h, --help            show this help message and exit
      -b ORA_BINARY, --ora-binary ORA_BINARY
                            Specify the path to Oracle binary. The program will
                            look for $ORACLE_HOME/bin/oracle if no binary is
                            specified
      -f, --force           Set to true to refresh the local cache
      -v, --verbose         Enable verbose output
      -q, --quiet           Enable silent mode (only show warnings and errors)
      -o {table,json,html}, --output {table,json,html}
                            The formatting style for command output

**Examples**:

Describe X$KSLLW::

    $ xinfo desc 'X$KSLLW'
    +-----+------------+----------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-------------+--------------------------+
    | cno |    nam_ptr | nam      | siz | dty | typ | max | lsz | lof | off | idx | ipo | kqfcop_indx | func                     |
    +-----+------------+----------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-------------+--------------------------+
    |   1 | 0x16e6959c | ADDR     |   8 |  23 |   9 |   0 |   0 |   0 |   0 |   1 |   0 |           0 |                          |
    |   2 | 0x15d7d660 | INDX     |   4 |   2 |  11 |   0 |   0 |   0 |   0 |   2 |   0 |           0 |                          |
    |   3 | 0x160f96b0 | INST_ID  |   4 |   2 |  11 |   0 |   0 |   0 |   0 |   0 |   0 |           0 |                          |
    |   4 | 0x16e78d5c | CON_ID   |   2 |   2 |  11 |   0 |   0 |   0 |   0 |   0 |   0 |           0 |                          |
    |   5 | 0x16e8b5b0 | KSLLWNAM |  80 |   1 |   7 |   0 |   0 |   0 |   0 |   0 |   0 |           4 | ksl_sanitize_latch_where |
    |   6 | 0x16e8b5bc | KSLLWLBL |  64 |   1 |   6 |   0 |   0 |   0 |   8 |   0 |   0 |           0 |                          |
    +-----+------------+----------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-------------+--------------------------+


Usage notes
===========

1. The first execution can take about 1 minute as the program parses several structures. Subsequent executions will use cache files in `tempfile.gettempdir()` (`/tmp` by default).

Prerequisites
=============
- Linux only
- Python 3
- Requires the binutils package since it calls objdump, nm, readelf under the hood
- Tested with: 19c (19.13), 21c (21.5)
