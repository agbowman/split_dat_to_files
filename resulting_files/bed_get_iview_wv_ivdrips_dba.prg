CREATE PROGRAM bed_get_iview_wv_ivdrips:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 working_view_id = f8
     2 name = vc
     2 section_display_name = vc
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
   working_view_section s
  PLAN (w
   WHERE w.active_ind=1)
   JOIN (s
   WHERE s.working_view_id=w.working_view_id
    AND s.section_type_flag=1)
  ORDER BY w.display_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->views,cnt), reply->views[cnt].working_view_id = w
   .working_view_id,
   reply->views[cnt].name = w.display_name, reply->views[cnt].section_display_name = s.display_name
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
