CREATE PROGRAM dm2_obs_pg_triggers:dba
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
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 IF (currdb="ORACLE")
  CALL echo("Running Obsolete Process to drop triggers...")
  SELECT INTO "nl:"
   di.info_char
   FROM dm_info di
   WHERE di.info_domain="UPDATE EPR'S ENCNTR_TYPE_CD"
    AND di.info_name="MAX ENCNTR_PRSNL_RELTN_ID EVALUATED BY*"
    AND di.info_char="SUCCESS"
   WITH nocounter
  ;end select
  IF (curqual != 3)
   SET readme_data->status = "F"
   SET readme_data->message =
   "Failed to drop triggers; All 3 dm2_pg_parent_readme children have not finished successfully!"
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "TEMP_README_TRIG1", "TRIGGER", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "TEMP_README_TRIG2", "TRIGGER", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message =
  "Triggers TEMP_README_TRIG1 and TEMP_README_TRIG2 were dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for Non-Oracle database"
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo(readme_data->message)
 ENDIF
END GO
