CREATE PROGRAM bed_run_pos_rel
 SET filename = "CER_INSTALL:ps_position_rel.csv"
 SET scriptname = "bed_ens_pos_rel"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
