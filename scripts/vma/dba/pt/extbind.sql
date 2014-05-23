-------------------------------------------------------------------------------
--
-- Script:	extbind.sql
-- Purpose:	Convert raw bind-data to human readable form
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display bind-data information for given sql_id
--
-- Usage:       @extbind.sql SQL_ID
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 06/13/24 08:38
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--extbind.sql
-------------
--
--Extract bind for given SQL and convert to human-readable format.
--
--extbind.sql {sql_id}
--
--DOCEND
@save_sqlplus_settings
          
set pages 200 timi off lin 155
whenever sqlerror continue

define _sql_id="&1."

break on child_number skip 1
col child_number for 999999 hea CHILD#
col name for a30
col position for 999 hea POS
col dup_position for 999999 hea DUPPOS
col datatype for 999 hea DTY
col datatype_string for a14 hea DTY_STRING
col character_sid for 9999 hea CSID
col precision for 9999 hea PRCS
col scale for 9999 hea SCAL
col max_length for 999999 hea MAXLEN
col value_string for a30
col value_anydata for a30

select sq.child_number,
       eb.name,
       eb.position,
       eb.dup_position,
       eb.datatype,
       eb.datatype_string,
       eb.character_sid,
       eb.precision,
       eb.scale,
       eb.max_length,
       eb.last_captured,
       eb.value_string
  from v$sql sq,
       table(dbms_sqltune.extract_binds(hextoraw(sq.bind_data)))(+) eb
 where sq.sql_id = '&_sql_id.'
 order by sq.child_number, eb.position;

undefine 1
undefine _sql_id

@restore_sqlplus_settings
