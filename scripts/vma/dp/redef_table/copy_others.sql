def l_table_owner="&1."
def l_table_name="&2."
def l_table_redef_name="&3."

var num_errors number

exec sys.dbms_application_info.set_action( 'COPY_OTHERS')

exec sys.dbms_redefinition.copy_table_dependents( -
  uname            => '&l_table_owner.', -
  orig_table       => '&l_table_name.', -
  int_table        => '&l_table_redef_name.', -
  copy_indexes     => 0, -
  copy_triggers    => true, -
  copy_constraints => true, -
  copy_privileges  => true, -
  ignore_errors    => false, -
  num_errors       => :num_errors, -
  copy_statistics  => false, -
  copy_mvlog       => true)

print num_errors

select to_number('FAIL_ON_ERROR') from dual where :num_errors>0;

exec sys.dbms_application_info.set_action( null)
