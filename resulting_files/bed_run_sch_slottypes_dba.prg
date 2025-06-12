CREATE PROGRAM bed_run_sch_slottypes:dba
 SET filename = "CCLUSERDIR:BED_SCH_SLOTTYPES.CSV"
 SET scriptname = "BED_IMP_SCH_SLOTTYPES"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
