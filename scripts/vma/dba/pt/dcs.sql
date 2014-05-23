-------------------------------------------------------------------------------
--
-- Script:	dcs.sql
-- Purpose:	Launch display_cursor for current session SQL
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) MEGAFON SIBERIA LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about current cursor for session
--
-- Usage:       @dcs.sql SID [FORMAT]
--
-- Change history:
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 13/07/15 09:20
--     Desc: Removed debug output
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 08/10/28 09:05
--     Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings
          
set pages 200 timi off lin 155
whenever sqlerror continue

col 1 new_value 1 noprint
col 2 new_value 2 noprint
select '' "1", '' "2" from dual where null=null;

select nvl('&2.', 'peeked_binds') "2" from dual;

define l_sid="&1."
define l_format="&2."

col p fold_a
set hea off

col sql_id new_value l_sql_id noprint
col sql_child_number new_value l_sql_child_number noprint

select sql_id, sql_child_number from v$session where sid=&l_sid.;

select plan_table_output from table (dbms_xplan.display_cursor('&l_sql_id.', '&l_sql_child_number.', '&l_format.'));

undefine 1
undefine 2

undefine l_sid
undefine l_format

@restore_sqlplus_settings