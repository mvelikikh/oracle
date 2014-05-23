--
-- DB Segment Caching
-- Oracle 10.2+
-- Usage: SQL> @db_seg_cache SCOTT EMP
-- Igor Usoltsev
--
@save_sqlplus_settings
 
SET VERIFY OFF
 
col AREA                 for a12
col STATUS               for a30
col DISTINCT_BLOCK_COUNT for a40
col BLOCK_COUNT          for a12
 
with OBJLIST as
 (select DATA_OBJECT_ID
    from dba_objects
   where (owner, object_name) in ((upper(nvl('&&1', 'user')), upper('&&2')))
     and DATA_OBJECT_ID is not null)
select 'BUFFER CACHE' as AREA,
       nvl(status,'summary') as STATUS,
       to_char(count(distinct(file# || '#' || block#))) as DISTINCT_BLOCK_COUNT,
       to_char(count(*)) as BLOCK_COUNT
  from V$BH, OBJLIST
 where objd = OBJLIST.DATA_OBJECT_ID
 group by rollup(status)
union all
select 'DATABASE',
       'db blocks',
       to_char(blocks),
       '' as BH_COUNT
from dba_segments where (owner, segment_name) in ((upper(nvl('&&1', 'user')), upper('&&2')))
union all
select 'SGA',
       'BUFFER CACHE of MAX SGA SIZE',
       trim(to_char(s1.bytes, '999,999,999,999,999')) ||
       ' of '||
       trim(to_char(s2.bytes, '999,999,999,999,999')),
       '(' || decode(s1.resizeable, 'Yes', 'Resizeable', 'Fixed') || ')'
from v$sgainfo s1, v$sgainfo s2 where s1.name = 'Buffer Cache Size' and s2.name = 'Maximum SGA Size'
/
 
SET VERIFY ON
@restore_sqlplus_settings