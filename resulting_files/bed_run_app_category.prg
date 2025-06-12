CREATE PROGRAM bed_run_app_category
 SET filename = "CER_INSTALL:ps_app_category.csv"
 SET scriptname = "bed_ens_app_category"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
