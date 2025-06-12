CREATE PROGRAM afc_get_applications:dba
 DECLARE afc_get_applicaitons_version = vc
 SET afc_get_applications_version = "155358.FT.001"
 RECORD reply(
   1 qual[*]
     2 description = vc
     2 object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  a.object_name, a.description
  FROM application a
  WHERE a.application_number IN (951001, 951005, 951050, 952400)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].description = a.description,
   reply->qual[cnt].object_name = a.object_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
