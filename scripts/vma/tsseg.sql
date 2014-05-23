-------------------------------------------------------------------------------
--
-- Script:      tsseg.sql (TableSpace SEGments)
-- Purpose:     Shows tablespace reports in different dimensions
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:   (c) FTC LLC
-- Author:      Velikikh Mikhail
--
-- Usage:       @tsseg <params>
--              where params can be any of the following in any combination:
--              ts=<ts>                                         - tablespace (regexp)
--              owner=<owner>                                   - owner (regexp)
--              segment_type=<segment_type>                     - segment types (regexp)
--              segment_name=<segment>                          - segment name (regexp)
--              partition_name=<partition>                      - partition name (regexp)
--              gby=<gby cols>                                  - group by columns
--              oby=<oby cols>                                  - order by columns
--              top=<top>                                       - restrict number of output rows
--
-- Examples:
--              @tsseg SYSTEM                                   - show system tablespace usage
--              @tsseg ts=SYSTEM,owner=SYS                      - system tablespace usage by sys
--              @tsseg ts=SYSTEM,owner=^SYS$,segment_type=TABLE 
--                                                              - % for tables
--              @tsseg ts=SYSTEM,owner=SYS$,segment_type=TABLE$,top=15 
--                                                              - shows top 15 tables
--              @tsseg owner=^SYS$,gby=tablespace_name          - sys objects by tablespace
--
-- Versions:
--              Vers:   1.0.1.1
--                Auth: Velikikh M.
--                Date: 2014/04/24 15:14
--                Desc: Documentation
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2013/10/21 09:40
--                Desc: Creation
--
-------------------------------------------------------------------------------

@save_sqlplus_settings.sql

set timing off

def input="&1."

@eva "&input." ts owner gby oby partition_name segment_name segment_type top

@evadef "&input." ts

set term off

col if_ts new_v if_ts nopri
col if_owner new_v if_owner nopri
col if_gby_gby new_v if_gby_gby nopri
col if_gby_lst new_v if_gby_lst nopri
col if_oby new_v if_oby nopri
col if_partition_name new_v if_partition_name nopri
col if_segment_name new_v if_segment_name nopri
col if_segment_type new_v if_segment_type nopri
col if_top new_v if_top nopri

with params as (
  select 'tablespace_name' parameter, '&ts.' value from dual union all
  select 'owner', '&owner.' from dual union all
  select 'segment_type', '&segment_type.' from dual union all
  select 'segment_name', '&segment_name.' from dual union all
  select 'partition_name', '&partition_name.' from dual union all
  select 'gby', '&gby.' from dual)
select nvl2('&ts.', '', '--') if_ts,
       nvl2('&owner.', '', '--') if_owner,
       nvl(listagg(nvl2(value, decode(parameter, 'gby', value, parameter), null), ',') within group (order by decode(parameter, 'gby', 2, 1)), '()') if_gby_gby,
       nvl(listagg(nvl2(value, decode(parameter, 'gby', value, parameter), null), ',') within group (order by decode(parameter, 'gby', 2, 1)), '()') if_gby_lst,
       nvl2('&oby.', '&oby.', 'sum(bytes) desc') if_oby,
       nvl2('&partition_name.', '', '--') if_partition_name,
       nvl2('&segment_name.', '', '--') if_segment_name,
       nvl2('&segment_type.', '', '--') if_segment_type,
       nvl2('&top.', 'rownum<=&top.', '1=1') if_top
  from params
/

set term on
set echo off
set ver off

col blocks nopri
col blocksh hea BLOCKS
col bytesi nopri
col bytesh hea BYTES
col extents nopri
col extentsh hea EXTENTS
col segment_name for a30
col pct_val for 990.99
col pct_bar for a20

select *
  from (
       select &if_gby_lst.,
              sum(blocks) blocks,
              lpad(case when sum(blocks) < 1e5 then sum(blocks) || ' '
                        when sum(blocks) < 1e8 then round(sum(blocks)/1e3) || 'K'
                        when sum(blocks) < 1e11 then round(sum(blocks)/1e6) || 'M'
                        else round(sum(blocks) / 1e9) || 'G'
                   end, 6, ' '
              ) blocksh,
              lpad(case when sum(bytes) < 1e5 then sum(bytes) || ' '
                        when sum(bytes) < 1e8 then round(sum(bytes)/1e3) || 'K'
                        when sum(bytes) < 1e11 then round(sum(bytes)/1e6) || 'M'
                        else round(sum(bytes) / 1e9) || 'G'
                   end, 6, ' '
              ) bytesh,
              sum(extents) extents,
              lpad(case when sum(extents) < 1e5 then sum(extents) || ' '
                        when sum(extents) < 1e8 then round(sum(extents)/1e3) || 'K'
                        when sum(extents) < 1e11 then round(sum(extents)/1e6) || 'M'
                        else round(sum(extents) / 1e9) || 'G'
                   end, 6, ' '
              ) extentsh,
              ratio_to_report(sum(bytes)) over ()*100 pct_val,
              lpad('#', ratio_to_report(sum(bytes)) over ()*100/5, '#') pct_bar
         from dba_segments
        where 1 = 1
          &if_ts. and regexp_like(tablespace_name, '&ts.')
          &if_owner. and regexp_like(owner, '&owner.')
          &if_partition_name. and regexp_like( partition_name, '&partition_name.')
          &if_segment_name. and regexp_like( segment_name, '&segment_name.')
          &if_segment_type. and regexp_like( segment_type, '&segment_type.')
          and segment_name not like 'BIN$%'
        group by &if_gby_gby.
        order by &if_oby.)
 where &if_top.
/

undef input
undef ts
undef if_ts
undef owner
undef if_owner
undef gby
undef if_gby_gby
undef if_gby_lst
undef oby
undef if_oby

col if_ts cle
col if_owner cle
col if_gby_gby cle
col if_gby_lst cle
col if_oby cle
col if_partition_name cle
col if_segment_name cle
col if_segment_type cle
col if_top cle

col blocks cle
col blocksh cle
col bytesi cle
col bytesh cle
col extents cle
col extentsh cle
col segment_name cle
col pct_bar cle
col pct_val cle

@restore_sqlplus_settings.sql
