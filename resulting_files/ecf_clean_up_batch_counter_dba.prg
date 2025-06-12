CREATE PROGRAM ecf_clean_up_batch_counter:dba
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
 SET readme_data->message = "Readme failed: starting script ecf_clean_up_batch_counter..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE info_number_var = f8
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_name="XMAP"
    AND d.info_char="CONSTRAINT"
    AND d.info_domain="External Content Factory")
  DETAIL
   info_number_var = d.info_number
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("DM_INFO Select failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM dm_info
   SET info_number = 0
   WHERE info_name="XMAP"
    AND info_char="CONSTRAINT"
    AND info_domain="External Content Factory"
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("DM_INFO Constraint Update Failed",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  INSERT  FROM dm_info
   SET info_domain = "External Content Factory", info_name = "XMAP", info_date = cnvtdatetime(curdate,
     curtime3),
    info_char = "CONSTRAINT", info_number = 0, info_long_id = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = 0,
    updt_id = 15301, updt_task = 0
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("DM_INFO Constraint Insert Failed",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
