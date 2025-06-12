CREATE PROGRAM dcp_add_pathway_notifications:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_add_pathway_notifications")
 DECLARE l_notification_count = i4 WITH protect, constant(value(size(request->notifications,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_notification_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The notification list was empty.")
  GO TO exit_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(l_notification_count)),
   pathway_notification pn
  SET pn.from_prsnl_group_id = request->notifications[d.seq].from_prsnl_group_id, pn.from_prsnl_id =
   request->notifications[d.seq].from_prsnl_id, pn.notification_comment = trim(request->
    notifications[d.seq].notification_comment),
   pn.notification_created_dt_tm = cnvtdatetime(request->notifications[d.seq].
    notification_created_dt_tm), pn.notification_created_tz = request->notifications[d.seq].
   notification_created_tz, pn.notification_resolved_dt_tm = cnvtdatetime(request->notifications[d
    .seq].notification_resolved_dt_tm),
   pn.notification_resolved_tz = request->notifications[d.seq].notification_resolved_tz, pn
   .notification_status_flag = request->notifications[d.seq].notification_status_flag, pn
   .notification_type_flag = request->notifications[d.seq].notification_type_flag,
   pn.parent_pathway_notification_id = request->notifications[d.seq].parent_pathway_notification_id,
   pn.pathway_id = request->notifications[d.seq].pathway_id, pn.pathway_notification_id = seq(
    carenet_seq,nextval),
   pn.pw_action_seq = request->notifications[d.seq].pw_action_seq, pn.to_prsnl_group_id = request->
   notifications[d.seq].to_prsnl_group_id, pn.to_prsnl_id = request->notifications[d.seq].to_prsnl_id,
   pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_id = reqinfo->updt_id, pn.updt_task =
   reqinfo->updt_task,
   pn.updt_cnt = 0, pn.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (pn)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F",s_script_name,
   "Failed to insert rows into the pathway_notification table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrcnt <= 50)
   SET lerrcnt = (lerrcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 SET last_mod = "001"
 SET mod_date = "July 20, 2011"
END GO
