CREATE PROGRAM cv_get_harvest:dba
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
 IF ( NOT (validate(csm_name_type_current,0)))
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
 IF ( NOT (validate(exit_after,0)))
  DECLARE exit_after = vc WITH protect, noconstant(curprog)
 ENDIF
 IF (cnvtupper(exit_after)="CV_INSERT_SUMMARY_DATA")
  GO TO exit_script
 ENDIF
 IF (size(trim(cv_hrv_rec->harvest_rec[1].batch_selection)) > 0)
  CALL cv_log_message("The OPS job processing needs to be setup")
  DECLARE curparsedone = i2 WITH protect
  DECLARE curpos = i4 WITH protect
  DECLARE param_pos = i4 WITH protect
  DECLARE cv_parse_data(param_sep=vc(ref),param_string=vc(ref),param_pos=i4(ref)) = vc
  SUBROUTINE cv_parse_data(param_sep,param_string,param_pos)
    SET curparsedone = 0
    SET curpos = findstring(param_sep,param_string,param_pos)
    IF (curpos=0)
     SET curpos = (size(param_string,1)+ 1)
     SET curparsedone = 1
    ENDIF
    IF (param_pos=0)
     SET param_pos = 1
    ENDIF
    SET retval = substring(param_pos,(curpos - param_pos),param_string)
    SET param_pos = (curpos+ size(param_sep,1))
    IF (curparsedone=1)
     SET param_pos = - (1)
    ENDIF
    RETURN(retval)
  END ;Subroutine
  DECLARE parse_string = vc
  DECLARE parse_sep = vc
  DECLARE dataset_name = vc
  SET parse_sep = substring(1,1,cv_hrv_rec->harvest_rec[1].batch_selection)
  SET parse_pos = 1
  SET parse_string = substring(2,size(cv_hrv_rec->harvest_rec[1].batch_selection),cv_hrv_rec->
   harvest_rec[1].batch_selection)
  SET cv_hrv_rec->dataset_id = cv_hrv_rec->harvest_rec[1].dataset_id
  SET dataset_name = cnvtupper(cnvtalphanum(cv_parse_data(parse_sep,parse_string,parse_pos)))
  CALL echo(build("parse_pos = ",parse_pos,"parse_sep = ",parse_sep,"parse_str = ",
    parse_string,"dataset_name = ",dataset_name))
  SET cnt = 0
  SELECT INTO "NL:"
   FROM cv_dataset d
   PLAN (d
    WHERE d.dataset_internal_name=dataset_name
     AND d.active_ind=1
     AND d.dataset_id != 0.0)
   DETAIL
    cnt = (cnt+ 1), cv_hrv_rec->harvest_rec[1].dataset_id = d.dataset_id, cv_hrv_rec->
    dataset_internal_name = d.dataset_internal_name
   WITH nocounter
  ;end select
  IF (cnt=0)
   CALL cv_log_message("No Dataset Found")
   GO TO exit_script
  ENDIF
  IF (cnt > 1)
   CALL cv_log_message("Multiple Datasets Found")
   GO TO exit_script
  ENDIF
  DECLARE loc_fac_name = vc
  SET loc_fac_name = cv_parse_data(parse_sep,parse_string,parse_pos)
  SET cnt = 0
  SET cv_hrv_rec->harvest_rec[1].loc_facility_cd = 0
  IF (size(trim(loc_fac_name)) > 0)
   SET cv_hrv_rec->harvest_rec[1].loc_facility_cd = uar_get_code_by("DESCRIPTION",220,nullterm(
     loc_fac_name))
   IF (uar_get_code_meaning(cv_hrv_rec->harvest_rec[1].loc_facility_cd) != "FACILITY")
    SELECT INTO "NL:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="FACILITY"
       AND c.active_ind=1
       AND c.description=loc_fac_name)
     DETAIL
      cv_hrv_rec->harvest_rec[1].loc_facility_cd = c.code_value
     WITH nocounter
    ;end select
    IF (cnt=0)
     CALL cv_log_message("No Organization-Facility Found")
     GO TO exit_script
    ENDIF
    IF (cnt > 1)
     CALL cv_log_message("Multiple Organization-Facilities Found")
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  DECLARE part_nbr = vc
  SET part_nbr = cv_parse_data(parse_sep,parse_string,parse_pos)
  IF (size(trim(part_nbr)) > 0)
   SET cv_hrv_rec->harvest_rec[1].participant_nbr = part_nbr
  ENDIF
  SET num_dates_found = 0
  DECLARE start_dt = vc
  SET start_dt = cv_parse_data(parse_sep,parse_string,parse_pos)
  IF (size(start_dt,1) > 0)
   SET cv_hrv_rec->harvest_rec[1].start_dt = cnvtdatetime(start_dt)
   SET num_dates_found = (num_dates_found+ 1)
  ENDIF
  DECLARE stop_dt = vc
  SET stop_dt = cv_parse_data(parse_sep,parse_string,parse_pos)
  IF (size(stop_dt,1) > 0)
   SET cv_hrv_rec->harvest_rec[1].stop_dt = cnvtdatetime(stop_dt)
   SET num_dates_found = (num_dates_found+ 1)
  ENDIF
  CALL cv_log_message(build("Number of Dates::",num_dates_found))
  IF (num_dates_found=1
   AND size(stop_dt,1)=0)
   SET cv_hrv_rec->harvest_rec[1].stop_dt = cnvtdatetime(curdate,0)
  ENDIF
  IF (num_dates_found=0)
   SET date_range = cv_parse_data(parse_sep,parse_string,parse_pos)
   IF (size(date_range,1)=0)
    CALL cv_log_message("No Dates or Date Range specified")
    GO TO exit_script
   ELSE
    IF ( NOT (validate(request_date,0)))
     RECORD request_date(
       1 date_range[*]
         2 code_value = f8
         2 date_meaning = c12
         2 date_display = vc
         2 from_date_str = vc
         2 to_date_str = vc
         2 to_date = dq8
         2 from_date = dq8
     )
    ENDIF
    IF ( NOT (validate(reply_date,0)))
     RECORD reply_date(
       1 date_range[*]
         2 to_date_str = vc
         2 from_date_str = vc
         2 to_date = dq8
         2 from_date = dq8
         2 translated_val = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
    ENDIF
    SET stat = alterlist(request_date->date_range,1)
    SET dt_cnt = 0
    SET code14729 = uar_get_code_by("DISPLAYKEY",14729,cnvtupper(cnvtalphanum(date_range)))
    SET code25832 = uar_get_code_by("DISPLAYKEY",25832,cnvtupper(cnvtalphanum(date_range)))
    IF (code14729 >= 1
     AND code25832 >= 1)
     CALL cv_log_message(" Multiple Date Ranges Defined")
     GO TO exit_script
    ELSEIF (code14729 < 1
     AND code25832 < 1)
     SELECT INTO "NL:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set IN (14729, 25832)
        AND cv.display_key=cnvtupper(cnvtalphanum(date_range))
        AND cv.active_ind=1)
      DETAIL
       request_date->date_range[1].code_value = cv.code_value, dt_cnt = (dt_cnt+ 1)
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL cv_log_message("No Date Range Defined")
      GO TO exit_script
     ENDIF
     IF (dt_cnt > 1)
      CALL cv_log_message(" Multiple Date Ranges Defined")
      GO TO exit_script
     ENDIF
    ELSEIF (code14729 >= 1
     AND code25832 < 1)
     SET request_date->date_range[1].code_value = code14729
    ELSEIF (code14729 < 1
     AND code25832 >= 1)
     SET request_date->date_range[1].code_value = code25832
    ELSE
     CALL cv_log_message("Date Range Error")
     GO TO exit_script
    ENDIF
    EXECUTE cv_get_date_range  WITH replace(request,request_date), replace(reply,reply_date)
    SET cv_hrv_rec->harvest_rec[1].start_dt = reply_date->date_range[1].from_date
    SET cv_hrv_rec->harvest_rec[1].stop_dt = reply_date->date_range[1].to_date
   ENDIF
  ELSE
   SET date_range = cv_parse_data(parse_sep,parse_string,parse_pos)
  ENDIF
  DECLARE case_id_str = vc
  SET case_id_str = cv_parse_data(parse_sep,parse_string,parse_pos)
  IF (cnvtint(case_id_str) > 0)
   SET cv_hrv_rec->harvest_rec[1].case_id = cnvtint(case_id_str)
  ENDIF
 ENDIF
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
 SET cv_hrv_rec->harvest_display = build("Harvest for Facility Id =",cv_hrv_rec->harvest_rec[1].
  loc_facility_cd,"Dataset Id  =",cv_hrv_rec->harvest_rec[1].dataset_id,"Start Date =",
  format(cv_hrv_rec->harvest_rec[1].start_dt,"@SHORTDATE"),"End Date = ",format(cv_hrv_rec->
   harvest_rec[1].stop_dt,"@SHORTDATE"))
 CALL cv_log_message(build("cv_hrv_rec->harvest_display = ",cv_hrv_rec->harvest_display))
 SELECT INTO "nl:"
  FROM cv_dataset cd
  PLAN (cd
   WHERE (cd.dataset_id=cv_hrv_rec->harvest_rec[1].dataset_id)
    AND cd.dataset_id != 0.0)
  DETAIL
   cv_hrv_rec->dataset_id = cv_hrv_rec->harvest_rec[1].dataset_id, cv_hrv_rec->dataset_internal_name
    = cd.dataset_internal_name, cv_hrv_rec->validation_script = trim(cd.validation_script)
  WITH nocounter
 ;end select
 CALL cv_log_message(build("cv_hrv_rec->validation_script = ",cv_hrv_rec->validation_script))
 EXECUTE cv_get_harvest_data
 IF (cnvtupper(exit_after)="CV_GET_HARVEST_DATA")
  GO TO exit_script
 ENDIF
 EXECUTE cv_get_harvest_translate
 IF (cnvtupper(exit_after)="CV_GET_HARVEST_TRANSLATE")
  GO TO exit_script
 ENDIF
 IF ((cv_hrv_rec->dataset_internal_name="STS*"))
  EXECUTE cv_get_proc_type_sts
 ENDIF
 IF (cnvtupper(exit_after)="CV_GET_PROC_TYPE_STS")
  GO TO exit_script
 ENDIF
 DECLARE execute_algorithm = i2 WITH public, noconstant(0)
 SET execute_algorithm = getcvcontrol(cv_hrv_rec->harvest_rec[1].dataset_id,
  "CV_EXECUTE_ALGORITHM_IN_HARVEST")
 IF (execute_algorithm > 0)
  EXECUTE cv_get_process_algorithm
  IF (cnvtupper(exit_after)="CV_GET_PROCESS_ALGORITHM")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL parser(concat(cv_hrv_rec->validation_script," go"))
 IF (cnvtupper(exit_after)="CV_GET_HARVEST_VALIDATE")
  GO TO exit_script
 ENDIF
 EXECUTE cv_get_harvest_output
 IF (cnvtupper(exit_after)="CV_GET_HARVEST_OUTPUT")
  GO TO exit_script
 ENDIF
 EXECUTE cv_get_harvest_insert
#exit_script
 DECLARE cv_get_harvest_crsn = vc WITH private, constant("MOD 015 BM9013 02/22/06")
END GO
