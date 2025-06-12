CREATE PROGRAM cv_get_harvest_output:dba
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
 DECLARE formsubstringbyrecurcnt(source_str_param=vc,search_str_param=vc,rec_cnt_str_param=i4,
  ins_str_param=vc) = vc
 DECLARE formsubstringbyrecurcnt_new(source_str_param=vc,search_str_param=vc,ins_str_param=vc) = vc
 DECLARE formatdecimal(paramval=vc,paramformat=vc) = vc
 DECLARE addstringtomessage(addstring=vc) = null
 DECLARE createlogforstatus(param_status=c12,param_status_disp=vc,param_case_idx=i4) = null
 CALL echo(build("Start output:",curtime3))
 IF ( NOT (validate(reply,0)))
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
 IF ( NOT (validate(cv_dn_msg,0)))
  RECORD cv_dn_msg(
    1 statuses[*]
      2 meaning = c12
      2 display = vc
    1 msgs[*]
      2 msg = vc
  )
 ELSE
  CALL cv_log_message("cv_dn_msg was already defined!")
 ENDIF
 IF ( NOT (validate(cv_lesion_succ,0)))
  RECORD cv_lesion_succ(
    1 rec[*]
      2 lesion[*]
        3 status = i2
  )
 ELSE
  CALL cv_log_message("cv_lesion_succ was already defined")
 ENDIF
 IF ( NOT (validate(cv_dev_msgs,0)))
  RECORD cv_dev_msgs(
    1 case_num = i2
    1 case_err[*]
      2 msg = vc
  )
 ELSE
  CALL cv_log_message("cv_dev_msgs was already defined")
 ENDIF
 FREE RECORD output_fields
 RECORD output_fields(
   1 qual[*]
     2 value = vc
 )
 DECLARE max_dn_msg_size = i4 WITH protect, constant(20000)
 DECLARE current_dn_msg = i4 WITH protect, noconstant(1)
 DECLARE name_last = vc WITH protect
 DECLARE name_first = vc WITH protect
 DECLARE name_middle = vc WITH protect
 DECLARE name_full = vc WITH protect
 DECLARE dn_string = vc WITH protect
 DECLARE harvest_dt_tm = vc WITH protect
 DECLARE chart_dt_tm = vc WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE spaceline = vc WITH protect, constant("          ")
 DECLARE indent_one = vc WITH protect, constant(".  ")
 DECLARE indent_two = vc WITH protect, constant(".    ")
 DECLARE num_dev_this_les = i4 WITH protect
 DECLARE dev_msg_str_header = vc WITH protect, constant(
  "The lesion was unsuccessful and hence no device(s) entered, will be exported.")
 DECLARE dev_msg_str_line_les = vc WITH protect, constant("The Lesion number ignored:")
 DECLARE dev_msg_str_line = vc WITH protect, constant(". The Device number ignored:")
 DECLARE unsuccessful = i2 WITH protect, constant(2)
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"CER_TEMP:CVOUTPUT_PRE")
 DECLARE max_harvest_rec = i4 WITH protect, constant(size(cv_hrv_rec->harvest_rec,5))
 DECLARE cad = i4 WITH protect, noconstant(0)
 DECLARE pad = i4 WITH protect, noconstant(0)
 DECLARE lad = i4 WITH protect, noconstant(0)
 DECLARE abd = i4 WITH protect, noconstant(0)
 DECLARE d1_var = i4 WITH protect, noconstant(0)
 DECLARE d2_var = i4 WITH protect, noconstant(0)
 DECLARE d3_var = i4 WITH protect, noconstant(0)
 DECLARE abstr_data_col = i4 WITH protect, constant(20)
 DECLARE xref_id_col = i4 WITH protect, constant((20+ abstr_data_col))
 DECLARE event_cd_col = i4 WITH protect, constant((20+ xref_id_col))
 DECLARE nomenclature_id_col = i4 WITH protect, constant((20+ event_cd_col))
 DECLARE result_val_col = i4 WITH protect, constant((20+ nomenclature_id_col))
 DECLARE result_id_col = i4 WITH protect, constant((20+ result_val_col))
 DECLARE result_dt_tm_col = i4 WITH protect, constant((20+ result_id_col))
 DECLARE task_assay_cd_col = i4 WITH protect, constant((20+ result_dt_tm_col))
 DECLARE task_assay_mean_col = i4 WITH protect, constant((20+ task_assay_cd_col))
 DECLARE valid_flag_col = i4 WITH protect, constant((20+ task_assay_mean_col))
 DECLARE translated_value_col = i4 WITH protect, constant((20+ valid_flag_col))
 DECLARE error_msg_col = i4 WITH protect, constant((150+ translated_value_col))
 DECLARE abstr_idx_col = i4 WITH protect, constant((15+ error_msg_col))
 DECLARE proc_data_col = i4 WITH protect, constant((15+ abstr_idx_col))
 DECLARE lesion_data_col = i4 WITH protect, constant((15+ proc_data_col))
 DECLARE field_type_cd_col = i4 WITH protect, constant((15+ lesion_data_col))
 DECLARE field_type_meaning_col = i4 WITH protect, constant((15+ field_type_cd_col))
 DECLARE result_source_col = i4 WITH protect, constant((20+ field_type_meaning_col))
 DECLARE abstr_type_flag_col = i4 WITH protect, constant((15+ result_source_col))
 DECLARE required_flag_col = i4 WITH protect, constant((15+ abstr_type_flag_col))
 DECLARE person_username = vc WITH protect
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE discern_message = vc WITH protect
 DECLARE file_name = vc WITH protect
 DECLARE device_num = i4 WITH protect
 DECLARE out_str = vc WITH protect
 DECLARE thisformat = vc WITH protect
 DECLARE upper = f8 WITH protect
 DECLARE lower = f8 WITH protect
 DECLARE bdone = i2 WITH protect
 DECLARE runaway = i4 WITH protect
 DECLARE numpound = i4 WITH protect
 DECLARE fparamval = f8 WITH protect
 DECLARE leftdec = vc WITH protect
 DECLARE tempit = vc WITH protect
 DECLARE echo_while = i2 WITH protect
 DECLARE loc = i4 WITH noconstant(0), protect
 DECLARE rec_cnt = i4 WITH noconstant(0), protect
 DECLARE retstr_l = vc WITH protect
 DECLARE retstr_r = vc WITH protect
 DECLARE i = i4 WITH protect
 DECLARE errheader = vc WITH protect
 DECLARE fld_str1 = vc WITH protect
 DECLARE errinfo = vc WITH protect
 DECLARE fld_str2 = vc WITH protect
 DECLARE this_cnt_for_subroutine = i4 WITH protect, noconstant(0)
 DECLARE hdfld = vc WITH protect, noconstant(fillstring(128," "))
 CALL cv_log_message(build("The number of Records is:",max_harvest_rec))
 CALL cv_log_message(build("Max procedures is:",cv_hrv_rec->max_proc_data))
 CALL cv_log_message(build("Max Lesions is: ",cv_hrv_rec->max_lesion))
 IF (size(trim(cv_hrv_rec->harvest_rec[1].output_dest)) > 0)
  SELECT INTO value(cv_hrv_rec->harvest_rec[1].output_dest)
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d2  WITH seq = value(cv_hrv_rec->max_proc_data)),
    (dummyt d3  WITH seq = value(cv_hrv_rec->max_lesion))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].proc_data,5))
    JOIN (d3
    WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].lesion,5))
   HEAD REPORT
    "case_abstr_data", col abstr_data_col, "xref_id",
    col xref_id_col, "event_cd", col event_cd_col,
    "nomenclature_id", col nomenclature_id_col, "result_val",
    col result_val_col, "result_id", col result_id_col,
    "result_dt_tm", col result_dt_tm_col, "task_assay_cd",
    col task_assay_cd_col, "task_assay_mean_col", col task_assay_mean_col,
    "valid_flag", col valid_flag_col, "translated_value",
    col translated_value_col, "error_msg", col error_msg_col,
    "abstr_idx", col abstr_idx_col, "proc_data",
    col proc_data_col, "lesion_data", col lesion_data_col,
    "field_type_cd", col field_type_cd_col, "field_type_meaning",
    col field_type_meaning_col, "result_source", col result_source_col,
    "abstr_type_flag", col abstr_type_flag_col, "required_flag",
    col required_flag_col, row + 1
   HEAD d1.seq
    "Case ", d1.seq, col + 2,
    "   person_id = ", cv_hrv_rec->harvest_rec[d1.seq].person_id, col + 2,
    "   encntr_id = ", cv_hrv_rec->harvest_rec[d1.seq].encntr_id, col + 2,
    "   top_parent_event_id = ", cv_hrv_rec->harvest_rec[d1.seq].top_parent_event_id, row + 1,
    "   case_abstr_data ", "Case ", d1.seq,
    row + 1
    FOR (cad = 1 TO size(cv_hrv_rec->harvest_rec[d1.seq].case_abstr_data,5))
      d1_var = cv_hrv_rec->harvest_rec[d1.seq].case_abstr_data[cad].abstr_data_idx, cad, col
      abstr_data_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].xref_id, col xref_id_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d1_var].event_cd,
      col event_cd_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].nomenclature_id, col
      nomenclature_id_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].result_val, col result_val_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d1_var].result_id,
      col result_id_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].result_dt_tm, col
      result_dt_tm_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].task_assay_cd, col task_assay_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].task_assay_mean,
      col task_assay_mean_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].valid_flag, col
      valid_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].translated_value, col translated_value_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].error_msg,
      col error_msg_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].abstr_idx, col
      abstr_idx_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].proc_data_idx, col proc_data_col, cv_hrv_rec
      ->harvest_rec[d1.seq].abstr_data[d1_var].lesion_data_idx,
      col lesion_data_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].field_type_cd, col
      field_type_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].field_type_meaning, col
      field_type_meaning_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].result_source,
      col result_source_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].abstr_type_flag, col
      abstr_type_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d1_var].required_flag, col required_flag_col, row +
      1
    ENDFOR
   HEAD d2.seq
    "   Procedure ", d2.seq, "Case ",
    d1.seq, row + 1, "      event_type_cd = ",
    cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].event_type_cd, col + 2,
    "      proc_physician_id = ",
    cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].proc_physician_id, col + 2,
    "      proc_start_dt_tm  = ",
    cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].proc_start_dt_tm, col + 2,
    "      proc_end_dt_tm = ",
    cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].proc_end_dt_tm, row + 1
    FOR (pad = 1 TO size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].proc_abstr_data,5))
      d2_var = cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].proc_abstr_data[pad].abstr_data_idx,
      pad, col abstr_data_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].xref_id, col xref_id_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2_var].event_cd,
      col event_cd_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].nomenclature_id, col
      nomenclature_id_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].result_val, col result_val_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2_var].result_id,
      col result_id_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].result_dt_tm, col
      result_dt_tm_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].task_assay_cd, col task_assay_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].task_assay_mean,
      col task_assay_mean_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].valid_flag, col
      valid_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].translated_value, col translated_value_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].error_msg,
      col error_msg_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].abstr_idx, col
      abstr_idx_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].proc_data_idx, col proc_data_col, cv_hrv_rec
      ->harvest_rec[d1.seq].abstr_data[d2_var].lesion_data_idx,
      col lesion_data_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].field_type_cd, col
      field_type_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].field_type_meaning, col
      field_type_meaning_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].result_source,
      col result_source_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].abstr_type_flag, col
      abstr_type_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2_var].required_flag, col required_flag_col, row +
      1
    ENDFOR
   HEAD d3.seq
    "      Lesion ", d3.seq, "Procedure ",
    d2.seq, "Case ", d1.seq,
    row + 1
    FOR (lad = 1 TO size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].lesion[d3.seq].
     les_abstr_data,5))
      d3_var = cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].lesion[d3.seq].les_abstr_data[lad].
      abstr_data_idx, lad, col abstr_data_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].xref_id, col xref_id_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d3_var].event_cd,
      col event_cd_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].nomenclature_id, col
      nomenclature_id_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].result_val, col result_val_col, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d3_var].result_id,
      col result_id_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].result_dt_tm, col
      result_dt_tm_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].task_assay_cd, col task_assay_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].task_assay_mean,
      col task_assay_mean_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].valid_flag, col
      valid_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].translated_value, col translated_value_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].error_msg,
      col error_msg_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].abstr_idx, col
      abstr_idx_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].proc_data_idx, col proc_data_col, cv_hrv_rec
      ->harvest_rec[d1.seq].abstr_data[d3_var].lesion_data_idx,
      col lesion_data_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].field_type_cd, col
      field_type_cd_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].field_type_meaning, col
      field_type_meaning_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].result_source,
      col result_source_col, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].abstr_type_flag, col
      abstr_type_flag_col,
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3_var].required_flag, col required_flag_col, row +
      1
    ENDFOR
   DETAIL
    col 0
   WITH nocounter, maxcol = 10000, outerjoin = d2,
    outerjoin = d3, maxrow = 1, noformfeed
  ;end select
 ENDIF
 FREE RECORD ofilerec
 RECORD ofilerec(
   1 rec[*]
     2 file_id = f8
     2 name = c30
     2 extension = c3
     2 delimiter = c1
 )
 DECLARE filecnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  file_nbr = t.file_nbr
  FROM cv_dataset_file t
  WHERE (t.dataset_id=cv_hrv_rec->harvest_rec[1].dataset_id)
   AND t.active_ind=1
  ORDER BY t.file_nbr DESC
  HEAD REPORT
   filecnt = file_nbr, rec_arr = alterlist(ofilerec->rec,file_nbr)
  DETAIL
   ofilerec->rec[file_nbr].file_id = t.file_id, ofilerec->rec[file_nbr].name = t.name, ofilerec->rec[
   file_nbr].extension = t.extension,
   ofilerec->rec[file_nbr].delimiter = t.delimiter
  WITH nocounter
 ;end select
 SET cv_hrv_rec->max_num_files = filecnt
 SET stat = alterlist(cv_hrv_rec->files,filecnt)
 IF ( NOT (validate(accv3_ind)))
  DECLARE accv3_ind = i4 WITH noconstant(0)
 ENDIF
 IF ( NOT (validate(registry_version)))
  DECLARE registry_version = i4 WITH noconstant(0)
 ENDIF
 IF ( NOT (validate(acc_sts_flag)))
  DECLARE acc_sts_flag = i4 WITH noconstant(0)
 ENDIF
 DECLARE old_sts_output = i4 WITH protect, noconstant(0)
 SET old_sts_output = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,"USE_OLD_STS_OUTPUT")
 SET acc_sts_flag = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,"CV_FLAG_CTRL_ACC_OR_STS_ETC")
 SET registry_version = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,"REGISTRY_VERSION")
 CALL echo(build("acc_sts_flag     ===>",acc_sts_flag))
 CALL echo(build("registry_version ===>",registry_version))
 CALL echo(build("old_sts_output ===>",old_sts_output))
 IF (registry_version >= 3
  AND acc_sts_flag=1)
  SET accv3_ind = 1
  CALL echo("accv3_ind set to 1")
  EXECUTE cv_get_harvest_output_acc3
  GO TO file_row_end
 ENDIF
 IF (acc_sts_flag=2
  AND old_sts_output <= 0)
  EXECUTE cv_get_harvest_output_sts
  GO TO file_row_end
 ENDIF
 DECLARE use_multiple_files = i2 WITH protect, noconstant(0)
 IF (size(ofilerec->rec,5) > 3)
  SET use_multiple_files = 1
 ENDIF
 CALL cv_log_message(build("use_multiple_files = ",use_multiple_files))
 CALL cv_log_message(build("Number of Harvest Records = ",size(cv_hrv_rec->harvest_rec,5)))
 DECLARE filidx = i4 WITH protect, noconstant(0)
 DECLARE position_field = i4 WITH protect, noconstant(0)
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 DECLARE rowtemplforfil = vc WITH protect, noconstant(fillstring(1024," "))
 DECLARE numfldsperrow = i4 WITH protect, noconstant(0)
 DECLARE myrow = vc WITH protect, noconstant(fillstring(31000," "))
 CALL cv_log_message("get status of guidewire for each lesion")
 SET stat = alterlist(cv_lesion_succ->rec,size(cv_hrv_rec->harvest_rec,5))
 DECLARE lesion_idx = i4 WITH protect
 SELECT INTO "NL:"
  lesion_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean="AC02LGUIDE"))
  ORDER BY d1.seq, lesion_idx
  HEAD REPORT
   rec_cnt = 0
  HEAD d1.seq
   rec_cnt = (rec_cnt+ 1), les_cnt = 0
  HEAD lesion_idx
   les_cnt = (les_cnt+ 1), stat = alterlist(cv_lesion_succ->rec[rec_cnt].lesion,cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx)
  DETAIL
   cv_lesion_succ->rec[rec_cnt].lesion[cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
   lesion_data_idx].status = cnvtreal(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
    translated_value)
  WITH nocounter
 ;end select
 EXECUTE cv_log_struct  WITH replace(request,cv_lesion_succ)
 FOR (filidx = 1 TO filecnt)
   IF ((ofilerec->rec[filidx].name != "")
    AND (ofilerec->rec[filidx].extension != ""))
    SET file_name = build("CER_TEMP",":",ofilerec->rec[filidx].name,".",ofilerec->rec[filidx].
     extension)
   ELSEIF ((ofilerec->rec[filidx].name != "")
    AND (ofilerec->rec[filidx].extension=""))
    SET file_name = build("CER_TEMP",":",ofilerec->rec[filidx].name)
   ELSEIF ((ofilerec->rec[filidx].name=""))
    SET file_name = build("CER_TEMP",":","D999999",filidx)
   ENDIF
   SET numfldsperrow = 0
   SELECT INTO "nl:"
    FROM cv_xref_field reff
    WHERE (reff.file_id=ofilerec->rec[filidx].file_id)
     AND reff.active_ind=1
    DETAIL
     numfldsperrow = (numfldsperrow+ 1)
    WITH nocounter
   ;end select
   CALL cv_log_message(build("numfldsperrow = ",numfldsperrow," for filidx =",filidx))
   SET device_num = 0
   CALL cv_log_message("-----------------------------")
   CALL cv_log_message(build("Before Select filidx = ",filidx))
   SELECT INTO "NL:"
    filidx, rec_case_idx = cv_hrv_rec->harvest_rec[d1.seq].case_id, case_idx = d1.seq,
    xref_id = reff.xref_id, abstr_idx = d2.seq, myformat = trim(reff.format),
    fdisplay = reff.display_name, flength = reff.length, fstpos = reff.start_pos,
    position_field = reff.position, proc_case_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq
    ].proc_data_idx, lesion_data_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
    lesion_data_idx,
    abstr_type_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].abstr_type_flag, device_idx
     = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx, lesdev_idx = ((cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx * 100)+ cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data[d2.seq].dev_idx),
    abstr_type_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].abstr_type_flag,
    myfieldtrans = substring(reff.start_pos,reff.length,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
     .seq].translated_value), myfieldreal = substring(1,40,cv_hrv_rec->harvest_rec[d1.seq].
     abstr_data[d2.seq].result_val)
    FROM cv_xref_field reff,
     (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
     (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
     JOIN (reff
     WHERE (reff.file_id=ofilerec->rec[filidx].file_id)
      AND reff.active_ind=1
      AND (reff.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
    ORDER BY case_idx, proc_case_idx, lesdev_idx,
     position_field
    HEAD REPORT
     "File Id::", col + 5, filidx,
     col + 4, ofilerec->rec[filidx].name, row + 1,
     cad_size = 0, pad_size = 0, lad_size = 0,
     bfirst = 0, nprevflag = 0, file_delimiter = ofilerec->rec[filidx].delimiter,
     headstr = fillstring(31000," "), bheaderprinted = 0, myfield = fillstring(256," "),
     myrow = fillstring(31000," "), case_template = fillstring(31000," "), proc_template = fillstring
     (31000," "),
     rowtemplforfil = fillstring(value(numfldsperrow),ofilerec->rec[filidx].delimiter),
     case_template_hdr = fillstring(31000," "), proc_template_hdr = fillstring(31000," "),
     numoffiles = (size(reply->files,5)+ 1), stat = alterlist(reply->files,numoffiles), reply->files[
     numoffiles].filename = ofilerec->rec[filidx].name,
     file_type_ind = - (1), file_type_ind = findstring(search_file_raw,cnvtupper(ofilerec->rec[filidx
       ].name)), sizeoflines = 0,
     sizeoffilesarr = 0, sizeoffilesarr_hdr = 0, numeric_result_val = fillstring(256," "),
     prev_device_number = 1
    HEAD case_idx
     bfirst = 1, boncepercase = 0, myrow = fillstring(31000," "),
     case_template = rowtemplforfil, case_template_hdr = rowtemplforfil, sizeoffilesarr = (size(
      cv_hrv_rec->harvest_rec[d1.seq].files,5)+ 1),
     stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].files,sizeoffilesarr), cv_hrv_rec->harvest_rec[
     d1.seq].files[sizeoffilesarr].dataset_file_id = reff.file_id, sizeoffilerow = 0,
     sizeoffilerow_hdr = 0
    HEAD proc_case_idx
     bonceperproc = 0
     IF (boncepercase=0)
      proc_template = case_template, proc_template_hdr = case_template_hdr, boncepercase = 1
     ENDIF
    HEAD lesdev_idx
     IF (bonceperproc=0)
      myrow = proc_template, headstr = proc_template_hdr, bonceperproc = 1,
      nemptycnt = 0
     ENDIF
     myrow = proc_template
     IF (mod(lesdev_idx,100)=0)
      device_num = 0
     ELSE
      device_num = (device_num+ 1)
     ENDIF
     prevpos = 0
    DETAIL
     myfield = fillstring(100," ")
     IF (file_type_ind <= 0)
      myfield = substring(reff.start_pos,reff.length,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
       .seq].translated_value)
     ELSE
      myfield = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
     ENDIF
     IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=
     csm_field_type_numeric)
      AND size(trim(reff.format)) > 0)
      numeric_result_val = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value
      IF (size(trim(numeric_result_val,3)) > 0)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = formatdecimal(
        numeric_result_val,myformat)
      ENDIF
      numeric_result_val = " ", myfield = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      translated_value
     ENDIF
     CASE (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].abstr_type_flag)
      OF abstr_type_case:
       this_cnt_for_subroutine = reff.position,case_template = formsubstringbyrecurcnt_new(
        case_template,file_delimiter,myfield),proc_template = case_template,
       myrow = proc_template,hdfld = trim(reff.display_name),case_template_hdr =
       formsubstringbyrecurcnt_new(case_template_hdr,file_delimiter,hdfld),
       proc_template_hdr = case_template_hdr,headstr = proc_template_hdr
      OF abstr_type_proc:
       this_cnt_for_subroutine = reff.position,proc_template = formsubstringbyrecurcnt_new(
        proc_template,file_delimiter,myfield),myrow = proc_template,
       hdfld = trim(reff.display_name),proc_template_hdr = formsubstringbyrecurcnt_new(
        proc_template_hdr,file_delimiter,hdfld),headstr = proc_template_hdr
      OF abstr_type_les:
       CALL cv_log_message(build("reff.position:",reff.position," lesdev_idx:",lesdev_idx))
       IF (prevpos != reff.position)
        num_dev_this_les = size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_case_idx].lesion[
         lesion_data_idx].exist_dev_idx,5)
        IF (trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean)="AC02LDPTD"
         AND num_dev_this_les=0)
         myfield = "1"
        ENDIF
        this_cnt_for_subroutine = reff.position, myrow = formsubstringbyrecurcnt_new(myrow,
         file_delimiter,myfield)
        IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean="AC02LDDEVICE"))
         this_cnt_for_subroutine = (reff.position - 1)
         IF (num_dev_this_les != 0)
          myfield = cnvtstring(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx),
          prev_device_number = (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx+ 1)
         ELSE
          myfield = cnvtstring(prev_device_number), prev_device_number = (prev_device_number+ 1)
         ENDIF
         myrow = formsubstringbyrecurcnt_new(myrow,file_delimiter,myfield)
         IF (device_idx > 0)
          this_cnt_for_subroutine = (reff.position - 2), myfield = cnvtstring(cv_hrv_rec->
           harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx), myrow =
          formsubstringbyrecurcnt_new(myrow,file_delimiter,myfield)
         ENDIF
        ENDIF
       ELSE
        CALL cv_log_message(build("ignoring d2.seq:",d2.seq))
       ENDIF
       ,hdfld = trim(reff.display_name),headstr = formsubstringbyrecurcnt_new(headstr,file_delimiter,
        hdfld),prevpos = reff.position
     ENDCASE
    FOOT  case_idx
     CALL echo("next_case")
    FOOT  proc_case_idx
     CALL echo("next_proc")
    FOOT  lesdev_idx
     IF (((use_multiple_files=1) OR (proc_case_idx=size(cv_hrv_rec->harvest_rec[d1.seq].proc_data,5)
     )) )
      CASE (filidx)
       OF 1:
       OF 2:
       OF 3:
       OF 8:
        IF (bheaderprinted=0)
         bheaderprinted = 1, headstr = replace(headstr,file_delimiter,"",2), headstr,
         row + 1, sizeoffilerow_hdr = (size(cv_hrv_rec->files[filidx].file_row,5)+ 1), stat =
         alterlist(cv_hrv_rec->files[filidx].file_row,sizeoffilerow_hdr),
         cv_hrv_rec->files[filidx].file_row[sizeoffilerow_hdr].line = headstr, sizeoflines = (size(
          reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->files[numoffiles].
          info_line,sizeoflines),
         reply->files[numoffiles].info_line[sizeoflines].new_line = headstr, headstr = build(headstr,
          file_delimiter)
        ENDIF
        ,myrow = replace(myrow,file_delimiter,"",2),myrow,row + 1,
        sizeoffilerow = (size(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,5)+ 1),
        stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,sizeoffilerow
         ),cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row[sizeoffilerow].line = myrow,
        sizeoflines = (size(reply->files[numoffiles].info_line,5)+ 1),stat = alterlist(reply->files[
         numoffiles].info_line,sizeoflines),reply->files[numoffiles].info_line[sizeoflines].new_line
         = myrow,
        myrow = build(myrow,file_delimiter)
       OF 4:
       OF 5:
        IF ((cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_case_idx].proc_id != 0))
         IF (proc_case_idx > 0)
          IF (bheaderprinted=0)
           bheaderprinted = 1, headstr = replace(headstr,file_delimiter,"",2), headstr,
           row + 1, sizeoffilerow_hdr = (size(cv_hrv_rec->files[filidx].file_row,5)+ 1), stat =
           alterlist(cv_hrv_rec->files[filidx].file_row,sizeoffilerow_hdr),
           cv_hrv_rec->files[filidx].file_row[sizeoffilerow_hdr].line = headstr, sizeoflines = (size(
            reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->files[numoffiles].
            info_line,sizeoflines),
           reply->files[numoffiles].info_line[sizeoflines].new_line = headstr, headstr = build(
            headstr,file_delimiter)
          ENDIF
          myrow = replace(myrow,file_delimiter,"",2), myrow, row + 1,
          sizeoffilerow = (size(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,5)+ 1),
          stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,
           sizeoffilerow), cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row[
          sizeoffilerow].line = myrow,
          sizeoflines = (size(reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->
           files[numoffiles].info_line,sizeoflines), reply->files[numoffiles].info_line[sizeoflines].
          new_line = myrow,
          myrow = build(myrow,file_delimiter)
         ENDIF
        ENDIF
       OF 6:
        IF (proc_case_idx > 0
         AND lesion_data_idx > 0)
         IF (bheaderprinted=0)
          bheaderprinted = 1, headstr = replace(headstr,file_delimiter,"",2), headstr,
          row + 1, sizeoffilerow_hdr = (size(cv_hrv_rec->files[filidx].file_row,5)+ 1), stat =
          alterlist(cv_hrv_rec->files[filidx].file_row,sizeoffilerow_hdr),
          cv_hrv_rec->files[filidx].file_row[sizeoffilerow_hdr].line = headstr, sizeoflines = (size(
           reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->files[numoffiles].
           info_line,sizeoflines),
          reply->files[numoffiles].info_line[sizeoflines].new_line = headstr, headstr = build(headstr,
           file_delimiter)
         ENDIF
         myrow = replace(myrow,file_delimiter,"",2), myrow, row + 1,
         sizeoffilerow = (size(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,5)+ 1),
         stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,
          sizeoffilerow), cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row[
         sizeoffilerow].line = myrow,
         sizeoflines = (size(reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->
          files[numoffiles].info_line,sizeoflines), reply->files[numoffiles].info_line[sizeoflines].
         new_line = myrow,
         myrow = build(myrow,file_delimiter)
        ENDIF
       OF 7:
        num_dev_this_les = size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_case_idx].lesion[
         lesion_data_idx].exist_dev_idx,5),
        IF (proc_case_idx > 0
         AND lesion_data_idx > 0
         AND ((device_idx > 0) OR (num_dev_this_les=0)) )
         IF (bheaderprinted=0)
          bheaderprinted = 1, headstr = replace(headstr,file_delimiter,"",2), headstr,
          row + 1, sizeoffilerow_hdr = (size(cv_hrv_rec->files[filidx].file_row,5)+ 1), stat =
          alterlist(cv_hrv_rec->files[filidx].file_row,sizeoffilerow_hdr),
          cv_hrv_rec->files[filidx].file_row[sizeoffilerow_hdr].line = headstr, sizeoflines = (size(
           reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->files[numoffiles].
           info_line,sizeoflines),
          reply->files[numoffiles].info_line[sizeoflines].new_line = headstr, headstr = build(headstr,
           file_delimiter)
         ENDIF
         IF ((cv_lesion_succ->rec[d1.seq].lesion[cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         lesion_data_idx].status != unsuccessful))
          myrow = replace(myrow,file_delimiter,"",2), myrow, row + 1,
          sizeoffilerow = (size(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,5)+ 1),
          stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row,
           sizeoffilerow), cv_hrv_rec->harvest_rec[d1.seq].files[sizeoffilesarr].file_row[
          sizeoffilerow].line = myrow,
          sizeoflines = (size(reply->files[numoffiles].info_line,5)+ 1), stat = alterlist(reply->
           files[numoffiles].info_line,sizeoflines), reply->files[numoffiles].info_line[sizeoflines].
          new_line = myrow,
          myrow = build(myrow,file_delimiter)
         ELSE
          IF ((cv_dev_msgs->case_num < case_idx))
           cv_dev_msgs->case_num = case_idx, stat = alterlist(cv_dev_msgs->case_err,cv_dev_msgs->
            case_num), cv_dev_msgs->case_err[cv_dev_msgs->case_num].msg = build(dev_msg_str_header,
            char(13),char(10))
          ENDIF
          cv_dev_msgs->case_err[cv_dev_msgs->case_num].msg = build(cv_dev_msgs->case_err[cv_dev_msgs
           ->case_num].msg,dev_msg_str_line_les,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
           lesion_data_idx,dev_msg_str_line,device_num,
           char(13),char(10))
         ENDIF
        ENDIF
      ENDCASE
     ENDIF
     IF ((cv_hrv_rec->max_file_rows < sizeoffilerow))
      cv_hrv_rec->max_file_rows = sizeoffilerow
     ENDIF
    WITH nocounter, noformfeed, maxrow = 1,
     maxcol = 32000, format = variable
   ;end select
   CALL echorecord(cv_hrv_rec,"cer_temp:CV_HrvChk6.dat")
 ENDFOR
