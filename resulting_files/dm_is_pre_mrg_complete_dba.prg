CREATE PROGRAM dm_is_pre_mrg_complete:dba
 RECORD reply(
   1 src_id = f8
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
  a.info_number
  FROM dm_info a
  WHERE a.info_domain="DATA MANAGEMENT"
   AND a.info_name="PRE_MERGE"
  DETAIL
   reply->src_id = a.info_number
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
