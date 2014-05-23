def log_prefix = movp_test
set feedback off
set heading off
set timing off
col current_date new_value current_date noprint
select to_char(sysdate, 'yyyymmdd"_"hh24miss') current_date from dual;
def spool_file=spool_&log_prefix._&current_date..log
spo &my_spool_dir.&spool_file.
col a for a100 fold_a
select 'DB_NAME:        '||sys_context('userenv', 'db_name')a,
       'INSTANCE_NAME:  '||sys_context('userenv', 'instance_name')a,
       'ISDBA:          '||sys_context('userenv', 'isdba')a,
       'SERVER_HOST:    '||sys_context('userenv', 'server_host')a,
       'SESSION_USER:   '||sys_context('userenv', 'session_user')a
  from dual;
set feedback on
set heading on
set serveroutput on size unlimited
set time on
set timing on
set echo on

DOC
  Script: config.sql
#
@@config

DOC
  Script: create internal table
#
@@cretab &job_count. "&objlst." &objtab.

DOC
  Script: before move
#
@@info &objtab.

DOC
  Script: create internal procedure
#
@@creprc &par_count. &task_name. &ts_name. &objtab. &prc_name. &resumable_timeout.

DOC
  Script: dbms_parallel_execute task
#
@@runpexe &job_count. &task_name. &objtab. &prc_name.

DOC
  Script: overall results
#
@@info &objtab.

DOC
  Script: delete created objects
#
@@delobj &prc_name. &objtab.

spo off
