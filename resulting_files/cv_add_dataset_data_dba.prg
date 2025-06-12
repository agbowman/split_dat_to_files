CREATE PROGRAM cv_add_dataset_data:dba
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
 SET csm_field_type_lname = "PLNAME"
 SET csm_field_type_fname = "PFNAME"
 SET csm_field_type_mname = "PMNAME"
 SET csm_field_type_hosp = "EHOSP"
 SET csm_field_type_part_nbr = "EPARTNBR"
 SET csm_field_type_birth_date = "PBTHDATE"
 SET csm_field_type_sex = "PSEXCD"
 SET csm_field_type_ssn = "PSSN"
 SET csm_field_type_prsnl_ssn = "PRSNLSSN"
 SET csm_field_type_regdate = "EREGDATE"
 SET csm_field_type_dischdate = "EDISCHDATE"
 SET csm_field_type_link = "PROCLINK"
 SET csm_field_type_race = "PRACECD"
 SET csm_field_type_constant = "CONSTANT"
 SET csm_field_type_patientid = "PPATIENTID"
 SET csm_field_type_patientage = "PATIENTAGE"
 SET csm_field_type_recordid = "CRECORDID"
 SET csm_field_type_mrn = "PMRN"
 SET csm_field_type_patientzip = "APATIENTZIP"
 SET csm_field_type_hospzip = "AHOSPZIP"
 SET csm_field_type_hospstate = "AHOSPSTATE"
 SET csm_field_type_reccomp = "XRECCOMP"
 SET csm_field_type_alpha = "ALPHA"
 SET csm_field_type_numeric = "NUMERIC"
 SET csm_field_type_date = "DATE"
 SET csm_field_type_string = "STRING"
 SET csm_field_type_prsnl_upin = "PRSNLUPIN"
 SET csm_field_type_stspatid = "STSPATID"
 FREE SET register
 RECORD register(
   1 cv_case_id = f8
   1 rec[*]
     2 xref_id = f8
     2 event_id = f8
     2 parent_event_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 clinical_event_id = f8
     2 result_val = vc
     2 insert_ind = i2
     2 dub_ind = i2
 )
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
 IF (validate(cv_omf_rec,"notdefined") != "notdefined")
  CALL cv_log_message("cv_omf_rec  is already defined!")
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
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 delim = vc
    1 file_name = vc
  )
  SET request->file_name = "TEST"
  SET request->delim = "|"
 ENDIF
 DECLARE cv_pad_date(parse_string=vc) = vc
 DECLARE auth_cd = f8 WITH protect
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 max_values = i4
    1 reply_message = vc
    1 list[*]
      2 line = vc
      2 values[*]
        3 value = vc
        3 name = vc
    1 files[*]
      2 filename = vc
      2 info_line[*]
        3 new_line = vc
    1 caselog[*]
      2 errorlog[*]
        3 error = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cv_log_error(icaseno=i4,serror=vc) = null
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH protect, noconstant("F")
 FREE RECORD req_parse
 RECORD req_parse(
   1 data_in_mem_ind = i2
   1 delim = vc
 )
 FREE RECORD rep_parse
 RECORD rep_parse(
   1 max_values = i4
   1 list[*]
     2 line = vc
     2 person_id = f8
     2 encntr_id = f8
     2 record_id = f8
     2 bvaliddatastatus = i2
     2 values[*]
       3 value = vc
       3 name = vc
       3 xref_id = f8
       3 result_val = vc
       3 result_id = f8
       3 result_dt_tm = dq8
       3 event_cd = f8
       3 person_id = f8
       3 encntr_id = f8
     2 participant_nbr = vc
     2 surgeon_name = vc
     2 surgeon_id = f8
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echorecord(request,"cer_temp:CVADDSDT_REQUEST.dat")
 CALL cv_log_message("dump request")
 EXECUTE cv_log_struct
 IF (validate(cv_utl_imp_file_name,0))
  IF (validate(request->file_name,0))
   IF (validate(cv_utl_imp_file_name,0))
    SET request->file_name = cv_utl_imp_file_name
   ELSE
    SET request->file_name = "cer_temp:cv_cases.csv"
   ENDIF
   CALL cv_log_message("after Enter packing rep_parse->list")
   EXECUTE cv_utl_read_csv
   SET cntl = 0
   SET cntv = 0
   SET rep_parse->max_values = reply->max_values
   SET stat = alterlist(rep_parse->list,size(reply->list,5))
   FOR (cntl = 1 TO size(reply->list,5))
     SET rep_parse->list[cntl].line = reply->list[cntl].line
     SET stat = alterlist(rep_parse->list[cntl].values,size(reply->list[cntl].values,5))
     FOR (cntv = 1 TO size(reply->list[cntl].values,5))
      SET rep_parse->list[cntl].values[cntv].name = reply->list[cntl].values[cntv].name
      SET rep_parse->list[cntl].values[cntv].value = reply->list[cntl].values[cntv].value
     ENDFOR
   ENDFOR
   IF ( NOT (validate(codevalue_l,0)))
    SET codevalue_l = - (1234.0)
   ENDIF
   IF ( NOT (validate(codevalue_s,0)))
    SET codevalue_s = - (5678.0)
   ENDIF
  ENDIF
  SET num_cases = size(rep_parse->list,5)
  SET stat = alterlist(rep_parse->list,(num_cases+ 1),0)
 ELSE
  SET curfileindex = 1
  IF (validate(curfileindex,0))
   SET stat = alterlist(rep_parse->list,size(request->file[curfileindex].line,5))
   SET idx = 0
   FOR (idx = 1 TO size(rep_parse->list,5))
     SET rep_parse->list[idx].line = request->file[curfileindex].line[idx].linedata
   ENDFOR
   SET req_parse->data_in_mem_ind = 1
   SET req_parse->delim = "|"
   EXECUTE cv_utl_read_csv  WITH replace(request,req_parse), replace(reply,rep_parse)
   CALL cv_log_message("cv_utl_read_csv executed!")
  ENDIF
 ENDIF
 CALL echorecord(rep_parse,"cer_temp:rep_parse.dat")
 DECLARE list_cnt = i4 WITH protect
 DECLARE list_idx = i4 WITH protect
 SET list_cnt = size(rep_parse->list,5)
 FREE RECORD person_request
 RECORD person_request(
   1 person[*]
     2 patientid = f8
     2 gender = vc
     2 race = vc
     2 patient_first_name = vc
     2 patient_m_i = vc
     2 date_of_birth = dq8
     2 patient_last_name = vc
     2 ssn = vc
     2 mrn = vc
     2 patient_zip_code = vc
     2 hospital_state = vc
     2 hospital_zip_code = vc
     2 hospital_name = vc
     2 date_of_admission = dq8
     2 date_of_discharge = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 bvaliddatastatus = i2
     2 recordid_str = vc
 )
 SET stat = alterlist(person_request->person,size(rep_parse->list,5))
 DECLARE dataversion = vc WITH protect
 IF (size(rep_parse->list,5) < 2)
  CALL cv_log_message("No Data Found")
  GO TO exit_script
 ENDIF
 DECLARE bdatavrsnexists = i2 WITH protect
 DECLARE bmrnexists = i2 WITH protect
 DECLARE bsurgdtexists = i2 WITH protect
 DECLARE bpatidexists = i2 WITH protect
 DECLARE brecordidexists = i2 WITH protect
 DECLARE blastname = i2 WITH protect
 DECLARE bfirstname = i2 WITH protect
 DECLARE bdob = i2 WITH protect
 DECLARE bgender = i2 WITH protect
 DECLARE brace = i2 WITH protect
 DECLARE bssn = i2 WITH protect
 DECLARE badmitdt = i2 WITH protect
 DECLARE bdischdt = i2 WITH protect
 DECLARE bhospname = i2 WITH protect
 DECLARE bhospzip = i2 WITH protect
 DECLARE bhospstat = i2 WITH protect
 DECLARE count = i2 WITH protect
 DECLARE nforceencntrcol = i2 WITH protect
 DECLARE headerfield = vc WITH protect
 WHILE (count < size(rep_parse->list[2].values,5))
   SET count = (count+ 1)
   SET headerfield = cnvtupper(rep_parse->list[2].values[count].name)
   IF (headerfield="DATAVRSN")
    SET dataversion = rep_parse->list[2].values[count].value
    SET bdatavrsnexists = 1
   ELSEIF (headerfield="MEDRECN")
    SET bmrnexists = 1
   ELSEIF (headerfield="SURGDT")
    SET bsurgdtexists = 1
   ELSEIF (headerfield="PATID")
    SET bpatidexists = 1
   ELSEIF (headerfield="RECORDID")
    SET brecordidexists = 1
   ELSEIF (headerfield="PATLNAME")
    SET blastname = 1
   ELSEIF (headerfield="PATFNAME")
    SET bfirstname = 1
   ELSEIF (headerfield="DOB")
    SET bdob = 1
   ELSEIF (headerfield="GENDER")
    SET bgender = 1
   ELSEIF (headerfield="SSN")
    SET bssn = 1
   ELSEIF (headerfield="RACE")
    SET brace = 1
   ELSEIF (headerfield="ADMITDT")
    SET badmitdt = 1
   ELSEIF (headerfield="DISCHDT")
    SET bdischdt = 1
   ELSEIF (headerfield="HOSPNAME")
    SET bhospname = 1
   ELSEIF (headerfield="HOSPZIP")
    SET bhospzip = 1
   ELSEIF (headerfield="HOSPSTAT")
    SET bhospstat = 1
   ELSEIF (headerfield="ENCOUNTER")
    SET nforceencntrcol = count
    CALL cv_log_error(1,build("nForceEncntrCol set to :",nforceencntrcol))
   ENDIF
 ENDWHILE
 IF (((bdatavrsnexists=0) OR (((bsurgdtexists=0) OR (nforceencntrcol=0
  AND ((bmrnexists=0) OR (((bpatidexists=0) OR (brecordidexists=0)) )) )) )) )
  IF (bdatavrsnexists=0)
   CALL cv_log_error(1,"No DATAVRSN field found")
  ENDIF
  IF (bmrnexists=0)
   CALL cv_log_error(1,"No MRN field found")
  ENDIF
  IF (bsurgdtexists=0)
   CALL cv_log_error(1,"No SurgDt field found")
  ENDIF
  IF (bpatidexists=0)
   CALL cv_log_error(1,"No PatId field found")
  ENDIF
  IF (brecordidexists=0)
   CALL cv_log_error(1,"No RecordId field found")
  ENDIF
  GO TO exit_script
 ENDIF
 DECLARE datasetid = f8 WITH protect
 DECLARE alias_pool_cs = i4 WITH protect, constant(263)
 DECLARE part_nbr_pool_cd = f8 WITH protect
 DECLARE part_nbr_pool_mean = vc WITH protect
 SELECT INTO "nl:"
  d.alias_pool_mean, cx.dataset_id, d.alias_pool_mean
  FROM cv_xref cx,
   cv_response cr,
   cv_dataset d
  PLAN (cr
   WHERE cr.a2=dataversion
    AND cr.response_internal_name="*_DATAVRSN")
   JOIN (cx
   WHERE cx.xref_id=cr.xref_id)
   JOIN (d
   WHERE d.dataset_id=cx.dataset_id)
  DETAIL
   datasetid = cx.dataset_id, part_nbr_pool_mean = d.alias_pool_mean, part_nbr_pool_cd =
   uar_get_code_by("MEANING",263,d.alias_pool_mean)
  WITH nocounter
 ;end select
 IF (((datasetid=0.0) OR (curqual != 1)) )
  CALL cv_log_error(1,concat("INVALID datasetid: dataset_id = ",cnvtstring(datasetid)," curqual = ",
    cnvtstring(curqual)))
  GO TO exit_script
 ENDIF
 IF (part_nbr_pool_cd <= 0.0
  AND size(trim(part_nbr_pool_mean)) > 0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=alias_pool_cs
    AND cv.cdf_meaning=part_nbr_pool_mean
   DETAIL
    part_nbr_pool_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (part_nbr_pool_cd <= 0.0)
  CALL cv_log_error(1,"No valid alias_pool_cd found for Participant Number")
  GO TO exit_script
 ENDIF
 CALL cv_log_message("dump rep_parse")
 EXECUTE cv_log_struct  WITH replace(request,rep_parse)
 SET datestr = fillstring(128," ")
 DECLARE timeint = i4 WITH protect, noconstant(- (1))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rep_parse->list,5))),
   (dummyt d1  WITH seq = value(rep_parse->max_values)),
   cv_xref x,
   cv_response r
  PLAN (d
   WHERE d.seq > 1)
   JOIN (d1
   WHERE d1.seq <= size(rep_parse->list[d.seq].values,5))
   JOIN (x
   WHERE x.dataset_id=datasetid
    AND trim(substring((findstring("_",x.xref_internal_name)+ 1),100,x.xref_internal_name))=cnvtupper
   (rep_parse->list[d.seq].values[d1.seq].name))
   JOIN (r
   WHERE r.xref_id=x.xref_id)
  ORDER BY d.seq, d1.seq, x.xref_id
  HEAD d.seq
   fname = fillstring(64," "), lname = fillstring(64," "), mname = fillstring(64," "),
   ssn = fillstring(32," "), bdate = fillstring(32," "), person_id = 0.0
  HEAD d1.seq
   rep_parse->list[d.seq].values[d1.seq].xref_id = x.xref_id, rep_parse->list[d.seq].values[d1.seq].
   event_cd = x.event_cd, rep_parse->list[d.seq].values[d1.seq].result_val = trim(rep_parse->list[d
    .seq].values[d1.seq].value,3)
   IF (cnvtupper(rep_parse->list[d.seq].values[d1.seq].value)="<BLANK>")
    rep_parse->list[d.seq].values[d1.seq].result_val = " ", rep_parse->list[d.seq].values[d1.seq].
    value = " "
   ENDIF
  DETAIL
   CASE (uar_get_code_meaning(x.field_type_cd))
    OF csm_field_type_fname:
     person_request->person[d.seq].patient_first_name = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_mname:
     person_request->person[d.seq].patient_m_i = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_lname:
     person_request->person[d.seq].patient_last_name = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_ssn:
     person_request->person[d.seq].ssn = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_birth_date:
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdate2(cnvtalphanum(rep_parse->list[d
       .seq].values[d1.seq].value),"MMDDYYYY"),person_request->person[d.seq].date_of_birth =
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm
    OF csm_field_type_sex:
     person_request->person[d.seq].gender = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_mrn:
     person_request->person[d.seq].mrn = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_patientzip:
     person_request->person[d.seq].patient_zip_code = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_hosp:
     person_request->person[d.seq].hospital_name = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_hospzip:
     person_request->person[d.seq].hospital_zip_code = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_hospstate:
     person_request->person[d.seq].hospital_state = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_race:
     person_request->person[d.seq].race = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_stspatid:
     person_request->person[d.seq].patientid = cnvtint(rep_parse->list[d.seq].values[d1.seq].value)
    OF csm_field_type_recordid:
     rep_parse->list[d.seq].record_id = cnvtint(rep_parse->list[d.seq].values[d1.seq].value),
     person_request->person[d.seq].recordid_str = trim(rep_parse->list[d.seq].values[d1.seq].value,3)
    OF csm_field_type_part_nbr:
     rep_parse->list[d.seq].participant_nbr = rep_parse->list[d.seq].values[d1.seq].value
    OF csm_field_type_patientage:
    OF csm_field_type_constant:
     col 0
    OF csm_field_type_alpha:
     IF (cnvtupper(trim(r.a1,3))=cnvtupper(trim(rep_parse->list[d.seq].values[d1.seq].value,3)))
      rep_parse->list[d.seq].values[d1.seq].result_id = r.nomenclature_id
     ENDIF
    OF csm_field_type_regdate:
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdate2(cnvtalphanum(rep_parse->list[d
       .seq].values[d1.seq].value),"MMDDYYYY"),person_request->person[d.seq].date_of_admission =
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm
    OF csm_field_type_dischdate:
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdate2(cnvtalphanum(rep_parse->list[d
       .seq].values[d1.seq].value),"MMDDYYYY"),person_request->person[d.seq].date_of_discharge =
     rep_parse->list[d.seq].values[d1.seq].result_dt_tm
    OF csm_field_type_date:
     IF (size(trim(rep_parse->list[d.seq].values[d1.seq].value)) > 0)
      IF (x.xref_internal_name IN ("STS03_SISTARTT", "STS03_SISTOPT"))
       rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdatetime(concat("01-JAN-2000 ",
         rep_parse->list[d.seq].values[d1.seq].value))
      ELSEIF (x.xref_internal_name IN ("ST02_SISTARTT", "ST02_SISTOPT"))
       rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdatetime(cnvtdate(01012000),cnvtint(
         rep_parse->list[d.seq].values[d1.seq].value))
      ELSE
       rep_parse->list[d.seq].values[d1.seq].result_dt_tm = cnvtdate2(cnvtalphanum(rep_parse->list[d
         .seq].values[d1.seq].value),"MMDDYYYY")
      ENDIF
      CASE (cnvtupper(trim(rep_parse->list[d.seq].values[d1.seq].name)))
       OF "ADMITDT":
        person_request->person[d.seq].date_of_admission = rep_parse->list[d.seq].values[d1.seq].
        result_dt_tm
       OF "DISCHDT":
        person_request->person[d.seq].date_of_discharge = rep_parse->list[d.seq].values[d1.seq].
        result_dt_tm
      ENDCASE
     ENDIF
    OF csm_field_type_string:
     IF (cnvtupper(trim(rep_parse->list[d.seq].values[d1.seq].name))="SURGEON")
      rep_parse->list[d.seq].surgeon_name = rep_parse->list[d.seq].values[d1.seq].value
     ENDIF
   ENDCASE
  FOOT  d1.seq
   col 0
  FOOT  d.seq
   col 0
  WITH nocounter
 ;end select
 EXECUTE cv_log_struct  WITH replace(request,person_request)
 IF (nforceencntrcol > 0)
  CALL cv_log_error(1,"nForceEncntrCol begin lookups")
  FOR (count = 1 TO size(rep_parse->list,5))
   SET person_request->person[count].encntr_id = cnvtreal(rep_parse->list[count].values[
    nforceencntrcol].value)
   CALL cv_log_error(count,build("Set encntr_id to:",person_request->person[count].encntr_id))
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    (dummyt d  WITH seq = value(size(person_request->person,5)))
   PLAN (d
    WHERE (person_request->person[d.seq].encntr_id > 0.0))
    JOIN (e
    WHERE (e.encntr_id=person_request->person[d.seq].encntr_id))
   DETAIL
    person_request->person[d.seq].person_id = e.person_id, person_request->person[d.seq].
    bvaliddatastatus = 1
   WITH nocounter
  ;end select
  CALL cv_log_error(1,build("nForceEncntrCol lookups curqual:",curqual))
  GO TO end_encounter_checks
 ENDIF
 EXECUTE cv_add_person_demog
 CALL echorecord(person_request,"cer_temp:person_request1.dat")
 DECLARE patlname = vc WITH protect
 DECLARE patfname = vc WITH protect
 DECLARE dob = dq8 WITH protect
 DECLARE gender = vc WITH protect
 DECLARE race = vc WITH protect
 DECLARE admit = dq8 WITH protect
 DECLARE discharge = dq8 WITH protect
 DECLARE ssn = vc WITH protect
 DECLARE hospname = vc WITH protect
 DECLARE errordisplay = vc WITH protect
 SELECT INTO "nl:"
  FROM person p,
   (dummyt d  WITH seq = size(person_request->person,5))
  PLAN (d
   WHERE d.seq > 1)
   JOIN (p
   WHERE (p.person_id=person_request->person[d.seq].person_id))
  DETAIL
   patlname = cnvtupper(p.name_last_key), patfname = cnvtupper(p.name_first_key), dob = p.birth_dt_tm,
   gender = cnvtupper(uar_get_code_display(p.sex_cd)), race = cnvtupper(uar_get_code_display(p
     .race_cd))
   IF (bfirstname=1
    AND cnvtupper(person_request->person[d.seq].patient_first_name) != cnvtupper(patfname)
    AND (person_request->person[d.seq].patient_first_name > " "))
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching PatFName"), tempstring = person_request->person[d.seq
    ].patient_first_name,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("PatFName from select- ",patfname))
   ENDIF
   IF (blastname=1
    AND cnvtupper(person_request->person[d.seq].patient_last_name) != cnvtupper(patlname)
    AND (person_request->person[d.seq].patient_last_name > " "))
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching PatLName"), tempstring = person_request->person[d.seq
    ].patient_last_name,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("PatLName from select- ",patlname))
   ENDIF
   IF (bdob=1
    AND cnvtdate(person_request->person[d.seq].date_of_birth) != cnvtdate(dob)
    AND (person_request->person[d.seq].date_of_birth > 0))
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching DOB")
   ENDIF
   IF (bgender=1
    AND cnvtupper(person_request->person[d.seq].gender) != gender
    AND (person_request->person[d.seq].gender > " "))
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching Gender"), tempstring = person_request->person[d.seq].
    gender,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("Gender from select- ",gender))
   ENDIF
   IF (brace=1
    AND cnvtupper(person_request->person[d.seq].race) != race
    AND (person_request->person[d.seq].race > " "))
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching Race"), tempstring = person_request->person[d.seq].
    race,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("Race from select- ",race))
   ENDIF
  WITH nocounter
 ;end select
 DECLARE add_type_cd = f8 WITH protect
 SET add_type_cd = uar_get_code_by("MEANING",212,"BUSINESS")
 SELECT INTO "nl:"
  addy_seq = decode(a.seq,a.address_type_seq,99)
  FROM encounter e,
   organization o,
   address a,
   (dummyt d  WITH seq = size(person_request->person,5))
  PLAN (d
   WHERE d.seq > 1)
   JOIN (e
   WHERE (e.person_id=person_request->person[d.seq].person_id)
    AND (e.encntr_id=person_request->person[d.seq].encntr_id))
   JOIN (o
   WHERE e.organization_id=o.organization_id)
   JOIN (a
   WHERE a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.parent_entity_id=outerjoin(o.organization_id)
    AND a.address_type_cd=outerjoin(add_type_cd)
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
  ORDER BY d.seq, addy_seq
  HEAD d.seq
   rep_parse->list[d.seq].organization_id = o.organization_id, hospzip = a.zipcode, hospstate =
   cnvtupper(a.state)
   IF (bhospzip=1
    AND (person_request->person[d.seq].hospital_zip_code != hospzip))
    CALL cv_log_error(d.seq,"Failed in matching HospZip"), tempstring = person_request->person[d.seq]
    .hospital_zip_code,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("Hospital_ZIP_Code from select- ",hospzip))
   ELSEIF (bhospstat=1
    AND (person_request->person[d.seq].hospital_state != hospstate))
    CALL cv_log_error(d.seq,"Failed in matching HospState"), tempstring = person_request->person[d
    .seq].hospital_state,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("Hospital_State from select- ",hospstate))
   ENDIF
  DETAIL
   admit = e.reg_dt_tm, discharge = e.disch_dt_tm, hospname = cnvtupper(o.org_name)
   IF (badmitdt=1
    AND cnvtdate(person_request->person[d.seq].date_of_admission) != cnvtdate(admit))
    CALL cv_log_error(d.seq,"Failed in matching Date_of_Admission")
   ENDIF
   IF (bdischdt=1
    AND cnvtdate(person_request->person[d.seq].date_of_discharge) != cnvtdate(discharge))
    CALL cv_log_error(d.seq,"Failed in matching Date_of_Discharge")
   ENDIF
   IF (bhospname=1
    AND cnvtupper(person_request->person[d.seq].hospital_name) != hospname)
    person_request->person[d.seq].bvaliddatastatus = 0,
    CALL cv_log_error(d.seq,"Failed in matching Hospital_Name"), tempstring = person_request->person[
    d.seq].hospital_name,
    CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
    CALL cv_log_error(d.seq,build("HospName from select- ",hospname))
   ENDIF
  WITH nocounter
 ;end select
 IF (bssn=1)
  DECLARE patssn = f8 WITH protect
  SET ssncd = uar_get_code_by("DISPLAY",4,"SSN")
  SELECT INTO "nl:"
   FROM person_alias pa,
    (dummyt d  WITH seq = size(person_request->person,5))
   PLAN (d
    WHERE d.seq > 1)
    JOIN (pa
    WHERE (pa.person_id=person_request->person[d.seq].person_id)
     AND pa.person_alias_type_cd=ssncd)
   DETAIL
    ssn = pa.alias
    IF (trim(cnvtalphanum(person_request->person[d.seq].ssn)) != trim(cnvtalphanum(ssn))
     AND (person_request->person[d.seq].ssn > " "))
     person_request->person[d.seq].bvaliddatastatus = 0,
     CALL cv_log_error(d.seq,"Failed in matching SSN"), tempstring = person_request->person[d.seq].
     ssn,
     CALL cv_log_error(d.seq,concat("Input Data - ",tempstring)),
     CALL cv_log_error(d.seq,build("SSN from select- ",ssn))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr,
   (dummyt d  WITH seq = list_cnt)
  PLAN (d
   WHERE d.seq > 0
    AND size(trim(rep_parse->list[d.seq].surgeon_name)) > 0)
   JOIN (pr
   WHERE pr.physician_ind=1
    AND pr.name_full_formatted=trim(rep_parse->list[d.seq].surgeon_name))
  DETAIL
   rep_parse->list[d.seq].surgeon_id = pr.person_id
  WITH nocounter
 ;end select
 FREE RECORD part_rec
 RECORD part_rec(
   1 organization_id = f8
   1 dataset[*]
     2 dataset_id = f8
     2 alias_pool_cd = f8
     2 alias_pool_mean = c12
     2 organization_id = f8
     2 participant_prsnl_id = f8
     2 participant_nbr = vc
 )
 SET stat = alterlist(part_rec->dataset,1)
 SET part_rec->dataset[1].dataset_id = datasetid
 FOR (list_idx = 2 TO list_cnt)
   SET part_rec->organization_id = rep_parse->list[list_idx].organization_id
   SET part_rec->dataset[1].organization_id = rep_parse->list[list_idx].organization_id
   SET part_rec->dataset[1].participant_prsnl_id = rep_parse->list[list_idx].surgeon_id
   SET part_rec->dataset[1].participant_nbr = fillstring(132," ")
   EXECUTE cv_get_dataset_part_nbr  WITH replace("CV_OMF_REC","PART_REC")
   IF (trim(part_rec->dataset[1].participant_nbr) != trim(rep_parse->list[list_cnt].participant_nbr))
    SET person_request->person[list_cnt].bvaliddatastatus = 0
    CALL cv_log_error(list_idx,"Failed in matching Participant Number")
    SET tempstring = rep_parse->list[list_cnt].participant_nbr
    CALL cv_log_error(list_idx,concat("Input Value -",tempstring))
    SET tempstring = part_rec->dataset[1].participant_nbr
    CALL cv_log_error(list_idx,concat("Lookup Value -",tempstring))
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM cv_case_dataset_r ccdr,
   cv_dataset d,
   cv_dataset d2,
   (dummyt d3  WITH seq = list_cnt)
  PLAN (d3
   WHERE d3.seq > 1
    AND (person_request->person[d3.seq].bvaliddatastatus=1))
   JOIN (ccdr
   WHERE (ccdr.registry_nbr=rep_parse->list[d3.seq].record_id)
    AND (ccdr.participant_nbr=rep_parse->list[d3.seq].participant_nbr))
   JOIN (d
   WHERE d.dataset_id=ccdr.dataset_id)
   JOIN (d2
   WHERE d2.dataset_id=datasetid
    AND d2.alias_pool_mean=d.alias_pool_mean)
  DETAIL
   person_request->person[d3.seq].bvaliddatastatus = 0,
   CALL cv_log_error(d3.seq,"Collision with existing registry_nbr"),
   CALL cv_log_error(d3.seq,build("Input Data:",rep_parse->list[d3.seq].record_id)),
   CALL cv_log_error(d3.seq,build("Colliding case_dataset_r_id:",ccdr.case_dataset_r_id))
  WITH nocounter
 ;end select
 DECLARE patid_pool_mean_prefix = c6 WITH protect, constant("STSPID")
 FREE RECORD request_patid
 RECORD request_patid(
   1 person_id = f8
   1 alias_pool_mean = vc
   1 alias = vc
   1 enable_insert_ind = i2
 )
 FREE RECORD reply_patid
 RECORD reply_patid(
   1 patid = vc
   1 action_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echorecord(person_request)
 FOR (num = 1 TO size(person_request->person,5))
   IF ((person_request->person[num].bvaliddatastatus=1))
    IF ((person_request->person[num].patientid > 0))
     SET request_patid->person_id = person_request->person[num].person_id
     SET request_patid->alias_pool_mean = concat(patid_pool_mean_prefix,rep_parse->list[num].
      participant_nbr)
     SET request_patid->alias = cnvtstring(person_request->person[num].patientid)
     SET request_patid->enable_insert_ind = 1
     FREE RECORD reply_patid
     RECORD reply_patid(
       1 patid = vc
       1 action_ind = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     EXECUTE cv_get_harvest_patid
     IF ((reply_patid->status_data.status != "S"))
      SET person_request->person[num].bvaliddatastatus = 0
      CALL cv_log_error(num,"Failed in cv_get_harvest_patid")
      CALL cv_log_error(num,build("Requested PatID:",request_patid->alias))
      CALL cv_log_error(num,build("Reply PatID:",reply_patid->patid))
     ENDIF
    ELSE
     SET person_request->person[num].bvaliddatastatus = 0
     CALL cv_log_error(num,"Patient ID missing")
    ENDIF
   ENDIF
 ENDFOR
 FOR (num = 2 TO size(person_request->person,5))
  IF ((person_request->person[num].person_id=0.0))
   CALL cv_log_error(num,"Mrn match failed. missing person_id and encounter information")
  ENDIF
  IF ((person_request->person[num].bvaliddatastatus=1))
   CALL cv_log_error(num,"Patient Data and Input Data -  Match")
  ENDIF
 ENDFOR
#end_encounter_checks
 SET casecnt = 0
 FOR (casecnt = 1 TO size(person_request->person,5))
   SET rep_parse->list[casecnt].bvaliddatastatus = person_request->person[casecnt].bvaliddatastatus
   SET rep_parse->list[casecnt].person_id = person_request->person[casecnt].person_id
   SET rep_parse->list[casecnt].encntr_id = person_request->person[casecnt].encntr_id
   FOR (fldcnt = 1 TO size(rep_parse->list[casecnt].values,5))
    SET rep_parse->list[casecnt].values[fldcnt].person_id = person_request->person[casecnt].person_id
    SET rep_parse->list[casecnt].values[fldcnt].encntr_id = person_request->person[casecnt].encntr_id
   ENDFOR
 ENDFOR
 CALL cv_log_message("dump person_request")
 EXECUTE cv_log_struct  WITH replace(request,person_request)
 CALL cv_log_message("dump rep_parse")
 EXECUTE cv_log_struct  WITH replace(request,rep_parse)
 FREE RECORD register
 RECORD register(
   1 calling_script_flag = i2
   1 cv_case_id = f8
   1 top_parent_event_id = f8
   1 no_event_id_ind = i2
   1 rec[*]
     2 xref_id = f8
     2 event_id = f8
     2 parent_event_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 clinical_event_id = f8
     2 result_val = vc
     2 result_id = f8
     2 result_dt_tm = dq8
     2 insert_ind = i2
     2 dub_ind = i2
     2 result_status_cd = f8
     2 result_status_change_ind = f8
 )
 SET register->calling_script_flag = 1
 SET register->no_event_id_ind = 1
 SET frmdate = cnvtdatetime(curdate,curtime3)
 SET cv_imp_dem_err_fil = fillstring(32," ")
 SET cv_imp_dem_err_fil = concat("cer_temp:CVIMPERR",format(frmdate,"DDMMHHMM;;Q"),".dat")
 DECLARE errcount = i4
 SELECT INTO value(cv_imp_dem_err_fil)
  birth_date = format(person_request->person[d.seq].date_of_birth,";;Q"), admit_date = format(
   person_request->person[d.seq].date_of_admission,";;Q"), disch_date = format(person_request->
   person[d.seq].date_of_discharge,";;Q")
  FROM (dummyt d  WITH seq = value(size(rep_parse->list,5)))
  PLAN (d
   WHERE d.seq > 1
    AND (((rep_parse->list[d.seq].person_id <= 0)) OR ((rep_parse->list[d.seq].encntr_id <= 0))) )
  HEAD REPORT
   row 0, errcount = 0
  DETAIL
   errcount = (errcount+ 1)
   IF ((rep_parse->list[d.seq].person_id <= 0)
    AND (rep_parse->list[d.seq].encntr_id <= 0))
    col 0, "Missing person and encounter:", row + 1
   ELSEIF ((rep_parse->list[d.seq].person_id > 0)
    AND (rep_parse->list[d.seq].encntr_id <= 0))
    col 0, "Missing encounter for person:", row + 1
   ELSE
    col 0, "Missing person/encounter data:", row + 1
   ENDIF
   col 4, "first name = ", person_request->person[d.seq].patient_first_name,
   "middle name = ", person_request->person[d.seq].patient_m_i, "last name = ",
   person_request->person[d.seq].patient_last_name, row + 1, col 4,
   "date of birth = ", birth_date, "date of admission = ",
   admit_date, "date of discharge = ", disch_date,
   row + 1,
   CALL cv_log_message(build("Missing info. lname:",person_request->person[d.seq].patient_last_name)),
   CALL cv_log_message(build("              fname:",person_request->person[d.seq].patient_first_name)
   ),
   CALL cv_log_message(build("          person_id:",rep_parse->list[d.seq].person_id)),
   CALL cv_log_message(build("       encounter_id:",rep_parse->list[d.seq].encntr_id))
  FOOT REPORT
   col 0
  WITH nocounter
 ;end select
 CALL cv_log_message(build("Incomplete demographic info cases = ",errcount))
 CALL echorecord(person_request,"cer_temp:person_request2.dat")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 FOR (casecnt = 1 TO size(rep_parse->list,5))
   IF ((rep_parse->list[casecnt].bvaliddatastatus=1)
    AND (rep_parse->list[casecnt].person_id > 0)
    AND (rep_parse->list[casecnt].encntr_id > 0))
    SET regfldcnt = 0
    IF ((rep_parse->list[casecnt].record_id > 0))
     SET register->top_parent_event_id = - ((1 * rep_parse->list[casecnt].record_id))
     CALL echo(build("Record_ID: ",register->top_parent_event_id))
    ENDIF
    FOR (fldcnt = 1 TO size(rep_parse->list[casecnt].values,5))
      IF ((rep_parse->list[casecnt].values[fldcnt].event_cd > 0.0)
       AND trim(rep_parse->list[casecnt].values[fldcnt].result_val) > " ")
       SET regfldcnt = (regfldcnt+ 1)
       IF (mod(regfldcnt,10)=1)
        SET stat = alterlist(register->rec,(regfldcnt+ 9))
       ENDIF
       SET register->rec[regfldcnt].result_status_cd = auth_cd
       SET register->rec[regfldcnt].result_status_change_ind = 1
       SET register->rec[regfldcnt].xref_id = rep_parse->list[casecnt].values[fldcnt].xref_id
       SET register->rec[regfldcnt].event_cd = rep_parse->list[casecnt].values[fldcnt].event_cd
       SET register->rec[regfldcnt].result_val = rep_parse->list[casecnt].values[fldcnt].result_val
       SET register->rec[regfldcnt].person_id = rep_parse->list[casecnt].values[fldcnt].person_id
       SET register->rec[regfldcnt].encntr_id = rep_parse->list[casecnt].values[fldcnt].encntr_id
       SET register->rec[regfldcnt].result_id = rep_parse->list[casecnt].values[fldcnt].result_id
       SET register->rec[regfldcnt].result_dt_tm = rep_parse->list[casecnt].values[fldcnt].
       result_dt_tm
      ENDIF
    ENDFOR
    SET stat = alterlist(register->rec,regfldcnt)
    CALL echorecord(register,"cer_temp:CVADDSDT_register_a.dat")
    CALL cv_log_message("dump register")
    EXECUTE cv_log_struct  WITH replace(request,register)
    IF ((register->rec[regfldcnt].person_id > 0)
     AND (register->rec[regfldcnt].encntr_id > 0))
     SET cv_omf_rec->called_by_import = 1
     FREE RECORD request
     EXECUTE cv_get_summary_data
     IF ((reply->status_data.status != "S"))
      CALL echo("cv_get_summary_data")
      SET rep_parse->list[casecnt].bvaliddatastatus = 0
     ENDIF
     FREE RECORD cv_omf_rec
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
   ENDIF
 ENDFOR
 CALL echorecord(reply,"cer_temp:reply.dat")
 FOR (casecnt = 1 TO size(reply->caselog,5))
   FOR (errcnt = 1 TO size(reply->caselog[casecnt].errorlog,5))
     CALL cv_log_message(reply->caselog[casecnt].errorlog[errcnt].error)
   ENDFOR
 ENDFOR
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reqinfo->commit_ind = 0
  SET reply->reply_message = "Failure loading the data to the CVTables. Please check the logfiles."
  CALL echo(reply->reply_message)
 ELSE
  SET casecount = 0
  SET nocases = size(rep_parse->list,5)
  FOR (cntl = 1 TO nocases)
    IF ((rep_parse->list[cntl].bvaliddatastatus=1))
     SET casecount = (casecount+ 1)
    ENDIF
  ENDFOR
  SET reply->reply_message = concat(trim(cnvtstring(casecount))," of ",trim(cnvtstring((nocases - 1))
    )," cases successfully Uploaded to the CVTables.")
  CALL echo(reply->reply_message)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
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
 SUBROUTINE getpersonidbyflname(fname,lname,person_id,encntr_id)
   CALL cv_log_message(build("Inside subr fname = ",fname,"lname = ",lname))
   SET person_id = 0.0
   SELECT INTO "nl"
    FROM person p
    WHERE p.name_first_key=fname
     AND p.name_last_key=lname
    DETAIL
     person_id = p.person_id
    WITH nocounter
   ;end select
   SET encntr_id = 0.0
   CALL cv_log_message(build("Before return subr fname = ",fname,"lname = ",lname,"person_id = ",
     person_id))
 END ;Subroutine
 SUBROUTINE cv_pad_date(parse_string)
   SET parse_sep = "/"
   SET parse_pos = 0
   SET ret_str = fillstring(value(size(parse_string))," ")
   SET l_str = fillstring(value(size(parse_string))," ")
   SET r_str = fillstring(value(size(parse_string))," ")
   WHILE ((parse_pos != - (1)))
    SET ret_str = cv_parse_data(parse_sep,parse_string,parse_pos)
    IF (size(ret_str)=1
     AND isnumeric(ret_str)=1)
     IF (parse_pos > 1)
      SET stal = movestring(substring(1,(parse_pos - 1),parse_string),1,l_str,1,(parse_pos - 1))
     ENDIF
     SET star = movestring(substring(loc,((size(parse_string,1) - parse_pos)+ 1),parse_string),1,
      r_str,1,((size(parse_string,1) - parse_pos)+ 1))
     SET parse_string = build("0",l_str,r_str)
     SET parse_pos = (parse_pos+ 1)
    ENDIF
   ENDWHILE
   CALL cv_log_message(build("parse_string = ",parse_string))
   RETURN(parse_string)
 END ;Subroutine
 SUBROUTINE cv_log_error(icaseno,serror)
  CALL echo(serror)
  IF (icaseno >= 0)
   IF (icaseno > size(reply->caselog,5))
    CALL echo("entering if")
    SET stat = alterlist(reply->caselog,icaseno)
   ENDIF
   SET nextndx = size(reply->caselog[icaseno].errorlog,5)
   SET nextndx = (nextndx+ 1)
   SET stat = alterlist(reply->caselog[icaseno].errorlog,nextndx)
   SET reply->caselog[icaseno].errorlog[nextndx].error = serror
   CALL cv_log_message(serror)
  ELSE
   CALL cv_log_message("Error: Invalid cv_log_error Call")
  ENDIF
 END ;Subroutine
 DECLARE cv_add_dataset_data_vrsn = vc WITH private, constant("MOD 002 BM9013 06/13/06")
END GO
