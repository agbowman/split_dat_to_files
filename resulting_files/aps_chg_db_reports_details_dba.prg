CREATE PROGRAM aps_chg_db_reports_details:dba
 RECORD reply(
   1 exception_data[1]
     2 update_cyto_report_control = c1
     2 update_cyto_endo_alpha_r = c1
     2 update_cyto_adeq_alpha_r = c1
     2 del_endo_task_assay_cd = c1
     2 del_adeq_task_assay_cd = c1
     2 add_cyto_adeq_alpha_r = c1
     2 add_cyto_endo_alpha_r = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET error_cnt = 0
 SET reply->exception_data[1].update_cyto_report_control = "S"
 SET reply->exception_data[1].update_cyto_endo_alpha_r = "S"
 SET reply->exception_data[1].update_cyto_adeq_alpha_r = "S"
 SET reply->exception_data[1].del_endo_task_assay_cd = "S"
 SET reply->exception_data[1].del_adeq_task_assay_cd = "S"
 SET reply->exception_data[1].add_cyto_adeq_alpha_r = "S"
 SET reply->exception_data[1].add_cyto_endo_alpha_r = "S"
 SET current_updt_cnt = 0
 SET count1 = 0
 SET cur_updt_cnt[500] = 0
 IF ((request->crc_action="C"))
  SELECT INTO "nl:"
   crc.*
   FROM cyto_report_control crc
   WHERE (request->catalog_cd=crc.catalog_cd)
   DETAIL
    current_updt_cnt = crc.updt_cnt
   WITH forupdate(crc), nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("select","f","table","cyto_report_control")
  ELSE
   IF ((request->updt_cnt != current_updt_cnt))
    CALL handle_errors("lock","f","table","cyto_report_control")
   ELSE
    SET current_updt_cnt += 1
    UPDATE  FROM cyto_report_control crc
     SET crc.report_type_flag = request->report_type_flag, crc.endocerv_task_assay_cd = request->
      endo_task_assay_cd, crc.diagnosis_task_assay_cd = request->diag_task_assay_cd,
      crc.adequacy_task_assay_cd = request->adeq_task_assay_cd, crc.adeq_reason_task_assay_cd =
      request->adeq_reason_task_assay_cd, crc.action_task_assay_cd = request->action_task_assay_cd,
      crc.clin_info_task_assay_cd = request->clin_info_task_assay_cd, crc.updt_cnt = current_updt_cnt,
      crc.updt_applctx = reqinfo->updt_applctx,
      crc.updt_dt_tm = cnvtdatetime(curdate,curtime), crc.updt_id = reqinfo->updt_id, crc.updt_task
       = reqinfo->updt_task
     WHERE (request->catalog_cd=crc.catalog_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("update","f","table","cyto_report_control")
     SET reply->exception_data[1].update_cyto_report_control = "F"
     SET reply->status_data.status = "F"
    ELSE
     COMMIT
     SET reply->status_data.status = "S"
     SET reply->exception_data[1].update_cyto_report_control = "S"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->adeq_chg_cnt > 0))
  SELECT INTO "nl:"
   FROM cyto_adequacy_alpha_r caar,
    (dummyt d  WITH seq = value(request->adeq_chg_cnt))
   PLAN (d)
    JOIN (caar
    WHERE (caar.catalog_cd=request->catalog_cd)
     AND (caar.task_assay_cd=request->adeq_task_assay_cd)
     AND (caar.nomenclature_id=request->adeq_chg_qual[d.seq].nomenclature_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, cur_updt_cnt[count1] = caar.updt_cnt
   WITH nocounter, forupdate(caar)
  ;end select
  IF ((count1 != request->adeq_chg_cnt))
   CALL handle_errors("select","f","table","cyto_alpha_adequacy_r")
  ELSE
   FOR (x = 1 TO request->adeq_chg_cnt)
     IF ((request->adeq_chg_qual[x].updt_cnt != cur_updt_cnt[x]))
      CALL handle_errors("lock","f","table","cyto_alpha_adequacy_r")
      SET reply->exception_data[1].update_cyto_adeq_alpha_r = "F"
      GO TO exit_adeq_update
     ENDIF
   ENDFOR
   UPDATE  FROM cyto_adequacy_alpha_r caar,
     (dummyt d  WITH seq = value(request->adeq_chg_cnt))
    SET caar.adequacy_flag = request->adeq_chg_qual[d.seq].adeq_flag, caar.reason_required_ind =
     request->adeq_chg_qual[d.seq].reason_required_ind, caar.updt_applctx = reqinfo->updt_applctx,
     caar.updt_cnt = (request->adeq_chg_qual[d.seq].updt_cnt+ 1), caar.updt_dt_tm = cnvtdatetime(
      curdate,curtime), caar.updt_id = reqinfo->updt_id,
     caar.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (caar
     WHERE (caar.catalog_cd=request->catalog_cd)
      AND (caar.task_assay_cd=request->adeq_task_assay_cd)
      AND (caar.nomenclature_id=request->adeq_chg_qual[d.seq].nomenclature_id))
    WITH nocounter
   ;end update
   IF ((curqual != request->adeq_chg_cnt))
    IF (curqual=0)
     CALL handle_errors("update","f","table","cyto_adeq_alpha_r")
     SET reply->exception_data[1].update_cyto_adeq_alpha_r = "F"
     SET reply->status_data.status = "F"
    ELSE
     CALL handle_errors("update","z","table","cyto_adeq_alpha_r")
     SET reply->exception_data[1].update_cyto_adeq_alpha_r = "Z"
     SET reply->status_data.status = "Z"
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
    SET reply->exception_data[1].update_cyto_adeq_alpha_r = "S"
   ENDIF
  ENDIF
 ENDIF
#exit_adeq_update
 IF ((request->adeq_add_cnt > 0))
  INSERT  FROM cyto_adequacy_alpha_r caar,
    (dummyt d  WITH seq = value(request->adeq_add_cnt))
   SET caar.catalog_cd = request->catalog_cd, caar.task_assay_cd = request->adeq_task_assay_cd, caar
    .nomenclature_id = request->adeq_add_qual[d.seq].nomenclature_id,
    caar.adequacy_flag = request->adeq_add_qual[d.seq].adeq_flag, caar.reason_required_ind = request
    ->adeq_add_qual[d.seq].reason_required_ind, caar.updt_dt_tm = cnvtdatetime(curdate,curtime),
    caar.updt_id = reqinfo->updt_id, caar.updt_task = reqinfo->updt_task, caar.updt_cnt = 0,
    caar.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (caar)
   WITH nocounter
  ;end insert
  IF ((curqual != request->adeq_add_cnt))
   IF (curqual=0)
    CALL handle_errors("insrt","f","table","cyto_adeq_alpha_r")
    SET reply->exception_data[1].add_cyto_adeq_alpha_r = "F"
   ELSE
    CALL handle_errors("insert","z","table","cyto_adeq_alpha_r")
    SET reply->exception_data[1].add_cyto_adeq_alpha_r = "Z"
   ENDIF
  ELSE
   SET reply->exception_data[1].add_cyto_adeq_alpha_r = "S"
  ENDIF
 ENDIF
 IF ((request->endo_chg_cnt > 0))
  SELECT INTO "nl:"
   FROM cyto_endocerv_alpha_r cear,
    (dummyt d  WITH seq = value(request->endo_chg_cnt))
   PLAN (d)
    JOIN (cear
    WHERE (cear.catalog_cd=request->catalog_cd)
     AND (cear.task_assay_cd=request->endo_task_assay_cd)
     AND (cear.nomenclature_id=request->endo_chg_qual[d.seq].nomenclature_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, cur_updt_cnt[count1] = cear.updt_cnt
   WITH nocounter, forupdate(cear)
  ;end select
  IF ((count1 != request->endo_chg_cnt))
   CALL handle_errors("select","f","table","cyto_endocerv_alpha_r")
  ELSE
   FOR (x = 1 TO request->endo_chg_cnt)
     IF ((request->endo_chg_qual[x].updt_cnt != cur_updt_cnt[x]))
      CALL handle_errors("lock","f","table","cyto_endocerv_alpha_r")
      SET reply->exception_data[1].update_cyto_endo_alpha_r = "F"
      GO TO exit_endo_update
     ENDIF
   ENDFOR
   UPDATE  FROM cyto_endocerv_alpha_r cear,
     (dummyt d  WITH seq = value(request->endo_chg_cnt))
    SET cear.endocerv_ind = request->endo_chg_qual[d.seq].endo_ind, cear.updt_dt_tm = cnvtdatetime(
      curdate,curtime), cear.updt_id = reqinfo->updt_id,
     cear.updt_task = reqinfo->updt_task, cear.updt_cnt = (request->endo_chg_qual[d.seq].updt_cnt+ 1),
     cear.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cear
     WHERE (cear.catalog_cd=request->catalog_cd)
      AND (cear.task_assay_cd=request->endo_task_assay_cd)
      AND (cear.nomenclature_id=request->endo_chg_qual[d.seq].nomenclature_id))
    WITH nocounter
   ;end update
   IF ((curqual != request->endo_chg_cnt))
    IF (curqual=0)
     CALL handle_errors("update","f","table","cyto_endo_alpha_r")
     SET reply->exception_data[1].update_cyto_endo_alpha_r = "F"
     SET reply->status_data.status = "F"
    ELSE
     CALL handle_errors("update","z","table","cyto_endo_alpha_r")
     SET reply->exception_data[1].update_cyto_endo_alpha_r = "Z"
     SET reply->status_data.status = "Z"
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
    SET reply->exception_data[1].update_cyto_endo_alpha_r = "S"
   ENDIF
  ENDIF
 ENDIF
#exit_endo_update
 IF ((request->del_endo_task_assay_cd > 0))
  DELETE  FROM cyto_endocerv_alpha_r cear
   WHERE (cear.catalog_cd=request->catalog_cd)
    AND (cear.task_assay_cd=request->del_endo_task_assay_cd)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL handle_errors("delete","f","table","cyto_endocerv_alpha_r")
   SET reply->exception_data[1].del_endo_task_assay_cd = "F"
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->del_adeq_task_assay_cd > 0))
  DELETE  FROM cyto_adequacy_alpha_r caar
   WHERE (caar.catalog_cd=request->catalog_cd)
    AND (caar.task_assay_cd=request->del_adeq_task_assay_cd)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL handle_errors("delete","f","table","cyto_adequacy_alpha_r")
   SET reply->exception_data[1].del_adeq_task_assay_cd = "F"
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->endo_add_cnt > 0))
  INSERT  FROM cyto_endocerv_alpha_r cear,
    (dummyt d  WITH seq = value(request->endo_add_cnt))
   SET cear.catalog_cd = request->catalog_cd, cear.task_assay_cd = request->endo_task_assay_cd, cear
    .nomenclature_id = request->endo_add_qual[d.seq].nomenclature_id,
    cear.endocerv_ind = request->endo_add_qual[d.seq].endo_ind, cear.updt_dt_tm = cnvtdatetime(
     curdate,curtime), cear.updt_id = reqinfo->updt_id,
    cear.updt_task = reqinfo->updt_task, cear.updt_cnt = 0, cear.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cear)
   WITH nocounter
  ;end insert
  IF ((curqual != request->endo_add_cnt))
   IF (curqual=0)
    CALL handle_errors("update","f","table","cyto_endo_alpha_r")
    SET reply->exception_data[1].add_cyto_endo_alpha_r = "F"
   ELSE
    CALL handle_errors("update","z","table","cyto_endo_alpha_r")
    SET reply->exception_data[1].add_cyto_endo_alpha_r = "Z"
   ENDIF
  ELSE
   SET reply->exception_data[1].add_cyto_endo_alpha_r = "S"
  ENDIF
 ENDIF
#end_of_plans
 IF ((reply->exception_data[1].update_cyto_report_control="S")
  AND (reply->exception_data[1].update_cyto_endo_alpha_r="S")
  AND (reply->exception_data[1].update_cyto_adeq_alpha_r="S")
  AND (reply->exception_data[1].del_endo_task_assay_cd="S")
  AND (reply->exception_data[1].del_adeq_task_assay_cd="S")
  AND (reply->exception_data[1].add_cyto_endo_alpha_r="S")
  AND (reply->exception_data[1].add_cyto_adeq_alpha_r="S"))
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_reports
END GO
