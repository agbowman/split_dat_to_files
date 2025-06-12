CREATE PROGRAM dcp_add_copy_task:dba
 DECLARE program_version = vc WITH private, constant("015")
 RECORD internal(
   1 orig_task_list[*]
     2 status = i2
     2 person_id = f8
     2 linked_order_ind = i2
     2 catalog_type_cd = f8
     2 continuous_ind = i2
     2 physician_order_ind = i2
     2 stat_ind = i2
     2 routine_ind = i2
     2 order_id = f8
     2 location_cd = f8
     2 encntr_id = f8
     2 reference_task_id = f8
     2 task_type_cd = f8
     2 task_class_cd = f8
     2 task_status_cd = f8
     2 careset_id = f8
     2 iv_ind = i2
     2 tpn_ind = i2
     2 task_dt_tm = dq8
     2 event_id = f8
     2 task_activity_cd = f8
     2 msg_text_id = f8
     2 msg_subject = vc
     2 confidential_ind = i2
     2 read_ind = i2
     2 delivery_ind = i2
     2 event_class_cd = f8
     2 msg_sender_id = f8
     2 catalog_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 task_rtg_id = f8
     2 msg_subject_cd = f8
     2 reschedule_ind = i2
     2 template_task_flag = i2
     2 med_order_type_cd = f8
     2 copy_ind = i2
     2 task_id = f8
     2 prn_task_dt_tm = dq8
     2 loc_bed_cd = f8
     2 loc_room_cd = f8
     2 parent_task_id = f8
     2 new_task_id = f8
     2 task_priority_cd = f8
     2 task_tz = i4
     2 source_tag = c255
     2 completed_tasks = i4
     2 deleted_stat_task_cd = f8
 )
 RECORD updatestatnow(
   1 update_task_list[*]
     2 task_id = f8
     2 task_priority_cd = f8
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET tasks_to_add = size(request->copy_list,5)
 SET stat = alterlist(internal->orig_task_list,tasks_to_add)
 SET max_refs = 0
 SET total_refs = 0
 SET task_count = 0
 SET pending = request->pending_cd
 SET new_prn_task_cnt = 0
 SET newtaskid = 0.0
 SET updatecount = 0
 SET execstatus = "F"
 SET null_ptr = 0
 DECLARE overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE taskcanceled = f8 WITH constant(uar_get_code_by("MEANING",79,"CANCELED"))
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 DECLARE ordercanceled = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE orderdeleted = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE orderdiscontinued = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE ordertranscancel = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE ordersuspended = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE adhocorder = f8 WITH constant(uar_get_code_by("MEANING",6025,"ADHOC"))
 DECLARE stat_pri = f8 WITH constant(uar_get_code_by("MEANING",4010,"STAT"))
 DECLARE now = f8 WITH constant(uar_get_code_by("MEANING",4010,"NOW"))
 DECLARE routine = f8 WITH constant(uar_get_code_by("MEANING",4010,"ROUTINE"))
 IF (((overdue <= 0) OR (((inprocess <= 0) OR (((taskcanceled <= 0) OR (((ordercanceled <= 0) OR (((
 orderdeleted <= 0) OR (((orderdiscontinued <= 0) OR (((ordertranscancel <= 0) OR (((ordersuspended
  <= 0) OR (((adhocorder <= 0) OR (complete_cd <= 0)) )) )) )) )) )) )) )) )) )
  GO TO exit_script
 ENDIF
 IF (tasks_to_add > 0)
  SELECT INTO "nl:"
   t.task_id
   FROM (dummyt d1  WITH seq = value(tasks_to_add)),
    orders o,
    task_activity t
   PLAN (d1)
    JOIN (t
    WHERE (t.task_id=request->copy_list[d1.seq].task_id)
     AND t.task_status_cd != taskcanceled
     AND t.task_class_cd != adhocorder)
    JOIN (o
    WHERE o.order_id=t.order_id
     AND o.order_status_cd != ordercanceled
     AND o.order_status_cd != orderdeleted
     AND o.order_status_cd != orderdiscontinued
     AND o.order_status_cd != ordertranscancel
     AND o.order_status_cd != ordersuspended)
   ORDER BY t.task_id
   DETAIL
    task_count += 1, internal->orig_task_list[task_count].person_id = t.person_id, internal->
    orig_task_list[task_count].linked_order_ind = t.linked_order_ind,
    internal->orig_task_list[task_count].catalog_type_cd = t.catalog_type_cd, internal->
    orig_task_list[task_count].continuous_ind = t.continuous_ind, internal->orig_task_list[task_count
    ].physician_order_ind = t.physician_order_ind,
    internal->orig_task_list[task_count].stat_ind = t.stat_ind, internal->orig_task_list[task_count].
    routine_ind = t.routine_ind, internal->orig_task_list[task_count].order_id = t.order_id,
    internal->orig_task_list[task_count].location_cd = t.location_cd, internal->orig_task_list[
    task_count].encntr_id = t.encntr_id, internal->orig_task_list[task_count].reference_task_id = t
    .reference_task_id,
    internal->orig_task_list[task_count].task_type_cd = t.task_type_cd, internal->orig_task_list[
    task_count].task_class_cd = t.task_class_cd, internal->orig_task_list[task_count].task_status_cd
     = t.task_status_cd,
    internal->orig_task_list[task_count].careset_id = t.careset_id, internal->orig_task_list[
    task_count].iv_ind = t.iv_ind, internal->orig_task_list[task_count].tpn_ind = t.tpn_ind,
    internal->orig_task_list[task_count].task_dt_tm = t.task_dt_tm, internal->orig_task_list[
    task_count].task_tz = t.task_tz, internal->orig_task_list[task_count].prn_task_dt_tm = request->
    copy_list[d1.seq].prn_task_dt_tm,
    internal->orig_task_list[task_count].task_activity_cd = t.task_activity_cd, internal->
    orig_task_list[task_count].msg_text_id = t.msg_text_id, internal->orig_task_list[task_count].
    msg_subject = t.msg_subject,
    internal->orig_task_list[task_count].confidential_ind = t.confidential_ind, internal->
    orig_task_list[task_count].read_ind = t.read_ind, internal->orig_task_list[task_count].
    delivery_ind = t.delivery_ind,
    internal->orig_task_list[task_count].event_class_cd = t.event_class_cd, internal->orig_task_list[
    task_count].msg_sender_id = t.msg_sender_id, internal->orig_task_list[task_count].catalog_cd = t
    .catalog_cd,
    internal->orig_task_list[task_count].active_ind = t.active_ind, internal->orig_task_list[
    task_count].active_status_cd = t.active_status_cd, internal->orig_task_list[task_count].
    active_status_prsnl_id = t.active_status_prsnl_id,
    internal->orig_task_list[task_count].task_rtg_id = t.task_rtg_id, internal->orig_task_list[
    task_count].msg_subject_cd = t.msg_subject_cd, internal->orig_task_list[task_count].
    reschedule_ind = t.reschedule_ind,
    internal->orig_task_list[task_count].template_task_flag = t.template_task_flag, internal->
    orig_task_list[task_count].med_order_type_cd = t.med_order_type_cd, internal->orig_task_list[
    task_count].copy_ind = 1,
    internal->orig_task_list[task_count].task_id = t.task_id, internal->orig_task_list[task_count].
    loc_room_cd = t.loc_room_cd, internal->orig_task_list[task_count].loc_bed_cd = t.loc_bed_cd,
    internal->orig_task_list[task_count].parent_task_id = request->copy_list[d1.seq].task_id,
    internal->orig_task_list[task_count].new_task_id = seq(carenet_seq,nextval), internal->
    orig_task_list[task_count].task_priority_cd = t.task_priority_cd,
    internal->orig_task_list[task_count].source_tag = t.source_tag, internal->orig_task_list[
    task_count].completed_tasks = 0, internal->orig_task_list[task_count].deleted_stat_task_cd = 0
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(internal->orig_task_list,task_count)
 IF (task_count=0)
  CALL echo(build("when task_count is ",task_count,
    " we have no task(s) for regeneration. Exiting the script."))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  t.order_id
  FROM (dummyt d1  WITH seq = value(task_count)),
   task_activity t
  PLAN (d1)
   JOIN (t
   WHERE (t.order_id=internal->orig_task_list[d1.seq].order_id)
    AND (t.reference_task_id=internal->orig_task_list[d1.seq].reference_task_id)
    AND t.active_ind=1
    AND (internal->orig_task_list[d1.seq].task_status_cd=complete_cd))
  ORDER BY t.order_id
  DETAIL
   IF (t.task_status_cd=deleted_cd
    AND t.task_priority_cd IN (stat_pri, now))
    internal->orig_task_list[d1.seq].deleted_stat_task_cd = t.task_priority_cd
   ELSEIF (t.task_status_cd=complete_cd)
    internal->orig_task_list[d1.seq].completed_tasks += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.order_id
  FROM (dummyt d1  WITH seq = value(task_count)),
   task_activity t
  PLAN (d1)
   JOIN (t
   WHERE (t.order_id=internal->orig_task_list[d1.seq].order_id)
    AND (t.reference_task_id=internal->orig_task_list[d1.seq].reference_task_id))
  ORDER BY t.order_id
  DETAIL
   IF ((internal->orig_task_list[d1.seq].task_id != t.task_id)
    AND t.active_ind=1
    AND ((t.task_status_cd=pending) OR (((t.task_status_cd=overdue) OR (t.task_status_cd=inprocess))
   )) )
    internal->orig_task_list[d1.seq].copy_ind = 0
    IF ((internal->orig_task_list[d1.seq].task_status_cd=complete_cd))
     IF ((((internal->orig_task_list[d1.seq].task_priority_cd=stat_pri)) OR ((internal->
     orig_task_list[d1.seq].task_priority_cd=now))) )
      updatecount += 1, stat = alterlist(updatestatnow->update_task_list,updatecount), updatestatnow
      ->update_task_list[updatecount].task_id = t.task_id
      IF ((internal->orig_task_list[d1.seq].completed_tasks > 1))
       updatestatnow->update_task_list[updatecount].task_priority_cd = 0
      ELSE
       updatestatnow->update_task_list[updatecount].task_priority_cd = internal->orig_task_list[d1
       .seq].task_priority_cd
      ENDIF
     ELSE
      IF ((internal->orig_task_list[d1.seq].completed_tasks=1)
       AND (internal->orig_task_list[d1.seq].deleted_stat_task_cd > 0))
       updatecount += 1, stat = alterlist(updatestatnow->update_task_list,updatecount), updatestatnow
       ->update_task_list[updatecount].task_id = t.task_id,
       updatestatnow->update_task_list[updatecount].task_priority_cd = internal->orig_task_list[d1
       .seq].deleted_stat_task_cd
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET task_cnt = cnvtint(size(internal->orig_task_list,5))
 FOR (x = 1 TO task_cnt)
   CALL echo(build(" copy_ind = ",internal->orig_task_list[x].copy_ind))
 ENDFOR
 CALL echorecord(internal)
 CALL echorecord(updatestatnow)
 FOR (x = 1 TO task_count)
   IF ((internal->orig_task_list[x].copy_ind=1))
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      internal->orig_task_list[x].new_task_id = nextseqnum
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET execstatus = "F"
     GO TO exit_script
    ENDIF
    INSERT  FROM task_activity ta
     SET ta.seq = 1, ta.task_id = internal->orig_task_list[x].new_task_id, ta.person_id = internal->
      orig_task_list[x].person_id,
      ta.linked_order_ind = internal->orig_task_list[x].linked_order_ind, ta.catalog_type_cd =
      internal->orig_task_list[x].catalog_type_cd, ta.continuous_ind = internal->orig_task_list[x].
      continuous_ind,
      ta.physician_order_ind = internal->orig_task_list[x].physician_order_ind, ta.stat_ind =
      internal->orig_task_list[x].stat_ind, ta.routine_ind = internal->orig_task_list[x].routine_ind,
      ta.order_id = internal->orig_task_list[x].order_id, ta.location_cd = internal->orig_task_list[x
      ].location_cd, ta.encntr_id = internal->orig_task_list[x].encntr_id,
      ta.task_class_cd = internal->orig_task_list[x].task_class_cd, ta.task_status_cd = pending, ta
      .careset_id = internal->orig_task_list[x].careset_id,
      ta.iv_ind = internal->orig_task_list[x].iv_ind, ta.tpn_ind = internal->orig_task_list[x].
      tpn_ind, ta.task_dt_tm = cnvtdatetime(internal->orig_task_list[x].prn_task_dt_tm),
      ta.task_tz =
      IF ((internal->orig_task_list[x].prn_task_dt_tm != 0)) internal->orig_task_list[x].task_tz
      ELSE 0
      ENDIF
      , ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->updt_id,
      ta.updt_task = reqinfo->updt_task, ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx,
      ta.event_id = 0, ta.msg_text_id = internal->orig_task_list[x].msg_text_id, ta.msg_subject =
      internal->orig_task_list[x].msg_subject,
      ta.msg_subject_cd = internal->orig_task_list[x].msg_subject_cd, ta.task_create_dt_tm =
      cnvtdatetime(sysdate), ta.confidential_ind = internal->orig_task_list[x].confidential_ind,
      ta.read_ind = internal->orig_task_list[x].read_ind, ta.delivery_ind = internal->orig_task_list[
      x].delivery_ind, ta.event_class_cd = internal->orig_task_list[x].event_class_cd,
      ta.msg_sender_id = internal->orig_task_list[x].msg_sender_id, ta.catalog_cd = internal->
      orig_task_list[x].catalog_cd, ta.active_ind = 1,
      ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm = cnvtdatetime(sysdate),
      ta.active_status_prsnl_id = reqinfo->updt_id,
      ta.task_rtg_id = internal->orig_task_list[x].task_rtg_id, ta.reference_task_id = internal->
      orig_task_list[x].reference_task_id, ta.task_type_cd = internal->orig_task_list[x].task_type_cd,
      ta.template_task_flag = internal->orig_task_list[x].template_task_flag, ta.task_activity_cd =
      internal->orig_task_list[x].task_activity_cd, ta.med_order_type_cd = internal->orig_task_list[x
      ].med_order_type_cd,
      ta.loc_room_cd = internal->orig_task_list[x].loc_room_cd, ta.loc_bed_cd = internal->
      orig_task_list[x].loc_bed_cd, ta.reschedule_ind = 0,
      ta.reschedule_reason_cd = 0, ta.task_status_reason_cd = 0, ta.source_tag = internal->
      orig_task_list[x].source_tag,
      ta.task_priority_cd =
      IF ((internal->orig_task_list[x].task_status_cd != complete_cd)
       AND (((internal->orig_task_list[x].task_priority_cd=stat_pri)) OR ((internal->orig_task_list[x
      ].task_priority_cd=now))) ) 0
      ELSE
       IF ((internal->orig_task_list[x].completed_tasks > 1)) 0
       ELSE internal->orig_task_list[x].task_priority_cd
       ENDIF
      ENDIF
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET execstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (updatecount > 0)
  CALL echo(build("updateCount = ",updatecount))
  UPDATE  FROM task_activity ta,
    (dummyt d  WITH seq = value(updatecount))
   SET ta.task_priority_cd = updatestatnow->update_task_list[d.seq].task_priority_cd, ta.updt_dt_tm
     = cnvtdatetime(curdate,curtime), ta.updt_id = reqinfo->updt_id,
    ta.updt_task = reqinfo->updt_task, ta.updt_applctx = reqinfo->updt_applctx, ta.updt_cnt = (ta
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=updatestatnow->update_task_list[d.seq].task_id))
   WITH nocounter
  ;end update
  IF (curqual=updatecount)
   CALL echo(build("updated ",curqual,"tasks to stat/now"))
  ELSE
   SET execstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET execstatus = "S"
 IF (task_count > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(task_count))
   WHERE (internal->orig_task_list[d1.seq].copy_ind=1)
   DETAIL
    new_prn_task_cnt += 1
    IF (new_prn_task_cnt > size(reply->new_prn_task_list,5))
     stat = alterlist(reply->new_prn_task_list,(new_prn_task_cnt+ 10))
    ENDIF
    reply->new_prn_task_list[new_prn_task_cnt].task_id = internal->orig_task_list[d1.seq].new_task_id,
    reply->new_prn_task_list[new_prn_task_cnt].parent_task_id = internal->orig_task_list[d1.seq].
    parent_task_id, reply->new_prn_task_list[new_prn_task_cnt].task_class_cd = internal->
    orig_task_list[d1.seq].task_class_cd,
    reply->new_prn_task_list[new_prn_task_cnt].task_dt_tm = internal->orig_task_list[d1.seq].
    prn_task_dt_tm, reply->new_prn_task_list[new_prn_task_cnt].updt_cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->new_prn_task_list,new_prn_task_cnt)
#exit_script
 IF (execstatus="S")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("exit_script - success")
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo("exit_script - failed")
 ENDIF
END GO
