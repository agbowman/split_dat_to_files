CREATE PROGRAM bed_cpy_med_related_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD delete_temp(
   1 assays[*]
     2 code_value = f8
 )
 RECORD found_temp(
   1 assays[*]
     2 row_exists = i2
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET tcnt = size(request->tasks,5)
 SET acnt = size(request->assays,5)
 FOR (t = 1 TO tcnt)
   SET delcnt = 0
   SELECT INTO "nl:"
    FROM task_discrete_r t
    WHERE (t.reference_task_id=request->tasks[t].id)
    DETAIL
     num = 0, found_ind = 0, found_ind = locateval(num,1,acnt,t.task_assay_cd,request->assays[num].
      code_value)
     IF (found_ind=0)
      delcnt = (delcnt+ 1), stat = alterlist(delete_temp->assays,delcnt), delete_temp->assays[delcnt]
      .code_value = t.task_assay_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (delcnt > 0)
    DELETE  FROM task_discrete_r t,
      (dummyt d  WITH seq = value(delcnt))
     SET t.seq = 1
     PLAN (d)
      JOIN (t
      WHERE (t.reference_task_id=request->tasks[t].id)
       AND (t.task_assay_cd=delete_temp->assays[d.seq].code_value))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error deleting from task_discrete_r")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (acnt > 0)
    SET stat = initrec(found_temp)
    SET stat = alterlist(found_temp->assays,acnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = acnt),
      task_discrete_r t
     PLAN (d)
      JOIN (t
      WHERE (t.reference_task_id=request->tasks[t].id)
       AND (t.task_assay_cd=request->assays[d.seq].code_value))
     DETAIL
      found_temp->assays[d.seq].row_exists = 1
     WITH nocounter
    ;end select
    INSERT  FROM task_discrete_r t,
      (dummyt d  WITH seq = acnt)
     SET t.reference_task_id = request->tasks[t].id, t.task_assay_cd = request->assays[d.seq].
      code_value, t.sequence = request->assays[d.seq].sequence,
      t.required_ind = request->assays[d.seq].required_ind, t.acknowledge_ind = request->assays[d.seq
      ].acknowledge_ind, t.view_only_ind = request->assays[d.seq].view_only_ind,
      t.document_ind = request->assays[d.seq].document_ind, t.active_ind = 1, t.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_cnt = 0,
      t.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (found_temp->assays[d.seq].row_exists=0))
      JOIN (t)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into task_discrete_r")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    UPDATE  FROM task_discrete_r t,
      (dummyt d  WITH seq = value(acnt))
     SET t.required_ind = request->assays[d.seq].required_ind, t.acknowledge_ind = request->assays[d
      .seq].acknowledge_ind, t.view_only_ind = request->assays[d.seq].view_only_ind,
      t.document_ind = request->assays[d.seq].document_ind, t.sequence = request->assays[d.seq].
      sequence, t.updt_id = reqinfo->updt_id,
      t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_applctx
       = reqinfo->updt_applctx,
      t.updt_cnt = (t.updt_cnt+ 1)
     PLAN (d
      WHERE (found_temp->assays[d.seq].row_exists=1))
      JOIN (t
      WHERE (t.reference_task_id=request->tasks[t].id)
       AND (t.task_assay_cd=request->assays[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error updating into task_discrete_r")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
