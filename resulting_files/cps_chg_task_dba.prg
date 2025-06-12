CREATE PROGRAM cps_chg_task:dba
 RECORD internal(
   1 qual[*]
     2 status = i1
     2 updt_cnt = i4
     2 updt_id = f8
     2 task_status_cd = f8
     2 task_dt_tm = dq8
     2 task_status_reason_cd = f8
     2 event_id = f8
     2 reschedule_ind = i2
     2 reschedule_reason_cd = f8
     2 person_id = f8
     2 assign_msg_text_id = f8
     2 task_type_cd = f8
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET nbr_to_chg = size(request->mod_list,5)
 SET stat = alterlist(internal->qual,nbr_to_chg)
 SET failures = 0
 SET code_set = 6026
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "PHONE MSG"
 EXECUTE cpm_get_cd_for_cdf
 SET phone_msg_cd = code_value
 SET msg_text_id = 0.0
 SET check_cd = 0
 SET sent_text = 0
 SET tasks_changed = 0
 SELECT INTO "nl:"
  ta.*
  FROM task_activity ta,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_id=request->mod_list[d.seq].task_id)
    AND ta.active_ind=1)
  DETAIL
   internal->qual[d.seq].updt_cnt = ta.updt_cnt, internal->qual[d.seq].updt_id = ta.updt_id, internal
   ->qual[d.seq].task_status_cd = ta.task_status_cd,
   internal->qual[d.seq].task_dt_tm = cnvtdatetime(ta.task_dt_tm), internal->qual[d.seq].
   task_status_reason_cd = ta.task_status_reason_cd, internal->qual[d.seq].event_id = ta.event_id,
   internal->qual[d.seq].reschedule_ind = ta.reschedule_ind, internal->qual[d.seq].
   reschedule_reason_cd = ta.reschedule_reason_cd, internal->qual[d.seq].task_type_cd = ta
   .task_type_cd,
   internal->qual[d.seq].person_id = ta.person_id, internal->qual[d.seq].task_id = ta.task_id
   IF ((ta.updt_cnt=request->mod_list[d.seq].updt_cnt))
    internal->qual[d.seq].status = 1
   ENDIF
  WITH nocounter, forupdate(ta)
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = lock_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO nbr_to_chg)
  IF ((internal->qual[i].task_type_cd=phone_msg_cd))
   SET check_cd = 1
  ENDIF
  IF ((request->mod_list[i].msg_text != null))
   SET sent_text = 1
  ENDIF
 ENDFOR
 IF (sent_text=1)
  EXECUTE FROM phone_msg_start TO phone_msg_end
 ENDIF
 INSERT  FROM task_action tac,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET tac.seq = 1, tac.task_id = request->mod_list[d.seq].task_id, tac.task_action_seq = cnvtint(seq(
     carenet_seq,nextval)),
   tac.task_status_cd =
   IF ((request->mod_list[d.seq].task_status_cd > 0.0)) internal->qual[d.seq].task_status_cd
   ELSE null
   ENDIF
   , tac.task_dt_tm =
   IF ((request->mod_list[d.seq].task_dt_tm != 0)) cnvtdatetime(internal->qual[d.seq].task_dt_tm)
   ELSE null
   ENDIF
   , tac.task_status_reason_cd =
   IF ((request->mod_list[d.seq].task_status_reason_cd > 0.0)) internal->qual[d.seq].
    task_status_reason_cd
   ELSE null
   ENDIF
   ,
   tac.reschedule_reason_cd =
   IF ((request->mod_list[d.seq].reschedule_reason_cd > 0.0)) internal->qual[d.seq].
    reschedule_reason_cd
   ELSE null
   ENDIF
   , tac.updt_dt_tm = cnvtdatetime(curdate,curtime3), tac.updt_id = reqinfo->updt_id,
   tac.updt_task = reqinfo->updt_task, tac.updt_cnt = 0, tac.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (internal->qual[d.seq].status=1))
   JOIN (tac)
  WITH nocounter, status(internal->qual[d.seq].status)
 ;end insert
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET ta.task_status_cd =
   IF ((request->mod_list[d.seq].task_status_cd > 0.0)
    AND (internal->qual[d.seq].task_type_cd != phone_msg_cd)) request->mod_list[d.seq].task_status_cd
   ELSEIF ((internal->qual[d.seq].task_type_cd != phone_msg_cd)) internal->qual[d.seq].task_status_cd
   ELSE ta.task_status_cd
   ENDIF
   , ta.task_dt_tm =
   IF ((request->mod_list[d.seq].task_dt_tm != 0)) cnvtdatetime(request->mod_list[d.seq].task_dt_tm)
   ELSE cnvtdatetime(internal->qual[d.seq].task_dt_tm)
   ENDIF
   , ta.task_status_reason_cd =
   IF ((request->mod_list[d.seq].task_status_reason_cd > 0.0)) request->mod_list[d.seq].
    task_status_reason_cd
   ELSE internal->qual[d.seq].task_status_reason_cd
   ENDIF
   ,
   ta.event_id =
   IF ((request->mod_list[d.seq].event_id > 0.0)) request->mod_list[d.seq].event_id
   ELSE internal->qual[d.seq].event_id
   ENDIF
   , ta.reschedule_ind =
   IF ((request->mod_list[d.seq].reschedule_ind > 0)) request->mod_list[d.seq].reschedule_ind
   ELSE internal->qual[d.seq].reschedule_ind
   ENDIF
   , ta.reschedule_reason_cd =
   IF ((request->mod_list[d.seq].reschedule_reason_cd > 0.0)) request->mod_list[d.seq].
    reschedule_reason_cd
   ELSE internal->qual[d.seq].reschedule_reason_cd
   ENDIF
   ,
   ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = reqinfo->updt_id, ta.updt_task =
   reqinfo->updt_task,
   ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->updt_applctx, ta.person_id =
   IF ((request->mod_list[d.seq].person_id > 0.0)) request->mod_list[d.seq].person_id
   ELSE internal->qual[d.seq].person_id
   ENDIF
  PLAN (d
   WHERE (internal->qual[d.seq].status=1))
   JOIN (ta
   WHERE (ta.task_id=internal->qual[d.seq].task_id)
    AND ta.active_ind=1)
  WITH nocounter, status(internal->qual[d.seq].status)
 ;end update
 IF (curqual != nbr_to_chg)
  FOR (x = 1 TO nbr_to_chg)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     IF (failures > 0)
      SET stat = alterlist(reply->result.task_list,failures)
     ENDIF
     SET reply->result.task_list[failures].task_id = request->mod_list[x].task_id
     SET reply->result.task_list[failures].updt_cnt = internal->qual[x].updt_cnt
     SET reply->result.task_list[failures].updt_id = internal->qual[x].updt_id
     SET reply->result.task_list[failures].task_status_cd = internal->qual[x].task_status_cd
     DELETE  FROM task_action tac
      WHERE (tac.task_id=request->mod_list[x].task_id)
      WITH nocounter
     ;end delete
    ENDIF
  ENDFOR
 ENDIF
 SET tasks_changed = curqual
 IF (tasks_changed < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 GO TO endscript
#phone_msg_start
 SELECT INTO "nl:"
  taa.*
  FROM task_activity_assignment taa,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (taa
   WHERE (taa.task_id=request->mod_list[d.seq].task_id)
    AND (taa.assign_prsnl_id=request->mod_list[d.seq].assign_prsnl_id))
  DETAIL
   internal->qual[d.seq].assign_msg_text_id = taa.msg_text_id
   IF (taa.task_status_cd > 0.0)
    internal->qual[d.seq].task_status_cd = taa.task_status_cd
   ENDIF
  WITH nocounter, forupdate(ta)
 ;end select
 IF (curqual < 1)
  CALL echo("Taa lock fail")
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = lock_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY_ASSIGNMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.*
  FROM long_text lt,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=internal->qual[d.seq].assign_msg_text_id)
    AND lt.active_ind=1)
  WITH nocounter, forupdate(lt)
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = lock_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 UPDATE  FROM long_text lt,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET lt.long_text =
   IF ((request->mod_list[d.seq].msg_text != null)) request->mod_list[d.seq].msg_text
   ENDIF
   , lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
   lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (internal->qual[d.seq].updt_cnt+ 1), lt
   .updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (internal->qual[d.seq].status=1))
   JOIN (lt
   WHERE (lt.long_text_id=internal->qual[d.seq].assign_msg_text_id)
    AND lt.active_ind=1)
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO nbr_to_chg)
   IF ((request->mod_list[i].msg_text != null)
    AND (internal->qual[i].assign_msg_text_id <= 0.0))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      msg_text_id = cnvtint(nextseqnum)
     WITH format
    ;end select
    IF (msg_text_id=0.0)
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = gen_nbr_error
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ENDIF
     GO TO exit_script
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "TASK_ACTIVITY", lt.parent_entity_id
       = request->mod_list[i].task_id,
      lt.long_text = request->mod_list[i].msg_text, lt.active_ind = 1, lt.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0, lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual < 1)
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ENDIF
     GO TO exit_script
    ENDIF
    SET internal->qual[i].assign_msg_text_id = msg_text_id
   ENDIF
 ENDFOR
