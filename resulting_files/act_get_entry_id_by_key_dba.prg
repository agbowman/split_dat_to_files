CREATE PROGRAM act_get_entry_id_by_key:dba
 RECORD reply(
   1 object_space_entry_id = f8
   1 object_space_id = f8
   1 long_blob_id = f8
   1 object_space_expiration = f8
   1 object_space_entry_expiration = f8
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
  e.object_space_entry_id, s.object_space_id, e.long_blob_id,
  s.object_space_expiration, e.object_space_entry_expiration
  FROM object_space s,
   object_space_entry e
  PLAN (s
   WHERE (s.object_space_id=request->object_space_id)
    AND (s.object_space_expiration > request->expiration))
   JOIN (e
   WHERE e.object_space_id=s.object_space_id
    AND (e.object_entry_name=request->object_entry_name)
    AND (e.object_space_entry_expiration > request->expiration))
  DETAIL
   cnt = (cnt+ 1), reply->object_space_entry_id = e.object_space_entry_id, reply->object_space_id = s
   .object_space_id,
   reply->long_blob_id = e.long_blob_id, reply->object_space_expiration = s.object_space_expiration,
   reply->object_space_entry_expiration = e.object_space_entry_expiration
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
