CREATE PROGRAM cr_upd_template_publish_dt_tm:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
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
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CR_UPD_TEMPLATE_PUBLISH_DT_TM"
 CALL log_message("Starting script: cr_upd_template_publish_dt_tm",log_level_debug)
 IF ( NOT (validate(reply)))
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD new_ids(
   1 qual[*]
     2 template_id = f8
     2 publish_id = f8
     2 long_text_id = f8
 )
 RECORD locked_ids(
   1 qual[*]
     2 id = f8
 )
 DECLARE nnumtemplates = i4 WITH protect, noconstant(size(request->templates,5))
 DECLARE dpublishid = f8 WITH protect, noconstant(0.0)
 DECLARE dlongtextid = f8 WITH protect, noconstant(0.0)
 DECLARE qpublishdttm = q8 WITH protect, noconstant(0.0)
 DECLARE errmsg = c132 WITH protect
 DECLARE current_dt_tm = q8 WITH public, constant(cnvtdatetime(sysdate))
 DECLARE nnew_pub = i2 WITH protect, constant(1)
 DECLARE nnew_pub_long_text = i2 WITH protect, constant(2)
 DECLARE insertlongtext(null) = null
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 IF (size(trim(request->publish_comment,3)) > 0)
  CALL createsequences(nnew_pub_long_text)
  CALL insertlongtext(null)
 ELSE
  CALL createsequences(nnew_pub)
 ENDIF
 SELECT INTO "nl:"
  FROM cr_template_publish ctp,
   (dummyt d  WITH seq = value(nnumtemplates))
  PLAN (d)
   JOIN (ctp
   WHERE (ctp.template_id=request->templates[d.seq].template_id)
    AND ctp.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(locked_ids->qual,(cnt+ 9))
   ENDIF
   locked_ids->qual[cnt].id = ctp.template_publish_id
  FOOT REPORT
   stat = alterlist(locked_ids->qual,cnt)
  WITH nocounter, forupdate(ctp)
 ;end select
 CALL echo(build("CurQual after first select : ",curqual))
 CALL echorecord(locked_ids)
 IF (size(locked_ids->qual,5) > 0)
  UPDATE  FROM cr_template_publish ctp,
    (dummyt d  WITH seq = value(size(locked_ids->qual,5)))
   SET ctp.end_effective_dt_tm = cnvtdatetime(current_dt_tm), ctp.active_ind = 0, ctp.updt_cnt = (ctp
    .updt_cnt+ 1),
    ctp.updt_dt_tm = cnvtdatetime(current_dt_tm), ctp.updt_id = reqinfo->updt_id, ctp.updt_task =
    reqinfo->updt_task,
    ctp.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ctp
    WHERE (ctp.template_publish_id=locked_ids->qual[d.seq].id))
   WITH nocounter
  ;end update
  CALL error_and_zero_check(curqual,"PublishTemplate",
   "CR_TEMPLATE_PUBLISH rows could not be updated.  Exiting script.",1,1)
 ENDIF
 IF ((request->publish_dt_tm=null))
  SET qpublishdttm = current_dt_tm
 ELSE
  SET qpublishdttm = request->publish_dt_tm
 ENDIF
 INSERT  FROM cr_template_publish ctp,
   (dummyt d  WITH seq = value(size(new_ids->qual,5)))
  SET ctp.template_publish_id = new_ids->qual[d.seq].publish_id, ctp.template_id = new_ids->qual[d
   .seq].template_id, ctp.active_ind = 1,
   ctp.beg_effective_dt_tm = cnvtdatetime(current_dt_tm), ctp.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), ctp.publish_dt_tm = cnvtdatetime(qpublishdttm),
   ctp.long_text_id = new_ids->qual[d.seq].long_text_id, ctp.updt_cnt = 0, ctp.updt_dt_tm =
   cnvtdatetime(current_dt_tm),
   ctp.updt_id = reqinfo->updt_id, ctp.updt_task = reqinfo->updt_task, ctp.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (ctp)
  WITH nocounter
 ;end insert
 CALL error_and_zero_check(curqual,"PublishTemplate",
  "CR_TEMPLATE_PUBLISH rows could not be created.  Exiting script.",1,1)
 SUBROUTINE (createsequences(seqind=i2) =null)
   CALL log_message("Entered CreateSequences subroutine.",log_level_debug)
   SET stat = alterlist(new_ids->qual,nnumtemplates)
   IF (seqind >= nnew_pub)
    FOR (i = 1 TO nnumtemplates)
      SELECT INTO "nl:"
       nextseqnum = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        dpublishid = nextseqnum
       WITH nocounter
      ;end select
      CALL error_and_zero_check(curqual,"CreateSequences",
       "Publish seq could not be created.  Exiting script.",1,1)
      SET new_ids->qual[i].template_id = request->templates[i].template_id
      SET new_ids->qual[i].publish_id = dpublishid
    ENDFOR
   ENDIF
   IF (seqind=nnew_pub_long_text)
    FOR (i = 1 TO nnumtemplates)
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        dlongtextid = nextseqnum
       WITH nocounter
      ;end select
      CALL error_and_zero_check(curqual,"CreateSequences",
       "Long_Text seq could not be created.  Exiting script.",1,1)
      SET new_ids->qual[i].long_text_id = dlongtextid
    ENDFOR
   ENDIF
   CALL echorecord(new_ids)
   CALL log_message("Exiting CreateSequences subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertlongtext(null)
   CALL log_message("Entered InsertLongtext subroutine.",log_level_debug)
   INSERT  FROM long_text_reference ltr,
     (dummyt d  WITH seq = value(size(new_ids->qual,5)))
    SET ltr.long_text_id = new_ids->qual[d.seq].long_text_id, ltr.long_text = request->
     publish_comment, ltr.parent_entity_id = new_ids->qual[d.seq].publish_id,
     ltr.parent_entity_name = "CR_TEMPLATE_PUBLISH", ltr.active_ind = 1, ltr.active_status_cd =
     reqdata->active_status_cd,
     ltr.active_status_dt_tm = cnvtdatetime(current_dt_tm), ltr.active_status_prsnl_id = reqinfo->
     updt_id, ltr.updt_cnt = 0,
     ltr.updt_dt_tm = cnvtdatetime(current_dt_tm), ltr.updt_id = reqinfo->updt_id, ltr.updt_task =
     reqinfo->updt_task,
     ltr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (ltr)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertLongText",
    "Long_Text_Reference table could not be updated.  Exiting script.",1,1)
   CALL log_message("Exiting InsertLongtext subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL log_message("End of script: cr_upd_template_publish_dt_tm",log_level_debug)
END GO
