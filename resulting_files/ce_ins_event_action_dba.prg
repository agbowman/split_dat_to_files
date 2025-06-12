CREATE PROGRAM ce_ins_event_action:dba
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",4001983,"PENDING"))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE getoriginatingprovider(orig_req=vc(ref)) = i2 WITH protect
 SUBROUTINE getoriginatingprovider(orig_req)
   DECLARE nlistcnt = i4 WITH protect, constant(size(orig_req->request_list,5))
   DECLARE nordcnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, constant(1)
   DECLARE startloc = i4 WITH protect, noconstant(1)
   DECLARE errorcode = i2 WITH protect, noconstant(0)
   DECLARE errormessage = vc
   SELECT INTO "nl:"
    FROM order_action oa
    WHERE expand(num,start,nlistcnt,oa.order_id,orig_req->request_list[num].order_id)
     AND oa.action_sequence=1
    DETAIL
     startloc = 1
     WHILE (startloc <= nlistcnt)
      pos = locateval(num,startloc,nlistcnt,oa.order_id,orig_req->request_list[num].order_id),
      IF (pos > 0)
       startloc = (pos+ 1), orig_req->request_list[pos].originating_provider_id = oa
       .action_personnel_id
      ELSE
       startloc = (nlistcnt+ 1)
      ENDIF
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   SET errorcode = error(errormessage,0)
   IF (errorcode != 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (getoriginatingprovider(request)=0)
  GO TO exit_script
 ENDIF
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 INSERT  FROM ce_event_action t,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET t.ce_event_action_id = request->request_list[d.seq].ce_event_action_id, t.event_id = request->
   request_list[d.seq].event_id, t.action_type_cd = request->request_list[d.seq].action_type_cd,
   t.action_prsnl_id = request->request_list[d.seq].action_prsnl_id, t.action_dt_tm = cnvtdatetime(
    request->request_list[d.seq].action_dt_tm), t.person_id = request->request_list[d.seq].person_id,
   t.encntr_id = request->request_list[d.seq].encntr_id, t.event_class_cd = request->request_list[d
   .seq].event_class_cd, t.event_tag = request->request_list[d.seq].event_tag,
   t.result_status_cd = request->request_list[d.seq].result_status_cd, t.clinsig_updt_dt_tm =
   cnvtdatetime(request->request_list[d.seq].clinsig_updt_dt_tm), t.event_cd = request->request_list[
   d.seq].event_cd,
   t.normalcy_cd = request->request_list[d.seq].normalcy_cd, t.event_title_text = request->
   request_list[d.seq].event_title_text, t.parent_event_id = request->request_list[d.seq].
   parent_event_id,
   t.parent_event_class_cd = request->request_list[d.seq].parent_event_class_cd, t.endorse_status_cd
    = request->request_list[d.seq].endorse_status_cd, t.originating_provider_id = request->
   request_list[d.seq].originating_provider_id,
   t.last_comment_txt = "", t.multiple_comment_ind = 0, t.last_saved_prsnl_id = 0.0,
   t.multiple_comment_prsnl_ind = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task =
   reqinfo->updt_task,
   t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (t)
  WITH counter
 ;end insert
 SET reply->num_inserted = curqual
 INSERT  FROM ce_prcs_queue ceq,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET ceq.ce_prcs_queue_id = request->request_list[d.seq].ce_prcs_queue_id, ceq.ce_event_action_id =
   request->request_list[d.seq].ce_event_action_id, ceq.event_id = request->request_list[d.seq].
   event_id,
   ceq.queue_status_cd = pending, ceq.create_dt_tm = cnvtdatetime(curdate,curtime3), ceq.prcs_dt_tm
    = null,
   ceq.queue_type_cd = endorse, ceq.updt_id = reqinfo->updt_id, ceq.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ceq.updt_task = reqinfo->updt_task, ceq.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->request_list[d.seq].ce_prcs_queue_id > 0.0))
   JOIN (ceq
   WHERE (ceq.ce_event_action_id=request->request_list[d.seq].ce_event_action_id))
  WITH nocounter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
