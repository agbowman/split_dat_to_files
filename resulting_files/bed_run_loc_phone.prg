CREATE PROGRAM bed_run_loc_phone
 SET filename = "CCLUSERDIR:BED_LOC_PHONE.CSV"
 SET scriptname = "BED_IMP_LOC_PHONE"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
