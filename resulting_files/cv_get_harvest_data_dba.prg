CREATE PROGRAM cv_get_harvest_data:dba
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
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply  is already defined !")
 ELSE
  RECORD reply(
    1 files[*]
      2 file_name = vc
      2 lines[*]
        3 output_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(internal_cv_case,"notdefined") != "notdefined")
  CALL cv_log_message("Entering cv_get_harvest_data")
 ELSE
  RECORD internal_cv_case(
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
 SET stat = alterlist(internal_cv_case->harvest_rec,1)
 DECLARE blank = c1 WITH protect, constant(" ")
 DECLARE missing_row = vc WITH protect, constant("<blank>")
 DECLARE max_proc_data = i4 WITH protect
 DECLARE max_closdev_cnt = i4 WITH protect
 DECLARE max_icdev_cnt = i4 WITH protect
 DECLARE max_les_cnt = i4 WITH protect
 DECLARE abstr_idx = i4 WITH protect
 DECLARE case_idx = i4 WITH protect
 DECLARE max_lesion = i4 WITH protect
 DECLARE event_type_cd = f8 WITH protect
 DECLARE nomenclature_id = f8 WITH protect
 DECLARE result_cd = f8 WITH protect
 DECLARE event_cd = f8 WITH protect
 DECLARE icaseabstrcnt = i4 WITH protect
 DECLARE iprocount = i4 WITH protect
 DECLARE ilescnt = i4 WITH protect
 DECLARE iclosdevcnt = i4 WITH protect
 DECLARE iicdevcnt = i4 WITH protect
 DECLARE abstr_cnt = i4 WITH protect
 DECLARE abscnt = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE ilesabscnt = i4 WITH protect
 DECLARE iclosdevabscnt = i4 WITH protect
 DECLARE iicdevabscnt = i4 WITH protect
 DECLARE les_idx = i4 WITH protect
 DECLARE result_val = vc WITH protect
 DECLARE scase = vc WITH protect, constant("CASE")
 DECLARE bfailed = c1 WITH protect, noconstant("T")
 DECLARE abstr_size = i4 WITH protect
 DECLARE iprocedureabscnt = i4 WITH protect
 DECLARE maxprocabstrdata = i4 WITH protect
 DECLARE maxclosabstrdata = i4 WITH protect
 DECLARE itotal_proc = i4 WITH protect
 DECLARE lesion_flag = i2 WITH protect
 DECLARE closdev_flag = i2 WITH protect
 DECLARE icdev_flag = i2 WITH protect
 DECLARE ptca_oper_abstr_idx = i4 WITH protect
 SELECT INTO "NL:"
  sub_event_type_mean = uar_get_code_meaning(x.sub_event_type_cd)
  FROM cv_xref x,
   cv_response r,
   code_value cv
  PLAN (x
   WHERE (x.dataset_id=cv_hrv_rec->harvest_rec[1].dataset_id))
   JOIN (cv
   WHERE cv.code_value=x.event_type_cd)
   JOIN (r
   WHERE r.xref_id=outerjoin(x.xref_id)
    AND r.a1=outerjoin(missing_row))
  ORDER BY cv.collation_seq, cv.cdf_meaning, sub_event_type_mean
  HEAD REPORT
   iprocidx = 0, iprocedureabscnt = 0, iclosdevcnt = 0,
   iicdevcnt = 0, iprocount = 0
  HEAD cv.cdf_meaning
   IF (cv.cdf_meaning != scase)
    iprocount = (iprocount+ 1), iprocidx = iprocount, stat = alterlist(internal_cv_case->harvest_rec[
     1].proc_data,iprocount),
    internal_cv_case->harvest_rec[1].proc_data[iprocount].event_type_cd = x.event_type_cd
   ELSE
    iprocidx = 0
   ENDIF
   iprocedureabscnt = 0, ilescnt = 0
  HEAD sub_event_type_mean
   IF (sub_event_type_mean="LESION")
    ilescnt = (ilescnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].proc_data[iprocount].
     lesion,ilescnt)
   ELSEIF (sub_event_type_mean="CLOS_DEV")
    iclosdevcnt = (iclosdevcnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].closuredevice,
     iclosdevcnt)
   ELSEIF (sub_event_type_mean="LESION_DEV_D")
    iicdevcnt = (iicdevcnt+ 1)
    IF (size(internal_cv_case->harvest_rec[1].proc_data[iprocount].lesion,5) < ilescnt)
     stat = alterlist(internal_cv_case->harvest_rec[1].proc_data[iprocount].lesion,ilescnt)
    ENDIF
    stat = alterlist(internal_cv_case->harvest_rec[1].proc_data[iprocount].lesion[ilescnt].icdevice,
     iicdevcnt)
   ENDIF
  DETAIL
   abscnt = (abscnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].abstr_data,abscnt),
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].event_cd = x.event_cd,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].result_val = r.a1, internal_cv_case->
   harvest_rec[1].abstr_data[abscnt].nomenclature_id = r.nomenclature_id, internal_cv_case->
   harvest_rec[1].abstr_data[abscnt].task_assay_cd = x.task_assay_cd,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].display_field_ind = x.display_field_ind,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].task_assay_mean = uar_get_code_meaning(x
    .task_assay_cd), internal_cv_case->harvest_rec[1].abstr_data[abscnt].xref_id = x.xref_id,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].field_type_cd = x.field_type_cd,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].field_type_meaning = uar_get_code_meaning(x
    .field_type_cd), internal_cv_case->harvest_rec[1].abstr_data[abscnt].required_flag = x.reqd_flag,
   internal_cv_case->harvest_rec[1].abstr_data[abscnt].proc_data_idx = iprocidx, internal_cv_case->
   harvest_rec[1].abstr_data[abscnt].collect_start_dt_tm = x.collect_start_dt_tm, internal_cv_case->
   harvest_rec[1].abstr_data[abscnt].collect_stop_dt_tm = x.collect_stop_dt_tm
   CASE (cv.cdf_meaning)
    OF scase:
     CASE (sub_event_type_mean)
      OF "CLOS_DEV":
       iclosdevabscnt = (iclosdevabscnt+ 1),stat = alterlist(internal_cv_case->harvest_rec[1].
        closuredevice[iclosdevcnt].cd_abstr_data,iclosdevabscnt),internal_cv_case->harvest_rec[1].
       closuredevice[iclosdevcnt].cd_abstr_data[iclosdevabscnt].abstr_data_idx = abscnt,
       internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_closdev,
       closdev_flag = 1,
       CALL echo(abstr_type_closdev)
      ELSE
       icaseabstrcnt = (icaseabstrcnt+ 1),stat = alterlist(internal_cv_case->harvest_rec[1].
        case_abstr_data,icaseabstrcnt),internal_cv_case->harvest_rec[1].case_abstr_data[icaseabstrcnt
       ].abstr_data_idx = abscnt,
       IF (sub_event_type_mean != "ADMIT")
        internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_case
       ELSE
        internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_admit
       ENDIF
     ENDCASE
    ELSE
     itotal_proc = (itotal_proc+ 1),
     IF (size(trim(sub_event_type_mean))=0)
      iprocedureabscnt = (iprocedureabscnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].
       proc_data[iprocount].proc_abstr_data,iprocedureabscnt), internal_cv_case->harvest_rec[1].
      proc_data[iprocount].proc_abstr_data[iprocedureabscnt].abstr_data_idx = abscnt,
      internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_proc
     ELSEIF (sub_event_type_mean="LESION")
      ilesabscnt = (ilesabscnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].proc_data[
       iprocount].lesion[ilescnt].les_abstr_data,ilesabscnt), internal_cv_case->harvest_rec[1].
      proc_data[iprocount].lesion[ilescnt].les_abstr_data[ilesabscnt].abstr_data_idx = abscnt,
      internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_les,
      lesion_flag = 1
     ELSEIF (sub_event_type_mean="LESION_DEV_D")
      iicdevabscnt = (iicdevabscnt+ 1), stat = alterlist(internal_cv_case->harvest_rec[1].proc_data[
       iprocount].lesion[ilescnt].icdevice[iicdevcnt].icd_abstr_data,iicdevabscnt), internal_cv_case
      ->harvest_rec[1].proc_data[iprocount].lesion[ilescnt].icdevice[iicdevcnt].icd_abstr_data[
      iicdevabscnt].abstr_data_idx = abscnt,
      internal_cv_case->harvest_rec[1].abstr_data[abscnt].abstr_type_flag = abstr_type_icdev,
      icdev_flag = 1
     ENDIF
   ENDCASE
  FOOT REPORT
   itotal_proc = (itotal_proc - ((ilesabscnt+ iclosdevabscnt)+ iicdevabscnt)),
   CALL echo(build("total procedure data in template==>",itotal_proc))
   IF (maxprocabstrdata <= itotal_proc)
    maxprocabstrdata = itotal_proc
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_message("Error:Selection Failed at the Template Packing Level")
  SET bfailed = "F"
  GO TO exit_script
 ENDIF
 SET cv_hrv_rec->max_proc_data = iprocount
 CALL cv_log_message(build("IPROCEDUREABSCNT ::",iprocedureabscnt))
 CALL cv_log_message(build("iCaseAbstrCnt ::",icaseabstrcnt))
 CALL cv_log_message(build("internal AbsCnt ::",abscnt))
 CALL cv_log_message(build("Total_Proc ::",itotal_proc))
 CALL cv_log_message(build("iLesAbsCnt ::",ilesabscnt))
 CALL cv_log_message(build("iClosDevAbsCnt ::",iclosdevabscnt))
 CALL cv_log_message(build("iICDevAbsCnt ::",iicdevabscnt))
 CALL cv_log_message(build("iProcount ::",iprocount))
 DECLARE form_type_chk = i2 WITH protect
 DECLARE req_part_nbr = vc WITH protect
 DECLARE req_loc_fac_cd = vc WITH protect
 DECLARE req_start_dt = vc WITH protect
 DECLARE req_stop_dt = vc WITH protect
 DECLARE req_case_id = vc WITH protect
 DECLARE req_encntr_id = vc WITH protect
 SET req_case_id = "0=0"
 SET req_encntr_id = "0=0"
 SET req_start_dt = "0=0"
 SET req_stop_dt = "0=0"
 SET req_part_nbr = "0=0"
 SET req_loc_fac_cd = "0=0"
 SET req_encntr_id = "0=0"
 IF ((cv_hrv_rec->harvest_rec[1].encntr_id > 0.0))
  SET req_encntr_id = concat("c.encntr_id = ",cnvtstring(cv_hrv_rec->harvest_rec[1].encntr_id))
 ENDIF
 IF ((cv_hrv_rec->harvest_rec[1].case_id > 0.0))
  SET req_case_id = "c.cv_case_id = cv_hrv_rec->harvest_rec[1].case_id"
 ELSE
  SET req_start_dt = "0=0"
  IF ((cv_hrv_rec->harvest_rec[1].start_dt=cnvtdatetime(cnvtdate(00000000),0)))
   SET req_start_dt = "0=0"
  ELSE
   SET req_start_dt = concat("c.Pat_adm_dt_tm >= ",
    "CNVTDATETIME(cnvtdate(cv_hrv_rec->harvest_rec[1].start_dt),0 )")
  ENDIF
  SET req_stop_dt = "0=0"
  IF ((cv_hrv_rec->harvest_rec[1].stop_dt <= cnvtdatetime(cnvtdate(00000000),0)))
   SET req_stop_dt = "0=0"
  ELSE
   SET req_stop_dt = concat("c.Pat_disch_dt_tm <= ",
    "CNVTDATETIME(cnvtdate(cv_hrv_rec->harvest_rec[1].stop_dt),235959)")
  ENDIF
  SET req_part_nbr = "0=0"
  SET req_loc_fac_cd = "0=0"
  IF (size(trim(cv_hrv_rec->harvest_rec[1].participant_nbr)) > 0)
   SET req_part_nbr = concat("rltn.PARTICIPANT_NBR = ",
    "patstring(cv_hrv_rec->harvest_rec[1].participant_nbr)")
  ENDIF
  IF ((cv_hrv_rec->harvest_rec[1].loc_facility_cd > 0))
   SET req_loc_fac_cd = concat("c.hospital_cd = ","cv_hrv_rec->harvest_rec[1].loc_facility_cd")
  ENDIF
 ENDIF
 CALL cv_log_message(build("req_case_id   ::",req_case_id))
 CALL cv_log_message(build("req_start_dt  ::",req_start_dt))
 CALL cv_log_message(build("req_stop_dt   ::",req_stop_dt))
 CALL cv_log_message(build("req_part_nbr  ::",req_part_nbr))
 CALL cv_log_message(build("req_loc_fac_cd::",req_loc_fac_cd))
 CALL cv_log_message(build("req_encntr_id ::",req_encntr_id))
 CALL cv_log_message(build("dataset_id    ::",cv_hrv_rec->harvest_rec[1].dataset_id))
 SELECT INTO "NL:"
  form_type_mean = uar_get_code_meaning(c.form_type_cd)
  FROM cv_case_dataset_r rltn,
   cv_case c,
   cv_procedure proc,
   code_value cv,
   cv_lesion les,
   cv_device cdev
  PLAN (rltn
   WHERE (rltn.dataset_id=cv_hrv_rec->harvest_rec[1].dataset_id)
    AND parser(req_part_nbr)
    AND ((rltn.status_cd=0.0) OR ((cv_hrv_rec->dataset_internal_name="ACC03"))) )
   JOIN (c
   WHERE c.cv_case_id=rltn.cv_case_id
    AND parser(req_encntr_id)
    AND parser(req_case_id)
    AND parser(req_loc_fac_cd)
    AND parser(req_start_dt)
    AND parser(req_stop_dt))
   JOIN (proc
   WHERE ((proc.cv_case_id=c.cv_case_id) OR (proc.procedure_id=0.0)) )
   JOIN (cv
   WHERE cv.code_value=proc.event_type_cd)
   JOIN (les
   WHERE ((les.procedure_id=proc.procedure_id) OR (les.lesion_id=0.0)) )
   JOIN (cdev
   WHERE ((cdev.lesion_id=les.lesion_id
    AND cdev.lesion_id > 0.0) OR (((cdev.cv_case_id=c.cv_case_id
    AND proc.procedure_id=0.0
    AND cdev.cv_case_id > 0.0) OR (cdev.device_id=0.0)) )) )
  ORDER BY form_type_mean, c.case_dt_tm, c.cv_case_id,
   cv.cdf_meaning, les.lesion_id, cdev.device_id
  HEAD REPORT
   proc_idx = 0, case_idx = 0, les_idx = 0,
   max_lesion = 0, max_les_cnt = 0, max_proc_data = 0,
   icdev_idx = 0, max_icdev = 0, max_icdev_cnt = 0,
   closdev_idx = 0, max_closdev = 0, max_closdev_cnt = 0,
   max_proc_data = 0,
   CALL cv_log_message("head report"), lab_form_cnt = 0,
   admit_form_cnt = 0, case_abstr_size = size(internal_cv_case->harvest_rec[1].case_abstr_data,5)
  HEAD c.cv_case_id
   CALL echo("Begin Head Case Idx"), proc_idx = 0, case_idx = (case_idx+ 1),
   closdev_idx = 0, stat = alterlist(cv_hrv_rec->harvest_rec,case_idx), abstr_size = size(cv_hrv_rec
    ->harvest_rec[case_idx].abstr_data,5),
   CALL cv_log_message(build("Abstr_size using 5",abstr_size)),
   CALL cv_log_message(build("Case_idx ",case_idx)),
   CALL cv_log_message(build("Abstr_size",abstr_size)),
   CALL cv_log_message(build("case_abstr_size",case_abstr_size)), cv_hrv_rec->harvest_rec[case_idx].
   case_id = c.cv_case_id, cv_hrv_rec->harvest_rec[case_idx].case_dataset_r_id = rltn
   .case_dataset_r_id,
   cv_hrv_rec->harvest_rec[case_idx].registry_nbr = rltn.registry_nbr, cv_hrv_rec->harvest_rec[
   case_idx].person_id = c.person_id, cv_hrv_rec->harvest_rec[case_idx].encntr_id = c.encntr_id,
   cv_hrv_rec->harvest_rec[case_idx].disch_dt_tm = c.pat_disch_dt_tm, cv_hrv_rec->harvest_rec[
   case_idx].admit_dt_tm = c.pat_adm_dt_tm, cv_hrv_rec->harvest_rec[case_idx].participant_nbr = rltn
   .participant_nbr,
   cv_hrv_rec->harvest_rec[case_idx].top_parent_event_id = c.form_event_id, cv_hrv_rec->harvest_rec[
   case_idx].form_id = c.form_id, cv_hrv_rec->harvest_rec[case_idx].form_type_mean = form_type_mean,
   CALL cv_log_message(build("c.form_event_id:",c.form_event_id)),
   CALL addcase(0)
   IF (form_type_mean="LABVISIT")
    lab_form_cnt = (lab_form_cnt+ 1)
   ENDIF
   IF (form_type_mean="ADMIT")
    IF (admit_form_cnt=0)
     cv_hrv_rec->admit_form_idx = case_idx
    ENDIF
    admit_form_cnt = (admit_form_cnt+ 1)
   ENDIF
  HEAD cv.cdf_meaning
   IF (proc.procedure_id > 0.0)
    les_idx = 0
    FOR (cur_proc_idx = 1 TO size(cv_hrv_rec->harvest_rec[case_idx].proc_data,5))
      IF ((cv_hrv_rec->harvest_rec[case_idx].proc_data[cur_proc_idx].event_type_cd=proc.event_type_cd
      ))
       proc_idx = cur_proc_idx, cur_proc_idx = (size(cv_hrv_rec->harvest_rec[case_idx].proc_data,5)+
       1)
      ENDIF
    ENDFOR
    IF (proc_idx > size(internal_cv_case->harvest_rec[1].proc_data,5))
     proc_idx = iprocount
    ENDIF
    cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].event_type_cd = proc.event_type_cd,
    cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].proc_physician_id = proc.proc_physic_id,
    cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].proc_start_dt_tm = proc.proc_start_dt_tm,
    cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].proc_end_dt_tm = proc.proc_end_dt_tm,
    cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].case_id = proc.cv_case_id, cv_hrv_rec->
    harvest_rec[case_idx].proc_data[proc_idx].proc_id = proc.procedure_id
   ENDIF
  HEAD les.lesion_id
   icdev_idx = 0
   IF (les.lesion_id > 0.0)
    les_idx = (les_idx+ 1),
    CALL add_lesion(case_idx,proc_idx,les_idx), cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx]
    .lesion[les_idx].lesion_id = les.lesion_id
   ENDIF
  HEAD cdev.device_id
   IF (cdev.device_id > 0.0)
    IF (les.lesion_id=clos_dev_lesion)
     closdev_idx = (closdev_idx+ 1),
     CALL add_closdevice(case_idx,closdev_idx), cv_hrv_rec->harvest_rec[case_idx].closuredevice[
     closdev_idx].device_id = cdev.device_id
    ELSE
     icdev_idx = (icdev_idx+ 1),
     CALL add_icdevice(case_idx,proc_idx,les_idx,icdev_idx), cv_hrv_rec->harvest_rec[case_idx].
     proc_data[proc_idx].lesion[les_idx].icdevice[icdev_idx].device_id = cdev.device_id
    ENDIF
   ENDIF
  DETAIL
   col 0
  FOOT  cdev.device_id
   col 0
  FOOT  les.lesion_id
   IF (icdev_idx > max_icdev_cnt)
    max_icdev_cnt = icdev_idx, max_icdev = max_icdev_cnt
   ENDIF
  FOOT  cv.cdf_meaning
   IF (les_idx > max_les_cnt)
    max_les_cnt = les_idx, max_lesion = max_les_cnt
   ENDIF
   IF (proc_idx > max_proc_data)
    max_proc_data = proc_idx, les_idx = 0
   ENDIF
  FOOT  c.cv_case_id
   IF (closdev_idx > max_closdev_cnt)
    max_closdev_cnt = closdev_idx, max_closdev = max_closdev_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_message(concat("Error!!!!!'Summary Tables' First selection ",
    " after building the Template failed"))
  CALL cv_log_message(build("req_case_id   ::",cv_hrv_rec->harvest_rec[1].case_id))
  CALL cv_log_message(build("req_start_dt  ::",req_start_dt))
  CALL cv_log_message(build("req_stop_dt   ::",req_stop_dt))
  CALL cv_log_message(build("req_part_nbr  ::",req_part_nbr))
  CALL cv_log_message(build("req_loc_fac_cd::",req_loc_fac_cd))
  CALL cv_log_message(build("req_encntr_id ::",req_encntr_id))
  CALL cv_log_message(build("dataset_id    ::",cv_hrv_rec->harvest_rec[1].dataset_id))
  SET bfailed = "F"
  GO TO exit_script
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 SET cv_hrv_rec->max_lesion = max_lesion
 SET cv_hrv_rec->max_closdev = max_closdev_cnt
 SET cv_hrv_rec->max_icdev = max_icdev_cnt
 CALL cv_log_message(build("Maximum Lesion Id is ::",max_lesion))
 DECLARE maxcaseabstrdata = i4 WITH protect, noconstant(size(internal_cv_case->harvest_rec[1].
   case_abstr_data,5))
 SET icaseabstrcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(maxcaseabstrdata)),
   cv_case_abstr_data ccad
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].case_abstr_data,5))
   JOIN (ccad
   WHERE (ccad.cv_case_id=cv_hrv_rec->harvest_rec[d1.seq].case_id)
    AND (ccad.event_cd=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[cv_hrv_rec->harvest_rec[d1.seq].
   case_abstr_data[d2.seq].abstr_data_idx].event_cd)
    AND  NOT ( EXISTS (
   (SELECT
    a.algorithm_id
    FROM cv_algorithm a,
     discrete_task_assay dta
    WHERE dta.event_cd=ccad.event_cd
     AND a.result_dta_cd=dta.task_assay_cd))))
  DETAIL
   icaseabstrcnt = (icaseabstrcnt+ 1), abstr_cnt = cv_hrv_rec->harvest_rec[d1.seq].case_abstr_data[d2
   .seq].abstr_data_idx, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].nomenclature_id = ccad
   .nomenclature_id,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].abstr_data_id = ccad.case_abstr_data_id,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].abstr_data_name = "CV_CASE_ABSTR_DATA",
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].case_id = cv_hrv_rec->harvest_rec[d1.seq].
   case_id
   IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].display_field_ind=1))
    cv_hrv_rec->harvest_rec[d1.seq].case_display = concat(cv_hrv_rec->harvest_rec[d1.seq].
     case_display,ccad.result_val)
   ENDIF
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].result_val = ccad.result_val
   IF (ccad.result_cd > 0)
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].result_id = ccad.result_cd, cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[abstr_cnt].result_source = "CODE_VALUE"
   ENDIF
   IF (ccad.result_id > 0)
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].result_id = ccad.result_id, cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[abstr_cnt].result_source = ccad.result_source
   ENDIF
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_cnt].result_dt_tm = ccad.result_dt_tm
  WITH nocounter
 ;end select
 IF (maxcaseabstrdata <= icaseabstrcnt)
  SET maxcaseabstrdata = icaseabstrcnt
 ENDIF
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("!!!!!!! Case Abstract selection failed")
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"CER_TEMP:CVHRVBEF.dat")
 SELECT INTO "NL:"
  FROM (dummyt d3  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d4  WITH seq = value(max_proc_data)),
   (dummyt d5  WITH seq = value(maxprocabstrdata)),
   cv_proc_abstr_data cpad
  PLAN (d3)
   JOIN (d4
   WHERE d4.seq <= size(cv_hrv_rec->harvest_rec[d3.seq].proc_data,5))
   JOIN (d5
   WHERE d5.seq <= size(cv_hrv_rec->harvest_rec[d3.seq].proc_data[d4.seq].proc_abstr_data,5))
   JOIN (cpad
   WHERE (cpad.procedure_id=cv_hrv_rec->harvest_rec[d3.seq].proc_data[d4.seq].proc_id)
    AND (cpad.event_cd=cv_hrv_rec->harvest_rec[d3.seq].abstr_data[cv_hrv_rec->harvest_rec[d3.seq].
   proc_data[d4.seq].proc_abstr_data[d5.seq].abstr_data_idx].event_cd))
  HEAD REPORT
   iprocabstrcnt = 0
  DETAIL
   iprocabstrcnt = (iprocabstrcnt+ 1), this_abstr_idx = cv_hrv_rec->harvest_rec[d3.seq].proc_data[d4
   .seq].proc_abstr_data[d5.seq].abstr_data_idx, cv_hrv_rec->harvest_rec[d3.seq].proc_data[d4.seq].
   proc_abstr_data[d5.seq].nbr_filled_fields = iprocabstrcnt,
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].nomenclature_id = cpad.nomenclature_id,
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].abstr_data_id = cpad.proc_abstr_data_id,
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].abstr_data_name = "CV_PROC_ABSTR_DATA",
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].procedure_id = cv_hrv_rec->harvest_rec[
   d3.seq].proc_data[d4.seq].proc_id
   IF ((cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].display_field_ind=1))
    cv_hrv_rec->harvest_rec[d3.seq].proc_data[d4.seq].event_type_display = concat(cv_hrv_rec->
     harvest_rec[d3.seq].proc_data[d4.seq].event_type_display,cpad.result_val)
   ENDIF
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].event_cd = cpad.event_cd, cv_hrv_rec->
   harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_val = cpad.result_val
   IF (cpad.result_cd > 0.0)
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_id = cpad.result_cd, cv_hrv_rec
    ->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_source = "CODE_VALUE"
   ENDIF
   IF (cpad.result_id > 0.0)
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_id = cpad.result_id, cv_hrv_rec
    ->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_source = cpad.result_source
   ENDIF
   cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_dt_tm = cpad.result_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_message("Selection Failed at the procedure Abstract data level")
 ENDIF
 CALL echorecord(cv_hrv_rec,"CER_TEMP:CVHRVAFT.dat")
 IF (lesion_flag=1)
  DECLARE maxlesdevabstrdata = i4 WITH protect, noconstant(ilesabscnt)
  CALL echo(build(size(cv_hrv_rec->harvest_rec,5),":",max_proc_data,":",max_les_cnt,
    ":",maxlesdevabstrdata))
  SELECT INTO "NL:"
   FROM (dummyt d6  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d7  WITH seq = value(max_proc_data)),
    (dummyt d8  WITH seq = value(max_les_cnt)),
    (dummyt d9  WITH seq = value(maxlesdevabstrdata)),
    cv_les_abstr_data labstr
   PLAN (d6)
    JOIN (d7
    WHERE d7.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data,5))
    JOIN (d8
    WHERE d8.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion,5))
    JOIN (d9
    WHERE d9.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].
     les_abstr_data,5))
    JOIN (labstr
    WHERE (labstr.lesion_id=cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].
    lesion_id)
     AND (labstr.event_cd=cv_hrv_rec->harvest_rec[d6.seq].abstr_data[cv_hrv_rec->harvest_rec[d6.seq].
    proc_data[d7.seq].lesion[d8.seq].les_abstr_data[d9.seq].abstr_data_idx].event_cd))
   HEAD REPORT
    ilesabstrcnt = 0
   DETAIL
    ilesabstrcnt = (ilesabstrcnt+ 1), abstr_idx = cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].
    lesion[d8.seq].les_abstr_data[d9.seq].abstr_data_idx, cv_hrv_rec->harvest_rec[d6.seq].proc_data[
    d7.seq].lesion[d8.seq].les_abstr_data[d9.seq].nbr_filled_fields = ilesabstrcnt,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].lesion_id = cv_hrv_rec->harvest_rec[d6.seq]
    .proc_data[d7.seq].lesion[d8.seq].lesion_id
    IF ((cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].display_field_ind=1))
     cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].lesion_display = concat(
      cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].lesion_display,labstr
      .result_val)
    ENDIF
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].nomenclature_id = labstr.nomenclature_id,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_val = labstr.result_val, cv_hrv_rec
    ->harvest_rec[d6.seq].abstr_data[abstr_idx].abstr_data_id = labstr.les_abstr_data_id,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].abstr_data_name = "CV_LES_ABSTR_DATA"
    IF (labstr.result_cd > 0.0)
     cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_id = labstr.result_cd, cv_hrv_rec->
     harvest_rec[d6.seq].abstr_data[abstr_idx].result_source = "CODE_VALUE"
    ENDIF
    IF (labstr.result_id > 0.0)
     cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_cnt].result_id = labstr.result_id, cv_hrv_rec->
     harvest_rec[d6.seq].abstr_data[abstr_cnt].result_source = labstr.result_source
    ENDIF
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_dt_tm = labstr.result_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message("Select failed at the Lesion_abstract_data level")
  ENDIF
 ENDIF
 IF (closdev_flag=1)
  CALL echo("inside closure device abstract")
  SET maxclosabstrdata = iclosdevabscnt
  CALL echo(build("max_closdev_cnt==========>",max_closdev_cnt))
  SELECT INTO "NL:"
   FROM (dummyt d3  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d4  WITH seq = value(max_closdev_cnt)),
    (dummyt d5  WITH seq = value(maxclosabstrdata)),
    cv_dev_abstr_data dabstr
   PLAN (d3)
    JOIN (d4
    WHERE d4.seq <= size(cv_hrv_rec->harvest_rec[d3.seq].closuredevice,5))
    JOIN (d5
    WHERE d5.seq <= size(cv_hrv_rec->harvest_rec[d3.seq].closuredevice[d4.seq].cd_abstr_data,5))
    JOIN (dabstr
    WHERE (dabstr.device_id=cv_hrv_rec->harvest_rec[d3.seq].closuredevice[d4.seq].device_id)
     AND (dabstr.event_cd=cv_hrv_rec->harvest_rec[d3.seq].abstr_data[cv_hrv_rec->harvest_rec[d3.seq].
    closuredevice[d4.seq].cd_abstr_data[d5.seq].abstr_data_idx].event_cd))
   HEAD REPORT
    iclosabstrcnt = 0
   DETAIL
    iclosabstrcnt = (iclosabstrcnt+ 1), this_abstr_idx = cv_hrv_rec->harvest_rec[d3.seq].
    closuredevice[d4.seq].cd_abstr_data[d5.seq].abstr_data_idx, cv_hrv_rec->harvest_rec[d3.seq].
    closuredevice[d4.seq].cd_abstr_data[d5.seq].nbr_filled_fields = iclosabstrcnt,
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].nomenclature_id = dabstr
    .nomenclature_id, cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_val = dabstr
    .result_val, cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].abstr_data_id = dabstr
    .dev_abstr_data_id,
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].abstr_data_name = "CV_CLOS_ABSTR_DATA",
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].device_id = cv_hrv_rec->harvest_rec[d3
    .seq].closuredevice[d4.seq].device_id
    IF ((cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].display_field_ind=1))
     cv_hrv_rec->harvest_rec[d3.seq].closuredevice[d4.seq].device_display = concat(cv_hrv_rec->
      harvest_rec[d3.seq].closuredevice[d4.seq].device_display,dabstr.result_val)
    ENDIF
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].event_cd = dabstr.event_cd
    IF (dabstr.result_cd > 0.0)
     cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_id = dabstr.result_cd,
     cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_source = "CODE_VALUE"
    ENDIF
    IF (dabstr.result_id > 0.0)
     cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_id = dabstr.result_id,
     cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_source = dabstr.result_source
    ENDIF
    cv_hrv_rec->harvest_rec[d3.seq].abstr_data[this_abstr_idx].result_dt_tm = dabstr.result_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message("Selection Failed at the Closure Abstract data level")
  ENDIF
 ENDIF
 IF (icdev_flag=1)
  DECLARE maxicdevabstrdata = i4 WITH protect, noconstant(iicdevabscnt)
  SELECT INTO "NL:"
   FROM (dummyt d6  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d7  WITH seq = value(max_proc_data)),
    (dummyt d8  WITH seq = value(max_les_cnt)),
    (dummyt d10  WITH seq = value(max_icdev_cnt)),
    (dummyt d11  WITH seq = value(maxicdevabstrdata)),
    cv_dev_abstr_data dabstr
   PLAN (d6)
    JOIN (d7
    WHERE d7.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data,5))
    JOIN (d8
    WHERE d8.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion,5))
    JOIN (d10
    WHERE d10.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].icdevice,5
     ))
    JOIN (d11
    WHERE d11.seq <= size(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].icdevice[
     d10.seq].icd_abstr_data,5))
    JOIN (dabstr
    WHERE (dabstr.device_id=cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].
    icdevice[d10.seq].device_id)
     AND (dabstr.event_cd=cv_hrv_rec->harvest_rec[d6.seq].abstr_data[cv_hrv_rec->harvest_rec[d6.seq].
    proc_data[d7.seq].lesion[d8.seq].icdevice[d10.seq].icd_abstr_data[d11.seq].abstr_data_idx].
    event_cd))
   HEAD REPORT
    iicdevabstrcnt = 0
   DETAIL
    iicdevabstrcnt = (iicdevabstrcnt+ 1), abstr_idx = cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7
    .seq].lesion[d8.seq].icdevice[d10.seq].icd_abstr_data[d11.seq].abstr_data_idx, cv_hrv_rec->
    harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].icdevice[d10.seq].icd_abstr_data[d11.seq].
    nbr_filled_fields = iicdevabstrcnt,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].lesion_id = cv_hrv_rec->harvest_rec[d6.seq]
    .proc_data[d7.seq].lesion[d8.seq].lesion_id, cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx
    ].device_id = cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].icdevice[d10.seq].
    device_id
    IF ((cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].display_field_ind=1))
     cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].icdevice[d10.seq].
     device_display = concat(cv_hrv_rec->harvest_rec[d6.seq].proc_data[d7.seq].lesion[d8.seq].
      icdevice[d10.seq].device_display,dabstr.result_val)
    ENDIF
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].nomenclature_id = dabstr.nomenclature_id,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_val = dabstr.result_val, cv_hrv_rec
    ->harvest_rec[d6.seq].abstr_data[abstr_idx].abstr_data_id = dabstr.dev_abstr_data_id,
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].abstr_data_name = "IC_DEV_ABSTR_DATA"
    IF (dabstr.result_cd > 0.0)
     cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_id = dabstr.result_cd, cv_hrv_rec->
     harvest_rec[d6.seq].abstr_data[abstr_idx].result_source = "CODE_VALUE"
    ENDIF
    IF (dabstr.result_id > 0.0)
     cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_cnt].result_id = dabstr.result_id, cv_hrv_rec->
     harvest_rec[d6.seq].abstr_data[abstr_cnt].result_source = dabstr.result_source
    ENDIF
    cv_hrv_rec->harvest_rec[d6.seq].abstr_data[abstr_idx].result_dt_tm = dabstr.result_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_message("Select failed at the device_abstract_data level")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  organization_id = cv_hrv_rec->harvest_rec[d10.seq].organization_id, encntr_id = cv_hrv_rec->
  harvest_rec[d10.seq].encntr_id
  FROM (dummyt d10  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   encounter e
  PLAN (d10)
   JOIN (e
   WHERE (e.encntr_id=cv_hrv_rec->harvest_rec[d10.seq].encntr_id))
  DETAIL
   cv_hrv_rec->harvest_rec[d10.seq].organization_id = e.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("WARNING!! Selecting Org_id from encounter table failed")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d10  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d11  WITH seq = value(cv_hrv_rec->max_abstr_data))
  PLAN (d10)
   JOIN (d11
   WHERE d11.seq <= size(cv_hrv_rec->harvest_rec[d10.seq].abstr_data,5))
  DETAIL
   CASE (cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].field_type_meaning)
    OF csm_field_type_fname:
    OF csm_field_type_mname:
    OF csm_field_type_lname:
    OF csm_field_type_ssn:
    OF csm_field_type_ssn_cc:
    OF csm_field_type_birth_date:
    OF csm_field_type_sex:
    OF csm_field_type_race:
    OF csm_field_type_patientage:
    OF csm_field_type_mrn:
    OF csm_field_type_patientzip:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_id = cv_hrv_rec->harvest_rec[d10.seq
     ].person_id,cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_source = "PERSON"
    OF csm_field_type_hosp:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_id = cv_hrv_rec->harvest_rec[d10.seq
     ].encntr_id,cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_source = "ENCOUNTER"
    OF csm_field_type_regdate:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_dt_tm = cv_hrv_rec->harvest_rec[d10
     .seq].admit_dt_tm
    OF csm_field_type_dischdate:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_dt_tm = cv_hrv_rec->harvest_rec[d10
     .seq].disch_dt_tm
    OF csm_field_type_part_nbr:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_val = cv_hrv_rec->harvest_rec[d10
     .seq].participant_nbr
    OF csm_field_type_patientid:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_val = cnvtstring(cv_hrv_rec->
      harvest_rec[d10.seq].person_id)
    OF csm_field_type_recordid:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_val = cnvtstring(cv_hrv_rec->
      harvest_rec[d10.seq].registry_nbr)
    OF csm_field_type_hospzip:
    OF csm_field_type_hospstate:
     cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_id = cv_hrv_rec->harvest_rec[d10.seq
     ].organization_id,cv_hrv_rec->harvest_rec[d10.seq].abstr_data[d11.seq].result_source =
     "ORGANIZATION"
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_message("Demographic data selection failed")
 ENDIF
 SELECT INTO "nl:"
  r.response_internal_name, r.a4, person_id = cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d14.seq].
  result_id
  FROM (dummyt d12  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d13  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   (dummyt d14  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_response r
  PLAN (d12)
   JOIN (d13
   WHERE d13.seq <= size(cv_hrv_rec->harvest_rec[d12.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d13.seq].field_type_meaning IN (
   csm_field_type_prsnl_ssn, csm_field_type_prsnl_upin)))
   JOIN (r
   WHERE (r.xref_id=cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d13.seq].xref_id))
   JOIN (d14
   WHERE d14.seq <= size(cv_hrv_rec->harvest_rec[d12.seq].abstr_data,5)
    AND trim(cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d14.seq].task_assay_mean)=trim(r.a4))
  DETAIL
   cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d13.seq].result_id = cv_hrv_rec->harvest_rec[d12.seq].
   abstr_data[d14.seq].result_id, cv_hrv_rec->harvest_rec[d12.seq].abstr_data[d13.seq].result_source
    = "PERSON"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_message("Person_id Selection for Personal SSN failed")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   cv_dataset cv,
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
  PLAN (d1
   WHERE (cv_hrv_rec->harvest_rec[d1.seq].form_type_mean != "ADMIT"))
   JOIN (cv
   WHERE (cv.dataset_id=cv_hrv_rec->harvest_rec[1].dataset_id))
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean))=cnvtupper
   (trim(cv.case_date_mean)))
  DETAIL
   cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
   result_dt_tm,
   CALL echo(build("case_dt_tm = ",cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("WARNING!!!case_dt_tm needed for age calculation failed")
 ENDIF
 EXECUTE cv_get_harvest_demog_data
 SUBROUTINE addcase(dummy)
   SET this_abstr_data_idx = 0
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].case_abstr_data,case_abstr_size)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,case_abstr_size)
   SET qualxrefcnt = 0
   CALL echo(build("patadmit=>",format(cv_hrv_rec->harvest_rec[case_idx].admit_dt_tm,"@SHORTDATETIME"
      )))
   IF (form_type_mean="ADMIT")
    SET form_type_chk = 1
   ELSEIF (form_type_mean="LABVISIT")
    SET form_type_chk = 2
   ELSE
    SET form_type_chk = 0
   ENDIF
   FOR (idx = 1 TO case_abstr_size)
     SET internal_idx = internal_cv_case->harvest_rec[1].case_abstr_data[idx].abstr_data_idx
     CALL echo(build("Testing item:",internal_cv_case->harvest_rec[1].abstr_data[idx].abstr_type_flag,
       ":",internal_cv_case->harvest_rec[1].abstr_data[internal_idx].field_type_meaning,":",
       internal_cv_case->harvest_rec[1].abstr_data[internal_idx].task_assay_mean,"=",internal_cv_case
       ->harvest_rec[1].abstr_data[internal_idx].result_val,":"))
     CALL echo(build("COLLECT RANGE:",format(internal_cv_case->harvest_rec[1].abstr_data[internal_idx
        ].collect_start_dt_tm,"@SHORTDATETIME"),"==>",format(internal_cv_case->harvest_rec[1].
        abstr_data[internal_idx].collect_stop_dt_tm,"@SHORTDATETIME")))
     IF ((((internal_cv_case->harvest_rec[1].abstr_data[internal_idx].collect_start_dt_tm=null)) OR (
     (((internal_cv_case->harvest_rec[1].abstr_data[internal_idx].collect_stop_dt_tm=null)) OR ((
     cv_hrv_rec->harvest_rec[case_idx].admit_dt_tm BETWEEN internal_cv_case->harvest_rec[1].
     abstr_data[internal_idx].collect_start_dt_tm AND internal_cv_case->harvest_rec[1].abstr_data[
     internal_idx].collect_stop_dt_tm))) ))
      AND ((form_type_chk=0) OR (((form_type_chk=1
      AND (internal_cv_case->harvest_rec[1].abstr_data[internal_idx].abstr_type_flag=abstr_type_admit
     )) OR (form_type_chk=2
      AND (internal_cv_case->harvest_rec[1].abstr_data[internal_idx].abstr_type_flag !=
     abstr_type_admit))) )) )
      CALL echo("Adding item")
      SET qualxrefcnt = (qualxrefcnt+ 1)
      SET this_abstr_data_idx = (abstr_size+ qualxrefcnt)
      SET cv_hrv_rec->harvest_rec[case_idx].case_abstr_data[this_abstr_data_idx].abstr_data_idx =
      this_abstr_data_idx
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].result_val =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].result_val
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].nomenclature_id =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].nomenclature_id
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].xref_id =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].xref_id
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].task_assay_cd =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].task_assay_cd
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].task_assay_mean =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].task_assay_mean
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].event_cd =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].event_cd
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].abstr_type_flag =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].abstr_type_flag
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].required_flag =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].required_flag
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].abstr_idx =
      this_abstr_data_idx
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].display_field_ind =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].display_field_ind
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].field_type_cd =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].field_type_cd
      SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[this_abstr_data_idx].field_type_meaning =
      internal_cv_case->harvest_rec[1].abstr_data[internal_idx].field_type_meaning
     ENDIF
   ENDFOR
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].case_abstr_data,qualxrefcnt)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,qualxrefcnt)
   SET abstr_data_size = size(cv_hrv_rec->harvest_rec[case_idx].abstr_data,5)
   IF (form_type_mean != "ADMIT")
    SET this_proc_idx = 0
    SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data,size(internal_cv_case->
      harvest_rec[1].proc_data,5))
    FOR (this_idx = 1 TO size(internal_cv_case->harvest_rec[1].proc_data,5))
      SET cv_hrv_rec->harvest_rec[case_idx].proc_data[this_idx].event_type_cd = internal_cv_case->
      harvest_rec[1].proc_data[this_idx].event_type_cd
      SET this_proc_abstr_size = size(internal_cv_case->harvest_rec[1].proc_data[this_idx].
       proc_abstr_data,5)
      SET cur_abstr_idx = abstr_data_size
      SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data[this_idx].proc_abstr_data,
       this_proc_abstr_size)
      SET abstr_data_size = (abstr_data_size+ this_proc_abstr_size)
      SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,abstr_data_size)
      FOR (cnt = 1 TO this_proc_abstr_size)
        SET cur_abstr_idx = (cur_abstr_idx+ 1)
        SET cur_proc_abstr_idx = internal_cv_case->harvest_rec[1].proc_data[this_idx].
        proc_abstr_data[cnt].abstr_data_idx
        SET cv_hrv_rec->harvest_rec[case_idx].proc_data[this_idx].proc_abstr_data[cnt].abstr_data_idx
         = cur_abstr_idx
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].abstr_idx = cnt
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].proc_data_idx = this_idx
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].lesion_data_idx = 0
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].dev_idx = 0
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].result_val = internal_cv_case
        ->harvest_rec[1].abstr_data[cur_proc_abstr_idx].result_val
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].nomenclature_id =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].nomenclature_id
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].event_cd = internal_cv_case->
        harvest_rec[1].abstr_data[cur_proc_abstr_idx].event_cd
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].task_assay_cd =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].task_assay_cd
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].task_assay_mean =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].task_assay_mean
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].xref_id = internal_cv_case->
        harvest_rec[1].abstr_data[cur_proc_abstr_idx].xref_id
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].abstr_type_flag =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].abstr_type_flag
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].required_flag =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].required_flag
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].field_type_cd =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].field_type_cd
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].field_type_meaning =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].field_type_meaning
        SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[cur_abstr_idx].display_field_ind =
        internal_cv_case->harvest_rec[1].abstr_data[cur_proc_abstr_idx].display_field_ind
      ENDFOR
    ENDFOR
   ENDIF
   IF ((cv_hrv_rec->max_abstr_data < abstr_data_size))
    SET cv_hrv_rec->max_abstr_data = abstr_data_size
   ENDIF
 END ;Subroutine
 SUBROUTINE copy_abstr_from_template(case_idx,abstr_data_size,this_abstr_data_idx)
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].xref_id = internal_cv_case->
   harvest_rec[1].abstr_data[this_abstr_data_idx].xref_id
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].result_val = internal_cv_case->
   harvest_rec[1].abstr_data[this_abstr_data_idx].result_val
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].nomenclature_id =
   internal_cv_case->harvest_rec[1].abstr_data[this_abstr_data_idx].nomenclature_id
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].event_cd = internal_cv_case->
   harvest_rec[1].abstr_data[this_abstr_data_idx].event_cd
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].task_assay_cd = internal_cv_case
   ->harvest_rec[1].abstr_data[this_abstr_data_idx].task_assay_cd
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].task_assay_mean =
   internal_cv_case->harvest_rec[1].abstr_data[this_abstr_data_idx].task_assay_mean
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].abstr_type_flag =
   internal_cv_case->harvest_rec[1].abstr_data[this_abstr_data_idx].abstr_type_flag
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].required_flag = internal_cv_case
   ->harvest_rec[1].abstr_data[this_abstr_data_idx].required_flag
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].field_type_cd = internal_cv_case
   ->harvest_rec[1].abstr_data[this_abstr_data_idx].field_type_cd
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].field_type_meaning =
   internal_cv_case->harvest_rec[1].abstr_data[this_abstr_data_idx].field_type_meaning
   SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].display_field_ind =
   internal_cv_case->harvest_rec[1].abstr_data[this_abstr_data_idx].display_field_ind
 END ;Subroutine
 SUBROUTINE add_lesion(case_idx,proc_idx,les_idx)
   CALL cv_log_message(build("Begin Add Lesion Case Idx::",case_idx,"ProcIdx::",proc_idx,"LesIdx::",
     les_idx))
   SET abstr_data_size = size(cv_hrv_rec->harvest_rec[case_idx].abstr_data,5)
   SET les_abstr_data_size = size(internal_cv_case->harvest_rec[1].proc_data[proc_idx].lesion[1].
    les_abstr_data,5)
   CALL cv_log_message(build("abstr_data_size:",abstr_data_size," les_abstr_data_size:",
     les_abstr_data_size))
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,(abstr_data_size+
    les_abstr_data_size))
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion,les_idx)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion[les_idx].
    les_abstr_data,les_abstr_data_size)
   FOR (cnt = 1 TO les_abstr_data_size)
     SET abstr_data_size = (abstr_data_size+ 1)
     SET cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion[les_idx].les_abstr_data[cnt].
     abstr_data_idx = abstr_data_size
     SET this_abstr_data_idx = internal_cv_case->harvest_rec[1].proc_data[proc_idx].lesion[1].
     les_abstr_data[cnt].abstr_data_idx
     CALL copy_abstr_from_template(case_idx,abstr_data_size,this_abstr_data_idx)
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].abstr_idx = cnt
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].proc_data_idx = proc_idx
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].lesion_data_idx = les_idx
   ENDFOR
   IF ((cv_hrv_rec->max_abstr_data < abstr_data_size))
    SET cv_hrv_rec->max_abstr_data = abstr_data_size
   ENDIF
 END ;Subroutine
 SUBROUTINE add_icdevice(case_idx,proc_idx,les_idx,icdev_idx)
   SET abstr_data_size = size(cv_hrv_rec->harvest_rec[case_idx].abstr_data,5)
   SET icd_abstr_data_size = size(internal_cv_case->harvest_rec[1].proc_data[proc_idx].lesion[1].
    icdevice[1].icd_abstr_data,5)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,(abstr_data_size+
    icd_abstr_data_size))
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion[les_idx].
    icdevice,icdev_idx)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion[les_idx].
    icdevice[icdev_idx].icd_abstr_data,icd_abstr_data_size)
   FOR (cnt = 1 TO icd_abstr_data_size)
     SET abstr_data_size = (abstr_data_size+ 1)
     SET cv_hrv_rec->harvest_rec[case_idx].proc_data[proc_idx].lesion[les_idx].icdevice[icdev_idx].
     icd_abstr_data[cnt].abstr_data_idx = abstr_data_size
     SET this_abstr_data_idx = internal_cv_case->harvest_rec[1].proc_data[proc_idx].lesion[1].
     icdevice[1].icd_abstr_data[cnt].abstr_data_idx
     CALL copy_abstr_from_template(case_idx,abstr_data_size,this_abstr_data_idx)
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].abstr_idx = cnt
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].proc_data_idx = proc_idx
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].lesion_data_idx = les_idx
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].dev_idx = icdev_idx
   ENDFOR
   IF ((cv_hrv_rec->max_abstr_data < abstr_data_size))
    SET cv_hrv_rec->max_abstr_data = abstr_data_size
   ENDIF
 END ;Subroutine
 SUBROUTINE add_closdevice(case_idx,closdev_idx)
   SET abstr_data_size = size(cv_hrv_rec->harvest_rec[case_idx].abstr_data,5)
   SET closdev_abstr_data_size = size(internal_cv_case->harvest_rec[1].closuredevice[1].cd_abstr_data,
    5)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].abstr_data,(abstr_data_size+
    closdev_abstr_data_size))
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].closuredevice,closdev_idx)
   SET stat = alterlist(cv_hrv_rec->harvest_rec[case_idx].closuredevice[closdev_idx].cd_abstr_data,
    closdev_abstr_data_size)
   FOR (cnt = 1 TO closdev_abstr_data_size)
     SET abstr_data_size = (abstr_data_size+ 1)
     SET cv_hrv_rec->harvest_rec[case_idx].closuredevice[closdev_idx].cd_abstr_data[cnt].
     abstr_data_idx = abstr_data_size
     SET this_abstr_data_idx = internal_cv_case->harvest_rec[1].closuredevice[1].cd_abstr_data[cnt].
     abstr_data_idx
     CALL copy_abstr_from_template(case_idx,abstr_data_size,this_abstr_data_idx)
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].abstr_idx = cnt
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].proc_data_idx = proc_idx
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].lesion_data_idx =
     clos_dev_lesion
     SET cv_hrv_rec->harvest_rec[case_idx].abstr_data[abstr_data_size].dev_idx = closdev_idx
   ENDFOR
   IF ((cv_hrv_rec->max_abstr_data < abstr_data_size))
    SET cv_hrv_rec->max_abstr_data = abstr_data_size
   ENDIF
 END ;Subroutine
#exit_script
 IF (bfailed="F")
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
 DECLARE cv_get_harvest_data_vrsn = vc WITH private, constant("MOD 023 03/23/06 BM9013")
END GO
