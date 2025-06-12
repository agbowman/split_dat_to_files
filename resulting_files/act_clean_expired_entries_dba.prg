CREATE PROGRAM act_clean_expired_entries:dba
 RECORD reply(
   1 entry_ids[*]
     2 object_space_entry_id = f8
     2 long_blob_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i2 WITH noconstant(0)
 DECLARE ctr = i2 WITH noconstant(1)
 SET stat = alterlist(reply->entry_ids,10)
 SELECT INTO "nl:"
  os.object_space_entry_id, os.long_blob_id
  FROM object_space_entry os
  WHERE (os.object_space_entry_expiration < request->time)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->entry_ids,(cnt+ 9))
   ENDIF
   reply->entry_ids[cnt].object_space_entry_id = os.object_space_entry_id, reply->entry_ids[cnt].
   long_blob_id = os.long_blob_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->entry_ids,cnt)
 IF (cnt=0)
  GO TO exit_program
 ENDIF
 FOR (ctr = 1 TO cnt)
  DELETE  FROM object_space_entry
   WHERE (object_space_entry_id=reply->entry_ids[ctr].object_space_entry_id)
   WITH nocounter
  ;end delete
  DELETE  FROM long_blob
   WHERE (long_blob_id=reply->entry_ids[ctr].long_blob_id)
   WITH nocounter
  ;end delete
 ENDFOR
#exit_program
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
