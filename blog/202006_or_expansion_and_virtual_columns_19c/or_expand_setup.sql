drop table t1;

create table t1 (
  part_key varchar2(8),
  status   varchar2(12),
  pad1     char(500)
)
partition by list(part_key) (
  partition values ('P1'),
  partition values (default)
)
;


insert into t1
select 'P1', status, 'X'
  from (select 90 pct, 'PROCESSED' status from dual union all
        select 1, 'UNPROCESSED' from dual union all
        select 9, 'PENDING' from dual) params,
       lateral(
         select level
           from dual
           connect by level <= params.pct * 1000
       ) duplicator;

commit;

create index t1_status_i on t1(status) local;

select status, 
       count(*), 
       round(ratio_to_report(count(*)) over () * 100, 2) pct
  from t1
 group by status
 order by 1;
