CREATE PROGRAM dcp_chg_ord_tasks:dba
 DECLARE program_version = vc WITH private, constant("028")
 RECORD internal_task(
   1 qual[*]
     2 status = i1
     2 task_id = f8
     2 task_status_cd = f8
     2 task_class_cd = f8
     2 task_dt_tm = dq8
     2 task_tz = i4
   1 req[*]
     2 status = i1
     2 task_id = f8
     2 order_id = f8
     2 task_status_cd = f8
     2 task_class_cd = f8
     2 beg_effective_dt_tm = dq8
     2 continuous_ind = i2
     2 task_dt_tm = dq8
     2 task_tz = i4
     2 task_priority_cd = f8
 )
 SET task_cnt = 0
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 0
 SET nbr_to_chg = size(request->order_list,5)
 SET failures = 0
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE task_class_nsch = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE task_class_sch = f8 WITH constant(uar_get_code_by("MEANING",6025,"SCH"))
 DECLARE task_class_cont = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE infusion_billing_task_meaning = c10 WITH constant("INFUSEBILL"), protect
 DECLARE end_bag_task_meaning = c8 WITH constant("IVENDBAG"), protect
 DECLARE discontinued_order_status_meaning = vc WITH constant("DISCONTINUED"), protect
 DECLARE canceled_order_status_meaning = vc WITH constant("CANCELED"), protect
 DECLARE deleted_order_status_meaning = vc WITH constant("DELETED"), protect
 DECLARE suspended_order_status_meaning = vc WITH constant("SUSPENDED"), protect
 DECLARE deleted_w_results_order_status_meaning = vc WITH constant("VOIDEDWRSLT"), protect
 DECLARE task_type_response = f8 WITH constant(uar_get_code_by("MEANING",6026,"RESPONSE"))
 DECLARE pco_consult_ref_task_id = f8 WITH constant(uar_get_ref_task_by_ctf(3)), protect
 DECLARE abnormal_endorsement_ref_task_id = f8 WITH constant(uar_get_ref_task_by_ctf(4)), protect
 DECLARE sign_endorsement_ref_task_id = f8 WITH constant(uar_get_ref_task_by_ctf(6)), protect
 DECLARE perform_result_endorsement_ref_task_id = f8 WITH constant(uar_get_ref_task_by_ctf(10)),
 protect
 DECLARE cancel_endorsement_task = i2 WITH noconstant(0), protect
 SET position = 0
 SET taskupdtcnt = 0
 DECLARE task_type_meaning = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM config_prefs c
  WHERE c.config_name="CNCLENDRSTSK"
  DETAIL
   IF (c.config_value="1")
    cancel_endorsement_task = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (nbr_to_chg > 0)
  SELECT INTO "nl:"
   ta.*
   FROM task_activity ta,
    (dummyt d  WITH seq = value(nbr_to_chg))
   PLAN (d)
    JOIN (ta
    WHERE (ta.order_id=request->order_list[d.seq].order_id)
     AND ((ta.task_status_cd=task_status_pending) OR (ta.task_status_cd=task_status_overdue))
     AND ta.active_ind=1
     AND ta.task_type_cd != task_type_response
     AND  NOT (((ta.reference_task_id+ 0) IN (pco_consult_ref_task_id,
    perform_result_endorsement_ref_task_id)))
     AND ((cancel_endorsement_task=1) OR ( NOT (((ta.reference_task_id+ 0) IN (
    abnormal_endorsement_ref_task_id, sign_endorsement_ref_task_id))))) )
   ORDER BY ta.order_id
   DETAIL
    task_type_meaning = uar_get_code_meaning(ta.task_type_cd)
    IF (task_type_meaning != infusion_billing_task_meaning
     AND ((task_type_meaning != end_bag_task_meaning) OR (task_type_meaning=end_bag_task_meaning
     AND (((request->order_list[d.seq].order_status_meaning=discontinued_order_status_meaning)) OR (
    (((request->order_list[d.seq].order_status_meaning=canceled_order_status_meaning)) OR ((((request
    ->order_list[d.seq].order_status_meaning=deleted_order_status_meaning)) OR ((((request->
    order_list[d.seq].order_status_meaning=suspended_order_status_meaning)) OR ((request->order_list[
    d.seq].order_status_meaning=deleted_w_results_order_status_meaning))) )) )) )) )) )
     task_cnt += 1
     IF (task_cnt > size(internal_task->qual,5))
      stat = alterlist(internal_task->qual,(task_cnt+ 10))
     ENDIF
     IF (task_cnt > size(internal_task->req,5))
      stat = alterlist(internal_task->req,(task_cnt+ 10))
     ENDIF
     internal_task->qual[task_cnt].task_id = ta.task_id, internal_task->qual[task_cnt].task_class_cd
      = ta.task_class_cd, internal_task->qual[task_cnt].task_status_cd = ta.task_status_cd,
     internal_task->qual[task_cnt].task_dt_tm =
     IF ((request->order_list[d.seq].task_dt_tm != 0)) cnvtdatetime(ta.task_dt_tm)
     ELSE null
     ENDIF
     , internal_task->qual[task_cnt].task_tz =
     IF ((request->order_list[d.seq].task_dt_tm != 0)) ta.task_tz
     ELSE 0
     ENDIF
     , internal_task->req[task_cnt].task_id = ta.task_id,
     internal_task->req[task_cnt].order_id = request->order_list[d.seq].order_id, internal_task->req[
     task_cnt].task_status_cd = request->order_list[d.seq].task_status_cd, internal_task->req[
     task_cnt].task_class_cd = request->order_list[d.seq].task_class_cd,
     internal_task->req[task_cnt].continuous_ind = request->order_list[d.seq].continuous_ind,
     internal_task->req[task_cnt].task_dt_tm = cnvtdatetime(request->order_list[d.seq].task_dt_tm),
     internal_task->req[task_cnt].task_tz =
     IF ((request->order_list[d.seq].task_dt_tm != 0)) request->order_list[d.seq].task_tz
     ELSE 0
     ENDIF
     ,
     internal_task->req[task_cnt].task_priority_cd = request->order_list[d.seq].task_priority_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(internal_task->qual,task_cnt)
 SET stat = alterlist(internal_task->req,task_cnt)
 CALL echo(build("nbr_to_chg = ",nbr_to_chg,"   task_cnt = ",task_cnt))
 IF (((curqual=0) OR (task_cnt=0)) )
  FOR (x = 1 TO nbr_to_chg)
    CALL echo(build("Order_id = ",request->order_list[x].order_id))
  ENDFOR
  FOR (x = 1 TO task_cnt)
    SET internal_task->req[x].status = 0
  ENDFOR
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta,
   (dummyt d  WITH seq = value(task_cnt))
  SET ta.updt_dt_tm = cnvtdatetime(sysdate), ta.task_status_cd =
   IF ((((internal_task->req[d.seq].task_status_cd != null)) OR ((internal_task->req[d.seq].
   task_status_cd != 0))) )
    IF ((internal_task->req[d.seq].task_status_cd=task_status_overdue)
     AND (internal_task->req[d.seq].task_dt_tm != null)) task_status_pending
    ELSE internal_task->req[d.seq].task_status_cd
    ENDIF
   ELSE task_status_pending
   ENDIF
   , ta.task_class_cd =
   IF ((internal_task->req[d.seq].task_class_cd != null)) internal_task->req[d.seq].task_class_cd
   ELSE ta.task_class_cd
   ENDIF
   ,
   ta.continuous_ind = internal_task->req[d.seq].continuous_ind, ta.task_dt_tm =
   IF ((internal_task->req[d.seq].task_dt_tm != 0)) cnvtdatetime(internal_task->req[d.seq].task_dt_tm
     )
   ELSE ta.task_dt_tm
   ENDIF
   , ta.task_tz =
   IF ((internal_task->req[d.seq].task_dt_tm != 0)) internal_task->req[d.seq].task_tz
   ELSE ta.task_tz
   ENDIF
   ,
   ta.task_priority_cd = internal_task->req[d.seq].task_priority_cd, ta.updt_id = reqinfo->updt_id,
   ta.updt_task = reqinfo->updt_task,
   ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->updt_applctx, ta.scheduled_dt_tm =
   IF ((internal_task->req[d.seq].task_class_cd=task_class_sch)
    AND (internal_task->req[d.seq].task_dt_tm != 0)) cnvtdatetime(internal_task->req[d.seq].
     task_dt_tm)
   ENDIF
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_id=internal_task->req[d.seq].task_id)
    AND ((ta.task_status_cd=task_status_pending) OR (ta.task_status_cd=task_status_overdue))
    AND ta.active_ind=1)
  WITH nocounter, status(internal_task->req[d.seq].status)
 ;end update
 SET taskupdtcnt = curqual
 FOR (x = 1 TO task_cnt)
   SET internal_task->qual[x].status = internal_task->req[x].status
 ENDFOR
 FOR (x = 1 TO task_cnt)
   INSERT  FROM task_action tac
    SET tac.seq = 1, tac.task_id = internal_task->qual[x].task_id, tac.task_action_seq = seq(
      carenet_seq,nextval),
     tac.task_status_cd = internal_task->qual[x].task_status_cd, tac.task_dt_tm =
     IF ((internal_task->qual[x].task_dt_tm != 0)) cnvtdatetime(internal_task->qual[x].task_dt_tm)
     ELSE null
     ENDIF
     , tac.task_tz =
     IF ((internal_task->qual[x].task_dt_tm != 0)) internal_task->qual[x].task_tz
     ELSE 0
     ENDIF
     ,
     tac.task_status_reason_cd = 0, tac.reschedule_reason_cd = 0, tac.updt_dt_tm = cnvtdatetime(
      sysdate),
     tac.updt_id = reqinfo->updt_id, tac.updt_task = reqinfo->updt_task, tac.updt_cnt = 0,
     tac.updt_applctx = reqinfo->updt_applctx
    WHERE (internal_task->qual[x].status=1)
   ;end insert
 ENDFOR
 SELECT INTO "nl:"
  ta.*
  FROM task_activity ta,
   (dummyt d  WITH seq = value(task_cnt))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_id=internal_task->req[d.seq].task_id)
    AND ta.active_ind=1)
  ORDER BY ta.task_id
  HEAD REPORT
   stat = alterlist(reply->task_list,task_cnt)
  HEAD ta.task_id
   reply->task_list[d.seq].task_id = ta.task_id, reply->task_list[d.seq].task_status_cd = ta
   .task_status_cd, reply->task_list[d.seq].event_id = ta.event_id,
   reply->task_list[d.seq].order_id = ta.order_id, reply->task_list[d.seq].reference_task_id = ta
   .reference_task_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO task_cnt)
   CALL echo(build("before task_id = ",internal_task->qual[x].task_id,"status =",internal_task->qual[
     x].status))
   CALL echo(build("before x =",x," task_status_cd = ",internal_task->qual[x].task_status_cd))
   CALL echo(build("after  task_id = ",reply->task_list[x].task_id))
   CALL echo(build("after x =",x," task_status_cd = ",reply->task_list[x].task_status_cd))
 ENDFOR
#exit_script
 IF (taskupdtcnt != task_cnt)
  FOR (x = 1 TO task_cnt)
    IF ((internal_task->req[x].status=0))
     SET failures += 1
     IF (failures > 0)
      SET stat = alterlist(reply->order_list,failures)
     ENDIF
     SET reply->order_list[failures].order_id = internal_task->req[x].order_id
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != nbr_to_chg)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ELSE
  ROLLBACK
 ENDIF
END GO
