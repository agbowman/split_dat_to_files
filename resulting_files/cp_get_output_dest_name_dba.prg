CREATE PROGRAM cp_get_output_dest_name:dba
 RECORD reply(
   1 output_dest_name = c50
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
  od.name
  FROM output_dest od
  WHERE (od.device_cd=request->device_cd)
  DETAIL
   reply->output_dest_name = od.name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
