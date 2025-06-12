CREATE PROGRAM cv_get_harvest_validate_acc:dba
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
 DECLARE max_status_cd(code1=f8,code2=f8) = f8
 IF (validate(cv_status_cds)=0)
  DECLARE max_status_loc1 = i4 WITH protect
  DECLARE max_status_loc2 = i4 WITH protect
  DECLARE max_status_idx = i4 WITH protect
  RECORD cv_status_cds(
    1 qual[5]
      2 status_cd = f8
  )
  SET cv_status_cds->qual[1].status_cd = uar_get_code_by("MEANING",25973,"NOERROR")
  SET cv_status_cds->qual[2].status_cd = uar_get_code_by("MEANING",25973,"HARVNOERROR")
  SET cv_status_cds->qual[3].status_cd = uar_get_code_by("MEANING",25973,"WARNING")
  SET cv_status_cds->qual[4].status_cd = uar_get_code_by("MEANING",25973,"REPORTWARN")
  SET cv_status_cds->qual[5].status_cd = uar_get_code_by("MEANING",25973,"ERROR")
  IF ((((cv_status_cds->qual[1].status_cd=0.0)) OR ((((cv_status_cds->qual[2].status_cd=0.0)) OR ((((
  cv_status_cds->qual[3].status_cd=0.0)) OR ((((cv_status_cds->qual[4].status_cd=0.0)) OR ((
  cv_status_cds->qual[5].status_cd=0.0))) )) )) )) )
   EXECUTE cv_log_struct  WITH replace("REQUEST","CV_STATUS_CDS")
   CALL cv_log_message("FAILURE IN LOOKUP ON CV_STATUS_CDS")
  ENDIF
 ENDIF
 SUBROUTINE max_status_cd(code1,code2)
   SET max_status_loc1 = locateval(max_status_idx,1,5,code1,cv_status_cds->qual[max_status_idx].
    status_cd)
   SET max_status_loc2 = locateval(max_status_idx,1,5,code2,cv_status_cds->qual[max_status_idx].
    status_cd)
   IF (((max_status_loc1=0) OR (max_status_loc2=0)) )
    RETURN(0.0)
   ELSEIF (max_status_loc1 > max_status_loc2)
    RETURN(cv_status_cds->qual[max_status_loc1].status_cd)
   ELSE
    RETURN(cv_status_cds->qual[max_status_loc2].status_cd)
   ENDIF
 END ;Subroutine
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE dataset_internal_name = vc WITH protect, noconstant(fillstring(64," "))
 DECLARE xref_internal_name = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE harvest_rec_idx = i4 WITH protect, noconstant(0)
 DECLARE this_abstr_idx = i4 WITH protect, noconstant(0)
 DECLARE abstr_data_idx = i4 WITH protect, noconstant(0)
 DECLARE reqd_str = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE mesg = vc WITH protect, noconstant(fillstring(128," "))
 DECLARE valid_flag = i2 WITH protect
 DECLARE reqd_flag = i2 WITH protect
 DECLARE status_cd = f8 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE person_id = f8 WITH protect
 DECLARE prsnl_id = f8 WITH protect
 DECLARE datediff = vc WITH protect
 DECLARE datelimit = vc WITH protect
 DECLARE getstatuscd(valid_flag=i2,reqd_flag=i2) = i4
 DECLARE reportwarn_message = vc WITH protect, constant(
  " Missing data may render the record unacceptable to the Data Registry.")
 DECLARE str_blank = vc WITH protect, constant("<BLANK>")
 CALL cv_log_message(build("status_cds:",c_status_error,":",c_status_reportwarn,":",
   c_status_warning,":",c_status_harvnoerror))
 DECLARE pgr_class_cd = f8 WITH protect, noconstant(0.0)
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
   CALL cv_log_message(build("Just before GetPrsnlGrp result_id = ",cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data[d2.seq].result_id)),
   CALL cv_log_message(build("Prsnl GroupDesc ::",pg.prsnl_group_desc)), delimpos = findstring(
    str_prsnlgrp_delimstr,pg.prsnl_group_desc),
   CALL cv_log_message(build("DelimPos::",delimpos))
   IF (delimpos > 0)
    prsnl_group_name = substring(1,(delimpos - 1),pg.prsnl_group_desc)
   ENDIF
   CALL cv_log_message(build("prsnl_group_name::",prsnl_group_name))
   IF (trim(prsnl_group_name,3)="")
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val = cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data[d2.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
    translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value
   ELSE
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val = prsnl_group_name, cv_hrv_rec->
    harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = prsnl_group_name
   ENDIF
   CALL cv_log_message(build("prsnl_group_name::",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
    result_val)),
   CALL cv_log_message(build("prsnl_group_name::",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
    translated_value)), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag = 1,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = ""
  WITH nocounter, outerjoin = d
 ;end select
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_valid1.dat")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x1,
   cv_xref_validation xv,
   (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_response r1,
   cv_response r2,
   dummyt d
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND xv.rltnship_flag IN (50, 55))
   JOIN (r1
   WHERE r1.response_id=xv.response_id)
   JOIN (d
   WHERE ((cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
     translated_value))) OR (size(trim(r1.a2))=0
    AND size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value))=0)) )
   JOIN (r2
   WHERE r2.response_id=xv.child_response_id)
   JOIN (d3
   WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx=cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx)) OR ((((cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d2.seq].lesion_data_idx=0)) OR ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
   lesion_data_idx=0))) ))
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx=cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d3.seq].dev_idx)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=xv.child_xref_id))
  DETAIL
   IF ( NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag IN (
   cv_stat_ignore_valid_chk_val, cv_stat_ignore_valid_chk_err))))
    CASE (xv.rltnship_flag)
     OF 50:
     OF 55:
      IF (cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        translated_value)))
       IF (((size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value))=0) OR ((
       cv_hrv_rec->dataset_internal_name="ACC02"))) )
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = "", cv_hrv_rec->harvest_rec[d1
        .seq].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_val,
        CALL cv_log_message(build("Valid blank child :",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
         .seq].task_assay_mean," with parent:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         task_assay_mean))
        IF (xv.rltnship_flag=55)
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val = r2.a1, cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = r2.a2
        ENDIF
       ELSE
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d3.seq].error_msg,"The parent field:",trim(x1
          .registry_field_name)," has a value of ",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq]
         .result_val,
         " which makes the current value invalid.(Internal Code 000)"), cv_hrv_rec->harvest_rec[d1
        .seq].abstr_data[d3.seq].valid_flag = cv_stat_ignore_valid_chk_err, cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d3.seq].translated_value = "",
        CALL cv_log_message(build("Error non-blank child :",cv_hrv_rec->harvest_rec[d1.seq].
         abstr_data[d3.seq].task_assay_mean," with parent:",cv_hrv_rec->harvest_rec[d1.seq].
         abstr_data[d2.seq].task_assay_mean))
       ENDIF
      ENDIF
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 IF ((cv_hrv_rec->dataset_internal_name="ACC03"))
  CALL cv_log_message("Performing ACC v3 special validations")
  DECLARE icdev_xref_id = f8 WITH noconstant(0.0)
  DECLARE icdev_xref_name = vc WITH constant("ACC03_DEV")
  DECLARE procdt_dta = f8 WITH noconstant(0.0)
  DECLARE mtdcstat_xref_name = vc WITH constant("ACC03_MTDCSTAT")
  DECLARE mtdcstat_ec = f8 WITH noconstant(0.0)
  DECLARE mtdcstat_dead = vc WITH constant("Dead")
  SET procdt_dta = uar_get_code_by("MEANING",14003,"AC03PROCDT")
  SELECT INTO "nl:"
   FROM cv_xref x
   WHERE x.xref_internal_name IN (icdev_xref_name, mtdcstat_xref_name)
   DETAIL
    CASE (x.xref_internal_name)
     OF icdev_xref_name:
      icdev_xref_id = x.xref_id
     OF mtdcstat_xref_name:
      mtdcstat_ec = x.event_cd
    ENDCASE
   WITH nocounter
  ;end select
  IF (icdev_xref_id > 0.0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
     (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
     (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data))
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (d2
     WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
      AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id=icdev_xref_id)
      AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value="0"))
     JOIN (d3
     WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
      AND d2.seq != d3.seq
      AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx=cv_hrv_rec->
     harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx)
      AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=cv_hrv_rec->harvest_rec[d1.seq]
     .abstr_data[d2.seq].xref_id))
    DETAIL
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1
      .seq].abstr_data[d2.seq].error_msg,"Must be selected as the only device"), cv_hrv_rec->
     harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = cv_stat_ignore_valid_chk_err,
     CALL cv_log_message("No device deployed error found")
    WITH nocounter
   ;end select
  ELSE
   CALL cv_log_message(concat("Failed to find xref_id for ",icdev_xref_name))
  ENDIF
  CALL cv_log_message(build("mtdcstat_ec = ",mtdcstat_ec))
  SELECT INTO "nl:"
   c.encntr_id, c.cv_case_id, adm_adm = datetimecmp(c.pat_adm_dt_tm,cnvtdatetime(cv_hrv_rec->
     harvest_rec[1].admit_dt_tm)),
   adm_disch = datetimecmp(c.pat_adm_dt_tm,cnvtdatetime(cv_hrv_rec->harvest_rec[1].disch_dt_tm)),
   disch_adm = datetimecmp(c.pat_disch_dt_tm,cnvtdatetime(cv_hrv_rec->harvest_rec[1].admit_dt_tm)),
   disch_disch = datetimecmp(c.pat_disch_dt_tm,cnvtdatetime(cv_hrv_rec->harvest_rec[1].disch_dt_tm))
   FROM cv_case c,
    cv_case_dataset_r cdr,
    cv_case_abstr_data cad
   PLAN (c
    WHERE (c.person_id=cv_hrv_rec->harvest_rec[1].person_id)
     AND c.cv_case_id != 0.0
     AND (c.encntr_id != cv_hrv_rec->harvest_rec[1].encntr_id))
    JOIN (cdr
    WHERE cdr.cv_case_id=c.cv_case_id
     AND (cdr.dataset_id=cv_hrv_rec->dataset_id))
    JOIN (cad
    WHERE cad.cv_case_id=outerjoin(c.cv_case_id)
     AND cad.event_cd=outerjoin(mtdcstat_ec))
   ORDER BY c.encntr_id, c.cv_case_id
   HEAD REPORT
    IF ((((cv_hrv_rec->harvest_rec[1].admit_dt_tm=cnvtdatetime(0,0))) OR ((cv_hrv_rec->harvest_rec[1]
    .disch_dt_tm=cnvtdatetime(0,0)))) )
     null_dates_ind = 1
    ELSE
     null_dates_ind = 0
    ENDIF
   HEAD c.encntr_id
    IF (null_dates_ind=0
     AND ((c.pat_adm_dt_tm != null
     AND ((adm_adm=0) OR (adm_adm > 0
     AND adm_disch < 0)) ) OR (((c.pat_disch_dt_tm != null
     AND disch_adm > 0
     AND disch_disch < 0) OR (c.pat_adm_dt_tm != null
     AND c.pat_disch_dt_tm != null
     AND adm_adm < 0
     AND disch_adm > 0)) )) )
     cv_hrv_rec->harvest_rec[1].error_msg = concat("Conflicting dates with encounter(",format(c
       .pat_adm_dt_tm,"MM/DD/YYYY;;D"),"-",format(c.pat_disch_dt_tm,"MM/DD/YYYY;;D"),") ",
      cv_hrv_rec->harvest_rec[1].error_msg), cv_hrv_rec->harvest_rec[1].status_cd = c_status_error,
     CALL cv_log_message("Conflicting dates error found")
    ENDIF
   DETAIL
    CALL echo(build("cv_case_id=",cad.cv_case_id,":cad=",cad.result_val,":ref=",
     mtdcstat_dead))
    IF (cnvtupper(trim(cad.result_val))=cnvtupper(trim(mtdcstat_dead))
     AND ((c.pat_disch_dt_tm != null
     AND disch_adm <= 0) OR (c.pat_disch_dt_tm=null
     AND c.pat_adm_dt_tm != null
     AND adm_adm < 0)) )
     cv_hrv_rec->harvest_rec[1].error_msg = concat("Patient dead after previous encounter(",format(c
       .pat_adm_dt_tm,"MM/DD/YYYY;;D"),"-",format(c.pat_disch_dt_tm,"MM/DD/YYYY;;D"),") ",
      cv_hrv_rec->harvest_rec[1].error_msg), cv_hrv_rec->harvest_rec[1].status_cd = c_status_error,
     CALL cv_log_message("Patient previously dead error found")
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("DEBUG Procdt previous day:",procdt_dta,":",cv_hrv_rec->dataset_id,":",
    cv_hrv_rec->harvest_rec[1].person_id,":",cv_hrv_rec->harvest_rec[1].encntr_id))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    cv_case c,
    cv_case_dataset_r cdr
   PLAN (d1
    WHERE d1.seq > 0
     AND (cv_hrv_rec->harvest_rec[d1.seq].form_type_mean="LABVISIT"))
    JOIN (c
    WHERE (c.person_id=cv_hrv_rec->harvest_rec[1].person_id))
    JOIN (cdr
    WHERE cdr.cv_case_id=c.cv_case_id
     AND (cdr.dataset_id=cv_hrv_rec->dataset_id))
   ORDER BY d1.seq
   HEAD REPORT
    l_proc_pos = 0
   HEAD d1.seq
    l_proc_idx = locateval(l_proc_pos,1,size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5),procdt_dta,
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_proc_pos].task_assay_cd)
    IF ((((datetimecmp(cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm),cnvtdatetime(
      cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm)) < - (1))) OR (datetimecmp(cnvtdatetime(cv_hrv_rec
      ->harvest_rec[d1.seq].case_dt_tm),cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm)) >
    0)) )
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_proc_idx].error_msg = concat(
      "ProcDt falls outside interval [AdmitDt - 1, DischDt]",cv_hrv_rec->harvest_rec[d1.seq].
      abstr_data[l_proc_idx].error_msg), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_proc_idx].
     valid_flag = cv_stat_ignore_valid_chk_err,
     CALL cv_log_message("Proc date outside valid range error found")
    ENDIF
   DETAIL
    CALL echo(build("DEBUG Procdt previous day:",procdt_dta,":",c.cv_case_id))
    IF ((datetimecmp(cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm),cnvtdatetime(cv_hrv_rec
      ->harvest_rec[d1.seq].admit_dt_tm))=- (1))
     AND (c.encntr_id != cv_hrv_rec->harvest_rec[1].encntr_id)
     AND datetimecmp(cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm),c.pat_adm_dt_tm) >= 0
     AND datetimecmp(cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm),c.pat_disch_dt_tm) <= 0
    )
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_proc_idx].error_msg = concat(
      "ProcDt before AdmitDt falls inside other encounter(",format(c.pat_adm_dt_tm,"MM/DD/YYYY;;D"),
      "-",format(c.pat_disch_dt_tm,"MM/DD/YYYY;;D"),") ",
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_proc_idx].error_msg), cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[l_proc_idx].valid_flag = cv_stat_ignore_valid_chk_err,
     CALL cv_log_message("Proc date inside other encounter error found")
    ENDIF
   WITH nocounter
  ;end select
  DECLARE deathdt = dq8 WITH protect
  DECLARE deathidx = i4 WITH protect, noconstant(0)
  DECLARE admitidx = i4 WITH protect, noconstant(0)
  DECLARE maxprocdt = dq8 WITH protect
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
    (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   DETAIL
    IF ((cv_hrv_rec->harvest_rec[d1.seq].form_type_mean="ADMIT"))
     IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean="AC03MTDATE"))
      deathdt = cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm),
      deathidx = d2.seq, admitidx = d1.seq,
      maxprocdt = cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm)
     ENDIF
    ELSE
     IF (datetimecmp(cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm),cnvtdatetime(maxprocdt)
      ) > 0)
      maxprocdt = cnvtdatetime(cv_hrv_rec->harvest_rec[d1.seq].case_dt_tm)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual != 0
   AND datetimecmp(cnvtdatetime(deathdt),cnvtdatetime(maxprocdt)) < 0
   AND  NOT ((cv_hrv_rec->harvest_rec[admitidx].abstr_data[deathidx].valid_flag IN (
  cv_stat_ignore_valid_chk_err, cv_stat_ignore_valid_chk_val)))
   AND  NOT ((cv_hrv_rec->harvest_rec[admitidx].abstr_data[deathidx].result_val IN ("<blank>",
  "<BLANK>"))))
   SET cv_hrv_rec->harvest_rec[admitidx].abstr_data[deathidx].error_msg = concat("Date of Death (",
    format(deathdt,"MM/DD/YYYY;;D"),") before Date of Procedure (",format(maxprocdt,"MM/DD/YYYY;;D"),
    ") is outside of usual range.")
   SET cv_hrv_rec->harvest_rec[admitidx].abstr_data[deathidx].valid_flag = 5
   CALL cv_log_message("Date of death before procedure")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x1,
   cv_xref_validation xv,
   cv_response r1
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND xv.rltnship_flag IN (30, 31))
   JOIN (r1
   WHERE r1.response_id=xv.response_id)
  ORDER BY d1.seq
  HEAD d1.seq
   admit_date_nbr = cnvtreal(format(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,"YYYYMMDD;;D"))
  DETAIL
   IF (((cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
     translated_value))) OR (size(trim(r1.a2))=0
    AND size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value))=0)) )
    IF (((xv.rltnship_flag=30
     AND xv.offset_nbr > admit_date_nbr) OR (xv.rltnship_flag=31
     AND xv.offset_nbr < admit_date_nbr)) )
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = cv_stat_ignore_valid_chk_err,
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = "", cv_hrv_rec->
     harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1.seq].
      abstr_data[d2.seq].error_msg,"This value [",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      result_val,"] is not valid for admit date [",format(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,
       "@SHORTDATE"),
      "]")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_valid2.dat")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL cv_log_message("Doing date error checks ...")
 SELECT INTO "nl:"
  xv.reqd_flag
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   (dummyt d3  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref_validation xv,
   cv_xref x1,
   cv_xref x2,
   cv_response r1,
   cv_response r2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag IN (
   cv_stat_ignore_valid_chk_val, cv_stat_ignore_valid_chk_err)))
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val IN ("<BLANK>", "<blank>"
   ))))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND  NOT (xv.rltnship_flag IN (30, 31, 50)))
   JOIN (r1
   WHERE r1.response_id=xv.response_id
    AND r1.field_type="D")
   JOIN (r2
   WHERE r2.response_id=xv.child_response_id
    AND r2.field_type="D")
   JOIN (x2
   WHERE x2.xref_id=r2.xref_id)
   JOIN (d3
   WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx=cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx)) OR ((((cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d2.seq].lesion_data_idx=0)) OR ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
   lesion_data_idx=0))) ))
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx=cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d3.seq].dev_idx)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=xv.child_xref_id)
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag IN (
   cv_stat_ignore_valid_chk_val, cv_stat_ignore_valid_chk_err)))
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val IN ("<BLANK>", "<blank>"
   ))))
  ORDER BY xv.reqd_flag
  HEAD REPORT
   date_validated = 0
  DETAIL
   temp_field_type_d2 = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning,
   temp_field_type_d3 = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].field_type_meaning,
   tmp_datecmp = datetimecmp(cnvtdatetime(curdate,curtime3),datetimeadd(cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].result_dt_tm,xv.offset_nbr))
   CASE (xv.rltnship_flag)
    OF 14:
     IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) > 0)
      date_validated = 1
     ENDIF
    OF 15:
     IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) < 0)
      date_validated = 1
     ENDIF
    OF 16:
     IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) >= 0)
      date_validated = 1
     ENDIF
    OF 17:
     IF (datetimediff(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) <= 0)
      date_validated = 1
     ENDIF
    OF 18:
     IF (tmp_datecmp < 0)
      CALL cv_log_message(build("Date diff:",tmp_datecmp," < 0")), date_validated = 2
     ENDIF
    OF 19:
     IF (tmp_datecmp <= 0)
      CALL cv_log_message(build("Date diff:",tmp_datecmp," <= 0")), date_validated = 2
     ENDIF
    OF 20:
     IF (tmp_datecmp > 0)
      CALL cv_log_message(build("Date diff:",tmp_datecmp," > 0")), date_validated = 2
     ENDIF
    OF 21:
     IF (tmp_datecmp >= 0)
      CALL cv_log_message(build("Date diff:",tmp_datecmp," >= 0")), date_validated = 2
     ENDIF
    OF 24:
     IF (temp_field_type_d2="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) > 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d2="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) > 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,xv.offset_nbr)) > 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,xv.offset_nbr)) > 0)
       date_validated = 1
      ENDIF
     ELSE
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) > 0)
       date_validated = 1
      ENDIF
     ENDIF
    OF 25:
     IF (temp_field_type_d2="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) < 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d2="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) < 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,xv.offset_nbr)) < 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,xv.offset_nbr)) < 0)
       date_validated = 1
      ENDIF
     ELSE
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) < 0)
       date_validated = 1
      ENDIF
     ENDIF
    OF 26:
     IF (temp_field_type_d2="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) >= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d2="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) >= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,xv.offset_nbr)) >= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,xv.offset_nbr)) >= 0)
       date_validated = 1
      ENDIF
     ELSE
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) >= 0)
       date_validated = 1
      ENDIF
     ENDIF
    OF 27:
     IF (temp_field_type_d2="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) <= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d2="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) <= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EREGDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].admit_dt_tm,xv.offset_nbr)) <= 0)
       date_validated = 1
      ENDIF
     ELSEIF (temp_field_type_d3="EDISCHDATE")
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].disch_dt_tm,xv.offset_nbr)) <= 0)
       date_validated = 1
      ENDIF
     ELSE
      IF (datetimecmp(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,xv.offset_nbr)) <= 0)
       date_validated = 1
      ENDIF
     ENDIF
   ENDCASE
   CASE (date_validated)
    OF 1:
     datediff = trim(cnvtage(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,0)),datelimit = trim(cnvtage(
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,datetimeadd(cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,xv.offset_nbr),0)),
     IF (xv.offset_nbr <= 31)
      datelimit = concat(trim(cnvtstring(xv.offset_nbr),3)," Days")
     ENDIF
     ,
     IF (xv.reqd_flag=required_flag_error_code)
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(" This field has value ",
       evaluate(trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
          "@SHORTDATE")),"","<BLANK>",trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
          result_dt_tm,"@SHORTDATE")))," and ",trim(x2.registry_field_name)," has value ",
       evaluate(trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_dt_tm,
          "@SHORTDATE")),"","<BLANK>",trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          result_dt_tm,"@SHORTDATE")))," , the difference is: ",datediff,", the limit is: ",datelimit,
       ". Are you sure? (Ref001)"), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag =
      cv_stat_ignore_valid_chk_err
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].error_msg," This field has value ",evaluate(trim(format(cv_hrv_rec
          ->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,"@SHORTDATE")),"","<BLANK>",trim(
         format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,"@SHORTDATE"))),
       " and ",trim(x2.registry_field_name),
       " has value ",evaluate(trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          result_dt_tm,"@SHORTDATE")),"","<BLANK>",trim(format(cv_hrv_rec->harvest_rec[d1.seq].
          abstr_data[d3.seq].result_dt_tm,"@SHORTDATE")))," , the difference is: ",datediff,
       ", the limit is: ",
       datelimit,". Are you sure? (Ref001)"), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      valid_flag = 5
     ENDIF
     ,
     CALL cv_log_message(build("error:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
      " flag:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag))date_validated = 0
    OF 2:
     IF (xv.reqd_flag=required_flag_error_code)
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(
       "Ref002. Invalid combined result for name-value pair: This field has value ",evaluate(trim(
         format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,"@SHORTDATE")),"",
        "<BLANK>",trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,
          "@SHORTDATE")))," while current system date/time is ",format(cnvtdatetime(curdate,curtime3),
        ";;Q"),"."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag =
      cv_stat_ignore_valid_chk_err
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].error_msg,"  Ref002. Invalid combined result for name-value pair: ",
       " This field has value ",evaluate(trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
          .seq].result_dt_tm,"@SHORTDATE")),"","<BLANK>",trim(format(cv_hrv_rec->harvest_rec[d1.seq].
          abstr_data[d2.seq].result_dt_tm,"@SHORTDATE")))," while current system date/time is ",
       format(cnvtdatetime(curdate,curtime3),";;Q"),"."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
      d2.seq].valid_flag = 5
     ENDIF
     ,
     CALL cv_log_message(build("error:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
      " flag:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag))date_validated = 0
   ENDCASE
  WITH nocounter
 ;end select
 CALL cv_log_message("Doing Interfield Checks...")
 SELECT INTO "nl:"
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
   cv_stat_ignore_valid_chk_val, cv_stat_ignore_valid_chk_err))))
   JOIN (x1
   WHERE (x1.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (xv
   WHERE xv.xref_id=x1.xref_id
    AND  NOT (xv.rltnship_flag IN (14, 15, 16, 17, 18,
   19, 20, 21, 24, 25,
   26, 27, 30, 31, 50)))
   JOIN (r1
   WHERE r1.response_id=xv.response_id)
   JOIN (r2
   WHERE r2.response_id=xv.child_response_id)
   JOIN (x2
   WHERE x2.xref_id=r2.xref_id)
   JOIN (d3
   WHERE d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx=cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx)) OR ((((cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d2.seq].lesion_data_idx=0)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx != 0)) OR ((cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d3.seq].lesion_data_idx=0)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx != 0))) ))
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx=cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d3.seq].dev_idx)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].xref_id=xv.child_xref_id)
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag IN (
   cv_stat_ignore_valid_chk_val, cv_stat_ignore_valid_chk_err))))
  DETAIL
   IF (cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
     translated_value)))
    CASE (r2.field_type)
     OF "A":
      CASE (xv.rltnship_flag)
       OF 1:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref003. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>","MM/DD/YYYY HH:MM","<blank>",
           "MM/DD/YYYY","<blank>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," has value ",evaluate(trim(r2.a1),"","<BLANK>",trim(r2.a1)),
          "."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
       OF 2:
        IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
          .seq].translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref004. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," has value ",evaluate(trim(r2.a1),"","<BLANK>",trim(r2.a1)),
          "."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "N":
      CASE (xv.rltnship_flag)
       OF 1:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref005. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
       OF 2:
        IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
          .seq].translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref006. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "S":
      CASE (xv.rltnship_flag)
       OF 1:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref007. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
       OF 13:
        IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value != ""))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = cv_hrv_rec->harvest_rec[d1
         .seq].abstr_data[d3.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value,
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "D":
      CASE (xv.rltnship_flag)
       OF 1:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref008. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(r1.a1),"","<BLANK>",trim(r1.a1))," while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
      ENDCASE
    ENDCASE
   ELSE
    CASE (r2.field_type)
     OF "A":
      CASE (xv.rltnship_flag)
       OF 7:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         CALL formatreqdflagstr(xv.reqd_flag), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         error_msg = concat(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref009. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val),"","<BLANK>",cnvtupper
           (trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)))," while ",
          trim(x2.registry_field_name)," has value ",evaluate(trim(r2.a1),"","<BLANK>",trim(r2.a1)),
          "."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
       OF 8:
        IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
          .seq].translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref010. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
           "<BLANK>",cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))),
          " while ",
          trim(x2.registry_field_name)," has value ",evaluate(trim(r2.a1),"","<BLANK>",trim(r2.a1)),
          "."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "N":
      CASE (xv.rltnship_flag)
       OF 7:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref011. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
           "<BLANK>",cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))),
          " while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
       OF 8:
        IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3
          .seq].translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref012. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
           "<BLANK>",cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))),
          " while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "S":
      CASE (xv.rltnship_flag)
       OF 7:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref013. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
           "<BLANK>",cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))),
          " while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
       OF 14:
        IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value != ""))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = cv_hrv_rec->harvest_rec[d1
         .seq].abstr_data[d3.seq].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
         translated_value = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value,
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 0
        ENDIF
      ENDCASE
     OF "D":
      CASE (xv.rltnship_flag)
       OF 7:
        IF (cnvtupper(trim(r2.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
          translated_value)))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
          harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,
          "  Ref014. Invalid combined result for name-value pair: "," This field has value ",evaluate
          (cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)),"",
           "<BLANK>",cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))),
          " while ",
          trim(x2.registry_field_name)," is missing."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
         .seq].valid_flag = 0
        ENDIF
      ENDCASE
    ENDCASE
   ENDIF
   IF (xv.rltnship_flag=22)
    IF (trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean)="AC02PAMIP")
     CALL cv_log_message(build("r1.a2:",r1.a2," r2.field_type:",r2.field_type,"D3 trans val:",
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value,"D2 trans val:",cv_hrv_rec
      ->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value,"D3 task_assay_mean:",cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean,
      "D3 task_assay_mean:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].task_assay_mean)),
     CALL cv_log_message(build("d2.seq:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      task_assay_mean))
    ENDIF
    IF (cnvtupper(trim(r1.a2))=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      translated_value)))
     IF (cnvtupper(trim(r2.a2)) != cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
       translated_value)))
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].error_msg,"This field has value ",evaluate(trim(r1.a1),"","<BLANK>",
        trim(r1.a1)),". Field ",trim(x2.registry_field_name),
       " was changed from: ",evaluate(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
         translated_value),"","<BLANK>",trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].
         translated_value))," to ",evaluate(trim(r2.a2),"","<BLANK>",trim(r2.a2)),". (Ref015). ")
     ENDIF
     CALL cv_log_message(build("VALIDATION FLAG 22 !!!! for field type",r2.response_internal_name)),
     CALL cv_log_message(build("VALIDATION FLAG 22 !!!! for field type",r2.field_type,"|")),
     CALL cv_log_message(build("VALIDATION FLAG 22 !!!! for field type",r1.response_internal_name)),
     CALL cv_log_message(build("VALIDATION FLAG 22 !!!! for field type",r1.field_type,"|"))
     CASE (r2.field_type)
      OF "A":
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = cnvtupper(trim(r2.a2)),
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag = 1
      OF "N":
       IF (trim(cnvtupper(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].result_val)) !=
       str_blank)
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,"This field has been replaced with ",
         cnvtstring(xv.offset_nbr),", since it had an invalid value.")
       ELSE
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag = 1
       ENDIF
       ,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = cnvtstring(xv
        .offset_nbr)
      OF "D":
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d3.seq].translated_value = trim(r2.a4),cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[d3.seq].valid_flag = 1
     ENDCASE
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL cv_log_message("End Interfield Checks")
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_valid3.dat")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL cv_log_message("Setting the Valid Flag and Status Codes...")
 DECLARE harvnoerror_status_cd = f8 WITH protect
 SET stat = uar_get_meaning_by_codeset(cs_cv_status_message,csm_cv_stat_msg_harvnoerror,1,
  harvnoerror_status_cd)
 DECLARE harverror_status_cd = f8 WITH protect
 SET stat = uar_get_meaning_by_codeset(cs_cv_status_message,csm_cv_stat_msg_error,1,
  harverror_status_cd)
 SELECT INTO "nl:"
  x.dataset_id
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x,
   long_text l,
   long_text l2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x
   WHERE (x.dataset_id=cv_hrv_rec->dataset_id)
    AND (x.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (l
   WHERE x.warning_text_id=l.long_text_id)
   JOIN (l2
   WHERE x.error_text_id=l2.long_text_id)
  ORDER BY d1.seq
  HEAD REPORT
   stat = 0, valid_flag = - (1), reqd_flag = - (1),
   status_cd = 0.0, cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 1
  HEAD d1.seq
   done_flag = 0, done_flag_case = 0, case_status_flag = 1
   IF ((cv_hrv_rec->harvest_rec[d1.seq].status_cd=0.0))
    cv_hrv_rec->harvest_rec[d1.seq].status_cd = c_status_harvnoerror
   ENDIF
  DETAIL
   valid_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag, status_cd = 0.0,
   reqd_flag = x.reqd_flag,
   stat = getstatuscd(valid_flag,reqd_flag), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
   status_cd = status_cd
   IF (l.long_text_id > 0.0)
    IF (reqd_flag=required_flag_reportwarn_code
     AND trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value)="")
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1
      .seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
    ELSEIF (reqd_flag=required_flag_error_code
     AND trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value)="")
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1
      .seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
    ENDIF
   ENDIF
   IF (status_cd=c_status_harvnoerror
    AND  NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag IN (1,
   cv_stat_ignore_valid_chk_val))))
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
   ENDIF
   IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag=cv_stat_ignore_valid_chk_val))
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = ""
   ENDIF
   CALL echo(build(x.xref_internal_name,".  status = ",uar_get_code_meaning(status_cd),
    ". with valid flag=",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag))
   IF (done_flag=0)
    IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag=0)
     AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].status_cd != harvnoerror_status_cd))
     cv_hrv_rec->harvest_rec[d1.seq].valid_flag = 0, done_flag = 1
    ENDIF
   ENDIF
   cv_hrv_rec->harvest_rec[d1.seq].status_cd = max_status_cd(cv_hrv_rec->harvest_rec[d1.seq].
    status_cd,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].status_cd),
   CALL echo(build("New status:",cv_hrv_rec->harvest_rec[d1.seq].status_cd))
  WITH nocounter, memsort
 ;end select
 CALL cv_log_message(build("status_cd:",cv_hrv_rec->harvest_rec[1].status_cd))
 CALL cv_log_message("Updating the RECCOMP")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=csm_field_type_reccomp
   ))
  DETAIL
   IF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=0))
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "NO", cv_hrv_rec->harvest_rec[d1
    .seq].abstr_data[d2.seq].translated_value = "2", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
    .seq].error_msg = "Record Incomplete"
   ELSEIF ((cv_hrv_rec->harvest_rec[d1.seq].valid_flag=1))
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "YES", cv_hrv_rec->harvest_rec[d1
    .seq].abstr_data[d2.seq].translated_value = "1", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
    .seq].error_msg = ""
   ENDIF
  WITH nocounter
 ;end select
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
    CASE (reqd_flag)
     OF required_flag_reportwarn_code:
      SET status_cd = c_status_reportwarn
     OF required_flag_error_code:
      SET status_cd = c_status_error
     OF required_flag_warning_code:
      SET status_cd = c_status_warning
     OF required_flag_dontcare_code:
      SET status_cd = c_status_harvnoerror
     ELSE
      SET status_cd = c_status_harvnoerror
    ENDCASE
   OF cv_stat_ignore_valid_chk_err:
    SET status_cd = c_status_error
   OF 3:
    SET status_cd = c_status_warning
   OF 5:
    SET status_cd = c_status_warning
   OF cv_stat_reportwarn:
    SET status_cd = c_status_reportwarn
   ELSE
    SET status_cd = c_status_harvnoerror
  ENDCASE
  CALL echo(build("GetStatusCd(",valid_flag,",",reqd_flag,")=",
    status_cd))
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
 DECLARE cv_get_harvest_validate_acc_vrsn = vc WITH private, constant("021 06/30/06 MH9140")
END GO
