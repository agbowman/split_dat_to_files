CREATE PROGRAM cv_get_omf_encntr_calc:dba
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
 SELECT INTO "nl:"
  e.encntr_type_class_cd, e.loc_facility_cd
  FROM encounter e
  WHERE (e.encntr_id=cv_omf_rec->encntr_id)
   AND e.active_ind=1
  DETAIL
   cv_omf_rec->patient_type_cd = e.encntr_type_class_cd, cv_omf_rec->hospital_cd = e.loc_facility_cd,
   cv_omf_rec->organization_id = e.organization_id,
   cv_omf_rec->admit_dt_tm = e.reg_dt_tm, cv_omf_rec->disch_dt_tm = e.disch_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Select Failed in select the encounter table")
  GO TO exit_script
 ENDIF
 SET proc_cnt = size(cv_omf_rec->proc_data,5)
 SET stat = alterlist(cv_omf_rec->proc_data,proc_cnt)
 SET cv_omf_rec->num_proc = proc_cnt
 RECORD event(
   1 event_list[*]
     2 event_id = f8
     2 cdf_meaning = c12
     2 status = i2
     2 result_dt_tm = dq8
 )
 SET event_cnt = 0
 SELECT INTO "nl:"
  cdr.event_id
  FROM code_value cv,
   discrete_task_assay dta,
   clinical_event ce
  PLAN (cv
   WHERE cv.cdf_meaning IN ("PROC-START", "PROC-STOP")
    AND cv.code_set=14003)
   JOIN (dta
   WHERE dta.task_assay_cd=cv.code_value)
   JOIN (ce
   WHERE ce.event_cd=dta.event_cd
    AND (ce.encntr_id=cv_omf_rec->encntr_id)
    AND (ce.person_id=cv_omf_rec->person_id))
  DETAIL
   event_cnt = (event_cnt+ 1), stat = alterlist(event->event_list,event_cnt), event->event_list[
   event_cnt].event_id = ce.event_id,
   event->event_list[event_cnt].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Select Failed in select clinical_event table.")
 ENDIF
 SET done = 0
 SET search_event_id = cv_omf_rec->top_parent_event_id
 SET temp_parent_event_id = 0
 SET temp_event_id = 0
 SET arr_size = 0
 SET stat = alterlist(event->event_list,event_cnt)
 WHILE (done=0)
  SELECT INTO "nl:"
   ce.event_id, ce.parent_event_id
   FROM clinical_event ce
   WHERE ce.parent_event_id=search_event_id
    AND ce.parent_event_id != ce.event_id
   DETAIL
    temp_parent_event_id = ce.parent_event_id, temp_event_id = ce.event_id
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET search_event_id = temp_event_id
  ELSE
   SET done = 1
   CALL echo(temp_parent_event_id)
   SELECT INTO "nl:"
    ce.event_id, this_cnt = d.seq
    FROM clinical_event ce,
     (dummyt d  WITH seq = value(size(event->event_list,5)))
    PLAN (d)
     JOIN (ce
     WHERE ce.parent_event_id=temp_parent_event_id
      AND ce.parent_event_id > 0
      AND (ce.event_id=event->event_list[d.seq].event_id))
    DETAIL
     col 0, event->event_list[d.seq].status = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  cdr.result_dt_tm
  FROM ce_date_result cdr,
   (dummyt d1  WITH seq = value(proc_cnt)),
   (dummyt d2  WITH seq = value(size(event->event_list,5)))
  PLAN (d1)
   JOIN (d2
   WHERE (event->event_list[d2.seq].status=1))
   JOIN (cdr
   WHERE (cdr.event_id=event->event_list[d2.seq].event_id))
  DETAIL
   IF ((event->event_list[d2.seq].cdf_meaning="PROC-START"))
    cv_omf_rec->proc_data[d1.seq].proc_start_dt_tm = cdr.result_dt_tm
   ELSE
    cv_omf_rec->proc_data[d1.seq].proc_end_dt_tm = cdr.result_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Select Failed in select ce_date_result table")
 ENDIF
 SET proc_start_dt_tm_formatted = fillstring(25," ")
 SET proc_end_dt_tm_formatted = fillstring(25," ")
 SET proc_start_time_string = fillstring(4," ")
 SET proc_end_time_string = fillstring(4," ")
 SET proc_start_time = 0
 SET proc_end_time = 0
 SET proc_cnt = 0
 SET los_proc_start_end = 0
 FOR (n = 1 TO proc_cnt)
   SET proc_start_dt_tm_formatted = format(cv_omf_rec->proc_data[n].proc_start_dt_tm,datefmt)
   SET proc_end_dt_tm_formatted = format(cv_omf_rec->proc_data[n].proc_end_dt_tm,datefmt)
   SET proc_start_time_string = format(cv_omf_rec->proc_data[n].proc_start_dt_tm,timefmt)
   SET proc_end_time_string = format(cv_omf_rec->proc_data[n].proc_end_dt_tm,timefmt)
   IF (size(trim(proc_start_time_string)) > 0
    AND size(trim(proc_end_time_string)) > 0)
    SET cv_omf_rec->proc_data[n].proc_complete_ind = 1
    SET cv_omf_rec->proc_data[n].proc_start_hour = hour(cnvtint(proc_start_time_string))
    SET cv_omf_rec->proc_data[n].proc_start_day = weekday(cnvtdatetime(proc_start_dt_tm_formatted))
    SET cv_omf_rec->proc_data[n].proc_start_month = month(cnvtdatetime(proc_start_dt_tm_formatted))
    SET los_proc_start_end = datetimecmp(cv_omf_rec->proc_data[n].proc_start_dt_tm,cv_omf_rec->
     proc_data[n].proc_end_dt_tm)
    SET proc_start_time = cnvtint(proc_start_time_string)
    SET proc_end_time = cnvtint(proc_end_time_string)
    IF (los_proc_start_end != 0)
     SET proc_end_time = (proc_end_time+ (2400 * los_proc_start_end))
    ENDIF
    SET cv_omf_rec->proc_data[n].proc_dur_min = (cnvtmin(proc_end_time) - cnvtmin(proc_start_time))
   ELSE
    SET cv_omf_rec->proc_data[n].proc_dur_min = 0
    SET cv_omf_rec->proc_data[n].proc_complete_ind = 0
    SET cv_omf_rec->proc_data[n].proc_start_hour = - (1)
    SET cv_omf_rec->proc_data[n].proc_start_day = - (1)
    SET cv_omf_rec->proc_data[n].proc_start_month = - (1)
   ENDIF
   IF (size(trim(admission_time_string)) > 0
    AND size(trim(proc_start_time_string)) > 0)
    SET cv_omf_rec->proc_data[n].los_adm_proc = datetimediff(cv_omf_rec->proc_data[n].
     proc_start_dt_tm,cv_omf_rec->admit_dt_tm)
   ENDIF
   IF (size(trim(discharge_time_string)) > 0
    AND size(trim(proc_end_time_string)) > 0)
    SET cv_omf_rec->proc_data[n].los_proc_disch = datetimediff(cv_omf_rec->disch_dt_tm,cv_omf_rec->
     proc_data[n].proc_end_dt_tm)
   ENDIF
 ENDFOR
 SET admission_dt_tm_formatted = fillstring(25," ")
 SET discharge_dt_tm_formatted = fillstring(25," ")
 SET admission_time_string = fillstring(4," ")
 SET discharge_time_string = fillstring(4," ")
 SET admission_dt_tm_formatted = format(cv_omf_rec->admit_dt_tm,datefmt)
 SET discharge_dt_tm_formatted = format(cv_omf_rec->disch_dt_tm,datefmt)
 SET admission_time_string = format(cv_omf_rec->admit_dt_tm,timefmt)
 SET discharge_time_string = format(cv_omf_rec->disch_dt_tm,timefmt)
 IF (size(trim(admission_time_string)) > 0)
  SET cv_omf_rec->admit_ind = 1
 ELSE
  SET cv_omf_rec->admit_ind = 0
 ENDIF
 IF (size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->disch_ind = 1
 ELSE
  SET cv_omf_rec->disch_ind = 0
 ENDIF
 IF (size(trim(admission_time_string)) > 0
  AND size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->los_adm_disch = datetimediff(cv_omf_rec->disch_dt_tm,cv_omf_rec->admit_dt_tm)
 ELSE
  SET cv_omf_rec->los_adm_disch = 0
 ENDIF
 SET age = 0
 SELECT INTO "nl:"
  p.sex_cd
  FROM person p
  WHERE (p.person_id=cv_omf_rec->person_id)
   AND p.active_ind=1
  DETAIL
   cv_omf_rec->sex_cd = p.sex_cd, age = (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm)/
   365.25), cv_omf_rec->age_year = age
   IF ((cv_omf_rec->death_ind=0))
    deceased_dt_tm_formatted = fillstring(25," "), deceased_time_string = fillstring(4," "),
    deceased_dt_tm_formatted = format(p.deceased_dt_tm,datefmt),
    deceased_time_string = format(p.deceased_dt_tm,timefmt)
    IF (size(trim(deceased_time_string)) > 0)
     cv_omf_rec->death_ind = 1
    ELSE
     cv_omf_rec->death_ind = 0
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
  SET cv_omf_rec->age_group_cd = baby_grp_cd
 ELSEIF (age >= 2
  AND age <= 18)
  SET cv_omf_rec->age_group_cd = 2_18_grp_cd
 ELSEIF (age >= 19
  AND age <= 44)
  SET cv_omf_rec->age_group_cd = 19_44_grp_cd
 ELSEIF (age >= 45
  AND age <= 54)
  SET cv_omf_rec->age_group_cd = 45_54_grp_cd
 ELSEIF (age >= 55
  AND age <= 64)
  SET cv_omf_rec->age_group_cd = 55_64_grp_cd
 ELSEIF (age >= 65
  AND age <= 74)
  SET cv_omf_rec->age_group_cd = 65_74_grp_cd
 ELSEIF (age >= 75
  AND age <= 84)
  SET cv_omf_rec->age_group_cd = 75_84_grp_cd
 ELSE
  SET cv_omf_rec->age_group_cd = 85_grp_cd
 ENDIF
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
