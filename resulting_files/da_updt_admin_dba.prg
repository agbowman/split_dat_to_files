CREATE PROGRAM da_updt_admin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select User" = 0,
  "Grant/Revoke" = "GRANT"
  WITH outdev, userid, sgrant
 DECLARE personid = f8 WITH constant( $USERID)
 DECLARE usersecid = f8 WITH noconstant(0.0)
 DECLARE userinfoid = f8 WITH noconstant(0.0)
 DECLARE userinfoactiveind = i2 WITH noconstant(0)
 DECLARE securitycd = f8 WITH noconstant(0.0)
 DECLARE grantdefinition = vc WITH noconstant("none")
 DECLARE found = i2 WITH noconstant(0)
 DECLARE reportingcd = f8 WITH noconstant(0)
 DECLARE activestatuscd = f8 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE errormsg = vc WITH noconstant("")
 SET stat = error(errormsg,1)
 SET grantdefinition = cnvtupper(trim( $SGRANT,3))
 IF (grantdefinition="R")
  SET grantdefinition = "REVOKE"
 ELSEIF (grantdefinition="G")
  SET grantdefinition = "GRANT"
 ENDIF
 IF ( NOT (((grantdefinition="GRANT") OR (grantdefinition="REVOKE")) ))
  SET errormsg = "Either G or R should be given to indicate GRANT or REVOKE"
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=4002362
   AND cv.cdf_meaning="SECTYPE"
   AND cv.definition=grantdefinition
  DETAIL
   securitycd = cv.code_value
  WITH nocounter
 ;end select
 IF (((curqual != 1) OR (securitycd=0.0)) )
  SET errormsg = concat("No security code found for ",grantdefinition," SECTYPE")
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  person_id
  FROM prsnl
  WHERE person_id=personid
   AND active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errormsg = build("No active PRSNL row found for ID=",personid)
  GO TO end_now
 ENDIF
 SET activestatuscd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET reportingcd = uar_get_code_by_cki("CKI.CODEVALUE!4100899206")
 IF ((reportingcd=- (1)))
  SET errormsg = "No REPORTING code found in code set 355"
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  pi.prsnl_info_id, pi.active_ind
  FROM prsnl_info pi
  WHERE pi.person_id=personid
   AND info_type_cd=reportingcd
  DETAIL
   CALL echo(build("***** found info row=",pi.prsnl_info_id))
   IF (userinfoactiveind=0)
    userinfoid = pi.prsnl_info_id, userinfoactiveind = pi.active_ind
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  s.da_user_security_id
  FROM code_value cv,
   (inner JOIN da_user_security s ON s.security_assignment_cd=cv.code_value)
  WHERE cv.code_set=4002362
   AND cv.cdf_meaning="SECTYPE"
   AND s.prsnl_id=personid
   AND s.parent_entity_name="ADMINISTRATOR"
   AND s.parent_entity_id=0.0
  HEAD REPORT
   found = 0
  DETAIL
   CALL echo(build("***** found row=",s.da_user_security_id))
   IF (found=0)
    usersecid = s.da_user_security_id
    IF (s.security_assignment_cd=securitycd)
     found = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE success_ind = i2 WITH noconstant(0)
 SET stat = error(errormsg,1)
 IF (userinfoactiveind=0)
  IF (userinfoid=0)
   CALL echo("***** inserting new row into prsnl_info")
   INSERT  FROM prsnl_info
    SET prsnl_info_id = seq(prsnl_seq,nextval), person_id = personid, info_type_cd = reportingcd,
     active_ind = 1, active_status_cd = activestatuscd, active_status_dt_tm = cnvtdatetime(sysdate),
     active_status_prsnl_id = reqinfo->updt_id, beg_effective_dt_tm = cnvtdatetime(sysdate),
     end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
     chartable_ind = 0, contributor_system_cd = 0, info_sub_type_cd = 0,
     long_text_id = 0, value_numeric = 0, updt_applctx = reqinfo->updt_app,
     updt_task = reqinfo->updt_task, updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_dt_tm = cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
  ELSE
   CALL echo(build("***** updating prsnl_info row, id=",userinfoid))
   UPDATE  FROM prsnl_info
    SET active_ind = 1, active_status_cd = activestatuscd, active_status_dt_tm = cnvtdatetime(sysdate
      ),
     active_status_prsnl_id = reqinfo->updt_id, end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00"), updt_applctx = reqinfo->updt_app,
     updt_task = reqinfo->updt_task, updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id,
     updt_dt_tm = cnvtdatetime(sysdate)
    WHERE prsnl_info_id=userinfoid
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 IF (error(errormsg,0) != 0)
  GO TO end_now
 ENDIF
 IF (usersecid=0)
  CALL echo("***** inserting new row into da_user_security")
  INSERT  FROM da_user_security
   SET da_user_security_id = seq(da_seq,nextval), prsnl_id = personid, parent_entity_name =
    "ADMINISTRATOR",
    parent_entity_id = 0, security_assignment_cd = securitycd, active_ind = 1,
    active_status_prsnl_id = reqinfo->updt_id, begin_effective_dt_tm = cnvtdatetime(sysdate),
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
    updt_applctx = reqinfo->updt_app, updt_task = reqinfo->updt_task, updt_cnt = 0,
    updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(sysdate)
   WITH nocounter
  ;end insert
 ELSE
  CALL echo(build("***** updating da_user_security row, id=",usersecid))
  UPDATE  FROM da_user_security
   SET security_assignment_cd = securitycd, active_ind = 1, active_status_prsnl_id = reqinfo->updt_id,
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), updt_applctx = reqinfo->updt_app,
    updt_task = reqinfo->updt_task,
    updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(sysdate)
   WHERE da_user_security_id=usersecid
   WITH nocounter
  ;end update
 ENDIF
 SET stat = error(errormsg,0)
 IF (stat=0
  AND curqual=1)
  SET success_ind = 1
  COMMIT
  SELECT INTO  $OUTDEV
   message = "Security was successfully set."
   WITH nocounter, format, separator = " "
  ;end select
 ELSE
  IF (textlen(trim(errormsg))=0)
   SET errormsg = "Unknown error: no row was updated."
  ENDIF
  ROLLBACK
 ENDIF
#end_now
 IF (textlen(trim(errormsg)) > 0)
  CALL echo("************** FAILURE **************")
  CALL echo(errormsg)
  CALL echo("*************************************")
  SELECT INTO  $OUTDEV
   message = errormsg
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