#phone_msg_end
#endscript
 IF (check_cd=1)
  UPDATE  FROM task_activity_assignment taa,
    (dummyt d  WITH seq = value(nbr_to_chg))
   SET taa.task_status_cd =
    IF ((request->mod_list[d.seq].task_status_cd > 0.0)
     AND (internal->qual[d.seq].task_type_cd=phone_msg_cd)) request->mod_list[d.seq].task_status_cd
    ELSEIF ((internal->qual[d.seq].task_type_cd=phone_msg_cd)) internal->qual[d.seq].task_status_cd
    ELSE taa.task_status_cd
    ENDIF
    , taa.msg_text_id =
    IF ((internal->qual[d.seq].assign_msg_text_id > 0.0)) internal->qual[d.seq].assign_msg_text_id
    ELSE taa.msg_text_id
    ENDIF
    , taa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    taa.updt_id = reqinfo->updt_id, taa.updt_task = reqinfo->updt_task, taa.updt_cnt = (taa.updt_cnt
    + 1),
    taa.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (internal->qual[d.seq].status=1))
    JOIN (taa
    WHERE (taa.task_id=internal->qual[d.seq].task_id)
     AND (taa.assign_prsnl_id=request->mod_list[d.seq].assign_prsnl_id))
   WITH nocounter, status(internal->qual[d.seq].status)
  ;end update
 ENDIF
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY_ASSIGNMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
 ENDIF
#exit_script
 IF (tasks_changed=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSEIF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != nbr_to_chg)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ELSEIF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->result.task_status = reply->status_data.status
END GO
