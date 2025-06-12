CREATE PROGRAM bed_run_other_names
 SET filename = "CER_INSTALL:other_names.csv"
 SET scriptname = "bed_imp_other_names"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
