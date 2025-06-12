CREATE PROGRAM ccl_prompt_coredr_rpts:dba
 DECLARE importform(strimport=vc) = null
 DECLARE errormsg = vc WITH public
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
 SET strdir = "cer_install"
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script ccl_prompt_coredr_rpts..."
 SET errorcount = 0
 CALL importform("drc_print_patient_specific_rpt.dat")
 CALL importform("drc_print_route_groupings_rpt.dat")
 IF (errorcount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "discern standard form installation completed with no errors"
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE importform(strimport)
   IF (errorcount > 0)
    RETURN
   ENDIF
   IF (cursys="AXP")
    SET strimportname = concat(trim(logical(strdir)),cnvtlower(trim(strimport)))
   ELSE
    SET strimportname = concat(trim(logical(strdir)),"/",cnvtlower(trim(strimport)))
   ENDIF
   IF (findfile(nullterm(strimportname))=0)
    SET errorcount = (errorcount+ 1)
    CALL echo(concat("file not found, ",trim(strimportname)))
    SET readme_data->message = concat("File '",trim(strimportname),"' not found. ")
   ELSE
    CALL echo(strimportname)
    SET errorflag = 0
    EXECUTE ccl_prompt_importform nullterm(strimportname)
    IF (errorflag != 0)
     SET errorcount = (errorcount+ 1)
     SET readme_data->message = substring(1,255,concat(strimport,errormsg))
    ENDIF
   ENDIF
 END ;Subroutine
END GO