#file_row_end
 CALL cv_log_message("build discern message")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
  WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PLNAME")
  DETAIL
   name_last = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
  WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PFNAME")
  DETAIL
   name_first = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
  WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PMNAME")
  DETAIL
   name_middle = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
  WITH nocounter
 ;end select
 SET name_full = concat("Patient Name: ",name_last,", ",name_first," ",
  name_middle)
 CALL addstringtomessage(name_full)
 SET dn_string = build("Person ID: ",cv_hrv_rec->harvest_rec[1].person_id)
 CALL addstringtomessage(dn_string)
 SET dn_string = build("Encounter ID: ",cv_hrv_rec->harvest_rec[1].encntr_id)
 CALL addstringtomessage(dn_string)
 SET dn_string = build("Case ID: ",cv_hrv_rec->harvest_rec[1].case_id)
 CALL addstringtomessage(dn_string)
 SET dn_string = build("Record ID: ",cv_hrv_rec->harvest_rec[1].case_dataset_r_id)
 CALL addstringtomessage(dn_string)
 SELECT INTO "nl:"
  FROM cv_case_dataset_r ccdr
  WHERE (ccdr.case_dataset_r_id=cv_hrv_rec->harvest_rec[1].case_dataset_r_id)
  DETAIL
   harvest_dt_tm = format(ccdr.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
  WITH nocounter
 ;end select
 SET dn_string = build("Harvest Date: ",harvest_dt_tm)
 CALL addstringtomessage(dn_string)
 SELECT INTO "nl:"
  FROM cv_case cv
  WHERE (cv.cv_case_id=cv_hrv_rec->harvest_rec[1].case_id)
  DETAIL
   chart_dt_tm = format(cv.chart_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
  WITH nocounter
 ;end select
 SET dn_string = build("Chart Date: ",chart_dt_tm)
 CALL addstringtomessage(dn_string)
 DECLARE dt_tm_str = vc WITH protect, noconstant(format(cv_hrv_rec->harvest_rec[1].case_dt_tm,
   "DD-MMM-YYYY HH:MM:SS;;D"))
 SET dn_string = build("Case Date: ",dt_tm_str)
 CALL addstringtomessage(dn_string)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25973
   AND cv.cdf_meaning > " "
   AND cv.active_ind=1
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(cv_dn_msg->statuses,cnt), cv_dn_msg->statuses[cnt].meaning = cv
   .cdf_meaning,
   cv_dn_msg->statuses[cnt].display = cv.display
  WITH nocounter
 ;end select
 IF (size(cv_dn_msg->statuses,5) > 0)
  FOR (idx = 1 TO size(cv_dn_msg->statuses,5))
   IF ((cv_dn_msg->statuses[idx].meaning="ERROR"))
    IF (size(cv_dev_msgs->case_err,5) > 0)
     IF (size(trim(cv_dev_msgs->case_err[1].msg,3),1) > 1)
      CALL addstringtomessage(cv_dev_msgs->case_err[1].msg)
     ENDIF
    ENDIF
   ENDIF
   CALL createlogforstatus(cv_dn_msg->statuses[idx].meaning,cv_dn_msg->statuses[idx].display,1)
  ENDFOR
 ENDIF
 IF (size(ofilerec->rec,5) > 1)
  SELECT INTO "NL:"
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
    cv_xref_field cxf,
    dummyt d3,
    cv_case_abstr_data ccad
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
     AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_cd != 0.0))
    JOIN (cxf
    WHERE (cxf.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id)
     AND (cxf.file_id=ofilerec->rec[2].file_id)
     AND cxf.active_ind=1)
    JOIN (d3)
    JOIN (ccad
    WHERE (ccad.cv_case_id=cv_hrv_rec->harvest_rec[d1.seq].case_id)
     AND (ccad.event_cd=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].event_cd))
   ORDER BY cxf.xref_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt=1)
     CALL addstringtomessage(spaceline),
     CALL addstringtomessage("Previously Charted Fields with Differing Values:"),
     CALL addstringtomessage(spaceline)
    ENDIF
    curval = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
    IF (cnvtupper(curval)="<BLANK>")
     curval = " "
    ENDIF
    curval = trim(curval), prevval = trim(ccad.result_val)
    IF (curval != prevval)
     IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_cd != 0.0))
      fldname = build("  ",uar_get_code_display(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        task_assay_cd))
     ELSE
      fldname = build("  ",uar_get_code_display(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        field_type_cd))
     ENDIF
     curval = build("    Current value : ",curval),
     CALL cv_log_message(build("    Current value: ",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
      .seq].result_val)), prevval = build("    Previous value: ",prevval),
     CALL cv_log_message(build("    Previous value: ",ccad.result_val)), errmsg = concat(fldname,char
      (13),char(10),curval,char(13),
      char(10),prevval),
     CALL addstringtomessage(errmsg),
     CALL addstringtomessage(spaceline)
    ENDIF
   WITH nocounter, outerjoin = d3
  ;end select
 ENDIF
 CALL cv_log_message("dump cv_dn_msg")
 EXECUTE cv_log_struct  WITH replace(request,cv_dn_msg)
 CALL cv_log_message("get person username")
 SELECT INTO "NL:"
  FROM cv_case c,
   dcp_forms_activity d,
   prsnl p
  PLAN (c
   WHERE (c.cv_case_id=cv_hrv_rec->harvest_rec[1].case_id)
    AND c.form_id != 0.0)
   JOIN (d
   WHERE d.dcp_forms_activity_id=c.form_id)
   JOIN (p
   WHERE p.person_id=d.updt_id)
  DETAIL
   person_username = p.username, person_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message(build("Discern Notify UserName not found for cv_case_id:",cv_hrv_rec->
    harvest_rec[1].case_id))
 ELSE
  CALL cv_log_message(build("Discern Notify UserName:",person_username," count:",curqual,
    " person_id:",
    person_id))
 ENDIF
 SET person_id = 0.0
 IF (person_id != 0.0)
  CALL cv_log_message("discern notify")
  DECLARE messagetitle = vc WITH protect
  FOR (idx = 1 TO current_dn_msg)
    IF (current_dn_msg=1)
     SET messagetitle = concat("Harvest Status: ",name_full,". Chart Date:",chart_dt_tm)
    ELSE
     SET messagetitle = build("Harvest Status (",idx,"-of-",current_dn_msg,"): ",
      name_full,". Chart Date:",chart_dt_tm)
    ENDIF
    CALL cv_log_message(messagetitle)
    EXECUTE eks_send_notify value(person_username), "REPLY", value(messagetitle),
    value(cv_dn_msg->msgs[idx].msg), "100"
  ENDFOR
 ENDIF
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
 SUBROUTINE formsubstringbyrecurcnt(source_str_param,search_str_param,rec_cnt_str_param,ins_str_param
  )
   SET retstr_l = fillstring(value(size(source_str_param))," ")
   SET retstr_r = fillstring(value(size(source_str_param))," ")
   DECLARE loc = i4 WITH noconstant(0), private
   DECLARE rec_cnt = i4 WITH noconstant(0), private
   SET rec_cnt = this_cnt_for_subroutine
   WHILE (rec_cnt > 0)
     SET loc = (loc+ 1)
     SET loc = findstring(search_str_param,source_str_param,loc)
     IF (loc=0)
      RETURN("Error")
     ENDIF
     SET rec_cnt = (rec_cnt - 1)
   ENDWHILE
   IF (loc > 1)
    SET stal = movestring(substring(1,(loc - 1),source_str_param),1,retstr_l,1,(loc - 1))
   ENDIF
   SET star = movestring(substring(loc,((size(source_str_param,1) - loc)+ 1),source_str_param),1,
    retstr_r,1,((size(source_str_param,1) - loc)+ 1))
   RETURN(build(retstr_l,trim(ins_str_param,3),retstr_r))
 END ;Subroutine
 SUBROUTINE formsubstringbyrecurcnt_new(source_str_param,search_str_param,ins_str_param)
   SET retstr_l = fillstring(value(size(source_str_param))," ")
   SET retstr_r = fillstring(value(size(source_str_param))," ")
   SET loc = 0
   SET rec_cnt = 0
   SET rec_cnt = this_cnt_for_subroutine
   SET echo_while = 0
   WHILE (rec_cnt > 0)
     SET loc = (loc+ 1)
     SET loc = findstring(search_str_param,source_str_param,loc)
     IF (((rec_cnt=238) OR (echo_while=1)) )
      SET echo_while = 1
     ENDIF
     IF (loc=0)
      RETURN("Error")
     ENDIF
     SET rec_cnt = (rec_cnt - 1)
   ENDWHILE
   IF (loc > 1)
    SET stal = movestring(substring(1,(loc - 1),source_str_param),1,retstr_l,1,(loc - 1))
   ENDIF
   SET star = movestring(substring(loc,((size(source_str_param,1) - loc)+ 1),source_str_param),1,
    retstr_r,1,((size(source_str_param,1) - loc)+ 1))
   RETURN(build(retstr_l,trim(ins_str_param,3),retstr_r))
 END ;Subroutine
 SUBROUTINE formatdecimal(paramval,paramformat)
   SET out_str = fillstring(100," ")
   SET myparser = fillstring(1000," ")
   SET thisformat = paramformat
   SET upper = 0.0
   SET lower = 0.0
   SET bdone = 0
   SET runaway = 0
   SET numpound = 0
   DECLARE fparamval = f8
   SET fparamval = cnvtreal(paramval)
   WHILE ( NOT (bdone))
     SET leftdec = trim(substring(1,(findstring(".",thisformat) - 1),thisformat))
     SET numpound = size(leftdec,1)
     SET tempit = leftdec
     SET numpound = size(trim(tempit,3),1)
     IF (numpound > 0)
      SET upper = (10** numpound)
      SET lower = ((10** (numpound - 1)) * - (1))
      IF (((fparamval <= lower) OR (fparamval >= upper)) )
       SET thisformat = concat("#",thisformat)
      ELSE
       SET bdone = 1
      ENDIF
     ELSE
      SET bdone = 1
     ENDIF
     SET runaway = (runaway+ 1)
     IF (runaway > 5)
      SET bdone = 1
     ENDIF
   ENDWHILE
   SET myparser = build("set out_str = format(cnvtreal(",char(34),paramval,char(34),"),",
    char(34),trim(thisformat),char(34),") go")
   CALL parser(myparser)
   RETURN(out_str)
 END ;Subroutine
 SUBROUTINE addstringtomessage(addstring)
   IF (size(cv_dn_msg->msgs,5)=0)
    SET stat = alterlist(cv_dn_msg->msgs,1)
   ENDIF
   IF (size(addstring) > max_dn_msg_size)
    CALL cv_log_message("Attempt to add a string to discern notify message > than max")
   ENDIF
   IF (((size(cv_dn_msg->msgs[current_dn_msg].msg)+ size(addstring,1)) > max_dn_msg_size))
    SET current_dn_msg = (current_dn_msg+ 1)
    SET stat = alterlist(cv_dn_msg->msgs,current_dn_msg)
   ENDIF
   SET cv_dn_msg->msgs[current_dn_msg].msg = concat(cv_dn_msg->msgs[current_dn_msg].msg,addstring)
   SET cv_dn_msg->msgs[current_dn_msg].msg = concat(cv_dn_msg->msgs[current_dn_msg].msg,char(13),char
    (10))
 END ;Subroutine
 SUBROUTINE createlogforstatus(param_status,param_status_disp,param_case_idx)
   IF (param_status="HARVNOERROR")
    RETURN
   ENDIF
   SET i = 0
   DECLARE errheader = vc
   DECLARE fld_str1 = vc
   DECLARE errinfo = vc
   DECLARE fld_str2 = vc
   FOR (m = 1 TO size(cv_hrv_rec->harvest_rec[param_case_idx].abstr_data,5))
     IF (uar_get_code_meaning(cv_hrv_rec->harvest_rec[param_case_idx].abstr_data[m].status_cd)=
     param_status)
      SET i = (i+ 1)
      IF (i=1)
       CALL addstringtomessage(spaceline)
       SET errheader = concat("Fields with ",param_status_disp,": ")
       CALL addstringtomessage(errheader)
       CALL addstringtomessage(spaceline)
      ENDIF
      CALL addstringtomessage(spaceline)
      IF ((cv_hrv_rec->harvest_rec[param_case_idx].abstr_data[m].task_assay_cd != 0))
       SET fld_str1 = concat("  ",uar_get_code_display(cv_hrv_rec->harvest_rec[param_case_idx].
         abstr_data[m].task_assay_cd))
      ELSE
       SET fld_str1 = concat("  ",uar_get_code_display(cv_hrv_rec->harvest_rec[param_case_idx].
         abstr_data[m].field_type_cd))
      ENDIF
      SET errinfo = concat("    ",cv_hrv_rec->harvest_rec[param_case_idx].abstr_data[m].error_msg)
      SET fld_str2 = concat(fld_str1,char(13),char(10),errinfo)
      CALL addstringtomessage(fld_str2)
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE cv_get_harvest_output_vrsn = vc WITH private, constant("MOD 022 BM9013 05/31/06")
END GO
