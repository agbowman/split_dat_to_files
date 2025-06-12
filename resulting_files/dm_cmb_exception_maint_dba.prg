CREATE PROGRAM dm_cmb_exception_maint:dba
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
 SET dcem_reply->status = "S"
 SET dcem_reply->err_msg = " "
 IF (error(dcem_reply->err_msg,1) != 0)
  GO TO dcem_exit
 ENDIF
 FOR (dcem_lp_cnt = 1 TO value(size(dcem_request->qual,5)))
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE (ut.table_name=dcem_request->qual[dcem_lp_cnt].child_entity)
    WITH nocounter
   ;end select
   IF (curqual=0
    AND operator(dcem_request->qual[dcem_lp_cnt].child_entity,"NOT REGEXPLIKE",".+DRR"))
    SET dcem_request->qual[dcem_lp_cnt].delete_row_ind = 1
   ENDIF
   IF ((dcem_request->qual[dcem_lp_cnt].delete_row_ind != 1))
    UPDATE  FROM dm_cmb_exception dce
     SET dce.updt_id = reqinfo->updt_id, dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_task = reqinfo->
      updt_task,
      dce.updt_applctx = reqinfo->updt_applctx, dce.updt_dt_tm = cnvtdatetime(sysdate), dce
      .script_name = dcem_request->qual[dcem_lp_cnt].script_name,
      dce.single_encntr_ind = dcem_request->qual[dcem_lp_cnt].single_encntr_ind, dce.script_run_order
       = dcem_request->qual[dcem_lp_cnt].script_run_order, dce.del_chg_id_ind = dcem_request->qual[
      dcem_lp_cnt].del_chg_id_ind
     WHERE (dce.operation_type=dcem_request->qual[dcem_lp_cnt].op_type)
      AND (dce.parent_entity=dcem_request->qual[dcem_lp_cnt].parent_entity)
      AND (dce.child_entity=dcem_request->qual[dcem_lp_cnt].child_entity)
     WITH nocounter
    ;end update
    IF (curqual=0)
     IF (error(dcem_reply->err_msg,0) != 0)
      SET dcem_reply->status = "F"
      GO TO dcem_exit
     ENDIF
     INSERT  FROM dm_cmb_exception dce
      SET dce.operation_type = dcem_request->qual[dcem_lp_cnt].op_type, dce.parent_entity =
       dcem_request->qual[dcem_lp_cnt].parent_entity, dce.child_entity = dcem_request->qual[
       dcem_lp_cnt].child_entity,
       dce.updt_id = reqinfo->updt_id, dce.updt_cnt = 0, dce.updt_task = reqinfo->updt_task,
       dce.updt_applctx = reqinfo->updt_applctx, dce.updt_dt_tm = cnvtdatetime(sysdate), dce
       .script_name = dcem_request->qual[dcem_lp_cnt].script_name,
       dce.single_encntr_ind = dcem_request->qual[dcem_lp_cnt].single_encntr_ind, dce
       .script_run_order = dcem_request->qual[dcem_lp_cnt].script_run_order, dce.del_chg_id_ind =
       dcem_request->qual[dcem_lp_cnt].del_chg_id_ind
      WITH nocounter
     ;end insert
     IF (error(dcem_reply->err_msg,0) != 0)
      SET dcem_reply->status = "F"
      GO TO dcem_exit
     ENDIF
    ENDIF
   ELSE
    DELETE  FROM dm_cmb_exception dce
     WHERE (dce.operation_type=dcem_request->qual[dcem_lp_cnt].op_type)
      AND (dce.parent_entity=dcem_request->qual[dcem_lp_cnt].parent_entity)
      AND (dce.child_entity=dcem_request->qual[dcem_lp_cnt].child_entity)
     WITH nocounter
    ;end delete
    IF (error(dcem_reply->err_msg,0) != 0)
     SET dcem_reply->status = "F"
     GO TO dcem_exit
    ENDIF
   ENDIF
   SET dgcemt_request->parent_entity = dcem_request->qual[dcem_lp_cnt].parent_entity
   SET dgcemt_request->child_entity = dcem_request->qual[dcem_lp_cnt].child_entity
   SET dgcemt_request->op_type = dcem_request->qual[dcem_lp_cnt].op_type
   EXECUTE dm_get_cmb_exc_maint_type
   IF ((dgcemt_reply->status="F"))
    SET dcem_reply->status = "F"
    SET dcem_reply->err_msg = dgcemt_reply->err_msg
    GO TO dcem_exit
   ELSEIF ((dgcemt_reply->cust_script_ind=0))
    INSERT  FROM dm_info d
     SET d.info_domain = concat(dcem_request->qual[dcem_lp_cnt].op_type,"_EXCEPTION:",cnvtupper(
        dcem_request->qual[dcem_lp_cnt].parent_entity)), d.info_name = dcem_request->qual[dcem_lp_cnt
      ].child_entity, d.updt_id = reqinfo->updt_id,
      d.updt_cnt = 0, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx,
      d.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (error(dcem_reply->err_msg,0) != 0)
     SET dcem_reply->status = "F"
     GO TO dcem_exit
    ENDIF
   ENDIF
 ENDFOR
#dcem_exit
END GO
