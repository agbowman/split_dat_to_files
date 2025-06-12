CREATE PROGRAM dm_fix_fk_ce_event_prsnl:dba
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
 FREE RECORD tables
 RECORD tables(
   1 list[3]
     2 name = vc
     2 fk_name = c30
     2 fk_name2 = c30
     2 tmp_fk_name = c30
     2 fk_exists = i2
     2 child_exists = i2
     2 child_column = vc
 )
 DECLARE rdm_err_msg = vc
 DECLARE dm_cnt = i4
 DECLARE dm_for_cnt = i4
 DECLARE dm_three_cnt = i4
 DECLARE dm_fifty_cnt = i4
 DECLARE d_str = vc
 DECLARE dm_failed_cons = vc
 DECLARE d_fk_created = i2
 DECLARE d_fk_exists = i2
 DECLARE d_child_exists = i2
 DECLARE d_xfk11_ind = i2
 DECLARE d_xfk12_ind = i2
 DECLARE d_xfk13_ind = i2
 DECLARE dm_child_cnt = i2
 DECLARE d_name = vc
 DECLARE d_fk_name = vc
 DECLARE d_suffix_name = vc
 DECLARE tmp_fk_name = vc
 DECLARE tmp_r_fk_name = vc
 DECLARE tmp_r_fk_name2 = vc
 DECLARE tmp_r_name = vc
 DECLARE cmb_lst_updt = c13
 DECLARE cmb_lst_updt2 = c14
 SET cmb_lst_updt = "CMB_LAST_UPDT"
 SET cmb_lst_updt2 = "CMB_LAST_UPDT2"
 SET d_fk_name = " "
 SET d_name = " "
 SET rdm_err_msg = fillstring(132," ")
 SET dm_cnt = 0
 SET d_xfk11_ind = 0
 SET d_xfk12_ind = 0
 SET d_xfk13_ind = 0
 SET dm_chid_cnt = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_fix_fk_ce_event_prsnl script."
 SELECT INTO "nl:"
  FROM dm2_user_tables ut,
   dm_tables_doc dtd
  PLAN (dtd
   WHERE dtd.table_name IN ("CE_EVENT_PRSNL", "PERSON", "PRSNL"))
   JOIN (ut
   WHERE ut.table_name=dtd.table_name)
  DETAIL
   IF (dtd.table_name="CE_EVENT_PRSNL")
    IF (currdb="ORACLE")
     d_name = dtd.full_table_name, tables->list[1].name = dtd.full_table_name, tables->list[1].
     tmp_fk_name = "XFK2CE_EVENT_PRSNL*",
     tables->list[1].fk_name = "XFK2CE_EVENT_PRSNL", tables->list[1].fk_name2 = "XFK11CE_EVENT_PRSNL"
    ELSEIF (currdb="DB2UDB")
     d_name = dtd.suffixed_table_name, tables->list[1].name = dtd.suffixed_table_name, tables->list[1
     ].tmp_fk_name = build("XFK2CE_EVENT",dtd.table_suffix,"*"),
     tables->list[1].fk_name = build("XFK2CE_EVENT",dtd.table_suffix), tables->list[1].fk_name2 =
     build("XFK11CE_EVEN",dtd.table_suffix)
    ENDIF
   ELSEIF (dtd.table_name="PRSNL")
    IF (currdb="ORACLE")
     tmp_r_fk_name2 = "XPKPRSNL", tmp_r_name = "PRSNL"
    ELSEIF (currdb="DB2UDB")
     tmp_r_fk_name2 = build("XPKPRSNL",dtd.table_suffix,"*"), tmp_r_name = concat("PRSNL",dtd
      .table_suffix)
    ENDIF
   ELSE
    IF (currdb="ORACLE")
     tmp_r_fk_name = "XPKPERSON"
    ELSEIF (currdb="DB2UDB")
     tmp_r_fk_name = build("XPKPERSON",dtd.table_suffix,"*")
    ENDIF
   ENDIF
  FOOT REPORT
   IF (currdb="ORACLE")
    tables->list[2].name = dtd.full_table_name, tables->list[2].tmp_fk_name = "XFK3CE_EVENT_PRSNL*",
    tables->list[2].fk_name = "XFK3CE_EVENT_PRSNL",
    tables->list[2].fk_name2 = "XFK12CE_EVENT_PRSNL", tables->list[3].name = dtd.full_table_name,
    tables->list[3].tmp_fk_name = "XFK4CE_EVENT_PRSNL*",
    tables->list[3].fk_name = "XFK4CE_EVENT_PRSNL", tables->list[3].fk_name2 = "XFK13CE_EVENT_PRSNL"
   ELSEIF (currdb="DB2UDB")
    tables->list[2].name = dtd.suffixed_table_name, tables->list[2].tmp_fk_name = build(
     "XFK3CE_EVENT",dtd.table_suffix,"*"), tables->list[2].fk_name = build("XFK3CE_EVENT",dtd
     .table_suffix),
    tables->list[2].fk_name2 = build("XFK12CE_EVEN",dtd.table_suffix), tables->list[3].name = dtd
    .suffixed_table_name, tables->list[3].tmp_fk_name = build("XFK4CE_EVENT",dtd.table_suffix,"*"),
    tables->list[3].fk_name = build("XFK4CE_EVENT",dtd.table_suffix), tables->list[3].fk_name2 =
    build("XFK13CE_EVEN",dtd.table_suffix)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("ERROR: Select from dm2_user_tables where table_name = '",d_name,
   "' failed.")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("SUCCESS: table ",d_name,
   " does not exist, no need to run program")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc
  WHERE uc.table_name=d_name
   AND uc.constraint_name IN (patstring(tables->list[1].tmp_fk_name), patstring(tables->list[2].
   tmp_fk_name), patstring(tables->list[3].tmp_fk_name))
   AND uc.r_constraint_name IN (tmp_r_fk_name, concat(tmp_r_fk_name,"$C"))
  HEAD REPORT
   dm_cnt = 0
  DETAIL
   dm_cnt = (dm_cnt+ 1)
   FOR (dm_for_cnt = 1 TO 3)
     IF (d_name=uc.table_name
      AND (tables->list[dm_for_cnt].fk_exists != 1))
      tables->list[dm_cnt].fk_name = uc.constraint_name
     ENDIF
   ENDFOR
   tables->list[dm_cnt].fk_exists = 1, d_fk_exists = 1
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "ERROR: could not retrieve data from dm2_user_constraints where table_name = '",d_name,"'")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  GO TO step2
 ENDIF
 FOR (dm_fifty_cnt = 1 TO 50)
   FOR (dm_three_cnt = 1 TO 3)
     IF ((tables->list[dm_three_cnt].fk_exists=1))
      IF (currdb="ORACLE")
       SET d_str = concat("rdb alter table ",d_name," disable constraint ",tables->list[dm_three_cnt]
        .fk_name," go")
      ELSEIF (currdb="DB2UDB")
       SET d_str = concat("rdb alter table ",d_suffix_name," alter foreign key ",tables->list[
        dm_three_cnt].fk_name," not enforced go")
      ENDIF
      CALL echo(d_str)
      CALL parser(d_str)
      IF (error(rdm_err_msg,1) != 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("ERROR: Could not disable constraint ",tables->list[
        dm_three_cnt].fk_name)
      ELSE
       IF (currdb="ORACLE")
        SET d_str = concat("rdb alter TABLE ",d_name," drop CONSTRAINT ",tables->list[dm_three_cnt].
         fk_name," go")
       ELSEIF (currdb="DB2UDB")
        SET d_str = concat("rdb alter TABLE ",d_suffix_name," drop CONSTRAINT ",tables->list[
         dm_three_cnt].fk_name," go")
       ENDIF
       CALL echo(d_str)
       CALL parser(d_str)
       IF (error(rdm_err_msg,1) != 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("ERROR: Could not drop constraint ",tables->list[dm_for_cnt
         ].fk_name)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM dm2_user_constraints uc
    WHERE uc.table_name=d_name
     AND uc.constraint_name IN (patstring(tables->list[1].tmp_fk_name), patstring(tables->list[2].
     tmp_fk_name), patstring(tables->list[3].tmp_fk_name))
     AND uc.r_constraint_name IN (tmp_r_fk_name, concat(tmp_r_fk_name,"$C"))
    DETAIL
     dm_failed_cons = concat(dm_failed_cons," ",uc.constraint_name)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FAILED: constraints ",dm_failed_cons,
     " were not dropped properly.")
    GO TO exit_script
   ELSE
    COMMIT
    SET dm_fifty_cnt = 50
   ENDIF
 ENDFOR
#step2
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc
  WHERE uc.table_name=d_name
   AND uc.constraint_name IN (patstring(concat(trim(tables->list[1].fk_name2,3),"*")), patstring(
   concat(trim(tables->list[2].fk_name2,3),"*")), patstring(concat(trim(tables->list[3].fk_name2,3),
    "*")))
   AND uc.r_constraint_name IN (tmp_r_fk_name2, concat(tmp_r_fk_name2,"$C"))
  DETAIL
   IF (currdb="ORACLE")
    IF (substring(1,19,uc.constraint_name)="XFK11CE_EVENT_PRSNL")
     d_xfk11_ind = 1
    ELSEIF (substring(1,19,uc.constraint_name)="XFK12CE_EVENT_PRSNL")
     d_xfk12_ind = 1
    ELSEIF (substring(1,19,uc.constraint_name)="XFK13CE_EVENT_PRSNL")
     d_xfk13_ind = 1
    ENDIF
   ELSEIF (currdb="DB2UDB")
    IF ((uc.constraint_name=tables->list[1].fk_name2))
     d_xfk11_ind = 1
    ELSEIF ((uc.constraint_name=tables->list[2].fk_name2))
     d_xfk12_ind = 1
    ELSEIF ((uc.constraint_name=tables->list[3].fk_name2))
     d_xfk13_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("ERROR: Select from dm2_user_constraints where table_name = '",
   d_name,"' and r_constraint_name = '",tmp_r_fk_name,"' failed.")
  GO TO exit_script
 ENDIF
 IF (d_xfk11_ind=0)
  SET d_str = concat("rdb alter table ",d_name," add constraint ",tables->list[1].fk_name2,
   " foreign key (ACTION_PRSNL_ID) references PRSNL disable go")
  CALL echo(d_str)
  CALL parser(d_str)
  IF (error(rdm_err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Could not add constraint ",tables->list[1].fk_name2)
   GO TO exit_script
  ELSE
   SET d_fk_created = 1
  ENDIF
 ENDIF
 IF (d_xfk12_ind=0)
  SET d_str = concat("rdb alter table ",d_name," add constraint ",tables->list[2].fk_name2,
   " foreign key (PROXY_PRSNL_ID) references PRSNL disable go")
  CALL echo(d_str)
  CALL parser(d_str)
  IF (error(rdm_err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Could not add constraint ",tables->list[2].fk_name2)
   GO TO exit_script
  ELSE
   SET d_fk_created = 1
  ENDIF
 ENDIF
 IF (d_xfk13_ind=0)
  SET d_str = concat("rdb alter table ",d_name," add constraint ",tables->list[3].fk_name2,
   " foreign key (REQUEST_PRSNL_ID) references PRSNL disable go")
  CALL echo(d_str)
  CALL parser(d_str)
  IF (error(rdm_err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Could not add constraint XFK13CE_EVENT_PRSNL",tables->
    list[3].fk_name2)
   GO TO exit_script
  ELSE
   SET d_fk_created = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children dcc
  WHERE dcc.parent_table="PERSON"
   AND dcc.child_table=d_name
   AND dcc.child_column IN ("REQUEST_PRSNL_ID", "ACTION_PRSNL_ID", "PROXY_PRSNL_ID")
  DETAIL
   dm_child_cnt = (dm_child_cnt+ 1)
   FOR (dm_for_cnt = 1 TO 3)
     IF ((tables->list[dm_child_cnt].name=dcc.child_table)
      AND (tables->list[dm_child_cnt].child_exists != 1))
      tables->list[dm_child_cnt].child_exists = 1, tables->list[dm_child_cnt].child_column = dcc
      .child_column
     ENDIF
   ENDFOR
   d_child_exists = 1
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "ERROR: Select from dm_cmb_children where child_table = 'CE_EVNET_PRSNL' failed."
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  DELETE  FROM dm_cmb_children dcc,
    (dummyt d  WITH seq = dm_child_cnt)
   SET dcc.seq = 1
   PLAN (d
    WHERE (tables->list[d.seq].child_exists=1))
    JOIN (dcc
    WHERE dcc.parent_table="PERSON"
     AND (dcc.child_table=tables->list[d.seq].name)
     AND (dcc.child_column=tables->list[d.seq].child_column))
   WITH nocounter
  ;end delete
  IF (error(rdm_err_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Delete from dm_cmb_children where child_table = '",
    d_name,"' failed.")
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children dcc
  WHERE dcc.parent_table="PERSON"
   AND dcc.child_table=d_name
   AND dcc.child_column IN ("REQUEST_PRSNL_ID", "ACTION_PRSNL_ID", "PROXY_PRSNL_ID")
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "FAILED: Rows were not deleted from dm_cmb_children for child_table ",d_name)
  GO TO exit_script
 ENDIF
 IF (d_fk_created=1)
  EXECUTE dm_temp_tables
 ENDIF
 IF (d_fk_exists=1
  AND d_child_exists=1)
  EXECUTE dm_reset_cmb_last_updt cmb_lst_updt
  EXECUTE dm_reset_cmb_last_updt cmb_lst_updt2
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = concat(
  "SUCCESS: foreign key constraint 'XFK*CE_EVENT_PRSNL*' dropped for table ",d_name)
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
