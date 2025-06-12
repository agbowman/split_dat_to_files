CREATE PROGRAM ce_upd_pending_result:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_pending_result pr
  SET pr.event_cd = request->event_cd
  PLAN (pr
   WHERE (pr.event_id=request->event_id))
  WITH counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_updated = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
