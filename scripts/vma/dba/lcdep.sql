-------------------------------------------------------------------------------
--
-- Script:	lcdep.sql
-- Purpose:	Display library cache dependencies between objects
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about library cache dependencies
--
-- Usage:       @lcdep.sql "{<sql_id>|sql_id=<sql_id>|kglnaobj=<kglnaobj>|kglnaown=<kglnaown>}"
--
-- Change history:
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 2013/09/09 14:12
--     Desc: rewrited to eva usage
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/04/17 09:11
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--lcdep.sql
-------------
--
--Library cache dependencies.
--
--lcdep.sql 
--  {
--    [<sql_id>] |
--    [sql_id=<sql_id>] |
--    [,kglnaobj=<kglnaobj>] |
--    [,kglnaown=<kglnaown>] |
--  }
--DOCEND

@save_sqlplus_settings.sql

set timing off

def input="&1."

@eva &input. sql_id kglnaobj kglnaown

@evadef &input. sql_id

set term off

col if_sql_id new_v if_sql_id nopri
col if_kglnaobj new_v if_kglnaobj nopri
col if_kglnaown new_v if_kglnaown nopri

select nvl2('&sql_id.', '', '--') if_sql_id,
       nvl2('&kglnaobj.', '', '--') if_kglnaobj,
       nvl2('&kglnaown.', '', '--') if_kglnaown
  from dual
/

set term on

col stored_object for a60

select distinct
         obj.kglnaown || '.' || obj.kglnaobj stored_object, 
         csr.kglobt03
  from x$kglob obj, 
       x$kglrd dep, 
       x$kglcursor csr
 where obj.inst_id = sys_context( 'userenv', 'instance')
   and dep.inst_id = sys_context( 'userenv', 'instance')
   and csr.inst_id = sys_context( 'userenv', 'instance')
   and obj.kglobtyp in (7, 8, 9, 11, 12)
   and dep.kglhdcdr = obj.kglhdadr
   and csr.kglhdpar = dep.kglrdhdl
   &if_sql_id. and csr.kglobt03 = '&sql_id.'
   &if_kglnaobj and obj.kglnaobj = '&kglnaobj.'
   &if_kglnaown and obj.kglnaown = '&kglnaown.'
/

undef input
undef if_sql_id
undef sql_id
undef if_kglnaobj
undef kglnaobj
undef if_kglnaown
undef kglnaown

col if_sql_id cle
col if_kglnaobj cle
col if_kglnaown cle
col stored_object cle

@restore_sqlplus_settings.sql
