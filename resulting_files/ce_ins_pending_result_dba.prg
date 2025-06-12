CREATE PROGRAM ce_ins_pending_result:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_pending_result t
  SET t.event_id = request->event_id, t.event_cd = request->event_cd
  PLAN (t)
  WITH counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
