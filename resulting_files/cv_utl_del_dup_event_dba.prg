CREATE PROGRAM cv_utl_del_dup_event:dba
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
 IF ( NOT (validate(cv_dup_event,0)))
  RECORD cv_dup_event(
    1 dup_rec[*]
      2 cv_abstr_id = f8
      2 event_id = f8
      2 result_val = vc
      2 result_dt_tm = dq8
    1 del_rec[*]
      2 cv_abstr_id = f8
  )
 ENDIF
 SELECT INTO "nl:"
  cdr.event_id
  FROM cv_case_abstr_data ccad,
   ce_date_result cdr
  PLAN (ccad
   WHERE ccad.event_id > 0)
   JOIN (cdr
   WHERE ccad.event_id=cdr.event_id
    AND cdr.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cdr.result_dt_tm=ccad.result_dt_tm)
  ORDER BY cdr.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = ccad.case_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = cdr.event_id, cv_dup_event->dup_rec[event_cnt].result_dt_tm = cdr
   .result_dt_tm
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid date records were found in CV_CASE_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  ccad.event_id, ccad.updt_dt_tm
  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (ccad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=ccad.event_id)
    AND ccad.result_dt_tm=cnvtdatetime(cv_dup_event->dup_rec[d.seq].result_dt_tm))
  ORDER BY ccad.event_id, cnvtdatetime(ccad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD ccad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = ccad.case_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_CASE_ABSTR_DATA's re-selection!")
 ENDIF
 DELETE  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET ccad.seq = 1
  PLAN (d)
   JOIN (ccad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=ccad.case_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid date records were deleted in CV_CASE_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 SELECT INTO "nl:"
  cdr.event_id
  FROM cv_proc_abstr_data cpad,
   ce_date_result cdr
  PLAN (cpad
   WHERE cpad.event_id > 0)
   JOIN (cdr
   WHERE cpad.event_id=cdr.event_id
    AND cdr.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cdr.result_dt_tm=cpad.result_dt_tm)
  ORDER BY cdr.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = cpad.proc_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = cdr.event_id, cv_dup_event->dup_rec[event_cnt].result_dt_tm = cdr
   .result_dt_tm
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_PROC_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  cpad.event_id, cpad.updt_dt_tm
  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (cpad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=cpad.event_id)
    AND cpad.result_dt_tm=cnvtdatetime(cv_dup_event->dup_rec[d.seq].result_dt_tm))
  ORDER BY cpad.event_id, cnvtdatetime(cpad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD cpad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = cpad.proc_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_PROC_ABSTR_DATA's re-selection!")
 ENDIF
 DELETE  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET cpad.seq = 1
  PLAN (d)
   JOIN (cpad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=cpad.proc_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid date records were deleted in CV_PROC_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 SELECT INTO "nl:"
  cdr.event_id
  FROM cv_les_abstr_data clad,
   ce_date_result cdr
  PLAN (clad
   WHERE clad.event_id > 0)
   JOIN (cdr
   WHERE clad.event_id=cdr.event_id
    AND cdr.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cdr.result_dt_tm=clad.result_dt_tm)
  ORDER BY cdr.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = clad.les_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = cdr.event_id, cv_dup_event->dup_rec[event_cnt].result_dt_tm = cdr
   .result_dt_tm
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid date records were found in CV_LES_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  clad.event_id, clad.updt_dt_tm
  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (clad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=clad.event_id)
    AND clad.result_dt_tm=cnvtdatetime(cv_dup_event->dup_rec[d.seq].result_dt_tm))
  ORDER BY clad.event_id, cnvtdatetime(clad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD clad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = clad.les_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_LES_ABSTR_DATA's re-selection!")
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,cv_dup_event)
 DELETE  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET clad.seq = 1
  PLAN (d)
   JOIN (clad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=clad.les_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid date records were deleted in CV_LES_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 SELECT INTO "nl:"
  ce.event_id
  FROM cv_case_abstr_data ccad,
   clinical_event ce
  PLAN (ccad
   WHERE ccad.event_id > 0)
   JOIN (ce
   WHERE ccad.event_id=ce.event_id
    AND ce.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cnvtupper(trim(ce.event_tag,3))=cnvtupper(trim(ccad.result_val,3)))
  ORDER BY ce.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = ccad.case_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = ce.event_id, cv_dup_event->dup_rec[event_cnt].result_val = trim(ce.event_tag
    )
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_CASE_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  ccad.event_id, ccad.updt_dt_tm
  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (ccad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=ccad.event_id)
    AND cnvtupper(trim(cv_dup_event->dup_rec[d.seq].result_val,3))=cnvtupper(trim(ccad.result_val,3))
   )
  ORDER BY ccad.event_id, cnvtdatetime(ccad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD ccad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = ccad.case_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_CASE_ABSTR_DATA's re-selection!")
 ENDIF
 DELETE  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET ccad.seq = 1
  PLAN (d)
   JOIN (ccad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=ccad.case_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid records were deleted in CV_CASE_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 SELECT INTO "nl:"
  ce.event_id
  FROM cv_proc_abstr_data cpad,
   clinical_event ce
  PLAN (cpad
   WHERE cpad.event_id > 0)
   JOIN (ce
   WHERE cpad.event_id=ce.event_id
    AND ce.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cnvtupper(trim(ce.event_tag))=cnvtupper(trim(cpad.result_val)))
  ORDER BY ce.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = cpad.proc_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = ce.event_id, cv_dup_event->dup_rec[event_cnt].result_val = trim(ce.event_tag
    )
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_PROC_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  cpad.event_id, cpad.updt_dt_tm
  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (cpad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=cpad.event_id)
    AND cnvtupper(trim(cv_dup_event->dup_rec[d.seq].result_val,3))=cnvtupper(trim(cpad.result_val,3))
   )
  ORDER BY cpad.event_id, cnvtdatetime(cpad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD cpad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = cpad.proc_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_PROC_ABSTR_DATA's re-selection!")
 ENDIF
 DELETE  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET cpad.seq = 1
  PLAN (d)
   JOIN (cpad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=cpad.proc_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid records were deleted in CV_PROC_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 SELECT INTO "nl:"
  ce.event_id
  FROM cv_les_abstr_data clad,
   clinical_event ce
  PLAN (clad
   WHERE clad.event_id > 0)
   JOIN (ce
   WHERE clad.event_id=ce.event_id
    AND ce.valid_until_dt_tm != cnvtdatetime(null_date)
    AND cnvtupper(trim(ce.event_tag))=cnvtupper(trim(clad.result_val)))
  ORDER BY ce.event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > size(cv_dup_event->dup_rec,5))
    stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
   ENDIF
   cv_dup_event->dup_rec[event_cnt].cv_abstr_id = clad.les_abstr_data_id, cv_dup_event->dup_rec[
   event_cnt].event_id = ce.event_id, cv_dup_event->dup_rec[event_cnt].result_val = trim(ce.event_tag
    )
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_LES_ABSTR_DATA!")
 ENDIF
 SELECT INTO "nl:"
  clad.event_id, clad.updt_dt_tm
  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  PLAN (d)
   JOIN (clad
   WHERE (cv_dup_event->dup_rec[d.seq].event_id=clad.event_id)
    AND cnvtupper(trim(cv_dup_event->dup_rec[d.seq].result_val,3))=cnvtupper(trim(clad.result_val,3))
   )
  ORDER BY clad.event_id, cnvtdatetime(clad.updt_dt_tm) DESC
  HEAD REPORT
   del_cnt = 0
  HEAD clad.event_id
   event_cnt = 0
  DETAIL
   event_cnt = (event_cnt+ 1)
   IF (event_cnt > 1)
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(cv_dup_event->del_rec,5))
     stat = alterlist(cv_dup_event->del_rec,(del_cnt+ 9))
    ENDIF
    cv_dup_event->del_rec[del_cnt].cv_abstr_id = clad.les_abstr_data_id
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->del_rec,del_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No invalid records were found in CV_LES_ABSTR_DATA's re-selection!")
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,cv_dup_event)
 DELETE  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(cv_dup_event->del_rec,5)))
  SET clad.seq = 1
  PLAN (d)
   JOIN (clad
   WHERE (cv_dup_event->del_rec[d.seq].cv_abstr_id=clad.les_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No invalid records were deleted in CV_LES_ABSTR_DATA!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SET stat = alterlist(cv_dup_event->del_rec,0)
 DECLARE result_tmp = vc
 SELECT INTO "nl:"
  ccad.event_id, ccad.case_abstr_data_id
  FROM cv_case_abstr_data ccad
  PLAN (ccad
   WHERE ccad.event_id > 0)
  ORDER BY ccad.event_id, ccad.case_abstr_data_id
  HEAD REPORT
   event_cnt = 0, event_tmp = 0, result_tmp = " "
  HEAD ccad.event_id
   dup_cnt = 0
  DETAIL
   event_tmp = ccad.event_id, result_tmp = ccad.result_val
   IF (event_tmp=ccad.event_id
    AND trim(result_tmp)=trim(ccad.result_val))
    dup_cnt = (dup_cnt+ 1)
    IF (dup_cnt > 1)
     event_cnt = (event_cnt+ 1)
     IF (event_cnt > size(cv_dup_event->dup_rec,5))
      stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
     ENDIF
     cv_dup_event->dup_rec[event_cnt].cv_abstr_id = ccad.case_abstr_data_id, cv_dup_event->dup_rec[
     event_cnt].event_id = ccad.event_id, cv_dup_event->dup_rec[event_cnt].result_val = ccad
     .result_val
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (size(cv_dup_event->dup_rec,5)=0)
  CALL cv_log_message("No duplicated records were founded in CV_CASE_ABSTR_DATA")
 ELSE
  CALL echorecord(cv_dup_event)
 ENDIF
 DELETE  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  SET ccad.seq = 1
  PLAN (d)
   JOIN (ccad
   WHERE (cv_dup_event->dup_rec[d.seq].cv_abstr_id=ccad.case_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("No duplicated records were deleted in cv_case_abstr_data!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SELECT INTO "nl:"
  cpad.event_id, cpad.proc_abstr_data_id
  FROM cv_proc_abstr_data cpad
  PLAN (cpad
   WHERE cpad.event_id > 0)
  ORDER BY cpad.event_id, cpad.proc_abstr_data_id
  HEAD REPORT
   event_cnt = 0, event_tmp = 0, result_tmp = " "
  HEAD cpad.event_id
   dup_cnt = 0
  DETAIL
   event_tmp = cpad.event_id, result_tmp = cpad.result_val
   IF (event_tmp=cpad.event_id
    AND trim(result_tmp)=trim(cpad.result_val))
    dup_cnt = (dup_cnt+ 1)
    IF (dup_cnt > 1)
     event_cnt = (event_cnt+ 1)
     IF (event_cnt > size(cv_dup_event->dup_rec,5))
      stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
     ENDIF
     cv_dup_event->dup_rec[event_cnt].cv_abstr_id = cpad.proc_abstr_data_id, cv_dup_event->dup_rec[
     event_cnt].event_id = cpad.event_id, cv_dup_event->dup_rec[event_cnt].result_val = cpad
     .result_val
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (size(cv_dup_event->dup_rec,5)=0)
  CALL cv_log_message("No duplicated records were founded in CV_PROC_ABSTR_DATA")
 ELSE
  CALL echorecord(cv_dup_event)
 ENDIF
 DELETE  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  SET cpad.seq = 1
  PLAN (d)
   JOIN (cpad
   WHERE (cv_dup_event->dup_rec[d.seq].cv_abstr_id=cpad.proc_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("No duplicated records were deleted in cv_PROC_abstr_data!")
 ENDIF
 SET stat = alterlist(cv_dup_event->dup_rec,0)
 SELECT INTO "nl:"
  clad.event_id, clad.les_abstr_data_id
  FROM cv_les_abstr_data clad
  PLAN (clad
   WHERE clad.event_id > 0)
  ORDER BY clad.event_id, clad.les_abstr_data_id
  HEAD REPORT
   event_cnt = 0, event_tmp = 0, result_tmp = " "
  HEAD clad.event_id
   dup_cnt = 0
  DETAIL
   event_tmp = clad.event_id, result_tmp = clad.result_val
   IF (event_tmp=clad.event_id
    AND trim(result_tmp)=trim(clad.result_val))
    dup_cnt = (dup_cnt+ 1)
    IF (dup_cnt > 1)
     event_cnt = (event_cnt+ 1)
     IF (event_cnt > size(cv_dup_event->dup_rec,5))
      stat = alterlist(cv_dup_event->dup_rec,(event_cnt+ 9))
     ENDIF
     cv_dup_event->dup_rec[event_cnt].cv_abstr_id = clad.les_abstr_data_id, cv_dup_event->dup_rec[
     event_cnt].event_id = clad.event_id, cv_dup_event->dup_rec[event_cnt].result_val = clad
     .result_val
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(cv_dup_event->dup_rec,event_cnt)
  WITH nocounter
 ;end select
 IF (size(cv_dup_event->dup_rec,5)=0)
  CALL cv_log_message("No duplicated records were founded in CV_LES_ABSTR_DATA")
 ELSE
  CALL echorecord(cv_dup_event)
 ENDIF
 DELETE  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(cv_dup_event->dup_rec,5)))
  SET clad.seq = 1
  PLAN (d)
   JOIN (clad
   WHERE (cv_dup_event->dup_rec[d.seq].cv_abstr_id=clad.les_abstr_data_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("No duplicated records were deleted in cv_LES_abstr_data!")
 ENDIF
#exit_script
 IF (size(cv_dup_event->dup_rec,5) > 0)
  CALL echorecord(cv_dup_event)
  CALL echo("Type commit go if you want to remove these records, otherwise type rollback go!")
 ELSE
  CALL cv_log_message("No duplicated records were found in any summary tables!")
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
