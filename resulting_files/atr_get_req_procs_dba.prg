CREATE PROGRAM atr_get_req_procs:dba
 RECORD reply(
   1 qual[1]
     2 request_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  r.request_number
  FROM request_processing r
  WHERE (r.request_number=request->request_number)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].request_number = r.request_number
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
