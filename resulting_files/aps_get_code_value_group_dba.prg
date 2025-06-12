CREATE PROGRAM aps_get_code_value_group:dba
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].operationstatus)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectname)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectvalue)))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt = (lglbslsubeventcnt+ 1)
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "APS_GET_CODE_VALUE_GROUP"
 IF (validate(reply->status_data.status,"W")="W")
  RECORD reply(
    1 parents[*]
      2 code_value = f8
      2 display = vc
      2 display_key = vc
      2 description = vc
      2 definition = vc
      2 code_set = i4
      2 cdf_meaning = c12
      2 collation_seq = i4
      2 active_ind = i2
      2 children[*]
        3 code_value = f8
        3 display = vc
        3 display_key = vc
        3 description = vc
        3 definition = vc
        3 code_set = i4
        3 cdf_meaning = c12
        3 collation_seq = i4
        3 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lcodesetcnt = i4 WITH protect, noconstant(0)
 DECLARE lparentcnt = i4 WITH protect, noconstant(0)
 DECLARE lchildcnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: aps_get_code_value_group",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(request)
 ENDIF
 SET lcodesetcnt = size(request->code_sets,5)
 IF (lcodesetcnt > 0)
  SELECT
   IF ((request->max_results > 0))
    WITH nocounter, maxqual(cvg,value(request->max_results))
   ELSE
    WITH nocounter
   ENDIF
   INTO "nl:"
   FROM (dummyt d  WITH seq = value(lcodesetcnt)),
    code_value cv,
    code_value_group cvg,
    code_value cv2
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->code_sets[d.seq].code_set)
     AND cv.code_value > 0
     AND ((cv.active_ind=1) OR ((request->inactives_ind=1))) )
    JOIN (cvg
    WHERE cvg.parent_code_value=cv.code_value)
    JOIN (cv2
    WHERE cv2.code_value=cvg.child_code_value
     AND ((cv2.active_ind=1) OR ((request->inactives_ind=1))) )
   ORDER BY cv.display_key
   HEAD cvg.parent_code_value
    lparentcnt = (lparentcnt+ 1), lchildcnt = 0
    IF (lparentcnt > size(reply->parents,5))
     stat = alterlist(reply->parents,(lparentcnt+ 9))
    ENDIF
    reply->parents[lparentcnt].code_value = cv.code_value, reply->parents[lparentcnt].display = cv
    .display, reply->parents[lparentcnt].display_key = cv.display_key,
    reply->parents[lparentcnt].description = cv.description, reply->parents[lparentcnt].definition =
    cv.definition, reply->parents[lparentcnt].code_set = cv.code_set,
    reply->parents[lparentcnt].cdf_meaning = cv.cdf_meaning, reply->parents[lparentcnt].collation_seq
     = cv.collation_seq, reply->parents[lparentcnt].active_ind = cv.active_ind
   HEAD cvg.child_code_value
    lchildcnt = (lchildcnt+ 1)
    IF (lchildcnt > size(reply->parents[lparentcnt].children,5))
     stat = alterlist(reply->parents[lparentcnt].children,(lchildcnt+ 9))
    ENDIF
    reply->parents[lparentcnt].children[lchildcnt].code_value = cv2.code_value, reply->parents[
    lparentcnt].children[lchildcnt].display = cv2.display, reply->parents[lparentcnt].children[
    lchildcnt].display_key = cv2.display_key,
    reply->parents[lparentcnt].children[lchildcnt].description = cv2.description, reply->parents[
    lparentcnt].children[lchildcnt].definition = cv2.definition, reply->parents[lparentcnt].children[
    lchildcnt].code_set = cv2.code_set,
    reply->parents[lparentcnt].children[lchildcnt].cdf_meaning = cv2.cdf_meaning, reply->parents[
    lparentcnt].children[lchildcnt].collation_seq = cv2.collation_seq, reply->parents[lparentcnt].
    children[lchildcnt].active_ind = cv2.active_ind
   FOOT  cvg.parent_code_value
    stat = alterlist(reply->parents[lparentcnt].children,lchildcnt)
   FOOT REPORT
    stat = alterlist(reply->parents,lparentcnt)
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (lparentcnt=0)
  CALL log_message("Zero code value children returned.",log_level_debug)
  SET reply->status_data.status = "Z"
 ELSEIF (lparentcnt > 0)
  CALL log_message("Code value children successfully returned.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: aps_get_code_value_group",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
 CALL uar_sysdestroyhandle(hsys)
END GO
