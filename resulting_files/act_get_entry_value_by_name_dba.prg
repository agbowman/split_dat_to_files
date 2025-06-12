CREATE PROGRAM act_get_entry_value_by_name:dba
 RECORD reply(
   1 long_blob = vgc
   1 object_space_entry_id = f8
   1 long_blob_id = f8
   1 object_space_name = vc
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
 DECLARE offset = i4 WITH noconstant(0)
 DECLARE retlen = i4 WITH noconstant(0)
 DECLARE bloblen = i4 WITH noconstant(0)
 SET cnt = 0
 SELECT INTO "nl:"
  e.object_space_entry_id, e.long_blob_id, s.object_space_name,
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
   cnt = (cnt+ 1), reply->object_space_entry_id = e.object_space_entry_id, reply->long_blob_id = e
   .long_blob_id,
   reply->object_space_name = s.object_space_name, reply->object_space_expiration = s
   .object_space_expiration, reply->object_space_entry_expiration = e.object_space_entry_expiration
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  bloblen = textlen(b.long_blob)
  FROM long_blob b
  PLAN (b
   WHERE (b.long_blob_id=reply->long_blob_id))
  HEAD REPORT
   msg_buf = fillstring(32767," ")
  DETAIL
   offset = 0, retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(msg_buf,offset,b.long_blob)
     IF (retlen > 0)
      IF (retlen=size(msg_buf))
       reply->long_blob = notrim(concat(reply->long_blob,msg_buf))
      ELSE
       reply->long_blob = notrim(concat(reply->long_blob,substring(1,retlen,msg_buf)))
      ENDIF
     ENDIF
     offset = (offset+ 32767)
   ENDWHILE
  WITH nocounter, rdbarrayfetch = 1
 ;end select
#exit_script
END GO
