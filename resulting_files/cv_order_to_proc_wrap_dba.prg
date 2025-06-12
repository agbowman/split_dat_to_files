CREATE PROGRAM cv_order_to_proc_wrap:dba
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
 RECORD order_req(
   1 catalog_cd = f8
   1 order_id = f8
   1 encntr_id = f8
   1 person_id = f8
   1 action_type_cd = f8
   1 sch_event_id = f8
   1 order_provider_id = f8
   1 detaillist[*]
     2 oefieldid = f8
     2 oefieldvalue = f8
     2 oefielddisplayvalue = vc
     2 oefielddttmvalue = dq8
     2 oefieldmeaning = vc
     2 oefieldmeaningid = f8
     2 modifiedind = i2
   1 activity_subtype_cd = f8
 )
 IF (validate(reply)=0)
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
 SET reply->status_data.status = "F"
 DECLARE g_cv_proc_id = f8
 DECLARE od_cnt = i4
 SET order_req->order_id = request->order_id
 SELECT INTO "nl:"
  FROM cv_proc p
  WHERE (p.order_id=request->order_id)
  DETAIL
   g_cv_proc_id = p.cv_proc_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  detail_null = nullind(od.order_id)
  FROM orders o,
   order_detail od,
   order_catalog oc
  PLAN (o
   WHERE (o.order_id=request->order_id))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id)) )
  ORDER BY od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   order_req->catalog_cd = o.catalog_cd, order_req->encntr_id = o.encntr_id, order_req->person_id = o
   .person_id,
   order_req->activity_subtype_cd = oc.activity_subtype_cd
  HEAD od.oe_field_id
   IF (detail_null=0)
    od_cnt += 1, stat = alterlist(order_req->detaillist,od_cnt), order_req->detaillist[od_cnt].
    oefieldid = od.oe_field_id,
    order_req->detaillist[od_cnt].oefielddisplayvalue = od.oe_field_display_value, order_req->
    detaillist[od_cnt].oefielddttmvalue = od.oe_field_dt_tm_value, order_req->detaillist[od_cnt].
    oefieldid = od.oe_field_id,
    order_req->detaillist[od_cnt].oefieldmeaning = od.oe_field_meaning, order_req->detaillist[od_cnt]
    .oefieldmeaningid = od.oe_field_meaning_id, order_req->detaillist[od_cnt].oefieldvalue = od
    .oe_field_value,
    order_req->detaillist[od_cnt].modifiedind = 1
   ENDIF
  DETAIL
   col 0
  FOOT  od.oe_field_id
   col 0
  WITH nocounter
 ;end select
 IF ((order_req->person_id=0.0))
  CALL cv_log_stat(cv_audit,"SELECT","F","ORDERS","PERSON_ID=0.0")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_action oa
  PLAN (oa
   WHERE (oa.order_id=order_req->order_id)
    AND oa.order_provider_id > 0.0)
  ORDER BY oa.action_sequence
  HEAD REPORT
   order_req->order_provider_id = oa.order_provider_id
  DETAIL
   col 0
  WITH nocounter, maxqual(oa,1)
 ;end select
 IF (g_cv_proc_id > 0.0)
  SET order_req->action_type_cd = uar_get_code_by("MEANING",6003,"MODIFY")
 ELSE
  SET order_req->action_type_cd = uar_get_code_by("MEANING",6003,"ORDER")
 ENDIF
 CALL echorecord(order_req)
 EXECUTE cv_order_to_proc  WITH replace("REQUEST","ORDER_REQ")
#exit_script
 IF ((reply->status_data.status != "S"))
  SET commit_ind = 0
  CALL cv_log_msg(cv_audit,"cv_order_to_proc_wrap Failed")
 ENDIF
 IF ((reqdata->loglevel >= cv_info))
  CALL cv_log_msg(cv_info,concat("Leaving ",curprog," at ",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
  CALL cv_log_msg(cv_info,concat("************ The Error Log File is: ",cv_log_file_name))
 ENDIF
 IF (cv_log_msg_cnt > 0)
  EXECUTE cv_log_flush_message
  SET cv_log_msg_cnt = 0
 ENDIF
END GO
