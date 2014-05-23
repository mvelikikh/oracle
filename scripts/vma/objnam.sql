-------------------------------------------------------------------------------
--
-- Script:      objnam.sql (OBJect Name)
-- Purpose:     Show objects for given owner/object_name.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @objnam <owner> <name> [type=<type>]
--              owner   - object owner (regexp)
--              name    - object name (regexp)
--              type    - object type (regexp)
--
-- Examples:
--              @objnam SYS DBMS_RANDOM                         - information for object SYS DBMS_RANDOM
--              @objnam SYS DBMS_RANDOM type=PACKAGE            - information for package SYS DBMS_RANDOM
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/04/29 11:41
--                Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set timi off term off

col "2" new_v 2
col "3" new_v 3
select '' "2", '' "3" from dual where null^=null;

def o_owner="&1."
def o_name="&2."

def eva_input="&3."

@eva "&eva_input." type

col if_type new_v if_type
select nvl2(q'#&type.#', '', '--') if_type
  from dual;

col o_owner hea "OWNER"
col o_object_name hea "OBJECT_NAME" for a30
col o_subobject_name hea "SUBOBJECT_NAME"
col o_object_type hea "OBJECT_TYPE"
col o_created hea "CREATED"
col o_last_ddl_time hea "LAST_DDL_TIME"
col o_status hea "STATUS"

set term on

select owner o_owner,
       object_name o_object_name,
       subobject_name o_subobject_name,
       object_type o_object_type,
       created o_created,
       last_ddl_time o_last_ddl_time,
       status o_status
  from dba_objects
 where regexp_like( owner, q'#&o_owner.#', 'i')
   and regexp_like( object_name, q'#&o_name.#', 'i')
   &if_type. and regexp_like( object_type, q'#&type.#', 'i')
/

col if_type cle

col o_owner cle
col o_object_name cle
col o_subobject_name cle
col o_object_type cle
col o_created cle
col o_last_ddl_time cle
col o_status cle

undef o_owner
undef o_name

undef type
undef if_type

undef 1
undef 2

@restore_sqlplus_settings
