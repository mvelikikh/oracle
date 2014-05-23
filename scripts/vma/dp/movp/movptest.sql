@vma/dp/header movp_test

DOC
  Script: config.sql
#
@@config

DOC
  Script: test
#
@@test

DOC
  Script: create internal table
#
@@cretab &job_count. "&objlst." &objtab.

DOC
  Script: before move
#
@@info &objtab.

DOC
  Script: create internal procedure
#
@@creprc &par_count. &task_name. &ts_name. &objtab. &prc_name. &resumable_timeout.

DOC
  Script: dbms_parallel_execute task
#
@@runpexe &job_count. &task_name. &objtab. &prc_name.

DOC
  Script: overall results
#
@@info &objtab.

DOC
  Script: delete created objects
#
@@delobj &prc_name. &objtab.

spo off
