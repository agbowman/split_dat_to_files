CREATE PROGRAM cr_rdm_update_qual_date_flag:dba
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
 SET readme_data->message = "Readme failed: starting script cr_rdm_update_qual_date_flag..."
 DECLARE rdm_errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM chart_discern_request
  SET qualification_date_flag = 1, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = (updt_cnt
   + 1),
   updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx
  WHERE request_number IN (1349790.00, 1349792.00)
  WITH nocounter
 ;end update
 IF (error(rdm_errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat(
   "Failed to update the chart_discern_request table (QUALIFICATION_DATE_FLAG):  ",rdm_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  ROLLBACK
  SET readme_data->status = "S"
  SET readme_data->message =
  "No rows were updated on the chart_discern_request table (QUALIFICATION_DATE_FLAG)."
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Readme Success: The chart_discern_request table (QUALIFICATION_DATE_FLAG) has been updated."
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
