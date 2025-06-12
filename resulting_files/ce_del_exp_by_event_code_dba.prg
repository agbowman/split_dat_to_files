CREATE PROGRAM ce_del_exp_by_event_code:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DELETE  FROM v500_event_set_explode ese
  WHERE (ese.event_cd=request->event_cd)
  WITH counter
 ;end delete
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
