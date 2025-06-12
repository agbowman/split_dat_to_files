CREATE PROGRAM cv_utl_upd_request:dba
 UPDATE  FROM request_processing t
  SET t.active_ind = 0
  WHERE t.request_number=3091000
   AND t.destination_step_id=6040
   AND t.service="CPMSCRIPTASYNC002"
   AND t.target_request_number=4100510
   AND t.active_ind=1
   AND t.format_script IN (" ")
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing t
  SET t.active_ind = 0
  WHERE t.request_number=600353
   AND t.destination_step_id=6040
   AND t.service="CPMSCRIPTASYNC002"
   AND t.target_request_number=4100511
   AND t.active_ind=1
   AND t.format_script IN (" ")
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing t
  SET t.active_ind = 0
  WHERE t.request_number=114001
   AND t.destination_step_id=0
   AND t.service="0"
   AND t.target_request_number=0
   AND t.active_ind=1
   AND t.format_script IN ("PFMT_E_CV_GET_DISCH_DT_TM")
  WITH nocounter
 ;end update
 EXECUTE dm_ocd_readme "cv_rqp.csv", "rqp_import", 10000,
 9669
 COMMIT
 CALL echo(
  "******************************************************************************************************"
  )
 CALL echo(
  "Please cycle the CPM Process, CPM Script Async 002, CPM Script, and the Clinical Events Servers again."
  )
 CALL echo(
  "******************************************************************************************************"
  )
#exit_script
END GO
