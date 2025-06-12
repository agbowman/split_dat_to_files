CREATE PROGRAM bed_run_order_appt:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_ORDER_APPT.CSV"
 SET scriptname = "BED_ENS_ORDER_APPT"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
