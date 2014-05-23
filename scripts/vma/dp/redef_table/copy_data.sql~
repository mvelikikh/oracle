def l_table_owner="&1."
def l_table_name="&2."
def l_table_redef_name="&3."
def l_degree="&4."
def l_resumable_timeout="&5."
def l_parallel_min_pct="&6."
def l_orderby_cols="&7."

exec sys.dbms_application_info.set_action( 'COPY_DATA' );

declare
  subtype name_type is varchar2(30);
  l_table_owner       name_type := '&l_table_owner.';
  l_table_name        name_type := '&l_table_name.';
  l_table_redef_name  name_type := '&l_table_redef_name.';
  l_degree            int       := &l_degree.;
  l_resumable_timeout int       := &l_resumable_timeout.;
	l_options_flag      binary_integer;
	l_orderby_cols varchar2(32767) := &l_orderby_cols.;
	l_parallel_min_pct_old int;
	l_parallel_min_pct_new int := &l_parallel_min_pct.;
begin 
  if l_degree > 1 
  then
	  select value
		  into l_parallel_min_pct_old
			from v$parameter
		 where name = 'parallel_min_percent';
    execute immediate 'ALTER SESSION FORCE PARALLEL DML PARALLEL ' || l_degree;
    execute immediate 'ALTER SESSION FORCE PARALLEL DDL PARALLEL ' || l_degree;
    execute immediate 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL ' || l_degree;
		execute immediate 'ALTER SESSION SET PARALLEL_MIN_PERCENT=' || l_parallel_min_pct_new;
  end if; 
  execute immediate 'ALTER SESSION ENABLE RESUMABLE TIMEOUT '||l_resumable_timeout||' NAME ''Redef ' || l_table_name || '''';

  select nvl2(max(1), sys.dbms_redefinition.cons_use_pk, sys.dbms_redefinition.cons_use_rowid)
	  into l_options_flag
		from dba_constraints
	 where owner = l_table_owner
	   and table_name = l_table_name
		 and constraint_type = 'P';

  dbms_output.put_line(' Options is: '||l_options_flag);

  sys.dbms_redefinition.start_redef_table(
    uname        => l_table_owner, 
    orig_table   => l_table_name, 
    int_table    => l_table_redef_name, 
    options_flag => l_options_flag,
	  orderby_cols => l_orderby_cols);
  if l_degree > 1 
  then
    execute immediate 'ALTER SESSION DISABLE PARALLEL DML';
    execute immediate 'ALTER SESSION DISABLE PARALLEL DDL';
    execute immediate 'ALTER SESSION DISABLE PARALLEL QUERY';
		execute immediate 'alter session set parallel_min_percent='||l_parallel_min_pct_old;
  end if; 
end;
/

col redef_mlog new_v redef_mlog
select log_table redef_mlog
  from dba_mview_logs mlog
 where log_owner = '&l_table_owner.'
	 and master = '&l_table_name.'
/

alter table &l_table_owner..&redef_mlog. noparallel;

exec sys.dbms_application_info.set_action( null )

