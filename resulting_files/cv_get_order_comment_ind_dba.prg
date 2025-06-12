CREATE PROGRAM cv_get_order_comment_ind:dba
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
 DECLARE request_count = i4 WITH protect, noconstant(0)
 DECLARE reply_count = i4 WITH protect, noconstant(0)
 DECLARE comments_batch_size = i4 WITH protect, constant(20)
 DECLARE temp_size = i4 WITH protect, noconstant(0)
 DECLARE start_index = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(1)
 DECLARE comment_text = vc WITH protect, noconstant("")
 IF (validate(reply) != 1)
  RECORD reply(
    1 orders[*]
      2 order_id = f8
      2 order_comment_ind = i4
  )
 ENDIF
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 DECLARE order_note_cd_val = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT")), protect
 SET request_count = size(request->orders,5)
 IF (request_count > 0)
  SET temp_size = (request_count+ ((comments_batch_size - 1) - mod((request_count - 1),
   comments_batch_size)))
  SET stat = alterlist(request->orders,temp_size)
  FOR (x = (request_count+ 1) TO temp_size)
    SET request->orders[x].order_id = request->orders[request_count].order_id
  ENDFOR
  SET start_index = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((temp_size/ comments_batch_size))),
    order_comment o,
    long_text l
   PLAN (d
    WHERE assign(start_index,evaluate(d.seq,1,1,(start_index+ comments_batch_size))))
    JOIN (o
    WHERE expand(index,start_index,((start_index+ comments_batch_size) - 1),o.order_id,request->
     orders[index].order_id)
     AND ((o.comment_type_cd+ 0) IN (order_note_cd_val)))
    JOIN (l
    WHERE o.long_text_id=l.long_text_id)
   ORDER BY o.order_id, o.action_sequence DESC
   HEAD REPORT
    reply_count = 0
   HEAD o.order_id
    comment_text = l.long_text, reply_count = (reply_count+ 1), stat = alterlist(reply->orders,
     reply_count)
    IF (size(comment_text,1) > 0)
     reply->orders[reply_count].order_id = o.order_id, reply->orders[reply_count].order_comment_ind
      = 1
    ELSE
     reply->orders[reply_count].order_comment_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(request->orders,request_count)
 ENDIF
END GO
