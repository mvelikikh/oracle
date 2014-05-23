@save_sqlplus_settings.sql
col owner for a20
col object_name for a30
col object_type for a20
select owner, object_name, object_type from dba_objects where status<>'VALID';
@restore_sqlplus_settings.sql
