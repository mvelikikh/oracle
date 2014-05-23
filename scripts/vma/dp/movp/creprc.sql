def l_degree="&1."
def l_task_name="&2."
def l_ts_name="&3."
def l_objtab="&4."
def l_prc_name="&5."
def l_resumable_timeout="&6."

create or replace procedure &l_prc_name.(
  p_start_id int,
  p_end_id   int)
is
  subtype name_type is varchar2(30);
  l_degree constant pls_integer := &l_degree.;
  l_resumable_timeout constant pls_integer := &l_resumable_timeout.;
  l_ts_name constant name_type := '&l_ts_name.';
  l_task_name constant name_type := '&l_task_name.';
  l_sts_in_progress constant &l_objtab..processed%type := 'IN_PROGRESS';
  l_sts_processed constant &l_objtab..processed%type := 'PROCESSED';
  l_owner name_type;
  l_objname name_type;
  procedure rebuild_index(
    p_owner   in name_type,
    p_name    in name_type,
    p_type    in name_type,
    p_degree  in pls_integer,
    p_ts_name in name_type)
  is
    l_sql_stmt clob;
  begin
    if p_type not in ('DOMAIN')
    then
      l_sql_stmt := 'alter index "'||p_owner||'"."'||p_name||'" rebuild parallel '||p_degree||' tablespace '||p_ts_name;
      execute immediate l_sql_stmt;
    else
      -- todo: domain index move currently not implemented
      l_sql_stmt := 'alter index "'||p_owner||'"."'||p_name||'" rebuild parallel '||p_degree;
      execute immediate l_sql_stmt;
    end if;
    l_sql_stmt := 'alter index "'||p_owner||'"."'||p_name||'" noparallel';
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
      select owner, index_name, index_type
        from dba_indexes
       where table_owner = p_owner
         and table_name = p_name
         and index_type not in ('LOB'))
    loop
      rebuild_index( ind_rec.owner, ind_rec.index_name, ind_rec.index_type, p_degree, p_ts_name);
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
    l_sql_stmt := 'alter table "'||p_owner||'"."'||p_name||'" move lob('||p_col_name||') store as (tablespace '||p_ts_name||')';
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
    l_sql_stmt := 'alter table "'||p_owner||'"."'||p_name||'" move parallel '||p_degree||' tablespace '||p_ts_name;
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
  procedure lock_object(
    p_id in &objtab..id%type,
    x_owner out name_type,
    x_objname out name_type)
  is
    pragma autonomous_transaction;
  begin
    update &objtab.
       set start_date = sysdate,
           processed = l_sts_in_progress,
           navi_date = sysdate,
           navi_sessionid = sys_context( 'userenv', 'sessionid')
     where id = p_id
     returning owner, name into x_owner, x_objname;
    commit;
  end lock_object;
  procedure set_processed(
    p_id in &objtab..id%type)
  is
    pragma autonomous_transaction;
  begin
    update &objtab.
       set processed = l_sts_processed,
           navi_date = sysdate,
           navi_sessionid = sys_context( 'userenv', 'sessionid'),
           processed_date = sysdate
     where id = p_id;
    commit;
  end set_processed;
begin
  execute immediate 'alter session enable resumable timeout '||l_resumable_timeout||' name '''||l_task_name||'''';
  lock_object( p_start_id, l_owner, l_objname);
  move( l_owner, l_objname, l_degree, l_ts_name);
  set_processed( p_start_id);
end &l_prc_name.;
/

undef l_degree
undef l_task_name
undef l_ts_name
undef l_objtab
undef l_prc_name
undef l_resumable_timeout
