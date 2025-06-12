CREATE PROGRAM bed_run_app_group_rel
 SET filename = "CER_INSTALL:ps_app_group_rel.csv"
 SET scriptname = "bed_ens_app_group_rel"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
