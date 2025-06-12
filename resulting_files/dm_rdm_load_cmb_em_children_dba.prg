CREATE PROGRAM dm_rdm_load_cmb_em_children:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_load_cmb_em_children..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE loop = i4 WITH protect, noconstant(0)
 DECLARE drlcec_iter = i4 WITH protect, noconstant(0)
 DECLARE drlcec_updt_flag = i4 WITH protect, noconstant(0)
 DECLARE drlcec_insert_flag = i4 WITH protect, noconstant(0)
 DECLARE drlcec_cur_dae_id = f8 WITH protect, noconstant(0.0)
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 child_table = vc
     2 child_cmb_column = vc
     2 child_pk_column = vc
     2 parent_table = vc
     2 parent_cmb_column = vc
     2 from_clause = vc
     2 where_clause = vc
     2 run_order = i4
     2 active_ind = i4
 )
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].child_table = cnvtupper(requestin->list_0[loop].child_table)
   SET copy_requestin->list_0[loop].child_cmb_column = cnvtupper(requestin->list_0[loop].
    child_cmb_column)
   SET copy_requestin->list_0[loop].child_pk_column = cnvtupper(requestin->list_0[loop].
    child_pk_column)
   SET copy_requestin->list_0[loop].parent_table = cnvtupper(requestin->list_0[loop].parent_table)
   SET copy_requestin->list_0[loop].parent_cmb_column = cnvtupper(requestin->list_0[loop].
    parent_cmb_column)
   SET copy_requestin->list_0[loop].from_clause = cnvtupper(requestin->list_0[loop].from_clause)
   SET copy_requestin->list_0[loop].where_clause = cnvtupper(requestin->list_0[loop].where_clause)
   SET copy_requestin->list_0[loop].run_order = cnvtreal(requestin->list_0[loop].run_order)
   SET copy_requestin->list_0[loop].active_ind = cnvtreal(requestin->list_0[loop].active_ind)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (size(requestin->list_0,5) > 0)
  FOR (drlcec_iter = 1 TO size(requestin->list_0,5))
    SET drlcec_updt_flag = 0
    SET drlcec_insert_flag = 0
    SELECT INTO "nl:"
     FROM dm_cmb_em_children ec
     WHERE (ec.child_table=copy_requestin->list_0[drlcec_iter].child_table)
      AND (ec.child_cmb_column=copy_requestin->list_0[drlcec_iter].child_cmb_column)
     DETAIL
      drlcec_updt_flag = 1
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to select DM_CMB_EM_CHILDREN: ",errmsg)
     GO TO exit_script
    ELSEIF (curqual=0)
     SET drlcec_insert_flag = 1
    ENDIF
    IF (drlcec_updt_flag=1)
     UPDATE  FROM dm_cmb_em_children ec
      SET ec.child_table = copy_requestin->list_0[drlcec_iter].child_table, ec.child_cmb_column =
       copy_requestin->list_0[drlcec_iter].child_cmb_column, ec.child_pk_column = copy_requestin->
       list_0[drlcec_iter].child_pk_column,
       ec.parent_table = copy_requestin->list_0[drlcec_iter].parent_table, ec.parent_cmb_column =
       copy_requestin->list_0[drlcec_iter].parent_cmb_column, ec.from_clause = copy_requestin->
       list_0[drlcec_iter].from_clause,
       ec.where_clause = copy_requestin->list_0[drlcec_iter].where_clause, ec.run_order =
       copy_requestin->list_0[drlcec_iter].run_order, ec.active_ind = copy_requestin->list_0[
       drlcec_iter].active_ind,
       ec.updt_dt_tm = cnvtdatetime(curdate,curtime3), ec.updt_task = reqinfo->updt_task, ec
       .updt_applctx = reqinfo->updt_applctx,
       ec.updt_id = reqinfo->updt_id, ec.updt_cnt = (ec.updt_cnt+ 1)
      WHERE (ec.child_table=copy_requestin->list_0[drlcec_iter].child_table)
       AND (ec.child_cmb_column=copy_requestin->list_0[drlcec_iter].child_cmb_column)
      WITH nocounter
     ;end update
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to update DM_CMB_EM_CHILDREN: ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
    IF (drlcec_insert_flag=1)
     SELECT INTO "nl:"
      x = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       drlcec_cur_dae_id = cnvtreal(x)
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->message = concat("Failed to get next seq val: ",errmsg)
      GO TO exit_script
     ENDIF
     INSERT  FROM dm_cmb_em_children ec
      SET ec.child_table = copy_requestin->list_0[drlcec_iter].child_table, ec.child_cmb_column =
       copy_requestin->list_0[drlcec_iter].child_cmb_column, ec.child_pk_column = copy_requestin->
       list_0[drlcec_iter].child_pk_column,
       ec.parent_table = copy_requestin->list_0[drlcec_iter].parent_table, ec.parent_cmb_column =
       copy_requestin->list_0[drlcec_iter].parent_cmb_column, ec.from_clause = copy_requestin->
       list_0[drlcec_iter].from_clause,
       ec.where_clause = copy_requestin->list_0[drlcec_iter].where_clause, ec.run_order =
       copy_requestin->list_0[drlcec_iter].run_order, ec.active_ind = copy_requestin->list_0[
       drlcec_iter].active_ind,
       ec.dm_cmb_em_children_id = drlcec_cur_dae_id, ec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ec.updt_task = reqinfo->updt_task,
       ec.updt_applctx = reqinfo->updt_applctx, ec.updt_id = reqinfo->updt_id, ec.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to insert DM_CMB_EM_CHILDREN: ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: batch data loaded successfully"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD copy_requestin
END GO
