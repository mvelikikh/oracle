def l_sleep_freq="&1."
def l_max_wait="&2."
def l_job_prefix="&3."

declare
  subtype name_type is varchar2(30);
  l_sleep_freq pls_integer := &l_sleep_freq.;
  l_job_prefix name_type := '&job_prefix.';
  l_max_wait pls_integer := &l_max_wait.;
  l_wait_start date;
  l_running_jobs pls_integer;
  function get_running_jobs(
    p_job_prefix in name_type)
    return pls_integer
  is
  begin
    for job_rec in (
      select count(*) job_count
        from user_scheduler_running_jobs
       where job_name like p_job_prefix||'%')
    loop
      return job_rec.job_count;
    end loop;
  end get_running_jobs;
  procedure print_msg( p_facility in varchar2, p_msg in varchar2)
  is
  begin
    sys.dbms_output.put_line( '['||p_facility||'] '||p_msg);
  end print_msg;
  procedure error( p_msg in varchar2)
  is
  begin
    print_msg( 'ERROR', p_msg);
  end error;
  procedure info( p_msg in varchar2)
  is
  begin
    print_msg( 'INFO', p_msg);
  end info;
begin
  l_wait_start := sysdate;
  loop
    l_running_jobs := get_running_jobs( l_job_prefix);
    if l_running_jobs = 0
    then
      info( 'NO MORE RUNNING JOBS');
      return;
    else
      sys.dbms_lock.sleep( l_sleep_freq);
    end if;
    if (sysdate-l_wait_start)*86400 > l_max_wait
    then
      error( 'MAX RUNNING TIME EXCEEDED');
      return;
    end if;
  end loop;
end;
/

undef l_job_prefix
undef l_max_wait
undef l_sleep_freq
