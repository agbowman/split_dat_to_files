CREATE PROGRAM bbt_chg_interp_results:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET y = 1
 SET text_id = 0.0
 SET next_code = 0.0
 FOR (y = 1 TO request->qual_count)
  IF ((request->qual[y].updt_interp_result="T"))
   SELECT INTO "nl:"
    ir.*
    FROM interp_result ir
    WHERE (ir.interp_result_id=request->qual[y].interp_result_id)
     AND (ir.updt_cnt=request->qual[y].updt_cnt)
    WITH nocounter, forupdate(ir)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_interp_results"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "interp_result_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Interp Result"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  IF ((request->qual[y].updt_text_table="T")
   AND (((request->qual[y].add_remove_text="")) OR ((request->qual[y].add_remove_text="R"))) )
   SELECT INTO "nl:"
    lt.*
    FROM long_text_reference lt
    WHERE (lt.long_text_id=request->qual[y].long_text_id)
     AND (lt.updt_cnt=request->qual[y].result_text_updt_cnt)
    WITH nocounter, forupdate(lt)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_interp_results"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "long_text_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Long Text"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDFOR
 FOR (y = 1 TO request->qual_count)
  IF ((request->qual[y].updt_interp_result="T"))
   IF ((request->qual[y].add_remove_text="A"))
    EXECUTE cpm_next_code
    SET text_id = next_code
   ENDIF
   UPDATE  FROM interp_result ir
    SET ir.hash_pattern = request->qual[y].hash_pattern, ir.result_nomenclature_id =
     IF ((request->qual[y].result_nomenclature_id=- (1))) 0
     ELSE request->qual[y].result_nomenclature_id
     ENDIF
     , ir.result_cd =
     IF ((request->qual[y].result_cd=- (1))) 0
     ELSE request->qual[y].result_cd
     ENDIF
     ,
     ir.long_text_id =
     IF ((request->qual[y].add_remove_text="A")) text_id
     ELSEIF ((request->qual[y].add_remove_text="R")) 0
     ELSE ir.long_text_id
     ENDIF
     , ir.active_ind = request->qual[y].active_ind, ir.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ir.updt_id = reqinfo->updt_id, ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->
     updt_applctx,
     ir.updt_cnt = (ir.updt_cnt+ 1)
    WHERE (ir.interp_result_id=request->qual[y].interp_result_id)
     AND (ir.updt_cnt=request->qual[y].updt_cnt)
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_interp_results"
    SET reply->status_data.subeventstatus[1].operationname = "Modify"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "interp_result_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Interp Result"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  IF ((request->qual[y].updt_text_table="T"))
   IF ((request->qual[y].add_remove_text="A"))
    INSERT  FROM long_text_reference lt
     SET lt.long_text_id = text_id, lt.parent_entity_name = "INTERP_RESULT", lt.parent_entity_id =
      request->qual[y].interp_result_id,
      lt.long_text = request->qual[y].result_text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      lt.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
   ELSEIF ((request->qual[y].add_remove_text="R"))
    DELETE  FROM long_text_reference lt
     WHERE (lt.long_text_id=request->qual[y].long_text_id)
      AND (lt.updt_cnt=request->qual[y].result_text_updt_cnt)
     WITH nocounter
    ;end delete
   ELSE
    UPDATE  FROM long_text_reference lt
     SET lt.long_text_id = request->qual[y].long_text_id, lt.parent_entity_name = "INTERP_RESULT", lt
      .parent_entity_id = request->qual[y].interp_result_id,
      lt.long_text = request->qual[y].result_text, lt.updt_cnt = (request->qual[y].
      result_text_updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd
     WHERE (lt.long_text_id=request->qual[y].long_text_id)
      AND (lt.updt_cnt=request->qual[y].result_text_updt_cnt)
    ;end update
   ENDIF
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_interp_results"
    SET reply->status_data.subeventstatus[1].operationname = "Modify"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "long_text_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Long Text"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
