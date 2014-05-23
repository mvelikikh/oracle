--DOCSTART
--
--stautrpt.sql
--------------
--
--SQL Tuning Advisor Auto Task report.
--
--stautrpt.sql
--
--DOCEND
-- sql tuning advisor auto report
@save_sqlplus_settings.sql
var rpt clob
exec :rpt:=dbms_sqltune.report_auto_tuning_task( type=> 'text', level=> 'typical', section=> 'all')
print rpt
@restore_sqlplus_settings.sql
