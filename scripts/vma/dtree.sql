-------------------------------------------------------------------------------
--
-- Script:      dtree.sql (Dependency TREE)
-- Purpose:     Show objects recursively dependent on given object.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @dtree <owner> <name> [indent=<indent>,sqltext=<sqltext>,sql=<true/false>]
--              indent  - indentation (default=3)
--              sql     - show dependant cursor or no (default=show)
--              sqltext - sql text length in output (default=no restriction)
--
-- Examples:
--              @dtree SYS DBMS_RANDOM                          - objects dependent on sys.dbms_random
--              @dtree SYS DBMS_RANDOM indent=2                 - with indentation 2
--              @dtree SYS DBMS_RANDOM sqltext=50               - truncate sql text to 50 bytes
--              @dtree SYS DBMS_RANDOM sql=false                - without cursors
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/04/25 13:50
--                Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set timi off term off

def d_owner="&1."
def d_name="&2."

col 3 new_v 3

select '' "3" from dual where null^=null;

def eva_input="&3."

sho term
select 'before' from dual;
@eva "&eva_input." indent sqltext sql
sho term
select 'after' from dual;

set term off

col d_indent  new_v  indent
col d_sql     new_v sqln
col d_sqltext new_v sqltext

select nvl2('&indent.', '&indent.', 3) d_indent,
       decode(lower('&sql.'), 'false', 0, 1) d_sql,
       nvl2('&sqltext.', '&sqltext.', 2000) d_sqltext
  from dual;

col d_output for a250 tru hea "DEPENDENCIES (owner=&d_owner. name=&d_name. indent=&indent. sql=&sql. sqltext=&sqltext.)"

set term on

with dep as (
  select object_id, referenced_object_id, level nest_level, rownum seq#
    from public_dependency
    connect by prior object_id = referenced_object_id
   start with referenced_object_id in (select object_id from dba_objects where owner='&d_owner.' and object_name='&d_name.')
   union all 
  select object_id, 0, 0, 0 from dba_objects where owner='&d_owner.' and object_name='&d_name.')
select lpad(' ', &indent.*nest_level, ' ')||
       object_type||' '||
       owner||
       decode(object_type, 'CURSOR', '', '.')||
       substr(object_name, 1, &sqltext.) 
         d_output
  from (
       select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
         from dep d, dba_objects o
        where d.object_id = o.object_id (+)
        union all
       select distinct d.nest_level+1, 'CURSOR', c.kglobt03||' ', c.kglnaobj, d.seq#+.5
         from dep d, 
              x$kgldp k, 
              x$kglob g, 
              sys.obj$ o, 
              sys.user$ u, 
              x$kglob c,
              x$kglxs a
        where d.object_id = o.obj#
          and o.name = g.kglnaobj
          and o.owner# = u.user#
          and u.name = g.kglnaown
          and g.kglhdadr = k.kglrfhdl
          and k.kglhdadr = a.kglhdadr   /* make sure it is not a transitive */
          and k.kgldepno = a.kglxsdep   /* reference, but a direct one */
          and k.kglhdadr = c.kglhdadr
          and c.kglhdnsp = 0 -- namespace='SQL AREA'
          and &sqln. = 1 -- show cursor
 ) 
 order by seq#, nest_level    ;

col d_indent  cle
col d_sql     cle
col d_sqltext cle
col d_output  cle

undef indent
undef sqln
undef sqltext
undef eva_input

undef 2 1

@restore_sqlplus_settings
