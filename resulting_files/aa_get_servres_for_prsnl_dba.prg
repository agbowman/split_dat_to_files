CREATE PROGRAM aa_get_servres_for_prsnl:dba
 RECORD reply(
   1 service_resource_list[*]
     2 service_resource_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4
 SET count1 = 0
 SET reply->status = "F"
 SELECT INTO "nl:"
  FROM prsnl_service_resource_reltn psr
  WHERE (psr.prsnl_id=request->prsnl_id)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->service_resource_list,(count1+ 9))
   ENDIF
   reply->service_resource_list[count1].service_resource_cd = psr.service_resource_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->service_resource_list,count1)
 IF (curqual=0)
  SET reply->status = "Z"
 ELSE
  SET reply->status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
