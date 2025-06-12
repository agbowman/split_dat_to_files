CREATE PROGRAM bed_get_coll_class_status:dba
 FREE SET reply
 RECORD reply(
   1 coll_class_status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->coll_class_status = 0
 SELECT INTO "NL:"
  FROM br_coll_class bcc
  WHERE (bcc.activity_type=request->activity_type)
   AND bcc.facility_id > 0.0
  DETAIL
   reply->coll_class_status = 1
  WITH nocounter, maxqual(bcc,1)
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
