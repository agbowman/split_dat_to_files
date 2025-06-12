CREATE PROGRAM bed_run_correspondence_rules:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_CORRESPONDENCE_RULES.CSV"
 SET scriptname = "BED_IMP_CORRESPONDENCE_RULES"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
