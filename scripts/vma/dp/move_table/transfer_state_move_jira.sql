def log_prefix = transfer_state_move
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


def par_count="20"

def old_tbs=""
def new_tbs=""

col old_tbs new_v old_tbs
col new_tbs new_v new_tbs
select tablespace_name old_tbs,
       decode(tablespace_name, 'USERS', 'QPAY_DATA') new_tbs
  from tabs
 where table_name = 'QP$_TRANSFER_STATE'
/

alter session set workarea_size_policy=manual;
alter session set sort_area_size=2147483647;

DOC
  Segment size before move
#
set num 20

select bytes, blocks from user_segments where segment_name = 'QP$_TRANSFER_STATE';

alter table qp$_transfer_state move parallel &par_count. tablespace &new_tbs. pctfree 0;

ALTER INDEX "TRF_STATE_UIN_IDX" rebuild parallel &par_count. tablespace &new_tbs.
/
alter index "TRF_STATE_UIN_IDX" noparallel
/
ALTER INDEX "TRF_STATE_WTIME_IDX" rebuild parallel &par_count. tablespace &new_tbs.
/
alter index "TRF_STATE_WTIME_IDX" noparallel
/
ALTER INDEX "TRANSFER_STATE_PK" rebuild parallel &par_count. tablespace &new_tbs.
/
alter index "TRANSFER_STATE_PK" noparallel
/

DOC
  Segment size after move
#
select bytes, blocks from user_segments where segment_name = 'QP$_TRANSFER_STATE';

exec dbms_mview.refresh( list=> 'WH$_OP_TR_STATE2', method=> 'f')

spool off
