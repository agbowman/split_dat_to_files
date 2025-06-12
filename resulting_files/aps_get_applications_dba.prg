CREATE PROGRAM aps_get_applications:dba
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
  WHERE a.application_number IN (200002, 200003, 200004, 200005, 200006,
  200007, 200008, 200009, 200010, 200011,
  200013, 200016, 200021, 200023, 200026,
  200027, 200031, 200033, 200037, 200038,
  200039, 200040, 200041, 200042, 200043,
  200045, 200056, 200059, 200063, 200067,
  200070, 200073, 200074, 200076, 200077,
  200078)
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
