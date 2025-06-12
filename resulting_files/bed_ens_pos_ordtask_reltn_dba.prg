CREATE PROGRAM bed_ens_pos_ordtask_reltn:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_load
 RECORD temp_load(
   1 lds[*]
     2 field1_id = f8
     2 field2_id = f8
     2 action_flag = i2
 )
 FREE SET temp_add_all
 RECORD temp_add_all(
   1 taa[*]
     2 id = f8
 )
 FREE SET aa_pos
 RECORD aa_pos(
   1 pos[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET pos_cnt = 0
 SET task_cnt = 0
 SET temp_cnt = 0
 SET pos_cnt = size(request->positions,5)
 SET ptcnt = 0
 FOR (p = 1 TO pos_cnt)
   SET pos_list_cnt = size(request->positions[p].pos_list,5)
   IF (pos_list_cnt > 0)
    SET ierrcode = 0
    DELETE  FROM order_task_position_xref o,
      (dummyt d  WITH seq = value(pos_list_cnt))
     SET o.seq = 1
     PLAN (d
      WHERE (request->positions[p].overwrite_ind=1))
      JOIN (o
      WHERE (o.position_cd=request->positions[p].pos_list[d.seq].code_value))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to delete position tasks")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET stat = alterlist(temp_load->lds,0)
   SET task_cnt = size(request->positions[p].sub_tasks,5)
   SET temp_cnt = 0
   FOR (x = 1 TO pos_list_cnt)
     FOR (y = 1 TO task_cnt)
       IF ((request->positions[p].sub_tasks[y].action_flag=1))
        SET temp_cnt = (temp_cnt+ 1)
        SET stat = alterlist(temp_load->lds,temp_cnt)
        SET temp_load->lds[temp_cnt].field1_id = request->positions[p].pos_list[x].code_value
        SET temp_load->lds[temp_cnt].field2_id = request->positions[p].sub_tasks[y].reference_task_id
        SET temp_load->lds[temp_cnt].action_flag = 1
       ELSEIF ((request->positions[p].sub_tasks[y].action_flag=3))
        SET temp_cnt = (temp_cnt+ 1)
        SET stat = alterlist(temp_load->lds,temp_cnt)
        SET temp_load->lds[temp_cnt].field1_id = request->positions[p].pos_list[x].code_value
        SET temp_load->lds[temp_cnt].field2_id = request->positions[p].sub_tasks[y].reference_task_id
        SET temp_load->lds[temp_cnt].action_flag = 3
       ENDIF
     ENDFOR
   ENDFOR
   IF (task_cnt > 0
    AND pos_list_cnt > 0)
    SET tacnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(task_cnt)),
      order_task o
     PLAN (d
      WHERE (request->positions[p].sub_tasks[d.seq].action_flag=3))
      JOIN (o
      WHERE (o.reference_task_id=request->positions[p].sub_tasks[d.seq].reference_task_id)
       AND o.allpositionchart_ind=1)
     ORDER BY o.reference_task_id
     HEAD REPORT
      tacnt = 0, cnt = 0, stat = alterlist(temp_add_all->taa,100)
     HEAD o.reference_task_id
      tacnt = (tacnt+ 1), cnt = (cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(temp_add_all->taa,(tacnt+ 100)), cnt = 1
      ENDIF
      temp_add_all->taa[tacnt].id = o.reference_task_id
     FOOT REPORT
      stat = alterlist(temp_add_all->taa,tacnt)
     WITH nocounter
    ;end select
    IF (tacnt > 0)
     SET ierrcode = 0
     DELETE  FROM order_task_position_xref o,
       (dummyt d  WITH seq = value(tacnt))
      SET o.seq = 1
      PLAN (d)
       JOIN (o
       WHERE (o.reference_task_id=temp_add_all->taa[d.seq].id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = build(
       "Unable to delete position tasks")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    FOR (t = 1 TO tacnt)
     IF (ptcnt=0)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=88
         AND cv.active_ind=1)
       ORDER BY cv.code_value
       HEAD REPORT
        pcnt = 0, ptcnt = 0, stat = alterlist(aa_pos->pos,100)
       HEAD cv.code_value
        pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
        IF (pcnt > 100)
         stat = alterlist(aa_pos->pos,(ptcnt+ 100)), pcnt = 1
        ENDIF
        aa_pos->pos[ptcnt].code_value = cv.code_value
       FOOT REPORT
        stat = alterlist(aa_pos->pos,ptcnt)
       WITH nocounter
      ;end select
     ENDIF
     IF (ptcnt > 0)
      SET ierrcode = 0
      INSERT  FROM order_task_position_xref o,
        (dummyt d  WITH seq = value(ptcnt))
       SET o.position_cd = aa_pos->pos[d.seq].code_value, o.reference_task_id = temp_add_all->taa[t].
        id, o.updt_applctx = reqinfo->updt_applctx,
        o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
        o.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (o)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = build(
        "Unable to insert all position tasks")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
    IF (tacnt > 0)
     SET ierrcode = 0
     UPDATE  FROM order_task o,
       (dummyt d  WITH seq = value(tacnt))
      SET o.allpositionchart_ind = 0, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
       .updt_cnt+ 1),
       o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (o
       WHERE (o.reference_task_id=temp_add_all->taa[d.seq].id)
        AND o.allpositionchart_ind != 0)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to update order_task"
       )
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (temp_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(temp_cnt)),
       order_task_position_xref o
      PLAN (d
       WHERE (temp_load->lds[d.seq].action_flag=1))
       JOIN (o
       WHERE (o.position_cd=temp_load->lds[d.seq].field1_id)
        AND (o.reference_task_id=temp_load->lds[d.seq].field2_id))
      ORDER BY d.seq
      HEAD d.seq
       temp_load->lds[d.seq].action_flag = 0
      WITH nocounter
     ;end select
     SET ierrcode = 0
     DELETE  FROM order_task_position_xref o,
       (dummyt d  WITH seq = value(temp_cnt))
      SET o.seq = 1
      PLAN (d
       WHERE (temp_load->lds[d.seq].action_flag=3))
       JOIN (o
       WHERE (o.position_cd=temp_load->lds[d.seq].field1_id)
        AND (o.reference_task_id=temp_load->lds[d.seq].field2_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = build(
       "Unable to delete position tasks2")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     INSERT  FROM order_task_position_xref o,
       (dummyt d  WITH seq = value(temp_cnt))
      SET o.position_cd = temp_load->lds[d.seq].field1_id, o.reference_task_id = temp_load->lds[d.seq
       ].field2_id, o.updt_applctx = reqinfo->updt_applctx,
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_task = reqinfo->updt_task
      PLAN (d
       WHERE (temp_load->lds[d.seq].action_flag=1))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = build(
       "Unable to insert position tasks")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     UPDATE  FROM order_task o,
       (dummyt d  WITH seq = value(tacnt))
      SET o.allpositionchart_ind = 0, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
       .updt_cnt+ 1),
       o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (temp_load->lds[d.seq].action_flag=1))
       JOIN (o
       WHERE (o.reference_task_id=temp_load->lds[d.seq].field2_id)
        AND o.allpositionchart_ind != 0)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to update order_task"
       )
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET task_cnt = size(request->tasks,5)
 FOR (t = 1 TO task_cnt)
  SET task_list_cnt = size(request->tasks[t].task_list,5)
  IF (task_list_cnt > 0)
   SET ierrcode = 0
   DELETE  FROM order_task_position_xref o,
     (dummyt d  WITH seq = value(task_list_cnt))
    SET o.seq = 1
    PLAN (d
     WHERE (((request->tasks[t].overwrite_ind=1)) OR ((request->tasks[t].all_pos_ind=1))) )
     JOIN (o
     WHERE (o.reference_task_id=request->tasks[t].task_list[d.seq].reference_task_id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET stat = alterlist(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = build(
     "Unable to delete task positions")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   SET temp_cnt = 0
   SET pos_cnt = size(request->tasks[t].sub_positions,5)
   SET stat = alterlist(temp_load->lds,0)
   IF (pos_cnt > 0)
    FOR (x = 1 TO task_list_cnt)
      FOR (y = 1 TO pos_cnt)
        IF ((request->tasks[t].sub_positions[y].action_flag=1))
         SET temp_cnt = (temp_cnt+ 1)
         SET stat = alterlist(temp_load->lds,temp_cnt)
         SET temp_load->lds[temp_cnt].field1_id = request->tasks[t].task_list[x].reference_task_id
         SET temp_load->lds[temp_cnt].field2_id = request->tasks[t].sub_positions[y].code_value
         SET temp_load->lds[temp_cnt].action_flag = 1
        ENDIF
      ENDFOR
      SET ierrcode = 0
      DELETE  FROM order_task_position_xref o,
        (dummyt d  WITH seq = value(pos_cnt))
       SET o.seq = 1
       PLAN (d
        WHERE (request->tasks[t].sub_positions[d.seq].action_flag=3))
        JOIN (o
        WHERE (o.position_cd=request->tasks[t].sub_positions[d.seq].code_value)
         AND (o.reference_task_id=request->tasks[t].task_list[x].reference_task_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = build(
        "Unable to delete task positions2")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   IF (temp_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(temp_cnt)),
      order_task_position_xref o
     PLAN (d)
      JOIN (o
      WHERE (o.position_cd=temp_load->lds[d.seq].field2_id)
       AND (o.reference_task_id=temp_load->lds[d.seq].field1_id))
     ORDER BY d.seq
     HEAD d.seq
      temp_load->lds[d.seq].action_flag = 0
     WITH nocounter
    ;end select
    SET ierrcode = 0
    INSERT  FROM order_task_position_xref o,
      (dummyt d  WITH seq = value(temp_cnt))
     SET o.position_cd = temp_load->lds[d.seq].field2_id, o.reference_task_id = temp_load->lds[d.seq]
      .field1_id, o.updt_applctx = reqinfo->updt_applctx,
      o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
      o.updt_task = reqinfo->updt_task
     PLAN (d
      WHERE (temp_load->lds[d.seq].action_flag=1))
      JOIN (o)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Unable to insert position tasks")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM order_task o,
     (dummyt d  WITH seq = value(task_list_cnt))
    SET o.allpositionchart_ind = request->tasks[t].all_pos_ind, o.updt_applctx = reqinfo->
     updt_applctx, o.updt_cnt = (o.updt_cnt+ 1),
     o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
     reqinfo->updt_task
    PLAN (d)
     JOIN (o
     WHERE (o.reference_task_id=request->tasks[t].task_list[d.seq].reference_task_id)
      AND (o.allpositionchart_ind != request->tasks[t].all_pos_ind))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET stat = alterlist(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to update order_task")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET stat = alterlist(reply->status_data.subeventstatus,0)
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
