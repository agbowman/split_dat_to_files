CREATE PROGRAM bbt_chg_req_test_phase:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_chg = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET code_updt_cnt = 0
 SET code_active_ind = 0
 SET code_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET code_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 SET phase_updt_cnt = 0
 SET phase_active_ind = 0
 SET phase_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET phase_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 IF ((request->phase_changed=1))
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE (c.code_value=request->phase_group_cd)
    AND c.code_set=1601
   DETAIL
    code_active_ind = c.active_ind, code_updt_cnt = c.updt_cnt, code_active_dt_tm = c.active_dt_tm,
    code_cdf_meaning = c.cdf_meaning
   WITH nocounter, forupdate(c)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.operationname = "lock"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Code_value-1601"
   SET reply->status_data.targetobjectvalue = "Lock failed"
  ENDIF
  IF ((request->updt_cnt != code_updt_cnt))
   SET failed = "T"
   SET reply->status_data.operationname = "change"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Code Value-1601"
   SET reply->status_data.targetobjectvalue = "Update count mismatch"
  ELSE
   UPDATE  FROM code_value c
    SET c.description = request->description, c.active_ind = request->active_ind, c.cdf_meaning =
     request->cdf_meaning,
     c.active_type_cd = 0, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.active_status_prsnl_id
      = reqinfo->updt_id,
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo
     ->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
    WHERE (c.code_value=request->phase_group_cd)
     AND c.code_set=1601
    WITH counter
   ;end update
   IF (curqual=0)
    SET failed = "T"
   ENDIF
   IF (failed="T")
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = "change"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "code_value-1601"
    SET reply->status_data.targetobjectvalue = "update failed"
    ROLLBACK
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 FOR (idx = 1 TO nbr_to_chg)
   IF ((request->qual[idx].selected_changed=1))
    IF ((request->qual[idx].add_phase=1))
     SET next_code = 0.0
     EXECUTE cpm_next_code
     INSERT  FROM phase_group p
      SET p.phase_group_id = next_code, p.task_assay_cd = request->qual[idx].task_assay_cd, p
       .phase_group_cd = request->phase_group_cd,
       p.required_ind = request->qual[idx].required_ind, p.sequence = request->qual[idx].sequence, p
       .active_ind = request->qual[idx].active_ind,
       p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .active_status_prsnl_id = reqinfo->updt_id,
       p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
      WITH counter
     ;end insert
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "insert"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "phase group"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].phase_group_id
      SET failed = "T"
      GO TO row_failed
     ENDIF
    ELSE
     SELECT INTO "nl:"
      p.phase_group_id
      FROM phase_group p
      WHERE (p.phase_group_id=request->qual[idx].phase_group_id)
      DETAIL
       phase_active_ind = p.active_ind, phase_updt_cnt = p.updt_cnt, phase_active_dt_tm = p
       .active_status_dt_tm
      WITH nocounter, forupdate(p)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "lock"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "Phase group"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "Lock failed"
     ENDIF
     IF ((request->qual[idx].updt_cnt != phase_updt_cnt))
      SET failed = "T"
      SET reply->status_data.operationname = "change"
      SET reply->status_data.operationstatus = "F"
      SET reply->status_data.targetobjectname = "phase group"
      SET reply->status_data.targetobjectvalue = "Update count mismatch"
     ELSE
      UPDATE  FROM phase_group p
       SET p.required_ind = request->qual[idx].required_ind, p.sequence = request->qual[idx].sequence,
        p.active_ind = request->qual[idx].active_ind,
        p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
        .active_status_prsnl_id = reqinfo->updt_id,
        p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
        reqinfo->updt_id,
        p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
       WHERE (p.phase_group_id=request->qual[idx].phase_group_id)
       WITH counter
      ;end update
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "change"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "phase group"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].phase_group_id
       SET failed = "T"
       GO TO row_failed
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "change"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "phase group"
  SET reqingo->commit_ind = 0
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 COMMIT
#end_script
END GO
