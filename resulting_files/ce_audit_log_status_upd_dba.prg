CREATE PROGRAM ce_audit_log_status_upd:dba
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
 SET readme_data->message = "Readme failed: Starting ce_audit_log_status_upd..."
 DECLARE error_cd = f8 WITH protected, noconstant(0.0)
 DECLARE error_msg = c132 WITH protected, noconstant("")
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 SET readme_data->message = "Readme failed: Starting retrieval from CODE_VALUE..."
 DECLARE operation_status_completed = f8 WITH protected, noconstant(- (1.0))
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4002019
    AND cv.active_ind=1
    AND cv.cdf_meaning="COMPLETED")
  DETAIL
   operation_status_completed = cv.code_value
  WITH nocounter
 ;end select
 IF (operation_status_completed < 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Unable to find necessary code values."
  GO TO exit_program
 ENDIF
 SET error_cd = error(error_msg,0)
 IF (error_cd != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed retrieving code values: ",error_msg)
  GO TO exit_program
 ENDIF
 UPDATE  FROM ce_audit_log t
  SET t.operation_status_cd = operation_status_completed, t.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), t.updt_task = reqinfo->updt_task,
   t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = (t.updt_cnt+ 1)
  WHERE t.ce_audit_log_id > 0.0
   AND t.operation_status_cd=0
  WITH counter
 ;end update
 SET total_updt_cnt = curqual
 SET error_cd = error(error_msg,0)
 IF (error_cd != 0)
  CALL echo(concat("Failure during update of ce_audit_log table:",error_msg))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure during ce_audit_log update:",error_msg)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
  " record(s) successfully.")
#exit_program
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
