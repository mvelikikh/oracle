def l_table_owner="&1."
def l_table_name="&2."
def l_table_name_int="&3."
def l_degree="&4."
def l_resumable_timeout="&5."

exec dbms_application_info.set_action( 'COPY_CONSTRAINT' )

declare
  subtype name_type is varchar2(30);
  l_table_owner         name_type := '&l_table_owner.';
  l_table_name          name_type := '&l_table_name.';
  l_table_name_int      name_type := '&l_table_name_int.';
  l_tablespace_name     name_type := '&l_tablespace_name.';
  l_tablespace_name_int name_type := '&l_tablespace_name_int.';
  l_degree              int       := &l_degree.;
  l_resumable_timeout   int       := &l_resumable_timeout.;
  -- local vars
  l_handle pls_integer;
  l_tr_handle pls_integer;
  l_ddls sys.ku$_ddls;
  l_start_time int;
  l_constraint_name name_type;
  procedure print_lob(p_clob in clob)
  is
    l_linesize pls_integer := 255;
    l_buffer   varchar2(255);
    l_length   pls_integer;
  begin
    l_length := dbms_lob.getlength(p_clob);
    for i in 0..floor(l_length/l_linesize)
    loop
      l_buffer := dbms_lob.substr(p_clob, l_linesize, 1+l_linesize*i);
      dbms_output.put_line(l_buffer);
    end loop;
  end print_lob;
begin 
  if l_degree > 1 
  then
    execute immediate 'ALTER SESSION ENABLE PARALLEL DML';
    execute immediate 'ALTER SESSION FORCE PARALLEL DML PARALLEL ' || l_degree;
    execute immediate 'ALTER SESSION FORCE PARALLEL DDL PARALLEL ' || l_degree;
    execute immediate 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL ' || l_degree;
  end if; 
  execute immediate 'ALTER SESSION ENABLE RESUMABLE TIMEOUT '||l_resumable_timeout||' NAME ''Redef ' || l_table_name || '''';
  l_handle := sys.dbms_metadata.open( 'CONSTRAINT');
  sys.dbms_metadata.set_filter(l_handle, 'BASE_OBJECT_SCHEMA', l_table_owner);
  sys.dbms_metadata.set_filter(l_handle, 'BASE_OBJECT_NAME', l_table_name);
  l_tr_handle := sys.dbms_metadata.add_transform( l_handle, 'MODIFY');
  sys.dbms_metadata.set_remap_param( l_tr_handle, 'REMAP_NAME', l_table_name, l_table_name_int);
  sys.dbms_metadata.set_remap_param( l_tr_handle, 'REMAP_TABLESPACE', l_tablespace_name, l_tablespace_name_int);
  -- Remap constraint names
  for cons_rec in (
    select constraint_name
      from dba_constraints
     where owner = l_table_owner
       and table_name = l_table_name
       and generated = 'USER NAME'
       and constraint_type <> 'R')
  loop
    l_constraint_name := substr(cons_rec.constraint_name, 1, 26)||'_INT';
    sys.dbms_metadata.set_remap_param( l_tr_handle, 'REMAP_NAME', cons_rec.constraint_name, l_constraint_name);
  end loop;
  --
  l_tr_handle := sys.dbms_metadata.add_transform( l_handle, 'DDL');
  sys.dbms_metadata.set_transform_param( l_tr_handle, 'SEGMENT_ATTRIBUTES', false);
  loop
    l_ddls := sys.dbms_metadata.fetch_ddl( l_handle);
    exit when l_ddls is null;
    for i in 1..cardinality(l_ddls)
    loop
      print_lob(l_ddls(i).ddlText);
      l_start_time := dbms_utility.get_time;
      execute immediate l_ddls(i).ddlText;
      dbms_output.put_line( 'Elapsed: '||round((dbms_utility.get_time-l_start_time)/1e2));
    end loop;
  end loop;
  -- Register dependent objects
  for cons_rec in (
    select constraint_name, substr(constraint_name, 1, 26)||'_INT' constraint_name_int
      from dba_constraints
     where owner = l_table_owner
       and table_name = l_table_name
       and generated = 'USER NAME'
       and constraint_type <> 'R'
     union all
    select src.constraint_name, dst.constraint_name constraint_name_int
      from (
           select con.constraint_name,
                  con.constraint_type,
                  listagg(conc.column_name, ',') within group (order by conc.position) cols
             from dba_constraints con,
                  dba_cons_columns conc
            where con.owner = l_table_owner
              and con.table_name = l_table_name
              and con.generated = 'GENERATED NAME'
              and con.constraint_type <> 'R'
              and conc.owner = con.owner
              and conc.constraint_name = con.constraint_name
            group by con.constraint_type, con.constraint_name) src,
           (
           select con.constraint_name,
                  con.constraint_type,
                  listagg(conc.column_name, ',') within group (order by conc.position) cols
             from dba_constraints con,
                  dba_cons_columns conc
            where con.owner = l_table_owner
              and con.table_name = l_table_name_int
              and con.generated = 'GENERATED NAME'
              and con.constraint_type <> 'R'
              and conc.owner = con.owner
              and conc.constraint_name = con.constraint_name
            group by con.constraint_type, con.constraint_name) dst
     where dst.cols = src.cols
       and dst.constraint_type = src.constraint_type)
  loop
    l_constraint_name := cons_rec.constraint_name_int;
    sys.dbms_redefinition.register_dependent_object(
      uname         => l_table_owner,
      orig_table    => l_table_name,
      int_table     => l_table_name_int,
      dep_type      => sys.dbms_redefinition.cons_constraint,
      dep_owner     => l_table_owner,
      dep_orig_name => cons_rec.constraint_name,
      dep_int_name  => l_constraint_name);
  end loop;
  sys.dbms_metadata.close( l_handle);
end;
/
exec dbms_application_info.set_action( null )

