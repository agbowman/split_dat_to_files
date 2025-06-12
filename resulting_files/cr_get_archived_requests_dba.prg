CREATE PROGRAM cr_get_archived_requests:dba
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
 SET log_program_name = "CR_GET_ARCHIVED_REQUESTS"
 IF (validate(request) != 1)
  RECORD request(
    1 base_information_ind = i2
    1 load_zipfile_ind = i2
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 qual[*]
      2 archive_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 archive_id = f8
      2 archived_dt_tm = dq8
      2 archived_cnt = i4
      2 long_blob_id = f8
      2 zip_file = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 qual_more[*]
      2 request[*]
        3 archive_id = f8
        3 archived_dt_tm = dq8
        3 archived_cnt = i4
        3 long_blob_id = f8
        3 zip_file = gvc
    1 count = i4
  )
 ENDIF
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE userlogicaldomainid = f8 WITH noconstant(0), protect
 DECLARE loadbaseinformation(null) = null
 DECLARE loadarchivedbyids(null) = null
 DECLARE loadarchivedbydaterange(null) = null
 DECLARE loadzipfile(null) = null
 CALL log_message("Begin script: cr_get_archived_requests",log_level_debug)
 SET reply->status_data.status = "F"
 IF ( NOT (getcurrentuserslogicaldomain(userlogicaldomainid)))
  GO TO exit_script
 ENDIF
 CALL loadbaseinformation(null)
 IF ((request->load_zipfile_ind=1))
  CALL loadzipfile(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE loadbaseinformation(null)
   CALL log_message("In LoadBaseInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   IF (size(request->qual,5) > 0)
    CALL loadarchivedbyids(null)
   ELSE
    CALL loadarchivedbydaterange(null)
   ENDIF
   CALL log_message(build("Exit LoadBaseInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadarchivedbyids(null)
   CALL log_message("In LoadArchivedByIds()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->qual,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->qual[i].archive_id = request->qual[nrecordsize].archive_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_report_request_archive cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_archive_id,request->qual[
      idx].archive_id,
      bind_cnt)
      AND cr.report_request_archive_id > 0
      AND cr.logical_domain_id=userlogicaldomainid)
    ORDER BY cr.archived_dt_tm
    HEAD REPORT
     ncount = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncount+ 19))
     ENDIF
     reply->qual[ncount].archived_dt_tm = cnvtdatetime(cr.archived_dt_tm), reply->qual[ncount].
     archived_cnt = cr.archived_report_nbr, reply->qual[ncount].long_blob_id = cr.long_blob_id,
     reply->qual[ncount].archive_id = cr.report_request_archive_id
    FOOT REPORT
     stat = alterlist(reply->qual,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_ARCHIVE","LoadArchivedByIds",1,1)
   CALL log_message(build("Exit LoadArchivedByIds(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadarchivedbydaterange(null)
   CALL log_message("In LoadArchivedByDateRange()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE begin_date = q8 WITH noconstant(cnvtdatetime("01-JAN-1800")), protect
   DECLARE end_date = q8 WITH noconstant(cnvtdatetime(current_date_time)), protect
   DECLARE requestcount = i4 WITH noconstant(0), protect
   DECLARE qualcount = i4 WITH noconstant(0), protect
   DECLARE max_size = i4 WITH constant(65000), protect
   IF ((request->begin_dt_tm != null))
    SET begin_date = cnvtdatetime(request->begin_dt_tm)
   ENDIF
   IF ((request->end_dt_tm != null))
    SET end_date = cnvtdatetime(request->end_dt_tm)
   ENDIF
   SELECT INTO "nl:"
    FROM cr_report_request_archive cr
    PLAN (cr
     WHERE cr.max_request_dt_tm >= cnvtdatetime(begin_date)
      AND cr.min_request_dt_tm <= cnvtdatetime(end_date)
      AND ((cr.report_request_archive_id+ 0) > 0)
      AND cr.logical_domain_id=userlogicaldomainid)
    ORDER BY cr.archived_dt_tm
    HEAD REPORT
     ncount = 0, qualcount = 0, requestcount = 0
    DETAIL
     ncount += 1
     IF (ncount <= max_size)
      IF (ncount > size(reply->qual,5))
       stat = alterlist(reply->qual,(ncount+ 19))
      ENDIF
      reply->qual[ncount].archived_dt_tm = cnvtdatetime(cr.archived_dt_tm), reply->qual[ncount].
      archived_cnt = cr.archived_report_nbr, reply->qual[ncount].long_blob_id = cr.long_blob_id,
      reply->qual[ncount].archive_id = cr.report_request_archive_id
     ELSE
      requestcount = mod(ncount,max_size)
      IF (requestcount=1)
       qualcount += 1, stat = alterlist(reply->qual_more,qualcount)
      ENDIF
      IF (requestcount=0)
       requestcount = max_size
      ENDIF
      stat = alterlist(reply->qual_more[qualcount].request,requestcount), reply->qual_more[qualcount]
      .request[requestcount].archived_dt_tm = cnvtdatetime(cr.archived_dt_tm), reply->qual_more[
      qualcount].request[requestcount].archived_cnt = cr.archived_report_nbr,
      reply->qual_more[qualcount].request[requestcount].long_blob_id = cr.long_blob_id, reply->
      qual_more[qualcount].request[requestcount].archive_id = cr.report_request_archive_id
     ENDIF
    FOOT REPORT
     reply->count = ncount
     IF (ncount <= max_size)
      stat = alterlist(reply->qual,ncount)
     ELSE
      stat = alterlist(reply->qual_more,qualcount), stat = alterlist(reply->qual_more[qualcount].
       request,requestcount)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_TRIGGER_PARAM","LoadArchivedByDateRange",1,1)
   CALL log_message(build("Exit LoadArchivedByDateRange(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadzipfile(null)
   CALL log_message("In LoadZipFile()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(reply->qual,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(reply->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET reply->qual[i].long_blob_id = reply->qual[nrecordsize].long_blob_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     long_blob lb
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (lb
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),lb.long_blob_id,reply->qual[idx].
      long_blob_id,
      bind_cnt)
      AND lb.long_blob_id > 0.0
      AND lb.active_ind=1)
    HEAD REPORT
     donothing = 0
    HEAD lb.long_blob_id
     loc = locateval(idx2,1,nrecordsize,lb.long_blob_id,reply->qual[idx2].long_blob_id), outbuf =
     fillstring(4096," ")
    DETAIL
     IF (loc > 0)
      retlen = 1, offset = 0
      WHILE (retlen > 0)
        retlen = blobget(outbuf,offset,lb.long_blob)
        IF (retlen=size(outbuf))
         reply->qual[loc].zip_file = notrim(concat(reply->qual[loc].zip_file,outbuf))
        ELSEIF (retlen > 0)
         reply->qual[loc].zip_file = notrim(concat(reply->qual[loc].zip_file,substring(1,retlen,
            outbuf)))
        ENDIF
        offset += retlen
      ENDWHILE
     ENDIF
    FOOT  lb.long_blob_id
     donothing = 0
    FOOT REPORT
     stat = alterlist(reply->qual,nrecordsize)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LONG_BLOB","LoadZipFile",1,1)
   CALL log_message(build("Exit LoadZipFile(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getcurrentuserslogicaldomain(logicaldomainid=f8(ref)) =i2)
   FREE RECORD logical_domain_reply
   RECORD logical_domain_reply(
     1 logical_domain_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE cr_get_logical_domain  WITH replace(reply,logical_domain_reply)
   IF ((logical_domain_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "cr_get_archived_requests"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors occurred in cr_get_logical_domain!  Exiting Job."
    SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
    SET logicaldomainid = 0
    RETURN(false)
   ENDIF
   SET logicaldomainid = logical_domain_reply->logical_domain_id
   RETURN(true)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cr_get_archived_requests",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
