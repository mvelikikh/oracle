def l_prg_prefix="&1."
def l_task_name="&2."
def l_prg_name="&3."
def l_queue_name="&4."
def l_degree="&5."
def l_ts_name="&6."
def l_resumable_timeout="&7."

declare
  subtype name_type is varchar2(30);
  subtype varchar_max is varchar2(32767);
  l_degree constant pls_integer := &l_degree.;
  l_prg_prefix name_type := '&l_prg_prefix.';
  l_queue_name name_type := '&l_queue_name.';
  l_resumable_timeout pls_integer := &l_resumable_timeout.;
  l_task_name name_type := '&l_task_name.';
  l_ts_name name_type := '&l_ts_name.';
  l_prg_name name_type := '&l_prg_name.';--l_prg_prefix||l_task_name;
  l_prg_action varchar_max := 'begin null;end;';
  procedure debug(p_msg in varchar2)
  is
  begin
    sys.dbms_output.put_line( '[DEBUG] '||p_msg);
  end debug;
  procedure get_prg_action
  is
  begin
    l_prg_action :=
'
declare
  subtype name_type is varchar2(30);
  queue_timeout_error exception;
  pragma exception_init(queue_timeout_error, -25228);
  l_deq_opt sys.dbms_aq.dequeue_options_t;
  l_msg_prop sys.dbms_aq.message_properties_t;
  l_payload  sys.xmltype;
  l_msgid    raw(16);
  l_queue_name name_type := '''||l_queue_name||''';
  l_degree constant pls_integer := '||l_degree||';
  l_resumable_timeout constant pls_integer := '||l_resumable_timeout||';
  l_task_name constant name_type := '''||l_task_name||''';
  l_ts_name constant name_type := '''||l_ts_name||''';
  l_owner name_type;
  l_name  name_type;
  procedure rebuild_index(
    p_owner   in name_type,
    p_name    in name_type,
    p_degree  in pls_integer,
    p_ts_name in name_type)
  is
    l_sql_stmt clob;
  begin
    l_sql_stmt := ''alter index "''||p_owner||''"."''||p_name||''" rebuild parallel ''||p_degree||'' tablespace ''||p_ts_name;
    execute immediate l_sql_stmt;
    l_sql_stmt := ''alter index "''||p_owner||''"."''||p_name||''" noparallel'';
    execute immediate l_sql_stmt;
  end rebuild_index;
  procedure rebuild_indexes(
    p_owner  in name_type,
    p_name   in name_type,
    p_degree in pls_integer,
    p_ts_name in varchar2)
  is
  begin
    for ind_rec in (
      select owner, index_name
        from dba_indexes
       where table_owner = p_owner
         and table_name = p_name
         and index_type not in (''LOB''))
    loop
      rebuild_index( ind_rec.owner, ind_rec.index_name, p_degree, p_ts_name);
    end loop;
  end rebuild_indexes;
  procedure move_lob(
    p_owner    in name_type,
    p_name     in name_type,
    p_degree   in pls_integer,
    p_ts_name  in name_type,
    p_col_name in name_type)
  is
    l_sql_stmt clob;
  begin
    l_sql_stmt := ''alter table "''||p_owner||''"."''||p_name||''" move lob(''||p_col_name||'') store as (tablespace ''||p_ts_name||'')'';
    execute immediate l_sql_stmt;
  end move_lob;
  procedure move_lobs(
    p_owner  in name_type,
    p_name   in name_type,
    p_degree in pls_integer,
    p_ts_name in name_type)
  is
  begin
    for lob_rec in (
      select column_name
        from dba_lobs
       where owner = p_owner
         and table_name = p_name)
    loop
      move_lob( p_owner, p_name, p_degree, p_ts_name, lob_rec.column_name);
    end loop;
  end move_lobs;
  procedure move_table(
    p_owner  in name_type,
    p_name   in name_type,
    p_degree in pls_integer,
    p_ts_name in varchar2)
  is
    l_sql_stmt clob;
  begin
    l_sql_stmt := ''alter table "''||p_owner||''"."''||p_name||''" move parallel ''||p_degree||'' tablespace ''||p_ts_name;
    execute immediate l_sql_stmt;
  end move_table;
  procedure move(
    p_owner  in name_type,
    p_name   in name_type,
    p_degree in pls_integer,
    p_ts_name in varchar2)
  is
    l_sql_stmt clob;
  begin
    move_table( p_owner, p_name, p_degree, p_ts_name);
    move_lobs( p_owner, p_name, p_degree, p_ts_name);
    rebuild_indexes( p_owner, p_name, p_degree, p_ts_name);
  end move;
begin
  l_deq_opt.wait := 1; -- wait for 1 second
  loop
    sys.dbms_aq.dequeue(
      queue_name         => l_queue_name,
      dequeue_options    => l_deq_opt,
      message_properties => l_msg_prop,
      payload            => l_payload,
      msgid              => l_msgid);
    execute immediate ''alter session enable resumable timeout ''||l_resumable_timeout||'' name ''''''||l_task_name||'''''''';
    for xml_rec in (
      select owner, name
        from xmltable(
               ''/ROWSET/ROW''
               passing l_payload
               columns 
                 owner varchar2(30) path ''OWNER'',
                 name varchar2(30) path ''NAME''))
    loop
      insert into log (sid, msg) values (sys_context(''userenv'', ''sid''), xml_rec.name);
      move( xml_rec.owner, xml_rec.name, l_degree, l_ts_name);
    end loop;
  end loop;
exception
  when queue_timeout_error
  then
    return;
end;
';
  end;
begin
  debug( l_prg_name);
  begin
    sys.dbms_scheduler.drop_program( l_prg_name);
  exception
    when others then null;
  end;
  get_prg_action;
  sys.dbms_scheduler.create_program (
    program_name        => l_prg_name,
    program_type        => 'PLSQL_BLOCK',
    program_action      => l_prg_action,
    number_of_arguments => 0,
    enabled             => true,
    comments            => 'Scheduler program for movep task '||l_task_name);
  for prg_rec in (select program_action from user_scheduler_programs where program_name = l_prg_name)
  loop
    debug( prg_rec.program_action);
  end loop;
end;
/

undef l_degree
undef l_prg_name
undef l_prg_prefix
undef l_queue_name
undef l_resumable_timeout
undef l_task_name
undef l_ts_name
