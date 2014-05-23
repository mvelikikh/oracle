@save_sqlplus_settings

define tabown="&1."
define tabname="&2."

set echo off pages 100

col index_name for a30
col column_name for a25
col column_position for 99999 hea "COLUMN|POS" jus l
col partitioned hea "PART(Y/N)" for a9

break on index_name
select i.index_name, ic.column_name, ic.column_position, i.partitioned
  from dba_ind_columns ic,
       dba_indexes i
 where ic.table_name = '&tabname.'
   and ic.table_owner = '&tabown.'
   and i.index_name = ic.index_name
   and i.table_name = '&tabname.'
   and i.table_owner = '&tabown.'
 order by 1,3;

undefine 1
undefine 2

@restore_sqlplus_settings
