CREATE PROGRAM cv_summary_data_handle_routine:dba
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
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE admit_dt_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE disch_dt_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE datefmt = vc WITH protect, noconstant("DD-MMM-YYYY HH:MM:SS.CC;;D")
 DECLARE timefmt = vc WITH protect, noconstant("HHMM;;d")
 DECLARE datefmt2 = vc WITH protect, noconstant("MM/DD/YYYY;;d")
 DECLARE cv_date = vc WITH protect, noconstant("DATE")
 DECLARE age_meaning = vc WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE ftc = f8 WITH protect
 DECLARE tac = f8 WITH protect
 DECLARE rsc = f8 WITH protect
 DECLARE dtidx = i2 WITH protect
 DECLARE date_str = vc WITH protect
 DECLARE case_abstr_cnt = i4 WITH protect
 DECLARE result_status_cd = f8 WITH protect
 DECLARE task_assay_cd = f8 WITH protect
 DECLARE field_type_cd = f8 WITH protect
 DECLARE auth_status_cd = f8 WITH protect
 DECLARE proc_cnt = i4 WITH protect
 DECLARE proc_abstr_cnt = i4 WITH protect
 DECLARE lesion_abstr_cnt = i4 WITH protect
 DECLARE field_tcd = f8 WITH protect
 DECLARE device_abstr_cnt = i4 WITH protect
 DECLARE task_ac = f8 WITH protect
 DECLARE result_sc = f8 WITH protect
 DECLARE closdev_cnt = i4 WITH protect
 DECLARE cd_abstr_cnt = i4 WITH protect
 DECLARE bar_cnt = i4 WITH protect
 DECLARE bar_cnt2 = i4 WITH protect
 DECLARE sub_str1 = vc WITH protect
 DECLARE sub_str2 = vc WITH protect
 DECLARE case_dt_ec = f8
 DECLARE admission_dt_tm_formatted = vc WITH protect
 DECLARE discharge_dt_tm_formatted = vc WITH protect
 DECLARE admission_time_string = vc WITH protect
 DECLARE discharge_time_string = vc WITH protect
 DECLARE proc_start_dt_tm_formatted = vc WITH protect
 DECLARE proc_start_time_string = vc WITH protect
 DECLARE deceased_dt_tm_formatted = vc WITH protect
 DECLARE deceased_time_string = vc WITH protect
 DECLARE age = i4 WITH protect
 DECLARE dfac_cs = i4 WITH protect, constant(18189)
 DECLARE dfac_cd = f8 WITH protect
 IF (validate(reply->status_data.status) != 1)
  CALL echo("No status block in the reply.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET admit_dt_ec = cv_get_code_by_dataset(cv_omf_rec->dataset[1].dataset_id,"ADMITDT")
 SET disch_dt_ec = cv_get_code_by_dataset(cv_omf_rec->dataset[1].dataset_id,"DISCHDT")
 CALL cv_log_message(build("admit_dt_ec=",admit_dt_ec))
 CALL cv_log_message(build("disch_dt_ec=",disch_dt_ec))
 IF ((cv_omf_rec->called_by_import=0))
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
   CALL cv_log_message("Unable to find code value for meaning CLINCALEVENT in code set 18189")
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to find code value for meaning CLINCALEVENT in code set 18189"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   dfa.dcp_forms_activity_id, dfa.beg_activity_dt_tm, dfap.dcp_forms_activity_prsnl_id
   FROM dcp_forms_activity dfa,
    dcp_forms_activity_prsnl dfap,
    dcp_forms_activity_comp dfac
   PLAN (dfac
    WHERE (dfac.parent_entity_id=cv_omf_rec->top_parent_event_id)
     AND dfac.parent_entity_id != 0.0
     AND dfac.dcp_forms_activity_id != 0.0
     AND dfac.component_cd=dfac_cd
     AND dfac.parent_entity_name="CLINICAL_EVENT")
    JOIN (dfa
    WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id)
    JOIN (dfap
    WHERE dfap.dcp_forms_activity_id=dfa.dcp_forms_activity_id)
   ORDER BY dfap.dcp_forms_activity_prsnl_id
   DETAIL
    cv_omf_rec->form_id = dfa.dcp_forms_activity_id, cv_omf_rec->chart_dt_tm = dfa.beg_activity_dt_tm,
    cv_omf_rec->updt_id = dfap.prsnl_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message(concat("Failed in select the dcp_forms_activity and ",
     "dcp_forms_activity_comp table, ","program continue!"))
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  e.encntr_type_class_cd, e.loc_facility_cd
  FROM encounter e
  WHERE (e.encntr_id=cv_omf_rec->encntr_id)
   AND e.active_ind=1
  DETAIL
   cv_omf_rec->patient_type_cd = e.encntr_type_class_cd, cv_omf_rec->hospital_cd = e.loc_facility_cd,
   cv_omf_rec->organization_id = e.organization_id,
   cv_omf_rec->dataset[1].organization_id = e.organization_id
   IF (admit_dt_ec <= 0.0)
    cv_omf_rec->admit_dt_tm = e.reg_dt_tm
   ENDIF
   IF (disch_dt_ec <= 0.0)
    cv_omf_rec->disch_dt_tm = e.disch_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Select from encounter failed, program continue!")
 ENDIF
 SET case_abstr_cnt = size(cv_omf_rec->case_abstr_data,5)
 IF (case_abstr_cnt > 0)
  FOR (n = 1 TO case_abstr_cnt)
    SET cv_omf_rec->case_abstr_data[n].case_id = cv_omf_rec->case_id
    SET field_type_cd = cv_omf_rec->case_abstr_data[n].field_type_cd
    SET task_assay_cd = cv_omf_rec->case_abstr_data[n].task_assay_cd
    SET cv_omf_rec->case_abstr_data[n].field_type_meaning = uar_get_code_meaning(field_type_cd)
    SET cv_omf_rec->case_abstr_data[n].task_assay_meaning = uar_get_code_meaning(task_assay_cd)
    SET result_status_cd = cv_omf_rec->case_abstr_data[n].result_status_cd
  ENDFOR
 ENDIF
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_status_cd)
 IF (auth_status_cd <= 0.0)
  CALL echo("There is no cdf_meaning - AUTH under code_set 8 in the database")
 ENDIF
 SELECT INTO "nl:"
  pr.person_id
  FROM prsnl pr,
   (dummyt d1  WITH seq = value(size(cv_omf_rec->case_abstr_data,5))),
   (dummyt d2  WITH seq = value(size(cv_omf_rec->dataset,5)))
  PLAN (d1
   WHERE trim(cv_omf_rec->case_abstr_data[d1.seq].task_assay_meaning) IN ("ST01REFCARD",
   "ST01REFPHYS", "ST01SURGEON", "ST03REFCARD", "ST03REFPHYS",
   "ST03SURGEON"))
   JOIN (d2)
   JOIN (pr
   WHERE trim(pr.name_full_formatted)=trim(cv_omf_rec->case_abstr_data[d1.seq].result_val)
    AND pr.physician_ind=1
    AND pr.active_ind=1
    AND pr.data_status_cd=auth_status_cd)
  DETAIL
   cv_omf_rec->case_abstr_data[d1.seq].result_id = pr.person_id
   IF (((trim(cv_omf_rec->case_abstr_data[d1.seq].task_assay_meaning)="ST01SURGEON") OR (trim(
    cv_omf_rec->case_abstr_data[d1.seq].task_assay_meaning)="ST03SURGEON")) )
    cv_omf_rec->dataset[d2.seq].participant_prsnl_id = pr.person_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Select from prsnl for sts personal failed program continue!")
 ENDIF
 SELECT INTO "nl:"
  pg.person_id
  FROM prsnl_group pg,
   (dummyt d1  WITH seq = value(size(cv_omf_rec->case_abstr_data,5))),
   (dummyt d2  WITH seq = value(size(cv_omf_rec->dataset,5)))
  PLAN (d1
   WHERE trim(cv_omf_rec->case_abstr_data[d1.seq].task_assay_meaning)="ST01SURGGRP")
   JOIN (d2)
   JOIN (pg
   WHERE pg.prsnl_group_name_key=cnvtupper(trim(cv_omf_rec->case_abstr_data[d1.seq].result_val)))
  DETAIL
   cv_omf_rec->case_abstr_data[d1.seq].result_id = pg.prsnl_group_id, cv_omf_rec->dataset[d2.seq].
   participant_prsnl_group_id = pg.prsnl_group_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message(
   "select from prsnl_group table for sts personal group failed, program continue!")
 ENDIF
 SET proc_cnt = size(cv_omf_rec->proc_data,5)
 IF (proc_cnt > 0)
  FOR (proc_nbr = 1 TO proc_cnt)
    SET cv_omf_rec->proc_data[proc_nbr].case_id = cv_omf_rec->case_id
    SET proc_abstr_cnt = 0
    SET proc_abstr_cnt = size(cv_omf_rec->proc_data[proc_nbr].proc_abstr_data,5)
    IF (proc_abstr_cnt > 0)
     FOR (proc_abstr_nbr = 1 TO proc_abstr_cnt)
       SET cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].procedure_id = cv_omf_rec
       ->proc_data[proc_nbr].procedure_id
       SET ftc = cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].field_type_cd
       SET tac = cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].task_assay_cd
       SET rsc = cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_status_cd
       SET cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].field_type_meaning =
       uar_get_code_meaning(ftc)
       SET cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].task_assay_meaning =
       uar_get_code_meaning(tac)
       SET cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_status_meaning =
       uar_get_code_meaning(rsc)
     ENDFOR
     SELECT INTO "nl:"
      pr.person_id
      FROM prsnl pr,
       (dummyt d1  WITH seq = value(proc_abstr_cnt))
      PLAN (d1
       WHERE cnvtupper(trim(cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[d1.seq].
         task_assay_meaning)) IN ("ACC033CNAME", "ACC066PNAME", "AC02CNAME", "AC02PNAME", "AC03DCPHY",
       "AC03PCIPHY"))
       JOIN (pr
       WHERE cnvtupper(trim(pr.name_full_formatted))=cnvtupper(trim(cv_omf_rec->proc_data[proc_nbr].
         proc_abstr_data[d1.seq].result_val))
        AND pr.physician_ind=1
        AND pr.active_ind=1
        AND pr.data_status_cd=auth_status_cd)
      DETAIL
       cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[d1.seq].result_id = pr.person_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL cv_log_message("Failed in select prsnl for person_id, program continue!")
     ENDIF
    ENDIF
    IF (size(cv_omf_rec->proc_data[proc_nbr].lesion,5) > 0)
     FOR (lesion_nbr = 1 TO size(cv_omf_rec->proc_data[proc_nbr].lesion,5))
       SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].procedure_id = cv_omf_rec->proc_data[
       proc_nbr].procedure_id
       SET lesion_abstr_cnt = 0
       SET lesion_abstr_cnt = size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data,
        5)
       IF (size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice,5) > 0)
        FOR (device_nbr = 1 TO size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice,5))
          SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].procedure_id =
          cv_omf_rec->proc_data[proc_nbr].procedure_id
          SET device_abstr_cnt = 0
          SET device_abstr_cnt = size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[
           device_nbr].icd_abstr_data,5)
          IF (device_abstr_cnt > 0)
           FOR (device_abstr_nbr = 1 TO device_abstr_cnt)
             SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].device_id = cv_omf_rec->proc_data[proc_nbr].lesion[
             lesion_nbr].icdevice[device_nbr].device_id
             SET field_tcd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].field_type_cd
             SET task_ac = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].task_assay_cd
             SET result_sc = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].result_status_cd
             SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].field_type_meaning = uar_get_code_meaning(field_tcd)
             SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].task_assay_meaning = uar_get_code_meaning(task_ac)
             SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].
             icd_abstr_data[device_abstr_nbr].result_status_meaning = uar_get_code_meaning(result_sc)
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
       IF (lesion_abstr_cnt > 0)
        FOR (lesion_abstr_nbr = 1 TO lesion_abstr_cnt)
          SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr].
          lesion_id = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].lesion_id
          SET field_tcd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
          lesion_abstr_nbr].field_type_cd
          SET task_ac = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
          lesion_abstr_nbr].task_assay_cd
          SET result_sc = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
          lesion_abstr_nbr].result_status_cd
          SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr].
          field_type_meaning = uar_get_code_meaning(field_tcd)
          SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr].
          task_assay_meaning = uar_get_code_meaning(task_ac)
          SET cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr].
          result_status_meaning = uar_get_code_meaning(result_sc)
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET closdev_cnt = size(cv_omf_rec->closuredevice,5)
 IF (closdev_cnt > 0)
  FOR (closdev_nbr = 1 TO closdev_cnt)
    SET cv_omf_rec->closuredevice[closdev_nbr].case_id = cv_omf_rec->case_id
    SET cd_abstr_cnt = 0
    SET cd_abstr_cnt = size(cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data,5)
    IF (cd_abstr_cnt > 0)
     FOR (cd_abstr_nbr = 1 TO cd_abstr_cnt)
       SET cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].device_id = cv_omf_rec
       ->closuredevice[closdev_nbr].device_id
       SET ftc = cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].field_type_cd
       SET tac = cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].task_assay_cd
       SET rsc = cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].result_status_cd
       SET cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].field_type_meaning =
       uar_get_code_meaning(ftc)
       SET cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].task_assay_meaning =
       uar_get_code_meaning(tac)
       SET cv_omf_rec->closuredevice[closdev_nbr].cd_abstr_data[cd_abstr_nbr].result_status_meaning
        = uar_get_code_meaning(rsc)
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 CALL echo(build("called_by_import: ",cv_omf_rec->called_by_import))
 IF ((cv_omf_rec->called_by_import=0))
  SELECT INTO "nl:"
   cdr.result_dt_tm
   FROM ce_date_result cdr,
    (dummyt d  WITH seq = value(size(cv_omf_rec->case_abstr_data,5)))
   PLAN (d
    WHERE trim(cv_omf_rec->case_abstr_data[d.seq].field_type_meaning)=cv_date)
    JOIN (cdr
    WHERE (cdr.event_id=cv_omf_rec->case_abstr_data[d.seq].event_id))
   HEAD REPORT
    proc_date_cd = 0.0
   DETAIL
    cv_omf_rec->case_abstr_data[d.seq].result_dt_tm = cdr.result_dt_tm, cv_omf_rec->case_abstr_data[d
    .seq].result_val = format(cdr.result_dt_tm,"MM/DD/YYYY;;d"), proc_date_cd = cv_omf_rec->
    case_abstr_data[d.seq].task_assay_cd
    IF (uar_get_code_meaning(proc_date_cd) IN ("AC02VDOP", "ST01SURGDT"))
     cv_omf_rec->proc_start_dt_tm = cdr.result_dt_tm, cv_omf_rec->proc_dt_num = cnvtdate(cdr
      .result_dt_tm)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message(
    "Failed in select ce_date_result for date in case abstr level, program continue!")
  ENDIF
  IF (proc_cnt > 0
   AND (cv_omf_rec->max_proc_abstr > 0))
   SELECT INTO "nl:"
    cdr.result_dt_tm
    FROM ce_date_result cdr,
     (dummyt d1  WITH seq = value(proc_cnt)),
     (dummyt d2  WITH seq = value(cv_omf_rec->max_proc_abstr))
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].proc_abstr_data,5)
      AND trim(cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].field_type_meaning)=cv_date)
     JOIN (cdr
     WHERE (cdr.event_id=cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].event_id))
    DETAIL
     cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_dt_tm = cdr.result_dt_tm,
     cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_val = format(cdr.result_dt_tm,
      "MM/DD/YYYY;;d")
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message(
     "Failed in select ce_date_result for date in proc_abstr_data level, program continue!")
   ENDIF
  ENDIF
  IF (proc_cnt > 0
   AND (cv_omf_rec->max_lesion > 0)
   AND (cv_omf_rec->max_lesion_abstr > 0))
   SELECT INTO "nl:"
    cdr.result_dt_tm
    FROM ce_date_result cdr,
     (dummyt d1  WITH seq = value(proc_cnt)),
     (dummyt d2  WITH seq = value(cv_omf_rec->max_lesion)),
     (dummyt d3  WITH seq = value(cv_omf_rec->max_lesion_abstr))
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion,5))
     JOIN (d3
     WHERE d3.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5)
      AND trim(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].field_type_meaning
      )=cv_date)
     JOIN (cdr
     WHERE (cdr.event_id=cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_id
     ))
    DETAIL
     cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].result_dt_tm = cdr
     .result_dt_tm, cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].result_val =
     format(cdr.result_dt_tm,datefmt2)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message(
     "Failed in select ce_date_result for date in lesion_abstr level, program continue")
   ENDIF
  ENDIF
 ELSE
  FOR (dtidx = 1 TO size(cv_omf_rec->case_abstr_data,5))
    IF (uar_get_code_meaning(cv_omf_rec->case_abstr_data[dtidx].task_assay_cd) IN ("AC02VDOP",
    "ST01SURGDT"))
     SET date_str = trim(cv_omf_rec->case_abstr_data[dtidx].result_val)
     CALL echo(build("date_str_bf: ",date_str))
     SET bar_cnt = findstring("/",date_str)
     IF (bar_cnt=2)
      SET date_str = trim(build("0",date_str))
      CALL echo(build("date_str_bar: ",date_str))
     ENDIF
     SET bar_cnt2 = findstring("/",date_str,4)
     IF (bar_cnt2=5)
      SET sub_str1 = substring(1,3,date_str)
      CALL echo(build("sub_str1: ",sub_str1))
      SET sub_str2 = substring(4,6,date_str)
      CALL echo(build("sub_str2: ",sub_str2))
      SET date_str = build(sub_str1,"0",sub_str2)
     ENDIF
     SET date_str = cnvtalphanum(date_str)
     CALL echo(build("date_str_af: ",date_str))
     SET cv_omf_rec->proc_start_dt_tm = cnvtdatetime(cnvtdate(date_str),0)
     SET cv_omf_rec->case_abstr_data[dtidx].result_dt_tm = cnvtdatetime(cnvtdate(date_str),0)
     SET cv_omf_rec->proc_dt_num = cnvtdate(cv_omf_rec->proc_start_dt_tm)
     CALL echo(build("proc_dt_num: ",cv_omf_rec->proc_dt_num))
    ENDIF
  ENDFOR
 ENDIF
 SET case_dt_ec = cv_get_case_date_ec(cv_omf_rec->dataset[1].dataset_id)
 IF (((admit_dt_ec > 0.0) OR (((disch_dt_ec > 0.0) OR (case_dt_ec > 0.0)) ))
  AND case_abstr_cnt > 0)
  FOR (n = 1 TO case_abstr_cnt)
    IF ((cv_omf_rec->case_abstr_data[n].event_cd > 0.0))
     CASE (cv_omf_rec->case_abstr_data[n].event_cd)
      OF admit_dt_ec:
       SET cv_omf_rec->admit_dt_tm = cv_omf_rec->case_abstr_data[n].result_dt_tm
      OF disch_dt_ec:
       SET cv_omf_rec->disch_dt_tm = cv_omf_rec->case_abstr_data[n].result_dt_tm
      OF case_dt_ec:
       SET cv_omf_rec->case_dt_tm = cv_omf_rec->case_abstr_data[n].result_dt_tm
     ENDCASE
    ENDIF
  ENDFOR
 ENDIF
 IF ((cv_omf_rec->form_type_mean="ADMIT"))
  SET cv_omf_rec->case_dt_tm = cnvtdatetime(cnvtdate(cv_omf_rec->admit_dt_tm),0)
 ENDIF
 SET cv_omf_rec->admt_dt_num = cnvtdate(cv_omf_rec->admit_dt_tm)
 SET cv_omf_rec->disch_dt_num = cnvtdate(cv_omf_rec->disch_dt_tm)
 SET admission_dt_tm_formatted = format(cv_omf_rec->admit_dt_tm,datefmt)
 SET discharge_dt_tm_formatted = format(cv_omf_rec->disch_dt_tm,datefmt)
 SET admission_time_string = format(cv_omf_rec->admit_dt_tm,timefmt)
 SET discharge_time_string = format(cv_omf_rec->disch_dt_tm,timefmt)
 SET proc_start_dt_tm_formatted = format(cv_omf_rec->proc_start_dt_tm,datefmt)
 SET proc_start_time_string = format(cv_omf_rec->proc_start_dt_tm,timefmt)
 IF (size(trim(admission_time_string)) > 0)
  SET cv_omf_rec->admit_ind = 1
 ELSE
  SET cv_omf_rec->admit_ind = 0
 ENDIF
 IF (size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->disch_ind = 1
 ELSE
  SET cv_omf_rec->disch_ind = 0
 ENDIF
 IF (size(trim(admission_time_string)) > 0
  AND size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->los_adm_disch = datetimecmp(cv_omf_rec->disch_dt_tm,cv_omf_rec->admit_dt_tm)
  IF ((cv_omf_rec->los_adm_disch < 0))
   SET cv_omf_rec->los_adm_disch = 0
  ENDIF
 ENDIF
 IF (size(trim(admission_time_string)) > 0
  AND size(trim(proc_start_time_string)) > 0)
  SET cv_omf_rec->los_adm_proc = datetimecmp(cv_omf_rec->proc_start_dt_tm,cv_omf_rec->admit_dt_tm)
  IF ((cv_omf_rec->los_adm_proc < 0))
   SET cv_omf_rec->los_adm_proc = 0
  ENDIF
 ENDIF
 IF (size(trim(discharge_time_string)) > 0
  AND size(trim(proc_start_time_string)) > 0)
  SET cv_omf_rec->los_proc_disch = datetimecmp(cv_omf_rec->disch_dt_tm,cv_omf_rec->proc_start_dt_tm)
  IF ((cv_omf_rec->los_proc_disch < 0))
   SET cv_omf_rec->los_proc_disch = 0
  ENDIF
 ENDIF
 SET age = 0
 SELECT INTO "nl:"
  p.sex_cd, bnullbirth = nullind(p.birth_dt_tm), p.birth_dt_tm
  FROM person p
  WHERE (p.person_id=cv_omf_rec->person_id)
   AND p.active_ind=1
  DETAIL
   deceased_dt_tm_formatted = format(p.deceased_dt_tm,datefmt), deceased_time_string = format(p
    .deceased_dt_tm,timefmt), cv_omf_rec->sex_cd = p.sex_cd,
   CALL echo(build("bNullBirth:",bnullbirth)),
   CALL echo(build("cv_omf_rec->case_dt_tm:",cv_omf_rec->case_dt_tm))
   IF (bnullbirth=0
    AND datetimecmp(cnvtdatetime(cv_omf_rec->case_dt_tm),p.birth_dt_tm) >= 0)
    age_string = cnvtupper(cnvtage(p.birth_dt_tm,cv_omf_rec->case_dt_tm,0)), ipos = findstring(
     "YEARS",age_string)
    IF (ipos=0)
     cv_omf_rec->age_year = 0
    ELSE
     cv_omf_rec->age_year = cnvtint(trim(substring(1,(ipos - 1),age_string),3))
    ENDIF
   ELSE
    cv_omf_rec->age_year = - (1)
   ENDIF
   IF ((cv_omf_rec->death_ind=0))
    IF (size(trim(deceased_time_string)) > 0)
     cv_omf_rec->death_ind = 1
    ELSE
     cv_omf_rec->death_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in select the person table")
 ENDIF
 IF ((cv_omf_rec->death_ind=0))
  SELECT INTO "nl:"
   FROM nomenclature n,
    (dummyt d  WITH seq = value(size(cv_omf_rec->case_abstr_data,5)))
   PLAN (d
    WHERE trim(cv_omf_rec->case_abstr_data[d.seq].task_assay_meaning)="ACC141DDETH")
    JOIN (n
    WHERE (n.nomenclature_id=cv_omf_rec->case_abstr_data[d.seq].nomenclature_id)
     AND cnvtupper(n.mnemonic)="YES")
   DETAIL
    cv_omf_rec->death_ind = 1, cv_omf_rec->disch_ind = 1
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message(concat("Failed in select nomenclature for ","death_ind, program continue!"))
  ENDIF
 ENDIF
 IF (age >= 0)
  IF (age < 2)
   SET age_meaning = "<2YEAR"
  ELSEIF (age < 19)
   SET age_meaning = "2-18"
  ELSEIF (age < 45)
   SET age_meaning = "19-44"
  ELSEIF (age < 55)
   SET age_meaning = "45-54"
  ELSEIF (age < 65)
   SET age_meaning = "55-64"
  ELSEIF (age < 75)
   SET age_meaning = "65-74"
  ELSEIF (age < 85)
   SET age_meaning = "75-84"
  ELSE
   SET age_meaning = "85+"
  ENDIF
  SET cv_omf_rec->age_group_cd = uar_get_code_by("MEANING",22329,nullterm(age_meaning))
 ELSE
  SET cv_omf_rec->age_group_cd = 0.0
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
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
 DECLARE cv_summary_data_handle_routine_vrsn = vc WITH private, constant("MOD 015 08/15/06 BM9013")
END GO
