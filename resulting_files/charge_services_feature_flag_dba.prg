CREATE PROGRAM charge_services_feature_flag:dba
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
 DECLARE mainsubroutine(null) = i2
 DECLARE updatewtpfeatureflag(flagvalue=i2) = i2
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE taskfailurecount = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 IF ( NOT (validate(flag_enabled)))
  DECLARE flag_enabled = i2 WITH protect, constant(true)
 ENDIF
 IF ( NOT (validate(flag_disabled)))
  DECLARE flag_disabled = i2 WITH protect, constant(false)
 ENDIF
 IF ( NOT (validate(retail_pharm_info_domain)))
  DECLARE retail_pharm_info_domain = vc WITH protect, constant("PATIENT_ACCOUNTING_EXT_BILLED")
 ENDIF
 IF ( NOT (validate(retail_pharm_info_name)))
  DECLARE retail_pharm_info_name = vc WITH protect, noconstant("PFT_PROCESS_RETAIL_PHARMACY")
 ENDIF
 SUBROUTINE mainsubroutine(null)
   IF ( NOT (insertwtpfeatureflag(flag_disabled)))
    ROLLBACK
    SET taskfailurecount += 1
   ELSE
    CALL echo("insertWTPFeatureFlag success, committing changes")
    COMMIT
   ENDIF
   IF (taskfailurecount=0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (insertwtpfeatureflag(flagvalue=i2) =i2)
   DECLARE returnsuccessindicator = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=retail_pharm_info_domain
     AND di.info_name=retail_pharm_info_name
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - Select int DM_INFO failed: ",error_msg)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = flagvalue, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(sysdate),
      di.updt_id = reqinfo->updt_id, di.updt_task = 0, di.updt_applctx = 0,
      di.info_domain = retail_pharm_info_domain, di.info_name = retail_pharm_info_name
    ;end insert
    SET err_code = error(error_msg,1)
    IF (err_code > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error - failed to insertWTP feature flag: ",
      retail_pharm_info_name," ",error_msg)
     RETURN(false)
    ENDIF
    SET returnsuccessindicator = true
   ELSE
    CALL echo("insertWTPFeatureFlag feature flage already exists, returning true for no failure")
    SET returnsuccessindicator = true
   ENDIF
   RETURN(returnsuccessindicator)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script charge_services_feature_flag..."
 IF (mainsubroutine(null))
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme performed all required tasks"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
