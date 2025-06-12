CREATE PROGRAM bed_run_br_type_seg_r
 SET filename = "CER_INSTALL:br_type_seg_r.csv"
 SET scriptname = "bed_imp_br_type_seg_r"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
