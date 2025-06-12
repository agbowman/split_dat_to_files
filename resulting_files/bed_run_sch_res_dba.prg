CREATE PROGRAM bed_run_sch_res:dba
 SET filename = "CCLUSERDIR:BED_SCH_RES.CSV"
 SET scriptname = "BED_IMP_SCH_RES"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
