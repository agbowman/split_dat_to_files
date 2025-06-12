CREATE PROGRAM cr_get_xr_service_url:dba
 IF (validate(request) != 1)
  RECORD request(
    1 service_key = vc
    1 request_type = i2
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 service_url = vc
    1 service_directory_url = vc
    1 canonicaldomainname = vc
    1 use_advance_routing = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 usingservicedirectory = i2
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
 DECLARE getserviceurlfromdminfo(null) = vc WITH protect
 DECLARE getservicekeybyrequesttype(null) = vc WITH protect
 DECLARE lookforservicedirectoryurl(null) = null WITH protect
 DECLARE dcloutput = vc WITH protect, noconstant("")
 DECLARE canonicaldomainname = vc WITH protect, noconstant("")
 DECLARE simpledomain = vc WITH protect, noconstant("")
 DECLARE zonename = vc WITH protect, noconstant("")
 DECLARE tempdcl = vc WITH protect, noconstant("")
 DECLARE dclcom = vc WITH protect, noconstant("")
 DECLARE status = i4 WITH protect, noconstant(0)
 DECLARE servicedirurl = vc WITH protect, noconstant("")
 DECLARE urllen = i4 WITH protect, noconstant(0)
 DECLARE lastslash = c1 WITH protect, noconstant("")
 DECLARE aixcommand = vc WITH protect, constant("hostnew -t SRV ")
 DECLARE hpuxcommand = vc WITH protect, constant("host -N 2 -t SRV ")
 SET log_program_name = "CR_GET_XR_SERVICE_URL"
 SET reply->status_data.status = "F"
 SET reply->usingservicedirectory = 1
 IF (size(trim(request->service_key),1)=0)
  SET request->service_key = getservicekeybyrequesttype(null)
 ENDIF
 CALL log_message(build2("XR Service key: ",request->service_key),log_level_debug)
 SET reply->service_url = getserviceurlfromservicedirectory(request->service_key)
 CALL log_message(build2("Retrieved XR URL from Service Directory: ",reply->service_url),
  log_level_info)
 IF (size(trim(reply->service_url),1)=0)
  SET reply->usingservicedirectory = 0
  SET reply->service_url = getserviceurlfromdminfo(null)
  CALL log_message(build2("Retrieved XR URL from DM_INFO table: ",reply->service_url),log_level_info)
 ENDIF
 SET urllen = size(reply->service_url,1)
 SET lastslash = substring(urllen,1,reply->service_url)
 IF (lastslash="/")
  SET reply->service_url = substring(1,(urllen - 1),reply->service_url)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE getserviceurlfromdminfo(null)
   CASE (request->request_type)
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
    ELSE
     SET info_name = build2("dm.info_name = INFO_NAME_DEFAULT")
   ENDCASE
   SELECT INTO "nl:"
    FROM dm_info dm
    WHERE dm.info_domain=info_domain
     AND parser(info_name)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     IF ((request->request_type > 0)
      AND dm.info_number > 0)
      reply->use_advance_routing = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ((reply->use_advance_routing=1))
    RETURN(getapplicationurlbytype(request->request_type))
   ELSE
    RETURN(getapplicationurl(null))
   ENDIF
 END ;Subroutine
 SUBROUTINE getservicekeybyrequesttype(null)
  CALL log_message(build2("getServiceKeyByRequestType: ",request->request_type),log_level_debug)
  CASE (request->request_type)
   OF 1:
    RETURN("urn:cerner:api:ml-clinical-reporting-adhoc-1")
   OF 2:
    RETURN("urn:cerner:api:ml-clinical-reporting-expedite-1")
   OF 3:
    RETURN("urn:cerner:api:ml-clinical-reporting-expedite-1")
   OF 4:
    RETURN("urn:cerner:api:ml-clinical-reporting-distribution-1")
   OF 5:
    RETURN("urn:cerner:api:ml-clinical-reporting-docservice-1")
   OF 6:
    RETURN("urn:cerner:api:ml-clinical-reporting-conceptservice:1")
   ELSE
    RETURN("")
  ENDCASE
 END ;Subroutine
 SUBROUTINE (getserviceurlfromservicedirectory(servicekey=vc) =vc WITH protect)
   CALL log_message("Enter GetServiceUrlFromserviceDirectory()",log_level_debug)
   DECLARE serviceurl = vc WITH protect, noconstant("")
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hheadershandle = i4 WITH protect, noconstant(0)
   DECLARE hcustomheaderhandle = i4 WITH protect, noconstant(0)
   DECLARE jstate = i4 WITH protect
   DECLARE jsonresponse = vc WITH protect, noconstant("")
   DECLARE statuscode = i4 WITH protect, noconstant(0)
   DECLARE statusdesc = vc WITH protect, noconstant("")
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE xrserviceurl = vc WITH protect, noconstant("")
   IF (size(trim(servicekey),1)=0)
    CALL log_message("Service key passed in is empty - invalid.",log_level_error)
    RETURN(xrserviceurl)
   ENDIF
   CALL lookforservicedirectoryurl(null)
   CALL log_message(build2("Service directory url: ",servicedirurl),log_level_debug)
   IF (size(trim(servicedirurl),1)=0)
    CALL log_message("Service directory url not found.",log_level_info)
    RETURN(xrserviceurl)
   ENDIF
   SET serviceurl = build2(servicedirurl,"/keys/",servicekey,".json")
   CALL log_message(build2("Service lookup url: ",serviceurl),log_level_debug)
   SET stat = initializehttprequest(serviceurl,"","",hrequest,hheadershandle,
    hcustomheaderhandle)
   IF (stat=0)
    CALL log_message(build2("Error initializeHttpRequest for service directory url: ",serviceurl),
     log_level_error)
    CALL closesrvhandles(hrequest,hheadershandle)
    RETURN(xrserviceurl)
   ENDIF
   SET stat = executehttprequest(hrequest,hheadershandle,hcustomheaderhandle,statuscode,statusdesc,
    jsonresponse)
   IF (stat=0)
    CALL log_message(build2("Error executeHttpRequest for service directory url.",serviceurl),
     log_level_error)
    CALL closesrvhandles(hrequest,hheadershandle)
    RETURN(xrserviceurl)
   ENDIF
   CALL echo(concat("jsonResponse: ",jsonresponse))
   IF (statuscode >= 200
    AND statuscode < 300)
    SET jstate = cnvtjsontorec(build('{"jsonrec",',jsonresponse,"}"))
    IF (jstate=1)
     SET xrserviceurl = jsonrec->link
     IF (validate(debug_ind,0))
      CALL echo(build("jsonrec link: ",jsonrec->link))
     ENDIF
    ELSE
     CALL log_message("Error converting json string to record",log_level_error)
    ENDIF
   ELSE
    CALL log_message(build2("Error retrieving XR service URL from Service Diectory -- service key: ",
      servicekey," -- Http status: ",statuscode),log_level_info)
   ENDIF
   SET reply->service_directory_url = servicedirurl
   CALL closesrvhandles(hrequest,hheadershandle)
   CALL log_message("Exit GetServiceUrlFromserviceDirectory()",log_level_debug)
   RETURN(xrserviceurl)
 END ;Subroutine
 SUBROUTINE (closesrvhandles(handleone=i4(ref),handletwo=i4(ref)) =i4 WITH protect)
   CALL log_message("Enter closeSRVHandles()",log_level_debug)
   CALL log_message(concat("Preparing to close hRequest:",trim(cnvtstring(handleone)),
     ", hHeadersHandle:",trim(cnvtstring(handletwo)),"."),log_level_debug)
   IF (handleone != 0)
    SET stat = uar_srv_closehandle(handleone)
    SET handleone = 0
   ENDIF
   IF (handletwo != 0)
    SET stat = uar_srv_closehandle(handletwo)
    SET handletwo = 0
   ENDIF
   CALL log_message(concat("Closed and reset hRequest:",trim(cnvtstring(handleone)),
     ", hHeadersHandle:",trim(cnvtstring(handletwo)),"."),log_level_debug)
   CALL log_message("Exit closeSRVHandles()",log_level_debug)
 END ;Subroutine
 SUBROUTINE lookforservicedirectoryurl(null)
   CALL log_message("Enter LookForServiceDirectoryURL()",log_level_debug)
   SET simpledomain = trim(cnvtlower(logical("environment")),3)
   IF (validate(debug_ind,0))
    CALL echo(build2("simpleDomain:--",simpledomain))
   ENDIF
   CALL log_message(build2("simpleDomain: ",simpledomain),log_level_debug)
   IF (cursys=cursys2)
    CALL getcanonicaldomain(aixcommand)
    CALL lookfordns(aixcommand)
   ELSE
    CALL getcanonicaldomain(hpuxcommand)
    CALL lookfordns(hpuxcommand)
   ENDIF
   CALL log_message("Exit LookForServiceDirectoryURL()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (getcanonicaldomain(cmdline=vc) =null WITH protect)
   CALL log_message("In GetCanonicalDomain()",log_level_debug)
   DECLARE begin_dttm_getcanonicaldomain = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE tempfile = vc WITH protect, noconstant("")
   DECLARE tcppos = i4 WITH protect, noconstant(0)
   DECLARE startpos = i4 WITH protect, noconstant(0)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   SET tempfile = getuniquefilename("xrenv")
   SET tempdcl = build2("_cerner_",simpledomain,"_mqclient._tcp")
   SET dclcom = build2(cmdline," ",trim(tempdcl,3)," >> ",tempfile)
   IF (validate(debug_ind,0))
    CALL echo(build2("DCLCOM ",dclcom))
   ENDIF
   SET status = 0
   CALL dcl(dclcom,size(trim(dclcom)),status)
   FREE DEFINE rtl
   DEFINE rtl tempfile
   SELECT INTO "nl:"
    FROM rtlt r
    DETAIL
     dcloutput = trim(r.line,3)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build2("dclOutput ",dcloutput))
   ENDIF
   CALL log_message(build2("dclOutput: ",dcloutput),log_level_debug)
   SET tcppos = findstring("._tcp.",dcloutput)
   SET startpos = (tcppos+ 6)
   SET endpos = findstring(char(32),dcloutput,startpos)
   SET zonename = substring(startpos,(endpos - startpos),dcloutput)
   IF (validate(debug_ind,0))
    CALL echo(build2("zonename ",zonename))
   ENDIF
   SET canonicaldomainname = concat(trim(simpledomain,3),".",trim(zonename,3))
   SET reply->canonicaldomainname = canonicaldomainname
   IF (validate(debug_ind,0))
    CALL echo(build2("canonicalDomainName  ",canonicaldomainname))
   ENDIF
   CALL log_message(build2("Exit GetCanonicalDomain(), Elapsed time in seconds: ",datetimediff(
      cnvtdatetime(sysdate),begin_dttm_getcanonicaldomain,5)),log_level_debug)
   CALL deletetempfile(tempfile)
 END ;Subroutine
 SUBROUTINE (lookfordns(cmdline=vc) =null WITH protect)
   CALL log_message("In LookForDNS()",log_level_debug)
   DECLARE begin_dttm_lookfordns = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE nssl = i2 WITH protect, noconstant(1)
   SET tempdcl = build2("_cerner_svcdirssl_",simpledomain,"._tcp.",zonename)
   CALL getservicedirectoryurl(tempdcl,cmdline)
   IF (validate(debug_ind,0))
    CALL echo(build("1:--",servicedirurl))
   ENDIF
   IF (servicedirurl="")
    SET tempdcl = build2("_cerner_svcdir_",simpledomain,"._tcp.",zonename)
    CALL getservicedirectoryurl(tempdcl,cmdline)
    SET nssl = 0
    IF (validate(debug_ind,0))
     CALL echo(build("2:--",servicedirurl))
    ENDIF
   ENDIF
   IF (servicedirurl="")
    SET tempdcl = build2("_cerner_svcdirssl._tcp.",zonename)
    CALL getservicedirectoryurl(tempdcl,cmdline)
    SET nssl = 1
    IF (validate(debug_ind,0))
     CALL echo(build("3:--",servicedirurl))
    ENDIF
   ENDIF
   IF (servicedirurl="")
    SET tempdcl = build2("_cerner_svcdir._tcp.",zonename)
    CALL getservicedirectoryurl(tempdcl,cmdline)
    SET nssl = 0
    IF (validate(debug_ind,0))
     CALL echo(build("4:--",servicedirurl))
    ENDIF
   ENDIF
   IF (servicedirurl="")
    CALL echo("LookForDNS, Cannot find serv.dir.rec: Service Directory record is blank")
    CALL log_message("LookForDNS, Cannot find serv.dir.rec: Service Directory record is blank",
     log_level_debug)
    RETURN
   ENDIF
   IF (nssl=1)
    SET servicedirurl = build2("https://",servicedirurl,"/services-directory/authorities/",
     canonicaldomainname)
   ELSE
    SET servicedirurl = build2("http://",servicedirurl,"/services-directory/authorities/",
     canonicaldomainname)
   ENDIF
   SET reply->service_directory_url = servicedirurl
   CALL log_message(build2("serviceDirURL: ",servicedirurl),log_level_debug)
   CALL log_message(build2("Exit LookForDNS(), Elapsed time in seconds: ",datetimediff(cnvtdatetime(
       sysdate),begin_dttm_lookfordns,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getservicedirectoryurl(strdcl=vc,cmdline=vc) =null WITH protect)
   CALL log_message("In GetServiceDirectoryURL()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE tempfile = vc WITH protect, noconstant("")
   DECLARE lastspacepos = i4 WITH protect, noconstant(0)
   DECLARE lengthtoextract = i4 WITH protect, noconstant(0)
   DECLARE tempchar = vc WITH protect, noconstant("")
   DECLARE tempurl = vc WITH protect, noconstant("")
   DECLARE lastchar = vc WITH protect, noconstant("")
   SET tempfile = getuniquefilename("xrenvsd")
   SET dclcom = build2(cmdline," ",trim(strdcl,3)," >> ",tempfile)
   CALL echo(build2("DCLCOM:GetServiceDirectoryURL: ",dclcom))
   SET status = 0
   CALL dcl(dclcom,size(trim(dclcom)),status)
   IF (validate(debug_ind,0))
    CALL echo(build2("status: ",status))
   ENDIF
   IF (status > 0)
    FREE DEFINE rtl
    DEFINE rtl tempfile
    SELECT INTO "nl:"
     FROM rtlt r
     DETAIL
      dcloutput = trim(r.line,3)
     WITH nocounter
    ;end select
    CALL echo(build2("dclOutput: ",dcloutput))
    SET lastspacepos = findstring(char(32),dcloutput,1,1)
    SET lengthtoextract = (textlen(trim(dcloutput,3)) - lastspacepos)
    SET tempurl = trim(substring((lastspacepos+ 1),lengthtoextract,dcloutput),3)
    FOR (count = 1 TO textlen(trim(tempurl,3)))
     SET tempchar = trim(substring(count,1,tempurl),3)
     IF (isnumeric(tempchar)=0)
      SET servicedirurl = trim(substring(count,textlen(trim(tempurl,3)),tempurl),3)
      SET count = textlen(trim(tempurl,3))
     ENDIF
    ENDFOR
    SET lastchar = trim(substring(textlen(trim(servicedirurl,3)),1,servicedirurl),3)
    IF (lastchar=".")
     SET servicedirurl = trim(substring(1,(textlen(trim(servicedirurl,3)) - 1),servicedirurl),3)
     CALL log_message(build2("serviceDirURL: ",servicedirurl),log_level_debug)
    ENDIF
   ENDIF
   CALL deletetempfile(tempfile)
   CALL log_message(build2("Exit GetServiceDirectoryURL(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (deletetempfile(file_name=vc) =null WITH protect)
   DECLARE cmd = vc WITH protect, noconstant("")
   DECLARE cdat = i4 WITH protect, noconstant(0)
   IF (findfile(file_name,0,0)=1)
    SET cmd = concat("rm ",file_name)
    SET cdat = dcl(cmd,size(cmd,2),0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getuniquefilename(prefix=vc) =vc)
   CALL log_message("Entering getUniqueFilename()",log_level_debug)
   DECLARE file_name = vc WITH protect
   EXECUTE cpm_create_file_name prefix, "dat"
   SET file_name = cpm_cfn_info->file_name_full_path
   CALL log_message(build2("Exiting getUniqueFilename() with filename : ",file_name),log_level_debug)
   RETURN(file_name)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0))
  CALL echorecord(reply)
 ENDIF
 CALL log_message("End of script: cr_get_xr_service_url",log_level_debug)
END GO
