-------------------------------------------------------------------------------
--
-- Script:	systrpt.sql
-- Purpose:	AWR System Statistics report
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information active session history
--
-- Usage:       @systrpt.sql "<filter>" "{<stat_name regexp>|
--                dbid=<dbid>|
--                instance_number=<instance_number>|
--                stat_name=<stat_name regexp>}"
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/12/09 10:54
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--systrpt.sql
------------
--
--AWR System Statistics report. 
--When not specified, current dbid and instance used.
--
--systrpt.sql {<filter>}
--  [
--    [<stat_name regexp>] |
--    [,dbid=<dbid>] |
--    [,instance_number=<instance_number>] |
--    [,stat_name=<stat_name regexp>]
--  ]
--
--DOCEND

@save_sqlplus_settings.sql

set timing off

col 2 new_v 2 nopri

select '' "2" from dual where null^=null;

def filter="&1."
def input="&2."

@eva "&input." dbid instance_number stat_name

@evadef "&input." stat_name

set term off

col if_stat_name new_v if_stat_name nopri
col if_filter new_v if_filter nopri
col dbid new_v dbid nopri
col instance_number new_v instance_number nopri

select nvl2(q'[&stat_name.]', '', '--') if_stat_name,
       nvl2(q'[&filter.]', '', '--') if_filter,
       nvl2('&dbid.', '&dbid.', (select dbid from v$database)) dbid,
       nvl2('&instance_number.', '&instance_number.', sys_context('userenv', 'instance')) instance_number
  from dual
/

set term on
set echo off
set ver off

col snap_id for 9999999
col start_of_delta for a20
col delta for 999999999999
col hdelta for a8 hea "HDELTA/S"
col stat_name for a70

select snap_id,
       start_of_delta,
       delta,
       stat_name,
       ela,
       lpad(case
              when hdelta = 0 or trunc(log(1e5, abs(hdelta))) = 0 then
               round(hdelta) || ' '
              when trunc(log(1e8, hdelta)) = 0 then
               round(hdelta / 1e3) || 'K'
              when trunc(log(1e11, hdelta)) = 0 then
               round(hdelta / 1e6) || 'M'
              else
               round(hdelta / 1e9) || 'G'
            end,
            6,
            ' ') hdelta
  from (select snap_id,
               snap_id_max,
               start_of_delta,
               stat_name,
               delta,
               delta/(extract(hour from interval) * 3600 + extract(minute from interval) * 60 + extract(second from interval)) hdelta,
               extract(hour from interval) * 3600 + extract(minute from interval) * 60 + extract(second from interval) ela
          from (select hs.snap_id,
                       to_char(cast(hs.end_interval_time as date)) start_of_delta,
                       lead(ss.value) over (partition by hs.startup_time, ss.stat_name order by hs.snap_id) - ss.value delta,
                       lead(hs.end_interval_time) over(partition by hs.startup_time, ss.stat_name order by hs.snap_id) - hs.end_interval_time interval,
                       ss.stat_name,
                       max(hs.snap_id) over (partition by hs.startup_time) snap_id_max
                  from (select snap_id,
                               dbid,
                               instance_number,
                               end_interval_time,
                               startup_time
                          from dba_hist_snapshot
                         where 1 = 1 
                           &if_filter. and &filter.
                       ) hs,
                       dba_hist_sysstat ss
                 where hs.dbid = &dbid.
                   and hs.instance_number = &instance_number.
                   and ss.dbid = hs.dbid
                   and ss.instance_number = hs.instance_number
                   and ss.snap_id = hs.snap_id
                   and regexp_like(ss.stat_name, '&stat_name.')))
 where snap_id <> snap_id_max
 order by snap_id, stat_name
/

undef dbid
undef filter
undef if_filter
undef if_stat_name
undef input
undef instance_number
undef stat_name

col dbid cle
col if_filter cle
col if_stat_name cle
col instance_number cle

col snap_id cle
col start_of_delta cle
col stat_name cle
col delta cle
col hdelta cle

@restore_sqlplus_settings.sql
