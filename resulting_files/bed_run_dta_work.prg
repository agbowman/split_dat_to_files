CREATE PROGRAM bed_run_dta_work
 SET filename = "CER_INSTALL:dta_work.csv"
 SET scriptname = "bed_imp_dta_work"
 EXECUTE bed_dm_dbimport filename, scriptname, 50000
END GO
