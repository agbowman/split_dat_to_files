CREATE PROGRAM dcp_get_tasks_by_assign_nosec:dba
 DECLARE program_version = vc WITH private, constant("002")
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN")), protect
 DECLARE task_class_continuous = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT")), protect
 DECLARE task_class_nonscheduled = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH")), protect
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING")), protect
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE")), protect
 DECLARE task_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS")), protect
 DECLARE task_status_validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION")),
 protect
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE assign_prsnl_count = i4 WITH constant(size(request->assign_prsnl_list,5)), protect
 DECLARE task_status_count = i4 WITH constant(size(request->task_status_list,5)), protect
 DECLARE task_status_index = i4 WITH noconstant(1), protect
 DECLARE task_type_count = i4 WITH constant(size(request->task_type_list,5)), protect
 DECLARE task_type_index = i4 WITH noconstant(1), protect
 DECLARE task_class_count = i4 WITH constant(size(request->task_class_list,5)), protect
 DECLARE task_class_index = i4 WITH noconstant(1), protect
 DECLARE location_count = i4 WITH constant(size(request->location_list,5)), protect
 DECLARE location_index = i4 WITH noconstant(1), protect
 DECLARE task_count = i4 WITH noconstant(0), protect
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH noconstant(60)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE index1 = i4 WITH noconstant(0)
 DECLARE num1 = i4 WITH noconstant(0)
 DECLARE expandclauses = c1000 WITH noconstant(fillstring(1000," ")), protect
 SET expandclauses = concat(trim(expandclauses)," ta.active_ind = 1 ")
 SET reply->status_data.status = "F"
 IF (assign_prsnl_count > 0)
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
    " and expand(task_type_index, 1, task_type_count, ta.task_type_cd+0, request->task_type_list[task_type_index].task_type_cd)"
    )
  ENDIF
  IF (task_status_count > 0)
   SET expandclauses = concat(trim(expandclauses),
" and expand(task_status_index, 1, task_status_count, ta.task_status_cd+0, request->task_status_list[task_status_index].sta\
tus_cd)\
")
  ENDIF
  IF (task_class_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(task_class_index, 1, task_class_count, ta.task_class_cd+0, request->task_class_list[task_class_index].class_cd)"
    )
  ENDIF
  IF (location_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(location_index, 1, location_count, ta.location_cd+0, request->location_list[location_index].location_cd)"
    )
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(assign_prsnl_count)),
    task_activity_assignment taa1,
    task_activity ta,
    task_activity_assignment taa,
    prsnl p
   PLAN (d)
    JOIN (taa1
    WHERE (taa1.assign_prsnl_id=request->assign_prsnl_list[d.seq].assign_prsnl_id)
     AND taa1.active_ind=1
     AND taa1.beg_eff_dt_tm <= cnvtdatetime(sysdate)
     AND taa1.end_eff_dt_tm >= cnvtdatetime(sysdate))
    JOIN (ta
    WHERE ta.task_id=taa1.task_id
     AND ((ta.person_id+ 0) > context->last_person_id)
     AND parser(trim(expandclauses)))
    JOIN (taa
    WHERE (taa.task_id= Outerjoin(ta.task_id))
     AND (taa.active_ind= Outerjoin(1))
     AND (taa.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (taa.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (p
    WHERE (p.person_id= Outerjoin(taa.assign_prsnl_id)) )
   ORDER BY ta.person_id, ta.task_id
   HEAD REPORT
    task_count = 0, cancel_ind = 0, task_assign_count = 0
   HEAD ta.person_id
    newperson = 1
   HEAD ta.task_id
    IF ((task_count >= request->dcp_task_limit)
     AND newperson=1)
     CALL cancel(1), cancel_ind = 1
    ELSE
     newperson = 0, task_count += 1
     IF (mod(task_count,25)=1)
      stat = alterlist(reply->task_list,(task_count+ 24))
     ENDIF
     reply->task_list[task_count].task_id = ta.task_id
     IF (ta.catalog_type_cd > 0)
      reply->task_list[task_count].catalog_type_cd = ta.catalog_type_cd, reply->task_list[task_count]
      .catalog_type_mean = uar_get_code_meaning(ta.catalog_type_cd), reply->task_list[task_count].
      catalog_type_disp = uar_get_code_display(ta.catalog_type_cd)
     ENDIF
     reply->task_list[task_count].catalog_cd = ta.catalog_cd
     IF (ta.location_cd > 0)
      reply->task_list[task_count].location_cd = ta.location_cd, reply->task_list[task_count].
      location_mean = uar_get_code_meaning(ta.location_cd), reply->task_list[task_count].
      location_disp = uar_get_code_display(ta.location_cd)
     ENDIF
     reply->task_list[task_count].reference_task_id = ta.reference_task_id
     IF (ta.task_type_cd > 0)
      reply->task_list[task_count].task_type_cd = ta.task_type_cd, reply->task_list[task_count].
      task_type_mean = uar_get_code_meaning(ta.task_type_cd), reply->task_list[task_count].
      task_type_disp = uar_get_code_display(ta.task_type_cd)
     ENDIF
     IF (ta.task_class_cd > 0)
      reply->task_list[task_count].task_class_cd = ta.task_class_cd, reply->task_list[task_count].
      task_class_mean = uar_get_code_meaning(ta.task_class_cd), reply->task_list[task_count].
      task_class_disp = uar_get_code_display(ta.task_class_cd)
     ENDIF
     IF (ta.task_status_cd > 0)
      reply->task_list[task_count].task_status_cd = ta.task_status_cd, reply->task_list[task_count].
      task_status_mean = uar_get_code_meaning(ta.task_status_cd), reply->task_list[task_count].
      task_status_disp = uar_get_code_display(ta.task_status_cd)
     ENDIF
     IF (ta.task_status_reason_cd > 0)
      reply->task_list[task_count].task_status_reason_cd = ta.task_status_reason_cd, reply->
      task_list[task_count].task_status_reason_mean = uar_get_code_meaning(ta.task_status_reason_cd),
      reply->task_list[task_count].task_status_reason_disp = uar_get_code_display(ta
       .task_status_reason_cd)
     ENDIF
     reply->task_list[task_count].task_dt_tm = ta.task_dt_tm, reply->task_list[task_count].task_tz =
     ta.task_tz, reply->task_list[task_count].event_id = ta.event_id
     IF (ta.task_activity_cd > 0)
      reply->task_list[task_count].task_activity_cd = ta.task_activity_cd, reply->task_list[
      task_count].task_activity_mean = uar_get_code_meaning(ta.task_activity_cd), reply->task_list[
      task_count].task_activity_disp = uar_get_code_display(ta.task_activity_cd)
     ENDIF
     reply->task_list[task_count].msg_text_id = ta.msg_text_id, reply->task_list[task_count].
     msg_subject_cd = ta.msg_subject_cd, reply->task_list[task_count].msg_subject = ta.msg_subject,
     reply->task_list[task_count].msg_sender_id = ta.msg_sender_id, reply->task_list[task_count].
     confidential_ind = ta.confidential_ind, reply->task_list[task_count].read_ind = ta.read_ind,
     reply->task_list[task_count].delivery_ind = ta.delivery_ind
     IF (ta.event_class_cd > 0)
      reply->task_list[task_count].event_class_cd = ta.event_class_cd, reply->task_list[task_count].
      event_class_mean = uar_get_code_meaning(ta.event_class_cd), reply->task_list[task_count].
      event_class_disp = uar_get_code_display(ta.event_class_cd)
     ENDIF
     reply->task_list[task_count].task_create_dt_tm = ta.task_create_dt_tm, reply->task_list[
     task_count].updt_cnt = ta.updt_cnt, reply->task_list[task_count].updt_dt_tm = ta.updt_dt_tm,
     reply->task_list[task_count].updt_id = ta.updt_id, reply->task_list[task_count].reschedule_ind
      = ta.reschedule_ind
     IF (ta.reschedule_reason_cd > 0)
      reply->task_list[task_count].reschedule_reason_cd = ta.reschedule_reason_cd, reply->task_list[
      task_count].reschedule_reason_mean = uar_get_code_meaning(ta.reschedule_reason_cd), reply->
      task_list[task_count].reschedule_reason_disp = uar_get_code_display(ta.reschedule_reason_cd)
     ENDIF
     reply->task_list[task_count].person_id = ta.person_id, reply->task_list[task_count].encntr_id =
     ta.encntr_id, reply->task_list[task_count].container_id = ta.container_id
     IF (ta.loc_bed_cd > 0)
      reply->task_list[task_count].loc_bed_cd = ta.loc_bed_cd, reply->task_list[task_count].
      loc_bed_mean = uar_get_code_meaning(ta.loc_bed_cd), reply->task_list[task_count].loc_bed_disp
       = uar_get_code_display(ta.loc_bed_cd)
     ENDIF
     IF (ta.loc_room_cd > 0)
      reply->task_list[task_count].loc_room_cd = ta.loc_room_cd, reply->task_list[task_count].
      loc_room_mean = uar_get_code_meaning(ta.loc_room_cd), reply->task_list[task_count].
      loc_room_disp = uar_get_code_display(ta.loc_room_cd)
     ENDIF
     reply->task_list[task_count].order_id = ta.order_id, reply->task_list[task_count].
     task_security_flag = 1
     IF (ta.task_priority_cd > 0)
      reply->task_list[task_count].task_priority_cd = ta.task_priority_cd, reply->task_list[
      task_count].task_priority_mean = uar_get_code_meaning(ta.task_priority_cd), reply->task_list[
      task_count].task_priority_disp = uar_get_code_display(ta.task_priority_cd)
     ENDIF
     reply->task_list[task_count].med_order_type_cd = ta.med_order_type_cd, reply->task_list[
     task_count].template_task_flag = ta.template_task_flag, task_assign_count = 0
     IF ((((reply->task_list[task_count].task_class_cd=task_class_prn)) OR ((((reply->task_list[
     task_count].task_class_cd=task_class_continuous)) OR ((reply->task_list[task_count].
     task_class_cd=task_class_nonscheduled))) ))
      AND (reply->task_list[task_count].task_status_cd=task_status_pending)
      AND (reply->task_list[task_count].task_dt_tm < cnvtdatetime(sysdate)))
      reply->task_list[task_count].task_dt_tm = cnvtdatetime(sysdate)
     ENDIF
     reply->task_list[task_count].charted_by_agent_cd = ta.charted_by_agent_cd, reply->task_list[
     task_count].charted_by_agent_identifier = ta.charted_by_agent_identifier, reply->task_list[
     task_count].charting_context_reference = ta.charting_context_reference,
     reply->task_list[task_count].result_set_id = ta.result_set_id, reply->task_list[task_count].
     scheduled_dt_tm = ta.scheduled_dt_tm, reply->task_list[task_count].comments = ta.comments,
     reply->task_list[task_count].suggested_entity_name = ta.suggested_entity_name, reply->task_list[
     task_count].suggested_entity_id = ta.suggested_entity_id, reply->task_list[task_count].
     source_tag = ta.source_tag,
     reply->task_list[task_count].performed_prsnl_id = ta.performed_prsnl_id
    ENDIF
   DETAIL
    IF (cancel_ind=0)
     IF (taa.task_id > 0)
      task_assign_count += 1
      IF (mod(task_assign_count,10)=1)
       stat = alterlist(reply->task_list[task_count].assign_prsnl_list,(task_assign_count+ 9))
      ENDIF
      reply->task_list[task_count].assign_prsnl_list[task_assign_count].assign_prsnl_id = taa
      .assign_prsnl_id, reply->task_list[task_count].assign_prsnl_list[task_assign_count].
      assign_prsnl_name = p.name_full_formatted, reply->task_list[task_count].assign_prsnl_list[
      task_assign_count].updt_cnt = taa.updt_cnt
     ENDIF
    ENDIF
   FOOT  ta.task_id
    IF (cancel_ind=0)
     stat = alterlist(reply->task_list[task_count].assign_prsnl_list,task_assign_count)
    ENDIF
   FOOT  ta.person_id
    stat = 0
   FOOT REPORT
    stat = alterlist(reply->task_list,task_count)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE program_version_dcp_get_order_task_info = vc WITH private, constant("005")
 IF (size(reply->task_list,5) > 0)
  DECLARE charting_agent_cnt = i4 WITH noconstant(0)
  SET nstart = 1
  SET ntotal2 = size(reply->task_list,5)
  SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
  SET stat = alterlist(reply->task_list,ntotal)
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET reply->task_list[idx].reference_task_id = reply->task_list[ntotal2].reference_task_id
  ENDFOR
  SELECT INTO "nl:"
   index = locateval(num1,1,ntotal2,ot.reference_task_id,reply->task_list[num1].reference_task_id)
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    order_task ot
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (ot
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ot.reference_task_id,reply->task_list[idx].
     reference_task_id))
   ORDER BY index
   HEAD index
    index1 = locateval(num1,1,ntotal2,ot.reference_task_id,reply->task_list[num1].reference_task_id)
    WHILE (index1 != 0)
      reply->task_list[index1].task_description = ot.task_description, reply->task_list[index1].
      chart_not_cmplt_ind = ot.chart_not_cmplt_ind, reply->task_list[index1].quick_chart_done_ind =
      ot.quick_chart_done_ind,
      reply->task_list[index1].quick_chart_ind = ot.quick_chart_ind, reply->task_list[index1].
      quick_chart_notdone_ind = ot.quick_chart_notdone_ind, reply->task_list[index1].cernertask_flag
       = ot.cernertask_flag,
      reply->task_list[index1].event_cd = ot.event_cd, reply->task_list[index1].reschedule_time = ot
      .reschedule_time, reply->task_list[index1].dcp_forms_ref_id = ot.dcp_forms_ref_id,
      reply->task_list[index1].capture_bill_info_ind = ot.capture_bill_info_ind, reply->task_list[
      index1].ignore_req_ind = ot.ignore_req_ind, reply->task_list[index1].allpositionchart_ind = ot
      .allpositionchart_ind,
      reply->task_list[index1].grace_period_mins = ot.grace_period_mins
      IF ((reply->task_list[index1].allpositionchart_ind=1))
       reply->task_list[index1].ability_ind = 1
      ENDIF
      index1 = locateval(num1,(index1+ 1),ntotal2,ot.reference_task_id,reply->task_list[num1].
       reference_task_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    task_charting_agent_r tcar
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (tcar
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),tcar.reference_task_id,reply->task_list[idx].
     reference_task_id))
   HEAD tcar.reference_task_id
    charting_agent_cnt = 0
   DETAIL
    charting_agent_cnt += 1, index = locateval(num1,1,ntotal2,tcar.reference_task_id,reply->
     task_list[num1].reference_task_id)
    WHILE (index != 0)
      stat = alterlist(reply->task_list[index].charting_agent_list,charting_agent_cnt), reply->
      task_list[index].charting_agent_list[charting_agent_cnt].charting_agent_cd = tcar
      .charting_agent_cd, reply->task_list[index].charting_agent_list[charting_agent_cnt].
      charting_agent_entity_name = tcar.charting_agent_entity_name,
      reply->task_list[index].charting_agent_list[charting_agent_cnt].charting_agent_entity_id = tcar
      .charting_agent_entity_id, reply->task_list[index].charting_agent_list[charting_agent_cnt].
      charting_agent_identifier = tcar.charting_agent_identifier, index = locateval(num1,(index+ 1),
       ntotal2,tcar.reference_task_id,reply->task_list[num1].reference_task_id)
    ENDWHILE
   WITH nocounter
  ;end select
  IF ((request->user_position_cd > 0))
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_task_position_xref otp
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (otp
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),otp.reference_task_id,reply->task_list[idx].
      reference_task_id)
      AND (otp.position_cd=request->user_position_cd))
    DETAIL
     index = locateval(num1,1,ntotal2,otp.reference_task_id,reply->task_list[num1].reference_task_id)
     WHILE (index != 0)
      reply->task_list[index].ability_ind = 1,index = locateval(num1,(index+ 1),ntotal2,otp
       .reference_task_id,reply->task_list[num1].reference_task_id)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->task_list,ntotal2)
 ENDIF
 SET context->more_data_ind = 0
 SET context->last_person_id = 0
 SET reply->more_data_ind = 0
 IF (error(errmsg,0))
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
 ELSEIF (task_count > 0)
  SET reply->status_data.status = "S"
  IF ((task_count >= request->dcp_task_limit))
   SET reply->more_data_ind = 1
   SET context->more_data_ind = 1
   SET context->last_person_id = reply->task_list[task_count].person_id
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
