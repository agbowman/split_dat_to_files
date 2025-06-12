CREATE PROGRAM ct_prompt_package_install:dba
 SET modify = predeclare
 DECLARE importform(strimport=vc) = null
 DECLARE strdir = c11 WITH protect, noconstant("")
 DECLARE strimportname = c255 WITH protect, noconstant("")
 DECLARE errorcount = i4 WITH protect, noconstant(0)
 DECLARE errorflag = i4 WITH public, noconstant(0)
 DECLARE errormsg = c255 WITH public, noconstant("")
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
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
 SET readme_data->message = "Readme failure: starting ct_prompt_package_install.prg"
 SET strdir = "cer_install"
 CALL importform("ct_rpt_questionnaire_layout.dat")
 CALL importform("ct_rpt_questionnaire_drv.dat")
 CALL importform("ct_trial_prescreen_test.dat")
 CALL importform("ct_get_protocol_access.dat")
 CALL importform("ct_trial_prescreen.dat")
 IF (errorcount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Clinical Trials standard form installation completed with no errors"
 ENDIF
 CALL echorecord(readme_data)
 SET modify = nopredeclare
 EXECUTE dm_readme_status
 SET modify = predeclare
 SUBROUTINE importform(strimport)
   IF (errorcount > 0)
    RETURN
   ENDIF
   IF (cursys="AXP")
    SET strimportname = concat(trim(logical(strdir),3),cnvtlower(trim(strimport,3)))
   ELSE
    SET strimportname = concat(trim(logical(strdir),3),"/",cnvtlower(trim(strimport,3)))
   ENDIF
   IF (findfile(nullterm(strimportname))=0)
    SET errorcount = (errorcount+ 1)
    SET readme_data->message = concat("%CCL-F-CT_PROMPT_PACKAGE_INSTALL FILE NOT FOUND '",trim(
      strimportname,3),"'")
   ELSE
    CALL echo(strimportname)
    SET errorflag = 0
    SET modify = nopredeclare
    EXECUTE ccl_prompt_importform nullterm(strimportname)
    SET modify = predeclare
    IF (errorflag != 0)
     SET errorcount = (errorcount+ 1)
     SET readme_data->message = substring(1,255,concat(strimport,errormsg))
    ENDIF
   ENDIF
 END ;Subroutine
 SET last_mod = "001"
 SET mod_date = "06/16/2006"
 SET modify = nopredeclare
END GO
