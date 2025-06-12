CREATE PROGRAM cv_get_omf_los:dba
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
  CALL cv_log_message("Select from encounter table failed, program continue!")
 ENDIF
 SET cv_omf_rec->admt_dt_num = cnvtdate(cv_omf_rec->admit_dt_tm)
 SET cv_omf_rec->disch_dt_num = cnvtdate(cv_omf_rec->disch_dt_tm)
 SELECT DISTINCT INTO "nl:"
  cc.pat_adm_dt_tm
  FROM cv_case cc
  WHERE (cc.encntr_id=cv_omf_rec->encntr_id)
   AND cc.active_ind=1
   AND cc.pat_adm_ind=1
  DETAIL
   cv_omf_rec->date_of_admission = cc.pat_adm_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ffailure = "T"
  CALL cv_log_message("Select Failed in select cv_case table")
  GO TO exit_script
 ENDIF
 DECLARE admission_dt_tm_formatted = c25 WITH protect, noconstant(fillstring(25," "))
 DECLARE discharge_dt_tm_formatted = c25 WITH protect, noconstant(fillstring(25," "))
 DECLARE admission_time_string = c4 WITH protect, noconstant(fillstring(4," "))
 DECLARE discharge_time_string = c4 WITH protect, noconstant(fillstring(4," "))
 SET admission_dt_tm_formatted = format(cv_omf_rec->date_of_admission,datefmt)
 SET discharge_dt_tm_formatted = format(cv_omf_rec->date_of_discharge,datefmt)
 SET admission_time_string = format(cv_omf_rec->date_of_admission,timefmt)
 SET discharge_time_string = format(cv_omf_rec->date_of_discharge,timefmt)
 IF (size(trim(admission_time_string)) > 0)
  SET cv_omf_rec->admission_ind = 1
 ELSE
  SET cv_omf_rec->admission_ind = 0
 ENDIF
 IF (size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->discharge_ind = 1
 ELSE
  SET cv_omf_rec->discharge_ind = 0
 ENDIF
 IF (size(trim(admission_time_string)) > 0
  AND size(trim(discharge_time_string)) > 0)
  SET cv_omf_rec->los_adm_disch = datetimecmp(cv_omf_rec->date_of_discharge,cv_omf_rec->
   date_of_admission)
 ELSE
  SET cv_omf_rec->los_adm_disch = 0
 ENDIF
 SET deceased_dt_tm_formatted = fillstring(25," ")
 SET deceased_time_string = fillstring(4," ")
 SET age = 0
 SELECT INTO "nl:"
  p.sex_cd
  FROM person p
  WHERE (p.person_id=cv_omf_rec->person_id)
   AND p.active_ind=1
  DETAIL
   deceased_dt_tm_formatted = format(p.deceased_dt_tm,datefmt), deceased_time_string = format(p
    .deceased_dt_tm,timefmt), cv_omf_rec->sex_cd = p.sex_cd,
   age = (datetimecmp(cnvtdatetime(curdate,curtime),p.birth_dt_tm)/ 365.25), cv_omf_rec->age_year =
   age
   IF ((cv_omf_rec->death_ind=0))
    IF (size(trim(deceased_time_string)) > 0)
     cv_omf_rec->death_ind = 1
    ELSE
     cv_omf_rec->death_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in select the person table")
 ENDIF
 IF ((cv_omf_rec->death_ind=0))
  SELECT INTO "nl:"
   FROM nomenclature n,
    (dummyt d  WITH seq = value(size(cv_omf_rec->case_abstr_data,5)))
   PLAN (d
    WHERE trim(cv_omf_rec->case_abstr_data[d.seq].task_assay_meaning)="ACC141DDETH")
    JOIN (n
    WHERE (n.nomenclature_id=cv_omf_rec->case_abstr_data[d.seq].nomenclature_id)
     AND cnvtupper(n.mnemonic)="YES")
   DETAIL
    cv_omf_rec->death_ind = 1, cv_omf_rec->disch_ind = 1
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message(concat("Select from nomenclature for death_ind "," failed, program continue!")
    )
  ENDIF
 ENDIF
 DECLARE baby_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 2_18_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 19_44_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 45_54_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 55_64_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 65_74_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 75_84_grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE 85_grp_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  cv.code_value, cdf = cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=22329
   AND cv.cdf_meaning IN ("<2YEAR", "2-18", "19-44", "45-54", "55-64",
  "65-74", "75-84", "85+")
   AND cv.active_ind=1
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
  CALL cv_log_message("Failed in select the code_value table, program continue!")
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
 CALL echorecord(cv_omf_rec)
#exit_script
 IF (ffailure="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
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
 DECLARE cv_get_omf_los_vrsn = vc WITH private, constant("MOD 001 BM9013 03/22/06")
END GO
