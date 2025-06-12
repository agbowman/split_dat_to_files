CREATE PROGRAM bed_run_defsched:dba
 SET filename = "CCLUSERDIR:BED_DEFSCHED.CSV"
 SET scriptname = "BED_IMP_DEFSCHED"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
