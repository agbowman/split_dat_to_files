CREATE PROGRAM bhs_wait_15_seconds
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL pause(15)
 SET reply->status_data.status = "S"
END GO
