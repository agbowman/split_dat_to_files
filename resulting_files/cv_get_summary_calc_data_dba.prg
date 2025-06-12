CREATE PROGRAM cv_get_summary_calc_data:dba
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
 DECLARE geteventcd(prmmeaning=vc) = f8
 DECLARE getcvcontrol(paramdatasetid=f8,paramuniquestring=vc) = i4
 DECLARE getseason(paramdatecd=f8) = c1
 DECLARE getcuryr(paramdatecd=f8) = i4
 DECLARE fmt_mean = c12 WITH protect
 DECLARE iret = i2 WITH protect
 DECLARE the_dta = f8 WITH protect
 DECLARE return_ec = f8 WITH protect
 DECLARE return_nbr = i4 WITH protect
 DECLARE fall_mean = c12 WITH protect
 DECLARE spring_mean = c12 WITH protect
 DECLARE fall_cd = f8 WITH protect
 DECLARE spring_cd = f8 WITH protect
 DECLARE fall_any_mean = c12 WITH protect
 DECLARE spring_any_mean = c12 WITH protect
 DECLARE fall_any_cd = f8 WITH protect
 DECLARE spring_any_cd = f8 WITH protect
 DECLARE cv_date_set = i4 WITH protect
 DECLARE retseason = c1 WITH protect
 DECLARE century19 = i2 WITH protect
 DECLARE century20 = i2 WITH protect
 DECLARE ret_yr = i4 WITH protect
 SUBROUTINE geteventcd(prmmeaning)
   IF (size(trim(prmmeaning)) > 12)
    CALL echo(build("String too long to be CDF meaning:",prmmeaning))
    RETURN(0.0)
   ENDIF
   SET fmt_mean = trim(prmmeaning)
   SET the_dta = 0.0
   SET return_ec = 0.0
   SET the_dta = uar_get_code_by("MEANING",14003,nullterm(fmt_mean))
   IF (the_dta=0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.cdf_meaning=fmt_mean
      AND cv.active_ind=1
     DETAIL
      the_dta = cv.code_value
     WITH nocounter, maxqual(cv,1)
    ;end select
   ENDIF
   IF (the_dta=0.0)
    CALL echo(build("Could not locate CDF meaning in CS 14003:",fmt_mean))
    RETURN(0.0)
   ENDIF
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.task_assay_cd=the_dta
    DETAIL
     return_ec = dta.event_cd
    WITH nocounter
   ;end select
   RETURN(return_ec)
 END ;Subroutine
 SUBROUTINE getcvcontrol(paramdatasetid,paramuniquestring)
   SET return_nbr = 0
   SELECT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain IN ("CVNET", "CVNet")
     AND dp.parent_entity_id=paramdatasetid
     AND dp.parent_entity_name="CV_DATASET"
     AND cnvtupper(trim(dp.pref_section,3))=cnvtupper(trim(paramuniquestring,3))
    DETAIL
     return_nbr = dp.pref_nbr
    WITH nocounter
   ;end select
   RETURN(return_nbr)
 END ;Subroutine
 SUBROUTINE getseason(paramdatecd)
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (spring_any_cd=paramdatecd)) )
    SET retseason = "S"
   ENDIF
   IF (((fall_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET retseason = "F"
   ENDIF
   RETURN(retseason)
 END ;Subroutine
 SUBROUTINE getcuryr(paramdatecd)
   SET century19 = 0
   SET century20 = 0
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (fall_cd=paramdatecd)) )
    SET ret_yr = 0
   ENDIF
   IF (((spring_any_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET paramdatedisp = uar_get_code_display(paramdatecd)
    SET century19 = findstring("19",trim(paramdatedisp,3))
    SET century20 = findstring("20",trim(paramdatedisp,3))
    IF (century19 > 0)
     SET ret_yr = cnvtint(substring(century19,4,trim(paramdatedisp,3)))
    ELSEIF (century20 > 0)
     SET ret_yr = cnvtint(substring(century20,4,trim(paramdatedisp,3)))
    ELSE
     SET ret_yr = 0
    ENDIF
   ENDIF
   RETURN(ret_yr)
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
 IF ( NOT (validate(cv_calc_rec,0)))
  RECORD cv_calc_rec(
    1 case_id = f8
    1 encntr_id = f8
    1 max_case_abs = i4
    1 max_pro = i4
    1 max_pro_abs = i4
    1 max_les = i4
    1 max_les_abs = i4
    1 case_ins_ind = i2
    1 proc_ins_ind = i2
    1 les_ins_ind = i2
    1 case_ab_cnt = i2
    1 case_abstr_data[*]
      2 case_abstr_id = f8
      2 case_id = f8
      2 event_cd = f8
      2 nomenclature_id = f8
      2 result_val = vc
      2 task_assay_cd = f8
      2 task_assay_meaning = c12
    1 proc_data[*]
      2 procedure_id = f8
      2 case_id = f8
      2 les_attempted = i2
      2 les_dilated = i2
      2 del_ind = i2
      2 proc_abstr_data[*]
        3 procedure_id = f8
        3 cpad_cnt = i2
        3 event_cd = f8
        3 nomenclature_id = f8
        3 proc_abstr_id = f8
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
      2 lesion[*]
        3 lesion_id = f8
        3 procedure_id = f8
        3 dev_cnt = i2
        3 del_ind = i2
        3 les_abstr_data[*]
          4 lesion_abstr_id = f8
          4 event_cd = f8
          4 lesion_id = f8
          4 nomenclature_id = f8
          4 result_val = vc
          4 task_assay_cd = f8
          4 task_assay_meaning = c12
  )
  DECLARE cdf_accv2_num_pci = c12 WITH protect, constant("AC02ANOPCI")
  DECLARE cdf_accv2_mult_pci = c12 WITH protect, constant("AC02AMULT")
  DECLARE cdf_accv2_proc_num = c12 WITH protect, constant("AC02VPROCNUM")
  DECLARE cdf_accv2_cathpci = c12 WITH protect, constant("AC02VCATHPCI")
  DECLARE cdf_accv2_proc_type = c12 WITH protect, constant("AC02VPROCTYP")
  DECLARE cdf_accv2_les_attemped = c12 WITH protect, constant("AC02PATT")
  DECLARE cdf_accv2_les_dilated = c12 WITH protect, constant("AC02PSUCC")
  DECLARE cdf_accv2_proc_results = c12 WITH protect, constant("AC02PREST")
  DECLARE cdf_accv2_les_segment = c12 WITH protect, constant("AC02LSEGT")
  DECLARE cdf_accv2_gw_mean = c12 WITH protect, constant("AC02LGUIDE")
  DECLARE cdf_accv2_pre_stn = c12 WITH protect, constant("AC02LPRSTN")
  DECLARE cdf_accv2_pos_stn = c12 WITH protect, constant("AC02LPSSTN")
  DECLARE cdf_accv2_timi_fl = c12 WITH protect, constant("AC02LPSTIMI")
  DECLARE cdf_lesion_id_num = c12 WITH protect, constant("AC02LLSNO")
  DECLARE xref_internal_name = vc WITH protect, constant("ACC02_LSEGT")
  DECLARE response_int_blank_name = vc WITH protect, constant("ACC02_LSEGT_<BLANK>")
  DECLARE response_proc_resu_suc = vc WITH protect, constant("ACC02_PREST_SUCCESSFUL")
  DECLARE response_proc_resu_psuc = vc WITH protect, constant("ACC02_PREST_PARTIALLY_SUCCESSFUL")
  DECLARE response_proc_resu_usuc = vc WITH protect, constant("ACC02_PREST_UNSUCCESSFUL")
  DECLARE response_post_suc_timi = vc WITH protect, constant(
   "ACC02_LPSTIMI_COMPLETE_AND_BRISK_FLOW_COMPLETE_PERFUSION")
  DECLARE response_gw_suc_pass = vc WITH protect, constant("ACC02_LGUIDE_SUCCESSFUL")
  DECLARE sub_cdf_meaning = c12
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
 IF ( NOT (validate(all_case,0)))
  RECORD all_case(
    1 cases[*]
      2 case_id = f8
      2 encntr_id = f8
      2 all_case_ins_ind = i2
      2 del_ind = i2
  )
 ENDIF
 SET cv_calc_rec->case_id = cv_omf_rec->case_id
 SET cv_calc_rec->encntr_id = cv_omf_rec->encntr_id
 DECLARE response_proc_resu_suc_nomen = f8 WITH protect, noconstant(0.0)
 DECLARE response_proc_resu_psuc_nomen = f8 WITH protect, noconstant(0.0)
 DECLARE response_proc_resu_usuc_nomen = f8 WITH protect, noconstant(0.0)
 DECLARE response_post_suc_timi_nomen = f8 WITH protect, noconstant(0.0)
 DECLARE response_gw_suc_pass_nomen = f8 WITH protect, noconstant(0.0)
 DECLARE proc_result_suc = vc WITH protect, noconstant(" ")
 DECLARE proc_result_psuc = vc WITH protect, noconstant(" ")
 DECLARE proc_result_usuc = vc WITH protect, noconstant(" ")
 DECLARE suc_timi = vc WITH protect, noconstant(" ")
 DECLARE suc_pass = vc WITH protect, noconstant(" ")
 DECLARE stat = i4 WITH protect
 DECLARE rec_cnt = i4 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE max_les = i4 WITH protect
 DECLARE add_data_code_value = f8 WITH protect
 DECLARE sub_cdf_meaning = c12 WITH protect
 DECLARE gw_ec = f8 WITH protect
 DECLARE prstn_ec = f8 WITH protect
 DECLARE psstn_ec = f8 WITH protect
 DECLARE pstimi_ec = f8 WITH protect
 DECLARE add_case_data(param_cdf_meaning=c12,param_result_val=vc,param_case_id=f8) = null
 DECLARE add_proc_data(proc_idx=i4,param_procedure_id=f8,param_cdf_meaning=c12,param_result_val=vc)
  = null
 DECLARE add_les_data(param_proc_idx=i4,param_les_idx=i4,param_lesion_id=f8,param_cdf_meaning=c12,
  param_result_val=vc) = null
 SELECT INTO "nl:"
  FROM cv_response cr
  WHERE cr.response_internal_name IN (response_proc_resu_suc, response_proc_resu_psuc,
  response_proc_resu_usuc, response_post_suc_timi, response_gw_suc_pass)
  DETAIL
   CASE (cr.response_internal_name)
    OF response_proc_resu_suc:
     response_proc_resu_suc_nomen = cr.nomenclature_id,proc_result_suc = cr.a1
    OF response_proc_resu_psuc:
     response_proc_resu_psuc_nomen = cr.nomenclature_id,proc_result_psuc = cr.a1
    OF response_proc_resu_usuc:
     response_proc_resu_usuc_nomen = cr.nomenclature_id,proc_result_usuc = cr.a1
    OF response_post_suc_timi:
     response_post_suc_timi_nomen = cr.nomenclature_id,suc_timi = cr.a1
    OF response_gw_suc_pass:
     response_gw_suc_pass_nomen = cr.nomenclature_id,suc_pass = cr.a1
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo(build("RESPONSE_PROC_RESU_SUC_NOMEN: ",response_proc_resu_suc_nomen))
 CALL echo(build("PROC_RESULT_SUC: ",proc_result_suc))
 CALL echo(build("RESPONSE_PROC_RESU_PSUC_NOMEN: ",response_proc_resu_psuc_nomen))
 CALL echo(build("PROC_RESULT_PSUC: ",proc_result_psuc))
 CALL echo(build("RESPONSE_PROC_RESU_USUC_NOMEN: ",response_proc_resu_usuc_nomen))
 CALL echo(build("PROC_RESULT_USUC: ",proc_result_usuc))
 CALL echo(build("RESPONSE_POST_SUC_TIMI_NOMEN: ",response_post_suc_timi_nomen))
 CALL echo(build("SUC_TIMI: ",suc_timi))
 CALL echo(build("RESPONSE_GW_SUC_PASS_NOMEN: ",response_gw_suc_pass_nomen))
 CALL echo(build("SUC_PASS: ",suc_pass))
 SELECT INTO "nl:"
  FROM cv_case cc
  WHERE (cc.encntr_id=cv_calc_rec->encntr_id)
   AND cc.cv_case_id != 0.0
  ORDER BY cc.chart_dt_tm, cc.form_event_id, cc.cv_case_id
  HEAD REPORT
   proc_num = 0, case_cnt = 0
  DETAIL
   case_cnt = (case_cnt+ 1), stat = alterlist(all_case->cases,case_cnt), all_case->cases[case_cnt].
   case_id = cc.cv_case_id,
   all_case->cases[case_cnt].encntr_id = cv_calc_rec->encntr_id, proc_num = (proc_num+ 1),
   sub_cdf_meaning = cdf_accv2_proc_num,
   CALL add_case_data(sub_cdf_meaning,cnvtstring(proc_num),cc.cv_case_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No cases (ACC procedure number) are associated with this encounter!")
 ENDIF
 DECLARE proc_type_ec = f8 WITH protect
 SET proc_type_ec = geteventcd(cdf_accv2_proc_type)
 CALL echo(build("PROC_TYPE_EC: ",proc_type_ec))
 DECLARE pci_cnt = i4 WITH protect, noconstant(0)
 DECLARE pci_done = c1 WITH protect, noconstant("F")
 SELECT INTO "nl:"
  FROM cv_case cc,
   cv_case_abstr_data ccad,
   cv_response cr,
   cv_xref cx
  PLAN (cc
   WHERE (cc.encntr_id=cv_calc_rec->encntr_id))
   JOIN (ccad
   WHERE ccad.cv_case_id=cc.cv_case_id
    AND ccad.event_cd=proc_type_ec)
   JOIN (cx
   WHERE cx.event_cd=ccad.event_cd)
   JOIN (cr
   WHERE cr.xref_id=cx.xref_id
    AND cr.nomenclature_id=ccad.nomenclature_id)
  ORDER BY cc.chart_dt_tm, cc.form_event_id, ccad.event_id
  DETAIL
   CASE (trim(cr.a2))
    OF "3":
    OF "5":
    OF "6":
    OF "7":
     pci_cnt = (pci_cnt+ 1)
   ENDCASE
   IF ((cc.cv_case_id=cv_calc_rec->case_id))
    sub_cdf_meaning = cdf_accv2_cathpci
    CASE (trim(cr.a2))
     OF "1":
     OF "2":
     OF "4":
      pci_done = "F",
      CALL add_case_data(sub_cdf_meaning,"No",ccad.cv_case_id)
     OF "3":
      pci_done = "T",
      CALL add_case_data(sub_cdf_meaning,"No",ccad.cv_case_id)
     OF "5":
     OF "6":
     OF "7":
      pci_done = "T",
      CALL add_case_data(sub_cdf_meaning,"Yes",ccad.cv_case_id)
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No. of PCI Lab Visit will be zero, CAth/PCI same lab will be blank!")
 ENDIF
 SET sub_cdf_meaning = cdf_accv2_num_pci
 FOR (idx = 1 TO size(all_case->cases,5))
   CALL add_case_data(sub_cdf_meaning,cnvtstring(pci_cnt),all_case->cases[idx].case_id)
 ENDFOR
 DECLARE les_seg_ec = f8 WITH protect
 SET les_seg_ec = geteventcd(cdf_accv2_les_segment)
 CALL echo(build("LES_SEG_EC: ",les_seg_ec))
 IF ( NOT (validate(les_seg,0)))
  RECORD les_seg(
    1 seg[*]
      2 nomenclature_id = f8
      2 cnt = i2
  )
 ENDIF
 DECLARE seg_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM cv_xref cx,
   cv_response cr
  PLAN (cx
   WHERE ((cx.xref_internal_name=xref_internal_name) OR (cx.event_cd=les_seg_ec)) )
   JOIN (cr
   WHERE cr.xref_id=cx.xref_id
    AND cr.response_internal_name != response_int_blank_name)
  DETAIL
   seg_cnt = (seg_cnt+ 1), stat = alterlist(les_seg->seg,seg_cnt), les_seg->seg[seg_cnt].
   nomenclature_id = cr.nomenclature_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Nomenclature_id for Lesion Segment not loaded!")
 ENDIF
 DECLARE yes_done = i2 WITH protect, noconstant(false)
 SELECT INTO "nl:"
  FROM cv_case cc,
   cv_procedure cp,
   cv_lesion cl,
   cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(seg_cnt))
  PLAN (cc
   WHERE (cc.encntr_id=cv_calc_rec->encntr_id)
    AND cc.cv_case_id != 0.0)
   JOIN (cp
   WHERE cp.cv_case_id=cc.cv_case_id)
   JOIN (cl
   WHERE cl.procedure_id=cp.procedure_id)
   JOIN (clad
   WHERE clad.lesion_id=cl.lesion_id
    AND clad.event_cd=les_seg_ec)
   JOIN (d
   WHERE (les_seg->seg[d.seq].nomenclature_id=clad.nomenclature_id))
  ORDER BY cc.chart_dt_tm, cc.form_event_id
  DETAIL
   les_seg->seg[d.seq].cnt = (les_seg->seg[d.seq].cnt+ 1)
   IF ((les_seg->seg[d.seq].cnt > 1))
    yes_done = true
   ENDIF
  WITH nocounter
 ;end select
 DECLARE multipci_val = vc WITH protect
 IF (yes_done=true)
  SET multipci_val = "Yes"
 ELSE
  SET multipci_val = "No"
 ENDIF
 SET sub_cdf_meaning = cdf_accv2_mult_pci
 FOR (idx = 1 TO size(all_case->cases,5))
   CALL add_case_data(sub_cdf_meaning,multipci_val,all_case->cases[idx].case_id)
 ENDFOR
 IF (pci_done="T")
  SELECT INTO "nl:"
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl
   WHERE (cc.cv_case_id=cv_calc_rec->case_id)
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cl.procedure_id
   ORDER BY cc.chart_dt_tm, cc.form_event_id, cp.procedure_id,
    cl.lesion_id
   HEAD REPORT
    cnt_proc = 0, cnt_les = 0, cv_calc_rec->case_id = cc.cv_case_id
   HEAD cp.procedure_id
    cnt_proc = (cnt_proc+ 1)
    IF (mod(cnt_proc,10)=1)
     stat = alterlist(cv_calc_rec->proc_data,(cnt_proc+ 9))
    ENDIF
    cv_calc_rec->encntr_id = cc.encntr_id, cv_calc_rec->proc_data[cnt_proc].case_id = cc.cv_case_id,
    cv_calc_rec->proc_data[cnt_proc].procedure_id = cp.procedure_id
   DETAIL
    cnt_les = (cnt_les+ 1)
    IF (mod(cnt_les,10)=1)
     stat = alterlist(cv_calc_rec->proc_data[cnt_proc].lesion,(cnt_les+ 9))
    ENDIF
    cv_calc_rec->proc_data[cnt_proc].lesion[cnt_les].lesion_id = cl.lesion_id, cv_calc_rec->
    proc_data[cnt_proc].lesion[cnt_les].procedure_id = cl.procedure_id
   FOOT  cp.procedure_id
    stat = alterlist(cv_calc_rec->proc_data[cnt_proc].lesion,cnt_les), cnt_les = 0
   FOOT REPORT
    stat = alterlist(cv_calc_rec->proc_data,cnt_proc)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("Failure in selecting cv summary tables!")
  ENDIF
  FOR (i = 1 TO size(cv_calc_rec->proc_data,5))
    SET max_les = maxval(max_les,size(cv_calc_rec->proc_data[i].lesion,5))
  ENDFOR
  SET gw_ec = geteventcd(cdf_accv2_gw_mean)
  SET prstn_ec = geteventcd(cdf_accv2_pre_stn)
  SET psstn_ec = geteventcd(cdf_accv2_pos_stn)
  SET pstimi_ec = geteventcd(cdf_accv2_timi_fl)
  CALL echo(build("GW_EC: ",gw_ec))
  CALL echo(build("PRSTN_EC: ",prstn_ec))
  CALL echo(build("PSSTN_EC: ",psstn_ec))
  CALL echo(build("PSTIMI_EC: ",pstimi_ec))
  DECLARE prstn_val = vc WITH public, noconstant(" ")
  DECLARE psstn_val = vc WITH public, noconstant(" ")
  DECLARE pstimi_val = vc WITH public, noconstant(" ")
  DECLARE gw_val = vc WITH public, noconstant(" ")
  DECLARE prstn_nomen = f8 WITH public, noconstant(0.0)
  DECLARE psstn_nomen = f8 WITH public, noconstant(0.0)
  DECLARE pstimi_nomen = f8 WITH public, noconstant(0.0)
  DECLARE gw_nomen = f8 WITH public, noconstant(0.0)
  SELECT INTO "nl:"
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl,
    cv_les_abstr_data clad,
    (dummyt d1  WITH seq = value(size(cv_calc_rec->proc_data,5))),
    (dummyt d2  WITH seq = value(max_les))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
    JOIN (cc
    WHERE (cc.cv_case_id=cv_calc_rec->case_id))
    JOIN (cp
    WHERE (cp.procedure_id=cv_calc_rec->proc_data[d1.seq].procedure_id))
    JOIN (cl
    WHERE (cl.lesion_id=cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id))
    JOIN (clad
    WHERE clad.lesion_id=cl.lesion_id)
   ORDER BY cc.chart_dt_tm, cc.form_event_id, cp.procedure_id,
    cl.lesion_id
   HEAD cl.lesion_id
    CALL echo("Resetting all the values..."), prstn_val = " ", psstn_val = " ",
    pstimi_val = "                                ", prstn_nomen = 0.0, psstn_nomen = 0.0,
    pstimi_nomen = 0.0, gw_nomen = 0.0, dev_cnt = 0,
    pre_val = 0, post_val = 0, final_val = 0
    IF (cl.lesion_id > 0)
     cv_calc_rec->proc_data[d1.seq].les_attempted = (cv_calc_rec->proc_data[d1.seq].les_attempted+ 1)
    ENDIF
   DETAIL
    CASE (clad.event_cd)
     OF gw_ec:
      gw_val = clad.result_val,gw_nomen = clad.nomenclature_id
     OF prstn_ec:
      prstn_val = clad.result_val,prstn_nomen = clad.nomenclature_id
     OF psstn_ec:
      psstn_val = clad.result_val,psstn_nomen = clad.nomenclature_id
     OF pstimi_ec:
      pstimi_val = clad.result_val,pstimi_nomen = clad.nomenclature_id
    ENDCASE
   FOOT  cl.lesion_id
    CALL echo("Reach foot!")
    IF (gw_nomen=response_gw_suc_pass_nomen)
     IF (cnvtint(psstn_val) <= 50)
      CALL echo("Reach <=50!")
      IF (pstimi_nomen=response_post_suc_timi_nomen)
       CALL echo("Reach timi flow!"), pre_val = cnvtint(prstn_val), post_val = cnvtint(psstn_val),
       final_val = (pre_val - post_val)
       IF (final_val >= 20)
        CALL echo("Reach >= 20"), cv_calc_rec->proc_data[d1.seq].les_dilated = (cv_calc_rec->
        proc_data[d1.seq].les_dilated+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("Failed in select cv_les_abstr_data table, program continue")
  ENDIF
  FOR (idx = 1 TO size(cv_calc_rec->proc_data,5))
    IF ((cv_calc_rec->proc_data[idx].case_id=cv_calc_rec->case_id))
     SET sub_cdf_meaning = cdf_accv2_les_attemped
     CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,cnvtstring(
       cv_calc_rec->proc_data[idx].les_attempted))
     SET sub_cdf_meaning = cdf_accv2_les_dilated
     CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,cnvtstring(
       cv_calc_rec->proc_data[idx].les_dilated))
     SET sub_cdf_meaning = cdf_accv2_proc_results
     IF ((cv_calc_rec->proc_data[idx].les_attempted=cv_calc_rec->proc_data[idx].les_dilated)
      AND (cv_calc_rec->proc_data[idx].les_dilated > 0))
      CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,proc_result_suc
       )
     ELSEIF ((cv_calc_rec->proc_data[idx].les_attempted > cv_calc_rec->proc_data[idx].les_dilated)
      AND (cv_calc_rec->proc_data[idx].les_dilated > 0))
      CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,
       proc_result_psuc)
     ELSEIF ((cv_calc_rec->proc_data[idx].les_dilated=0)
      AND (cv_calc_rec->proc_data[idx].les_attempted > 0))
      CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,
       proc_result_usuc)
     ELSE
      CALL add_proc_data(idx,cv_calc_rec->proc_data[idx].procedure_id,sub_cdf_meaning,
       proc_result_usuc)
     ENDIF
     SET sub_cdf_meaning = cdf_lesion_id_num
     FOR (idx2 = 1 TO size(cv_calc_rec->proc_data[idx].lesion,5))
       CALL add_les_data(idx,idx2,cv_calc_rec->proc_data[idx].lesion[idx2].lesion_id,sub_cdf_meaning,
        cnvtstring(idx2))
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 FOR (c = 1 TO size(cv_calc_rec->case_abstr_data,5))
   IF ((cv_calc_rec->max_case_abs < size(cv_calc_rec->case_abstr_data,5)))
    SET cv_calc_rec->max_case_abs = size(cv_calc_rec->case_abstr_data,5)
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(cv_calc_rec->proc_data,5))
   IF ((cv_calc_rec->max_pro < size(cv_calc_rec->proc_data,5)))
    SET cv_calc_rec->max_pro = size(cv_calc_rec->proc_data,5)
   ENDIF
   FOR (p = 1 TO size(cv_calc_rec->proc_data[i].proc_abstr_data,5))
     IF ((cv_calc_rec->max_pro_abs < size(cv_calc_rec->proc_data[i].proc_abstr_data,5)))
      SET cv_calc_rec->max_pro_abs = size(cv_calc_rec->proc_data[i].proc_abstr_data,5)
     ENDIF
   ENDFOR
   FOR (j = 1 TO size(cv_calc_rec->proc_data[i].lesion,5))
    IF ((cv_calc_rec->max_les < size(cv_calc_rec->proc_data[i].lesion,5)))
     SET cv_calc_rec->max_les = size(cv_calc_rec->proc_data[i].lesion,5)
    ENDIF
    FOR (k = 1 TO size(cv_calc_rec->proc_data[i].lesion[j].les_abstr_data,5))
      IF ((cv_calc_rec->max_les_abs < size(cv_calc_rec->proc_data[i].lesion[j].les_abstr_data,5)))
       SET cv_calc_rec->max_les_abs = size(cv_calc_rec->proc_data[i].lesion[j].les_abstr_data,5)
      ENDIF
    ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM cv_xref cx,
   cv_response cr,
   (dummyt d  WITH seq = value(cv_calc_rec->max_case_abs))
  PLAN (d
   WHERE (cv_calc_rec->case_abstr_data[d.seq].task_assay_cd != 0.0))
   JOIN (cx
   WHERE (cx.task_assay_cd=cv_calc_rec->case_abstr_data[d.seq].task_assay_cd))
   JOIN (cr
   WHERE cr.xref_id=cx.xref_id)
  DETAIL
   cv_calc_rec->case_abstr_data[d.seq].event_cd = cx.event_cd
   IF (cnvtupper(trim(cr.a1))=cnvtupper(trim(cv_calc_rec->case_abstr_data[d.seq].result_val)))
    cv_calc_rec->case_abstr_data[d.seq].nomenclature_id = cr.nomenclature_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failure in getting event_cd for cv_case_abstr_data struct!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_xref cx,
   cv_response cr,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
   JOIN (cx
   WHERE (cx.task_assay_cd=cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].task_assay_cd))
   JOIN (cr
   WHERE cr.xref_id=cx.xref_id)
  DETAIL
   cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].event_cd = cx.event_cd
   IF (cnvtupper(trim(cr.a1))=cnvtupper(trim(cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].
     result_val)))
    cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].nomenclature_id = cr.nomenclature_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failure in getting event_cd for cv_proc_abstr_data struct!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_xref cx,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_les)),
   (dummyt d3  WITH seq = value(cv_calc_rec->max_les_abs))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
   JOIN (d3
   WHERE d3.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5))
   JOIN (cx
   WHERE (cx.task_assay_cd=cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].
   task_assay_cd))
  DETAIL
   cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_cd = cx.event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failure in getting event_cd for cv_les_abstr_data struct!")
 ENDIF
 CALL echorecord(cv_calc_rec,"cer_temp:cv_calc_rec.dat")
 CALL echorecord(cv_calc_rec)
 EXECUTE cv_add_summary_calc_data
 GO TO exit_script
 SUBROUTINE add_case_data(param_cdf_meaning,param_result_val,param_case_id)
   SET add_data_code_value = 0.0
   SET iret = uar_get_meaning_by_codeset(14003,param_cdf_meaning,1,add_data_code_value)
   SET rec_cnt = (size(cv_calc_rec->case_abstr_data,5)+ 1)
   SET stat = alterlist(cv_calc_rec->case_abstr_data,rec_cnt)
   SET cv_calc_rec->case_abstr_data[rec_cnt].result_val = param_result_val
   SET cv_calc_rec->case_abstr_data[rec_cnt].task_assay_cd = add_data_code_value
   SET cv_calc_rec->case_abstr_data[rec_cnt].task_assay_meaning = param_cdf_meaning
   SET cv_calc_rec->case_abstr_data[rec_cnt].case_id = param_case_id
 END ;Subroutine
 SUBROUTINE add_proc_data(proc_idx,param_procedure_id,param_cdf_meaning,param_result_val)
   SET add_data_code_value = 0.0
   SET iret = uar_get_meaning_by_codeset(14003,param_cdf_meaning,1,add_data_code_value)
   SET rec_cnt = (size(cv_calc_rec->proc_data[proc_idx].proc_abstr_data,5)+ 1)
   SET stat = alterlist(cv_calc_rec->proc_data[proc_idx].proc_abstr_data,rec_cnt)
   SET cv_calc_rec->proc_data[proc_idx].proc_abstr_data[rec_cnt].result_val = param_result_val
   SET cv_calc_rec->proc_data[proc_idx].proc_abstr_data[rec_cnt].task_assay_cd = add_data_code_value
   SET cv_calc_rec->proc_data[proc_idx].proc_abstr_data[rec_cnt].task_assay_meaning =
   param_cdf_meaning
   SET cv_calc_rec->proc_data[proc_idx].proc_abstr_data[rec_cnt].procedure_id = param_procedure_id
 END ;Subroutine
 SUBROUTINE add_les_data(param_proc_idx,param_les_idx,param_lesion_id,param_cdf_meaning,
  param_result_val)
   SET add_data_code_value = 0.0
   SET iret = uar_get_meaning_by_codeset(14003,param_cdf_meaning,1,add_data_code_value)
   SET rec_cnt = (size(cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data,5)
   + 1)
   SET stat = alterlist(cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data,
    rec_cnt)
   SET cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data[rec_cnt].
   result_val = param_result_val
   SET cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data[rec_cnt].
   task_assay_cd = add_data_code_value
   SET cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data[rec_cnt].
   task_assay_meaning = param_cdf_meaning
   SET cv_calc_rec->proc_data[param_proc_idx].lesion[param_les_idx].les_abstr_data[rec_cnt].lesion_id
    = param_lesion_id
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
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
 DECLARE cv_get_summary_calc_data_vrsn = vc WITH private, constant("MOD 008 05/24/06 BM9013")
END GO
