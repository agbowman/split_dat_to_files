CREATE PROGRAM bed_run_br_sched_dept_type
 SET filename = "CER_INSTALL:br_sched_dept_type.csv"
 SET scriptname = "bed_imp_br_sched_dept_type"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
