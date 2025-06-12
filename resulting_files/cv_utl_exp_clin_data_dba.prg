CREATE PROGRAM cv_utl_exp_clin_data:dba
 PROMPT
  "Output(Mine):" = "mine",
  "Form Name(Partial)(STS)" = "STS",
  "Number of Forms:(5)" = 5,
  "Parent Event ID:(0-All)(0)" = 0,
  "Charted After:(01-jul-2000)" = "01-jul-2000",
  "Status Log:(0-No 1-yes)(0)" = 0,
  "CDFMEaning for DCPGENERIC(DCPGENERIC)" = "DCPGENERIC",
  "CDFMEaning for DATE EventClass(DATE)" = "DATE",
  "Parent Entity Name on DCP Component table(CLINICAL_EVENT)" = "CLINICAL_EVENT",
  "File for DTA(CCLUSERDIR:cv_dta_exp.dat)" = "CCLUSERDIR:cv_dta_exp.dat"
 CALL echo("The Command line equivalent is::")
 SET cmd_line = build("cv_utl_exp_clin_data ",char(34), $1,char(34),",",
  char(34), $2,char(34),",", $3,
  ",", $4,",",char(34), $5,
  char(34),",", $6,",",char(34),
   $7,char(34),",",char(34), $8,
  char(34),",",char(34), $9,char(34),
  ",",char(34), $10,char(34)," go")
 CALL echo(cmd_line)
 SET start_date = cnvtdatetime(curdate,curtime)
 IF (( $5="CURDATE"))
  SET start_date = cnvtdatetime(curdate)
 ELSE
  SET start_date = cnvtdatetime( $5)
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
 RECORD internal(
   1 max_children = i4
   1 header1 = vc
   1 header2 = vc
   1 header3 = vc
   1 forms[*]
     2 old_cnt = i2
     2 cur_cnt = i2
     2 description = vc
     2 dcp_forms_activity_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 event_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 out_row = vc
     2 person_info
       3 name_last = vc
       3 name_first = vc
       3 name_middle = vc
       3 birth_dt = vc
       3 age = vc
       3 sex_mean = vc
       3 race_mean = vc
       3 ssn = vc
       3 mrn = vc
       3 zip = vc
       3 hosp_name = vc
       3 hosp_zip = vc
       3 hosp_state = vc
       3 adm_date = vc
       3 disch_date = vc
     2 children[*]
       3 parent_event_id = f8
       3 event_id = f8
       3 event_cd = f8
       3 task_assay_cd = f8
       3 result_val = vc
       3 event_disp = vc
       3 dta_disp = vc
       3 event_class_cd = f8
 )
 SET dataset_param = build("*",cnvtupper( $2),"*")
 CALL echo(dataset_param)
 SET continue = 1
 SET old_cnt = 0
 SET cur_cnt = 1
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
 SUBROUTINE cv_get_cd_for_cdf(param_codeset,param_cdfmeaning)
   SET cdf_meaning = fillstring(12," ")
   SET code_value = 0.0
   SET cdf_meaning = param_cdfmeaning
   SET code_set = param_codeset
   SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
   IF (code_value=0)
    CALL cv_log_message(concat("UAR Routine failed for code_set ",cnvtstring(code_set),
      "with cdf_meaning ",cdf_meaning))
   ENDIF
   IF (iret > 1)
    CALL cv_log_message(concat("UAR Routine found multiple code_values(",cnvtstring(iret),
      ") for code_set ",cnvtstring(code_set),"with cdf_meaning ",
      cdf_meaning))
   ENDIF
   RETURN(code_value)
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
 SET dcp_event_cd = 0.0
 SET dcp_event_cd = cv_get_cd_for_cdf(72, $7)
 SET event_class_date_cd = 0.0
 SET event_class_date_cd = cv_get_cd_for_cdf(53, $8)
 SET failed = "F"
 SET valid_date = "31-Dec-2100"
 SET numbers_of_forms = 0
 SET form_id = 0.0
 SELECT INTO "nl:"
  dfr.description
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE trim(cnvtupper(dfr.description))=patstring(dataset_param)
    AND dfr.active_ind=1)
  DETAIL
   form_id = dfr.dcp_forms_ref_id,
   CALL echo(build("The FormId is ::",form_id))
  WITH nocounter
 ;end select
 CALL echo(form_id)
 IF (form_id=0)
  GO TO exit_script
 ENDIF
 SET where_cond = build("dfac.parent_entity_id >= ", $4)
 CALL echo(build(" The fourth condition is ",where_cond))
 SELECT INTO "nl:"
  dfr.description, dfa.dcp_forms_ref_id, dfa.beg_activity_dt_tm,
  dfac.dcp_forms_activity_id, dfac.parent_entity_id, ce.event_id
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce
  PLAN (dfr
   WHERE trim(cnvtupper(dfr.description))=patstring(dataset_param)
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfa.beg_activity_dt_tm > cnvtdatetime(start_date))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND (dfac.parent_entity_name= $9)
    AND parser(where_cond))
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
  DETAIL
   numbers_of_forms = (numbers_of_forms+ 1), stat = alterlist(internal->forms,numbers_of_forms), stat
    = alterlist(internal->forms[numbers_of_forms].children,1),
   internal->forms[numbers_of_forms].description = dfr.description, internal->forms[numbers_of_forms]
   .dcp_forms_activity_id = dfa.dcp_forms_activity_id, internal->forms[numbers_of_forms].
   parent_entity_name = dfac.parent_entity_name,
   internal->forms[numbers_of_forms].parent_entity_id = dfac.parent_entity_id, internal->forms[
   numbers_of_forms].event_id = ce.event_id, internal->forms[numbers_of_forms].person_id = ce
   .person_id,
   internal->forms[numbers_of_forms].encntr_id = ce.encntr_id, internal->forms[numbers_of_forms].
   children[1].event_id = ce.event_id, internal->forms[numbers_of_forms].cur_cnt = 1
  WITH maxrec = value( $3), nocounter
 ;end select
 SET internal->max_children = 1
 SET continue = 1
 SET old_cnt = 0
 SET cur_cnt = 1
 WHILE (continue=1)
  SELECT INTO "NL:"
   code_disp = uar_get_code_display(ce.event_cd), dta_disp = uar_get_code_display(ce.task_assay_cd),
   ce.*
   FROM (dummyt d1  WITH seq = value(size(internal->forms,5))),
    (dummyt d2  WITH seq = value(internal->max_children)),
    clinical_event ce
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(internal->forms[d1.seq].children,5)
     AND (d2.seq > internal->forms[d1.seq].old_cnt))
    JOIN (ce
    WHERE (ce.parent_event_id=internal->forms[d1.seq].children[d2.seq].event_id)
     AND (ce.event_id != internal->forms[d1.seq].children[d2.seq].event_id)
     AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
   ORDER BY d1.seq
   DETAIL
    ce.event_id, col + 5, ce.parent_event_id,
    row + 1, stat = alterlist(internal->forms[d1.seq].children,(size(internal->forms[d1.seq].children,
      5)+ 1)), child_cnt = size(internal->forms[d1.seq].children,5),
    internal->forms[d1.seq].children[child_cnt].event_id = ce.event_id, internal->forms[d1.seq].
    children[child_cnt].event_cd = ce.event_cd, internal->forms[d1.seq].children[child_cnt].
    task_assay_cd = ce.task_assay_cd,
    internal->forms[d1.seq].children[child_cnt].dta_disp = dta_disp, internal->forms[d1.seq].
    children[child_cnt].event_disp = code_disp, internal->forms[d1.seq].children[child_cnt].
    parent_event_id = ce.parent_event_id,
    internal->forms[d1.seq].children[child_cnt].result_val = ce.result_val, internal->forms[d1.seq].
    children[child_cnt].event_class_cd = ce.event_class_cd
   FOOT  d1.seq
    IF ((internal->max_children < size(internal->forms[d1.seq].children,5)))
     internal->max_children = size(internal->forms[d1.seq].children,5)
    ENDIF
    internal->forms[d1.seq].old_cnt = internal->forms[d1.seq].cur_cnt, internal->forms[d1.seq].
    cur_cnt = size(internal->forms[d1.seq].children,5)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET continue = 2
  ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  dr.*
  FROM (dummyt d1  WITH seq = value(size(internal->forms,5))),
   (dummyt d2  WITH seq = value(internal->max_children)),
   ce_date_result dr
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal->forms[d1.seq].children,5)
    AND (internal->forms[d1.seq].children[d2.seq].event_class_cd=event_class_date_cd))
   JOIN (dr
   WHERE (dr.event_id=internal->forms[d1.seq].children[d2.seq].event_id))
  DETAIL
   internal->forms[d1.seq].children[d2.seq].result_val = format(dr.result_dt_tm,"@SHORTDATE")
  WITH nocounter
 ;end select
 GO TO next_loop
 FOR (searchcnt = 1 TO numbers_of_forms)
   SET continue = 1
   SET old_cnt = 0
   SET cur_cnt = 1
   WHILE (continue=1)
     SELECT INTO "NL:"
      code_disp = uar_get_code_display(ce.event_cd), ce.*
      FROM (dummyt d  WITH seq = value(size(internal->forms[searchcnt].children,5))),
       clinical_event ce
      PLAN (d
       WHERE d.seq > old_cnt)
       JOIN (ce
       WHERE (ce.parent_event_id=internal->forms[searchcnt].children[d.seq].event_id)
        AND (ce.event_id != internal->forms[searchcnt].children[d.seq].event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
      DETAIL
       ce.event_id, col + 5, ce.parent_event_id,
       row + 1, stat = alterlist(internal->forms[searchcnt].children,(size(internal->forms[searchcnt]
         .children,5)+ 1)), child_cnt = size(internal->forms[searchcnt].children,5),
       internal->forms[searchcnt].children[child_cnt].event_id = ce.event_id, internal->forms[
       searchcnt].children[child_cnt].event_cd = ce.event_cd, internal->forms[searchcnt].children[
       child_cnt].event_disp = code_disp,
       internal->forms[searchcnt].children[child_cnt].parent_event_id = ce.parent_event_id, internal
       ->forms[searchcnt].children[child_cnt].result_val = ce.result_val
      WITH nocounter
     ;end select
     SET old_cnt = cur_cnt
     SET cur_cnt = size(internal->forms[searchcnt].children,5)
     IF (old_cnt=cur_cnt)
      SET continue = 2
     ENDIF
   ENDWHILE
   IF ((internal->max_children < size(internal->forms[searchcnt].children,5)))
    SET internal->max_children = size(internal->forms[searchcnt].children,5)
   ENDIF
 ENDFOR
#next_loop
 CALL echorecord(internal,"CER_TEMP:CV_CLIN.DAT")
 RECORD request(
   1 select_nbr = i4
   1 qual[*]
     2 person_id = f8
 )
 SET request->select_nbr = 11
 SET stat = alterlist(request->qual,size(internal->forms,5))
 FOR (i = 1 TO size(internal->forms,5))
   SET request->qual[i].person_id = internal->forms[i].person_id
 ENDFOR
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 name_full_formatted = vc
      2 birth_dt_tm = dq8
      2 age = vc
      2 race_cd = f8
      2 race_disp = c40
      2 race_mean = c12
      2 sex_cd = f8
      2 sex_disp = c40
      2 sex_mean = c12
      2 name_last = vc
      2 name_first = vc
      2 name_middle = vc
      2 person_alias[*]
        3 person_alias_id = f8
        3 alias_pool_cd = f8
        3 person_alias_type_cd = f8
        3 person_alias_type_disp = c40
        3 person_alias_type_mean = c12
        3 alias = vc
        3 alias_formatted = vc
      2 person_name[*]
      2 address[*]
        3 address_id = f8
        3 address_type_cd = f8
        3 address_type_disp = c40
        3 address_type_mean = c12
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city = vc
        3 state_cd = f8
        3 state_disp = c40
        3 state_mean = c12
        3 zipcode = c25
        3 county_cd = f8
        3 county_disp = c40
        3 county_mean = c25
        3 country_cd = f8
        3 country_disp = c40
        3 country_mean = c25
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 EXECUTE cv_get_person_master
 SELECT INTO "nl:"
  FROM encounter e,
   (dummyt d1  WITH seq = value(size(internal->forms,5)))
  PLAN (d1
   WHERE (internal->forms[d1.seq].encntr_id > 0))
   JOIN (e
   WHERE (e.encntr_id=internal->forms[d1.seq].encntr_id))
  DETAIL
   internal->forms[d1.seq].person_info.disch_date = format(e.disch_dt_tm,"MM/DD/YY;;D"), internal->
   forms[d1.seq].person_info.adm_date = format(e.reg_dt_tm,"MM/DD/YY;;D"), internal->forms[d1.seq].
   person_info.hosp_name = "Research Medical Center",
   internal->forms[d1.seq].person_info.hosp_state = "MO", internal->forms[d1.seq].person_info.
   hosp_zip = "64132"
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(internal->forms,5))
   SET internal->forms[i].person_info.name_last = reply->qual[i].name_last
   SET internal->forms[i].person_info.name_first = reply->qual[i].name_first
   SET internal->forms[i].person_info.name_middle = substring(1,1,reply->qual[i].name_middle)
   SET internal->forms[i].person_info.birth_dt = format(reply->qual[i].birth_dt_tm,"MM/DD/YY;;D")
   SET internal->forms[i].person_info.age = reply->qual[i].age
   SET internal->forms[i].person_info.sex_mean = uar_get_code_meaning(reply->qual[i].sex_cd)
   SET internal->forms[i].person_info.race_mean = uar_get_code_display(reply->qual[i].race_cd)
   FOR (j = 1 TO size(reply->qual[i].person_alias,5))
     IF (uar_get_code_meaning(reply->qual[i].person_alias[j].person_alias_type_cd)="SSN")
      SET internal->forms[i].person_info.ssn = reply->qual[i].person_alias[j].alias
     ENDIF
   ENDFOR
   FOR (j = 1 TO size(reply->qual[i].person_alias,5))
     IF (uar_get_code_meaning(reply->qual[i].person_alias[j].person_alias_type_cd)="MRN")
      SET internal->forms[i].person_info.mrn = reply->qual[i].person_alias[j].alias
     ENDIF
   ENDFOR
   FOR (j = 1 TO size(reply->qual[i].address,5))
     IF (uar_get_code_meaning(reply->qual[i].address[j].address_type_cd)="HOME")
      SET internal->forms[i].person_info.zip = reply->qual[i].address[j].zipcode
     ENDIF
   ENDFOR
 ENDFOR
 RECORD request_csv(
   1 file_name = vc
 )
 IF ( NOT (validate(reply_csv,0)))
  RECORD reply_csv(
    1 max_values = i4
    1 list[*]
      2 line = vc
      2 value = vc
      2 mnem = vc
      2 desc = vc
      2 event_cd = f8
      2 dta_cd = f8
      2 values[*]
        3 value = vc
        3 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET request_csv->file_name =  $10
 EXECUTE cv_utl_read_csv  WITH replace(request,request_csv), replace(reply,reply_csv)
 CALL echorecord(reply_csv,"CCLUSERDIR:cv_read.dat")
 FOR (i = 1 TO size(reply_csv->list,5))
   FOR (j = 1 TO size(reply_csv->list[i].values,5))
     CASE (reply_csv->list[i].values[j].name)
      OF "event_cd":
       SET reply_csv->list[i].event_cd = cnvtreal(reply_csv->list[i].values[j].value)
      OF "task_assay_cd":
       SET reply_csv->list[i].dta_cd = cnvtreal(reply_csv->list[i].values[j].value)
      OF "EVENTDISP":
       SET reply_csv->list[i].value = reply_csv->list[i].values[j].value
      OF "mnem":
       SET reply_csv->list[i].mnem = reply_csv->list[i].values[j].value
      OF "desc":
       SET reply_csv->list[i].desc = reply_csv->list[i].values[j].value
     ENDCASE
   ENDFOR
 ENDFOR
 CALL echorecord(reply_csv,"CCLUSERDIR:cv_read.dat")
 CALL echo(build("Maximum number of Children::",internal->max_children))
 SET event_name = fillstring(100," ")
 SET event_value = fillstring(100," ")
 SET form_value = fillstring(100," ")
 SELECT INTO value( $1)
  d1seq = d1.seq, d2seq = d2.seq, case_idx = d2.seq,
  child_idx = d4.seq, event_disp = reply_csv->list[d1.seq].value, dta_cd = reply_csv->list[d1.seq].
  dta_cd,
  event_cd = reply_csv->list[d1.seq].event_cd, dta_desc = reply_csv->list[d1.seq].desc, dta_disp =
  internal->forms[d2.seq].children[d4.seq].dta_disp,
  event_disp = internal->forms[d2.seq].children[d4.seq].event_disp, res_value = internal->forms[d2
  .seq].children[d4.seq].result_val, dta_mnemonic = reply_csv->list[d1.seq].mnem
  FROM (dummyt d1  WITH seq = value(size(reply_csv->list,5))),
   (dummyt d2  WITH seq = value(size(internal->forms,5))),
   dummyt d3,
   (dummyt d4  WITH seq = value(internal->max_children))
  PLAN (d1)
   JOIN (d2)
   JOIN (d3)
   JOIN (d4
   WHERE d4.seq <= size(internal->forms[d2.seq].children,5)
    AND (internal->forms[d2.seq].children[d4.seq].event_cd=reply_csv->list[d1.seq].event_cd))
  ORDER BY case_idx, dta_mnemonic
  HEAD REPORT
   case_cnt = 0, internal->header1 = build("event_id",",","name_last",",","name_first",
    ",","name_middle",",","birth_dt",",",
    "age",",","sex",",","race",
    ",","ssn",",","zip",",",
    "mrn",",","disch_date",",","adm_date",
    ",","hosp_name",",","hosp_state",",",
    "hosp_zip"), internal->header2 = internal->header1,
   internal->header3 = internal->header1
  HEAD case_idx
   case_cnt = (case_cnt+ 1), internal->forms[case_idx].out_row = build(internal->forms[case_idx].
    event_id,",",internal->forms[case_idx].person_info.name_last,",",internal->forms[case_idx].
    person_info.name_first,
    ",",internal->forms[case_idx].person_info.name_middle,",",internal->forms[case_idx].person_info.
    birth_dt,",",
    internal->forms[case_idx].person_info.age,",",internal->forms[case_idx].person_info.sex_mean,",",
    internal->forms[case_idx].person_info.race_mean,
    ",",internal->forms[case_idx].person_info.ssn,",",internal->forms[case_idx].person_info.zip,",",
    internal->forms[case_idx].person_info.mrn,",",internal->forms[case_idx].person_info.disch_date,
    ",",internal->forms[case_idx].person_info.adm_date,
    ",",internal->forms[case_idx].person_info.hosp_name,",",internal->forms[case_idx].person_info.
    hosp_state,",",
    internal->forms[case_idx].person_info.hosp_zip)
  DETAIL
   col 0
  FOOT  dta_mnemonic
   IF (case_cnt=1)
    internal->header1 = build(internal->header1,",",reply_csv->list[d1.seq].value), internal->header2
     = build(internal->header2,",",reply_csv->list[d1.seq].mnem), internal->header3 = build(internal
     ->header3,",",reply_csv->list[d1.seq].desc)
   ENDIF
   IF (findstring(",",internal->forms[d2.seq].children[d4.seq].result_val) > 0)
    internal->forms[case_idx].out_row = build(internal->forms[case_idx].out_row,",",char(34),internal
     ->forms[d2.seq].children[d4.seq].result_val,char(34))
   ELSE
    internal->forms[case_idx].out_row = build(internal->forms[case_idx].out_row,",",internal->forms[
     d2.seq].children[d4.seq].result_val)
   ENDIF
  FOOT  case_idx
   IF (case_cnt=1)
    internal->header1, row + 1, internal->header2,
    row + 1, internal->header3
   ENDIF
   row + 1, internal->forms[case_idx].out_row
  WITH nocounter, outerjoin = d3, maxcol = 6000,
   format = variable, noformfeed, maxrow = 1
 ;end select
 CALL echorecord(internal,"CER_TEMP:CV_CLIN.DAT")
 CALL echorecord(reply_csv,"CER_TEMP:CV_csv.DAT")
 IF (( $6 > 0))
  SELECT INTO "CCLUSERDIR:CV_EXP_LOG.DAT"
   FROM dual
   HEAD REPORT
    "The Program Succeeded!!", row + 1, "DCP GENERIC CODE is::",
    dcp_event_cd, row + 1
   DETAIL
    thissize = size(internal->forms,5), "The number of Forms is ::", thissize,
    row + 1
    FOR (i = 1 TO thissize)
      numchild = size(internal->forms[i].children,5), "The number of Child events on the Form ", i,
      " is ", numchild, row + 1,
      numrealchild = 0
      FOR (j = 1 TO numchild)
        IF ((dcp_event_cd != internal->forms[i].children[j].event_cd))
         numrealchild = (numrealchild+ 1)
        ENDIF
      ENDFOR
      "The number of Real Child  events on the Form ", i, " is ",
      numrealchild, row + 1
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echo(cmd_line)
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
