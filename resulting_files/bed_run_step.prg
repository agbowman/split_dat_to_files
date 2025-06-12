CREATE PROGRAM bed_run_step
 SET filename = "CER_INSTALL:allsteps0419.csv"
 SET scriptname = "bed_imp_step"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
