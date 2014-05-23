declare
  cursor ind_csr is
    with tabs as (select q'[QP$_AGENT]' c from dual union all
    select q'[QP$_AGENT_PARAMETERS]' c from dual union all
    select q'[QP$_AG_DIR_FLAT]' c from dual union all
    select q'[QP$_CITY]' c from dual union all
    select q'[QP$_DIRECTION]' c from dual union all
    select q'[QP$_MONEYTRANSFER_SYSTEMS]' c from dual union all
    select q'[TUNING]' c from dual)
    select ind.owner, ind.table_name, ind.index_name, ind.uniqueness, cons.constraint_name, cons.constraint_type, obj.created
      from dba_indexes ind,
           tabs t,
           dba_constraints cons,
           dba_objects obj
     where ind.table_owner = 'TBE_QPAY' 
       and ind.table_name = t.c
       and ind.owner = cons.index_owner(+)
       and ind.index_name = cons.index_name(+)
       and ind.owner = obj.owner(+)
       and ind.index_name = obj.object_name(+)
     order by 1,2;
  l_ind_rec ind_csr%rowtype;
  procedure print_lob(
    p_data in clob)
  is
    l_buffer_size constant pls_integer := 32767;
    l_buffer varchar2(32767);
  begin
    l_buffer := sys.dbms_lob.substr(p_data, l_buffer_size, 1);
    dbms_output.put_line( l_buffer);
  end print_lob;
  procedure rebuild_index(p_ind_rec in ind_csr%rowtype)
  is
    l_ddl clob;
    l_create_ddl clob;
    cursor fk_csr(p_owner in varchar2, p_constraint_name in varchar2)
    is
      select owner, table_name, constraint_name
        from dba_constraints
       where r_owner = p_owner
         and r_constraint_name = p_constraint_name;
  begin
    --dbms_output.put_line( 'INDEX_NAME: '||p_ind_rec.index_name||' CONSTRAINT_NAME: '||p_ind_rec.constraint_name||' TYPE: '||p_ind_rec.constraint_type);
    if p_ind_rec.index_name is not null and p_ind_rec.constraint_name is null
    then
      -- indexes without constraints can be safely dropped and recreated
      l_create_ddl := sys.dbms_metadata.get_ddl( 'INDEX', p_ind_rec.index_name, p_ind_rec.owner);
      -- drop index
      l_ddl := 'DROP INDEX "'||sys.dbms_assert.SCHEMA_NAME( p_ind_rec.owner)||'"."'||sys.dbms_assert.SIMPLE_SQL_NAME( p_ind_rec.index_name)||'"';
      print_lob( l_ddl);
      print_lob( l_create_ddl);
    elsif p_ind_rec.index_name is not null 
      and p_ind_rec.uniqueness = 'UNIQUE' 
      and p_ind_rec.constraint_name = p_ind_rec.index_name
      and p_ind_rec.constraint_type = 'P'
    then
      -- primary key with same index 
      -- disable fk
      for fk_rec in fk_csr(p_ind_rec.owner, p_ind_rec.constraint_name)
      loop
        l_ddl := 'ALTER TABLE "'||fk_rec.owner||'"."'||fk_rec.table_name||'" DISABLE CONSTRAINT "'||fk_rec.constraint_name||'"';
        print_lob( l_ddl);
      end loop;
      --
      l_ddl := 'ALTER TABLE "'||sys.dbms_assert.schema_name( p_ind_rec.owner)||'"."'||sys.dbms_assert.simple_sql_name( p_ind_rec.table_name)||'" DISABLE PRIMARY KEY DROP INDEX';
      print_lob( l_ddl);
      l_ddl := 'ALTER TABLE "'||sys.dbms_assert.schema_name( p_ind_rec.owner)||'"."'||sys.dbms_assert.simple_sql_name( p_ind_rec.table_name)||'" ENABLE PRIMARY KEY';
      print_lob( l_ddl);
      -- enable fk
      for fk_rec in fk_csr(p_ind_rec.owner, p_ind_rec.constraint_name)
      loop
        l_ddl := 'ALTER TABLE "'||fk_rec.owner||'"."'||fk_rec.table_name||'" ENABLE CONSTRAINT "'||fk_rec.constraint_name||'"';
        print_lob( l_ddl);
      end loop;
    else
      -- unhandled
      raise_application_error( -20000, 'Undefined branch');
    end if;
  end rebuild_index;
begin
  open ind_csr;
  sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
  loop
    fetch ind_csr into l_ind_rec;
    exit when ind_csr%notfound;
    rebuild_index(l_ind_rec);
  end loop;
  close ind_csr;
  sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'DEFAULT');
end;
/
