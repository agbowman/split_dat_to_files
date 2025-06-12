CREATE PROGRAM act_get_space_names:dba
 RECORD reply(
   1 qual[*]
     2 object_space_name = vc
     2 object_space_expiration = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  s.object_space_name, s.object_space_expiration
  FROM object_space s
  WHERE (s.object_space_expiration > request->expiration)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].object_space_name = s
   .object_space_name,
   reply->qual[cnt].object_space_expiration = s.object_space_expiration
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
