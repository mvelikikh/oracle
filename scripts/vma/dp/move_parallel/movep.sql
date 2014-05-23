@vma/dp/header movp

DOC
  Script: config.sql
#
@@config

DOC
  Script: test
#
@@test

DOC
  Script: create_queue
#
@@creque &task_name. &queue_name. &queue_table.

DOC
  Script: enqueue
#
@@enq "&objlst." &queue_name.

DOC
  Script: create program
#
@@creprg &prg_prefix. &task_name. &prg_name. &queue_name. &par_count. &ts_name. &resumable_timeout.

DOC
  Script: launch_jobs
#
@@crejob &job_count. &task_name. &queue_name. &job_prefix. &prg_name.

DOC
  Script: wait_for_complete
#
@@wait &sleep_freq. &max_wait. &job_prefix.

DOC
  Script: delete program
#
@@delprg &prg_name.

DOC
  Script: delete queue
#
@@delque &queue_name. &queue_table.

spo off
