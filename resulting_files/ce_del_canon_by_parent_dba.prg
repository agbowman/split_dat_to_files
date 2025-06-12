CREATE PROGRAM ce_del_canon_by_parent:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DELETE  FROM canon_by_parent esc
  WHERE (esc.parent_event_set_cd=request->parent_event_set_cd)
  WITH counter
 ;end delete
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
