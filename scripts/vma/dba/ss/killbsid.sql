@save_sqlplus_settings.sql

set timing off
set define on
set ver off
set hea off
set echo off
set feed off

define sid=&1.
col serial new_value serial noprint

select serial# serial
  from v$session
 where sid=&sid.;

set feed on

prompt alter system kill session '&sid.,&serial.';

alter system kill session '&sid.,&serial.';

@restore_sqlplus_settings.sql