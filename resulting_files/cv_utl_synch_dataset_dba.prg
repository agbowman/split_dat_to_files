CREATE PROGRAM cv_utl_synch_dataset:dba
 PROMPT
  "Enter form description to synchronize (e.g. ACC, Society)[*] = " = "*",
  "Enter the begining date of forms (e.g 01-JAN-1998) to process = " = "01-JAN-1998",
  "Enter the ending date of forms (e.g 31-DEC-2003) to process = " = "31-DEC-2003",
  "Enter the Form Id  = " = " ",
  "Override existing Case(Y/N)[N] = " = "N"
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
 FREE RECORD temp_date
 RECORD temp_date(
   1 input_startdatevalue = dq8
   1 input_enddatevalue = dq8
 )
 DECLARE dataset_param = vc WITH protect
 DECLARE override_case = i2 WITH protect
 DECLARE input_form_id = f8 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE g_sts_dataset_present_flag = i2 WITH protect
 DECLARE synch_failed = c1 WITH protect, noconstant("T")
 DECLARE valid_date = vc WITH protect
 DECLARE numbers_of_forms = i4 WITH protect
 DECLARE child_cnt = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE num1 = i4 WITH protect
 DECLARE index = i4 WITH protect
 DECLARE firstchildrensize = i4 WITH protect
 DECLARE case_uncharted = c1 WITH protect
 DECLARE case_inprogress = c1 WITH protect
 DECLARE inerror_cd = f8 WITH protect
 DECLARE inprogress_cd = f8 WITH protect
 DECLARE register_cnt = i4 WITH protect
 DECLARE seek = i4 WITH protect
 DECLARE previous_cnt = i4 WITH protect
 DECLARE present_cnt = i4 WITH protect
 DECLARE child_cnt = i4 WITH protect
 DECLARE searchcnt = i4 WITH protect
 DECLARE inerror_cs = i4 WITH protect
 DECLARE inerror_mean = vc WITH protect
 DECLARE inprogress_mean = vc WITH protect
 DECLARE add_valves_to_lookup(dummy=i2) = null
 DECLARE do_lookup_dta_translation(searchcnt=i4) = null
 DECLARE initial_lookup_cnt = i4 WITH protect
 DECLARE valve_lookup_cnt = i4 WITH protect
 DECLARE valve_type_cnt = i4 WITH protect
 DECLARE valve_cnt = i4 WITH protect
 DECLARE v_loca_tot = i4 WITH protect
 DECLARE v_type_tot = i4 WITH protect
 DECLARE valve_mean = vc WITH protect
 DECLARE v_type_max = i4 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE lookup_cnt = i4 WITH protect
 DECLARE synch_error_msg = vc WITH protect
 DECLARE synch_error = i4 WITH protect
 SET override_case = 0
 SET dataset_param = build("*",cnvtupper( $1),"*")
 SET temp_date->input_startdatevalue = cnvtdate2( $2,"DD-MMM-YYYY")
 SET temp_date->input_enddatevalue = cnvtdate2( $3,"DD-MMM-YYYY")
 SET input_form_id = cnvtreal( $4)
 CASE ( $5)
  OF "Y":
  OF "y":
   SET override_case = 1
  OF "N":
  OF "n":
   SET override_case = 0
 ENDCASE
 CALL echo(build("override_case:",override_case))
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
 SET reply->status_data.status = "F"
 FREE RECORD internal
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
     2 dataset_id = f8
     2 form_type_cd = f8
 )
 IF (validate(register,"notdefined") != "notdefined")
  CALL echo("Register Record is already defined!")
 ELSE
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
    1 form_type_cd = f8
  )
 ENDIF
 SET g_sts_dataset_present_flag = false
 FREE RECORD lookup
 RECORD lookup(
   1 qual[*]
     2 org_dta = f8
     2 new_dta = f8
     2 new_ec = f8
 )
 DECLARE dfac_cs = i4 WITH protect, constant(18189)
 DECLARE dfac_cd = f8 WITH protect
 SET dfac_cd = uar_get_code_by("MEANING",dfac_cs,"CLINCALEVENT")
 IF (dfac_cd <= 0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=dfac_cs
    AND cv.cdf_meaning="CLINCALEVENT"
    AND cv.active_ind=1
   DETAIL
    dfac_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (dfac_cd <= 0.0)
  CALL cv_log_message("Unable to find code value for meaning CLINCALEVENT on code_set 18189")
  SET synch_failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to find code value for meaning CLINCALEVENT on code_set 18189"
  GO TO exit_script
 ENDIF
 SET register->calling_script_flag = 1
 SET valid_date = "31-DEC-2100"
 SET numbers_of_forms = 0
 SET child_cnt = 0
 CALL cv_log_message(build("dataset parameter",dataset_param))
 CALL echo(build("input_StartdateValue",format(temp_date->input_startdatevalue,"MM/DD/YYYY;;d")))
 CALL echo(build("input_EnddateValue",format(temp_date->input_enddatevalue,"MM/DD/YYYY;;d")))
 IF (validate(g_dataset_id,0.0) != 0.0)
  CALL cv_log_message("g_Dataset_ID is already defined!")
 ELSE
  DECLARE g_dataset_id = f8 WITH public, noconstant(0.0)
 ENDIF
 SELECT
  IF (input_form_id != 0.0)
   PLAN (dfa
    WHERE dfa.dcp_forms_activity_id=input_form_id)
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
     AND dfr.active_ind=1)
    JOIN (dfac
    WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
     AND dfac.parent_entity_name="CLINICAL_EVENT"
     AND dfac.component_cd=dfac_cd)
    JOIN (ce
    WHERE ce.event_id=dfac.parent_entity_id
     AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
    JOIN (dp
    WHERE dp.pref_domain="CVNET"
     AND dp.pref_section="CV Dataset Form"
     AND dp.parent_entity_name="DCP_FORMS_REF"
     AND dp.parent_entity_id=dfa.dcp_forms_ref_id)
    JOIN (cd
    WHERE cd.dataset_internal_name=substring(1,5,dp.pref_name))
    JOIN (c
    WHERE c.encntr_id=outerjoin(dfa.encntr_id)
     AND c.form_id=outerjoin(dfa.dcp_forms_activity_id))
  ELSE
  ENDIF
  INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   dm_prefs dp,
   cv_case c,
   cv_dataset cd
  PLAN (dfr
   WHERE trim(cnvtupper(dfr.description))=patstring(cnvtupper(dataset_param))
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfa.form_dt_tm BETWEEN cnvtdatetime(temp_date->input_startdatevalue) AND cnvtdatetime(
    temp_date->input_enddatevalue)
    AND dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.parent_entity_name="CLINICAL_EVENT"
    AND dfac.component_cd=dfac_cd)
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(valid_date))
   JOIN (dp
   WHERE dp.pref_domain="CVNET"
    AND dp.pref_section="CV Dataset Form"
    AND dp.parent_entity_name="DCP_FORMS_REF"
    AND dp.parent_entity_id=dfa.dcp_forms_ref_id)
   JOIN (cd
   WHERE cd.dataset_internal_name=substring(1,5,dp.pref_name)
    AND cd.dataset_id != 0.0)
   JOIN (c
   WHERE c.encntr_id=outerjoin(dfa.encntr_id)
    AND c.form_id=outerjoin(dfa.dcp_forms_activity_id))
  ORDER BY dfr.description
  HEAD REPORT
   numbers_of_forms = 0
  HEAD dfr.description
   IF (dfr.description=patstring("Society*"))
    g_sts_dataset_present_flag = true
   ENDIF
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
   encntr_id = ce.encntr_id, internal->forms[numbers_of_forms].dataset_id = cd.dataset_id
   IF (dp.pref_cd != 0.0)
    internal->forms[numbers_of_forms].form_type_cd = dp.pref_cd
   ENDIF
   IF (c.form_id != 0.0)
    internal->forms[numbers_of_forms].cv_case_exists = 1
   ENDIF
  FOOT  dfr.description
   col 0
  FOOT REPORT
   col 0
  WITH nocounter
 ;end select
 SET firstchildrensize = size(internal->forms,5)
 IF (curqual=0)
  SET cv_log_level = 0
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed to select forms. Exiting....")
  GO TO exit_script
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,internal)
 CALL cv_log_message(concat("* Synching ",trim(cnvtstring(numbers_of_forms),3)," forms."))
 SET inerror_mean = "INERROR"
 SET inprogress_mean = "IN PROGRESS"
 SET inerror_cs = 8
 SET inerror_cd = uar_get_code_by("MEANING",inerror_cs,nullterm(inerror_mean))
 IF (inerror_cd <= 0.0)
  CALL echo("UAR did not return code value for meaning INERROR on CS 8")
 ENDIF
 SET inprogress_cd = uar_get_code_by("MEANING",inerror_cs,nullterm(inprogress_mean))
 IF (inprogress_cd <= 0.0)
  CALL echo("UAR did not return code_value for meaning IN PROGRESS on CS 8")
 ENDIF
 IF (g_sts_dataset_present_flag)
  CALL add_valves_to_lookup(null)
 ENDIF
 FOR (searchcnt = 1 TO numbers_of_forms)
   SET case_uncharted = "F"
   SET case_inprogress = "F"
   SET child_cnt = size(internal->forms[searchcnt].children,5)
   IF ((((internal->forms[searchcnt].cv_case_exists=0)) OR (override_case=1)) )
    SET seek = 1
    SET previous_cnt = 0
    SET present_cnt = 1
    IF (child_cnt > 0)
     WHILE (seek=1)
       SELECT
        IF (child_cnt=1)
         PLAN (ce
          WHERE (ce.parent_event_id=internal->forms[searchcnt].children[1].event_id)
           AND ce.event_id != ce.parent_event_id
           AND ce.valid_until_dt_tm=cnvtdatetime(valid_date)
           AND ce.result_status_cd != inerror_cd)
        ELSE
        ENDIF
        INTO "NL:"
        FROM clinical_event ce
        PLAN (ce
         WHERE expand(idx,(previous_cnt+ 1),child_cnt,ce.parent_event_id,internal->forms[searchcnt].
          children[idx].event_id)
          AND ce.event_id != ce.parent_event_id
          AND ce.valid_until_dt_tm=cnvtdatetime(valid_date)
          AND ce.result_status_cd != inerror_cd)
        DETAIL
         stat = alterlist(internal->forms[searchcnt].children,(size(internal->forms[searchcnt].
           children,5)+ 1)), child_cnt = size(internal->forms[searchcnt].children,5), internal->
         forms[searchcnt].children[child_cnt].event_id = ce.event_id,
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
    ENDIF
    SET register->top_parent_event_id = internal->forms[searchcnt].parent_entity_id
    IF (size(lookup->qual,5) > 0)
     CALL echo("Translating DTAs")
     CALL do_lookup_dta_translation(searchcnt)
    ENDIF
    SET synch_failed = "F"
    SELECT INTO "nl:"
     FROM cv_xref ref,
      (dummyt d  WITH seq = value(child_cnt))
     PLAN (d
      WHERE (internal->forms[searchcnt].children[d.seq].event_cd > 0.0))
      JOIN (ref
      WHERE (ref.dataset_id=internal->forms[searchcnt].dataset_id)
       AND (ref.event_cd=internal->forms[searchcnt].children[d.seq].event_cd)
       AND (ref.task_assay_cd=internal->forms[searchcnt].children[d.seq].task_assay_cd))
     ORDER BY ref.event_cd, ref.dataset_id DESC
     HEAD REPORT
      CALL echo("Hit head report"), cnt = 0, ecnt = 0,
      pcnt = 0, register->form_type_cd = internal->forms[searchcnt].form_type_cd,
      CALL echo(build("form_type_cd set to:",register->form_type_cd)),
      register->calling_script_flag = 1, register->top_parent_event_id = internal->forms[searchcnt].
      parent_entity_id
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(register->rec,cnt), register->rec[cnt].person_id = internal->
      forms[searchcnt].person_id,
      register->rec[cnt].encntr_id = internal->forms[searchcnt].encntr_id, register->rec[cnt].
      event_id = internal->forms[searchcnt].children[d.seq].event_id, register->rec[cnt].event_cd =
      internal->forms[searchcnt].children[d.seq].event_cd,
      register->rec[cnt].result_val = internal->forms[searchcnt].children[d.seq].result_val, register
      ->rec[cnt].parent_event_id = internal->forms[searchcnt].children[d.seq].parent_event_id,
      register->rec[cnt].result_status_cd = internal->forms[searchcnt].children[d.seq].
      result_status_cd,
      register->rec[cnt].xref_id = ref.xref_id, register->rec[cnt].result_status_change_ind = 1,
      register->rec[cnt].clinical_event_id = internal->forms[searchcnt].children[d.seq].
      clinical_event_id
      IF ((register->rec[cnt].result_status_cd=inerror_cd))
       ecnt = (ecnt+ 1)
      ENDIF
      IF ((register->rec[cnt].result_status_cd=inprogress_cd))
       pcnt = (pcnt+ 1)
      ENDIF
     FOOT REPORT
      IF (pcnt=cnt
       AND pcnt > 0)
       case_inprogress = "T"
      ELSE
       case_inprogress = "F"
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET case_uncharted = "T"
    ELSE
     SET case_uncharted = "F"
    ENDIF
    CALL cv_log_message(build("*** Case_InProgress =",case_inprogress,"***"))
    CALL cv_log_message(build("*** Case_UnCharted =",case_uncharted,"***"))
    IF (((case_inprogress="F") OR ((register->form_type_cd > 0.0))) )
     IF ((register->form_type_cd > 0.0)
      AND case_inprogress != "F")
      CALL cv_log_message("Processing unsigned form")
     ENDIF
     IF (case_uncharted="T")
      SET unchart_case_id = 0.0
      SELECT INTO "nl:"
       FROM cv_case c
       PLAN (c
        WHERE (c.form_event_id=register->top_parent_event_id))
       DETAIL
        unchart_case_id = c.cv_case_id
       WITH nocounter
      ;end select
      IF (unchart_case_id > 0.0)
       EXECUTE cv_utl_del_summary_data unchart_case_id
       CALL cv_log_message(concat("Uncharting case_id :",cnvtstring(unchart_case_id)))
       COMMIT
       SET synch_failed = "F"
      ENDIF
      CALL echo("DEBUG HERE")
      CALL echo(register->form_type_cd)
      CALL echo(validate(exit_after,"0"))
      IF ((internal->forms[searchcnt].form_type_cd > 0.0)
       AND validate(exit_after,"0") != "CV_INSERT_SUMMARY_DATA")
       EXECUTE cv_get_harvest_person internal->forms[searchcnt].person_id, internal->forms[searchcnt]
       .dataset_id
       COMMIT
      ENDIF
     ELSE
      SET g_dataset_id = internal->forms[searchcnt].dataset_id
      CALL cv_log_message(build("g_Dataset_id:",g_dataset_id))
      EXECUTE cv_log_struct  WITH replace(request,register)
      EXECUTE cv_log_struct  WITH replace(request,internal)
      EXECUTE cv_get_summary_data
      COMMIT
      SET synch_failed = "F"
     ENDIF
    ENDIF
   ENDIF
   CALL cv_log_message(build("***",searchcnt,"*** of ",numbers_of_forms," Imported."))
 ENDFOR
 SUBROUTINE add_valves_to_lookup(null)
   SET v_loca_tot = 12
   SET v_type_tot = 6
   SET v_type_max = 5
   FREE RECORD valves
   RECORD valves(
     1 location[v_loca_tot]
       2 meaning = c12
       2 implant_dta = f8
       2 implant_ec = f8
     1 types[v_type_tot]
       2 letter = vc
   )
   SET valves->location[1].meaning = "ST01VSAOIM"
   SET valves->location[2].meaning = "ST01VSAOEX"
   SET valves->location[3].meaning = "ST01VSMIIM"
   SET valves->location[4].meaning = "ST01VSMIEX"
   SET valves->location[5].meaning = "ST01VSTRIM"
   SET valves->location[6].meaning = "ST01VSTREX"
   SET valves->location[7].meaning = "ST01VSPUIM"
   SET valves->location[8].meaning = "ST01VSPUEX"
   SET valves->location[9].meaning = "ST03VSAOIM"
   SET valves->location[10].meaning = "ST03VSMIIM"
   SET valves->location[11].meaning = "ST03VSTRIM"
   SET valves->location[12].meaning = "ST03VSPUIM"
   SET valves->types[1].letter = "M"
   SET valves->types[2].letter = "B"
   SET valves->types[3].letter = "H"
   SET valves->types[4].letter = "A"
   SET valves->types[5].letter = "R"
   SET valves->types[6].letter = "BA"
   SELECT INTO "NL:"
    FROM discrete_task_assay dta,
     code_value cv
    PLAN (cv
     WHERE cv.code_set=14003
      AND cv.active_ind=1
      AND expand(idx,1,size(valves->location,5),cv.cdf_meaning,valves->location[idx].meaning))
     JOIN (dta
     WHERE dta.task_assay_cd=cv.code_value)
    DETAIL
     index = locateval(num1,1,size(valves->location,5),cv.cdf_meaning,valves->location[num1].meaning),
     valves->location[index].implant_dta = dta.task_assay_cd, valves->location[index].implant_ec =
     dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("No STS valves found for DTA Mapper")
    RETURN
   ENDIF
   SET initial_lookup_cnt = size(lookup->qual,5)
   SET lookup_cnt = initial_lookup_cnt
   SET stat = alterlist(lookup->qual,(initial_lookup_cnt+ (v_loca_tot * v_type_tot)))
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv,
     (dummyt d1  WITH seq = v_loca_tot),
     (dummyt d2  WITH seq = v_type_tot)
    PLAN (d1
     WHERE (valves->location[d1.seq].implant_dta > 0.0))
     JOIN (d2
     WHERE ((d1.seq >= 9) OR (d2.seq < v_loca_tot)) )
     JOIN (cv
     WHERE cv.code_set=14003
      AND cv.cdf_meaning=concat(valves->location[d1.seq].meaning,valves->types[d2.seq].letter)
      AND cv.active_ind=1)
    DETAIL
     lookup_cnt = (lookup_cnt+ 1), lookup->qual[lookup_cnt].org_dta = cv.code_value, lookup->qual[
     lookup_cnt].new_dta = valves->location[d1.seq].implant_dta,
     lookup->qual[lookup_cnt].new_ec = valves->location[d1.seq].implant_ec
    WITH nocounter
   ;end select
   SET stat = alterlist(lookup->qual,lookup_cnt)
   CALL echo(concat("Size of translation table = ",cnvtstring(size(lookup->qual,5))))
 END ;Subroutine
 SUBROUTINE do_lookup_dta_translation(searchcnt)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(internal->forms[searchcnt].children,5))),
     (dummyt d2  WITH seq = value(size(lookup->qual,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (internal->forms[searchcnt].children[d1.seq].task_assay_cd=lookup->qual[d2.seq].org_dta))
    DETAIL
     CALL echo(concat("Changing event_cd ",cnvtstring(internal->forms[searchcnt].children[d1.seq].
       event_cd),"to",cnvtstring(lookup->qual[d2.seq].new_ec))), internal->forms[searchcnt].children[
     d1.seq].event_cd = lookup->qual[d2.seq].new_ec, internal->forms[searchcnt].children[d1.seq].
     task_assay_cd = lookup->qual[d2.seq].new_dta
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (synch_failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
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
 SET synch_error = error(synch_error_msg,1)
 DECLARE cv_utl_synch_dataset_vrsn = vc WITH private, constant("MOD 023 08/15/06 BM9013")
END GO
