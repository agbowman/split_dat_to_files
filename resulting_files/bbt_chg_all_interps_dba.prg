CREATE PROGRAM bbt_chg_all_interps:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD ltext(
   1 qual[*]
     2 long_text_id = f8
 )
 SET reply->status_data.status = "F"
 SET t_cnt = 0
 SELECT INTO "nl:"
  ita.*
  FROM interp_task_assay ita
  WHERE (ita.interp_id=request->interp_id)
   AND ita.active_ind=1
  WITH nocounter, forupdate(ita)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INTERP_TASK_ASSAY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to select on INTERP_TASK_ASSAY table for desired record"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 UPDATE  FROM interp_task_assay ita
  SET ita.active_ind = 0, ita.updt_cnt = (ita.updt_cnt+ 1), ita.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ita.updt_id = reqinfo->updt_id, ita.updt_task = reqinfo->updt_task, ita.updt_applctx = reqinfo->
   updt_applctx
  WHERE (ita.interp_id=request->interp_id)
   AND ita.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INTERP_TASK_ASSAY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to inactive record on the INTERP_TASK_ASSAY table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ic.*
  FROM interp_component ic
  WHERE (ic.interp_id=request->interp_id)
   AND ic.active_ind=1
  WITH nocounter, forupdate(ic)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "T"
  GO TO exit_script
 ELSE
  UPDATE  FROM interp_component ic
   SET ic.active_ind = 0, ic.updt_cnt = (ic.updt_cnt+ 1), ic.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ic.updt_id = reqinfo->updt_id, ic.updt_task = reqinfo->updt_task, ic.updt_applctx = reqinfo->
    updt_applctx
   WHERE (ic.interp_id=request->interp_id)
    AND ic.active_ind=1
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "INTERP_COMPONENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to inactivate records on INTERP_COMPONENT table for interpretation"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ir.*
  FROM interp_range ir
  WHERE (ir.interp_id=request->interp_id)
   AND ir.active_ind=1
  WITH nocounter, forupdate(ir)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "T"
  GO TO exit_script
 ELSE
  UPDATE  FROM interp_range ir
   SET ir.active_ind = 0, ir.updt_cnt = (ir.updt_cnt+ 1), ir.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ir.updt_id = reqinfo->updt_id, ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->
    updt_applctx
   WHERE (ir.interp_id=request->interp_id)
    AND ir.active_ind=1
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "INTERP_RANGE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to inactivate records on the INTERP_RANGE table for the interpretation"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  rh.*
  FROM result_hash rh
  WHERE (rh.interp_id=request->interp_id)
   AND rh.active_ind=1
  WITH nocounter, forupdate(rh)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "RESULT_HASH"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to select rows on RESULT_HASH table for update"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ELSE
  UPDATE  FROM result_hash rh
   SET rh.active_ind = 0, rh.updt_cnt = (rh.updt_cnt+ 1), rh.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    rh.updt_id = reqinfo->updt_id, rh.updt_task = reqinfo->updt_task, rh.updt_applctx = reqinfo->
    updt_applctx
   WHERE (rh.interp_id=request->interp_id)
    AND rh.active_ind=1
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "RESULT_HASH"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to inactivate rows on RESULT_HASH table for interpretation"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ir.*
  FROM interp_result ir
  WHERE (ir.interp_id=request->interp_id)
   AND ir.active_ind=1
  DETAIL
   IF (ir.long_text_id > 0)
    t_cnt = (t_cnt+ 1), stat = alterlist(ltext->qual,t_cnt), ltext->qual[t_cnt].long_text_id = ir
    .long_text_id
   ENDIF
  WITH nocounter, forupdate(ir)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "T"
  GO TO exit_script
 ELSE
  UPDATE  FROM interp_result ir
   SET ir.active_ind = 0, ir.updt_cnt = (ir.updt_cnt+ 1), ir.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ir.updt_id = reqinfo->updt_id, ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->
    updt_applctx
   WHERE (ir.interp_id=request->interp_id)
    AND ir.active_ind=1
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "INTERP_RESULT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to inactivate records on the RESULT_HASH table for the interpretation"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  IF (t_cnt > 0)
   SELECT INTO "nl:"
    lt.*
    FROM long_text_reference lt,
     (dummyt d  WITH seq = value(t_cnt))
    PLAN (d)
     JOIN (lt
     WHERE (lt.long_text_id=ltext->qual[d.seq].long_text_id)
      AND lt.active_ind=1)
    WITH nocounter, forupdate(lt)
   ;end select
   IF (curqual != t_cnt)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT_REFERENCE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to select records on the long_text_reference table for the interpretation result"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    GO TO exit_script
   ELSE
    UPDATE  FROM long_text_reference lt,
      (dummyt d  WITH seq = value(t_cnt))
     SET lt.active_ind = 0, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d)
      JOIN (lt
      WHERE (lt.long_text_id=ltext->qual[d.seq].long_text_id)
       AND lt.active_ind=1)
     WITH counter
    ;end update
    IF (curqual != t_cnt)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_CHG_ALL_INTERPS"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT_REFERENCE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to inactivate records on the long_text_reference table for the interpretation result"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "T"
#exit_script
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
