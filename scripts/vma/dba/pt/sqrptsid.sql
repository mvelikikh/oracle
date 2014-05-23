@save_sqlplus_settings.sql

define sid="&1."
define spool_file="sqlmon_&sid..html"

set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000 feedback off
spool &spool_file.
select dbms_sqltune.report_sql_monitor(report_level=>'+histogram', type=>'HTML', sql_id=>m.sql_id) monitor_report from gv$sql_monitor m where sid=&sid. and status='EXECUTING';
spool off

prompt Report written to &spool_file.

undefine sid
undefine spool_file

@restore_sqlplus_settings.sql