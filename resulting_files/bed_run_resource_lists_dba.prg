CREATE PROGRAM bed_run_resource_lists:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_IMP_RESOURCE_LISTS.CSV"
 SET scriptname = "bed_imp_resource_lists"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
