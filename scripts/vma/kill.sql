-------------------------------------------------------------------------------
--
-- Script:      kill.sql (KILL session)
-- Purpose:     Generates command to kill session based on condition.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @kill <filter> [cols=<cols>,opts=<opts>,oby=<order by columns>]
--              cols - additional columns in the output
--              oby  - order by columns
--              opts - kill options (immediate/post transaction)
--
-- Examples:
--              @kill                                           - kill all
--              @kill "username='SYSTEM'"                       - kill user SYSTEM sessions
--              @kill "username='SYSTEM'" cols=logon_time,program
--                                                              - show additional columns in the output
--              @kill "username='SYSTEM'" oby=logon_time        - order by logon_time
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/04/25 13:00
--                Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set term off timi off

col 1 new_v 1
col 2 new_v 2
select '' "1", '' "2" from dual where null^=null;

def k_filter="&1."
def eva_input="&2."

@eva "&eva_input." cols oby opts

set term off
col k_filter new_v k_filter
col k_opts new_v opts
col k_cols new_v cols
col k_oby  new_v oby
select nvl2(q'#&k_filter.#', q'#&k_filter.#', '1=1') k_filter,
       nvl2(q'#&oby.#', q'#&oby.#', '1') k_oby,
       nvl2('&opts.', '&opts.', 'immediate') k_opts,
       nvl2(q'#&cols.#', q'#&cols.#', 'username, osuser, program') k_cols
  from dual;

col k_kill_cmd for a60 hea "KILL_CMD"

set term on
select 'alter system kill session '''||sid||','||serial#||''' '||nvl2('&opts.', '&opts.', 'immediate')||';' k_kill_cmd,
       &cols.
  from v$session
 where &k_filter.
   and sid <> sys_context( 'userenv', 'sid')
 order by &oby.
/

col k_filter cle
col k_kill_cmd cle
col k_oby cle
col k_opts cle
col k_cols cle
col 1 cle

undef k_filter
undef k_cols
undef k_opts
undef k_oby
undef 2
undef 1

@restore_sqlplus_settings
