CREATE PROGRAM ce_upd_event_action_assign:dba
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 num_updated = i4
    1 error_code = f8
    1 error_msg = vc
  )
 ENDIF
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 event_action[*]
     2 ce_event_action_id = f8
     2 assign_prsnl_id = f8
 )
 DECLARE request_size = i4 WITH constant(size(request->request_list,5))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  FROM ce_event_action cea,
   (dummyt d  WITH seq = value(request_size))
  PLAN (d)
   JOIN (cea
   WHERE (cea.event_id=request->request_list[d.seq].event_id)
    AND (cea.action_prsnl_id=request->request_list[d.seq].action_prsnl_id)
    AND (cea.action_type_cd=request->request_list[d.seq].action_type_cd))
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(temp_rec->event_action,5))
    stat = alterlist(temp_rec->event_action,(count+ 5))
   ENDIF
   temp_rec->event_action[count].ce_event_action_id = cea.ce_event_action_id, temp_rec->event_action[
   count].assign_prsnl_id = request->request_list[d.seq].assign_prsnl_id
  FOOT REPORT
   stat = alterlist(temp_rec->event_action,count)
  WITH nocounter, forupdatewait(cea)
 ;end select
 IF (count > 0)
  UPDATE  FROM ce_event_action cea,
    (dummyt d  WITH seq = value(count))
   SET cea.assign_prsnl_id = temp_rec->event_action[d.seq].assign_prsnl_id, cea.updt_id = reqinfo->
    updt_id, cea.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cea.updt_task = reqinfo->updt_task, cea.updt_cnt = (cea.updt_cnt+ 1), cea.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d)
    JOIN (cea
    WHERE (cea.ce_event_action_id=temp_rec->event_action[d.seq].ce_event_action_id))
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual > 0)
  SET reqinfo->commit_ind = 1
 ENDIF
 SET error_code = error(error_msg,0)
 SET reply->num_updated = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
