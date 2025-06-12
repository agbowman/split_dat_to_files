CREATE PROGRAM dm_fill_dm_cmb_children2:dba
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
 FREE RECORD cmb_ins_reply
 RECORD cmb_ins_reply(
   1 error_ind = i2
   1 error_msg = vc
 )
 SET cmb_ins_reply->error_ind = 0
 SET readme_data->message = "Get Clinical Environment ID."
 EXECUTE dm_readme_status
 DECLARE cur_env_id = i4
 DECLARE dcc_row_cnt = i4
 DECLARE chk_row_cnt = i4
 SET dcc_row_cnt = 0
 SET chk_row_cnt = 0
 SET cur_env_id = 0
 FREE RECORD chk_tbl
 RECORD chk_tbl(
   1 tbl_cnt = i4
   1 list[*]
     2 tbl_name = vc
     2 cons_name = vc
     2 full_table_name = vc
     2 child_column = vc
 )
 FREE RECORD hlp_tbl
 RECORD hlp_tbl(
   1 hlp_cnt = i4
   1 list[*]
     2 fulltbl_name = vc
     2 tbl_name = vc
 )
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
  DETAIL
   cur_env_id = d.info_number
  WITH nocounter
 ;end select
 EXECUTE dm_cmb_ins_user_children2
 IF ((cmb_ins_reply->error_ind=1))
  SET readme_data->status = "F"
  SET readme_data->message = cmb_ins_reply->error_msg
  GO TO exit_script
 ENDIF
 FREE RECORD miss_table
 RECORD miss_table(
   1 list[*]
     2 table_name = vc
 )
 SELECT INTO "nl:"
  FROM user_constraints dc,
   user_constraints uc,
   dm_tables_doc tdp,
   dm_tables_doc tdc
  PLAN (uc
   WHERE uc.table_name IN ("PRSNL", "PRSNL0386", "LOCATION", "LOCATION0737", "ORGANIZATION",
   "ORGANIZATION0376", "HEALTH_PLAN", "HEALTH_PLAN0373")
    AND uc.constraint_type="P"
    AND uc.owner=currdbuser)
   JOIN (dc
   WHERE dc.owner=uc.owner
    AND uc.constraint_name=dc.r_constraint_name
    AND findstring("$",dc.table_name)=0
    AND dc.constraint_type="R"
    AND  EXISTS (
   (SELECT
    "X"
    FROM user_constraints uc1
    WHERE uc1.owner=dc.owner
     AND uc1.constraint_type="P"
     AND uc1.table_name=dc.table_name))
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM dm_cmb_children2 d
    WHERE d.child_cons_name=dc.constraint_name))))
   JOIN (tdp
   WHERE tdp.table_name=uc.table_name)
   JOIN (tdc
   WHERE tdc.table_name=dc.table_name)
  DETAIL
   chk_row_cnt = (chk_row_cnt+ 1), stat = alterlist(miss_table->list,chk_row_cnt), miss_table->list[
   chk_row_cnt].table_name = dc.table_name
  WITH nocounter
 ;end select
 CALL echo(build("dm_cmb_children2 check =",chk_row_cnt))
 IF (chk_row_cnt > 0)
  CALL echo("Missing the following tables:")
  CALL echorecord(miss_table)
  SET readme_data->message = concat("Population for dm_cmb_children2 failed:",trim(cnvtstring(
     chk_row_cnt))," tables missing")
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd,
   user_tables ut
  PLAN (ut)
   JOIN (dtd
   WHERE ut.table_name=dtd.table_name)
  DETAIL
   hlp_tbl->hlp_cnt = (hlp_tbl->hlp_cnt+ 1)
   IF (mod(hlp_tbl->hlp_cnt,1000)=1)
    stat = alterlist(hlp_tbl->list,(hlp_tbl->hlp_cnt+ 999))
   ENDIF
   hlp_tbl->list[hlp_tbl->hlp_cnt].fulltbl_name = dtd.full_table_name, hlp_tbl->list[hlp_tbl->hlp_cnt
   ].tbl_name = dtd.table_name
  FOOT REPORT
   stat = alterlist(hlp_tbl->list,hlp_tbl->hlp_cnt)
  WITH nocounter
 ;end select
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm_cmb_children2 dcc,
    (dummyt d  WITH seq = value(hlp_tbl->hlp_cnt))
   PLAN (dcc)
    JOIN (d
    WHERE (dcc.child_table=hlp_tbl->list[d.seq].tbl_name))
   DETAIL
    chk_tbl->tbl_cnt = (chk_tbl->tbl_cnt+ 1)
    IF (mod(chk_tbl->tbl_cnt,1000)=1)
     stat = alterlist(chk_tbl->list,(chk_tbl->tbl_cnt+ 999))
    ENDIF
    chk_tbl->list[chk_tbl->tbl_cnt].tbl_name = hlp_tbl->list[d.seq].tbl_name, chk_tbl->list[chk_tbl->
    tbl_cnt].cons_name = dcc.child_cons_name, chk_tbl->list[chk_tbl->tbl_cnt].full_table_name =
    hlp_tbl->list[d.seq].fulltbl_name,
    chk_tbl->list[chk_tbl->tbl_cnt].child_column = dcc.child_column
   FOOT REPORT
    stat = alterlist(chk_tbl->list,chk_tbl->tbl_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dm_cmb_children2 dcc,
    (dummyt d  WITH seq = value(hlp_tbl->hlp_cnt))
   PLAN (dcc)
    JOIN (d
    WHERE (dcc.child_table=hlp_tbl->list[d.seq].fulltbl_name))
   DETAIL
    chk_tbl->tbl_cnt = (chk_tbl->tbl_cnt+ 1)
    IF (mod(chk_tbl->tbl_cnt,1000)=1)
     stat = alterlist(chk_tbl->list,(chk_tbl->tbl_cnt+ 999))
    ENDIF
    chk_tbl->list[chk_tbl->tbl_cnt].tbl_name = hlp_tbl->list[d.seq].tbl_name, chk_tbl->list[chk_tbl->
    tbl_cnt].cons_name = dcc.child_cons_name, chk_tbl->list[chk_tbl->tbl_cnt].full_table_name =
    hlp_tbl->list[d.seq].fulltbl_name,
    chk_tbl->list[chk_tbl->tbl_cnt].child_column = dcc.child_column
   FOOT REPORT
    stat = alterlist(chk_tbl->list,chk_tbl->tbl_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("tbl_cnt=",chk_tbl->tbl_cnt))
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints uc,
   (dummyt d  WITH seq = chk_tbl->tbl_cnt)
  PLAN (d)
   JOIN (uc
   WHERE uc.owner=currdbuser
    AND uc.constraint_type="P"
    AND (uc.table_name=chk_tbl->list[d.seq].tbl_name))
   JOIN (dcc
   WHERE dcc.table_name=uc.table_name
    AND dcc.constraint_name=uc.constraint_name
    AND dcc.owner=uc.owner
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM dm_cmb_children_pk dccp
    WHERE dccp.pk_ind=1
     AND (dccp.child_table=chk_tbl->list[d.seq].full_table_name)
     AND dccp.pk_column_name=dcc.column_name
     AND dccp.pk_column_pos=dcc.position))))
  DETAIL
   chk_row_cnt = (chk_row_cnt+ 1), stat = alterlist(miss_table->list,chk_row_cnt), miss_table->list[
   chk_row_cnt].table_name = dcc.table_name
  WITH nocounter
 ;end select
 CALL echo(build("pk=",chk_row_cnt))
 IF (chk_row_cnt > 0)
  CALL echo("The following tables are missing PK:")
  CALL echorecord(miss_table)
  SET readme_data->message = concat("Population for dm_cmb_children_pk failed:",cnvtstring(
    chk_row_cnt)," pk missing")
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(chk_tbl->tbl_cnt)),
   user_ind_columns dcc,
   user_indexes ui
  PLAN (ui
   WHERE ui.uniqueness="UNIQUE")
   JOIN (d
   WHERE (ui.table_name=chk_tbl->list[d.seq].tbl_name))
   JOIN (dcc
   WHERE dcc.index_name=ui.index_name
    AND (dcc.table_name=chk_tbl->list[d.seq].tbl_name)
    AND (dcc.column_name=chk_tbl->list[d.seq].child_column)
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM dm_cmb_children_pk dccp
    WHERE dccp.pk_index_name=dcc.index_name))))
  DETAIL
   chk_row_cnt = (chk_row_cnt+ 1), stat = alterlist(miss_table->list,chk_row_cnt), miss_table->list[
   chk_row_cnt].table_name = dcc.table_name
  WITH nocounter
 ;end select
 CALL echo(build("uk=",chk_row_cnt))
 IF (chk_row_cnt > 0)
  CALL echo("The following tables are missing unique key:")
  CALL echorecord(miss_table)
  SET readme_data->message = concat("Population for dm_cmb_children2 failed:",cnvtstring(chk_row_cnt),
   " unique indexs missing")
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children_pk d,
   user_ind_columns dcc,
   user_indexes ui
  PLAN (ui
   WHERE ui.uniqueness="UNIQUE")
   JOIN (d
   WHERE ui.index_name=d.pk_index_name
    AND ui.table_name=d.child_table
    AND d.pk_ind=0)
   JOIN (dcc
   WHERE dcc.index_name=ui.index_name
    AND dcc.table_name=d.child_table
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM dm_cmb_children_pk dccp
    WHERE dccp.pk_ind=0
     AND dccp.pk_column_name=dcc.column_name
     AND dccp.pk_column_pos=dcc.column_position
     AND dccp.pk_index_name=dcc.index_name))))
  DETAIL
   chk_row_cnt = (chk_row_cnt+ 1), stat = alterlist(miss_table->list,chk_row_cnt), miss_table->list[
   chk_row_cnt].table_name = dcc.table_name
  WITH nocounter
 ;end select
 CALL echo(build("uk col=",chk_row_cnt))
 IF (chk_row_cnt > 0)
  CALL echo("The following tables are missing unique key:")
  CALL echorecord(miss_table)
  SET readme_data->message = concat(
   "Population for dm_cmb_children2 failed, unique indexes info are not correct ")
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET readme_data->message = "Import for dm_cmb_children2/dm_cmb_children_pk was successful."
 SET readme_data->status = "S"
#exit_script
 EXECUTE dm_readme_status
 CALL echo(readme_data->message)
END GO
