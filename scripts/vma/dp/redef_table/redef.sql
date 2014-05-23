@vma/dp/header redef
@@config

whenever oserror exit failure
whenever sqlerror exit failure

timi start redef
DOC
  Script: create_interim 
#
@@create_interim &owner. &table. &tablespace. &table_int. &tablespace_int.

DOC
  Script: copy_data
#
@@copy_data &owner. &table. &table_int. &par_count. &resumable_timeout. &parallel_min_pct. &orderby_cols.

DOC
  Script: copy_index
#
@@copy_index &owner. &table. &tablespace. &table_int. &tablespace_int. &par_count. &resumable_timeout. &parallel_min_pct. &workarea_size_policy. &sort_area_size.

DOC
  Script: copy_constraint
#
@@copy_constraint &owner. &table. &table_int. &par_count. &resumable_timeout.

--DOC
--  Script: copy_ref_constraint
--#
--@@copy_ref_constraint &owner. &table. &table_int. &par_count. &resumable_timeout.
--
DOC
  Script: copy_others
#
@@copy_others &owner. &table. &table_int.

DOC
  Script: gather mlog stats
#
@@gather_stats &owner. &redef_mlog. &par_count.

DOC
  Script: inline sync
#
exec sys.dbms_redefinition.sync_interim_table( '&owner.', '&table.', '&table_int.')

DOC
  Script: gather_stats
#
@@gather_stats &owner. &table_int. &par_count.

DOC
  Script: inline finish
#
exec sys.dbms_redefinition.finish_redef_table( '&owner.', '&table.', '&table_int.')

select num_rows from dba_tab_statistics where owner='&owner.' and table_name='&table.';

timi stop

spool off
