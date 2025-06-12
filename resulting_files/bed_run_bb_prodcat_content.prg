CREATE PROGRAM bed_run_bb_prodcat_content
 SET filename = "CER_INSTALL:bed_bb_prodcat_content.csv"
 SET scriptname = "bed_imp_bb_prodcat_content"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
