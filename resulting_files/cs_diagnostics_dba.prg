CREATE PROGRAM cs_diagnostics:dba
 PAINT
 EXECUTE cclseclogin
 RECORD recdate(
   1 datetime = dq8
 )
 RECORD reqnumbers(
   1 list[7]
     2 reqnbr = i4
     2 reqstr = c30
 )
 SET reqnumbers->list[1].reqnbr = 951021
 SET reqnumbers->list[1].reqstr = "951021 - Reprocess/Release"
 SET reqnumbers->list[2].reqnbr = 951060
 SET reqnumbers->list[2].reqstr = "951060 - Main pricing"
 SET reqnumbers->list[3].reqnbr = 951062
 SET reqnumbers->list[3].reqstr = "951062 - Pharmacy"
 SET reqnumbers->list[4].reqnbr = 951093
 SET reqnumbers->list[4].reqstr = "951093 - Batch charge entry"
 SET reqnumbers->list[5].reqnbr = 951360
 SET reqnumbers->list[5].reqstr = "951360 - Sync main pricing"
 SET reqnumbers->list[6].reqnbr = 951361
 SET reqnumbers->list[6].reqstr = "951361 - Sync price inquiry"
 SET reqnumbers->list[7].reqnbr = 0
 SET reqnumbers->list[7].reqstr = "Cancel"
 RECORD logoptions(
   1 list[8]
     2 optvalue = c1
     2 optstr = c30
 )
 SET logoptions->list[1].optvalue = "B"
 SET logoptions->list[1].optstr = "Bill Item"
 SET logoptions->list[2].optvalue = "P"
 SET logoptions->list[2].optstr = "Payor"
 SET logoptions->list[3].optvalue = "S"
 SET logoptions->list[3].optstr = "Service Resource"
 SET logoptions->list[4].optvalue = "L"
 SET logoptions->list[4].optstr = "Location"
 SET logoptions->list[5].optvalue = "T"
 SET logoptions->list[5].optstr = "Tier"
 SET logoptions->list[6].optvalue = "C"
 SET logoptions->list[6].optstr = "Code Set"
 SET logoptions->list[7].optvalue = "I"
 SET logoptions->list[7].optstr = "Interface File"
 SET logoptions->list[8].optvalue = "O"
 SET logoptions->list[8].optstr = "Organization TimeZone"
 SET codeset = 13029
 SET meaning = "DBGREPROCESS"
 SET index = 1
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,1,codevalue)
 SET g_dbgreprocess = - (1)
 IF (iret=0)
  SET g_dbgreprocess = codevalue
 ENDIF
 EXECUTE crmrtl
 EXECUTE srvrtl
 EXECUTE dpsrtl
 DECLARE bxmaintop = i2
 DECLARE bxmainbot = i2
 DECLARE bxmainlft = i2
 DECLARE bxmainrgt = i2
 DECLARE msglft = i2
 DECLARE msgrgt = i2
 SET bxmaintop = 3
 SET bxmainbot = 23
 SET bxmainlft = 1
 SET bxmainrgt = 80
 SET msglft = 39
 SET msgrgt = 79
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hstep = i4
 DECLARE hreq = i4
 DECLARE hevent = i4
 DECLARE hother = i4
 DECLARE appid = i4
 DECLARE taskid = i4
 DECLARE stepid = i4
 DECLARE crmstat = i2
 DECLARE srvstat = i2
 SET appid = 951020
 SET taskid = 951020
 DECLARE identifier = vc
 SUBROUTINE clearmessagearea(a)
   FOR (x = (bxmaintop+ 1) TO (bxmainbot - 1))
     CALL clear(x,msglft,(msgrgt - msglft))
   ENDFOR
 END ;Subroutine
 SUBROUTINE messagebox(title,string,pause)
   SET sizetitle = size(trim(title),1)
   SET sizestring = size(trim(string),1)
   IF (sizetitle > sizestring)
    SET boxsize = (sizetitle+ 4)
   ELSE
    SET boxsize = (sizestring+ 4)
   ENDIF
   SET boxleft = (msglft+ (((msgrgt - msglft) - boxsize)/ 2))
   SET boxright = (boxleft+ boxsize)
   SET titleleft = (boxleft+ ((boxsize - sizetitle)/ 2))
   SET stringleft = (boxleft+ ((boxsize - sizestring)/ 2))
   SET formatstr = build("P(",sizestring,");CU")
   CALL clearmessagearea("INTEXT")
   CALL box(5,boxleft,11,boxright)
   CALL text(6,titleleft,trim(title))
   CALL line(7,boxleft,(boxsize+ 1),xhor)
   IF (pause=1)
    CALL text(12,(boxleft+ 1),"Press Return")
    CALL accept(9,stringleft,formatstr,trim(string))
   ELSE
    CALL text(9,stringleft,trim(string))
   ENDIF
 END ;Subroutine
 SUBROUTINE initapptask(b)
   SET crmstat = uar_crmbeginapp(appid,happ)
   IF (crmstat != 0)
    SET errorstr = build("CrmBeginApp(",appid,") stat:",crmstat)
    CALL messagebox("Error",errorstr,1)
   ELSE
    SET crmstat = uar_crmbegintask(happ,taskid,htask)
    IF (crmstat != 0)
     SET errorstr = build("CrmBeginTask(",taskid,") stat:",crmstat)
     CALL messagebox("Error",errorstr,1)
     CALL uar_crmendapp(happ)
    ENDIF
   ENDIF
   RETURN(crmstat)
 END ;Subroutine
 SUBROUTINE callserver(c)
   SET help = pos(5,40,11,40)
   SET help =
   SELECT INTO "nl:"
    request = reqnumbers->list[d.seq].reqstr
    FROM (dummyt d  WITH seq = value(size(reqnumbers->list,5)))
    WITH nocounter
   ;end select
   CALL accept(11,51,"X;;CUF")
   CALL clear(11,51,1)
   SET stepid = reqnumbers->list[curhelp].reqnbr
   SET help = off
   IF (stepid > 0)
    CALL messagebox("CrmPerform","Processing",0)
    SET crmstat = uar_crmbeginreq(htask,"",stepid,hstep)
    IF (crmstat != 0)
     SET errorstr = build("CrmBeginReq(",stepid,") stat:",crmstat)
     CALL messagebox("Error",errorstr,1)
    ELSE
     SET crmstat = uar_crmperform(hstep)
     IF (crmstat=0)
      CALL messagebox("CrmPerform","Success",1)
     ELSE
      SET crmstatstr = build("Status:",crmstat)
      CALL messagebox("CrmPerform Error",crmstatstr,1)
     ENDIF
     CALL uar_crmendreq(hstep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logevent(d)
   DECLARE datatype = c1
   DECLARE datavalue = f8
   DECLARE datadate = c30
   SET done = 0
   WHILE (done=0)
     CALL clearmessagearea("INTEXT")
     CALL box(5,(msglft+ 2),13,(msgrgt - 2))
     CALL text(6,(msglft+ 12),"Logging Request")
     CALL line(7,(msglft+ 2),37,xhor)
     CALL text(8,(msglft+ 4),"Server")
     SET help = pos(9,(msglft+ 5),10,30)
     SET help = fix("Async,Sync")
     CALL accept(8,(msglft+ 16),"P(19);CUF")
     IF (curhelp=1)
      SET stepid = 951063
     ELSE
      SET stepid = 951363
     ENDIF
     CALL text(9,(msglft+ 4),"Data Type")
     SET help = pos(10,(msglft+ 6),10,30)
     SET help =
     SELECT INTO "nl:"
      type = logoptions->list[d.seq].optstr
      FROM (dummyt d  WITH seq = value(8))
      WITH nocounter
     ;end select
     CALL accept(9,(msglft+ 16),"P(19);CUF")
     SET datatype = logoptions->list[curhelp].optvalue
     SET help = off
     CALL text(10,(msglft+ 4),"Data Value")
     CALL accept(10,(msglft+ 16),"9999999999")
     SET datavalue = curaccept
     IF (datatype="T")
      CALL text(11,(msglft+ 4),"Date")
      SET now = cnvtdatetime(curdate,curtime)
      SET again = 1
      WHILE (again=1)
       CALL accept(11,(msglft+ 16),"NNDXXXDNNNNDNNDNN;CUS",format(now,"DD-MMM-YYYY HH:MM;;D"))
       IF (curscroll=0)
        SET again = 0
        SET datadate = curaccept
       ELSE
        CALL text(11,(msglft+ 16),format(now,"DD-MMM-YYYY HH:MM;;D"))
       ENDIF
      ENDWHILE
     ENDIF
     CALL text(14,(msglft+ 10),"Correct(Y/N/C)?")
     CALL accept(14,(msglft+ 26),"P;CU","Y")
     IF (curaccept="Y")
      SET done = 1
     ELSEIF (curaccept="C")
      SET done = - (1)
     ENDIF
   ENDWHILE
   IF (done > 0)
    SET identifier = concat(format(curdate,"MMDDYYYY;;D"),format(curtime,"HHMMSS;;M"))
    CALL messagebox("CrmPerform","Processing",0)
    SET crmstat = uar_crmbeginreq(htask,"",stepid,hstep)
    IF (crmstat != 0)
     SET errorstr = build("CrmBeginReq(",stepid,") stat:",crmstat)
     CALL messagebox("Error",errorstr,1)
    ELSE
     SET hreq = uar_crmgetrequest(hstep)
     SET srvstat = uar_srvsetstring(hreq,"identifier",identifier)
     SET srvstat = uar_srvsetstring(hreq,"data_type",datatype)
     SET srvstat = uar_srvsetdouble(hreq,"value",datavalue)
     SET recdate->datetime = cnvtdatetime(datadate)
     SET srvstat = uar_srvsetdate2(hreq,"service_dt_tm",recdate)
     SET crmstat = uar_crmperform(hstep)
     IF (crmstat=0)
      CALL messagebox("CrmPerform","Success",1)
      CALL messagebox("Identifier",identifier,1)
     ELSE
      SET crmstatstr = build("Status:",crmstat)
      CALL messagebox("CrmPerform Error",crmstatstr,1)
     ENDIF
     CALL uar_crmendreq(hstep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE searchlog(e)
   RECORD msgdata(
     1 line[*]
       2 data = c256
   )
   DECLARE node = vc
   SET node = logical("jou_instance")
   SET done = 0
   WHILE (done=0)
     CALL clearmessagearea("INTEXT")
     CALL box(5,44,12,74)
     CALL text(6,52,"Search Logging")
     CALL line(7,44,31,xhor)
     CALL text(8,46,"Action")
     SET help = pos(9,45,8,29)
     SET help = fix("Refresh,Append,View")
     CALL accept(8,58,"P(14);CUF")
     SET logaction = curhelp
     IF (logaction=3)
      SET done = 1
     ELSE
      CALL text(9,46,"Identifier")
      CALL accept(9,58,"P(14);CU",identifier)
      SET identifier = curaccept
      CALL text(13,(msglft+ 10),"Correct(Y/N/C)?")
      CALL accept(13,(msglft+ 26),"P;CU","Y")
      IF (curaccept="Y")
       SET done = 1
      ELSEIF (curaccept="C")
       SET done = - (1)
      ENDIF
     ENDIF
   ENDWHILE
   IF (done > 0)
    IF (logaction=3)
     SELECT
      data
      FROM cs_diag
      WITH nocounter
     ;end select
    ELSE
     CALL messagebox("Search Logging","Processing",0)
     DECLARE hlogmsg = i4
     SET hlogmsg = uar_srvselectmessage(1001)
     IF (hlogmsg=0)
      CALL messagebox("Error","SrvSelectMessage")
     ELSE
      DECLARE hlogreq = i4
      SET hlogreq = uar_srvcreaterequest(hlogmsg)
      IF (hlogreq=0)
       CALL messagebox("Error","SrvCreateRequest",1)
      ELSE
       DECLARE hlogitem = i4
       DECLARE hlogrep = i4
       DECLARE hreclist = i4
       DECLARE emsgmatch_and = i1
       DECLARE eforward = i1
       DECLARE emsgitem_event = i4
       DECLARE maxfetch = i4
       DECLARE binding = vc
       DECLARE repcnt = i4
       DECLARE recloop = i4
       SET emsgmatch_and = 0
       SET eforward = 49
       SET emsgitem_event = 5
       SET maxfetch = 10
       SET binding = concat("MSG_",node)
       SET srvstat = uar_srvsetstring(hlogreq,"filename","cstest")
       SET srvstat = uar_srvsetuchar(hlogreq,"forward",eforward)
       SET srvstat = uar_srvsetuchar(hlogreq,"and",emsgmatch_and)
       SET srvstat = uar_srvsetulong(hlogreq,"maxFetch",maxfetch)
       SET hlogitem = uar_srvadditem(hlogreq,"items")
       SET srvstat = uar_srvsetulong(hlogitem,"itemType",emsgitem_event)
       SET srvstat = uar_srvsetstring(hlogitem,"string0",identifier)
       SET hlogrep = uar_srvcreatereply(hlogmsg)
       DECLARE hscp = i4
       DECLARE hscpstep = i4
       DECLARE hscpreq = i4
       DECLARE hscprep = i4
       DECLARE hnodelist = i4
       DECLARE nodeloop = i2
       DECLARE nodecnt = i2
       DECLARE nodename = vc
       SET hscp = uar_scpcreate(node)
       IF (hscp=0)
        CALL messagebox("Error","ScpCreate",1)
       ELSE
        SET hscpstep = uar_scpselect(hscp,scp_enumnodes)
        IF (hscpstep=0)
         CALL messagebox("Error","ScpSelect",1)
        ELSE
         SET hscpreq = uar_srvcreaterequest(hscpstep)
         SET hscprep = uar_srvcreatereply(hscpstep)
         SET srvstat = uar_srvexecute(hscpstep,hscpreq,hscprep)
         IF (srvstat != 0)
          SET srvstatstr = build("Status:",srvstat)
          CALL messagebox("SrvExecute Error",srvstatstr,1)
         ELSE
          DECLARE msgfound = i2
          SET msgfound = 0
          SET nodecnt = uar_srvgetitemcount(hscprep,"nodelist")
          SET nodeloop = 0
          WHILE (msgfound=0
           AND nodeloop < nodecnt)
            SET hnodelist = uar_srvgetitem(hscprep,"nodelist",nodeloop)
            SET nodename = uar_srvgetstringptr(hnodelist,"nodename")
            SET binding = concat("MSG_",nodename)
            SET srvstat = uar_srvexecuteas(hlogmsg,hlogreq,hlogrep,binding)
            SET reccnt = uar_srvgetitemcount(hlogrep,"recList")
            IF (reccnt > 0)
             SET msgfound = 1
            ENDIF
            SET nodeloop += 1
          ENDWHILE
          IF (msgfound=1)
           SET firsttime = 1
           WHILE (reccnt > 0)
             FOR (recloop = 0 TO (reccnt - 1))
               SET hreclist = uar_srvgetitem(hlogrep,"recList",recloop)
               SET stat = alterlist(msgdata->line,(recloop+ 1))
               CALL uar_srvgetstring(hreclist,"data",msgdata->line[(recloop+ 1)].data,256)
             ENDFOR
             IF (logaction=1
              AND firsttime=1)
              SELECT INTO TABLE cs_diag
               data = msgdata->line[d.seq].data
               FROM (dummyt d  WITH seq = value(reccnt))
               WITH nocounter
              ;end select
             ELSE
              SELECT INTO TABLE cs_diag
               data = msgdata->line[d.seq].data
               FROM (dummyt d  WITH seq = value(reccnt))
               WITH append, nocounter
              ;end select
             ENDIF
             IF (reccnt >= maxfetch)
              SET srvstat = uar_srvsetulong(hlogreq,"context",uar_srvgetulong(hlogrep,"context"))
              SET srvstat = uar_srvexecuteas(hlogmsg,hlogreq,hlogrep,binding)
              SET reccnt = uar_srvgetitemcount(hlogrep,"recList")
              SET stat = alterlist(msgdata->line,0)
             ELSE
              SET reccnt = 0
             ENDIF
             SET firsttime = 0
           ENDWHILE
           CALL uar_srvdestroyinstance(hlogreq)
           CALL uar_srvdestroyinstance(hlogrep)
           SELECT
            data
            FROM cs_diag
            WITH nocounter
           ;end select
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      CALL uar_srvdestroymessage(hlogmsg)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE reprocess(f)
   DECLARE processtype = f8
   DECLARE eventid = f8
   DECLARE otherid = f8
   SET done = 0
   WHILE (done=0)
     CALL clearmessagearea("INTEXT")
     CALL box(5,41,13,77)
     CALL text(6,51,"Reprocess/Release")
     CALL line(7,41,37,xhor)
     CALL text(8,44,"Action")
     SET help = pos(9,45,10,30)
     SET help = fix("Reprocess,Release")
     CALL accept(8,65,"P(10);CUF")
     SET processtype = 0.0
     IF (curhelp=1)
      SET processtype = g_dbgreprocess
     ENDIF
     IF (processtype > 0)
      CALL text(9,44,"Charge Event Act Id")
     ELSE
      CALL text(9,44,"Charge Item Id")
     ENDIF
     CALL accept(9,65,"9999999999")
     SET otherid = curaccept
     CALL text(14,(msglft+ 10),"Correct(Y/N/C)?")
     CALL accept(14,(msglft+ 26),"P;CU","Y")
     IF (curaccept="Y")
      SET done = 1
     ELSEIF (curaccept="C")
      SET done = - (1)
     ENDIF
     IF (processtype > 0)
      SELECT INTO "nl:"
       c.charge_event_id
       FROM charge_event_act c
       WHERE c.charge_event_act_id=otherid
       DETAIL
        eventid = c.charge_event_id
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       c.charge_event_id
       FROM charge c
       WHERE c.charge_item_id=otherid
       DETAIL
        eventid = c.charge_event_id
       WITH nocounter
      ;end select
     ENDIF
   ENDWHILE
   IF (done > 0)
    CALL messagebox("CrmPerform","Processing",0)
    SET stepid = 951021
    SET crmstat = uar_crmbeginreq(htask,"",stepid,hstep)
    IF (crmstat != 0)
     SET errorstr = build("CrmBeginReq(",stepid,") stat:",crmstat)
     CALL messagebox("Error",errorstr,1)
    ELSE
     SET hreq = uar_crmgetrequest(hstep)
     SET hevent = uar_srvadditem(hreq,"process_event")
     SET srvstat = uar_srvsetdouble(hevent,"charge_event_id",eventid)
     IF (processtype > 0)
      SET srvstat = uar_srvsetdouble(hreq,"process_type_cd",processtype)
      SET hother = uar_srvadditem(hevent,"charge_acts")
      SET srvstat = uar_srvsetdouble(hother,"charge_event_act_id",otherid)
     ELSE
      SET hother = uar_srvadditem(hevent,"charge_item")
      SET srvstat = uar_srvsetdouble(hother,"charge_item_id",otherid)
     ENDIF
     SET crmstat = uar_crmperform(hstep)
     IF (crmstat=0)
      CALL messagebox("CrmPerform","Success",1)
     ELSE
      SET crmstatstr = build("Status:",crmstat)
      CALL messagebox("CrmPerform Error",crmstatstr,1)
     ENDIF
     CALL uar_crmendreq(hstep)
    ENDIF
   ENDIF
 END ;Subroutine
 IF (initapptask("INTEXT")=0)
  DECLARE diagchoice = i2
  DECLARE diagquit = c1
  SET diagchoice = 0
  SET diagquit = "N"
  WHILE (diagquit="N")
    CALL box(bxmaintop,bxmainlft,bxmainbot,bxmainrgt)
    CALL text(2,1,"CS Diagnostics",w)
    CALL text((bxmaintop+ 3),10," 1) Afc Master Report")
    CALL text((bxmaintop+ 5),10," 2) Server Diagnostics Report")
    CALL text((bxmaintop+ 7),10," 3) Test Server Step")
    CALL text((bxmaintop+ 9),10," 4) Send Logging Request")
    CALL text((bxmaintop+ 11),10," 5) Search Logging")
    CALL text((bxmaintop+ 13),10," 6) Reprocess/Release")
    CALL text((bxmaintop+ 15),10," 7) ")
    CALL video(r)
    CALL text((bxmaintop+ 15),14,"Exit")
    CALL video(n)
    CALL text((bxmainbot+ 1),2,"Select Option (1,2,3...)")
    CALL accept((bxmainbot+ 1),36,"9;",7
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7))
    SET diagchoice = curaccept
    CASE (diagchoice)
     OF 1:
      EXECUTE cs_master_menu 1
     OF 2:
      EXECUTE cs_master_menu 2
     OF 3:
      CALL callserver("INTEXT")
     OF 4:
      CALL logevent("INTEXT")
     OF 5:
      CALL searchlog("INTEXT")
     OF 6:
      CALL reprocess("INTEXT")
     ELSE
      SET diagquit = "Y"
    ENDCASE
    CALL clear(24,1)
    CALL clear(1,1)
  ENDWHILE
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  CALL clear(24,1)
  CALL clear(1,1)
 ENDIF
END GO
