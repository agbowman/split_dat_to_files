CREATE PROGRAM dm_obs_pm_encntr_tbls:dba
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
 SET readme_data->message = "Failed to execute obsolete process"
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  CALL echo("Running Obsolete Process on constraints and indexes for Person Management...")
  EXECUTE dm_drop_obsolete_objects "XARCENCNTR_AUGM_CARE_PERIOD", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XFK2ENCNTR_AUGM_CARE_PERIOD", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XARCENCNTR_ACP_HIST", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XFK4ENCNTR_ACP_HIST", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XFK2ENCNTR_ACP_HIST", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE1ENCNTR_AUGM_CARE_PERIOD", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE2ENCNTR_AUGM_CARE_PERIOD", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE2ENCNTR_ACP_HIST", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE3ENCNTR_ACP_HIST", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XARC1ENCNTR_AUGM_CARE_PERIOD", "CONSTRAINT", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  DELETE  FROM dm_cmb_children d
   WHERE d.parent_table="ENCOUNTER"
    AND d.child_table="ENCNTR_ACP_HIST"
    AND d.child_column="ENCNTR_ID"
   WITH nocounter
  ;end delete
  DELETE  FROM dm_cmb_children d
   WHERE d.parent_table="PERSON"
    AND d.child_table="ENCNTR_ACP_HIST"
    AND d.child_column="PERSON_ID"
   WITH nocounter
  ;end delete
  DELETE  FROM dm_cmb_children d
   WHERE d.parent_table="PERSON"
    AND d.child_table="ENCNTR_AUGM_CARE_PERIOD"
    AND d.child_column="PERSON_ID"
   WITH nocounter
  ;end delete
  SELECT INTO "nl:"
   d.child_table
   FROM dm_cmb_children d
   WHERE d.parent_table="ENCOUNTER"
    AND d.child_table="ENCNTR_ACP_HIST"
    AND d.child_column="ENCNTR_ID"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   ROLLBACK
   SET readme_data->message = "FAIL: encounter.encntr_acp_hist row not deleted from dm_cmb_children"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   d.child_table
   FROM dm_cmb_children d
   WHERE d.parent_table="PERSON"
    AND d.child_table="ENCNTR_ACP_HIST"
    AND d.child_column="PERSON_ID"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   ROLLBACK
   SET readme_data->message = "FAIL: person.encntr_acp_hist row not deleted from dm_cmb_children"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   d.child_table
   FROM dm_cmb_children d
   WHERE d.parent_table="PERSON"
    AND d.child_table="ENCNTR_AUGM_CARE_PERIOD"
    AND d.child_column="PERSON_ID"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   ROLLBACK
   SET readme_data->message = "FAIL: encntr_augm_care_period row not deleted from dm_cmb_children"
   GO TO exit_script
  ENDIF
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Constraints and Indexes were dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
