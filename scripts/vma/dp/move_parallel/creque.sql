def l_task_name="&1."
def l_queue_name="&2."
def l_queue_table="&3."

exec sys.dbms_aqadm.stop_queue( '&l_queue_name.')
exec sys.dbms_aqadm.drop_queue( '&l_queue_name.')
exec sys.dbms_aqadm.drop_queue_table( '&l_queue_table.')

exec sys.dbms_aqadm.create_queue_table( -
  queue_table        => '&l_queue_table.', -
  queue_payload_type => 'sys.xmltype', -
  comment            => 'Queue table for movep task &l_task_name.')

exec sys.dbms_aqadm.create_queue( -
  queue_name  => '&l_queue_name.', -
  queue_table => '&l_queue_table.', -
  comment     => 'Queue for movep task &l_task_name.')

exec sys.dbms_aqadm.start_queue( queue_name=> '&l_queue_name.')

undef l_task_name
undef l_queue_name
undef l_queue_table
