CREATE PROGRAM dm_del_merge_audit:dba
 SET c_mod = "DM_DEL_MERGE_AUDIT 001"
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
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success on DB2 sites"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = " "
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE table_name="DM_MERGE_AUDIT"
  WITH nocounter
 ;end select
 IF (curqual)
  CALL echo("Parser: Truncating table DM_MERGE_AUDIT ...")
  CALL parser("rdb truncate table dm_merge_audit go",1)
  SELECT INTO "nl:"
   da.*
   FROM dm_merge_audit da
   WITH nocounter
  ;end select
  IF (curqual)
   SET readme_data->status = "F"
   SET readme_data->message = "README FAILED.  Truncate on DM_MERGE_AUDIT table failed. "
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "README SUCCESS.  Truncate on DM_MERGE_AUDIT table success. "
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
