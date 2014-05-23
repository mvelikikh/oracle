@save_sqlplus_settings

def input="&1."
def input
@eva "&input." begin_date end_date db_name

def
doc
  &db_name.
#
def db_name

col dbid       new_v dbid
col inst_num   new_v inst_num
col begin_snap new_v begin_snap
col end_snap   new_v end_snap
col num_days   new_v num_days


set echo on
set ver on
select i.dbid dbid,
       i.instance_number inst_num,
       ceil(sysdate-to_date('&begin_date.')) num_days,
       min(snap_id) begin_snap,
       max(snap_id) end_snap
  from dba_hist_snapshot s,
       dba_hist_database_instance i
 where i.db_name = upper('&db_name.')
   and s.dbid = i.dbid
   and s.instance_number = i.instance_number
   and (to_date('&begin_date.') between begin_interval_time and end_interval_time
       or to_date('&end_date.') between begin_interval_time and end_interval_time)
 group by i.dbid, i.instance_number;

def report_type ='html'
def report_name = awrrpt_&inst_num._&begin_snap._&end_snap..html
@?/rdbms/admin/awrrpti

undef input
undef dbid
undef inst_num
undef num_days
undef begin_date
undef end_date
undef report_type
undef report_name

@restore_sqlplus_settings