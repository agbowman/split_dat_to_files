CREATE PROGRAM bed_get_fn_events:dba
 FREE SET reply
 RECORD reply(
   1 tglist[*]
     2 tracking_group_code_value = f8
     2 reg_notify_ind = i2
     2 elist[*]
       3 track_event_id = f8
       3 active_ind = i2
       3 event_name = c20
       3 normal_icon = i4
       3 critical_ind = i2
       3 time_to_critical_secs = i4
       3 critical_color = c20
       3 critical_icon = i4
       3 overdue_ind = i2
       3 time_to_overdue_secs = i4
       3 overdue_color = c20
       3 overdue_icon = i4
       3 event_type_code_value = f8
       3 event_type_mean = c12
       3 auto_start_ind = i2
       3 plist[*]
         4 provider_display = c20
       3 auto_complete_ind = i2
       3 clist[*]
         4 track_event_id = f8
         4 event_name = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET prov_rel_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prov_rel_cd = cv.code_value
  WITH nocounter
 ;end select
 SET evt_trigger_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20320
   AND cv.cdf_meaning="EVT_TRIGGER"
  DETAIL
   evt_trigger_cd = cv.code_value
  WITH nocounter
 ;end select
 SET req_cnt = size(request->rlist,5)
 SET stat = alterlist(reply->tglist,req_cnt)
 IF (req_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = req_cnt),
    track_event te,
    code_value cv,
    track_reference tr
   PLAN (d)
    JOIN (te
    WHERE (te.tracking_group_cd=request->rlist[d.seq].tracking_group_code_value))
    JOIN (cv
    WHERE cv.code_value=outerjoin(te.tracking_event_type_cd)
     AND cv.active_ind=outerjoin(1))
    JOIN (tr
    WHERE tr.tracking_group_cd=outerjoin(request->rlist[d.seq].tracking_group_code_value)
     AND tr.assoc_code_value=outerjoin(te.track_event_id)
     AND tr.tracking_ref_type_cd=outerjoin(prov_rel_cd)
     AND tr.active_ind=outerjoin(1))
   ORDER BY d.seq, te.track_event_id, tr.tracking_ref_id
   HEAD d.seq
    reply->tglist[d.seq].tracking_group_code_value = request->rlist[d.seq].tracking_group_code_value,
    alterlist_ecnt = 0, ecnt = 0,
    stat = alterlist(reply->tglist[d.seq].elist,50)
   HEAD te.track_event_id
    ecnt = (ecnt+ 1), alterlist_ecnt = (alterlist_ecnt+ 1)
    IF (alterlist_ecnt > 50)
     stat = alterlist(reply->tglist[d.seq].elist,(ecnt+ 50)), alterlist_ecnt = 0
    ENDIF
    reply->tglist[d.seq].elist[ecnt].track_event_id = te.track_event_id, reply->tglist[d.seq].elist[
    ecnt].active_ind = te.active_ind, reply->tglist[d.seq].elist[ecnt].event_name = te.display,
    reply->tglist[d.seq].elist[ecnt].normal_icon = te.normal_icon, reply->tglist[d.seq].elist[ecnt].
    time_to_critical_secs = te.critical_interval, reply->tglist[d.seq].elist[ecnt].critical_color =
    te.critical_color,
    reply->tglist[d.seq].elist[ecnt].critical_icon = te.critical_icon, reply->tglist[d.seq].elist[
    ecnt].time_to_overdue_secs = te.overdue_interval, reply->tglist[d.seq].elist[ecnt].overdue_color
     = te.overdue_color,
    reply->tglist[d.seq].elist[ecnt].overdue_icon = te.overdue_icon, reply->tglist[d.seq].elist[ecnt]
    .auto_start_ind = te.auto_start_ind, reply->tglist[d.seq].elist[ecnt].auto_complete_ind = te
    .auto_complete_ind,
    reply->tglist[d.seq].elist[ecnt].event_type_code_value = te.tracking_event_type_cd, reply->
    tglist[d.seq].elist[ecnt].critical_ind = te.critical_blink_ind, reply->tglist[d.seq].elist[ecnt].
    overdue_ind = te.overdue_blink_ind
    IF (te.tracking_event_type_cd > 0)
     reply->tglist[d.seq].elist[ecnt].event_type_mean = cv.cdf_meaning
    ENDIF
    alterlist_pcnt = 0, pcnt = 0, stat = alterlist(reply->tglist[d.seq].elist[ecnt].plist,20)
   HEAD tr.tracking_ref_id
    IF (tr.tracking_ref_id > 0.0)
     pcnt = (pcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
     IF (alterlist_pcnt > 20)
      stat = alterlist(reply->tglist[d.seq].elist[ecnt].plist,(pcnt+ 20)), alterlist_pcnt = 0
     ENDIF
     reply->tglist[d.seq].elist[ecnt].plist[pcnt].provider_display = tr.display
    ENDIF
   FOOT  te.track_event_id
    stat = alterlist(reply->tglist[d.seq].elist[ecnt].plist,pcnt)
   FOOT  d.seq
    stat = alterlist(reply->tglist[d.seq].elist,ecnt)
   WITH nocounter
  ;end select
 ENDIF
 FOR (t = 1 TO req_cnt)
  SET event_cnt = size(reply->tglist[t].elist,5)
  IF (event_cnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = event_cnt),
     dummyt d1,
     track_event te1,
     track_collection_element tce,
     track_event te2,
     dummyt d2,
     track_event te3
    PLAN (d)
     JOIN (te1
     WHERE (te1.tracking_group_cd=reply->tglist[t].tracking_group_code_value)
      AND (te1.track_event_id=reply->tglist[t].elist[d.seq].track_event_id))
     JOIN (((d1)
     JOIN (tce
     WHERE tce.track_collection_id=te1.def_next_event_id
      AND tce.element_table="TRACK_EVENT")
     JOIN (te2
     WHERE (te2.tracking_group_cd=reply->tglist[t].tracking_group_code_value)
      AND te2.track_event_id=tce.element_value)
     ) ORJOIN ((d2)
     JOIN (te3
     WHERE (te3.tracking_group_cd=reply->tglist[t].tracking_group_code_value)
      AND te3.track_event_id=te1.def_next_event_id)
     ))
    ORDER BY d.seq, te2.track_event_id, te3.track_event_id
    HEAD d.seq
     alterlist_ccnt = 0, ccnt = 0, stat = alterlist(reply->tglist[t].elist[d.seq].clist,20)
    HEAD te2.track_event_id
     IF (te2.track_event_id > 0)
      ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
      IF (alterlist_ccnt > 20)
       stat = alterlist(reply->tglist[t].elist[d.seq].clist,(ccnt+ 20)), alterlist_ccnt = 0
      ENDIF
      reply->tglist[t].elist[d.seq].clist[ccnt].track_event_id = te2.track_event_id, reply->tglist[t]
      .elist[d.seq].clist[ccnt].event_name = te2.display
     ENDIF
    HEAD te3.track_event_id
     IF (te3.track_event_id > 0)
      ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
      IF (alterlist_ccnt > 20)
       stat = alterlist(reply->tglist[t].elist[d.seq].clist,(ccnt+ 20)), alterlist_ccnt = 0
      ENDIF
      reply->tglist[t].elist[d.seq].clist[ccnt].track_event_id = te3.track_event_id, reply->tglist[t]
      .elist[d.seq].clist[ccnt].event_name = te3.display
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->tglist[t].elist[d.seq].clist,ccnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
