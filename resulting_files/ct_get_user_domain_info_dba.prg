CREATE PROGRAM ct_get_user_domain_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 user_token_txt = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM ct_user_domain_info cd
  WHERE (cd.ct_domain_info_id=request->ct_domain_id)
   AND (cd.person_id=request->person_id)
  DETAIL
   reply->user_token_txt = cd.user_token_txt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Sept 25, 2008"
END GO
