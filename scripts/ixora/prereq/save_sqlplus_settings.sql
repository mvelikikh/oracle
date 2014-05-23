-------------------------------------------------------------------------------
--
-- Script:	save_sqlplus_settings.sql
-- Purpose:	to reset sqlplus settings
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------

set termout off
store set sqlplus_settings replace
cl bre
set feedback off
set verify off
set termout on
set define "&"


