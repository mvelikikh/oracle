--DOCSTART
--
--gps.sql
------------
--
--Gather extended row source execution statistics for SQL in script.
--
--gps.sql {script_file}
--
--DOCEND
@save_sqlplus_settings.sql

set serverout on size unlimited

define _script_name="&1."


begin
  for qry_rec in (
    @&_script_name.
  )
  loop
    null;
  end loop;
  for plan_rec in (
    select plan_table_output
      from table(dbms_xplan.display_cursor(format=> 'allstats last')))
  loop
    dbms_output.put_line(plan_rec.plan_table_output);
  end loop;
end;
/

undefine _script_name

@restore_sqlplus_settings.sql
