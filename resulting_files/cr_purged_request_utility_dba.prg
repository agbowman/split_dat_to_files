CREATE PROGRAM cr_purged_request_utility:dba
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
 IF (validate(uar_xml_parsestring,char(128))=char(128))
  DECLARE uar_xml_parsestring(xmlstring=vc,filehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getroot,char(128))=char(128))
  DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getchildcount,char(128))=char(128))
  DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getchildnode,char(128))=char(128))
  DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getnodename,char(128))=char(128))
  DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_findchildnode,char(128))=char(128))
  DECLARE uar_xml_findchildnode(nodehandle=i4(ref),nodename=vc,childhandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getnodecontent,char(128))=char(128))
  DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getattrvalue,char(128))=char(128))
  DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getattrbyname,char(128))=char(128))
  DECLARE uar_xml_getattrbyname(nodehandle=i4(ref),attrname=vc,attributehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrcount,char(128))=char(128))
  DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrbypos,char(128))=char(128))
  DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrname,char(128))=char(128))
  DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_closefile,char(128))=char(128))
  DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
 ENDIF
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE sc_ok = i4 WITH protect, constant(1)
 DECLARE current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 CALL log_message(concat("Beginning ",curprog),log_level_debug)
 SET reply->status_data.status = "F"
 SET modify maxvarlen 9999999
 IF ((request->reportrequestarchiveid > 0.0))
  IF ( NOT (logicalydomainarchive(request->reportrequestarchiveid)))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  CALL echo("Archive ID provided is not valid.")
 ENDIF
 SUBROUTINE (rundclcommand(dclcommand=vc(val)) =i4)
   CALL log_message("Entering runDCLCommand",log_level_debug)
   DECLARE dclflag = i4 WITH noconstant(0)
   DECLARE dcllen = i4 WITH constant(size(dclcommand)), protect
   DECLARE returnval = i4 WITH noconstant(0), protect
   SET returnval = dcl(dclcommand,dcllen,dclflag)
   IF (dclflag=0
    AND cursys="AIX"
    AND returnval > 255)
    SET returnval /= 256
   ENDIF
   CALL log_message("Exiting runDCLCommand",log_level_debug)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE (parsexmlbuffer(pxmlbuffer=vc,prxmlfilehandle=i4(ref)) =i4)
   DECLARE prxmlfilehandle = i4 WITH private, noconstant(0)
   DECLARE __hxmlroot = i4 WITH private, noconstant(0)
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
 SUBROUTINE (getchildelementoccurrencehandle(pelementhandle=i4,pchildname=vc,poccurrenceindex=i4) =i4
  )
   DECLARE __chidx = i4 WITH private, noconstant(0)
   DECLARE __osnumber = i4 WITH private, noconstant(0)
   DECLARE __chcnt = i4 WITH private, noconstant(0)
   DECLARE __tmpnode = i4 WITH private, noconstant(0)
   IF (pelementhandle > 0.0)
    SET __chidx = 0
    SET __osnumber = 0
    SET __chcnt = uar_xml_getchildcount(pelementhandle)
    FOR (__chidx = 1 TO __chcnt)
      SET __tmpnode = 0
      IF (uar_xml_getchildnode(pelementhandle,(__chidx - 1),__tmpnode) != sc_ok)
       RETURN(0)
      ENDIF
      IF (uar_xml_getnodename(__tmpnode)=pchildname)
       SET __osnumber += 1
       IF (__osnumber=poccurrenceindex)
        RETURN(__tmpnode)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (writexmlelement(helement=i4) =vc)
   DECLARE childidx = i4 WITH private, noconstant(0)
   DECLARE childcnt = i4 WITH private, noconstant(uar_xml_getchildcount(helement))
   DECLARE attridx = i4 WITH private, noconstant(0)
   DECLARE attrcnt = i4 WITH private, noconstant(uar_xml_getattrcount(helement))
   DECLARE mycontent = vc WITH private, noconstant(nullterm(uar_xml_getnodecontent(helement)))
   DECLARE theelementstring = vc WITH private, noconstant(nullterm(concat(nullterm("<"),nullterm(
       uar_xml_getnodename(helement)))))
   DECLARE thechildelementstring = vc WITH private, noconstant(nullterm(""))
   IF (attrcnt=0
    AND childcnt=0
    AND mycontent="")
    RETURN(nullterm(concat(theelementstring,"/>")))
   ENDIF
   FOR (attridx = 1 TO attrcnt)
     DECLARE hattr = i4 WITH private, noconstant(0)
     CALL uar_xml_getattrbypos(helement,(attridx - 1),hattr)
     DECLARE attrname = vc WITH private, noconstant(nullterm(uar_xml_getattrname(hattr)))
     DECLARE attrvalue = vc WITH private, noconstant(nullterm(uar_xml_getattrvalue(hattr)))
     SET theelementstring = concat(theelementstring," ",attrname,'="',attrvalue,
      '"')
   ENDFOR
   IF (childcnt=0
    AND mycontent="")
    RETURN(concat(theelementstring,"/>"))
   ELSEIF (childcnt=0)
    RETURN(nullterm(concat(theelementstring,">",mycontent,"</",nullterm(uar_xml_getnodename(helement)
       ),
      ">")))
   ENDIF
   SET theelementstring = concat(theelementstring,">",mycontent)
   FOR (childidx = 1 TO childcnt)
     DECLARE hchildnode = i4 WITH private, noconstant(0)
     CALL uar_xml_getchildnode(helement,(childidx - 1),hchildnode)
     SET thechildelementstring = writexmlelement(hchildnode)
     SET theelementstring = concat(theelementstring,thechildelementstring)
   ENDFOR
   RETURN(nullterm(concat(theelementstring,"</",nullterm(uar_xml_getnodename(helement)),">")))
 END ;Subroutine
 SUBROUTINE (releasexmlresources(prxmlfilehandle=i4(ref)) =i2)
  CALL uar_xml_closefile(prxmlfilehandle)
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (logicalydomainarchive(archiveid=f8) =i2)
   CALL log_message("Entering logicalyDomainArchive",log_level_debug)
   DECLARE hxmlfile = i4 WITH protect
   DECLARE hxmlroot = i4 WITH protect
   DECLARE hrequests = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE harchiveprocess = i4 WITH protect, noconstant(0)
   DECLARE hpersonid = i4 WITH private, noconstant(0)
   DECLARE htokeninfo = i4 WITH protect, noconstant(0)
   DECLARE hactdistinfo = i4 WITH protect, noconstant(0)
   DECLARE hinactdistinfo = i4 WITH protect, noconstant(0)
   DECLARE hrdrgrplist = i4 WITH protect, noconstant(0)
   DECLARE hproctime = i4 WITH protect, noconstant(0)
   DECLARE hrundttm = i4 WITH protect, noconstant(0)
   DECLARE hcurnodeo = i4 WITH protect, noconstant(0)
   DECLARE hcurrdbsys = i4 WITH protect, noconstant(0)
   DECLARE hrequestdttm = i4 WITH protect, noconstant(0)
   DECLARE hdistinfo = i4 WITH protect, noconstant(0)
   DECLARE hrdrinfo = i4 WITH protect, noconstant(0)
   DECLARE requestidx = i4 WITH private, noconstant(1)
   DECLARE logicaldomainidx = i4 WITH protect, noconstant(0)
   DECLARE locatevalidx = i4 WITH protect, noconstant(0)
   DECLARE requestdttmtext = vc WITH private
   DECLARE requestdttm = dq8 WITH private
   DECLARE requesttime = vc WITH private
   DECLARE requestcnt = i4 WITH protect, noconstant(0)
   DECLARE nextarchiveid = f8 WITH protect, noconstant(0.0)
   DECLARE nextblobid = f8 WITH protect, noconstant(0.0)
   DECLARE fileprefix = vc WITH private, constant("aud")
   DECLARE distinfoidx = i4 WITH protect, noconstant(1)
   DECLARE rdrinfoidx = i4 WITH protect, noconstant(1)
   DECLARE batch_size = i4 WITH protect, constant(200)
   DECLARE temploopcount = i4 WITH noconstant(0), protect
   DECLARE temploopsize = i4 WITH noconstant(0), protect
   DECLARE nidx = i4 WITH protect, noconstant(0)
   DECLARE nstartidx = i4 WITH protect, noconstant(1)
   DECLARE validrequestcnt = i4 WITH private, noconstant(0)
   FREE RECORD convertedarchives
   RECORD convertedarchives(
     1 logicaldomains[*]
       2 logicaldomainid = f8
       2 currentarchiveid = f8
       2 nextarchiveid = f8
       2 nextlongblobid = f8
       2 archivezipfilename = vc
       2 archivexmlfilename = vc
       2 minrequestdatetime = dq8
       2 maxrequestdatetime = dq8
       2 archivedocument
         3 requests[*]
           4 xml = vc
         3 tokeninfoxml = vc
         3 activedistributions[*]
           4 xml = vc
         3 inactivedistributions[*]
           4 xml = vc
         3 readergroups[*]
           4 xml = vc
         3 proctimexml = vc
         3 rundttmxml = vc
         3 curnodexml = vc
         3 currdbsysxml = vc
   )
   FREE RECORD requeststoconvert
   RECORD requeststoconvert(
     1 requests[*]
       2 personid = f8
       2 hrequest = i4
       2 logicaldomainid = f8
   )
   FREE RECORD myrequest
   RECORD myrequest(
     1 hrequests = i4
     1 hrequest = i4
     1 requestidx = i4
   )
   IF ( NOT (getarchivexml(archiveid,hxmlroot,hxmlfile)))
    CALL log_message("Unable to retrieve archive XML",log_level_error)
    RETURN(false)
   ENDIF
   IF (validate(debug,0)=1)
    CALL echo(build2("XML Root Handle:",hxmlroot))
    CALL echo(build2("XML File Handle:",hxmlfile))
   ENDIF
   SET harchiveprocess = getchildelementoccurrencehandle(hxmlroot,"archiveProcess",1)
   SET hrequests = getchildelementoccurrencehandle(harchiveprocess,"archivedRequests",1)
   SET hrequest = getchildelementoccurrencehandle(hrequests,"reportRequest",requestidx)
   IF (validate(debug,0)=1)
    CALL echo("Parsing requests from XML")
   ENDIF
   SET myrequest->hrequests = hrequests
   SET myrequest->hrequest = hrequest
   SET myrequest->requestidx = requestidx
   WHILE ((myrequest->hrequest > 0))
     EXECUTE cr_extract_purged_request  WITH replace("REQUEST",myrequest), replace(
      "OBJREQUESTSTOCONVERT",requeststoconvert)
   ENDWHILE
   SET requestcnt = size(requeststoconvert->requests,5)
   IF (validate(debug,0)=1)
    CALL echo(build("Requests found:",requestcnt))
   ENDIF
   SET temploopcount = ceil((cnvtreal(requestcnt)/ batch_size))
   SET temploopsize = (temploopcount * batch_size)
   SET stat = alterlist(requeststoconvert->requests,temploopsize)
   FOR (icount = (requestcnt+ 1) TO temploopsize)
     SET requeststoconvert->requests[icount].personid = requeststoconvert->requests[requestcnt].
     personid
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temploopcount)),
     person p
    PLAN (d
     WHERE assign(nstartidx,evaluate(d.seq,1,1,(nstartidx+ batch_size))))
     JOIN (p
     WHERE expand(nidx,nstartidx,(nstartidx+ (batch_size - 1)),p.person_id,requeststoconvert->
      requests[nidx].personid))
    HEAD REPORT
     requestidx = 0
    DETAIL
     requestidx = 1
     WHILE (requestidx > 0)
      requestidx = locateval(locatevalidx,requestidx,size(requeststoconvert->requests,5),p.person_id,
       requeststoconvert->requests[locatevalidx].personid),
      IF (requestidx > 0)
       requeststoconvert->requests[requestidx].logicaldomainid = p.logical_domain_id, requestidx += 1
      ENDIF
     ENDWHILE
    FOOT REPORT
     stat = alterlist(requeststoconvert->requests,requestcnt)
    WITH nocounter
   ;end select
   FOR (requestidx = 1 TO requestcnt)
     SET distinfoidx = 1
     SET rdrinfoidx = 1
     SET logicaldomainidx = 0
     IF ((requeststoconvert->requests[requestidx].logicaldomainid >= 0.0))
      SET logicaldomainidx = locatevalsort(locatevalidx,1,size(convertedarchives->logicaldomains,5),
       requeststoconvert->requests[requestidx].logicaldomainid,convertedarchives->logicaldomains[
       locatevalidx].logicaldomainid)
      IF (validate(debug,0)=1)
       CALL echo(build2("Currently checking logical domain:",requeststoconvert->requests[requestidx].
         logicaldomainid))
      ENDIF
      IF (logicaldomainidx <= 0)
       IF (size(convertedarchives->logicaldomains,5)=0)
        IF (validate(debug,0)=1)
         CALL echo("no logical domains added at all yet")
        ENDIF
        SET logicaldomainidx = 1
        SET stat = alterlist(convertedarchives->logicaldomains,1)
       ELSE
        IF (validate(debug,0)=1)
         CALL echo("adding logical domain")
        ENDIF
        SET logicaldomainidx = (abs(logicaldomainidx)+ 1)
        SET stat = alterlist(convertedarchives->logicaldomains,(size(convertedarchives->
          logicaldomains,5)+ 1),(logicaldomainidx - 1))
       ENDIF
       SET convertedarchives->logicaldomains[logicaldomainidx].logicaldomainid = requeststoconvert->
       requests[requestidx].logicaldomainid
       SET convertedarchives->logicaldomains[logicaldomainidx].currentarchiveid = archiveid
       SET convertedarchives->logicaldomains[logicaldomainidx].maxrequestdatetime = cnvtdatetime(
        "01-JAN-1800")
       SET convertedarchives->logicaldomains[logicaldomainidx].minrequestdatetime = cnvtdatetime(
        "31-DEC-2100")
       SET htokeninfo = getchildelementoccurrencehandle(harchiveprocess,"tokenInfo",1)
       SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.tokeninfoxml =
       writexmlelement(htokeninfo)
       SET hactdistinfo = getchildelementoccurrencehandle(harchiveprocess,"actDistInfo",1)
       IF (hactdistinfo != 0)
        SET hdistinfo = getchildelementoccurrencehandle(hactdistinfo,"distInfo",distinfoidx)
        SET stat = alterlist(convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
         activedistributions,uar_xml_getchildcount(hactdistinfo))
        WHILE (hdistinfo > 0)
          SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
          activedistributions[distinfoidx].xml = writexmlelement(hdistinfo)
          SET distinfoidx += 1
          SET hdistinfo = getchildelementoccurrencehandle(hactdistinfo,"distInfo",distinfoidx)
        ENDWHILE
       ENDIF
       SET distinfoidx = 1
       SET hinactdistinfo = getchildelementoccurrencehandle(harchiveprocess,"inactDistInfo",1)
       IF (hinactdistinfo != 0)
        SET hdistinfo = getchildelementoccurrencehandle(hinactdistinfo,"distInfo",distinfoidx)
        SET stat = alterlist(convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
         inactivedistributions,uar_xml_getchildcount(hinactdistinfo))
        WHILE (hdistinfo > 0)
          SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
          inactivedistributions[distinfoidx].xml = writexmlelement(hdistinfo)
          SET distinfoidx += 1
          SET hdistinfo = getchildelementoccurrencehandle(hinactdistinfo,"distInfo",distinfoidx)
        ENDWHILE
       ENDIF
       SET hrdrgrplist = getchildelementoccurrencehandle(harchiveprocess,"rdrGrpList",1)
       IF (hrdrgrplist != 0)
        SET hrdrinfo = getchildelementoccurrencehandle(hrdrgrplist,"rdrInfo",rdrinfoidx)
        SET stat = alterlist(convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
         readergroups,uar_xml_getchildcount(hrdrgrplist))
        WHILE (hrdrinfo > 0)
          SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.readergroups[
          rdrinfoidx].xml = writexmlelement(hrdrinfo)
          SET rdrinfoidx += 1
          SET hrdrinfo = getchildelementoccurrencehandle(hrdrgrplist,"rdrInfo",rdrinfoidx)
        ENDWHILE
       ENDIF
       SET hproctime = getchildelementoccurrencehandle(harchiveprocess,"procTime",1)
       SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.proctimexml =
       writexmlelement(hproctime)
       SET hrundttm = getchildelementoccurrencehandle(harchiveprocess,"runDtTm",1)
       SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.rundttmxml =
       writexmlelement(hrundttm)
       SET hcurnodeo = getchildelementoccurrencehandle(harchiveprocess,"curnode",1)
       SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.curnodexml =
       writexmlelement(hcurnodeo)
       SET hcurrdbsys = getchildelementoccurrencehandle(harchiveprocess,"currdbsys",1)
       SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.currdbsysxml =
       writexmlelement(hcurrdbsys)
      ENDIF
     ENDIF
     IF (logicaldomainidx > 0)
      IF (uar_xml_getattrbyname(requeststoconvert->requests[requestidx].hrequest,"requestDtTm",
       hrequestdttm)=sc_ok)
       SET requestdttmtext = uar_xml_getattrvalue(hrequestdttm)
      ENDIF
      SET requesttime = substring(12,8,requestdttmtext)
      SET requestdttm = cnvtdatetime(cnvtdate2(requestdttmtext,"YYYY-MM-DD"),cnvttime2(requesttime,
        "HH:MM:SS"))
      IF (validate(debug,0)=1)
       CALL echo(requestdttmtext)
       CALL echo(requesttime)
       CALL echo(format(requestdttm,";;Q"))
      ENDIF
      IF ((requestdttm > convertedarchives->logicaldomains[logicaldomainidx].maxrequestdatetime))
       SET convertedarchives->logicaldomains[logicaldomainidx].maxrequestdatetime = cnvtdatetime(
        requestdttm)
      ENDIF
      IF ((requestdttm < convertedarchives->logicaldomains[logicaldomainidx].minrequestdatetime))
       SET convertedarchives->logicaldomains[logicaldomainidx].minrequestdatetime = cnvtdatetime(
        requestdttm)
      ENDIF
      SET validrequestcnt = (size(convertedarchives->logicaldomains[logicaldomainidx].archivedocument
       .requests,5)+ 1)
      SET stat = alterlist(convertedarchives->logicaldomains[logicaldomainidx].archivedocument.
       requests,validrequestcnt)
      SET convertedarchives->logicaldomains[logicaldomainidx].archivedocument.requests[
      validrequestcnt].xml = writexmlelement(requeststoconvert->requests[requestidx].hrequest)
     ELSE
      IF (validate(debug,0)=1)
       CALL echo(build2("Person: ",requeststoconvert->requests[requestidx].personid,
         " was not found. Unable to convert this request."))
      ENDIF
     ENDIF
   ENDFOR
   FREE RECORD requeststoconvert
   CALL releasexmlresources(hxmlfile)
   IF (size(convertedarchives->logicaldomains,5) > 0)
    CALL echo(build("Logical Domains Found:",size(convertedarchives->logicaldomains,5)))
    FOR (logicaldomainidx = 1 TO size(convertedarchives->logicaldomains,5))
      CALL echo(build2("Logical Domain: ",convertedarchives->logicaldomains[logicaldomainidx].
        logicaldomainid))
    ENDFOR
   ELSE
    IF (validate(debug,0)=1)
     CALL echorecord(convertedarchives)
    ENDIF
    CALL log_message(
     "Unable to convert XML. XML File either contains no requests or no valid requests.",
     log_level_warning)
    RETURN(true)
   ENDIF
   IF (size(convertedarchives->logicaldomains,5)=1)
    IF ((convertedarchives->logicaldomains[1].logicaldomainid=0.0))
     CALL echo(
      "Archive contains a single logical domain which is the default logical domain. No conversion necessary."
      )
     RETURN(true)
    ELSE
     UPDATE  FROM cr_report_request_archive cr
      SET cr.logical_domain_id = convertedarchives->logicaldomains[1].logicaldomainid, cr.updt_id =
       reqinfo->updt_id, cr.updt_dt_tm = cnvtdatetime(curdate,curtime),
       cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
       updt_applctx
      WHERE (cr.report_request_archive_id=convertedarchives->logicaldomains[1].currentarchiveid)
      WITH nocounter
     ;end update
     IF (curqual=1)
      CALL echo(build2("Archive ",convertedarchives->logicaldomains[1].currentarchiveid,
        " Logical Domain successfully updated"))
      RETURN(true)
     ELSE
      CALL log_message(build2("Unable to update archive ",convertedarchives->logicaldomains[1].
        currentarchiveid," Logical Domain"),log_level_error)
      RETURN(false)
     ENDIF
    ENDIF
   ENDIF
   FOR (logicaldomainidx = 1 TO size(convertedarchives->logicaldomains,5))
     IF (logicaldomainidx > 1)
      SELECT INTO "nl:"
       nextseqnum = seq(chart_seq,nextval)"######################;rp0"
       FROM dual
       DETAIL
        nextarchiveid = nextseqnum
       WITH format, nocounter
      ;end select
     ELSE
      SET nextarchiveid = convertedarchives->logicaldomains[logicaldomainidx].currentarchiveid
     ENDIF
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
      FROM dual
      DETAIL
       nextblobid = nextseqnum
      WITH format, nocounter
     ;end select
     SET convertedarchives->logicaldomains[logicaldomainidx].nextarchiveid = nextarchiveid
     SET convertedarchives->logicaldomains[logicaldomainidx].nextlongblobid = nextblobid
     SET convertedarchives->logicaldomains[logicaldomainidx].archivexmlfilename = build(fileprefix,
      format(cnvtdatetime(current_date_time),"#################;P0"),"-",cnvtstring(convertedarchives
       ->logicaldomains[logicaldomainidx].logicaldomainid,15,0),".xml")
     SET convertedarchives->logicaldomains[logicaldomainidx].archivezipfilename = build(fileprefix,
      format(convertedarchives->logicaldomains[logicaldomainidx].nextarchiveid,
       "#####################;P0"),"-",cnvtstring(convertedarchives->logicaldomains[logicaldomainidx]
       .logicaldomainid,15,0),".zip")
     IF (validate(debug,0)=1)
      CALL echorecord(convertedarchives)
     ENDIF
     IF ( NOT (savearchive(convertedarchives,logicaldomainidx)))
      CALL log_message("Unable to zip the XML archive",log_level_error)
      RETURN(false)
     ENDIF
   ENDFOR
   CALL log_message("Exiting logicalyDomainArchive",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (savearchive(archivestozip=vc(ref),logicaldomainindex=i4) =i2)
   CALL log_message("Entering saveArchive",log_level_debug)
   DECLARE xml_version_encoding = vc WITH protect, constant(
    "<?xml version='1.0' encoding='ISO-8859-1'?>")
   DECLARE certempdirectory = vc WITH private, constant("cer_temp:")
   DECLARE xmlfilepath = vc WITH protect, constant(concat(certempdirectory,archivestozip->
     logicaldomains[logicaldomainindex].archivexmlfilename))
   DECLARE zipcommand = vc WITH protect
   DECLARE zip_successful = i4 WITH private, constant(1)
   DECLARE zipfile = gvc WITH protect
   DECLARE zipfilesize = i4 WITH protect
   DECLARE requestcnt = i4 WITH protect, constant(size(archivestozip->logicaldomains[
     logicaldomainindex].archivedocument.requests,5))
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(1))
    HEAD REPORT
     col 0,
     CALL print(xml_version_encoding), row + 1,
     col + 1,
     CALL print("<archiveProcess>"), row + 1,
     col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.tokeninfoxml)
    DETAIL
     row + 1
    FOOT REPORT
     donothing = 0
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(size(archivestozip->logicaldomains[logicaldomainindex].
       archivedocument.activedistributions,5)))
    HEAD REPORT
     row + 1, col + 1,
     CALL print("<actDistInfo>")
    DETAIL
     row + 1, col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.
     activedistributions[d.seq].xml)
     IF (d.seq < value(size(archivestozip->logicaldomains[logicaldomainindex].archivedocument.
       activedistributions,5)))
      row + 1
     ENDIF
    FOOT REPORT
     col + 1,
     CALL print("</actDistInfo>")
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(size(archivestozip->logicaldomains[logicaldomainindex].
       archivedocument.inactivedistributions,5)))
    HEAD REPORT
     row + 1, col + 1,
     CALL print("<inactDistInfo>")
    DETAIL
     row + 1, col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.
     inactivedistributions[d.seq].xml)
     IF (d.seq < value(size(archivestozip->logicaldomains[logicaldomainindex].archivedocument.
       inactivedistributions,5)))
      row + 1
     ENDIF
    FOOT REPORT
     col + 1,
     CALL print("</inactDistInfo>")
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(size(archivestozip->logicaldomains[logicaldomainindex].
       archivedocument.readergroups,5)))
    HEAD REPORT
     row + 1, col + 1,
     CALL print("<rdrGrpList>")
    DETAIL
     row + 1, col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.readergroups[d.seq]
     .xml)
     IF (d.seq < value(size(archivestozip->logicaldomains[logicaldomainindex].archivedocument.
       readergroups,5)))
      row + 1
     ENDIF
    FOOT REPORT
     col + 1,
     CALL print("</rdrGrpList>")
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(requestcnt))
    HEAD REPORT
     row + 1, col + 1,
     CALL print("<archivedRequests>")
    DETAIL
     row + 1, col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.requests[d.seq].xml
     )
     IF (d.seq < value(requestcnt))
      row + 1
     ENDIF
    FOOT REPORT
     col + 1,
     CALL print("</archivedRequests>")
    WITH format = variable, maxcol = 32000, noformfeed,
     maxrow = 1, append
   ;end select
   SELECT INTO value(xmlfilepath)
    d.seq
    FROM (dummyt d  WITH seq = value(1))
    HEAD REPORT
     donothing = 0
    DETAIL
     row + 1
    FOOT REPORT
     col + 1,
     CALL print(build("<requestCount>",requestcnt,"</requestCount>")), col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.proctimexml), col
      + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.rundttmxml),
     col + 1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.curnodexml), col +
     1,
     CALL print(archivestozip->logicaldomains[logicaldomainindex].archivedocument.currdbsysxml), col
      + 1,
     CALL print("</archiveProcess>")
    WITH format = variable, maxcol = 2000, noformfeed,
     maxrow = 1, append
   ;end select
   SET zipcommand = concat("zip -9jm ","$cer_temp/",archivestozip->logicaldomains[logicaldomainindex]
    .archivezipfilename," ","$cer_temp/",
    archivestozip->logicaldomains[logicaldomainindex].archivexmlfilename)
   SET zipcommand = concat("$cer_exe/",zipcommand)
   IF (validate(debug,0)=1)
    CALL echo(concat("Zip command: ",zipcommand))
   ENDIF
   IF (rundclcommand(zipcommand) > zip_successful)
    CALL log_message(concat("Failed to zip: ",archivestozip->logicaldomains[logicaldomainindex].
      archivezipfilename),log_level_error)
    RETURN(false)
   ENDIF
   IF ( NOT (readinfile(certempdirectory,archivestozip->logicaldomains[logicaldomainindex].
    archivezipfilename,zipfile,zipfilesize)))
    CALL log_message("Failed to read ZIP file in",log_level_error)
    RETURN(false)
   ENDIF
   CALL deletefile(certempdirectory,archivestozip->logicaldomains[logicaldomainindex].
    archivezipfilename)
   INSERT  FROM long_blob lb
    SET lb.active_ind = 1, lb.active_status_cd = reqdata->active_status_cd, lb.blob_length =
     zipfilesize,
     lb.long_blob = zipfile, lb.long_blob_id = archivestozip->logicaldomains[logicaldomainindex].
     nextlongblobid, lb.parent_entity_name = "CR_REPORT_REQUEST_ARCHIVE",
     lb.parent_entity_id = archivestozip->logicaldomains[logicaldomainindex].nextarchiveid, lb
     .updt_id = reqinfo->updt_id, lb.updt_dt_tm = cnvtdatetime(curdate,curtime),
     lb.updt_cnt = 1, lb.updt_task = reqinfo->updt_task, lb.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    CALL log_message("Failed to insert long blob",log_level_error)
    RETURN(false)
   ENDIF
   IF (logicaldomainindex=1)
    UPDATE  FROM cr_report_request_archive cr
     SET cr.archived_report_nbr = requestcnt, cr.logical_domain_id = archivestozip->logicaldomains[
      logicaldomainindex].logicaldomainid, cr.long_blob_id = archivestozip->logicaldomains[
      logicaldomainindex].nextlongblobid,
      cr.max_request_dt_tm = cnvtdatetime(archivestozip->logicaldomains[logicaldomainindex].
       maxrequestdatetime), cr.min_request_dt_tm = cnvtdatetime(archivestozip->logicaldomains[
       logicaldomainindex].minrequestdatetime), cr.updt_id = reqinfo->updt_id,
      cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_task =
      reqinfo->updt_task,
      cr.updt_applctx = reqinfo->updt_applctx
     WHERE (cr.report_request_archive_id=archivestozip->logicaldomains[logicaldomainindex].
     currentarchiveid)
     WITH nocounter
    ;end update
    IF (curqual != 1)
     CALL log_message("Failed to update existing archive row",log_level_error)
     RETURN(false)
    ENDIF
   ELSE
    INSERT  FROM cr_report_request_archive cr
     SET cr.archived_report_nbr = requestcnt, cr.archived_dt_tm = cnvtdatetime(current_date_time), cr
      .report_request_archive_id = archivestozip->logicaldomains[logicaldomainindex].nextarchiveid,
      cr.long_blob_id = archivestozip->logicaldomains[logicaldomainindex].nextlongblobid, cr
      .min_request_dt_tm = cnvtdatetime(archivestozip->logicaldomains[logicaldomainindex].
       minrequestdatetime), cr.max_request_dt_tm = cnvtdatetime(archivestozip->logicaldomains[
       logicaldomainindex].maxrequestdatetime),
      cr.updt_id = reqinfo->updt_id, cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_cnt = 1,
      cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->updt_applctx, cr
      .logical_domain_id = archivestozip->logicaldomains[logicaldomainindex].logicaldomainid
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     CALL log_message("Failed to insert archive row",log_level_error)
     RETURN(false)
    ENDIF
   ENDIF
   CALL log_message("Exiting saveArchive",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getarchivexml(archiveid=f8,xmlroothandle=i4(ref),xmlfilehandle=i4(ref)) =i2)
   CALL log_message("Entering getArchiveXML",log_level_debug)
   DECLARE certempdirectory = vc WITH private, constant("cer_temp:")
   DECLARE certempdirectoryalias = vc WITH private, constant("$cer_temp")
   DECLARE cerexedirectoryalias = vc WITH private, constant("$cer_exe")
   DECLARE txtfilename = vc WITH protect
   DECLARE zipfilename = vc WITH protect
   DECLARE xmlfilename = vc WITH private
   DECLARE archivezipfile = gvc WITH protect
   DECLARE textfile = gvc WITH protect
   DECLARE archivexmlfile = gvc WITH protect
   DECLARE filesize = i4 WITH protect
   DECLARE zipcommand = vc WITH private
   DECLARE zip_successful = i4 WITH private, constant(1)
   DECLARE xmlfileprefix = vc WITH private, constant("aud")
   DECLARE xmlfileextension = vc WITH private, constant(".xml")
   DECLARE xmlfilenamestartidx = i4 WITH private, noconstant(0)
   DECLARE xmlfilenameendidx = i4 WITH private, noconstant(0)
   SELECT INTO "nl:"
    FROM cr_report_request_archive cr,
     long_blob lb
    PLAN (cr
     WHERE cr.report_request_archive_id=archiveid)
     JOIN (lb
     WHERE lb.long_blob_id=cr.long_blob_id)
    HEAD REPORT
     donothing = 0
    HEAD lb.long_blob_id
     zipfilename = build("aud",format(cr.report_request_archive_id,"#####################;P0"),".zip"
      ), txtfilename = build("aud",format(cr.report_request_archive_id,"#####################;P0"),
      ".txt"), outbuf = fillstring(4096," ")
    DETAIL
     retlen = 1, offset = 0
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,lb.long_blob)
       IF (retlen=size(outbuf))
        archivezipfile = notrim(concat(archivezipfile,outbuf))
       ELSEIF (retlen > 0)
        archivezipfile = notrim(concat(archivezipfile,substring(1,retlen,outbuf)))
       ENDIF
       offset += retlen
     ENDWHILE
    FOOT  lb.long_blob_id
     donothing = 0
    WITH nocounter
   ;end select
   IF (size(archivezipfile) <= 0)
    CALL log_message("Unable to retrieve the ZIP file",log_level_error)
    RETURN(false)
   ENDIF
   IF ( NOT (writeoutfile(archivezipfile,certempdirectory,zipfilename)))
    CALL log_message(concat("Unable to write out ZIP file to: ",certempdirectory,zipfilename),
     log_level_error)
    RETURN(false)
   ENDIF
   SET zipcommand = concat("unzip -d ",certempdirectoryalias,"/ -o ",certempdirectoryalias,"/",
    zipfilename)
   SET zipcommand = concat(cerexedirectoryalias,"/",zipcommand)
   IF (validate(debug,0)=1)
    CALL echo(concat("Zip command: ",zipcommand))
   ENDIF
   IF (rundclcommand(zipcommand) > zip_successful)
    CALL log_message(concat("Failed to unzip: ",zipfilename),log_level_error)
    RETURN(false)
   ENDIF
   SET zipcommand = concat("unzip -ov ",certempdirectoryalias,"/",zipfilename," > ",
    certempdirectoryalias,"/",txtfilename)
   SET zipcommand = concat(cerexedirectoryalias,"/",zipcommand)
   IF (validate(debug,0)=1)
    CALL echo(concat("Zip command: ",zipcommand))
   ENDIF
   IF (rundclcommand(zipcommand) > zip_successful)
    CALL log_message(concat("Failed to unzip: ",zipfilename," to text file"),log_level_error)
    RETURN(false)
   ENDIF
   IF ( NOT (readinfile(certempdirectory,txtfilename,textfile,filesize)))
    CALL log_message(concat("Unable to read in text file to: ",certempdirectory,txtfilename),
     log_level_error)
    RETURN(false)
   ENDIF
   SET xmlfilenamestartidx = findstring(xmlfileprefix,textfile,1,1)
   SET xmlfilenameendidx = ((findstring(xmlfileextension,textfile,1,0)+ size(xmlfileextension)) -
   xmlfilenamestartidx)
   SET xmlfilename = substring(xmlfilenamestartidx,xmlfilenameendidx,textfile)
   IF ( NOT (readinfile(certempdirectory,xmlfilename,archivexmlfile,filesize)))
    CALL log_message(concat("Unable to read in text file to: ",certempdirectory,xmlfilename),
     log_level_error)
    RETURN(false)
   ENDIF
   CALL deletefile(certempdirectory,zipfilename)
   CALL deletefile(certempdirectory,txtfilename)
   CALL deletefile(certempdirectory,xmlfilename)
   SET xmlroothandle = parsexmlbuffer(archivexmlfile,xmlfilehandle)
   IF (((xmlroothandle <= 0) OR (xmlfilehandle <= 0)) )
    CALL log_message("Unable to parse XML",log_level_error)
    RETURN(false)
   ENDIF
   CALL log_message("Exiting getArchiveXML",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (writeoutfile(filecontents=gvc,directory=vc,filename=vc) =i2)
   CALL log_message("Entering writeOutFile",log_level_debug)
   FREE RECORD eksputrequest
   RECORD eksputrequest(
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
   FREE RECORD eksputreply
   RECORD eksputreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET eksputrequest->source_dir = directory
   SET eksputrequest->source_filename = filename
   SET eksputrequest->isblob = "1"
   SET eksputrequest->document_size = size(filecontents)
   SET eksputrequest->document = filecontents
   EXECUTE eks_put_source  WITH replace("REQUEST",eksputrequest), replace("REPLY",eksputreply)
   IF ((eksputreply->status_data.status != "S"))
    CALL echorecord(eksputrequest)
    CALL echorecord(eksputreply)
    RETURN(false)
   ENDIF
   CALL log_message("Exiting writeOutFile",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (readinfile(directory=vc,filename=vc,filecontents=gvc(ref),filesize=i4(ref)) =i2)
   CALL log_message("Entering readInFile",log_level_debug)
   FREE RECORD ekssourcerequest
   RECORD ekssourcerequest(
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   FREE RECORD ekssourcereply
   RECORD ekssourcereply(
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
   SET ekssourcerequest->module_dir = directory
   SET ekssourcerequest->module_name = filename
   SET ekssourcerequest->basblob = true
   EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",ekssourcereply)
   IF ((ekssourcereply->status_data.status != "S"))
    CALL echorecord(ekssourcerequest)
    CALL echorecord(ekssourcereply)
    CALL echo("Unable to read in file")
    RETURN(false)
   ENDIF
   SET filecontents = ekssourcereply->data_blob
   SET filesize = ekssourcereply->data_blob_size
   CALL log_message("Exiting readInFile",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (deletefile(directory=vc,filename=vc) =i2)
   CALL log_message("Entering deleteFile",log_level_debug)
   IF ( NOT (findfile(concat(directory,filename))))
    CALL echo(concat("Unable to find the specified file to delete:",directory,filename))
    RETURN(false)
   ENDIF
   IF (validate(debug,0)=1)
    CALL echo(concat("Deleting ",directory,filename))
   ENDIF
   SET stat = remove(concat(directory,filename))
   CALL log_message("Exiting deleteFile",log_level_debug)
   RETURN(true)
 END ;Subroutine
END GO
