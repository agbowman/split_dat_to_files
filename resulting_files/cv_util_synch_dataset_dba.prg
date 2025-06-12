CREATE PROGRAM cv_util_synch_dataset:dba
 PROMPT
  "Please enter dataset name (embedded in quotes) to synchronize = " = "ACC02",
  "Enter the begining date of forms (embedded in quotes e.g 01-JAN-2000) to process = " =
  "01-JAN-2000",
  "Enter the ending date of forms (embedded in quotes e.g 31-DEC-2000) to process = " = "30-MAY-2001",
  "Enter the Form Id  = " = " ",
  "Override existing Case(Y/N)[N] = " = "N"
 RECORD temp_date(
   1 input_startdatevalue = dq8
   1 input_enddatevalue = dq8
 )
 SET dataset_param = build("*",cnvtupper( $1),"*")
 SET override_case = 0
 SET temp_date->input_startdatevalue = cnvtdate2( $2,"DD-MMM-YYYY")
 SET temp_date->input_enddatevalue = cnvtdate2( $3,"DD-MMM-YYYY")
 SET input_form_id = cnvtint( $4)
 SET activity_cond = fillstring(250," ")
 SET activity_cond = "0=0"
 IF (input_form_id > 0)
  SET activity_cond = "dfa.dcp_forms_activity_id = input_form_id"
 ELSE
  SET activity_cond = concat("dfa.form_dt_tm between cnvtdatetime(temp_date->input_StartdateValue) ",
   " and cnvtdatetime(temp_date->input_enddateValue)")
 ENDIF
 CASE ( $5)
  OF "Y":
  OF "y":
   SET override_case = 1
  OF "N":
  OF "n":
   SET override_case = 0
 ENDCASE
 CALL echo(build("override_case",override_case))
 CALL echo(build("Activity_cond",activity_cond))
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
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply  is already defined!")
 ELSE
  RECORD reply(
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
 IF (validate(register,"notdefined") != "notdefined")
  CALL echo("Register Record is already defined!")
 ELSE
  CALL echo(" ")
 ENDIF
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
 SET register->calling_script_flag = 1
 SET failed = "F"
 SET valid_date = "31-Dec-2100"
 SET numbers_of_forms = 0
 SET child_cnt = 0
 CALL cv_log_message(build("dataset parameter",dataset_param))
 CALL echo(build("input_StartdateValue",format(temp_date->input_startdatevalue,"MM/DD/YYYY;;d")))
 CALL echo(build("input_EnddateValue",format(temp_date->input_enddatevalue,"MM/DD/YYYY;;d")))
 SET numbers_of_forms = 0
 SELECT INTO "nl:"
  dfr.description, dfa.dcp_forms_ref_id, dfac.dcp_forms_activity_id,
  dfac.parent_entity_id, ce.event_id
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce
  PLAN (dfr
   WHERE trim(cnvtupper(dfr.description))=patstring(cnvtupper(dataset_param))
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE parser(activity_cond)
    AND dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id)
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
  HEAD REPORT
   numbers_of_forms = 0
  DETAIL
   numbers_of_forms = (numbers_of_forms+ 1), stat = alterlist(internal->forms,numbers_of_forms), stat
    = alterlist(internal->forms[numbers_of_forms].children,1),
   internal->forms[numbers_of_forms].description = dfr.description, internal->forms[numbers_of_forms]
   .dcp_forms_activity_id = dfa.dcp_forms_activity_id, internal->forms[numbers_of_forms].
   parent_entity_name = dfac.parent_entity_name,
   internal->forms[numbers_of_forms].parent_entity_id = dfac.parent_entity_id, internal->forms[
   numbers_of_forms].event_id = ce.event_id, internal->forms[numbers_of_forms].children[1].event_id
    = ce.event_id,
   internal->forms[numbers_of_forms].person_id = ce.person_id, internal->forms[numbers_of_forms].
   encntr_id = ce.encntr_id
  WITH nocounter
 ;end select
 SET firstchildrensize = size(internal->forms,5)
 CALL cv_log_message(build("firstChildrenSize ::",numbers_of_forms))
 IF (curqual=0)
  SET cv_log_level = 0
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed to select forms. Exiting....")
  SET failed = "T"
  GO TO exit_script
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,internal)
 SELECT INTO "nl:"
  FROM cv_case c,
   (dummyt d  WITH seq = value(size(internal->forms,5)))
  PLAN (d)
   JOIN (c
   WHERE (c.form_id=internal->forms[d.seq].dcp_forms_activity_id))
  DETAIL
   internal->forms[d.seq].cv_case_exists = 1
  WITH nocounter
 ;end select
 FOR (searchcnt = 1 TO numbers_of_forms)
  IF ((((internal->forms[searchcnt].cv_case_exists=0)) OR (override_case=1)) )
   SET seek = 1
   SET previous_cnt = 0
   SET present_cnt = 1
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
      DETAIL
       stat = alterlist(internal->forms[searchcnt].children,(size(internal->forms[searchcnt].children,
         5)+ 1)), child_cnt = size(internal->forms[searchcnt].children,5), internal->forms[searchcnt]
       .children[child_cnt].event_id = ce.event_id,
       internal->forms[searchcnt].children[child_cnt].event_cd = ce.event_cd, internal->forms[
       searchcnt].children[child_cnt].task_assay_cd = ce.task_assay_cd, internal->forms[searchcnt].
       children[child_cnt].parent_event_id = ce.parent_event_id,
       internal->forms[searchcnt].children[child_cnt].result_val = ce.result_val, internal->forms[
       searchcnt].children[child_cnt].result_status_cd = ce.result_status_cd, internal->forms[
       searchcnt].children[child_cnt].clinical_event_id = ce.clinical_event_id
      WITH nocounter
     ;end select
     SET previous_cnt = present_cnt
     SET present_cnt = size(internal->forms[searchcnt].children,5)
     IF (previous_cnt=present_cnt)
      SET seek = 2
     ENDIF
     CALL cv_log_message(build("The Current Count::",present_cnt))
   ENDWHILE
   EXECUTE cv_log_struct  WITH replace(request,internal)
   SET register->top_parent_event_id = internal->forms[searchcnt].parent_entity_id
   SET failed = "F"
   SELECT INTO "NL:"
    ref.event_cd, ref.xref_id, internal->forms[searchcnt].children[d.seq].event_cd,
    internal->forms[searchcnt].children[d.seq].task_assay_cd, ref.*
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
     cnt = (cnt+ 1), stat = alterlist(register->rec,cnt), register->calling_script_flag = 1,
     register->top_parent_event_id = internal->forms[searchcnt].parent_entity_id, register->rec[cnt].
     person_id = internal->forms[searchcnt].person_id, register->rec[cnt].encntr_id = internal->
     forms[searchcnt].encntr_id,
     register->rec[cnt].event_id = internal->forms[searchcnt].children[d.seq].event_id, register->
     rec[cnt].event_cd = internal->forms[searchcnt].children[d.seq].event_cd, register->rec[cnt].
     result_val = internal->forms[searchcnt].children[d.seq].result_val,
     register->rec[cnt].parent_event_id = internal->forms[searchcnt].children[d.seq].parent_event_id,
     register->rec[cnt].result_status_cd = internal->forms[searchcnt].children[d.seq].
     result_status_cd, register->rec[cnt].xref_id = ref.xref_id,
     register->rec[cnt].result_status_change_ind = 1, register->rec[cnt].clinical_event_id = internal
     ->forms[searchcnt].children[d.seq].clinical_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET cv_log_level = 0
    CALL cv_log_current_default(0)
    CALL cv_log_message("Incomming event_cd failed to match  reference table. Exiting....")
    SET failed = "T"
    GO TO exit_script
   ENDIF
   EXECUTE cv_log_struct  WITH replace(request,register)
   EXECUTE cv_get_summary_data
   COMMIT
  ENDIF
  CALL cv_log_message(build("***",searchcnt,"*** of ",numbers_of_forms," Imported."))
 ENDFOR
 EXECUTE cv_log_struct  WITH replace(request,register)
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
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
