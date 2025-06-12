CREATE PROGRAM bed_run_him_locs:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_HIM_LOCS.CSV"
 SET scriptname = "BED_IMP_HIM_LOCS"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
