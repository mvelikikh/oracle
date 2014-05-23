def par_count="2"
def job_count="4"
def ts_name="TEST"
def job_prefix="SCJ_MOVP_"
def prg_prefix="SCP_MOVP_"
def sleep_freq=5
def max_wait=7200
def task_name="MOVEP_TEST"
def prg_name=&prg_prefix.&task_name.
def resumable_timeout="3600"
def queue_name="MOVP_&task_name._Q"
def queue_table="MOVP_&task_name._QT"
def objlst="select owner, table_name name from dba_tables where owner='TEST_MOVEP'"
