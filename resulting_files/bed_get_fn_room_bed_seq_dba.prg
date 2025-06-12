CREATE PROGRAM bed_get_fn_room_bed_seq:dba
 FREE SET reply
 RECORD reply(
   1 unit_code_value = f8
   1 unit_display = vc
   1 unit_description = vc
   1 unit_meaning = vc
   1 rlist[*]
     2 room_code_value = f8
     2 room_display = vc
     2 room_description = vc
     2 room_meaning = vc
     2 room_sequence = i4
     2 blist[*]
       3 bed_code_value = f8
       3 bed_display = vc
       3 bed_description = vc
       3 bed_meaning = vc
       3 bed_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET unit_cd = 0.0
 DECLARE ed_code_value = f8
 SET ed_code_value = 0.0
 IF (validate(request->location_code_value))
  SET ed_code_value = request->location_code_value
 ENDIF
 IF (ed_code_value > 0)
  SET unit_cd = request->location_code_value
 ELSE
  SELECT INTO "nl:"
   FROM track_group tg
   PLAN (tg
    WHERE (tg.tracking_group_cd=request->track_group_code_value)
     AND tg.parent_value > 0
     AND tg.child_value=0
     AND tg.child_table="TRACK_ASSOC")
   ORDER BY tg.parent_value
   DETAIL
    unit_cd = tg.parent_value
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM location_group lg,
   code_value c,
   code_value cv,
   location_group lg2,
   code_value cv2
  PLAN (lg
   WHERE lg.parent_loc_cd=unit_cd
    AND (lg.root_loc_cd=request->view_code_value)
    AND lg.active_ind=1)
   JOIN (c
   WHERE c.code_value=lg.parent_loc_cd)
   JOIN (cv
   WHERE cv.code_value=lg.child_loc_cd)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=outerjoin(lg.child_loc_cd)
    AND lg2.root_loc_cd=outerjoin(request->view_code_value)
    AND lg2.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(lg2.child_loc_cd))
  ORDER BY lg.sequence, lg2.sequence
  HEAD REPORT
   rcnt = 0, bcnt = 0, reply->unit_code_value = c.code_value,
   reply->unit_display = c.display, reply->unit_description = c.description, reply->unit_meaning = c
   .cdf_meaning
  HEAD lg.child_loc_cd
   bcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt),
   reply->rlist[rcnt].room_code_value = lg.child_loc_cd, reply->rlist[rcnt].room_display = cv.display,
   reply->rlist[rcnt].room_description = cv.description,
   reply->rlist[rcnt].room_meaning = cv.cdf_meaning, reply->rlist[rcnt].room_sequence = lg.sequence
  HEAD lg2.child_loc_cd
   IF (lg2.child_loc_cd > 0)
    bcnt = (bcnt+ 1), stat = alterlist(reply->rlist[rcnt].blist,bcnt), reply->rlist[rcnt].blist[bcnt]
    .bed_code_value = lg2.child_loc_cd,
    reply->rlist[rcnt].blist[bcnt].bed_display = cv2.display, reply->rlist[rcnt].blist[bcnt].
    bed_description = cv2.description, reply->rlist[rcnt].blist[bcnt].bed_meaning = cv2.cdf_meaning,
    reply->rlist[rcnt].blist[bcnt].bed_sequence = lg2.sequence
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->rlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
