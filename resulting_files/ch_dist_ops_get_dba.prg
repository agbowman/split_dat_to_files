CREATE PROGRAM ch_dist_ops_get:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 IF (cnvtreal(request->dist_id) > 0)
  SELECT INTO "nl:"
   o.param
   FROM charting_operations o
   WHERE o.param_type_flag=2
    AND (o.param=request->dist_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "GET"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARTING_OPERATIONS"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF (cnvtreal(request->law_id) > 0)
  SELECT INTO "nl:"
   o.param
   FROM charting_operations o
   WHERE o.param_type_flag=18
    AND (o.param=request->law_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "GET"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARTING_OPERATIONS"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
