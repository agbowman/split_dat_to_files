CREATE PROGRAM cps_chg_evt_task:dba
 RECORD internal(
   1 qual[*]
     2 status = i1
     2 updt_cnt = i4
     2 updt_id = f8
     2 task_status_cd = f8
     2 task_id = f8
     2 task_dt_tm = dq8
     2 task_status_reason_cd = f8
     2 event_id = f8
     2 reschedule_ind = i2
     2 reschedule_reason_cd = f8
     2 msg_text_id = f8
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET nbr_to_chg = size(request->mod_list,5)
 SET stat = alterlist(internal->qual,nbr_to_chg)
 SET failures = 0
 SELECT INTO "nl:"
  ta.*
  FROM task_activity ta,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_id=request->mod_list[d.seq].task_id)
    AND ta.active_ind=1)
  DETAIL
   internal->qual[d.seq].task_id = ta.task_id, internal->qual[d.seq].updt_cnt = ta.updt_cnt, internal
   ->qual[d.seq].updt_id = ta.updt_id,
   internal->qual[d.seq].task_status_cd = ta.task_status_cd, internal->qual[d.seq].task_dt_tm =
   cnvtdatetime(ta.task_dt_tm), internal->qual[d.seq].task_status_reason_cd = ta
   .task_status_reason_cd,
   internal->qual[d.seq].event_id = ta.event_id, internal->qual[d.seq].reschedule_ind = ta
   .reschedule_ind, internal->qual[d.seq].reschedule_reason_cd = ta.reschedule_reason_cd,
   internal->qual[d.seq].msg_text_id = ta.msg_text_id
   IF ((ta.updt_cnt=request->mod_list[d.seq].updt_cnt))
    internal->qual[d.seq].status = 1
   ENDIF
  WITH nocounter, forupdate(ta)
 ;end select
 SET msg_text_id = 0
 FOR (count = 1 TO nbr_to_chg)
   IF ((request->mod_list[count].msg_text != null))
    IF ((internal->qual[count].msg_text_id=0))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
      FROM dual
      DETAIL
       internal->qual[count].msg_text_id = cnvtint(nextseqnum)
      WITH format
     ;end select
     INSERT  FROM long_text lt
      SET lt.long_text_id = internal->qual[count].msg_text_id, lt.parent_entity_name =
       "TASK_ACTIVITY", lt.parent_entity_id = request->mod_list[count].task_id,
       lt.long_text = request->mod_list[count].msg_text, lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt
       .updt_task = reqinfo->updt_task,
       lt.updt_cnt = 0, lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM long_text lt
      SET lt.long_text = request->mod_list[count].msg_text, lt.updt_id = reqinfo->updt_id, lt
       .updt_task = reqinfo->updt_task,
       lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->updt_applctx
      WHERE (lt.long_text_id=internal->qual[count].msg_text_id)
       AND lt.active_ind=1
     ;end update
    ENDIF
   ENDIF
 ENDFOR
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
 UPDATE  FROM task_activity ta,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET ta.msg_text_id = internal->qual[d.seq].msg_text_id, ta.task_status_cd =
   IF ((request->mod_list[d.seq].task_status_cd > 0.0)) request->mod_list[d.seq].task_status_cd
   ELSE internal->qual[d.seq].task_status_cd
   ENDIF
   , ta.task_dt_tm =
   IF ((request->mod_list[d.seq].task_dt_tm != 0)) cnvtdatetime(request->mod_list[d.seq].task_dt_tm)
   ELSE cnvtdatetime(internal->qual[d.seq].task_dt_tm)
   ENDIF
   ,
   ta.task_status_reason_cd =
   IF ((request->mod_list[d.seq].task_status_reason_cd > 0.0)) request->mod_list[d.seq].
    task_status_reason_cd
   ELSE internal->qual[d.seq].task_status_reason_cd
   ENDIF
   , ta.event_id =
   IF ((request->mod_list[d.seq].event_id > 0.0)) request->mod_list[d.seq].event_id
   ELSE internal->qual[d.seq].event_id
   ENDIF
   , ta.reschedule_ind =
   IF ((request->mod_list[d.seq].reschedule_ind > 0)) request->mod_list[d.seq].reschedule_ind
   ELSE internal->qual[d.seq].reschedule_ind
   ENDIF
   ,
   ta.reschedule_reason_cd =
   IF ((request->mod_list[d.seq].reschedule_reason_cd > 0.0)) request->mod_list[d.seq].
    reschedule_reason_cd
   ELSE internal->qual[d.seq].reschedule_reason_cd
   ENDIF
   , ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = reqinfo->updt_id,
   ta.updt_task = reqinfo->updt_task, ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (internal->qual[d.seq].status=1))
   JOIN (ta
   WHERE (ta.task_id=request->mod_list[d.seq].task_id)
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
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != nbr_to_chg)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET reply->result.task_status = reply->status_data.status
END GO
