CREATE PROGRAM dm_rdm_adr_updt_cat5:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_adr_updt..."
 DECLARE ms_temp_tbl_name = vc WITH protect, noconstant("")
 DECLARE mn_tbl_exists = i2 WITH protect, noconstant(0)
 DECLARE mn_rollback_seg_failed = i2 WITH protect, noconstant(0)
 DECLARE mf_baseline = f8 WITH protect, constant(2000.0)
 DECLARE mf_min_increment = f8 WITH protect, constant(1000.0)
 DECLARE range_inc = f8 WITH protect, noconstant(250000.0)
 DECLARE ms_info_domain = vc WITH protect, constant("DM_RDM_ADR_UPDT")
 DECLARE ms_info_name = vc WITH protect, constant("MAX VALUE PROCESSED")
 DECLARE max_id = f8
 DECLARE min_id = f8
 DECLARE min_range = f8
 DECLARE max_range = f8
 DECLARE sbr_drop_temp_table(ps_tbl_name=vc) = null
 DECLARE sbr_dm2_rdm_resume_on_chk(pn_null=i2) = null
 DECLARE sbr_dm2_rdm_resume_off_chk(pn_null=i2) = null
 SET ms_temp_tbl_name = "TEMP_ADR"
 FREE SET string_struct
 RECORD string_struct(
   1 ms_err_msg = vc
   1 ms_info_name = vc
   1 ms_min_max_string = vc
 )
 SELECT INTO "nl:"
  FROM duaf df
  PLAN (df
   WHERE df.user_name=curuser)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed: Insufficient privileges, User id must have group 0 privileges"
  GO TO exit_script
 ENDIF
 CALL sbr_drop_temp_table(ms_temp_tbl_name)
 CALL parser(concat("rdb asis(^ create global temporary table ",ms_temp_tbl_name,"( ^)"))
 CALL parser("asis(^ adr_id number, ^)")
 CALL parser("asis(^ adr_person_id number)  ^) ")
 CALL parser("asis(^ on commit preserve rows ^) go")
 EXECUTE oragen3 value(ms_temp_tbl_name)
 IF (error(string_struct->ms_err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error creating temporary table:",string_struct->ms_err_msg)
  GO TO exit_script
 ENDIF
 CALL echo(concat("Temporary table ",ms_temp_tbl_name,"- created"))
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name=ms_info_name
  DETAIL
   min_id = di.info_number
  WITH nocounter
 ;end select
 IF (error(string_struct->ms_err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error selecting from dm_info to find max_id already processed:",
   string_struct->ms_err_msg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "Error reading max_id processed from dm_info row, check status of parent readme"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  max_val = max(a.activity_data_reltn_id)
  FROM activity_data_reltn a
  DETAIL
   max_id = max_val
  WITH nocounter
 ;end select
 SET min_range = min_id
 SET max_range = range_inc
 IF (min_id=max_id)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No new rows to update"
  GO TO exit_script
 ENDIF
 CALL sbr_dm2_rdm_resume_on_chk(0)
 WHILE (min_range <= max_id)
   INSERT  FROM temp_adr
    (adr_id, adr_person_id)(SELECT DISTINCT
     a.activity_data_reltn_id, o.person_id
     FROM activity_data_reltn a,
      orders o
     WHERE a.activity_data_reltn_id BETWEEN min_range AND max_range
      AND a.activity_entity_name="ORDERS"
      AND a.activity_entity_id=o.order_id)
    WITH nocounter
   ;end insert
   IF (error(string_struct->ms_err_msg,0) != 0)
    IF (((findstring("ORA-01555",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01650",
     string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01562",string_struct->ms_err_msg) != 0)
     OR (((findstring("ORA-30036",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-30027",
     string_struct->ms_err_msg) != 0) OR (findstring("ORA-01581",string_struct->ms_err_msg) != 0))
    )) )) )) )) )
     ROLLBACK
     SET mn_rollback_seg_failed = 1
     CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
     SET readme_data->message = string_struct->ms_err_msg
    ELSE
     CALL echo("Processing FAILED...")
     CALL echo(concat("Failure during insert:",string_struct->ms_err_msg))
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during insert on temp table:",string_struct->
      ms_err_msg)
     CALL sbr_dm2_rdm_resume_off_chk(0)
     ROLLBACK
     GO TO exit_script
    ENDIF
   ELSE
    COMMIT
   ENDIF
   IF (mn_rollback_seg_failed != 1)
    INSERT  FROM temp_adr
     (adr_id, adr_person_id)(SELECT DISTINCT
      a.activity_data_reltn_id, al.person_id
      FROM activity_data_reltn a,
       allergy al
      WHERE a.activity_data_reltn_id BETWEEN min_range AND max_range
       AND a.activity_entity_name="ALLERGY"
       AND a.activity_entity_id=al.allergy_id)
     WITH nocounter
    ;end insert
    IF (error(string_struct->ms_err_msg,0) != 0)
     IF (((findstring("ORA-01555",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01650",
      string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01562",string_struct->ms_err_msg) != 0)
      OR (((findstring("ORA-30036",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-30027",
      string_struct->ms_err_msg) != 0) OR (findstring("ORA-01581",string_struct->ms_err_msg) != 0))
     )) )) )) )) )
      ROLLBACK
      SET mn_rollback_seg_failed = 1
      CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
      SET readme_data->message = string_struct->ms_err_msg
     ELSE
      CALL echo("Processing FAILED...")
      CALL echo(concat("Failure during insert:",string_struct->ms_err_msg))
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure during insert on temp table:",string_struct->
       ms_err_msg)
      CALL sbr_dm2_rdm_resume_off_chk(0)
      ROLLBACK
      GO TO exit_script
     ENDIF
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (mn_rollback_seg_failed != 1)
    CALL echo("Processing...")
    CALL echo("Updating the activity_data_reltn table ")
    UPDATE  FROM activity_data_reltn adr
     SET adr.person_id =
      (SELECT
       t.adr_person_id
       FROM temp_adr t
       WHERE adr.activity_data_reltn_id=t.adr_id), adr.updt_task = reqinfo->updt_task, adr.updt_id =
      reqinfo->updt_id,
      adr.updt_dt_tm = sysdate, adr.updt_applctx = reqinfo->updt_applctx, adr.updt_cnt = (adr
      .updt_cnt+ 1)
     WHERE adr.activity_data_reltn_id IN (
     (SELECT
      t2.adr_id
      FROM temp_adr t2
      WHERE t2.adr_id > 0))
     WITH nocounter
    ;end update
    IF (error(string_struct->ms_err_msg,0) != 0)
     IF (((findstring("ORA-01555",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01650",
      string_struct->ms_err_msg) != 0) OR (((findstring("ORA-01562",string_struct->ms_err_msg) != 0)
      OR (((findstring("ORA-30036",string_struct->ms_err_msg) != 0) OR (((findstring("ORA-30027",
      string_struct->ms_err_msg) != 0) OR (findstring("ORA-01581",string_struct->ms_err_msg) != 0))
     )) )) )) )) )
      ROLLBACK
      SET mn_rollback_seg_failed = 1
      CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
      SET readme_data->message = string_struct->ms_err_msg
     ELSE
      CALL echo("Processing FAILED...")
      CALL echo(concat("Failure during insert:",string_struct->ms_err_msg))
      SET readme_data->status = "F"
      SET readme_data->message = concat("Error updating ACTIVITY_DATA_RELTN table:",string_struct->
       ms_err_msg)
      CALL sbr_dm2_rdm_resume_off_chk(0)
      ROLLBACK
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (mn_rollback_seg_failed=1)
    IF (range_inc > mf_baseline)
     SET range_inc = ceil((range_inc/ 2))
    ELSEIF (range_inc > mf_min_increment)
     SET range_inc = mf_min_increment
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message = concat("Encountered rollback segment failure; Could not recover...",
      readme_data->message)
     CALL sbr_dm2_rdm_resume_off_chk(0)
     ROLLBACK
     GO TO exit_script
    ENDIF
    SET max_range = ((min_range+ range_inc) - 1)
    SET mn_rollback_seg_failed = 0
   ELSE
    COMMIT
    SET min_range = (max_range+ 1)
    SET max_range = (max_range+ range_inc)
   ENDIF
   CALL parser(concat("rdb asis(^ truncate table ",ms_temp_tbl_name," ^) go"))
 ENDWHILE
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_number = max_id
  WHERE di.info_domain=ms_info_domain
   AND di.info_name=ms_info_name
  WITH nocounter
 ;end update
 IF (error(string_struct->ms_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update max_id value on DM_INFO table:",string_struct->
   ms_err_msg)
  GO TO exit_script
 ENDIF
 COMMIT
 CALL sbr_dm2_rdm_resume_off_chk(0)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 SUBROUTINE sbr_drop_temp_table(ps_tbl_name)
   SET mn_tbl_exists = 0
   SELECT INTO "nl:"
    FROM dba_tables d
    WHERE d.table_name=ps_tbl_name
    DETAIL
     mn_tbl_exists = 1
    WITH nocounter
   ;end select
   IF (mn_tbl_exists=1)
    DECLARE do_ora_version = i2
    SET do_ora_version = 0
    SELECT INTO "nl:"
     FROM product_component_version p
     WHERE cnvtupper(p.product)="ORACLE*"
     DETAIL
      do_ora_version = cnvtint(substring(1,findstring(".",p.version,1,0),p.version)),
      CALL echo(build("ORACLE_VERSION:",do_ora_version))
     WITH nocounter
    ;end select
    IF (do_ora_version >= 10)
     CALL parser(concat("rdb asis(^ truncate table ",ps_tbl_name," ^) go"))
     CALL parser(concat("rdb asis(^ drop table ",ps_tbl_name," purge ^) go"))
    ELSE
     CALL parser(concat("rdb asis(^ truncate table ",ps_tbl_name," ^) go"))
     CALL parser(concat("rdb asis(^ drop table ",ps_tbl_name," ^) go"))
    ENDIF
    IF (error(string_struct->ms_err_msg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error dropping (rdbms level) temporary table :",string_struct
      ->ms_err_msg)
     GO TO exit_script
    ENDIF
    CALL parser(concat("drop table ",ps_tbl_name," go"))
    IF (error(string_struct->ms_err_msg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error dropping (ccl level) temporary table :",string_struct->
      ms_err_msg)
     GO TO exit_script
    ENDIF
    CALL echo(concat("Temporary table ",ps_tbl_name,"- dropped "))
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_dm2_rdm_resume_on_chk(pn_null)
   IF (checkprg("DM2_RDM_RESUME_ON") > 0)
    EXECUTE dm2_rdm_resume_on
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_dm2_rdm_resume_off_chk(pn_null)
   IF (checkprg("DM2_RDM_RESUME_OFF") > 0)
    EXECUTE dm2_rdm_resume_off
   ENDIF
 END ;Subroutine
#exit_script
 CALL sbr_drop_temp_table(ms_temp_tbl_name)
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
