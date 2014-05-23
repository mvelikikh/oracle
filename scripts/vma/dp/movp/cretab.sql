def l_job_count="&1."
def l_objlst="&2."
def l_objtab="&3."

declare
  object_not_exists_error exception;
  pragma exception_init( object_not_exists_error, -942);
begin
  execute immediate 'drop table &l_objtab.';
exception
  when object_not_exists_error
  then
    null;
end;
/
create table &l_objtab. initrans &l_job_count. as &l_objlst.;
alter table &l_objtab. add (id int, processed varchar2(12) default 'NO' not null, navi_date date default sysdate, navi_sessionid int, start_date date, processed_date date);
update &l_objtab. set id=rownum;
commit;
alter table &l_objtab. move;
alter table &l_objtab. add primary key (id);
exec sys.dbms_stats.gather_table_stats( '', '&l_objtab.')

undef l_job_count
undef l_objlst
undef l_objtab
