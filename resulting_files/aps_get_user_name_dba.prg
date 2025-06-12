CREATE PROGRAM aps_get_user_name:dba
 RECORD reply(
   1 full_name = vc
   1 user_id = f8
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
 SET prnsl_where = fillstring(500," ")
 IF (textlen(trim(request->username)) > 0)
  SET prsnl_where = build("p.username = ","'",trim(request->username),"'")
 ELSE
  SET prsnl_where = build("p.person_id = ",request->prsnl_id)
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, p.person_id
  FROM prsnl p
  PLAN (p
   WHERE parser(prsnl_where))
  DETAIL
   reply->full_name = trim(p.name_full_formatted), reply->user_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
