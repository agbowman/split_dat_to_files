CREATE PROGRAM ce_del_event_action:dba
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 event_action[*]
     2 ce_event_action_id = f8
 )
 DECLARE request_size = i4 WITH constant(size(request->request_list,5))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM ce_event_action cea
  WHERE expand(num,1,request_size,cea.event_id,request->request_list[num].event_id,
   cea.action_prsnl_id,request->request_list[num].action_prsnl_id,cea.action_type_cd,request->
   request_list[num].action_type_cd)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(temp_rec->event_action,5))
    stat = alterlist(temp_rec->event_action,(count+ 5))
   ENDIF
   temp_rec->event_action[count].ce_event_action_id = cea.ce_event_action_id
  FOOT REPORT
   stat = alterlist(temp_rec->event_action,count)
  WITH nocounter
 ;end select
 IF (count > 0)
  DELETE  FROM ce_prcs_queue cpq
   WHERE expand(num,1,size(temp_rec->event_action,5),cpq.ce_event_action_id,temp_rec->event_action[
    num].ce_event_action_id)
    AND cpq.queue_type_cd=endorse
   WITH nocounter
  ;end delete
  DELETE  FROM ce_rte_prsnl_reltn crpr
   WHERE expand(num,1,size(temp_rec->event_action,5),crpr.ce_event_action_id,temp_rec->event_action[
    num].ce_event_action_id)
   WITH nocounter
  ;end delete
  DELETE  FROM ce_event_action cea
   WHERE expand(num,1,size(temp_rec->event_action,5),cea.ce_event_action_id,temp_rec->event_action[
    num].ce_event_action_id)
   WITH nocounter
  ;end delete
 ENDIF
 SET error_code = error(error_msg,0)
 SET reply->num_deleted = count
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
