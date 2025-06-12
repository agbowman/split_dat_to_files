CREATE PROGRAM cv_utl_chg_part_nbr:dba
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
 IF ( NOT (validate(cv_omf_rec,0)))
  RECORD cv_omf_rec(
    1 max_lesion = i4
    1 max_lesion_abstr = i4
    1 max_proc_abstr = i4
    1 max_icdev = i4
    1 max_icdev_abstr = i4
    1 max_closdev = i4
    1 max_closdev_abstr = i4
    1 called_by_import = i2
    1 dataset[*]
      2 dataset_id = f8
      2 alias_pool_cd = f8
      2 alias_pool_mean = vc
      2 participant_nbr = vc
      2 organization_id = f8
      2 participant_prsnl_id = f8
      2 participant_prsnl_group_id = f8
      2 status_ind = i2
      2 case_dataset_r_id = f8
    1 admit_dt_tm = dq8
    1 admit_ind = i2
    1 age_group_cd = f8
    1 age_year = i4
    1 case_id = f8
    1 cv_case_nbr = f8
    1 form_event_id = f8
    1 death_ind = i2
    1 disch_dt_tm = dq8
    1 disch_ind = i2
    1 encntr_id = f8
    1 hospital_cd = f8
    1 los_adm_disch = i4
    1 los_adm_proc = i4
    1 los_proc_disch = i4
    1 admt_dt_num = i4
    1 disch_dt_num = i4
    1 proc_dt_num = i4
    1 proc_start_dt_tm = dq8
    1 num_proc = i4
    1 patient_type_cd = f8
    1 person_id = f8
    1 sex_cd = f8
    1 source_cd = f8
    1 organization_id = f8
    1 status_ind = i2
    1 updt_cnt = i2
    1 updt_id = f8
    1 top_parent_event_id = f8
    1 form_id = f8
    1 chart_dt_tm = dq8
    1 reference_nbr = c50
    1 case_abstr_data[*]
      2 case_abstr_id = f8
      2 case_id = f8
      2 event_cd = f8
      2 event_id = f8
      2 event_type_cd = f8
      2 field_type_cd = f8
      2 field_type_meaning = c12
      2 nomenclature_id = f8
      2 result_dt_tm = dq8
      2 result_id = f8
      2 result_status_cd = f8
      2 result_status_meaning = c12
      2 updt_cnt = i2
      2 result_val = vc
      2 task_assay_cd = f8
      2 task_assay_meaning = c12
      2 ins_upd_ind = i2
    1 proc_data[*]
      2 procedure_id = f8
      2 case_id = f8
      2 event_type_cd = f8
      2 proc_physician_id = f8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
      2 proc_dur_min = i4
      2 proc_start_month = i4
      2 proc_start_day = i4
      2 proc_start_hour = i4
      2 proc_complete_ind = i2
      2 los_adm_proc = i4
      2 los_proc_disch = i4
      2 num_lesion = i4
      2 status_ind = i2
      2 updt_cnt = i2
      2 proc_abstr_data[*]
        3 procedure_id = f8
        3 event_cd = f8
        3 event_id = f8
        3 event_type_cd = f8
        3 field_type_cd = f8
        3 field_type_meaning = c12
        3 nomenclature_id = f8
        3 proc_abstr_id = f8
        3 result_dt_tm = dq8
        3 result_id = f8
        3 result_status_cd = f8
        3 result_status_meaning = c12
        3 updt_cnt = i2
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
        3 ins_upd_ind = i2
      2 lesion[*]
        3 lesion_id = f8
        3 procedure_id = f8
        3 parent_event_id = f8
        3 status_ind = i2
        3 updt_cnt = i2
        3 les_abstr_data[*]
          4 event_cd = f8
          4 event_id = f8
          4 event_type_cd = f8
          4 field_type_cd = f8
          4 field_type_meaning = c12
          4 lesion_abstr_id = f8
          4 lesion_id = f8
          4 nomenclature_id = f8
          4 result_dt_tm = dq8
          4 result_id = f8
          4 result_status_cd = f8
          4 result_status_meaning = c12
          4 updt_cnt = i2
          4 result_val = vc
          4 task_assay_cd = f8
          4 task_assay_meaning = c12
          4 ins_upd_ind = i2
        3 icdevice[*]
          4 device_id = f8
          4 procedure_id = f8
          4 parent_event_id = f8
          4 status_ind = i2
          4 updt_cnt = i2
          4 icd_abstr_data[*]
            5 event_cd = f8
            5 event_id = f8
            5 event_type_cd = f8
            5 field_type_cd = f8
            5 field_type_meaning = c12
            5 device_abstr_id = f8
            5 device_id = f8
            5 nomenclature_id = f8
            5 result_dt_tm = dq8
            5 result_id = f8
            5 result_status_cd = f8
            5 result_status_meaning = c12
            5 updt_cnt = i2
            5 result_val = vc
            5 task_assay_cd = f8
            5 task_assay_meaning = c12
            5 ins_upd_ind = i2
    1 closuredevice[*]
      2 device_id = f8
      2 case_id = f8
      2 parent_event_id = f8
      2 status_ind = i2
      2 updt_cnt = i2
      2 cd_abstr_data[*]
        3 event_cd = f8
        3 event_id = f8
        3 event_type_cd = f8
        3 field_type_cd = f8
        3 field_type_meaning = c12
        3 device_abstr_id = f8
        3 device_id = f8
        3 nomenclature_id = f8
        3 result_dt_tm = dq8
        3 result_id = f8
        3 result_status_cd = f8
        3 result_status_meaning = c12
        3 updt_cnt = i2
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
        3 ins_upd_ind = i2
    1 form_type_cd = f8
    1 form_type_mean = vc
    1 case_dt_tm = dq8
  )
  IF (validate(cv_status_add) != 1)
   DECLARE cv_status_add = i4 WITH protect, constant(0)
  ENDIF
  IF (validate(cv_status_chg) != 1)
   DECLARE cv_status_chg = i4 WITH protect, constant(1)
  ENDIF
  IF (validate(cv_status_del) != 1)
   DECLARE cv_status_del = i4 WITH protect, constant(2)
  ENDIF
 ENDIF
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET sts_dataset_id = 0.0
 SET acc_dataset_id = 0.0
 SET part_cd = 0.0
 SET part_mean = fillstring(12," ")
 SET ds_sz = size(cv_omf_rec->dataset,5)
 CALL echo(build("ds_sz: ",ds_sz))
 SELECT INTO "nl:"
  FROM cv_dataset cd,
   (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
  PLAN (d)
   JOIN (cd
   WHERE (cd.dataset_id=cv_omf_rec->dataset[d.seq].dataset_id))
  DETAIL
   IF (((cd.dataset_internal_name="STS") OR (cd.dataset_internal_name="STS02")) )
    sts_dataset_id = cd.dataset_id, part_mean = "ST01SURGEON"
   ELSEIF (cd.dataset_internal_name="STS03")
    sts_dataset_id = cd.dataset_id, part_mean = "ST03SURGEON"
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failure in getting Participant Meaning in cv_dataset!")
 ENDIF
 IF (sts_dataset_id > 0)
  SELECT INTO "nl:"
   *
   FROM cv_case_dataset_r ccdr,
    (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
   PLAN (d)
    JOIN (ccdr
    WHERE (ccdr.cv_case_id=cv_omf_rec->case_id)
     AND (ccdr.dataset_id=cv_omf_rec->dataset[d.seq].dataset_id))
   DETAIL
    stat = alterlist(cv_omf_rec->dataset,d.seq), cv_omf_rec->dataset[d.seq].case_dataset_r_id = ccdr
    .case_dataset_r_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("Failure in getting case_dataset_r_id in cv_case_abstr_data!")
  ENDIF
  SET iret = uar_get_meaning_by_codeset(14003,part_mean,1,part_cd)
  SET part_event_cd = 0.0
  SELECT INTO "nl:"
   dta.*
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE dta.task_assay_cd=part_cd)
   DETAIL
    part_event_cd = dta.event_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   *
   FROM cv_case_abstr_data ccad,
    (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
   PLAN (d)
    JOIN (ccad
    WHERE (ccad.cv_case_id=cv_omf_rec->case_id)
     AND ccad.event_cd=part_event_cd)
   DETAIL
    cv_omf_rec->dataset[d.seq].participant_prsnl_id = ccad.result_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("Failure in getting result_id in cv_case_abstr_data!")
  ENDIF
  SELECT INTO "nl:"
   e.encntr_type_class_cd, e.loc_facility_cd
   FROM encounter e,
    cv_case_dataset_r ccdr,
    (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=cv_omf_rec->encntr_id)
     AND e.active_ind=1)
    JOIN (ccdr
    WHERE (cv_omf_rec->case_id=ccdr.cv_case_id)
     AND (ccdr.case_dataset_r_id=cv_omf_rec->dataset[d.seq].case_dataset_r_id))
   DETAIL
    cv_omf_rec->organization_id = e.organization_id, cv_omf_rec->dataset[d.seq].organization_id = e
    .organization_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("Failure in getting organization_id in encounter!")
  ENDIF
  CALL cv_log_message("After the cv_omf_rec structure was filled")
  EXECUTE cv_log_struct  WITH replace(request,cv_omf_rec)
  EXECUTE cv_get_dataset_part_nbr
  UPDATE  FROM cv_case_dataset_r ccdr,
    (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
   SET ccdr.participant_nbr = cv_omf_rec->dataset[d.seq].participant_nbr
   PLAN (d)
    JOIN (ccdr
    WHERE (ccdr.case_dataset_r_id=cv_omf_rec->dataset[d.seq].case_dataset_r_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL cv_log_message("Failure in updating participant number!")
   SET failure = "T"
  ELSE
   CALL cv_log_message("Success in updating participant number and it is COMMITED!")
  ENDIF
 ELSE
  CALL cv_log_message("No STS dataset in database!")
  GO TO exit_script
 ENDIF
#exit_script
 IF (failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
  CALL cv_log_message(build("Commited at: ",curprog))
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
