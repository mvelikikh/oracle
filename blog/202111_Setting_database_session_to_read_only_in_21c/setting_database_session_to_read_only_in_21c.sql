set echo on

conn tc/tc@db-21/pdb

drop table t;

drop table new_tab;

create table t(x int);

insert into t values (0);
commit;

alter session set read_only=true;

update t
   set x=1;

create table new_tab(x int);

select *
  from t
  for update skip locked;

lock table t in exclusive mode;

alter session set read_only=false;

update t
   set x=1;

create table new_tab(x int);

select *
  from t
  for update;

lock table t in exclusive mode;

create or replace trigger logon_trg
after logon on tc.schema
declare
begin
  execute immediate 'alter session set read_only=true';
end;
/

conn tc/tc@db-21/pdb
select *
  from t
  for update;

conn system/manager@db-21/pdb
select *
  from tc.t
  for update;

drop trigger tc.logon_trg;