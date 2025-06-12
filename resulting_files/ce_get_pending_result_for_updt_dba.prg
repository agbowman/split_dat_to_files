CREATE PROGRAM ce_get_pending_result_for_updt:dba
 DECLARE cnt = i4 WITH noconstant(0)
 SET reply->event_cd = 0.0
 SELECT INTO "nl:"
  cpr.event_cd
  FROM ce_pending_result cpr
  WHERE (cpr.event_id=request->event_id)
  DETAIL
   cnt += 1, reply->event_cd = cpr.event_cd
  WITH forupdate(cpr)
 ;end select
 SET reply->qual = cnt
END GO
