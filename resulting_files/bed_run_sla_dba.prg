CREATE PROGRAM bed_run_sla:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_SLA.CSV"
 SET scriptname = "BED_IMP_SLA"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
