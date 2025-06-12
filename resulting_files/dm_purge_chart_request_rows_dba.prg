CREATE PROGRAM dm_purge_chart_request_rows:dba
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
 SET log_program_name = "DM_PURGE_CHART_REQUEST_ROWS"
 DECLARE xml_version_encoding = vc WITH constant("<?xml version='1.0' encoding='ISO-8859-1'?>"),
 protect
 DECLARE export_successful = i4 WITH constant(1), protect
 DECLARE export_failed = i4 WITH constant(- (1)), protect
 DECLARE double_quote_char = c1 WITH constant('"'), protect
 DECLARE sencodedstr = vc WITH noconstant(""), protect
 SUBROUTINE (createelementstring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build(createstartelementstring(stag),scontent,createendelementstring(stag)))
 END ;Subroutine
 SUBROUTINE (createstartelementstring(stag=vc(val)) =vc)
   RETURN(build("<",stag,">"))
 END ;Subroutine
 SUBROUTINE (createendelementstring(stag=vc(val)) =vc)
   RETURN(build("</",stag,">"))
 END ;Subroutine
 SUBROUTINE (createattributestring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build2(" ",stag,"=",double_quote_char,scontent,
    double_quote_char))
 END ;Subroutine
 SUBROUTINE (createattributestringbystring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build2(" ",stag,"=",double_quote_char,findandreplacespecialcharacters(scontent),
    double_quote_char))
 END ;Subroutine
 SUBROUTINE (createcommentstring(scomment=vc(val)) =vc)
   RETURN(build2("<!--",scomment,"-->"))
 END ;Subroutine
 SUBROUTINE (findandreplacespecialcharacters(str=vc(val)) =vc)
   SET sencodedstr = replace(str,"&","&amp;",0)
   SET sencodedstr = replace(sencodedstr,"<","&lt;",0)
   SET sencodedstr = replace(sencodedstr,">","&gt;",0)
   SET sencodedstr = replace(sencodedstr,char(34),"&quot;",0)
   SET sencodedstr = replace(sencodedstr,char(39),"&apos;",0)
   RETURN(sencodedstr)
 END ;Subroutine
 SUBROUTINE (exportfilebyblobid(longblobid=f8(val),tosourcdir=vc(val),filename=vc(val)) =i4)
   CALL log_message("In ExportFileByBlobId()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SET modify maxvarlen 99999999
   DECLARE blob_string = vc WITH noconstant(" "), protect
   DECLARE blob_size = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    moreblob = textlen(lb.long_blob)
    FROM long_blob lb
    PLAN (lb
     WHERE lb.long_blob_id=longblobid)
    HEAD REPORT
     outbuf = fillstring(32767," ")
    DETAIL
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,lb.long_blob), blob_size += retlen, offset += retlen,
       blob_string = notrim(concat(notrim(blob_string),notrim(outbuf)))
     ENDWHILE
     IF (blob_size > lb.blob_length)
      CALL echo(build("adjusted size from",blob_size," to: ",lb.blob_length)), blob_size = lb
      .blob_length
     ENDIF
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   CALL error_and_zero_check(curqual,"LONG_BLOB","EXPORTFILEBYBLOBID",1,1)
   FREE RECORD temp_request
   RECORD temp_request(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET temp_request->source_dir = tosourcdir
   SET temp_request->source_filename = filename
   SET temp_request->isblob = "1"
   SET temp_request->document_size = blob_size
   SET temp_request->document = blob_string
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 info_line[*]
       2 new_line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE eks_put_source  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   CALL log_message(build("Exit ExportFileByBlobId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   IF ((temp_reply->status_data.status != "S"))
    RETURN(export_failed)
   ELSE
    RETURN(export_successful)
   ENDIF
 END ;Subroutine
 DECLARE i18nhandle = i4 WITH noconstant(0), protect
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 DECLARE addreadergrouptolist(null) = null
 DECLARE getreadergroupinformation(null) = null
 DECLARE getinactivedistributioninformation(null) = null
 DECLARE getactivedistributioninformation(null) = null
 DECLARE preparetemprequests(null) = null
 DECLARE gettokeninfoxml(null) = vc
 DECLARE insertactivedistributioninfoxml(null) = null
 DECLARE insertinactivedistributioninfoxml(null) = null
 DECLARE insertreadergroupinfoxml(null) = null
 DECLARE gettokeninformation(null) = null
 DECLARE getnextchartrecseq(null) = f8
 DECLARE getnextlongdataseq(null) = f8
 DECLARE initinforec(null) = null
 DECLARE insertstartoffile(null) = null
 DECLARE insertendoffile(null) = null
 DECLARE writerequeststofile(null) = null
 DECLARE bind_cnt = i4 WITH constant(100), protect
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE report_request_element_str = vc WITH constant("reportRequest"), protect
 DECLARE chart_request_element_str = vc WITH constant("chartRequest"), protect
 DECLARE report_request_archive_str = vc WITH constant("archivedRequests"), protect
 DECLARE chart_request_archive_str = vc WITH constant("archivedCharts"), protect
 DECLARE updt_day_lookback = i4 WITH constant(15), protect
 DECLARE purge_flag_token_found = i2 WITH constant(1), protect
 DECLARE cr_purge_job_template_nbr = i4 WITH constant(10049), protect
 DECLARE rr_purge_job_template_nbr = i4 WITH constant(10063), protect
 DECLARE do_not_purge_flag = i2 WITH constant(3), protect
 DECLARE zip_successful = i4 WITH constant(1), protect
 DECLARE remove_successful = i4 WITH constant(1), protect
 DECLARE absolute_lookback_date_opt = i4 WITH constant(0), protect
 DECLARE report_request_table_name = vc WITH constant("CR_REPORT_REQUEST"), protect
 DECLARE chart_request_table_name = vc WITH constant("CHART_REQUEST"), protect
 DECLARE report_request_archive_table_name = vc WITH constant("CR_REPORT_REQUEST_ARCHIVE"), protect
 DECLARE chart_request_archive_table_name = vc WITH constant("CHART_REQUEST_ARCHIVE"), protect
 DECLARE person_scope = i2 WITH constant(1), protect
 DECLARE encoutner_scope = i2 WITH constant(2), protect
 DECLARE order_scope = i2 WITH constant(3), protect
 DECLARE accession_scope = i2 WITH constant(4), protect
 DECLARE crossencntr_scope = i2 WITH constant(5), protect
 DECLARE event_scope = i2 WITH constant(6), protect
 DECLARE distribution_request_type = i4 WITH constant(4), protect
 DECLARE mrp_request_type = i4 WITH constant(8), protect
 DECLARE look_back_days_adhoc_exp = f8 WITH noconstant(0.0), protect
 DECLARE look_back_days_dist = f8 WITH noconstant(0.0), protect
 DECLARE purge_adhoc_exp_ind = i2 WITH noconstant(0), protect
 DECLARE purge_dist_ind = i2 WITH noconstant(0), protect
 DECLARE getreadergroupinformationerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR1",
   "Retrieving reader group information failed."))
 DECLARE getinactivedistributioninformationerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "UTERR2","Retrieving information for inactive Distributions failed."))
 DECLARE getactivedistributioninformationerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "UTERR3","Retrieving information for active Distributions failed."))
 DECLARE writerequeststofileerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR4",
   "Writing charts to file failed."))
 DECLARE inserttolongbloberr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR5",
   "Insertion of zip file into long_blob failed."))
 DECLARE inserttochartarchiveerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR6",
   "Insertion of archived row into chart_request_archive failed."))
 DECLARE rundclerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR7",
   "The command line request failed."))
 DECLARE getnextchartrecseqerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR8",
   "Retrieval of the next ReportRequest sequence failed."))
 DECLARE getnextlongdataseqerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR9",
   "Retrieval of the next LongBlob sequence failed."))
 DECLARE eksgetsourceerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR10",
   "Retrieval of the zip file for storage failed."))
 DECLARE inserttoreportrequestarchiveerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"UTERR11",
   "Insertion of archived row into report_request_archive failed."))
 DECLARE request_cutoff_exceeded = vc WITH constant(uar_i18ngetmessage(i18nhandle,"COM1",
   "Request cutoff exceeded."))
 DECLARE chart_cutoff_exceeded = vc WITH constant(uar_i18ngetmessage(i18nhandle,"COM2",
   "Chart cutoff exceeded."))
 DECLARE request_archive_id = f8 WITH noconstant(0.0), protect
 DECLARE dont_remove_files_ind = i2 WITH noconstant(0), protect
 DECLARE minrequestdatetime = dq8 WITH noconstant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE maxrequestdatetime = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800")), protect
 FREE RECORD info_rec
 RECORD info_rec(
   1 cer_temp = vc
   1 ccl_cer_temp = vc
   1 disk_cer_temp = vc
   1 xml_file_name = vc
   1 zip_file_name = vc
   1 next_request_archive_id = f8
   1 next_request_archive_id_str = vc
   1 lonb_blob_id = f8
   1 orig_report_count = i4
   1 purge_flag_token_found = i2
   1 purge_flag = i2
 )
 FREE RECORD token_info
 RECORD token_info(
   1 qual[*]
     2 token = vc
     2 val = vc
 )
 FREE RECORD debug_requests
 RECORD debug_requests(
   1 qual[*]
     2 request_id = f8
 )
 FREE RECORD temp_requests
 RECORD temp_requests(
   1 cnt = i4
   1 qual[*]
     2 request_id = f8
     2 xml_string = vc
 )
 FREE RECORD reader_groups
 RECORD reader_groups(
   1 rdr_cnt = i4
   1 qual[*]
     2 cutoff_dt_tm = dq8
     2 reader_group = vc
 )
 FREE RECORD inactive_temp_dist
 RECORD inactive_temp_dist(
   1 dist_cnt = i4
   1 qual[*]
     2 distribution_id = f8
     2 dist_run_type_cd = f8
     2 cutoff_dt_tm = dq8
     2 reader_group = vc
 )
 FREE RECORD active_temp_dist
 RECORD active_temp_dist(
   1 dist_cnt = i4
   1 qual[*]
     2 distribution_id = f8
     2 dist_run_type_cd = f8
     2 cutoff_dt_tm = dq8
     2 reader_group = vc
 )
 SUBROUTINE getreadergroupinformation(null)
   CALL log_message("In GetReaderGroupInformation()",log_level_debug)
   SET reply->err_msg = getreadergroupinformationerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE rdr_idx = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    cd.reader_group
    FROM chart_distribution cd
    WHERE trim(cd.reader_group) > ""
    DETAIL
     CALL addreadergrouptolist(null)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETREADERGROUPINFORMATION",1,0)
   CALL log_message(build("Exit GetReaderGroupInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addreadergrouptolist(null)
   SET x = size(reader_groups->qual,5)
   SET idx = 0
   SET date_time = cnvtdatetime(0,0)
   SET rdr_idx = locateval(idx,1,rdr_idx,cd.reader_group,reader_groups->qual[idx].reader_group)
   IF (rdr_idx=0)
    SET rdr_idx = (x+ 1)
    SET stat = alterlist(reader_groups->qual,rdr_idx)
    SET reader_groups->qual[rdr_idx].reader_group = cd.reader_group
    IF (cd.active_ind=0)
     SET reader_groups->qual[rdr_idx].cutoff_dt_tm = cnvtdatetime(current_date_time)
    ELSE
     IF (cd.absolute_lookback_ind=absolute_lookback_date_opt)
      SET reader_groups->qual[rdr_idx].cutoff_dt_tm = getmaxcutoffdatetime(cnvtdatetime(cd
        .absolute_qualification_dt_tm))
     ELSE
      SET reader_groups->qual[rdr_idx].cutoff_dt_tm = getmaxcutoffdatetime(cnvtdatetime(datetimeadd(
         current_date_time,- (cd.absolute_qualification_days))))
     ENDIF
    ENDIF
    SET reader_groups->rdr_cnt = rdr_idx
   ELSE
    IF (cd.active_ind=0)
     SET date_time = cnvtdatetime(current_date_time)
    ELSE
     IF (cd.absolute_lookback_ind=absolute_lookback_date_opt)
      SET date_time = getmaxcutoffdatetime(cnvtdatetime(cd.absolute_qualification_dt_tm))
     ELSE
      SET date_time = getmaxcutoffdatetime(cnvtdatetime(datetimeadd(current_date_time,- (cd
         .absolute_qualification_days))))
     ENDIF
    ENDIF
    IF (datetimediff(date_time,reader_groups->qual[rdr_idx].cutoff_dt_tm) < 0)
     SET reader_groups->qual[rdr_idx].cutoff_dt_tm = cnvtdatetime(date_time)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getinactivedistributioninformation(null)
   CALL log_message("In GetInactiveDistributionInformation()",log_level_debug)
   SET reply->err_msg = getinactivedistributioninformationerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM chart_distribution cd
    WHERE cd.active_ind=0
     AND cd.distribution_id > 0
     AND cd.updt_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (updt_day_lookback)))
    HEAD REPORT
     x = size(inactive_temp_dist->qual,5)
    DETAIL
     x += 1
     IF (x > size(inactive_temp_dist->qual,5))
      stat = alterlist(inactive_temp_dist->qual,(x+ 9))
     ENDIF
     inactive_temp_dist->qual[x].distribution_id = cd.distribution_id, inactive_temp_dist->qual[x].
     reader_group = cd.reader_group, inactive_temp_dist->qual[x].cutoff_dt_tm =
     IF (trim(cd.reader_group) > "") getreadergroupdatetime(cd.reader_group)
     ELSE cnvtdatetime(current_date_time)
     ENDIF
    FOOT REPORT
     stat = alterlist(inactive_temp_dist->qual,x), inactive_temp_dist->dist_cnt = x
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETINACTIVEDISTRIBUTIONINFORMATION",1,0)
   CALL log_message(build("Exit GetInactiveDistributionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getactivedistributioninformation(null)
   CALL log_message("In GetActiveDistributionInformation()",log_level_debug)
   SET reply->err_msg = getactivedistributioninformationerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM chart_distribution cd
    PLAN (cd
     WHERE cd.active_ind=1
      AND cd.distribution_id > 0)
    HEAD REPORT
     x = 0
    DETAIL
     x += 1
     IF (x > size(active_temp_dist->qual,5))
      stat = alterlist(active_temp_dist->qual,(x+ 9))
     ENDIF
     active_temp_dist->qual[x].distribution_id = cd.distribution_id, active_temp_dist->qual[x].
     reader_group = cd.reader_group, active_temp_dist->qual[x].cutoff_dt_tm =
     IF (trim(cd.reader_group) > "") getreadergroupdatetime(cd.reader_group)
     ELSEIF (cd.absolute_lookback_ind=absolute_lookback_date_opt) getmaxcutoffdatetime(cnvtdatetime(
        cd.absolute_qualification_dt_tm))
     ELSE getmaxcutoffdatetime(cnvtdatetime(datetimeadd(current_date_time,- (cd
         .absolute_qualification_days))))
     ENDIF
    FOOT REPORT
     stat = alterlist(active_temp_dist->qual,x), active_temp_dist->dist_cnt = x
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETACTIVEDISTRIBUTIONINFORMATION",1,0)
   CALL log_message(build("Exit GetActiveDistributionInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE preparetemprequests(null)
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE tempstring = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(temp_requests->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET temp_requests->qual[i].request_id = temp_requests->qual[nrecordsize].request_id
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE gettokeninfoxml(null)
   CALL log_message("In GetTokenInfoXML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE sreturnval = vc WITH noconstant(""), private
   DECLARE nrecsize = i4 WITH noconstant(size(token_info->qual,5)), private
   IF (nrecsize > 0)
    SET sreturnval = "<tokenInfo "
    FOR (x = 1 TO nrecsize)
      SET sreturnval = build2(sreturnval,createattributestring(token_info->qual[x].token,token_info->
        qual[x].val))
    ENDFOR
    SET sreturnval = build2(sreturnval,"></tokenInfo>")
    IF (size(debug_requests->qual,5) > 0)
     SET sreturnval = build2(sreturnval,createstartelementstring("debugRequests"))
     FOR (x = 1 TO size(debug_requests->qual,5))
       SET sreturnval = build2(sreturnval,createelementstring("id",debug_requests->qual[x].request_id
         ))
     ENDFOR
     SET sreturnval = build2(sreturnval,createendelementstring("debugRequests"))
    ENDIF
   ENDIF
   CALL log_message(build("Exit GetTokenInfoXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(sreturnval)
 END ;Subroutine
 SUBROUTINE insertactivedistributioninfoxml(null)
   CALL log_message("In InsertActiveDistributionInfoXML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   IF ((active_temp_dist->dist_cnt > 0))
    SELECT INTO value(ccl_full_file_and_folder)
     d.seq
     FROM (dummyt d  WITH seq = value(active_temp_dist->dist_cnt))
     HEAD REPORT
      row + 1, col + 1,
      CALL print(createstartelementstring("actDistInfo"))
     DETAIL
      row + 1, col + 1,
      CALL print(build("<distInfo ",createattributestring("id",trim(cnvtstring(active_temp_dist->
          qual[d.seq].distribution_id))))),
      col + 1,
      CALL print(createattributestring("cutoffDtTm",trim(format(cnvtdatetimeutc(active_temp_dist->
          qual[d.seq].cutoff_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
      IF (trim(active_temp_dist->qual[d.seq].reader_group) > "")
       col + 1,
       CALL print(createattributestring("rdrGrp",active_temp_dist->qual[d.seq].reader_group))
      ENDIF
      col + 1,
      CALL print(">"), col + 1,
      CALL print(createendelementstring("distInfo"))
      IF (d.seq < value(active_temp_dist->dist_cnt))
       row + 1
      ENDIF
     FOOT REPORT
      col + 1,
      CALL print(createendelementstring("actDistInfo"))
     WITH format = variable, maxcol = 2000, noformfeed,
      maxrow = 1, append
    ;end select
    CALL error_and_zero_check(curqual,"DUMMY","INSERTACTIVEDISTRIBUTIONINFOXML",1,0)
   ENDIF
   CALL log_message(build("Exit InsertActiveDistributionInfoXML(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE insertinactivedistributioninfoxml(null)
   CALL log_message("In InsertInactiveDistributionInfoXML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   IF ((inactive_temp_dist->dist_cnt > 0))
    SELECT INTO value(ccl_full_file_and_folder)
     d.seq
     FROM (dummyt d  WITH seq = value(inactive_temp_dist->dist_cnt))
     HEAD REPORT
      row + 1, col + 1,
      CALL print(createstartelementstring("inactDistInfo"))
     DETAIL
      row + 1, col + 1,
      CALL print(build("<distInfo ",createattributestring("id",trim(cnvtstring(inactive_temp_dist->
          qual[d.seq].distribution_id))))),
      col + 1,
      CALL print(createattributestring("cutoffDtTm",trim(format(cnvtdatetimeutc(inactive_temp_dist->
          qual[d.seq].cutoff_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
      IF (trim(inactive_temp_dist->qual[d.seq].reader_group) > "")
       col + 1,
       CALL print(createattributestring("rdrGrp",inactive_temp_dist->qual[d.seq].reader_group))
      ENDIF
      col + 1,
      CALL print(">"), col + 1,
      CALL print(createendelementstring("distInfo"))
      IF (d.seq < value(inactive_temp_dist->dist_cnt))
       row + 1
      ENDIF
     FOOT REPORT
      col + 1,
      CALL print(createendelementstring("inactDistInfo"))
     WITH format = variable, maxcol = 2000, noformfeed,
      maxrow = 1, append
    ;end select
    CALL error_and_zero_check(curqual,"DUMMY","INSERTINACTIVEDISTRIBUTIONINFOXML",1,0)
   ENDIF
   CALL log_message(build("Exit InsertInactiveDistributionInfoXML(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE insertreadergroupinfoxml(null)
   CALL log_message("In InsertReaderGroupInfoXML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   IF ((reader_groups->rdr_cnt > 0))
    SELECT INTO value(ccl_full_file_and_folder)
     d.seq
     FROM (dummyt d  WITH seq = value(reader_groups->rdr_cnt))
     HEAD REPORT
      row + 1, col + 1,
      CALL print(createstartelementstring("rdrGrpList"))
     DETAIL
      row + 1, col + 1,
      CALL print(build("<rdrInfo ",createattributestring("rdrGrp",trim(reader_groups->qual[d.seq].
         reader_group)))),
      col + 1,
      CALL print(createattributestring("cutoffDtTm",trim(format(cnvtdatetimeutc(reader_groups->qual[d
          .seq].cutoff_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q")))), col + 1,
      CALL print(">"), col + 1,
      CALL print(createendelementstring("rdrInfo"))
      IF (d.seq < value(reader_groups->rdr_cnt))
       row + 1
      ENDIF
     FOOT REPORT
      col + 1,
      CALL print(createendelementstring("rdrGrpList"))
     WITH format = variable, maxcol = 2000, noformfeed,
      maxrow = 1, append
    ;end select
    CALL error_and_zero_check(curqual,"DUMMY","INSERTREADERGROUPINFOXML",1,0)
   ENDIF
   CALL log_message(build("Exit InsertReaderGroupInfoXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gettokeninformation(null)
   CALL log_message("In GetTokenInformation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE tok_ndx = i4 WITH noconstant(0), protect
   DECLARE debugchartcount = i4 WITH noconstant(0), protect
   SET info_rec->purge_flag_token_found = purge_flag_token_found
   SET info_rec->purge_flag = request->purge_flag
   CALL addtokeninfotorec("PURGE_FLAG",cnvtstring(request->purge_flag))
   FOR (tok_ndx = 1 TO size(request->tokens,5))
    CASE (trim(request->tokens[tok_ndx].token_str))
     OF "PURGEDISTIND":
      SET purge_dist_ind = cnvtint(request->tokens[tok_ndx].value)
     OF "LOOKBACKDAYSADHOCEXP":
      SET look_back_days_adhoc_exp = cnvtreal(request->tokens[tok_ndx].value)
     OF "PURGEADHOCEXPIND":
      SET purge_adhoc_exp_ind = cnvtint(request->tokens[tok_ndx].value)
     OF "LOOKBACKDAYSDIST":
      SET look_back_days_dist = cnvtreal(request->tokens[tok_ndx].value)
     OF "REPORTREQUESTID":
      SET debugchartcount += 1
      SET stat = alterlist(debug_requests->qual,debugchartcount)
      SET debug_requests->qual[debugchartcount].request_id = cnvtreal(request->tokens[tok_ndx].value)
     OF "CHARTREQUESTID":
      SET debugchartcount += 1
      SET stat = alterlist(debug_requests->qual,debugchartcount)
      SET debug_requests->qual[debugchartcount].request_id = cnvtreal(request->tokens[tok_ndx].value)
     OF "DONTREMOVEFILES":
      SET dont_remove_files_ind = cnvtint(request->tokens[tok_ndx].value)
     ELSE
      CALL log_message(build("Unrecognized token: ",request->tokens[tok_ndx].token_str," value: ",
        request->tokens[tok_ndx].value),log_level_debug)
    ENDCASE
    IF (trim(request->tokens[tok_ndx].token_str) != "REPORTREQUESTID"
     AND trim(request->tokens[tok_ndx].token_str) != "CHARTREQUESTID"
     AND trim(request->tokens[tok_ndx].token_str) > ""
     AND trim(request->tokens[tok_ndx].value) > "")
     CALL addtokeninfotorec(request->tokens[tok_ndx].token_str,request->tokens[tok_ndx].value)
    ENDIF
   ENDFOR
   IF (debugchartcount > 0)
    CALL log_message("Processing debug requests",log_level_debug)
   ELSEIF (look_back_days_adhoc_exp < 30
    AND purge_adhoc_exp_ind=1)
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS","%1 %2 %3","sss",
     "You must look back at least 30 days for adhoc and expedite requests.  You entered ",
     nullterm(trim(cnvtstring(look_back_days_adhoc_exp),3))," days or did not enter any value.")
    CALL log_message(reply->err_msg,log_level_debug)
    GO TO exit_script
   ELSEIF (look_back_days_dist < 90
    AND purge_dist_ind=1)
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS2","%1 %2 %3","sss",
     "You must look back at least 90 days for distribution requests.  You entered ",
     nullterm(trim(cnvtstring(look_back_days_dist),3))," days or did not enter any value.")
    CALL log_message(reply->err_msg,log_level_debug)
    GO TO exit_script
   ENDIF
   CALL log_message(build("Exit GetTokenInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getnextchartrecseq(null)
   CALL log_message("In GetNextChartRecSeq()",log_level_debug)
   SET reply->err_msg = getnextchartrecseqerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    nextseqnum = seq(chart_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     return_val = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTCHARTRECSEQ",1,1)
   CALL log_message(build("Exit GetNextChartRecSeq(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE getnextlongdataseq(null)
   CALL log_message("In GetNextLongDataSeq()",log_level_debug)
   SET reply->err_msg = getnextlongdataseqerr
   DECLARE returnval = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTLONGDATASEQ",1,1)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE initinforec(null)
   CALL log_message("In InitInfoRec()",log_level_debug)
   DECLARE vms_cer_temp = vc WITH constant("cer_temp:"), private
   DECLARE aix_cer_temp = vc WITH constant("$cer_temp/"), private
   DECLARE cer_temp = vc WITH constant("cer_temp:"), private
   DECLARE file_name_str = vc WITH constant("aud"), private
   DECLARE purge_job_template_nbr = i4 WITH noconstant(0), private
   SET info_rec->ccl_cer_temp = cer_temp
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET info_rec->disk_cer_temp = vms_cer_temp
   ELSE
    SET info_rec->disk_cer_temp = aix_cer_temp
   ENDIF
   SET info_rec->next_request_archive_id = getnextchartrecseq(null)
   SET info_rec->next_request_archive_id_str = format(info_rec->next_request_archive_id,
    "#####################;P0")
   SET info_rec->xml_file_name = build(file_name_str,format(cnvtdatetime(current_date_time),
     "#################;P0"),".xml")
   SET info_rec->zip_file_name = build(file_name_str,info_rec->next_request_archive_id_str,".zip")
   IF ((info_rec->purge_flag_token_found != purge_flag_token_found))
    IF ((reply->table_name=chart_request_table_name))
     SET purge_job_template_nbr = cr_purge_job_template_nbr
    ELSE
     SET purge_job_template_nbr = rr_purge_job_template_nbr
    ENDIF
    SELECT INTO "nl:"
     FROM dm_purge_job dm
     PLAN (dm
      WHERE dm.active_flag > 0
       AND dm.template_nbr=purge_job_template_nbr)
     DETAIL
      info_rec->purge_flag = dm.purge_flag
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"DM_PURGE_JOB","INITINFOREC",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getmaxcutoffdatetime(datetime=q8(val)) =dq8)
   SET tempdatetime = cnvtdatetime(datetimeadd(current_date_time,- (look_back_days_dist)))
   SET returndatetime = cnvtdatetime(datetime)
   IF (datetimediff(datetime,tempdatetime) < 0)
    SET returndatetime = datetime
   ELSE
    SET returndatetime = tempdatetime
   ENDIF
   RETURN(returndatetime)
 END ;Subroutine
 SUBROUTINE (getreadergroupdatetime(sreadergroup=vc(val)) =dq8)
   SET reader_idx = 0
   SET rdr_idx = 0
   SET rdr_idx = locateval(reader_idx,1,size(reader_groups->qual,5),sreadergroup,reader_groups->qual[
    reader_idx].reader_group)
   RETURN(reader_groups->qual[rdr_idx].cutoff_dt_tm)
 END ;Subroutine
 SUBROUTINE (getinactivedistributiondatetime(ddistributionid=f8(val)) =dq8)
   SET inactive_idx = 0
   SET dist_idx = 0
   SET dist_idx = locateval(inactive_idx,1,size(inactive_temp_dist->qual,5),ddistributionid,
    inactive_temp_dist->qual[inactive_idx].distribution_id)
   RETURN(inactive_temp_dist->qual[dist_idx].cutoff_dt_tm)
 END ;Subroutine
 SUBROUTINE (getactivedistributiondatetime(ddistributionid=f8(val)) =dq8)
   SET active_idx = 0
   SET dist_idx = 0
   SET dist_idx = locateval(active_idx,1,size(active_temp_dist->qual,5),ddistributionid,
    active_temp_dist->qual[active_idx].distribution_id)
   RETURN(active_temp_dist->qual[dist_idx].cutoff_dt_tm)
 END ;Subroutine
 SUBROUTINE (run_dcl(dclcommand=vc(val)) =i4)
   CALL log_message("In Run_DCL()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE dclflag = i4 WITH noconstant(0)
   DECLARE dcllen = i4 WITH constant(size(dclcommand)), protect
   DECLARE returnval = i4 WITH noconstant(0), protect
   CALL log_message(dclcommand,log_level_debug)
   SET returnval = dcl(dclcommand,dcllen,dclflag)
   CALL log_message(build("dclFlag:   ",dclflag),log_level_debug)
   CALL log_message(build("returnVal: ",returnval),log_level_debug)
   IF (dclflag=0
    AND cursys="AIX"
    AND returnval > 255)
    SET returnval /= 256
   ENDIF
   CALL log_message(build("Exit Run_DCL(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE writerequeststofile(null)
   CALL log_message("In WriteRequestsToFile()",log_level_debug)
   SET reply->err_msg = writerequeststofileerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   DECLARE archive_table_name = vc WITH noconstant(""), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE zip_command = vc WITH noconstant(""), protect
   DECLARE remove_command = vc WITH noconstant(""), protect
   DECLARE grparchive = vc WITH noconstant(""), protect
   DECLARE requestelement = vc WITH noconstant(""), protect
   IF ((reply->table_name=chart_request_table_name))
    SET grparchive = chart_request_archive_str
    SET requestelement = chart_request_element_str
    SET archive_table_name = chart_request_archive_table_name
   ELSE
    SET grparchive = report_request_archive_str
    SET requestelement = report_request_element_str
    SET archive_table_name = report_request_archive_table_name
   ENDIF
   CALL insertstartoffile(null)
   CALL insertactivedistributioninfoxml(null)
   CALL insertinactivedistributioninfoxml(null)
   CALL insertreadergroupinfoxml(null)
   SELECT INTO value(ccl_full_file_and_folder)
    d.seq
    FROM (dummyt d  WITH seq = value(temp_requests->cnt))
    HEAD REPORT
     row + 1, col + 1,
     CALL print(createstartelementstring(grparchive))
    DETAIL
     row + 1, col + 1,
     CALL print(trim(temp_requests->qual[d.seq].xml_string)),
     col + 1,
     CALL print(createendelementstring(requestelement))
     IF (d.seq < value(temp_requests->cnt))
      row + 1
     ENDIF
    FOOT REPORT
     col + 1,
     CALL print(createendelementstring(grparchive))
    WITH format = variable, maxcol = 32000, noformfeed,
     maxrow = 1, append
   ;end select
   CALL error_and_zero_check(curqual,"DUMMY","WRITEREQUESTSTOFILE",1,0)
   CALL insertendoffile(null)
   SET zip_command = concat("zip -9jm ",info_rec->disk_cer_temp,info_rec->zip_file_name," ",info_rec
    ->disk_cer_temp,
    info_rec->xml_file_name)
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET zip_command = concat("mcr cer_exe:",zip_command)
   ELSE
    SET zip_command = concat("$cer_exe/",zip_command)
   ENDIF
   IF (run_dcl(zip_command) > zip_successful)
    SET reply->err_msg = concat(rundclerr," <",zip_command,">")
    GO TO exit_script
   ENDIF
   FREE RECORD temp_request
   RECORD temp_request(
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 info_line[*]
       2 new_line = vc
     1 data_blob = gvc
     1 data_blob_size = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET temp_request->basblob = 1
   SET temp_request->module_dir = info_rec->ccl_cer_temp
   SET temp_request->module_name = info_rec->zip_file_name
   EXECUTE eks_get_source  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   IF ((temp_reply->status_data.status != "S"))
    SET reply->err_msg = eksgetsourceerr
    SET reply->status_data.subeventstatus[1].operationname = temp_reply->status_data.subeventstatus[1
    ].operationname
    SET reply->status_data.subeventstatus[1].operationstatus = temp_reply->status_data.
    subeventstatus[1].operationstatus
    SET reply->status_data.subeventstatus[1].targetobjectname = temp_reply->status_data.
    subeventstatus[1].targetobjectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = temp_reply->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
   IF ((info_rec->purge_flag != do_not_purge_flag))
    SET info_rec->lonb_blob_id = getnextlongdataseq(null)
    SET reply->err_msg = inserttolongbloberr
    INSERT  FROM long_blob lb
     SET lb.active_ind = 1, lb.active_status_cd = reqdata->active_status_cd, lb.blob_length =
      temp_reply->data_blob_size,
      lb.long_blob = temp_reply->data_blob, lb.long_blob_id = info_rec->lonb_blob_id, lb
      .parent_entity_name = archive_table_name,
      lb.parent_entity_id = info_rec->next_request_archive_id, lb.updt_id = reqinfo->updt_id, lb
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      lb.updt_cnt = 1, lb.updt_task = reqinfo->updt_task, lb.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"INSERT_LONG_BLOB","WRITEREQUESTSTOFILE",1,1)
   ENDIF
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET remove_command = "del"
   ELSE
    SET remove_command = "rm"
   ENDIF
   SET remove_command = concat(remove_command," ",info_rec->disk_cer_temp,info_rec->zip_file_name)
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET remove_command = concat(remove_command,";*")
   ENDIF
   IF (dont_remove_files_ind != 1)
    IF (run_dcl(remove_command) > remove_successful)
     SET reply->err_msg = concat(rundclerr," <",remove_command,">")
     GO TO exit_script
    ENDIF
   ELSE
    CALL log_message(build("Remove temporary zip file command: ",remove_command),log_level_debug)
   ENDIF
   IF ((info_rec->purge_flag != do_not_purge_flag))
    IF ((reply->table_name=chart_request_table_name))
     SET reply->err_msg = inserttochartarchiveerr
     INSERT  FROM chart_request_archive cra
      SET cra.archive_chart_nbr = temp_requests->cnt, cra.archive_dt_tm = cnvtdatetime(
        current_date_time), cra.chart_request_archive_id = info_rec->next_request_archive_id,
       cra.long_blob_id = info_rec->lonb_blob_id, cra.updt_id = reqinfo->updt_id, cra.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       cra.updt_cnt = 1, cra.updt_task = reqinfo->updt_task, cra.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"INSERT_CHART_REQUEST_ARCHIVE","WRITEREQUESTSTOFILE",1,1)
    ELSE
     SET reply->err_msg = inserttoreportrequestarchiveerr
     INSERT  FROM cr_report_request_archive rra
      SET rra.archived_report_nbr = temp_requests->cnt, rra.archived_dt_tm = cnvtdatetime(
        current_date_time), rra.report_request_archive_id = info_rec->next_request_archive_id,
       rra.long_blob_id = info_rec->lonb_blob_id, rra.min_request_dt_tm = cnvtdatetime(
        minrequestdatetime), rra.max_request_dt_tm = cnvtdatetime(maxrequestdatetime),
       rra.updt_id = reqinfo->updt_id, rra.updt_dt_tm = cnvtdatetime(curdate,curtime), rra.updt_cnt
        = 1,
       rra.updt_task = reqinfo->updt_task, rra.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"INSERT_REPORT_REQUEST_ARCHIVE","WRITEREQUESTSTOFILE",1,1)
    ENDIF
   ENDIF
   CALL log_message(build("Exit WriteRequestsToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE insertstartoffile(null)
   CALL log_message("In InsertStartOfFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   DECLARE tokeninfoxml = vc WITH noconstant(""), protect
   SET tokeninfoxml = gettokeninfoxml(null)
   SELECT INTO value(ccl_full_file_and_folder)
    d.seq
    FROM (dummyt d  WITH seq = value(1))
    HEAD REPORT
     col 0,
     CALL print(xml_version_encoding), row + 1,
     col + 1,
     CALL print(createstartelementstring("archiveProcess")), row + 1,
     col + 1,
     CALL print(tokeninfoxml)
    DETAIL
     row + 1
    FOOT REPORT
     donothing = 0
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   CALL error_and_zero_check(curqual,"DUMMY","INSERTSTARTOFFILE",1,0)
   CALL log_message(build("Exit InsertStartOfFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE insertendoffile(null)
   CALL log_message("In InsertEndOfFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ccl_full_file_and_folder = vc WITH constant(build(info_rec->ccl_cer_temp,info_rec->
     xml_file_name)), private
   SELECT INTO value(ccl_full_file_and_folder)
    d.seq
    FROM (dummyt d  WITH seq = value(1))
    HEAD REPORT
     donothing = 0
    DETAIL
     row + 1
    FOOT REPORT
     col + 1,
     CALL print(createelementstring("requestCount",temp_requests->cnt)), col + 1,
     CALL print(createelementstring("procTime",cnvtstring(datetimediff(cnvtdatetime(sysdate),
        current_date_time,5)))), col + 1,
     CALL print(createelementstring("runDtTm",trim(format(cnvtdatetimeutc(current_date_time,3),
        "YYYY-MM-DDTHH:MM:SSZ;3;Q")))),
     col + 1,
     CALL print(createelementstring("curnode",trim(curnode))), col + 1,
     CALL print(createelementstring("currdbsys",trim(currdbsys)))
     IF ((temp_requests->cnt >= max_qual_requests))
      col + 1,
      CALL print(createcommentstring(request_cutoff_exceeded))
     ENDIF
     col + 1,
     CALL print(createendelementstring("archiveProcess"))
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   CALL error_and_zero_check(curqual,"DUMMY","INSERTENDOFFILE",1,0)
   CALL log_message(build("Exit InsertStartOfFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addtokeninfotorec(stoken=vc(val),svalue=vc(val)) =null)
   DECLARE nrecsize = i4 WITH noconstant(size(token_info->qual,5)), private
   SET nrecsize += 1
   SET stat = alterlist(token_info->qual,nrecsize)
   SET token_info->qual[nrecsize].token = trim(stoken)
   SET token_info->qual[nrecsize].val = trim(svalue)
 END ;Subroutine
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_delete_starting_id(null) = null
 SUBROUTINE (output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) =null)
   CALL echo(i_file)
   SELECT INTO value(i_file)
    x = substring(1,100,i_debug_str)
    FROM dual
    DETAIL
     x
    WITH maxcol = 130
   ;end select
   FOR (i = 2 TO ceil((size(i_debug_str)/ 100.0)))
     SELECT INTO value(i_file)
      x = substring((1+ ((i - 1) * 100)),100,i_debug_str)
      FROM dual
      DETAIL
       x
      WITH maxcol = 130, append
     ;end select
   ENDFOR
   SELECT INTO value(i_file)
    x = fillstring(100,"=")
    FROM dual
    DETAIL
     x
    WITH maxcol = 130, append
   ;end select
   SELECT INTO value(i_file)
    dm_ind = nullind(dm.index_name), p.statement_id, p.id,
    p.parent_id, p.position, p.operation,
    p.options, p.object_name, dm.table_name,
    dm.index_name, dm.column_position, dm.uniqueness,
    colname = substring(1,30,dm.column_name)
    FROM plan_table p,
     dm_user_ind_columns dm
    PLAN (p
     WHERE p.statement_id=patstring(i_statement_id))
     JOIN (dm
     WHERE (dm.index_name= Outerjoin(p.object_name)) )
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent += 1, col 0, p.id"#####",
     col + 1, col + indent, indent"###",
     ")", p.operation, col + 1,
     p.options, col + 1, p.object_name,
     col + 1
    DETAIL
     IF (dm_ind=0)
      IF (dm.column_position=1)
       row + 1, col + (indent+ 10), ">>>",
       col + 1, dm.uniqueness, col + 1
      ELSE
       ","
      ENDIF
      CALL print(trim(colname))
     ENDIF
    FOOT  p.id
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 400, append
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_fetch_starting_id(null)
   DECLARE sbr_startingid = f8 WITH protect, noconstant(1.0)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   IF (batch_ndx=1)
    RETURN(1.0)
   ENDIF
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    DETAIL
     sbr_startingid = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(sbr_startingid)
 END ;Subroutine
 SUBROUTINE (sbr_update_starting_id(sbr_newid=f8) =null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(sysdate),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(sysdate), di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
      cnvtdatetime(sysdate),
      di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_delete_starting_id(null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE (sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) =vc)
   IF ((jobs->data[job_ndx].purge_flag != c_audit))
    RETURN(sbr_whereclause)
   ENDIF
   DECLARE sbr_newwhereclause = vc WITH protect, noconstant("")
   SET sbr_newwhereclause = concat(sbr_whereclause,
    " and NOT EXISTS (select rowidtbl.purge_table_rowid ","from dm_purge_rowid_list_gttp rowidtbl ",
    "where rowidtbl.purge_table_rowid = ",sbr_tablealias,
    ".rowid)")
   RETURN(sbr_newwhereclause)
 END ;Subroutine
 SET reply->table_name = chart_request_table_name
 SET reply->rows_between_commit = 100
 SET reply->err_code = - (1)
 SET reply->status_data.status = "F"
 DECLARE v_batch_size = f8 WITH protect, noconstant(50000.0)
 DECLARE v_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_cur_min_id = f8 WITH protect, noconstant(1.0)
 DECLARE v_cur_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_rows_left = i4 WITH protect, noconstant(request->max_rows)
 DECLARE cr_begin_date_time = dq8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE getinactivedistributionchartrequests(null) = null
 DECLARE getrowbychartrequestid(null) = null
 DECLARE getnondistributionchartrequests(null) = null
 DECLARE getactivedistributionchartrequests(null) = null
 DECLARE finalizerecordsforarchiveanddelete(null) = null
 DECLARE getchartprintqueuexml(null) = null
 DECLARE getchartrequestencntrxml(null) = null
 DECLARE getchartrequesteventxml(null) = null
 DECLARE getchartrequestsectionxml(null) = null
 DECLARE getchartrequestorderxml(null) = null
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"INPROCESS")), protect
 DECLARE unprocessed_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"UNPROCESSED")), protect
 DECLARE queued_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"QUEUED")), protect
 DECLARE spooled_cd = f8 WITH constant(uar_get_code_by("MEANING",28800,"SPOOLED")), protect
 DECLARE unspooled_cd = f8 WITH constant(uar_get_code_by("MEANING",28800,"UNSPOOLED")), protect
 DECLARE print_only_storage_cd = f8 WITH constant(uar_get_code_by("MEANING",22549,"PRINT")), protect
 IF (inprocess_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"INPROCESS_CD",
   "No code value by CDF_MEANING 'INPROCESS' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 IF (unprocessed_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"UNPROCESSED_CD",
   "No code value by CDF_MEANING 'UNPROCESSED' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 IF (queued_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"QUEUED_CD",
   "No code value by CDF_MEANING 'QUEUED' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 IF (spooled_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"SPOOLED_CD",
   "No code value by CDF_MEANING 'SPOOLED' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 IF (unspooled_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"UNSPOOLED_CD",
   "No code value by CDF_MEANING 'UNSPOOLED' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 IF (print_only_storage_cd=0.0)
  SET reply->status_data.status = "F"
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PRINT_CD",
   "No code value by CDF_MEANING 'PRINT' found for codeset 18609.")
  GO TO exit_script
 ENDIF
 DECLARE max_qual_requests = i4 WITH constant(minval(cnvtint(request->max_rows),500000)), protect
 DECLARE getrowbychartrequestiderr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR1",
   "Retrieving charts by chart_request_id failed."))
 DECLARE getnondistributionchartrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR2",
   "Retrieving charts for AdHocs and Expedites failed."))
 DECLARE getactivedistributionchartrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "ERR3","Retrieving charts for active Distributions failed."))
 DECLARE getinactivedistributionchartrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "ERR6","Retrieving charts for inactive Distributions failed."))
 DECLARE getchartprintqueuexmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR8",
   "Retrieving print queue information failed."))
 DECLARE getchartrequestencntrxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR9",
   "Retrieving requested encounter information failed."))
 DECLARE getchartrequesteventxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR10",
   "Retrieving requested event information failed."))
 DECLARE getchartrequestsectionxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR11",
   "Retrieving requested section information failed."))
 DECLARE getchartrequestorderxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR12",
   "Retrieving requested order information failed."))
 CALL log_message("Begin script: dm_purge_chart_request_rows",log_level_debug)
 CALL gettokeninformation(null)
 IF (size(debug_requests->qual,5) > 0)
  CALL getrowbychartrequestid(null)
 ELSE
  IF (purge_dist_ind=1)
   CALL getreadergroupinformation(null)
   CALL getinactivedistributioninformation(null)
   CALL getinactivedistributionchartrequests(null)
   CALL getactivedistributioninformation(null)
   CALL getactivedistributionchartrequests(null)
  ENDIF
  IF (purge_adhoc_exp_ind=1)
   CALL getnondistributionchartrequests(null)
  ENDIF
 ENDIF
 IF ((temp_requests->cnt > 0))
  CALL preparetemprequests(null)
  CALL getchartprintqueuexml(null)
  CALL getchartrequestencntrxml(null)
  CALL getchartrequesteventxml(null)
  CALL getchartrequestsectionxml(null)
  CALL getchartrequestorderxml(null)
  CALL initinforec(null)
  CALL writerequeststofile(null)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->err_code = 0
 SET reply->err_msg = ""
 SUBROUTINE getrowbychartrequestid(null)
   CALL log_message("In GetRowByChartRequestId()",log_level_debug)
   SET reply->err_msg = getrowbychartrequestiderr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   DECLARE idx = i4 WITH noconstant(size(reply->rows,5)), protect
   DECLARE idx3 = i4 WITH noconstant(0), protect
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM chart_request cr
     PLAN (cr
      WHERE expand(idx3,1,size(debug_requests->qual,5),cr.chart_request_id,debug_requests->qual[idx3]
       .request_id))
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.chart_request_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST","GETROWBYCHARTREQUESTID",1,0)
   ELSE
    CALL log_message(chart_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetRowByChartRequestId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getnondistributionchartrequests(null)
   CALL log_message("In GetNonDistributionChartRequests()",log_level_debug)
   SET reply->err_msg = getnondistributionchartrequestserr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   DECLARE idx = i4 WITH noconstant(size(reply->rows,5)), protect
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM chart_request cr
     PLAN (cr
      WHERE cr.distribution_id=0
       AND cr.request_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (look_back_days_adhoc_exp)
        ))
       AND cr.chart_status_cd != unprocessed_cd
       AND cr.updt_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (updt_day_lookback)))
       AND  NOT (((cr.request_type+ 0) IN (distribution_request_type, mrp_request_type)))
       AND parser(sbr_getrowidnotexists("cr.chart_request_id+0 != 0","cr")))
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.chart_request_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST","GETNONDISTRIBUTIONCHARTREQUESTS",1,0)
   ELSE
    CALL log_message(chart_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetNonDistributionChartRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getactivedistributionchartrequests(null)
   CALL log_message("In GetActiveDistributionChartRequests()",log_level_debug)
   SET reply->err_msg = getactivedistributionchartrequestserr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(size(reply->rows,5)), protect
   DECLARE dist_date = q8 WITH noconstant(cnvtdatetime(0,0)), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idx3 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   IF ((temp_requests->cnt < max_qual_requests))
    IF (size(active_temp_dist->qual,5) > 0)
     DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(active_temp_dist->dist_cnt)),
       chart_request cr
      PLAN (d)
       JOIN (cr
       WHERE (cr.distribution_id=active_temp_dist->qual[d.seq].distribution_id)
        AND cr.request_dt_tm <= cnvtdatetime(active_temp_dist->qual[d.seq].cutoff_dt_tm)
        AND cr.chart_status_cd != unprocessed_cd
        AND cr.updt_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (updt_day_lookback)))
        AND parser(sbr_getrowidnotexists("cr.request_type+0 = DISTRIBUTION_REQUEST_TYPE","cr")))
      HEAD REPORT
       donothing = 0
      DETAIL
       CALL addrowforarchiveanddelete(cr.rowid,cr.chart_request_id)
      FOOT REPORT
       CALL finalizerecordsforarchiveanddelete(null)
      WITH nocounter, maxqual(cr,value(max_qual_count))
     ;end select
     CALL error_and_zero_check(curqual,"CHART_REQUEST","GETACTIVEDISTRIBUTIONCHARTREQUESTS",1,0)
    ENDIF
   ELSE
    CALL log_message(chart_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetActiveDistributionChartRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getinactivedistributionchartrequests(null)
   CALL log_message("In GetInactiveDistributionChartRequests()",log_level_debug)
   SET reply->err_msg = getinactivedistributionchartrequestserr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(size(reply->rows,5)), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idx3 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE dist_date = q8 WITH noconstant(cnvtdatetime(0,0)), protect
   IF ((temp_requests->cnt < max_qual_requests))
    IF (size(inactive_temp_dist->qual,5) > 0)
     DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(inactive_temp_dist->dist_cnt)),
       chart_request cr
      PLAN (d)
       JOIN (cr
       WHERE (cr.distribution_id=inactive_temp_dist->qual[d.seq].distribution_id)
        AND cr.request_dt_tm <= cnvtdatetime(inactive_temp_dist->qual[d.seq].cutoff_dt_tm)
        AND cr.chart_status_cd != unprocessed_cd
        AND cr.updt_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (updt_day_lookback)))
        AND parser(sbr_getrowidnotexists("cr.request_type+0 = DISTRIBUTION_REQUEST_TYPE","cr")))
      HEAD REPORT
       donothing = 0
      DETAIL
       CALL addrowforarchiveanddelete(cr.rowid,cr.chart_request_id)
      FOOT REPORT
       CALL finalizerecordsforarchiveanddelete(null)
      WITH nocounter, maxqual(cr,value(max_qual_count))
     ;end select
     CALL error_and_zero_check(curqual,"CHART_REQUEST","GETINACTIVEDISTRIBUTIONCHARTREQUESTS",1,0)
    ENDIF
   ELSE
    CALL log_message(chart_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetInactiveDistributionChartRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addrowforarchiveanddelete(chartrequestrowid=vc(val),chartrequestid=f8(val)) =null)
   IF (idx < max_qual_requests)
    SET idx += 1
    IF (idx > size(reply->rows,5))
     SET stat = alterlist(reply->rows,(idx+ 999))
     SET stat = alterlist(temp_requests->qual,(idx+ 999))
    ENDIF
    SET reply->rows[idx].row_id = chartrequestrowid
    SET temp_requests->qual[idx].request_id = chartrequestid
    SET temp_requests->qual[idx].xml_string = "<chartRequest "
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("chartRequestId",trim(cnvtstring(cr.chart_request_id))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("requestPrsnlId",trim(cnvtstring(cr.request_prsnl_id))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("requestType",trim(cnvtstring(cr.request_type))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("scope",trim(cnvtstring(cr.scope_flag))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("personId",trim(cnvtstring(cr.person_id))))
    IF (cr.encntr_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("encntrId",trim(cnvtstring(cr.encntr_id))))
    ENDIF
    IF (cr.order_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("orderId",trim(cnvtstring(cr.order_id))))
    ENDIF
    IF (trim(cr.accession_nbr) != "")
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("accession",trim(cr.accession_nbr)))
    ENDIF
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("cfId",trim(cnvtstring(cr.chart_format_id))))
    IF (cr.distribution_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("distId",trim(cnvtstring(cr.distribution_id))))
    ENDIF
    IF (trim(cr.reader_group) > "")
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestringbystring("rdrGrp",trim(cr.reader_group)))
    ENDIF
    IF (cr.dist_run_type_cd > 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("distRunType",trim(uar_get_code_meaning(cr.dist_run_type_cd))))
    ENDIF
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("beginDtTm",trim(format(cnvtdatetimeutc(cr.begin_dt_tm,3),
        "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("endDtTm",trim(format(cnvtdatetimeutc(cr.end_dt_tm,3),
        "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    IF (cr.non_ce_begin_dt_tm != null
     AND cr.non_ce_begin_dt_tm >= cnvtdatetime(cr_begin_date_time))
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("nonCeBeginDtTm",trim(format(cnvtdatetimeutc(cr.non_ce_begin_dt_tm,3),
         "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    ENDIF
    IF (cr.non_ce_end_dt_tm != null)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("nonCeEndDtTm",trim(format(cnvtdatetimeutc(cr.non_ce_end_dt_tm,3),
         "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    ENDIF
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("updtDtTm",trim(format(cnvtdatetimeutc(cr.updt_dt_tm,3),
        "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("requestDtTm",trim(format(cnvtdatetimeutc(cr.request_dt_tm,3),
        "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
     createattributestring("statusCd",trim(uar_get_code_meaning(cr.chart_status_cd))))
    IF (cr.trigger_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("triggerId",trim(cnvtstring(cr.trigger_id))))
    ENDIF
    IF (cr.event_ind != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("eventInd",trim(cnvtstring(cr.event_ind))))
    ENDIF
    IF (cr.file_storage_cd > 0
     AND cr.file_storage_cd != print_only_storage_cd)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("storageCd",trim(uar_get_code_meaning(cr.file_storage_cd))))
    ENDIF
    IF (cr.prsnl_person_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("prsnlPersonId",trim(cnvtstring(cr.prsnl_person_id))))
    ENDIF
    IF (trim(cr.trigger_name) != "")
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestringbystring("triggerName",trim(cr.trigger_name)))
    ENDIF
    IF (cr.chart_trigger_id != 0)
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestring("chartTriggerId",trim(cnvtstring(cr.chart_trigger_id))))
    ENDIF
    IF (trim(cr.user_role_profile) != "")
     SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,
      createattributestringbystring("userRoleProfile",trim(cr.user_role_profile)))
    ENDIF
    SET temp_requests->qual[idx].xml_string = build2(temp_requests->qual[idx].xml_string,">")
   ENDIF
 END ;Subroutine
 SUBROUTINE finalizerecordsforarchiveanddelete(null)
   SET stat = alterlist(reply->rows,idx)
   SET stat = alterlist(temp_requests->qual,idx)
   SET temp_requests->cnt = idx
   CALL log_message(build("Finalizing Chart Count:",idx),log_level_debug)
 END ;Subroutine
 SUBROUTINE getchartprintqueuexml(null)
   CALL log_message("In GetChartPrintQueueXML()",log_level_debug)
   SET reply->err_msg = getchartprintqueuexmlerr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_print_queue cpq
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cpq
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cpq.request_id,temp_requests->qual[idx1].
       request_id))
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cpq.request_id,temp_requests->qual[idx2].request_id)
      IF (locval != 0)
       temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
        createelementstring("queueStatus",trim(uar_get_code_meaning(cpq.queue_status_cd))))
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_PRINT_QUEUE","GETCHARTPRINTQUEUEXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetChartPrintQueueXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getchartrequestencntrxml(null)
   CALL log_message("In GetChartRequestEncntrXML()",log_level_debug)
   SET reply->err_msg = getchartrequestencntrxmlerr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstartencntrlisttag = vc WITH constant(createstartelementstring("encntrList")), protect
   DECLARE sendencntrlisttag = vc WITH constant(createendelementstring("encntrList")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_request_encntr cre
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cre
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cre.chart_request_id,temp_requests->qual[
       idx1].request_id))
     ORDER BY cre.chart_request_id, cre.cr_encntr_seq
     HEAD cre.chart_request_id
      stempelement = sstartencntrlisttag
     HEAD cre.cr_encntr_seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cre.chart_request_id,temp_requests->qual[idx2].request_id
       )
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(cre.encntr_id))))
      ENDIF
     FOOT  cre.cr_encntr_seq
      donothing = 0
     FOOT  cre.chart_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendencntrlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST_ENCNTR","GETCHARTREQUESTENCNTRXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetChartRequestEncntrXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getchartrequesteventxml(null)
   CALL log_message("In GetChartRequestEventXML()",log_level_debug)
   SET reply->err_msg = getchartrequesteventxmlerr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstarteventlisttag = vc WITH constant(createstartelementstring("eventIdList")), protect
   DECLARE sendeventlisttag = vc WITH constant(createendelementstring("eventIdList")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_request_event cre
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cre
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cre.chart_request_id,temp_requests->qual[
       idx1].request_id))
     ORDER BY cre.chart_request_id, cre.cr_event_seq
     HEAD cre.chart_request_id
      stempelement = sstarteventlisttag
     HEAD cre.cr_event_seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cre.chart_request_id,temp_requests->qual[idx2].request_id
       )
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(cre.event_id))))
      ENDIF
     FOOT  cre.cr_event_seq
      donothing = 0
     FOOT  cre.chart_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendeventlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST_EVENT","GETCHARTREQUESTEVENTXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetChartRequestEventXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getchartrequestsectionxml(null)
   CALL log_message("In GetChartRequestSectionXML()",log_level_debug)
   SET reply->err_msg = getchartrequestsectionxmlerr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstartsectionlisttag = vc WITH constant(createstartelementstring("chartSectList")),
   protect
   DECLARE sendsectionlisttag = vc WITH constant(createendelementstring("chartSectList")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_request_section crs
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (crs
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),crs.chart_request_id,temp_requests->qual[
       idx1].request_id))
     ORDER BY crs.chart_request_id, crs.cr_sect_seq
     HEAD crs.chart_request_id
      stempelement = sstartsectionlisttag
     HEAD crs.cr_sect_seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,crs.chart_request_id,temp_requests->qual[idx2].request_id
       )
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(crs
           .chart_section_id))))
      ENDIF
     FOOT  crs.cr_sect_seq
      donothing = 0
     FOOT  crs.chart_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendsectionlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST_SECTION","GETCHARTREQUESTSECTIONXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetChartRequestSectionXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getchartrequestorderxml(null)
   CALL log_message("In GetChartRequestOrderXML()",log_level_debug)
   SET reply->err_msg = getchartrequestorderxmlerr
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstartsectionlisttag = vc WITH constant(createstartelementstring("chartOrderList")),
   protect
   DECLARE sendsectionlisttag = vc WITH constant(createendelementstring("chartOrderList")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_request_order cro
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cro
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cro.chart_request_id,temp_requests->qual[
       idx1].request_id))
     ORDER BY cro.chart_request_id, cro.chart_request_order_id
     HEAD cro.chart_request_id
      stempelement = sstartsectionlisttag
     HEAD cro.chart_request_order_id
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cro.chart_request_id,temp_requests->qual[idx2].request_id
       )
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(cro.order_id))))
      ENDIF
     FOOT  cro.chart_request_order_id
      donothing = 0
     FOOT  cro.chart_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendsectionlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQUEST_ORDER","GETCHARTREQUESTORDERXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetChartRequestOrderXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: dm_purge_chart_request_rows",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
