-------------------------------------------------------------------------------
--
-- Script:	rsmrpt.sql
-- Purpose:	Display real time sql monitoring report for given parameters
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	Real Time SQL Monitoring report
--
-- Usage:       @rsmrpt.sql {<sql_id>|sql_id=<sql_id>|session_id=<session_id>|sql_exec_id=<sql_exec_id>}
--
-- Change history:
--   Vers:   1.0.4.4
--     Auth: Velikikh M.
--     Date: 2014/04/23 08:33
--     Desc: sql_exec_id added
--   Vers:   1.0.3.3
--     Auth: Velikikh M.
--     Date: 2013/07/24 11:49
--     Desc: rewrited to eva usage
--   Vers:   1.0.2.2
--     Auth: Velikikh M.
--     Date: 2013/07/08 09:03
--     Desc: renamed to rsmrpt.sql
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 2013/05/06 15:22
--     Desc: session_id processing added "{<sql_id>|sql_id=<sql_id>|session_id=<session_id>}"
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/04/25 15:31
--     Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

def input="&1."

@eva &input. sql_id sql_exec_id session_id
@evadef &input. sql_id

col if_sql_id new_v if_sql_id nopri
col if_sql_exec_id new_v if_sql_exec_id nopri
col if_session_id new_v if_session_id nopri

select nvl2('&sql_id.', '', '--') if_sql_id,
       nvl2('&sql_exec_id.', '', '--') if_sql_exec_id,
       nvl2('&session_id.', '', '--') if_session_id
  from dual
/

set term on

select dbms_sqltune.report_sql_monitor(
         type => 'TEXT'
         &if_sql_id.     ,sql_id => '&sql_id.'
         &if_sql_exec_id.     ,sql_exec_id => '&sql_exec_id.'
         &if_session_id. ,session_id => '&session_id.'
       ) "SQL Monitoring Report"
  from dual
/

undef if_session_id
undef session_id
undef if_sql_id
undef sql_id
undef if_sql_exec_id
undef sql_exec_id
undef input

col if_sql_id cle
col if_sql_exec_id cle
col if_session_id cle

@restore_sqlplus_settings.sql
