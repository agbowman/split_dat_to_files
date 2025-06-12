CREATE PROGRAM cp_get_device:dba
 RECORD reply(
   1 qual[*]
     2 device_cd = f8
     2 device_name = c20
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
  FROM device_xref d,
   output_dest o
  PLAN (d
   WHERE d.parent_entity_name=cnvtupper(cnvtalphanum(request->destination_type))
    AND (d.parent_entity_id=request->destination_id))
   JOIN (o
   WHERE o.device_cd=d.device_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].device_cd = o.device_cd, reply->qual[cnt].device_name = o.name
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
