-------------------------------------------------------------------------------
--
-- Script:      desc.sql (DESCribe helper)
-- Purpose:     Lists the column definitions for a table, view, or synonym,
--              or the specifications for a function or procedure.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @desc {[schema.]object[@connect_identifier]}
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/04/25 08:21
--                Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

-- assign linesize for readability
set lin 80

desc &1.

@restore_sqlplus_settings
