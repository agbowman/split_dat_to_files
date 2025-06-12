CREATE PROGRAM bed_run_br_of_depts
 SET filename = "CER_INSTALL:br_of_depts.csv"
 SET scriptname = "bed_imp_br_of_depts"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
