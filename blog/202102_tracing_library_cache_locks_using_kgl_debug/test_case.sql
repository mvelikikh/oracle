conn tc/tc@rac1:1522/pdb

set echo on lin 200

drop table t;
create table t (n1 integer,n2 integer);
create index ix_t on t(n1,n2);
exec dbms_stats.gather_table_stats ('', 'T', cascade => true)

--alter system set "_kgl_debug"=16 scope=memory;
--alter system set "_kgl_debug"=32;
alter system set "_kgl_debug"=32 scope=memory;
-- tracepin
--alter system set "_kgl_debug"=64 scope=memory;
--alter system set "_kgl_debug"=128 scope=memory;
-- trace invalidation
--alter system set "_kgl_debug"=256 scope=memory;
--allocations
--alter system set "_kgl_debug"=1024 scope=memory;
--alter system set "_kgl_debug"=8192 scope=memory;

alter index ix_t invisible ;

col trace_file old_v tf for a72
col dirname old_v dn for a50
col basename old_v bn for a21

select value trace_file,
       substr(value, 1, instr(value, '/', -1)-1) dirname, 
       substr(value, instr(value, '/', -1)+1) basename
  from v$diag_info
 where name='Default Trace File';

ho tail -64 &tf.

alter system set "_kgl_debug"=0 scope=memory;

create or replace directory trace_dir as '&dn.';

drop table trace_ext;

create table trace_ext (
  trace_data clob
)
organization external (
  type oracle_loader
  default directory trace_dir
  access parameters (
    records
    xmltag ("KGLTRACE")
    fields ldrtrim
    missing field values are null (
      trace_data char(1000000)
    )
  )
  location ('&bn.')
)
reject limit unlimited;

select count(*) from trace_ext;
ho grep KGLTRACE &tf. | wc -l

set lin 3000 trims on
spo /tmp/lc.dat

select xt."Timestamp", xt.sid, xt."Function", xt."Reason", xt."Param1", xt."Param2",
       --lh."Address", lh."Hash",
       lh."LockMode", lh."PinMode", lh."LoadLockMode", lh."Status",
       obj.*, 
       --lol."Address" lol_address,
       --lol."Handle" lol_handle,
       lol."Mode" lol_mode
  from trace_ext,
       xmltable('/KGLTRACE' passing xmltype(trace_data)
         columns
           "Timestamp" varchar2(24),
           sid number,
           "Function" varchar2(20),
           "Reason" varchar2(10),
           "Param1" varchar2(14),
           "Param2" number,
           "LibraryHandle" xmltype,
           "LibraryObjectLock" xmltype
       )(+) xt,
       xmltable('/LibraryHandle' passing xt."LibraryHandle"
         columns "Address" varchar2(10),
                 "Hash" varchar2(10),
                 "LockMode" varchar2(8),
                 "PinMode" varchar2(8),
                 "LoadLockMode" varchar2(8),
                 "Status" varchar2(10),
                 "ObjectName" xmltype
       )(+) lh,
       xmltable('/ObjectName' passing lh."ObjectName"
         columns "Name" varchar2(64),
                 "FullHashValue" varchar2(32),
                 "Namespace" varchar2(32),
                 "Type" varchar2(32),
                 "ContainerId" number,
                 "ContainerUid" number,
                 "Identifier" number,
                 "OwnerIdn" number
       )(+) obj,
       xmltable('/LibraryObjectLock' passing xt."LibraryObjectLock"
         columns "Address" varchar2(10),
                 "Handle" varchar2(10),
                 "Mode"   varchar2(4)
       )(+) lol
 where obj."Name" like '%TC.T%'
   and xt."Function"='kgllkal';

spo off

col "Function" for a8
col "Name" for a15
col "Namespace" for a20
col "Type" for a10
col lol_mode for a8
select xt."Timestamp",
       xt."Function",
       xt."Reason",
       xt."Param1",
       lh."LockMode",
       lh."PinMode",
       obj."Name",
       obj."Namespace",
       obj."Type",
       lol."Address" lol_address,
       lol."Mode" lol_mode
  from trace_ext,
       xmltable('/KGLTRACE' passing xmltype(trace_data)
         columns "Timestamp" varchar2(24),
                 sid number,
                 "Function" varchar2(20),
                 "Reason" varchar2(10),
                 "Param1" varchar2(14),
                 "Param2" number,
                 "LibraryHandle" xmltype,
                 "LibraryObjectLock" xmltype
       )(+) xt,
       xmltable('/LibraryHandle' passing xt."LibraryHandle"
         columns "Address" varchar2(10),
                 "Hash" varchar2(10),
                 "LockMode" varchar2(8),
                 "PinMode" varchar2(8),
                 "LoadLockMode" varchar2(8),
                 "Status" varchar2(10),
                 "ObjectName" xmltype
       )(+) lh,
       xmltable('/ObjectName' passing lh."ObjectName"
         columns "Name" varchar2(64),
                 "FullHashValue" varchar2(32),
                 "Namespace" varchar2(32),
                 "Type" varchar2(32),
                 "ContainerId" number,
                 "ContainerUid" number,
                 "Identifier" number,
                 "OwnerIdn" number
       )(+) obj,
       xmltable('/LibraryObjectLock' passing xt."LibraryObjectLock"
         columns "Address" varchar2(10),
                 "Handle" varchar2(10),
                 "Mode"   varchar2(4)
       )(+) lol
 where 1=1
   and obj."Name" like '%PDB.TC.%'
   and xt."Function"='kgllkal';


