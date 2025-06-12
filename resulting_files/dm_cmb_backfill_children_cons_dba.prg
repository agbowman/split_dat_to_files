CREATE PROGRAM dm_cmb_backfill_children_cons:dba
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
 SET readme_data->message = "Readme Failed: Starting dm_cmb_backfill_children_cons.prg script"
 DECLARE dcbcc_errmsg = c132
 FREE RECORD usr_constraints
 RECORD usr_constraints(
   1 details[*]
     2 constraint_name = vc
     2 table_name = vc
     2 column_name = vc
 )
 FREE RECORD missed_constraints
 RECORD missed_constraints(
   1 details[*]
     2 constraint_name = vc
     2 table_name = vc
     2 column_name = vc
     2 schema_instance = f8
 )
 SELECT INTO "nl:"
  ucc.constraint_name, ucc.table_name, ucc.column_name
  FROM user_cons_columns ucc
  WHERE ucc.constraint_name IN (
  (SELECT
   uc2.constraint_name
   FROM user_constraints uc2
   WHERE uc2.owner="V500"
    AND uc2.constraint_type="R"
    AND uc2.r_constraint_name IN (
   (SELECT
    uc.constraint_name
    FROM user_constraints uc
    WHERE uc.owner="V500"
     AND uc.constraint_type="P"
     AND uc.table_name IN (
    (SELECT
     table_name
     FROM dm_tables_doc
     WHERE full_table_name IN ("ENCOUNTER", "PERSON")))))))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,100)=1)
    stat = alterlist(usr_constraints->details,(cnt+ 99))
   ENDIF
   usr_constraints->details[cnt].constraint_name = ucc.constraint_name, usr_constraints->details[cnt]
   .table_name = ucc.table_name, usr_constraints->details[cnt].column_name = ucc.column_name
  FOOT REPORT
   stat = alterlist(usr_constraints->details,cnt)
  WITH nocounter
 ;end select
 IF (error(dcbcc_errmsg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED: error during selection of constraint information"
  GO TO exit_program
 ENDIF
 IF (size(usr_constraints->details,5)=0)
  GO TO readme_success
 ENDIF
 UPDATE  FROM dm_cmb_children dcc,
   (dummyt d  WITH seq = size(usr_constraints->details,5))
  SET dcc.child_cons_name = usr_constraints->details[d.seq].constraint_name, dcc.updt_task = reqinfo
   ->updt_task, dcc.updt_id = reqinfo->updt_id,
   dcc.updt_cnt = (dcc.updt_cnt+ 1), dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_dt_tm =
   cnvtdatetime(sysdate)
  PLAN (d)
   JOIN (dcc
   WHERE (dcc.child_table=usr_constraints->details[d.seq].table_name)
    AND (dcc.child_column=usr_constraints->details[d.seq].column_name))
  WITH nocounter
 ;end update
 IF (error(dcbcc_errmsg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED: error during update into dm_cmb_children"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  dcc.child_table, dcc.child_column
  FROM dm_cmb_children dcc
  WHERE dcc.child_cons_name=" "
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,100)=1)
    stat = alterlist(missed_constraints->details,(cnt+ 99))
   ENDIF
   missed_constraints->details[cnt].table_name = dcc.child_table, missed_constraints->details[cnt].
   column_name = dcc.child_column
  FOOT REPORT
   stat = alterlist(missed_constraints->details,cnt)
  WITH nocounter
 ;end select
 IF (error(dcbcc_errmsg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "FAILED: error during select to determine if any constraints wer enot filled out"
  GO TO exit_program
 ENDIF
 IF (size(missed_constraints->details,5)=0)
  GO TO readme_success
 ENDIF
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di,
   (dummyt d  WITH seq = size(missed_constraints->details,5))
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="DM2_SCHEMA_INSTANCE"
    AND (di.info_name=missed_constraints->details[d.seq].table_name))
  DETAIL
   missed_constraints->details[d.seq].schema_instance = di.info_number
  WITH nocounter
 ;end select
 IF (error(dcbcc_errmsg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED: error during selection of schema instance number"
  GO TO exit_program
 ENDIF
 FOR (m_c_cnt = 1 TO size(missed_constraints->details,5))
  IF ((missed_constraints->details[m_c_cnt].schema_instance > 0))
   SELECT INTO "nl:"
    dacc.constraint_name
    FROM dm_afd_cons_columns dacc
    WHERE (dacc.table_name=missed_constraints->details[m_c_cnt].table_name)
     AND (dacc.column_name=missed_constraints->details[m_c_cnt].column_name)
     AND dacc.constraint_name IN (
    (SELECT
     dac.constraint_name
     FROM dm_afd_constraints dac
     WHERE dac.constraint_type="R"
      AND dac.r_constraint_name IN ("XPKENCOUNTER", "XPKPERSON", "XPKENCOUNTER0077", "XPKPERSON4859")
    ))
     AND (dacc.alpha_feature_nbr=
    (SELECT
     max(alpha_feature_nbr)
     FROM dm_afd_tables
     WHERE (schema_instance=missed_constraints->details[m_c_cnt].schema_instance)
      AND (table_name=missed_constraints->details[m_c_cnt].table_name)))
    DETAIL
     missed_constraints->details[m_c_cnt].constraint_name = dacc.constraint_name
    WITH nocounter
   ;end select
   IF (error(dcbcc_errmsg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = "FAILED: error during selection of constraint information"
    GO TO exit_program
   ENDIF
  ELSE
   SELECT INTO "nl:"
    dacc.constraint_name
    FROM dm_afd_cons_columns dacc
    WHERE (dacc.table_name=missed_constraints->details[m_c_cnt].table_name)
     AND (dacc.column_name=missed_constraints->details[m_c_cnt].column_name)
     AND dacc.constraint_name IN (
    (SELECT
     dac.constraint_name
     FROM dm_afd_constraints dac
     WHERE dac.constraint_type="R"
      AND dac.r_constraint_name IN ("XPKENCOUNTER", "XPKPERSON", "XPKENCOUNTER0077", "XPKPERSON4859")
    ))
     AND (dacc.alpha_feature_nbr=
    (SELECT
     max(dat.alpha_feature_nbr)
     FROM dm_afd_tables dat
     WHERE (dat.schema_date=
     (SELECT
      max(dat2.schema_date)
      FROM dm_afd_tables dat2
      WHERE (dat2.table_name=missed_constraints->details[m_c_cnt].table_name)
       AND dat2.alpha_feature_nbr IN (
      (SELECT
       dafe.alpha_feature_nbr
       FROM dm_alpha_features_env dafe
       WHERE (dafe.environment_id=
       (SELECT
        di.info_number
        FROM dm_info di
        WHERE di.info_domain="DATA MANAGEMENT"
         AND di.info_name="DM_ENV_ID"))))))))
    DETAIL
     missed_constraints->details[m_c_cnt].constraint_name = dacc.constraint_name
    WITH nocounter
   ;end select
   IF (error(dcbcc_errmsg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = "FAILED: error during selection of constraint information"
    GO TO exit_program
   ENDIF
  ENDIF
  IF ((missed_constraints->details[m_c_cnt].constraint_name=""))
   SELECT INTO "nl:"
    dcc.constraint_name
    FROM dm_cons_columns dcc
    WHERE (dcc.table_name=missed_constraints->details[m_c_cnt].table_name)
     AND (dcc.column_name=missed_constraints->details[m_c_cnt].column_name)
     AND dcc.constraint_name IN (
    (SELECT
     dc.constraint_name
     FROM dm_constraints dc
     WHERE dc.constraint_type="R"
      AND dc.r_constraint_name IN ("XPKENCOUNTER", "XPKPERSON", "XPKENCOUNTER0077", "XPKPERSON4859"))
    )
     AND (dcc.schema_date=
    (SELECT
     dsv.schema_date
     FROM dm_schema_version dsv,
      dm_environment de
     WHERE (de.environment_id=
     (SELECT
      di.info_number
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="DM_ENV_ID"))
      AND de.schema_version=dsv.schema_version))
    DETAIL
     missed_constraints->details[m_c_cnt].constraint_name = dcc.constraint_name
    WITH nocounter
   ;end select
   IF (error(dcbcc_errmsg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message =
    "FAILED: error during last attempt at selection of constraint information"
    GO TO exit_program
   ENDIF
  ENDIF
 ENDFOR
 IF (size(missed_constraints->details,5) > 0)
  UPDATE  FROM dm_cmb_children dcc,
    (dummyt d  WITH seq = size(missed_constraints->details,5))
   SET dcc.child_cons_name = missed_constraints->details[d.seq].constraint_name, dcc.updt_task =
    reqinfo->updt_task, dcc.updt_id = reqinfo->updt_id,
    dcc.updt_cnt = (dcc.updt_cnt+ 1), dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_dt_tm =
    cnvtdatetime(sysdate)
   PLAN (d
    WHERE  NOT ((missed_constraints->details[d.seq].constraint_name="")))
    JOIN (dcc
    WHERE (dcc.child_table=missed_constraints->details[d.seq].table_name)
     AND (dcc.child_column=missed_constraints->details[d.seq].column_name))
   WITH nocounter
  ;end update
  IF (error(dcbcc_errmsg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = "FAILED: error during final update into dm_cmb_children"
   GO TO exit_program
  ENDIF
 ENDIF
#readme_success
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: The DM_CMB_CHILDREN rows were updated successfully"
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
