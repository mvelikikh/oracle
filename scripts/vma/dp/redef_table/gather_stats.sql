def l_table_owner="&1."
def l_table_name="&2."
def l_par_count="&3."

exec sys.dbms_application_info.set_action( 'GATHER_STATS')

exec sys.dbms_stats.gather_table_stats( '&l_table_owner.', '&l_table_name.', degree=> &l_par_count., cascade=> false)

exec sys.dbms_application_info.set_action( null)
