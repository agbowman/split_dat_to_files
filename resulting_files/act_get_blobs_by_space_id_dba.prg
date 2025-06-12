CREATE PROGRAM act_get_blobs_by_space_id:dba
 RECORD reply(
   1 qual[*]
     2 long_blob = vgc
     2 object_entry_name = vc
     2 object_space_id = f8
     2 long_blob_id = f8
     2 object_space_entry_id = f8
     2 object_space_expiration = f8
     2 object_space_entry_expiration = f8
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
 DECLARE size1 = i4 WITH noconstant(0)
 DECLARE size2 = i4 WITH noconstant(0)
 SET size1 = 0
 SET size2 = 0
 SELECT INTO "nl:"
  e.object_entry_name, s.object_space_id, e.long_blob_id,
  e.object_space_entry_id, s.object_space_expiration, e.object_space_entry_expiration
  FROM object_space s,
   object_space_entry e
  PLAN (s
   WHERE (s.object_space_id=request->object_space_id)
    AND (s.object_space_expiration > request->expiration))
   JOIN (e
   WHERE e.object_space_id=s.object_space_id
    AND (e.object_space_entry_expiration > request->expiration))
  DETAIL
   size1 = (size1+ 1), stat = alterlist(reply->qual,size1), reply->qual[size1].object_entry_name = e
   .object_entry_name,
   reply->qual[size1].object_space_id = s.object_space_id, reply->qual[size1].long_blob_id = e
   .long_blob_id, reply->qual[size1].object_space_entry_id = e.object_space_entry_id,
   reply->qual[size1].object_space_expiration = s.object_space_expiration, reply->qual[size1].
   object_space_entry_expiration = e.object_space_entry_expiration
  WITH nocounter
 ;end select
 IF (size1=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 WHILE (size2 != size1)
  SET size2 = (size2+ 1)
  SELECT INTO "nl:"
   bloblen = textlen(b.long_blob)
   FROM long_blob b
   PLAN (b
    WHERE (b.long_blob_id=reply->qual[size2].long_blob_id))
   HEAD REPORT
    msg_buf = fillstring(32000," ")
   DETAIL
    offset = 0, retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(msg_buf,offset,b.long_blob)
      IF (retlen > 0)
       IF (retlen=size(msg_buf))
        reply->qual[size2].long_blob = notrim(concat(reply->qual[size2].long_blob,msg_buf))
       ELSE
        reply->qual[size2].long_blob = notrim(concat(reply->qual[size2].long_blob,substring(1,retlen,
           msg_buf)))
       ENDIF
      ENDIF
      offset = (offset+ retlen)
    ENDWHILE
   WITH nocounter, rdbarrayfetch = 1
  ;end select
 ENDWHILE
#exit_script
END GO
