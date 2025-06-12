CREATE PROGRAM bed_del_cki_matched_items:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 IF (size(request->qual,5) > 0)
  DELETE  FROM br_cki_match b,
    (dummyt d  WITH seq = value(size(request->qual,5)))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.client_id=request->client_id)
     AND (b.data_type_id=request->data_type_id)
     AND (b.data_item_id=request->qual[d.seq].data_item_id))
   WITH nocounter
  ;end delete
  SET ierrcode = 0
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
