def l_table_owner="&1."
def l_table_name="&2."
def l_tablespace="&3."
def l_degree="&4."
def l_resumable_timeout="&5."
def l_parallel_min_pct="&6."
def l_workarea_size_policy="&7."
def l_sort_area_size="&8."

exec dbms_application_info.set_action( 'MOVE_INDEX' )

declare
  subtype name_type is varchar2(30);
  l_table_owner         name_type := '&l_table_owner.';
  l_table_name          name_type := '&l_table_name.';
  l_index_owner         name_type;
  l_tablespace     name_type := '&l_tablespace.';
  l_degree              int       := &l_degree.;
  l_parallel_min_pct_old int;
  l_parallel_min_pct_new int         := &l_parallel_min_pct.;
  l_resumable_timeout   int          := &l_resumable_timeout.;
  l_workarea_size_policy varchar2(6) :=lower('&l_workarea_size_policy');
  l_workarea_size_policy_old l_workarea_size_policy%type;
  l_sort_area_size       int         := &l_sort_area_size.;
  l_sort_area_size_old       l_sort_area_size%type;
  l_index_name name_type;
  l_parallel_move boolean;
  l_intval binary_integer;
  l_strval varchar2(256);
  l_partyp binary_integer;
  l_sql_stmt varchar2(32767);
  type ind_tbl_type is table of varchar2(40) index by varchar2(60);
  l_ind_tbl ind_tbl_type;
  -- session longops
  l_rindex    binary_integer := sys.dbms_application_info.set_session_longops_nohint;
  l_slno      binary_integer;
  l_totalwork number;
  l_sofar     number;
  l_obj       binary_integer;
  l_op_name   constant varchar2(60) := 'INDEX REBUILD';
  l_units     constant varchar2(60) := 'Indexes';
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
  -- Rebuild indexes
  for ind_rec in (
    select owner, index_name, degree, 
           count(1) over () total, 
           row_number() over (order by owner, index_name) index_num
      from dba_indexes
     where table_owner = l_table_owner
       and table_name = l_table_name
       and index_type not in ('LOB')
     order by owner, index_name)
  loop
    if l_totalwork is null
    then
      l_totalwork := ind_rec.total;
    end if;
    l_index_owner := ind_rec.owner;
    l_index_name := ind_rec.index_name;
    l_ind_tbl(l_index_owner||l_index_name) := ind_rec.degree;
    l_sql_stmt := 'alter index "'||l_index_owner||'"."'||l_index_name||'" rebuild '||
      case when l_parallel_move then 'parallel '||l_degree||' ' end ||
      'tablespace '||l_tablespace;
    dbms_output.put_line( l_sql_stmt);
    sys.dbms_application_info.set_session_longops( 
      rindex      => l_rindex, 
      slno        => l_slno, 
      op_name     => l_op_name,
      sofar       => ind_rec.index_num - 1,
      totalwork   => l_totalwork,
      target_desc => 'Index '||l_index_name,
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
  -- Alter index degree
  for ind_rec in (
    select owner, index_name
      from dba_indexes
     where table_owner = l_table_owner
       and table_name = l_table_name
       and index_type not in ('LOB'))
  loop
    l_index_owner := ind_rec.owner;
    l_index_name := ind_rec.index_name;
    l_sql_stmt := 'alter index "'||l_index_owner||'"."'||l_index_name||'" parallel '||l_ind_tbl(l_index_owner||l_index_name);
    dbms_output.put_line( l_sql_stmt);
    execute immediate l_sql_stmt;
  end loop;
  if l_parallel_move
  then
    execute immediate 'alter session set parallel_min_percent='||l_parallel_min_pct_old;
    execute immediate 'alter session set workarea_size_policy='||l_workarea_size_policy_old;
    execute immediate 'alter session set sort_area_size='||l_sort_area_size_old;
  end if; 
end;
/
exec dbms_application_info.set_action( null )
