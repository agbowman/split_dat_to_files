CREATE PROGRAM bed_run_query_list_template
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_QUERY_LIST_TEMPLATE.CSV"
 SET scriptname = "bed_imp_query_list_template"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
