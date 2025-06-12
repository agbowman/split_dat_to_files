CREATE PROGRAM atr_get_requests:dba
 RECORD reply(
   1 qual[10]
     2 request_number = i4
     2 description = vc
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
 SET stat = alter(reply->qual,request->number_to_get)
 SET last_number = (request->start_number - 1)
 SELECT INTO "nl:"
  r.request_number, r.description
  FROM request r
  WHERE r.request_number > last_number
  ORDER BY r.request_number
  DETAIL
   count1 += 1, reply->qual[count1].request_number = r.request_number, reply->qual[count1].
   description = r.description
  WITH nocounter, maxqual(r,value(request->number_to_get))
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((count1 != request->number_to_get))
  SET stat = alter(reply->qual,count1)
 ENDIF
END GO
