CREATE PROGRAM daf_migrator_lock_ccl:dba
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dm2_alt_reply
 RECORD dm2_alt_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dm2_lock_ccl_dictionary  WITH replace("REPLY",dm2_alt_reply)
 IF ((dm2_alt_reply->status_data.status="S"))
  SET reply->status_data.status = "S"
  SET reply->message = "The CCL Dictionary was locked successfully."
 ELSE
  SET reply->status_data.status = "F"
  SET reply->message = dm2_alt_reply->status_data.subeventstatus[1].targetobjectvalue
 ENDIF
 FREE RECORD dm2_alt_reply
END GO
