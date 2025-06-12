CREATE PROGRAM dm_rdm_update_clm_cancel_cve:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_update_clm_cancel_cve..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=29322
   AND cv.cki="CKI.CODEVALUE!3165673"
  DETAIL
   codevalue = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find the Code Value: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No record found for the code value."
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value_extension cve
  SET cve.updt_applctx = reqinfo->updt_applctx, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.field_value =
   "ASYNCHRONOUS"
  WHERE cve.code_set=29322
   AND cve.code_value=codevalue
   AND cve.field_name="PROCESSING KEY"
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update the Code Value Extension's 'PROCESSING KEY': ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM code_value_extension cve
  SET cve.updt_applctx = reqinfo->updt_applctx, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.field_value = "1"
  WHERE cve.code_set=29322
   AND cve.code_value=codevalue
   AND cve.field_name="WORK ITEM EVENT"
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update Code Value Extension's 'WORK ITEM EVENT': ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
