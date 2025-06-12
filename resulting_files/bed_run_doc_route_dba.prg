CREATE PROGRAM bed_run_doc_route:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_DOC_ROUTE.CSV"
 SET scriptname = "BED_IMP_DOC_ROUTE"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
