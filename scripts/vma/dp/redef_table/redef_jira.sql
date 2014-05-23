def log_prefix = redef
set feedback off
set heading off
set timing off
col current_date new_value current_date noprint
select to_char(sysdate, 'yyyymmdd"_"hh24miss') current_date from dual;
def spool_file=spool_&log_prefix._&current_date..log
spool &spool_file.
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

@@config

whenever oserror exit failure
whenever sqlerror exit failure

timi start redef
DOC
  Script: create_interim 
#
@@create_interim &owner. &table. &tablespace. &table_int. &tablespace_int.

DOC
  Script: copy_data
#
@@copy_data &owner. &table. &table_int. &par_count. &resumable_timeout. &parallel_min_pct. &orderby_cols.

DOC
  Script: copy_index
#
@@copy_index &owner. &table. &tablespace. &table_int. &tablespace_int. &par_count. &resumable_timeout. &parallel_min_pct. &workarea_size_policy. &sort_area_size.

DOC
  Script: copy_constraint
#
@@copy_constraint &owner. &table. &table_int. &par_count. &resumable_timeout.

--DOC
--  Script: copy_ref_constraint
--#
--@@copy_ref_constraint &owner. &table. &table_int. &par_count. &resumable_timeout.
--
DOC
  Script: copy_others
#
@@copy_others &owner. &table. &table_int.

DOC
  Script: gather mlog stats
#
@@gather_stats &owner. &redef_mlog. &par_count.

DOC
  Script: inline sync
#
exec sys.dbms_redefinition.sync_interim_table( '&owner.', '&table.', '&table_int.')

DOC
  Script: gather_stats
#
@@gather_stats &owner. &table_int. &par_count.

DOC
  Script: inline finish
#
exec sys.dbms_redefinition.finish_redef_table( '&owner.', '&table.', '&table_int.')

select num_rows from dba_tab_statistics where owner='&owner.' and table_name='&table.';

timi stop

spool off
