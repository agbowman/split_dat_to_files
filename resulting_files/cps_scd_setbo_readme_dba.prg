CREATE PROGRAM cps_scd_setbo_readme:dba
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
 SET readme_data->message = "FAILED: Failed starting script cps_scd_setbo_readme"
 DECLARE err_cd = i4 WITH public
 DECLARE failed = i2 WITH public
 SET err_msg = ""
 SET err_cd = 0
 SET failed = 0
 SELECT INTO "nl:"
  FROM request r
  WHERE request_number IN (964555, 964560)
  WITH nocounter
 ;end select
 SET err_cd = error(err_msg,1)
 IF (err_cd != 0)
  SET failed = 1
  SET readme_data->message = "FAILED: Could not determine if expected data exists"
  GO TO end_script
 ENDIF
 IF (curqual != 2)
  SET failed = 1
  SET readme_data->message = "FAILED: One or both of requests 964555 and 964560 not found"
  GO TO end_script
 ENDIF
 UPDATE  FROM request
  SET binding_override = "ScdRefServer"
  WHERE request_number IN (964555, 964560)
 ;end update
 SET err_cd = error(err_msg,1)
 IF (err_cd != 0)
  SET failed = 1
  SET readme_data->message = "FAILED: Failed to update one or more of requests 964555 and 964560"
  GO TO end_script
 ENDIF
#end_script
 IF (failed > 0)
  ROLLBACK
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET readme_data->message = "SUCCESS: Added/updated binding override for requests 964555 and 964560"
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
