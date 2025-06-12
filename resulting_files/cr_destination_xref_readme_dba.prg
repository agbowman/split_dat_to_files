CREATE PROGRAM cr_destination_xref_readme:dba
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
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE domaininfostring = vc WITH protect, noconstant("CLINICAL REPORTING XR")
 DECLARE onflag = i2 WITH protect, noconstant(1)
 DECLARE offflag = i2 WITH protect, noconstant(0)
 SUBROUTINE (setfeatureflag(flagname=vc,flagvalue=i2) =i2)
   DECLARE correctvalue = i2 WITH protect, noconstant(true)
   DECLARE success = i2 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=domaininfostring
     AND di.info_name=flagname
    DETAIL
     IF (di.info_number != flagvalue)
      correctvalue = false
     ENDIF
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to validate if feature flag exists: ",flagname,
     " ",error_msg)
    RETURN(0)
   ENDIF
   IF (curqual != 0
    AND  NOT (correctvalue))
    SET success = updateflag(flagname,flagvalue)
   ELSEIF (curqual=0)
    SET success = insertflag(flagname,flagvalue)
   ENDIF
   IF (success=1)
    SET readme_data->status = "S"
    SET readme_data->message = "Success: Feature Flag was inserted."
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (updateflag(flagname=vc,flagvalue=i2) =i2)
   UPDATE  FROM dm_info d
    SET d.info_number = flagvalue, d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm =
     cnvtdatetime(sysdate),
     d.updt_id = reqinfo->updt_id, d.updt_cnt = (d.updt_cnt+ 1), d.updt_task = reqinfo->updt_task
    WHERE d.info_domain=domaininfostring
     AND d.info_name=flagname
    WITH nocounter
   ;end update
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to update feature flag:",flagname," ",error_msg
     )
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (insertflag(flagname=vc,flagvalue=i2) =i2)
   INSERT  FROM dm_info
    (info_domain, info_name, info_number,
    updt_applctx, updt_dt_tm, updt_cnt,
    updt_id, updt_task)
    VALUES(domaininfostring, flagname, flagvalue,
    reqinfo->updt_applctx, cnvtdatetime(sysdate), 0,
    reqinfo->updt_id, reqinfo->updt_task)
   ;end insert
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to insert feature flag: ",flagname," ",
     error_msg)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getfeatureflag(flagname=vc) =i2)
   DECLARE flagvalue = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=domaininfostring
     AND di.info_name=flagname
    DETAIL
     flagvalue = di.info_number
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to validate if feature flag exists: ",flagname,
     " ",error_msg)
    RETURN(0)
   ENDIF
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Feature Flag was checked."
   RETURN(flagvalue)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dm_info_name = vc WITH protect, constant("DESTINATION_ROUTING")
 DECLARE empty_dms_service_ident = vc WITH protect, constant(" ")
 DECLARE fax_cd_codeset_3000 = f8 WITH protect, constant(get_code_by_meaning(3000.0,"FAX"))
 DECLARE printer_cd_codeset_3000 = f8 WITH protect, constant(get_code_by_meaning(3000.0,"PRINTER"))
 DECLARE fax_cd_codeset_4636013 = f8 WITH protect, constant(get_code_by_meaning(4636013.0,"FAX"))
 DECLARE printer_cd_codeset_4636013 = f8 WITH protect, constant(get_code_by_meaning(4636013.0,
   "PRINTER"))
 DECLARE actv_status_cd = f8 WITH protect, constant(get_code_by_meaning(48.0,"ACTIVE"))
 IF (getfeatureflag(dm_info_name) > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Feature flag is already enabled. ",cnvtstring(readme_data->
    readme_id))
  GO TO exit_script
 ENDIF
 INSERT  FROM cr_destination_xref
  (cr_destination_xref_id, parent_entity_name, parent_entity_id,
  device_cd, destination_type_cd, dms_service_identifier,
  active_ind, active_status_dt_tm, active_status_prsnl_id,
  active_status_cd, updt_id, updt_dt_tm,
  updt_task, updt_applctx, updt_cnt)(SELECT
   seq(reference_seq,nextval), dx.parent_entity_name, dx.parent_entity_id,
   dx.device_cd, destination_type_cd = evaluate2(
    IF (dx.usage_type_cd=fax_cd_codeset_3000) fax_cd_codeset_4636013
    ELSEIF (dx.usage_type_cd=printer_cd_codeset_3000) printer_cd_codeset_4636013
    ENDIF
    ), empty_dms_service_ident,
   1, cnvtdatetime(sysdate), reqinfo->updt_id,
   actv_status_cd, reqinfo->updt_id, cnvtdatetime(sysdate),
   reqinfo->updt_task, reqinfo->updt_applctx, 0
   FROM device_xref dx,
    device d
   WHERE dx.parent_entity_name IN ("LOCATION", "ORGANIZATION", "PRSNL", "SERVICE_RESOURCE")
    AND dx.usage_type_cd IN (fax_cd_codeset_3000, printer_cd_codeset_3000)
    AND d.device_cd=dx.device_cd)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert rows into cr_destination_xref: ",errmsg)
  GO TO exit_script
 ELSE
  IF (setfeatureflag(dm_info_name,1)=0)
   ROLLBACK
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SUBROUTINE (get_code_by_meaning(code_set=f8,cdf_meaning=vc) =f8)
   DECLARE code_value = f8
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning=cdf_meaning
     AND cv.code_set=code_set
     AND cv.active_ind=1
    DETAIL
     code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select from code_value table: ",errmsg)
    GO TO exit_script
   ELSEIF (code_value=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = build2("No code value found for CDF_MEANING: ",cdf_meaning,
     " in CODE_SET:",code_set)
    GO TO exit_script
   ELSE
    RETURN(code_value)
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
