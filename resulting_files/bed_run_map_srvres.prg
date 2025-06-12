CREATE PROGRAM bed_run_map_srvres
 SET filename = "cer_install:bed_map_srvres.csv"
 SET scriptname = "bed_map_srvres"
 EXECUTE bed_dm_dbimport filename, scriptname, 1000
END GO
