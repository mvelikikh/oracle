-------------------------------------------------------------------------------
--
-- Script:	stat.sql
-- Purpose:	Display table and index statistics for given table.
--              Initial script was written by Timur Akhmadeev.
--              I adapted script for day-to-day usage.
--              ixora save/restore_s+ used for saving user environment
--
-- Copyright:	(c) NetCracker
-- Author:	Timur Akhmadeev
--
-- Description:	This script display information about table statistics
--
-- Usage:       @stat.sql OWNER TABLE_NAME
--
-- Change history:
--   Vers:   1.0.2.2
--     Auth: Velikikh M.
--     Date: 14/01/17 10:07
--     Desc: Clear columns 
--
--   Vers:   1.0.1.1
--     Auth: Velikikh M.
--     Date: 12/04/02 10:11
--     Desc: Added 
--
--   Vers:   1.0.0.0
--     Auth: Timur Akhmadeev
--     Date: unknown
--     Desc: Creation
--
-------------------------------------------------------------------------------
@save_sqlplus_settings.sql

set echo off feed off termout off timi off

repheader off
ttitle off

col num_rows                format a6                   heading 'Num|rows'                  justify right
col avg_row_len             format 9999                 heading 'Avg|len'
col blocks                  format a6                   heading 'Blocks'                    justify right
col seg_size                format 9999.99              heading 'Segment|GB'
col sample_size             format a6                   heading 'Sample'                    justify right
col user_stats              format a5                   heading 'User|stats'
col degree                  format a3                   heading 'DOP'
col partitioned             format a3                   heading 'Partitioned'
col iot_type                format a3                   

col data_type               format a15                  truncate
col avg_col_len             format 9999                 heading 'Avg|len'
col num_distinct            format a6                   heading 'Num di|stinct'
col density                 format 9.99EEEE
col num_nulls               format a6                   heading 'Num|nulls'                 justify right
col num_buckets             format 999                  heading 'Buck|ets'
col low_value               format a20                                                      trunc
col high_value              format a20                                                      trunc

col index_name              format a25                  truncate
col column_name             format a30                  truncate
col prefix_length           format 99                   heading 'Pre|fix'
col avg_leaf_blocks_per_key format 999,999              heading 'Leafs|per key'
col avg_data_blocks_per_key format 999,999              heading 'Data|per key'
col clustering_factor       format a6                   heading 'Cluste|ring'               justify right
col blevel                  format 9                    heading 'BLev'
col leaf_blocks             format a6                   heading 'Leaf|blocks'               justify right
col distinct_keys           format 999,999,999          heading 'Distinct|keys'
col rows_per_key            format 999,999,999          heading 'Rows per key'

var tab_name  varchar2(30)
var tab_owner varchar2(30)

exec :tab_owner := upper('&1')
exec :tab_name  := upper('&2')

set termout on

ttitle left 'Table statistics'

select lpad(case when num_rows < 1e5 then num_rows || ' '
                 when num_rows < 1e8 then round(num_rows / 1e3) || 'K'
                 when num_rows < 1e11 then round(num_rows / 1e6) || 'M'
                 else round(num_rows / 1e9) || 'G'
            end, 6, ' '
       ) num_rows
     , avg_row_len
     , lpad(case when blocks < 1e5 then blocks || ' '
                 when blocks < 1e8 then round(blocks / 1e3) || 'K'
                 when blocks < 1e11 then round(blocks / 1e6) || 'M'
                 else round(blocks / 1e9) || 'G'
            end, 6, ' '
       ) blocks
     , (select sum(bytes)/1024/1024/1024 from dba_segments where owner = t.owner and segment_name = table_name) seg_size
     , lpad(case when sample_size < 1e5 then sample_size || ' '
                 when sample_size < 1e8 then round(sample_size / 1e3) || 'K'
                 when sample_size < 1e11 then round(sample_size / 1e6) || 'M'
                 else round(sample_size / 1e9) || 'G'
            end, 6, ' '
       ) sample_size
     , last_analyzed
     , user_stats
     , compression
     , substr(replace(degree, ' '), 1, 3) degree
     , partitioned
     , iot_type
  from dba_tables t 
 where owner = :tab_owner 
   and table_name = :tab_name;

ttitle left "Column statistics"

