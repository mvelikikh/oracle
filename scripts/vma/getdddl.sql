-------------------------------------------------------------------------------
--
-- Script:	getdddl.sql
-- Purpose:	Display dependent metadata for specified object as DDL
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display DDL for given object
--
-- Usage:       @getdddl.sql "<object_type> <name> <params>"
--
-- Change history:
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 2013/12/24 11:06
--     Desc: emit_schema added
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/09/18 14:49
--     Desc: Creation
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

@eva "&input." base_object_schema constraints_as_alter emit_schema segment_attributes sqlterminator storage

set term off

col if_constraints_as_alter new_v if_constraints_as_alter nopri
col if_emit_schema new_v if_emit_schema nopri
col if_sqlterminator new_v if_sqlterminator nopri
col if_storage new_v if_storage nopri
col if_segment_attributes new_v if_segment_attributes nopri

select nvl2('&constraints_as_alter.', '', '--') if_constraints_as_alter,
       nvl2('&emit_schema.', '', '--') if_emit_schema,
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
  &if_segment_attributes. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', &segment_attributes.);
  &if_sqlterminator. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'SQLTERMINATOR', &sqlterminator.);
  &if_storage. sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'STORAGE', &storage.);
end;
/

select sys.dbms_metadata.get_dependent_ddl( '&object_type.', '&name.', '&base_object_schema.') get_dependent_ddl 
  from dual
/

exec sys.dbms_metadata.set_transform_param( sys.dbms_metadata.session_transform, 'DEFAULT')

undef input

undef name
undef object_type
undef base_object_schema
undef if_constraints_as_alter
undef constraints_as_alter
undef if_emit_schema
undef emit_schema
undef if_segment_attributes
undef segment_attributes
undef if_sqlterminator
undef sqlterminator
undef if_storage
undef storage

col if_constraints_as_alter cle
col if_emit_schema cle
col if_segment_attributes cle
col if_sqlterminator cle
col if_storage cle

@restore_sqlplus_settings.sql
