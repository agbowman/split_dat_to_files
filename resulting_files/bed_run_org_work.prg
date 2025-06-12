CREATE PROGRAM bed_run_org_work
 SET filename = "CER_INSTALL:org_work.csv"
 SET scriptname = "bed_imp_org_work"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
