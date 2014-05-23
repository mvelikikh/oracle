-------------------------------------------------------------------------------
--
-- Script:	awrtopnrpt.sql
-- Purpose:	AWR Top-N timed foregrounds event report
--              ixora save/restore_s+ used for saving user environment
--              Alex Fatkulin Ideas a used
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about timed events
--
-- Usage:       @awrtopnrpt.sql "<filter>" "{dbid=<dbid>|
--                instance_number=<instance_number>|
--                top=<top events count>}"
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2014/04/18 13:51
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--sysevpt.sql
------------
--
--AWR Top-N timed foreground events report.
--When not specified, current dbid and instance used.
--
--awrtopnrpt.sql {<filter>}
--  [
--    [,dbid=<dbid>] |
--    [,instance_number=<instance_number>] |
--    [,top=<top events count>]
--  ]
--
--DOCEND

@save_sqlplus_settings.sql

set timing off

col 2 new_v 2 nopri

select '' "2" from dual where null^=null;

def filter="&1."
def input="&2."

@eva "&input." dbid instance_number top

@evadef "&input." top

set term off

col if_filter new_v if_filter nopri
col dbid new_v dbid nopri
col instance_number new_v instance_number nopri
col top new_v top

select nvl2(q'[&filter.]', '', '--') if_filter,
       nvl2('&dbid.', '&dbid.', (select dbid from v$database)) dbid,
       nvl2('&instance_number.', '&instance_number.', sys_context('userenv', 'instance')) instance_number,
       nvl2(q'[&top.]', '&top.', '5') top
  from dual
/

set term on
set echo off
set ver off

col instance_number hea "INST NUM" nopri
col snap_id for 999999 hea "SNAP ID"
col start_of_delta for a20 hea "BEGIN SNAP"
col end_of_delta for a8 hea "END SNAP"
col event_name for a40 hea "EVENT"
col wait_class for a13 hea "WAIT CLASS"
col total_waits for 9g999g999 hea "WAITS"
col time_waited for 999g999 hea "TIME(S)"
col avg_wait for 999g999 hea "AVG WAIT(MS)"
col db_time_pct for 990.99 hea "% DB TIME"

break on snap_id nodup on start_of_delta nodup on end_of_delta nodup skip 1

with snaps as (
  select snap_id,
         dbid,
         instance_number,
         end_interval_time,
         startup_time
    from dba_hist_snapshot
   where 1 = 1
     and dbid = &dbid.
     and instance_number = &instance_number.
     &if_filter. and &filter.
   ),
  stats as
    (
     select dbid, instance_number, snap_id, event_name, wait_class, total_waits_fg total_waits, time_waited_micro_fg time_waited
      from dba_hist_system_event
      where wait_class not in ('Idle', 'System I/O')
     union all
     select dbid, instance_number, snap_id, stat_name event_name, null wait_class, null total_waits, value time_waited
      from dba_hist_sys_time_model
      where stat_name in ('DB CPU', 'DB time')
    ),
  snap_stats as (
    select s1.instance_number,
           s1.snap_id,
           cast(s1.end_interval_time as date) start_of_delta,
           cast(s2.end_interval_time as date) end_of_delta,
           extract(hour from s2.end_interval_time - s1.end_interval_time)*3600+
             extract(minute from s2.end_interval_time - s1.end_interval_time)*60+
             extract(second from s2.end_interval_time - s1.end_interval_time) ela,
           e1.event_name,
           e1.wait_class,
           e2.total_waits - e1.total_waits total_waits,
           round((e2.time_waited - e1.time_waited)/1e6, 2) time_waited,
           round((e2.time_waited-e1.time_waited)/max(e2.time_waited-e1.time_waited) over (partition by s1.instance_number, s1.snap_id)*100, 2) db_time_pct,
           round((e2.time_waited-e1.time_waited)/nullif(e2.total_waits-e1.total_waits, 0)/1e3) avg_wait
      from snaps s1, snaps s2,
           stats e1, stats e2
     where s2.dbid = s1.dbid
       and s2.instance_number = s1.instance_number
       and s2.snap_id = s1.snap_id + 1
       and e1.dbid = s1.dbid
       and e1.snap_id = s1.snap_id
       and e1.instance_number = s1.instance_number
       and e2.dbid = s2.dbid
       and e2.snap_id = s2.snap_id
       and e2.instance_number = s2.instance_number
       and e2.event_name = e1.event_name
    ),
  snap_stats_rank as (
    select instance_number, snap_id, start_of_delta, end_of_delta, event_name, wait_class, total_waits, time_waited, avg_wait, db_time_pct,
           dense_rank() over (partition by instance_number, snap_id order by time_waited desc)-1 wait_rank
      from snap_stats
  )
select instance_number, snap_id, start_of_delta, to_char(end_of_delta, 'hh24:mi') end_of_delta, event_name, total_waits, time_waited, avg_wait, wait_class, db_time_pct
  from snap_stats_rank
 where event_name <> 'DB time'
   and wait_rank <= &top.
/

col instance_number cle
col snap_id cle
col start_of_delta cle
col end_of_delta cle
col event_name cle
col wait_class cle
col total_waits cle
col time_waited cle
col avg_wait cle
col db_time_pct cle

col if_filter cle
col dbid cle
col top cle

@restore_sqlplus_settings.sql
