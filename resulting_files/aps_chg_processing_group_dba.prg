CREATE PROGRAM aps_chg_processing_group:dba
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
 SET cv_updt_cnt = 0
 SET count1 = 0
 SET cnt = 0
 SET chg_updt_cnts[500] = 0
 IF ((request->change_cv_ind=1))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE (cv.code_value=request->parent_entity_id)
   DETAIL
    cv_updt_cnt = cv.updt_cnt
   WITH nocounter, forupdate(cv)
  ;end select
  IF (curqual=0)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  IF ((cv_updt_cnt != request->code_value_updt_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Changed"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  UPDATE  FROM code_value cv
   SET cv.code_set = request->code_set, cv.display = trim(request->short_name), cv.display_key =
    cnvtupper(cnvtalphanum(trim(request->short_name))),
    cv.description = trim(request->description), cv.active_ind = request->active_ind, cv.updt_cnt = (
    cv.updt_cnt+ 1),
    cv.updt_dt_tm = cnvtdatetime(sysdate), cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->
    updt_task,
    cv.updt_applctx = reqinfo->updt_applctx
   WHERE (cv.code_value=request->parent_entity_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  IF ((request->code_set=1310)
   AND (request->active_ind=0))
   DELETE  FROM ap_prefix_proc_grp_r appg
    WHERE (appg.processing_grp_cd=request->parent_entity_id)
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF ((request->task_del_cnt > 0))
  SELECT INTO "nl:"
   agi.parent_entity_id
   FROM ap_processing_grp_r agi,
    (dummyt d  WITH seq = value(request->task_del_cnt))
   PLAN (d)
    JOIN (agi
    WHERE (agi.parent_entity_id=request->parent_entity_id)
     AND agi.parent_entity_name="CODE_VALUE"
     AND (agi.sequence=request->task_del_qual[d.seq].sequence))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
   WITH nocounter, forupdate(agi)
  ;end select
  IF ((count1 != request->task_del_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->task_chg_cnt > 0))
  SELECT INTO "nl:"
   agi.parent_entity_id
   FROM ap_processing_grp_r agi,
    (dummyt d  WITH seq = value(request->task_chg_cnt))
   PLAN (d)
    JOIN (agi
    WHERE (agi.parent_entity_id=request->parent_entity_id)
     AND agi.parent_entity_name="CODE_VALUE"
     AND (agi.sequence=request->task_chg_qual[d.seq].sequence))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, chg_updt_cnts[count1] = agi.updt_cnt
   WITH nocounter, forupdate(agi)
  ;end select
  IF ((count1 != request->task_chg_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (cnt = 1 TO request->task_chg_cnt)
   IF ((request->task_chg_qual[cnt].updt_cnt != chg_updt_cnts[cnt]))
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "VerifyChg"
    SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
     parent_entity_id)
    ROLLBACK
    GO TO exit_script
   ENDIF
 ENDFOR
 IF ((request->task_chg_cnt > 0))
  UPDATE  FROM ap_processing_grp_r agi,
    (dummyt d  WITH seq = value(request->task_chg_cnt))
   SET agi.parent_entity_name = "CODE_VALUE", agi.parent_entity_id = request->parent_entity_id, agi
    .task_assay_cd = request->task_chg_qual[d.seq].task_assay_cd,
    agi.begin_section = request->task_chg_qual[d.seq].begin_section, agi.begin_level = request->
    task_chg_qual[d.seq].begin_level, agi.end_section = request->task_chg_qual[d.seq].begin_section,
    agi.end_level = request->task_chg_qual[d.seq].begin_level, agi.no_charge_ind = request->
    task_chg_qual[d.seq].no_charge_ind, agi.sequence = request->task_chg_qual[d.seq].sequence,
    agi.updt_dt_tm = cnvtdatetime(sysdate), agi.updt_id = reqinfo->updt_id, agi.updt_task = reqinfo->
    updt_task,
    agi.updt_applctx = reqinfo->updt_applctx, agi.updt_cnt = (agi.updt_cnt+ 1)
   PLAN (d)
    JOIN (agi
    WHERE (agi.parent_entity_id=request->parent_entity_id)
     AND agi.parent_entity_name="CODE_VALUE"
     AND (agi.sequence=request->task_chg_qual[d.seq].sequence))
   WITH nocounter, outerjoin = d, dontexist
  ;end update
  IF ((curqual != request->task_chg_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->task_del_cnt > 0))
  DELETE  FROM ap_processing_grp_r agi,
    (dummyt d  WITH seq = value(request->task_del_cnt))
   SET agi.parent_entity_id = request->parent_entity_id, agi.parent_entity_name = "CODE_VALUE", agi
    .sequence = request->task_del_qual[d.seq].sequence
   PLAN (d)
    JOIN (agi
    WHERE (agi.parent_entity_id=request->parent_entity_id)
     AND agi.parent_entity_name="CODE_VALUE"
     AND (agi.sequence=request->task_del_qual[d.seq].sequence))
   WITH nocounter
  ;end delete
  IF ((curqual != request->task_del_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->task_add_cnt > 0))
  INSERT  FROM ap_processing_grp_r agi,
    (dummyt d  WITH seq = value(request->task_add_cnt))
   SET agi.parent_entity_id = request->parent_entity_id, agi.parent_entity_name = "CODE_VALUE", agi
    .task_assay_cd = request->task_add_qual[d.seq].task_assay_cd,
    agi.begin_section = request->task_add_qual[d.seq].begin_section, agi.begin_level = request->
    task_add_qual[d.seq].begin_level, agi.end_section = request->task_add_qual[d.seq].begin_section,
    agi.end_level = request->task_add_qual[d.seq].begin_level, agi.no_charge_ind = request->
    task_add_qual[d.seq].no_charge_ind, agi.sequence = request->task_add_qual[d.seq].sequence,
    agi.updt_dt_tm = cnvtdatetime(sysdate), agi.updt_id = reqinfo->updt_id, agi.updt_task = reqinfo->
    updt_task,
    agi.updt_applctx = reqinfo->updt_applctx, agi.updt_cnt = 0
   PLAN (d)
    JOIN (agi
    WHERE (agi.parent_entity_id=request->parent_entity_id)
     AND agi.parent_entity_name="CODE_VALUE"
     AND (agi.sequence=request->task_add_qual[d.seq].sequence))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF ((curqual != request->task_add_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PROCESSING_GRP_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("parent_entity_id: ",request->
    parent_entity_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
