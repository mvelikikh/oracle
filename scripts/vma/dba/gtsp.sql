@save_sqlplus_settings.sql

set echo on
set ver on
exec dbms_stats.gather_table_stats (ownname => '&1.', tabname => '&2.', cascade => true, no_invalidate => false, degree => &3.);
set echo off

@restore_sqlplus_settings.sql