CREATE PROGRAM bed_run_health_plans
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_HEALTH_PLANS.CSV"
 SET scriptname = "bed_imp_health_plans"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
