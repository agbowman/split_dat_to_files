CREATE PROGRAM ce_get_prsnl_notify:dba
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  pn.person_id
  FROM prsnl_notify pn
  WHERE (pn.person_id=request->person_id)
   AND (pn.query_ind=request->query_ind)
  DETAIL
   cnt += 1
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
