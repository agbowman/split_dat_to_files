CREATE PROGRAM cv_utl_del_dataset:dba
 PROMPT
  "Dataset Internal Name:" = "",
  "Delete Activity Data(Default=Y):" = "Y"
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
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
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE g_delete_activity_data = i2
 DECLARE dataset_id = f8
 DECLARE case_cnt = i4
 DECLARE deleted_cd = f8 WITH noconstant(0.0), public
 SET deleted_cd = uar_get_code_by("MEANING",48,"DELETED")
 SET dataset_id = 0.0
 IF (cnvtupper( $2)=patstring("Y*"))
  SET g_delete_activity_data = true
 ELSE
  SET g_delete_activity_data = false
 ENDIF
 SELECT INTO "nl:"
  t.*
  FROM cv_dataset d
  PLAN (d
   WHERE d.dataset_internal_name=patstring( $1)
    AND d.dataset_id > 0)
  DETAIL
   dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No Dataset found!!")
  GO TO exit_script
 ENDIF
 IF (curqual > 1)
  CALL echo("Multiple Datasets found, Please be more specific..")
  GO TO exit_script
 ENDIF
 IF (g_delete_activity_data)
  RECORD del_case(
    1 list[*]
      2 case_id = f8
  )
  SELECT DISTINCT INTO "nl:"
   case_id = c.cv_case_id
   FROM cv_case_dataset_r cdr,
    cv_case c
   PLAN (cdr
    WHERE cdr.dataset_id=dataset_id)
    JOIN (c
    WHERE c.cv_case_id=cdr.cv_case_id
     AND c.cv_case_id > 0)
   HEAD REPORT
    case_cnt = 0
   DETAIL
    case_cnt = (case_cnt+ 1)
    IF (case_cnt > size(del_case->list,5))
     stat = alterlist(del_case->list,(case_cnt+ 9))
    ENDIF
    del_case->list[case_cnt].case_id = case_id
   FOOT REPORT
    stat = alterlist(del_case->list,case_cnt)
   WITH nocounter
  ;end select
  IF (size(case_cnt) > 0)
   CALL echo(notrim(build("calling cv_utl_del_summary_data to delete ",case_cnt," cases.")))
   FOR (case_idx = 1 TO case_cnt)
     EXECUTE cv_utl_del_summary_data del_case->list[case_idx].case_id
   ENDFOR
  ELSE
   CALL echo("No valid cases found for this dataset")
  ENDIF
 ENDIF
 CALL del_long_texts(null)
 DELETE  FROM cv_xref_validation v
  WHERE v.xref_validation_id IN (
  (SELECT INTO "nl:"
   v.xref_validation_id
   FROM cv_xref_validation v,
    cv_response r,
    cv_xref x
   WHERE x.dataset_id=dataset_id
    AND r.xref_id=x.xref_id
    AND r.response_id=v.response_id))
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from cv_xref_validation had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_xref_validation v
  WHERE v.xref_validation_id IN (
  (SELECT INTO "nl:"
   v.xref_validation_id
   FROM cv_xref_validation v,
    cv_xref x
   WHERE x.dataset_id=dataset_id
    AND v.xref_id=x.xref_id))
 ;end delete
 DELETE  FROM cv_response r
  WHERE r.response_id IN (
  (SELECT
   r.response_id
   FROM cv_xref x,
    cv_response r
   WHERE x.dataset_id=dataset_id
    AND r.xref_id=x.xref_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_RESPONSE had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_xref_field t
  WHERE t.xref_field_id IN (
  (SELECT
   xf.xref_field_id
   FROM cv_xref_field xf,
    cv_dataset_file df
   WHERE df.dataset_id=dataset_id
    AND xf.file_id=df.file_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_XREF_FIELD had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_dataset_file t
  WHERE t.dataset_id=dataset_id
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_DATASET_FILE had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_component cc
  WHERE (cc.algorithm_id=
  (SELECT
   a.algorithm_id
   FROM cv_algorithm a
   WHERE a.dataset_id=dataset_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_COMPONENT had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_algorithm a
  WHERE a.dataset_id=dataset_id
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_ALGORITHM had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_xref x
  WHERE x.dataset_id=dataset_id
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_XREF had no non-zero Rows")
 ENDIF
 DELETE  FROM cv_dataset d
  WHERE d.dataset_id=dataset_id
   AND d.dataset_id > 0
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from CV_DATASET had no non-zero Rows")
 ENDIF
 DELETE  FROM dm_prefs dp
  WHERE dp.pref_domain="CVN*"
   AND parent_entity_name="CV_DATASET"
   AND parent_entity_id=dataset_id
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("Delete from DM_PREFS had no non-zero Rows")
 ENDIF
 CALL echo("If you need to apply the changes do a COMMIT GO")
 SUBROUTINE del_long_texts(null)
   RECORD long_texts(
     1 list[*]
       2 id = f8
   )
   SELECT INTO "nl:"
    text_id = c.long_text_id
    FROM cv_component c,
     cv_algorithm a
    PLAN (a
     WHERE a.dataset_id=dataset_id)
     JOIN (c
     WHERE c.algorithm_id=a.algorithm_id
      AND c.long_text_id > 0)
    HEAD REPORT
     text_cnt = size(long_texts->list,5)
    DETAIL
     text_cnt = (text_cnt+ 1)
     IF (text_cnt > size(long_texts->list,5))
      stat = alterlist(long_texts->list,(text_cnt+ 19))
     ENDIF
     long_texts->list[text_cnt].id = text_id
    FOOT REPORT
     stat = alterlist(long_texts->list,text_cnt)
    WITH nocounter
   ;end select
   UPDATE  FROM long_text lt,
     dummyt d1
    SET lt.active_ind = 0, lt.active_status_cd = deleted_cd, lt.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.active_status_prsnl_id = 0
    PLAN (d1)
     JOIN (lt
     WHERE (lt.long_text_id=long_texts->list[d1.seq].id)
      AND ((lt.long_text_id+ 0) > 0))
   ;end update
 END ;Subroutine
 DECLARE cv_log_destroyhandle(dummy=i2) = null
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
