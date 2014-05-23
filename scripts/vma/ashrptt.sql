-------------------------------------------------------------------------------
--
-- Script:      ashrptt.sql (ASH Report Tree)
-- Purpose:     ASH tree-like report. Useful for identifying blocking sessions.
--              Inspired by ideas of Igor Usoltsev and Tanel Poder.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @ashrptt <start_filter> <params>
--              start_filter                                    - filter for start report
--              where params can be any of the following in any combination:
--              gby=<gby>                                       - group by columns
--              when gby omitted, params interpreted as gby
--
-- Examples:
--              @ashrptt "event='latch free'" event,sql_id      - start with latch free. Group by event, sql_id on output
--              @ashrptt "event='latch free'" gby=module        - start with latch free. Group by module
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/05/23 15:16
--                Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

col 2 new_v 2 nopri

select '' "2" from dual where null^=null;

def filter="&1."
def input="&2."

@eva "&input." gby

@evadef "&input." gby

set term off

col if_filter new_v if_filter nopri
col if_gby_lst new_v if_gby_lst nopri

select nvl2(q'[&filter.]', q'[&filter.]', 'sample_time between systimestamp-interval ''15'' minute and systimestamp') if_filter,
       nvl2(q'[&gby.]', q'[&gby.]', '--') if_gby_lst
  from dual
/

set term on
set echo off
set ver off

col wait_level for 999 hea LVL
col blocking_tree for a40 hea BLOCKING_TREE
col samples for 99999
col avg_wait for 99999
col max_wait for 99999

select LEVEL as WAIT_LEVEL,
       LPAD(' ',(LEVEL-1)*2)||decode(ash.session_type,'BACKGROUND',REGEXP_SUBSTR(program, '\([^\)]+\)'),'FOREGROUND') as BLOCKING_TREE,
       &if_gby_lst.,
       &if_agg.,
       count(*) samples,
       round(avg(time_waited) / 1000) avg_wait,
       round(max(time_waited)/1e3) max_wait
  from gv$active_session_history ash
 --where session_state = 'WAITING'
 start with &if_filter.
connect by nocycle
 prior ash.sample_id = ash.sample_id
       and ash.session_id = prior ash.blocking_session
 group by level,
          LPAD(' ',(LEVEL-1)*2)||decode(ash.session_type,'BACKGROUND',REGEXP_SUBSTR(program, '\([^\)]+\)'),'FOREGROUND'),
          &if_gby_lst.
 order by LEVEL, count(*) desc
/

undef filter
undef if_filter
undef input
undef gby
undef if_gby_lst

col if_filter cle
col if_gby_lst cle

col wait_level cle
col blocking_tree cle
col samples cle
col avg_wait cle
col max_wait cle

@restore_sqlplus_settings.sql
