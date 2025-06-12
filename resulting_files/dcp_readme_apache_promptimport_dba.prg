CREATE PROGRAM dcp_readme_apache_promptimport:dba
 IF (validate(readme_data,"0")="0")
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
 ENDIF
 SET strdir = "cer_install"
 SET readme_data->status = "F"
 SET errorcount = 0
 CALL importform("dcp_apache_dm_info.dat")
 CALL importform("dcp_arpt_1_prompt.dat")
 CALL importform("dcp_arpt_6_prompt.dat")
 CALL importform("dcp_arpt_7_prompt.dat")
 CALL importform("dcp_arpt_9_prompt.dat")
 CALL importform("dcp_arpt_10_prompt.dat")
 CALL importform("dcp_arpt_15_prompt.dat")
 CALL importform("dcp_arpt_16_prompt.dat")
 CALL importform("dcp_arpt_17_prompt.dat")
 CALL importform("dcp_arpt_19_prompt.dat")
 CALL importform("dcp_arpt_23_prompt.dat")
 CALL importform("dcp_arpt_24_prompt.dat")
 CALL importform("dcp_arpt_31_prompt.dat")
 CALL importform("dcp_arpt_33_prompt.dat")
 IF (errorcount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "discern standard form installation completed with no errors"
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
  CALL echo(readme_data->message)
 ENDIF
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
    CALL echo(concat("importing : ",strimportname))
    SET errorflag = 0
    EXECUTE ccl_prompt_importform nullterm(strimportname)
    IF (errorflag != 0)
     CALL echo("error")
     SET errorcount = (errorcount+ 1)
     SET readme_data->message = substring(1,255,concat(strimport,errormsg))
    ELSE
     CALL echo("success")
     SET readme_data->message = substring(1,255,concat(strimport," : success"))
    ENDIF
   ENDIF
 END ;Subroutine
END GO
