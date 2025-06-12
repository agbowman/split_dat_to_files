CREATE PROGRAM afc_rdm_upd_icd_display:dba
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
 SET readme_data->message = "Readme afc_rdm_upd_icd_display failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE update_error = vc WITH protect, constant("UPDATE_ERROR")
 DECLARE failed = i2 WITH noconstant(false)
 CALL echo("calling update_codeDisplay")
 CALL update_codedisplay(1)
 IF (failed=false)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Readme updated Codeset and  Common Data Foundations for    13030, 13036 and  for 14002."
  COMMIT
 ELSE
  CALL echo("failed update_codeDisplay")
  ROLLBACK
 ENDIF
 GO TO exit_script
 SUBROUTINE update_codedisplay(dummyvar)
   UPDATE  FROM code_value cv
    SET cv.display = "Missing ICD", cv.display_key = "MISSINGICD", cv.definition = "Missing ICD",
     cv.description = "Missing ICD", cv.updt_task = reqinfo->updt_task, cv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = reqinfo->updt_applctx, cv.updt_id = reqinfo->
     updt_id
    WHERE cv.cki="CKI.CODEVALUE!3562"
     AND cv.code_set=13030
     AND cv.cdf_meaning="NOICD9"
     AND cv.active_ind=1
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating Code set 13030.")
    RETURN(0)
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.display = "Missing ICD Procedure", cv.display_key = "MISSINGICDPROCEDURE", cv.definition
      = "Missing ICD Procedure",
     cv.description = "Missing ICD Procedure", cv.updt_task = reqinfo->updt_task, cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = reqinfo->updt_applctx, cv.updt_id = reqinfo->
     updt_id
    WHERE cv.cki="CKI.CODEVALUE!20812"
     AND cv.code_set=13030
     AND cv.cdf_meaning="NOICD9PROC"
     AND cv.active_ind=1
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating Code set 13030.")
    RETURN(0)
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.display = "ICD", cv.display_key = "ICD", cv.updt_task = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cki="CKI.CODEVALUE!3587"
     AND cv.code_set=13036
     AND cv.cdf_meaning="ICD9"
     AND cv.active_ind=1
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating Code set 13036.")
    RETURN(0)
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.display = "ICD Proc", cv.display_key = "ICDPROC", cv.updt_task = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cki="CKI.CODEVALUE!20816"
     AND cv.code_set=13036
     AND cv.cdf_meaning="PROCCODE"
     AND cv.active_ind=1
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating Code set 13036.")
    RETURN(0)
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.display = "ICD", cv.display_key = "ICD", cv.definition = "ICD Bill Code",
     cv.description = "ICD Bill Code", cv.updt_task = reqinfo->updt_task, cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = reqinfo->updt_applctx, cv.updt_id = reqinfo->
     updt_id
    WHERE cv.cki="CKI.CODEVALUE!14322"
     AND cv.code_set=14002
     AND cv.cdf_meaning="ICD9"
     AND cv.active_ind=1
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating Code set 14002.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "Missing ICD", cv.definition = "Missing ICD", cv.updt_task = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="NOICD9"
     AND cv.code_set=13030
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 13030.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "Missing ICD Procedure", cv.definition = "Missing ICD Procedure", cv.updt_task
      = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="NOICD9PROC"
     AND cv.code_set=13030
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 13030.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "ICD", cv.definition = "ICD", cv.updt_task = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="ICD9"
     AND cv.code_set=13036
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 13036.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "ICD Proc", cv.definition = "ICD Procedure Code", cv.updt_task = reqinfo->
     updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="PROCCODE"
     AND cv.code_set=13036
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 13036.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "ICD", cv.definition = "ICD Bill Code", cv.updt_task = reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="ICD9"
     AND cv.code_set=14002
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 14002.")
    RETURN(0)
   ENDIF
   UPDATE  FROM common_data_foundation cv
    SET cv.display = "ICD Procedure Codes", cv.definition = "ICD Procedure Codes", cv.updt_task =
     reqinfo->updt_task,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx
      = reqinfo->updt_applctx,
     cv.updt_id = reqinfo->updt_id
    WHERE cv.cdf_meaning="PROCCODE"
     AND cv.code_set=14002
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET failed = update_error
    SET readme_data->message = build(errmsg,"Failed updating COMMON_DATA_FOUNDATION for 14002.")
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
