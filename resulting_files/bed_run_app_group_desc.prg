CREATE PROGRAM bed_run_app_group_desc
 SET filename = "CER_INSTALL:ps_app_group_desc.csv"
 SET scriptname = "bed_ens_app_group_desc"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
