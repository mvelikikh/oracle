set echo on

spool update_queue_with_priorities

/* Create Queue table */
drop table t_myqueue purge;
create table t_myqueue (
   order_of_arrival   number
 , priority           number not null
 , retrycount         number default 0 not null
 , queue_tag          varchar2(1000) default '*' not null
 , id                 varchar2(64)
 , filler1            varchar2(1000)
 , filler2            varchar2(1000)
 , CONSTRAINT pk_t_myqueue PRIMARY KEY (order_of_arrival)
);
 
/* Create indexes (choose one) */
DROP INDEX idx_t_myqueue_1;
DROP INDEX idx_t_myqueue_fbi_asc;
DROP INDEX idx_t_myqueue_fbi_dsc;
CREATE INDEX idx_t_myqueue_1 ON t_myqueue (queue_tag, id, priority, retrycount, order_of_arrival);
CREATE INDEX idx_t_myqueue_fbi_asc ON t_myqueue (
   queue_tag, CASE WHEN id IS NULL THEN 1 END, CASE WHEN retrycount < 10 THEN 1 END, priority, order_of_arrival
);
CREATE INDEX idx_t_myqueue_fbi_dsc ON t_myqueue (
   queue_tag, CASE WHEN id IS NULL THEN 1 END, CASE WHEN retrycount < 10 THEN 1 END, priority DESC, order_of_arrival
);
 
/* Clear, fill table, gather stats - uncomment one line */
truncate table t_myqueue;
insert into t_myqueue
  select level as order_of_arrival,
    floor(dbms_random.value(1, 6)) as priority,
    0 as retrycount,
    '*' queue_tag,
--  /* 100% matches */ null as id,
--  /*  20% matches */ case when mod(rownum, 5)=0 then null else sys_guid() end as id,
    /*  10% matches */ case when mod(rownum, 10)=0 then null else sys_guid() end as id,
    rpad('xxhx',1000,'xder') as filler1,
    rpad('xdsxx',1000,'xgdder') as filler2
  from dual
  connect by level <=100000;
commit;
exec dbms_stats.gather_table_stats(user,'t_myqueue');
 
/* Create testing procedure */
CREATE OR REPLACE PROCEDURE time_sql_x (title varchar2, sqltxt varchar2) AS
   timestart INTEGER;
   counter INTEGER;
BEGIN
   dbms_output.enable;
   timestart := dbms_utility.get_time();
   FOR counter IN 1..1000
   LOOP
     execute immediate(replace(sqltxt, 'update t_myqueue', 'update /*+ '||title||'*/t_myqueue'));
   END LOOP;  
   dbms_output.put_line(title||': ' || to_char((dbms_utility.get_time() - timestart)/100,'0.99') || ' seconds');
   rollback;
END;
/
 
/* Enable output */
set serveroutput on;
 
/* Check table matches */
select total, matches, to_char(matches/total*100 ||'%') PCT from (
select count(*) total, count(case when id is null and queue_tag='*' and retrycount<10 then 1 end) matches from t_myqueue);

alter session set events 'sql_trace plan_stat=all_executions';
 
/* Run tests */
begin time_sql_x('Simple subqueries',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.order_of_arrival = (
           select min(q2.order_of_arrival)
           from t_myqueue q2
           where q2.queue_tag = '*'
           and q2.id is null
           and q2.retrycount < 10
           and q2.priority = (
              select max(q3.priority)
              from t_myqueue q3
              where q3.queue_tag = '*'
              and q3.id is null
              and q3.retrycount < 10
           )
        )
]'); end;
/
 
begin time_sql_x('Simple fetch first',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.rowid = (
           select rowid
           from t_myqueue
           where queue_tag = '*'
           and id is null
           and retrycount < 10
           order by priority desc, order_of_arrival
           fetch first 1 row only
        )
]'); end;
/
 
begin time_sql_x('Simple Stop count',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.rowid = (
           select * from (
               select rowid
               from t_myqueue
               where queue_tag = '*'
               and id is null
               and retrycount < 10
               order by priority desc, order_of_arrival
               )
          where rownum=1
           )
]'); end;
/
 
begin time_sql_x('FBI - Subqueries',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.order_of_arrival = (
           select min(q2.order_of_arrival)
           from t_myqueue q2
           where q2.queue_tag = '*'
           and case when q2.id is null then 1 end = 1
           and case when q2.retrycount < 10 then 1 end = 1
           and q2.priority = (
              select max(q3.priority)
              from t_myqueue q3
              where q3.queue_tag = '*'
              and case when q3.id is null then 1 end = 1
              and case when q3.retrycount < 10 then 1 end = 1
           )
        )
]'); end;
/
 
begin time_sql_x('FBI - Fetch First',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.rowid = (
           select rowid
           from t_myqueue
           where queue_tag = '*'
           and case when id is null then 1 end = 1
           and case when retrycount < 10 then 1 end = 1
           order by queue_tag, case when id is null then 1 end, case when retrycount < 10 then 1 end, priority desc, order_of_arrival
           fetch first 1 row only
        )
]'); end;
/
 
begin time_sql_x('FBI - Stop count',q'[
        update t_myqueue q1
        set id = 'x'
        where q1.rowid = (
           select * from (
               select /*+ index(t_myqueue idx_t_myqueue_fbi_dsc)*/rowid
               from t_myqueue
               where queue_tag = '*'
               and case when id is null then 1 end = 1
               and case when retrycount < 10 then 1 end = 1
               order by queue_tag, case when id is null then 1 end, case when retrycount < 10 then 1 end, priority desc, order_of_arrival
               )
          where rownum=1
           )
]'); end;
/

alter session set events 'sql_trace off';

select value from v$diag_info where name='Default Trace File';

spo off