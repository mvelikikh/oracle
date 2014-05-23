def log_prefix = &1.
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
