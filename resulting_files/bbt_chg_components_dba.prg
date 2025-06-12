CREATE PROGRAM bbt_chg_components:dba
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
 SET x = 0
 SET y = 0
 FOR (y = 1 TO request->comp_count)
   SELECT INTO "nl:"
    ic.*
    FROM interp_component ic
    WHERE (ic.interp_detail_id=request->comp_data[y].interp_detail_id)
     AND (ic.updt_cnt=request->comp_data[y].updt_cnt)
     AND ic.active_ind=1
    WITH counter, forupdate(ic)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Component"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
    interp_detail_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   UPDATE  FROM interp_component ic
    SET ic.sequence = request->comp_data[y].sequence, ic.verified_flag = request->comp_data[y].
     verified_flag, ic.cross_drawn_dt_tm_ind = request->comp_data[y].cross_time_ind,
     ic.time_window_minutes =
     IF ((request->comp_data[y].time_win_minutes=- (1))) null
     ELSE request->comp_data[y].time_win_minutes
     ENDIF
     , ic.time_window_units_cd =
     IF ((request->comp_data[y].time_win_min_cd=- (1))) 0
     ELSE request->comp_data[y].time_win_min_cd
     ENDIF
     , ic.result_req_flag = request->comp_data[y].result_req_flag,
     ic.active_ind = request->comp_data[y].active_ind, ic.updt_cnt = (ic.updt_cnt+ 1), ic.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     ic.updt_id = reqinfo->updt_id, ic.updt_task = reqinfo->updt_task, ic.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ic.interp_detail_id=request->comp_data[y].interp_detail_id)
     AND (ic.updt_cnt=request->comp_data[y].updt_cnt)
     AND ic.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Component"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
    interp_detail_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   IF ((request->comp_data[y].active_ind=0)
    AND (request->children_exist="T"))
    SELECT INTO "nl:"
     ir.*
     FROM interp_range ir
     WHERE (ir.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND ir.active_ind=1
     WITH counter, forupdate(ir)
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range Inactivate"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    UPDATE  FROM interp_range ir
     SET ir.active_ind = 0, ir.updt_cnt = (ir.updt_cnt+ 1), ir.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      ir.updt_id = reqinfo->updt_id, ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->
      updt_applctx
     WHERE (ir.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND ir.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Inactivate"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    SELECT INTO "nl:"
     rh.*
     FROM result_hash rh
     WHERE (rh.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND rh.active_ind=1
     WITH nocounter, forupdate(rh)
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash Inactivate"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    UPDATE  FROM result_hash rh
     SET rh.active_ind = 0, rh.updt_cnt = (rh.updt_cnt+ 1), rh.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      rh.updt_id = reqinfo->updt_id, rh.updt_task = reqinfo->updt_task, rh.updt_applctx = reqinfo->
      updt_applctx
     WHERE (rh.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND rh.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Inactivate"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
   IF ((request->comp_data[y].sequence_changed="T")
    AND (request->children_exist="T"))
    SELECT INTO "nl:"
     ir.*
     FROM interp_range ir
     WHERE (ir.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND ir.active_ind=1
     WITH counter, forupdate(ir)
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range Resequence"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    UPDATE  FROM interp_range ir
     SET ir.sequence = request->comp_data[y].sequence, ir.updt_cnt = (ir.updt_cnt+ 1), ir.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      ir.updt_id = reqinfo->updt_id, ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->
      updt_applctx
     WHERE (ir.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND ir.active_ind=1
     WITH nocounter
    ;end update
    FOR (x = 1 TO request->range_count)
      IF ((request->range_data[x].interp_detail_id=request->comp_data[y].interp_detail_id))
       SET request->range_data[x].updt_cnt = (request->range_data[x].updt_cnt+ 1)
      ENDIF
    ENDFOR
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Resequence"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    SELECT INTO "nl:"
     rh.*
     FROM result_hash rh
     WHERE (rh.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND rh.active_ind=1
     WITH nocounter, forupdate(rh)
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash Resequence"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    FOR (x = 1 TO request->result_count)
      IF ((request->result_data[x].interp_detail_id=request->comp_data[y].interp_detail_id))
       SET request->result_data[x].updt_cnt = (request->result_data[x].updt_cnt+ 1)
      ENDIF
    ENDFOR
    UPDATE  FROM result_hash rh
     SET rh.sequence = request->comp_data[y].sequence, rh.updt_cnt = (rh.updt_cnt+ 1), rh.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      rh.updt_id = reqinfo->updt_id, rh.updt_task = reqinfo->updt_task, rh.updt_applctx = reqinfo->
      updt_applctx
     WHERE (rh.interp_detail_id=request->comp_data[y].interp_detail_id)
      AND rh.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Resequence"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->comp_data[y].
     interp_detail_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
 ENDFOR
 FOR (y = 1 TO request->range_count)
   SELECT INTO "nl:"
    ir.*
    FROM interp_range ir
    WHERE (ir.interp_range_id=request->range_data[y].interp_range_id)
     AND (ir.updt_cnt=request->range_data[y].updt_cnt)
     AND ir.active_ind=1
    WITH counter, forupdate(ir)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range Update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
    interp_range_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   UPDATE  FROM interp_range ir
    SET ir.age_from_units_cd =
     IF ((request->range_data[y].age_from_units_cd=- (1))) 0
     ELSE request->range_data[y].age_from_units_cd
     ENDIF
     , ir.age_from_minutes = request->range_data[y].age_from_minutes, ir.age_to_units_cd =
     IF ((request->range_data[y].age_to_units_cd=- (1))) 0
     ELSE request->range_data[y].age_to_units_cd
     ENDIF
     ,
     ir.age_to_minutes = request->range_data[y].age_to_minutes, ir.species_cd =
     IF ((request->range_data[y].species_cd=- (1))) 0
     ELSE request->range_data[y].species_cd
     ENDIF
     , ir.gender_cd =
     IF ((request->range_data[y].gender_cd=- (1))) 0
     ELSE request->range_data[y].gender_cd
     ENDIF
     ,
     ir.race_cd =
     IF ((request->range_data[y].race_cd=- (1))) 0
     ELSE request->range_data[y].race_cd
     ENDIF
     , ir.unknown_age_ind = request->range_data[y].unknown_age_ind, ir.active_ind = request->
     range_data[y].active_ind,
     ir.updt_cnt = (ir.updt_cnt+ 1), ir.updt_dt_tm = cnvtdatetime(curdate,curtime3), ir.updt_id =
     reqinfo->updt_id,
     ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->updt_applctx
    WHERE (ir.interp_range_id=request->range_data[y].interp_range_id)
     AND (ir.updt_cnt=request->range_data[y].updt_cnt)
     AND ir.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Interp Range"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
    interp_range_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   IF ((request->range_data[y].active_ind=0))
    SELECT INTO "nl:"
     rh.*
     FROM result_hash rh
     WHERE (rh.interp_range_id=request->range_data[y].interp_range_id)
      AND rh.active_ind=1
     WITH nocounter, forupdate(rh)
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash Inactivate 2"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
     interp_range_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    UPDATE  FROM result_hash rh
     SET rh.active_ind = 0, rh.updt_cnt = (rh.updt_cnt+ 1), rh.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      rh.updt_id = reqinfo->updt_id, rh.updt_task = reqinfo->updt_task, rh.updt_applctx = reqinfo->
      updt_applctx
     WHERE (rh.interp_range_id=request->range_data[y].interp_range_id)
      AND rh.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
     SET reply->status_data.subeventstatus[1].operationname = "Inactivate"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
     interp_range_id
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
 ENDFOR
 FOR (y = 1 TO request->result_count)
   SELECT INTO "nl:"
    rh.*
    FROM result_hash rh
    WHERE (rh.result_hash_id=request->result_data[y].result_hash_id)
     AND (rh.updt_cnt=request->result_data[y].updt_cnt)
     AND rh.active_ind=1
    WITH nocounter, forupdate(rh)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash Update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
    interp_range_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   UPDATE  FROM result_hash rh
    SET rh.from_result_range =
     IF ((request->result_data[y].from_result_range_yn="N")) null
     ELSE request->result_data[y].from_result_range
     ENDIF
     , rh.to_result_range =
     IF ((request->result_data[y].to_result_range_yn="N")) null
     ELSE request->result_data[y].to_result_range
     ENDIF
     , rh.result_hash = request->result_data[y].result_hash,
     rh.nomenclature_id =
     IF ((request->result_data[y].nomenclature_id=- (1))) 0
     ELSE request->result_data[y].nomenclature_id
     ENDIF
     , rh.donor_eligibility_cd =
     IF ((request->result_data[y].donor_eligibility_cd=- (1))) 0
     ELSE request->result_data[y].donor_eligibility_cd
     ENDIF
     , rh.donor_reason_cd =
     IF ((request->result_data[y].donor_reason_cd=- (1))) 0
     ELSE request->result_data[y].donor_reason_cd
     ENDIF
     ,
     rh.days_ineligible = request->result_data[y].days_ineligible, rh.biohazard_ind = request->
     result_data[y].biohazard_ind, rh.active_ind = request->result_data[y].active_ind,
     rh.updt_cnt = (rh.updt_cnt+ 1), rh.updt_dt_tm = cnvtdatetime(curdate,curtime3), rh.updt_id =
     reqinfo->updt_id,
     rh.updt_task = reqinfo->updt_task, rh.updt_applctx = reqinfo->updt_applctx
    WHERE (rh.result_hash_id=request->result_data[y].result_hash_id)
     AND (rh.updt_cnt=request->result_data[y].updt_cnt)
     AND rh.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_components"
    SET reply->status_data.subeventstatus[1].operationname = "Modify"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Result Hash Update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = request->range_data[y].
    interp_range_id
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
