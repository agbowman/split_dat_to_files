CREATE PROGRAM dcp_add_task:dba
 RECORD internal(
   1 qual[*]
     2 status = i2
 )
 SET reply->status_data.status = "F"
 SET reply->result.task_status = "F"
 SET reqinfo->commit_ind = 0
 SET task_id = 0.0
 SET msg_text_id = 0.0
 SET prsnl_to_add = size(request->assign_prsnl_list,5)
 SET stat = alterlist(internal->qual,prsnl_to_add)
 SET failures = 0
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   task_id = nextseqnum
  WITH format
 ;end select
 IF (task_id=0.0)
  GO TO exit_script
 ENDIF
 IF ((request->msg_text != null))
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    msg_text_id = nextseqnum
   WITH format
  ;end select
  IF (msg_text_id=0.0)
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "TASK_ACTIVITY", lt.parent_entity_id =
    task_id,
    lt.long_text = request->msg_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM task_activity ta
  SET ta.task_id = task_id, ta.person_id = request->person_id, ta.encntr_id = request->encntr_id,
   ta.stat_ind = request->stat_ind, ta.reference_task_id = request->reference_task_id, ta
   .task_type_cd = request->task_type_cd,
   ta.task_status_cd = request->task_status_cd, ta.task_dt_tm = cnvtdatetime(request->task_dt_tm), ta
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ta.updt_id = reqinfo->updt_id, ta.updt_task = reqinfo->updt_task, ta.updt_cnt = 0,
   ta.updt_applctx = reqinfo->updt_applctx, ta.task_activity_cd = request->task_activity_cd, ta
   .msg_text_id = msg_text_id,
   ta.msg_subject_cd =
   IF ((request->msg_subject_cd > 0.0)) request->msg_subject_cd
   ELSE 0
   ENDIF
   , ta.msg_subject = request->msg_subject, ta.msg_sender_id = reqinfo->updt_id,
   ta.confidential_ind = request->confidential_ind, ta.read_ind = request->read_ind, ta.delivery_ind
    = request->delivery_ind,
   ta.task_create_dt_tm = cnvtdatetime(curdate,curtime3), ta.catalog_cd = 0, ta.encntr_id = 0,
   ta.task_class_cd = 0, ta.event_id = request->event_id, ta.event_class_cd = request->event_class_cd,
   ta.event_class_cd = 0, ta.catalog_type_cd = 0, ta.careset_id = 0,
   ta.active_ind = 1, ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ta.active_status_prsnl_id = reqinfo->updt_id, ta.med_order_type_cd = 0, ta.task_rtg_id = 0,
   ta.reschedule_ind = 0, ta.reschedule_reason_cd = 0, ta.task_status_reason_cd = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 IF (prsnl_to_add > 0)
  INSERT  FROM task_activity_assignment taa,
    (dummyt d  WITH seq = value(prsnl_to_add))
   SET taa.seq = 1, taa.task_activity_assign_id = seq(carenet_seq,nextval), taa.task_id = task_id,
    taa.assign_prsnl_id = request->assign_prsnl_list[d.seq].assign_prsnl_id, taa.active_ind = 1, taa
    .beg_eff_dt_tm = cnvtdatetime(curdate,curtime3),
    taa.end_eff_dt_tm = cnvtdatetime("31-Dec-2100"), taa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    taa.updt_id = reqinfo->updt_id,
    taa.updt_task = reqinfo->updt_task, taa.updt_cnt = 0, taa.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (taa)
   WITH nocounter, status(internal->qual[d.seq].status)
  ;end insert
 ENDIF
 IF (curqual != prsnl_to_add)
  FOR (x = 1 TO prsnl_to_add)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     IF (failures > 0)
      SET stat = alterlist(reply->result.assign_prsnl_list,failures)
     ENDIF
     SET reply->result.assign_prsnl_list[failures].assign_prsnl_id = request->assign_prsnl_list[x].
     assign_prsnl_id
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reply->task_id = task_id
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != prsnl_to_add)
  SET reply->status_data.status = "P"
  SET reply->task_id = task_id
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET reply->result.task_status = reply->status_data.status
END GO
