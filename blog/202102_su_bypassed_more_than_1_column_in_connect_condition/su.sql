conn tc/tc@localhost/pdb

set echo on lin 130 pages 100

drop table departments;
drop table employees;

create table departments
as
select rownum department_id,
       10 manager_count,
       100 employee_count
  from dual
  connect by level<=10;

create table employees
as
select rownum employee_id,
       department_id,
       lpad('x', 100, 'x') name
  from departments,
       lateral(
         select level 
           from dual
           connect by level<=employee_count
       )(+);

set lin 85

alter session set events 'trace[sql_optimizer.*]';
explain plan for
select *
  from departments d
 where manager_count > employee_count
                       + (select --+ unnest
                                 count(*)
                            from employees e
                           where e.department_id = d.department_id);
alter session set events 'trace[sql_optimizer.*] off';
select value from v$diag_info where name='Default Trace File';

select * from dbms_xplan.display();

explain plan for
select *
  from departments d
 where manager_count > (select --+ unnest
                               count(*)
                          from employees e
                         where e.department_id = d.department_id);

select * from dbms_xplan.display();

set lin 130

select --+ gather_plan_statistics
       *
  from departments d
 where manager_count > employee_count 
                       + (select --+ unnest
                                 count(*)
                            from employees e
                           where e.department_id = d.department_id);
select * from dbms_xplan.display_cursor(format=> 'allstats last');

insert into departments values (100, 1, 0);

select --+ gather_plan_statistics
       *
  from departments d
 where manager_count > employee_count 
                       + (select --+ unnest
                                 count(*)
                            from employees e
                           where e.department_id = d.department_id);
select * from dbms_xplan.display_cursor(format=> 'allstats last');

select banner_full from v$version;

explain plan for
select *
  from departments d
 where employee_count > (select --+ unnest
                                count(*)
                           from employees e
                          where e.department_id = d.department_id);
select * from dbms_xplan.display();

explain plan for
with d as (
  select --+ no_merge
         d.*, manager_count - employee_count employee_diff
    from departments d)
select *
  from d
 where employee_diff > (select --+ unnest
                               count(*)
                          from employees e
                         where e.department_id = d.department_id);
select * from dbms_xplan.display();
