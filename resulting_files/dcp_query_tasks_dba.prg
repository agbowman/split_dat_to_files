CREATE PROGRAM dcp_query_tasks:dba
 RECORD reply(
   1 task_list[*]
     2 task_id = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 catalog_type_mean = vc
     2 catalog_cd = f8
     2 stat_ind = i2
     2 location_cd = f8
     2 location_disp = vc
     2 location_mean = vc
     2 reference_task_id = f8
     2 task_type_cd = f8
     2 task_type_disp = vc
     2 task_type_mean = vc
     2 task_class_cd = f8
     2 task_class_disp = vc
     2 task_class_mean = vc
     2 task_status_cd = f8
     2 task_status_disp = vc
     2 task_status_mean = vc
     2 task_status_reason_cd = f8
     2 task_status_reason_disp = vc
     2 task_status_reason_mean = vc
     2 task_dt_tm = dq8
     2 event_id = f8
     2 task_activity_cd = f8
     2 task_activity_disp = vc
     2 task_activity_mean = vc
     2 msg_text_id = f8
     2 msg_subject_cd = f8
     2 msg_subject = vc
     2 msg_sender_id = f8
     2 msg_sender_name = vc
     2 confidential_ind = i2
     2 read_ind = i2
     2 delivery_ind = i2
     2 event_class_cd = f8
     2 event_class_disp = vc
     2 event_class_mean = vc
     2 task_create_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 reschedule_ind = i2
     2 reschedule_reason_cd = f8
     2 reschedule_reason_disp = vc
     2 reschedule_reason_mean = vc
     2 template_task_flag = i2
     2 med_order_type_cd = f8
     2 task_description = vc
     2 chart_not_cmplt_ind = i2
     2 quick_chart_done_ind = i2
     2 quick_chart_ind = i2
     2 quick_chart_notdone_ind = i2
     2 allpositionchart_ind = i2
     2 event_cd = f8
     2 reschedule_time = i4
     2 cernertask_flag = i2
     2 ability_ind = i2
     2 dcp_forms_ref_id = f8
     2 capture_bill_info_ind = i2
     2 ignore_req_ind = i2
     2 order_id = f8
     2 order_comment_ind = i2
     2 order_status_cd = f8
     2 template_order_id = f8
     2 stop_type_cd = f8
     2 projected_stop_dt_tm = dq8
     2 comment_type_mask = i4
     2 hna_mnemonic = vc
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 additive_cnt = i4
     2 order_detail_display_line = vc
     2 order_provider_id = f8
     2 order_dt_tm = dq8
     2 activity_type_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 need_rx_verify_ind = i2
     2 orderable_type_flag = i2
     2 need_nurse_review_ind = i2
     2 freq_type_flag = i2
     2 current_start_dt_tm = dq8
     2 template_order_flag = i2
     2 order_comment_text = vc
     2 parent_order_status_cd = f8
     2 parent_need_rx_verify_ind = i2
     2 parent_need_nurse_review_ind = i2
     2 parent_freq_type_flag = i2
     2 parent_stop_type_cd = f8
     2 parent_current_start_dt_tm = dq8
     2 parent_projected_stop_dt_tm = dq8
     2 route_detail_display = vc
     2 freq_detail_display = vc
     2 rsn_detail_display = vc
     2 frequency_cd = f8
     2 encntr_id = f8
     2 loc_room_cd = f8
     2 loc_room_disp = vc
     2 loc_room_mean = vc
     2 loc_bed_cd = f8
     2 loc_bed_disp = vc
     2 loc_bed_mean = vc
     2 isolation_cd = f8
     2 isolation_disp = vc
     2 isolation_mean = vc
     2 finnbr = vc
     2 mrn = vc
     2 person_id = f8
     2 person_name = vc
     2 updt_person_name = vc
     2 response_required_flag = i2
     2 last_done_dt_tm = dq8
     2 initial_volume = f8
     2 initial_dosage = f8
     2 admin_dosage = f8
     2 dosage_unit_cd = f8
     2 admin_site_cd = f8
     2 infusion_rate = f8
     2 infusion_unit_cd = f8
     2 iv_event_cd = f8
     2 task_priority_cd = f8
     2 task_priority_meaning = vc
     2 task_priority_display = vc
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 updt_cnt = i4
       3 assign_prsnl_name = vc
     2 task_tz = i4
     2 projected_stop_tz = i4
     2 order_tz = i4
     2 current_start_tz = i4
     2 parent_projected_stop_tz = i4
     2 parent_current_start_tz = i4
     2 last_done_tz = i4
     2 charted_by_agent_cd = f8
     2 charted_by_agent_identifier = vc
     2 charting_context_reference = vc
     2 charting_agent_list[*]
       3 charting_agent_cd = f8
       3 charting_agent_entity_name = vc
       3 charting_agent_entity_id = f8
       3 charting_agent_identifier = vc
     2 link_nbr = f8
     2 link_type_flag = i2
     2 template_core_action_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 name_value_list[*]
     2 name = c5
     2 value = f8
 )
 SET reply->status_data.status = "F"
 SET task_activity_where = fillstring(32000," ")
 SET task_activity_assign_where = fillstring(32000," ")
 SET task_type_where = fillstring(7000," ")
 SET loc_bed_where = fillstring(7000," ")
 SET order_task_event_where = fillstring(7000," ")
 SET task_status_where = fillstring(3000," ")
 SET task_class_where = fillstring(3000," ")
 SET task_location_where = fillstring(3000," ")
 SET nbroftasks = 0
 SET total_selects_needed = 1
 SET select_cnt = 0
 SET max_tasks = 1000
 SET continue_flag = 0
 SET in_max = 200
 SET cnt = 0
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE task_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE task_status_validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE task_class_continuous = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE task_class_nonscheduled = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH"))
 SET assigned_prsnl_cnt = cnvtint(size(request->assign_prsnl_list,5))
 SET person_cnt = cnvtint(size(request->person_list,5))
 SET location_cnt = cnvtint(size(request->location_list,5))
 SET bed_cnt = cnvtint(size(request->loc_bed_list,5))
 SET order_cnt = cnvtint(size(request->order_list,5))
 SET task_cnt = cnvtint(size(request->task_list,5))
 SET event_cnt = cnvtint(size(request->event_list,5))
 SET task_type_cnt = cnvtint(size(request->task_type_filter_list,5))
 SET encntr_cnt = cnvtint(size(request->encntr_list,5))
 SET status_filter_cnt = cnvtint(size(request->status_filter_list,5))
 SET class_filter_cnt = cnvtint(size(request->class_filter_list,5))
 SET location_filter_cnt = cnvtint(size(request->location_filter_list,5))
 SET loc_bed_filter_cnt = cnvtint(size(request->loc_bed_filter_list,5))
 SET name_value_cnt = 0
 IF (assigned_prsnl_cnt > 0
  AND (request->assign_prsnl_only_ind=0))
  SET total_selects_needed = (total_selects_needed+ 1)
 ENDIF
 IF (person_cnt > 0
  AND encntr_cnt > 0)
  SET person_cnt = 0
 ENDIF
 IF (location_cnt > 0)
  FOR (cnt = 1 TO location_cnt)
    SET name_value_cnt = (name_value_cnt+ 1)
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "LOC"
    SET internal->name_value_list[name_value_cnt].value = request->location_list[cnt].location_cd
  ENDFOR
 ENDIF
 IF (bed_cnt > 0)
  FOR (cnt = 1 TO bed_cnt)
    SET name_value_cnt = (name_value_cnt+ 1)
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "BED"
    SET internal->name_value_list[name_value_cnt].value = request->loc_bed_list[cnt].loc_bed_cd
  ENDFOR
 ENDIF
 IF (order_cnt > 0)
  FOR (cnt = 1 TO order_cnt)
    SET name_value_cnt = (name_value_cnt+ 1)
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "ORDER"
    SET internal->name_value_list[name_value_cnt].value = request->order_list[cnt].order_id
  ENDFOR
 ENDIF
 IF (task_cnt > 0)
  FOR (cnt = 1 TO task_cnt)
    SET name_value_cnt = (name_value_cnt+ 1)
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "TASK"
    SET internal->name_value_list[name_value_cnt].value = request->task_list[cnt].task_id
  ENDFOR
 ENDIF
 IF (event_cnt > 0)
  FOR (cnt = 1 TO event_cnt)
    SET name_value_cnt = (name_value_cnt+ 1)
    IF (name_value_cnt > size(internal->name_value_list,5))
     SET stat = alterlist(internal->name_value_list,(name_value_cnt+ 10))
    ENDIF
    SET internal->name_value_list[name_value_cnt].name = "EVENT"
    SET internal->name_value_list[name_value_cnt].value = request->event_list[cnt].event_id
  ENDFOR
 ENDIF
 SET stat = alterlist(internal->name_value_list,name_value_cnt)
 IF (task_type_cnt > 0)
  SET task_type_where = concat(trim(task_type_where)," AND (ta.task_type_cd IN (")
  SET last_type_to_get = ((task_type_cnt - in_max)+ 1)
  IF (last_type_to_get < 1)
   SET last_type_to_get = 1
  ENDIF
  WHILE (task_type_cnt >= last_type_to_get)
   IF (task_type_cnt != last_type_to_get)
    SET task_type_where = concat(trim(task_type_where),trim(cnvtstring(request->
       task_type_filter_list[task_type_cnt].task_type_cd)),",")
   ELSE
    SET task_type_where = concat(trim(task_type_where),trim(cnvtstring(request->
       task_type_filter_list[task_type_cnt].task_type_cd)),")")
   ENDIF
   SET task_type_cnt = (task_type_cnt - 1)
  ENDWHILE
  SET stat = alterlist(request->task_type_filter_list,task_type_cnt)
  IF (task_type_cnt > 0)
   SET task_type_where = concat(trim(task_type_where),
    " OR ta.task_type_cd = request->task_type_filter_list[d3.seq]->task_type_cd)")
  ELSE
   SET task_type_where = concat(trim(task_type_where),")")
   SET task_type_cnt = 1
  ENDIF
 ELSE
  SET task_type_cnt = 1
 ENDIF
 IF (name_value_cnt > 0)
  IF (((location_cnt > 0) OR (bed_cnt > 0)) )
   SET loc_bed_where = concat(trim(loc_bed_where)," and (")
   IF (location_cnt > 0)
    SET loc_bed_where = concat(trim(loc_bed_where)," (internal->name_value_list[d2.seq].name = 'LOC'",
     " AND ta.location_cd = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (bed_cnt > 0)
    IF (location_cnt > 0)
     SET loc_bed_where = concat(trim(loc_bed_where)," OR")
    ENDIF
    SET loc_bed_where = concat(trim(loc_bed_where)," (internal->name_value_list[d2.seq].name = 'BED'",
     " AND ta.loc_bed_cd = internal->name_value_list[d2.seq]->value)")
   ENDIF
   SET loc_bed_where = concat(trim(loc_bed_where)," )")
  ENDIF
 ENDIF
 IF (name_value_cnt > 0)
  IF (((order_cnt > 0) OR (((task_cnt > 0) OR (event_cnt > 0)) )) )
   SET order_task_event_where = concat(trim(order_task_event_where)," AND (")
   IF (order_cnt > 0)
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'ORDER'",
     " AND ta.order_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (task_cnt > 0)
    IF (order_cnt > 0)
     SET order_task_event_where = concat(trim(order_task_event_where)," OR")
    ENDIF
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'TASK'",
     " AND ta.task_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   IF (event_cnt > 0)
    IF (((order_cnt > 0) OR (task_cnt > 0)) )
     SET order_task_event_where = concat(trim(order_task_event_where)," OR")
    ENDIF
    SET order_task_event_where = concat(trim(order_task_event_where),
     " (internal->name_value_list[d2.seq].name = 'EVENT'",
     " AND ta.event_id = internal->name_value_list[d2.seq]->value)")
   ENDIF
   SET order_task_event_where = concat(trim(order_task_event_where)," )")
  ENDIF
 ENDIF
 IF (status_filter_cnt > 0)
  SET task_status_where = " AND ta.task_status_cd IN ("
  FOR (cnt = 1 TO status_filter_cnt)
   SET task_status_where = concat(trim(task_status_where),cnvtstring(request->status_filter_list[cnt]
     .status_cd))
   IF (cnt != status_filter_cnt)
    SET task_status_where = concat(trim(task_status_where),",")
   ENDIF
  ENDFOR
  SET task_status_where = concat(trim(task_status_where),")")
 ENDIF
 IF (class_filter_cnt > 0)
  SET task_class_where = " AND ta.task_class_cd IN ("
  FOR (cnt = 1 TO class_filter_cnt)
   SET task_class_where = concat(trim(task_class_where),cnvtstring(request->class_filter_list[cnt].
     class_cd))
   IF (cnt != class_filter_cnt)
    SET task_class_where = concat(trim(task_class_where),",")
   ENDIF
  ENDFOR
  SET task_class_where = concat(trim(task_class_where),")")
 ENDIF
 IF (location_filter_cnt > 0)
  SET task_location_where = " AND ta.location_cd IN ("
  FOR (cnt = 1 TO location_filter_cnt)
   SET task_location_where = concat(trim(task_location_where),cnvtstring(request->
     location_filter_list[cnt].location_cd))
   IF (cnt != location_filter_cnt)
    SET task_location_where = concat(trim(task_location_where),",")
   ENDIF
  ENDFOR
  SET task_location_where = concat(trim(task_location_where),")")
 ENDIF
 IF (loc_bed_filter_cnt > 0)
  SET task_location_where = concat(trim(task_location_where)," AND ta.loc_bed_cd IN (")
  FOR (cnt = 1 TO loc_bed_filter_cnt)
   SET task_location_where = concat(trim(task_location_where),cnvtstring(request->
     loc_bed_filter_list[cnt].loc_bed_cd))
   IF (cnt != loc_bed_filter_cnt)
    SET task_location_where = concat(trim(task_location_where),",")
   ENDIF
  ENDFOR
  SET task_location_where = concat(trim(task_location_where),")")
 ENDIF
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),"ta.active_ind = 1")
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),trim(task_type_where))
 SET task_activity_assign_where = concat(trim(task_activity_assign_where),trim(task_status_where),
  trim(task_class_where),trim(task_location_where))
 IF ((request->beg_dt_tm > 0)
  AND (request->end_dt_tm > 0))
  SET task_activity_assign_where = concat(trim(task_activity_assign_where),
   " AND ((ta.task_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm)",
   " AND cnvtdatetime(request->end_dt_tm))"," OR (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)",
   " AND (ta.task_status_cd = TASK_STATUS_OVERDUE",
   " OR ta.task_status_cd = TASK_STATUS_INPROCESS"," OR ta.task_status_cd = TASK_STATUS_VALIDATION",
   " OR ((ta.task_class_cd = TASK_CLASS_PRN"," OR ta.task_class_cd = TASK_CLASS_CONTINUOUS",
   " OR ta.task_class_cd = TASK_CLASS_NONSCHEDULED)",
   " AND ta.task_status_cd = TASK_STATUS_PENDING))))")
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),"ta.active_ind = 1")
 IF (person_cnt > 0)
  SET task_activity_where = concat(trim(task_activity_where),
   " AND ta.person_id = request->person_list[d1.seq]->person_id")
 ELSE
  SET person_cnt = 1
 ENDIF
 IF (encntr_cnt > 0)
  SET task_activity_where = concat(trim(task_activity_where),
   " AND ta.encntr_id = request->encntr_list[d4.seq]->encntr_id")
 ELSE
  SET encntr_cnt = 1
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),trim(order_task_event_where))
 SET task_activity_where = concat(trim(task_activity_where),trim(loc_bed_where))
 IF (name_value_cnt <= 0)
  SET name_value_cnt = 1
 ENDIF
 SET task_activity_where = concat(trim(task_activity_where),trim(task_type_where))
 SET task_activity_where = concat(trim(task_activity_where),trim(task_status_where),trim(
   task_class_where),trim(task_location_where))
 IF ((request->beg_dt_tm > 0)
  AND (request->end_dt_tm > 0))
  SET task_activity_where = concat(trim(task_activity_where),
   " AND ((ta.task_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm)",
   " AND cnvtdatetime(request->end_dt_tm))"," OR (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)",
   " AND (ta.task_status_cd = TASK_STATUS_OVERDUE",
   " OR ta.task_status_cd = TASK_STATUS_INPROCESS"," OR ta.task_status_cd = TASK_STATUS_VALIDATION",
   " OR ((ta.task_class_cd = TASK_CLASS_PRN"," OR ta.task_class_cd = TASK_CLASS_CONTINUOUS",
   " OR ta.task_class_cd = TASK_CLASS_NONSCHEDULED)",
   " AND ta.task_status_cd = TASK_STATUS_PENDING))))")
 ENDIF
 WHILE (select_cnt < total_selects_needed)
   SET select_cnt = (select_cnt+ 1)
   SELECT
    IF (assigned_prsnl_cnt > 0)
     FROM (dummyt d1  WITH seq = value(assigned_prsnl_cnt)),
      task_activity_assignment taa2,
      (dummyt d2  WITH seq = value(name_value_cnt)),
      (dummyt d3  WITH seq = value(task_type_cnt)),
      task_activity ta,
      task_activity_assignment taa,
      prsnl psl
     PLAN (d1)
      JOIN (taa2
      WHERE (taa2.assign_prsnl_id=request->assign_prsnl_list[d1.seq].assign_prsnl_id)
       AND taa2.active_ind=1
       AND taa2.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND taa2.end_eff_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d2)
      JOIN (d3)
      JOIN (ta
      WHERE ta.task_id=taa2.task_id
       AND parser(trim(task_activity_assign_where)))
      JOIN (taa
      WHERE taa.task_id=outerjoin(ta.task_id)
       AND taa.active_ind=outerjoin(1)
       AND taa.beg_eff_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND taa.end_eff_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (psl
      WHERE psl.person_id=outerjoin(taa.assign_prsnl_id))
    ELSE
     FROM (dummyt d1  WITH seq = value(person_cnt)),
      (dummyt d2  WITH seq = value(name_value_cnt)),
      (dummyt d3  WITH seq = value(task_type_cnt)),
      (dummyt d4  WITH seq = value(encntr_cnt)),
      task_activity ta,
      task_activity_assignment taa,
      prsnl psl
     PLAN (d1)
      JOIN (d2)
      JOIN (d3)
      JOIN (d4)
      JOIN (ta
      WHERE parser(trim(task_activity_where)))
      JOIN (taa
      WHERE taa.task_id=outerjoin(ta.task_id)
       AND taa.active_ind=outerjoin(1)
       AND taa.beg_eff_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND taa.end_eff_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (psl
      WHERE psl.person_id=outerjoin(taa.assign_prsnl_id))
    ENDIF
    DISTINCT INTO "nl:"
    ORDER BY ta.task_id, taa.assign_prsnl_id
    HEAD REPORT
     continue_flag = 0
    HEAD ta.task_id
     task_assign_cnt = 0, continue_flag = 0
     IF (((nbroftasks+ 1) <= max_tasks))
      continue_flag = 1, nbroftasks = (nbroftasks+ 1)
      IF (nbroftasks > size(reply->task_list,5))
       stat = alterlist(reply->task_list,(nbroftasks+ 10))
      ENDIF
      reply->task_list[nbroftasks].task_id = ta.task_id, reply->task_list[nbroftasks].person_id = ta
      .person_id, reply->task_list[nbroftasks].catalog_type_cd = ta.catalog_type_cd,
      reply->task_list[nbroftasks].catalog_cd = ta.catalog_cd, reply->task_list[nbroftasks].stat_ind
       = ta.stat_ind, reply->task_list[nbroftasks].order_id = ta.order_id,
      reply->task_list[nbroftasks].location_cd = ta.location_cd, reply->task_list[nbroftasks].
      encntr_id = ta.encntr_id, reply->task_list[nbroftasks].reference_task_id = ta.reference_task_id,
      reply->task_list[nbroftasks].task_type_cd = ta.task_type_cd, reply->task_list[nbroftasks].
      task_class_cd = ta.task_class_cd, reply->task_list[nbroftasks].task_status_cd = ta
      .task_status_cd,
      reply->task_list[nbroftasks].task_status_reason_cd = ta.task_status_reason_cd, reply->
      task_list[nbroftasks].task_dt_tm = ta.task_dt_tm, reply->task_list[nbroftasks].event_id = ta
      .event_id,
      reply->task_list[nbroftasks].task_activity_cd = ta.task_activity_cd, reply->task_list[
      nbroftasks].msg_text_id = ta.msg_text_id, reply->task_list[nbroftasks].msg_subject_cd = ta
      .msg_subject_cd,
      reply->task_list[nbroftasks].msg_subject = ta.msg_subject, reply->task_list[nbroftasks].
      msg_sender_id = ta.msg_sender_id, reply->task_list[nbroftasks].confidential_ind = ta
      .confidential_ind,
      reply->task_list[nbroftasks].read_ind = ta.read_ind, reply->task_list[nbroftasks].delivery_ind
       = ta.delivery_ind, reply->task_list[nbroftasks].event_class_cd = ta.event_class_cd,
      reply->task_list[nbroftasks].task_create_dt_tm = ta.task_create_dt_tm, reply->task_list[
      nbroftasks].updt_cnt = ta.updt_cnt, reply->task_list[nbroftasks].updt_dt_tm = ta.updt_dt_tm,
      reply->task_list[nbroftasks].updt_id = ta.updt_id, reply->task_list[nbroftasks].reschedule_ind
       = ta.reschedule_ind, reply->task_list[nbroftasks].reschedule_reason_cd = ta
      .reschedule_reason_cd,
      reply->task_list[nbroftasks].template_task_flag = ta.template_task_flag, reply->task_list[
      nbroftasks].med_order_type_cd = ta.med_order_type_cd, reply->task_list[nbroftasks].
      task_priority_cd = ta.task_priority_cd,
      reply->task_list[nbroftasks].task_priority_meaning = uar_get_code_meaning(ta.task_priority_cd),
      reply->task_list[nbroftasks].task_priority_display = uar_get_code_display(ta.task_priority_cd),
      reply->task_list[nbroftasks].task_tz = ta.task_tz,
      reply->task_list[nbroftasks].charted_by_agent_cd = ta.charted_by_agent_cd, reply->task_list[
      nbroftasks].charted_by_agent_identifier = ta.charted_by_agent_identifier, reply->task_list[
      nbroftasks].charting_context_reference = ta.charting_context_reference
      IF ((((reply->task_list[nbroftasks].task_class_cd=task_class_prn)) OR ((((reply->task_list[
      nbroftasks].task_class_cd=task_class_continuous)) OR ((reply->task_list[nbroftasks].
      task_class_cd=task_class_nonscheduled))) ))
       AND (reply->task_list[nbroftasks].task_status_cd=task_status_pending)
       AND (reply->task_list[nbroftasks].task_dt_tm < cnvtdatetime(curdate,curtime3)))
       reply->task_list[nbroftasks].task_dt_tm = cnvtdatetime(curdate,curtime3)
      ENDIF
     ENDIF
    DETAIL
     IF (continue_flag=1
      AND taa.assign_prsnl_id > 0)
      task_assign_cnt = (task_assign_cnt+ 1)
      IF (task_assign_cnt > size(reply->task_list[nbroftasks].assign_prsnl_list,5))
       stat = alterlist(reply->task_list[nbroftasks].assign_prsnl_list,(task_assign_cnt+ 10))
      ENDIF
      reply->task_list[nbroftasks].assign_prsnl_list[task_assign_cnt].assign_prsnl_id = taa
      .assign_prsnl_id, reply->task_list[nbroftasks].assign_prsnl_list[task_assign_cnt].updt_cnt =
      taa.updt_cnt, reply->task_list[nbroftasks].assign_prsnl_list[task_assign_cnt].assign_prsnl_name
       = psl.name_full_formatted
     ENDIF
    FOOT  ta.task_id
     stat = alterlist(reply->task_list[nbroftasks].assign_prsnl_list,task_assign_cnt)
    FOOT REPORT
     stat = alterlist(reply->task_list,nbroftasks)
    WITH check
   ;end select
   SET assigned_prsnl_cnt = 0
 ENDWHILE
 IF (nbroftasks=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->task_list,5))),
   order_task ot,
   task_charting_agent_r tcar
  PLAN (d)
   JOIN (ot
   WHERE (ot.reference_task_id=reply->task_list[d.seq].reference_task_id))
   JOIN (tcar
   WHERE tcar.reference_task_id=outerjoin(ot.reference_task_id))
  ORDER BY d.seq
  HEAD d.seq
   charting_agent_cnt = 0, stat = alterlist(reply->task_list[d.seq].charting_agent_list,10), reply->
   task_list[d.seq].task_description = ot.task_description,
   reply->task_list[d.seq].chart_not_cmplt_ind = ot.chart_not_cmplt_ind, reply->task_list[d.seq].
   quick_chart_done_ind = ot.quick_chart_done_ind, reply->task_list[d.seq].quick_chart_ind = ot
   .quick_chart_ind,
   reply->task_list[d.seq].quick_chart_notdone_ind = ot.quick_chart_notdone_ind, reply->task_list[d
   .seq].cernertask_flag = ot.cernertask_flag, reply->task_list[d.seq].event_cd = ot.event_cd,
   reply->task_list[d.seq].reschedule_time = ot.reschedule_time, reply->task_list[d.seq].
   dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->task_list[d.seq].capture_bill_info_ind = ot
   .capture_bill_info_ind,
   reply->task_list[d.seq].ignore_req_ind = ot.ignore_req_ind, reply->task_list[d.seq].
   allpositionchart_ind = ot.allpositionchart_ind
   IF ((reply->task_list[d.seq].allpositionchart_ind=1))
    reply->task_list[d.seq].ability_ind = 1
   ENDIF
  DETAIL
   charting_agent_cnt = (charting_agent_cnt+ 1)
   IF (charting_agent_cnt > size(reply->task_list[d.seq].charting_agent_list,5))
    stat = alterlist(reply->task_list[d.seq].charting_agent_list,(charting_agent_cnt+ 10))
   ENDIF
   reply->task_list[d.seq].charting_agent_list[charting_agent_cnt].charting_agent_cd = tcar
   .charting_agent_cd, reply->task_list[d.seq].charting_agent_list[charting_agent_cnt].
   charting_agent_entity_name = tcar.charting_agent_entity_name, reply->task_list[d.seq].
   charting_agent_list[charting_agent_cnt].charting_agent_entity_id = tcar.charting_agent_entity_id,
   reply->task_list[d.seq].charting_agent_list[charting_agent_cnt].charting_agent_identifier = tcar
   .charting_agent_identifier
  FOOT  d.seq
   stat = alterlist(reply->task_list[d.seq].charting_agent_list,charting_agent_cnt)
  WITH check
 ;end select
 IF ((request->user_position_cd > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    order_task_position_xref otp
   PLAN (d)
    JOIN (otp
    WHERE (otp.reference_task_id=reply->task_list[d.seq].reference_task_id)
     AND (otp.position_cd=request->user_position_cd))
   DETAIL
    reply->task_list[d.seq].ability_ind = 1
   WITH check
  ;end select
 ENDIF
 IF ((request->get_order_info=1))
  SET order_action_new = uar_get_code_by("MEANING",6003,"ORDER")
  DECLARE admin_note_mask = i4 WITH constant(128)
  DECLARE mar_note_mask = i4 WITH constant(2)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    orders o,
    order_action oa,
    orders o1
   PLAN (d
    WHERE (reply->task_list[d.seq].order_id > 0))
    JOIN (o
    WHERE (o.order_id=reply->task_list[d.seq].order_id)
     AND o.active_ind=1)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=order_action_new)
    JOIN (o1
    WHERE o1.order_id=o.template_order_id)
   ORDER BY o.order_id
   DETAIL
    reply->task_list[d.seq].order_comment_ind = o.order_comment_ind, reply->task_list[d.seq].
    order_status_cd = o.order_status_cd, reply->task_list[d.seq].template_order_id = o
    .template_order_id,
    reply->task_list[d.seq].stop_type_cd = o.stop_type_cd, reply->task_list[d.seq].
    projected_stop_dt_tm = o.projected_stop_dt_tm, reply->task_list[d.seq].projected_stop_tz = o
    .projected_stop_tz,
    reply->task_list[d.seq].hna_mnemonic = o.hna_order_mnemonic, reply->task_list[d.seq].
    order_mnemonic = o.order_mnemonic, reply->task_list[d.seq].ordered_as_mnemonic = o
    .ordered_as_mnemonic,
    reply->task_list[d.seq].activity_type_cd = o.activity_type_cd, reply->task_list[d.seq].
    ref_text_mask = o.ref_text_mask, reply->task_list[d.seq].cki = o.cki,
    reply->task_list[d.seq].need_rx_verify_ind = o.need_rx_verify_ind, reply->task_list[d.seq].
    orderable_type_flag = o.orderable_type_flag, reply->task_list[d.seq].need_nurse_review_ind = o
    .need_nurse_review_ind,
    reply->task_list[d.seq].freq_type_flag = o.freq_type_flag, reply->task_list[d.seq].
    current_start_dt_tm = o.current_start_dt_tm, reply->task_list[d.seq].current_start_tz = o
    .current_start_tz,
    reply->task_list[d.seq].template_order_flag = o.template_order_flag, reply->task_list[d.seq].
    template_core_action_sequence = o.template_core_action_sequence
    IF (trim(o.clinical_display_line) > " ")
     reply->task_list[d.seq].order_detail_display_line = o.clinical_display_line
    ELSE
     reply->task_list[d.seq].order_detail_display_line = o.order_detail_display_line
    ENDIF
    reply->task_list[d.seq].order_provider_id = oa.order_provider_id, reply->task_list[d.seq].
    order_dt_tm = oa.order_dt_tm, reply->task_list[d.seq].order_tz = oa.order_tz
    IF (o.template_order_id > 0)
     reply->task_list[d.seq].parent_order_status_cd = o1.order_status_cd, reply->task_list[d.seq].
     parent_need_rx_verify_ind = o1.need_rx_verify_ind, reply->task_list[d.seq].
     parent_need_nurse_review_ind = o1.need_nurse_review_ind,
     reply->task_list[d.seq].parent_freq_type_flag = o1.freq_type_flag, reply->task_list[d.seq].
     parent_stop_type_cd = o1.stop_type_cd, reply->task_list[d.seq].parent_current_start_dt_tm = o1
     .current_start_dt_tm,
     reply->task_list[d.seq].parent_current_start_tz = o1.current_start_tz, reply->task_list[d.seq].
     parent_projected_stop_dt_tm = o1.projected_stop_dt_tm, reply->task_list[d.seq].
     parent_projected_stop_tz = o1.projected_stop_tz,
     comment_type_mask_temp = o.comment_type_mask, comment_type_mask_temp = bor(
      comment_type_mask_temp,band(o1.comment_type_mask,admin_note_mask)), comment_type_mask_temp =
     bor(comment_type_mask_temp,band(o1.comment_type_mask,mar_note_mask)),
     reply->task_list[d.seq].comment_type_mask = comment_type_mask_temp, reply->task_list[d.seq].
     link_nbr = o1.link_nbr, reply->task_list[d.seq].link_type_flag = o1.link_type_flag
    ELSE
     reply->task_list[d.seq].comment_type_mask = o.comment_type_mask, reply->task_list[d.seq].
     link_nbr = o.link_nbr, reply->task_list[d.seq].link_type_flag = o.link_type_flag
    ENDIF
   WITH check
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    order_detail od
   PLAN (d)
    JOIN (od
    WHERE (((od.order_id=reply->task_list[d.seq].order_id)
     AND (reply->task_list[d.seq].template_order_id=0)) OR ((od.order_id=reply->task_list[d.seq].
    template_order_id)))
     AND od.oe_field_meaning IN ("FREQ", "RSN", "RXROUTE")
     AND (od.action_sequence=
    (SELECT
     max(od2.action_sequence)
     FROM order_detail od2
     WHERE od2.order_id=od.order_id
      AND od2.oe_field_id=od.oe_field_id)))
   ORDER BY od.order_id
   DETAIL
    CASE (od.oe_field_meaning)
     OF "FREQ":
      reply->task_list[d.seq].frequency_cd = od.oe_field_value,reply->task_list[d.seq].
      freq_detail_display = od.oe_field_display_value
     OF "RSN":
      reply->task_list[d.seq].rsn_detail_display = od.oe_field_display_value
     OF "RXROUTE":
      reply->task_list[d.seq].route_detail_display = od.oe_field_display_value
    ENDCASE
   WITH check
  ;end select
  DECLARE order_comment_mask = i4 WITH constant(1)
  DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    order_comment oc,
    long_text lt
   PLAN (d
    WHERE band(reply->task_list[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
    JOIN (oc
    WHERE (oc.order_id=reply->task_list[d.seq].order_id)
     AND oc.comment_type_cd=order_comment_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=oc.order_id
      AND oc2.comment_type_cd=order_comment_cd)))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id)
   DETAIL
    reply->task_list[d.seq].order_comment_text = lt.long_text
   WITH check
  ;end select
  DECLARE additive_ing_type_flag = i4 WITH constant(3)
  DECLARE ivpb_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    order_ingredient oi
   PLAN (d
    WHERE (reply->task_list[d.seq].med_order_type_cd=ivpb_type_cd))
    JOIN (oi
    WHERE (oi.order_id=reply->task_list[d.seq].order_id)
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE oi2.order_id=oi.order_id))
     AND oi.ingredient_type_flag=additive_ing_type_flag)
   DETAIL
    reply->task_list[d.seq].additive_cnt = (reply->task_list[d.seq].additive_cnt+ 1)
   WITH check
  ;end select
 ENDIF
 IF ((request->get_encounter_info=1))
  SET finnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    encounter enc,
    encntr_alias ea
   PLAN (d
    WHERE (reply->task_list[d.seq].encntr_id > 0))
    JOIN (enc
    WHERE (enc.encntr_id=reply->task_list[d.seq].encntr_id)
     AND enc.active_ind=1
     AND enc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND enc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(enc.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(finnbr_cd)
     AND ea.active_ind=outerjoin(1)
     AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   DETAIL
    reply->task_list[d.seq].location_cd = enc.loc_nurse_unit_cd, reply->task_list[d.seq].loc_room_cd
     = enc.loc_room_cd, reply->task_list[d.seq].loc_bed_cd = enc.loc_bed_cd,
    reply->task_list[d.seq].isolation_cd = enc.isolation_cd
    IF (ea.encntr_alias_type_cd=finnbr_cd)
     reply->task_list[d.seq].finnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   WITH check
  ;end select
 ENDIF
 IF ((request->get_person_info=1))
  DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    person p
   PLAN (d
    WHERE (reply->task_list[d.seq].person_id > 0))
    JOIN (p
    WHERE (p.person_id=reply->task_list[d.seq].person_id))
   DETAIL
    reply->task_list[d.seq].person_name = p.name_full_formatted
   WITH check
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    prsnl msg_psl
   PLAN (d
    WHERE (reply->task_list[d.seq].msg_sender_id > 0))
    JOIN (msg_psl
    WHERE (msg_psl.person_id=reply->task_list[d.seq].msg_sender_id))
   DETAIL
    reply->task_list[d.seq].msg_sender_name = msg_psl.name_full_formatted
   WITH check
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    prsnl updt_psl
   PLAN (d
    WHERE (reply->task_list[d.seq].updt_id > 0))
    JOIN (updt_psl
    WHERE (updt_psl.person_id=reply->task_list[d.seq].updt_id))
   DETAIL
    reply->task_list[d.seq].updt_person_name = updt_psl.name_full_formatted
   WITH check
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    encntr_alias ea
   PLAN (d
    WHERE (reply->task_list[d.seq].encntr_id > 0))
    JOIN (ea
    WHERE (ea.encntr_id=reply->task_list[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mrn_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->task_list[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH check
  ;end select
 ENDIF
 IF ((request->get_ce_med_result_info=1))
  SET grp_event_class = uar_get_code_by("MEANING",53,"GRP")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    clinical_event ce,
    ce_med_result cmr
   PLAN (d
    WHERE (reply->task_list[d.seq].event_id > 0))
    JOIN (ce
    WHERE (ce.parent_event_id=reply->task_list[d.seq].event_id)
     AND ce.event_class_cd != grp_event_class)
    JOIN (cmr
    WHERE cmr.event_id=ce.event_id)
   DETAIL
    reply->task_list[d.seq].response_required_flag = cmr.response_required_flag
   WITH check
  ;end select
 ENDIF
 IF ((request->get_floating_dosage_info=1))
  DECLARE task_status_complete = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
  DECLARE grp_event_class = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
  DECLARE task_status_reason_notdone = f8 WITH constant(uar_get_code_by("MEANING",14024,"DCP_NOTDONE"
    ))
  DECLARE pharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbroftasks)),
    task_activity ta,
    task_activity ta1,
    clinical_event ce,
    ce_med_result cmr
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=reply->task_list[d.seq].task_id)
     AND ((ta.task_status_cd=task_status_inprocess) OR (((ta.task_status_cd=task_status_validation)
     OR (ta.task_status_cd=task_status_pending)) ))
     AND ((ta.task_class_cd=task_class_prn) OR (((ta.task_class_cd=task_class_continuous) OR (ta
    .task_class_cd=task_class_nonscheduled)) )) )
    JOIN (ta1
    WHERE ta1.order_id=ta.order_id
     AND ta1.task_status_cd=task_status_complete
     AND ta1.task_status_reason_cd != task_status_reason_notdone)
    JOIN (ce
    WHERE ce.parent_event_id=ta1.event_id
     AND ((ta1.catalog_type_cd != pharmacy) OR (ta1.catalog_type_cd=pharmacy
     AND ce.event_class_cd != grp_event_class)) )
    JOIN (cmr
    WHERE cmr.event_id=outerjoin(ce.event_id))
   ORDER BY ce.order_id, ce.event_end_dt_tm DESC
   HEAD ce.order_id
    reply->task_list[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm), reply->task_list[d
    .seq].last_done_tz = ce.event_end_tz, reply->task_list[d.seq].initial_volume = cmr.initial_volume,
    reply->task_list[d.seq].initial_dosage = cmr.initial_dosage, reply->task_list[d.seq].admin_dosage
     = cmr.admin_dosage, reply->task_list[d.seq].dosage_unit_cd = cmr.dosage_unit_cd,
    reply->task_list[d.seq].admin_site_cd = cmr.admin_site_cd, reply->task_list[d.seq].infusion_rate
     = cmr.infusion_rate, reply->task_list[d.seq].infusion_unit_cd = cmr.infusion_unit_cd,
    reply->task_list[d.seq].iv_event_cd = cmr.iv_event_cd
   DETAIL
    junk = 1
   WITH check
  ;end select
 ENDIF
#exit_script
 IF (nbroftasks=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD internal
END GO
