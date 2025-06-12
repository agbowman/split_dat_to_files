CREATE PROGRAM bed_run_req_routing:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 EXECUTE dm_dbimport value("CCLUSERDIR:BED_IMP_REQ_ROUTING.CSV"), value("BED_IMP_REQ_ROUTING"), 10000
END GO
