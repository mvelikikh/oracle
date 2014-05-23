-------------------------------------------------------------------------------
--
-- Script:	lmpre.sql
-- Purpose:	Logminer prepare script.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script prepares environment to run some tests and run Logminer afterwards.
--
-- Usage:       @lmpre.sql
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
--lmpre.sql
-------------
--
--Logminer prepare script.
--
--lmpre.sql 
--DOCEND

@save_sqlplus_settings.sql

set timing off

var lm_starttime varchar2(30)
exec :lm_starttime := to_char(sysdate)

@restore_sqlplus_settings.sql
