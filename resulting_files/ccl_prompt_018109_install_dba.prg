CREATE PROGRAM ccl_prompt_018109_install:dba
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
 IF (((curcclrev < 7.8) OR (curcclrev=7.8
  AND currevminor2 <= 4)) )
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success: CCL version 7.8.5 or later required"
  CALL echorecord(readme_data)
  EXECUTE dm_readme_status
  RETURN
 ENDIF
 DECLARE importform(strimport=vc) = null
 DECLARE checkimportversion(nversion=i4) = i2
 DECLARE errormsg = vc WITH public
 SET strdir = "cer_install"
 SET readme_data->status = "F"
 SET errorcount = 0
 CALL importform("dpl_sys_default_template.dat")
 CALL importform("ccl_dlg_get_object.dat")
 CALL importform("ccl_dlg_getperson.dat")
 CALL importform("ccl_dlg_ds_utility.dat")
 CALL importform("ccl_dlg_get_pers_by_fullname.dat")
 CALL importform("cclprot.dat")
 CALL importform("cclglos.dat")
 CALL importform("prompthelp.dat")
 CALL importform("ccl_prompt_pck14577_test.dat")
 CALL importform("eks_monitor.dat")
 CALL importform("ccl_prompt_audit.dat")
 CALL importform("ccl_dlg_get_person_info.dat")
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
    SET readme_data->message = concat("%CCL-F-CCL_PROMPT_CUMULATIVE_INSTALL FILE NOT FOUND '",trim(
      strimportname),"'")
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
