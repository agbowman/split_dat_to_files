CREATE PROGRAM bed_run_br_seg_field_r
 SET filename = "CER_INSTALL:br_seg_field_r.csv"
 SET scriptname = "bed_imp_br_seg_field_r"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
