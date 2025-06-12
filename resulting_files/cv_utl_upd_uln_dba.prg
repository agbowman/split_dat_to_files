CREATE PROGRAM cv_utl_upd_uln:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ccad_ids(
   1 del_list[*]
     2 ccad_id = f8
 )
 RECORD case_field_ids(
   1 del_list[*]
     2 case_field_id = f8
 )
 RECORD case_ds_r_ids(
   1 file_list[*]
     2 case_ds_r_id = f8
 )
 DECLARE commit_cnt = i4 WITH public, noconstant(0)
 DECLARE old_xref_id = f8 WITH public, noconstant(0.0)
 DECLARE new_xref_id = f8 WITH public, noconstant(0.0)
 DECLARE new_xref_val_id = f8 WITH public, noconstant(0.0)
 DECLARE old_event_cd = f8 WITH public, noconstant(0.0)
 DECLARE new_event_cd = f8 WITH public, noconstant(0.0)
 DECLARE old_task_assay_cd = f8 WITH public, noconstant(0.0)
 DECLARE new_task_assay_cd = f8 WITH public, noconstant(0.0)
 DECLARE old_xref_id_cnt = i4 WITH public, noconstant(0)
 DECLARE new_xref_id_cnt = i4 WITH public, noconstant(0)
 DECLARE old_result_val = vc WITH public, noconstant(" ")
 DECLARE new_result_val = vc WITH public, noconstant(" ")
 DECLARE old_event_id = f8 WITH public, noconstant(0.0)
 DECLARE new_event_id = f8 WITH public, noconstant(0.0)
 DECLARE old_event_cd_flag = i2 WITH public, noconstant(0)
 DECLARE new_event_cd_flag = i2 WITH public, noconstant(0)
 DECLARE old_xref_id_flag = i2 WITH public, noconstant(0)
 DECLARE new_xref_id_flag = i2 WITH public, noconstant(0)
 DECLARE new_ccad_id = f8 WITH public, noconstant(0.0)
 DECLARE new_case_field_id = f8 WITH public, noconstant(0.0)
 DECLARE ccad_id_cnt = i4 WITH public, noconstant(0)
 DECLARE case_field_id_cnt = i4 WITH public, noconstant(0)
 DECLARE serrmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH public, noconstant(0)
 DECLARE updateactivitydata(null) = i2
 DECLARE updatereferencedata(null) = i2
 DECLARE addtosynchfile(null) = i2
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  cx.xref_id, cx.event_cd, cx.task_assay_cd
  FROM cv_xref cx
  WHERE cx.xref_internal_name IN ("ACC02_OCKULN", "ACC02_OCKULM")
   AND cx.active_ind=1
  ORDER BY cx.xref_internal_name
  DETAIL
   IF (cx.xref_internal_name="ACC02_OCKULM")
    old_xref_id = cx.xref_id, old_event_cd = cx.event_cd, old_task_assay_cd = cx.task_assay_cd,
    old_xref_id_cnt = (old_xref_id_cnt+ 1)
   ELSEIF (cx.xref_internal_name="ACC02_OCKULN")
    new_xref_id = cx.xref_id, new_event_cd = cx.event_cd, new_task_assay_cd = cx.task_assay_cd,
    new_xref_id_cnt = (new_xref_id_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET readme_data->status = "F"
  SET readme_data->message = serrmsg
  GO TO exit_script
 ENDIF
 IF (((old_xref_id_cnt > 1) OR (new_xref_id_cnt > 1)) )
  CALL echo("Too many active xref_ids for single registry field.")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (old_xref_id_cnt=1
  AND new_xref_id_cnt=1)
  CALL echo("Updating activity and reference data.")
  CALL updateactivitydata(null)
  CALL updatereferencedata(null)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ELSEIF (old_xref_id_cnt=1
  AND new_xref_id_cnt=0)
  CALL echo("Updating reference data.")
  CALL updatereferencedata(null)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ELSE
  CALL echo("No xref_ids to update/migrate. Nothing for script to do.")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SUBROUTINE updateactivitydata(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    ccad.*
    FROM cv_case_abstr_data ccad
    WHERE ccad.event_cd IN (old_event_cd, new_event_cd)
     AND ccad.active_ind=1
    ORDER BY ccad.cv_case_id
    HEAD REPORT
     stat = alterlist(ccad_ids->del_list,10)
    HEAD ccad.cv_case_id
     row + 1
    DETAIL
     IF (ccad.event_cd=old_event_cd)
      old_event_cd_flag = 1, old_result_val = ccad.result_val, old_event_id = ccad.event_id
     ELSEIF (ccad.event_cd=new_event_cd)
      new_event_cd_flag = 1, new_result_val = ccad.result_val, new_event_id = ccad.event_id,
      new_ccad_id = ccad.case_abstr_data_id
     ENDIF
    FOOT  ccad.cv_case_id
     IF (old_event_cd_flag=1
      AND new_event_cd_flag=1
      AND new_event_cd=old_event_cd
      AND new_result_val=old_result_val
      AND new_event_id=old_event_id)
      ccad_id_cnt = (ccad_id_cnt+ 1)
      IF (mod(ccad_id_cnt,10)=1
       AND ccad_id_cnt != 1)
       stat = alterlist(ccad_ids->del_list,(ccad_id_cnt+ 9))
      ENDIF
      ccad_ids->del_list[ccad_id_cnt].ccad_id = new_ccad_id
     ENDIF
     new_ccad_id = 0, new_event_cd_flag = 0, old_event_cd_flag = 0,
     new_result_val = "", old_result_val = "", new_event_id = 0,
     old_event_id = 0
    FOOT REPORT
     stat = alterlist(ccad_ids->del_list,ccad_id_cnt)
    WITH nocounter, forupdate(ccad)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_CASE_ABSTR_DATA"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (size(ccad_ids->del_list,5) != 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_case_abstr_data ccad,
      (dummyt d  WITH seq = value(size(ccad_ids->del_list,5)))
     SET ccad.seq = 1
     PLAN (d)
      JOIN (ccad
      WHERE (ccad.case_abstr_data_id=ccad_ids->del_list[d.seq].ccad_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_CASE_ABSTR_DATA"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (curqual=0)
    CALL echo("No cases with duplicate ULN/ULM found in CCAD.")
   ELSE
    CALL echo("Duplicate cases deleted from CCAD.")
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    ccf.xref_id, ccf.result_val, ccf.case_dataset_r_id
    FROM cv_case_field ccf
    WHERE ccf.xref_id IN (new_xref_id, old_xref_id)
     AND ccf.active_ind=1
    ORDER BY ccf.case_dataset_r_id
    HEAD REPORT
     stat = alterlist(case_field_ids->del_list,10), stat = alterlist(case_ds_r_ids->file_list,10)
    HEAD ccf.case_dataset_r_id
     row + 1
    DETAIL
     IF (ccf.xref_id=old_xref_id)
      old_xref_id_flag = 1, old_result_val = ccf.result_val
     ELSEIF (ccf.xref_id=new_xref_id)
      new_xref_id_flag = 1, new_result_val = ccf.result_val, new_case_field_id = ccf.case_field_id
     ENDIF
    FOOT  ccf.case_dataset_r_id
     IF (old_xref_id_flag=1
      AND new_xref_id_flag=1
      AND new_result_val=old_result_val)
      case_field_id_cnt = (case_field_id_cnt+ 1)
      IF (mod(case_field_id_cnt,10)=1
       AND case_field_id_cnt != 1)
       stat = alterlist(case_field_ids->del_list,(case_field_id_cnt+ 9)), stat = alterlist(
        case_ds_r_ids->file_list,(case_field_id_cnt+ 9))
      ENDIF
      case_field_ids->del_list[case_field_id_cnt].case_field_id = new_case_field_id, case_ds_r_ids->
      file_list[case_field_id_cnt].case_ds_r_id = ccf.case_dataset_r_id
     ENDIF
     new_case_field_id = 0, new_xref_id_flag = 0, old_xref_id_flag = 0,
     new_result_val = "", old_result_val = ""
    FOOT REPORT
     stat = alterlist(case_field_ids->del_list,case_field_id_cnt), stat = alterlist(case_ds_r_ids->
      file_list,case_field_id_cnt)
    WITH nocounter, forupdate(ccf)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_CASE_FIELD"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (size(case_field_ids->del_list,5) != 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_case_field ccf,
      (dummyt d  WITH seq = value(size(case_field_ids->del_list,5)))
     SET ccf.seq = 1
     PLAN (d)
      JOIN (ccf
      WHERE (ccf.case_field_id=case_field_ids->del_list[d.seq].case_field_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_CASE_FIELD"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (curqual=0)
    CALL echo("No cases with duplicate ULN/ULM found in CCF.")
   ELSE
    CALL echo("Duplicate cases deleted from CCF.")
   ENDIF
   CALL addtosynchfile(null)
 END ;Subroutine
 SUBROUTINE updatereferencedata(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    cxv.xref_validation_id
    FROM cv_xref_validation cxv,
     cv_xref cx
    PLAN (cx
     WHERE cx.xref_internal_name="ACC02_OPPMI"
      AND cx.active_ind=1)
     JOIN (cxv
     WHERE cxv.xref_id=cx.xref_id
      AND cxv.child_xref_id IN (old_xref_id, new_xref_id)
      AND cxv.active_ind=1)
    ORDER BY cxv.xref_id
    DETAIL
     IF (cxv.child_xref_id=old_xref_id)
      old_xref_id_flag = 1
     ELSEIF (cxv.child_xref_id=new_xref_id)
      new_xref_id_flag = 1, new_xref_val_id = cxv.xref_validation_id
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_VALIDATION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (old_xref_id_flag=1
    AND new_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_xref_validation cxv
     WHERE cxv.xref_validation_id=new_xref_val_id
      AND cxv.xref_validation_id != 0
      AND cxv.active_ind=1
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_VALIDATION"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No duplicate ULN/ULM found in CXV.")
    ELSE
     CALL echo("Duplicates deleted from CXV.")
    ENDIF
   ENDIF
   SET old_xref_id_flag = 0
   SET new_xref_id_flag = 0
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    cr.xref_id
    FROM cv_response cr
    WHERE cr.xref_id IN (old_xref_id, new_xref_id)
     AND cr.active_ind=1
    ORDER BY cr.xref_id
    DETAIL
     IF (cr.xref_id=old_xref_id)
      old_xref_id_flag = 1
     ELSEIF (cr.xref_id=new_xref_id)
      new_xref_id_flag = 1
     ENDIF
    WITH nocounter, forupdate(cr)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_RESPONSE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (old_xref_id_flag=1
    AND new_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_response cr
     WHERE cr.xref_id=new_xref_id
      AND cr.response_id != 0
      AND cr.active_ind=1
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_RESPONSE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No duplicate ULN/ULM found in CR.")
    ELSE
     CALL echo("Duplicates deleted from CR.")
    ENDIF
   ENDIF
   IF (old_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM cv_response cr
     SET cr.response_internal_name = "ACC02_OCKULN_NO_PERIPROCEDURAL_MI", cr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), cr.updt_cnt = (cr.updt_cnt+ 1),
      cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
      updt_applctx
     WHERE cr.xref_id=old_xref_id
      AND cr.active_ind=1
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_RESPONSE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No ULN/ULM found in CR.")
    ELSE
     CALL echo("ULM updated to ULN in CR.")
    ENDIF
   ENDIF
   SET old_xref_id_flag = 0
   SET new_xref_id_flag = 0
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    cxf.xref_id
    FROM cv_xref_field cxf
    WHERE cxf.xref_id IN (new_xref_id, old_xref_id)
     AND cxf.active_ind=1
    ORDER BY cxf.xref_id
    DETAIL
     IF (cxf.xref_id=old_xref_id)
      old_xref_id_flag = 1
     ELSEIF (cxf.xref_id=new_xref_id)
      new_xref_id_flag = 1
     ENDIF
    WITH nocounter, forupdate(cxf)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_FIELD"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (old_xref_id_flag=1
    AND new_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_xref_field cxf
     WHERE cxf.xref_id=new_xref_id
      AND cxf.xref_field_id != 0
      AND cxf.active_ind=1
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_FIELD"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No duplicate ULN/ULM found in CXF.")
    ELSE
     CALL echo("Duplicates deleted from CXF.")
    ENDIF
   ENDIF
   IF (old_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM cv_xref_field cxf
     SET cxf.display_name = "OCKULN", cxf.updt_dt_tm = cnvtdatetime(curdate,curtime3), cxf.updt_cnt
       = (cxf.updt_cnt+ 1),
      cxf.updt_id = reqinfo->updt_id, cxf.updt_task = reqinfo->updt_task, cxf.updt_applctx = reqinfo
      ->updt_applctx
     WHERE cxf.xref_id=old_xref_id
      AND cxf.active_ind=1
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_FIELD"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No ULN/ULM found in CXF.")
    ELSE
     CALL echo("ULM updated to ULN in CXF.")
    ENDIF
   ENDIF
   SET old_xref_id_flag = 0
   SET new_xref_id_flag = 0
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    cx.xref_id
    FROM cv_xref cx
    WHERE cx.xref_id IN (old_xref_id, new_xref_id)
     AND cx.active_ind=1
    ORDER BY cx.xref_id
    DETAIL
     IF (cx.xref_id=old_xref_id)
      old_xref_id_flag = 1
     ELSEIF (cx.xref_id=new_xref_id)
      new_xref_id_flag = 1
     ENDIF
    WITH nocounter, forupdate(cx)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
   IF (old_xref_id_flag=1
    AND new_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM cv_xref cx
     WHERE cx.xref_id=new_xref_id
      AND cx.xref_id != 0
      AND cx.active_ind=1
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No duplicate ULN/ULM found in cv_xref.")
    ELSE
     CALL echo("Duplicates deleted from cv_xref.")
    ENDIF
   ENDIF
   IF (old_xref_id_flag=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM cv_xref cx
     SET cx.registry_field_name = "CK-MB ULN", cx.xref_internal_name = "ACC02_OCKULN", cx.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      cx.updt_cnt = (cx.updt_cnt+ 1), cx.updt_id = reqinfo->updt_id, cx.updt_task = reqinfo->
      updt_task,
      cx.updt_applctx = reqinfo->updt_applctx
     WHERE cx.xref_id=old_xref_id
      AND cx.active_ind=1
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET readme_data->status = "F"
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     CALL echo("No ULN/ULM found in cv_xref.")
    ELSE
     CALL echo("ULM updated to ULN in cv_xref.")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addtosynchfile(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "CV_UTL_UPD_ULN_SYNCH.CCL"
    cc.form_id
    FROM cv_case cc,
     cv_case_dataset_r ccdr,
     (dummyt d  WITH seq = value(size(case_ds_r_ids->file_list,5)))
    PLAN (d)
     JOIN (ccdr
     WHERE (ccdr.case_dataset_r_id=case_ds_r_ids->file_list[d.seq].case_ds_r_id)
      AND ccdr.active_ind=1)
     JOIN (cc
     WHERE cc.cv_case_id=ccdr.cv_case_id
      AND cc.active_ind=1)
    DETAIL
     col 0, 'CV_UTL_SYNCH_DATASET "","","",', cc.form_id,
     ',"Y" go', row + 1
    WITH noformat
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_CASE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET readme_data->status = "F"
    SET readme_data->message = serrmsg
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 CALL echorecord(ccad_ids)
 CALL echorecord(case_field_ids)
 CALL echorecord(case_ds_r_ids)
 CALL echorecord(reply)
 IF ((reply->status_data.status="S"))
  COMMIT
  CALL echo("Script executed successfully.")
  SET readme_data->status = "S"
  SET readme_data->message = "CV_UTL_UPD_ULN executed and commited successfully."
 ELSEIF ((reply->status_data.status="Z"))
  CALL echo("No changes made by CV_UTL_UPD_ULN.")
  SET readme_data->status = "S"
  SET readme_data->message = "No changes made by CV_UTL_UPD_ULN."
 ELSE
  ROLLBACK
  CALL echo("Script failed. Rolling back changes.")
 ENDIF
 EXECUTE dm_readme_status
END GO
