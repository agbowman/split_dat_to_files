CREATE PROGRAM ccl_prompt_rtlfiles
 PROMPT
  "Output to File/Printer/MINE:" = "MINE"
  WITH outdev
 DECLARE uar_crmnodeperform(p1=i4(value),p2=vc(ref)) = i2 WITH image_axp = "crmrtl", image_aix =
 "libcrm.a(libcrm.o)", uar = "CrmNodePerform",
 persist
 DECLARE _app = i4 WITH protect, noconstant(0)
 DECLARE _task = i4 WITH protect, noconstant(0)
 DECLARE _happ = i4 WITH protect, noconstant(0)
 DECLARE _htask = i4 WITH protect, noconstant(0)
 DECLARE _hreq = i4 WITH protect, noconstant(0)
 DECLARE _hrep = i4 WITH protect, noconstant(0)
 DECLARE _hstat = i4 WITH protect, noconstant(0)
 DECLARE dsfilename = i4 WITH protect, noconstant(0)
 DECLARE rec = i4 WITH protect, noconstant(0)
 DECLARE iitem = i4 WITH protect, noconstant(0)
 DECLARE iitemcnt = i4 WITH protect, noconstant(0)
 DECLARE p_server = i2 WITH constant( $1), public
 DECLARE p_host = vc WITH constant(trim( $2)), public
 DECLARE p_type = vc WITH constant("RTL"), public
 DECLARE com = vc
 DECLARE _fname = vc WITH constant(cnvtlower(build(curuser,p_type,".out")))
 IF (cnvtupper(cursys)="AIX"
  AND p_host != cnvtupper(trim(curnode)))
  EXECUTE ccl_prompt_api_dataset "dataset"
  SET stat = setstatus("F")
  SET stat = makedataset(10)
  SET dsfilename = addstringfield("Filename","File Name",1,100)
  SET _app = 3070000
  SET _task = 3070001
  SET crmstatus = uar_crmbeginapp(_app,_happ)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Error! uar_CrmBeginApp failed with status: ",build(crmstatus))
   CALL echo(fillstr)
   RETURN(0)
  ELSE
   CALL echo(concat("Uar_CrmBeginApp success, app: ",build(_app)))
  ENDIF
  SET crmstatus = uar_crmbegintask(_happ,_task,_htask)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Error! uar_CrmBeginTask failed with status: ",build(crmstatus))
   CALL echo(fillstr)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ELSE
   CALL echo(concat("Uar_CrmBeginTask success, task: ",build(_task)))
  ENDIF
  SET _reqnum = 3050005
  SET crmstatus = uar_crmbeginreq(_htask,0,_reqnum,_hreq)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Invalid CrmBeginReq return status of",build(crmstatus))
   CALL echo(fillstr)
   CALL uar_crmendtask(_htask)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ELSE
   CALL echo("uar_CrmBeginReq success")
  ENDIF
  SET _hrequest = uar_crmgetrequest(_hreq)
  IF (_hrequest)
   SET stat = uar_srvsetshort(_hrequest,"servernum",p_server)
   SET stat = uar_srvsetstring(_hrequest,"hostname",nullterm(p_host))
   SET stat = uar_srvsetstring(_hrequest,"logtype",nullterm(p_type))
   CALL echo(" calling uar_CrmNodePerform()")
   SET crmstatus = uar_crmnodeperform(_hreq,nullterm(p_host))
   IF (crmstatus != 0)
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("uar_CrmNodePerform for ccl_get_rtlfiles returned status= ",build(crmstatus)
     )
    CALL echo(fillstr)
   ELSE
    CALL echo(" uar_CrmNodePerform() success")
    SET _hreply = uar_crmgetreply(_hreq)
    SET _hstat = uar_srvgetstruct(_hreply,"status_data")
    SET _status = uar_srvgetstringptr(_hstat,"status")
    CALL echo(concat("Called process returned: ",_status))
    IF (_status != "S")
     SET fillstr = fillstring(255," ")
     SET fillstr = concat("ccl_get_rtlfiles returned status= ",build(_status))
     CALL echo(fillstr)
    ELSE
     SET iitemcnt = uar_srvgetitemcount(_hreply,"data")
     FOR (iitem = 0 TO (iitemcnt - 1))
       SET _hitem = uar_srvgetitem(_hreply,"data",iitem)
       SET buffertext = uar_srvgetstringptr(_hitem,"buffer")
       SET fillstr = fillstring(255," ")
       SET fillstr = concat("Filename= ",buffertext)
       CALL echo(fillstr)
       SET rec = getnextrecord(0)
       SET stat = setstringfield(rec,dsfilename,buffertext)
     ENDFOR
    ENDIF
   ENDIF
  ELSE
   SET fillstr = fillstring(255," ")
   SET fillstr = "Invalid hRequest handle returned from CrmGetRequest"
   CALL echo(fillstr)
  ENDIF
  SET stat = closedataset(0)
  SET stat = setstatus("S")
  IF (_hreq > 0)
   CALL uar_crmendreq(_hreq)
   CALL uar_crmendtask(_htask)
   CALL uar_crmendapp(_happ)
   SET _hreq = 0
  ENDIF
 ELSE
  CASE (p_type)
   OF "RTL":
    IF (cursys="AIX")
     SET com = concat("cd $CCLUSERDIR|rm ",_fname,".out")
     CALL dcl(com,size(trim(com)),0)
     SET com = concat("cd $CCLUSERDIR|ls rtlsrv*.log >> ",_fname)
    ELSE
     SET com = concat("$dir ccluserdir:rtlsrv*",build(p_server),"*.log /date/versions=2 /output=",
      _fname," /col=1")
    ENDIF
    CALL dcl(com,size(trim(com)),0)
    FREE DEFINE rtl
    DEFINE rtl _fname
    CALL echo(com)
    CALL echo(_fname)
    IF (p_server > 0)
     SELECT INTO "nl:"
      log = substring(1,30,r.line), id = substring(7,4,r.line), server = cnvtint(substring(7,4,r.line
        ))"####",
      instance = substring(12,2,r.line)
      FROM rtlt r
      WHERE r.line IN ("RTLSRV*", "rtlsrv*")
       AND p_server=cnvtint(substring(7,4,r.line))
      HEAD REPORT
       delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
       stat = alterlist(reply->data,delta)
      DETAIL
       count += 1
       IF (mod(count,delta)=1)
        stat = alterlist(reply->data,(count+ delta))
       ENDIF
       reply->data[count].buffer = concat(reportinfo(2),"$")
      FOOT REPORT
       stat = alterlist(reply->data,count)
      WITH maxrow = 1, reporthelp, check
     ;end select
    ELSE
     SELECT INTO "nl:"
      log = substring(1,30,r.line), id = substring(7,4,r.line), server = cnvtint(substring(7,4,r.line
        ))"####",
      instance = substring(12,2,r.line)
      FROM rtlt r
      WHERE ((r.line="RTLSRV*") OR (r.line="rtlsrv*"))
      HEAD REPORT
       delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
       stat = alterlist(reply->data,delta)
      DETAIL
       count += 1
       IF (mod(count,delta)=1)
        stat = alterlist(reply->data,(count+ delta))
       ENDIF
       reply->data[count].buffer = concat(reportinfo(2),"$")
      FOOT REPORT
       stat = alterlist(reply->data,count)
      WITH maxrow = 1, reporthelp, check
     ;end select
    ENDIF
    IF (cursys="AIX")
     SET _stat = remove(_fname)
    ELSE
     SET _stat = remove(build(_fname,";*"))
    ENDIF
  ENDCASE
  FREE DEFINE rtl
 ENDIF
END GO
