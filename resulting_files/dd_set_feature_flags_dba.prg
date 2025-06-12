CREATE PROGRAM dd_set_feature_flags:dba
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
 DECLARE insertflag(flagname=vc,flagvalue=i2) = null
 DECLARE updateflag(flagname=vc,flagvalue=i2) = null
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE domaininfostring = vc WITH protect, noconstant("PHYSDOC_FEATURE_FLAG")
 DECLARE datatokenflagname = vc WITH protect
 DECLARE distributionflagname = vc WITH protect
 DECLARE signonprintflagname = vc WITH protect
 DECLARE onflag = i2 WITH protect
 DECLARE offflag = i2 WITH protect
 DECLARE numberofflags = i4
 SET datatokenflag = "DATA_TOKEN"
 SET distributionflag = "DISTRIBUTION"
 SET signonprintflag = "SIGN_ON_PRINT"
 SET onflag = 1
 SET offflag = 0
 SET numberofflags = 3
 SET readme_data->status = "F"
 SET readme_data->message = concat("Error: Fail starting script dd_set_feature_flags:",error_msg)
 FREE RECORD flags
 RECORD flags(
   1 data[*]
     2 string = vc
     2 value = i2
 )
 SET stat = alterlist(flags->data,numberofflags)
 SET flags->data[1].string = datatokenflag
 SET flags->data[1].value = onflag
 SET flags->data[2].string = signonprintflag
 SET flags->data[2].value = onflag
 SET flags->data[3].string = distributionflag
 SET flags->data[3].value = onflag
 DECLARE correctvalue = i2 WITH protect, noconstant(true)
 FOR (i = 1 TO size(flags->data,5))
   SET correctvalue = true
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=domaininfostring
     AND (di.info_name=flags->data[i].string)
    DETAIL
     IF ((di.info_number != flags->data[i].value))
      correctvalue = false
     ENDIF
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to validate if feature flag exists: ",flagname,
     " ",error_msg)
    GO TO exit_script
   ENDIF
   IF (curqual != 0
    AND  NOT (correctvalue))
    CALL updateflag(flags->data[i].string,flags->data[i].value)
   ELSEIF (curqual=0)
    CALL insertflag(flags->data[i].string,flags->data[i].value)
   ENDIF
 ENDFOR
 SUBROUTINE updateflag(flagname,flagvalue)
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
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE insertflag(flagname,flagvalue)
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
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Feature Flags were inserted."
#exit_script
 FREE RECORD flags
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
