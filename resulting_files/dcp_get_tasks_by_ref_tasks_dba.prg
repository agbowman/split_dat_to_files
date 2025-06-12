CREATE PROGRAM dcp_get_tasks_by_ref_tasks:dba
 SUBROUTINE retrieveordertaskinfo(no_parameters)
  DECLARE reply_task_count = i4 WITH constant(size(reply->task_list,5))
  IF (reply_task_count > 0)
   SELECT INTO "nl: "
    FROM (dummyt d  WITH seq = value(reply_task_count)),
     order_task ot
    PLAN (d
     WHERE (reply->task_list[d.seq].reference_task_id > 0))
     JOIN (ot
     WHERE (ot.reference_task_id=reply->task_list[d.seq].reference_task_id))
    DETAIL
     reply->task_list[d.seq].task_description = ot.task_description, reply->task_list[d.seq].
     chart_not_cmplt_ind = ot.chart_not_cmplt_ind, reply->task_list[d.seq].quick_chart_done_ind = ot
     .quick_chart_done_ind,
     reply->task_list[d.seq].quick_chart_ind = ot.quick_chart_ind, reply->task_list[d.seq].
     quick_chart_notdone_ind = ot.quick_chart_notdone_ind, reply->task_list[d.seq].cernertask_flag =
     ot.cernertask_flag,
     reply->task_list[d.seq].event_cd = ot.event_cd, reply->task_list[d.seq].reschedule_time = ot
     .reschedule_time, reply->task_list[d.seq].dcp_forms_ref_id = ot.dcp_forms_ref_id,
     reply->task_list[d.seq].capture_bill_info_ind = ot.capture_bill_info_ind, reply->task_list[d.seq
     ].ignore_req_ind = ot.ignore_req_ind, reply->task_list[d.seq].allpositionchart_ind = ot
     .allpositionchart_ind,
     reply->task_list[d.seq].grace_period_mins = ot.grace_period_mins
     IF ((reply->task_list[d.seq].scheduled_dt_tm != null))
      reply->task_list[d.seq].beg_grace_period_dt_tm = datetimeadd(cnvtdatetime(reply->task_list[d
        .seq].scheduled_dt_tm),- ((ot.grace_period_mins/ 1440))), reply->task_list[d.seq].
      end_grace_period_dt_tm = datetimeadd(cnvtdatetime(reply->task_list[d.seq].scheduled_dt_tm),(ot
       .grace_period_mins/ 1440))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE retrievechartingagents(no_parameters)
  DECLARE reply_task_count = i4 WITH constant(size(reply->task_list,5))
  IF (reply_task_count > 0)
   SELECT INTO "nl: "
    FROM (dummyt d  WITH seq = value(reply_task_count)),
     task_charting_agent_r tcar
    PLAN (d
     WHERE (reply->task_list[d.seq].reference_task_id > 0))
     JOIN (tcar
     WHERE (tcar.reference_task_id=reply->task_list[d.seq].reference_task_id))
    ORDER BY d.seq
    HEAD d.seq
     charting_agent_count = 0
    DETAIL
     charting_agent_count += 1
     IF (size(reply->task_list[d.seq].charting_agent_list,5) < charting_agent_count)
      stat = alterlist(reply->task_list[d.seq].charting_agent_list,(charting_agent_count+ 10))
     ENDIF
     reply->task_list[d.seq].charting_agent_list[charting_agent_count].charting_agent_cd = tcar
     .charting_agent_cd, reply->task_list[d.seq].charting_agent_list[charting_agent_count].
     charting_agent_entity_name = tcar.charting_agent_entity_name, reply->task_list[d.seq].
     charting_agent_list[charting_agent_count].charting_agent_entity_id = tcar
     .charting_agent_entity_id,
     reply->task_list[d.seq].charting_agent_list[charting_agent_count].charting_agent_identifier =
     tcar.charting_agent_identifier
    FOOT  d.seq
     stat = alterlist(reply->task_list[d.seq].charting_agent_list,charting_agent_count)
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveordertaskpositions(no_parameters)
  DECLARE reply_task_count = i4 WITH constant(size(reply->task_list,5))
  IF (reply_task_count > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(reply_task_count)),
     order_task_position_xref otp
    PLAN (d
     WHERE (reply->task_list[d.seq].reference_task_id > 0))
     JOIN (otp
     WHERE (otp.reference_task_id=reply->task_list[d.seq].reference_task_id))
    ORDER BY d.seq
    HEAD d.seq
     position_count = 0
    DETAIL
     position_count += 1
     IF (size(reply->task_list[d.seq].position_list,5) < position_count)
      stat = alterlist(reply->task_list[d.seq].position_list,(position_count+ 10))
     ENDIF
     reply->task_list[d.seq].position_list[position_count].position_cd = otp.position_cd
    FOOT  d.seq
     stat = alterlist(reply->task_list[d.seq].position_list,position_count)
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE retrievetemplateorder(no_parameters)
   DECLARE reply_task_count = i4 WITH constant(size(reply->task_list,5))
   DECLARE order_action_type_new = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
   IF (reply_task_count > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(reply_task_count)),
      orders o,
      order_action oa
     PLAN (d
      WHERE (reply->task_list[d.seq].order_id > 0))
      JOIN (o
      WHERE (o.order_id=reply->task_list[d.seq].order_id))
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_type_cd=order_action_type_new)
     DETAIL
      reply->task_list[d.seq].template_order_id = o.template_order_id, reply->task_list[d.seq].
      frequency_id = o.frequency_id, reply->task_list[d.seq].order_provider_id = oa.order_provider_id
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN")), protect
 DECLARE task_class_continuous = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT")), protect
 DECLARE task_class_nonscheduled = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH")), protect
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING")), protect
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE")), protect
 DECLARE task_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS")), protect
 DECLARE task_status_validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION")),
 protect
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE reference_task_count = i4 WITH constant(size(request->reference_task_list,5)), protect
 DECLARE person_count = i4 WITH constant(size(request->person_list,5)), protect
 DECLARE encntr_count = i4 WITH constant(size(request->encntr_list,5)), protect
 DECLARE task_status_count = i4 WITH constant(size(request->task_status_list,5)), protect
 DECLARE task_status_index = i4 WITH noconstant(1), protect
 DECLARE task_type_count = i4 WITH constant(size(request->task_type_list,5)), protect
 DECLARE task_type_index = i4 WITH noconstant(1), protect
 DECLARE task_class_count = i4 WITH constant(size(request->task_class_list,5)), protect
 DECLARE task_class_index = i4 WITH noconstant(1), protect
 DECLARE task_count = i4 WITH noconstant(0), protect
 DECLARE expandclauses = c1000 WITH noconstant(fillstring(1000," ")), protect
 SET expandclauses = concat(trim(expandclauses)," ta.active_ind = 1 ")
 SET reply->status_data.status = "F"
 IF (reference_task_count > 0)
  IF ((request->beg_dt_tm > 0)
   AND (request->end_dt_tm > 0))
   IF (validate(request->apply_grace_period_ind,0) > 0)
    SET expandclauses = concat(trim(expandclauses),
     " and ((ta.scheduled_dt_tm >= datetimeadd(cnvtdatetime(request->beg_dt_tm), -ot.grace_period_mins/1440.0) ",
     " and ta.scheduled_dt_tm <= datetimeadd(cnvtdatetime(request->end_dt_tm), ot.grace_period_mins/1440.0))",
     " or (ta.task_dt_tm <= cnvtdatetime(request->end_dt_tm)")
   ELSE
    SET expandclauses = concat(trim(expandclauses),
     " and ((ta.task_dt_tm between cnvtdatetime(request->beg_dt_tm)",
     " and cnvtdatetime(request->end_dt_tm))",
     " or (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)")
   ENDIF
   IF ((((request->ignore_beg_dt_on_overdue_ind=1)) OR ((request->ignore_beg_dt_on_working_ind=1))) )
    IF ((request->ignore_beg_dt_on_overdue_ind=1))
     SET expandclauses = concat(trim(expandclauses)," and (ta.task_status_cd = task_status_overdue")
     IF ((request->ignore_beg_dt_on_working_ind=1))
      SET expandclauses = concat(trim(expandclauses)," or ta.task_status_cd = task_status_inprocess",
       " or ta.task_status_cd = task_status_validation")
     ENDIF
    ELSEIF ((request->ignore_beg_dt_on_working_ind=1))
     SET expandclauses = concat(trim(expandclauses)," and (ta.task_status_cd = task_status_inprocess",
      " or ta.task_status_cd = task_status_validation")
    ENDIF
    SET expandclauses = concat(trim(expandclauses)," ) or ((ta.task_class_cd = task_class_prn",
     " or ta.task_class_cd = task_class_continuous"," or ta.task_class_cd = task_class_nonscheduled)",
     " and ta.task_status_cd = task_status_pending)))")
   ELSE
    SET expandclauses = concat(trim(expandclauses)," and ((ta.task_class_cd = task_class_prn",
     " or ta.task_class_cd = task_class_continuous"," or ta.task_class_cd = task_class_nonscheduled)",
     " and ta.task_status_cd = task_status_pending)))")
   ENDIF
  ENDIF
  IF (task_type_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(task_type_index, 1, task_type_count, ta.task_type_cd, request->task_type_list[task_type_index].task_type_cd)"
    )
  ENDIF
  IF (task_status_count > 0)
   SET expandclauses = concat(trim(expandclauses),
" and expand(task_status_index, 1, task_status_count, ta.task_status_cd, request->task_status_list[task_status_index].statu\
s_cd)\
")
  ENDIF
  IF (task_class_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(task_class_index, 1, task_class_count, ta.task_class_cd, request->task_class_list[task_class_index].class_cd)"
    )
  ENDIF
  SELECT
   IF (person_count > 0
    AND encntr_count > 0)
    FROM (dummyt dref  WITH seq = value(reference_task_count)),
     (dummyt dpers  WITH seq = value(person_count)),
     (dummyt dencntr  WITH seq = value(encntr_count)),
     order_task ot,
     task_activity ta,
     task_activity_assignment taa
    PLAN (dref)
     JOIN (dpers)
     JOIN (dencntr)
     JOIN (ot
     WHERE (ot.reference_task_id=request->reference_task_list[dref.seq].reference_task_id))
     JOIN (ta
     WHERE ta.reference_task_id=ot.reference_task_id
      AND (ta.person_id=request->person_list[dpers.seq].person_id)
      AND (ta.encntr_id=request->encntr_list[dencntr.seq].encntr_id)
      AND parser(trim(expandclauses)))
     JOIN (taa
     WHERE (taa.task_id= Outerjoin(ta.task_id))
      AND (taa.active_ind= Outerjoin(1))
      AND (taa.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (taa.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY ta.task_id
   ELSEIF (person_count > 0)
    FROM (dummyt dref  WITH seq = value(reference_task_count)),
     (dummyt dpers  WITH seq = value(person_count)),
     order_task ot,
     task_activity ta,
     task_activity_assignment taa
    PLAN (dref)
     JOIN (dpers)
     JOIN (ot
     WHERE (ot.reference_task_id=request->reference_task_list[dref.seq].reference_task_id))
     JOIN (ta
     WHERE ta.reference_task_id=ot.reference_task_id
      AND (ta.person_id=request->person_list[dpers.seq].person_id)
      AND parser(trim(expandclauses)))
     JOIN (taa
     WHERE (taa.task_id= Outerjoin(ta.task_id))
      AND (taa.active_ind= Outerjoin(1))
      AND (taa.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (taa.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY ta.task_id
   ELSEIF (encntr_count > 0)
    FROM (dummyt dref  WITH seq = value(reference_task_count)),
     (dummyt dencntr  WITH seq = value(encntr_count)),
     order_task ot,
     task_activity ta,
     task_activity_assignment taa
    PLAN (dref)
     JOIN (dencntr)
     JOIN (ot
     WHERE (ot.reference_task_id=request->reference_task_list[dref.seq].reference_task_id))
     JOIN (ta
     WHERE ta.reference_task_id=ot.reference_task_id
      AND (ta.encntr_id=request->encntr_list[dencntr.seq].encntr_id)
      AND parser(trim(expandclauses)))
     JOIN (taa
     WHERE (taa.task_id= Outerjoin(ta.task_id))
      AND (taa.active_ind= Outerjoin(1))
      AND (taa.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (taa.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY ta.task_id
   ELSE
   ENDIF
   INTO "nl:"
   FROM (dummyt dref  WITH seq = value(reference_task_count)),
    order_task ot,
    task_activity ta,
    task_activity_assignment taa
   PLAN (dref)
    JOIN (ot
    WHERE (ot.reference_task_id=request->reference_task_list[dref.seq].reference_task_id))
    JOIN (ta
    WHERE ta.reference_task_id=ot.reference_task_id
     AND parser(trim(expandclauses)))
    JOIN (taa
    WHERE (taa.task_id= Outerjoin(ta.task_id))
     AND (taa.active_ind= Outerjoin(1))
     AND (taa.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (taa.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   ORDER BY ta.task_id
   HEAD REPORT
    task_count = 0, task_assign_count = 0
   HEAD ta.task_id
    task_count += 1
    IF (mod(task_count,25)=1)
     stat = alterlist(reply->task_list,(task_count+ 24))
    ENDIF
    reply->task_list[task_count].task_id = ta.task_id, reply->task_list[task_count].catalog_type_cd
     = ta.catalog_type_cd, reply->task_list[task_count].catalog_cd = ta.catalog_cd,
    reply->task_list[task_count].location_cd = ta.location_cd, reply->task_list[task_count].
    task_type_cd = ta.task_type_cd, reply->task_list[task_count].task_class_cd = ta.task_class_cd,
    reply->task_list[task_count].task_status_cd = ta.task_status_cd, reply->task_list[task_count].
    task_status_reason_cd = ta.task_status_reason_cd, reply->task_list[task_count].task_dt_tm = ta
    .task_dt_tm,
    reply->task_list[task_count].task_tz = ta.task_tz, reply->task_list[task_count].event_id = ta
    .event_id, reply->task_list[task_count].task_activity_cd = ta.task_activity_cd,
    reply->task_list[task_count].event_class_cd = ta.event_class_cd, reply->task_list[task_count].
    task_create_dt_tm = ta.task_create_dt_tm, reply->task_list[task_count].updt_cnt = ta.updt_cnt,
    reply->task_list[task_count].updt_dt_tm = ta.updt_dt_tm, reply->task_list[task_count].updt_id =
    ta.updt_id, reply->task_list[task_count].reschedule_ind = ta.reschedule_ind,
    reply->task_list[task_count].reschedule_reason_cd = ta.reschedule_reason_cd, reply->task_list[
    task_count].person_id = ta.person_id, reply->task_list[task_count].encntr_id = ta.encntr_id,
    reply->task_list[task_count].loc_bed_cd = ta.loc_bed_cd, reply->task_list[task_count].loc_room_cd
     = ta.loc_room_cd, reply->task_list[task_count].order_id = ta.order_id,
    reply->task_list[task_count].task_priority_cd = ta.task_priority_cd, reply->task_list[task_count]
    .med_order_type_cd = ta.med_order_type_cd, reply->task_list[task_count].template_task_flag = ta
    .template_task_flag
    IF ((((reply->task_list[task_count].task_class_cd=task_class_prn)) OR ((((reply->task_list[
    task_count].task_class_cd=task_class_continuous)) OR ((reply->task_list[task_count].task_class_cd
    =task_class_nonscheduled))) ))
     AND (reply->task_list[task_count].task_status_cd=task_status_pending)
     AND (reply->task_list[task_count].task_dt_tm < cnvtdatetime(sysdate)))
     reply->task_list[task_count].task_dt_tm = cnvtdatetime(sysdate)
    ENDIF
    reply->task_list[task_count].charted_by_agent_cd = ta.charted_by_agent_cd, reply->task_list[
    task_count].charted_by_agent_identifier = ta.charted_by_agent_identifier, reply->task_list[
    task_count].charting_context_reference = ta.charting_context_reference,
    reply->task_list[task_count].result_set_id = ta.result_set_id, reply->task_list[task_count].
    scheduled_dt_tm = ta.scheduled_dt_tm
    IF (ta.scheduled_dt_tm != null)
     reply->task_list[task_count].beg_grace_period_dt_tm = datetimeadd(cnvtdatetime(ta
       .scheduled_dt_tm),- ((ot.grace_period_mins/ 1440.0))), reply->task_list[task_count].
     end_grace_period_dt_tm = datetimeadd(cnvtdatetime(ta.scheduled_dt_tm),(ot.grace_period_mins/
      1440.0))
    ENDIF
    reply->task_list[task_count].reference_task_id = ta.reference_task_id, reply->task_list[
    task_count].task_description = ot.task_description, reply->task_list[task_count].
    chart_not_cmplt_ind = ot.chart_not_cmplt_ind,
    reply->task_list[task_count].quick_chart_done_ind = ot.quick_chart_done_ind, reply->task_list[
    task_count].quick_chart_ind = ot.quick_chart_ind, reply->task_list[task_count].
    quick_chart_notdone_ind = ot.quick_chart_notdone_ind,
    reply->task_list[task_count].cernertask_flag = ot.cernertask_flag, reply->task_list[task_count].
    event_cd = ot.event_cd, reply->task_list[task_count].reschedule_time = ot.reschedule_time,
    reply->task_list[task_count].dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->task_list[task_count]
    .capture_bill_info_ind = ot.capture_bill_info_ind, reply->task_list[task_count].ignore_req_ind =
    ot.ignore_req_ind,
    reply->task_list[task_count].allpositionchart_ind = ot.allpositionchart_ind, reply->task_list[
    task_count].grace_period_mins = ot.grace_period_mins, task_assign_count = 0
   DETAIL
    IF (taa.task_id > 0)
     task_assign_count += 1
     IF (mod(task_assign_count,10)=1)
      stat = alterlist(reply->task_list[task_count].assign_prsnl_list,(task_assign_count+ 9))
     ENDIF
     reply->task_list[task_count].assign_prsnl_list[task_assign_count].assign_prsnl_id = taa
     .assign_prsnl_id
    ENDIF
   FOOT  ta.task_id
    stat = alterlist(reply->task_list[task_count].assign_prsnl_list,task_assign_count)
   FOOT REPORT
    stat = alterlist(reply->task_list,task_count)
   WITH nocounter
  ;end select
  IF (task_count > 0)
   CALL retrievechartingagents(0)
   CALL retrieveordertaskpositions(0)
   IF ((request->get_order_info=1))
    CALL retrievetemplateorder(0)
   ENDIF
  ENDIF
 ENDIF
 IF (error(errmsg,0))
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
 ELSEIF (task_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
