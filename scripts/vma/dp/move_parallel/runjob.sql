def l_degree="&1."
def l_task_name="&2."
def l_queue_name="&3."
def l_job_prefix="&4."

declare
  subtype name_type is varchar2(30);
  l_degree pls_integer := &l_degree.;
  l_job_prefix name_type := '&l_job_prefix.';
  l_task_name name_type := '&l_task_name.';
  l_queue_name name_type := '&l_queue_name.';
  l_job_name name_type;
  procedure debug( p_msg in varchar2)
  is
  begin
    sys.dbms_output.put_line( '[DEBUG] ' || p_msg);
  end debug;
begin
  for ind in 1..l_degree
  loop
    l_job_name := l_job_prefix || ind;
    debug( l_job_name);
  end loop;
end;
/

undef l_degree
undef l_job_prefix
undef l_queue_name
undef l_task_name
