def l_table_owner="&1."
def l_table_name="&2."
def l_tablespace="&3."
def l_degree="&4."
def l_resumable_timeout="&5."
def l_parallel_min_pct="&6."

exec sys.dbms_application_info.set_action( 'MOVE_TABLE' );

declare
  subtype name_type is varchar2(30);
  l_table_owner       name_type := '&l_table_owner.';
  l_table_name        name_type := '&l_table_name.';
  l_tablespace        name_type := '&l_tablespace.';
  l_degree            int       := &l_degree.;
  l_resumable_timeout int       := &l_resumable_timeout.;
  l_parallel_min_pct_old int;
  l_parallel_min_pct_new int := &l_parallel_min_pct.;
  l_sql_stmt varchar2(32767);
  l_parallel_move boolean;
  l_intval binary_integer;
  l_strval varchar2(256);
  l_partyp binary_integer;
  l_partitioned dba_tables.partitioned%type;
begin 
  if l_degree > 1 
  then
    l_parallel_move := true;
    l_partyp := sys.dbms_utility.get_parameter_value( 'parallel_min_percent', l_parallel_min_pct_old, l_strval);
    execute immediate 'alter session set parallel_min_percent=' || l_parallel_min_pct_new;
  end if; 
  execute immediate 'alter session enable resumable timeout '||l_resumable_timeout||' name ''MOVE_' || l_table_name || '''';

  select partitioned
    into l_partitioned
    from dba_tables
   where owner = l_table_owner
     and table_name = l_table_name;
  if l_partitioned = 'NO'
  then
    l_sql_stmt := 'alter table "'||l_table_owner||'"."'||l_table_name||'" move '||
      case when l_parallel_move then ' parallel '||l_degree||' ' end ||
      'tablespace "'||l_tablespace||'"';
    dbms_output.put_line( l_sql_stmt);
    execute immediate l_sql_stmt;
  else
    l_sql_stmt := 'alter table "'||l_table_owner||'"."'||l_table_name||'" modify default attributes '||
      'tablespace "'||l_tablespace||'"';
    dbms_output.put_line( l_sql_stmt);
    execute immediate l_sql_stmt;
    for part_rec in (
      select partition_name
        from dba_tab_partitions
       where table_owner = l_table_owner
         and table_name = l_table_name)
    loop
      l_sql_stmt := 'alter table "'||l_table_owner||'"."'||l_table_name||'" move partition "'||part_rec.partition_name||'"'||
        case when l_parallel_move then ' parallel '||l_degree||' ' end ||
        'tablespace "'||l_tablespace||'"';
      dbms_output.put_line( l_sql_stmt);
      execute immediate l_sql_stmt;
    end loop;
  end if;
  if l_degree > 1 
  then
    execute immediate 'alter session set parallel_min_percent='||l_parallel_min_pct_old;
  end if; 
end;
/

exec sys.dbms_application_info.set_action( null )
