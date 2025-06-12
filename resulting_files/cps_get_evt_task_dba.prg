CREATE PROGRAM cps_get_evt_task:dba
 SET reply->status_data.status = "F"
 SET active_temp = 0
 SET reply->task_id = 0
 SET reply->task_assign_id = 0
 SET reply->updt_cnt = 0
 SELECT INTO "nl:"
  ta.task_id
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_activity_cd=request->task_activity_cd)
    AND (ta.event_id=request->event_id)
    AND ((ta.active_ind=1) OR ((ta.active_ind=- (1)))) )
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND (taa.assign_prsnl_id=request->assign_prsnl_id)
    AND ((taa.active_ind=1
    AND taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime3)) OR ((taa.active_ind=- (1)))) )
  DETAIL
   IF ((ta.active_ind=- (1)))
    active_temp = - (1)
   ELSE
    reply->task_id = ta.task_id, reply->updt_cnt = ta.updt_cnt
   ENDIF
  WITH check
 ;end select
 IF ((request->create_new_flag=0)
  AND curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET task_id = 0.0
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    task_id = cnvtint(nextseqnum)
   WITH format
  ;end select
  IF (task_id=0.0)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  INSERT  FROM task_activity ta
   SET ta.task_id = task_id, ta.task_activity_cd = request->task_activity_cd, ta.event_id = request->
    event_id,
    ta.active_ind = - (1)
   WITH nocounter
  ;end insert
  SET task_activity_assign_id = 0.0
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    task_activity_assign_id = cnvtint(nextseqnum)
   WITH format
  ;end select
  IF (task_activity_assign_id=0.0)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  INSERT  FROM task_activity_assignment taa
   SET taa.task_activity_assign_id = task_activity_assign_id, taa.task_id = task_id, taa
    .assign_prsnl_id = request->assign_prsnl_id,
    taa.active_ind = - (1)
   WITH nocounter
  ;end insert
  COMMIT
  SET dup_found = 0
  SELECT INTO "nl:"
   ta.task_id
   FROM task_activity ta,
    task_activity_assignment taa
   PLAN (ta
    WHERE (ta.active_ind=- (1))
     AND (ta.task_activity_cd=request->task_activity_cd)
     AND (ta.event_id=request->event_id))
    JOIN (taa
    WHERE taa.task_id=ta.task_id
     AND (taa.active_ind=- (1))
     AND (taa.assign_prsnl_id=request->assign_prsnl_id))
   DETAIL
    IF (ta.task_id != task_id)
     dup_found = 1
    ENDIF
   WITH forupdate(ta), forupdate(taa)
  ;end select
  IF (dup_found=0)
   SET reply->task_id = task_id
   SET reply->task_assign_id = task_activity_assign_id
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->task_id = 0
   SET reply->task_assign_id = 0
   SET reply->status_data.status = "Z"
   DELETE  FROM task_activity ta
    WHERE ta.task_id=task_id
   ;end delete
   DELETE  FROM task_activity_assignment taa
    WHERE taa.task_activity_assign_id=task_activity_assign_id
   ;end delete
  ENDIF
 ELSEIF ((active_temp=- (1)))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#exit_script
 CALL echo(reply->status_data.status)
END GO
