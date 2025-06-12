CREATE PROGRAM dcp_chg_task_form:dba
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp_request(
   1 reference_task_id = f8
   1 dcp_forms_ref_id = f8
   1 charting_agent_cd = f8
   1 charting_agent_entity_id = f8
   1 charting_agent_entity_name = vc
   1 charting_agent_identifier = vc
   1 agent_qual[*]
     2 charting_agent_cd = f8
     2 charting_agent_entity_id = f8
     2 charting_agent_entity_name = vc
     2 charting_agent_identifier = vc
 )
 SET failed = false
 DECLARE tempcnt = i4 WITH noconstant(0)
 SET temp_request->reference_task_id = request->reference_task_id
 SET temp_request->dcp_forms_ref_id = request->dcp_forms_ref_id
 SET temp_request->charting_agent_cd = request->charting_agent_cd
 SET temp_request->charting_agent_entity_id = request->charting_agent_entity_id
 SET temp_request->charting_agent_entity_name = request->charting_agent_entity_name
 SET temp_request->charting_agent_identifier = request->charting_agent_identifier
 SET stat = alterlist(temp_request->agent_qual,size(request->agent_qual,5))
 FOR (tempcnt = 1 TO size(request->agent_qual,5))
   SET temp_request->agent_qual[tempcnt].charting_agent_cd = request->agent_qual[tempcnt].
   charting_agent_cd
   SET temp_request->agent_qual[tempcnt].charting_agent_entity_id = request->agent_qual[tempcnt].
   charting_agent_entity_id
   SET temp_request->agent_qual[tempcnt].charting_agent_entity_name = request->agent_qual[tempcnt].
   charting_agent_entity_name
   SET temp_request->agent_qual[tempcnt].charting_agent_identifier = request->agent_qual[tempcnt].
   charting_agent_identifier
 ENDFOR
 IF ((temp_request->dcp_forms_ref_id=0))
  SET temp_reference_task_id = temp_request->reference_task_id
  EXECUTE dcp_del_td_r_afc
 ENDIF
 UPDATE  FROM order_task ot
  SET ot.dcp_forms_ref_id = temp_request->dcp_forms_ref_id
  WHERE (ot.reference_task_id=temp_request->reference_task_id)
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "order_task"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CHANGE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
  SET failed = true
 ENDIF
 IF (failed=true)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  DELETE  FROM task_charting_agent_r tca
   WHERE (tca.reference_task_id=temp_request->reference_task_id)
   WITH nocounter
  ;end delete
  IF ((temp_request->charting_agent_cd > 0))
   INSERT  FROM task_charting_agent_r tca
    SET tca.task_charting_agent_r_id = seq(reference_seq,nextval), tca.reference_task_id =
     temp_request->reference_task_id, tca.charting_agent_cd = temp_request->charting_agent_cd,
     tca.charting_agent_entity_id = temp_request->charting_agent_entity_id, tca
     .charting_agent_entity_name = temp_request->charting_agent_entity_name, tca
     .charting_agent_identifier = temp_request->charting_agent_identifier,
     tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_id = reqinfo->updt_id, tca.updt_task
      = reqinfo->updt_task,
     tca.updt_cnt = 0, tca.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
  FOR (tempcnt = 1 TO size(temp_request->agent_qual,5))
    INSERT  FROM task_charting_agent_r tca
     SET tca.task_charting_agent_r_id = seq(reference_seq,nextval), tca.reference_task_id =
      temp_request->reference_task_id, tca.charting_agent_cd = temp_request->agent_qual[tempcnt].
      charting_agent_cd,
      tca.charting_agent_entity_id = temp_request->agent_qual[tempcnt].charting_agent_entity_id, tca
      .charting_agent_entity_name = temp_request->agent_qual[tempcnt].charting_agent_entity_name, tca
      .charting_agent_identifier = temp_request->agent_qual[tempcnt].charting_agent_identifier,
      tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_id = reqinfo->updt_id, tca.updt_task
       = reqinfo->updt_task,
      tca.updt_cnt = 0, tca.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
  ENDFOR
  IF ((temp_request->dcp_forms_ref_id > 0))
   SET temp_dcp_forms_ref_id = temp_request->dcp_forms_ref_id
   EXECUTE dcp_add_td_r_afc
  ENDIF
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
