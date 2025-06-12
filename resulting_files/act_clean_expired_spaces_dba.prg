CREATE PROGRAM act_clean_expired_spaces:dba
 RECORD reply(
   1 space_ids[*]
     2 object_space_id = f8
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
 SET cnt = 0
 SET stat = alterlist(reply->space_ids,10)
 SELECT INTO "nl:"
  o.object_space_id
  FROM object_space o
  WHERE (o.object_space_expiration < request->time)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->space_ids,(cnt+ 9))
   ENDIF
   reply->space_ids[cnt].object_space_id = o.object_space_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->space_ids,cnt)
 SET space_cnt = cnt
 CALL echo(space_cnt)
 IF (cnt=0)
  GO TO exit_program
 ENDIF
 SET cnt2 = 0
 SET stat = alterlist(reply->entry_ids,10)
 SELECT INTO "nl:"
  o.object_space_entry_id, o.long_blob_id
  FROM object_space_entry o,
   (dummyt d  WITH seq = value(space_cnt))
  PLAN (d)
   JOIN (o
   WHERE (o.object_space_id=reply->space_ids[d.seq].object_space_id))
  DETAIL
   cnt2 = (cnt2+ 1)
   IF (mod(cnt2,10)=1
    AND cnt2 != 1)
    stat = alterlist(reply->entry_ids,(cnt2+ 9))
   ENDIF
   reply->entry_ids[cnt2].object_space_entry_id = o.object_space_entry_id, reply->entry_ids[cnt2].
   long_blob_id = o.long_blob_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->entry_ids,cnt2)
 IF (cnt2=0)
  GO TO exit_program
 ENDIF
 FOR (ctr = 1 TO cnt2)
  DELETE  FROM object_space_entry
   WHERE (object_space_entry_id=reply->entry_ids[ctr].object_space_entry_id)
   WITH nocounter
  ;end delete
  DELETE  FROM long_blob
   WHERE (long_blob_id=reply->entry_ids[ctr].long_blob_id)
   WITH nocounter
  ;end delete
 ENDFOR
 FOR (ctr = 1 TO space_cnt)
   DELETE  FROM object_space o
    WHERE (o.object_space_id=reply->space_ids[ctr].object_space_id)
    WITH nocounter
   ;end delete
 ENDFOR
#exit_program
 IF (space_cnt=0)
  SET reply->status_data.status = "Z"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
