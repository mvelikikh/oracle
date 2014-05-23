def l_objtab="&1."

doc
  Table info
#
select tab.tablespace_name, count(1) table_count
  from dba_tables tab,
       &l_objtab. tabo
 where tab.owner = tabo.owner
   and tab.table_name = tabo.name
 group by tab.tablespace_name
 order by tab.tablespace_name;

doc
  Index info
#
select ind.tablespace_name, ind.status, count(1) index_count
  from dba_indexes ind,
       &l_objtab. tabo
 where ind.table_owner = tabo.owner
   and ind.table_name = tabo.name
 group by ind.tablespace_name, ind.status
 order by ind.tablespace_name, ind.status;

doc
  Lob info
#
select lob.tablespace_name, count(1) lob_count
  from dba_lobs lob,
       &l_objtab. mov
 where lob.owner = mov.owner
   and lob.table_name = mov.name
 group by lob.tablespace_name
 order by lob.tablespace_name;

undef l_objtab
