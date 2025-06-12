CREATE PROGRAM bed_run_br_report
 SET filename = "CER_INSTALL:report_tbl.csv"
 SET scriptname = "bed_imp_br_report"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
