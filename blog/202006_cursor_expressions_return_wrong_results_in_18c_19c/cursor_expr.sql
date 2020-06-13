doc
################################################################################
   Demonstration for Bug 30528947: Nested Query Using CURSOR Expression Returns 
Wrong Result (Doc ID 30528947.8)
################################################################################
#

set echo on

drop table t1;
drop table t2;

create table t1(id int);
create table t2(id int);

insert into t1 values (1);
insert into t2 values (1);

alter session set events 'sql_trace bind=true';

doc
##############################
   One row, different value
##############################
#
select cursor(
         select query_type
           from (select 'A' query_type
                   from t1 t11
                  where exists (
                          select null
                            from t2 t21
                           where t21.id = t11.id)
                  union all
                 select 'B' query_type
                   from t1 t12
                  where not exists (
                          select null
                            from t2 t22
                           where t22.id = t12.id)
                )
       ) data
  from dual;

doc
   The cursor subquery
#
select query_type
  from (select 'A' query_type
          from t1 t11
         where exists (
                 select null
                   from t2 t21
                  where t21.id = t11.id)
         union all
        select 'B' query_type
          from t1 t12
         where not exists (
                 select null
                   from t2 t22
                  where t22.id = t12.id)
       );
doc
##############################
   More rows
##############################
#

select cursor(
         select query_type
           from (select 'A' query_type
                   from t1 t11
                  union all
                 select 'B' query_type
                   from t1 t12
                  where not exists (
                          select null
                            from t2 t22
                           where t22.id = t12.id)
                )
       ) data
  from dual;

doc
   The cursor subquery
#
select query_type
  from (select 'A' query_type
          from t1 t11
         union all
        select 'B' query_type
          from t1 t12
         where not exists (
                 select null
                   from t2 t22
                  where t22.id = t12.id)
       );

doc
##############################
   Less rows
##############################
#

select cursor(
         select query_type
           from (select 'A' query_type
                   from t1 t11
                  where exists (
                          select null
                            from t2 t21
                           where t21.id = t11.id)
                  union all
                 select 'B' query_type
                   from t1 t12
                  where exists (
                          select null
                            from t2 t22
                           where t22.id = t12.id)
                )
       ) data
  from dual;

doc
   The cursor subquery
#
select query_type
  from (select 'A' query_type
          from t1 t11
         where exists (
                 select null
                   from t2 t21
                  where t21.id = t11.id)
         union all
        select 'B' query_type
          from t1 t12
         where exists (
                 select null
                   from t2 t22
                  where t22.id = t12.id)
       )
;
