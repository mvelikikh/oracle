--
-- ASH wait tree for Waits Event or SQL_ID
-- Usage: SQL> @ash_wait_tree.sql "event = 'log file sync'"
-- Igor Usoltsev
-- http://iusoltsev.wordpress.com
--
@save_sqlplus_settings 
set echo off feedback off heading on timi off pages 1000 lines 500 VERIFY OFF
 
col WAIT_LEVEL for 999
col BLOCKING_TREE for a30
col EVENT for a64
col WAITS for 999999
col AVG_TIME_WAITED_MS for 999999
 
select LEVEL as WAIT_LEVEL,
       LPAD(' ',(LEVEL-1)*2)||decode(ash.session_type,'BACKGROUND',REGEXP_SUBSTR(program, '\([^\)]+\)'),'FOREGROUND') as BLOCKING_TREE,
       ash.EVENT,
       count(*) as WAITS_COUNT,
       round(avg(time_waited) / 1000) as AVG_TIME_WAITED_MS
  from gv$active_session_history ash
 where session_state = 'WAITING'
 start with &&1 --event = nvl('&&1',event) and sql_id = nvl('&&2',sql_id)
connect by nocycle
 prior ash.SAMPLE_ID = ash.SAMPLE_ID
       and ash.SESSION_ID = prior ash.BLOCKING_SESSION
 group by LEVEL,
          LPAD(' ',(LEVEL-1)*2)||decode(ash.session_type,'BACKGROUND',REGEXP_SUBSTR(program, '\([^\)]+\)'),'FOREGROUND'),
          ash.EVENT
 order by LEVEL, count(*) desc
/
set feedback on echo off VERIFY ON

@restore_sqlplus_settings