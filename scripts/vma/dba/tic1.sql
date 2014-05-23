@save_sqlplus_settings

var table_owner varchar2(30)
var table_name varchar2(30)

exec :table_owner := '&1.'
exec :table_name := '&2.'

set echo off pages 100 serverout on size unlimited format wrapped

declare
  l_column_expression varchar2(100);
begin
  dbms_output.put_line('                                                         COLUMN');
  dbms_output.put_line('INDEX_NAME                     COLUMN_NAME               POS    PART(Y/N)');
  dbms_output.put_line('------------------------------ ------------------------- ------ ---------');

  for ind_rec in (
    select decode(ic.column_position, 1, i.index_name, ' ') index_name, ic.column_name, ie.column_expression, ic.column_position, i.partitioned
      from all_ind_columns ic,
           all_indexes i,
           all_ind_expressions ie
     where ic.table_name = :table_name
       and ic.table_owner = :table_owner
       and i.index_name = ic.index_name
       and i.table_name = :table_name
       and i.table_owner = :table_owner
       and ic.index_owner = ie.index_owner(+)
       and ic.index_name = ie.index_name(+)
       and ic.column_position = ie.column_position(+)
     order by ic.index_name, ic.column_position)
  loop
    l_column_expression := ind_rec.column_expression;
    dbms_output.put_line(
      rpad(ind_rec.index_name, 30, ' ')||' '||
      rpad(coalesce(l_column_expression, ind_rec.column_name), 40, ' ')||' '||
      rpad(ind_rec.column_position, 6, ' ')||' '||
      ind_rec.partitioned);
  end loop;
end;
/

undefine 1
undefine 2

@restore_sqlplus_settings
