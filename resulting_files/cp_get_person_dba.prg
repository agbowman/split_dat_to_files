CREATE PROGRAM cp_get_person:dba
 RECORD reply(
   1 name_full_formatted = c100
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
  p.name_full_formatted
  FROM person p
  WHERE (p.person_id=request->person_id)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
