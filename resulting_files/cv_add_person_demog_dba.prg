CREATE PROGRAM cv_add_person_demog:dba
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
 DECLARE mrn_cd = f8 WITH noconstant(0.0), protect
 SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
 IF (mrn_cd <= 0.0)
  CALL cv_log_message("Failed to find MRN person_alias_type_cd")
  GO TO exit_script
 ENDIF
 IF (validate(person_request->person[1].recordid_str))
  DECLARE recordid_cd = f8 WITH noconstant(0.0), protect
  SET recordid_cd = uar_get_code_by("MEANING",263,"STSRECORDID")
  IF (recordid_cd <= 0.0)
   CALL cv_log_message("Failed to find RecordID alias_pool_cd. Matching only on encounter data")
  ELSE
   SELECT INTO "nl:"
    e.encntr_id, e.person_id
    FROM encntr_alias ea,
     encounter e,
     organization o,
     (dummyt d  WITH seq = value(size(person_request->person,5)))
    PLAN (d
     WHERE (person_request->person[d.seq].recordid_str > " "))
     JOIN (ea
     WHERE (ea.alias=person_request->person[d.seq].recordid_str)
      AND ea.alias_pool_cd=recordid_cd)
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id)
     JOIN (o
     WHERE o.organization_id=e.organization_id
      AND cnvtupper(o.org_name)=cnvtupper(trim(person_request->person[d.seq].hospital_name)))
    DETAIL
     person_request->person[d.seq].encntr_id = e.encntr_id, person_request->person[d.seq].person_id
      = e.person_id, person_request->person[d.seq].bvaliddatastatus = 1,
     CALL cv_log_message(build("Matched record:",person_request->person[d.seq].recordid_str,
      ": with encntr_id:",e.encntr_id))
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  CALL cv_log_message("No recordid_str field found in person_request")
 ENDIF
 SELECT INTO "nl:"
  bnulldisch = nullind(e.disch_dt_tm), e.reg_dt_tm, e.disch_dt_tm,
  p.person_id, e.encntr_id
  FROM person_alias pa,
   person p,
   encounter e,
   organization o,
   (dummyt d  WITH seq = value(size(person_request->person,5)))
  PLAN (d
   WHERE d.seq > 0
    AND (person_request->person[d.seq].encntr_id=0.0))
   JOIN (pa
   WHERE (pa.alias=person_request->person[d.seq].mrn)
    AND pa.person_alias_type_cd=mrn_cd)
   JOIN (p
   WHERE p.person_id=pa.person_id)
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND cnvtupper(o.org_name)=cnvtupper(trim(person_request->person[d.seq].hospital_name)))
  ORDER BY d.seq
  HEAD d.seq
   bfoundmatch = 0
  DETAIL
   IF (cnvtdate(e.reg_dt_tm)=cnvtdate(person_request->person[d.seq].date_of_admission)
    AND ((cnvtdate(e.disch_dt_tm)=cnvtdate(person_request->person[d.seq].date_of_discharge)) OR (
   bnulldisch=1
    AND (person_request->person[d.seq].date_of_discharge=cnvtdate2("","MMDDYYYY")))) )
    IF (bfoundmatch=0)
     bfoundmatch = 1, person_request->person[d.seq].person_id = p.person_id, person_request->person[d
     .seq].encntr_id = e.encntr_id,
     person_request->person[d.seq].bvaliddatastatus = 1
    ELSEIF ((((e.encntr_id != person_request->person[d.seq].encntr_id)) OR ((p.person_id !=
    person_request->person[d.seq].person_id))) )
     CALL cv_log_message(build("Conflicting matches on person or encounter at d.seq=",d.seq)),
     person_request->person[d.seq].person_id = 0.0, person_request->person[d.seq].encntr_id = 0.0,
     person_request->person[d.seq].bvaliddatastatus = 0
    ENDIF
   ENDIF
  FOOT  d.seq
   IF ((person_request->person[d.seq].encntr_id=0.0))
    CALL cv_log_message(build("Failed to match unique encounter at d.seq=",d.seq)), person_request->
    person[d.seq].bvaliddatastatus = 0
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
END GO
