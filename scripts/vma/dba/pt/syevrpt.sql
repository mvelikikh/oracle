-------------------------------------------------------------------------------
--
-- Script:	syevrpt.sql
-- Purpose:	AWR Timed Events report
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about timed events
--
-- Usage:       @syevrpt.sql "<filter>" "{<event_name regexp>|
--                dbid=<dbid>|
--                instance_number=<instance_number>|
--                oby=<order by cols>|
--                wait_class=<wait_class regexp>}"
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2014/02/24 14:52
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--sysevpt.sql
------------
--
--AWR Timed Events report. 
--When not specified, current dbid and instance used.
--
--syevrpt.sql {<filter>}
--  [
--    [<event_name regexp>] |
--    [,dbid=<dbid>] |
--    [,instance_number=<instance_number>] |
--    [,event_name=<event_name regexp>]
--    [,oby=<order by cols>]
--    [,wait_class=<wait_class regexp>]
--  ]
--
--DOCEND

@save_sqlplus_settings.sql

set timing off

col 2 new_v 2 nopri

select '' "2" from dual where null^=null;

def filter="&1."
def input="&2."

@eva "&input." dbid instance_number event_name oby wait_class

@evadef "&input." event_name

set term off

col if_event_name new_v if_event_name nopri
col if_wait_class new_v if_wait_class nopri
col if_filter new_v if_filter nopri
col dbid new_v dbid nopri
col instance_number new_v instance_number nopri
col oby new_v oby nopri

select nvl2(q'[&event_name.]', '', '--') if_event_name,
       nvl2(q'[&wait_class.]', '', '--') if_wait_class,
       nvl2(q'[&filter.]', '', '--') if_filter,
       nvl2('&dbid.', '&dbid.', (select dbid from v$database)) dbid,
       nvl2('&instance_number.', '&instance_number.', sys_context('userenv', 'instance')) instance_number,
       nvl2('&oby.', '&oby.', 'start_of_delta, wait_class, event_name') oby
  from dual
/

set term on
set echo off
set ver off

col snap_id for 9999999
col start_of_delta for a20
col event_name for a58
col wait_class for a13
col total_waits for 999999 hea WAITS
col time_waited for 999999 hea "TIME(S)"
col avg_wait for 999
col htotal_waits for a8 hea "HWAITS/S"
col ela for 9999

bre on snap_id nodup on start_of_delta nodup

with snaps as (
  select snap_id,
         dbid,
         instance_number,
         end_interval_time,
         startup_time
    from dba_hist_snapshot
   where 1 = 1 
     &if_filter. and &filter.
   ),
  events as (
    select dbid, instance_number, snap_id, event_name, wait_class, total_waits_fg total_waits, time_waited_micro_fg time_waited
      from dba_hist_system_event
    union all
    select dbid, instance_number, snap_id, stat_name event_name, null wait_class, null total_waits, value
      from dba_hist_sys_time_model
  ),
  snap_event as (
  select s1.snap_id,
         cast(s1.end_interval_time as date) start_of_delta,
         extract(hour from s2.end_interval_time - s1.end_interval_time)*3600+
           extract(minute from s2.end_interval_time - s1.end_interval_time)*60+
           extract(second from s2.end_interval_time - s1.end_interval_time) ela,
         e1.event_name,
         e1.wait_class,
         e2.total_waits - e1.total_waits total_waits,
         e2.time_waited - e1.time_waited time_waited,
         round((e2.time_waited-e1.time_waited)/nullif(e2.total_waits-e1.total_waits, 0)/1e3) avg_wait
    from snaps s1, snaps s2,
         events e1, events e2
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
  )
select snap_id, start_of_delta, event_name, wait_class, total_waits, time_waited, avg_wait, --htotal_waits, 
       lpad(case
              when htotal_waits = 0 or trunc(log(1e5, abs(htotal_waits))) = 0 then
               round(htotal_waits) || ' '
              when trunc(log(1e8, htotal_waits)) = 0 then
               round(htotal_waits / 1e3) || 'K'
              when trunc(log(1e11, htotal_waits)) = 0 then
               round(htotal_waits / 1e6) || 'M'
              else
               round(htotal_waits / 1e9) || 'G'
            end,
            6,
            ' ') htotal_waits,
       round(ela) ela
  from (select snap_id, start_of_delta, ela, event_name, wait_class, total_waits, 
               round(time_waited/1e6) time_waited,
               avg_wait,
               total_waits/ela htotal_waits
          from snap_event 
         where 1 = 1
           &if_event_name. and regexp_like(event_name, q'#&event_name.#'))
           &if_wait_class. and regexp_like(wait_class, q'#&wait_class.#'))
 order by &oby.
/

undef dbid
undef event_name
undef filter
undef if_event_name
undef if_filter
undef if_wait_class
undef input
undef instance_number
undef oby
undef wait_class

col dbid cle
col if_filter cle
col if_event_name cle
col if_wait_class cle
col instance_number cle
col oby cle

col snap_id cle
col start_of_delta cle
col event_name cle
col wait_class cle
col total_waits cle
col time_waited cle
col avg_wait cle
col htotal_waits cle
col ela cle

@restore_sqlplus_settings.sql
