-------------------------------------------------------------------------------
--
-- Script:	lmpost.sql
-- Purpose:	Logminer start script.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script runs Logminer. Lmpre.sql must be run before this.
--
-- Usage:       @lmpost.sql
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2014/02/14 15:04
--     Desc: Creation
--
-------------------------------------------------------------------------------
--DOCSTART
--
--lmpost.sql
-------------
--
--Logminer start script.
--
--lmpost.sql 
--DOCEND

@save_sqlplus_settings.sql

set timing off

var lm_endtime varchar2(30)

exec :lm_endtime:=to_char(sysdate)
exec sys.dbms_logmnr.start_logmnr( -
  starttime => to_date(:lm_starttime), -
  endtime   => to_date(:lm_endtime), -
  options   => sys.dbms_logmnr.dict_from_online_catalog + sys.dbms_logmnr.continuous_mine)

drop table v_logmnr_contents;
create table v_logmnr_contents as select * from v$logmnr_contents;

@restore_sqlplus_settings.sql
