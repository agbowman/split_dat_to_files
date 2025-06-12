CREATE PROGRAM dwb_get_user:dba
 RECORD reply(
   1 person_id = f8
   1 name_full_formatted = vc
   1 email = vc
   1 name_first = vc
   1 name_first_key = vc
   1 name_last = vc
   1 name_last_key = vc
 )
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  p.person_id, p.name_full_formatted
  FROM prsnl p
  WHERE (p.username=request->username)
  DETAIL
   reply->person_id = p.person_id, reply->name_full_formatted = p.name_full_formatted, reply->
   person_id = p.person_id,
   reply->name_full_formatted = p.name_full_formatted, reply->email = p.email, reply->name_first = p
   .name_first,
   reply->name_first_key = p.name_first_key, reply->name_last = p.name_last, reply->name_last_key = p
   .name_last_key
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
