CREATE PROGRAM dm_cleanup_cmb_tables:dba
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
 IF (validate(mgx_errcode,0)=0)
  SET mgx_errmsg = fillstring(132," ")
  SET mgx_errcode = 0
  SET mgx_errcode = error(mgx_errmsg,1)
 ENDIF
 FREE RECORD cmb_tables
 RECORD cmb_tables(
   1 cnt = i4
   1 qual[*]
     2 name = vc
     2 cnt = i4
     2 list[*]
       3 parent_entity = vc
       3 operation_type = vc
       3 exist_flag = i2
 )
 SET cmb_tables->cnt = 0
 SET stat = alterlist(cmb_tables->qual,cmb_tables->cnt)
 CALL echo("**************************")
 CALL echo("Grab a list of obsolete tables that do not exist in this environment.")
 CALL echo("**************************")
 SET mgx_errcode = error(mgx_errmsg,1)
 SELECT INTO "NL:"
  dtd.table_name, dtd.drop_ind
  FROM dm_tables_doc dtd
  WHERE dtd.drop_ind=1
   AND dtd.table_name=dtd.full_table_name
   AND  NOT ( EXISTS (
  (SELECT
   utc.table_name
   FROM user_tab_columns utc
   WHERE utc.table_name=dtd.table_name)))
  ORDER BY dtd.table_name
  DETAIL
   cmb_tables->cnt = (cmb_tables->cnt+ 1), stat = alterlist(cmb_tables->qual,cmb_tables->cnt),
   cmb_tables->qual[cmb_tables->cnt].name = cnvtupper(dtd.table_name),
   cmb_tables->qual[cmb_tables->cnt].cnt = 4, stat = alterlist(cmb_tables->qual[cmb_tables->cnt].list,
    4), cmb_tables->qual[cmb_tables->cnt].list[1].parent_entity = "PERSON",
   cmb_tables->qual[cmb_tables->cnt].list[1].operation_type = "COMBINE", cmb_tables->qual[cmb_tables
   ->cnt].list[1].exist_flag = 0, cmb_tables->qual[cmb_tables->cnt].list[2].parent_entity = "PERSON",
   cmb_tables->qual[cmb_tables->cnt].list[2].operation_type = "UNCOMBINE", cmb_tables->qual[
   cmb_tables->cnt].list[2].exist_flag = 0, cmb_tables->qual[cmb_tables->cnt].list[3].parent_entity
    = "ENCOUNTER",
   cmb_tables->qual[cmb_tables->cnt].list[3].operation_type = "COMBINE", cmb_tables->qual[cmb_tables
   ->cnt].list[3].exist_flag = 0, cmb_tables->qual[cmb_tables->cnt].list[4].parent_entity =
   "ENCOUNTER",
   cmb_tables->qual[cmb_tables->cnt].list[4].operation_type = "UNCOMBINE", cmb_tables->qual[
   cmb_tables->cnt].list[4].exist_flag = 0
  WITH nocounter
 ;end select
 SET mgx_errcode = error(mgx_errmsg,0)
 IF (mgx_errcode)
  SET readme_data->message = "ERROR: Could not query DM_TABLES_DOC with USER_TAB_COLUMNS."
  GO TO exit_script
 ENDIF
 IF ((cmb_tables->cnt > 0))
  CALL echo("**************************")
  CALL echo(
   "Obsolete tables found and should not exist in DM_CMB_CHILDREN table. Attempting to delete rows..."
   )
  CALL echo("**************************")
  SET mgx_errcode = error(mgx_errmsg,1)
  DELETE  FROM dm_cmb_children dcc,
    (dummyt d  WITH seq = value(cmb_tables->cnt))
   SET dcc.seq = 1
   PLAN (d)
    JOIN (dcc
    WHERE (dcc.child_table=cmb_tables->qual[d.seq].name))
   WITH nocounter
  ;end delete
  SET mgx_errcode = error(mgx_errmsg,0)
  IF (mgx_errcode)
   ROLLBACK
   SET readme_data->message = "ERROR: Could not delete rows from DM_CMB_CHILDREN."
   GO TO exit_script
  ELSE
   COMMIT
   CALL echo("**************************")
   CALL echo(concat("Successfully deleted the following number of rows from DM_CMB_CHILDREN: ",
     cnvtstring(curqual)))
   CALL echo("**************************")
  ENDIF
  CALL echo("**************************")
  CALL echo("Check if these obsolete tables have DM_CMB_EXCEPTION rows...")
  CALL echo("**************************")
  SET mgx_errcode = error(mgx_errmsg,1)
  SELECT INTO "NL:"
   dce.child_entity
   FROM dm_cmb_exception dce,
    (dummyt d  WITH seq = value(cmb_tables->cnt)),
    (dummyt d1  WITH seq = value(cmb_tables->qual[cmb_tables->cnt].cnt))
   PLAN (d)
    JOIN (d1)
    JOIN (dce
    WHERE (dce.operation_type=cmb_tables->qual[d.seq].list[d1.seq].operation_type)
     AND (dce.parent_entity=cmb_tables->qual[d.seq].list[d1.seq].parent_entity)
     AND (dce.child_entity=cmb_tables->qual[d.seq].name))
   DETAIL
    cmb_tables->qual[d.seq].list[d1.seq].exist_flag = 1
   WITH nocounter
  ;end select
  SET mgx_errcode = error(mgx_errmsg,0)
  IF (mgx_errcode)
   SET readme_data->message = "ERROR: Could not select rows from DM_CMB_EXCEPTION."
   GO TO exit_script
  ENDIF
  CALL echo("**************************")
  CALL echo("If rows exist then update them so that Script_Name = 'NONE' and Script_run_order = 0.")
  CALL echo("**************************")
  SET mgx_errcode = error(mgx_errmsg,1)
  UPDATE  FROM dm_cmb_exception dm,
    (dummyt d  WITH seq = value(cmb_tables->cnt)),
    (dummyt d1  WITH seq = value(cmb_tables->qual[cmb_tables->cnt].cnt))
   SET dm.seq = 1, dm.single_encntr_ind = 0, dm.script_name = "NONE",
    dm.script_run_order = 0, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (d1
    WHERE (cmb_tables->qual[d.seq].list[d1.seq].exist_flag=1))
    JOIN (dm
    WHERE (dm.operation_type=cmb_tables->qual[d.seq].list[d1.seq].operation_type)
     AND (dm.parent_entity=cmb_tables->qual[d.seq].list[d1.seq].parent_entity)
     AND (dm.child_entity=cmb_tables->qual[d.seq].name))
   WITH nocounter
  ;end update
  SET mgx_errcode = error(mgx_errmsg,0)
  IF (mgx_errcode)
   ROLLBACK
   SET readme_data->message = "ERROR: Could not UPDATE rows in DM_CMB_EXCEPTION."
   GO TO exit_script
  ELSE
   COMMIT
   CALL echo(concat("Successfully updated the following number of rows in DM_CMB_EXCEPTION: ",
     cnvtstring(curqual)))
  ENDIF
  CALL echo("**************************")
  CALL echo("If rows don't exist, then insert them appropriately.")
  CALL echo("**************************")
  SET mgx_errcode = error(mgx_errmsg,1)
  INSERT  FROM dm_cmb_exception dce,
    (dummyt d  WITH seq = value(cmb_tables->cnt)),
    (dummyt d1  WITH seq = value(cmb_tables->qual[cmb_tables->cnt].cnt))
   SET dce.seq = 1, dce.operation_type = cmb_tables->qual[d.seq].list[d1.seq].operation_type, dce
    .parent_entity = cmb_tables->qual[d.seq].list[d1.seq].parent_entity,
    dce.child_entity = cmb_tables->qual[d.seq].name, dce.script_name = "NONE", dce.single_encntr_ind
     = 0,
    dce.script_run_order = 0, dce.del_chg_id_ind = 0, dce.updt_cnt = 0,
    dce.updt_id = 0, dce.updt_dt_tm = cnvtdatetime(curdate,curtime3), dce.updt_applctx = 0,
    dce.updt_task = 0
   PLAN (d)
    JOIN (d1
    WHERE (cmb_tables->qual[d.seq].list[d1.seq].exist_flag=0))
    JOIN (dce)
   WITH nocounter
  ;end insert
  SET mgx_errcode = error(mgx_errmsg,0)
  IF (mgx_errcode)
   ROLLBACK
   SET readme_data->message = "ERROR: Could not INSERT rows in DM_CMB_EXCEPTION."
   GO TO exit_script
  ELSE
   COMMIT
   CALL echo("**************************")
   CALL echo(concat("Successfully inserted the following number of rows in DM_CMB_EXCEPTION: ",
     cnvtstring(curqual)))
   CALL echo("**************************")
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "SUCCES: No obsolete objects found in DM_TABLES_DOC, hence NO ACTION taken."
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "SUCCESS: DM_CMB_CHILDREN and DM_CMB_EXCEPTION have been modified to account for ALL obsolete tables."
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
