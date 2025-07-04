CREATE PROGRAM cv_add_upd_long_text:dba
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
  DECLARE cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) = null
  DECLARE cv_log_msg(log_lev=i2,the_message=vc(byval)) = null
  DECLARE cv_log_msg_post(script_vrsn=vc) = null
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(curdate,curtime3),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE cv_log_stat(log_lev,op_name,op_stat,obj_name,obj_value)
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
 SUBROUTINE cv_log_msg(log_lev,the_message)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt = (cv_log_error_string_cnt+ 1)
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE cv_log_msg_post(script_vrsn)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 RECORD reply(
   1 long_text_id = f8
   1 long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->mode=1)
  AND (request->long_text_id > 0))
  DELETE  FROM long_text lt
   WHERE (lt.long_text_id=request->long_text_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET reply->status_data.status = "F"
   CALL cv_log_msg(cv_error,"Delete from Long_Text failed")
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->mode=2)
  AND (request->long_text_id > 0))
  UPDATE  FROM long_text lt
   SET lt.long_text = request->long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WHERE (lt.long_text_id=request->long_text_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   CALL cv_log_msg(cv_error,"Update to Long_Text failed")
  ELSE
   SET reply->status_data.status = "S"
   SET reply->long_text_id = request->long_text_id
  ENDIF
 ELSEIF ((request->mode=3))
  DECLARE dlongtextid = f8 WITH noconstant(0.0)
  SELECT INTO "nl:"
   nextsequence = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    dlongtextid = cnvtreal(nextsequence)
   WITH format, nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = dlongtextid, lt.long_text = request->long_text, lt.updt_cnt = 0,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
    reqinfo->updt_task,
    lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   CALL cv_log_msg(cv_error,"Insert to Long_Text failed")
  ELSE
   SET reply->long_text_id = dlongtextid
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->mode=4)
  AND (request->long_text_id > 0))
  SELECT INTO "nl:"
   FROM long_text lt
   WHERE (lt.long_text_id=request->long_text_id)
   DETAIL
    reply->long_text = lt.long_text
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   CALL cv_log_msg(cv_error,"No rows qualified from Long_Text")
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 COMMIT
 CALL cv_log_msg_post("001 12/07/17 JT023123")
END GO
