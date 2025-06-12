CREATE PROGRAM bed_ens_med_related_results:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET ackresultmin_offset_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002164
   AND cv.cdf_meaning="ACKRESULTMIN"
   AND cv.active_ind=1
  DETAIL
   ackresultmin_offset_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET acnt = size(request->assays,5)
 IF (acnt > 0)
  INSERT  FROM task_discrete_r t,
    (dummyt d  WITH seq = acnt)
   SET t.reference_task_id = request->task_id, t.task_assay_cd = request->assays[d.seq].code_value, t
    .sequence = request->assays[d.seq].sequence,
    t.required_ind = request->assays[d.seq].required_ind, t.acknowledge_ind = request->assays[d.seq].
    acknowledge_ind, t.view_only_ind = request->assays[d.seq].view_only_ind,
    t.document_ind = request->assays[d.seq].document_ind, t.active_ind = 1, t.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_cnt = 0,
    t.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=1))
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
    WHERE (request->assays[d.seq].action_flag=2))
    JOIN (t
    WHERE (t.reference_task_id=request->task_id)
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
  DELETE  FROM task_discrete_r t,
    (dummyt d  WITH seq = value(acnt))
   SET t.seq = 1
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=3))
    JOIN (t
    WHERE (t.reference_task_id=request->task_id)
     AND (t.task_assay_cd=request->assays[d.seq].code_value))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting into task_discrete_r")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (x = 1 TO acnt)
   IF ((request->assays[x].action_flag IN (1, 2)))
    SET dta_offset_min_id = 0.0
    SET offset_min_nbr = 0
    SELECT INTO "nl:"
     FROM dta_offset_min d
     WHERE (d.task_assay_cd=request->assays[x].code_value)
      AND d.offset_min_type_cd=ackresultmin_offset_type_cd
      AND d.active_ind=1
     DETAIL
      dta_offset_min_id = d.dta_offset_min_id, offset_min_nbr = d.offset_min_nbr
     WITH nocounter
    ;end select
    IF ((request->assays[x].lookback_minutes=0))
     IF (dta_offset_min_id > 0)
      UPDATE  FROM dta_offset_min d
       SET d.active_ind = 0, d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
        .updt_cnt+ 1)
       WHERE d.dta_offset_min_id=dta_offset_min_id
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error updating into dta_offset_min")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     IF (dta_offset_min_id > 0)
      IF ((offset_min_nbr != request->assays[x].lookback_minutes))
       UPDATE  FROM dta_offset_min d
        SET d.active_ind = 0, d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
         .updt_cnt+ 1)
        WHERE d.dta_offset_min_id=dta_offset_min_id
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET stat = alterlist(reply->status_data.subeventstatus,1)
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Error updating into dta_offset_min")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
       INSERT  FROM dta_offset_min d
        SET d.dta_offset_min_id = seq(reference_seq,nextval), d.task_assay_cd = request->assays[x].
         code_value, d.offset_min_type_cd = ackresultmin_offset_type_cd,
         d.offset_min_nbr = request->assays[x].lookback_minutes, d.active_ind = 1, d
         .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
         d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime
         (curdate,curtime3), d.updt_id = reqinfo->updt_id,
         d.updt_task = reqinfo->updt_task, d.updt_cnt = 0, d.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET stat = alterlist(reply->status_data.subeventstatus,1)
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Error inserting into dta_offset_min")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSE
      INSERT  FROM dta_offset_min d
       SET d.dta_offset_min_id = seq(reference_seq,nextval), d.task_assay_cd = request->assays[x].
        code_value, d.offset_min_type_cd = ackresultmin_offset_type_cd,
        d.offset_min_nbr = request->assays[x].lookback_minutes, d.active_ind = 1, d
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), d.updt_id = reqinfo->updt_id,
        d.updt_task = reqinfo->updt_task, d.updt_cnt = 0, d.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET stat = alterlist(reply->status_data.subeventstatus,1)
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error inserting into dta_offset_min")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
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
