CREATE PROGRAM bed_run_res_list_appt_type_rel:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 EXECUTE dm_dbimport value("CCLUSERDIR:BED_IMP_RESOURCE_LISTS.CSV"), value(
  "BED_IMP_RES_LIST_APPT_TYPE_REL"), 10000
END GO
