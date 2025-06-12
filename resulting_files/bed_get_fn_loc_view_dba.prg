CREATE PROGRAM bed_get_fn_loc_view:dba
 FREE SET reply
 RECORD reply(
   1 location_views[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 mean = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET tot_count = 0
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
    WHERE (tg.tracking_group_cd=request->trk_group_code_value)
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
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rooms->cnt)),
   location_group lg,
   code_value cv
  PLAN (d)
   JOIN (lg
   WHERE (lg.child_loc_cd=rooms->qual[d.seq].cd)
    AND lg.root_loc_cd > 0
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.root_loc_cd
    AND cv.cdf_meaning="PTTRACKROOT"
    AND cv.display_key != "SURGERY*"
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD REPORT
   stat = alterlist(reply->location_views,10)
  HEAD cv.display
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 10)
    stat = alterlist(reply->location_views,(tot_count+ 10))
   ENDIF
   reply->location_views[tot_count].code_value = cv.code_value, reply->location_views[tot_count].
   display = cv.display, reply->location_views[tot_count].description = cv.description
  FOOT REPORT
   stat = alterlist(reply->location_views,tot_count)
  WITH nocounter
 ;end select
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