select column_name
     , avg_col_len
     , data_type || decode(data_type, 'NUMBER', '(' || data_precision || decode(data_scale, 0, null, ',' || data_scale) || ')'
                                    , 'VARCHAR2', '(' || data_length || ')'
                                    , null
       ) data_type
     , lpad(case when num_distinct < 1e5 then num_distinct || ' '
                 when num_distinct < 1e8 then round(num_distinct / 1e3) || 'K'
                 when num_distinct < 1e11 then round(num_distinct / 1e6) || 'M'
                 else round(num_distinct / 1e9) || 'G'
            end, 6, ' '
       ) num_distinct
     , density
     , lpad(case when num_nulls < 1e5 then num_nulls || ' '
                 when num_nulls < 1e8 then round(num_nulls / 1e3) || 'K'
                 when num_nulls < 1e11 then round(num_nulls / 1e6) || 'M'
                 else round(num_nulls / 1e9) || 'G'
            end, 6, ' '
       ) num_nulls
     , num_buckets
     , user_stats
     , decode(data_type, 'NUMBER', to_char(utl_raw.cast_to_number(low_value)),
                         'VARCHAR2', utl_raw.cast_to_varchar2(low_value)
       ) low_value
     , decode(data_type, 'NUMBER', to_char(utl_raw.cast_to_number(high_value)),
                         'VARCHAR2', utl_raw.cast_to_varchar2(high_value)
       ) high_value
  from dba_tab_cols
 where owner = :tab_owner 
   and table_name = :tab_name
 order by column_id;

ttitle left "Index statistics"
break on index_name skip 1

select ui.index_name
     , uic.column_name
     , prefix_length
     , blevel
     , lpad(case when leaf_blocks < 1e5 then leaf_blocks || ' '
                 when leaf_blocks < 1e8 then round(leaf_blocks / 1e3) || 'K'
                 when leaf_blocks < 1e11 then round(leaf_blocks / 1e6) || 'M'
                 else round(leaf_blocks / 1e9) || 'G'
            end, 6, ' '
       ) leaf_blocks
     , avg_leaf_blocks_per_key
     , avg_data_blocks_per_key
--     , distinct_keys
     , (num_rows / nullif(distinct_keys, 0)) rows_per_key
     , lpad(case when num_rows < 1e5 then num_rows || ' '
                 when num_rows < 1e8 then round(num_rows / 1e3) || 'K'
                 when num_rows < 1e11 then round(num_rows / 1e6) || 'M'
                 else round(num_rows / 1e9) || 'G'
            end, 6, ' '
       ) num_rows
     , lpad(case when clustering_factor < 1e5 then clustering_factor || ' '
                 when clustering_factor < 1e8 then round(clustering_factor / 1e3) || 'K'
                 when clustering_factor < 1e11 then round(clustering_factor / 1e6) || 'M'
                 else round(clustering_factor / 1e9) || 'G'
            end, 6, ' '
       ) clustering_factor
     , lpad(case when sample_size < 1e5 then sample_size || ' '
                 when sample_size < 1e8 then round(sample_size / 1e3) || 'K'
                 when sample_size < 1e11 then round(sample_size / 1e6) || 'M'
                 else round(sample_size / 1e9) || 'G'
            end, 6, ' '
       ) sample_size
     , user_stats
     , substr(replace(degree, ' '), 1, 3) degree
     , last_analyzed
  from dba_indexes ui
     , dba_ind_columns uic
 where ui.table_owner = :tab_owner
   and ui.table_name = :tab_name
   and ui.index_name = uic.index_name
   and ui.table_name = uic.table_name
   and ui.owner = uic.index_owner
 order by index_name, column_position;

ttitle off
repheader on

undef 1
undef 2

col avg_col_len cle
col avg_data_blocks_per_key cle
col avg_leaf_blocks_per_key cle
col avg_row_len cle
col blevel cle
col blocks cle
col clustering_factor cle
col column_name cle
col data_type cle
col degree cle
col density cle
col distinct_keys cle
col high_value cle
col index_name cle
col iot_type cle
col leaf_blocks cle
col low_value cle
col num_buckets cle
col num_distinct cle
col num_nulls cle
col num_rows cle
col partitioned cle
col prefix_length cle
col rows_per_key cle
col sample_size cle
col seg_size cle
col user_stats cle

@restore_sqlplus_settings.sql
