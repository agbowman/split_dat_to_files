CREATE PROGRAM bed_run_locs
 SET filename = "CER_INSTALL:locs.csv"
 SET scriptname = "BED_IMP_LOCS"
 EXECUTE bed_dm_dbimport filename, scriptname, 10000
END GO
