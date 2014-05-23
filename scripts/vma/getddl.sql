-------------------------------------------------------------------------------
--
-- Script:      getddl.sql (get DDL)
-- Purpose:     Display DDL for specified objects
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @getddl object_type name <params>
--              where params can be any of the following in any combination:
--              constraints_as_alter=<true|false>               - constraints will be shown as alter
--              emit_schema=<true|false>                        - include schema on output
--              export=<true|false>                             - datapump behaviour
--              owner=<owner>                                   - object schema
--              segment_attributes=<true|false>                 - include segment attributes
--              sqlterminator=<true|false>                      - append sqlterminator
--              storage=<true|false>                            - include storage
--
-- Examples:
--              @getddl TABLE OBJ$ owner=SYS                    - get DDL for table SYS.OBJ$
--              @getddl TABLE OBJ$ owner=SYS,segment_attributes=false
--                                                              - same without segment_attributes
--              @getddl TABLE OBJ$ owner=SYS,sqlterminator=true - append SQLTERMINATOR
--
-- Versions:
--              Vers:   1.0.2.2
--                Auth: Velikikh M.
--                Date: 2014/02/10
--                Desc: added export parameter
--              Vers:   1.0.1.1
--                Auth: Velikikh M.
--                Date: 2013/09/13
--                Desc: added dbms_metadata.set_transform_param to DEFAULT
--                      added emit_schema parameter
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2013/09/12
--                Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

col 3 new_v 3 nopri

select '' "3" from dual where null^=null
/

def input="&3."
def object_type="&1."
def name="&2."

@eva "&input." constraints_as_alter emit_schema export owner segment_attributes storage sqlterminator

set term off

col if_constraints_as_alter new_v if_constraints_as_alter nopri
col if_emit_schema new_v if_emit_schema nopri
col if_export new_v if_export nopri
col if_sqlterminator new_v if_sqlterminator nopri
col if_storage new_v if_storage nopri
col if_segment_attributes new_v if_segment_attributes nopri

select nvl2('&constraints_as_alter.', '', '--') if_constraints_as_alter,
       nvl2('&emit_schema.', '', '--') if_emit_schema,
       nvl2('&export.', '', '--') if_export,
       nvl2('&sqlterminator.', '', '--') if_sqlterminator,
       nvl2('&storage.', '', '--') if_storage,
       nvl2('&segment_attributes', '', '--') if_segment_attributes
  from dual
/

set term on

begin
  null;
  &if_constraints_as_alter. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', &constraints_as_alter.);
  &if_emit_schema. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'EMIT_SCHEMA', &emit_schema.);
  &if_export. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'EXPORT', &export.);
  &if_sqlterminator. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'SQLTERMINATOR', &sqlterminator.);
  &if_storage. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'STORAGE', &storage.);
  &if_segment_attributes. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', &segment_attributes.);
end;
/

select dbms_metadata.get_ddl( '&object_type.', '&name.', '&owner.') get_ddl from dual
/

exec sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'DEFAULT')

undef input

undef name
undef object_type
undef owner
undef if_constraints_as_alter
undef constraints_as_alter
undef if_emit_schema
undef emit_schema
undef if_export
undef export
undef if_segment_attributes
undef segment_attributes
undef if_sqlterminator
undef sqlterminator
undef if_storage
undef storage

@restore_sqlplus_settings.sql
