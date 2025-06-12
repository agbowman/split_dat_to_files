CREATE PROGRAM bed_run_correspondence_procs:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 EXECUTE dm_dbimport value("CCLUSERDIR:BED_CORRESPONDENCE_PROCS.CSV"), value(
  "UK_CUST_PM_POST_DOC_UPLOAD"), 10000
END GO
