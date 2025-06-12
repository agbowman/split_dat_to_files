CREATE PROGRAM dd_set_feature_flag_orcrd:dba
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
 DECLARE domaininfostring = vc WITH protect, noconstant("PHYSDOC_FEATURE_FLAG")
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
    SET d.info_number = flagvalue
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
    (info_domain, info_name, info_number)
    VALUES(domaininfostring, flagname, flagvalue)
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
 SET readme_data->status = "F"
 SET readme_data->message = concat("Error: Fail starting script dd_set_feature_flag_orcrd:",error_msg
  )
 CALL setfeatureflag("OUTSIDE_RECORDS_NOTETYPES",onflag)
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
