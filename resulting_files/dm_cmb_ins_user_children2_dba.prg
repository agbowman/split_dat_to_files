CREATE PROGRAM dm_cmb_ins_user_children2:dba
 DECLARE ct_det_cnt = i4 WITH protect, noconstant(0)
 DECLARE cmb_cnt = i4 WITH protect, noconstant(0)
 DECLARE col_cnt = i4 WITH protect, noconstant(0)
 DECLARE con_flg = i4 WITH protect, noconstant(0)
 DECLARE ct_head_cnt = i4 WITH protect, noconstant(0)
 DECLARE full_ind = i4 WITH protect, noconstant(0)
 DECLARE dciuc_errmsg = c132 WITH protect
 DECLARE dciuc_rec_ind = i2 WITH protect, noconstant(1)
 DECLARE dciu_debug_flag = i2 WITH protect, noconstant(0)
 DECLARE diu_check_admin = i2 WITH protect, noconstant(0)
 DECLARE diu_sub_query = vc WITH protect, noconstant("")
 DECLARE dciuc_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dciuc_ts_ind = i2 WITH protect, noconstant(0)
 DECLARE dciuc_idx = i4 WITH protect, noconstant(0)
 DECLARE dciuc_tbl_idx = i4 WITH protect, noconstant(0)
 DECLARE dciuc_idx2 = i4 WITH protect, noconstant(0)
 IF (validate(debug_flag,- (1)) > 0)
  SET dciu_debug_flag = debug_flag
 ENDIF
 CALL echo("Starting dm_cmb_ins_user_children2.prg")
 FREE RECORD cmb_child
 RECORD cmb_child(
   1 child_cnt = i4
   1 qual[*]
     2 parent_table = vc
     2 full_parent_table = vc
     2 child_table = vc
     2 full_child_table = vc
     2 child_column = vc
     2 child_fk = vc
     2 exists_ind = i2
     2 pk_exists_ind = i2
     2 update_ind = i2
 )
 FREE RECORD child_tbl
 RECORD child_tbl(
   1 tbl_cnt = i4
   1 max_col = i4
   1 tbl[*]
     2 table_name = vc
     2 full_table_name = vc
     2 pk_name = vc
     2 pk_col_cnt = i4
     2 pk_col[*]
       3 name = vc
       3 position = i4
       3 data_type = vc
     2 pk_ind = i2
     2 exists_ind = i2
 )
 IF ((validate(cmb_ins_reply->error_ind,- (999))=- (999)))
  CALL echo("Reply structure for error message doesn't exist")
  SET dciuc_rec_ind = 0
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COMBINE_TRIGGER_TYPE_PERSON"
  WITH nocounter, maxqual(di,1)
 ;end select
 IF (curqual=0)
  SET diu_check_admin = 1
 ENDIF
 IF (diu_check_admin=1)
  SELECT INTO "nl:"
   FROM dm_tables_doc dtd
   WITH nocounter, maxqual(dtd,1)
  ;end select
  SET dciuc_err_ind = error(dciuc_errmsg,0)
  IF (dciuc_err_ind > 0)
   CALL dciuc_error(dciuc_errmsg)
  ENDIF
  SET diu_sub_query =
  "exists(select 'x' from dm_tables_doc dtd where dtd.table_name = dcc.table_name)"
 ELSE
  SET diu_sub_query = concat(
   "exists(select 'x' from dm_info di where di.info_domain = 'COMBINE_TRIGGER_TYPE_PERSON' ",
   " and di.info_name = dcc.table_name)")
 ENDIF
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints dc,
   user_constraints uc,
   user_tables uta,
   user_tables utb
  PLAN (uc
   WHERE uc.table_name IN ("PRSNL", "LOCATION", "ORGANIZATION", "HEALTH_PLAN")
    AND uc.constraint_type="P")
   JOIN (dc
   WHERE uc.constraint_name=dc.r_constraint_name
    AND findstring("$",dc.table_name)=0
    AND dc.constraint_type="R")
   JOIN (dcc
   WHERE dc.constraint_name=dcc.constraint_name
    AND dcc.position=1
    AND dc.table_name=dcc.table_name
    AND parser(diu_sub_query))
   JOIN (uta
   WHERE uta.table_name=uc.table_name)
   JOIN (utb
   WHERE utb.table_name=dcc.table_name)
  DETAIL
   cmb_cnt += 1
   IF (mod(cmb_cnt,100)=1)
    stat = alterlist(cmb_child->qual,(cmb_cnt+ 99))
   ENDIF
   cmb_child->qual[cmb_cnt].parent_table = uc.table_name, cmb_child->qual[cmb_cnt].child_table = dc
   .table_name, cmb_child->qual[cmb_cnt].child_column = dcc.column_name,
   cmb_child->qual[cmb_cnt].child_fk = dcc.constraint_name, cmb_child->qual[cmb_cnt].exists_ind = 0,
   cmb_child->qual[cmb_cnt].full_parent_table = uta.table_name,
   cmb_child->qual[cmb_cnt].full_child_table = utb.table_name, cmb_child->qual[cmb_cnt].pk_exists_ind
    = 0, cmb_child->qual[cmb_cnt].update_ind = 0
  FOOT REPORT
   cmb_child->child_cnt = cmb_cnt
  WITH nocounter
 ;end select
 IF ((cmb_child->child_cnt=0))
  CALL dciuc_error("Could not find child tables for any parents")
 ENDIF
 IF (dciu_debug_flag=1)
  CALL echo(build("child_cnt=",cmb_child->child_cnt))
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children2 dcc,
   (dummyt d  WITH seq = value(cmb_child->child_cnt)),
   (dummyt dt  WITH seq = 1)
  PLAN (dcc)
   JOIN (dt)
   JOIN (d
   WHERE (cmb_child->qual[d.seq].full_child_table=dcc.child_table)
    AND (cmb_child->qual[d.seq].full_parent_table=dcc.parent_table)
    AND (cmb_child->qual[d.seq].child_column=dcc.child_column))
  DETAIL
   cmb_cnt += 1
   IF (mod(cmb_cnt,100)=1)
    stat = alterlist(cmb_child->qual,(cmb_cnt+ 99))
   ENDIF
   cmb_child->qual[cmb_cnt].child_column = dcc.child_column, cmb_child->qual[cmb_cnt].child_fk = dcc
   .child_cons_name, cmb_child->qual[cmb_cnt].exists_ind = 1,
   cmb_child->qual[cmb_cnt].full_parent_table = dcc.parent_table, cmb_child->qual[cmb_cnt].
   full_child_table = dcc.child_table, cmb_child->qual[cmb_cnt].pk_exists_ind = 0,
   cmb_child->qual[cmb_cnt].update_ind = 0,
   CALL echo(dcc.child_table)
  FOOT REPORT
   cmb_child->child_cnt = cmb_cnt
  WITH nocounter, outerjoin = dt, dontexist
 ;end select
 SET stat = alterlist(cmb_child->qual,cmb_child->child_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cmb_child->child_cnt)),
   user_tables ut
  PLAN (d
   WHERE (cmb_child->qual[d.seq].exists_ind=1))
   JOIN (ut
   WHERE (cmb_child->qual[d.seq].full_child_table=ut.table_name))
  DETAIL
   cmb_child->qual[d.seq].child_table = ut.table_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_cmb_children2 dcc,
   (dummyt d  WITH seq = value(cmb_child->child_cnt))
  PLAN (d)
   JOIN (dcc
   WHERE (cmb_child->qual[d.seq].full_child_table=dcc.child_table)
    AND (cmb_child->qual[d.seq].full_parent_table=dcc.parent_table)
    AND (cmb_child->qual[d.seq].child_column=dcc.child_column))
  DETAIL
   cmb_child->qual[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (dciu_debug_flag=1)
  CALL echo(build("second cmb_cnt =",cmb_cnt))
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children2 dcc,
   (dummyt d  WITH seq = value(cmb_child->child_cnt))
  PLAN (d)
   JOIN (dcc
   WHERE (cmb_child->qual[d.seq].full_child_table=dcc.child_table)
    AND (cmb_child->qual[d.seq].full_parent_table=dcc.parent_table)
    AND (cmb_child->qual[d.seq].child_column=dcc.child_column))
  DETAIL
   IF ((cmb_child->qual[d.seq].child_fk != dcc.child_cons_name))
    cmb_child->qual[d.seq].update_ind = 1,
    CALL echo(build("updated table:",dcc.child_table))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints uc,
   user_tab_cols utc
  PLAN (uc
   WHERE uc.constraint_type="P"
    AND expand(dciuc_idx,1,cmb_child->child_cnt,uc.table_name,cmb_child->qual[dciuc_idx].child_table)
   )
   JOIN (dcc
   WHERE dcc.table_name=uc.table_name
    AND dcc.constraint_name=uc.constraint_name)
   JOIN (utc
   WHERE utc.table_name=dcc.table_name
    AND utc.column_name=dcc.column_name)
  ORDER BY dcc.constraint_name, dcc.position
  HEAD dcc.constraint_name
   ct_det_cnt = 0, ct_head_cnt += 1
   IF (mod(ct_head_cnt,100)=1)
    stat = alterlist(child_tbl->tbl,(ct_head_cnt+ 99))
   ENDIF
   dciuc_tbl_idx = locateval(dciuc_idx,1,cmb_child->child_cnt,dcc.table_name,cmb_child->qual[
    dciuc_idx].child_table), child_tbl->tbl[ct_head_cnt].table_name = dcc.table_name, child_tbl->tbl[
   ct_head_cnt].full_table_name = cmb_child->qual[dciuc_tbl_idx].full_child_table,
   child_tbl->tbl[ct_head_cnt].pk_name = dcc.constraint_name, child_tbl->tbl[ct_head_cnt].pk_ind = 1,
   child_tbl->tbl[ct_head_cnt].pk_col_cnt = 0
  HEAD dcc.position
   IF (utc.hidden_column="NO"
    AND utc.virtual_column="NO")
    ct_det_cnt += 1
    IF (mod(ct_det_cnt,10)=1)
     stat = alterlist(child_tbl->tbl[ct_head_cnt].pk_col,(ct_det_cnt+ 9))
    ENDIF
    child_tbl->tbl[ct_head_cnt].pk_col[ct_det_cnt].name = dcc.column_name, child_tbl->tbl[ct_head_cnt
    ].pk_col[ct_det_cnt].position = dcc.position, child_tbl->tbl[ct_head_cnt].pk_col[ct_det_cnt].
    data_type = utc.data_type
    IF (utc.data_type=patstring("TIMESTAMP*"))
     dciuc_err_ind = 1, dciuc_errmsg = concat("Error on table: ",trim(child_tbl->tbl[ct_head_cnt].
       table_name),
      ". Unique keys containing TIMESTAMP columns are not allowed for combinable tables.")
    ENDIF
   ELSE
    dciuc_err_ind = 1, dciuc_errmsg = concat("Error on table: ",trim(child_tbl->tbl[ct_head_cnt].
      table_name),". Hidden and Virtual columns not allowed for primary keys for combinable tables.")
   ENDIF
  DETAIL
   c = 1
  FOOT  dcc.constraint_name
   child_tbl->tbl[ct_head_cnt].pk_col_cnt = ct_det_cnt, stat = alterlist(child_tbl->tbl[ct_head_cnt].
    pk_col,ct_det_cnt)
  FOOT REPORT
   child_tbl->tbl_cnt = ct_head_cnt
  WITH nocounter, expand = 1
 ;end select
 IF ((child_tbl->tbl_cnt=0))
  CALL dciuc_error("Could not find PK info for table DM_CMB_CHILDREN_PK")
 ENDIF
 IF (dciuc_err_ind=1)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 SELECT INTO "nl:"
  FROM user_ind_columns dcc,
   user_indexes ui
  PLAN (ui
   WHERE ui.uniqueness="UNIQUE"
    AND ui.index_type="NORMAL"
    AND expand(dciuc_idx2,1,cmb_child->child_cnt,ui.table_name,cmb_child->qual[dciuc_idx2].
    child_table))
   JOIN (dcc
   WHERE dcc.index_name=ui.index_name
    AND dcc.table_name=ui.table_name
    AND expand(dciuc_idx,1,cmb_child->child_cnt,dcc.table_name,cmb_child->qual[dciuc_idx].child_table,
    dcc.column_name,cmb_child->qual[dciuc_idx].child_column))
  ORDER BY dcc.index_name, dcc.column_position
  HEAD dcc.index_name
   skip_flag = 0
   FOR (id_cnt = 1 TO child_tbl->tbl_cnt)
     IF ((ui.index_name=child_tbl->tbl[id_cnt].pk_name))
      skip_flag = 1, id_cnt = cmb_child->child_cnt
     ENDIF
   ENDFOR
   IF (skip_flag=0)
    ct_head_cnt += 1
    IF (mod(ct_head_cnt,100)=1)
     stat = alterlist(child_tbl->tbl,(ct_head_cnt+ 99))
    ENDIF
    dciuc_tbl_idx = locateval(dciuc_idx,1,cmb_child->child_cnt,dcc.table_name,cmb_child->qual[
     dciuc_idx].child_table), child_tbl->tbl[ct_head_cnt].table_name = dcc.table_name, child_tbl->
    tbl[ct_head_cnt].full_table_name = cmb_child->qual[dciuc_tbl_idx].full_child_table,
    child_tbl->tbl[ct_head_cnt].pk_name = dcc.index_name, child_tbl->tbl[ct_head_cnt].pk_ind = 0,
    child_tbl->tbl[ct_head_cnt].pk_col_cnt = 0
   ENDIF
  DETAIL
   c = 1
  FOOT REPORT
   child_tbl->tbl_cnt = ct_head_cnt, stat = alterlist(child_tbl->tbl,ct_head_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM user_tab_cols uc,
   user_ind_columns dcc
  PLAN (dcc
   WHERE expand(dciuc_idx,1,child_tbl->tbl_cnt,dcc.index_name,child_tbl->tbl[dciuc_idx].pk_name,
    dcc.table_name,child_tbl->tbl[dciuc_idx].table_name,0,child_tbl->tbl[dciuc_idx].pk_ind))
   JOIN (uc
   WHERE uc.table_name=dcc.table_name
    AND uc.column_name=dcc.column_name)
  ORDER BY dcc.index_name, dcc.column_position
  HEAD dcc.index_name
   ct_det_cnt = 0, dciuc_ts_ind = 0
  HEAD dcc.column_position
   dciuc_tbl_idx = locateval(dciuc_idx,1,child_tbl->tbl_cnt,dcc.index_name,child_tbl->tbl[dciuc_idx].
    pk_name,
    dcc.table_name,child_tbl->tbl[dciuc_idx].table_name,0,child_tbl->tbl[dciuc_idx].pk_ind),
   ct_det_cnt += 1
   IF (mod(ct_det_cnt,10)=1)
    stat = alterlist(child_tbl->tbl[dciuc_tbl_idx].pk_col,(ct_det_cnt+ 9))
   ENDIF
   child_tbl->tbl[dciuc_tbl_idx].pk_col[ct_det_cnt].name = dcc.column_name, child_tbl->tbl[
   dciuc_tbl_idx].pk_col[ct_det_cnt].position = dcc.column_position, child_tbl->tbl[dciuc_tbl_idx].
   pk_col[ct_det_cnt].data_type = uc.data_type
   IF (uc.data_type=patstring("TIMESTAMP*"))
    dciuc_ts_ind = 1
   ENDIF
  DETAIL
   c = 1
  FOOT  dcc.index_name
   dciuc_tbl_idx = locateval(dciuc_idx,1,child_tbl->tbl_cnt,dcc.index_name,child_tbl->tbl[dciuc_idx].
    pk_name,
    dcc.table_name,child_tbl->tbl[dciuc_idx].table_name,0,child_tbl->tbl[dciuc_idx].pk_ind)
   IF (dciuc_ts_ind=0)
    child_tbl->tbl[dciuc_tbl_idx].pk_col_cnt = ct_det_cnt, stat = alterlist(child_tbl->tbl[
     dciuc_tbl_idx].pk_col,ct_det_cnt)
   ELSE
    stat = alterlist(child_tbl->tbl[dciuc_tbl_idx].pk_col,0)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echo(build("end child_tbl=",child_tbl->tbl_cnt))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = child_tbl->tbl_cnt),
   (dummyt d  WITH seq = cmb_child->child_cnt)
  PLAN (d)
   JOIN (d1
   WHERE (child_tbl->tbl[d1.seq].table_name=cmb_child->qual[d.seq].child_table)
    AND (child_tbl->tbl[d1.seq].pk_ind=1))
  DETAIL
   cmb_child->qual[d.seq].pk_exists_ind = 1
  WITH nocounter
 ;end select
 IF (dciu_debug_flag=1)
  CALL echorecord(cmb_child)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children_pk dccp,
   (dummyt d  WITH seq = value(child_tbl->tbl_cnt))
  PLAN (d)
   JOIN (dccp
   WHERE dccp.pk_ind=1
    AND (child_tbl->tbl[d.seq].full_table_name=dccp.child_table)
    AND (child_tbl->tbl[d.seq].pk_name=dccp.pk_index_name))
  DETAIL
   child_tbl->tbl[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (dciu_debug_flag=1)
  CALL echorecord(child_tbl)
 ENDIF
 SET dciuc_err_ind = error(dciuc_errmsg,1)
 UPDATE  FROM dm_cmb_children2 dcc,
   (dummyt d  WITH seq = value(cmb_child->child_cnt))
  SET dcc.seq = 1, dcc.child_cons_name = cmb_child->qual[d.seq].child_fk, dcc.updt_dt_tm =
   cnvtdatetime(sysdate),
   dcc.updt_cnt = (dcc.updt_cnt+ 1)
  PLAN (d
   WHERE (cmb_child->qual[d.seq].update_ind=1)
    AND (cmb_child->qual[d.seq].pk_exists_ind=1))
   JOIN (dcc
   WHERE (dcc.parent_table=cmb_child->qual[d.seq].full_parent_table)
    AND (cmb_child->qual[d.seq].full_child_table=dcc.child_table)
    AND (cmb_child->qual[d.seq].child_column=dcc.child_column))
  WITH nocounter
 ;end update
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 INSERT  FROM dm_cmb_children2 dcc2,
   (dummyt d  WITH seq = cmb_child->child_cnt)
  SET dcc2.seq = 1, dcc2.parent_table = cmb_child->qual[d.seq].full_parent_table, dcc2.child_table =
   cmb_child->qual[d.seq].full_child_table,
   dcc2.child_column = cmb_child->qual[d.seq].child_column, dcc2.child_cons_name = cmb_child->qual[d
   .seq].child_fk, dcc2.create_dt_tm = cnvtdatetime(sysdate),
   dcc2.updt_dt_tm = cnvtdatetime(sysdate), dcc2.updt_cnt = 0
  PLAN (d
   WHERE (cmb_child->qual[d.seq].exists_ind=0)
    AND (cmb_child->qual[d.seq].pk_exists_ind=1))
   JOIN (dcc2)
  WITH nocounter
 ;end insert
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 DELETE  FROM dm_cmb_children_pk dccp
  WHERE dccp.pk_ind=0
  WITH nocounter
 ;end delete
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 INSERT  FROM dm_cmb_children_pk dccp,
   (dummyt d  WITH seq = value(child_tbl->tbl_cnt)),
   (dummyt dt  WITH seq = 50)
  SET dccp.seq = 1, dccp.child_table = child_tbl->tbl[d.seq].full_table_name, dccp.pk_index_name =
   child_tbl->tbl[d.seq].pk_name,
   dccp.pk_column_name = child_tbl->tbl[d.seq].pk_col[dt.seq].name, dccp.pk_column_pos = child_tbl->
   tbl[d.seq].pk_col[dt.seq].position, dccp.pk_column_type = child_tbl->tbl[d.seq].pk_col[dt.seq].
   data_type,
   dccp.pk_ind = child_tbl->tbl[d.seq].pk_ind, dccp.create_dt_tm = cnvtdatetime(sysdate), dccp
   .updt_dt_tm = cnvtdatetime(sysdate),
   dccp.updt_cnt = 0
  PLAN (d
   WHERE (child_tbl->tbl[d.seq].pk_ind=1)
    AND (child_tbl->tbl[d.seq].exists_ind=0))
   JOIN (dt
   WHERE (dt.seq <= child_tbl->tbl[d.seq].pk_col_cnt))
   JOIN (dccp)
  WITH nocounter
 ;end insert
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 INSERT  FROM dm_cmb_children_pk dccp,
   (dummyt d  WITH seq = value(child_tbl->tbl_cnt)),
   (dummyt dt  WITH seq = 50)
  SET dccp.seq = 1, dccp.child_table = child_tbl->tbl[d.seq].full_table_name, dccp.pk_index_name =
   child_tbl->tbl[d.seq].pk_name,
   dccp.pk_column_name = child_tbl->tbl[d.seq].pk_col[dt.seq].name, dccp.pk_column_pos = child_tbl->
   tbl[d.seq].pk_col[dt.seq].position, dccp.pk_column_type = child_tbl->tbl[d.seq].pk_col[dt.seq].
   data_type,
   dccp.pk_ind = child_tbl->tbl[d.seq].pk_ind, dccp.create_dt_tm = cnvtdatetime(sysdate), dccp
   .updt_dt_tm = cnvtdatetime(sysdate),
   dccp.updt_cnt = 0
  PLAN (d
   WHERE (child_tbl->tbl[d.seq].pk_ind=0))
   JOIN (dt
   WHERE (dt.seq <= child_tbl->tbl[d.seq].pk_col_cnt))
   JOIN (dccp)
  WITH nocounter
 ;end insert
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 UPDATE  FROM dm_info
  SET info_date = cnvtdatetime(sysdate)
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="CMB_LAST_UPDT2"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info
   SET info_domain = "DATA MANAGEMENT", info_name = "CMB_LAST_UPDT2", info_date = cnvtdatetime(
     sysdate),
    info_char = null, info_number = null, info_long_id = 0,
    updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = 0, updt_cnt = 0,
    updt_id = 0, updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET dciuc_err_ind = error(dciuc_errmsg,0)
 IF (dciuc_err_ind > 0)
  CALL dciuc_error(dciuc_errmsg)
 ENDIF
 COMMIT
 SUBROUTINE (dciuc_error(sub_msg=vc) =null)
   ROLLBACK
   IF (dciuc_rec_ind=1)
    SET cmb_ins_reply->error_ind = 1
    SET cmb_ins_reply->error_msg = sub_msg
   ELSEIF (dciuc_rec_ind=0)
    CALL echo(sub_msg)
   ENDIF
   GO TO exit_program
 END ;Subroutine
#exit_program
 CALL echo("Ending dm_cmb_ins_user_children2.prg")
END GO
