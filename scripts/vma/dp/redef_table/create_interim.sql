def l_table_owner="&1."
def l_table_name="&2."
def l_tablespace_name="&3."
def l_table_name_int="&4."
def l_tablespace_name_int="&5."

declare 
  l_handle pls_integer;
  l_tr_handle pls_integer;
  l_table_owner         varchar2(30) := '&l_table_owner.';
  l_table_name          l_table_owner%type:= '&l_table_name.';
  l_tablespace_name     l_table_owner%type := '&l_tablespace_name.';
  l_table_name_int      l_table_owner%type := '&l_table_name_int.';
  l_tablespace_name_int l_table_owner%type := '&l_tablespace_name_int.';
  l_ddls sys.ku$_ddls;
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
  l_handle := sys.dbms_metadata.open( 'TABLE');
  sys.dbms_metadata.set_filter(l_handle, 'SCHEMA', l_table_owner);
  sys.dbms_metadata.set_filter(l_handle, 'NAME', l_table_name);
  l_tr_handle := sys.dbms_metadata.add_transform( l_handle, 'MODIFY');
  sys.dbms_metadata.set_remap_param( l_tr_handle, 'REMAP_NAME', l_table_name, l_table_name_int);
  sys.dbms_metadata.set_remap_param( l_tr_handle, 'REMAP_TABLESPACE', l_tablespace_name, l_tablespace_name_int);
  l_tr_handle := sys.dbms_metadata.add_transform( l_handle, 'DDL');
  sys.dbms_metadata.set_transform_param( l_tr_handle, 'CONSTRAINTS', false);
  sys.dbms_metadata.set_transform_param( l_tr_handle, 'REF_CONSTRAINTS', false);
  loop
    l_ddls := sys.dbms_metadata.fetch_ddl( l_handle);
    exit when l_ddls is null;
    for i in 1..cardinality(l_ddls)
    loop
      print_lob(l_ddls(i).ddlText);
      execute immediate l_ddls(i).ddlText;
    end loop;
  end loop;
  sys.dbms_metadata.close( l_handle);
end;
/
