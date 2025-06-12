CREATE PROGRAM dcp_get_encntr_event_set_io:dba
 RECORD reply(
   1 qual[*]
     2 event_set_name = vc
     2 event_set_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET cnt = 0
 SELECT INTO "nl:"
  FROM encntr_event_set_io e,
   v500_event_set_code v
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND (e.encntr_id=request->encntr_id))
   JOIN (v
   WHERE v.event_set_name=e.event_set_name)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].event_set_name = e.event_set_name, reply->qual[cnt].event_set_cd = v.event_set_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
