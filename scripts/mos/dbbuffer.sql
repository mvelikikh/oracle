-- Source: Script to Identify Objects and Amount of Blocks in the Buffer Pools - Default, Keep, Recycle, nK Cache (Doc ID 373472.1)
spool dbbuffer.log

select decode(pd.bp_id,1,'KEEP',2,'RECYCLE',3,'DEFAULT',
              4,'2K SUBCACHE',5,'4K SUBCACHE',6,'8K SUBCACHE',
              7,'16K SUBCACHE',8,'32K SUBCACHE','UNKNOWN') subcache,
       bh.object_name,
       bh.blocks
from   x$kcbwds ds,
       x$kcbwbpd pd,
       (select /*+ use_hash(x) */ set_ds,
               o.name object_name,
               count(*) BLOCKS
        from   obj$ o,
               x$bh x
        where  o.dataobj# = x.obj
        and    x.state !=0 and o.owner# !=0
        group by set_ds,o.name) bh 
where  ds.set_id >= pd.bp_lo_sid
and    ds.set_id <= pd.bp_hi_sid
and    pd.bp_size != 0
and    ds.addr=bh.set_ds;

spool off;