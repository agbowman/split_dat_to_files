CREATE PROGRAM act_del_space:dba
 RECORD reply(
   1 remove_count = i4
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
 SET spaceid = 0.0
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 long_blob_id = f8
     2 seq = i4
 )
 SELECT INTO "nl:"
  s.object_space_id
  FROM object_space s
  WHERE (s.object_space_name=request->object_space_name)
  DETAIL
   spaceid = s.object_space_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  e.long_blob_id
  FROM object_space_entry e
  WHERE e.object_space_id=spaceid
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
   long_blob_id = e.long_blob_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 DELETE  FROM object_space_entry e
  PLAN (e
   WHERE e.object_space_id=spaceid)
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 DELETE  FROM object_space s
  PLAN (s
   WHERE s.object_space_id=spaceid)
  WITH nocounter
 ;end delete
 SET reply->remove_count = curqual
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 DELETE  FROM long_blob b,
   (dummyt d  WITH seq = value(temp->cnt))
  SET b.seq = 1
  PLAN (d)
   JOIN (b
   WHERE (b.long_blob_id=temp->qual[d.seq].long_blob_id)
    AND b.long_blob_id > 0)
  WITH nocounter
 ;end delete
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
