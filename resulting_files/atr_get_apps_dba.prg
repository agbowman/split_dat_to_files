CREATE PROGRAM atr_get_apps:dba
 RECORD reply(
   1 qual[10]
     2 application_number = i4
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
 SET last_number = (request->start_number - 1)
 IF ((request->number_to_get=0))
  GO TO exit_script
 ENDIF
 SET stat = alter(reply->qual,request->number_to_get)
 SELECT INTO "nl:"
  a.application_number, a.description
  FROM application a
  WHERE a.application_number > last_number
  ORDER BY a.application_number
  DETAIL
   count1 += 1, reply->qual[count1].application_number = a.application_number, reply->qual[count1].
   description = a.description
  WITH nocounter, maxqual(a,value(request->number_to_get))
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "application"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((curqual != request->number_to_get))
  SET stat = alter(reply->qual,count1)
 ENDIF
#exit_script
END GO
