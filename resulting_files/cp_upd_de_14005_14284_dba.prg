CREATE PROGRAM cp_upd_de_14005_14284:dba
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
 DECLARE failed = c1 WITH noconstant("F")
 SET errmsg = fillstring(132," ")
 UPDATE  FROM code_value cv
  SET cv.active_ind = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE cv.cdf_meaning="50003"
   AND cv.code_set=14284
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "Z"
 ELSE
  SET failed = "S"
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.active_ind = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE cv.cdf_meaning IN ("947", "948")
   AND cv.code_set=14005
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "Z"
 ELSE
  SET failed = "S"
 ENDIF
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET failed = "F"
 ENDIF
#exit_script
 IF (failed="F")
  SET readme_data->message = "README FAILED"
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  CALL echo("README FAILED")
  COMMIT
 ELSEIF (failed="Z")
  SET readme_data->message = "Data Elements do not exist"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("ZERO ROWS")
  COMMIT
 ELSE
  SET readme_data->message = "Successfully updated Data Elements - SUCCESSFUL"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("SUCCESSFUL")
  COMMIT
 ENDIF
END GO
