CREATE PROGRAM bed_get_fn_event_loc:dba
 FREE SET reply
 RECORD reply(
   1 elist[*]
     2 track_event_id = f8
     2 display = vc
     2 loc_ind = i2
     2 event_type_code_value = f8
     2 event_type_mean = vc
     2 llist[*]
       3 display = vc
       3 code_value = f8
       3 rule = vc
       3 description = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET tot_loc_count = 0
 SET count = 0
 SET loc_count = 0
 SET stat = alterlist(reply->elist,50)
 SELECT INTO "NL:"
  FROM track_group tg,
   track_event te,
   code_value cv,
   location_group lg,
   code_value cv2
  PLAN (te
   WHERE (te.tracking_group_cd=request->trk_group_code_value)
    AND te.active_ind=1)
   JOIN (tg
   WHERE tg.tracking_group_cd=outerjoin(request->trk_group_code_value)
    AND tg.child_table=outerjoin("TRACK_EVENT")
    AND tg.child_value=outerjoin(te.track_event_id))
   JOIN (cv
   WHERE cv.active_ind=outerjoin(1)
    AND cv.code_value=outerjoin(tg.parent_value))
   JOIN (lg
   WHERE lg.active_ind=outerjoin(1)
    AND lg.child_loc_cd=outerjoin(cv.code_value))
   JOIN (cv2
   WHERE cv2.active_ind=outerjoin(1)
    AND cv2.code_value=outerjoin(lg.parent_loc_cd))
  ORDER BY te.display_key, cv2.display, cv.display
  HEAD te.display_key
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->elist,(tot_count+ 50)), count = 1
   ENDIF
   reply->elist[tot_count].display = te.display, reply->elist[tot_count].track_event_id = te
   .track_event_id, reply->elist[tot_count].event_type_code_value = te.tracking_event_type_cd,
   reply->elist[tot_count].loc_ind = 0, loc_count = 0, tot_loc_count = 0
   IF ((request->load.locations > 0))
    stat = alterlist(reply->elist[tot_count].llist,20)
   ENDIF
  HEAD cv.code_value
   IF (tg.child_value > 0)
    reply->elist[tot_count].loc_ind = 1
    IF ((request->load.locations > 0))
     loc_count = (loc_count+ 1), tot_loc_count = (tot_loc_count+ 1)
     IF (loc_count > 20)
      stat = alterlist(reply->elist[tot_count].llist,(tot_loc_count+ 20)), loc_count = 1
     ENDIF
     reply->elist[tot_count].llist[tot_loc_count].display = concat(trim(cv2.display)," - ",trim(cv
       .display)), reply->elist[tot_count].llist[tot_loc_count].description = cv.description, reply->
     elist[tot_count].llist[tot_loc_count].mean = cv.cdf_meaning,
     reply->elist[tot_count].llist[tot_loc_count].code_value = tg.parent_value, reply->elist[
     tot_count].llist[tot_loc_count].rule = tg.tracking_rule
    ENDIF
   ENDIF
  FOOT  te.display_key
   IF ((request->load.locations > 0))
    stat = alterlist(reply->elist[tot_count].llist,tot_loc_count)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->elist,tot_count)
 IF (tot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->elist[d.seq].event_type_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->elist[d.seq].event_type_code_value))
   DETAIL
    reply->elist[d.seq].event_type_mean = cv.cdf_meaning
   WITH counter
  ;end select
 ENDIF
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
END GO
