set echo on

col log_file old_v log_file

select f.member log_file
  from v$log g,
       v$logfile f
 where g.status = 'CURRENT'
   and f.group# = g.group#
   and rownum = 1 /* any member is okay*/
/

alter session set tracefile_identifier=for_update -
  events 'sql_trace';

col start_scn old_v start_scn
select current_scn start_scn from v$database;

var rc refcursor

exec open :rc for select * from t1 order by n1 for update

col xid for a20
col xid_with_spaces like xid
col xid_with_spaces old_v xid_with_spaces

select dbms_transaction.local_transaction_id xid,
       replace(dbms_transaction.local_transaction_id, '.', ' ') xid_with_spaces
  from dual;

col end_scn old_v end_scn
select current_scn end_scn from v$database;

roll

alter system dump logfile '&log_file.' scn min &start_scn. scn max &end_scn. xid &xid_with_spaces.;

alter session set tracefile_identifier=for_update_skip_locked;

col start_scn old_v start_scn
select current_scn start_scn from v$database;

exec open :rc for select * from t1 order by n1 for update skip locked

col xid_with_spaces old_v xid_with_spaces

select dbms_transaction.local_transaction_id xid,
       replace(dbms_transaction.local_transaction_id, '.', ' ') xid_with_spaces
  from dual;

col end_scn old_v end_scn
select current_scn end_scn from v$database;

exec dbms_session.sleep(5)

roll

alter system dump logfile '&log_file.' scn min &start_scn. scn max &end_scn. xid &xid_with_spaces.;

