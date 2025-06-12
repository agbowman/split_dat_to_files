CREATE PROGRAM cv_ins_updt_cv_omf_filter:dba
 RECORD cv_requestin(
   1 list_0[*]
     2 indicator_cd = vc
     2 cdf_meaning = vc
     2 task_assay_cd = f8
 )
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
 IF ((- (1)=validate(request->codeset,- (1))))
  RECORD request(
    1 codeset = f8
  )
  SET request->codeset = 24549
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reqinfo->commit_ind = 1
  SET reply->status = "S"
 ENDIF
 RECORD action(
   1 row[*]
     2 app_action = i1
     2 fact_ind = i2
     2 sg_type = vc
     2 sort_flag = i2
 )
 SET v_count = size(requestin->list_0,5)
 SET t_count = 0
 FOR (n = 1 TO v_count)
   IF ((requestin->list_0[n].cdf_meaning != "  "))
    SET t_count = (t_count+ 1)
    SET stat = alterlist(cv_requestin->list_0,t_count)
    SET cv_requestin->list_0[t_count].indicator_cd = requestin->list_0[n].indicator_cd
    SET cv_requestin->list_0[t_count].cdf_meaning = requestin->list_0[n].cdf_meaning
   ENDIF
 ENDFOR
 CALL echorecord(cv_requestin,"cer_temp:cv_requestin.dat")
 SET stat = alterlist(action->row,v_count)
 SELECT INTO "nl:"
  coi.indicator_cd
  FROM code_value cv,
   cv_omf_indicator coi,
   (dummyt d  WITH seq = value(size(cv_requestin->list_0,5)))
  PLAN (d)
   JOIN (coi
   WHERE (coi.cdf_meaning=cv_requestin->list_0[d.seq].cdf_meaning))
   JOIN (cv
   WHERE (cv.code_set=request->codeset)
    AND cv.cdf_meaning="INDICATOR"
    AND cv.code_value=coi.indicator_cd
    AND cv.active_ind=1)
  DETAIL
   IF (coi.indicator_cd > 0)
    action->row[d.seq].app_action = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO t_count)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.code_set=request->codeset)
     AND cv.cdf_meaning="INDICATOR"
     AND cv.display_key=cnvtalphanum(cnvtupper(cv_requestin->list_0[x].indicator_cd))
     AND (cv.display=cv_requestin->list_0[x].indicator_cd)
     AND cv.active_ind=1
    DETAIL
     cv_requestin->list_0[x].indicator_cd = cnvtstring(cv.code_value)
    WITH nocounter, orahint("index(XIE2CODE_VALUE cv)")
   ;end select
   IF (curqual=0)
    SET action->row[x].app_action = 999
   ENDIF
   SELECT INTO "nl:"
    code_value
    FROM code_value cv
    WHERE cv.code_set=14003
     AND (cv.cdf_meaning=cv_requestin->list_0[x].cdf_meaning)
     AND cv.active_ind=1
    DETAIL
     cv_requestin->list_0[x].task_assay_cd = cv.code_value
    WITH nocounter
   ;end select
 ENDFOR
 INSERT  FROM cv_omf_indicator coi,
   (dummyt d  WITH seq = value(size(cv_requestin->list_0,5)))
  SET coi.indicator_cd = cnvtint(cv_requestin->list_0[d.seq].indicator_cd), coi.cdf_meaning =
   cv_requestin->list_0[d.seq].cdf_meaning, coi.task_assay_cd = cv_requestin->list_0[d.seq].
   task_assay_cd,
   coi.active_ind = 1, coi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), coi.active_status_cd
    = reqdata->active_status_cd,
   coi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), coi.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), coi.data_status_cd = reqdata->data_status_cd,
   coi.data_status_prsnl_id = reqinfo->updt_id, coi.active_status_prsnl_id = reqinfo->updt_id, coi
   .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   coi.updt_dt_tm = cnvtdatetime(curdate,curtime3), coi.updt_task = reqinfo->updt_task, coi
   .updt_applctx = reqinfo->updt_applctx,
   coi.updt_cnt = 0, coi.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE (action->row[d.seq].app_action=0))
   JOIN (coi)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL cv_log_message("Failed in insert data to cv_ins_updt_cd_omf_filter")
 ENDIF
 UPDATE  FROM cv_omf_indicator coi,
   (dummyt d  WITH seq = value(size(cv_requestin->list_0,5)))
  SET coi.indicator_cd = cnvtint(cv_requestin->list_0[d.seq].indicator_cd), coi.cdf_meaning =
   cv_requestin->list_0[d.seq].cdf_meaning, coi.task_assay_cd = cv_requestin->list_0[d.seq].
   task_assay_cd,
   coi.active_ind = 1, coi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), coi.active_status_cd
    = reqdata->active_status_cd,
   coi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), coi.end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100"), coi.data_status_cd = reqdata->data_status_cd,
   coi.data_status_prsnl_id = reqinfo->updt_id, coi.active_status_prsnl_id = reqinfo->updt_id, coi
   .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   coi.updt_dt_tm = cnvtdatetime(curdate,curtime3), coi.updt_task = reqinfo->updt_task, coi
   .updt_applctx = reqinfo->updt_applctx,
   coi.updt_cnt = (coi.updt_cnt+ 1), coi.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE (action->row[d.seq].app_action=1))
   JOIN (coi
   WHERE (coi.cdf_meaning=cv_requestin->list_0[d.seq].cdf_meaning))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL cv_log_message("Failed in insert data to cv_ins_updt_cd_omf_filter")
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
