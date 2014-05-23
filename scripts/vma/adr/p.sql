-------------------------------------------------------------------------------
--
-- Script:      p.sql (ADR problems)
-- Purpose:     Report ADR problems.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @p <filter>
--              filter - where condition
--
-- Examples:
--              @p "problem_key like 'ORA 600%'"                - report ORA-600 problems
--
-- Versions:
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2014/04/25 16:31
--                Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set timi off
col 1 new_v 1
select '' "1" from dual where null^=null;
def p_filter="&1."

set term off
col p_filter new_v p_filter
select nvl2(q'#&p_filter.#', q'#&p_filter.#', '1=1') p_filter
  from dual;

set term on

col p_problem_id for 999 hea "ID"
col p_problem_key for a50 hea "PROBLEM_KEY"
col p_first_incident for 99999999 hea "FIRSTINC"
col p_firstinc_time for a19 hea "FIRSTINC_TIME"
col p_last_incident like p_first_incident hea "LASTINC"
col p_lastinc_time like p_firstinc_time hea "LASTINC_TIME"
col p_impact for a30 hea "IMPACT"
col p_impact_str for a30 hea "IMPACT_STRING"
col p_flood_controlled for 99999 hea "FLOOD"
col p_incident_cnt for 999999999 hea "INCIDENTS"
col p_package_cnt for 999 hea "PKG"
col p_active_status for 999 hea "ACT"

select problem_id p_problem_id,
       problem_key p_problem_key,
       first_incident p_first_incident,
       cast(firstinc_time as date) p_firstinc_time,
       last_incident p_last_incident,
       cast(lastinc_time as date) p_lastinc_time,
       decode(impact1,0,null,impact1)||decode(impact2,0,null,'/'||impact2)||decode(impact3,0,null,'/'||impact3)||decode(impact4,0,null,'/'||impact4) p_impact,
       impact_str1||nvl2(impact_str2, '/'||impact_str2, '')||nvl2(impact_str3, '/'||impact_str3, '')||nvl2(impact_str4, '/'||impact_str4, '') p_impact_str,
       flood_controlled p_flood_controlled,
       incident_cnt p_incident_cnt,
       package_cnt p_package_cnt,
       active_status p_active_status
  from v$diag_vproblem
 where &p_filter.
 order by lastinc_time
;

col p_problem_id cle
col p_problem_key cle
col p_first_incident cle
col p_firstinc_time cle
col p_last_incident cle
col p_lastinc_time cle
col p_impact cle
col p_impact_str cle
col p_flood_controlled cle
col p_incident_cnt cle
col p_package_cnt cle
col p_active_status cle

undef 1
undef p_filter

@restore_sqlplus_settings
