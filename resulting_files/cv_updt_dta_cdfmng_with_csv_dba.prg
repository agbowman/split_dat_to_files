CREATE PROGRAM cv_updt_dta_cdfmng_with_csv:dba
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
 IF (validate(requestin,"notdefined") != "notdefined")
  CALL echo("Requestin record structure  is already defined!")
 ELSE
  CALL echo("Please use the *.com file to run this!!")
 ENDIF
 IF (validate(cv_internal,"notdefined") != "notdefined")
  CALL echo("Cv_internal record structure  is already defined!")
 ELSE
  RECORD cv_internal(
    1 pack[*]
      2 cdf_meaning = c12
      2 xref_internal_name = vc
      2 event_cd = f8
      2 task_assay_cd = f8
  )
 ENDIF
 IF (validate(reply,"notdefined") != "notdefined")
  CALL echo("reply  is already defined!")
 ELSE
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
 SET beventselect = "FALSE"
 SET packet = 0
 SELECT INTO "NL:"
  ref.event_cd
  FROM cv_xref ref,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (ref
   WHERE (ref.xref_internal_name=requestin->list_0[d1.seq].xref_internal_name))
  DETAIL
   beventselect = "TRUE", packet = (packet+ 1), stat = alterlist(cv_internal->pack,packet)
   IF (mod(packet,100)=1)
    update_rows = alterlist(cv_internal->pack,(packet+ 99))
   ENDIF
   cv_internal->pack[packet].event_cd = ref.event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("The select statement Failed to get event_cd ")
  SET reply->status_data.subeventstatus[1].operationname = "Event_cd Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_event_cd"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get cv_xref event_cd "
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET bselection = "False"
 SET event_cnt = 0
 SELECT INTO "NL:"
  dta.task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d2  WITH seq = value(size(cv_internal->pack,5)))
  PLAN (d2)
   JOIN (dta
   WHERE (dta.event_cd=cv_internal->pack[d2.seq].event_cd))
  HEAD REPORT
   rows_to_update = 0
  DETAIL
   bselection = "True", event_cnt = (event_cnt+ 1), cv_internal->pack[d2.seq].task_assay_cd = dta
   .task_assay_cd
  FOOT REPORT
   stat = alterlist(cv_internal->pack,packet)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("The select statement Failed to get task_assay_cd ")
  SET reply->status_data.subeventstatus[1].operationname = "Task_assay_cd Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "get_task_assay_cd"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get_task_assay_cd "
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value cv,
   (dummyt d3  WITH seq = value(event_cnt))
  SET cv.cdf_meaning = cv_internal->pack[d3.seq].cdf_meaning
  PLAN (d3)
   JOIN (cv
   WHERE (cv.code_value=cv_internal->pack[d3.seq].task_assay_cd)
    AND cv.code_set=14003
    AND cv.active_ind=1
    AND ((cv.begin_effective_dt_tm=null) OR (cv.begin_effective_dt_tm != null
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((cv.end_effective_dt_tm=null) OR (cv.end_effective_dt_tm != null
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
  WITH nocounter
 ;end update
#exit_script
 IF (bselection="TRUE")
  SET reply->status_data.status = "T"
 ENDIF
 IF (beventselect="TRUE")
  SET reply->status_data.status = "T"
 ENDIF
#end_program
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
