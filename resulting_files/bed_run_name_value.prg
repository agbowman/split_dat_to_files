CREATE PROGRAM bed_run_name_value
 SET filename = "CER_INSTALL:name_value.csv"
 SET scriptname = "bed_imp_name_value"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
