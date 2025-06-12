CREATE PROGRAM dm_cmb_metadata_maint:dba
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
 SET dcmm_reply->status = "S"
 SET dcmm_reply->err_msg = " "
 IF (error(dcmm_reply->err_msg,1) != 0)
  GO TO dcmm_exit
 ENDIF
 FOR (dcmm_lp_cnt = 1 TO value(size(dcmm_request->qual,5)))
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE (ut.table_name=dcmm_request->qual[dcmm_lp_cnt].child_table)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dcmm_request->qual[dcmm_lp_cnt].delete_row_ind = 1
   ENDIF
   IF ((dcmm_request->qual[dcmm_lp_cnt].delete_row_ind != 1))
    UPDATE  FROM dm_cmb_metadata dcm
     SET dcm.updt_id = reqinfo->updt_id, dcm.updt_cnt = (dcm.updt_cnt+ 1), dcm.updt_task = reqinfo->
      updt_task,
      dcm.updt_applctx = reqinfo->updt_applctx, dcm.updt_dt_tm = cnvtdatetime(sysdate), dcm
      .active_only_flag = dcmm_request->qual[dcmm_lp_cnt].active_only_flag,
      dcm.child_column = dcmm_request->qual[dcmm_lp_cnt].child_column, dcm.child_cons_name =
      dcmm_request->qual[dcmm_lp_cnt].child_cons_name, dcm.child_pe_name1_txt = dcmm_request->qual[
      dcmm_lp_cnt].child_pe_name1_txt,
      dcm.child_pe_name2_txt = dcmm_request->qual[dcmm_lp_cnt].child_pe_name2_txt, dcm
      .child_pe_name3_txt = dcmm_request->qual[dcmm_lp_cnt].child_pe_name3_txt, dcm
      .child_pe_name_column = dcmm_request->qual[dcmm_lp_cnt].child_pe_name_column,
      dcm.child_pk = dcmm_request->qual[dcmm_lp_cnt].child_pk, dcm.child_table = dcmm_request->qual[
      dcmm_lp_cnt].child_table, dcm.combine_action_type_cd = dcmm_request->qual[dcmm_lp_cnt].
      combine_action_type_cd,
      dcm.parent_table = dcmm_request->qual[dcmm_lp_cnt].parent_table
     WHERE (dcm.parent_table=dcmm_request->qual[dcmm_lp_cnt].parent_table)
      AND (dcm.child_table=dcmm_request->qual[dcmm_lp_cnt].child_table)
      AND (dcm.child_column=dcmm_request->qual[dcmm_lp_cnt].child_column)
     WITH nocounter
    ;end update
    IF (curqual=0)
     IF (error(dcmm_reply->err_msg,0) != 0)
      SET dcmm_reply->status = "F"
      GO TO dcmm_exit
     ENDIF
     INSERT  FROM dm_cmb_metadata dcm
      SET dcm.dm_cmb_metadata_id = seq(combine_seq,"NEXTVAL"), dcm.active_only_flag = dcmm_request->
       qual[dcmm_lp_cnt].active_only_flag, dcm.child_column = dcmm_request->qual[dcmm_lp_cnt].
       child_column,
       dcm.child_cons_name = dcmm_request->qual[dcmm_lp_cnt].child_cons_name, dcm.child_pe_name1_txt
        = dcmm_request->qual[dcmm_lp_cnt].child_pe_name1_txt, dcm.child_pe_name2_txt = dcmm_request->
       qual[dcmm_lp_cnt].child_pe_name2_txt,
       dcm.child_pe_name3_txt = dcmm_request->qual[dcmm_lp_cnt].child_pe_name3_txt, dcm
       .child_pe_name_column = dcmm_request->qual[dcmm_lp_cnt].child_pe_name_column, dcm.child_pk =
       dcmm_request->qual[dcmm_lp_cnt].child_pk,
       dcm.child_table = dcmm_request->qual[dcmm_lp_cnt].child_table, dcm.combine_action_type_cd =
       dcmm_request->qual[dcmm_lp_cnt].combine_action_type_cd, dcm.parent_table = dcmm_request->qual[
       dcmm_lp_cnt].parent_table,
       dcm.updt_id = reqinfo->updt_id, dcm.updt_cnt = 0, dcm.updt_task = reqinfo->updt_task,
       dcm.updt_applctx = reqinfo->updt_applctx, dcm.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     IF (error(dcmm_reply->err_msg,0) != 0)
      SET dcmm_reply->status = "F"
      GO TO dcmm_exit
     ENDIF
    ENDIF
   ELSE
    DELETE  FROM dm_cmb_metadata dcm
     WHERE (dcm.parent_table=dcmm_request->qual[dcmm_lp_cnt].parent_table)
      AND (dcm.child_table=dcmm_request->qual[dcmm_lp_cnt].child_table)
      AND (dcm.child_column=dcmm_request->qual[dcmm_lp_cnt].child_column)
     WITH nocounter
    ;end delete
    IF (error(dcmm_reply->err_msg,0) != 0)
     SET dcmm_reply->status = "F"
     GO TO dcmm_exit
    ENDIF
   ENDIF
   SET dgcemt_request->parent_entity = dcmm_request->qual[dcmm_lp_cnt].parent_table
   SET dgcemt_request->child_entity = concat(dcmm_request->qual[dcmm_lp_cnt].child_table,":",
    dcmm_request->qual[dcmm_lp_cnt].child_column)
   SET dgcemt_request->op_type = "CMB_METADATA"
   EXECUTE dm_get_cmb_exc_maint_type
   IF ((dgcemt_reply->status="F"))
    SET dcmm_reply->status = "F"
    SET dcmm_reply->err_msg = dgcemt_reply->err_msg
    GO TO dcmm_exit
   ELSEIF ((dgcemt_reply->cust_script_ind=0))
    INSERT  FROM dm_info d
     SET d.info_domain = concat(dgcemt_request->op_type,"_EXCEPTION:",cnvtupper(dgcemt_request->
        parent_entity)), d.info_name = concat(cnvtupper(dgcemt_request->child_entity)), d.updt_id =
      reqinfo->updt_id,
      d.updt_cnt = 0, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx,
      d.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (error(dcmm_reply->err_msg,0) != 0)
     SET dcmm_reply->status = "F"
     GO TO dcmm_exit
    ENDIF
   ENDIF
 ENDFOR
#dcmm_exit
END GO
