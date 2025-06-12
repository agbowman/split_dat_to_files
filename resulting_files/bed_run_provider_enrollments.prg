CREATE PROGRAM bed_run_provider_enrollments
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_PROVIDER_ENROLLMENTS.CSV"
 SET scriptname = "bed_imp_provider_enrollments"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
