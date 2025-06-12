CREATE PROGRAM cr_send_http_requests:dba
 IF (validate(send_request) != 1)
  RECORD send_request(
    1 requests[*]
      2 request_id = f8
      2 debug_ind = i2
      2 print_ind = i2
    1 requesting_locale = c5
  )
 ENDIF
 IF (validate(send_reply) != 1)
  FREE RECORD send_reply
  RECORD send_reply(
    1 http_status_code = i4
    1 http_status = vc
    1 content_type = vc
    1 response_uri = vc
    1 response_buffer = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE clinical_rept_servlet = vc WITH constant("ClinicalReportServlet"), protect
 DECLARE health_servlet = vc WITH constant("ServiceHealthServlet"), protect
 DECLARE cpm_http_transaction = i4 WITH constant(2000), protect
 DECLARE info_domain = vc WITH noconstant("ClinicalReporting"), protect
 DECLARE info_name_default = vc WITH noconstant("XR Application URL"), protect
 DECLARE info_name_adhoc = vc WITH noconstant("XR Application URL ADHOC"), protect
 DECLARE info_name_distribution = vc WITH noconstant("XR Application URL DIST"), protect
 DECLARE info_name_expedite = vc WITH noconstant("XR Application URL EXPEDITE"), protect
 DECLARE info_name_docservice = vc WITH noconstant("XR Application URL DOCSERVICE"), protect
 DECLARE info_name_conceptservice = vc WITH noconstant("XR Application URL CONCEPTSERVICE"), protect
 DECLARE sc_ok_response = i4 WITH constant(200), protect
 DECLARE sc_accepted_response = i4 WITH constant(202), protect
 DECLARE sc_no_content = i4 WITH constant(204), protect
 DECLARE sc_bad_request = i4 WITH constant(400), protect
 DECLARE sc_not_found = i4 WITH constant(404), protect
 DECLARE sc_internal_server_error = i4 WITH constant(500), protect
 DECLARE cr_bad_response = i4 WITH constant(900), protect
 DECLARE hhealthmsg = i4 WITH noconstant(0), protect
 DECLARE hhealthreq = i4 WITH noconstant(0), protect
 DECLARE hhealthrep = i4 WITH noconstant(0), protect
 IF ( NOT (validate(sc_unkstat)))
  DECLARE sc_unkstat = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(sc_ok)))
  DECLARE sc_ok = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(sc_parserror)))
  DECLARE sc_parserror = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(sc_nofile)))
  DECLARE sc_nofile = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(sc_nonode)))
  DECLARE sc_nonode = i4 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(sc_noattr)))
  DECLARE sc_noattr = i4 WITH protect, constant(5)
 ENDIF
 IF ( NOT (validate(sc_badobjref)))
  DECLARE sc_badobjref = i4 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(sc_invindex)))
  DECLARE sc_invindex = i4 WITH protect, constant(7)
 ENDIF
 IF ( NOT (validate(sc_notfound)))
  DECLARE sc_notfound = i4 WITH protect, constant(8)
 ENDIF
 IF ( NOT (validate(validate_success)))
  DECLARE validate_success = c1 WITH protect, constant("1")
 ENDIF
 IF (validate(uar_xml_getattributevalue,char(128))=char(128))
  DECLARE uar_xml_getattributevalue(nodehandle=i4(ref),attrname=vc) = vc
 ENDIF
 IF (validate(uar_xml_getnodename,char(128))=char(128))
  DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getnodecontent,char(128))=char(128))
  DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_parsestring,char(128))=char(128))
  DECLARE uar_xml_parsestring(xmlstring=vc,filehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getroot,char(128))=char(128))
  DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(parsexmlbuffer,char(128))=char(128))
  SUBROUTINE (parsexmlbuffer(pxmlbuffer=vc,prxmlfilehandle=i4(ref)) =i4)
    SET prxmlfilehandle = 0
    IF (uar_xml_parsestring(nullterm(pxmlbuffer),prxmlfilehandle) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hxmlroot = 0
    IF (uar_xml_getroot(prxmlfilehandle,__hxmlroot) != sc_ok)
     RETURN(0)
    ENDIF
    RETURN(__hxmlroot)
  END ;Subroutine
 ENDIF
 IF (validate(getchildnodevalue,char(128))=char(128))
  SUBROUTINE (getchildnodevalue(pparenthandle=i4,pchildname=vc) =vc)
    IF (pparenthandle=0.0)
     RETURN(nullterm(""))
    ENDIF
    SET __hitem = 0
    IF (uar_xml_findchildnode(pparenthandle,nullterm(pchildname),__hitem) != sc_ok)
     RETURN(nullterm(""))
    ENDIF
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    SET __tmpstring = nullterm(uar_xml_getnodecontent(__hitem))
    SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
    SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
    SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
    SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
    SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getattributevalue,char(128))=char(128))
  SUBROUTINE (getattributevalue(pelementhandle=i4,pattrname=vc) =vc)
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    IF (pelementhandle != 0.0)
     SET __tmpstring = nullterm(uar_xml_getattributevalue(pelementhandle,nullterm(pattrname)))
     SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
     SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
     SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
     SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
     SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    ENDIF
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getchildnodeattributevalue,char(128))=char(128))
  SUBROUTINE (getchildnodeattributevalue(pparenthandle=i4,pchildname=vc,pattrname=vc) =vc)
    IF (pparenthandle=0.0)
     RETURN(nullterm(""))
    ENDIF
    SET __hitem = 0
    IF (uar_xml_findchildnode(pparenthandle,nullterm(pchildname),__hitem) != sc_ok)
     RETURN(nullterm(""))
    ENDIF
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    SET __tmpstring = nullterm(uar_xml_getattributevalue(__hitem,nullterm(pattrname)))
    SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
    SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
    SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
    SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
    SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getdomainvalidation,char(128))=char(128))
  SUBROUTINE (getdomainvalidation(proothandle=i4) =i2)
    SET __hservicehealthdata = 0
    IF (uar_xml_findchildnode(proothandle,"servlet-health",__hservicehealthdata) != sc_ok)
     RETURN(0)
    ENDIF
    SET __chidx = 0
    SET __chcnt = uar_xml_getchildcount(__hservicehealthdata)
    FOR (__chidx = 1 TO __chcnt)
      SET __tmpnode = 0
      IF (uar_xml_getchildnode(__hservicehealthdata,(__chidx - 1),__tmpnode) != sc_ok)
       RETURN(0)
      ENDIF
      IF (uar_xml_getnodename(__tmpnode)="health-item")
       SET __tmpstring = getattributevalue(__tmpnode,"key")
       IF (__tmpstring="domain-validation")
        SET __tmpstring = trim(getchildnodevalue(__tmpnode,"response-code"),3)
        IF (__tmpstring=validate_success)
         RETURN(1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    RETURN(0)
  END ;Subroutine
 ENDIF
 IF (validate(getstring,char(128))=char(128))
  SUBROUTINE (getstring(hrep=i4,svalue=vc) =vc)
    SET lstringlength = 0
    SET sfixedstring = fillstring(500," ")
    SET lstringlength = uar_srvgetstringlen(hrep,svalue)
    IF (lstringlength > 500)
     SET lstringlength = 500
    ENDIF
    CALL uar_srvgetstring(hrep,svalue,sfixedstring,lstringlength)
    SET returnval = trim(sfixedstring,3)
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 IF (validate(getapplicationurl,char(128))=char(128))
  DECLARE getapplicationurl(null) = vc WITH protect
  SUBROUTINE getapplicationurl(null)
    CALL log_message("Entering GetApplicationURL",log_level_debug)
    DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
    DECLARE returnval = vc WITH noconstant(""), protect
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="ClinicalReporting"
      AND di.info_name="XR Application URL"
     DETAIL
      returnval = di.info_char
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"Application URL was empty","GETAPPLICATIONURL",1,1)
    CALL log_message(build("Exiting GetApplicationURL, Elapsed time in seconds:",datetimediff(
       cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 IF (validate(getapplicationurlbytype,char(128))=char(128))
  SUBROUTINE (getapplicationurlbytype(request_type=i2) =vc WITH protect)
    CALL log_message("Entering GetApplicationURLByType",log_level_debug)
    DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
    DECLARE returnval = vc WITH noconstant(""), protect
    CASE (request_type)
     OF 1:
      SET info_name = build2("dm.info_name = INFO_NAME_ADHOC")
     OF 2:
      SET info_name = build2("dm.info_name = INFO_NAME_EXPEDITE")
     OF 3:
      SET info_name = build2("dm.info_name = INFO_NAME_EXPEDITE")
     OF 4:
      SET info_name = build2("dm.info_name = INFO_NAME_DISTRIBUTION")
     OF 5:
      SET info_name = build2("dm.info_name = INFO_NAME_DOCSERVICE")
     OF 6:
      SET info_name = build2("dm.info_name = INFO_NAME_CONCEPTSERVICE")
     OF 0:
      SET info_name = build2("dm.info_name = INFO_NAME_DEFAULT")
    ENDCASE
    SELECT INTO "nl:"
     FROM dm_info dm
     WHERE dm.info_domain=info_domain
      AND parser(info_name)
     DETAIL
      returnval = dm.info_char
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"Application URL was empty","GetApplicationURLByType",1,1)
    CALL log_message(build("Exiting GetApplicationURLByType, Elapsed time in seconds:",datetimediff(
       cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 IF (validate(gethealthresponse,char(128))=char(128))
  SUBROUTINE (gethealthresponse(application_url=vc) =i4 WITH protect)
    CALL log_message("Entering GetHealthResponse",log_level_debug)
    DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
    DECLARE health_request = vc WITH constant(concat("domain-validation=",curdomain)), private
    DECLARE health_url = vc WITH noconstant(trim(application_url)), private
    SET laststr = substring(size(health_url),1,health_url)
    IF (laststr != "/")
     SET health_url = concat(health_url,"/")
    ENDIF
    SET health_url = concat(health_url,health_servlet)
    IF (validate(debug_ind,0))
     CALL echo(build("HEALTH-REQUEST: ",health_url,"?",health_request))
    ENDIF
    SET hhealthmsg = uar_srvselectmessage(cpm_http_transaction)
    SET hhealthreq = uar_srvcreaterequest(hhealthmsg)
    SET hhealthrep = uar_srvcreatereply(hhealthmsg)
    SET stat = uar_srvsetstringfixed(hhealthreq,"uri",health_url,size(health_url,1))
    SET stat = uar_srvsetstring(hhealthreq,"method","POST")
    SET stat = uar_srvsetasis(hhealthreq,"request_buffer",health_request,size(health_request,1))
    SET stat = uar_srvexecute(hhealthmsg,hhealthreq,hhealthrep)
    IF (validate(debug_ind,0))
     SET responsesize = uar_srvgetasissize(hhealthrep,"response_buffer")
     IF (responsesize > 0)
      SET responsestring = substring(1,responsesize,uar_srvgetasisptr(hhealthrep,"response_buffer"))
      CALL echo(build("HEALTH-RESPONSE: ",responsestring))
     ELSE
      CALL echo("HEALTH-RESPONSE: no response replied")
     ENDIF
    ENDIF
    CALL log_message(build("Exiting GetHealthResponse, Elapsed time in seconds:",datetimediff(
       cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
    RETURN(hhealthrep)
  END ;Subroutine
 ENDIF
 IF (validate(clean,char(128))=char(128))
  DECLARE clean(null) = i2 WITH protect
  SUBROUTINE clean(null)
    IF (hhealthmsg != 0)
     SET stat = uar_srvdestroyinstance(hhealthmsg)
    ENDIF
    IF (hhealthreq != 0)
     SET stat = uar_srvdestroyinstance(hhealthreq)
    ENDIF
    IF (hhealthrep != 0)
     SET stat = uar_srvdestroyinstance(hhealthrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(gethttpresponsecode,char(128))=char(128))
  SUBROUTINE (gethttpresponsecode(httpresponse=i4) =i4 WITH protect)
    CALL log_message("Entering GetHTTPResponseCode",log_level_debug)
    DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
    DECLARE http_status_code = i4 WITH noconstant(sc_not_found), protect
    DECLARE responsesize = i4 WITH noconstant(0), protect
    IF (httpresponse != 0)
     SET responsesize = uar_srvgetasissize(httpresponse,"response_buffer")
     SET http_status_code = uar_srvgetlong(httpresponse,"http_status_code")
     IF (isresponseaccepted(http_status_code))
      CALL log_message(build("Service Health http_status_code: ",http_status_code),log_level_debug)
      IF (validate(debug_ind,0))
       CALL echo(build("http_status_code: ",http_status_code))
       CALL echo(build("http_status: ",getstring(httpresponse,"http_status")))
       CALL echo(build("content_type: ",getstring(httpresponse,"content_type")))
       CALL echo(build("response_uri: ",getstring(httpresponse,"response_uri")))
       CALL echo(build("size: ",responsesize))
      ENDIF
      IF (responsesize=0)
       SET http_status_code = cr_bad_response
      ENDIF
     ELSE
      IF (http_status_code=0)
       SET http_status_code = sc_not_found
      ENDIF
     ENDIF
    ENDIF
    CALL log_message(build("Exiting GetHTTPResponseCode, Elapsed time in seconds:",datetimediff(
       cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
    RETURN(http_status_code)
  END ;Subroutine
 ENDIF
 IF (validate(isresponseaccepted,char(128))=char(128))
  SUBROUTINE (isresponseaccepted(http_response_code=i4) =i2 WITH protect)
    IF (http_response_code != sc_not_found)
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getdomainvalidationindicator,char(128))=char(128))
  SUBROUTINE (getdomainvalidationindicator(replystring=vc) =i2 WITH protect)
    CALL log_message("Entering GetDomainValidationIndicator()",log_level_debug)
    DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
    DECLARE returnval = i2 WITH noconstant(0), protect
    DECLARE hparsedxml = i4 WITH noconstant(0), protect
    DECLARE hxmlresourcefile = i4 WITH noconstant(0), protect
    DECLARE hchildnode = i4 WITH noconstant(0), protect
    IF (validate(debug_ind,0))
     CALL echo(replystring)
    ENDIF
    SET hparsedxml = parsexmlbuffer(replystring,hxmlresourcefile)
    SET returnval = getdomainvalidation(hparsedxml)
    CALL log_message(build("Exiting GetDomainValidationIndicator, Elapsed time in seconds:",
      datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 DECLARE size = h WITH protect, noconstant(0)
 DECLARE pos = h WITH protect, noconstant(0)
 DECLARE actual = h WITH protect, noconstant(0)
 IF ( NOT (validate(initializehttprequest)))
  SUBROUTINE (initializehttprequest(purl=vc,phttpmethod=vc,pmediatype=vc,prrequesthandle=i4(ref),
   prheadershandle=i4(ref),prcustomheadershandle=i4(ref)) =i2)
    DECLARE huri = i4 WITH protect, noconstant(0)
    CALL log_message("Begin initializeHttpRequest",log_level_debug)
    EXECUTE cr_srvuri
    CALL log_message(concat("url passed in: ",purl),log_level_debug)
    SET huri = uar_srv_geturiparts(nullterm(trim(purl)))
    IF (huri=0)
     CALL log_message(concat("Failed to parse URL: ",purl),log_level_error)
     RETURN(false)
    ENDIF
    SET prrequesthandle = uar_srv_createwebrequest(huri)
    IF (prrequesthandle=0)
     CALL log_message("Failed to create request",log_level_error)
     RETURN(false)
    ENDIF
    SET prheadershandle = uar_srv_createproplist()
    IF (prheadershandle=0)
     CALL log_message("Failed to create request headers",log_level_error)
     RETURN(false)
    ENDIF
    SET prcustomheadershandle = uar_srv_createproplist()
    IF (prcustomheadershandle=0)
     CALL log_message("Failed to create request custom headers",log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_setpropstring(prheadershandle,"method",nullterm(trim(phttpmethod)))
    SET stat = uar_srv_setpropstring(prheadershandle,"accept",nullterm(trim(pmediatype)))
    SET stat = uar_srv_closehandle(huri)
    CALL log_message("End initializeHttpRequest",log_level_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(executehttprequest)))
  SUBROUTINE (executehttprequest(prequesthandle=i4,pheadershandle=i4,pcustomheadershandle=i4,
   prstatuscode=i4(ref),prstatusdesc=vc(ref),prresponsebody=vc(ref)) =i2)
    CALL log_message("Begin executeHttpRequest",log_level_debug)
    DECLARE hresponse = i4 WITH protect, noconstant(0)
    DECLARE hresponsebuffer = i4 WITH protect, noconstant(0)
    DECLARE responsebody = vc WITH protect
    SET hresponsebuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
     0)
    SET stat = uar_srv_setprophandle(pheadershandle,"customHeaders",pcustomheadershandle,1)
    SET stat = uar_srv_setwebrequestprops(prequesthandle,pheadershandle)
    SET hresponse = uar_srv_getwebresponse(prequesthandle,hresponsebuffer)
    IF (hresponse=0)
     CALL log_message("executeHttpRequest - Failed to execute HTTP request",log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_getmemorybuffersize(hresponsebuffer,size)
    IF (stat=0)
     CALL log_message("executeHttpRequest - Failed to get buffer size for response body",
      log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_setbufferpos(hresponsebuffer,0,0,pos)
    IF (stat=0)
     CALL log_message("executeHttpRequest - Failed to set buffer position for response body",
      log_level_error)
     RETURN(false)
    ENDIF
    SET stat = memrealloc(responsebody,1,build("C",size))
    SET stat = uar_srv_readbuffer(hresponsebuffer,responsebody,size,actual)
    SET prresponsebody = trim(responsebody)
    IF (stat=0)
     CALL log_message("executeHttpRequest - Failed to read buffer for response body",log_level_error)
     RETURN(false)
    ENDIF
    IF ( NOT (gethttpstatus(hresponse,prstatuscode,prstatusdesc)))
     CALL log_message("executeHttpRequest - Failed to retrieve status code",log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_closehandle(hresponse)
    SET stat = uar_srv_closehandle(hresponsebuffer)
    CALL log_message("Exiting executeHttpRequest",log_level_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(gethttpstatus)))
  SUBROUTINE (gethttpstatus(presponsehandle=i4,prstatuscode=i4(ref),prstatusdesc=vc(ref)) =i2)
    CALL log_message("Begin getHttpStatus",log_level_debug)
    DECLARE hproperties = i4 WITH protect, noconstant(0)
    IF (presponsehandle=0)
     CALL log_message("getHttpStatus - Invalid response handle",log_level_error)
     RETURN(false)
    ENDIF
    SET hproperties = uar_srv_getwebresponseprops(presponsehandle)
    IF (hproperties=0)
     CALL log_message("getHttpStatus - Failed to obtain handle to response properties",
      log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_getpropstring(hproperties,"statusDesc",prstatusdesc,size)
    SET stat = uar_srv_getpropint(hproperties,"statusCode",prstatuscode)
    IF (stat=0)
     CALL log_message("getHttpStatus - Failed to retrieve http status code",log_level_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_closehandle(hproperties)
    CALL log_message("Exiting getHttpStatus",log_level_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 DECLARE populatexmlforrequestbatch(null) = null WITH protect
 DECLARE sendhttprequestbatch(null) = null WITH protect
 DECLARE checkxrhttptimeoutsetting(null) = null WITH protect
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE http_xml_request = vc WITH noconstant(""), protect
 DECLARE app_url = vc WITH noconstant(""), protect
 DECLARE canonicaldomain = vc WITH noconstant(""), protect
 DECLARE default_locale = vc WITH noconstant(""), protect
 DECLARE request_type = i2 WITH noconstant(0)
 DECLARE is_advance_routing_enabled = i2 WITH noconstant(0)
 DECLARE xrhttptimeout = i4 WITH protect, noconstant(5)
 SET log_program_name = "CR_SEND_HTTP_REQUESTS"
 SET default_locale = logical("ccl_lang")
 SELECT INTO "nl:"
  FROM cr_report_request cr
  WHERE (cr.report_request_id=send_request->requests[1].request_id)
  HEAD REPORT
   request_type = cr.request_type_flag
  WITH nocounter
 ;end select
 IF (validate(get_service_url_request) != 1)
  FREE RECORD get_service_url_request
  RECORD get_service_url_request(
    1 service_key = vc
    1 request_type = i2
  )
 ENDIF
 IF (validate(get_service_url_reply) != 1)
  FREE RECORD get_service_url_reply
  RECORD get_service_url_reply(
    1 service_url = vc
    1 service_directory_url = vc
    1 canonicaldomainname = vc
    1 use_advance_routing = i2
    1 usingservicedirectory = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET get_service_url_request->request_type = request_type
 EXECUTE cr_get_xr_service_url  WITH replace("REQUEST",get_service_url_request), replace("REPLY",
  get_service_url_reply)
 IF (validate(debug_ind,0))
  CALL echorecord(get_service_url_reply)
 ENDIF
 IF ((get_service_url_reply->status_data.status="S"))
  SET app_url = get_service_url_reply->service_url
  SET canonicaldomain = get_service_url_reply->canonicaldomainname
  IF ((get_service_url_reply->use_advance_routing=1))
   CASE (request_type)
    OF 1:
     SET app_url = concat(app_url,"/Adhoc")
    OF 2:
     SET app_url = concat(app_url,"/Expedite")
    OF 3:
     SET app_url = concat(app_url,"/Expedite")
    OF 4:
     SET app_url = concat(app_url,"/Distribution")
    OF 5:
     SET app_url = concat(app_url,"/DocService")
    OF 6:
     SET app_url = concat(app_url,"/ConceptService")
   ENDCASE
  ENDIF
 ELSE
  SET send_reply->status_data.status = "F"
  IF (size(send_reply->status_data.subeventstatus,5)=0)
   SET stat = alterlist(send_reply->status_data.subeventstatus,1)
  ENDIF
  IF (size(get_service_url_reply->status_data.subeventstatus,5) > 0)
   SET send_reply->status_data.subeventstatus[1].operationname = get_service_url_reply->status_data.
   subeventstatus[1].operationname
   SET send_reply->status_data.subeventstatus[1].operationstatus = get_service_url_reply->status_data
   .subeventstatus[1].operationstatus
   SET send_reply->status_data.subeventstatus[1].targetobjectname = get_service_url_reply->
   status_data.subeventstatus[1].targetobjectname
   SET send_reply->status_data.subeventstatus[1].targetobjectvalue = get_service_url_reply->
   status_data.subeventstatus[1].targetobjectvalue
  ENDIF
  GO TO exit_script
 ENDIF
 CALL populatexmlforrequestbatch(null)
 CALL sendhttprequestbatch(null)
 IF (isresponseaccepted(send_reply->http_status_code))
  SET send_reply->status_data.status = "S"
 ELSE
  SET send_reply->status_data.status = "W"
  SET send_reply->status_data.subeventstatus[1].operationname = "CR_SEND_HTTP_REQUESTS"
  SET send_reply->status_data.subeventstatus[1].operationstatus = "W"
  SET send_reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(send_reply->
   http_status_code)
  SET send_reply->status_data.subeventstatus[1].targetobjectvalue = send_reply->http_status
 ENDIF
 SUBROUTINE sendhttprequestbatch(null)
   CALL log_message("Entering sendHttpRequestBatch()",log_level_debug)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hheadershandle = i4 WITH protect, noconstant(0)
   DECLARE hcustomheaderhandle = i4 WITH protect, noconstant(0)
   DECLARE hrequestbuffer = i4 WITH protect, noconstant(0)
   DECLARE servlet_url = vc WITH protect, noconstant("")
   DECLARE statuscode = i4 WITH protect, noconstant(0)
   DECLARE statusdesc = vc WITH protect, noconstant("")
   DECLARE responsebody = vc WITH protect, noconstant("")
   DECLARE pos = h WITH protect, noconstant(0)
   DECLARE actual = h WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   EXECUTE srvuri
   SET servlet_url = concat(app_url,"/",clinical_rept_servlet)
   SET stat = initializehttprequest(servlet_url,"post","",hrequest,hheadershandle,
    hcustomheaderhandle)
   IF (stat=true)
    SET hrequestbuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
     0)
    SET stat = uar_srv_setbufferpos(hrequestbuffer,0,0,pos)
    SET stat = uar_srv_writebuffer(hrequestbuffer,http_xml_request,size(http_xml_request),actual)
    SET stat = uar_srv_setprophandle(hheadershandle,"reqBuffer",hrequestbuffer,1)
    SET stat = uar_srv_setpropstring(hheadershandle,"contentType","text/xml")
    CALL checkxrhttptimeoutsetting(null)
    SET stat = uar_srv_setpropint(hheadershandle,"timeout",xrhttptimeout)
    SET stat = uar_srv_setpropint(hheadershandle,"conTimeout",xrhttptimeout)
    SET stat = executehttprequest(hrequest,hheadershandle,hcustomheaderhandle,statuscode,statusdesc,
     responsebody)
   ENDIF
   IF (stat=true)
    SET send_reply->http_status_code = statuscode
    SET send_reply->http_status = statusdesc
    SET send_reply->response_buffer = responsebody
   ELSE
    SET send_reply->http_status_code = sc_notfound
    SET send_reply->http_status = "Failed to execute HTTP request"
   ENDIF
   CALL log_message(concat("Preparing to close hRequest:",trim(cnvtstring(hrequest)),
     ", hHeadersHandle:",trim(cnvtstring(hheadershandle)),"."),log_level_debug)
   IF (hrequest != 0)
    CALL log_message("Closing hRequest",log_level_debug)
    SET stat = uar_srv_closehandle(hrequest)
    SET hrequest = 0
   ENDIF
   IF (hheadershandle != 0)
    CALL log_message("Closing hHeadersHandle",log_level_debug)
    SET stat = uar_srv_closehandle(hheadershandle)
    SET hheadershandle = 0
   ENDIF
   CALL log_message("Exiting sendHttpRequestBatch()",log_level_debug)
 END ;Subroutine
 SUBROUTINE populatexmlforrequestbatch(null)
   CALL log_message("Entering populateXmlForRequestBatch",log_level_debug)
   SET send_reply->status_data.status = "F"
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(send_request->requests,5)))
    HEAD REPORT
     IF ((send_request->requests[1].debug_ind=1))
      http_xml_request = "<report-processing-batch debug-ind='true'"
     ELSE
      http_xml_request = "<report-processing-batch"
     ENDIF
     IF (trim(send_request->requesting_locale) != "")
      http_xml_request = concat(http_xml_request," locale='",send_request->requesting_locale,"'")
     ELSEIF (trim(default_locale) != "")
      http_xml_request = concat(http_xml_request," locale='",default_locale,"'")
     ENDIF
     http_xml_request = concat(http_xml_request," data-source-authority='",trim(cnvtlower(curdomain)),
      "'")
     IF ((send_request->requests[1].print_ind=1))
      http_xml_request = concat(http_xml_request," print-ind='true'>")
     ELSE
      http_xml_request = concat(http_xml_request,">")
     ENDIF
    DETAIL
     http_xml_request = concat(http_xml_request,"<report-request request-id='"), http_xml_request =
     concat(http_xml_request,cnvtstring(send_request->requests[d1.seq].request_id)), http_xml_request
      = concat(http_xml_request,"'/>")
    FOOT REPORT
     http_xml_request = concat(http_xml_request,"</report-processing-batch>")
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(http_xml_request)
   ENDIF
   CALL log_message("Exiting populateXmlForRequestBatch",log_level_debug)
 END ;Subroutine
 SUBROUTINE checkxrhttptimeoutsetting(null)
   SELECT INTO "nl:"
    FROM dm_info dm
    WHERE dm.info_domain=info_domain
     AND dm.info_name="XR Http Timeout"
    DETAIL
     xrhttptimeout = dm.info_number
    WITH nocounter
   ;end select
   CALL log_message(build2("XR HTTP timeout: ",xrhttptimeout),log_level_debug)
   IF (validate(debug_ind,0))
    CALL echo(build2("XR HTTP timeout: ",xrhttptimeout))
   ENDIF
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0))
  CALL echorecord(send_reply)
 ENDIF
END GO
