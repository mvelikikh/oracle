-- <bug description="ALLOW UPDATE OF JOIN VIEW WITHOUT KEY PRESERVED PROPERTY" number="19138896"/>

conn tc/tc@localhost/pdb2 

set echo on long 10000 longc 10000 lin 100

drop table t1;
drop table t2;

select banner_full from v$version;

col fix_control for a90

select xmltype.createxml(cursor(
         select *
           from v$system_fix_control
          where bugno = 19138896)) fix_control
  from dual;

create table t1 (
  pk_col int,
  t1_col varchar2(30));

create table t2 (
  pk_col int,
  t2_col varchar2(30));

insert into t1 values (1, 't1_1');
insert into t1 values (2, 't1_2');

select * from t1;

insert into t2 values (2, 't2_2');
insert into t2 values (3, 't2_3');

commit;

select * from t2;

update (select t2_col, t1_col
          from t1, t2
         where t2.pk_col = t1.pk_col)
   set t2_col = t1_col;

select *
  from t2;

update --+ bypass_ujvc
       (select t2_col, t1_col
          from t1, t2
         where t2.pk_col = t1.pk_col)
   set t2_col = t1_col;

select *
  from t2;

update --+ opt_param('_fix_control' '19138896:1')
       (select t2_col, t1_col
          from t1, t2
         where t2.pk_col = t1.pk_col)
   set t2_col = t1_col;

select *
  from t2;

roll

insert into t1 values (2, 't1_22');
update --+ opt_param('_fix_control' '19138896:1')
       (select t2_col, t1_col
          from t1, t2
         where t2.pk_col = t1.pk_col)
   set t2_col = t1_col;

select *
  from t2;

roll

