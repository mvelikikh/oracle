def l_job_count="&1."
def l_task_name="&2."
def l_objtab="&3."
def l_prc_name="&4."

DECLARE
  type tsk_sts_tbl_type is table of varchar2(20) index by binary_integer;
  subtype name_type is varchar2(30);
  l_tsk_sts_tbl tsk_sts_tbl_type;
  l_chunk_sql VARCHAR2(1000);
  l_sql_stmt VARCHAR2(1000);
  l_status NUMBER;
  l_taskname varchar2(30) := '&l_task_name.';
  procedure get_std_sts
  is
  begin
    l_tsk_sts_tbl(1) := 'CREATED';
    l_tsk_sts_tbl(2) := 'CHUNKING';
    l_tsk_sts_tbl(3) := 'CHUNKING_FAILED';
    l_tsk_sts_tbl(4) := 'CHUNKED';
    l_tsk_sts_tbl(5) := 'PROCESSING';
    l_tsk_sts_tbl(6) := 'FINISHED';
    l_tsk_sts_tbl(7) := 'FINISHED_WITH_ERROR';
    l_tsk_sts_tbl(8) := 'CRASHED';
  end get_std_sts;
  procedure write_error(p_msg in varchar2)
  is
  begin
    sys.dbms_output.put_line( '[ERROR] ' || p_msg);
  end write_error;
  function get_task_status( p_status in binary_integer)
    return varchar2
  is
  begin
    return l_tsk_sts_tbl( p_status);
  exception
    when no_data_found
    then
      write_error( 'Undefined task status = ' || p_status);
      return to_char(p_status);
  end get_task_status;
  procedure drop_task( p_taskname in name_type)
  is
  begin
    sys.dbms_parallel_execute.drop_task( p_taskname);
  exception
    when sys.dbms_parallel_execute.task_not_found
    then
      null;
  end drop_task;
BEGIN
  -- populate standard statuses
  get_std_sts;
  drop_task( l_taskname);
  -- Create the TASK
  sys.dbms_parallel_execute.create_task ( l_taskname);

  -- Chunk the table
  l_chunk_sql := 'select id start_id, id end_id from &l_objtab.';
  sys.dbms_parallel_execute.create_chunks_by_sql( l_taskname, l_chunk_sql, false);

  -- Execute task
  l_sql_stmt := 'begin &l_prc_name.(:start_id, :end_id); end;';
  sys.dbms_parallel_execute.run_task( l_taskname, l_sql_stmt, dbms_sql.native, parallel_level => &job_count.);

  -- If there is error, dont drop task.
  l_status := sys.dbms_parallel_execute.task_status( l_taskname);
  if l_status != sys.dbms_parallel_execute.finished
  then
    write_error( 'task completed with status = '||get_task_status(l_status));
    return;
  else
    -- Done with processing; drop the task
    sys.dbms_parallel_execute.drop_task( l_taskname);
  end if;
end;
/

undef l_job_count
undef l_task_name
undef l_objtab
undef l_prc_name
