CREATE PROGRAM bed_run_pos_category
 SET filename = "CER_INSTALL:ps_pos_category.csv"
 SET scriptname = "bed_ens_pos_category"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
