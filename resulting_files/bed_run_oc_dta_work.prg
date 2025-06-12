CREATE PROGRAM bed_run_oc_dta_work
 SET filename = "CER_INSTALL:oc_dta_work.csv"
 SET scriptname = "bed_imp_oc_dta_work"
 EXECUTE bed_dm_dbimport filename, scriptname, 50000
END GO
