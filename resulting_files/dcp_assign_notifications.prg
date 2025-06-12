CREATE PROGRAM dcp_assign_notifications
 SET modify = predeclare
 CALL echo("<------------------------------------->")
 CALL echo("<---   BEGIN: DCP_ASSIGN_NOTIFICATIONS   --->")
 CALL echo("<------------------------------------->")
 DECLARE dqtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(dqtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 SET reply->status_data.status = "F"
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nstatus_unknown = i2 WITH private, constant(0)
 DECLARE nsuccess = i2 WITH private, constant(1)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(2)
 DECLARE nfailed_empty_request = i2 WITH private, constant(3)
 DECLARE nfailed_no_update = i2 WITH private, constant(4)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nstatus_unknown)
 DECLARE nstat = i2 WITH private, noconstant(0)
 DECLARE slastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE smoddate = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE request_count = i4 WITH protect, constant(value(size(request->notifications,5)))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE notificationslistcount = i4 WITH protect, noconstant(0)
 IF (request_count=0)
  SET nscriptstatus = nfailed_empty_request
  GO TO exit_script2
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(size(request->notifications,5))),
   pathway_notification pn
  SET pn.to_prsnl_id = request->notifications[d.seq].to_prsnl_id, pn.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), pn.updt_id = reqinfo->updt_id,
   pn.updt_task = reqinfo->updt_task, pn.updt_cnt = (pn.updt_cnt+ 1), pn.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (pn
   WHERE (pn.pathway_notification_id=request->notifications[d.seq].pathway_notification_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET nscriptstatus = nfailed_no_update
  GO TO exit_script2
 ENDIF
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET nstat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET nstat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
#exit_script2
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_ASSIGN_NOTIFICATIONS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
   OF nfailed_empty_request:
    SET reply->status_data.subeventstatus[1].operationname = "EMPTY REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_ASSIGN_NOTIFICATIONS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "The request was empty."
   OF nfailed_no_update:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_ASSIGN_NOTIFICATIONS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to update notifications."
  ENDCASE
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD errors
 SET smoddate = "July 03, 2012"
 SET slastmod = "000"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),dqtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<---------------------------------->")
 CALL echo("<---   END DCP_ASSIGN_NOTIFICATIONS   --->")
 CALL echo("<---------------------------------->")
END GO
