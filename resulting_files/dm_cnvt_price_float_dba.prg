CREATE PROGRAM dm_cnvt_price_float:dba
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
    AND t.table_name="LINE_ITEM_QUANTITY")
   JOIN (c
   WHERE t.alpha_feature_nbr=c.alpha_feature_nbr
    AND t.owner=c.owner
    AND t.table_name=c.table_name
    AND c.column_name="EXTENDED_PRICE")
  ORDER BY t.schema_date
  FOOT REPORT
   IF (c.data_type != "FLOAT")
    readme_data->status = "S", readme_data->message =
    "Column EXTENDED_PRICE on table LINE_ITEM_QUANTITY does not need to be converted to float."
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
  "Column EXTENDED_PRICE on table LINE_ITEM_QUANTITY is not on table dm_afd_column."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="LINE_ITEM_QUANTITY"
   AND u.column_name="EXTENDED_PRICE"
  DETAIL
   IF (u.data_type="FLOAT")
    readme_data->status = "S", readme_data->message =
    "Column EXTENDED_PRICE on table LINE_ITEM_QUANTITY has already been converted to float."
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
  "Column EXTENDED_PRICE on table LINE_ITEM_QUANTITY does not exist in the database."
  GO TO exit_script
 ENDIF
 EXECUTE dm_schema_cnvt_num_to_float "LINE_ITEM_QUANTITY", "EXTENDED_PRICE"
 SELECT INTO "nl:"
  u.column_name
  FROM user_tab_columns u
  WHERE u.table_name="LINE_ITEM_QUANTITY"
   AND u.column_name="EXTENDED_PRICE"
   AND u.data_type="FLOAT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "Failed to convert column EXTENDED_PRICE on table LINE_ITEM_QUANTITY to FLOAT."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "Column EXTENDED_PRICE on table FILL_PRINT_ORD_HX was converted to FLOAT successfully."
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
END GO
