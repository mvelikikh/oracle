set echo on
conn / as sysdba

alter session set container=pdb;

exec dbms_scheduler.purge_log()

drop user tc cascade;

grant create job, create session to tc identified by tc;

grant execute on sys.dbms_isched to tc;

conn tc/tc@localhost/pdb

doc
################################################################################
#  Traditional Job
################################################################################
#

select dbms_transaction.local_transaction_id from dual;

exec dbms_scheduler.create_job( -
  job_name => 'JOB_NON_TX', -
  job_type => 'PLSQL_BLOCK', -
  job_action => 'null;', -
  enabled    => true)

select dbms_transaction.local_transaction_id from dual;

exec dbms_session.sleep(5)

col job_name for a10

select job_name, state
  from user_scheduler_jobs;

col log_date for a35
select log_date, job_name, status
  from user_scheduler_job_run_details
 order by log_date;

doc
################################################################################
#  Transactional Job
################################################################################
#

exec sys.dbms_isched.set_no_commit_flag

select dbms_transaction.local_transaction_id from dual;

exec dbms_scheduler.create_job( -
  job_name => 'JOB_TX', -
  job_type => 'PLSQL_BLOCK', -
  job_action => 'null;', -
  enabled    => true)

select dbms_transaction.local_transaction_id from dual;

exec dbms_session.sleep(5)

col job_name for a10

select job_name, state
  from user_scheduler_jobs;

col log_date for a35
select log_date, job_name, status
  from user_scheduler_job_run_details
 order by log_date;

commit;

exec dbms_session.sleep(5)

col job_name for a10
col state for a10

select job_name, state
  from user_scheduler_jobs;

col status for a10

col log_date for a35
select log_date, job_name, status
  from user_scheduler_job_run_details
 order by log_date;
