CREATE PROGRAM ce_ins_prcs_queue:dba
 DECLARE event = f8 WITH constant(uar_get_code_by("MEANING",4001982,"EVENT"))
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",4001983,"PENDING"))
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_prcs_queue ceq,
   (dummyt d  WITH seq = size(request->ce_prcs_queue_list,5))
  SET ceq.ce_prcs_queue_id = request->ce_prcs_queue_list[d.seq].ce_prcs_queue_id, ceq
   .ce_event_action_id = 0.0, ceq.event_id = request->ce_prcs_queue_list[d.seq].event_id,
   ceq.queue_status_cd = pending, ceq.create_dt_tm = cnvtdatetime(sysdate), ceq.prcs_dt_tm = null,
   ceq.queue_type_cd = event, ceq.updt_id = reqinfo->updt_id, ceq.updt_dt_tm = cnvtdatetime(sysdate),
   ceq.updt_task = reqinfo->updt_task, ceq.updt_applctx = reqinfo->updt_applctx, ceq.updt_cnt = 0
  PLAN (d
   WHERE (request->ce_prcs_queue_list[d.seq].ce_prcs_queue_id > 0.0))
   JOIN (ceq)
  WITH nocounter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
