@vma/dp/header move
@@config

whenever oserror exit failure
whenever sqlerror exit failure

timi start move
DOC
  Script: seg_info
#
@@seg_info &owner. &table.

DOC
  Script: move_table
#
@@move_table &owner. &table. &tblsp. &par_count. &resumable_timeout. &parallel_min_pct.

DOC
  Script: move_lob
#
@@move_lob &owner. &table. &tblsp. &resumable_timeout. &parallel_min_pct. &workarea_size_policy. &sort_area_size.

DOC
  Script: move_index
#
@@move_index &owner. &table. &tblsp. &par_count. &resumable_timeout. &parallel_min_pct. &workarea_size_policy. &sort_area_size.

DOC
  Script: seg_info
#
@@seg_info &owner. &table.

timi stop

spo off
