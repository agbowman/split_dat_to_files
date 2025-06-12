CREATE PROGRAM ce_del_v500_event_set_canon:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DELETE  FROM v500_event_set_canon esc
  WHERE (esc.parent_event_set_cd=request->parent_event_set_cd)
   AND (esc.event_set_cd=request->event_set_cd)
  WITH counter
 ;end delete
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
