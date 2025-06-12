CREATE PROGRAM bed_run_uk_defsched:dba
 SET filename = "CCLUSERDIR:BED_DEFSCHED.CSV"
 SET scriptname = "BED_IMP_UK_DEFSCHED"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
