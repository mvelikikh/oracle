-------------------------------------------------------------------------------
--
-- Script:	tsseg.sql
-- Purpose:	Display tablespace segments in different dimensions
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) FTC LLC
-- Author:	Velikikh Mikhail
--
-- Description:	This script display information about tablespace segments
--
-- Usage:       @tsseg.sql "<tablespace>" "{<owner>|owner=<owner regexp>|
--                segment_name=<segment regexp>|gby=<gby cols>|
--                partition_name=<partition regexp>|oby=<oby cols>|
--                segment_type=<segment_type regexp>}"
--
-- Change history:
--   Vers:   1.0.0.0
--     Auth: Velikikh M.
--     Date: 2013/10/21 09:40
--     Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

--
-- Drop the HELP table in a PL/SQL block so that the unnecessary error 
-- ORA-0942 can be suppressed when table does not exist.
-- 

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE HELP';
  EXCEPTION WHEN OTHERS THEN
  IF (SQLCODE = -942) THEN
   NULL;
  ELSE
   RAISE;
  END IF;
END;
/

--
-- Create the HELP table
--
CREATE TABLE HELP
(
  TOPIC VARCHAR2 (50) NOT NULL,
  SEQ   NUMBER        NOT NULL,
  INFO  VARCHAR2 (80),
  constraint help_pk primary key (topic, seq)
) 
  organization index tablespace users;

--
-- Insert the data into HELP.
--

@@helpus.sql

@restore_sqlplus_settings.sql
