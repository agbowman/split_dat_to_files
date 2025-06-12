CREATE PROGRAM dcp_get_tasks_by_events_assign:dba
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN")), protect
 DECLARE task_class_continuous = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT")), protect
 DECLARE task_class_nonscheduled = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH")), protect
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING")), protect
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE")), protect
 DECLARE task_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS")), protect
 DECLARE task_status_validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION")),
 protect
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," ")), private
 DECLARE event_count = i4 WITH constant(size(request->event_list,5)), private
 DECLARE assign_prsnl_count = i4 WITH constant(size(request->assign_prsnl_list,5)), protect
 DECLARE task_status_count = i4 WITH constant(size(request->task_status_list,5)), protect
 DECLARE task_status_index = i4 WITH noconstant(1), protect
 DECLARE task_type_count = i4 WITH constant(size(request->task_type_list,5)), protect
 DECLARE task_type_index = i4 WITH noconstant(1), protect
 DECLARE task_class_count = i4 WITH constant(size(request->task_class_list,5)), protect
 DECLARE task_class_index = i4 WITH noconstant(1), protect
 DECLARE location_count = i4 WITH constant(size(request->location_list,5)), protect
 DECLARE location_index = i4 WITH noconstant(1), protect
 DECLARE internal_task_count = i4 WITH noconstant(0)
 DECLARE assign_task_count = i4 WITH noconstant(0)
 DECLARE expandclauses = c1000 WITH noconstant(fillstring(1000," ")), protect
 SET expandclauses = concat(trim(expandclauses)," ta.active_ind = 1 ")
 SET reply->status_data.status = "F"
 IF (event_count > 0
  AND assign_prsnl_count > 0)
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
  IF (location_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(location_index, 1, location_count, ta.location_cd, request->location_list[location_index].location_cd)"
    )
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(assign_prsnl_count)),
    task_activity_assignment taa,
    task_activity ta
   PLAN (d)
    JOIN (taa
    WHERE (taa.assign_prsnl_id=request->assign_prsnl_list[d.seq].assign_prsnl_id)
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
     AND taa.end_eff_dt_tm >= cnvtdatetime(sysdate))
    JOIN (ta
    WHERE ta.task_id=taa.task_id
     AND ((ta.person_id+ 0) > context->last_person_id)
     AND parser(trim(expandclauses)))
   ORDER BY ta.person_id
   HEAD REPORT
    internal_task_count = 0, cancel_ind = 0
   HEAD ta.person_id
    newperson = 1
   HEAD ta.task_id
    IF ((context->encntr_org_enabled=0)
     AND (request->force_encounter_sec_ind=0)
     AND (internal_task_count >= request->dcp_task_limit)
     AND newperson=1)
     CALL cancel(1), cancel_ind = 1
    ELSE
     newperson = 0, internal_task_count += 1, assign_task_count += 1
     IF (internal_task_count > size(request->task_list,5))
      stat = alterlist(request->task_list,(internal_task_count+ 24))
     ENDIF
     request->task_list[internal_task_count].task_id = ta.task_id
    ENDIF
   DETAIL
    stat = 0
   FOOT  ta.task_id
    stat = 0
   FOOT  ta.person_id
    stat = 0
   FOOT REPORT
    stat = alterlist(request->task_list,internal_task_count)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(event_count)),
    task_activity ta
   PLAN (d)
    JOIN (ta
    WHERE (ta.event_id=request->event_list[d.seq].event_id)
     AND ((ta.person_id+ 0) > context->last_person_id)
     AND parser(trim(expandclauses)))
   ORDER BY ta.person_id, ta.task_id
   HEAD REPORT
    cancel_ind = 0
   HEAD ta.person_id
    newperson = 1
   HEAD ta.task_id
    IF ((context->encntr_org_enabled=0)
     AND (request->force_encounter_sec_ind=0)
     AND ((internal_task_count - assign_task_count) >= request->dcp_task_limit)
     AND newperson=1)
     CALL cancel(1), cancel_ind = 1
    ELSE
     newperson = 0, internal_task_count += 1
     IF (internal_task_count > size(request->task_list,5))
      stat = alterlist(request->task_list,(internal_task_count+ 24))
     ENDIF
     request->task_list[internal_task_count].task_id = ta.task_id
    ENDIF
   DETAIL
    stat = 0
   FOOT  ta.task_id
    stat = 0
   FOOT  ta.person_id
    stat = 0
   FOOT REPORT
    stat = alterlist(request->task_list,internal_task_count)
   WITH nocounter
  ;end select
  SET context->more_data_ind = 0
  SET context->last_person_id = 0
  SET reply->more_data_ind = 0
  IF (error(errmsg,0))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  ELSEIF (internal_task_count=0)
   SET reply->status_data.status = "Z"
  ELSE
   IF ((context->encntr_org_enabled=0)
    AND (request->force_encounter_sec_ind=0))
    EXECUTE dcp_get_tasks_by_task_ids
   ELSE
    EXECUTE dcp_get_tasks_by_tasks_sec
   ENDIF
  ENDIF
 ENDIF
END GO
