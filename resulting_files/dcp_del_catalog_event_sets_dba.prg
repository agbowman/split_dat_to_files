CREATE PROGRAM dcp_del_catalog_event_sets:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 DELETE  FROM catalog_event_sets ces
  WHERE (ces.catalog_cd=request->catalog_cd)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
