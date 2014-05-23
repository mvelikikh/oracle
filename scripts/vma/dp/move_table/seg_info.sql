def l_table_owner="&1."
def l_table_name="&2."

exec sys.dbms_application_info.set_action( 'TABLE_INFO' )

var table_owner varchar2(30)
var table_name  varchar2(30)
begin
  :table_owner:='&l_table_owner.';
  :table_name:='&l_table_name.';
end;
/
col segment_type for a30
col segment_name like segment_type
col tablespace_name like segment_type
with lob as (
  select owner, column_name, segment_name, index_name
    from dba_lobs
   where owner = :table_owner
     and table_name = :table_name)
select cast('TABLE' as varchar2(30)) segment_type, table_name segment_name, tablespace_name, cast('N/A' as varchar2(8)) status, cast(trim(degree) as varchar2(40)) degree
  from dba_tables
 where owner = :table_owner
   and table_name = :table_name
 union all
select 'INDEX', index_name, tablespace_name, status, degree
  from dba_indexes
 where table_owner = :table_owner
   and table_name = :table_name
 union all
select lob.segment_type, lob.segment_name, seg.tablespace_name, 'N/A', 'N/A'
  from (select owner, column_name, segment_type, segment_name
         from lob
        unpivot (segment_name for segment_type in (segment_name as 'LOBSEGMENT', index_name as 'LOBINDEX'))) lob,
       dba_segments seg
 where lob.owner = seg.owner(+)
   and lob.segment_name = seg.segment_name(+)
/

with tab as (
  select :table_owner owner, :table_name table_name from dual),
  ind as (
  select owner, index_name from dba_indexes where table_owner = :table_owner and table_name = :table_name),
  lobseg as (
  select owner, segment_name, index_name from dba_lobs where owner = :table_owner and table_name = :table_name),
  lobs as (
  select owner, segment_name from lobseg unpivot (segment_name for segment_type in (segment_name as 'LOBSEGMENT', index_name as 'LOBINDEX')))
select owner, segment_name, segment_type, 
       lpad(
         case when sum(bytes)<1e5 then sum(bytes)||' '
           when sum(bytes)<1e8 then round(sum(bytes)/power(2,10))||'K'
           when sum(bytes)<1e11 then round(sum(bytes)/power(2,20))||'M'
           else round(sum(bytes)/power(2,30))||'G'
         end
         , 6, ' ')
         segsiz
  from dba_segments
 where (owner, segment_name) in (
         select * from tab union all
         select * from ind union all
         select * from lobs)
 group by owner, segment_name, segment_type 
 order by owner, segment_type, segment_name
/

col segment_type cle
col segment_name cle
col tablespace_name cle

exec sys.dbms_application_info.set_action( null )
