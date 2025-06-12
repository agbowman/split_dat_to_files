CREATE PROGRAM ce_upd_event_action:dba
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
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 event_action[*]
     2 ce_event_action_id = f8
     2 event_id = f8
     2 action_dt_tm = f8
 )
 DECLARE request_size = i4 WITH constant(size(request->request_list,5))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",4001983,"PENDING"))
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM ce_event_action cea
  WHERE expand(num,1,request_size,cea.ce_event_action_id,request->request_list[num].
   ce_event_action_id)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(temp_rec->event_action,5))
    stat = alterlist(temp_rec->event_action,(count+ 5))
   ENDIF
   temp_rec->event_action[count].action_dt_tm = cea.action_dt_tm
  FOOT REPORT
   stat = alterlist(temp_rec->event_action,count)
  WITH nocounter, expand = 1, forupdatewait(cea)
 ;end select
 UPDATE  FROM ce_event_action cea,
   (dummyt d  WITH seq = value(count))
  SET cea.action_dt_tm =
   IF ((request->request_list[d.seq].action_dt_tm > 0)) cnvtdatetime(request->request_list[d.seq].
     action_dt_tm)
   ELSE cnvtdatetime(temp_rec->event_action[d.seq].action_dt_tm)
   ENDIF
   , cea.person_id = request->request_list[d.seq].person_id, cea.encntr_id = request->request_list[d
   .seq].encntr_id,
   cea.event_class_cd = request->request_list[d.seq].event_class_cd, cea.event_tag = request->
   request_list[d.seq].event_tag, cea.result_status_cd = request->request_list[d.seq].
   result_status_cd,
   cea.clinsig_updt_dt_tm = cnvtdatetime(request->request_list[d.seq].clinsig_updt_dt_tm), cea
   .event_cd = request->request_list[d.seq].event_cd, cea.normalcy_cd = request->request_list[d.seq].
   normalcy_cd,
   cea.event_title_text = request->request_list[d.seq].event_title_text, cea.parent_event_id =
   request->request_list[d.seq].parent_event_id, cea.parent_event_class_cd = request->request_list[d
   .seq].parent_event_class_cd,
   cea.endorse_status_cd = evaluate(request->request_list[d.seq].clinsig_updt_ind,1,request->
    request_list[d.seq].endorse_status_cd,cea.endorse_status_cd), cea.originating_provider_id =
   request->request_list[d.seq].originating_provider_id, cea.updt_id = reqinfo->updt_id,
   cea.updt_dt_tm = cnvtdatetime(curdate,curtime3), cea.updt_task = reqinfo->updt_task, cea.updt_cnt
    = (cea.updt_cnt+ 1),
   cea.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (cea
   WHERE (cea.ce_event_action_id=request->request_list[d.seq].ce_event_action_id))
  WITH nocounter
 ;end update
 IF (curqual != count)
  GO TO exit_script
 ENDIF
 SET reply->num_updated = curqual
 INSERT  FROM ce_prcs_queue ceq,
   (dummyt d  WITH seq = value(count))
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
   JOIN (ceq)
  WITH nocounter
 ;end insert
#exit_script
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
