CREATE PROGRAM ch_decoder:dba
 RECORD reply(
   1 qual[10]
     2 code = f8
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET searchstring = cnvtupper(concat(request->start_name,"*"))
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
   AND c.display_key=patstring(searchstring)
  ORDER BY c.display_key
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].code = c.code_value, reply->qual[count1].display = c.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
