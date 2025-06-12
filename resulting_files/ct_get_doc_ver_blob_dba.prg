CREATE PROGRAM ct_get_doc_ver_blob:dba
 RECORD reply(
   1 long_blob = vgc
   1 long_blob_id = f8
   1 parent_entity_id = f8
   1 parent_entity_name = c32
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->long_blob_id != 0))
  SELECT INTO "nl:"
   lb.long_blob, lb.long_blob_id, lb.parent_entity_id,
   lb.parent_entity_name, lb.updt_cnt
   FROM long_blob lb
   WHERE (lb.long_blob_id=request->long_blob_id)
   DETAIL
    reply->long_blob = lb.long_blob, reply->long_blob_id = lb.long_blob_id, reply->parent_entity_id
     = lb.parent_entity_id,
    reply->parent_entity_name = lb.parent_entity_name, reply->updt_cnt = lb.updt_cnt
   WITH nocounter
  ;end select
  IF (curqual=1)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  SET reply->status_data.status = "X"
 ENDIF
END GO
