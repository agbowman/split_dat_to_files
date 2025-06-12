CREATE PROGRAM dm_drop_zrow_pl_defaults:dba
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
 DECLARE pl_client_def_ind = i2
 DECLARE pl_def_ind = i2
 DECLARE pl_def_trig_ind = i2
 DECLARE pl_client_def_trig_ind = i2
 DECLARE pl_def_trig_ind2 = i2
 DECLARE pl_client_def_trig_ind2 = i2
 DECLARE dm_err_txt = vc
 DECLARE tmp_pcd_suffix = c4
 DECLARE tmp_pd_suffix = c4
 DECLARE tmp_pcd_suffix_name = vc
 DECLARE tmp_pd_suffix_name = vc
 DECLARE tmp_trig_name = vc
 DECLARE tmp_trig_name2 = vc
 DECLARE tmp_trig_name3 = vc
 DECLARE tmp_trig_name4 = vc
 SET pl_client_def_ind = 0
 SET pl_def_ind = 0
 SET pl_client_def_trig_ind = 0
 SET pl_def_trig_ind = 0
 SET pl_client_def_trig_ind2 = 0
 SET pl_def_trig_ind2 = 0
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name IN ("PL_CLIENT_DEFAULTS", "PL_DEFAULTS")
  DETAIL
   IF (dtd.table_name="PL_CLIENT_DEFAULTS")
    pl_client_def_ind = 1, tmp_pcd_suffix = trim(dtd.table_suffix,3), tmp_pcd_suffix_name = trim(dtd
     .suffixed_table_name,3)
   ELSEIF (dtd.table_name="PL_DEFAULTS")
    pl_def_ind = 1, tmp_pd_suffix = trim(dtd.table_suffix,3), tmp_pd_suffix_name = trim(dtd
     .suffixed_table_name,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(dm_err_txt,1) != 0)
  SET readme_data->message =
  "ERROR: could not select from dm_tables_doc where table_name in ('PL_CLIENT_DEFAULTS','PL_DEFAULTS')"
  GO TO end_program
 ENDIF
 IF (pl_def_ind=1
  AND pl_client_def_ind=1)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="INHOUSE DOMAIN"
   WITH nocounter
  ;end select
  IF (error(dm_err_txt,1) != 0)
   SET readme_data->message = "ERROR: could not perform inhouse check from dm_info table"
   GO TO end_program
  ENDIF
  IF (curqual=0)
   UPDATE  FROM dm_tables_doc dtd
    SET dtd.default_row_ind = 0
    WHERE dtd.table_name IN ("PL_CLIENT_DEFAULTS", "PL_DEFAULTS")
    WITH nocounter
   ;end update
  ENDIF
  IF (error(dm_err_txt,1) != 0)
   ROLLBACK
   SET readme_data->message =
   "ERROR: updating default_row_ind on dm_tables_doc for PL_CLIENT_DEFAULTS and PL_DEFAULTS"
   GO TO end_program
  ELSE
   COMMIT
  ENDIF
 ELSE
  IF (pl_client_def_ind != 1)
   ROLLBACK
   SET readme_data->message = "FAIL: PL_CLIENT_DEFAULTS is not on DM_TABLES_DOC"
   GO TO end_program
  ELSE
   ROLLBACK
   SET readme_data->message = "FAIL: PL_DEFAULTS is not on DM_TABLES_DOC"
   GO TO end_program
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm2_user_triggers dut
   WHERE dut.table_name IN ("PL_CLIENT_DEFAULTS", "PL_DEFAULTS")
   DETAIL
    IF (dut.trigger_name=concat("TRG_",tmp_pd_suffix,"_DR_UPDT_DEL*"))
     pl_def_trig_ind = 1, tmp_trig_name = dut.trigger_name
    ELSEIF (dut.trigger_name=concat("TRG_",tmp_pcd_suffix,"_DR_UPDT_DEL*"))
     pl_client_def_trig_ind = 1, tmp_trig_name2 = dut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (error(dm_err_txt,1) != 0)
   SET readme_data->message = concat("ERROR retrieving ",tmp_trig_name," ",tmp_trig_name2,
    " from dm2_user_triggers")
   GO TO end_program
  ENDIF
  IF (pl_def_trig_ind=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (pl_client_def_trig_ind=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name2," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name2,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM dm2_user_triggers dut
   WHERE dut.table_name IN ("PL_CLIENT_DEFAULTS", "PL_DEFAULTS")
    AND dut.trigger_name IN (value(tmp_trig_name), value(tmp_trig_name2))
   WITH nocounter
  ;end select
  IF (error(dm_err_txt,1) != 0)
   SET readme_data->message = concat("ERROR retrieving ",tmp_trig_name," ",tmp_trig_name2,
    " from dm2_user_triggers")
   GO TO end_program
  ENDIF
  IF (curqual != 0)
   SET readme_data->message = concat("FAIL: triggers ",tmp_trig_name," ",tmp_trig_name2,
    " were not dropped properly")
   GO TO end_program
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SELECT INTO "nl:"
   FROM dm2_user_triggers dut
   WHERE dut.table_name IN (value(tmp_pcd_suffix_name), value(tmp_pd_suffix_name))
   DETAIL
    IF (dut.trigger_name=concat("TRG_",tmp_pd_suffix,"_DRDEL*"))
     pl_def_trig_ind = 1, tmp_trig_name = dut.trigger_name
    ELSEIF (dut.trigger_name=concat("TRG_",tmp_pd_suffix,"_DRUPD*"))
     pl_def_trig_ind2 = 1, tmp_trig_name2 = dut.trigger_name
    ELSEIF (dut.trigger_name=concat("TRG_",tmp_pcd_suffix,"_DRDEL*"))
     pl_client_def_trig_ind = 1, tmp_trig_name3 = dut.trigger_name
    ELSEIF (dut.trigger_name=concat("TRG_",tmp_pcd_suffix,"_DRUPD*"))
     pl_client_def_trig_ind2 = 1, tmp_trig_name4 = dut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (error(dm_err_txt,1) != 0)
   SET readme_data->message = concat("ERROR retrieving ",tmp_trig_name," ",tmp_trig_name2," ",
    tmp_trig_name3," ",tmp_trig_name4," from dm2_user_triggers")
   GO TO end_program
  ENDIF
  IF (pl_def_trig_ind=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (pl_client_def_trig_ind=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name2," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name2,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (pl_def_trig_ind2=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name3," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name3,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (pl_client_def_trig_ind2=1)
   SET dm_str = concat("rdb drop trigger ",tmp_trig_name4," go")
   CALL echo(dm_str)
   CALL parser(dm_str)
   IF (error(dm_err_txt,1) != 0)
    ROLLBACK
    SET readme_data->message = concat("FAIL: did not drop zero row ",tmp_trig_name4,
     " trigger properly")
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM dm2_user_triggers dut
   WHERE dut.table_name IN (value(tmp_pcd_suffix_name), value(tmp_pd_suffix_name))
    AND dut.trigger_name IN (value(tmp_trig_name), value(tmp_trig_name2), value(tmp_trig_name3),
   value(tmp_trig_name4))
   WITH nocounter
  ;end select
  IF (error(dm_err_txt,1) != 0)
   SET readme_data->message = concat("ERROR retrieving ",tmp_trig_name," ",tmp_trig_name2," ",
    tmp_trig_name3," ",tmp_trig_name4," from dm2_user_triggers")
   GO TO end_program
  ENDIF
  IF (curqual != 0)
   SET readme_data->message = concat("FAIL: triggers ",tmp_trig_name,tmp_trig_name2,tmp_trig_name3,
    tmp_trig_name4,
    " were not dropped properly")
   GO TO end_program
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "SUCCESS: it is now possible to drop the zero row off of PL_CLIENT_DEFAULTS and PL_DEFAULTS"
#end_program
 EXECUTE dm_readme_status
END GO
