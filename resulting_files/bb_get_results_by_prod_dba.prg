CREATE PROGRAM bb_get_results_by_prod:dba
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
  DECLARE hsys = i4 WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
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
 SET log_program_name = "bb_get_results_by_prod"
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 results[*]
       3 result_id = f8
       3 order_id = f8
       3 catalog_cd = f8
       3 task_assay_cd = f8
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: bb_get_results_by_prod",log_level_debug)
 SET modify = predeclare
 DECLARE product_id_count = i4 WITH protect, noconstant(0)
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE j_idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET product_id_count = size(request->qual,5)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(product_id_count)),
   orders o,
   result r
  PLAN (d1)
   JOIN (o
   WHERE (o.product_id=request->qual[d1.seq].product_id)
    AND o.product_id > 0)
   JOIN (r
   WHERE r.order_id=o.order_id)
  HEAD REPORT
   i_idx = 0
  HEAD d1.seq
   i_idx = (i_idx+ 1)
   IF (i_idx > size(reply->qual,5))
    stat = alterlist(reply->qual,(i_idx+ 9))
   ENDIF
   j_idx = 0
  DETAIL
   j_idx = (j_idx+ 1)
   IF (j_idx > size(reply->qual[i_idx].results,5))
    stat = alterlist(reply->qual[i_idx].results,(j_idx+ 9))
   ENDIF
   reply->qual[i_idx].product_id = o.product_id, reply->qual[i_idx].results[j_idx].result_id = r
   .result_id, reply->qual[i_idx].results[j_idx].order_id = r.order_id,
   reply->qual[i_idx].results[j_idx].catalog_cd = r.catalog_cd, reply->qual[i_idx].results[j_idx].
   task_assay_cd = r.task_assay_cd, reply->qual[i_idx].results[j_idx].result_status_cd = r
   .result_status_cd
  FOOT  d1.seq
   stat = alterlist(reply->qual[i_idx].results,j_idx)
  FOOT REPORT
   stat = alterlist(reply->qual,i_idx)
  WITH nocounter
 ;end select
 IF (error_message(1) > 0)
  GO TO exit_script
 ENDIF
 IF (curqual <= 0)
  CALL log_message("Zero product results returned.",log_level_debug)
  SET reply->status_data.status = "Z"
 ELSE
  CALL log_message("Product results successfully returned.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: bb_get_results_by_prod",log_level_debug)
END GO
