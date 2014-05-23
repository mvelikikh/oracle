-------------------------------------------------------------------------------
--
-- Script:	whoami.sql
-- Purpose:	Display session information for current session.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	Session information report for current session.
--
-- Usage:       @whoami.sql
--
-- Change history:
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 2013/12/05 09:03
--     Desc: Added instance information. Rewritten for RAC
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/10/28 14:47
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--whoami.sql
------------
--
--Session information report for current session.
--
--whoami.sql
--
--DOCEND
@save_sqlplus_settings.sql

set echo off timi off

col current_schema for a20 hea SCHEMA
col current_user like current_schema hea USER
col host_name for a20
col instance_name for a8 hea INSTANCE
col sid for 99999
col spid for a9
col tracefile for a80
col version for a10

select /*+ LEADING(@"SEL$66C44981" "W"@"SEL$4" "E"@"SEL$4" "S"@"SEL$4" "X$KSUPR"@"SEL$7") */
       sys_context('userenv', 'current_user') current_user,
       sys_context('userenv', 'current_schema') current_schema,
			 s.sid, s.serial#, p.spid, s.server, s.logon_time, p.tracefile, 
       i.host_name, i.instance_name, i.version, i.startup_time
  from gv$session s,
       gv$process p,
       gv$instance i
 where s.sid = sys_context( 'userenv', 'sid')
   and p.addr = s.paddr
   and i.inst_id = s.inst_id;

col current_schema cle
col current_user cle
col host_name cle
col instance_name cle
col sid cle
col spid cle
col tracefile cle
col version cle

@restore_sqlplus_settings.sql
