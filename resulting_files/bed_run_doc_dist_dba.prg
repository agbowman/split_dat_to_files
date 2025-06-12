CREATE PROGRAM bed_run_doc_dist:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_DOC_DIST.CSV"
 SET scriptname = "BED_IMP_DOC_DIST"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
