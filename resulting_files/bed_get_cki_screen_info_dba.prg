CREATE PROGRAM bed_get_cki_screen_info:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 screen_display = vc
     2 screen_position = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM br_cki_screen_info b
  PLAN (b
   WHERE (b.data_type_id=request->data_type_id)
    AND (b.screen_type=request->screen_type))
  ORDER BY b.screen_position
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].screen_display = b
   .screen_display,
   reply->qual[cnt].screen_position = b.screen_position
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
