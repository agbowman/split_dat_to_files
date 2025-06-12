CREATE PROGRAM bed_run_sn_report_privs:dba
 FREE RECORD tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 EXECUTE dm_dbimport value("CCLUSERDIR:BED_SN_REPORT_PRIVS.CSV"), value("BED_IMP_SN_REPORT_PRIVS"),
 100000
END GO
