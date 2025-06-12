CREATE PROGRAM cv_get_timezone_for_study:dba
 RECORD reply(
   1 timezone = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 SELECT INTO "nl:"
  FROM im_acquired_study ias,
   im_device dev
  PLAN (ias
   WHERE (ias.study_uid=request->study_uid))
   JOIN (dev
   WHERE dev.im_device_id=ias.im_device_id)
  DETAIL
   reply->timezone = dev.timezone
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
