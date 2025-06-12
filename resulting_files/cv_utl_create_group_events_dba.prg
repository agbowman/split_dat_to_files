CREATE PROGRAM cv_utl_create_group_events:dba
 PROMPT
  "Create group events if missing? (Y/N) " = "Y",
  "Synch event start date/time on clinical events? (Y/N) " = "Y",
  "Synch clinical event display with procedure status? (Y/N) " = "Y"
  WITH group_synch, ce_dt_tm_synch, ce_proc_status_synch
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD batch_req
 RECORD batch_req(
   1 orders[*]
     2 order_id = f8
 )
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 DECLARE group_synch_ind = i2 WITH protect
 DECLARE ce_dt_tm_synch_ind = i2 WITH protect
 DECLARE ce_proc_status_synch_ind = i2 WITH protect
 IF (cnvtupper( $GROUP_SYNCH)="Y")
  SET group_synch_ind = 1
 ENDIF
 IF (cnvtupper( $CE_DT_TM_SYNCH)="Y")
  SET ce_dt_tm_synch_ind = 1
 ENDIF
 IF (cnvtupper( $CE_PROC_STATUS_SYNCH)="Y")
  SET ce_proc_status_synch_ind = 1
 ENDIF
 IF (group_synch_ind=0
  AND ce_dt_tm_synch_ind=0
  AND ce_proc_status_synch_ind=0)
  CALL cv_log_msg(cv_info,"No actions chosen. Exiting script.")
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 DECLARE order_cnt = i4 WITH protect
 DECLARE locate_idx = i4 WITH protect
 DECLARE pos = i4 WITH protect
 IF (((ce_dt_tm_synch_ind=1) OR (group_synch_ind=1)) )
  SELECT
   IF (ce_dt_tm_synch_ind=1
    AND group_synch_ind=1)
    FROM cv_proc cp,
     clinical_event ce
    PLAN (cp
     WHERE cp.encntr_id != 0.0
      AND cp.order_id != 0.0)
     JOIN (ce
     WHERE ce.event_id=cp.group_event_id
      AND ((ce.event_start_dt_tm != cp.action_dt_tm
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)) OR (ce.clinical_event_id=0.0)) )
   ELSEIF (ce_dt_tm_synch_ind=1)
    FROM cv_proc cp,
     clinical_event ce
    PLAN (cp
     WHERE cp.encntr_id != 0.0
      AND cp.order_id != 0.0
      AND cp.group_event_id != 0.0)
     JOIN (ce
     WHERE ce.event_id=cp.group_event_id
      AND ce.event_start_dt_tm != cp.action_dt_tm
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
   ELSEIF (group_synch_ind=1)
    FROM cv_proc cp
    WHERE cp.encntr_id != 0.0
     AND cp.order_id != 0.0
     AND cp.group_event_id=0.0
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_proc cp
   WHERE (cp.cv_proc_id=- (1.0))
   HEAD REPORT
    order_cnt = 0
   DETAIL
    order_cnt += 1
    IF (order_cnt > size(batch_req->orders,5))
     stat = alterlist(batch_req->orders,(order_cnt+ 10))
    ENDIF
    batch_req->orders[order_cnt].order_id = cp.order_id
   FOOT REPORT
    stat = alterlist(batch_req->orders,order_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (ce_proc_status_synch_ind=1)
  SELECT INTO "nl:"
   FROM cv_proc cp,
    code_value cv,
    clinical_event ce
   PLAN (cp
    WHERE cp.group_event_id != 0.0
     AND cp.order_id != 0.0
     AND cp.encntr_id != 0.0)
    JOIN (cv
    WHERE cv.code_value=cp.proc_status_cd)
    JOIN (ce
    WHERE ce.event_id=cp.group_event_id
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.result_val != cv.display)
   HEAD REPORT
    order_cnt = size(batch_req->orders,5)
   DETAIL
    pos = 0
    IF (size(batch_req->orders,5) > 0)
     pos = locateval(locate_idx,1,order_cnt,cp.order_id,batch_req->orders[locate_idx].order_id)
    ENDIF
    IF (pos=0)
     order_cnt += 1
     IF (order_cnt >= size(batch_req->orders,5))
      stat = alterlist(batch_req->orders,(order_cnt+ 10))
     ENDIF
     batch_req->orders[order_cnt].order_id = cp.order_id
    ENDIF
   FOOT REPORT
    stat = alterlist(batch_req->orders,order_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","No qualifying procedures")
  GO TO exit_script
 ENDIF
 EXECUTE cv_batch_process_order  WITH replace("REQUEST",batch_req), replace("REPLY",reply)
#exit_script
 IF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"CV_UTL_CREATE_GROUP_EVENTS failed!")
  CALL echorecord(batch_req)
  CALL echorecord(reply)
 ELSE
  CALL cv_log_msg(cv_info,"CV_UTL_CREATE_GROUP_EVENTS successful")
 ENDIF
 CALL cv_log_msg_post("MOD 004 SM013857 04/07/2008")
END GO
