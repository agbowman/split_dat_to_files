CREATE PROGRAM cclut_service_health_wrapper
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
 IF (validate(reply) != 1)
  RECORD reply(
    1 domainvalidationindicator = i2
    1 getchildnodevalue = vc
    1 getattributevalue = vc
    1 getchildnodeattributevalue = vc
  )
 ENDIF
 CASE (request->subroutineflagtocall)
  OF 1:
   CALL echo("Calling GetDomainValidationIndicator()")
   SET reply->domainvalidationindicator = getdomainvalidationindicator(request->params.
    getdomainvalidationindicator.responsexml)
  OF 2:
   CALL echo("Calling getChildNodeValue()")
   SET reply->getchildnodevalue = getchildnodevalue(request->params.getchildnodevalue.handle,request
    ->params.getchildnodevalue.childname)
  OF 3:
   CALL echo("Calling getAttributeValue()")
   SET reply->getattributevalue = getattributevalue(request->params.getattributevalue.handle,request
    ->params.getattributevalue.attributename)
  OF 4:
   CALL echo("Calling getChildNodeAttributeValue()")
   SET reply->getchildnodeattributevalue = getchildnodeattributevalue(request->params.
    getchildnodeattributevalue.handle,request->params.getchildnodeattributevalue.childname,request->
    params.getchildnodeattributevalue.attributename)
 ENDCASE
#exit_script
END GO
