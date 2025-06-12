CREATE PROGRAM bbt_get_tech_id:dba
 RECORD reply(
   1 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  pnl.person_id, pnl.username
  FROM prsnl pnl
  WHERE cnvtupper(pnl.username)=cnvtupper(request->username)
  DETAIL
   reply->person_id = pnl.person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status = "Z"
  SET reply->process = "get prsnl.username"
  SET reply->message = "get prsnl.username failed"
 ENDIF
END GO
