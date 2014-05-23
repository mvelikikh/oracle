-------------------------------------------------------------------------------
--
-- Script:	awrlprofh.sql
-- Purpose:	AWR-like Load profile report.
--              ixora save/restore_s+ used for saving user environment
--              Timur Akhmadeev Ideas are used
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about timed events
--
-- Usage:       @awrlprofh.sql "<filter>" "{dbid=<dbid>|
--                instance_number=<instance_number>}"
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2014/04/21 12:47
--     Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

col 2 new_v 2 nopri

select '' "2" from dual where null^=null;

def filter="&1."
def input="&2."

@eva "&input." dbid instance_number

@evadef "&input." top

set term off

col if_filter new_v if_filter nopri
col dbid new_v dbid nopri
col instance_number new_v instance_number nopri

select nvl2(q'[&filter.]', '', '--') if_filter,
       nvl2('&dbid.', '&dbid.', (select dbid from v$database)) dbid,
       nvl2('&instance_number.', '&instance_number.', sys_context('userenv', 'instance')) instance_number
  from dual
/

set term on
set echo off
set ver off

col instance_number nopri
col snap_id for 9999999
col start_of_delta for a19 hea "BEGIN_SNAP"
col end_of_delta for a8 hea "END_SNAP"
col short_name for a15 hea "LOAD_PROFILE"
col per_sec for 9g999g999d99
col per_tx for 9g999g999d99

break on snap_id nodup on start_of_delta nodup on end_of_delta nodup skip 1

with snaps as (
  select snap_id,
         dbid,
         instance_number,
         begin_interval_time,
         end_interval_time,
         startup_time
    from dba_hist_snapshot
   where 1 = 1
     and dbid = &dbid.
     and instance_number = &instance_number.
     &if_filter. and &filter.
   ),
  sysmetric as
    (
     select dbid, instance_number, snap_id, metric_name, average value
      from dba_hist_sysmetric_summary
    ),
  snap_sysmetric as (
    select s.instance_number,
           s.snap_id,
           cast(s.begin_interval_time as date) start_of_delta,
           cast(s.end_interval_time as date) end_of_delta,
           sm.value*m.coeff value, sm.metric_name, m.typ, m.m_rank,
           m.short_name
      from snaps s,
           sysmetric sm,
           (select 'Database Time Per Sec'                      metric_name, 'DB Time' short_name, .01 coeff, 1 typ, 1 m_rank from dual union all
                select 'CPU Usage Per Sec'                          metric_name, 'DB CPU' short_name, .01 coeff, 1 typ, 2 m_rank from dual union all
                select 'Redo Generated Per Sec'                     metric_name, 'Redo size' short_name, 1 coeff, 1 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Sec'                      metric_name, 'Logical reads' short_name, 1 coeff, 1 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Sec'                   metric_name, 'Block changes' short_name, 1 coeff, 1 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Sec'                     metric_name, 'Physical reads' short_name, 1 coeff, 1 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Sec'                    metric_name, 'Physical writes' short_name, 1 coeff, 1 typ, 7 m_rank from dual union all
                select 'User Calls Per Sec'                         metric_name, 'User calls' short_name, 1 coeff, 1 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Sec'                  metric_name, 'Parses' short_name, 1 coeff, 1 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Sec'                   metric_name, 'Hard Parses' short_name, 1 coeff, 1 typ, 10 m_rank from dual union all
                select 'Logons Per Sec'                             metric_name, 'Logons' short_name, 1 coeff, 1 typ, 11 m_rank from dual union all
                select 'Executions Per Sec'                         metric_name, 'Executes' short_name, 1 coeff, 1 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Sec'                     metric_name, 'Rollbacks' short_name, 1 coeff, 1 typ, 13 m_rank from dual union all
                select 'User Transaction Per Sec'                   metric_name, 'Transactions' short_name, 1 coeff, 1 typ, 14 m_rank from dual union all
                select 'User Rollback UndoRec Applied Per Sec'      metric_name, 'Applied urec' short_name, 1 coeff, 1 typ, 15 m_rank from dual union all
                select 'Redo Generated Per Txn'                     metric_name, 'Redo size' short_name, 1 coeff, 2 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Txn'                      metric_name, 'Logical reads' short_name, 1 coeff, 2 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Txn'                   metric_name, 'Block changes' short_name, 1 coeff, 2 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Txn'                     metric_name, 'Physical reads' short_name, 1 coeff, 2 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Txn'                    metric_name, 'Physical writes' short_name, 1 coeff, 2 typ, 7 m_rank from dual union all
                select 'User Calls Per Txn'                         metric_name, 'User calls' short_name, 1 coeff, 2 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Txn'                  metric_name, 'Parses' short_name, 1 coeff, 2 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Txn'                   metric_name, 'Hard Parses' short_name, 1 coeff, 2 typ, 10 m_rank from dual union all
                select 'Logons Per Txn'                             metric_name, 'Logons' short_name, 1 coeff, 2 typ, 11 m_rank from dual union all
                select 'Executions Per Txn'                         metric_name, 'Executes' short_name, 1 coeff, 2 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Txn'                     metric_name, 'Rollbacks' short_name, 1 coeff, 2 typ, 13 m_rank from dual union all
                select 'User Transaction Per Txn'                   metric_name, 'Transactions' short_name, 1 coeff, 2 typ, 14 m_rank from dual union all
                select 'User Rollback Undo Records Applied Per Txn' metric_name, 'Applied urec' short_name, 1 coeff, 2 typ, 15 m_rank from dual) m
     where sm.dbid = s.dbid
       and sm.instance_number = s.instance_number
       and sm.snap_id = s.snap_id
       and sm.metric_name = m.metric_name
    ),
  snap_sysmetric_agg as (
    select instance_number,
           snap_id,
           start_of_delta,
           end_of_delta,
           short_name,
           max(decode(typ, 1, value)) per_sec,
           max(decode(typ, 2, value)) per_tx,
           max(m_rank) m_rank
      from snap_sysmetric
     group by instance_number,
           snap_id,
           start_of_delta,
           end_of_delta,
           short_name
  )
select instance_number, snap_id, start_of_delta, to_char(end_of_delta, 'hh24:mi') end_of_delta, short_name, round(per_sec, 2) per_sec, round(per_tx, 2) per_tx
  from snap_sysmetric_agg 
 order by instance_number, snap_id, m_rank
/

col instance_number cle
col snap_id cle
col start_of_delta cle
col end_of_delta cle
col short_name cle
col per_sec cle
col per_tx cle

col if_filter cle
col dbid cle

@restore_sqlplus_settings.sql
