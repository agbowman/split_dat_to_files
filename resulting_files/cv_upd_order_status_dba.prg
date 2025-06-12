CREATE PROGRAM cv_upd_order_status:dba
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
 IF (validate(reply->status_data))
  CALL cv_log_msg(cv_debug,"Reply already defined")
 ELSE
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
 FREE RECORD orderinfo
 RECORD orderinfo(
   1 timezone_index = i4
   1 orderaction_id = f8
   1 order_id = f8
 )
 DECLARE applicationid = i4 WITH constant(4100001), protect
 DECLARE taskid = i4 WITH constant(560201), protect
 DECLARE requestid = i4 WITH constant(560201), protect
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE horder = i4 WITH protect, noconstant(0)
 DECLARE hmisclistitem = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE timezone_name = vc WITH protect, noconstant("")
 DECLARE lastupdtcnt = i4 WITH protect, noconstant(0)
 DECLARE catalog_type_cardiovascul = f8 WITH constant(uar_get_code_by("MEANING",6000,"CARDIOVASCUL")),
 protected
 DECLARE order_action_statuschange = f8 WITH constant(uar_get_code_by("MEANING",6003,"STATUSCHANGE")),
 protected
 DECLARE order_action_complete = f8 WITH constant(uar_get_code_by("MEANING",6003,"COMPLETE")),
 protected
 DECLARE order_action_cancel = f8 WITH constant(uar_get_code_by("MEANING",6003,"CANCEL")), protected
 DECLARE order_action_discontinue = f8 WITH constant(uar_get_code_by("MEANING",6003,"DISCONTINUE")),
 protected
 DECLARE order_status_ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")),
 protected
 DECLARE order_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS")),
 protected
 DECLARE order_status_completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")),
 protected
 DECLARE order_status_canceled = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED")),
 protected
 DECLARE order_status_discontinued = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED")),
 protected
 DECLARE order_status_transfercanceled = f8 WITH constant(uar_get_code_by("MEANING",6004,
   "TRANS/CANCEL")), protected
 DECLARE order_status_deleted = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED")),
 protected
 DECLARE order_status_voidedwrslt = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT")),
 protected
 DECLARE order_status_suspended = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED")),
 protected
 DECLARE order_status_incomplete = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE")),
 protected
 DECLARE order_status_future = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE")), protected
 DECLARE dept_status_ordered = f8 WITH constant(uar_get_code_by("MEANING",14281,"ORDERED")),
 protected
 DECLARE dept_status_scheduled = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVSCHEDULED")),
 protected
 DECLARE dept_status_arrived = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVARRIVED")),
 protected
 DECLARE dept_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVINPROCESS")),
 protected
 DECLARE dept_status_completed = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVCOMPLETED")),
 protected
 DECLARE dept_status_verified = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVVERIFIED")),
 protected
 DECLARE dept_status_unsigned = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVUNSIGNED")),
 protected
 DECLARE dept_status_signed = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVSIGNED")),
 protected
 DECLARE dept_status_canceled = f8 WITH constant(uar_get_code_by("MEANING",14281,"CANCELED")),
 protected
 DECLARE dept_status_discontinued = f8 WITH constant(uar_get_code_by("MEANING",14281,"DISCONTINUED")),
 protected
 DECLARE dept_status_edreview = f8 WITH constant(uar_get_code_by("MEANING",14281,"CVEDREVIEW")),
 protected
 DECLARE proc_status_meaning_ordered = vc WITH constant("ORDERED"), protected
 DECLARE proc_status_meaning_scheduled = vc WITH constant("SCHEDULED"), protected
 DECLARE proc_status_meaning_arrived = vc WITH constant("ARRIVED"), protected
 DECLARE proc_status_meaning_inprocess = vc WITH constant("INPROCESS"), protected
 DECLARE proc_status_meaning_completed = vc WITH constant("COMPLETED"), protected
 DECLARE proc_status_meaning_verified = vc WITH constant("VERIFIED"), protected
 DECLARE proc_status_meaning_signed = vc WITH constant("SIGNED"), protected
 DECLARE proc_status_meaning_cancelled = vc WITH constant("CANCELLED"), protected
 DECLARE proc_status_meaning_discontinued = vc WITH constant("DISCONTINUED"), protected
 DECLARE proc_status_meaning_unsigned = vc WITH constant("UNSIGNED"), protected
 DECLARE proc_status_meaning_edreview = vc WITH constant("EDREVIEW"), protected
 DECLARE actiontypecd = f8
 DECLARE orderid = f8
 DECLARE order_idx = i4 WITH noconstant(0)
 DECLARE order_cnt = i4 WITH noconstant(size(request->orders,5))
 DECLARE srvstat = i4 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE order_action_id = f8 WITH protect, noconstant(0)
 DECLARE cv_login_id = f8 WITH noconstant(0.0)
 DECLARE external_perf_provider_id = f8 WITH noconstant(0.0)
 FREE RECORD order_list
 RECORD order_list(
   1 orders[*]
     2 order_status_cd = f8
     2 dept_status_cd = f8
     2 order_action_cd = f8
     2 oe_format_id = f8
     2 bill_only_ind = i2
     2 proc_status_cd = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 encntr_id = f8
     2 communication_type_cd = f8
     2 order_dt_tm = dq8
 )
 SET stat = alterlist(order_list->orders,order_cnt)
 FOR (order_idx = 1 TO order_cnt)
   SET order_list->orders[order_idx].proc_status_cd = request->orders[order_idx].proc_status_cd
   SET order_list->orders[order_idx].order_id = request->orders[order_idx].order_id
   SET order_list->orders[order_idx].catalog_cd = request->orders[order_idx].catalog_cd
   SET order_list->orders[order_idx].encntr_id = request->orders[order_idx].encntr_id
   SET order_list->orders[order_idx].communication_type_cd = request->orders[order_idx].
   communication_type_cd
   SET order_list->orders[order_idx].order_dt_tm = request->orders[order_idx].order_dt_tm
   IF ((request->orders[order_idx].encntr_id=0))
    CALL cv_log_msg(cv_info,build("Order status will not be updated for order id:",request->orders[
      order_idx].order_id,"as the encounter id is zero"))
    SET reply->status_data.status = "S"
    GO TO exit_script
   ELSE
    CASE (uar_get_code_meaning(request->orders[order_idx].proc_status_cd))
     OF proc_status_meaning_ordered:
      SET order_list->orders[order_idx].order_status_cd = order_status_ordered
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_ordered
     OF proc_status_meaning_scheduled:
      SET order_list->orders[order_idx].order_status_cd = order_status_ordered
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_scheduled
     OF proc_status_meaning_arrived:
      SET order_list->orders[order_idx].order_status_cd = order_status_ordered
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_arrived
     OF proc_status_meaning_inprocess:
      SET order_list->orders[order_idx].order_status_cd = order_status_inprocess
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_inprocess
     OF proc_status_meaning_completed:
      SET order_list->orders[order_idx].order_status_cd = order_status_inprocess
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_completed
     OF proc_status_meaning_verified:
      SET order_list->orders[order_idx].order_status_cd = order_status_inprocess
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_verified
     OF proc_status_meaning_signed:
      SET order_list->orders[order_idx].order_status_cd = order_status_completed
      SET order_list->orders[order_idx].order_action_cd = order_action_complete
      SET order_list->orders[order_idx].dept_status_cd = dept_status_signed
     OF proc_status_meaning_cancelled:
      SET order_list->orders[order_idx].order_status_cd = order_status_canceled
      SET order_list->orders[order_idx].order_action_cd = order_action_cancel
      SET order_list->orders[order_idx].dept_status_cd = dept_status_canceled
     OF proc_status_meaning_discontinued:
      SET order_list->orders[order_idx].order_status_cd = order_status_discontinued
      SET order_list->orders[order_idx].order_action_cd = order_action_discontinue
      SET order_list->orders[order_idx].dept_status_cd = dept_status_discontinued
     OF proc_status_meaning_unsigned:
      SET order_list->orders[order_idx].order_status_cd = order_status_inprocess
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_unsigned
     OF proc_status_meaning_edreview:
      SET order_list->orders[order_idx].order_status_cd = order_status_inprocess
      SET order_list->orders[order_idx].order_action_cd = order_action_statuschange
      SET order_list->orders[order_idx].dept_status_cd = dept_status_edreview
     ELSE
      CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST",build("PROC_STATUS_CD=",request->orders[
        order_idx].proc_status_cd))
      SET reply->status_data.status = "F"
      GO TO exit_script
    ENDCASE
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM order_action o
  WHERE (o.order_action_id=
  (SELECT
   max(o.order_action_id)
   FROM order_action o
   WHERE expand(order_idx,1,order_cnt,o.order_id,order_list->orders[order_idx].order_id)
   GROUP BY o.order_id))
  DETAIL
   order_action_id = o.order_action_id, lastupdtcnt = o.action_sequence
  WITH nocounter
 ;end select
 SET orderinfo->timezone_index = request->order_action_tz
 SET orderinfo->orderaction_id = order_action_id
 SET orderinfo->order_id = order_list->orders[order_idx].order_id
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE expand(order_idx,1,order_cnt,oc.catalog_cd,order_list->orders[order_idx].catalog_cd)
  DETAIL
   order_idx = locateval(order_idx,1,order_cnt,oc.catalog_cd,order_list->orders[order_idx].catalog_cd
    )
   WHILE (order_idx > 0)
    order_list->orders[order_idx].bill_only_ind = oc.bill_only_ind,order_idx = locateval(order_idx,(
     order_idx+ 1),order_cnt,oc.catalog_cd,order_list->orders[order_idx].catalog_cd)
   ENDWHILE
  WITH nocounter
 ;end select
 CALL echorecord(order_list)
 SET iret = uar_crmbeginapp(applicationid,happ)
 IF (iret != 0)
  CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMBEGINAPP",cnvtstring(iret))
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbegintask(happ,taskid,htask)
 IF (iret != 0)
  CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMBEGINTASK",cnvtstring(iret))
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
 IF (iret != 0)
  CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMBEGINREQ",cnvtstring(iret))
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 CALL cv_log_msg(cv_info,build("hReq:",hreq))
 SET srvstat = uar_srvsetshort(hreq,"commitGroupInd",0)
 SET srvstat = uar_srvsetdouble(hreq,"personId",request->person_id)
 SET srvstat = uar_srvsetdouble(hreq,"encntrId",order_list->orders[1].encntr_id)
 FOR (order_idx = 1 TO order_cnt)
   SET horder = uar_srvadditem(hreq,"orderList")
   SET srvstat = uar_srvsetdouble(horder,"orderId",order_list->orders[order_idx].order_id)
   SET srvstat = uar_srvsetdouble(horder,"actionTypeCd",order_list->orders[order_idx].order_action_cd
    )
   SET srvstat = uar_srvsetdouble(horder,"catalogTypeCd",catalog_type_cardiovascul)
   SET srvstat = uar_srvsetdouble(horder,"orderStatusCd",order_list->orders[order_idx].
    order_status_cd)
   SET srvstat = uar_srvsetdouble(horder,"encntrId",order_list->orders[order_idx].encntr_id)
   SET srvstat = uar_srvsetdouble(horder,"communicationTypeCd",order_list->orders[order_idx].
    communication_type_cd)
   SET srvstat = uar_srvsetdate(horder,"orderDtTm",order_list->orders[order_idx].order_dt_tm)
   SET srvstat = uar_srvsetdouble(horder,"oeFormatId",order_list->orders[order_idx].oe_format_id)
   SET srvstat = uar_srvsetshort(horder,"billOnlyInd",order_list->orders[order_idx].bill_only_ind)
   SET srvstat = uar_srvsetdouble(horder,"deptStatusCd",order_list->orders[order_idx].dept_status_cd)
   SET srvstat = uar_srvsetint(horder,"lastUpdtCnt",(lastupdtcnt - 1))
   SET hmisclistitem = uar_srvadditem(horder,"miscList")
   SET srvstat = uar_srvsetdouble(hmisclistitem,"FieldMeaningId",137.0)
   SET srvstat = uar_srvsetstring(hmisclistitem,"FieldMeaning","OVERRIDESHARE")
   SET srvstat = uar_srvsetdouble(hmisclistitem,"FieldValue",1.0)
 ENDFOR
 IF (validate(g_cv_login_id)
  AND validate(g_external_perf_provider_id))
  SET cv_login_id = g_cv_login_id
  SET external_perf_provider_id = g_external_perf_provider_id
 ENDIF
 IF (cv_login_id=0.0
  AND external_perf_provider_id > 0.0)
  SET srvstat = uar_srvsetdouble(hreq,"actionPersonnelId",external_perf_provider_id)
 ELSE
  SET srvstat = uar_srvsetdouble(hreq,"actionPersonnelId",reqinfo->updt_id)
 ENDIF
 SET timezone_name = datetimezonebyindex(request->order_action_tz)
 CALL uar_crmsetproperty(hstep,"timezone",timezone_name)
 SET iret = uar_crmperform(hstep)
 CALL cv_log_msg(cv_info,build("uar_CrmPerform returned:",iret))
 SET hrep = uar_crmgetreply(hstep)
 CALL cv_log_msg(cv_info,build("hRep:",hrep))
 SET hstatus = uar_srvgetstruct(hrep,"status_data")
 SET reply->status_data.status = uar_srvgetstringptr(hstatus,"status")
 IF (hstep)
  CALL uar_crmendreq(hstep)
  SET hstep = 0
 ENDIF
 IF (htask)
  CALL uar_crmendtask(htask)
  SET htask = 0
 ENDIF
 IF (happ)
  CALL uar_crmendapp(happ)
  SET happ = 0
 ENDIF
 IF ((request->order_action_tz != 0))
  UPDATE  FROM order_action o
   SET o.action_tz = request->order_action_tz, o.effective_tz = request->order_action_tz, o.order_tz
     = request->order_action_tz
   WHERE (o.order_action_id=orderinfo->orderaction_id)
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reqinfo->commit_ind = 0
  CALL cv_log_msg(cv_warning,"CV_UPD_ORDER_STATUS exiting without success")
  CALL echorecord(request)
  CALL echorecord(reply)
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("012 04/08/24 AS043139")
END GO
