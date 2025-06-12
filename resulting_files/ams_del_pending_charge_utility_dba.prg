CREATE PROGRAM ams_del_pending_charge_utility:dba
 PROMPT
  "" = "MINE",
  "Patient lookup by:" = "",
  "Search for:" = "",
  "Patient Name" = 0,
  "Pending Charge" = 0,
  "Confirm Deletion?" = ""
  WITH outdev, searchtype, searchstr,
  personid, pendchargeeventid, delprompt
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE quesrow = i4 WITH constant(22), protect
 DECLARE maxrows = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE arow = i4 WITH protect
 DECLARE rowstr = c75 WITH protect
 DECLARE pick = i4 WITH protect
 DECLARE ccl_ver = i4 WITH protect, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
 DECLARE status = c1 WITH protect, noconstant("F")
 DECLARE debug_ind = i2 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE i = i4 WITH protect
 RECORD log(
   1 qual_cnt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 ) WITH protect
 DECLARE validatelogin(null) = null WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE drawmenu(title=vc,detailline=vc,warningline=vc) = null WITH protect
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE addlogmsg(msgtype=vc,msg=vc) = null WITH protect
 DECLARE createlogfile(filename=vc) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 SUBROUTINE validatelogin(null)
   EXECUTE cclseclogin
   SET message = nowindow
   IF ((xxcclseclogin->loggedin != 1))
    SET status = "F"
    SET statusstr = "You must be logged in securely. Please run the program again."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE drawmenu(title,detailline,warningline)
   CALL clear(1,1)
   CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
   CALL video(r)
   CALL text((soffrow - 4),soffcol,title)
   CALL text((soffrow - 3),soffcol,detailline)
   CALL video(b)
   CALL text((soffrow - 2),soffcol,warningline)
   CALL video(n)
   CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
   CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
   CALL text((soffrow+ 16),soffcol,"Choose an option:")
 END ;Subroutine
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE gethnaemail(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    p.email
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.email)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE addlogmsg(msgtype,msg)
   SET log->qual_cnt = (log->qual_cnt+ 1)
   IF (mod(log->qual_cnt,50)=1)
    SET stat = alterlist(log->qual,(log->qual_cnt+ 49))
   ENDIF
   SET log->qual[log->qual_cnt].smsgtype = msgtype
   SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_cnt].smsg = msg
 END ;Subroutine
 SUBROUTINE createlogfile(filename)
   DECLARE logcnt = i4 WITH protect
   IF (ccl_ver >= 871)
    SET modify = filestream
   ENDIF
   SET stat = alterlist(log->qual,log->qual_cnt)
   FREE SET output_log
   SET logical output_log value(nullterm(concat("CCLUSERDIR:",trim(cnvtlower(filename)))))
   SELECT INTO output_log
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     outline = fillstring(254," ")
    DETAIL
     FOR (logcnt = 1 TO log->qual_cnt)
       outline = trim(substring(1,254,concat(format(log->qual[logcnt].smsgtype,"############")," :: ",
          format(log->qual[logcnt].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[logcnt
           ].smsg)))), col 0, outline
       IF ((logcnt != log->qual_cnt))
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, formfeed = none, format = stream,
     append, maxcol = 255, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,rowstr)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,rowstr)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0))
  IF (debug=1)
   SET debug_ind = 1
  ELSE
   SET debug_ind = 0
   SET trace = callecho
   SET trace = notest
   SET trace = nordbdebug
   SET trace = nordbbind
   SET trace = noechoinput
   SET trace = noechoinput2
   SET trace = noechorecord
   SET trace = noshowuar
   SET trace = noechosub
   SET trace = nowarning
   SET trace = nowarning2
   SET message = noinformation
   SET trace = nocost
  ENDIF
 ELSE
  SET debug_ind = 0
  SET trace = callecho
  SET trace = notest
  SET trace = nordbdebug
  SET trace = nordbbind
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET trace = noechosub
  SET trace = nowarning
  SET trace = nowarning2
  SET message = noinformation
  SET trace = nocost
 ENDIF
 SET last_mod = "005"
 DECLARE createoutputreport(null) = null WITH protect
 DECLARE incrementexecutioncnt(null) = null WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_DEL_PENDING_CHARGE_UTILITY")
 DECLARE ams_email = vc WITH protect, constant("ams_pharm_backups@cerner.com")
 DECLARE detail_line = vc WITH protect, constant("Number of executions:")
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE bodystr = vc WITH protect
 DECLARE filename = vc WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE domainname = vc WITH constant(getclient(null)), protect
 DECLARE facname = vc WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE addcnt = f8 WITH protect
 DECLARE statusstr = vc WITH protect
 SET statusstr = null
 DECLARE checkpendeventid = vc WITH protect
 SET checkpendeventid = null
 DECLARE patname = vc WITH protect
 SET patname = null
 DECLARE patfin = vc WITH protect
 SET patfin = null
 DECLARE orderdesc = vc WITH protect
 SET orderdesc = null
 DECLARE delname = vc WITH protect
 SET delname = null
 DECLARE delposition = vc WITH protect
 SET delposition = null
 DECLARE delpersonid = vc WITH protect
 SET delpersonid = null
 DECLARE eventid = f8 WITH protect
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 SELECT INTO "nl:"
  rpc.rx_pending_charge_id, o.dept_misc_line, ea.alias,
  p.name_full_formatted, e.loc_facility_cd, pr.person_id,
  name = pr.name_full_formatted, position = uar_get_code_display(pr.position_cd)
  FROM rx_pending_charge rpc,
   encntr_alias ea,
   encounter e,
   orders o,
   person p,
   prsnl pr
  PLAN (rpc
   WHERE (rpc.event_id= $PENDCHARGEEVENTID))
   JOIN (o
   WHERE o.order_id=rpc.order_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR")))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pr
   WHERE (pr.person_id=reqinfo->updt_id))
  DETAIL
   checkpendeventid = trim(cnvtstring(rpc.event_id)), patname = p.name_full_formatted, patfin = ea
   .alias,
   orderdesc = o.dept_misc_line, facname = uar_get_code_display(e.loc_facility_cd), delname = pr
   .name_full_formatted,
   delposition = position, delpersonid = trim(cnvtstring(pr.person_id)), eventid = rpc.event_id
  WITH nocounter
 ;end select
 IF (textlen(trim(checkpendeventid)) > 0)
  SET addcnt = 1
  SET filename = cnvtlower(concat(replace(facname," ","_"),"_",trim(curdomain),"_del_pend_charge_",
    format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q"),
    ".csv"))
  SELECT INTO value(filename)
   *
   FROM rx_pending_charge rpc
   WHERE (rpc.event_id= $PENDCHARGEEVENTID)
   WITH format = stream, pcformat('"',",",1), format(date,";;q"),
    format
  ;end select
  DELETE  FROM rx_pending_charge rpc
   WHERE (rpc.event_id= $PENDCHARGEEVENTID)
  ;end delete
  IF (((curqual < 1) OR (error(errormsg,0) != 0)) )
   SET status = "F"
   SET statusstr = build2("Error deleting pending charge. curqual = ",trim(cnvtstring(curqual)))
   GO TO exit_script
  ENDIF
  SET statusstr = "You have SUCCESSFULLY DELETED the pending charge."
  SET recpstr = ams_email
  SET subjstr = concat(domainname," ",facname," ",trim(curdomain),
   ": Delete Pending Charge Utility ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
  SET bodystr = concat("Name: ",delname,"  Position: ",delposition,"  person_id: ",
   delpersonid," Time: ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
  SET stat = emailfile(recpstr,ams_email,subjstr,bodystr,filename)
  IF (stat=1)
   SET status = "S"
  ELSE
   SET status = "F"
   SET statusstr = "Email not successfully sent. Pending charge not deleted."
   GO TO exit_script
  ENDIF
 ELSE
  SET statusstr = "An ERROR occured.  The Pending Charge was not found and/or already deleted."
  SET patname = "NOT DELETED"
  SET patfin = "NOT DELETED"
  SET orderdesc = "NOT DELETED"
  SET status = "F"
  GO TO exit_script
 ENDIF
#exit_script
 IF (status="F")
  ROLLBACK
  SELECT INTO value( $OUTDEV)
   DETAIL
    row + 1, statusstr, row + 1,
    errormsg
  ;end select
 ELSEIF (status="S")
  SET statusstr = substring(1,100,statusstr)
  SET errormsg = substring(1,100,errormsg)
  SET patname = substring(1,100,patname)
  SET patfin = substring(1,100,patfin)
  SET orderdesc = substring(1,100,orderdesc)
  SET trace = nocallecho
  CALL updtdminfo(script_name,cnvtreal(addcnt))
  SET trace = callecho
  COMMIT
  SELECT INTO value( $OUTDEV)
   DETAIL
    row + 1, statusstr, row + 2,
    "Patient: ", col 10, patname,
    row + 1, "    FIN: ", col 10,
    patfin, row + 1, "  Order: ",
    col 10, orderdesc
  ;end select
 ENDIF
 SET last_mod = "002"
END GO
