CREATE PROGRAM bed_run_template_flexing:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_TEMPLATE_FLEXING.CSV"
 SET scriptname = "bed_imp_template_flexing"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
