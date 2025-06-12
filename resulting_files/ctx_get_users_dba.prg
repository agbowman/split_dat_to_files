CREATE PROGRAM ctx_get_users:dba
 RECORD reply(
   1 qual[1]
     2 username = vc
     2 name_full_formatted = vc
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
 SELECT
  IF ((request->optrange=1))
   WHERE a.name_full_formatted < "H"
  ELSEIF ((request->optrange=2))
   WHERE a.name_full_formatted >= "H"
    AND a.name_full_formatted < "P"
  ELSEIF ((request->optrange=3))
   WHERE a.name_full_formatted >= "P"
  ELSE
  ENDIF
  INTO "nl:"
  a.username, a.name_full_formatted
  FROM prsnl a
  WHERE a.person_id > 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].username = a.username, reply->qual[count1].name_full_formatted = a
   .name_full_formatted
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
