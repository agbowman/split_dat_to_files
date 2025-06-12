CREATE PROGRAM dcp_get_correspondence_types:dba
 RECORD reply(
   1 user_id = f8
   1 position_cd = f8
   1 type_qual[*]
     2 correspondence_type_cd = f8
     2 correspondence_disp = vc
     2 correspondence_mean = vc
     2 correspondence_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->user_id = request->user_id
 SET reply->position_cd = request->position_cd
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  cv.code_value, cv.display, cv.cdf_meaning,
  cv.description
  FROM code_value cv
  WHERE cv.code_set=26514
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->type_qual,count1), reply->type_qual[count1].
   correspondence_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
#end_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
