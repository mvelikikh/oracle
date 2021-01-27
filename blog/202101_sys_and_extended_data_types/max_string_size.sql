set echo on long 10000 longc 10000 lines 80

conn tc/tc@localhost/pdb2
sho parameter max_string_size
select banner_full from v$version;
drop table t;
create table t(c varchar2(32767));
desc t
insert into t values (lpad('x',32767,'x'));
select length(c) from t;

conn sys/Oracle123@localhost/orcl2 as sysdba
alter session set container=cdb$root;
sho parameter max_string_size
alter session set container=pdb2;
sho parameter max_string_size
select banner_full from v$version;
drop table t;
create table t(c varchar2(32767));
desc t
insert into t values (lpad('x',32767,'x'));
select length(c) from t;

update t
   set c=c||'y';
select length(c) from t;

update t
   set c=c||c;
select length(c) from t;

update t
   set c=c||c;
select length(c) from t;

update t
   set c=c||c;
select length(c) from t;

update t
   set c=c||c;
select length(c) from t;

update t
   set c=c||lpad('x',759,'x');
select length(c) from t;

update t
   set c=c||'x';
select length(c) from t;

select dbms_metadata.get_ddl('TABLE', 'T') from dual;

col column_name for a11
col segment_name for a25
col index_name like segment_name
col securefile for a10
select column_name, segment_name, index_name, securefile
  from user_lobs
 where table_name='T';

drop table t;

col owner for a5
col table_name for a25
col column_name for a20
select table_name, column_name, data_length
  from user_tab_cols
 where data_type = 'VARCHAR2'
   and data_length > 4000;
