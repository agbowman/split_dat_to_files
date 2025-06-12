CREATE PROGRAM dcp_get_pathway_notifications:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_get_pathway_notifications")
 DECLARE l_phase_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE notification_type_none = i2 WITH protect, constant(0)
 DECLARE notification_type_phase_protocol_review = i2 WITH protect, constant(1)
 DECLARE notification_status_none = i2 WITH protect, constant(0)
 DECLARE notification_status_pending = i2 WITH protect, constant(1)
 DECLARE notification_status_accepted = i2 WITH protect, constant(2)
 DECLARE notification_status_rejected = i2 WITH protect, constant(3)
 DECLARE notification_status_forwarded = i2 WITH protect, constant(4)
 DECLARE notification_status_no_longer_needed = i2 WITH protect, constant(5)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
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
 IF (l_phase_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The phase list was empty.")
  GO TO exit_script
 ENDIF
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_phase_count)/ cnvtreal(
     l_batch_size)))))
 DECLARE l_max_phase_count = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 SET stat = alterlist(request->phases,l_max_phase_count)
 FOR (idx = (l_phase_count+ 1) TO l_max_phase_count)
   SET request->phases[idx].pathway_id = request->phases[l_phase_count].pathway_id
 ENDFOR
 SELECT INTO "nl:"
  pn.pathway_id, pn.notification_type_flag, pn.notification_status_flag
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway_notification pn
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pn
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pn.pathway_id,request->phases[idx].pathway_id
    ))
  ORDER BY pn.pathway_id, pn.notification_type_flag, pn.notification_status_flag
  HEAD REPORT
   idx = 0, baddnotification = 0, lnotificationtypeidx = 0,
   lnotificationtypecount = 0, lnotificationstatusidx = 0, lnotificationstatuscount = 0,
   lnotificationcount = 0, lnotificationsize = 0
  HEAD pn.pathway_id
   idx = locateval(idx,1,l_phase_count,pn.pathway_id,request->phases[idx].pathway_id),
   CALL echo(concat("idx = ",build(idx)))
  HEAD pn.notification_type_flag
   lnotificationtypeidx = 0, lnotificationtypecount = 0
   IF (idx > 0)
    lnotificationtypecount = size(request->phases[idx].notification_types,5)
    IF (lnotificationtypecount > 0)
     lnotificationtypeidx = locateval(lnotificationtypeidx,1,lnotificationtypecount,pn
      .notification_type_flag,request->phases[idx].notification_types[lnotificationtypeidx].
      notification_type_flag)
    ELSE
     baddnotification = 1
    ENDIF
   ENDIF
   CALL echo(concat("lNotificationTypeIdx = ",build(lnotificationtypeidx)))
  HEAD pn.notification_status_flag
   baddnotification = 0, lnotificationstatusidx = 0, lnotificationstatuscount = 0
   IF (lnotificationtypeidx > 0)
    lnotificationstatuscount = size(request->phases[idx].notification_types[lnotificationtypeidx].
     notification_statuses,5)
    IF (lnotificationstatuscount > 0)
     lnotificationstatusidx = locateval(lnotificationstatusidx,1,lnotificationstatuscount,pn
      .notification_status_flag,request->phases[idx].notification_types[lnotificationtypeidx].
      notification_statuses[lnotificationstatusidx].notification_status_flag)
     IF (lnotificationstatusidx > 0)
      baddnotification = 1
     ELSE
      baddnotification = 0
     ENDIF
    ELSE
     baddnotification = 1
    ENDIF
   ENDIF
   CALL echo(concat("lNotificationStatusIdx = ",build(lnotificationstatusidx)))
  DETAIL
   IF (baddnotification=1)
    lnotificationcount = (lnotificationcount+ 1)
    IF (lnotificationsize < lnotificationcount)
     lnotificationsize = (lnotificationsize+ 20), stat = alterlist(reply->notifications,
      lnotificationsize)
    ENDIF
    reply->notifications[lnotificationcount].from_prsnl_group_id = pn.from_prsnl_group_id, reply->
    notifications[lnotificationcount].from_prsnl_id = pn.from_prsnl_id, reply->notifications[
    lnotificationcount].notification_comment = trim(pn.notification_comment),
    reply->notifications[lnotificationcount].notification_created_dt_tm = cnvtdatetime(pn
     .notification_created_dt_tm), reply->notifications[lnotificationcount].notification_created_tz
     = pn.notification_created_tz, reply->notifications[lnotificationcount].
    notification_resolved_dt_tm = cnvtdatetime(pn.notification_resolved_dt_tm),
    reply->notifications[lnotificationcount].notification_resolved_tz = pn.notification_resolved_tz,
    reply->notifications[lnotificationcount].notification_status_flag = pn.notification_status_flag,
    reply->notifications[lnotificationcount].notification_type_flag = pn.notification_type_flag,
    reply->notifications[lnotificationcount].parent_pathway_notification_id = pn
    .parent_pathway_notification_id, reply->notifications[lnotificationcount].pathway_id = pn
    .pathway_id, reply->notifications[lnotificationcount].pathway_notification_id = pn
    .pathway_notification_id,
    reply->notifications[lnotificationcount].pw_action_seq = pn.pw_action_seq, reply->notifications[
    lnotificationcount].to_prsnl_group_id = pn.to_prsnl_group_id, reply->notifications[
    lnotificationcount].to_prsnl_id = pn.to_prsnl_id,
    reply->notifications[lnotificationcount].updt_cnt = pn.updt_cnt
   ENDIF
  FOOT REPORT
   IF (lnotificationcount > 0)
    IF (lnotificationcount < lnotificationsize)
     stat = alterlist(reply->notifications,lnotificationcount)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (lnotificationcount <= 0)
  CALL set_script_status("Z","SELECT","Z",s_script_name,"No data qualified from PATHWAY_NOTIFICATION"
   )
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
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
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
