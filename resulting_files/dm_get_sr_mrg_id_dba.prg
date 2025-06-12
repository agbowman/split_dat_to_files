CREATE PROGRAM dm_get_sr_mrg_id:dba
 RECORD reply(
   1 source_sr_merge_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  l1.merge_id
  FROM dm_merge_action l1
  WHERE (l1.from_rowid=request->source_sr_rowid)
   AND l1.active_ind=1
  DETAIL
   reply->source_sr_merge_id = l1.merge_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
