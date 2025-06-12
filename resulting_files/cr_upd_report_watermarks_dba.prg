CREATE PROGRAM cr_upd_report_watermarks:dba
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
 CALL log_message("Starting script: cr_upd_report_watermarks",log_level_debug)
 IF (validate(reply->report_watermarks))
  CALL log_message("Called from parent script",log_level_debug)
 ELSE
  CALL log_message("Called from Front-End App",log_level_debug)
  FREE RECORD reply
  RECORD reply(
    1 report_watermarks[*]
      2 watermark_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dwatermarkid = f8 WITH protect, noconstant(0.0)
 DECLARE dlongblobid = f8 WITH protect, noconstant(0.0)
 DECLARE lnumofwatermarks = i4 WITH noconstant(0)
 DECLARE lwatermarkcnt = i4 WITH noconstant(0)
 IF (validate(currentdatetime,1)=1)
  DECLARE currentdatetime = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 ENDIF
 DECLARE errmsg = c132 WITH protect
 DECLARE nnew_watermark = i2 WITH protect, constant(1)
 DECLARE nnew_long_blob = i2 WITH protect, constant(2)
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET errmsg = fillstring(132," ")
 SET lnumofwatermarks = size(request->watermarks,5)
 SET stat = alterlist(reply->report_watermarks,lnumofwatermarks)
 FOR (lwatermarkcnt = 1 TO lnumofwatermarks)
   CALL insertnewwatermark(lwatermarkcnt)
 ENDFOR
 SUBROUTINE (insertnewwatermark(requestindex=i4) =null)
   CALL log_message("Entered InsertNewRegion subroutine.",log_level_debug)
   CALL createsequences(nnew_watermark)
   CALL insertlongblob(requestindex)
   SET dsystemdate = sysdate
   INSERT  FROM cr_report_watermark crw
    SET crw.report_watermark_id = dwatermarkid, crw.long_blob_id = dlongblobid, crw.file_name =
     request->watermarks[requestindex].file_name,
     crw.orientation_flag = request->watermarks[requestindex].orientation_flag, crw.active_ind = 1,
     crw.updt_cnt = 0,
     crw.updt_dt_tm = cnvtdatetime(currentdatetime), crw.updt_id = reqinfo->updt_id, crw.updt_task =
     reqinfo->updt_task,
     crw.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertNewWatermark",
    "CR_Report_Watermark table could not be updated.  Exiting script.",1,1)
   SET reply->report_watermarks[requestindex].watermark_id = dwatermarkid
   CALL log_message("Exiting InsertNewWatermark subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createsequences(seqind=i2) =null)
   CALL log_message("Entered CreateSequences subroutine.",log_level_debug)
   IF (seqind=nnew_watermark)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dwatermarkid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Watermark seq could not be created.  Exiting script.",1,1)
    SET dlongblobid = 0
   ELSEIF (seqind=nnew_long_blob)
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dlongblobid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Long_Blob seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dLongBlobId:  ",dlongblobid))
   ENDIF
   CALL log_message("Exiting CreateSequences subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertlongblob(requestindex=i4) =null)
   CALL log_message("Entered InsertLongBlob subroutine.",log_level_debug)
   CALL createsequences(nnew_long_blob)
   INSERT  FROM long_blob_reference lb
    SET lb.long_blob_id = dlongblobid, lb.long_blob = request->watermarks[requestindex].
     watermark_image, lb.parent_entity_id = dwatermarkid,
     lb.parent_entity_name = "CR_REPORT_WATERMARK", lb.active_ind = 1, lb.active_status_cd = reqdata
     ->active_status_cd,
     lb.active_status_dt_tm = cnvtdatetime(currentdatetime), lb.active_status_prsnl_id = reqinfo->
     updt_id, lb.updt_cnt = 0,
     lb.updt_dt_tm = cnvtdatetime(currentdatetime), lb.updt_id = reqinfo->updt_id, lb.updt_task =
     reqinfo->updt_task,
     lb.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertLongBlob",
    "Long_Blob table could not be updated.  Exiting script.",1,1)
   CALL log_message("Exiting InsertLongBlob subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
#exit_script
 CALL log_message("End of script: cr_upd_report_watermarks",log_level_debug)
 CALL echorecord(reply)
END GO
