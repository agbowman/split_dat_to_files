CREATE PROGRAM cps_get_prsnl_tasks:dba
 RECORD internal(
   1 task_list[*]
     2 task_id = f8
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET count = 0
 SET reply->status_data.status = "F"
 SET prsnl_to_get = cnvtint(size(request->assign_prsnl_list,5))
 SET dropped = 0.0
 SET inerror = 0.0
 SET refused = 0.0
 SET dropped = request->dropped_cd
 SET inerror = request->inerror_cd
 SET refused = request->refused_cd
 SET dynamic_where = fillstring(132," ")
 SET dynamic_where2 = fillstring(132," ")
 SET dynamic_where = "0=0"
 SET dynamic_where2 = "0=0"
 IF ((request->complete_ind=1)
  AND (request->onhold_ind=1))
  SET dynamic_where =
  "ta.task_status_cd != request->complete_cd and ta.task_status_cd != request->onhold_cd"
  SET dynamic_where2 =
  "taa.task_status_cd != request->complete_cd and taa.task_status_cd != request->onhold_cd"
 ELSEIF ((request->complete_ind=1))
  SET dynamic_where = "ta.task_status_cd != request->complete_cd"
  SET dynamic_where2 = "taa.task_status_cd != request->complete_cd"
 ELSEIF ((request->onhold_ind=1))
  SET dynamic_where = "ta.task_status_cd != request->onhold_cd"
  SET dynamic_where2 = "taa.task_status_cd != request->onhold_cd"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  taa.task_id
  FROM (dummyt d  WITH seq = value(prsnl_to_get)),
   task_activity_assignment taa
  PLAN (d)
   JOIN (taa
   WHERE (request->assign_prsnl_list[d.seq].assign_prsnl_id=taa.assign_prsnl_id)
    AND taa.active_ind=1
    AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY taa.task_id
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(internal->task_list,5))
    stat = alterlist(internal->task_list,(count+ 10))
   ENDIF
   internal->task_list[count].task_id = taa.task_id
  FOOT REPORT
   stat = alterlist(internal->task_list,count)
  WITH check
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY_ASSIGNMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO exit_script
 ENDIF
 SET count1 = 0
 SET count2 = 0
 SET tasks_to_get = cnvtint(size(internal->task_list,5))
 SET types_to_get = cnvtint(size(request->type_list,5))
 SELECT
  IF (types_to_get > 0
   AND (request->beg_dt_tm > 0)
   AND (request->end_dt_tm > 0))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (d2)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND (ta.task_type_cd=request->type_list[d2.seq].task_type_cd)
     AND ta.task_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND ta.task_status_cd != inerror
     AND parser(dynamic_where)
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get > 0
   AND (request->beg_dt_tm > 0)
   AND (request->end_dt_tm < 1))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (d2)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND (ta.task_type_cd=request->type_list[d2.seq].task_type_cd)
     AND ta.task_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get > 0
   AND (request->beg_dt_tm < 1)
   AND (request->end_dt_tm > 0))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (d2)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND (ta.task_type_cd=request->type_list[d2.seq].task_type_cd)
     AND ta.task_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get > 0
   AND (request->beg_dt_tm < 1)
   AND (request->end_dt_tm < 1))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    (dummyt d2  WITH seq = value(types_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (d2)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND (ta.task_type_cd=request->type_list[d2.seq].task_type_cd)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get=0
   AND (request->beg_dt_tm > 0)
   AND (request->end_dt_tm > 0))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND ta.task_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get=0
   AND (request->beg_dt_tm > 0)
   AND (request->end_dt_tm=0))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND ta.task_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refu)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSEIF (types_to_get=0
   AND (request->beg_dt_tm=0)
   AND (request->end_dt_tm > 0))
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND ta.task_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND parser(dynamic_where)
     AND ta.task_status_cd != inerror
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ELSE
   FROM (dummyt d  WITH seq = value(tasks_to_get)),
    task_activity ta,
    task_activity_assignment taa
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=internal->task_list[d.seq].task_id)
     AND ta.active_ind=1
     AND ta.task_status_cd != dropped
     AND ta.task_status_cd != inerror
     AND parser(dynamic_where)
     AND ta.task_status_cd != refused)
    JOIN (taa
    WHERE ta.task_id=taa.task_id
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)
     AND taa.task_status_cd != inerror
     AND parser(dynamic_where2))
  ENDIF
  INTO "nl:"
  ta.task_id, taa.assign_prsnl_id, check = decode(taa.seq,"taa","z")
  ORDER BY ta.task_id, taa.assign_prsnl_id
  HEAD REPORT
   count1 = 0
  HEAD ta.task_id
   count2 = 0, count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].task_id = ta.task_id, reply->get_list[count1].person_id = ta.person_id,
   reply->get_list[count1].catalog_type_cd = ta.catalog_type_cd,
   reply->get_list[count1].catalog_cd = ta.catalog_cd, reply->get_list[count1].physician_order_ind =
   ta.physician_order_ind, reply->get_list[count1].stat_ind = ta.stat_ind,
   reply->get_list[count1].order_id = ta.order_id, reply->get_list[count1].location_cd = ta
   .location_cd, reply->get_list[count1].encntr_id = ta.encntr_id,
   reply->get_list[count1].reference_task_id = ta.reference_task_id, reply->get_list[count1].
   task_type_cd = ta.task_type_cd, reply->get_list[count1].task_class_cd = ta.task_class_cd,
   reply->get_list[count1].task_status_cd = ta.task_status_cd, reply->get_list[count1].
   task_status_reason_cd = ta.task_status_reason_cd, reply->get_list[count1].iv_ind = ta.iv_ind,
   reply->get_list[count1].tpn_ind = ta.tpn_ind, reply->get_list[count1].task_dt_tm = ta.task_dt_tm,
   reply->get_list[count1].event_id = ta.event_id,
   reply->get_list[count1].task_activity_cd = ta.task_activity_cd, reply->get_list[count1].
   msg_text_id = ta.msg_text_id, reply->get_list[count1].msg_subject_cd = ta.msg_subject_cd,
   reply->get_list[count1].msg_subject = ta.msg_subject, reply->get_list[count1].msg_sender_id = ta
   .msg_sender_id, reply->get_list[count1].confidential_ind = ta.confidential_ind,
   reply->get_list[count1].read_ind = ta.read_ind, reply->get_list[count1].delivery_ind = ta
   .delivery_ind, reply->get_list[count1].event_class_cd = ta.event_class_cd,
   reply->get_list[count1].task_create_dt_tm = ta.task_create_dt_tm, reply->get_list[count1].updt_cnt
    = ta.updt_cnt, reply->get_list[count1].updt_dt_tm = ta.updt_dt_tm,
   reply->get_list[count1].updt_id = ta.updt_id, reply->get_list[count1].reschedule_ind = ta
   .reschedule_ind, reply->get_list[count1].reschedule_reason_cd = ta.reschedule_reason_cd
  HEAD taa.assign_prsnl_id
   IF (check="taa")
    count2 = (count2+ 1)
    IF (count2 > size(reply->get_list[count1].assign_prsnl_list,5))
     stat = alterlist(reply->get_list[count1].assign_prsnl_list,(count2+ 10))
    ENDIF
    reply->get_list[count1].assign_prsnl_list[count2].assign_prsnl_id = taa.assign_prsnl_id, reply->
    get_list[count1].assign_prsnl_list[count2].updt_cnt = taa.updt_cnt, reply->get_list[count1].
    assign_prsnl_list[count2].task_status_cd = taa.task_status_cd,
    reply->get_list[count1].assign_prsnl_list[count2].msg_text_id = taa.msg_text_id
   ENDIF
  DETAIL
   col + 0
  FOOT  taa.assign_prsnl_id
   col + 0
  FOOT  ta.task_id
   stat = alterlist(reply->get_list[count1].assign_prsnl_list,count2)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
