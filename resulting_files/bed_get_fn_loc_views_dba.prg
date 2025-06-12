CREATE PROGRAM bed_get_fn_loc_views:dba
 FREE SET reply
 RECORD reply(
   1 viewlist[*]
     2 view_code_value = f8
     2 view_display = vc
     2 view_description = vc
     2 view_meaning = vc
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
 SELECT INTO "nl:"
  FROM track_group tg,
   location_group lg,
   code_value cv
  PLAN (tg
   WHERE (tg.tracking_group_cd=request->track_group_code_value)
    AND tg.child_value=0
    AND tg.child_table="TRACK_ASSOC")
   JOIN (lg
   WHERE lg.child_loc_cd=tg.parent_value
    AND lg.root_loc_cd > 0
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.root_loc_cd
    AND cv.cdf_meaning="PTTRACKROOT")
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  HEAD cv.display
   IF (cv.display_key != "SURG*")
    cnt = (cnt+ 1), stat = alterlist(reply->viewlist,cnt), reply->viewlist[cnt].view_code_value = cv
    .code_value,
    reply->viewlist[cnt].view_display = cv.display, reply->viewlist[cnt].view_description = cv
    .description, reply->viewlist[cnt].view_meaning = cv.cdf_meaning,
    reply->viewlist[cnt].active_ind = cv.active_ind
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->viewlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
