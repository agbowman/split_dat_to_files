CREATE PROGRAM bed_run_br_def_sched_temp:dba
 SET filename = "ccluserdir:br_def_sched_temp.csv"
 SET scriptname = "bed_imp_br_def_sched_temp"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
