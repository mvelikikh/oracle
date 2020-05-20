set def on lin 124 pages 100

-- alter table t1 add lower_status varchar2(128) generated always as (lower(status)) virtual;

exec dbms_stats.gather_table_stats( '', 't1', method_opt => 'for all columns size 254')

col tfi old_v tfi nopri

select to_char(sysdate, 'yyyymmdd_hh24miss') tfi from dual;

alter session set tracefile_identifier='&tfi.';

alter session set events 'trace[sql_optimizer.*]';


var part_key varchar2(10)='P1'
var param    varchar2(12)='WAITING'

select --+ gather_plan_statistics or_expand(@sel$1 (1) (2))
       count(pad1)
  from t1
 where part_key = :part_key
   and (:param = 'WAITING' and status = 'UNPROCESSED'
        or
        :param = 'ALL' and status <> 'PENDING');

select *
  from dbms_xplan.display_cursor(format=> 'allstats last outline');

alter session set events 'trace[sql_optimizer.*] off';

col value for a80

select value 
  from v$diag_info
 where name='Default Trace File';

