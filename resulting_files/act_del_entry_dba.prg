CREATE PROGRAM act_del_entry:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM object_space_entry e
  PLAN (e
   WHERE (e.object_space_entry_id=request->object_space_entry_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  ROLLBACK
  SET reply->status_data.status = "Z"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 DELETE  FROM long_blob b
  PLAN (b
   WHERE b.parent_entity_name="OBJECT_SPACE_ENTRY"
    AND (b.parent_entity_id=request->object_space_entry_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 CALL echorecord(reply)
END GO
