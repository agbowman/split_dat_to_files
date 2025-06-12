CREATE PROGRAM ce_get_event_action:dba
 SET error_msg = fillstring(132," ")
 SET error_code = 0
 SELECT INTO "nl:"
  cea.ce_event_action_id
  FROM ce_event_action cea
  WHERE (cea.event_id=request->event_id)
   AND (cea.action_prsnl_id=request->action_prsnl_id)
   AND (cea.action_type_cd=request->action_type_cd)
  DETAIL
   reply->ce_event_action_id = cea.ce_event_action_id
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
