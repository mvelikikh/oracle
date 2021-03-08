drop table tc.test;

create table tc.test(
  id int primary key,
  n1 number,
  n2 number);

insert into tc.test values (0, 123.0123456789, 123.0123456789);
commit;

select * from tc.test;

doc
   PostgreSQL
#

drop table tc.test;
create table tc.test(
  id bigint primary key,
  n1 numeric,
  n2 numeric(38,10));
