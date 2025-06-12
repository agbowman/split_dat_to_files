CREATE PROGRAM dcp_forward_notifications
 SET modify = predeclare
 CALL echo("<------------------------------------->")
 CALL echo("<---   BEGIN: DCP_FORWARD_NOTIFICAITONS   --->")
 CALL echo("<------------------------------------->")
 DECLARE dqtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(dqtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 RECORD notificationstoforward(
   1 notifications[*]
     2 from_prsnl_group_id = f8
     2 from_prsnl_id = f8
     2 notification_comment = vc
     2 notification_created_dt_tm = dq8
     2 notification_created_tz = i4
     2 notification_resolved_dt_tm = dq8
     2 notification_resolved_tz = i4
     2 notification_status_flag = i2
     2 notification_type_flag = i2
     2 parent_pathway_notification_id = f8
     2 pathway_id = f8
     2 pathway_notification_id = f8
     2 pw_action_seq = i4
     2 to_prsnl_group_id = f8
     2 to_prsnl_id = f8
     2 forwarding_prsnl_id = f8
     2 forwarding_prsnl_group_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE slastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE smoddate = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE s_script_name = vc WITH protect, constant("DCP_FORWARD_NOTIFICATIONS")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE request_count = i4 WITH protect, constant(value(size(request->notifications,5)))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE notificationslistcount = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE protocolreview = i4 WITH protect, constant(1)
 DECLARE pendingstatus = i4 WITH protect, constant(1)
 DECLARE forwardedstatus = i4 WITH protect, constant(4)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  pn.from_prsnl_group_id, pn.from_prsnl_id, pn.notification_resolved_dt_tm,
  pn.notification_resolved_tz, pn.notification_status_flag, pn.notification_type_flag,
  pn.parent_pathway_notification_id, pn.pathway_id, pn.pathway_notification_id,
  pn.pw_action_seq
  FROM pathway_notification pn
  WHERE expand(num,1,request_count,pn.pathway_notification_id,request->notifications[num].
   pathway_notification_id)
  HEAD REPORT
   notificationslistcount = 0
  DETAIL
   notificationslistcount = (notificationslistcount+ 1)
   IF (mod(notificationslistcount,10)=1)
    stat = alterlist(notificationstoforward->notifications,(notificationslistcount+ 10))
   ENDIF
   idx = locateval(idx,1,request_count,pn.pathway_notification_id,request->notifications[idx].
    pathway_notification_id)
   IF (idx > 0)
    notificationstoforward->notifications[notificationslistcount].from_prsnl_group_id = pn
    .from_prsnl_group_id, notificationstoforward->notifications[notificationslistcount].from_prsnl_id
     = pn.from_prsnl_id, notificationstoforward->notifications[notificationslistcount].
    notification_comment = trim(request->notifications[idx].forwarding_comment),
    notificationstoforward->notifications[notificationslistcount].notification_resolved_dt_tm = pn
    .notification_resolved_dt_tm, notificationstoforward->notifications[notificationslistcount].
    notification_resolved_tz = pn.notification_resolved_tz, notificationstoforward->notifications[
    notificationslistcount].notification_status_flag = pendingstatus,
    notificationstoforward->notifications[notificationslistcount].notification_type_flag =
    protocolreview, notificationstoforward->notifications[notificationslistcount].
    parent_pathway_notification_id = pn.pathway_notification_id, notificationstoforward->
    notifications[notificationslistcount].pathway_id = pn.pathway_id,
    notificationstoforward->notifications[notificationslistcount].pw_action_seq = pn.pw_action_seq,
    notificationstoforward->notifications[notificationslistcount].to_prsnl_group_id = request->
    notifications[idx].to_prsnl_group_id, notificationstoforward->notifications[
    notificationslistcount].to_prsnl_id = request->notifications[idx].to_prsnl_id,
    notificationstoforward->notifications[notificationslistcount].forwarding_prsnl_id = request->
    notifications[idx].forwarding_prsnl_id, notificationstoforward->notifications[
    notificationslistcount].forwarding_prsnl_group_id = request->notifications[idx].
    forwarding_prsnl_group_id
   ENDIF
  FOOT REPORT
   stat = alterlist(notificationstoforward->notifications,notificationslistcount)
  WITH nocounter, forupdate(pn)
 ;end select
 IF (curqual < 1)
  CALL report_failure("SELECT","F",s_script_name,"No notifications found to forward.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  next_seq_nbr = seq(carenet_seq,nextval)
  FROM dual d,
   (dummyt dt  WITH seq = value(notificationslistcount))
  PLAN (d)
   JOIN (dt
   WHERE dt.seq > 0)
  DETAIL
   notificationstoforward->notifications[dt.seq].pathway_notification_id = cnvtreal(next_seq_nbr)
  WITH nocounter
 ;end select
 INSERT  FROM (dummyt d  WITH seq = value(notificationslistcount)),
   pathway_notification pn
  SET pn.from_prsnl_group_id = notificationstoforward->notifications[d.seq].from_prsnl_group_id, pn
   .from_prsnl_id = notificationstoforward->notifications[d.seq].from_prsnl_id, pn
   .notification_comment = trim(notificationstoforward->notifications[d.seq].notification_comment),
   pn.notification_created_dt_tm = cnvtdatetime(curdate,curtime3), pn.notification_created_tz =
   curtimezonesys, pn.notification_status_flag = pendingstatus,
   pn.notification_type_flag = protocolreview, pn.parent_pathway_notification_id =
   notificationstoforward->notifications[d.seq].parent_pathway_notification_id, pn
   .pathway_notification_id = notificationstoforward->notifications[d.seq].pathway_notification_id,
   pn.pathway_id = notificationstoforward->notifications[d.seq].pathway_id, pn.pw_action_seq =
   notificationstoforward->notifications[d.seq].pw_action_seq, pn.to_prsnl_id =
   notificationstoforward->notifications[d.seq].to_prsnl_id,
   pn.to_prsnl_group_id = notificationstoforward->notifications[d.seq].to_prsnl_group_id, pn
   .forwarding_prsnl_id = notificationstoforward->notifications[d.seq].forwarding_prsnl_id, pn
   .forwarding_prsnl_group_id = notificationstoforward->notifications[d.seq].
   forwarding_prsnl_group_id,
   pn.updt_applctx = reqinfo->updt_applctx, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn
   .updt_id = reqinfo->updt_id,
   pn.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (pn
   WHERE d.seq > 0)
  WITH nocounter
 ;end insert
 IF (curqual < 1)
  CALL report_failure("INSERT","F",s_script_name,"Error when inserting new notifications.")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(notificationslistcount)),
   pathway_notification pn
  SET pn.notification_resolved_dt_tm = cnvtdatetime(curdate,curtime3), pn.notification_resolved_tz =
   curtimezonesys, pn.notification_status_flag = forwardedstatus,
   pn.updt_applctx = reqinfo->updt_applctx, pn.updt_cnt = (pn.updt_cnt+ 1), pn.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (pn
   WHERE (pn.pathway_notification_id=notificationstoforward->notifications[d.seq].
   parent_pathway_notification_id))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  CALL report_failure("UPDATE","F",s_script_name,"Error when updating old notifications.")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     opname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (targetname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F",s_script_name,errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD notificationstoforward
 SET smoddate = "July 03, 2012"
 SET slastmod = "000"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),dqtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<---------------------------------->")
 CALL echo("<---   END DCP_FORWARD_NOTIFICAITONS   --->")
 CALL echo("<---------------------------------->")
END GO
