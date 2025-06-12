CREATE PROGRAM dm_cnvt_infuseover_float:dba
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
 SET readme_data->message = " "
 IF (currdb != "ORACLE")
  SET readme_data->status = "S"
  SET readme_data->message = "This type of change not supported on db2."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_tables t,
   dm_afd_columns c
  PLAN (t
   WHERE t.owner=currdbuser
    AND t.table_name="MED_OE_DEFAULTS")
   JOIN (c
   WHERE t.alpha_feature_nbr=c.alpha_feature_nbr
    AND t.owner=c.owner
    AND t.table_name=c.table_name
    AND c.column_name="INFUSE_OVER")
  ORDER BY t.schema_date
  FOOT REPORT
   IF (c.data_type != "FLOAT")
    readme_data->status = "S", readme_data->message =
    "Column INFUSE_OVER on table MED_OE_DEFAULTS does not need to be converted to float."
   ENDIF
  WITH nocounter
 ;end select
 IF ((readme_data->status="S")
  AND (readme_data->message > " "))
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Column INFUSE_OVER on table MED_OE_DEFAULTS is not on table dm_afd_column."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="MED_OE_DEFAULTS"
   AND u.column_name="INFUSE_OVER"
  DETAIL
   IF (u.data_type="FLOAT")
    readme_data->status = "S", readme_data->message =
    "Column INFUSE_OVER on table MED_OE_DEFAULTS has already been converted to float."
   ENDIF
  WITH nocounter
 ;end select
 IF ((readme_data->status="S")
  AND (readme_data->message > " "))
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Column INFUSE_OVER on table MED_OE_DEFAULTS does not exist in the database."
  GO TO exit_script
 ENDIF
 EXECUTE dm_schema_cnvt_num_to_float "MED_OE_DEFAULTS", "INFUSE_OVER"
 SELECT INTO "nl:"
  u.column_name
  FROM user_tab_columns u
  WHERE u.table_name="MED_OE_DEFAULTS"
   AND u.column_name="INFUSE_OVER"
   AND u.data_type="FLOAT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "Failed to convert column INFUSE_OVER on table MED_OE_DEFAULTS to FLOAT."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Column INFUSE_OVER on table MED_OE_DEFAULTS was converted to FLOAT successfully."
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
END GO
