CREATE PROGRAM dm_update_cv_act_dt_tm:dba
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
 DECLARE d_continue = i2
 DECLARE d_problem = c132
 DECLARE d_err_msg = c132
 SET d_err_msg = fillstring(132," ")
 SET d_continue = 1
 WHILE (d_continue=1)
   UPDATE  FROM code_value cv
    SET cv.active_dt_tm = cv.updt_dt_tm
    WHERE ((cv.active_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime3),1)) OR (cv.active_dt_tm <
    cnvtdatetime("01-JAN-1700")))
    WITH nocounter, maxqual(cv,5000)
   ;end update
   IF (curqual < 5000)
    SET d_continue = 0
   ENDIF
   IF (error(d_err_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("FAIL: ",d_err_msg)
    GO TO exit_script
   ELSE
    COMMIT
    CALL echo("** code_value.active_dt_tm update is conplete **")
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE ((cv.active_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime3),1)) OR (cv.active_dt_tm <
  cnvtdatetime("01-JAN-1700")))
  DETAIL
   d_problem = concat(trim(cnvtstring(cv.code_value),3),",",d_problem)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: these code_values still have a corrupt active_dt_tm: ",
   d_problem)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message =
  "SUCCESS: all bad active_dt_tm fields have been corrected on the code_value table"
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
