CREATE PROGRAM aps_get_ops_exception:dba
 RECORD reply(
   1 qual[*]
     2 exception_type = i2
     2 parent_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET retry_threshold = 10
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="ORDER RETRY THRESHOLD"
  DETAIL
   retry_threshold = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  aoe.parent_id, aoe.action_flag
  FROM ap_ops_exception aoe
  WHERE aoe.parent_id != 0.0
   AND aoe.action_flag > 1
   AND aoe.active_ind=1
   AND aoe.updt_cnt < retry_threshold
  ORDER BY aoe.action_flag DESC
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].parent_id = aoe.parent_id,
   reply->qual[cnt].exception_type = aoe.action_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,cnt)
  SET reply->status_data.status = "S"
 ENDIF
END GO
