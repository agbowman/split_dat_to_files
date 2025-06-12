CREATE PROGRAM cv_get_summary_data:dba
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
 IF (validate(cv_omf_rec,"notdefined") != "notdefined")
  CALL cv_log_message("cv_omf_rec is already defined!")
 ELSE
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
 IF (validate(reply,"Notdefined") != "Notdefined")
  CALL cv_log_message("reply is already defined!")
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
 FREE RECORD les_lookup
 RECORD les_lookup(
   1 lesion[*]
     2 lesion_cnt = i4
     2 lesion_pe_id = f8
     2 lesion_dev_pe_id = f8
 )
 FREE RECORD dev_lookup
 RECORD dev_lookup(
   1 device[*]
     2 device_pe_id = f8
     2 les_lookup_idx = i4
 )
 IF (validate(g_dataset_id,0.0) != 0.0)
  CALL cv_log_message("g_Dataset_ID is already defined!")
 ELSE
  DECLARE g_dataset_id = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE date = vc WITH protect, constant("dd-mm-yyyy hh:mm:ss.cc;;d")
 SET reply->status_data.status = "F"
 DECLARE get_failed = c1 WITH protect, noconstant("F")
 DECLARE iprocount = i4 WITH protect
 DECLARE lesioncnt = i4 WITH protect
 DECLARE icdevcnt = i4 WITH protect
 DECLARE closdevcnt = i4 WITH protect
 DECLARE iabstrcount = i4 WITH protect
 IF ((register->no_event_id_ind=0))
  IF ((cv_omf_rec->top_parent_event_id=0))
   EXECUTE cv_get_surg_case_id
  ELSE
   SET cv_omf_rec->form_event_id = cv_omf_rec->top_parent_event_id
  ENDIF
 ELSE
  SET cv_omf_rec->top_parent_event_id = register->top_parent_event_id
  SET cv_omf_rec->form_event_id = cv_omf_rec->top_parent_event_id
 ENDIF
 SET cv_omf_rec->encntr_id = register->rec[1].encntr_id
 SET cv_omf_rec->person_id = register->rec[1].person_id
 SET cv_omf_rec->form_type_cd = validate(register->form_type_cd,0.0)
 IF ((cv_omf_rec->form_type_cd > 0.0))
  SET cv_omf_rec->form_type_mean = uar_get_code_meaning(cv_omf_rec->form_type_cd)
 ENDIF
 SELECT
  IF (g_dataset_id != 0.0)
   PLAN (d1
    WHERE (register->rec[d1.seq].event_cd != 0.0))
    JOIN (ref
    WHERE (ref.event_cd=register->rec[d1.seq].event_cd)
     AND (ref.xref_id=register->rec[d1.seq].xref_id)
     AND ref.dataset_id=g_dataset_id
     AND  NOT ( EXISTS (
    (SELECT
     a.result_dta_cd
     FROM cv_algorithm a
     WHERE a.result_dta_cd=ref.task_assay_cd
      AND a.result_dta_cd != 0.0
      AND a.dataset_id=ref.dataset_id))))
    JOIN (cv
    WHERE cv.code_value=ref.event_type_cd
     AND cv.code_set=22309
     AND cv.active_ind=1
     AND ((cv.begin_effective_dt_tm=null) OR (cv.begin_effective_dt_tm != null
     AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
     AND ((cv.end_effective_dt_tm=null) OR (cv.end_effective_dt_tm != null
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))) )
    JOIN (d)
    JOIN (cer
    WHERE (cer.event_id=register->rec[d1.seq].event_id)
     AND cer.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND (register->no_event_id_ind=0))
  ELSE
  ENDIF
  INTO "NL:"
  parent_event_id = register->rec[d1.seq].parent_event_id, dataset_id = ref.dataset_id, ref
  .event_type_cd,
  ref.task_assay_cd, cer.nomenclature_id, register->rec[d1.seq].result_val,
  cv.cdf_meaning, sub_event_meaning = uar_get_code_meaning(ref.sub_event_type_cd), cv.collation_seq
  FROM code_value cv,
   cv_xref ref,
   dummyt d,
   ce_coded_result cer,
   (dummyt d1  WITH seq = value(size(register->rec,5)))
  PLAN (d1
   WHERE (register->rec[d1.seq].event_cd != 0.0))
   JOIN (ref
   WHERE (ref.event_cd=register->rec[d1.seq].event_cd)
    AND (ref.xref_id=register->rec[d1.seq].xref_id)
    AND  NOT ( EXISTS (
   (SELECT
    a.result_dta_cd
    FROM cv_algorithm a
    WHERE a.result_dta_cd=ref.task_assay_cd
     AND a.result_dta_cd != 0.0))))
   JOIN (cv
   WHERE cv.code_value=ref.event_type_cd
    AND cv.code_set=22309
    AND cv.active_ind=1
    AND ((cv.begin_effective_dt_tm=null) OR (cv.begin_effective_dt_tm != null
    AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
    AND ((cv.end_effective_dt_tm=null) OR (cv.end_effective_dt_tm != null
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))) )
   JOIN (d)
   JOIN (cer
   WHERE (cer.event_id=register->rec[d1.seq].event_id)
    AND cer.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND (register->no_event_id_ind=0))
  ORDER BY cv.collation_seq, sub_event_meaning, parent_event_id,
   dataset_id
  HEAD REPORT
   les_lookup_cnt = 0, dev_lookup_cnt = 0
  HEAD cv.collation_seq
   iabstrcount = 0
   IF (cv.cdf_meaning != "CASE")
    iprocount = (iprocount+ 1), iprosize = alterlist(cv_omf_rec->proc_data,iprocount), cv_omf_rec->
    proc_data[iprocount].event_type_cd = ref.event_type_cd
   ENDIF
  HEAD sub_event_meaning
   col 0
  HEAD parent_event_id
   idatasetid = 0, ilesabstrcount = 0, iicdevabstrcount = 0,
   iclosdevabstrcount = 0
   IF (sub_event_meaning="LESION")
    lesioncnt = (lesioncnt+ 1), stat = alterlist(cv_omf_rec->proc_data[iprocount].lesion,lesioncnt)
    IF ((cv_omf_rec->max_lesion < lesioncnt))
     cv_omf_rec->max_lesion = lesioncnt
    ENDIF
   ELSEIF (sub_event_meaning="CLOS_DEV")
    closdevcnt = (closdevcnt+ 1), stat = alterlist(cv_omf_rec->closuredevice,closdevcnt)
    IF ((cv_omf_rec->max_closdev < closdevcnt))
     cv_omf_rec->max_closdev = closdevcnt
    ENDIF
   ELSEIF (sub_event_meaning="LESION_DEV_D")
    FOR (i = 1 TO size(dev_lookup->device,5))
      IF ((register->rec[d1.seq].parent_event_id=dev_lookup->device[i].device_pe_id))
       actlesion = les_lookup->lesion[dev_lookup->device[i].les_lookup_idx].lesion_cnt, i = size(
        dev_lookup->device,5)
      ENDIF
    ENDFOR
    icdevcnt = (size(cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice,5)+ 1), stat =
    alterlist(cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice,icdevcnt)
    IF ((cv_omf_rec->max_icdev < icdevcnt))
     cv_omf_rec->max_icdev = icdevcnt
    ENDIF
   ENDIF
  HEAD dataset_id
   idatasetid = (idatasetid+ 1), stat = alterlist(cv_omf_rec->dataset,idatasetid), cv_omf_rec->
   dataset[idatasetid].dataset_id = ref.dataset_id
  DETAIL
   iabstrcount = (iabstrcount+ 1)
   IF (cv.cdf_meaning="CASE")
    IF (sub_event_meaning != "CLOS_DEV")
     stat = alterlist(cv_omf_rec->case_abstr_data,iabstrcount), cv_omf_rec->case_abstr_data[
     iabstrcount].event_cd = register->rec[d1.seq].event_cd, cv_omf_rec->case_abstr_data[iabstrcount]
     .event_id = register->rec[d1.seq].event_id,
     cv_omf_rec->case_abstr_data[iabstrcount].event_type_cd = ref.event_type_cd, cv_omf_rec->
     case_abstr_data[iabstrcount].result_val = register->rec[d1.seq].result_val
     IF ((register->no_event_id_ind=0))
      cv_omf_rec->case_abstr_data[iabstrcount].nomenclature_id = cer.nomenclature_id
     ELSE
      cv_omf_rec->case_abstr_data[iabstrcount].nomenclature_id = register->rec[d1.seq].result_id
     ENDIF
     cv_omf_rec->case_abstr_data[iabstrcount].result_dt_tm = register->rec[d1.seq].result_dt_tm,
     cv_omf_rec->case_abstr_data[iabstrcount].task_assay_cd = ref.task_assay_cd, cv_omf_rec->
     case_abstr_data[iabstrcount].task_assay_meaning = uar_get_code_meaning(ref.task_assay_cd),
     cv_omf_rec->case_abstr_data[iabstrcount].field_type_cd = ref.field_type_cd, cv_omf_rec->
     case_abstr_data[iabstrcount].field_type_meaning = uar_get_code_meaning(ref.field_type_cd),
     cv_omf_rec->case_abstr_data[iabstrcount].result_status_cd = register->rec[d1.seq].
     result_status_cd,
     cv_omf_rec->case_abstr_data[iabstrcount].result_status_meaning = uar_get_code_meaning(register->
      rec[d1.seq].result_status_cd)
    ELSEIF (sub_event_meaning="CLOS_DEV")
     iclosdevabstrcount = (iclosdevabstrcount+ 1), stat = alterlist(cv_omf_rec->closuredevice[
      closdevcnt].cd_abstr_data,iclosdevabstrcount)
     IF ((cv_omf_rec->max_closdev_abstr < iclosdevabstrcount))
      cv_omf_rec->max_closdev_abstr = iclosdevabstrcount
     ENDIF
     cv_omf_rec->closuredevice[closdevcnt].parent_event_id = register->rec[d1.seq].parent_event_id,
     cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].event_cd = register->
     rec[d1.seq].event_cd, cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].
     event_id = register->rec[d1.seq].event_id,
     cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].result_val = register->
     rec[d1.seq].result_val
     IF ((register->no_event_id_ind=0))
      cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].nomenclature_id = cer
      .nomenclature_id
     ELSE
      cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].nomenclature_id =
      register->rec[d1.seq].result_id
     ENDIF
     cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].event_type_cd = ref
     .event_type_cd, cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].
     task_assay_cd = ref.task_assay_cd, cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[
     iclosdevabstrcount].task_assay_meaning = uar_get_code_meaning(ref.task_assay_cd),
     cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].field_type_cd = ref
     .field_type_cd, cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].
     field_type_meaning = uar_get_code_meaning(ref.field_type_cd), cv_omf_rec->closuredevice[
     closdevcnt].cd_abstr_data[iclosdevabstrcount].result_status_cd = register->rec[d1.seq].
     result_status_cd,
     cv_omf_rec->closuredevice[closdevcnt].cd_abstr_data[iclosdevabstrcount].result_status_meaning =
     uar_get_code_meaning(register->rec[d1.seq].result_status_cd)
    ENDIF
   ELSE
    IF (size(trim(sub_event_meaning))=0)
     stat = alterlist(cv_omf_rec->proc_data[iprocount].proc_abstr_data,iabstrcount)
     IF ((cv_omf_rec->max_proc_abstr < iabstrcount))
      cv_omf_rec->max_proc_abstr = iabstrcount
     ENDIF
     IF ((register->no_event_id_ind=0))
      cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].nomenclature_id = cer
      .nomenclature_id
     ELSE
      cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].nomenclature_id = register->rec[
      d1.seq].result_id
     ENDIF
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].event_cd = register->rec[d1.seq].
     event_cd, cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].event_id = register->
     rec[d1.seq].event_id, cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].result_val
      = register->rec[d1.seq].result_val,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].task_assay_cd = ref.task_assay_cd,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].task_assay_meaning =
     uar_get_code_meaning(ref.task_assay_cd), cv_omf_rec->proc_data[iprocount].proc_abstr_data[
     iabstrcount].field_type_cd = ref.field_type_cd,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].field_type_meaning =
     uar_get_code_meaning(ref.field_type_cd), cv_omf_rec->proc_data[iprocount].proc_abstr_data[
     iabstrcount].result_status_cd = register->rec[d1.seq].result_status_cd, cv_omf_rec->proc_data[
     iprocount].proc_abstr_data[iabstrcount].result_status_meaning = uar_get_code_meaning(register->
      rec[d1.seq].result_status_cd)
    ELSEIF (sub_event_meaning="LESION")
     CALL echo("LESION")
     IF (uar_get_code_display(register->rec[d1.seq].event_cd)="AC03 IC Device Grid")
      les_lookup_cnt = (les_lookup_cnt+ 1), stat = alterlist(les_lookup->lesion,les_lookup_cnt),
      les_lookup->lesion[les_lookup_cnt].lesion_pe_id = register->rec[d1.seq].parent_event_id,
      les_lookup->lesion[les_lookup_cnt].lesion_dev_pe_id = register->rec[d1.seq].event_id,
      les_lookup->lesion[les_lookup_cnt].lesion_cnt = lesioncnt
     ELSE
      ilesabstrcount = (ilesabstrcount+ 1), stat = alterlist(cv_omf_rec->proc_data[iprocount].lesion[
       lesioncnt].les_abstr_data,ilesabstrcount)
      IF ((cv_omf_rec->max_lesion_abstr < ilesabstrcount))
       cv_omf_rec->max_lesion_abstr = ilesabstrcount
      ENDIF
      cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].parent_event_id = register->rec[d1.seq].
      parent_event_id, cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[
      ilesabstrcount].event_cd = register->rec[d1.seq].event_cd, cv_omf_rec->proc_data[iprocount].
      lesion[lesioncnt].les_abstr_data[ilesabstrcount].event_id = register->rec[d1.seq].event_id,
      cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].result_val =
      register->rec[d1.seq].result_val
      IF ((register->no_event_id_ind=0))
       cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].
       nomenclature_id = cer.nomenclature_id
      ELSE
       cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].
       nomenclature_id = register->rec[d1.seq].result_id
      ENDIF
      cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].event_type_cd
       = ref.event_type_cd, cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[
      ilesabstrcount].task_assay_cd = ref.task_assay_cd, cv_omf_rec->proc_data[iprocount].lesion[
      lesioncnt].les_abstr_data[ilesabstrcount].task_assay_meaning = uar_get_code_meaning(ref
       .task_assay_cd),
      cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].field_type_cd
       = ref.field_type_cd, cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[
      ilesabstrcount].field_type_meaning = uar_get_code_meaning(ref.field_type_cd), cv_omf_rec->
      proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].result_status_cd =
      register->rec[d1.seq].result_status_cd,
      cv_omf_rec->proc_data[iprocount].lesion[lesioncnt].les_abstr_data[ilesabstrcount].
      result_status_meaning = uar_get_code_meaning(register->rec[d1.seq].result_status_cd)
     ENDIF
    ELSEIF (sub_event_meaning="LESION_DEV")
     CALL echo("LESION_DEV")
     FOR (i = 1 TO size(les_lookup->lesion,5))
       IF ((register->rec[d1.seq].parent_event_id=les_lookup->lesion[i].lesion_dev_pe_id))
        dev_lookup_cnt = (dev_lookup_cnt+ 1), stat = alterlist(dev_lookup->device,dev_lookup_cnt),
        dev_lookup->device[dev_lookup_cnt].device_pe_id = register->rec[d1.seq].event_id,
        dev_lookup->device[dev_lookup_cnt].les_lookup_idx = i, i = size(les_lookup->lesion,5)
       ENDIF
     ENDFOR
    ELSEIF (sub_event_meaning="LESION_DEV_D")
     CALL echo("LESION_DEV_D"), iicdevabstrcount = (iicdevabstrcount+ 1), stat = alterlist(cv_omf_rec
      ->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data,iicdevabstrcount)
     IF ((cv_omf_rec->max_icdev_abstr < iicdevabstrcount))
      cv_omf_rec->max_icdev_abstr = iicdevabstrcount
     ENDIF
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].parent_event_id = register
     ->rec[d1.seq].parent_event_id, cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[
     icdevcnt].icd_abstr_data[iicdevabstrcount].event_cd = register->rec[d1.seq].event_cd, cv_omf_rec
     ->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[iicdevabstrcount].
     event_id = register->rec[d1.seq].event_id,
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
     iicdevabstrcount].result_val = register->rec[d1.seq].result_val
     IF ((register->no_event_id_ind=0))
      cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
      iicdevabstrcount].nomenclature_id = cer.nomenclature_id
     ELSE
      cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
      iicdevabstrcount].nomenclature_id = register->rec[d1.seq].result_id
     ENDIF
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
     iicdevabstrcount].event_type_cd = ref.event_type_cd, cv_omf_rec->proc_data[iprocount].lesion[
     actlesion].icdevice[icdevcnt].icd_abstr_data[iicdevabstrcount].task_assay_cd = ref.task_assay_cd,
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
     iicdevabstrcount].task_assay_meaning = uar_get_code_meaning(ref.task_assay_cd),
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
     iicdevabstrcount].field_type_cd = ref.field_type_cd, cv_omf_rec->proc_data[iprocount].lesion[
     actlesion].icdevice[icdevcnt].icd_abstr_data[iicdevabstrcount].field_type_meaning =
     uar_get_code_meaning(ref.field_type_cd), cv_omf_rec->proc_data[iprocount].lesion[actlesion].
     icdevice[icdevcnt].icd_abstr_data[iicdevabstrcount].result_status_cd = register->rec[d1.seq].
     result_status_cd,
     cv_omf_rec->proc_data[iprocount].lesion[actlesion].icdevice[icdevcnt].icd_abstr_data[
     iicdevabstrcount].result_status_meaning = uar_get_code_meaning(register->rec[d1.seq].
      result_status_cd)
    ENDIF
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_xref for packing cv_omf_rec!!")
  SET get_failed = "T"
  GO TO exit_script
 ENDIF
 EXECUTE cv_add_special_abstr_data
 IF ((register->calling_script_flag > 0))
  CALL cv_log_message("Execute cv_insert_summary_data!")
  EXECUTE cv_insert_summary_data
 ELSE
  CALL cv_log_message("Execute cv_inst_updt_summary_data!")
  EXECUTE cv_inst_updt_summary_data
 ENDIF
#exit_script
 IF (get_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
  CALL cv_log_message(build("Rollback at: ",curprog))
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
  CALL cv_log_message(build("Committed at: ",curprog))
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
 DECLARE cv_get_summary_data_vrsn = vc WITH private, constant("MOD 019 09/27/05 BM9013")
END GO
