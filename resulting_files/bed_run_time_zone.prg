CREATE PROGRAM bed_run_time_zone
 SET filename = "CER_INSTALL:time_zones.csv"
 SET scriptname = "bed_imp_time_zone"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
