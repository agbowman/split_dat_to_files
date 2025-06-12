CREATE PROGRAM bed_run_br_pharm_product_work
 SET filename = "CER_INSTALL:br_pharm_product_work.csv"
 SET scriptname = "bed_imp_br_pharm_product_work"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
