-- Expert-Oracle-Database-Architecture 2ed
-- save/restore_sqlplus_settings added by me
@save_sqlplus_settings.sql
set echo off
set verify off
column value new_val V
define S="&1"
set autotrace off
select a.name, b.value
from v$statname a, v$mystat b
where a.statistic# = b.statistic#
and lower(a.name) like '%' || lower('&S')||'%'
/
@restore_sqlplus_settings.sql