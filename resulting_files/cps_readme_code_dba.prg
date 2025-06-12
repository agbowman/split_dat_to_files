CREATE PROGRAM cps_readme_code:dba
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
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET error_level = 0
 SET readme_data->message = concat("CPS_readme_code BEG : ",format(cnvtdatetime(curdate,curtime3),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM request
  SET requestclass = 0
  WHERE request_number BETWEEN 967101 AND 967121
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred when updating"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_level=1)
  ROLLBACK
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_readme_code  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
