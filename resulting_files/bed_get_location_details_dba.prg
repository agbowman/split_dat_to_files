CREATE PROGRAM bed_get_location_details:dba
 FREE SET reply
 RECORD reply(
   01 short_description = vc
   01 full_description = vc
   01 location_type_code_value = f8
   01 is_parent_ind = i2
   01 organization_id = f8
   01 org_name = vc
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
  FROM location l
  PLAN (l
   WHERE (l.location_cd=request->location_code_value))
  DETAIL
   reply->location_type_code_value = l.location_type_cd, reply->organization_id = l.organization_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.code_value=request->location_code_value))
  DETAIL
   reply->short_description = cv.display, reply->full_description = cv.description
  WITH nocounter
 ;end select
 SET reply->is_parent_ind = 0
 SELECT INTO "nl:"
  FROM location_group lg
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->location_code_value)
    AND lg.active_ind=1)
  DETAIL
   reply->is_parent_ind = 1
  WITH nocounter, maxqual(lg,1)
 ;end select
 IF ((reply->organization_id > 0))
  SELECT INTO "nl:"
   FROM organization o
   PLAN (o
    WHERE (o.organization_id=reply->organization_id))
   DETAIL
    reply->org_name = o.org_name
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
