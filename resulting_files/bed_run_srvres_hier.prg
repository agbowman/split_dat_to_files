CREATE PROGRAM bed_run_srvres_hier
 SET filename = "CER_INSTALL:srvres_hier.csv"
 SET scriptname = "bed_imp_srvres_hier"
 SET curclientid = 0
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
