CREATE PROGRAM cv_get_order_detail:dba
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
 IF (validate(reply->status_data.status)=0)
  FREE SET reply
  RECORD reply(
    1 cv_proc[*]
      2 order_detail[*]
        3 oe_field_display_value = vc
        3 oe_field_dt_tm_value = dq8
        3 oe_field_id = f8
        3 oe_field_meaning_id = f8
        3 oe_field_tz = i4
        3 of_field_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE proc_cnt = i4 WITH protect
 IF (validate(proc_list->cv_proc)=0)
  CALL cv_log_stat(cv_warning,"VALIDATE","F","PROC_LIST","")
  GO TO exit_script
 ENDIF
 SET proc_cnt = size(proc_list->cv_proc,5)
 IF (proc_cnt <= 0)
  CALL cv_log_stat(cv_audit,"SIZE","Z","PROC_LIST","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->cv_proc,proc_cnt)
 DECLARE block_size = i4 WITH protect, noconstant(40)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nstart2 = i4 WITH protect, noconstant(1)
 DECLARE proc_idx = i4 WITH protect
 DECLARE proc_pad = i4 WITH protect
 DECLARE oe_field_cnt = i4 WITH protect, noconstant(size(request->oe_field,5))
 DECLARE oe_field_idx = i4 WITH protect
 DECLARE oe_field_pad = i4 WITH protect
 DECLARE detail_cnt = i4 WITH protect
 IF (oe_field_cnt > 0)
  SET block_size = 10
  SET oe_field_pad = (oe_field_cnt+ ((block_size - 1) - mod((oe_field_cnt - 1),block_size)))
  SET stat = alterlist(request->oe_field,oe_field_pad)
  FOR (oe_field_idx = (oe_field_cnt+ 1) TO oe_field_pad)
    SET request->oe_field[oe_field_idx].oe_field_meaning_id = request->oe_field[oe_field_cnt].
    oe_field_meaning_id
  ENDFOR
 ENDIF
 SET proc_pad = (proc_cnt+ ((block_size - 1) - mod((proc_cnt - 1),block_size)))
 SET stat = alterlist(proc_list->cv_proc,proc_pad)
 FOR (proc_idx = (proc_cnt+ 1) TO proc_pad)
   SET proc_list->cv_proc[proc_idx].order_id = proc_list->cv_proc[proc_cnt].order_id
 ENDFOR
 SET curalias this_detail reply->cv_proc[proc_idx].order_detail[detail_cnt]
 SELECT
  IF (oe_field_cnt > 0)
   FROM (dummyt d  WITH seq = value((proc_pad/ block_size))),
    (dummyt d2  WITH seq = value((oe_field_pad/ block_size))),
    order_detail od
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (d2
    WHERE assign(nstart2,evaluate(d2.seq,1,1,(nstart2+ block_size))))
    JOIN (od
    WHERE expand(proc_idx,nstart,((nstart+ block_size) - 1),od.order_id,proc_list->cv_proc[proc_idx].
     order_id)
     AND expand(oe_field_idx,nstart2,((nstart2+ block_size) - 1),od.oe_field_meaning_id,request->
     oe_field[oe_field_idx].oe_field_meaning_id))
  ELSE
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value((proc_pad/ block_size))),
   order_detail od
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
   JOIN (od
   WHERE expand(proc_idx,nstart,((nstart+ block_size) - 1),od.order_id,proc_list->cv_proc[proc_idx].
    order_id))
  ORDER BY od.order_id, od.oe_field_id, od.action_sequence
  HEAD od.order_id
   proc_idx = locateval(proc_idx,(1+ ((d.seq - 1) * block_size)),proc_cnt,od.order_id,proc_list->
    cv_proc[proc_idx].order_id), detail_cnt = 0
  HEAD od.oe_field_id
   col 0
  DETAIL
   col 0
  FOOT  od.oe_field_id
   detail_cnt += 1
   IF (mod(detail_cnt,10)=1)
    stat = alterlist(reply->cv_proc[proc_idx].order_detail,(detail_cnt+ 9))
   ENDIF
   this_detail->oe_field_display_value = od.oe_field_display_value, this_detail->oe_field_dt_tm_value
    = od.oe_field_dt_tm_value, this_detail->oe_field_id = od.oe_field_id,
   this_detail->oe_field_meaning_id = od.oe_field_meaning_id, this_detail->oe_field_tz = od
   .oe_field_tz, this_detail->oe_field_value = od.oe_field_value
  FOOT  od.order_id
   stat = alterlist(reply->cv_proc[proc_idx].order_detail,detail_cnt)
  WITH nocounter
 ;end select
 SET curalias this_detail off
 SET stat = alterlist(request->oe_field,oe_field_cnt)
 SET stat = alterlist(proc_list->cv_proc,proc_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL cv_log_msg_post("001 18/04/17 RR035230")
END GO
