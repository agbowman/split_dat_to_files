CREATE PROGRAM aps_upd_prompt_fields:dba
 RECORD reply(
   1 prompt_id = f8
   1 long_text_id = f8
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE dactivecd = f8 WITH protect, noconstant(0.0)
 SET dactivecd = uar_get_code_by("MEANING",48,"ACTIVE")
 IF (dactivecd <= 0)
  CALL populate_subeventstatus("UAR","F","MEANING","CS 48 - ACTIVE")
  GO TO exit_script
 ENDIF
 IF ((request->prompt_id != 0))
  DELETE  FROM ap_prompt_field apf
   PLAN (apf
    WHERE (apf.ap_prompt_id=request->prompt_id))
   WITH counter
  ;end delete
 ENDIF
 IF ((request->status_flag=1))
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    reply->long_text_id = seq_nbr
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    reply->prompt_id = seq_nbr
   WITH nocounter
  ;end select
  INSERT  FROM long_text_reference lt
   SET lt.long_text_id = reply->long_text_id, lt.long_text = request->text, lt.active_ind = 1,
    lt.active_status_cd = dactivecd, lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt
    .active_status_prsnl_id = reqinfo->updt_id,
    lt.parent_entity_name = "AP_PROMPT", lt.parent_entity_id = reply->prompt_id, lt.updt_cnt = 0,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
    reqinfo->updt_task,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL populate_subeventstatus("INSERT","F","TABLE","LONG_TEXT_REFERENCE")
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_prompt ap
   SET ap.ap_prompt_id = reply->prompt_id, ap.catalog_cd = request->catalog_cd, ap.task_assay_cd =
    request->task_assay_cd,
    ap.action_flag = request->action_flag, ap.long_text_id = reply->long_text_id, ap.updt_cnt = 0,
    ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_id = reqinfo->updt_id, ap.updt_task =
    reqinfo->updt_task,
    ap.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL populate_subeventstatus("INSERT","F","TABLE","AP_PROMPT")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->status_flag=2))
  SELECT INTO "nl:"
   ap.*
   FROM ap_prompt ap
   PLAN (ap
    WHERE (ap.ap_prompt_id=request->prompt_id)
     AND (ap.updt_cnt=request->updt_cnt))
   DETAIL
    reply->prompt_id = ap.ap_prompt_id, reply->long_text_id = ap.long_text_id, reply->updt_cnt = (ap
    .updt_cnt+ 1)
   WITH nocounter, forupdate(ap)
  ;end select
  IF (curqual=0)
   CALL populate_subeventstatus("LOCK","F","TABLE","AP_PROMPT")
   GO TO exit_script
  ENDIF
  UPDATE  FROM long_text_reference lt
   SET lt.long_text = request->text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx
   PLAN (lt
    WHERE (lt.long_text_id=reply->long_text_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL populate_subeventstatus("UPDATE","F","TABLE","LONG_TEXT_REFERENCE")
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_prompt ap
   SET ap.action_flag = request->action_flag, ap.updt_cnt = reply->updt_cnt, ap.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
    updt_applctx
   PLAN (ap
    WHERE (ap.ap_prompt_id=reply->prompt_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL populate_subeventstatus("UPDATE","F","TABLE","AP_PROMPT")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->status_flag=3))
  DELETE  FROM ap_prompt ap
   PLAN (ap
    WHERE (ap.ap_prompt_id=request->prompt_id))
   WITH counter
  ;end delete
  DELETE  FROM long_text_reference lt
   PLAN (lt
    WHERE (lt.long_text_id=request->long_text_id))
   WITH counter
  ;end delete
 ENDIF
 IF ((reply->prompt_id != 0)
  AND size(request->field_qual,5) > 0)
  INSERT  FROM ap_prompt_field ap,
    (dummyt d  WITH seq = value(size(request->field_qual,5)))
   SET ap.ap_prompt_field_id = seq(reference_seq,nextval), ap.ap_prompt_id = reply->prompt_id, ap
    .field_nbr_seq = request->field_qual[d.seq].field_nbr,
    ap.field_type_txt = request->field_qual[d.seq].field_type, ap.action_flag = request->field_qual[d
    .seq].field_action_flag, ap.oe_field_id = request->field_qual[d.seq].field_oe_field_id,
    ap.updt_cnt = 0, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_id = reqinfo->updt_id,
    ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ap)
   WITH nocounter
  ;end insert
  IF (curqual != size(request->field_qual,5))
   CALL populate_subeventstatus("INSERT","F","TABLE","AP_PROMPT_FIELD")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
