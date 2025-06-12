CREATE PROGRAM bed_get_iview_working_views:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 working_view_id = f8
     2 current_working_view_id = f8
     2 display_name = vc
     2 active_ind = i2
     2 version_num = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 position_code_value = f8
     2 position_display = vc
     2 position_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM working_view w,
   code_value cv
  PLAN (w
   WHERE w.display_name != "**IO2GRESERVED**")
   JOIN (cv
   WHERE cv.code_value=w.position_cd
    AND cv.code_set=88)
  ORDER BY w.display_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->views,cnt), reply->views[cnt].working_view_id = w
   .working_view_id,
   reply->views[cnt].current_working_view_id = w.current_working_view, reply->views[cnt].display_name
    = w.display_name, reply->views[cnt].active_ind = w.active_ind,
   reply->views[cnt].version_num = w.version_num, reply->views[cnt].beg_effective_dt_tm = w
   .beg_effective_dt_tm, reply->views[cnt].end_effective_dt_tm = w.end_effective_dt_tm,
   reply->views[cnt].position_code_value = cv.code_value, reply->views[cnt].position_display = cv
   .display, reply->views[cnt].position_active_ind = cv.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
