def l_table_owner="&1."
def l_table_name="&2."
def l_tablespace="&3."
def l_resumable_timeout="&4."
def l_parallel_min_pct="&5."
def l_workarea_size_policy="&6."
def l_sort_area_size="&7."

exec dbms_application_info.set_action( 'MOVE_LOB' )

declare
  subtype name_type is varchar2(30);
  l_table_owner         name_type := '&l_table_owner.';
  l_table_name          name_type := '&l_table_name.';
  l_tablespace     name_type := '&l_tablespace.';
  l_degree              int       := &l_degree.;
  l_parallel_min_pct_old int;
  l_parallel_min_pct_new int         := &l_parallel_min_pct.;
  l_resumable_timeout   int          := &l_resumable_timeout.;
  l_workarea_size_policy varchar2(6) :=lower('&l_workarea_size_policy');
  l_workarea_size_policy_old l_workarea_size_policy%type;
  l_sort_area_size       int         := &l_sort_area_size.;
  l_sort_area_size_old       l_sort_area_size%type;
  l_parallel_move boolean;
  l_intval binary_integer;
  l_strval varchar2(256);
  l_partyp binary_integer;
  l_sql_stmt varchar2(32767);
  -- session longops
  l_rindex    binary_integer := sys.dbms_application_info.set_session_longops_nohint;
  l_slno      binary_integer;
  l_totalwork number;
  l_sofar     number;
  l_obj       binary_integer;
  l_op_name   constant varchar2(60) := 'MOVE LOB';
  l_units     constant varchar2(60) := 'Lobs';
begin 
  if l_degree > 1 
  then
    l_parallel_move := true;
    l_partyp := sys.dbms_utility.get_parameter_value( 'parallel_min_percent', l_parallel_min_pct_old, l_strval);
    l_partyp := sys.dbms_utility.get_parameter_value( 'workarea_size_policy', l_intval, l_workarea_size_policy_old);
    l_partyp := sys.dbms_utility.get_parameter_value( 'sort_area_size', l_sort_area_size_old, l_strval);
    execute immediate 'alter session set parallel_min_percent=' || l_parallel_min_pct_new;
    execute immediate 'alter session set workarea_size_policy='||l_workarea_size_policy;
    execute immediate 'alter session set sort_area_size='||l_sort_area_size;
  end if; 
  execute immediate 'alter session enable resumable timeout '||l_resumable_timeout||' name ''Move_' || l_table_name || '''';
  -- Move lobs
  for lob_rec in (
    select column_name,
           count(1) over () total, 
           row_number() over (order by column_name) col_num
      from dba_lobs
     where owner = l_table_owner
       and table_name = l_table_name
     order by column_name)
  loop
    if l_totalwork is null
    then
      l_totalwork := lob_rec.total;
    end if;
    l_sql_stmt := 'alter table "'||l_table_owner||'"."'||l_table_name||'" move lob ("'||
      lob_rec.column_name||'") store as (tablespace '||l_tablespace||')';
    dbms_output.put_line( l_sql_stmt);
    sys.dbms_application_info.set_session_longops( 
      rindex      => l_rindex, 
      slno        => l_slno, 
      op_name     => l_op_name,
      sofar       => lob_rec.col_num - 1,
      totalwork   => l_totalwork,
      target_desc => 'Lob '||lob_rec.column_name,
      units       => l_units);
    execute immediate l_sql_stmt;
  end loop;
  sys.dbms_application_info.set_session_longops( 
    rindex      => l_rindex, 
    slno        => l_slno, 
    op_name     => l_op_name,
    sofar       => l_totalwork,
    totalwork   => l_totalwork,
    units       => l_units);
  if l_parallel_move
  then
    execute immediate 'alter session set parallel_min_percent='||l_parallel_min_pct_old;
    execute immediate 'alter session set workarea_size_policy='||l_workarea_size_policy_old;
    execute immediate 'alter session set sort_area_size='||l_sort_area_size_old;
  end if; 
end;
/
exec dbms_application_info.set_action( null )
