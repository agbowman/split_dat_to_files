CREATE PROGRAM cv_utl_del_summary_rec:dba
 PROMPT
  "Please enter cv_case_id from the case you want to delete = " = " "
 SET input_case_id = cnvtreal( $1)
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  SET null_date = "31-DEC-2100 00:00:00"
  SET cv_log_debug = 5
  SET cv_log_info = 4
  SET cv_log_audit = 3
  SET cv_log_warning = 2
  SET cv_log_error = 1
  SET cv_log_handle_cnt = 1
  SET cv_log_handle = 0
  SET cv_log_status = 0
  SET cv_log_level = 0
  SET cv_log_echo_level = 0
  SET cv_log_error_time = 0
  SET cv_log_error_file = 1
  SET cv_log_error_string = fillstring(32000," ")
  SET cv_err_msg = fillstring(100," ")
  SET cv_log_err_num = 0
  SET cv_log_file_name = build("cer_temp:CV_DEFAULT",format(cnvtdatetime(curdate,curtime3),
    "HHMMSS;;q"),".dat")
  SET cv_log_struct_file_name = build("cer_temp:",curprog)
  SET cv_log_struct_file_nbr = 0
  SET cv_log_event = "CV_DEFAULT_LOG"
  SET cv_log_level = cv_log_debug
  SET cv_def_log_level = cv_log_debug
  SET cv_log_echo_level = cv_log_debug
  SET cv_log_chg_to_default = 1
  SET cv_log_error_time = 1
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
   ENDIF
   SET reply->status_data.subeventstatus[num_event].targetobjectname = object_name_param
   SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
   SET reply->status_data.subeventstatus[num_event].operationname = operation_name_param
   SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 RECORD del_rec(
   1 max_case_field_cnt = i4
   1 max_case_file_row_cnt = i4
   1 del_dataset[*]
     2 dataset_r_id = f8
     2 case_field[*]
       3 case_field_id = f8
     2 case_file_row[*]
       3 cv_case_file_row_id = f8
   1 del_proc[*]
     2 procedure_id = f8
   1 del_les[*]
     2 lesion_id = f8
 )
 SET sfailure = "F"
 SET del_flag = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  cc.cv_case_id, cc.cv_case_nbr
  FROM cv_case cc
  WHERE cc.cv_case_id=input_case_id
   AND cc.cv_case_id != 0
  DETAIL
   input_case_id = cc.cv_case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ELSE
  SET del_flag = 1
 ENDIF
 IF (del_flag=1)
  SELECT INTO "nl:"
   proc_id = cp.procedure_id
   FROM cv_procedure cp
   WHERE cp.cv_case_id=input_case_id
    AND cp.cv_case_id > 0
   HEAD REPORT
    del_pro_cnt = 0
   DETAIL
    del_pro_cnt = (del_pro_cnt+ 1), stat = alterlist(del_rec->del_proc,del_pro_cnt), del_rec->
    del_proc[del_pro_cnt].procedure_id = proc_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No procedure associates with this case!")
  ENDIF
  SELECT INTO "nl:"
   cl.lesion_id
   FROM cv_lesion cl,
    (dummyt d2  WITH seq = value(size(del_rec->del_proc,5)))
   PLAN (d2)
    JOIN (cl
    WHERE (del_rec->del_proc[d2.seq].procedure_id=cl.procedure_id)
     AND cl.lesion_id > 0)
   HEAD REPORT
    del_les_cnt = 0
   DETAIL
    del_les_cnt = (del_les_cnt+ 1), stat = alterlist(del_rec->del_les,del_les_cnt), del_rec->del_les[
    del_les_cnt].lesion_id = cl.lesion_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion associates with this case or procedure!")
  ENDIF
  SELECT INTO "nl:"
   ccdr.case_dataset_r_id
   FROM cv_case_dataset_r ccdr
   WHERE ccdr.cv_case_id=input_case_id
    AND ccdr.cv_case_id > 0
   HEAD REPORT
    del_ds_cnt = 0
   DETAIL
    del_ds_cnt = (del_ds_cnt+ 1), stat = alterlist(del_rec->del_dataset,del_ds_cnt), del_rec->
    del_dataset[del_ds_cnt].dataset_r_id = ccdr.case_dataset_r_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No dataset associates with this case or procedure!")
  ENDIF
  SELECT INTO "nl:"
   ccf.case_field_id
   FROM cv_case_field ccf,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5)))
   PLAN (d)
    JOIN (ccf
    WHERE (ccf.case_dataset_r_id=del_rec->del_dataset[d.seq].dataset_r_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(del_rec->del_dataset[d.seq].case_field,cnt), del_rec->
    del_dataset[d.seq].case_field[cnt].case_field_id = ccf.case_field_id
   FOOT REPORT
    IF ((del_rec->max_case_field_cnt < cnt))
     del_rec->max_case_field_cnt = cnt
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_field data for the dataset_r_id data!")
  ENDIF
  SELECT INTO "nl:"
   ccfr.cv_case_file_row_id
   FROM cv_case_file_row ccfr,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5)))
   PLAN (d)
    JOIN (ccfr
    WHERE (ccfr.case_dataset_r_id=del_rec->del_dataset[d.seq].dataset_r_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(del_rec->del_dataset[d.seq].case_file_row,cnt), del_rec->
    del_dataset[d.seq].case_file_row[cnt].cv_case_file_row_id = ccfr.cv_case_file_row_id
   FOOT REPORT
    IF ((del_rec->max_case_file_row_cnt < cnt))
     del_rec->max_case_file_row_cnt = cnt
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_file_row data for the dataset_r_id data!")
  ENDIF
  DELETE  FROM cv_les_abstr_data clad,
    (dummyt d3  WITH seq = value(size(del_rec->del_les,5)))
   SET clad.seq = 1
   PLAN (d3)
    JOIN (clad
    WHERE (del_rec->del_les[d3.seq].lesion_id=clad.lesion_id)
     AND clad.lesion_id > 0)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion abstract fields were deleted with this case or procedure!")
  ENDIF
  DELETE  FROM cv_lesion cl,
    (dummyt d4  WITH seq = value(size(del_rec->del_proc,5)))
   SET cl.seq = 1
   PLAN (d4)
    JOIN (cl
    WHERE (del_rec->del_proc[d4.seq].procedure_id=cl.procedure_id)
     AND cl.lesion_id > 0)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion fields were deleted with this case or procedure!")
  ENDIF
  DELETE  FROM cv_proc_abstr_data cpad,
    (dummyt d5  WITH seq = value(size(del_rec->del_proc,5)))
   SET cpad.seq = 1
   PLAN (d5)
    JOIN (cpad
    WHERE (del_rec->del_proc[d5.seq].procedure_id=cpad.procedure_id)
     AND cpad.procedure_id > 0)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No procedure abstract fields were deleted with this case or procedure!")
  ENDIF
  DELETE  FROM cv_procedure cp,
    (dummyt d6  WITH seq = value(size(del_rec->del_proc,5)))
   SET cp.seq = 1
   PLAN (d6)
    JOIN (cp
    WHERE (del_rec->del_proc[d6.seq].procedure_id=cp.procedure_id)
     AND cp.procedure_id > 0)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No procedure fields were deleted with this case!")
  ENDIF
  DELETE  FROM cv_case_abstr_data ccad
   WHERE ccad.cv_case_id=input_case_id
    AND ccad.cv_case_id > 0
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv case abstract fields were deleted with this case!")
  ENDIF
  DELETE  FROM cv_case_field ccf,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5))),
    (dummyt d1  WITH seq = value(del_rec->max_case_field_cnt))
   SET ccf.seq = 1
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(del_rec->del_dataset[d.seq].case_field,5))
    JOIN (ccf
    WHERE (ccf.case_field_id=del_rec->del_dataset[d.seq].case_field[d1.seq].case_field_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_field records were deleted for this case!")
  ENDIF
  DELETE  FROM cv_case_file_row ccfr,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5))),
    (dummyt d2  WITH seq = value(del_rec->max_case_file_row_cnt))
   SET ccfr.seq = 1
   PLAN (d)
    JOIN (d2
    WHERE d2.seq <= size(del_rec->del_dataset[d.seq].case_file_row,5))
    JOIN (ccfr
    WHERE (ccfr.cv_case_file_row_id=del_rec->del_dataset[d.seq].case_file_row[d2.seq].
    cv_case_file_row_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_file_row records were deleted for this case!")
  ENDIF
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5))),
    (dummyt d1  WITH seq = value(del_rec->max_case_field_cnt))
   SET lt.seq = 1
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(del_rec->del_dataset[d.seq].case_field,5))
    JOIN (lt
    WHERE (lt.parent_entity_id=del_rec->del_dataset[d.seq].case_field[d1.seq].case_field_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message(
    "No long_text records associated with cv_case_field records were deleted from this case!")
  ENDIF
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(size(del_rec->del_dataset,5))),
    (dummyt d2  WITH seq = value(del_rec->max_case_file_row_cnt))
   SET lt.seq = 1
   PLAN (d)
    JOIN (d2
    WHERE d2.seq <= size(del_rec->del_dataset[d.seq].case_file_row,5))
    JOIN (lt
    WHERE (lt.parent_entity_id=del_rec->del_dataset[d.seq].case_file_row[d2.seq].cv_case_file_row_id)
    )
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message(
    "No long_text records associated with cv_case_file_row records were deleted from this case!")
  ENDIF
  DELETE  FROM cv_case_dataset_r ccdr
   WHERE ccdr.cv_case_id=input_case_id
    AND ccdr.cv_case_id > 0
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv case dataset fields were deleted with this case!")
  ENDIF
  DELETE  FROM cv_count_data ccd
   WHERE ccd.parent_entity_id=input_case_id
    AND ccd.parent_entity_id > 0
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_count_data records were deleted with this case!")
  ENDIF
  DELETE  FROM cv_case cc
   WHERE cc.cv_case_id=input_case_id
  ;end delete
  IF (curqual=0)
   SET sfailure = "T"
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No case field was deleted with this case!")
  ENDIF
 ENDIF
#exit_script
 IF (sfailure="T")
  SET reply->status_data.status = "F"
  ROLLBACK
  CALL cv_log_message("Check cv_case_id in cv_case table and try again!")
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
  CALL cv_log_message(
   "The records associated with the case are successfully removed and command is committed!")
 ENDIF
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
END GO
