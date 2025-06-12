CREATE PROGRAM cv_ins_updt_omf_summary_tables:dba
 RECORD int_rec(
   1 del_proc[*]
     2 procedure_id = f8
   1 del_lesion[*]
     2 lesion_id = f8
   1 dataset[*]
     2 dataset_id = f8
   1 cv_case_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 sex_cd = f8
   1 cv_case_nbr = f8
   1 hospital_cd = f8
   1 patient_type_cd = f8
   1 date_of_admission = dq8
   1 date_of_discharge = dq8
   1 num_proc = i4
   1 age_year = i4
   1 age_group_cd = f8
   1 los_adm_disch = i4
   1 admission_ind = i2
   1 discharge_ind = i2
   1 death_ind = i2
   1 case_abstr_data[*]
     2 event_id = f8
     2 case_abstr_id = f8
     2 cv_case_id = f8
     2 group_type_cd = f8
     2 group_type_meaning = c12
     2 event_cd = f8
     2 nomenclature_id = f8
     2 result_val = vc
     2 result_cd = f8
     2 result_dt_tm = dq8
     2 task_assay_meaning = c12
   1 procedure[*]
     2 procedure_id = f8
     2 cv_case_id = f8
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
     2 proc_abstr_data[*]
       3 event_id = f8
       3 proc_abstr_id = f8
       3 procedure_id = f8
       3 event_type_cd = f8
       3 group_type_cd = f8
       3 group_type_meaning = c12
       3 event_cd = f8
       3 nomenclature_id = f8
       3 result_val = vc
       3 result_cd = f8
       3 result_dt_tm = dq8
       3 task_assay_meaning = c12
     2 lesion[*]
       3 lesion_id = f8
       3 procedure_id = f8
       3 lesion_abstr_data[*]
         4 event_id = f8
         4 lesion_abstr_id = f8
         4 lesion_id = f8
         4 event_type_cd = f8
         4 group_type_cd = f8
         4 group_type_meaning = c12
         4 event_cd = f8
         4 nomenclature_id = f8
         4 result_val = vc
         4 result_dt_tm = dq8
         4 result_cd = f8
 )
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  SET null_date = "31-DEC-2100 00:00:00"
  SET cv_log_debug = 5
  SET cv_log_info = 4
  SET cv_log_audit = 3
  SET cv_log_warning = 2
  SET cv_log_error = 1
  SET cv_log_handle_cnt = 1
  SET cv_log_handle = 0
  SET cv_log_status = 0
  SET cv_log_level = 0
  SET cv_log_echo_level = 0
  SET cv_log_error_time = 0
  SET cv_log_error_file = 1
  SET cv_log_error_string = fillstring(32000," ")
  SET cv_err_msg = fillstring(100," ")
  SET cv_log_err_num = 0
  SET cv_log_file_name = build("cer_temp:CV_DEFAULT",format(cnvtdatetime(curdate,curtime3),
    "HHMMSS;;q"),".dat")
  SET cv_log_struct_file_name = build("cer_temp:",curprog)
  SET cv_log_struct_file_nbr = 0
  SET cv_log_event = "CV_DEFAULT_LOG"
  SET cv_log_level = cv_log_debug
  SET cv_def_log_level = cv_log_debug
  SET cv_log_echo_level = cv_log_debug
  SET cv_log_chg_to_default = 1
  SET cv_log_error_time = 1
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
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
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
   ENDIF
   SET reply->status_data.subeventstatus[num_event].targetobjectname = object_name_param
   SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
   SET reply->status_data.subeventstatus[num_event].operationname = operation_name_param
   SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
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
 SET datefmt = "dd-mmm-yyyy hh:mm:ss.cc;;d"
 SET timefmt = "HHMM;;d"
 SET null_date = "31-Dec-2100 23:59:59.59"
 SET reply->status_data.status = "F"
 SET ffailure = "F"
 SET max_lesion_cnt = 0
 SELECT INTO "nl:"
  e.encntr_type_class_cd, e.loc_facility_cd
  FROM encounter e
  WHERE (e.encntr_id=cv_omf_rec->encntr_id)
   AND e.active_ind=1
  DETAIL
   int_rec->patient_type_cd = e.encntr_type_class_cd, int_rec->hospital_cd = e.loc_facility_cd,
   int_rec->date_of_admission = e.reg_dt_tm,
   int_rec->date_of_discharge = e.disch_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Select Failed in select the encounter table")
  GO TO exit_script
 ENDIF
 SET admission_dt_tm_formatted = fillstring(25," ")
 SET discharge_dt_tm_formatted = fillstring(25," ")
 SET admission_time_string = fillstring(4," ")
 SET discharge_time_string = fillstring(4," ")
 SET admission_dt_tm_formatted = format(int_rec->date_of_admission,datefmt)
 SET discharge_dt_tm_formatted = format(int_rec->date_of_discharge,datefmt)
 SET admission_time_string = format(int_rec->date_of_admission,timefmt)
 SET discharge_time_string = format(int_rec->date_of_discharge,timefmt)
 IF (size(trim(admission_time_string)) > 0)
  SET int_rec->admission_ind = 1
 ELSE
  SET int_rec->admission_ind = 0
 ENDIF
 IF (size(trim(discharge_time_string)) > 0)
  SET int_rec->discharge_ind = 1
 ELSE
  SET int_rec->discharge_ind = 0
 ENDIF
 IF (size(trim(admission_time_string)) > 0
  AND size(trim(discharge_time_string)) > 0)
  SET int_rec->los_adm_disch = datetimediff(int_rec->date_of_discharge,int_rec->date_of_admission)
 ELSE
  SET int_rec->los_adm_disch = 0
 ENDIF
 SET proc_start_dt_tm_formatted = fillstring(25," ")
 SET proc_end_dt_tm_formatted = fillstring(25," ")
 SET proc_start_time_string = fillstring(4," ")
 SET proc_end_time_string = fillstring(4," ")
 SET proc_start_time = 0
 SET proc_end_time = 0
 SET proc_cnt = 0
 SET los_proc_start_end = 0
 SET proc_cnt = size(cv_omf_rec->proc_data,5)
 SET stat = alterlist(int_rec->procedure,proc_cnt)
 SET int_rec->num_proc = proc_cnt
 FOR (n = 1 TO proc_cnt)
   SET proc_start_dt_tm_formatted = format(cv_omf_rec->proc_data[n].proc_start_dt_tm,datefmt)
   SET proc_end_dt_tm_formatted = format(cv_omf_rec->proc_data[n].proc_end_dt_tm,datefmt)
   SET proc_start_time_string = format(cv_omf_rec->proc_data[n].proc_start_dt_tm,timefmt)
   SET proc_end_time_string = format(cv_omf_rec->proc_data[n].proc_end_dt_tm,timefmt)
   IF (size(trim(proc_start_time_string)) > 0
    AND size(trim(proc_end_time_string)) > 0)
    SET int_rec->procedure[n].proc_complete_ind = 1
    SET int_rec->procedure[n].proc_start_hour = hour(cnvtint(proc_start_time_string))
    SET int_rec->procedure[n].proc_start_day = weekday(cnvtdatetime(proc_start_dt_tm_formatted))
    SET int_rec->procedure[n].proc_start_month = month(cnvtdatetime(proc_start_dt_tm_formatted))
    SET los_proc_start_end = datetimecmp(cv_omf_rec->proc_data[n].proc_start_dt_tm,cv_omf_rec->
     proc_data[n].proc_end_dt_tm)
    SET proc_start_time = cnvtint(proc_start_time_string)
    SET proc_end_time = cnvtint(proc_end_time_string)
    IF (los_proc_start_end != 0)
     SET proc_end_time = (proc_end_time+ (2400 * los_proc_start_end))
    ENDIF
    SET int_rec->procedure[n].proc_dur_min = (cnvtmin(proc_end_time) - cnvtmin(proc_start_time))
   ELSE
    SET int_rec->procedure[n].proc_dur_min = 0
    SET int_rec->procedure[n].proc_complete_ind = 0
    SET int_rec->procedure[n].proc_start_hour = - (1)
    SET int_rec->procedure[n].proc_start_day = - (1)
    SET int_rec->procedure[n].proc_start_month = - (1)
   ENDIF
   IF (size(trim(admission_time_string)) > 0
    AND size(trim(proc_start_time_string)) > 0)
    SET int_rec->procedure[n].los_adm_proc = datetimediff(cv_omf_rec->proc_data[n].proc_start_dt_tm,
     int_rec->date_of_admission)
   ENDIF
   IF (size(trim(discharge_time_string)) > 0
    AND size(trim(proc_end_time_string)) > 0)
    SET int_rec->procedure[n].los_proc_disch = datetimediff(int_rec->date_of_discharge,cv_omf_rec->
     proc_data[n].proc_end_dt_tm)
   ENDIF
 ENDFOR
 SET age = 0
 SELECT INTO "nl:"
  p.sex_cd
  FROM person p
  WHERE (p.person_id=cv_omf_rec->person_id)
   AND p.active_ind=1
  DETAIL
   int_rec->sex_cd = p.sex_cd, age = (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm)/
   365.25), int_rec->age_year = age
   IF ((int_rec->death_ind=0))
    deceased_dt_tm_formatted = fillstring(25," "), deceased_time_string = fillstring(4," "),
    deceased_dt_tm_formatted = format(p.deceased_dt_tm,datefmt),
    deceased_time_string = format(p.deceased_dt_tm,timefmt)
    IF (size(trim(deceased_time_string)) > 0)
     int_rec->death_ind = 1
    ELSE
     int_rec->death_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Failed in select the person table")
 ENDIF
 SET baby_grp_cd = 0
 SET 2_18_grp_cd = 0
 SET 19_44_grp_cd = 0
 SET 45_54_grp_cd = 0
 SET 55_64_grp_cd = 0
 SET 65_74_grp_cd = 0
 SET 75_84_grp_cd = 0
 SET 85_grp_cd = 0
 SELECT INTO "nl:"
  cv.code_value, cdf = cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=22329
   AND cv.cdf_meaning IN ("<2YEAR", "2-18", "19-44", "45-54", "55-64",
  "65-74", "75-84", "85+")
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   CASE (cdf)
    OF "<2YEAR":
     baby_grp_cd = cv.code_value
    OF "2-18":
     2_18_grp_cd = cv.code_value
    OF "19-44":
     19_44_grp_cd = cv.code_value
    OF "45-54":
     45_54_grp_cd = cv.code_value
    OF "55-64":
     55_64_grp_cd = cv.code_value
    OF "65-74":
     65_74_grp_cd = cv.code_value
    OF "75-84":
     75_84_grp_cd = cv.code_value
    OF "85+":
     85_grp_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Failed in select the code_value table")
  GO TO exit_script
 ENDIF
 IF (age < 2)
  SET int_rec->age_group_cd = baby_grp_cd
 ELSEIF (age >= 2
  AND age <= 18)
  SET int_rec->age_group_cd = 2_18_grp_cd
 ELSEIF (age >= 19
  AND age <= 44)
  SET int_rec->age_group_cd = 19_44_grp_cd
 ELSEIF (age >= 45
  AND age <= 54)
  SET int_rec->age_group_cd = 45_54_grp_cd
 ELSEIF (age >= 55
  AND age <= 64)
  SET int_rec->age_group_cd = 55_64_grp_cd
 ELSEIF (age >= 65
  AND age <= 74)
  SET int_rec->age_group_cd = 65_74_grp_cd
 ELSEIF (age >= 75
  AND age <= 84)
  SET int_rec->age_group_cd = 75_84_grp_cd
 ELSE
  SET int_rec->age_group_cd = 85_grp_cd
 ENDIF
 SET cc_case_id = 0.0
 SELECT INTO "NL:"
  cc.cv_case_id, cv_case_nbr
  FROM cv_case cc
  WHERE (cc.cv_case_nbr=cv_omf_rec->cv_case_nbr)
  DETAIL
   cc_case_id = cc.cv_case_id, int_rec->cv_case_id = cc_case_id, register->cv_case_id = cc_case_id
  WITH nocounter
 ;end select
 IF (cc_case_id > 0)
  CALL echo(cc_case_id)
  SELECT INTO "nl:"
   cp.procedure_id, cp.event_type_cd
   FROM cv_procedure cp,
    (dummyt d  WITH seq = value(size(cv_omf_rec->proc_data,5)))
   PLAN (d)
    JOIN (cp
    WHERE cp.cv_case_id=cc_case_id
     AND cp.active_ind=1
     AND (cp.event_type_cd=cv_omf_rec->proc_data[d.seq].event_type_cd))
   HEAD REPORT
    pro_type_cnt = 0
   DETAIL
    pro_type_cnt = (pro_type_cnt+ 1), stat = alterlist(int_rec->procedure,pro_type_cnt), int_rec->
    procedure[pro_type_cnt].procedure_id = cp.procedure_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   nextseqnum = seq(card_vas_seq,nextval)"#############;rp0"
   FROM dual
   DETAIL
    int_rec->cv_case_id = cnvtint(nextseqnum), register->cv_case_id = int_rec->cv_case_id
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET ffailure = "T"
   CALL cv_log_message("Failed in select cv_case_id from the dual table")
   GO TO exit_script
  ENDIF
  SET proc_cnt = size(cv_omf_rec->proc_data,5)
  FOR (x = 1 TO proc_cnt)
   SELECT INTO "nl:"
    nextseqnbr = seq(card_vas_seq,nextval)"##############;rp0"
    FROM dual
    DETAIL
     int_rec->procedure[x].procedure_id = cnvtint(nextseqnbr)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET ffailure = "T"
    CALL cv_log_message("Failed in select the dual table")
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 SET max_lesion_cnt = 0
 SET max_proc_abs_cnt = 0
 SET max_les_abs_cnt = 0
 SET int_rec->person_id = cv_omf_rec->person_id
 SET int_rec->encntr_id = cv_omf_rec->encntr_id
 SET int_rec->cv_case_nbr = cv_omf_rec->cv_case_nbr
 SET case_abstr_cnt = 0
 SET ds_cnt = size(cv_omf_rec->dataset,5)
 SET stat = alterlist(int_rec->dataset,ds_cnt)
 FOR (m = 1 TO ds_cnt)
   SET int_rec->dataset[m].dataset_id = cv_omf_rec->dataset[m].dataset_id
 ENDFOR
 SET case_abstr_cnt = size(cv_omf_rec->case_abstr_data,5)
 SET stat = alterlist(int_rec->case_abstr_data,case_abstr_cnt)
 FOR (n = 1 TO case_abstr_cnt)
   SELECT INTO "nl:"
    nextseqnbr = seq(card_vas_seq,nextval)"##############;rp0"
    FROM dual
    DETAIL
     int_rec->case_abstr_data[n].case_abstr_id = cnvtint(nextseqnbr)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET ffailure = "T"
    CALL cv_log_message("Failed in select case_abstr_id from the dual table")
    GO TO exit_script
   ENDIF
   SET int_rec->case_abstr_data[n].event_id = cv_omf_rec->case_abstr_data[n].event_id
   SET int_rec->case_abstr_data[n].group_type_cd = cv_omf_rec->case_abstr_data[n].group_type_cd
   SET int_rec->case_abstr_data[n].group_type_meaning = cv_omf_rec->case_abstr_data[n].
   group_type_meaning
   SET int_rec->case_abstr_data[n].cv_case_id = int_rec->cv_case_id
   SET int_rec->case_abstr_data[n].event_cd = cv_omf_rec->case_abstr_data[n].event_cd
   SET int_rec->case_abstr_data[n].nomenclature_id = cv_omf_rec->case_abstr_data[n].nomenclature_id
   SET int_rec->case_abstr_data[n].result_val = cv_omf_rec->case_abstr_data[n].result_val
   SET int_rec->case_abstr_data[n].result_cd = cv_omf_rec->case_abstr_data[n].result_cd
   SET holder_cd = cv_omf_rec->case_abstr_data[n].task_assay_cd
   SET int_rec->case_abstr_data[n].task_assay_meaning = uar_get_code_meaning(holder_cd)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(int_rec->case_abstr_data,5)))
  WHERE (int_rec->case_abstr_data[d.seq].task_assay_meaning IN ("ACC018ADTCA", "ACC130DCDAT",
  "STS01004", "STS01190"))
  DETAIL
   result_val = int_rec->case_abstr_data[d.seq].result_val, int_rec->case_abstr_data[d.seq].
   result_val = format(cnvtdate2(substring(3,8,result_val),"YYYYMMDD"),"MM/DD/YYYY;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ce_date_result cdr,
   (dummyt d  WITH seq = value(size(int_rec->case_abstr_data,5)))
  PLAN (d
   WHERE (int_rec->case_abstr_data[d.seq].task_assay_meaning IN ("ACC018ADTCA", "ACC130DCDAT",
   "STS01004", "STS01190")))
   JOIN (cdr
   WHERE (cdr.event_id=int_rec->case_abstr_data[d.seq].event_id))
  DETAIL
   int_rec->case_abstr_data[d.seq].result_dt_tm = cdr.result_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("No match date fields was found in ce_date_result")
 ENDIF
 IF ((int_rec->death_ind=0))
  SELECT INTO "nl:"
   FROM nomenclature n,
    (dummyt d  WITH seq = value(size(int_rec->case_abstr_data,5)))
   PLAN (d)
    JOIN (n
    WHERE (n.nomenclature_id=int_rec->case_abstr_data[d.seq].nomenclature_id)
     AND n.mnemonic="Yes"
     AND (int_rec->case_abstr_data[d.seq].task_assay_meaning="ACC141DDETH"))
   DETAIL
    int_rec->death_ind = 1, int_rec->discharge_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET proc_cnt = size(cv_omf_rec->proc_data,5)
 SET stat = alterlist(int_rec->procedure,proc_cnt)
 FOR (proc_nbr = 1 TO proc_cnt)
   SET int_rec->procedure[proc_nbr].cv_case_id = int_rec->cv_case_id
   SET int_rec->procedure[proc_nbr].event_type_cd = cv_omf_rec->proc_data[proc_nbr].event_type_cd
   SET int_rec->procedure[proc_nbr].proc_start_dt_tm = cv_omf_rec->proc_data[proc_nbr].
   proc_start_dt_tm
   SET int_rec->procedure[proc_nbr].proc_end_dt_tm = cv_omf_rec->proc_data[proc_nbr].proc_end_dt_tm
   SET proc_abstr_cnt = 0
   SET proc_abstr_cnt = size(cv_omf_rec->proc_data[proc_nbr].proc_abstr_data,5)
   SET stat = alterlist(int_rec->procedure[proc_nbr].proc_abstr_data,proc_abstr_cnt)
   IF (max_proc_abs_cnt < proc_abstr_cnt)
    SET max_proc_abs_cnt = proc_abstr_cnt
   ENDIF
   FOR (proc_abstr_nbr = 1 TO proc_abstr_cnt)
     SELECT INTO "nl:"
      nextseqnbr = seq(card_vas_seq,nextval)"##############;rp0"
      FROM dual
      DETAIL
       int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].proc_abstr_id = cnvtint(
        nextseqnbr)
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET ffailure = "T"
      CALL cv_log_message("Failed in select proc_abstr_id from dual table")
      GO TO exit_script
     ENDIF
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].procedure_id = int_rec->
     procedure[proc_nbr].procedure_id
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_id = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_id
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_type_cd = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_type_cd
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].group_type_cd = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].group_type_cd
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_cd = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].event_cd
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].nomenclature_id = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].nomenclature_id
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_val = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_val
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_cd = cv_omf_rec->
     proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].result_cd
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].group_type_meaning = cv_omf_rec
     ->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].group_type_meaning
     SET task_cd = cv_omf_rec->proc_data[proc_nbr].proc_abstr_data[proc_abstr_nbr].task_assay_cd
     SET int_rec->procedure[proc_nbr].proc_abstr_data[proc_abstr_nbr].task_assay_meaning =
     uar_get_code_meaning(task_cd)
   ENDFOR
   SET lesion_cnt = size(cv_omf_rec->proc_data[proc_nbr].lesion,5)
   SET int_rec->procedure[proc_nbr].num_lesion = lesion_cnt
   IF (max_lesion_cnt < lesion_cnt)
    SET max_lesion_cnt = lesion_cnt
   ENDIF
   CALL cv_log_message(build("Lesion_cnt = ",lesion_cnt))
   SET stat = alterlist(int_rec->procedure[proc_nbr].lesion,lesion_cnt)
   FOR (lesion_nbr = 1 TO lesion_cnt)
     SELECT INTO "nl:"
      nextseqnbr = seq(card_vas_seq,nextval)"##############;rp0"
      FROM dual
      DETAIL
       int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_id = cnvtint(nextseqnbr)
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET ffailure = "T"
      CALL cv_log_message("Failed in select lesion_id from the dual table")
      GO TO exit_script
     ENDIF
     SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].procedure_id = int_rec->procedure[proc_nbr].
     procedure_id
     SET lesion_abstr_cnt = 0
     SET lesion_abstr_cnt = size(cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data,5)
     SET stat = alterlist(int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data,
      lesion_abstr_cnt)
     IF (max_les_abs_cnt < lesion_abstr_cnt)
      SET max_les_abs_cnt = lesion_abstr_cnt
     ENDIF
     FOR (lesion_abstr_nbr = 1 TO lesion_abstr_cnt)
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       lesion_id = int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_id
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       event_id = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr]
       .event_id
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       event_type_cd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
       lesion_abstr_nbr].event_type_cd
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       group_type_cd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
       lesion_abstr_nbr].group_type_cd
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       event_cd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr]
       .event_cd
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       nomenclature_id = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
       lesion_abstr_nbr].nomenclature_id
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       result_cd = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[lesion_abstr_nbr
       ].result_cd
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       result_val = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
       lesion_abstr_nbr].result_val
       SET int_rec->procedure[proc_nbr].lesion[lesion_nbr].lesion_abstr_data[lesion_abstr_nbr].
       group_type_meaning = cv_omf_rec->proc_data[proc_nbr].lesion[lesion_nbr].les_abstr_data[
       lesion_abstr_nbr].group_type_meaning
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM prsnl pr,
   (dummyt d1  WITH seq = value(proc_cnt)),
   (dummyt d2  WITH seq = value(max_proc_abs_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(int_rec->procedure[d1.seq].proc_abstr_data,5))
   JOIN (pr
   WHERE trim(pr.name_full_formatted)=trim(int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].
    result_val)
    AND (int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].task_assay_meaning IN ("ACC033CNAME",
   "ACC066PNAME")))
  DETAIL
   int_rec->procedure[d1.seq].proc_physician_id = pr.person_id
  WITH nocounter
 ;end select
 CALL echo("*********************************************************")
 CALL echo(build("Num of case: ","1"))
 CALL echo(build("Num of case abstract: ",case_abstr_cnt))
 CALL echo(build("Num of procedure: ",proc_cnt))
 CALL echo(build("Num of proc abstract: ",proc_abstr_cnt))
 CALL echo(build("Num of lesion: ",lesion_cnt))
 CALL echo(build("Num of lesion abstract: ",lesion_abstr_cnt))
 CALL echorecord(int_rec)
 IF (cc_case_id > 0)
  SELECT INTO "nl:"
   proc_id = cp.procedure_id
   FROM cv_procedure cp,
    (dummyt d1  WITH seq = value(size(cv_omf_rec->proc_data,5)))
   PLAN (d1)
    JOIN (cp
    WHERE (cv_omf_rec->proc_data[d1.seq].event_type_cd=cp.event_type_cd)
     AND (cp.cv_case_id=int_rec->cv_case_id))
   HEAD REPORT
    del_pro_cnt = 0
   DETAIL
    del_pro_cnt = (del_pro_cnt+ 1), stat = alterlist(int_rec->del_proc,del_pro_cnt), int_rec->
    del_proc[del_pro_cnt].procedure_id = proc_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cl.lesion_id
   FROM cv_lesion cl,
    (dummyt d2  WITH seq = value(size(int_rec->del_proc,5)))
   PLAN (d2)
    JOIN (cl
    WHERE (int_rec->del_proc[d2.seq].procedure_id=cl.procedure_id))
   HEAD REPORT
    del_les_cnt = 0
   DETAIL
    del_les_cnt = (del_les_cnt+ 1), stat = alterlist(int_rec->del_lesion,del_les_cnt), int_rec->
    del_lesion[del_les_cnt].lesion_id = cl.lesion_id
   WITH nocounter
  ;end select
  DELETE  FROM cv_les_abstr_data clad,
    (dummyt d2  WITH seq = value(size(int_rec->del_lesion,5)))
   SET clad.seq = 1
   PLAN (d2)
    JOIN (clad
    WHERE (int_rec->del_lesion[d2.seq].lesion_id=clad.lesion_id))
   WITH nocounter
  ;end delete
  DELETE  FROM cv_lesion cl,
    (dummyt d3  WITH seq = value(size(int_rec->del_proc,5)))
   SET cl.seq = 1
   PLAN (d3)
    JOIN (cl
    WHERE (int_rec->del_proc[d3.seq].procedure_id=cl.procedure_id)
     AND cl.active_ind=1)
   WITH nocounter
  ;end delete
  DELETE  FROM cv_proc_abstr_data cpad,
    (dummyt d4  WITH seq = value(size(int_rec->del_proc,5)))
   SET cpad.seq = 1
   PLAN (d4)
    JOIN (cpad
    WHERE (int_rec->del_proc[d4.seq].procedure_id=cpad.procedure_id)
     AND cpad.active_ind=1)
   WITH nocounter
  ;end delete
  DELETE  FROM cv_procedure cp,
    (dummyt d5  WITH seq = value(size(int_rec->del_proc,5)))
   SET cp.seq = 1
   PLAN (d5)
    JOIN (cp
    WHERE (int_rec->del_proc[d5.seq].procedure_id=cp.procedure_id)
     AND cp.active_ind=1)
   WITH nocounter
  ;end delete
  DELETE  FROM cv_case_abstr_data ccad
   WHERE ccad.cv_case_id=cc_case_id
    AND ccad.active_ind=1
   WITH nocounter
  ;end delete
  DELETE  FROM cv_case_dataset_r ccdr
   WHERE ccdr.cv_case_id=cc_case_id
    AND ccdr.active_ind=1
   WITH nocounter
  ;end delete
  SELECT INTO "nl:"
   cc.cv_case_id, cc.cv_case_nbr
   FROM cv_case cc
   WHERE (cc.cv_case_nbr=cv_omf_rec->cv_case_nbr)
   HEAD REPORT
    cur_updt_cnt = 0
   DETAIL
    cur_updt_cnt = cc.updt_cnt
   WITH nocounter, forupdate(cc)
  ;end select
  UPDATE  FROM cv_case cc
   SET cc.cv_case_id = int_rec->cv_case_id, cc.cv_case_nbr = int_rec->cv_case_nbr, cc.num_proc =
    int_rec->num_proc,
    cc.person_id = int_rec->person_id, cc.encntr_id = int_rec->encntr_id, cc.patient_type_cd =
    int_rec->patient_type_cd,
    cc.age = int_rec->age_year, cc.age_group_cd = int_rec->age_group_cd, cc.sex_cd = int_rec->sex_cd,
    cc.hospital_cd = int_rec->hospital_cd, cc.pat_adm_dt_tm = cnvtdatetime(int_rec->date_of_admission
     ), cc.pat_disch_dt_tm = cnvtdatetime(int_rec->date_of_discharge),
    cc.los_adm_disch = int_rec->los_adm_disch, cc.pat_adm_ind = int_rec->admission_ind, cc
    .pat_disch_ind = int_rec->discharge_ind,
    cc.active_ind = 1, cc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cc.active_status_cd
     = reqdata->active_status_cd,
    cc.death_ind = int_rec->death_ind, cc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cc
    .end_effective_dt_tm = cnvtdatetime(null_date),
    cc.data_status_cd = reqdata->data_status_cd, cc.data_status_prsnl_id = reqinfo->updt_id, cc
    .active_status_prsnl_id = reqinfo->updt_id,
    cc.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), cc.updt_task = reqinfo->updt_task,
    cc.updt_app = reqinfo->updt_app, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = (cc
    .updt_cnt+ 1),
    cc.updt_id = reqinfo->updt_id, cc.updt_req = reqinfo->updt_req
   WHERE (cc.cv_case_nbr=int_rec->cv_case_nbr)
    AND (int_rec->cv_case_nbr > 0)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET ffailure = "T"
   CALL cv_log_message("Failed in update cv_case table")
   GO TO exit_script
  ENDIF
 ELSE
  INSERT  FROM cv_case cc
   SET cc.cv_case_id = int_rec->cv_case_id, cc.cv_case_nbr = int_rec->cv_case_nbr, cc.num_proc =
    int_rec->num_proc,
    cc.person_id = int_rec->person_id, cc.encntr_id = int_rec->encntr_id, cc.patient_type_cd =
    int_rec->patient_type_cd,
    cc.age = int_rec->age_year, cc.age_group_cd = int_rec->age_group_cd, cc.sex_cd = int_rec->sex_cd,
    cc.hospital_cd = int_rec->hospital_cd, cc.pat_adm_dt_tm = cnvtdatetime(int_rec->date_of_admission
     ), cc.pat_disch_dt_tm = cnvtdatetime(int_rec->date_of_discharge),
    cc.los_adm_disch = int_rec->los_adm_disch, cc.pat_adm_ind = int_rec->admission_ind, cc
    .pat_disch_ind = int_rec->discharge_ind,
    cc.active_ind = 1, cc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cc.active_status_cd
     = reqdata->active_status_cd,
    cc.death_ind = int_rec->death_ind, cc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cc
    .end_effective_dt_tm = cnvtdatetime(null_date),
    cc.data_status_cd = reqdata->data_status_cd, cc.data_status_prsnl_id = reqinfo->updt_id, cc
    .active_status_prsnl_id = reqinfo->updt_id,
    cc.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), cc.updt_task = reqinfo->updt_task,
    cc.updt_app = reqinfo->updt_app, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
    cc.updt_req = reqinfo->updt_req, cc.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET ffailure = "T"
   CALL cv_log_message("Failed in insert cv_case table")
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM cv_case_dataset_r ccdr,
   (dummyt d  WITH seq = value(size(int_rec->dataset,5)))
  SET ccdr.case_dataset_r_id = cnvtint(seq(card_vas_seq,nextval)), ccdr.cv_case_id = int_rec->
   cv_case_id, ccdr.dataset_id = int_rec->dataset[d.seq].dataset_id,
   ccdr.active_ind = 1, ccdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccdr
   .active_status_cd = reqdata->active_status_cd,
   ccdr.updt_id = reqinfo->updt_id
  PLAN (d)
   JOIN (ccdr)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Failed in insert cv_case_dataset_r table")
  GO TO exit_script
 ENDIF
 INSERT  FROM cv_procedure cp,
   (dummyt d  WITH seq = value(size(int_rec->procedure,5)))
  SET cp.procedure_id = int_rec->procedure[d.seq].procedure_id, cp.cv_case_id = int_rec->procedure[d
   .seq].cv_case_id, cp.event_type_cd = int_rec->procedure[d.seq].event_type_cd,
   cp.proc_physic_id = int_rec->procedure[d.seq].proc_physician_id, cp.proc_start_dt_tm =
   cnvtdatetime(int_rec->procedure[d.seq].proc_start_dt_tm), cp.proc_end_dt_tm = cnvtdatetime(int_rec
    ->procedure[d.seq].proc_end_dt_tm),
   cp.proc_dur_min = int_rec->procedure[d.seq].proc_dur_min, cp.proc_start_mnth = int_rec->procedure[
   d.seq].proc_start_month, cp.proc_start_day = int_rec->procedure[d.seq].proc_start_day,
   cp.proc_start_hour = int_rec->procedure[d.seq].proc_start_hour, cp.proc_complete_ind = int_rec->
   procedure[d.seq].proc_complete_ind, cp.los_adm_proc = int_rec->procedure[d.seq].los_adm_proc,
   cp.los_proc_disch = int_rec->procedure[d.seq].los_proc_disch, cp.num_lesion = int_rec->procedure[d
   .seq].num_lesion, cp.active_ind = 1,
   cp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cp.active_status_cd = reqdata->
   active_status_cd, cp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cp.end_effective_dt_tm = cnvtdatetime(null_date), cp.data_status_cd = reqdata->data_status_cd, cp
   .data_status_prsnl_id = reqinfo->updt_id,
   cp.active_status_prsnl_id = reqinfo->updt_id, cp.data_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), cp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cp.updt_task = reqinfo->updt_task, cp.updt_app = reqinfo->updt_app, cp.updt_applctx = reqinfo->
   updt_applctx,
   cp.updt_cnt = 0, cp.updt_req = reqinfo->updt_req, cp.updt_id = reqinfo->updt_id
  PLAN (d)
   JOIN (cp)
  WITH nocounter
 ;end insert
 IF (curqual != proc_cnt)
  SET ffailure = "T"
  CALL cv_log_message("Failed in insert cv_procedure table")
  GO TO exit_script
 ENDIF
 IF (case_abstr_cnt > 0)
  INSERT  FROM cv_case_abstr_data ccad,
    (dummyt d  WITH seq = value(size(int_rec->case_abstr_data,5)))
   SET ccad.case_abstr_data_id = int_rec->case_abstr_data[d.seq].case_abstr_id, ccad.cv_case_id =
    int_rec->case_abstr_data[d.seq].cv_case_id, ccad.group_type_cd = int_rec->case_abstr_data[d.seq].
    group_type_cd,
    ccad.event_cd = int_rec->case_abstr_data[d.seq].event_cd, ccad.nomenclature_id = int_rec->
    case_abstr_data[d.seq].nomenclature_id, ccad.result_cd = int_rec->case_abstr_data[d.seq].
    result_cd,
    ccad.result_val = int_rec->case_abstr_data[d.seq].result_val, ccad.result_dt_tm = cnvtdatetime(
     int_rec->case_abstr_data[d.seq].result_dt_tm), ccad.active_ind = 1,
    ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
    active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
    ccad.data_status_prsnl_id = reqinfo->updt_id,
    ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
    reqinfo->updt_applctx,
    ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
   PLAN (d)
    JOIN (ccad)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual != case_abstr_cnt)
  SET ffailure = "T"
  CALL cv_log_message("Failed in insert cv_case_abstr_data table")
  GO TO exit_script
 ENDIF
 INSERT  FROM cv_proc_abstr_data cpad,
   (dummyt d1  WITH seq = value(proc_cnt)),
   (dummyt d2  WITH seq = value(max_proc_abs_cnt))
  SET cpad.proc_abstr_data_id = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].proc_abstr_id,
   cpad.procedure_id = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].procedure_id, cpad
   .group_type_cd = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].group_type_cd,
   cpad.event_cd = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].event_cd, cpad.nomenclature_id
    = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].nomenclature_id, cpad.result_cd = int_rec->
   procedure[d1.seq].proc_abstr_data[d2.seq].result_cd,
   cpad.result_val = int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].result_val, cpad.result_dt_tm
    = cnvtdatetime(int_rec->procedure[d1.seq].proc_abstr_data[d2.seq].result_dt_tm), cpad.active_ind
    = 1,
   cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
   active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->data_status_cd,
   cpad.data_status_prsnl_id = reqinfo->updt_id,
   cpad.active_status_prsnl_id = reqinfo->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
   reqinfo->updt_applctx,
   cpad.updt_cnt = 0, cpad.updt_req = reqinfo->updt_req, cpad.updt_id = reqinfo->updt_id
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(int_rec->procedure[d1.seq].proc_abstr_data,5))
   JOIN (cpad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message(lvl_error,log_to_screen,"Insert","Failed in insert cv_proc_abstr_data table")
  GO TO exit_script
 ENDIF
 INSERT  FROM cv_lesion cl,
   (dummyt d1  WITH seq = value(proc_cnt)),
   (dummyt d2  WITH seq = value(max_lesion_cnt))
  SET cl.lesion_id = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_id, cl.procedure_id = int_rec->
   procedure[d1.seq].lesion[d2.seq].procedure_id, cl.active_ind = 1,
   cl.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cl.active_status_cd = reqdata->
   active_status_cd, cl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cl.end_effective_dt_tm = cnvtdatetime(null_date), cl.data_status_cd = reqdata->data_status_cd, cl
   .data_status_prsnl_id = reqinfo->updt_id,
   cl.active_status_prsnl_id = reqinfo->updt_id, cl.data_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), cl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cl.updt_task = reqinfo->updt_task, cl.updt_app = reqinfo->updt_app, cl.updt_applctx = reqinfo->
   updt_applctx,
   cl.updt_cnt = 0, cl.updt_req = reqinfo->updt_req, cl.updt_id = reqinfo->updt_id
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(int_rec->procedure[d1.seq].lesion,5))
   JOIN (cl)
  WITH nocounter
 ;end insert
 IF (curqual != lesion_cnt)
  SET ffailure = "T"
  CALL cv_log_message("Failed in insert cv_lesion table")
  GO TO exit_script
 ENDIF
 INSERT  FROM cv_les_abstr_data clad,
   (dummyt d1  WITH seq = value(proc_cnt)),
   (dummyt d2  WITH seq = value(max_lesion_cnt)),
   (dummyt d3  WITH seq = value(max_les_abs_cnt))
  SET clad.les_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), clad.lesion_id = int_rec->
   procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq].lesion_id, clad.event_type_cd = int_rec
   ->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq].event_type_cd,
   clad.group_type_cd = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq].
   group_type_cd, clad.event_cd = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq]
   .event_cd, clad.nomenclature_id = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3
   .seq].nomenclature_id,
   clad.result_cd = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq].result_cd,
   clad.result_val = int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3.seq].result_val,
   clad.result_dt_tm = cnvtdatetime(int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data[d3
    .seq].result_dt_tm),
   clad.active_ind = 1, clad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clad
   .active_status_cd = reqdata->active_status_cd,
   clad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), clad.end_effective_dt_tm = cnvtdatetime
   (null_date), clad.data_status_cd = reqdata->data_status_cd,
   clad.data_status_prsnl_id = reqinfo->updt_id, clad.active_status_prsnl_id = reqinfo->updt_id, clad
   .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   clad.updt_dt_tm = cnvtdatetime(curdate,curtime3), clad.updt_task = reqinfo->updt_task, clad
   .updt_app = reqinfo->updt_app,
   clad.updt_applctx = reqinfo->updt_applctx, clad.updt_cnt = 0, clad.updt_req = reqinfo->updt_req,
   clad.updt_id = reqinfo->updt_id
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(int_rec->procedure[d1.seq].lesion,5))
   JOIN (d3
   WHERE d3.seq <= size(int_rec->procedure[d1.seq].lesion[d2.seq].lesion_abstr_data,5))
   JOIN (clad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Failed in insert cv_les_abstr_data table")
  GO TO exit_script
 ENDIF
 EXECUTE cv_ins_updt_omf_count
#exit_script
 IF (ffailure="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
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
END GO
