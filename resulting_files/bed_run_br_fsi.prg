CREATE PROGRAM bed_run_br_fsi
 SET filename = "CER_INSTALL:bed_imp_br_fsi.csv"
 SET scriptname = "bed_imp_br_fsi"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
