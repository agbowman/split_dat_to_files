CREATE PROGRAM bed_run_search_settings
 SET filename = "cer_install:search_settings.csv"
 SET scriptname = "bed_imp_search_settings"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
