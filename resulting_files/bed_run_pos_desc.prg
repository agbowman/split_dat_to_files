CREATE PROGRAM bed_run_pos_desc
 SET filename = "CER_INSTALL:ps_pos_desc.csv"
 SET scriptname = "bed_ens_pos_desc"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
