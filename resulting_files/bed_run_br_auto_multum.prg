CREATE PROGRAM bed_run_br_auto_multum
 SET filename = "CER_INSTALL:br_auto_multum.csv"
 SET scriptname = "bed_imp_br_auto_multum"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
