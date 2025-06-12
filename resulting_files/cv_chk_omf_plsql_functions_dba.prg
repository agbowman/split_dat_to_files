CREATE PROGRAM cv_chk_omf_plsql_functions:dba
 RECORD request(
   1 setup_proc[1]
     2 process_id = f8
     2 success_ind = i4
     2 error_msg = vc200
 )
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = fillstring(200," ")
 SET request->setup_proc[1].error_msg = "CV_OMF_PLSQL_FUNCTIONS Successful"
 SET v_first_error = 1
 SELECT INTO "nl:"
  object_name, status
  FROM user_objects uo
  WHERE object_type="FUNCTION"
   AND object_name="CV_CHK_OMF_PLSQL*"
  DETAIL
   IF (uo.status != "VALID"
    AND v_first_error=1)
    request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg = concat(trim(uo
      .object_name,3),"compiled incorrectly.  Status is ",trim(uo.status,3)), v_first_error = 0
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE dm_add_upt_setup_proc_log
END GO
