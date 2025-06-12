CREATE PROGRAM dm_rmc_chk_realm:dba
 DECLARE drrd_get_realm(null) = vc
 SUBROUTINE drrd_get_realm(null)
   DECLARE dgr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dgr_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgr_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgr_domain = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Get environment name via environment logical"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (cursys="AXP")
    SET dgr_domain = "-1"
    RETURN(dgr_domain)
   ENDIF
   SET dgr_env_name = cnvtlower(trim(logical("environment")))
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL clear(1,1)
    CALL echo(concat("ENVIRONMENT LOGICAL:",dgr_env_name))
   ENDIF
   IF (trim(dgr_env_name) <= " ")
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   SET dm_err->eproc = "Checking for domain name in registry"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgr_cmd = concat("$cer_exe/lreg -getp \\environment\\",dgr_env_name," Domain")
   SET dm_err->disp_dcl_err_ind = 0
   SET dgr_no_error = dm2_push_dcl(dgr_cmd)
   IF (dgr_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN("-1")
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN("-1")
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
     CALL pause(3)
    ENDIF
   ENDIF
   IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
    "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)))
   )) )) )
    SET dgr_no_error = 1
    SET dgr_domain = "NOPARMRETURNED"
   ELSE
    SET dgr_domain = dm_err->errtext
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("domain_value: <<",dgr_domain,">>"))
   ENDIF
   IF (dgr_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   RETURN(cnvtupper(dgr_domain))
 END ;Subroutine
 IF (validate(reply->status_data.status,"5")="5")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to find reply structure for dm_rmc_chk_realm"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_chk
 ENDIF
 IF (check_logfile("dm_rmc_chk_realm",".log","DM_RMC_CHK_REALM LOGFILE")=0)
  SET reply->status_data.status = "F"
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_chk
 ENDIF
 SET reply->realm_value = drrd_get_realm(null)
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(reply)
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  SET reply->status_data.status = "F"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_chk
 ELSEIF ((reply->realm_value IN ("NOPARMRETURNED", "-1")))
  SET reply->status_data.status = "F"
  IF ((reply->realm_value="NOPARMRETURNED"))
   SET dm_err->emsg = "Realm data is unavailable in registry."
  ENDIF
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSEIF ((reply->realm_value > " "))
  SET reply->status_data.status = "S"
 ENDIF
#exit_chk
END GO
