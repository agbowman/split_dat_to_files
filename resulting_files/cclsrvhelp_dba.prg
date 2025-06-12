CREATE PROGRAM cclsrvhelp:dba
 PROMPT
  "Output to File/Printer/MINE (MINE):" = "MINE",
  "Server Number (51):" = 51,
  "Host Name (CURNODE):" = "",
  "Server Log Name:" = ""
  WITH _outputdev, _servernumber, _host,
  _logname
 DECLARE uar_crmnodeperform(p1=i4(value),p2=vc(ref)) = i2 WITH image_axp = "crmrtl", image_aix =
 "libcrm.a(libcrm.o)", uar = "CrmNodePerform",
 persist
 IF (cnvtupper(cursys)="AIX"
  AND ( $_HOST != cnvtupper(trim(curnode))))
  DECLARE _app = i4 WITH protect, noconstant(0)
  DECLARE _task = i4 WITH protect, noconstant(0)
  DECLARE _happ = i4 WITH protect, noconstant(0)
  DECLARE _htask = i4 WITH protect, noconstant(0)
  DECLARE _hreq = i4 WITH protect, noconstant(0)
  DECLARE _hrep = i4 WITH protect, noconstant(0)
  DECLARE _hstat = i4 WITH protect, noconstant(0)
  SET _app = 3010000
  SET _task = 3011002
  SET _reqnum = 3011001
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
   SET stat = uar_srvsetstring(_hrequest,"Module_Dir","ccluserdir:")
   SET stat = uar_srvsetstring(_hrequest,"Module_Name", $_LOGNAME)
   SET stat = uar_srvsetshort(_hrequest,"bAsBlob",1)
   CALL echo(" calling uar_CrmNodePerform()")
   SET crmstatus = uar_crmnodeperform(_hreq,nullterm( $_HOST))
   IF (crmstatus != 0)
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("uar_CrmNodePerform for eks_get_source returned status= ",build(crmstatus))
    CALL echo(fillstr)
    RETURN(0)
   ELSE
    CALL echo(" uar_CrmNodePerform() success")
    SET _hreply = uar_crmgetreply(_hreq)
    SET _hstat = uar_srvgetstruct(_hreply,"status_data")
    SET _status = uar_srvgetstringptr(_hstat,"status")
    CALL echo(concat("Called process returned: ",_status))
    IF (_status != "S")
     SET fillstr = fillstring(255," ")
     SET fillstr = concat("eks_get_source returned status= ",build(_status))
     CALL echo(fillstr)
     RETURN(0)
    ELSE
     FREE RECORD datablob
     RECORD datablob(
       1 blobsize = i4
       1 blobtext = gvc
     )
     SET datablob->blobsize = uar_srvgetlong(_hreply,"data_blob_size")
     SET datablob->blobtext = uar_srvgetasisptr(_hreply,"data_blob")
     FREE RECORD putreq
     RECORD putreq(
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
     SET putreq->document = datablob->blobtext
     IF (size(putreq->document) > 0)
      SET putreq->source_filename =  $_OUTPUTDEV
      SET putreq->isblob = "1"
      SET putreq->document_size = size(putreq->document)
      FREE RECORD putreply
      EXECUTE eks_put_source  WITH replace("REQUEST","PUTREQ"), replace("REPLY","PUTREPLY")
     ELSE
      SET fillstr = fillstring(255," ")
      SET fillstr = "Invalid blob size.  Failed to retrieve the blob text"
      CALL echo(fillstr)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  DEFINE rtl  $_LOGNAME
  SELECT INTO  $_OUTPUTDEV
   rtlt.line
   FROM rtlt
   DETAIL
    CALL print(trim(substring(1,131,rtlt.line))), row + 1
   WITH counter, format = variable, maxcol = 132,
    check
  ;end select
  FREE DEFINE rtl
 ENDIF
END GO
