CREATE PROGRAM aps_get_prompts:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prompt_test_qual[*]
      2 prefix_cd = f8
      2 task_assay_cd = f8
      2 catalog_cd = f8
      2 specimen_catalog_cd = f8
      2 required_ind = i2
      2 description = vc
      2 specimen_description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 prompt_test_qual[*]
     2 prefix_cd = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcatcnt = i4 WITH protect, noconstant(0)
 DECLARE daptypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dapspecsubtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE ddefaultproccatcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcatalogtypecd = f8 WITH protect, noconstant(0.0)
 SET ddefaultproccatcd = validate(request->default_catalog_cd,0)
 SET lcatcnt = size(request->prompt_test_qual,5)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
   AND cv.active_ind=1
   AND cnvtdatetime(curdate,curtime3) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm
  DETAIL
   dcatalogtypecd = cv.code_value
  WITH nocounter
 ;end select
 IF (dcatalogtypecd <= 0)
  CALL subevent_add("CodeValue","F","GetCodeValue","6000_GENERAL LAB")
  GO TO exit_script
 ENDIF
 IF (lcatcnt=0
  AND validate(request->prefix_cd,0) != 0)
  SELECT INTO "nl:"
   FROM profile_task_r ptr,
    prefix_report_r prr
   PLAN (prr
    WHERE (prr.prefix_id=request->prefix_cd))
    JOIN (ptr
    WHERE ptr.catalog_cd=prr.catalog_cd
     AND ptr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   DETAIL
    lcatcnt = (lcatcnt+ 1)
    IF (mod(lcatcnt,10)=1)
     stat = alterlist(temp->prompt_test_qual,(lcatcnt+ 9))
    ENDIF
    temp->prompt_test_qual[lcatcnt].prefix_cd = prr.prefix_id, temp->prompt_test_qual[lcatcnt].
    catalog_cd = ptr.catalog_cd, temp->prompt_test_qual[lcatcnt].task_assay_cd = ptr.task_assay_cd
   WITH nocounter
  ;end select
  IF (lcatcnt=0)
   GO TO exit_script
  ENDIF
 ELSE
  SET daptypecd = uar_get_code_by("MEANING",106,"AP")
  IF (daptypecd=0)
   CALL populate_subeventstatus("UAR","F","MEANING","CS 106 - AP")
   GO TO exit_script
  ENDIF
  SET dapspecsubtypecd = uar_get_code_by("MEANING",5801,"APSPECIMEN")
  IF (dapspecsubtypecd=0)
   CALL populate_subeventstatus("UAR","F","MEANING","CS 5801 - APSPECIMEN")
   GO TO exit_script
  ENDIF
  IF (lcatcnt=0)
   SET lcatcnt = 1
  ENDIF
 ENDIF
 SELECT
  IF (size(temp->prompt_test_qual,5) > 0)
   PLAN (d)
    JOIN (ptr
    WHERE ptr.active_ind=1
     AND ptr.item_type_flag=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND (ptr.task_assay_cd=temp->prompt_test_qual[d.seq].task_assay_cd)
     AND (ptr.catalog_cd != temp->prompt_test_qual[d.seq].catalog_cd))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.catalog_type_cd=dcatalogtypecd)
  ELSEIF (size(request->prompt_test_qual,5) > 0)
   PLAN (d)
    JOIN (oc
    WHERE oc.activity_type_cd=daptypecd
     AND oc.activity_subtype_cd=dapspecsubtypecd
     AND (oc.catalog_cd=request->prompt_test_qual[d.seq].specimen_catalog_cd)
     AND oc.active_ind=1
     AND oc.catalog_type_cd=dcatalogtypecd)
    JOIN (ptr
    WHERE ptr.active_ind=1
     AND ptr.item_type_flag=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND oc.catalog_cd=ptr.catalog_cd)
  ELSE
   PLAN (d)
    JOIN (oc
    WHERE oc.activity_type_cd=daptypecd
     AND oc.activity_subtype_cd=dapspecsubtypecd
     AND oc.active_ind=1
     AND oc.catalog_type_cd=dcatalogtypecd)
    JOIN (ptr
    WHERE ptr.active_ind=1
     AND ptr.item_type_flag=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND oc.catalog_cd=ptr.catalog_cd)
  ENDIF
  INTO "nl:"
  ptr.catalog_cd, dspecsequence = evaluate(ptr.catalog_cd,ddefaultproccatcd,0,ptr.catalog_cd),
  dassaysequence = evaluate(ptr.catalog_cd,ddefaultproccatcd,ptr.sequence,0),
  sassaydescription = uar_get_code_description(ptr.task_assay_cd)
  FROM profile_task_r ptr,
   order_catalog oc,
   (dummyt d  WITH seq = value(lcatcnt))
  ORDER BY dspecsequence, dassaysequence, sassaydescription
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1)
   IF (mod(lcnt,10)=1)
    stat = alterlist(reply->prompt_test_qual,(lcnt+ 9))
   ENDIF
   reply->prompt_test_qual[lcnt].specimen_catalog_cd = ptr.catalog_cd, reply->prompt_test_qual[lcnt].
   specimen_description = oc.primary_mnemonic, reply->prompt_test_qual[lcnt].task_assay_cd = ptr
   .task_assay_cd,
   reply->prompt_test_qual[lcnt].description = sassaydescription, reply->prompt_test_qual[lcnt].
   required_ind = ptr.pending_ind
   IF (size(temp->prompt_test_qual,5) > 0)
    reply->prompt_test_qual[lcnt].prefix_cd = temp->prompt_test_qual[d.seq].prefix_cd, reply->
    prompt_test_qual[lcnt].catalog_cd = temp->prompt_test_qual[d.seq].catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 FREE SET temp
#exit_script
 SET stat = alterlist(reply->prompt_test_qual,lcnt)
 IF (lcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
