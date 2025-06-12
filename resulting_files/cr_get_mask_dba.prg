CREATE PROGRAM cr_get_mask:dba
 RECORD reply(
   1 qual[*]
     2 cr_mask_id = f8
     2 cr_mask_text = vc
     2 cr_publish_ind = i2
     2 cr_default_ind = i2
     2 qual[*]
       3 operation_id = f8
       3 operation_name = vc
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
 SET log_program_name = "CR_GET_MASK"
 DECLARE getmasklist(null) = null WITH protect
 DECLARE getmaskbyid(null) = null WITH protect
 DECLARE getoperationnames(null) = null WITH protect
 DECLARE idx = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE maskcount = i4
 DECLARE batch_param = f8
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.logical_domain_id
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (size(request->mask,5) > 0)
  CALL getmaskbyid(null)
 ELSE
  CALL getmasklist(null)
  CALL getoperationnames(null)
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE getoperationnames(null)
  SELECT INTO "nl:"
   cop.charting_operations_id, cop.batch_name, cop.param
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    charting_operations cop
   PLAN (d)
    JOIN (cop
    WHERE cop.param_type_flag=23
     AND cop.active_ind=1
     AND cop.param=cnvtstring(reply->qual[d.seq].cr_mask_id))
   HEAD d.seq
    opcnt = 0
   DETAIL
    opcnt += 1, stat = alterlist(reply->qual[d.seq].qual,opcnt), reply->qual[d.seq].qual[opcnt].
    operation_name = cop.batch_name,
    reply->qual[d.seq].qual[opcnt].operation_id = cop.charting_operations_id
   WITH nocounter
  ;end select
  CALL log_message("Exit GetOperationNames()",log_level_debug)
 END ;Subroutine
 SUBROUTINE getmasklist(null)
   CALL log_message("In GetMaskList()",log_level_debug)
   SELECT INTO "nl:"
    cm.cr_mask_id
    FROM cr_mask cm
    WHERE cm.cr_mask_id > 0
     AND cm.logical_domain_id=personnel_logical_domain_id
    ORDER BY cm.cr_mask_text
    HEAD REPORT
     maskcnt = 0
    DETAIL
     maskcnt += 1
     IF (mod(maskcnt,5)=1)
      stat = alterlist(reply->qual,(maskcnt+ 4))
     ENDIF
     reply->qual[maskcnt].cr_mask_id = cm.cr_mask_id, reply->qual[maskcnt].cr_mask_text = cm
     .cr_mask_text, reply->qual[maskcnt].cr_publish_ind = cm.publish_ind,
     reply->qual[maskcnt].cr_default_ind = cm.default_ind
    FOOT REPORT
     stat = alterlist(reply->qual,maskcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_MASK","GetMaskList",1,1)
   CALL log_message("Exit GetMaskList()",log_level_debug)
 END ;Subroutine
 SUBROUTINE getmaskbyid(null)
   CALL log_message("In GetMaskById()",log_level_debug)
   SET nrecordsize = size(request->mask,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(request->mask,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->mask[i].mask_id = request->mask[nrecordsize].mask_id
   ENDFOR
   SELECT INTO "nl:"
    cm.cr_mask_id
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_mask cm
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cm
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cm.cr_mask_id,request->mask[idx].mask_id,
      bind_cnt))
    HEAD REPORT
     maskcnt = 0
    DETAIL
     maskcnt += 1
     IF (mod(maskcnt,5)=1)
      stat = alterlist(reply->qual,(maskcnt+ 4))
     ENDIF
     reply->qual[maskcnt].cr_mask_id = cm.cr_mask_id, reply->qual[maskcnt].cr_mask_text = cm
     .cr_mask_text
    FOOT REPORT
     stat = alterlist(reply->qual,maskcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_MASK","GetMaskById",1,1)
   CALL log_message("Exit GetMaskById()",log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0))
  CALL echorecord(reply)
 ENDIF
 CALL log_message("End of script: cr_get_mask.",log_level_debug)
END GO
