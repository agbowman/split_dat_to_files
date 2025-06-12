CREATE PROGRAM cv_get_harvest_validate_sts:dba
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
 IF (validate(cv_hrv_rec,"notdefined")="notdefined")
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
    SET star = movestring(substring((loc+ 1),(size(soustr,1) - loc),soustr),(loc+ 1),retstr_r,1,(size
     (soustr,1) - loc))
  END ;Subroutine
 ENDIF
 FREE RECORD rule_status
 RECORD rule_status(
   1 qual[*]
     2 xref_id = f8
     2 valid_flag = f8
     2 xref_validation_id = f8
     2 req_flag = f8
 )
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE dataset_internal_name = vc WITH protect
 DECLARE xref_internal_name = vc WITH protect
 DECLARE harvest_rec_idx = i4 WITH protect
 DECLARE this_abstr_idx = i4 WITH protect
 DECLARE abstr_data_idx = i4 WITH protect
 DECLARE reqd_str = vc WITH protect
 DECLARE mesg = vc WITH protect
 DECLARE valid_flag = i2 WITH protect
 DECLARE reqd_flag = i2 WITH protect
 DECLARE status_cd = f8 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE person_id = f8 WITH protect
 DECLARE prsnl_id = f8 WITH protect
 DECLARE getstatuscd(valid_flag=i2,reqd_flag=i2) = i4
 DECLARE blank_str = vc WITH protect, constant("<blank>")
 DECLARE cv_rltnship_flag_parent_child = i4 WITH protect, constant(50)
 DECLARE cv_rltnship_flag_parent_child_inv = i4 WITH protect, constant(51)
 DECLARE reportwarn_message = vc WITH protect, constant(
  " Missing data may render the record unacceptable to the Data Registry.")
 DECLARE cv_resp_flag_ignore_time = i2 WITH protect, noconstant(1)
 DECLARE pgr_class_cd = f8
 SET pgr_class_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(cs_prsnl_group_type,csm_prsnl_group_type_sts,1,pgr_class_cd)
 SELECT INTO "nl:"
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean, cv_hrv_rec->harvest_rec[d1.seq]
  .abstr_data[d3.seq].task_assay_mean, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_id,
  pg.prsnl_group_class_cd, pgr.prsnl_group_id, pgr.person_id
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   dummyt d,
   prsnl_group pg,
   prsnl_group_reltn pgr
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean=csm_task_assay_surgeon))
   JOIN (d3
   WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].task_assay_mean=csm_task_assay_surggrp))
   JOIN (d)
   JOIN (pg
   WHERE pg.prsnl_group_class_cd=pgr_class_cd)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND (pgr.person_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_id))
  ORDER BY d1.seq
  HEAD REPORT
   prsnl_group_name = fillstring(100," "), prsnl_id = 0.0, delimpos = 0
  DETAIL
   prsnl_group_name = "", prsnl_id = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_id,
   delimpos = findstring(str_prsnlgrp_delimstr,pg.prsnl_group_desc)
   IF (delimpos > 0)
    prsnl_group_name = substring(1,(delimpos - 1),pg.prsnl_group_desc)
   ENDIF
   IF (trim(prsnl_group_name,3)="")
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val = cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data[d2.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
    translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value
   ELSE
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val = prsnl_group_name, cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = prsnl_group_name
   ENDIF
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag = 1, cv_hrv_rec->harvest_rec[d1.seq]
   .abstr_data[d3.seq].error_msg = ""
  WITH nocounter, outerjoin = d
 ;end select
 CALL cv_log_message("Checking the Values for the Parent-Child Relationships")
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_parent1.dat")
 SELECT INTO "nl:"
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x1,
   cv_xref_validation xv,
   (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_response r1,
   cv_xref x2,
   dummyt d
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND xv.rltnship_flag IN (cv_rltnship_flag_parent_child, cv_rltnship_flag_parent_child_inv))
   JOIN (r1
   WHERE r1.response_id=xv.response_id)
   JOIN (d
   WHERE ((cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
     translated_value))) OR (size(trim(r1.a2))=0
    AND size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value))=0)) )
   JOIN (x2
   WHERE x2.xref_id=xv.child_xref_id)
   JOIN (d3
   WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=xv.child_xref_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   CASE (xv.rltnship_flag)
    OF cv_rltnship_flag_parent_child:
     IF (cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       translated_value)))
      IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value)) > 0
       AND trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value) != blank_str)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = build(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d3.seq].error_msg,"The parent field",trim(x1.registry_field_name),
        " has a value of ",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,
        " which makes the current value invalid.(Internal Code 000)"), cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_err, cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[d3.seq].translated_value = "",
       cnt = (cnt+ 1)
       IF (cnt > size(rule_status->qual,5))
        stat = alterlist(rule_status->qual,(cnt+ 9))
       ENDIF
       rule_status->qual[cnt].valid_flag = cv_stat_ignore_valid_chk_err, rule_status->qual[cnt].
       xref_id = xv.child_xref_id, rule_status->qual[cnt].xref_validation_id = xv.xref_validation_id,
       rule_status->qual[cnt].req_flag = xv.reqd_flag
      ELSE
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = "", cv_hrv_rec->harvest_rec[d1
       .seq].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_val
      ENDIF
     ENDIF
    OF cv_rltnship_flag_parent_child_inv:
     IF (cnvtupper(trim(r1.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       translated_value)))
      IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value)) > 0
       AND trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value) != blank_str)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = build(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d3.seq].error_msg,"The parent field",trim(x1.registry_field_name),
        " has a value of ",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,
        " which makes the current value invalid.(Internal Code 000)"), cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_err, cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[d3.seq].translated_value = "",
       cnt = (cnt+ 1)
       IF (cnt > size(rule_status->qual,5))
        stat = alterlist(rule_status->qual,(cnt+ 9))
       ENDIF
       rule_status->qual[cnt].valid_flag = cv_stat_ignore_valid_chk_err, rule_status->qual[cnt].
       xref_id = xv.child_xref_id, rule_status->qual[cnt].xref_validation_id = xv.xref_validation_id,
       rule_status->qual[cnt].req_flag = xv.reqd_flag
      ELSE
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = "", cv_hrv_rec->harvest_rec[d1
       .seq].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_val
      ENDIF
     ENDIF
   ENDCASE
  FOOT REPORT
   stat = alterlist(rule_status->qual,cnt)
  WITH nocounter, maxcol = 10000
 ;end select
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_parent2.dat")
 CALL cv_log_message("Doing Interfield Checks...")
 SELECT INTO "nl:"
  xv.rltnship_flag
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x1,
   cv_xref_validation xv,
   (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_response r1,
   cv_response r2,
   cv_xref x2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag IN (
   cv_stat_ignore_valid_chk_err, cv_stat_ignore_valid_chk_val))))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND  NOT (xv.rltnship_flag IN (cv_rltnship_flag_parent_child, cv_rltnship_flag_parent_child_inv))
   )
   JOIN (r1
   WHERE r1.response_id=xv.response_id)
   JOIN (r2
   WHERE r2.response_id=xv.child_response_id)
   JOIN (x2
   WHERE x2.xref_id=r2.xref_id)
   JOIN (d3
   WHERE ((xv.child_xref_id=0.0) OR (d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx=cv_hrv_rec->harvest_rec[d1
   .seq].abstr_data[d3.seq].proc_data_idx)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx=cv_hrv_rec->harvest_rec[
   d1.seq].abstr_data[d3.seq].lesion_data_idx)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=xv.child_xref_id)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag !=
   cv_stat_ignore_valid_chk_err)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag !=
   cv_stat_ignore_valid_chk_val))) )
  ORDER BY xv.rltnship_flag, xv.xref_validation_id
  HEAD REPORT
   cnt = size(rule_status->qual,5), rule_processed = 0
  HEAD xv.xref_validation_id
   l_valid_flag = 1, rule_processed = 0
  DETAIL
   col 0
  FOOT  xv.xref_validation_id
   CASE (r1.field_type)
    OF "A":
    OF "N":
    OF "S":
    OF "D":
     IF (r1.field_type="D")
      date_validated = 0
      IF (((cnvtupper(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)="<BLANK>") OR (
      xv.rltnship_flag >= 14
       AND xv.rltnship_flag <= 17
       AND cnvtupper(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val)="<BLANK>")) )
       rule_processed = 1
      ELSE
       CASE (xv.rltnship_flag)
        OF 14:
         IF (band(cnvtint(r1.a5),cv_resp_flag_ignore_time)=0
          AND band(cnvtint(r2.a5),cv_resp_flag_ignore_time)=0)
          IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
           datetimeadd(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)
           ) > 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ELSE
          IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd
           (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) > 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ENDIF
        OF 15:
         IF (band(cnvtint(r1.a5),cv_resp_flag_ignore_time)=0
          AND band(cnvtint(r2.a5),cv_resp_flag_ignore_time)=0)
          IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
           datetimeadd(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)
           ) < 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ELSE
          IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd
           (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) < 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ENDIF
        OF 16:
         IF (band(cnvtint(r1.a5),cv_resp_flag_ignore_time)=0
          AND band(cnvtint(r2.a5),cv_resp_flag_ignore_time)=0)
          IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
           datetimeadd(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)
           ) >= 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ELSE
          IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd
           (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) >= 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ENDIF
        OF 17:
         IF (band(cnvtint(r1.a5),cv_resp_flag_ignore_time)=0
          AND band(cnvtint(r2.a5),cv_resp_flag_ignore_time)=0)
          IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
           datetimeadd(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)
           ) <= 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ELSE
          IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd
           (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) <= 0)
           date_validated = 1, rule_processed = 1
          ENDIF
         ENDIF
        OF 18:
         IF (datetimediff(cnvtdatetime(curdate,curtime3),cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
          d2.seq].result_dt_tm) < cnvtint(xv.offset_nbr))
          date_validated = 2
         ENDIF
        OF 19:
         IF (datetimediff(cnvtdatetime(curdate,curtime3),cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
          d2.seq].result_dt_tm) <= cnvtint(xv.offset_nbr))
          date_validated = 2
         ENDIF
        OF 20:
         IF (datetimediff(cnvtdatetime(curdate,curtime3),cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
          d2.seq].result_dt_tm) > cnvtint(xv.offset_nbr))
          date_validated = 2
         ENDIF
        OF 21:
         IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm > 0))
          IF (datetimediff(cnvtdatetime(curdate,curtime3),cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
           d2.seq].result_dt_tm) >= cnvtint(xv.offset_nbr))
           date_validated = 2
          ENDIF
         ELSE
          l_valid_flag = 0
         ENDIF
       ENDCASE
      ENDIF
      CASE (date_validated)
       OF 1:
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim(
           format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,"@SHORTDATE")),"",
          blank_str,trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
            "@SHORTDATE")))," while ",trim(x2.registry_field_name),
         " has value ",evaluate(trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
            result_dt_tm,"@SHORTDATE")),"",blank_str,trim(format(cv_hrv_rec->harvest_rec[d1.seq].
            abstr_data[d3.seq].result_dt_tm,"@SHORTDATE"))),".","(Internal Code 001)"),l_valid_flag
         = 4,rule_processed = 1
       OF 2:
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim(
           format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,"@SHORTDATE")),"",
          blank_str,trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
            "@SHORTDATE")))," while "," current system date/time is ",
         format(cnvtdatetime(curdate,curtime3),";;Q"),".","(Internal Code 002)"),
        IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag=1))
         l_valid_flag = cv_stat_date_err
        ENDIF
        ,rule_processed = 1
      ENDCASE
      date_validated = 0
     ENDIF
     ,
     CASE (xv.rltnship_flag)
      OF 1:
      OF 2:
       IF (cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         translated_value)))
        CASE (r2.field_type)
         OF "A":
          CASE (xv.rltnship_flag)
           OF 1:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field =",evaluate(trim(r1.a1),
               "",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " =",evaluate(trim(r2.a1),"",blank_str,trim(r2.a1)),".","(Internal Code 003)"),
             l_valid_flag = 0,
             CALL cv_log_message("Found the Alpha Error!!"),
             CALL cv_log_message(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg)
            ENDIF
           OF 2:
            IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
              d3.seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " has value ",evaluate(trim(r2.a1),"",blank_str,trim(r2.a1)),".","(Internal Code 004)"),
             l_valid_flag = 0
            ENDIF
           OF 3:
           OF 4:
           OF 5:
           OF 6:
           OF 13:
            message = "Not implemented"
           OF 22:
            IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
              d3.seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"","<BLANK>",trim(r1.a1))," while ",trim(x2.registry_field_name),
              " has value ",evaluate(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
                translated_value),"","<BLANK>",trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq
                ].translated_value))," overwritten with ",evaluate(trim(r2.a2),"","<BLANK>",trim(r2
                .a2)),".",
              "(Internal Code 005)")
            ENDIF
            ,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = cnvtupper(trim(r2
              .a2))
          ENDCASE
         OF "N":
          CASE (xv.rltnship_flag)
           OF 1:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 006)"), l_valid_flag = 0
            ENDIF
           OF 2:
            IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
              d3.seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 007)"), l_valid_flag = 0
            ENDIF
           OF 3:
           OF 4:
           OF 5:
           OF 6:
           OF 13:
            message = "Not implemented"
          ENDCASE
         OF "S":
          CASE (xv.rltnship_flag)
           OF 1:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 008)"), l_valid_flag = 0
            ENDIF
           OF 2:
           OF 3:
           OF 4:
           OF 5:
           OF 6:
            message = "Not implemented"
           OF 13:
            IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value != ""))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = cv_hrv_rec->harvest_rec[
             d1.seq].abstr_data[d3.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq
             ].translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value,
             l_valid_flag = 0
            ENDIF
          ENDCASE
         OF "D":
          CASE (xv.rltnship_flag)
           OF 1:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim
               (r1.a1),"",blank_str,trim(r1.a1))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 009)"), l_valid_flag = 0
            ENDIF
           OF 2:
           OF 3:
           OF 4:
           OF 5:
           OF 6:
            message = "Not implemented"
          ENDCASE
        ENDCASE
       ENDIF
      OF 7:
      OF 8:
       IF (cnvtupper(trim(r1.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq
         ].translated_value)))
        CASE (r2.field_type)
         OF "A":
          CASE (xv.rltnship_flag)
           OF 7:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             CALL formatreqdflagstr(xv.reqd_flag), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq]
             .error_msg = concat(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
              " This field has value ",evaluate(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
                .seq].result_val),"",blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].
                 abstr_data[d2.seq].result_val)))," while ",trim(x2.registry_field_name),
              " has value ",evaluate(trim(r2.a1),"",blank_str,trim(r2.a1)),".","(Internal Code 010)"),
             l_valid_flag = 0
            ENDIF
           OF 8:
            IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
              d3.seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(
               cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
               blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
                 )))," while ",trim(x2.registry_field_name),
              " has value ",evaluate(trim(r2.a1),"",blank_str,trim(r2.a1)),".","(Internal Code 011)"),
             l_valid_flag = 0
            ENDIF
           OF 9:
           OF 10:
           OF 11:
           OF 12:
           OF 14:
            message = "Not implemented"
          ENDCASE
         OF "N":
          CASE (xv.rltnship_flag)
           OF 7:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(
               cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
               blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
                 )))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 012)"), l_valid_flag = 0
            ENDIF
           OF 8:
            IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
              d3.seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(
               cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
               blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
                 )))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 013)"), l_valid_flag = 0
            ENDIF
           OF 9:
           OF 10:
           OF 11:
           OF 12:
           OF 14:
            message = "Not implemented"
          ENDCASE
         OF "S":
          CASE (xv.rltnship_flag)
           OF 7:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(
               cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
               blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
                 )))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 014)"), l_valid_flag = 0
            ENDIF
           OF 8:
           OF 9:
           OF 10:
           OF 11:
           OF 12:
            message = "Not Implemented"
           OF 14:
            IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value != ""))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = cv_hrv_rec->harvest_rec[
             d1.seq].abstr_data[d3.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq
             ].translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value,
             l_valid_flag = 0
            ENDIF
          ENDCASE
         OF "D":
          CASE (xv.rltnship_flag)
           OF 7:
            IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
              .seq].translated_value)))
             cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
              harvest_rec[d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(
               cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
               blank_str,cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val
                 )))," while ",trim(x2.registry_field_name),
              " is missing.","(Internal Code 015)"), l_valid_flag = 0
            ENDIF
           OF 8:
           OF 9:
           OF 10:
           OF 11:
           OF 12:
            message = "Not implemented"
          ENDCASE
        ENDCASE
       ENDIF
     ENDCASE
   ENDCASE
   IF (l_valid_flag != 1)
    cnt = (cnt+ 1)
    IF (cnt > size(rule_status->qual,5))
     stat = alterlist(rule_status->qual,(cnt+ 9))
    ENDIF
    rule_status->qual[cnt].valid_flag = l_valid_flag, rule_status->qual[cnt].xref_id = xv.xref_id,
    rule_status->qual[cnt].xref_validation_id = xv.xref_validation_id,
    rule_status->qual[cnt].req_flag = xv.reqd_flag
   ENDIF
  FOOT REPORT
   stat = alterlist(rule_status->qual,cnt)
  WITH nocounter
 ;end select
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL cv_log_message("Setting the Valid Flag and Status Codes...")
 CALL echorecord(cv_hrv_rec,"cer_Temp:BeforeStatus.dat")
 SELECT INTO "nl:"
  x.xref_internal_name, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value,
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   (dummyt d3  WITH seq = value(size(rule_status->qual,5))),
   cv_xref x,
   dummyt d4
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x
   WHERE (x.dataset_id=cv_hrv_rec->dataset_id)
    AND (x.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (d4)
   JOIN (d3
   WHERE (rule_status->qual[d3.seq].xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
   xref_id))
  ORDER BY d1.seq, x.xref_id, ((rule_status->qual[d3.seq].req_flag - 23) * (rule_status->qual[d3.seq]
   .req_flag - 23))
  HEAD REPORT
   stat = 0, valid_flag = - (1), reqd_flag = - (1),
   status_cd = 0.0, cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 1
  HEAD d1.seq
   done_flag = 0, done_flag_case = 0, case_status_flag = 1
  HEAD x.xref_id
   valid_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag, status_cd = 0.0
   IF (d3.seq=0)
    reqd_flag = x.reqd_flag
   ELSE
    CASE (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag)
     OF 1:
     OF cv_stat_ignore_valid_chk_err:
      reqd_flag = rule_status->qual[d3.seq].req_flag,valid_flag = rule_status->qual[d3.seq].
      valid_flag
     OF cv_stat_ignore_valid_chk_val:
      valid_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag,reqd_flag =
      cv_stat_ignore_valid_chk_val
     ELSE
      IF ((((x.reqd_flag - 23) * (x.reqd_flag - 23)) <= ((rule_status->qual[d3.seq].req_flag - 23) *
      (rule_status->qual[d3.seq].req_flag - 23))))
       reqd_flag = x.reqd_flag, valid_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       valid_flag
      ELSE
       reqd_flag = rule_status->qual[d3.seq].req_flag, valid_flag = rule_status->qual[d3.seq].
       valid_flag
      ENDIF
    ENDCASE
   ENDIF
   stat = getstatuscd(valid_flag,reqd_flag), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
   status_cd = status_cd, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = valid_flag
   IF (x.xref_internal_name IN ("STS_PREDMORT", "STS_RECCOMP", "ST02_PREDMORT", "ST02_RECCOMP"))
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
   ENDIF
   IF (reqd_flag=required_flag_reportwarn_code
    AND trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value)="")
    IF ( NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag IN (
    cv_stat_ignore_valid_chk_err, cv_stat_ignore_valid_chk_val))))
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1
      .seq].abstr_data[d2.seq].error_msg,reportwarn_message), cv_hrv_rec->harvest_rec[d1.seq].
     abstr_data[d2.seq].valid_flag = 1
    ENDIF
   ENDIF
   IF (done_flag=0)
    CASE (status_cd)
     OF c_status_error:
      cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 0,cv_hrv_rec->harvest_rec[d1.seq].status_cd =
      c_status_error,done_flag = 1
     OF c_status_harvnoerror:
      IF ((cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_error)
       AND (cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_reportwarn)
       AND (cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_warning))
       cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 1, cv_hrv_rec->harvest_rec[d1.seq].status_cd =
       c_status_harvnoerror
      ENDIF
     OF c_status_reportwarn:
      IF ((cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_error))
       cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 0, cv_hrv_rec->harvest_rec[d1.seq].status_cd =
       c_status_reportwarn
      ENDIF
     OF c_status_warning:
      IF ((cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_error)
       AND (cv_hrv_rec->harvest_rec[d1.seq].status_cd != c_status_reportwarn))
       cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 0, cv_hrv_rec->harvest_rec[d1.seq].status_cd =
       c_status_warning
      ENDIF
     ELSE
      CALL cv_log_message(build("Field has no status cd:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
       d2.seq].abstr_data_name))
    ENDCASE
   ENDIF
  FOOT  x.xref_id
   col 0
  FOOT  d1.seq
   col 0
  WITH outerjoin = d4, nocounter
 ;end select
 CALL echorecord(cv_hrv_rec,"cer_Temp:AfterValid.dat")
 DECLARE insert_reccomplete = i2 WITH public, noconstant(0)
 SET insert_reccomplete = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,
  "CV_INSERT_RECORD_COMPLETE_IN_FILE")
 CALL echo(build("Insert_RecComplete: ",insert_reccomplete))
 IF (insert_reccomplete=1)
  SELECT INTO "nl:"
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean, cv_hrv_rec->harvest_rec[d1.seq
   ].abstr_data[d2.seq].valid_flag
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
     AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=
    csm_field_type_reccomp))
   DETAIL
    IF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=0))
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "NO", cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].translated_value = "2", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
     .seq].error_msg = "Record Incomplete"
    ELSEIF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=1))
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "YES", cv_hrv_rec->harvest_rec[
     d1.seq].abstr_data[d2.seq].translated_value = "1", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
     .seq].error_msg = "Record Complete"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE remove_reccomplete = i2 WITH public, noconstant(0)
 SET remove_reccomplete = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,
  "CV_REMOVE_RECORD_COMPLETE_IN_FILE")
 IF (remove_reccomplete=1)
  SELECT INTO "nl:"
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean, cv_hrv_rec->harvest_rec[d1.seq
   ].abstr_data[d2.seq].valid_flag
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
     AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=
    csm_field_type_reccomp))
   DETAIL
    IF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=0))
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "No", cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].translated_value = " ", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
     .seq].error_msg = "Record Incomplete"
    ELSEIF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=1))
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "Yes", cv_hrv_rec->harvest_rec[
     d1.seq].abstr_data[d2.seq].translated_value = " ", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
     .seq].error_msg = "Record Completed"
    ENDIF
   WITH nocounter
  ;end select
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
 SUBROUTINE getstatuscd(valid_flag,reqd_flag)
   CASE (valid_flag)
    OF 0:
    OF 3:
    OF 4:
    OF cv_stat_date_err:
    OF cv_stat_ignore_valid_chk_err:
     CASE (reqd_flag)
      OF required_flag_reportwarn_code:
       SET status_cd = c_status_reportwarn
      OF required_flag_error_code:
       SET status_cd = c_status_error
      OF required_flag_warning_code:
       SET status_cd = c_status_warning
      OF required_flag_dontcare_code:
       SET status_cd = c_status_harvnoerror
     ENDCASE
    OF cv_stat_ignore_valid_chk_val:
     SET status_cd = c_status_harvnoerror
    ELSE
     SET status_cd = c_status_harvnoerror
   ENDCASE
 END ;Subroutine
 SUBROUTINE getprsnlgrp(param_person_id)
   SET int_class_cd = 0.0
   SET iret = uar_get_meaning_by_codeset(cs_prsnl_group_type,csm_prsnl_group_type_sts,1,class_cd)
   SELECT INTO "nl:"
    FROM prsnl_group pg
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=int_class_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 DECLARE cv_get_harvest_validate_sts_vrsn = vc WITH private, constant("MOD 021 BM9013 09/11/06")
END GO
