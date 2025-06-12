CREATE PROGRAM act_upd_entry_lease:dba
 RECORD reply(
   1 expiration = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 UPDATE  FROM object_space_entry e
  SET e.object_space_entry_expiration = request->object_space_entry_expiration
  PLAN (e
   WHERE (e.object_space_entry_id=request->object_space_entry_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  ROLLBACK
  SET reply->status_data.status = "Z"
 ELSE
  COMMIT
  SET reply->expiration = request->object_space_entry_expiration
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
