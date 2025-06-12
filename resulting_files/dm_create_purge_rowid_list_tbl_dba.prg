CREATE PROGRAM dm_create_purge_rowid_list_tbl:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_create_purge_rowid_list_tbl..."
 DECLARE temp_table_name = vc WITH protect, constant("DM_PURGE_ROWID_LIST_GTTP")
 DECLARE tableexistsind = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name=temp_table_name
  DETAIL
   tableexistsind = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for existence of temp table: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (tableexistsind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Temp table already exists; auto-successing."
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb asis(^ CREATE GLOBAL TEMPORARY TABLE ",temp_table_name,
   " (PURGE_TABLE_ROWID ROWID) ON COMMIT PRESERVE ROWS ^) go"))
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create temporary table: ",errmsg)
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb asis(^ CREATE INDEX XIE1DM_PURGE_ROWID_LIST_GTTP ON ",temp_table_name,
   " (PURGE_TABLE_ROWID) ^) go"))
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create index: ",errmsg)
  GO TO exit_script
 ENDIF
 EXECUTE oragen3 value(temp_table_name)
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to ORAGEN temp table: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
