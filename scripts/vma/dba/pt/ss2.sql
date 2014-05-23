--DOCSTART
--
--ss.sql
------------
--
--SQL Statistics.
--
--ss.sql {<sql_id>}
--
--DOCEND
@save_sqlplus_settings.sql
set def  on
set echo off
set hea  on
set timi off
set ver  off

col sql for a13
col plh for 9999999999
col exe for 9999999
col ela for 9999999
col cpu for 9999999
col io  for 9999999
col lio for a6 jus r
col pio for a6 jus r
col rpe for a6 jus r
col fpe for 99999

select sql_id sql,
       plan_hash_value plh,
       executions exe, 
       round(elapsed_time/executions/1e3) ela, 
       round(cpu_time/executions/1e3) cpu,
       round(user_io_wait_time/executions/1e3) io,
       lpad(case when buffer_gets/executions < 1e5 then round(buffer_gets/executions) || ' '
                 when buffer_gets/executions < 1e8 then round(buffer_gets/executions / 1e3) || 'K'
                 when buffer_gets/executions < 1e11 then round(buffer_gets/executions / 1e6) || 'M'
                 else round(buffer_gets/executions / 1e9) || nvl2( executions, 'G', '')
            end, 6, ' '
       ) lio,
       lpad(case when disk_reads/executions < 1e5 then round(disk_reads/executions) || ' '
                 when disk_reads/executions < 1e8 then round(disk_reads/executions / 1e3) || 'K'
                 when disk_reads/executions < 1e11 then round(disk_reads/executions / 1e6) || 'M'
                 else round(disk_reads/executions / 1e9) || nvl2( executions, 'G', '')
            end, 6, ' '
       ) pio,
       lpad(case when rows_processed/executions < 1e5 then round(rows_processed/executions) || ' '
                 when rows_processed/executions < 1e8 then round(rows_processed/executions / 1e3) || 'K'
                 when rows_processed/executions < 1e11 then round(rows_processed/executions / 1e6) || 'M'
                 else round(rows_processed/executions / 1e9) || nvl2( executions, 'G', '')
            end, 6, ' '
       ) rpe,
       round(fetches/executions) fpe,
       last_load_time loa,
       last_active_time act
  from v$sqlarea_plan_hash 
 where &1.
 order by sql, plh
/

prompt 

undef 1

col sql cle
col plh cle
col exe cle
col ela cle
col cpu cle
col io  cle
col lio cle
col pio cle
col rpe cle
col fpe cle

@restore_sqlplus_settings.sql
