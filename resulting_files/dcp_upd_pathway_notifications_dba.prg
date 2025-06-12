CREATE PROGRAM dcp_upd_pathway_notifications:dba
 SET modify = predeclare
 RECORD to_update(
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
     2 pathway_notification_id = f8
     2 pathway_id = f8
     2 pw_action_seq = i4
     2 to_prsnl_group_id = f8
     2 to_prsnl_id = f8
     2 updt_cnt = i4
 )
 DECLARE s_script_name = vc WITH protect, constant("dcp_upd_pathway_notifications")
 DECLARE l_notification_count = i4 WITH protect, constant(value(size(request->notifications,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE lfailurecount = i4 WITH protect, noconstant(0)
 DECLARE lnotificationcount = i4 WITH protect, noconstant(0)
 DECLARE lnotificationsize = i4 WITH protect, noconstant(0)
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
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_notification_count)/
    cnvtreal(l_batch_size)))))
 DECLARE l_max_notification_count = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 SET stat = alterlist(request->notifications,l_max_notification_count)
 FOR (idx = (l_notification_count+ 1) TO l_max_notification_count)
   SET request->notifications[idx].pathway_notification_id = request->notifications[
   l_notification_count].pathway_notification_id
 ENDFOR
 SELECT INTO "nl:"
  pn.pathway_notification_id
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway_notification pn
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pn
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pn.pathway_notification_id,request->
    notifications[idx].pathway_notification_id))
  HEAD REPORT
   idx = 0, lfailurecount = 0
  DETAIL
   idx = locateval(idx,1,l_notification_count,pn.pathway_notification_id,request->notifications[idx].
    pathway_notification_id)
   IF (idx > 0)
    IF ((pn.updt_cnt != request->notifications[idx].updt_cnt))
     lfailurecount = (lfailurecount+ 1),
     CALL set_script_status("F","SELECT","F",s_script_name,concat("Pathway notification (",
      "pathway_notification_id = ",build(pn.pathway_notification_id),",expected updt_cnt = ",build(
       request->notifications[idx].updt_cnt),
      ",actual updt_cnt = ",build(pn.updt_cnt),") has already been updated by another process"))
    ELSE
     lnotificationcount = (lnotificationcount+ 1)
     IF (lnotificationsize < lnotificationcount)
      lnotificationsize = (lnotificationsize+ 20), stat = alterlist(to_update->notifications,
       lnotificationsize)
     ENDIF
     to_update->notifications[lnotificationcount].from_prsnl_group_id = request->notifications[idx].
     from_prsnl_group_id, to_update->notifications[lnotificationcount].from_prsnl_id = request->
     notifications[idx].from_prsnl_id, to_update->notifications[lnotificationcount].
     notification_comment = trim(request->notifications[idx].notification_comment),
     to_update->notifications[lnotificationcount].notification_created_dt_tm = cnvtdatetime(request->
      notifications[idx].notification_created_dt_tm), to_update->notifications[lnotificationcount].
     notification_created_tz = request->notifications[idx].notification_created_tz, to_update->
     notifications[lnotificationcount].notification_resolved_dt_tm = cnvtdatetime(request->
      notifications[idx].notification_resolved_dt_tm),
     to_update->notifications[lnotificationcount].notification_resolved_tz = request->notifications[
     idx].notification_resolved_tz, to_update->notifications[lnotificationcount].
     notification_status_flag = request->notifications[idx].notification_status_flag, to_update->
     notifications[lnotificationcount].notification_type_flag = request->notifications[idx].
     notification_type_flag,
     to_update->notifications[lnotificationcount].parent_pathway_notification_id = request->
     notifications[idx].parent_pathway_notification_id, to_update->notifications[lnotificationcount].
     pathway_id = request->notifications[idx].pathway_id, to_update->notifications[lnotificationcount
     ].pathway_notification_id = request->notifications[idx].pathway_notification_id,
     to_update->notifications[lnotificationcount].pw_action_seq = request->notifications[idx].
     pw_action_seq, to_update->notifications[lnotificationcount].to_prsnl_group_id = request->
     notifications[idx].to_prsnl_group_id, to_update->notifications[lnotificationcount].to_prsnl_id
      = request->notifications[idx].to_prsnl_id,
     to_update->notifications[lnotificationcount].updt_cnt = request->notifications[idx].updt_cnt
    ENDIF
   ENDIF
  FOOT REPORT
   IF (lnotificationcount > 0)
    IF (lnotificationcount < lnotificationsize)
     stat = alterlist(to_update->notifications,lnotificationcount)
    ENDIF
   ENDIF
  WITH forupdate(pn), nocounter
 ;end select
 IF (curqual <= 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"Failed to lock rows on PATHWAY_NOTIFICATION"
   )
  GO TO exit_script
 ENDIF
 IF (lfailurecount > 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"Select from PATHWAY_NOTIFICATION failed")
  GO TO exit_script
 ENDIF
 IF (lnotificationcount <= 0)
  CALL set_script_status("Z","SELECT","Z",s_script_name,"Failed to lock rows on PATHWAY_NOTIFICATION"
   )
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(size(to_update->notifications,5))),
   pathway_notification pn
  SET pn.from_prsnl_group_id = to_update->notifications[d.seq].from_prsnl_group_id, pn.from_prsnl_id
    = to_update->notifications[d.seq].from_prsnl_id, pn.notification_comment = trim(to_update->
    notifications[d.seq].notification_comment),
   pn.notification_created_dt_tm = cnvtdatetime(to_update->notifications[d.seq].
    notification_created_dt_tm), pn.notification_created_tz = to_update->notifications[d.seq].
   notification_created_tz, pn.notification_resolved_dt_tm = cnvtdatetime(to_update->notifications[d
    .seq].notification_resolved_dt_tm),
   pn.notification_resolved_tz = to_update->notifications[d.seq].notification_resolved_tz, pn
   .notification_status_flag = to_update->notifications[d.seq].notification_status_flag, pn
   .notification_type_flag = to_update->notifications[d.seq].notification_type_flag,
   pn.parent_pathway_notification_id = to_update->notifications[d.seq].parent_pathway_notification_id,
   pn.pathway_id = to_update->notifications[d.seq].pathway_id, pn.pw_action_seq = to_update->
   notifications[d.seq].pw_action_seq,
   pn.to_prsnl_group_id = to_update->notifications[d.seq].to_prsnl_group_id, pn.to_prsnl_id =
   to_update->notifications[d.seq].to_prsnl_id, pn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_cnt = (pn.updt_cnt+ 1),
   pn.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (pn
   WHERE (pn.pathway_notification_id=to_update->notifications[d.seq].pathway_notification_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,
   "Failed to update rows on the pathway_notification table.")
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
 FREE RECORD to_update
 SET last_mod = "001"
 SET mod_date = "July 20, 2011"
END GO
