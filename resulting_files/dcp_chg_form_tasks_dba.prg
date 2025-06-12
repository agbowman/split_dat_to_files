CREATE PROGRAM dcp_chg_form_tasks:dba
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
   1 charting_agent_cd = f8
   1 charting_agent_entity_id = f8
   1 charting_agent_entity_name = vc
   1 charting_agent_identifier = vc
   1 dcp_forms_ref_id = f8
   1 task_cnt = i4
   1 task_qual[*]
     2 reference_task_id = f8
 )
 RECORD task_list(
   1 qual[*]
     2 reference_task_id = f8
 )
 RECORD tca_task_list(
   1 qual[*]
     2 reference_task_id = f8
 )
 SET failed = false
 SET taskcnt = 0
 SET temp_request->dcp_forms_ref_id = request->dcp_forms_ref_id
 SET temp_request->task_cnt = request->task_cnt
 SET temp_request->charting_agent_cd = request->charting_agent_cd
 SET temp_request->charting_agent_entity_id = request->charting_agent_entity_id
 SET temp_request->charting_agent_entity_name = request->charting_agent_entity_name
 SET temp_request->charting_agent_identifier = request->charting_agent_identifier
 SET stat = alterlist(temp_request->task_qual,temp_request->task_cnt)
 FOR (cnt = 1 TO temp_request->task_cnt)
   SET temp_request->task_qual[cnt].reference_task_id = request->task_qual[cnt].reference_task_id
 ENDFOR
 IF ((temp_request->dcp_forms_ref_id > 0))
  SELECT INTO "nl:"
   ot.reference_task_id
   FROM order_task ot
   WHERE (ot.dcp_forms_ref_id=temp_request->dcp_forms_ref_id)
   DETAIL
    taskcnt = (taskcnt+ 1)
    IF (taskcnt > size(task_list->qual,5))
     stat = alterlist(task_list->qual,(taskcnt+ 5))
    ENDIF
    task_list->qual[taskcnt].reference_task_id = ot.reference_task_id
   WITH nocounter
  ;end select
  SET stat = alterlist(task_list->qual,taskcnt)
  UPDATE  FROM order_task ot
   SET ot.dcp_forms_ref_id = 0
   WHERE (ot.dcp_forms_ref_id=temp_request->dcp_forms_ref_id)
   WITH nocounter
  ;end update
 ENDIF
 FOR (cntx = 1 TO taskcnt)
  SET temp_reference_task_id = task_list->qual[cntx].reference_task_id
  EXECUTE dcp_del_td_r_afc
 ENDFOR
 IF ((temp_request->task_cnt > 0))
  UPDATE  FROM order_task ot,
    (dummyt d1  WITH seq = value(temp_request->task_cnt))
   SET ot.dcp_forms_ref_id = temp_request->dcp_forms_ref_id
   PLAN (d1)
    JOIN (ot
    WHERE (ot.reference_task_id=temp_request->task_qual[d1.seq].reference_task_id))
   WITH nocounter
  ;end update
  IF (curqual <= 0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "order_task"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CHANGE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
   SET failed = true
  ENDIF
 ENDIF
 DELETE  FROM task_charting_agent_r tca
  WHERE (tca.charting_agent_entity_id=temp_request->charting_agent_entity_id)
  WITH nocounter
 ;end delete
 INSERT  FROM task_charting_agent_r tca,
   (dummyt d1  WITH seq = value(temp_request->task_cnt))
  SET tca.task_charting_agent_r_id = seq(reference_seq,nextval), tca.reference_task_id = temp_request
   ->task_qual[d1.seq].reference_task_id, tca.charting_agent_cd = temp_request->charting_agent_cd,
   tca.charting_agent_entity_id = temp_request->charting_agent_entity_id, tca
   .charting_agent_entity_name = temp_request->charting_agent_entity_name, tca
   .charting_agent_identifier = temp_request->charting_agent_identifier,
   tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_id = reqinfo->updt_id, tca.updt_task =
   reqinfo->updt_task,
   tca.updt_cnt = 0, tca.updt_applctx = reqinfo->updt_applctx
  PLAN (d1)
   JOIN (tca)
  WITH nocounter
 ;end insert
 IF (failed=true)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  IF ((temp_request->dcp_forms_ref_id > 0))
   SET temp_dcp_forms_ref_id = temp_request->dcp_forms_ref_id
   EXECUTE dcp_add_td_r_afc
  ENDIF
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
