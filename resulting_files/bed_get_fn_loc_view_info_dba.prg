CREATE PROGRAM bed_get_fn_loc_view_info:dba
 FREE SET reply
 RECORD reply(
   1 rlist[*]
     2 room_code_value = f8
     2 room_display = vc
     2 room_description = vc
     2 room_meaning = vc
     2 viewlist[*]
       3 view_code_value = f8
       3 view_display = vc
       3 view_description = vc
       3 view_meaning = vc
     2 blist[*]
       3 bed_code_value = f8
       3 bed_display = vc
       3 bed_description = vc
       3 bed_meaning = vc
       3 vlist[*]
         4 view_code_value = f8
         4 view_display = vc
         4 view_description = vc
         4 view_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD loc(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 RECORD rooms(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 SET reply->status_data.status = "F"
 SET viewcnt = 0
 DECLARE track_group_cd = f8 WITH noconstant(0.0), protect
 DECLARE ed_loc_cd = f8 WITH noconstant(0.0), protect
 DECLARE ed_code_value = f8
 SET ed_code_value = 0.0
 IF (validate(request->location_code_value))
  SET ed_code_value = request->location_code_value
 ENDIF
 IF (ed_code_value > 0)
  SET loc->cnt = 1
  SET stat = alterlist(loc->qual,1)
  SET loc->qual[1].cd = ed_code_value
 ELSE
  SELECT INTO "nl:"
   FROM track_group tg
   PLAN (tg
    WHERE (tg.tracking_group_cd=request->track_group_code_value)
     AND tg.child_value=0
     AND tg.child_table="TRACK_ASSOC")
   ORDER BY tg.parent_value
   HEAD REPORT
    cnt = 0
   HEAD tg.parent_value
    cnt = (cnt+ 1), loc->cnt = cnt, stat = alterlist(loc->qual,cnt),
    loc->qual[cnt].cd = tg.parent_value
   WITH nocounter
  ;end select
 ENDIF
 SET rcnt = 0
 FOR (x = 1 TO loc->cnt)
  SELECT INTO "nl:"
   FROM location_group lg,
    code_value cv,
    location_group lg2
   PLAN (lg
    WHERE (lg.child_loc_cd=loc->qual[x].cd)
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.location_group_type_cd
     AND cv.cdf_meaning="BUILDING")
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg.child_loc_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
   ORDER BY lg2.sequence
   DETAIL
    rcnt = (rcnt+ 1), rooms->cnt = rcnt, stat = alterlist(rooms->qual,rcnt),
    rooms->qual[rcnt].cd = lg2.child_loc_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM location_group lg,
    location_group lg2,
    code_value cv
   PLAN (lg
    WHERE (lg.child_loc_cd=loc->qual[x].cd)
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg.parent_loc_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg2.location_group_type_cd
     AND cv.cdf_meaning="BUILDING")
   DETAIL
    rcnt = (rcnt+ 1), rooms->cnt = rcnt, stat = alterlist(rooms->qual,rcnt),
    rooms->qual[rcnt].cd = lg.child_loc_cd
   WITH nocounter
  ;end select
 ENDFOR
 IF ((rooms->cnt=0))
  GO TO exit_script
 ENDIF
 SET view_found = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rooms->cnt)),
   location_group lg,
   code_value cv,
   location_group lg2,
   location_group lg3,
   location_group lg4
  PLAN (d)
   JOIN (lg
   WHERE (lg.child_loc_cd=rooms->qual[d.seq].cd)
    AND lg.root_loc_cd > 0
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.root_loc_cd
    AND cv.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.root_loc_cd=lg.root_loc_cd
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE lg3.child_loc_cd=lg2.parent_loc_cd
    AND lg3.root_loc_cd=lg2.root_loc_cd
    AND lg3.active_ind=1)
   JOIN (lg4
   WHERE lg4.child_loc_cd=lg3.parent_loc_cd
    AND lg4.root_loc_cd=lg3.root_loc_cd
    AND lg4.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   view_found = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET track_group_cd = request->track_group_code_value
  SET ed_loc_cd = 0.0
  IF (validate(request->location_code_value))
   SET ed_loc_cd = request->location_code_value
  ENDIF
  EXECUTE bed_ens_fn_proposed_views
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rooms->cnt)),
   location_group lg,
   code_value cv,
   location_group lg2,
   code_value cv2
  PLAN (d)
   JOIN (lg
   WHERE (lg.child_loc_cd=rooms->qual[d.seq].cd)
    AND lg.root_loc_cd=0
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.child_loc_cd)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=outerjoin(lg.child_loc_cd)
    AND lg2.root_loc_cd=outerjoin(0)
    AND lg2.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(lg2.child_loc_cd))
  ORDER BY d.seq, lg.sequence
  HEAD REPORT
   roomcnt = 0, bedcnt = 0
  HEAD d.seq
   bedcnt = 0, roomcnt = (roomcnt+ 1), stat = alterlist(reply->rlist,roomcnt),
   reply->rlist[roomcnt].room_code_value = lg.child_loc_cd, reply->rlist[roomcnt].room_display = cv
   .display, reply->rlist[roomcnt].room_description = cv.description,
   reply->rlist[roomcnt].room_meaning = cv.cdf_meaning
  HEAD lg2.child_loc_cd
   IF (lg2.child_loc_cd > 0)
    bedcnt = (bedcnt+ 1), stat = alterlist(reply->rlist[roomcnt].blist,bedcnt), reply->rlist[roomcnt]
    .blist[bedcnt].bed_code_value = lg2.child_loc_cd,
    reply->rlist[roomcnt].blist[bedcnt].bed_display = cv2.display, reply->rlist[roomcnt].blist[bedcnt
    ].bed_description = cv2.description, reply->rlist[roomcnt].blist[bedcnt].bed_meaning = cv2
    .cdf_meaning
   ENDIF
  WITH nocounter
 ;end select
 SET roomcnt = size(reply->rlist,5)
 IF (roomcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->rlist,5))),
    location_group lg,
    code_value cv,
    location_group lg2,
    location_group lg3,
    location_group lg4
   PLAN (d)
    JOIN (lg
    WHERE (lg.child_loc_cd=reply->rlist[d.seq].room_code_value)
     AND lg.root_loc_cd > 0
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.root_loc_cd
     AND cv.active_ind=1)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg.parent_loc_cd
     AND lg2.root_loc_cd=lg.root_loc_cd
     AND lg2.active_ind=1)
    JOIN (lg3
    WHERE lg3.child_loc_cd=lg2.parent_loc_cd
     AND lg3.root_loc_cd=lg2.root_loc_cd
     AND lg3.active_ind=1)
    JOIN (lg4
    WHERE lg4.child_loc_cd=lg3.parent_loc_cd
     AND lg4.root_loc_cd=lg3.root_loc_cd
     AND lg4.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    viewcnt = 0
   DETAIL
    viewcnt = (viewcnt+ 1), stat = alterlist(reply->rlist[d.seq].viewlist,viewcnt), reply->rlist[d
    .seq].viewlist[viewcnt].view_code_value = cv.code_value,
    reply->rlist[d.seq].viewlist[viewcnt].view_display = cv.display, reply->rlist[d.seq].viewlist[
    viewcnt].view_description = cv.description, reply->rlist[d.seq].viewlist[viewcnt].view_meaning =
    cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO size(reply->rlist,5))
   IF (size(reply->rlist[x].blist,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->rlist[x].blist,5))),
      location_group lg,
      code_value cv,
      location_group lg2,
      location_group lg3,
      location_group lg4,
      location_group lg5
     PLAN (d)
      JOIN (lg
      WHERE (lg.child_loc_cd=reply->rlist[x].blist[d.seq].bed_code_value)
       AND lg.root_loc_cd > 0
       AND lg.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=lg.root_loc_cd
       AND cv.active_ind=1)
      JOIN (lg2
      WHERE lg2.child_loc_cd=lg.parent_loc_cd
       AND lg2.root_loc_cd=lg.root_loc_cd
       AND lg2.active_ind=1)
      JOIN (lg3
      WHERE lg3.child_loc_cd=lg2.parent_loc_cd
       AND lg3.root_loc_cd=lg2.root_loc_cd
       AND lg3.active_ind=1)
      JOIN (lg4
      WHERE lg4.child_loc_cd=lg3.parent_loc_cd
       AND lg4.root_loc_cd=lg3.root_loc_cd
       AND lg4.active_ind=1)
      JOIN (lg5
      WHERE lg5.child_loc_cd=lg4.parent_loc_cd
       AND lg5.root_loc_cd=lg4.root_loc_cd
       AND lg5.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      viewcnt = 0
     DETAIL
      viewcnt = (viewcnt+ 1), stat = alterlist(reply->rlist[x].blist[d.seq].vlist,viewcnt), reply->
      rlist[x].blist[d.seq].vlist[viewcnt].view_code_value = cv.code_value,
      reply->rlist[x].blist[d.seq].vlist[viewcnt].view_display = cv.display, reply->rlist[x].blist[d
      .seq].vlist[viewcnt].view_description = cv.description, reply->rlist[x].blist[d.seq].vlist[
      viewcnt].view_meaning = cv.cdf_meaning
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF (size(reply->rlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
