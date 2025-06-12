CREATE PROGRAM dcp_get_activity_tasks:dba
 RECORD internal(
   1 name_value_list[*]
     2 name = c5
     2 value = f8
 )
 SET reply->status_data.status = "F"
 SET task_activity_where = fillstring(20000," ")
 SET task_activity_assign_where = fillstring(20000," ")
 SET task_type_where = fillstring(5000," ")
 SET loc_bed_where = fillstring(5000," ")
 SET order_task_event_where = fillstring(5000," ")
 SET task_status_where = fillstring(1000," ")
 SET task_class_where = fillstring(1000," ")
 SET task_cnt = 0
 SET total_selects_needed = 1
 SET select_cnt = 0
 SET max_tasks = 1000
 SET continue_flag = 0
 SET in_max = 200
 SET temp = 0
 SET cnt = 0
 DECLARE dropped = f8 WITH constant(request->dropped_cd)
 DECLARE inerror = f8 WITH constant(request->inerror_cd)
 DECLARE overdue = f8 WITH constant(request->overdue_cd)
 DECLARE inprocess = f8 WITH constant(request->inprocess_cd)
 DECLARE prn = f8 WITH constant(request->prn_cd)
 DECLARE continuous = f8 WITH constant(request->continuous_cd)
 DECLARE deleted = f8 WITH constant(request->deleted_cd)
 DECLARE nonscheduled = f8 WITH constant(request->nonscheduled_cd)
 DECLARE pending = f8 WITH constant(request->pending_cd)
 DECLARE validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 IF (validation <= 0)
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  GO TO exit_script
 ENDIF
 SET assigned_to_get = 0
 SET persons_to_get = 0
 SET locations_to_get = 0
 SET beds_to_get = 0
 SET orders_to_get = 0
 SET template_orders_to_get = 0
 SET tasks_to_get = 0
 SET events_to_get = 0
 SET types_to_get = 0
 SET encntrs_to_get = 0
 SET status_not_to_get = 0
 SET class_not_to_get = 0
 SET name_value_cnt = 0
 SET assigned_to_get = cnvtint(size(request->assign_prsnl_list,5))
 SET persons_to_get = cnvtint(size(request->person_list,5))
 SET locations_to_get = cnvtint(size(request->location_list,5))
 SET beds_to_get = cnvtint(size(request->loc_bed_list,5))
 SET orders_to_get = cnvtint(size(request->order_list,5))
 SET template_orders_to_get = cnvtint(size(request->template_order_list,5))
 SET tasks_to_get = cnvtint(size(request->task_list,5))
 SET events_to_get = cnvtint(size(request->event_list,5))
 SET types_to_get = cnvtint(size(request->type_list,5))
 SET encntrs_to_get = cnvtint(size(request->encntr_list,5))
 SET status_not_to_get = cnvtint(size(request->status_filter_off_list,5))
 SET class_not_to_get = cnvtint(size(request->class_filter_off_list,5))
 IF (assigned_to_get > 0)
  IF (((persons_to_get > 0) OR ((((request->assigned_loc_ind=1)
   AND ((locations_to_get > 0) OR (beds_to_get > 0)) ) OR ((request->task_type_ind=1)
   AND types_to_get > 0)) )) )
   SET total_selects_needed += 1
  ENDIF
 ENDIF
 IF (persons_to_get > 0
  AND encntrs_to_get > 0)
  SET persons_to_get = 0
 ENDIF
 CALL echo(build("total selects needed:  ",total_selects_needed))
 CALL echo(build("Locations to get:  ",locations_to_get))
 IF (locations_to_get > 0)
  FOR (cnt = 1 TO locations_to_get)
    SET name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "LOC"
    SET internal->name_value_list[name_value_cnt].value = request->location_list[cnt].location_cd
  ENDFOR
 ENDIF
 CALL echo(build("Beds to get:  ",beds_to_get))
 IF (beds_to_get > 0)
  FOR (cnt = 1 TO beds_to_get)
    SET name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "BED"
    SET internal->name_value_list[name_value_cnt].value = request->loc_bed_list[cnt].loc_bed_cd
  ENDFOR
 ENDIF
 CALL echo(build("Orders to get:  ",orders_to_get))
 IF (orders_to_get > 0)
  FOR (cnt = 1 TO orders_to_get)
    SET name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "ORDER"
    SET internal->name_value_list[name_value_cnt].value = request->order_list[cnt].order_id
  ENDFOR
 ENDIF
 CALL echo(build("Template Orders to get:  ",template_orders_to_get))
 IF (template_orders_to_get > 0)
  SELECT DISTINCT INTO "nl:"
   o.template_order_id, o.order_id
   FROM (dummyt d  WITH seq = value(template_orders_to_get)),
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.template_order_id=request->template_order_list[d.seq].template_order_id))
   DETAIL
    orders_to_get += 1, name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     stat = alterlist(internal->name_value_list,(name_value_cnt+ 5))
    ENDIF
    internal->name_value_list[name_value_cnt].name = "ORDER", internal->name_value_list[
    name_value_cnt].value = o.order_id
   WITH nocounter
  ;end select
  IF (orders_to_get <= 0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(build("Tasks to get:  ",tasks_to_get))
 IF (tasks_to_get > 0)
  FOR (cnt = 1 TO tasks_to_get)
    SET name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "TASK"
    SET internal->name_value_list[name_value_cnt].value = request->task_list[cnt].task_id
  ENDFOR
 ENDIF
 CALL echo(build("Events to get:  ",events_to_get))
 IF (events_to_get > 0)
  FOR (cnt = 1 TO events_to_get)
    SET name_value_cnt += 1
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "EVENT"
    SET internal->name_value_list[name_value_cnt].value = request->event_list[cnt].event_id
  ENDFOR
 ENDIF
 SET stat = alterlist(internal->name_value_list,name_value_cnt)
 CALL echo(build("task types to get:  ",types_to_get))
 IF (types_to_get > 0)
  SET task_type_where = concat(trim(task_type_where)," and (ta.task_type_cd in (")
  SET last_type_to_get = ((types_to_get - in_max)+ 1)
  IF (last_type_to_get < 1)
   SET last_type_to_get = 1
  ENDIF
  WHILE (types_to_get >= last_type_to_get)
   IF (types_to_get != last_type_to_get)
    SET task_type_where = concat(trim(task_type_where),trim(cnvtstring(request->type_list[
       types_to_get].task_type_cd,20,1)),",")
   ELSE
    SET task_type_where = concat(trim(task_type_where),trim(cnvtstring(request->type_list[
       types_to_get].task_type_cd,20,1)),")")
   ENDIF
   SET types_to_get -= 1
  ENDWHILE
  SET stat = alterlist(request->type_list,types_to_get)
  IF (types_to_get > 0)
   SET task_type_where = concat(trim(task_type_where),
    " or ta.task_type_cd = request->type_list[d3.seq]->task_type_cd)")
  ELSE
   SET task_type_where = concat(trim(task_type_where),")")
   SET types_to_get = 1
  ENDIF
 ELSE
  SET types_to_get = 1
 ENDIF
 CALL echo(build("task type where:  ",task_type_where))
 CALL echo(build("Name Value Cnt:  ",name_value_cnt))
 IF (name_value_cnt > 0)
  IF (((locations_to_get > 0) OR (beds_to_get > 0)) )
   SET loc_bed_where = concat(trim(loc_bed_where)," and (")
   IF (locations_to_get > 0)
    SET loc_bed_where = concat(trim(loc_bed_where)," (internal->name_value_list[d2.seq].name = 'LOC'",
     " and ta.location_cd = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (beds_to_get > 0)
    IF (locations_to_get > 0)
     SET loc_bed_where = concat(trim(loc_bed_where)," or")
    ENDIF
    SET loc_bed_where = concat(trim(loc_bed_where)," (internal->name_value_list[d2.seq].name = 'BED'",
     " and ta.loc_bed_cd = internal->name_value_list[d2.seq]->value)")
   ENDIF
   SET loc_bed_where = concat(trim(loc_bed_where)," )")
  ENDIF
 ENDIF
 IF (name_value_cnt > 0)
  IF (((orders_to_get > 0) OR (((tasks_to_get > 0) OR (events_to_get > 0)) )) )
   SET order_task_event_where = concat(trim(order_task_event_where)," and (")
   IF (orders_to_get > 0)
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'ORDER'",
     " and ta.order_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (tasks_to_get > 0)
    IF (orders_to_get > 0)
     SET order_task_event_where = concat(trim(order_task_event_where)," or")
    ENDIF
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'TASK'",
     " and ta.task_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (events_to_get > 0)
    IF (((orders_to_get > 0) OR (tasks_to_get > 0)) )
     SET order_task_event_where = concat(trim(order_task_event_where)," or")
    ENDIF
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'EVENT'",
     " and ta.event_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   SET order_task_event_where = concat(trim(order_task_event_where)," )")
  ENDIF
 ENDIF
 CALL echo(build("Status not to get:  ",status_not_to_get))
 IF (status_not_to_get > 0)
  FOR (cnt = 1 TO status_not_to_get)
    SET task_status_where = concat(trim(task_status_where)," and ta.task_status_cd != ",cnvtstring(
      request->status_filter_off_list[cnt].task_status_cd,20,1))
  ENDFOR
 ENDIF
 CALL echo(build("Class not to get:  ",class_not_to_get))
 IF (class_not_to_get > 0)
  FOR (cnt = 1 TO class_not_to_get)
    SET task_class_where = concat(trim(task_class_where)," and ta.task_class_cd != ",cnvtstring(
      request->class_filter_off_list[cnt].task_class_cd,20,1))
  ENDFOR
 ENDIF
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),"ta.active_ind = 1",
  " and ta.task_status_cd != DROPPED"," and ta.task_status_cd != INERROR",
  " and ta.task_status_cd != DELETED")
 IF ((request->assigned_loc_ind=0))
  SET task_activity_assign_where = concat(trim(task_activity_assign_where),trim(loc_bed_where))
 ENDIF
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),trim(task_type_where))
 IF ((request->beg_dt_tm > 0)
  AND (request->end_dt_tm > 0))
  SET task_activity_assign_where = concat(trim(task_activity_assign_where),
   " and ((ta.task_dt_tm between cnvtdatetime(request->beg_dt_tm)",
   " and cnvtdatetime(request->end_dt_tm))"," or (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)",
   " and (ta.task_status_cd = OVERDUE",
   " or ta.task_status_cd = INPROCESS"," or ta.task_status_cd = VALIDATION",
   " or ((ta.task_class_cd = PRN"," or ta.iv_ind = 1"," or ta.task_class_cd = CONTINUOUS",
   " or ta.task_class_cd = NONSCHEDULED)"," and ta.task_status_cd = PENDING))))")
 ENDIF
 IF ((request->med_flag=3))
  SET task_activity_assign_where = concat(trim(task_activity_assign_where),
   " and ta.iv_ind = request->iv_ind and ta.tpn_ind = request->tpn_ind")
 ENDIF
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),trim(task_status_where),
  trim(task_class_where))
 CALL echo(build("task activity assign where:  ",task_activity_assign_where))
 SET task_activity_where = concat(trim(task_activity_where),"ta.active_ind = 1",
  " and ta.task_status_cd != DROPPED"," and ta.task_status_cd != INERROR",
  " and ta.task_status_cd != DELETED")
 IF (persons_to_get > 0)
  SET task_activity_where = concat(trim(task_activity_where),
   " and ta.person_id = request->person_list[d1.seq]->person_id")
 ELSE
  SET persons_to_get = 1
 ENDIF
 IF (encntrs_to_get > 0)
  SET task_activity_where = concat(trim(task_activity_where),
   " and ta.encntr_id = request->encntr_list[d4.seq]->encntr_id")
 ELSE
  SET encntrs_to_get = 1
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),trim(order_task_event_where))
 SET task_activity_where = concat(trim(task_activity_where),trim(loc_bed_where))
 IF (name_value_cnt <= 0)
  SET name_value_cnt = 1
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),trim(task_type_where))
 IF ((request->beg_dt_tm > 0)
  AND (request->end_dt_tm > 0))
  SET task_activity_where = concat(trim(task_activity_where),
   " and ((ta.task_dt_tm between cnvtdatetime(request->beg_dt_tm)",
   " and cnvtdatetime(request->end_dt_tm))"," or (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)",
   " and (ta.task_status_cd = OVERDUE",
   " or ta.task_status_cd = INPROCESS"," or ta.task_status_cd = VALIDATION",
   " or ((ta.task_class_cd = PRN"," or ta.iv_ind = 1"," or ta.task_class_cd = CONTINUOUS",
   " or ta.task_class_cd = NONSCHEDULED)"," and ta.task_status_cd = PENDING))))")
 ENDIF
 IF ((request->med_flag=3))
  SET task_activity_where = concat(trim(task_activity_where),
   " and ta.iv_ind = request->iv_ind and ta.tpn_ind = request->tpn_ind")
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),trim(task_status_where),trim(
   task_class_where))
 CALL echo(build("task activity where:  ",task_activity_where))
 CALL echo(build("Entering select while, total_selects_needed:  ",total_selects_needed))
 WHILE (select_cnt < total_selects_needed)
   CALL echo(build("In the select while, select_cnt:  ",select_cnt))
   SET select_cnt += 1
   SELECT
    IF (assigned_to_get > 0)
     FROM (dummyt d1  WITH seq = value(assigned_to_get)),
      task_activity_assignment taa2,
      (dummyt d2  WITH seq = value(name_value_cnt)),
      (dummyt d3  WITH seq = value(types_to_get)),
      task_activity ta,
      (dummyt d5  WITH seq = 1),
      task_activity_assignment taa
     PLAN (d1)
      JOIN (taa2
      WHERE (taa2.assign_prsnl_id=request->assign_prsnl_list[d1.seq].assign_prsnl_id)
       AND taa2.active_ind=1
       AND taa2.beg_eff_dt_tm <= cnvtdatetime(sysdate)
       AND taa2.end_eff_dt_tm > cnvtdatetime(sysdate))
      JOIN (d2)
      JOIN (d3)
      JOIN (ta
      WHERE ta.task_id=taa2.task_id
       AND parser(trim(task_activity_assign_where)))
      JOIN (d5)
      JOIN (taa
      WHERE taa.task_id=ta.task_id
       AND taa.active_ind=1
       AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
       AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
    ELSE
     FROM (dummyt d1  WITH seq = value(persons_to_get)),
      (dummyt d2  WITH seq = value(name_value_cnt)),
      (dummyt d3  WITH seq = value(types_to_get)),
      (dummyt d4  WITH seq = value(encntrs_to_get)),
      task_activity ta,
      (dummyt d5  WITH seq = 1),
      task_activity_assignment taa
     PLAN (d1)
      JOIN (d2)
      JOIN (d3)
      JOIN (d4)
      JOIN (ta
      WHERE parser(trim(task_activity_where)))
      JOIN (d5)
      JOIN (taa
      WHERE taa.task_id=ta.task_id
       AND taa.active_ind=1
       AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
       AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
    ENDIF
    DISTINCT INTO "nl:"
    ta.task_id, taa.assign_prsnl_id, check = decode(taa.seq,"taa","z")
    ORDER BY ta.task_id, taa.assign_prsnl_id
    HEAD REPORT
     temp = 0
    HEAD ta.task_id
     task_assign_cnt = 0, continue_flag = 0
     IF (((task_cnt+ 1) <= max_tasks))
      continue_flag = 1, task_cnt += 1
      IF (task_cnt > size(reply->get_list,5))
       stat = alterlist(reply->get_list,(task_cnt+ 10))
      ENDIF
      reply->get_list[task_cnt].task_id = ta.task_id, reply->get_list[task_cnt].person_id = ta
      .person_id, reply->get_list[task_cnt].catalog_type_cd = ta.catalog_type_cd,
      reply->get_list[task_cnt].catalog_cd = ta.catalog_cd, reply->get_list[task_cnt].
      physician_order_ind = ta.physician_order_ind, reply->get_list[task_cnt].stat_ind = ta.stat_ind,
      reply->get_list[task_cnt].order_id = ta.order_id, reply->get_list[task_cnt].location_cd = ta
      .location_cd, reply->get_list[task_cnt].encntr_id = ta.encntr_id,
      reply->get_list[task_cnt].reference_task_id = ta.reference_task_id, reply->get_list[task_cnt].
      task_type_cd = ta.task_type_cd, reply->get_list[task_cnt].task_class_cd = ta.task_class_cd,
      reply->get_list[task_cnt].task_status_cd = ta.task_status_cd, reply->get_list[task_cnt].
      task_status_reason_cd = ta.task_status_reason_cd, reply->get_list[task_cnt].iv_ind = ta.iv_ind,
      reply->get_list[task_cnt].tpn_ind = ta.tpn_ind, reply->get_list[task_cnt].task_dt_tm = ta
      .task_dt_tm, reply->get_list[task_cnt].event_id = ta.event_id,
      reply->get_list[task_cnt].task_activity_cd = ta.task_activity_cd, reply->get_list[task_cnt].
      msg_text_id = ta.msg_text_id, reply->get_list[task_cnt].msg_subject_cd = ta.msg_subject_cd,
      reply->get_list[task_cnt].msg_subject = ta.msg_subject, reply->get_list[task_cnt].msg_sender_id
       = ta.msg_sender_id, reply->get_list[task_cnt].confidential_ind = ta.confidential_ind,
      reply->get_list[task_cnt].read_ind = ta.read_ind, reply->get_list[task_cnt].delivery_ind = ta
      .delivery_ind, reply->get_list[task_cnt].event_class_cd = ta.event_class_cd,
      reply->get_list[task_cnt].task_create_dt_tm = ta.task_create_dt_tm, reply->get_list[task_cnt].
      updt_cnt = ta.updt_cnt, reply->get_list[task_cnt].updt_dt_tm = ta.updt_dt_tm,
      reply->get_list[task_cnt].updt_id = ta.updt_id, reply->get_list[task_cnt].reschedule_ind = ta
      .reschedule_ind, reply->get_list[task_cnt].reschedule_reason_cd = ta.reschedule_reason_cd,
      reply->get_list[task_cnt].template_task_flag = ta.template_task_flag, reply->get_list[task_cnt]
      .med_order_type_cd = ta.med_order_type_cd
      IF ((((reply->get_list[task_cnt].task_class_cd=prn)) OR ((((reply->get_list[task_cnt].
      task_class_cd=continuous)) OR ((((reply->get_list[task_cnt].task_class_cd=nonscheduled)) OR ((
      reply->get_list[task_cnt].iv_ind=1))) )) ))
       AND (reply->get_list[task_cnt].task_status_cd=pending)
       AND (reply->get_list[task_cnt].task_dt_tm < cnvtdatetime(sysdate)))
       reply->get_list[task_cnt].task_dt_tm = cnvtdatetime(sysdate)
      ENDIF
     ENDIF
    HEAD taa.assign_prsnl_id
     IF (check="taa"
      AND continue_flag=1)
      task_assign_cnt += 1
      IF (task_assign_cnt > size(reply->get_list[task_cnt].assign_prsnl_list,5))
       stat = alterlist(reply->get_list[task_cnt].assign_prsnl_list,(task_assign_cnt+ 10))
      ENDIF
      reply->get_list[task_cnt].assign_prsnl_list[task_assign_cnt].assign_prsnl_id = taa
      .assign_prsnl_id, reply->get_list[task_cnt].assign_prsnl_list[task_assign_cnt].updt_cnt = taa
      .updt_cnt
     ENDIF
    DETAIL
     temp = 0
    FOOT  taa.assign_prsnl_id
     temp = 0
    FOOT  ta.task_id
     stat = alterlist(reply->get_list[task_cnt].assign_prsnl_list,task_assign_cnt)
    FOOT REPORT
     stat = alterlist(reply->get_list,task_cnt)
    WITH check, outerjoin = d5
   ;end select
   SET assigned_to_get = 0
 ENDWHILE
 CALL echo(build("person cnt:  ",persons_to_get))
 CALL echo(build("task types cnt:  ",types_to_get))
 CALL echo(build("encntr cnt:  ",encntrs_to_get))
 CALL echo(build("assign cnt:  ",assigned_to_get))
 CALL echo(build("loc_ind:  ",request->assigned_loc_ind))
 CALL echo(build("task_type_ind:  ",request->task_type_ind))
 FOR (x = 1 TO locations_to_get)
   CALL echo(build("loc:  ",request->location_list[x].location_cd))
 ENDFOR
 FOR (x = 1 TO cnvtint(size(request->type_list,5)))
   CALL echo(build("type:  ",request->type_list[x].task_type_cd))
 ENDFOR
 FOR (x = 1 TO encntrs_to_get)
   CALL echo(build("encntr:  ",request->encntr_list[x].encntr_id))
 ENDFOR
 CALL echo(build("beg date:  ",request->beg_dt_tm))
 CALL echo(build("end date:  ",request->end_dt_tm))
 CALL echo(build("# of tasks returned:  ",task_cnt))
#exit_script
 SET reply->status_data.status = "S"
END GO
