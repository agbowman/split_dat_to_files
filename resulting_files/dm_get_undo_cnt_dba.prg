CREATE PROGRAM dm_get_undo_cnt:dba
 RECORD reply(
   1 undo_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET i = 1
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_merge_action
  WHERE (merge_id > request->merge_id)
   AND active_ind=1
   AND merge_status_flag=3
  DETAIL
   reply->undo_cnt = y
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
