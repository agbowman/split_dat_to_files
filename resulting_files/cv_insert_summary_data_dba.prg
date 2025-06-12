CREATE PROGRAM cv_insert_summary_data:dba
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
 IF (validate(cv_hrv_rec,"notdefined") != "notdefined")
  CALL cv_log_message("cv_hrv_rec  is already defined - Get_Harvest_inc!")
 ELSE
  RECORD cv_hrv_rec(
    1 max_proc_data = i4
    1 max_lesion = i4
    1 max_closdev = i4
    1 max_icdev = i4
    1 max_abstr_data = i4
    1 max_num_files = i4
    1 max_file_rows = i4
    1 dataset_id = f8
    1 validation_script = vc
    1 harvest_display = vc
    1 admit_form_idx = i4
    1 harvest_rec[*]
      2 dataset_id = f8
      2 case_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 loc_facility_cd = f8
      2 start_dt = dq8
      2 stop_dt = dq8
      2 ops_date = dq8
      2 batch_selection = vc
      2 output_dest = vc
      2 case_dataset_r_id = f8
      2 organization_id = f8
      2 disch_dt_tm = dq8
      2 admit_dt_tm = dq8
      2 birth_dt_tm = dq8
      2 case_dt_tm = dq8
      2 participant_nbr = vc
      2 case_display = vc
      2 valid_flag = i2
      2 error_msg = vc
      2 status_cd = f8
      2 top_parent_event_id = f8
      2 case_abstr_data[*]
        3 nbr_filled_fields = i4
        3 abstr_data_idx = i4
      2 proc_data[*]
        3 case_id = f8
        3 proc_id = f8
        3 event_type_cd = f8
        3 event_type_display = vc
        3 proc_physician_id = f8
        3 proc_start_dt_tm = dq8
        3 proc_end_dt_tm = dq8
        3 cur_dev_num = i4
        3 proc_abstr_data[*]
          4 abstr_data_idx = i4
          4 nbr_filled_fields = i4
        3 lesion[*]
          4 procedure_id = f8
          4 lesion_id = f8
          4 lesion_display = vc
          4 les_abstr_data[*]
            5 abstr_data_idx = i4
            5 nbr_filled_fields = i4
          4 exist_dev_idx[*]
            5 dev_idx = i4
          4 icdevice[*]
            5 procedure_id = f8
            5 device_id = f8
            5 device_display = vc
            5 icd_abstr_data[*]
              6 abstr_data_idx = i4
              6 nbr_filled_fields = i4
            5 exist_dev_idx[*]
              6 dev_idx = i4
      2 closuredevice[*]
        3 device_id = f8
        3 device_display = vc
        3 cd_abstr_data[*]
          4 abstr_data_idx = i4
          4 nbr_filled_fields = i4
        3 exist_dev_idx[*]
          4 dev_idx = i4
      2 abstr_data[*]
        3 xref_id = f8
        3 abstr_data_id = f8
        3 abstr_data_name = vc
        3 case_id = f8
        3 procedure_id = f8
        3 lesion_id = f8
        3 field_type_cd = f8
        3 field_type_meaning = c12
        3 display_field_ind = i2
        3 event_cd = f8
        3 nomenclature_id = f8
        3 result_val = vc
        3 result_id = f8
        3 result_source = vc
        3 result_dt_tm = dq8
        3 task_assay_cd = f8
        3 task_assay_mean = c12
        3 normal_high = f8
        3 normal_low = f8
        3 required_flag = i4
        3 valid_flag = i4
        3 translated_value = vc
        3 error_msg = vc
        3 err_status = i2
        3 status_cd = f8
        3 abstr_type_flag = i4
        3 abstr_idx = i4
        3 proc_data_idx = i4
        3 lesion_data_idx = i4
        3 dev_idx = i4
        3 case_field_id = f8
        3 long_text_id = f8
        3 device_id = f8
        3 collect_start_dt_tm = dq8
        3 collect_stop_dt_tm = dq8
      2 files[*]
        3 dataset_file_id = f8
        3 file_row[*]
          4 case_file_row_id = f8
          4 line = vc
          4 long_text_id = f8
          4 err_status = i2
      2 registry_nbr = f8
      2 form_id = f8
      2 form_type_mean = vc
    1 files[*]
      2 dataset_file_id = f8
      2 file_row[*]
        3 line = vc
        3 long_text_id = f8
        3 err_status = i2
    1 dataset_internal_name = vc
  )
 ENDIF
 IF (validate(abstr_type_case) != 1)
  DECLARE abstr_type_case = i4 WITH protect, constant(1)
  DECLARE abstr_type_proc = i4 WITH protect, constant(2)
  DECLARE abstr_type_les = i4 WITH protect, constant(3)
  DECLARE abstr_type_closdev = i4 WITH protect, constant(4)
  DECLARE abstr_type_icdev = i4 WITH protect, constant(5)
  DECLARE abstr_type_admit = i4 WITH protect, constant(6)
  DECLARE err_country_code = vc WITH protect, constant("The Country Code is Missing.")
  DECLARE err_ssn = vc WITH protect, constant("The Social Security Number is Missing.")
  DECLARE err_mrn = vc WITH protect, constant("The Medical Record Number is Missing.")
  DECLARE err_patientzip = vc WITH protect, constant("The Patient ZIP is Missing.")
  DECLARE err_hospzip = vc WITH protect, constant("The Hospital ZIP is Missing.")
  DECLARE err_hospstate = vc WITH protect, constant("The Hospital State is Missing.")
  DECLARE cs_name_type = i4 WITH protect, constant(213)
  DECLARE cs_alias_type = i4 WITH protect, constant(4)
  DECLARE cs_contributor = i4 WITH protect, constant(73)
  DECLARE cs_alias_pool = i4 WITH protect, constant(263)
  DECLARE cs_prsnl_group_type = i4 WITH protect, constant(19189)
  DECLARE cs_cv_status_message = i4 WITH protect, constant(25973)
  DECLARE cs_cv_task_assay = i4 WITH protect, constant(14003)
  DECLARE cs_cv_address_type = i4 WITH protect, constant(212)
  DECLARE cs_name_type_docupin = i4 WITH protect, constant(320)
  DECLARE csm_field_type_stspatid = vc WITH protect, constant("STSPATID")
  DECLARE csm_name_type_current = vc WITH protect, constant("CURRENT")
  DECLARE csm_alias_type_ssn = vc WITH protect, constant("SSN")
  DECLARE csm_alias_type_mrn = vc WITH protect, constant("MRN")
  DECLARE csm_field_type_numeric = vc WITH protect, constant("NUMERIC")
  DECLARE csm_field_type_lname = vc WITH protect, constant("PLNAME")
  DECLARE csm_field_type_fname = vc WITH protect, constant("PFNAME")
  DECLARE csm_field_type_mname = vc WITH protect, constant("PMNAME")
  DECLARE csm_field_type_hosp = vc WITH protect, constant("EHOSP")
  DECLARE csm_field_type_part_nbr = vc WITH protect, constant("EPARTNBR")
  DECLARE csm_field_type_birth_date = vc WITH protect, constant("PBTHDATE")
  DECLARE csm_field_type_sex = vc WITH protect, constant("PSEXCD")
  DECLARE csm_field_type_ssn = vc WITH protect, constant("PSSN")
  DECLARE csm_field_type_ssn_cc = vc WITH protect, constant("PSSNCC")
  DECLARE csm_field_type_prsnl_ssn = vc WITH protect, constant("PRSNLSSN")
  DECLARE csm_field_type_regdate = vc WITH protect, constant("EREGDATE")
  DECLARE csm_field_type_dischdate = vc WITH protect, constant("EDISCHDATE")
  DECLARE csm_field_type_link = vc WITH protect, constant("PROCLINK")
  DECLARE csm_field_type_race = vc WITH protect, constant("PRACECD")
  DECLARE csm_field_type_constant = vc WITH protect, constant("CONSTANT")
  DECLARE csm_field_type_patientid = vc WITH protect, constant("PPATIENTID")
  DECLARE csm_field_type_patientage = vc WITH protect, constant("PATIENTAGE")
  DECLARE csm_field_type_recordid = vc WITH protect, constant("CRECORDID")
  DECLARE csm_field_type_mrn = vc WITH protect, constant("PMRN")
  DECLARE csm_field_type_patientzip = vc WITH protect, constant("APATIENTZIP")
  DECLARE csm_field_type_hospzip = vc WITH protect, constant("AHOSPZIP")
  DECLARE csm_field_type_hospstate = vc WITH protect, constant("AHOSPSTATE")
  DECLARE csm_field_type_reccomp = vc WITH protect, constant("XRECCOMP")
  DECLARE csm_field_type_devused = vc WITH protect, constant("DDEVICEUSED")
  DECLARE csm_field_type_primdevind = vc WITH protect, constant("DPRIMDEVIND")
  DECLARE csm_field_type_transnum = vc WITH protect, constant("TTRANSNUM")
  DECLARE csm_task_assay_surgeon = vc WITH protect, constant("ST01SURGEON")
  DECLARE csm_task_assay_surggrp = vc WITH protect, constant("ST01SURGGRP")
  DECLARE csm_prsnl_group_type_sts = vc WITH protect, constant("CVNET_STS_PA")
  DECLARE csm_cv_stat_msg_reportwarn = vc WITH protect, constant("REPORTWARN")
  DECLARE csm_cv_stat_msg_error = vc WITH protect, constant("ERROR")
  DECLARE csm_cv_stat_msg_harvnoerror = vc WITH protect, constant("HARVNOERROR")
  DECLARE csm_cv_stat_msg_warning = vc WITH protect, constant("WARNING")
  DECLARE csm_alias_pool_accfa = vc WITH protect, constant("CVNET_ACC_FA")
  DECLARE csm_alias_pool_stsfa = vc WITH protect, constant("CVNET_STS_PA")
  DECLARE csm_field_type_prsnl_upin = vc WITH protect, constant("PRSNLUPIN")
  DECLARE csm_name_type_docupin = vc WITH protect, constant("DOCUPIN")
  DECLARE csd_contributor_cvnet = vc WITH protect, constant("CVNET")
  DECLARE str_prsnlgrp_delimstr = vc WITH protect, constant("___")
  DECLARE acc02_max_dev_count = i4 WITH protect, constant(20)
  DECLARE required_flag_reportwarn_code = i4 WITH protect, constant(30)
  DECLARE required_flag_error_code = i4 WITH protect, constant(20)
  DECLARE required_flag_warning_code = i4 WITH protect, constant(10)
  DECLARE required_flag_dontcare_code = i4 WITH protect, constant(0)
  DECLARE required_flag_reportwarn_str = vc WITH protect, constant("REPORTWARN")
  DECLARE required_flag_error_str = vc WITH protect, constant("ERROR")
  DECLARE required_flag_warning_str = vc WITH protect, constant("WARNING")
  DECLARE required_flag_dontcare_str = vc WITH protect, constant("DONTCARE")
  DECLARE cv_stat_ignore_valid_chk_err = i4 WITH protect, constant(2)
  DECLARE cv_stat_date_err = i4 WITH protect, constant(5)
  DECLARE cv_stat_ignore_valid_chk_val = i4 WITH protect, constant(6)
  DECLARE cv_stat_reportwarn = i4 WITH protect, constant(7)
  DECLARE search_file_raw = vc WITH protect, constant("_RAW")
 ENDIF
 IF (validate(c_status_error)=0)
  DECLARE c_status_noerror = f8 WITH protect, constant(uar_get_code_by("MEANING",25973,"NOERROR"))
  DECLARE c_status_harvnoerror = f8 WITH protect, constant(uar_get_code_by("MEANING",25973,
    "HARVNOERROR"))
  DECLARE c_status_warning = f8 WITH protect, constant(uar_get_code_by("MEANING",25973,"WARNING"))
  DECLARE c_status_reportwarn = f8 WITH protect, constant(uar_get_code_by("MEANING",25973,
    "REPORTWARN"))
  DECLARE c_status_error = f8 WITH protect, constant(uar_get_code_by("MEANING",25973,"ERROR"))
 ENDIF
 DECLARE clos_dev_lesion = f8 WITH protect
 DECLARE reqd_str = vc WITH protect
 DECLARE loc = i4 WITH protect
 DECLARE stal = i4 WITH protect
 DECLARE star = i4 WITH protect
 DECLARE formatreqdflagstr(reqd_flag=i4) = null
 SUBROUTINE formatreqdflagstr(reqd_flag)
   CASE (reqd_flag)
    OF required_flag_reportwarn_code:
     SET reqd_str = required_flag_reportwarn_str
    OF required_flag_error_code:
     SET reqd_str = required_flag_error_str
    OF required_flag_warning_code:
     SET reqd_str = required_flag_warning_str
    OF required_flag_dontcare_code:
     SET reqd_str = required_flag_dontcare_str
   ENDCASE
 END ;Subroutine
 DECLARE findsubstringbyrecurcnt(soustr=vc,seastr=vc,retstr_l=vc,retstr_r=vc,reccnt=i4) = null
 SUBROUTINE findsubstringbyrecurcnt(soustr,seastr,retstr_l,retstr_r,reccnt)
   SET loc = 1
   WHILE (reccnt > 0)
     SET loc = findstring(seastr,soustr,loc)
     CALL echo(build("loc: ",loc))
     SET reccnt = (reccnt - 1)
   ENDWHILE
   SET stal = movestring(substring(1,loc,soustr),1,retstr_l,1,loc)
   SET star = movestring(substring((loc+ 1),(size(soustr,1) - loc),soustr),(loc+ 1),retstr_r,1,(size(
     soustr,1) - loc))
 END ;Subroutine
 IF (validate(reply,"notdefined") != "notdefined")
  CALL echo("Reply Record is already defined!")
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
 IF (validate(cv_case_dataset_r_id,0.0) != 0.0)
  CALL cv_log_message("cv_case_dataset_r_id is already defined!")
 ELSE
  DECLARE cv_case_dataset_r_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 DECLARE sfailure = c1 WITH protect, noconstant("F")
 DECLARE del_flag = i2 WITH protect, noconstant(0)
 CALL echorecord(cv_omf_rec,"cer_temp:cv_omf_rec_bf.dat")
 DECLARE registry_nbr = f8 WITH noconstant(0.0), protect
 IF ((cv_omf_rec->form_event_id >= 0.0))
  SELECT INTO "NL:"
   cc.cv_case_id
   FROM cv_case cc
   WHERE (cc.form_event_id=cv_omf_rec->form_event_id)
    AND cc.form_event_id != 0.0
   DETAIL
    cv_omf_rec->case_id = cc.cv_case_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("No such case in cv_case table!")
  ELSE
   SET del_flag = 1
  ENDIF
  CALL echo(build("case id is here",cv_omf_rec->case_id))
  SELECT INTO "NL:"
   ccdr.case_dataset_r_id
   FROM cv_case_dataset_r ccdr
   WHERE (ccdr.cv_case_id=cv_omf_rec->case_id)
    AND ccdr.cv_case_id != 0.0
   DETAIL
    cv_case_dataset_r_id = ccdr.case_dataset_r_id, registry_nbr = ccdr.registry_nbr
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("No such case in cv_case_dataset_r table!")
  ELSE
   CALL echo(build("Previous case_dataset_r_id::",cv_case_dataset_r_id))
  ENDIF
 ELSE
  SET del_flag = 0
  SET cv_case_dataset_r_id = 0.0
  SET registry_nbr = - (cv_omf_rec->form_event_id)
 ENDIF
 DECLARE acc_ind = f8 WITH protect, noconstant(0.0)
 DECLARE registry_version = i4 WITH protect, noconstant(0)
 DECLARE call_calc = i2 WITH protect, noconstant(0)
 DECLARE accv3_ind = i2 WITH noconstant(0)
 SET call_calc = getcvcontrol(cv_omf_rec->dataset[1].dataset_id,"CV_FLAG_CTRL_ACC_OR_STS_ETC")
 IF (call_calc=1)
  SET registry_version = getcvcontrol(cv_omf_rec->dataset[1].dataset_id,"REGISTRY_VERSION")
  IF (registry_version >= 3)
   SET accv3_ind = 1
   CALL echo("Setting ACC v3 indicator")
  ENDIF
  SET acc_ind = cv_omf_rec->dataset[1].dataset_id
  IF (accv3_ind=0)
   EXECUTE cv_del_summary_calc_data
  ENDIF
 ENDIF
 IF (del_flag=1)
  EXECUTE cv_utl_del_summary_data cv_omf_rec->case_id
  CALL cv_log_message("Finished deleting existing case data")
 ENDIF
 IF ((cv_omf_rec->case_id=0.0))
  SELECT INTO "nl:"
   nextseqnum = seq(card_vas_seq,nextval)
   FROM dual
   DETAIL
    cv_omf_rec->case_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET sfailure = "T"
   SET cv_log_level = cv_log_debug
   CALL cv_log_message("Failed in creating cv_case_id from the dual table")
   GO TO commit_rollback_script
  ENDIF
 ENDIF
 IF (cv_case_dataset_r_id=0.0)
  SELECT INTO "nl:"
   nextseqnum = seq(card_vas_seq,nextval)
   FROM dual
   DETAIL
    cv_case_dataset_r_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET sfailure = "T"
   CALL cv_log_message("Failed in creating case_dataset_r_id from the dual table")
   GO TO commit_rollback_script
  ENDIF
  IF (registry_nbr=0.0)
   SET registry_nbr = cv_case_dataset_r_id
  ENDIF
 ENDIF
 DECLARE proc_cnt = i4 WITH protect, noconstant(size(cv_omf_rec->proc_data,5))
 FOR (proc_nbr = 1 TO proc_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(card_vas_seq,nextval)
    FROM dual
    DETAIL
     cv_omf_rec->proc_data[proc_nbr].procedure_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_message("Failed in creating procedure_id from dual table")
   ENDIF
   FOR (lesion_nbr = 1 TO size(cv_omf_rec->proc_data[proc_nbr].lesion,5))
     SELECT INTO "nl:"
      nextseqnum = seq(card_vas_seq,nextval)
      FROM dual
      DETAIL
       cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].lesion_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET cv_log_level = cv_log_debug
      CALL cv_log_message("Failed in creating lesion_id from dual table")
     ENDIF
     FOR (device_nbr = 1 TO size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice,5))
      SELECT INTO "nl:"
       nextseqnum = seq(card_vas_seq,nextval)
       FROM dual
       DETAIL
        cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].icdevice[device_nbr].device_id =
        nextseqnum
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       SET cv_log_level = cv_log_debug
       CALL cv_log_message("Failed in creating IC device_id from dual table")
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 DECLARE closdevice_cnt = i4 WITH protect, noconstant(size(cv_omf_rec->closuredevice,5))
 FOR (closdevice_nbr = 1 TO closdevice_cnt)
  SELECT INTO "nl:"
   nextseqnum = seq(card_vas_seq,nextval)
   FROM dual
   DETAIL
    cv_omf_rec->closuredevice[closdevice_nbr].device_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message("Failed in creating Closure device_id from dual table")
  ENDIF
 ENDFOR
 EXECUTE cv_summary_data_handle_routine
 EXECUTE cv_get_dataset_part_nbr
 EXECUTE cv_get_dataset_part_nbr
 IF ((cv_omf_rec->form_event_id < 0.0))
  CALL cv_log_message(concat("Imported case: RecordID =",cnvtstring(registry_nbr)))
  SELECT INTO "nl:"
   FROM cv_case_dataset_r ccdr,
    cv_dataset d,
    cv_dataset d2
   PLAN (ccdr
    WHERE ccdr.registry_nbr=registry_nbr
     AND (ccdr.participant_nbr=cv_omf_rec->dataset[1].participant_nbr))
    JOIN (d
    WHERE d.dataset_id=ccdr.dataset_id)
    JOIN (d2
    WHERE (d2.dataset_id=cv_omf_rec->dataset[1].dataset_id)
     AND d2.alias_pool_mean=d.alias_pool_mean)
   DETAIL
    CALL cv_log_message(build("Imported case has registry_nbr collision")),
    CALL cv_log_message(build("alias_pool:",d2.alias_pool_mean)),
    CALL cv_log_message(build("participant_nbr:",ccdr.participant_nbr)),
    CALL cv_log_message(build("registy_nbr:",ccdr.registry_nbr)),
    CALL cv_log_message(build("Existing case_dataset_r_id:",ccdr.case_dataset_r_id))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET sfailure = "T"
   GO TO commit_rollback_script
  ENDIF
 ENDIF
 SET cv_omf_rec->num_proc = size(cv_omf_rec->proc_data,5)
 FOR (i = 1 TO cv_omf_rec->num_proc)
   SET cv_omf_rec->proc_data[i].num_lesion = size(cv_omf_rec->proc_data[i].lesion,5)
 ENDFOR
 INSERT  FROM cv_case cc
  SET cc.cv_case_id = cv_omf_rec->case_id, cc.form_event_id = cv_omf_rec->form_event_id, cc.num_proc
    = cv_omf_rec->num_proc,
   cc.person_id = cv_omf_rec->person_id, cc.encntr_id = cv_omf_rec->encntr_id, cc.patient_type_cd =
   cv_omf_rec->patient_type_cd,
   cc.age =
   IF ((cv_omf_rec->age_year >= 0)) cv_omf_rec->age_year
   ELSE null
   ENDIF
   , cc.age_group_cd = cv_omf_rec->age_group_cd, cc.sex_cd = cv_omf_rec->sex_cd,
   cc.hospital_cd = cv_omf_rec->hospital_cd, cc.admt_dt_nbr = cv_omf_rec->admt_dt_num, cc
   .disch_dt_nbr = cv_omf_rec->disch_dt_num,
   cc.proc_dt_nbr = cv_omf_rec->proc_dt_num, cc.pat_adm_dt_tm = cnvtdatetime(cv_omf_rec->admit_dt_tm),
   cc.pat_disch_dt_tm = cnvtdatetime(cv_omf_rec->disch_dt_tm),
   cc.los_adm_disch = cv_omf_rec->los_adm_disch, cc.los_adm_proc = cv_omf_rec->los_adm_proc, cc
   .los_proc_disch = cv_omf_rec->los_proc_disch,
   cc.pat_adm_ind = cv_omf_rec->admit_ind, cc.pat_disch_ind = cv_omf_rec->disch_ind, cc.form_id =
   cv_omf_rec->form_id,
   cc.chart_dt_tm = cnvtdatetime(cv_omf_rec->chart_dt_tm), cc.active_ind = 1, cc.active_status_dt_tm
    = cnvtdatetime(curdate,curtime3),
   cc.active_status_cd = reqdata->active_status_cd, cc.death_ind = cv_omf_rec->death_ind, cc
   .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cc.end_effective_dt_tm = cnvtdatetime(null_date), cc.data_status_cd = reqdata->data_status_cd, cc
   .data_status_prsnl_id = cv_omf_rec->updt_id,
   cc.active_status_prsnl_id = cv_omf_rec->updt_id, cc.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cc.updt_task = reqinfo->updt_task, cc.updt_app = reqinfo->updt_app, cc.updt_applctx = reqinfo->
   updt_applctx,
   cc.updt_cnt = 0, cc.updt_req = reqinfo->updt_req, cc.updt_id = cv_omf_rec->updt_id,
   cc.form_type_cd = cv_omf_rec->form_type_cd, cc.case_dt_tm = cnvtdatetime(cv_omf_rec->case_dt_tm)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_message("No case fields were inserted into cv_case table!")
  SET sfailure = "T"
  GO TO commit_rollback_script
 ENDIF
 INSERT  FROM cv_case_dataset_r ccdr,
   (dummyt d  WITH seq = value(size(cv_omf_rec->dataset,5)))
  SET ccdr.case_dataset_r_id = cv_case_dataset_r_id, ccdr.registry_nbr = registry_nbr, ccdr
   .cv_case_id = cv_omf_rec->case_id,
   ccdr.dataset_id = cv_omf_rec->dataset[d.seq].dataset_id, ccdr.participant_nbr = cv_omf_rec->
   dataset[d.seq].participant_nbr, ccdr.status_cd = 0.0,
   ccdr.active_ind = 1, ccdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccdr
   .active_status_cd = reqdata->active_status_cd,
   ccdr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ccdr.end_effective_dt_tm = cnvtdatetime
   (null_date), ccdr.data_status_cd = reqdata->data_status_cd,
   ccdr.data_status_prsnl_id = cv_omf_rec->updt_id, ccdr.active_status_prsnl_id = cv_omf_rec->updt_id,
   ccdr.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   ccdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ccdr.updt_task = reqinfo->updt_task, ccdr
   .updt_app = reqinfo->updt_app,
   ccdr.updt_applctx = reqinfo->updt_applctx, ccdr.updt_cnt = 0, ccdr.updt_req = reqinfo->updt_req,
   ccdr.updt_id = cv_omf_rec->updt_id
  PLAN (d)
   JOIN (ccdr)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_message(concat("Failed in insert cv_case_dataset_r table, ","program continue!"))
 ENDIF
 INSERT  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_omf_rec->case_abstr_data,5)))
  SET ccad.case_abstr_data_id = seq(card_vas_seq,nextval), ccad.cv_case_id = cv_omf_rec->case_id,
   ccad.event_cd = cv_omf_rec->case_abstr_data[d.seq].event_cd,
   ccad.nomenclature_id = cv_omf_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_id =
   cv_omf_rec->case_abstr_data[d.seq].result_id, ccad.event_id = cv_omf_rec->case_abstr_data[d.seq].
   event_id,
   ccad.result_val = cv_omf_rec->case_abstr_data[d.seq].result_val, ccad.result_dt_tm = cnvtdatetime(
    cv_omf_rec->case_abstr_data[d.seq].result_dt_tm), ccad.active_ind = 1,
   ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
   active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
   ccad.data_status_prsnl_id = cv_omf_rec->updt_id,
   ccad.active_status_prsnl_id = cv_omf_rec->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
   reqinfo->updt_applctx,
   ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = cv_omf_rec->updt_id
  PLAN (d)
   JOIN (ccad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_message(concat("failed in insert cv_case_abstr_data table, ","program continue!"))
 ENDIF
 IF (proc_cnt > 0)
  INSERT  FROM cv_procedure cp,
    (dummyt d  WITH seq = value(size(cv_omf_rec->proc_data,5)))
   SET cp.procedure_id = cv_omf_rec->proc_data[d.seq].procedure_id, cp.cv_case_id = cv_omf_rec->
    proc_data[d.seq].case_id, cp.event_type_cd = cv_omf_rec->proc_data[d.seq].event_type_cd,
    cp.proc_physic_id = cv_omf_rec->proc_data[d.seq].proc_physician_id, cp.proc_start_dt_tm =
    cnvtdatetime(cv_omf_rec->proc_data[d.seq].proc_start_dt_tm), cp.proc_end_dt_tm = cnvtdatetime(
     cv_omf_rec->proc_data[d.seq].proc_end_dt_tm),
    cp.proc_dur_min = cv_omf_rec->proc_data[d.seq].proc_dur_min, cp.proc_start_mnth = cv_omf_rec->
    proc_data[d.seq].proc_start_month, cp.proc_start_day = cv_omf_rec->proc_data[d.seq].
    proc_start_day,
    cp.proc_start_hour = cv_omf_rec->proc_data[d.seq].proc_start_hour, cp.proc_complete_ind =
    cv_omf_rec->proc_data[d.seq].proc_complete_ind, cp.los_adm_proc = cv_omf_rec->proc_data[d.seq].
    los_adm_proc,
    cp.los_proc_disch = cv_omf_rec->proc_data[d.seq].los_proc_disch, cp.num_lesion = cv_omf_rec->
    proc_data[d.seq].num_lesion, cp.active_ind = 1,
    cp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cp.active_status_cd = reqdata->
    active_status_cd, cp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    cp.end_effective_dt_tm = cnvtdatetime(null_date), cp.data_status_cd = reqdata->data_status_cd, cp
    .data_status_prsnl_id = cv_omf_rec->updt_id,
    cp.active_status_prsnl_id = cv_omf_rec->updt_id, cp.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), cp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cp.updt_task = reqinfo->updt_task, cp.updt_app = reqinfo->updt_app, cp.updt_applctx = reqinfo->
    updt_applctx,
    cp.updt_cnt = 0, cp.updt_req = reqinfo->updt_req, cp.updt_id = cv_omf_rec->updt_id
   PLAN (d
    WHERE (cv_omf_rec->proc_data[d.seq].procedure_id > 0.0))
    JOIN (cp)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message(concat("Failed in insert cv_procedure table, ","program continue!"))
  ENDIF
  IF ((cv_omf_rec->max_proc_abstr > 0))
   INSERT  FROM cv_proc_abstr_data cpad,
     (dummyt d1  WITH seq = value(proc_cnt)),
     (dummyt d2  WITH seq = value(cv_omf_rec->max_proc_abstr))
    SET cpad.proc_abstr_data_id = seq(card_vas_seq,nextval), cpad.procedure_id = cv_omf_rec->
     proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id, cpad.event_cd = cv_omf_rec->proc_data[d1
     .seq].proc_abstr_data[d2.seq].event_cd,
     cpad.nomenclature_id = cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].nomenclature_id,
     cpad.result_id = cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_id, cpad.event_id
      = cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].event_id,
     cpad.result_val = cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_val, cpad
     .result_dt_tm = cnvtdatetime(cv_omf_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_dt_tm),
     cpad.active_ind = 1,
     cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
     active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->
     data_status_cd, cpad.data_status_prsnl_id = cv_omf_rec->updt_id,
     cpad.active_status_prsnl_id = cv_omf_rec->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
      curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
     reqinfo->updt_applctx,
     cpad.updt_cnt = 0, cpad.updt_req = reqinfo->updt_req, cpad.updt_id = cv_omf_rec->updt_id
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].proc_abstr_data,5))
     JOIN (cpad)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_message(concat("Failed in insert cv_proc_abstr_data table, ","program continue!"))
   ENDIF
  ELSE
   CALL cv_log_message("No items to insert in cv_proc_abstr_data table")
  ENDIF
  IF ((cv_omf_rec->max_lesion > 0))
   INSERT  FROM cv_lesion cl,
     (dummyt d1  WITH seq = value(proc_cnt)),
     (dummyt d2  WITH seq = value(cv_omf_rec->max_lesion))
    SET cl.lesion_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id, cl.procedure_id =
     cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].procedure_id, cl.parent_event_id = cv_omf_rec->
     proc_data[d1.seq].lesion[d2.seq].parent_event_id,
     cl.active_ind = 1, cl.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cl.active_status_cd
      = reqdata->active_status_cd,
     cl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cl.end_effective_dt_tm = cnvtdatetime(
      null_date), cl.data_status_cd = reqdata->data_status_cd,
     cl.data_status_prsnl_id = cv_omf_rec->updt_id, cl.active_status_prsnl_id = cv_omf_rec->updt_id,
     cl.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     cl.updt_dt_tm = cnvtdatetime(curdate,curtime3), cl.updt_task = reqinfo->updt_task, cl.updt_app
      = reqinfo->updt_app,
     cl.updt_applctx = reqinfo->updt_applctx, cl.updt_cnt = 0, cl.updt_req = reqinfo->updt_req,
     cl.updt_id = cv_omf_rec->updt_id
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion,5))
     JOIN (cl)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_message("Failed in insert cv_lesion table, program continue!")
   ENDIF
   IF ((cv_omf_rec->max_lesion_abstr > 0))
    INSERT  FROM cv_les_abstr_data clad,
      (dummyt d1  WITH seq = value(proc_cnt)),
      (dummyt d2  WITH seq = value(cv_omf_rec->max_lesion)),
      (dummyt d3  WITH seq = value(cv_omf_rec->max_lesion_abstr))
     SET clad.les_abstr_data_id = seq(card_vas_seq,nextval), clad.lesion_id = cv_omf_rec->proc_data[
      d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].lesion_id, clad.event_type_cd = cv_omf_rec->
      proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_type_cd,
      clad.event_cd = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_cd,
      clad.nomenclature_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].
      nomenclature_id, clad.result_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[
      d3.seq].result_id,
      clad.event_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_id,
      clad.result_val = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].
      result_val, clad.result_dt_tm = cnvtdatetime(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].
       les_abstr_data[d3.seq].result_dt_tm),
      clad.active_ind = 1, clad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clad
      .active_status_cd = reqdata->active_status_cd,
      clad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), clad.end_effective_dt_tm =
      cnvtdatetime(null_date), clad.data_status_cd = reqdata->data_status_cd,
      clad.data_status_prsnl_id = cv_omf_rec->updt_id, clad.active_status_prsnl_id = cv_omf_rec->
      updt_id, clad.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      clad.updt_dt_tm = cnvtdatetime(curdate,curtime3), clad.updt_task = reqinfo->updt_task, clad
      .updt_app = reqinfo->updt_app,
      clad.updt_applctx = reqinfo->updt_applctx, clad.updt_cnt = 0, clad.updt_req = reqinfo->updt_req,
      clad.updt_id = cv_omf_rec->updt_id
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion,5))
      JOIN (d3
      WHERE d3.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5)
       AND (cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_cd > 0.0))
      JOIN (clad)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET cv_log_level = cv_log_debug
     CALL cv_log_message(concat("Failed in insert cv_les_abstr_data table, ","program continue!"))
    ENDIF
   ELSE
    CALL cv_log_message("No items to insert into cv_les_abstr_data table")
   ENDIF
   IF ((cv_omf_rec->max_icdev > 0))
    INSERT  FROM cv_device cdev,
      (dummyt d1  WITH seq = value(proc_cnt)),
      (dummyt d2  WITH seq = value(cv_omf_rec->max_lesion)),
      (dummyt d3  WITH seq = value(cv_omf_rec->max_icdev))
     SET cdev.device_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].device_id,
      cdev.lesion_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id, cdev.parent_event_id
       = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].parent_event_id,
      cdev.cv_case_id = 0.0, cdev.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cdev
      .end_effective_dt_tm = cnvtdatetime(null_date),
      cdev.updt_id = cv_omf_rec->updt_id, cdev.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdev
      .updt_task = reqinfo->updt_task,
      cdev.updt_applctx = reqinfo->updt_applctx, cdev.updt_cnt = 0, cdev.active_ind = 1,
      cdev.active_status_cd = reqdata->active_status_cd, cdev.active_status_prsnl_id = cv_omf_rec->
      updt_id, cdev.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion,5))
      JOIN (d3
      WHERE d3.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice,5))
      JOIN (cdev)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET cv_log_level = cv_log_debug
     CALL cv_log_message(concat("Failed in insert ic device records in ",
       "cv_device table, program continue!"))
    ENDIF
    IF ((cv_omf_rec->max_icdev_abstr > 0))
     INSERT  FROM cv_dev_abstr_data cdad,
       (dummyt d1  WITH seq = value(proc_cnt)),
       (dummyt d2  WITH seq = value(cv_omf_rec->max_lesion)),
       (dummyt d3  WITH seq = value(cv_omf_rec->max_icdev)),
       (dummyt d4  WITH seq = value(cv_omf_rec->max_icdev_abstr))
      SET cdad.dev_abstr_data_id = seq(card_vas_seq,nextval), cdad.device_id = cv_omf_rec->proc_data[
       d1.seq].lesion[d2.seq].icdevice[d3.seq].device_id, cdad.event_cd = cv_omf_rec->proc_data[d1
       .seq].lesion[d2.seq].icdevice[d3.seq].icd_abstr_data[d4.seq].event_cd,
       cdad.result_val = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].
       icd_abstr_data[d4.seq].result_val, cdad.result_dt_tm = cnvtdatetime(cv_omf_rec->proc_data[d1
        .seq].lesion[d2.seq].icdevice[d3.seq].icd_abstr_data[d4.seq].result_dt_tm), cdad.result_id =
       cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].icd_abstr_data[d4.seq].result_id,
       cdad.nomenclature_id = cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].
       icd_abstr_data[d4.seq].nomenclature_id, cdad.event_type_cd = cv_omf_rec->proc_data[d1.seq].
       lesion[d2.seq].icdevice[d3.seq].icd_abstr_data[d4.seq].event_type_cd, cdad.event_id =
       cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].icd_abstr_data[d4.seq].event_id,
       cdad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cdad.end_effective_dt_tm =
       cnvtdatetime(null_date), cdad.updt_id = cv_omf_rec->updt_id,
       cdad.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdad.updt_task = reqinfo->updt_task, cdad
       .updt_applctx = reqinfo->updt_applctx,
       cdad.updt_cnt = 0, cdad.active_ind = 1, cdad.active_status_cd = reqdata->active_status_cd,
       cdad.active_status_prsnl_id = cv_omf_rec->updt_id, cdad.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3)
      PLAN (d1)
       JOIN (d2
       WHERE d2.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion,5))
       JOIN (d3
       WHERE d3.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice,5))
       JOIN (d4
       WHERE d4.seq <= size(cv_omf_rec->proc_data[d1.seq].lesion[d2.seq].icdevice[d3.seq].
        icd_abstr_data,5))
       JOIN (cdad)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET cv_log_level = cv_log_debug
      CALL cv_log_message(concat("Failed to insert ic devices into ",
        "cv_dev_abstr_data table, program continue!"))
     ENDIF
    ELSE
     CALL cv_log_message("No items to insert into cv_dev_abstr_data table")
    ENDIF
   ELSE
    CALL cv_log_message("No items to insert into cv_device table")
   ENDIF
  ELSE
   CALL cv_log_message("No items to insert into cv_lesion table")
  ENDIF
 ENDIF
 IF (size(cv_omf_rec->closuredevice,5) > 0)
  INSERT  FROM cv_device cdev,
    (dummyt d3  WITH seq = value(size(cv_omf_rec->closuredevice,5)))
   SET cdev.device_id = cv_omf_rec->closuredevice[d3.seq].device_id, cdev.lesion_id = clos_dev_lesion,
    cdev.cv_case_id = cv_omf_rec->case_id,
    cdev.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cdev.end_effective_dt_tm =
    cnvtdatetime(null_date), cdev.updt_id = cv_omf_rec->updt_id,
    cdev.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdev.updt_task = reqinfo->updt_task, cdev
    .updt_applctx = reqinfo->updt_applctx,
    cdev.updt_cnt = 0, cdev.active_ind = 1, cdev.active_status_cd = reqdata->active_status_cd,
    cdev.active_status_prsnl_id = cv_omf_rec->updt_id, cdev.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3), cdev.parent_event_id = cv_omf_rec->closuredevice[d3.seq].parent_event_id
   PLAN (d3
    WHERE d3.seq <= size(cv_omf_rec->closuredevice,5))
    JOIN (cdev)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message(concat("Failed in insert closure_device records in ",
     " cv_device table, program continue!"))
  ENDIF
  INSERT  FROM cv_dev_abstr_data cdad,
    (dummyt d3  WITH seq = value(size(cv_omf_rec->closuredevice,5))),
    (dummyt d4  WITH seq = value(cv_omf_rec->max_closdev_abstr))
   SET cdad.dev_abstr_data_id = seq(card_vas_seq,nextval), cdad.device_id = cv_omf_rec->
    closuredevice[d3.seq].device_id, cdad.event_cd = cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[
    d4.seq].event_cd,
    cdad.result_val = cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[d4.seq].result_val, cdad
    .result_dt_tm = cnvtdatetime(cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[d4.seq].result_dt_tm
     ), cdad.result_id = cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[d4.seq].result_id,
    cdad.nomenclature_id = cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[d4.seq].nomenclature_id,
    cdad.event_type_cd = cv_omf_rec->closuredevice[d3.seq].cd_abstr_data[d4.seq].event_type_cd, cdad
    .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    cdad.end_effective_dt_tm = cnvtdatetime(null_date), cdad.updt_id = cv_omf_rec->updt_id, cdad
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cdad.updt_task = reqinfo->updt_task, cdad.updt_applctx = reqinfo->updt_applctx, cdad.updt_cnt = 0,
    cdad.active_ind = 1, cdad.active_status_cd = reqdata->active_status_cd, cdad
    .active_status_prsnl_id = cv_omf_rec->updt_id,
    cdad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cdad.event_id = cv_omf_rec->
    closuredevice[d3.seq].cd_abstr_data[d4.seq].event_id
   PLAN (d3)
    JOIN (d4
    WHERE d4.seq <= size(cv_omf_rec->closuredevice[d3.seq].cd_abstr_data,5))
    JOIN (cdad)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message(concat("Failed to insert closure devices into ",
     " cv_dev_abstr_data table, program continue!"))
  ENDIF
 ENDIF
 CALL echorecord(cv_omf_rec,"cer_temp:cv_omf_rec_af.dat")
