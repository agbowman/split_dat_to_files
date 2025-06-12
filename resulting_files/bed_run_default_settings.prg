CREATE PROGRAM bed_run_default_settings
 SET filename = "cer_install:default_settings.csv"
 SET scriptname = "bed_imp_default_settings"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
