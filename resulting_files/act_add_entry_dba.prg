CREATE PROGRAM act_add_entry:dba
 RECORD reply(
   1 object_space_entry_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET entryid = 0.0
 SET blobid = 0.0
 SELECT INTO "nl:"
  FROM object_space_entry o
  PLAN (o
   WHERE (o.object_entry_name=request->object_entry_name)
    AND (o.object_space_id=request->object_space_id))
  DETAIL
   entryid = o.object_space_entry_id
  WITH nocounter
 ;end select
 IF (entryid > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->object_space_entry_id=0))
  SELECT INTO "nl:"
   y = seq(object_space_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    entryid = cnvtreal(y), reply->object_space_entry_id = entryid
   WITH format, nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSE
  SET entryid = request->object_space_entry_id
 ENDIF
 SELECT INTO "nl:"
  y = seq(long_data_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   blobid = cnvtreal(y)
  WITH format, nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 INSERT  FROM long_blob b
  SET b.parent_entity_id = entryid, b.parent_entity_name = "OBJECT_SPACE_ENTRY", b.long_blob_id =
   blobid,
   b.long_blob = request->long_blob
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 INSERT  FROM object_space_entry e
  SET e.object_space_entry_id = entryid, e.object_entry_name = request->object_entry_name, e
   .object_space_id = request->object_space_id,
   e.object_space_entry_expiration = request->object_space_entry_expiration, e.long_blob_id = blobid
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  ROLLBACK
  SET reply->status = "F"
 ELSE
  COMMIT
  SET reply->status = "S"
 ENDIF
END GO
