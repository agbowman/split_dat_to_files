CREATE PROGRAM ecm_get_list:dba
 RECORD reply(
   1 qual[1]
     2 event_cd = f8
     2 parent_cd = f8
     2 parent_code_set = i4
     2 parent_disp = c40
     2 event_cd_disp = c40
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
 SELECT INTO "nl:"
  r.event_cd
  FROM code_value_event_r r,
   code_value cv1,
   code_value cv2
  PLAN (r
   WHERE r.parent_cd > 0)
   JOIN (cv1
   WHERE r.parent_cd=cv1.code_value)
   JOIN (cv2
   WHERE r.event_cd=cv2.code_value)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,100)=2)
    stat = alter(reply->qual,(count1+ 99))
   ENDIF
   reply->qual[count1].event_cd = r.event_cd, reply->qual[count1].event_cd_disp = cv2.display, reply
   ->qual[count1].parent_cd = r.parent_cd,
   reply->qual[count1].parent_disp = cv1.display, reply->qual[count1].parent_code_set = cv1.code_set
  FOOT REPORT
   stat = alter(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