#commit_rollback_script
 IF (sfailure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL cv_log_message(build("Rolling back Changes due to sum_failure = T: ",curprog))
  SET reply->status_data.subeventstatus[1].operationname = "Insert-Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_ins_updt_summary_data"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].operationname = "Insert-Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_ins_updt_summary_data"
  IF (validate(cv_call_by_client,0)=0)
   SET reqinfo->commit_ind = 1
   CALL cv_log_message(build("Commited at: ",curprog))
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
   CALL cv_log_message(build("Rolling at: ",curprog))
   ROLLBACK
  ENDIF
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,cv_omf_rec)
 SET stat = alterlist(cv_hrv_rec->harvest_rec,1)
 IF (acc_ind > 0)
  IF (accv3_ind=0)
   EXECUTE cv_get_summary_calc_data
   EXECUTE cv_chg_dt_tm_format
  ENDIF
  SET cv_hrv_rec->harvest_rec[1].case_id = 0.0
  SET cv_hrv_rec->harvest_rec[1].encntr_id = cv_omf_rec->encntr_id
  CALL echo(build("setting harvest encntr_id===>",cv_hrv_rec->harvest_rec[1].encntr_id))
 ELSE
  SET cv_hrv_rec->harvest_rec[1].case_id = cv_omf_rec->case_id
  SET cv_hrv_rec->harvest_rec[1].encntr_id = 0.0
  CALL echo(build("setting harvest case_id===>",cv_hrv_rec->harvest_rec[1].case_id))
 ENDIF
 IF (validate(exit_after,"0") != "CV_INSERT_SUMMARY_DATA")
  IF (accv3_ind=1)
   EXECUTE cv_get_harvest_person cv_omf_rec->person_id, cv_omf_rec->dataset[1].dataset_id
  ELSE
   FOR (n = 1 TO size(cv_omf_rec->dataset,5))
     SET cv_hrv_rec->harvest_rec[1].dataset_id = cv_omf_rec->dataset[n].dataset_id
     EXECUTE cv_get_harvest
     CALL cv_log_message("cv_inst.. executed cv_get_harvest!!")
   ENDFOR
  ENDIF
 ELSE
  CALL cv_log_message("exit_after set to CV_INSERT_SUMMARY_DATA")
  CALL echo("exit_after set to CV_INSERT_SUMMARY_DATA")
 ENDIF
 EXECUTE cv_ins_updt_summary_count
 CALL cv_log_message("cv_ins_updt_summary_count is executed!!")
#exit_script
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
 DECLARE cv_insert_summary_data_vrsn = vc WITH private, constant("MOD 020 03/23/06 BM9013")
END GO
