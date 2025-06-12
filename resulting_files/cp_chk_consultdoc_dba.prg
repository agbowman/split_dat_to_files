CREATE PROGRAM cp_chk_consultdoc:dba
 SET nbr_records = 0
 SET error_cnt = 0
 SET old_consult_doc_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="CONSULTDOC"
   AND cv.active_ind=1
   AND cv.code_set=333
  HEAD REPORT
   do_nothing = 0
  DETAIL
   old_consult_doc_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co
  WHERE co.active_ind=1
   AND co.param=cnvtstring(old_consult_doc_cd)
  HEAD REPORT
   error_cnt = 0
  DETAIL
   error_cnt += 1,
   CALL echo(build("error on charting_operations_id = ",co.charting_operations_id))
  WITH nocounter
 ;end select
 IF (error_cnt > 0)
  CALL echo(build("error_cnt = ",error_cnt))
  CALL echo("not successful")
 ELSE
  CALL echo("successful")
 ENDIF
 IF (error_cnt=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "SUCCESS - CHARTING_OPERATIONS consult_doc updated correctly"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "FAILURE - CHARTING_OPERATIONS consult_doc NOT updated"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
