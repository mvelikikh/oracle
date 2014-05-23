-------------------------------------------------------------------------------
--
-- Script:	capstt.sql
-- Purpose:	Returns Streams Capture state and other capture metrics
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about given capture process
--
-- Usage:       @capstt.sql [CAPTURE_NAME]
--
-- Change history:
--   Vers:   1.0.2.2
--     Auth: Velikikh M.
--     Date: 2013/12/16 11:13
--     Desc: Added eva usage
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 12/02/13 10:26
--     Desc: Added clear columns
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 08/27/12 08:45
--     Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings          
set echo off pages 200 timi off lin 155
whenever sqlerror continue

col 1 new_value 1 noprint
select '' "1" from dual where null=null;

@evadef "&1." l_capture_name

set hea on term on

col capture_name for a20
col state for a50
col capture_message_create_time for a20 hea "CAPTURE MESSAGE|CREATETIME"
col lag_fmt for a10 hea "LATENCY"

select capture_name,
       state,
       capture_message_create_time,
       to_char(trunc(lag_secs/3600), 'fm999999999999990')||':'||
       to_char(mod(trunc(lag_secs/60), 60), 'fm00')||':'||
       to_char(mod(lag_secs, 60), 'fm00') lag_fmt
  from (select capture_name, 
               state, 
               capture_message_create_time,
               (sysdate-capture_message_create_time)*86400 lag_secs
          from v$streams_capture
         where capture_name = nvl('&l_capture_name.', capture_name))
/

pro

undef 1
undef l_capture_name

col 1 cle
col capture_message_create_time cle
col capture_name cle
col lag_fmt cle
col state cle

@restore_sqlplus_settings
