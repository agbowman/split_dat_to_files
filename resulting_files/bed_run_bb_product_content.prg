CREATE PROGRAM bed_run_bb_product_content
 SET filename = "CER_INSTALL:bed_bb_product_content.csv"
 SET scriptname = "bed_imp_bb_product_content"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
