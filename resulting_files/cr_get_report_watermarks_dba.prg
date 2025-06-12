CREATE PROGRAM cr_get_report_watermarks:dba
 SET modify maxvarlen 100000000
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
 IF (validate(reply->report_watermarks))
  CALL log_message("Called from parent script",log_level_debug)
 ELSE
  RECORD reply(
    1 report_watermarks[*]
      2 watermark_id = f8
      2 file_name = vc
      2 orientation_flag = i2
      2 watermark_image = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE watermarkcnt = i4 WITH protect, noconstant(0)
 DECLARE retrieveallwatermarks(null) = null
 DECLARE retrieverequestedwatermarks(null) = null
 DECLARE retrievewatermarkimage(null) = null
 SET reply->status_data.status = "F"
 IF (size(request->watermarks,5) > 0)
  CALL retrieverequestedwatermarks(null)
 ELSE
  CALL retrieveallwatermarks(null)
 ENDIF
 IF ((request->loadimages=1)
  AND size(reply->report_watermarks,5) > 0)
  CALL retrievewatermarkimage(null)
 ENDIF
 IF (size(reply->report_watermarks,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE retrieveallwatermarks(null)
   CALL log_message("Entered RetrieveAllWatermarks subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_report_watermark crw
    PLAN (crw
     WHERE crw.report_watermark_id > 0
      AND crw.active_ind=1)
    DETAIL
     watermarkcnt += 1
     IF (mod(watermarkcnt,10)=1)
      stat = alterlist(reply->report_watermarks,(watermarkcnt+ 9))
     ENDIF
     reply->report_watermarks[watermarkcnt].watermark_id = crw.report_watermark_id, reply->
     report_watermarks[watermarkcnt].file_name = crw.file_name, reply->report_watermarks[watermarkcnt
     ].orientation_flag = crw.orientation_flag
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveAllWatermarks",
    "Cr_report_watermark table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveAllWatermarks subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieverequestedwatermarks(null)
   CALL log_message("Entered RetrieveRequestedWatermarks subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(request->watermarks,5))),
     cr_report_watermark crw
    PLAN (d1
     WHERE (request->watermarks[d1.seq].watermark_id > 0.0))
     JOIN (crw
     WHERE (crw.report_watermark_id=request->watermarks[d1.seq].watermark_id)
      AND crw.active_ind=1)
    DETAIL
     watermarkcnt += 1
     IF (mod(watermarkcnt,10)=1)
      stat = alterlist(reply->report_watermarks,(watermarkcnt+ 9))
     ENDIF
     reply->report_watermarks[watermarkcnt].watermark_id = crw.report_watermark_id, reply->
     report_watermarks[watermarkcnt].file_name = crw.file_name, reply->report_watermarks[watermarkcnt
     ].orientation_flag = crw.orientation_flag
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveRequestedWatermarks",
    "Cr_report_watermark table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveRequestedWatermarks subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievewatermarkimage(null)
   CALL log_message("Entered RetrieveWatermarkImage subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(size(reply->report_watermarks,5))),
     cr_report_watermark crw,
     long_blob_reference lbr
    PLAN (d2
     WHERE (reply->report_watermarks[d2.seq].watermark_id > 0.0))
     JOIN (crw
     WHERE (crw.report_watermark_id=reply->report_watermarks[d2.seq].watermark_id)
      AND crw.active_ind=1)
     JOIN (lbr
     WHERE lbr.long_blob_id=crw.long_blob_id)
    HEAD REPORT
     outbuf = fillstring(4096," ")
    DETAIL
     retlen = 1, offset = 0
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,lbr.long_blob)
       IF (retlen=size(outbuf))
        reply->report_watermarks[d2.seq].watermark_image = notrim(concat(reply->report_watermarks[d2
          .seq].watermark_image,outbuf))
       ELSEIF (retlen > 0)
        reply->report_watermarks[d2.seq].watermark_image = notrim(concat(reply->report_watermarks[d2
          .seq].watermark_image,substring(1,retlen,outbuf)))
       ENDIF
       offset += retlen
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveWatermarkImage",
    "Cr_report_watermark table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveWatermarkImage subroutine.",log_level_debug)
 END ;Subroutine
#exit_script
 SET stat = alterlist(reply->report_watermarks,watermarkcnt)
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
