CREATE PROGRAM dm_rdds_ins_dm_info:dba
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
 SET readme_data->message = "Readme failure.  Starting DM_RDDS_INS_DM_INFO script."
 FREE RECORD dm_error
 RECORD dm_error(
   1 message = vc
 )
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONTEXT"
   AND di.info_name="ACTIVE_IND"
  WITH nocounter
 ;end select
 IF (error(dm_error->message,1) != 0)
  SET readme_data->message = concat("FAIL:",dm_error->message)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: dm_info row already exists, no action required"
  GO TO exit_script
 ELSE
  INSERT  FROM dm_info di
   SET di.info_domain = "RDDS CONTEXT", di.info_name = "ACTIVE_IND", di.info_number = 0,
    di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="RDDS CONTEXT"
    AND di.info_name="ACTIVE_IND"
   WITH nocounter
  ;end select
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET readme_data->message = "FAIL: did not insert dm_info row"
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "SUCCESS: dm_info row imported"
  ENDIF
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
 FREE RECORD dm_error
END GO
