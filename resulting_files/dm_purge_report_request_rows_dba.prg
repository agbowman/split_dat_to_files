CREATE PROGRAM dm_purge_report_request_rows:dba
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
 SET log_program_name = "DM_PURGE_REPORT_REQUEST_ROWS"
 IF (validate(reply) != 1)
  RECORD reply(
    1 err_msg = vc
    1 err_code = i4
    1 table_name = vc
    1 rows_between_commit = i4
    1 rows[*]
      2 row_id = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE gettokeninformation(null) = null
 DECLARE getnextchartrecseq(null) = f8
 DECLARE getnextlongdataseq(null) = f8
 DECLARE initinforec(null) = null
 DECLARE buildstartoffile(null) = vc
 DECLARE buildendoffile(null) = vc
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
 DECLARE document_service_request_type = i4 WITH constant(5), protect
 DECLARE concept_service_request_type = i4 WITH constant(6), protect
 DECLARE mrp_request_type = i4 WITH constant(8), protect
 DECLARE look_back_days_adhoc_exp = f8 WITH noconstant(0.0), protect
 DECLARE look_back_days_dist = f8 WITH noconstant(0.0), protect
 DECLARE look_back_days_docservice = f8 WITH noconstant(0.0), protect
 DECLARE look_back_days_conceptservice = f8 WITH noconstant(0.0), protect
 DECLARE purge_adhoc_exp_ind = i2 WITH noconstant(0), protect
 DECLARE purge_dist_ind = i2 WITH noconstant(0), protect
 DECLARE purge_docservice_ind = i2 WITH noconstant(0), protect
 DECLARE purge_conceptservice_ind = i2 WITH noconstant(0), protect
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
 FREE RECORD info_rec
 RECORD info_rec(
   1 cer_temp = vc
   1 ccl_cer_temp = vc
   1 disk_cer_temp = vc
   1 orig_report_count = i4
   1 purge_flag_token_found = i2
   1 purge_flag = i2
   1 logical_domains[*]
     2 xml_file_name = vc
     2 zip_file_name = vc
     2 logical_domain_id = f8
     2 ccl_full_file_and_folder = vc
     2 request_count = i4
     2 next_request_archive_id = f8
     2 next_request_archive_id_str = vc
     2 long_blob_id = f8
     2 minrequestdatetime = dq8
     2 maxrequestdatetime = dq8
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
     2 logical_domain_id = f8
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
   SET rdr_idx = locateval(idx,1,x,cd.reader_group,reader_groups->qual[idx].reader_group)
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
     OF "PURGECONCEPTSERVICEIND":
      SET purge_conceptservice_ind = cnvtint(request->tokens[tok_ndx].value)
     OF "LOOKBACKDAYSCONCEPTSERVICE":
      SET look_back_days_conceptservice = cnvtreal(request->tokens[tok_ndx].value)
     OF "PURGEDOCSERVICEIND":
      SET purge_docservice_ind = cnvtint(request->tokens[tok_ndx].value)
     OF "LOOKBACKDAYSDOCSERVICE":
      SET look_back_days_docservice = cnvtreal(request->tokens[tok_ndx].value)
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
   ELSEIF (look_back_days_conceptservice < 30
    AND purge_conceptservice_ind=1)
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS3","%1 %2 %3","sss",
     "You must look back at least 30 days for concept service requests.  You entered ",
     nullterm(trim(cnvtstring(look_back_days_conceptservice),3))," days or did not enter any value.")
    CALL log_message(reply->err_msg,log_level_debug)
    GO TO exit_script
   ELSEIF (look_back_days_docservice < 30
    AND purge_docservice_ind=1)
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS4","%1 %2 %3","sss",
     "You must look back at least 30 days for document service requests.  You entered ",
     nullterm(trim(cnvtstring(look_back_days_docservice),3))," days or did not enter any value.")
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
   DECLARE count = i4 WITH noconstant(1), private
   FOR (count = 1 TO size(info_rec->logical_domains,5))
     SET info_rec->logical_domains[count].next_request_archive_id = getnextchartrecseq(null)
     SET info_rec->logical_domains[count].next_request_archive_id_str = cnvtstring(info_rec->
      logical_domains[count].next_request_archive_id,16)
     SET temp_file_name = build(file_name_str,info_rec->logical_domains[count].
      next_request_archive_id_str)
     SET info_rec->logical_domains[count].xml_file_name = build(temp_file_name,"-",cnvtstring(
       info_rec->logical_domains[count].logical_domain_id,16),".xml")
     SET info_rec->logical_domains[count].zip_file_name = build(temp_file_name,"-",cnvtstring(
       info_rec->logical_domains[count].logical_domain_id,16),".zip")
     SET info_rec->logical_domains[count].ccl_full_file_and_folder = build(info_rec->ccl_cer_temp,
      info_rec->logical_domains[count].xml_file_name)
     SET info_rec->logical_domains[count].long_blob_id = getnextlongdataseq(null)
   ENDFOR
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
 SUBROUTINE (writerequeststofile(null=vc(val)) =null)
   CALL log_message("In WriteRequestsToFile()",log_level_debug)
   SET reply->err_msg = writerequeststofileerr
   RECORD file(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   )
   FREE RECORD get_xml_request
   RECORD get_xml_request(
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
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE archive_table_name = vc WITH noconstant(""), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE zip_command = vc WITH noconstant(""), protect
   DECLARE remove_command = vc WITH noconstant(""), protect
   DECLARE file_path = vc WITH noconstant("\0"), private
   DECLARE grparchive = vc WITH noconstant(""), protect
   DECLARE requestelement = vc WITH noconstant(""), protect
   SET grparchive = report_request_archive_str
   SET requestelement = report_request_element_str
   SET archive_table_name = report_request_archive_table_name
   FOR (i = 1 TO size(info_rec->logical_domains,5))
     SET file_path = info_rec->logical_domains[i].ccl_full_file_and_folder
     SET file->file_name = file_path
     SET file->file_buf = "w"
     SET stat = cclio("OPEN",file)
     SET file->file_buf = buildstartoffile(null)
     SET stat = cclio("PUTS",file)
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = value(temp_requests->cnt))
      WHERE (info_rec->logical_domains[i].logical_domain_id=temp_requests->qual[d.seq].
      logical_domain_id)
      HEAD REPORT
       file->file_buf = build2(char(10)," ",createstartelementstring(grparchive)), stat = cclio(
        "PUTS",file)
      DETAIL
       info_rec->logical_domains[i].request_count += 1, file->file_buf = build2(char(10)," ",trim(
         temp_requests->qual[d.seq].xml_string)," ",createendelementstring(requestelement)), stat =
       cclio("PUTS",file)
       IF (d.seq < value(temp_requests->cnt))
        file->file_buf = build2(char(10)), stat = cclio("PUTS",file)
       ENDIF
      FOOT REPORT
       file->file_buf = build2(" ",createendelementstring(grparchive),char(10)), stat = cclio("PUTS",
        file)
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"DUMMY","WRITEREQUESTSTOFILE",1,0)
     SET file->file_buf = buildendoffile(null)
     SET stat = cclio("PUTS",file)
     SET stat = cclio("CLOSE",file)
     IF ((info_rec->logical_domains[i].request_count > 0))
      SET zip_command = concat("zip -9jm ",info_rec->disk_cer_temp,info_rec->logical_domains[i].
       zip_file_name," ",info_rec->disk_cer_temp,
       info_rec->logical_domains[i].xml_file_name)
      IF (((cursys="VMS") OR (cursys="AXP")) )
       SET zip_command = concat("mcr cer_exe:",zip_command)
      ELSE
       SET zip_command = concat("$cer_exe/",zip_command)
      ENDIF
      IF (run_dcl(zip_command) > zip_successful)
       SET reply->err_msg = concat(rundclerr," <",zip_command,">")
       GO TO exit_script
      ENDIF
      SET stat = initrec(get_xml_request)
      SET stat = initrec(temp_reply)
      SET get_xml_request->basblob = 1
      SET get_xml_request->module_dir = info_rec->ccl_cer_temp
      SET get_xml_request->module_name = info_rec->logical_domains[i].zip_file_name
      EXECUTE eks_get_source  WITH replace("REQUEST","GET_XML_REQUEST"), replace("REPLY","TEMP_REPLY"
       )
      IF ((temp_reply->status_data.status != "S"))
       SET reply->err_msg = eksgetsourceerr
       SET reply->status_data.subeventstatus[1].operationname = get_xml_request->status_data.
       subeventstatus[1].operationname
       SET reply->status_data.subeventstatus[1].operationstatus = get_xml_request->status_data.
       subeventstatus[1].operationstatus
       SET reply->status_data.subeventstatus[1].targetobjectname = get_xml_request->status_data.
       subeventstatus[1].targetobjectname
       SET reply->status_data.subeventstatus[1].targetobjectvalue = get_xml_request->status_data.
       subeventstatus[1].targetobjectvalue
       GO TO exit_script
      ENDIF
      IF ((info_rec->purge_flag != do_not_purge_flag))
       SET reply->err_msg = inserttolongbloberr
       INSERT  FROM long_blob lb
        SET lb.active_ind = 1, lb.active_status_cd = reqdata->active_status_cd, lb.blob_length =
         temp_reply->data_blob_size,
         lb.long_blob = temp_reply->data_blob, lb.long_blob_id = info_rec->logical_domains[i].
         long_blob_id, lb.parent_entity_name = archive_table_name,
         lb.parent_entity_id = info_rec->logical_domains[i].next_request_archive_id, lb.updt_id =
         reqinfo->updt_id, lb.updt_dt_tm = cnvtdatetime(curdate,curtime),
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
      SET remove_command = concat(remove_command," ",info_rec->disk_cer_temp,info_rec->
       logical_domains[i].zip_file_name)
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
       SET reply->err_msg = inserttoreportrequestarchiveerr
       INSERT  FROM cr_report_request_archive rra
        SET rra.archived_report_nbr = info_rec->logical_domains[i].request_count, rra.archived_dt_tm
          = cnvtdatetime(current_date_time), rra.report_request_archive_id = info_rec->
         logical_domains[i].next_request_archive_id,
         rra.long_blob_id = info_rec->logical_domains[i].long_blob_id, rra.min_request_dt_tm =
         cnvtdatetime(info_rec->logical_domains[i].minrequestdatetime), rra.max_request_dt_tm =
         cnvtdatetime(info_rec->logical_domains[i].maxrequestdatetime),
         rra.updt_id = reqinfo->updt_id, rra.updt_dt_tm = cnvtdatetime(curdate,curtime), rra.updt_cnt
          = 1,
         rra.updt_task = reqinfo->updt_task, rra.updt_applctx = reqinfo->updt_applctx, rra
         .logical_domain_id = info_rec->logical_domains[i].logical_domain_id
        WITH nocounter
       ;end insert
       CALL error_and_zero_check(curqual,"INSERT_REPORT_REQUEST_ARCHIVE","WRITEREQUESTSTOFILE",1,1)
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit WriteRequestsToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildstartoffile(null)
   CALL log_message("In BuildStartOfFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE tokeninfoxml = vc WITH noconstant(""), protect
   SET tokeninfoxml = gettokeninfoxml(null)
   DECLARE startoffile = vc WITH noconstant(""), private
   SET startoffile = build2(xml_version_encoding,char(10)," ",createstartelementstring(
     "archiveProcess"),char(10),
    " ",tokeninfoxml,char(10))
   CALL error_and_zero_check(curqual,"DUMMY","BUILDSTARTOFFILE",1,0)
   CALL log_message(build("Exit BuildStartOfFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(startoffile)
 END ;Subroutine
 SUBROUTINE buildendoffile(null)
   CALL log_message("In BuildEndOfFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE endoffile = vc WITH noconstant(""), private
   SET endoffile = build2(char(10)," ",createelementstring("requestCount",temp_requests->cnt)," ",
    createelementstring("procTime",cnvtstring(datetimediff(cnvtdatetime(sysdate),current_date_time,5)
      )),
    " ",createelementstring("runDtTm",trim(format(cnvtdatetimeutc(current_date_time,3),
       "YYYY-MM-DDTHH:MM:SSZ;3;Q")))," ",createelementstring("curnode",trim(curnode))," ",
    createelementstring("currdbsys",trim(currdbsys)))
   IF ((temp_requests->cnt >= max_qual_requests))
    SET endoffile = build2(endoffile," ",createcommentstring(request_cutoff_exceeded))
   ENDIF
   SET endoffile = build2(endoffile," ",createendelementstring("archiveProcess"),char(10))
   CALL error_and_zero_check(curqual,"DUMMY","BUILDENDOFFILE",1,0)
   CALL log_message(build("Exit BuildEndOfFile(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
   RETURN(endoffile)
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
 DECLARE getinactivedistributionreportrequests(null) = null
 DECLARE getrowbyreportrequestid(null) = null
 DECLARE getnondistributionreportrequests(null) = null
 DECLARE getactivedistributionreportrequests(null) = null
 DECLARE getdocservicereportrequests(null) = null
 DECLARE getconceptservicereportrequests(null) = null
 DECLARE finalizerecordsforarchiveanddelete(null) = null
 DECLARE getreportrequestencntrxml(null) = null
 DECLARE getreportrequesteventxml(null) = null
 DECLARE getreportrequestsectionxml(null) = null
 DECLARE getprintedsectionxml(null) = null
 DECLARE getsecureemailxml(null) = null
 DECLARE getoutputdestinationxml(null) = null
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",367571,"PENDING")), protect
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",367571,"INPROCESS")), protect
 DECLARE batch_cd = f8 WITH constant(uar_get_code_by("MEANING",367571,"BATCHINPROC")), protect
 DECLARE max_qual_requests = i4 WITH constant(minval(cnvtint(request->max_rows),500000)), protect
 DECLARE getrowbyreportrequestiderr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR1",
   "Retrieving requests by report_request_id failed."))
 DECLARE getnondistributionreportrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "RRERR2","Retrieving charts for AdHocs and Expedites failed."))
 DECLARE getactivedistributionreportrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "RRERR3","Retrieving charts for active Distributions failed."))
 DECLARE getinactivedistributionreportrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "RRERR4","Retrieving charts for inactive Distributions failed."))
 DECLARE getreportrequestencntrxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR5",
   "Retrieving requested encounter information failed."))
 DECLARE getreportrequesteventxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR6",
   "Retrieving requested event information failed."))
 DECLARE getreportrequestsectionxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR7",
   "Retrieving requested section information failed."))
 DECLARE getprintedsectionxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR8",
   "Retrieving printed section information failed."))
 DECLARE getsecureemailsectionxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR9",
   "Retrieving secure email information failed."))
 DECLARE getoutputdestinationsectionxmlerr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR10",
   "Retrieving output destination information failed."))
 DECLARE getconceptservicereportrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "RRERR11","Retrieving charts for Concept Service failed."))
 DECLARE getdocservicereportrequestserr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RRERR12",
   "Retrieving charts for Document Service failed."))
 DECLARE nreplycount = i4 WITH noconstant(0), protect
 DECLARE rr_begin_date_time = dq8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 CALL log_message("Begin script: dm_purge_report_request_rows",log_level_debug)
 SET reply->table_name = report_request_table_name
 SET reply->rows_between_commit = 100
 SET reply->err_code = - (1)
 SET reply->status_data.status = "F"
 CALL gettokeninformation(null)
 IF (size(debug_requests->qual,5) > 0)
  CALL getrowbyreportrequestid(null)
 ELSE
  IF (purge_dist_ind=1)
   CALL getreadergroupinformation(null)
   CALL getinactivedistributioninformation(null)
   CALL getinactivedistributionreportrequests(null)
   CALL getactivedistributioninformation(null)
   CALL getactivedistributionreportrequests(null)
  ENDIF
  IF (purge_adhoc_exp_ind=1)
   CALL getnondistributionreportrequests(null)
  ENDIF
  IF (purge_docservice_ind=1)
   CALL getdocservicereportrequests(null)
  ENDIF
  IF (purge_conceptservice_ind=1)
   CALL getconceptservicereportrequests(null)
  ENDIF
 ENDIF
 IF ((temp_requests->cnt > 0))
  CALL preparetemprequests(null)
  CALL getreportrequestencntrxml(null)
  CALL getreportrequesteventxml(null)
  CALL getreportrequestsectionxml(null)
  CALL getprintedsectionxml(null)
  CALL getsecureemailxml(null)
  CALL getoutputdestinationxml(null)
  CALL initinforec(null)
  CALL writerequeststofile(null)
 ENDIF
 IF (nreplycount > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->err_code = 0
 SET reply->err_msg = ""
 SUBROUTINE getrowbyreportrequestid(null)
   CALL log_message("In GetRowByReportRequestId()",log_level_debug)
   SET reply->err_msg = getrowbyreportrequestiderr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   DECLARE idx3 = i4 WITH noconstant(0), protect
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM cr_report_request cr,
      person p,
      application app
     PLAN (cr
      WHERE expand(idx3,1,size(debug_requests->qual,5),cr.report_request_id,debug_requests->qual[idx3
       ].request_id))
      JOIN (p
      WHERE p.person_id=cr.person_id)
      JOIN (app
      WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETROWBYREPORTREQUESTID",1,0)
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetRowByReportRequestId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getnondistributionreportrequests(null)
   CALL log_message("In GetNonDistributionReportRequests()",log_level_debug)
   SET reply->err_msg = getnondistributionreportrequestserr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM cr_report_request cr,
      person p,
      application app
     PLAN (cr
      WHERE cr.distribution_id=0
       AND cr.request_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (look_back_days_adhoc_exp)
        ))
       AND  NOT (cr.report_status_cd IN (pending_cd, inprocess_cd, batch_cd))
       AND  NOT (((cr.request_type_flag+ 0) IN (distribution_request_type,
      document_service_request_type, concept_service_request_type)))
       AND parser(sbr_getrowidnotexists("cr.report_request_id+0 != 0","cr")))
      JOIN (p
      WHERE p.person_id=cr.person_id)
      JOIN (app
      WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
     ORDER BY cr.request_dt_tm
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETNONDISTRIBUTIONREPORTREQUESTS",1,0)
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetNonDistributionReportRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getactivedistributionreportrequests(null)
   CALL log_message("In GetActiveDistributionReportRequests()",log_level_debug)
   SET reply->err_msg = getactivedistributionreportrequestserr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE dist_date = dq8 WITH noconstant(cnvtdatetime(0,0)), protect
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
       cr_report_request cr,
       person p,
       application app
      PLAN (d)
       JOIN (cr
       WHERE (cr.distribution_id=active_temp_dist->qual[d.seq].distribution_id)
        AND cr.request_dt_tm <= cnvtdatetime(active_temp_dist->qual[d.seq].cutoff_dt_tm)
        AND  NOT (cr.report_status_cd IN (pending_cd, inprocess_cd, batch_cd))
        AND parser(sbr_getrowidnotexists("cr.request_type_flag+0 = DISTRIBUTION_REQUEST_TYPE","cr")))
       JOIN (p
       WHERE p.person_id=cr.person_id)
       JOIN (app
       WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
      ORDER BY cr.request_dt_tm
      HEAD REPORT
       donothing = 0
      DETAIL
       CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
      FOOT REPORT
       CALL finalizerecordsforarchiveanddelete(null)
      WITH nocounter, maxqual(cr,value(max_qual_count))
     ;end select
     CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETACTIVEDISTRIBUTIONREPORTREQUESTS",1,0)
    ENDIF
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetActiveDistributionReportRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getinactivedistributionreportrequests(null)
   CALL log_message("In GetInactiveDistributionReportRequests()",log_level_debug)
   SET reply->err_msg = getinactivedistributionreportrequestserr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idx3 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE dist_date = dq8 WITH noconstant(cnvtdatetime(0,0)), protect
   IF ((temp_requests->cnt < max_qual_requests))
    IF (size(inactive_temp_dist->qual,5) > 0)
     DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(inactive_temp_dist->dist_cnt)),
       cr_report_request cr,
       person p,
       application app
      PLAN (d)
       JOIN (cr
       WHERE (cr.distribution_id=inactive_temp_dist->qual[d.seq].distribution_id)
        AND cr.request_dt_tm <= cnvtdatetime(inactive_temp_dist->qual[d.seq].cutoff_dt_tm)
        AND  NOT (cr.report_status_cd IN (pending_cd, inprocess_cd, batch_cd))
        AND parser(sbr_getrowidnotexists("cr.request_type_flag+0 = DISTRIBUTION_REQUEST_TYPE","cr")))
       JOIN (p
       WHERE p.person_id=cr.person_id)
       JOIN (app
       WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
      ORDER BY cr.request_dt_tm
      HEAD REPORT
       donothing = 0
      DETAIL
       CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
      FOOT REPORT
       CALL finalizerecordsforarchiveanddelete(null)
      WITH nocounter, maxqual(cr,value(max_qual_count))
     ;end select
     CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETINACTIVEDISTRIBUTIONREPORTREQUESTS",1,
      0)
    ENDIF
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetInactiveDistributionReportRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getdocservicereportrequests(null)
   CALL log_message("In GetDocServiceReportRequests()",log_level_debug)
   SET reply->err_msg = getdocservicereportrequestserr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM cr_report_request cr,
      person p,
      application app
     PLAN (cr
      WHERE cr.distribution_id=0
       AND cr.request_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (look_back_days_docservice
        )))
       AND  NOT (cr.report_status_cd IN (pending_cd, inprocess_cd, batch_cd))
       AND parser(sbr_getrowidnotexists("cr.request_type_flag+0 = DOCUMENT_SERVICE_REQUEST_TYPE","cr"
        )))
      JOIN (p
      WHERE p.person_id=cr.person_id)
      JOIN (app
      WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
     ORDER BY cr.request_dt_tm
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETDOCSERVICEREPORTREQUESTS",1,0)
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetDocServiceReportRequests(), Elapsed time in seconds:",datetimediff
     (cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getconceptservicereportrequests(null)
   CALL log_message("In GetConceptServiceReportRequests()",log_level_debug)
   SET reply->err_msg = getconceptservicereportrequestserr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE max_qual_count = i4 WITH noconstant((max_qual_requests - temp_requests->cnt)), private
   IF ((temp_requests->cnt < max_qual_requests))
    SELECT INTO "nl:"
     FROM cr_report_request cr,
      person p,
      application app
     PLAN (cr
      WHERE cr.distribution_id=0
       AND cr.request_dt_tm < cnvtdatetime(datetimeadd(current_date_time,- (
        look_back_days_conceptservice)))
       AND  NOT (cr.report_status_cd IN (pending_cd, inprocess_cd, batch_cd))
       AND parser(sbr_getrowidnotexists("cr.request_type_flag+0 = CONCEPT_SERVICE_REQUEST_TYPE","cr")
       ))
      JOIN (p
      WHERE p.person_id=cr.person_id)
      JOIN (app
      WHERE (app.application_number= Outerjoin(cr.request_app_nbr)) )
     ORDER BY cr.request_dt_tm
     HEAD REPORT
      donothing = 0
     DETAIL
      CALL addrowforarchiveanddelete(cr.rowid,cr.report_request_id,p.logical_domain_id)
     FOOT REPORT
      CALL finalizerecordsforarchiveanddelete(null)
     WITH nocounter, maxqual(cr,value(max_qual_count))
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","GETCONCEPTSERVICEREPORTREQUESTS",1,0)
   ELSE
    CALL log_message(request_cutoff_exceeded,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GetConceptServiceReportRequests(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addrowforarchiveanddelete(reportrequestrowid=vc(val),reportrequestid=f8(val),
  logicaldomainid=f8(val)) =null)
   IF (nreplycount < max_qual_requests)
    SET nreplycount += 1
    IF (nreplycount > size(reply->rows,5))
     SET stat = alterlist(reply->rows,(nreplycount+ 999))
    ENDIF
    SET reply->rows[nreplycount].row_id = reportrequestrowid
    IF (cr.request_xml_id=0)
     SET temp_requests->cnt += 1
     SET nrpt = temp_requests->cnt
     IF ((temp_requests->cnt > size(temp_requests->qual,5)))
      SET stat = alterlist(temp_requests->qual,(temp_requests->cnt+ 999))
     ENDIF
     SET temp_requests->qual[nrpt].request_id = reportrequestid
     SET temp_requests->qual[nrpt].logical_domain_id = logicaldomainid
     SET temp_requests->qual[nrpt].xml_string = "<reportRequest "
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("reportRequestId",trim(cnvtstring(cr.report_request_id,16),3)))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("personId",trim(cnvtstring(cr.person_id,16),3)))
     IF (cr.disk_identifier != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("diskId",trim(cnvtstring(cr.disk_identifier,16),3)))
     ENDIF
     IF (cr.encntr_id != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("encntrId",trim(cnvtstring(cr.encntr_id,16),3)))
     ENDIF
     IF (trim(cr.accession_nbr) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("accession",trim(cr.accession_nbr,3)))
     ENDIF
     IF (cr.order_id != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("orderId",trim(cnvtstring(cr.order_id,16),3)))
     ENDIF
     IF (cr.request_prsnl_id > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("requestPrsnlId",trim(cnvtstring(cr.request_prsnl_id,16),3)))
     ENDIF
     IF (trim(cr.requesting_role_profile) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("requestingRoleProfile",trim(cr.requesting_role_profile,3)))
     ENDIF
     IF (cr.provider_prsnl_id > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("providerPrsnlId",trim(cnvtstring(cr.provider_prsnl_id,16),3)))
     ENDIF
     IF (cr.provider_reltn_cd > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("providerReltn",trim(cnvtstring(cr.provider_reltn_cd,16),3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("requestDtTm",trim(format(cnvtdatetimeutc(cr.request_dt_tm,3),
         "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("requestType",trim(cnvtstring(cr.request_type_flag),3)))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("scope",trim(cnvtstring(cr.scope_flag),3)))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("postingDate",trim(cnvtstring(cr.use_posting_date_ind),3)))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("reportStatus",trim(cnvtstring(cr.report_status_cd,16),3)))
     IF (cr.distribution_id != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("distId",trim(cnvtstring(cr.distribution_id,16),3)))
     ENDIF
     IF (cr.dist_run_type_cd > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("distRunType",trim(cnvtstring(cr.dist_run_type_cd,16),3)))
     ENDIF
     IF (trim(cr.reader_group) > "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("rdrGrp",trim(cr.reader_group,3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("templateId",trim(cnvtstring(cr.template_id,16),3)))
     IF (cr.template_version_mode_flag > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("templateVersionModeFlag",trim(cnvtstring(cr.template_version_mode_flag),
         3)))
     ENDIF
     IF (cr.template_version_dt_tm != null)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("templateVersionDtTm",trim(format(cnvtdatetimeutc(cr
           .template_version_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     ENDIF
     IF (cr.begin_dt_tm != null
      AND cr.begin_dt_tm >= cnvtdatetime(rr_begin_date_time))
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("beginDtTm",trim(format(cnvtdatetimeutc(cr.begin_dt_tm,3),
          "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     ENDIF
     IF (cr.end_dt_tm != null)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("endDtTm",trim(format(cnvtdatetimeutc(cr.end_dt_tm,3),
          "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     ENDIF
     IF (cr.non_ce_begin_dt_tm != null
      AND cr.non_ce_begin_dt_tm >= cnvtdatetime(rr_begin_date_time))
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("nonCeBeginDtTm",trim(format(cnvtdatetimeutc(cr.non_ce_begin_dt_tm,3),
          "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     ENDIF
     IF (cr.non_ce_end_dt_tm != null)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("nonCeEndDtTm",trim(format(cnvtdatetimeutc(cr.non_ce_end_dt_tm,3),
          "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     ENDIF
     IF (cr.request_app_nbr != null
      AND cr.request_app_nbr > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("requestingApplicationNbr",trim(cnvtstring(cr.request_app_nbr),3)))
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("requestingApplicationDescr",trim(app.description,3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("updtDtTm",trim(format(cnvtdatetimeutc(cr.updt_dt_tm,3),
         "YYYY-MM-DDTHH:MM:SSZ;3;Q"))))
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("statusFlag",trim(cnvtstring(cr.result_status_flag),3)))
     IF (cr.trigger_id != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("triggerId",trim(cnvtstring(cr.trigger_id,16),3)))
     ENDIF
     IF (trim(cr.trigger_type) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("triggerType",trim(cr.trigger_type,3)))
     ENDIF
     IF (trim(cr.trigger_name) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("triggerName",trim(cr.trigger_name,3)))
     ENDIF
     IF (cr.chart_trigger_id != 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("chartTriggerId",trim(cnvtstring(cr.chart_trigger_id,16),3)))
     ENDIF
     IF (trim(cr.output_content_type_str) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("outputContentType",trim(cr.output_content_type_str,3)))
     ENDIF
     IF (cr.output_content_type_cd > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("outputContentTypeCd",trim(cnvtstring(cr.output_content_type_cd,16),3)))
     ENDIF
     IF (trim(cr.dms_service_ident) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("requestDMSServiceIdent",trim(cr.dms_service_ident,3)))
     ENDIF
     IF (trim(cr.dms_adhoc_fax_number_txt) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("requestAdhocFaxNumberTxt",trim(cr.dms_adhoc_fax_number_txt,3)))
     ENDIF
     IF (cr.output_dest_cd > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("requestOutputDestCd",trim(cnvtstring(cr.output_dest_cd,16),3)))
     ENDIF
     IF (trim(cr.external_content_ident) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("externalContentIdent",trim(cr.external_content_ident,3)))
     ENDIF
     IF (trim(cr.external_content_name) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("externalContentName",trim(cr.external_content_name,3)))
     ENDIF
     IF (trim(cr.prsnl_role_profile_uid) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("prsnlRoleProfileUID",trim(cr.prsnl_role_profile_uid,3)))
     ENDIF
     IF (trim(cr.concept_service_name) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("conceptServiceName",trim(cr.concept_service_name,3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,">")
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      "<releaseInfo")
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("patientConsent",trim(cnvtstring(cr.patient_consent_received_ind),3)))
     IF (cr.release_reason_cd > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("releaseReason",trim(cnvtstring(cr.release_reason_cd,16),3)))
     ENDIF
     IF (trim(cr.release_comment) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("releaseComment",trim(cr.release_comment,3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("requestorType",trim(cnvtstring(cr.requestor_type_flag),3)))
     IF (trim(cr.requestor_value_txt) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("requestorTxt",trim(cr.requestor_value_txt,3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      createattributestring("destinationType",trim(cnvtstring(cr.destination_type_flag),3)))
     IF (trim(cr.destination_value_txt) != "")
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestringbystring("destinationTxt",trim(cr.destination_value_txt,3)))
     ENDIF
     IF (cr.patient_request_ind > 0)
      SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
       createattributestring("patientRequest",trim(cnvtstring(cr.patient_request_ind),3)))
     ENDIF
     SET temp_requests->qual[nrpt].xml_string = build2(temp_requests->qual[nrpt].xml_string,
      "></releaseInfo>")
     DECLARE num = i4 WITH private, noconstant(0)
     DECLARE logicaldomainidx = i4 WITH protect, noconstant(0)
     SET logicaldomainidx = locatevalsort(num,1,size(info_rec->logical_domains,5),logicaldomainid,
      info_rec->logical_domains[num].logical_domain_id)
     IF (logicaldomainidx <= 0)
      IF (size(info_rec->logical_domains,5)=0)
       SET logicaldomainidx = 1
       SET stat = alterlist(info_rec->logical_domains,1)
      ELSE
       SET logicaldomainidx = (abs(logicaldomainidx)+ 1)
       SET stat = alterlist(info_rec->logical_domains,(size(info_rec->logical_domains,5)+ 1),(
        logicaldomainidx - 1))
      ENDIF
      SET info_rec->logical_domains[logicaldomainidx].logical_domain_id = logicaldomainid
      SET info_rec->logical_domains[logicaldomainidx].maxrequestdatetime = cnvtdatetime(cr
       .request_dt_tm)
      SET info_rec->logical_domains[logicaldomainidx].minrequestdatetime = cnvtdatetime(cr
       .request_dt_tm)
     ELSE
      IF ((cr.request_dt_tm > info_rec->logical_domains[logicaldomainidx].maxrequestdatetime))
       SET info_rec->logical_domains[logicaldomainidx].maxrequestdatetime = cnvtdatetime(cr
        .request_dt_tm)
      ENDIF
      IF ((cr.request_dt_tm < info_rec->logical_domains[logicaldomainidx].minrequestdatetime))
       SET info_rec->logical_domains[logicaldomainidx].minrequestdatetime = cnvtdatetime(cr
        .request_dt_tm)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE finalizerecordsforarchiveanddelete(null)
   SET stat = alterlist(reply->rows,nreplycount)
   SET stat = alterlist(temp_requests->qual,temp_requests->cnt)
   CALL log_message(build("Finalizing Request Count:",temp_requests->cnt),log_level_debug)
 END ;Subroutine
 SUBROUTINE getreportrequestencntrxml(null)
   CALL log_message("In GetReportRequestEncntrXML()",log_level_debug)
   SET reply->err_msg = getreportrequestencntrxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
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
      cr_report_request_encntr cre
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cre
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cre.report_request_id,temp_requests->
       qual[idx1].request_id))
     ORDER BY cre.report_request_id, cre.seq
     HEAD cre.report_request_id
      stempelement = sstartencntrlisttag
     HEAD cre.seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cre.report_request_id,temp_requests->qual[idx2].
       request_id)
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(cre.encntr_id,16),3
          )))
      ENDIF
     FOOT  cre.seq
      donothing = 0
     FOOT  cre.report_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendencntrlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_ENCNTR","GETREPORTREQUESTENCNTRXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetReportRequestEncntrXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getreportrequesteventxml(null)
   CALL log_message("In GetReportRequestEventXML()",log_level_debug)
   SET reply->err_msg = getreportrequesteventxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
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
      cr_report_request_event cre
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cre
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cre.report_request_id,temp_requests->
       qual[idx1].request_id))
     ORDER BY cre.report_request_id, cre.seq
     HEAD cre.report_request_id
      stempelement = sstarteventlisttag
     HEAD cre.seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cre.report_request_id,temp_requests->qual[idx2].
       request_id)
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(cre.event_id,16),3)
         ))
      ENDIF
     FOOT  cre.seq
      donothing = 0
     FOOT  cre.report_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendeventlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_EVENT","GETREPORTREQUESTEVENTXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetReportRequestEventXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getreportrequestsectionxml(null)
   CALL log_message("In GetReportRequestSectionXML()",log_level_debug)
   SET reply->err_msg = getreportrequestsectionxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstartsectionlisttag = vc WITH constant(createstartelementstring("requestedSectList")),
   protect
   DECLARE sendsectionlisttag = vc WITH constant(createendelementstring("requestedSectList")),
   protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      cr_report_request_section crs
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (crs
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),crs.report_request_id,temp_requests->
       qual[idx1].request_id))
     ORDER BY crs.report_request_id, crs.seq
     HEAD crs.report_request_id
      stempelement = sstartsectionlisttag
     HEAD crs.seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,crs.report_request_id,temp_requests->qual[idx2].
       request_id)
      IF (locval != 0)
       stempelement = build(stempelement,createelementstring("id",trim(cnvtstring(crs.section_id,16),
          3)))
      ENDIF
     FOOT  crs.seq
      donothing = 0
     FOOT  crs.report_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendsectionlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_SECTION","GETREPORTREQUESTSECTIONXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetReportRequestSectionXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getprintedsectionxml(null)
   CALL log_message("In GetPrintedSectionXML()",log_level_debug)
   SET reply->err_msg = getprintedsectionxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE sstartsectionlisttag = vc WITH constant(createstartelementstring("printedSectList")),
   protect
   DECLARE sendsectionlisttag = vc WITH constant(createendelementstring("printedSectList")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      cr_printed_sections crs
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (crs
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),crs.report_request_id,temp_requests->
       qual[idx1].request_id))
     ORDER BY crs.report_request_id, crs.seq
     HEAD crs.report_request_id
      stempelement = sstartsectionlisttag
     HEAD crs.seq
      donothing = 0
     DETAIL
      locval = locateval(idx2,1,nrecordsize,crs.report_request_id,temp_requests->qual[idx2].
       request_id)
      IF (locval != 0)
       stempelement = build2(stempelement,"<id")
       IF (crs.content_type_cd > 0.0)
        stempelement = build2(stempelement,createattributestring("contentTypeCd",trim(cnvtstring(crs
            .content_type_cd,16),3)))
       ENDIF
       stempelement = build2(stempelement,">",trim(cnvtstring(crs.section_id,16),3),
        createendelementstring("id"))
      ENDIF
     FOOT  crs.seq
      donothing = 0
     FOOT  crs.report_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendsectionlisttag)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CR_PRINTED_SECTIONS","GETPRINTEDSECTIONXML",1,0)
   ENDIF
   CALL log_message(build("Exit GetPrintedSectionXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsecureemailxml(null)
   CALL log_message("GetSecureEmailXML()",log_level_debug)
   SET reply->err_msg = getsecureemailsectionxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE sendsecemailtag = vc WITH constant(createendelementstring("secureEmail")), protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      cr_report_request cr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cr
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,temp_requests->qual[
       idx1].request_id)
       AND cr.email_subject_id > 0)
     ORDER BY cr.report_request_id
     HEAD cr.report_request_id
      stempelement = "<secureEmail"
     DETAIL
      locval = locateval(idx2,1,nrecordsize,cr.report_request_id,temp_requests->qual[idx2].request_id
       )
      IF (locval != 0)
       stempelement = build2(stempelement,createattributestringbystring("senderEmail",trim(cr
          .sender_email,3))), stempelement = build2(stempelement,">")
      ENDIF
     FOOT  cr.report_request_id
      temp_requests->qual[locval].xml_string = build(temp_requests->qual[locval].xml_string,
       stempelement,sendsecemailtag)
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit GetSecureEmailXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getoutputdestinationxml(null)
   CALL log_message("GetOutputDestinationXML()",log_level_debug)
   SET reply->err_msg = getoutputdestinationsectionxmlerr
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx1 = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE sendoutputdestlisttag = vc WITH constant(createendelementstring("outputDestinationList")),
   protect
   DECLARE stempelement = vc WITH noconstant(""), protect
   IF ((temp_requests->cnt > 0))
    SET nrecordsize = temp_requests->cnt
    SET noptimizedtotal = size(temp_requests->qual,5)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      cr_output_destination crdest
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (crdest
      WHERE expand(idx1,idxstart,((idxstart+ bind_cnt) - 1),crdest.report_request_id,temp_requests->
       qual[idx1].request_id))
     ORDER BY crdest.report_request_id, crdest.seq
     HEAD crdest.report_request_id
      stempelement = " "
     HEAD crdest.seq
      stempelement = build2(stempelement,"<outputDestinationList")
     DETAIL
      locval = locateval(idx2,1,nrecordsize,crdest.report_request_id,temp_requests->qual[idx2].
       request_id)
      IF (locval != 0)
       IF (crdest.output_dest_cd > 0)
        stempelement = build2(stempelement,createattributestring("crDestOutputDestCd",trim(cnvtstring
           (crdest.output_dest_cd,16),3)))
       ENDIF
       IF (crdest.dms_service_ident != "")
        stempelement = build2(stempelement,createattributestringbystring("crDestDMSServiceIdent",trim
          (crdest.dms_service_ident,3)))
       ENDIF
       IF (crdest.dms_adhoc_fax_number_txt != "")
        stempelement = build2(stempelement,createattributestringbystring("crDestDMSAdhocFaxNumberTxt",
          trim(crdest.dms_adhoc_fax_number_txt,3)))
       ENDIF
       stempelement = build2(stempelement,createattributestring("crDestDistributedStatusInd",trim(
          cnvtstring(crdest.distributed_status_ind),3))), stempelement = build2(stempelement,">")
      ENDIF
     FOOT  crdest.seq
      stempelement = build2(stempelement,sendoutputdestlisttag)
     FOOT  crdest.report_request_id
      temp_requests->qual[locval].xml_string = build2(temp_requests->qual[locval].xml_string,
       stempelement)
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit GetOutputDestinationXML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: dm_purge_chart_request_rows",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
