CREATE PROGRAM cv_utl_sync_dta:dba
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
 RECORD cv_internal(
   1 xref[*]
     2 xref_internal_name = vc
     2 dta_cd = f8
     2 event_cd = f8
     2 dta_meaning = vc
 )
 SET failure = "F"
 SET alpha_cs = 25290
 SET dta_cs = 14003
 SET alpha_cd = 0.0
 SET alpha_mean = "ALPHA"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=alpha_cs
   AND c.cdf_meaning=alpha_mean
  DETAIL
   alpha_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failure in selecting code_value!")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 CALL echo(build("The Alpha Code is::",alpha_cd))
 SELECT INTO "NL:"
  ref.xref_internal_name
  FROM cv_xref ref
  WHERE ref.field_type_cd=alpha_cd
   AND ref.xref_id > 0
   AND ((ref.event_cd=0) OR (ref.task_assay_cd=0))
  HEAD REPORT
   stat = alterlist(cv_internal->xref,10), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(cv_internal->xref,(cnt+ 9))
   ENDIF
   cv_internal->xref[cnt].xref_internal_name = cnvtupper(trim(ref.xref_internal_name))
  FOOT REPORT
   stat = alterlist(cv_internal->xref,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No such case in cv_case table!")
 ELSE
  SET del_flag = 1
 ENDIF
 CALL cv_log_message("Finished Loading Internal Struct!")
 CALL cv_log_message(build("Size of internal:",size(cv_internal->xref,5)))
 SET idx = 0
 DECLARE str1 = vc
 DECLARE str2 = vc
 CALL echorecord(cv_internal)
 FOR (idx = 1 TO size(cv_internal->xref,5))
   SET str1 = substring(1,2,cv_internal->xref[idx].xref_internal_name)
   SET str2 = substring(3,2,cv_internal->xref[idx].xref_internal_name)
   SET str3 = substring(7,95,cv_internal->xref[idx].xref_internal_name)
   SET str3 = trim(str3)
   SET cv_internal->xref[idx].dta_meaning = concat(str1,"02",str3)
 ENDFOR
 CALL echorecord(cv_internal)
 CALL cv_log_message("Before selecting code_value & discrete_task_assay!")
 SELECT
  *
  FROM code_value cv,
   discrete_task_assay dta,
   (dummyt d1  WITH seq = value(size(cv_internal->xref,5)))
  PLAN (d1
   WHERE (cv_internal->xref[d1.seq].xref_internal_name > " "))
   JOIN (cv
   WHERE cv.code_set=dta_cs
    AND trim(cv.cdf_meaning)=trim(cv_internal->xref[d1.seq].dta_meaning)
    AND cv.active_ind=1)
   JOIN (dta
   WHERE cv.code_value=dta.task_assay_cd)
  DETAIL
   cv_internal->xref[d1.seq].dta_cd = dta.task_assay_cd, cv_internal->xref[d1.seq].event_cd = dta
   .event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = 2
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failure in selecting code_value & discrete_task_assay!")
 ENDIF
 CALL cv_log_message("After selecting code_value & discrete_task_assay!")
 CALL echorecord(cv_internal)
 UPDATE  FROM cv_xref ref,
   (dummyt d  WITH seq = value(size(cv_internal->xref,5)))
  SET ref.event_cd = cv_internal->xref[d.seq].event_cd, ref.task_assay_cd = cv_internal->xref[d.seq].
   dta_cd
  PLAN (d)
   JOIN (ref
   WHERE (ref.xref_internal_name=cv_internal->xref[d.seq].xref_internal_name))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET cv_log_level = 2
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failure in updating cv_xref for event_cd and dta_cd!")
 ENDIF
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
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
END GO
