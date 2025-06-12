CREATE PROGRAM dm_dm_cmb_exception:dba
 IF (validate(dgcemt_request->parent_entity,"X")="X")
  RECORD dgcemt_request(
    1 parent_entity = c30
    1 child_entity = c30
    1 op_type = c10
  )
 ENDIF
 IF ((validate(dgcemt_reply->cust_script_ind,- (1))=- (1)))
  RECORD dgcemt_reply(
    1 cust_script_ind = i2
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET readme_data->status = reply->status_data.status
 SET readme_data->message = "Readme Failed: Starting dm_dm_cmb_exception.prg script"
 SET dgcemt_request->parent_entity = request->parent_entity
 SET dgcemt_request->child_entity = request->child_entity
 SET dgcemt_request->op_type = request->operation_type
 EXECUTE dm_get_cmb_exc_maint_type
 IF ((dgcemt_reply->status="S"))
  IF ((dgcemt_reply->cust_script_ind=1))
   SET reply->status_data.status = "S"
  ELSE
   IF ((request->delete_row_ind != 1))
    UPDATE  FROM dm_cmb_exception dce
     SET dce.updt_id = reqinfo->updt_id, dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_task = reqinfo->
      updt_task,
      dce.updt_applctx = reqinfo->updt_applctx, dce.updt_dt_tm = cnvtdatetime(sysdate), dce
      .script_name = request->script_name,
      dce.single_encntr_ind = request->single_encntr_ind, dce.script_run_order = request->
      script_run_order, dce.del_chg_id_ind = request->del_chg_id_ind
     WHERE (dce.operation_type=request->operation_type)
      AND (dce.parent_entity=request->parent_entity)
      AND (dce.child_entity=request->child_entity)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_cmb_exception dce
      SET dce.operation_type = request->operation_type, dce.parent_entity = request->parent_entity,
       dce.child_entity = request->child_entity,
       dce.updt_id = reqinfo->updt_id, dce.updt_cnt = 0, dce.updt_task = reqinfo->updt_task,
       dce.updt_applctx = reqinfo->updt_applctx, dce.updt_dt_tm = cnvtdatetime(sysdate), dce
       .script_name = request->script_name,
       dce.single_encntr_ind = request->single_encntr_ind, dce.script_run_order = request->
       script_run_order, dce.del_chg_id_ind = request->del_chg_id_ind
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET reply->status_data.status = "S"
     ENDIF
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ELSE
    DELETE  FROM dm_cmb_exception dce
     WHERE (dce.operation_type=request->operation_type)
      AND (dce.parent_entity=request->parent_entity)
      AND (dce.child_entity=request->child_entity)
     WITH nocounter
    ;end delete
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="S"))
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = reply->status_data.status
 IF ((readme_data->status="S"))
  SET readme_data->message = "DM_DM_CMB_EXCEPTION.prg completed successfully"
 ENDIF
 EXECUTE dm_readme_status
END GO
