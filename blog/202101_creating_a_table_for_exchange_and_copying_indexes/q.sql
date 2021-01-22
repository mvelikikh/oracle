-- BUG 28808656: CREATE TABLE FOR EXCHANGE NEEDS A WAY TO CLONE INDEXES

set echo on long 10000 longc 10000 lines 100 pages 100

drop table t;
drop table tex;

select banner_full from v$version;

create table t (
  created date,
  c1 int,
  c2 int
)
partition by range(created) interval(numtoyminterval(1, 'year')) (
  partition values less than(date'2019-01-01')
);

create index t_c1_i on t(c2) local;
create index t_c1_c2_i on t(c1, c2) local;
create index t_created_c1_i on t(trunc(created), c1) local;
create index t_desc_i on t(c1 desc, c2) local;

insert into t values (date'2018-01-01', 1, 10);
insert into t values (date'2019-01-01', 2, 20);
insert into t values (date'2020-01-01', 3, 30);

alter session set events 'trace[sql_ddl]';
create table tex for exchange with table t clone indexes;
alter session set events 'trace[sql_ddl] off';

exec dbms_metadata.set_transform_param( -
  dbms_metadata.session_transform, -
  'SQLTERMINATOR', true)

select dbms_metadata.get_ddl('INDEX', index_name) from ind where table_name='TEX';

alter table t 
  exchange partition for (date'2018-01-01')
  with table tex
  including indexes;

select * from t;
select * from tex;

select value from v$diag_info where name='Default Trace File';

set echo off
