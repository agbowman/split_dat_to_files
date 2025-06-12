CREATE PROGRAM dm_fix_fk_rule_audit:dba
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
 DECLARE rdm_err_msg = vc
 DECLARE d_str = vc
 DECLARE d_name = vc
 DECLARE d_fk_name = vc
 DECLARE d_fk_created = i2
 DECLARE d_fk_exists = i2
 DECLARE d_child_exists = i2
 DECLARE d_child_column = vc
 DECLARE dm_fifty_cnt = i4
 DECLARE tmp_fk_name = vc
 DECLARE tmp_r_fk_name = vc
 DECLARE tmp_r_fk_name2 = vc
 DECLARE tmp_r_name = vc
 DECLARE cmb_lst_updt = c13
 DECLARE cmb_lst_updt2 = c14
 SET cmb_lst_updt = "CMB_LAST_UPDT"
 SET cmb_lst_updt2 = "CMB_LAST_UPDT2"
 SET d_name = " "
 SET d_fk_name = " "
 SET rdm_err_msg = fillstring(132," ")
 SET d_fk_exists = 0
 SET d_child_exists = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_fix_fk_rule_audit script."
 SELECT INTO "nl:"
  FROM dm2_user_tables ut,
   dm_tables_doc dtd
  PLAN (dtd
   WHERE dtd.table_name IN ("RULE_AUDIT", "PERSON", "PRSNL"))
   JOIN (ut
   WHERE ut.table_name=dtd.table_name)
  DETAIL
   IF (dtd.table_name="RULE_AUDIT")
    IF (currdb="ORACLE")
     d_name = dtd.full_table_name, tmp_fk_name = "XFK1RULE_AUDIT*", d_fk_name = "XFK1RULE_AUDIT"
    ELSEIF (currdb="DB2UDB")
     d_name = dtd.suffixed_table_name, tmp_fk_name = build("XFK1RULE_AUD",dtd.table_suffix,"*"),
     d_fk_name = build("XFK1RULE_AUD",dtd.table_suffix)
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
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("ERROR: Select from dm2_user_tables where table_name = '",d_name,
   "' failed.")
  GO TO exit_script
 ENDIF
 IF (d_name=" ")
  SET readme_data->status = "S"
  SET readme_data->message = concat("SUCCESS: table ",d_name,
   " does not exist, no need to run program")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc
  WHERE uc.table_name=d_name
   AND uc.constraint_name=patstring(tmp_fk_name)
   AND uc.r_constraint_name IN (tmp_r_fk_name, concat(tmp_r_fk_name,"$C"))
  DETAIL
   d_fk_name = trim(uc.constraint_name,3), d_fk_exists = 1
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "ERROR: Select from dm2_user_constraints where constraint_name = ",d_fk_name," and ",
   "table_name = '",d_name,
   "' and r_constraint_name = '",tmp_r_fk_name,"' OR '",tmp_r_fk_name,"$C' failed.")
  GO TO exit_script
 ENDIF
 FOR (dm_fifty_cnt = 1 TO 50)
   IF (d_fk_exists=1)
    IF (currdb="ORACLE")
     SET d_str = concat("rdb alter table ",d_name," disable constraint ",d_fk_name," go")
    ELSEIF (currdb="DB2UDB")
     SET d_str = concat("rdb alter table ",d_name," alter foreign key ",d_fk_name," not enforced go")
    ENDIF
    CALL echo(d_str)
    CALL parser(d_str)
    IF (error(rdm_err_msg,1) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("ERROR: Could not disable constraint ",d_fk_name)
    ELSE
     SET d_str = concat("rdb alter TABLE ",d_name," drop CONSTRAINT ",d_fk_name," go")
     CALL echo(d_str)
     CALL parser(d_str)
     IF (error(rdm_err_msg,1) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("ERROR: Could not drop constraint ",d_fk_name)
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_user_constraints uc
    WHERE uc.table_name=d_name
     AND uc.constraint_name=patstring(concat(d_fk_name,"*"))
     AND uc.r_constraint_name IN (tmp_r_fk_name, concat(tmp_r_fk_name,"$C"))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FAILED: constraint '",d_fk_name,"*' was not dropped properly."
     )
    GO TO exit_script
   ELSE
    COMMIT
    SET dm_fifty_cnt = 50
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM dm2_user_constraints uc
  WHERE uc.table_name=d_name
   AND uc.constraint_name=patstring(concat(d_fk_name,"*"))
   AND uc.r_constraint_name IN (tmp_r_fk_name2, concat(tmp_r_fk_name2,"$C"))
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "ERROR: Select from dm2_user_constraints where constraint_name = ",d_fk_name," and ",
   "table_name = '",d_name,
   "' and r_constraint_name = '",tmp_r_fk_name2,"' OR '",tmp_r_fk_name2,"$C' failed.")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET d_str = concat("rdb alter table ",d_name," add constraint ",d_fk_name,
   " foreign key (RUN_PRSNL_ID) references ",
   tmp_r_name," disable go")
  CALL echo(d_str)
  CALL parser(d_str)
  IF (error(rdm_err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Could not add constraint ",d_fk_name)
   GO TO exit_script
  ELSE
   SET d_fk_created = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children dcc
  WHERE dcc.child_table=d_name
   AND dcc.child_column="RUN_PRSNL_ID"
  DETAIL
   d_child_exists = 1, d_child_column = dcc.child_column
  WITH nocounter
 ;end select
 IF (error(rdm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("ERROR: Select from dm_cmb_children where child_table = '",d_name,
   "' ","and child_column = '",d_child_column,
   "' failed.")
  GO TO exit_script
 ENDIF
 IF (d_child_exists=1)
  DELETE  FROM dm_cmb_children dcc
   WHERE dcc.child_table=d_name
    AND dcc.child_column=d_child_column
   WITH nocounter
  ;end delete
  IF (error(rdm_err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ERROR: Delete from dm_cmb_children where child_table = ",d_name,
    " and child_column = ",d_child_column," failed.")
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children dcc
  WHERE dcc.child_table=d_name
   AND dcc.child_column=d_child_column
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "FAILED: Rows were not properly deleted from dm_cmb_children where child_table = ",d_name,
   " and child_column = ",d_child_column)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM dm_tables_doc dtd
   WHERE dtd.table_name=d_name
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_tables_doc dtd
    SET dtd.person_cmb_trigger_type = null
    WHERE dtd.table_name=d_name
    WITH nocounter
   ;end update
   IF (error(rdm_err_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("ERROR: Update into dm_tables_doc where table_name = '",d_name,
     "' failed.")
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
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
 SET readme_data->message = concat("SUCCESS: foreign key constraint ",d_fk_name," dropped for table ",
  d_name)
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
