CREATE PROGRAM bbd_get_db_tools:dba
 RECORD reply(
   1 qual[*]
     2 description = vc
     2 object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE ncount = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM application a
  WHERE a.application_number IN (225026, 225049, 225051, 225057, 225060,
  225068, 225074, 225088)
   AND a.active_ind=1
  DETAIL
   ncount = (ncount+ 1), stat = alterlist(reply->qual,ncount), reply->qual[ncount].description = a
   .description,
   reply->qual[ncount].object_name = a.object_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.subeventstatus.targetobjectvalue = "SUCCESS"
 ENDIF
END GO
