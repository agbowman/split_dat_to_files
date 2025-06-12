CREATE PROGRAM cv_get_harvest_test:dba
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
 IF ((request->batch_selection > ""))
  CALL cv_log_message("The OPS job processing needs to be setup")
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 files[*]
      2 file_name = vc
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
 SET cv_log_level = cv_log_debug
 SET cv_hrv_rec->harvest_display = build("Harvest for Facility Id =",request->loc_facility_cd,
  "Dataset Id  =",request->dataset_id,"Start Date =",
  format(request->start_dt,"@SHORTDATE"),"End Date = ",format(request->stop_dt,"@SHORTDATE"))
 SELECT INTO "nl:"
  d.*
  FROM cv_dataset ds
  PLAN (ds
   WHERE (ds.dataset_id=request->dataset_id))
  DETAIL
   cv_hrv_rec->dataset_id = request->dataset_id, cv_hrv_rec->validation_script = ds.validation_script
  WITH nocounter
 ;end select
 CALL echo("Calling cv_get_harvest_data....")
 EXECUTE cv_get_harvest_data
 EXECUTE cv_get_harvest_translate
 CALL parser(concat(cv_hrv_rec->validation_script," go"))
 EXECUTE cv_get_harvest_output
 CALL echorecord(reply)
#exit_script
END GO
