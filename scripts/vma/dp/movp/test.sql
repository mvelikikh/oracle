whenever sqlerror continue
def tmp_schema="test_movep"
grant create table to &tmp_schema. identified by &tmp_schema.;
alter user &tmp_schema. quota 100M on users;
alter user &tmp_schema. quota 100M on test;
begin
  for i in 1..1e1
  loop
    begin
      execute immediate 'drop table &tmp_schema..t'||i;
    exception when others then null;
    end;
    execute immediate 'create table &tmp_schema..t'||i||'(id int primary key, c clob)';
    execute immediate 'insert into &tmp_schema..t'||i||' values (1, ''x'')';
  end loop;
end;
/
