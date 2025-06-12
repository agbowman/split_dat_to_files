CREATE PROGRAM cr_maintain_mask:dba
 RECORD reply(
   1 cr_mask_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET log_program_name = "CR_MAINTAIN_MASK"
 DECLARE insertmask(null) = null WITH protect
 DECLARE editmask(null) = null WITH protect
 DECLARE removemask(null) = null WITH protect
 DECLARE removeolddefault(null) = null WITH protect
 DECLARE default_mask = f8 WITH noconstant(0.0)
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE action_insert = i2 WITH constant(0)
 DECLARE action_updt = i2 WITH constant(1)
 DECLARE action_remove = i2 WITH constant(2)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.logical_domain_id
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (getmaskbyname(request->mask_template)=0
  AND (request->action_type=action_insert))
  CALL insertmask(null)
 ELSEIF ((request->action_type=action_updt))
  CALL editmask(null)
 ELSEIF ((request->action_type=action_remove))
  CALL removemask(null)
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SUBROUTINE (getmaskbyname(mask=vc) =i2 WITH protect)
   CALL log_message("In GetMaskByName()",log_level_debug)
   SELECT INTO "nl:"
    cm.cr_mask_text
    FROM cr_mask cm
    WHERE cm.cr_mask_text=mask
     AND cm.logical_domain_id=personnel_logical_domain_id
    DETAIL
     reply->cr_mask_id = cm.cr_mask_id
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_MASK","GetMaskByName",1,0)
   RETURN(curqual)
   CALL log_message("Exit GetMaskByName()",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertmask(null)
   CALL log_message("In InsertMask()",log_level_debug)
   IF ((request->default_ind=1))
    CALL removeolddefault(null)
   ENDIF
   DECLARE mask_id = f8
   SELECT INTO "nl:"
    seq_val = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     mask_id = seq_val
    WITH format, counter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","cr_mask",1,1)
   INSERT  FROM cr_mask cm
    SET cm.cr_mask_id = mask_id, cm.cr_mask_text = request->mask_template, cm.default_ind = request->
     default_ind,
     cm.updt_cnt = 0, cm.updt_dt_tm = cnvtdatetime(sysdate), cm.updt_id = reqinfo->updt_id,
     cm.updt_applctx = reqinfo->updt_applctx, cm.updt_task = reqinfo->updt_task, cm.logical_domain_id
      = personnel_logical_domain_id
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CR_MASK","INSERT_MASK",1,1)
   SET reply->cr_mask_id = mask_id
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   CALL log_message("Exit InsertMask()",log_level_debug)
 END ;Subroutine
 SUBROUTINE editmask(null)
   CALL log_message("In EditMask()",log_level_debug)
   IF ((request->default_ind=1))
    CALL removeolddefault(null)
   ENDIF
   UPDATE  FROM cr_mask cm
    SET cm.cr_mask_text = request->mask_template, cm.logical_domain_id = personnel_logical_domain_id,
     cm.default_ind = request->default_ind,
     cm.updt_cnt = (cm.updt_cnt+ 1), cm.updt_dt_tm = cnvtdatetime(sysdate), cm.updt_id = reqinfo->
     updt_id,
     cm.updt_applctx = reqinfo->updt_applctx, cm.updt_task = reqinfo->updt_task
    WHERE (cm.cr_mask_id=request->mask_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"CR_MASK","EDIT_MASK",1,1)
   SET reply->cr_mask_id = request->mask_id
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   CALL log_message("Exit EditMask()",log_level_debug)
 END ;Subroutine
 SUBROUTINE removemask(null)
   CALL log_message("In RemoveMask()",log_level_debug)
   DELETE  FROM cr_mask cm
    WHERE (cm.cr_mask_id=request->mask_id)
    WITH nocounter
   ;end delete
   CALL log_message("Exit RemoveMask()",log_level_debug)
 END ;Subroutine
 SUBROUTINE removeolddefault(null)
   CALL log_message("In RemoveOldDefault()",log_level_debug)
   UPDATE  FROM cr_mask cm
    SET cm.default_ind = 0, cm.updt_cnt = (cm.updt_cnt+ 1), cm.updt_dt_tm = cnvtdatetime(sysdate),
     cm.updt_id = reqinfo->updt_id, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_task = reqinfo->
     updt_task
    WHERE cm.default_ind=1
     AND cm.logical_domain_id=personnel_logical_domain_id
    WITH nocounter
   ;end update
   CALL log_message("Exit RemoveOldDefault()",log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0))
  CALL echorecord(reply)
 ENDIF
 CALL log_message("End of script: cr_maintain_mask.",log_level_debug)
END GO
