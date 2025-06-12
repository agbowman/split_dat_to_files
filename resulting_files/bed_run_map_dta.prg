CREATE PROGRAM bed_run_map_dta
 SET filename = "cer_install:bed_map_dta.csv"
 SET scriptname = "bed_map_dta"
 EXECUTE bed_dm_dbimport filename, scriptname, 1000
END GO
