CREATE PROGRAM bed_run_oc_work_tables_mig
 SET filename = "CER_INSTALL:oc_work.csv"
 SET scriptname = "bed_imp_oc_work_tables_mig"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
