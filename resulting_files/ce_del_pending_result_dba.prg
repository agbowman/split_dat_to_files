CREATE PROGRAM ce_del_pending_result:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DELETE  FROM ce_pending_result pr
  WHERE (pr.event_id=request->event_id)
  WITH counter
 ;end delete
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
