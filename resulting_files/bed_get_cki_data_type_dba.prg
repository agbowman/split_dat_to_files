CREATE PROGRAM bed_get_cki_data_type:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 data_type_id = f8
     2 data_type_name = vc
     2 data_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM br_cki_data_type b
  PLAN (b)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].data_type_id = b.data_type_id,
   reply->qual[cnt].data_type_name = b.data_type_name, reply->qual[cnt].data_type_mean = b
   .data_type_meaning
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
