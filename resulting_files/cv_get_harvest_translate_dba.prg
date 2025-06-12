CREATE PROGRAM cv_get_harvest_translate:dba
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
 CALL cv_log_message("In CV_GET_HARVEST_TRANSLATE")
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
 CALL cv_log_message(concat("Entering ",curprog))
 DECLARE max_proc_cnt = i4 WITH protect
 DECLARE max_les_cnt = i4 WITH protect
 DECLARE reqd_str = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE harv_idx = i4 WITH protect
 DECLARE harv_cnt = i4 WITH protect, noconstant(size(cv_hrv_rec->harvest_rec,5))
 DECLARE abstr_idx = i4 WITH protect
 DECLARE abstr_cnt = i4 WITH protect
 DECLARE dta_idx = i4 WITH protect
 DECLARE dta_cnt = i4 WITH protect
 DECLARE dta_pad = i4 WITH protect
 DECLARE occur_idx = i4 WITH protect
 DECLARE occur_cnt = i4 WITH protect
 DECLARE c_block_sz = i4 WITH protect, constant(20)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE date_greater_cur = vc WITH protect, constant(
  " Date greater than current date and time is invalid.")
 DECLARE outside_numeric_range = vc WITH protect, constant(
  " The result is outside the numeric range of ")
 DECLARE outside_normal_range = vc WITH protect, constant(
  " The result is outside the usual range of ")
 DECLARE invalid_devprimind = vc WITH protect, constant(
  " Indicated primary device used does not exist.")
 DECLARE namecodevalue = f8 WITH protect
 DECLARE namedisplay = vc WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE copy_field_cnt = i4 WITH protect
 DECLARE copy_field_idx = i4 WITH protect
 DECLARE funsuccessful = i4 WITH protect
 DECLARE formatstring = vc WITH protect
 DECLARE formatdate(paramval=q8,paramformat=vc) = vc
 DECLARE unsuccessful = i2 WITH protect, constant(2)
 CALL cv_log_message(concat("size(cv_hrv_rec->harvest_rec,5) = ",cnvtstring(size(cv_hrv_rec->
     harvest_rec,5))))
 CALL cv_log_message(concat("cv_hrv_rec->max_abstr_data = ",cnvtstring(cv_hrv_rec->max_abstr_data)))
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL cv_log_message("Get Normal Highs and Lows")
 FREE RECORD dtas
 RECORD dtas(
   1 dta[*]
     2 task_assay_cd = f8
     2 occur[*]
       3 harv_idx = i4
       3 abstr_idx = i4
 )
 FOR (harv_idx = 1 TO harv_cnt)
  SET abstr_cnt = size(cv_hrv_rec->harvest_rec[harv_idx].abstr_data,5)
  FOR (abstr_idx = 1 TO abstr_cnt)
    IF ((cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx].task_assay_cd > 0.0)
     AND (cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx].field_type_meaning="NUMERIC"))
     SET dta_idx = locateval(dta_idx,1,dta_cnt,cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx
      ].task_assay_cd,dtas->dta[dta_idx].task_assay_cd)
     IF (dta_idx != 0)
      SET occur_cnt = (1+ size(dtas->dta[dta_idx].occur,5))
     ELSE
      SET dta_cnt = (dta_cnt+ 1)
      IF (mod(dta_cnt,c_block_sz)=1)
       SET dta_pad = (dta_pad+ c_block_sz)
       SET stat = alterlist(dtas->dta,dta_pad)
      ENDIF
      SET dtas->dta[dta_cnt].task_assay_cd = cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx].
      task_assay_cd
      SET dta_idx = dta_cnt
      SET occur_cnt = 1
     ENDIF
     SET stat = alterlist(dtas->dta[dta_idx].occur,occur_cnt)
     SET dtas->dta[dta_idx].occur[occur_cnt].harv_idx = harv_idx
     SET dtas->dta[dta_idx].occur[occur_cnt].abstr_idx = abstr_idx
    ENDIF
  ENDFOR
 ENDFOR
 IF ((reqdata->loglevel >= 4))
  CALL echorecord(dtas)
 ENDIF
 IF (dta_cnt > 0)
  SET dta_pad = (dta_cnt+ ((c_block_sz - 1) - mod((dta_cnt - 1),c_block_sz)))
  SET stat = alterlist(dtas->dta,dta_pad)
  FOR (dta_idx = (dta_cnt+ 1) TO dta_pad)
    SET dtas->dta[dta_idx].task_assay_cd = dtas->dta[dta_cnt].task_assay_cd
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((dta_pad/ c_block_sz))),
    reference_range_factor rrf
   PLAN (d1
    WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ c_block_sz))))
    JOIN (rrf
    WHERE expand(dta_idx,nstart,(nstart+ (c_block_sz - 1)),rrf.task_assay_cd,dtas->dta[dta_idx].
     task_assay_cd,
     200))
   DETAIL
    dta_idx = locateval(dta_idx,(1+ ((d1.seq - 1) * c_block_sz)),dta_cnt,rrf.task_assay_cd,dtas->dta[
     dta_idx].task_assay_cd), occur_cnt = size(dtas->dta[dta_idx].occur,5)
    FOR (occur_idx = 1 TO occur_cnt)
      abstr_idx = dtas->dta[dta_idx].occur[occur_idx].abstr_idx, harv_idx = dtas->dta[dta_idx].occur[
      occur_idx].harv_idx, cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx].normal_high = rrf
      .normal_high,
      cv_hrv_rec->harvest_rec[harv_idx].abstr_data[abstr_idx].normal_low = rrf.normal_low
    ENDFOR
   WITH nocounter
  ;end select
 ELSE
  CALL cv_log_message("dta_cnt = 0")
 ENDIF
 FREE RECORD dtas
 CALL cv_log_message("calling cv_log_struct pre 005")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_trans00.dat")
 SELECT INTO "NL:"
  field_type_meaning = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning,
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id, case_index = d1.seq,
  proc_data_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx, lesion_data_idx
   = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x,
   cv_response r,
   cv_xref x1
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].nomenclature_id > 0.0)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=csm_field_type_devused
   ))
   JOIN (x
   WHERE (x.dataset_id=cv_hrv_rec->dataset_id)
    AND (x.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id)
    AND x.active_ind=1)
   JOIN (r
   WHERE r.xref_id=x.xref_id
    AND r.response_id != 0.0
    AND r.active_ind=1)
   JOIN (x1
   WHERE x1.xref_internal_name=trim(r.a1,3)
    AND x1.active_ind=1)
  ORDER BY case_index, proc_data_idx, lesion_data_idx
  HEAD REPORT
   namecodevalue = 0.0, namedisplay = "", iret = 0,
   abstr_data_ini_cnt = size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5), les_abstr_data_ini_cnt =
   size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
    les_abstr_data,5), abstr_idx = 0,
   les_abstr_idx = 0
  HEAD lesion_data_idx
   cnt = 0
  DETAIL
   CALL cv_log_message(build("1. d2.seq:",d2.seq)), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq
   ].xref_id = x1.xref_id, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].event_cd = x1.event_cd,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx = cnvtint(r.a2), cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d2.seq].field_type_cd = x1.field_type_cd, cv_hrv_rec->harvest_rec[
   d1.seq].abstr_data[d2.seq].field_type_meaning = uar_get_code_meaning(x1.field_type_cd),
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].display_field_ind = true, cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d2.seq].required_flag = x1.reqd_flag, cv_hrv_rec->harvest_rec[d1
   .seq].abstr_data[d2.seq].task_assay_cd = x1.task_assay_cd,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean = uar_get_code_meaning(x1
    .task_assay_cd), cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].cur_dev_num = (
   cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].cur_dev_num+ 1), cnt = (cnt+ 1),
   stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
    exist_dev_idx,cnt), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx = cv_hrv_rec->
   harvest_rec[d1.seq].proc_data[proc_data_idx].cur_dev_num, cv_hrv_rec->harvest_rec[d1.seq].
   proc_data[proc_data_idx].lesion[lesion_data_idx].exist_dev_idx[cnt].dev_idx = cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx
  FOOT  lesion_data_idx
   cnt = 0
  WITH nocounter
 ;end select
 CALL cv_log_message("calling cv_log_struct intra 005")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_trans0.dat")
 SELECT INTO "NL:"
  field_type_meaning = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning,
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id, case_index = d1.seq,
  proc_data_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx, lesion_data_idx
   = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x,
   cv_response r,
   cv_xref x1,
   cv_response r1,
   cv_response r2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning=
   csm_field_type_primdevind))
   JOIN (x
   WHERE (x.dataset_id=cv_hrv_rec->dataset_id)
    AND (x.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id)
    AND x.active_ind=1)
   JOIN (r
   WHERE r.xref_id=x.xref_id
    AND (r.nomenclature_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].nomenclature_id))
   JOIN (x1
   WHERE x1.xref_internal_name=trim(r.a5,3)
    AND x1.active_ind=1)
   JOIN (r1
   WHERE r1.xref_id=x1.xref_id
    AND r1.response_internal_name=trim(r.a3,3))
   JOIN (r2
   WHERE r2.xref_id=x1.xref_id
    AND r2.response_internal_name=trim(r.a4,3))
  ORDER BY case_index, proc_data_idx, lesion_data_idx
  HEAD REPORT
   namecodevalue = 0.0, namedisplay = "", iret = 0,
   abstr_idx = 0, les_abstr_idx = 0, cnt = 0,
   add_device_number = 0
  HEAD lesion_data_idx
   abstr_data_ini_cnt = size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5), les_abstr_data_ini_cnt =
   size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
    les_abstr_data,5), siz_exist_dev_idx = 0,
   i = 0, j = 0, k = 0,
   exist_dev_idx_cnt = 0
  DETAIL
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id = x1.xref_id, cv_hrv_rec->harvest_rec[
   d1.seq].abstr_data[d2.seq].event_cd = x1.event_cd, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
   .seq].dev_idx = (cnvtint(r.a2)+ add_device_number),
   add_device_number = (add_device_number+ size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[
    proc_data_idx].lesion[lesion_data_idx].exist_dev_idx,5)), cv_hrv_rec->harvest_rec[d1.seq].
   abstr_data[d2.seq].field_type_cd = x1.field_type_cd, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2
   .seq].field_type_meaning = uar_get_code_meaning(x1.field_type_cd),
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].display_field_ind = true, cv_hrv_rec->
   harvest_rec[d1.seq].abstr_data[d2.seq].required_flag = x1.reqd_flag, cv_hrv_rec->harvest_rec[d1
   .seq].abstr_data[d2.seq].task_assay_cd = x1.task_assay_cd,
   cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean = uar_get_code_meaning(x1
    .task_assay_cd), siz_exist_dev_idx = size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx
    ].lesion[lesion_data_idx].exist_dev_idx,5)
   FOR (i = 1 TO siz_exist_dev_idx)
     IF ((cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
     exist_dev_idx[i].dev_idx=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx))
      j = 1
     ENDIF
   ENDFOR
   IF (j=0)
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].error_msg,invalid_devprimind), cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data[d2.seq].valid_flag = 0, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx =
    cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].exist_dev_idx[1]
    .dev_idx
   ELSE
    cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1, cv_hrv_rec->harvest_rec[d1.seq
    ].abstr_data[d2.seq].result_val = r1.a1, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
    nomenclature_id = r1.nomenclature_id
   ENDIF
   IF ((((abstr_data_ini_cnt+ siz_exist_dev_idx) - 1) > size(cv_hrv_rec->harvest_rec[d1.seq].
    abstr_data,5)))
    stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,((abstr_data_ini_cnt+
     siz_exist_dev_idx) - 1))
   ENDIF
   stat = alterlist(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
    les_abstr_data,((les_abstr_data_ini_cnt+ siz_exist_dev_idx) - 1)), exist_dev_idx_cnt = 0, k = 0,
   iteration_num = 1, exist_dev_idx_cnt = 1
   FOR (abstr_idx = (abstr_data_ini_cnt+ 1) TO size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
     k = 0, bdone = 0
     WHILE (exist_dev_idx_cnt <= size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].
      lesion[lesion_data_idx].exist_dev_idx,5)
      AND bdone=0)
      IF ((cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
      exist_dev_idx[exist_dev_idx_cnt].dev_idx != cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
      dev_idx))
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].xref_id = cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[d2.seq].xref_id, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].event_cd
        = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].event_cd, cv_hrv_rec->harvest_rec[d1.seq
       ].abstr_data[abstr_idx].result_id = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       result_id,
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].result_source = cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].result_source, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx
       ].result_dt_tm = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm, cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[abstr_idx].task_assay_cd = cv_hrv_rec->harvest_rec[d1.seq].
       abstr_data[d2.seq].task_assay_cd,
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].task_assay_mean = cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean, cv_hrv_rec->harvest_rec[d1.seq].
       abstr_data[abstr_idx].required_flag = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       required_flag, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].abstr_type_flag =
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].abstr_type_flag,
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].abstr_idx = cv_hrv_rec->harvest_rec[d1
       .seq].abstr_data[d2.seq].abstr_idx, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].
       proc_data_idx = cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx, cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[abstr_idx].lesion_data_idx = cv_hrv_rec->harvest_rec[d1.seq].
       abstr_data[d2.seq].lesion_data_idx
       IF (j != 0)
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].result_val = r2.a1, cv_hrv_rec->
        harvest_rec[d1.seq].abstr_data[abstr_idx].nomenclature_id = r2.nomenclature_id
       ENDIF
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[abstr_idx].dev_idx = cv_hrv_rec->harvest_rec[d1.seq
       ].proc_data[proc_data_idx].lesion[lesion_data_idx].exist_dev_idx[exist_dev_idx_cnt].dev_idx, k
        = (k+ 1), cnt = (k+ les_abstr_data_ini_cnt),
       cv_hrv_rec->harvest_rec[d1.seq].proc_data[proc_data_idx].lesion[lesion_data_idx].
       les_abstr_data[cnt].abstr_data_idx = abstr_idx, bdone = 1
      ENDIF
      ,exist_dev_idx_cnt = (exist_dev_idx_cnt+ 1)
     ENDWHILE
   ENDFOR
   IF ((cv_hrv_rec->max_abstr_data < size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)))
    cv_hrv_rec->max_abstr_data = size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
   ENDIF
  WITH nocounter
 ;end select
 CALL cv_log_message("dump cv_hrv_rec")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_trans1.dat")
 CALL cv_log_message("Do the translation")
 SELECT INTO "NL:"
  cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].event_cd
  FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
   (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data)),
   cv_xref x,
   cv_response r,
   long_text l
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5))
   JOIN (x
   WHERE (x.dataset_id=cv_hrv_rec->dataset_id)
    AND (x.xref_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].xref_id))
   JOIN (r
   WHERE r.xref_id=x.xref_id
    AND ((r.field_type IN ("N", "S", "D", "C", "I")) OR (r.field_type="A"
    AND ((r.nomenclature_id != 0.0
    AND (r.nomenclature_id=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].nomenclature_id)) OR (
   ((cnvtupper(r.a1)="<BLANK>"
    AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val="")) OR (r.nomenclature_id=0.0
    AND cnvtupper(r.a1)=cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,
     3)))) )) )) )
   JOIN (l
   WHERE l.long_text_id=x.warning_text_id)
  HEAD REPORT
   namecodevalue = 0.0, namedisplay = "", iret = 0
  DETAIL
   CASE (r.field_type)
    OF "A":
     IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3))=0)
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "<BLANK>"
     ENDIF
     ,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = r.a2,
     IF (((size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3))=0) OR (
     cnvtupper(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3))="<BLANK>")) )
      IF (l.long_text_id != 0.0
       AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg=""))
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
      ENDIF
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
     ENDIF
    OF "N":
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].result_val,
     IF (((size(trim(r.a3)) > 0
      AND cnvtreal(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)=cnvtreal(r.a3)) OR
     (size(trim(r.a2)) > 0
      AND cnvtreal(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)=cnvtreal(r.a2))) )
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1,
      CALL cv_log_message(build("translate d2.seq:",d2.seq))
     ELSEIF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)) > 0
      AND ((size(trim(r.a4)) > 0
      AND cnvtint(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val) < cnvtint(r.a4)) OR
     (size(trim(r.a5)) > 0
      AND cnvtint(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val) > cnvtint(r.a5))) )
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].error_msg,"Value :",trim(cv_hrv_rec->harvest_rec[d1.seq].
        abstr_data[d2.seq].result_val),outside_numeric_range,trim(r.a4),
       " and ",trim(r.a5),"."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value
       = "", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag =
      cv_stat_ignore_valid_chk_err
     ELSEIF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val)) > 0
      AND (((cnvtreal(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val) < cv_hrv_rec->
     harvest_rec[d1.seq].abstr_data[d2.seq].normal_low)) OR ((cnvtreal(cv_hrv_rec->harvest_rec[d1.seq
      ].abstr_data[d2.seq].result_val) > cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
     normal_high))) )
      IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].normal_low != 0)
       AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].normal_high != 0))
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d2.seq].error_msg,"Value :",trim(cv_hrv_rec->harvest_rec[d1.seq].
         abstr_data[d2.seq].result_val),outside_normal_range,trim(format(cv_hrv_rec->harvest_rec[d1
          .seq].abstr_data[d2.seq].normal_low,"#######.##;L;F")),
        " and ",trim(format(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].normal_high,
          "#######.##;L;F")),"."), cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 3
      ELSE
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
      ENDIF
     ELSEIF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value))=0)
      IF (l.long_text_id > 0.0)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
      ENDIF
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = r.a2, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "<BLANK>"
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
     ENDIF
    OF "S":
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].result_val,
     IF (cnvtupper(trim(r.a3,3))="UPPER")
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = cnvtupper(cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[d2.seq].result_val)
     ENDIF
     ,
     IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3))=0)
      IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].field_type_meaning !=
      csm_field_type_constant))
       IF (l.long_text_id > 0.0)
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
       ENDIF
      ELSE
       IF (size(trim(r.a2)) != 0)
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
       ENDIF
      ENDIF
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = r.a2, cv_hrv_rec->harvest_rec[
      d1.seq].abstr_data[d2.seq].translated_value = r.a2
     ELSE
      IF (size(trim(r.a1,3)) > 0
       AND size(trim(r.a5,3)) > 0
       AND size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3)) < cnvtint(r.a1
       ))
       WHILE (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val,3)) < cnvtint(r
        .a1))
         cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = concat(trim(r.a5),trim(
           cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))
       ENDWHILE
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].result_val
      ENDIF
      IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag != 3))
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
      ENDIF
     ENDIF
    OF "D":
     formatstring = concat(trim(r.a1),";;d"),
     CALL echo(build("FormatString:",formatstring))
     CALL echo(build("result_dt_tm:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm)
     )
     IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm != 0.0))
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = formatdate(cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,formatstring),
      CALL echo(build("translated_value:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
       translated_value))
     ENDIF
     ,cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = formatdate(cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm,formatstring),
     CALL echo(build("result_val:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val))
     IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm > cnvtdatetime(curdate,
      curtime3)))
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
       d1.seq].abstr_data[d2.seq].error_msg,date_greater_cur)
     ELSEIF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_dt_tm=0))
      IF (l.long_text_id != 0.0)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
      ENDIF
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
     ENDIF
     ,
     IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value,3))=0)
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = r.a2, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "<BLANK>"
     ENDIF
    OF "C":
     namecodevalue = 0.0,namedisplay = "",iret = 0,
     IF (size(trim(r.a1)) != 0
      AND cnvtint(r.a4) > 0)
      IF (size(trim(r.a3)) != 0)
       iret = uar_get_meaning_by_codeset(cnvtint(r.a4),r.a3,1,namecodevalue)
       IF ((namecodevalue=cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_id))
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1, cv_hrv_rec->harvest_rec[d1
        .seq].abstr_data[d2.seq].error_msg = "", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        translated_value = r.a2,
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = r.a1
       ENDIF
      ELSEIF (size(trim(r.a5)) != 0)
       namedisplay = uar_get_code_display(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        result_id)
       IF (cnvtupper(cnvtalphanum(namedisplay))=cnvtupper(cnvtalphanum(r.a5)))
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1, cv_hrv_rec->harvest_rec[d1
        .seq].abstr_data[d2.seq].error_msg = "", cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
        translated_value = r.a2,
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = r.a1
       ENDIF
      ENDIF
     ELSE
      IF ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag != 1))
       IF (l.long_text_id != 0.0)
        cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->
         harvest_rec[d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
       ENDIF
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = r.a2
      ENDIF
     ENDIF
    OF "I":
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value = cv_hrv_rec->harvest_rec[d1
     .seq].abstr_data[d2.seq].result_val,
     IF (size(trim(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value,3))=0)
      IF (l.long_text_id != 0.0)
       cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].error_msg = concat(cv_hrv_rec->harvest_rec[
        d1.seq].abstr_data[d2.seq].error_msg,trim(l.long_text,3))
      ENDIF
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].result_val = "<BLANK>"
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].valid_flag = 1
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 CALL cv_log_message(concat("size(cv_hrv_rec->harvest_rec,5) = ",cnvtstring(size(cv_hrv_rec->
     harvest_rec,5))))
 CALL cv_log_message(concat("cv_hrv_rec->max_abstr_data = ",cnvtstring(cv_hrv_rec->max_abstr_data)))
 CALL cv_log_message("Dumping cv_hrv_rec--------------")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_trans2.dat")
 CALL cv_log_message("calculate device idx's")
 FOR (idx1 = 1 TO size(cv_hrv_rec->harvest_rec,5))
   FOR (idx2 = 1 TO size(cv_hrv_rec->harvest_rec[1].proc_data,5))
     FOR (idx3 = 1 TO size(cv_hrv_rec->harvest_rec[1].proc_data[idx2].lesion,5))
       IF (size(cv_hrv_rec->harvest_rec[1].proc_data[idx2].lesion[idx3].exist_dev_idx,5)=0)
        SET funsuccessful = 1
        SELECT INTO "NL:"
         FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
          (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
         PLAN (d1)
          JOIN (d2
          WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
           AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx=idx2)
           AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx=idx3)
           AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_mean="AC02LGUIDE"))
         DETAIL
          IF (cnvtint(cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].translated_value) !=
          unsuccessful)
           CALL cv_log_message(build("tx val:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].
            translated_value)), funsuccessful = 0
          ENDIF
         WITH nocounter
        ;end select
        CALL cv_log_message(build("size exist_dev_idx = 0:"," idx1:",idx1," idx2:",idx2,
          " idx3:",idx3," fUnsuccessful:",funsuccessful))
        IF ( NOT (funsuccessful))
         SELECT INTO "NL:"
          FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
           (dummyt d2  WITH seq = 1000),
           (dummyt d3  WITH seq = 1000),
           (dummyt d4  WITH seq = 1000)
          PLAN (d1
           WHERE d1.seq=idx1)
           JOIN (d2
           WHERE d2.seq=idx2)
           JOIN (d3
           WHERE d3.seq > idx3
            AND d3.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].lesion,5))
           JOIN (d4
           WHERE d4.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].lesion[d3.seq].
            exist_dev_idx,5))
          DETAIL
           CALL cv_log_message(build("increment exist_dev_idx:"," d1.seq:",d1.seq," d2.seq:",d2.seq,
            " d3.seq:",d3.seq," d4.seq:",d4.seq)), cv_hrv_rec->harvest_rec[d1.seq].proc_data[d2.seq].
           lesion[d3.seq].exist_dev_idx[d4.seq].dev_idx = (cv_hrv_rec->harvest_rec[d1.seq].proc_data[
           d2.seq].lesion[d3.seq].exist_dev_idx[d4.seq].dev_idx+ 1)
          WITH nocounter
         ;end select
         SELECT INTO "NL:"
          FROM (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec,5))),
           (dummyt d2  WITH seq = value(cv_hrv_rec->max_abstr_data))
          PLAN (d1)
           JOIN (d2
           WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
            AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].proc_data_idx=idx2)
            AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].lesion_data_idx > idx3)
            AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx > 0))
          DETAIL
           CALL cv_log_message(build("increment abstr_data:"," d1.seq:",d1.seq," d2.seq:",d2.seq,
            " prev:",cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx)), cv_hrv_rec->
           harvest_rec[d1.seq].abstr_data[d2.seq].dev_idx = (cv_hrv_rec->harvest_rec[d1.seq].
           abstr_data[d2.seq].dev_idx+ 1)
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL cv_log_message("dump cv_hrv_rec")
 EXECUTE cv_log_struct  WITH replace(request,cv_hrv_rec)
 IF ((cv_hrv_rec->dataset_internal_name="ACC03"))
  FREE RECORD copy_field
  RECORD copy_field(
    1 qual[*]
      2 cdf_meaning = vc
      2 task_assay_cd = f8
      2 found_pos = i2
      2 recs[*]
        3 idx = i4
  )
  SET copy_field_cnt = 2
  SET copy_field_idx = 0
  SET stat = alterlist(copy_field->qual,copy_field_cnt)
  SET copy_field->qual[1].cdf_meaning = "AC03PRCAB"
  SET copy_field->qual[2].cdf_meaning = "AC03PRCABDT"
  FOR (copy_field_idx = 1 TO copy_field_cnt)
   SET copy_field->qual[copy_field_idx].task_assay_cd = uar_get_code_by("MEANING",14003,nullterm(
     copy_field->qual[copy_field_idx].cdf_meaning))
   IF ((copy_field->qual[copy_field_idx].task_assay_cd > 0.0))
    SET stat = alterlist(copy_field->qual[copy_field_idx].recs,harv_cnt)
   ELSE
    CALL cv_log_message(concat("WARNING: Failed UAR on cdf_meaning:",copy_field->qual[copy_field_idx]
      .cdf_meaning))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=14003
      AND (cv.cdf_meaning=copy_field->qual[copy_field_idx].cdf_meaning)
      AND cv.active_ind=1
     DETAIL
      copy_field->qual[copy_field_idx].task_assay_cd = cv.code_value
     WITH nocounter
    ;end select
    IF ((copy_field->qual[copy_field_idx].task_assay_cd > 0.0))
     SET stat = alterlist(copy_field->qual[copy_field_idx].recs,harv_cnt)
    ELSE
     CALL cv_log_message(concat("WARNING: Failed select from code_value on cdf_meaning:",copy_field->
       qual[copy_field_idx].cdf_meaning))
    ENDIF
   ENDIF
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d1  WITH seq = harv_cnt),
    (dummyt d2  WITH seq = cv_hrv_rec->max_abstr_data),
    (dummyt d3  WITH seq = copy_field_cnt)
   PLAN (d1)
    JOIN (d3
    WHERE (copy_field->qual[d3.seq].task_assay_cd > 0.0))
    JOIN (d2
    WHERE d2.seq <= size(cv_hrv_rec->harvest_rec[d1.seq].abstr_data,5)
     AND (cv_hrv_rec->harvest_rec[d1.seq].abstr_data[d2.seq].task_assay_cd=copy_field->qual[d3.seq].
    task_assay_cd))
   DETAIL
    IF ((copy_field->qual[d3.seq].recs[d1.seq].idx=0))
     copy_field->qual[d3.seq].recs[d1.seq].idx = d2.seq
    ELSE
     CALL cv_log_message("WARNING: ignoring repeated instance of copied field in same form"),
     CALL cv_log_message(build("Form_id=",cv_hrv_rec->harvest_rec[d1.seq].form_id,", task_assay_cd =",
      copy_field->qual[d3.seq].task_assay_cd))
    ENDIF
    IF ((copy_field->qual[d3.seq].found_pos=0)
     AND (cv_hrv_rec->harvest_rec[d1.seq].form_type_mean="LABVISIT"))
     copy_field->qual[d3.seq].found_pos = d1.seq,
     CALL cv_log_message(build("First labvisit for cdf_meaing=",copy_field->qual[d3.seq].cdf_meaning,
      ", found in form=",d1.seq))
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   l_idx = copy_field->qual[d3.seq].recs[d1.seq].idx, l_base_form = copy_field->qual[d3.seq].
   found_pos, l_base_idx = copy_field->qual[d3.seq].recs[copy_field->qual[d3.seq].found_pos].idx
   FROM (dummyt d1  WITH seq = harv_cnt),
    (dummyt d3  WITH seq = copy_field_cnt)
   PLAN (d3
    WHERE (copy_field->qual[d3.seq].found_pos > 0))
    JOIN (d1
    WHERE (d1.seq != copy_field->qual[d3.seq].found_pos)
     AND (copy_field->qual[d3.seq].recs[d1.seq].idx > 0))
   DETAIL
    IF ((cv_hrv_rec->harvest_rec[l_base_form].abstr_data[l_base_idx].result_val != trim(cv_hrv_rec->
     harvest_rec[d1.seq].abstr_data[l_idx].result_val)))
     IF ( NOT ((cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_idx].result_val IN ("<blank>", "<BLANK>"
     ))))
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_idx].valid_flag = cv_stat_reportwarn, cv_hrv_rec->
      harvest_rec[d1.seq].abstr_data[l_idx].error_msg = build("Charted value (",cv_hrv_rec->
       harvest_rec[d1.seq].abstr_data[l_idx].result_val,") overwritten with (",cv_hrv_rec->
       harvest_rec[l_base_form].abstr_data[l_base_idx].result_val,") from first lab visit form")
     ELSE
      cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_idx].valid_flag = cv_hrv_rec->harvest_rec[
      l_base_form].abstr_data[l_base_idx].valid_flag, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[
      l_idx].error_msg = build("Blank value defaulted to (",cv_hrv_rec->harvest_rec[l_base_form].
       abstr_data[l_base_idx].result_val,") from first lab visit form")
     ENDIF
     cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_idx].result_val = cv_hrv_rec->harvest_rec[
     l_base_form].abstr_data[l_base_idx].result_val, cv_hrv_rec->harvest_rec[d1.seq].abstr_data[l_idx
     ].translated_value = cv_hrv_rec->harvest_rec[l_base_form].abstr_data[l_base_idx].
     translated_value,
     CALL cv_log_message(build("Setting result for cdf_meaning=",copy_field->qual[d3.seq].cdf_meaning,
      ", in form=",d1.seq))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE formatdate(paramval,paramformat)
   DECLARE tmp_str = vc WITH protect
   CALL parser("set tmp_str = format(paramVal, paramFormat) go")
   CALL cv_log_message(build("pv:",paramval," pf:",paramformat," temp_str:",
     tmp_str))
   RETURN(tmp_str)
 END ;Subroutine
#exit_script
 CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec_trans.dat")
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
 DECLARE cv_get_harvest_translate_vrsn = vc WITH private, constant("MOD 039 10/02/2006 MH9140")
END GO
