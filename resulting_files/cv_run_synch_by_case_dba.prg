CREATE PROGRAM cv_run_synch_by_case:dba
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
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply  is already defined !")
 ELSE
  RECORD reply(
    1 caserec[*]
      2 case_id = f8
      2 error_msg = vc
      2 status_cd = f8
      2 status_disp = vc
      2 status_mean = vc
      2 chart_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 name_full_formatted = vc
      2 form_id = f8
      2 form_ref_id = f8
      2 fieldrec[*]
        3 field_name = vc
        3 field_val = vc
        3 error_msg = vc
        3 status_cd = f8
        3 status_disp = vc
        3 status_mean = vc
        3 translated_val = vc
        3 case_field_id = f8
        3 long_text_id = f8
        3 dev_idx = i2
        3 lesion_idx = i2
    1 files[*]
      2 filename = vc
      2 info_line[*]
        3 new_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(internal,"notdefined")="notdefined")
  RECORD internal(
    1 forms[*]
      2 cv_case_exists = i2
      2 description = vc
      2 dcp_forms_activity_id = f8
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 event_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 children[*]
        3 parent_event_id = f8
        3 event_id = f8
        3 event_cd = f8
        3 task_assay_cd = f8
        3 result_val = vc
        3 result_status_cd = f8
        3 clinical_event_id = f8
  )
 ENDIF
 IF (validate(register,"notdefined")="notdefined")
  RECORD register(
    1 no_event_id_ind = i2
    1 calling_script_flag = i2
    1 cv_case_id = f8
    1 top_parent_event_id = f8
    1 rec[*]
      2 xref_id = f8
      2 event_id = f8
      2 parent_event_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 event_cd = f8
      2 clinical_event_id = f8
      2 result_val = vc
      2 result_dt_tm = f8
      2 result_id = f8
      2 insert_ind = i2
      2 dub_ind = i2
      2 result_status_cd = f8
      2 result_status_change_ind = f8
  )
 ENDIF
 SET register->calling_script_flag = 1
 DECLARE synch_failed = c1 WITH public, noconstant("F")
 DECLARE valid_date = vc WITH public, noconstant("31-DEC-2100")
 DECLARE child_cnt = i2 WITH public, noconstant(0)
 DECLARE searchcnt = i4 WITH public, noconstant(0)
 IF (validate(g_dataset_id,0.0)=0.0)
  DECLARE g_dataset_id = f8 WITH public, noconstant(0.0)
 ENDIF
 SELECT INTO "nl:"
  ccdr.dataset_id
  FROM (dummyt d  WITH seq = value(size(request->case_ids,5))),
   cv_case_dataset_r ccdr
  PLAN (d
   WHERE (request->case_ids[d.seq].cv_case_id > 0.0))
   JOIN (ccdr
   WHERE (ccdr.cv_case_id=request->case_ids[d.seq].cv_case_id))
  DETAIL
   g_dataset_id = ccdr.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Case is not in cv_case_dataset_r table, exit!")
  SET synch_failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cc.form_id
  FROM (dummyt d  WITH seq = value(size(request->case_ids,5))),
   cv_case cc
  PLAN (d)
   JOIN (cc
   WHERE (cc.cv_case_id=request->case_ids[d.seq].cv_case_id))
  HEAD REPORT
   form_cnt = 0
  DETAIL
   form_cnt = (form_cnt+ 1), stat = alterlist(internal->forms,form_cnt), internal->forms[form_cnt].
   cv_case_exists = 1,
   internal->forms[form_cnt].dcp_forms_activity_id = cc.form_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Case is not in cv_case table, exit!")
  SET synch_failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE number_forms = i4 WITH private, noconstant(0)
 SET number_forms = size(internal->forms,5)
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d  WITH seq = value(number_forms)),
   dcp_forms_activity_comp dfac,
   clinical_event ce
  PLAN (d
   WHERE (internal->forms[d.seq].dcp_forms_activity_id > 0))
   JOIN (dfac
   WHERE (dfac.dcp_forms_activity_id=internal->forms[d.seq].dcp_forms_activity_id)
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
  DETAIL
   stat = alterlist(internal->forms[d.seq].children,1), internal->forms[d.seq].parent_entity_name =
   dfac.parent_entity_name, internal->forms[d.seq].parent_entity_id = dfac.parent_entity_id,
   internal->forms[d.seq].event_id = ce.event_id, internal->forms[d.seq].children[1].event_id = ce
   .event_id, internal->forms[d.seq].person_id = ce.person_id,
   internal->forms[d.seq].encntr_id = ce.encntr_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed to select forms. Exiting....")
  SET synch_failed = "T"
  GO TO exit_script
 ENDIF
 FOR (searchcnt = 1 TO number_forms)
   DECLARE seek = i4 WITH public, noconstant(1)
   DECLARE previous_cnt = i4 WITH public, noconstant(0)
   DECLARE present_cnt = i4 WITH public, noconstant(1)
   WHILE (seek=1)
     SELECT INTO "NL:"
      parent_event_id = ce.parent_event_id, event_id = ce.event_id
      FROM (dummyt d  WITH seq = value(size(internal->forms[searchcnt].children,5))),
       clinical_event ce
      PLAN (d
       WHERE d.seq > previous_cnt)
       JOIN (ce
       WHERE (ce.parent_event_id=internal->forms[searchcnt].children[d.seq].event_id)
        AND (ce.event_id != internal->forms[searchcnt].children[d.seq].event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
      HEAD REPORT
       child_cnt = 0
      DETAIL
       child_cnt = (child_cnt+ 1)
       IF (child_cnt > size(internal->forms[searchcnt].children,5))
        stat = alterlist(internal->forms[searchcnt].children,(child_cnt+ 9))
       ENDIF
       internal->forms[searchcnt].children[child_cnt].event_id = ce.event_id, internal->forms[
       searchcnt].children[child_cnt].event_cd = ce.event_cd, internal->forms[searchcnt].children[
       child_cnt].task_assay_cd = ce.task_assay_cd,
       internal->forms[searchcnt].children[child_cnt].parent_event_id = ce.parent_event_id, internal
       ->forms[searchcnt].children[child_cnt].result_val = ce.result_val, internal->forms[searchcnt].
       children[child_cnt].result_status_cd = ce.result_status_cd,
       internal->forms[searchcnt].children[child_cnt].clinical_event_id = ce.clinical_event_id
      FOOT REPORT
       stat = alterlist(internal->forms[searchcnt].children,child_cnt)
      WITH nocounter
     ;end select
     SET previous_cnt = present_cnt
     SET present_cnt = size(internal->forms[searchcnt].children,5)
     IF (previous_cnt=present_cnt)
      SET seek = 2
     ENDIF
   ENDWHILE
   SET register->top_parent_event_id = internal->forms[searchcnt].parent_entity_id
   SET synch_failed = "F"
   SELECT INTO "NL:"
    ref.event_cd, ref.xref_id, internal->forms[searchcnt].children[d.seq].event_cd,
    internal->forms[searchcnt].children[d.seq].task_assay_cd
    FROM cv_xref ref,
     (dummyt d  WITH seq = value(size(internal->forms[searchcnt].children,5)))
    PLAN (d
     WHERE (internal->forms[searchcnt].children[d.seq].event_cd != 0))
     JOIN (ref
     WHERE (ref.event_cd=internal->forms[searchcnt].children[d.seq].event_cd)
      AND (ref.task_assay_cd=internal->forms[searchcnt].children[d.seq].task_assay_cd)
      AND ref.event_cd != 0
      AND ref.task_assay_cd != 0)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(register->rec,5))
      stat = alterlist(register->rec,(cnt+ 9))
     ENDIF
     register->calling_script_flag = 1, register->top_parent_event_id = internal->forms[searchcnt].
     parent_entity_id, register->rec[cnt].person_id = internal->forms[searchcnt].person_id,
     register->rec[cnt].encntr_id = internal->forms[searchcnt].encntr_id, register->rec[cnt].event_id
      = internal->forms[searchcnt].children[d.seq].event_id, register->rec[cnt].event_cd = internal->
     forms[searchcnt].children[d.seq].event_cd,
     register->rec[cnt].result_val = internal->forms[searchcnt].children[d.seq].result_val, register
     ->rec[cnt].parent_event_id = internal->forms[searchcnt].children[d.seq].parent_event_id,
     register->rec[cnt].result_status_cd = internal->forms[searchcnt].children[d.seq].
     result_status_cd,
     register->rec[cnt].xref_id = ref.xref_id, register->rec[cnt].result_status_change_ind = 1,
     register->rec[cnt].clinical_event_id = internal->forms[searchcnt].children[d.seq].
     clinical_event_id
    FOOT REPORT
     stat = alterlist(register->rec,cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("Incomming event_cd failed to match  reference table. Exiting....")
    SET synch_failed = "T"
    GO TO exit_script
   ENDIF
   EXECUTE cv_get_summary_data
   COMMIT
 ENDFOR
#exit_script
 IF (synch_failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  EXECUTE cv_get_harvest_audit_by_case
 ENDIF
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
