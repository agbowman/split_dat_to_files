CREATE PROGRAM bbt_chg_trans_req:dba
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
 SET require_updt_cnt = 0
 SET require_active_ind = 0
 SET require_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET require_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 FOR (idx = 1 TO nbr_to_chg)
   IF ((request->qual[idx].selected_changed=1))
    IF ((request->qual[idx].add_require=1))
     SET next_code = 0.0
     EXECUTE cpm_next_code
     INSERT  FROM person_trans_req p
      SET p.person_trans_req_id = next_code, p.requirement_cd = request->qual[idx].requirement_cd, p
       .person_id = request->person_id,
       p.encntr_id = request->encntr_id, p.active_ind = request->qual[idx].active_ind, p
       .active_status_cd = 0,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
       updt_id, p.updt_cnt = 0,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.added_prsnl_id = reqinfo->updt_id, p.added_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "insert"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "person_trans_req"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].person_id
      SET failed = "T"
      GO TO row_failed
     ENDIF
    ELSE
     SELECT INTO "nl:"
      p.person_trans_req_id
      FROM person_trans_req p
      WHERE (p.person_trans_req_id=request->qual[idx].person_trans_req_id)
      DETAIL
       require_active_ind = p.active_ind, require_updt_cnt = p.updt_cnt, require_active_dt_tm = p
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
      SET reply->status_data.subeventstatus[y].targetobjectname = "Person Trans Req"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "Lock failed"
     ENDIF
     IF ((request->qual[idx].updt_cnt != require_updt_cnt))
      SET failed = "T"
      SET reply->status_data.operationname = "change"
      SET reply->status_data.operationstatus = "F"
      SET reply->status_data.targetobjectname = "person trans req"
      SET reply->status_data.targetobjectvalue = "Update count mismatch"
     ELSE
      UPDATE  FROM person_trans_req p
       SET p.active_ind = request->qual[idx].active_ind, p.active_status_cd = 0, p
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
        updt_applctx,
        p.removed_prsnl_id = reqinfo->updt_id, p.removed_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE (p.person_trans_req_id=request->qual[idx].person_trans_req_id)
       WITH counter
      ;end update
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "change"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "person trans req"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].
       person_trans_req_id
       SET failed = "T"
       GO TO row_failed
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "change"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "person trans req"
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
