def l_queue_name="&1."
def l_queue_table="&2."

exec sys.dbms_aqadm.stop_queue( '&l_queue_name.')
exec sys.dbms_aqadm.drop_queue( '&l_queue_name.')
exec sys.dbms_aqadm.drop_queue_table( '&l_queue_table.')

undef l_queue_name
undef l_queue_table
