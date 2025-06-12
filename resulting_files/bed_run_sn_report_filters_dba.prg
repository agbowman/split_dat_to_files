CREATE PROGRAM bed_run_sn_report_filters:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 EXECUTE dm_dbimport value("CCLUSERDIR:BED_SN_REPORT_FILTERS.CSV"), value("BED_IMP_SN_REPORT_FILTERS"
  ), 100000
END GO
