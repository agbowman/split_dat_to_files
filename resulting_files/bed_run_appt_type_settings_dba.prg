CREATE PROGRAM bed_run_appt_type_settings:dba
 FREE SET tempreq
 RECORD tempreq(
   1 insert_ind = c1
 )
 SET tempreq->insert_ind =  $1
 SET filename = "CCLUSERDIR:BED_APPT_TYPE_SETTINGS.CSV"
 SET scriptname = "BED_IMP_APPT_TYPE_SETTINGS"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
