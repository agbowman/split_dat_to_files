CREATE PROGRAM dm_get_mrg_status:dba
 RECORD reply(
   1 merge_status_flag = i2
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
  a.merge_status_flag
  FROM dm_merge_action a
  WHERE (a.merge_id=request->merge_id)
  DETAIL
   reply->merge_status_flag = a.merge_status_flag
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
