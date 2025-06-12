CREATE PROGRAM ams_periop_health_check:dba
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
 DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
 RECORD prefs(
   1 list_sz = i4
   1 list[*]
     2 pref_id = f8
     2 pref_domain = vc
     2 pref_section = vc
     2 pref_name = vc
     2 pref_type = vc
     2 yes_value = vc
     2 no_value = vc
     2 min_value = f8
     2 max_value = f8
     2 question = vc
     2 value = vc
 ) WITH protect
 RECORD ignores(
   1 list_sz = i4
   1 list[*]
     2 name = vc
     2 description = vc
     2 category = vc
     2 category_alias = c3
     2 audit_num = i4
     2 bypass_audit = i2
     2 primary_key = vc
     2 table_name = vc
     2 disp_field_name = vc
     2 where_str = vc
     2 default_audit_off_ind = i2
     2 values[*]
       3 id = vc
       3 disp = vc
       3 br_name_value_id = f8
 ) WITH protect
 DECLARE incrementerrorcnt(progname=vc,inccnt=i4,infodetail=vc) = i2 WITH protect
 DECLARE geterrorcnt(progname=vc) = i4 WITH protect
 DECLARE deleteerrorcnt(progname=vc) = i4 WITH protect
 DECLARE addignorevalue(scriptname=vc,primarykey=vc,keyid=vc) = i2 WITH protect
 DECLARE loadprefs(scriptname=vc) = i2 WITH protect
 DECLARE setprefs(scriptname=vc,promptuserind=i2) = null WITH protect
 DECLARE displayprefs(scriptname=vc) = null WITH protect
 DECLARE displayignorevalues(scriptname=vc,ignorepos=i4) = null WITH protect
 DECLARE refreshignorevalues(ignorepos=i4) = null WITH protect
 DECLARE setignorevalues(scriptname=vc,ignorepos=i4) = null WITH protect
 DECLARE removeignorevalues(scriptname=vc,ignorepos=i4,ignorevaluepos=i4) = null WITH protect
 DECLARE validateignorevalueexists(ignorepos=i4,wherestr=vc) = i2 WITH protect
 SUBROUTINE incrementerrorcnt(progname,inccnt,infodetail)
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=progname
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = pref_domain, d.info_name = progname, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = inccnt, d.info_char = trim(infodetail), d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ELSE
    IF (datetimediff(cnvtdatetime(curdate,curtime3),lastupdt,3) > 23)
     UPDATE  FROM dm_info d
      SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
       .updt_cnt+ 1),
       d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
      WHERE d.info_domain=pref_domain
       AND d.info_name=progname
      WITH nocounter
     ;end update
     IF (curqual=1)
      SET retval = 1
     ENDIF
    ELSE
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE geterrorcnt(progname)
   DECLARE retval = i4 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=progname
    DETAIL
     retval = cnvtint(d.info_number)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE deleteerrorcnt(progname)
   DECLARE retval = i4 WITH protect
   DELETE  FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=patstring(progname)
    WITH nocounter
   ;end delete
   SET retval = curqual
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE addignorevalue(scriptname,primarykey,keyid)
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET trace = recpersist
   RECORD br_request(
     1 br_name = vc
     1 br_value = vc
     1 br_nv_key1 = vc
   )
   RECORD br_reply(
     1 br_name_value_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET br_request->br_name = trim(primarykey,3)
   SET br_request->br_value = trim(keyid,3)
   SET br_request->br_nv_key1 = trim(scriptname,3)
   EXECUTE bed_add_name_value  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
   IF ((br_reply->status_data.status="F"))
    SET retval = 0
   ELSE
    SET retval = 1
   ENDIF
   SET trace = norecpersist
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE setprefs(scriptname,promptuserind)
   DECLARE updtcnt = i4 WITH protect
   DECLARE insertcnt = i4 WITH protect
   DECLARE ques = c65 WITH protect
   DECLARE minval = f8 WITH protect
   DECLARE maxval = f8 WITH protect
   SET status = "F"
   FOR (i = 1 TO prefs->list_sz)
     IF ((prefs->list[i].pref_id > 0))
      SET updtcnt = (updtcnt+ 1)
     ELSE
      SET insertcnt = (insertcnt+ 1)
     ENDIF
   ENDFOR
   IF (promptuserind=1)
    CALL clearscreen(null)
    FOR (i = 1 TO prefs->list_sz)
      IF (insertcnt > 0)
       CALL text(soffrow,soffcol,"You must set all preferences before running the program")
      ELSE
       CALL text(soffrow,soffcol,"Resetting preferences:")
      ENDIF
      CALL clear((soffrow+ i),soffcol,numcols)
      CALL clear(((soffrow+ i)+ 1),soffcol,numcols)
      SET ques = prefs->list[i].question
      CALL text((soffrow+ i),soffcol,ques)
      CALL text(((soffrow+ i)+ 1),(soffcol+ 3),"Previous setting:")
      CALL text(((soffrow+ i)+ 1),(soffcol+ 21),prefs->list[i].value)
      CASE (prefs->list[i].pref_type)
       OF "YESNO":
        CALL text(quesrow,soffcol,"(Y)es or (N)o?:")
        CALL accept(quesrow,(soffcol+ 15),"A;CU"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         SET prefs->list[i].value = prefs->list[i].yes_value
        ELSE
         SET prefs->list[i].value = prefs->list[i].no_value
        ENDIF
        CALL text((soffrow+ i),(numcols - 5),curaccept)
       OF "NUMERIC":
        CALL text(quesrow,soffcol,"Enter number:")
        SET minval = prefs->list[i].min_value
        SET maxval = prefs->list[i].max_value
        CALL accept(quesrow,(soffcol+ 13),"9(9);"
         WHERE cnvtreal(curaccept) BETWEEN value(minval) AND value(maxval))
        SET prefs->list[i].value = trim(cnvtstring(curaccept))
        CALL text((soffrow+ i),(numcols - 5),trim(cnvtstring(curaccept)))
      ENDCASE
    ENDFOR
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","After setting prefs record structure before updating dm_prefs:")
    CALL echorecord(prefs,logfilename,1)
    CALL addlogmsg("INFO",build2("updtCnt = ",trim(cnvtstring(updtcnt))))
    CALL addlogmsg("INFO",build2("insertCnt = ",trim(cnvtstring(insertcnt))))
   ENDIF
   IF (updtcnt > 0)
    SELECT INTO "nl:"
     dm.pref_id
     FROM dm_prefs dm
     WHERE expand(i,1,prefs->list_sz,dm.pref_id,prefs->list[i].pref_id)
      AND dm.pref_id != 0.0
     WITH nocounter, forupdate(dm)
    ;end select
    UPDATE  FROM (dummyt d1  WITH seq = value(prefs->list_sz)),
      dm_prefs dm
     SET dm.pref_str = prefs->list[d1.seq].value, dm.updt_applctx = reqinfo->updt_applctx, dm
      .updt_cnt = (dm.updt_cnt+ 1),
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id, dm.updt_task =
      - (267)
     PLAN (d1)
      JOIN (dm
      WHERE (dm.pref_id=prefs->list[d1.seq].pref_id)
       AND dm.pref_id != 0.0
       AND dm.pref_domain=pref_domain
       AND dm.pref_section=scriptname)
     WITH nocounter
    ;end update
    IF (curqual != updtcnt)
     SET status = "F"
     CALL text((soffrow+ 14),soffcol,"ERROR UPDATING DM_PREFS. ROLLING BACK CHANGES")
     ROLLBACK
    ELSE
     SET status = "S"
    ENDIF
   ENDIF
   IF (insertcnt > 0
    AND curqual=updtcnt)
    INSERT  FROM (dummyt d1  WITH seq = value(prefs->list_sz)),
      dm_prefs dm
     SET dm.pref_id = seq(dm_clinical_seq,nextval), dm.pref_domain = prefs->list[d1.seq].pref_domain,
      dm.pref_section = prefs->list[d1.seq].pref_section,
      dm.pref_name = prefs->list[d1.seq].pref_name, dm.pref_str = prefs->list[d1.seq].value, dm
      .pref_dt_tm = cnvtdatetime(curdate,curtime3),
      dm.reference_ind = 1, dm.updt_applctx = reqinfo->updt_applctx, dm.updt_cnt = 0,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id, dm.updt_task =
      - (267)
     PLAN (d1
      WHERE (prefs->list[d1.seq].pref_id=0))
      JOIN (dm)
     WITH nocounter
    ;end insert
    IF (curqual != insertcnt)
     SET status = "F"
     CALL text((soffrow+ 14),soffcol,"ERROR INSERTING INTO DM_PREFS. ROLLING BACK CHANGES")
     ROLLBACK
    ELSE
     SET status = "S"
    ENDIF
   ENDIF
   CALL clear(quesrow,soffcol,numcols)
   IF (status="S")
    IF (promptuserind=1)
     CALL text((soffrow+ 14),soffcol,"Successfully updated preferences")
     CALL text(quesrow,soffcol,"Commit?:")
     CALL accept(quesrow,(soffcol+ 8),"A;CU"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      COMMIT
     ELSE
      ROLLBACK
     ENDIF
    ELSE
     COMMIT
    ENDIF
   ELSE
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 11),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
 END ;Subroutine
 SUBROUTINE displayprefs(scriptname)
   DECLARE ques = c65
   CALL clearscreen(null)
   IF (loadprefs(scriptname)=1)
    CALL text(soffrow,soffcol,"Current settings:")
    FOR (i = 1 TO prefs->list_sz)
      SET ques = prefs->list[i].question
      CALL text((soffrow+ i),soffcol,ques)
      CALL text((soffrow+ i),(soffcol+ textlen(ques)),prefs->list[i].value)
    ENDFOR
   ELSE
    CALL setprefs(scriptname,1)
    GO TO main_menu
   ENDIF
   CALL text(quesrow,soffcol,"(M)ain Menu or (S)et Prefs:")
   CALL accept(quesrow,(soffcol+ 27),"A;CU","M"
    WHERE curaccept IN ("M", "S"))
   IF (curaccept="M")
    GO TO main_menu
   ELSE
    CALL setprefs(scriptname,1)
    GO TO main_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE refreshignorevalues(ignorepos)
   DECLARE descrip = c68 WITH protect
   DECLARE primid = c19 WITH protect
   DECLARE igndisp = c50 WITH protect
   SET descrip = ignores->list[ignorepos].description
   CALL clearscreen(null)
   CALL loadignorevalues(scriptname)
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND cnt < size(ignores->list[ignorepos].values,5))
     SET cnt = (cnt+ 1)
     SET primid = ignores->list[ignorepos].values[cnt].id
     SET igndisp = " "
     SET igndisp = ignores->list[ignorepos].values[cnt].disp
     SET rowstr = build2(cnvtstring(cnt,3,0,r)," ",primid,igndisp)
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text(soffrow,soffcol,"Audit:")
   CALL text(soffrow,(soffcol+ 7),descrip)
   CALL text((soffrow+ 1),(soffcol+ 6),ignores->list[ignorepos].primary_key)
   IF ((ignores->list[ignorepos].primary_key != ignores->list[ignorepos].disp_field_name))
    CALL text((soffrow+ 1),(soffcol+ 25),ignores->list[ignorepos].disp_field_name)
   ENDIF
   CALL text((soffrow+ 1),(soffcol+ 60),"TOTAL:")
   CALL text((soffrow+ 1),(soffcol+ 67),trim(cnvtstring(size(ignores->list[ignorepos].values,5),3,0))
    )
 END ;Subroutine
 SUBROUTINE displayignorevalues(scriptname,ignorepos)
   DECLARE primid = c19 WITH protect
   DECLARE igndisp = c50 WITH protect
   CALL refreshignorevalues(ignorepos)
   WHILE (pick=0)
     CALL text(quesrow,soffcol,"(M)ain Menu or (A)dd or (R)emove Item:")
     CALL accept(quesrow,(soffcol+ 38),"A;CUS","M"
      WHERE curaccept IN ("M", "A", "R"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="M")
        GO TO main_menu
       ELSEIF (curaccept="A")
        CALL setignorevalues(scriptname,ignorepos)
        CALL refreshignorevalues(ignorepos)
       ELSE
        CALL removeignorevalues(scriptname,ignorepos,cnt)
        CALL refreshignorevalues(ignorepos)
       ENDIF
      OF 1:
       IF (cnt < size(ignores->list[ignorepos].values,5))
        SET cnt = (cnt+ 1)
        SET primid = ignores->list[ignorepos].values[cnt].id
        SET igndisp = " "
        SET igndisp = ignores->list[ignorepos].values[cnt].disp
        SET rowstr = build2(cnvtstring(cnt,3,0,r)," ",primid,igndisp)
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET primid = ignores->list[ignorepos].values[cnt].id
        SET igndisp = " "
        SET igndisp = ignores->list[ignorepos].values[cnt].disp
        SET rowstr = build2(cnvtstring(cnt,3,0,r)," ",primid,igndisp)
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE setignorevalues(scriptname,ignorepos)
   DECLARE instructs = c75 WITH protect
   DECLARE wherestr = vc WITH protect
   DECLARE listsz = i4 WITH protect, noconstant(0)
   DECLARE errorstr = vc WITH protect
   DECLARE tempstr = vc WITH protect
   DECLARE formattedaccept = vc WITH protect
   DECLARE notfound = vc WITH protect, constant("Not Found")
   DECLARE valuecnt = i4 WITH protect
   SET instructs = build2("Enter ",ignores->list[ignorepos].primary_key,
    " of item you want to ignore or ALL or NONE:")
   SET pick = 0
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,instructs)
   WHILE (pick=0)
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);CU"
      WHERE ((curaccept IN ("ALL", "NONE", "QUIT", "MUL.*")) OR (cnvtreal(piece(curaccept,",",1,
        notfound,3)) > 1)) )
     IF (curaccept="ALL")
      SET i = addignorevalue(ignores->list[ignorepos].name,ignores->list[ignorepos].primary_key,"ALL"
       )
      SET pick = 1
      IF (i=1)
       COMMIT
       CALL text((soffrow+ 14),soffcol,"Successfully updated ignore value")
      ELSE
       ROLLBACK
       CALL text((soffrow+ 14),soffcol,"Error updating ignore value. Changes rolled back")
      ENDIF
     ELSEIF (curaccept="NONE")
      IF (size(ignores->list[ignorepos].values,5)=0)
       SET i = addignorevalue(ignores->list[ignorepos].name,ignores->list[ignorepos].primary_key,
        "NONE")
       SET pick = 1
       IF (i=1)
        COMMIT
        CALL text((soffrow+ 14),soffcol,"Successfully updated ignore value")
       ELSE
        ROLLBACK
        CALL text((soffrow+ 14),soffcol,"Error updating ignore value. Changes rolled back")
       ENDIF
      ELSE
       CALL text((soffrow+ 14),soffcol,"Cannot add None because other ignore values already exist")
      ENDIF
     ELSEIF (curaccept="QUIT")
      GO TO main_menu
     ELSE
      IF ((ignores->list[ignorepos].values[1].id="NONE"))
       CALL text((soffrow+ 14),soffcol,"Cannot add ignore value because None is in ignore list")
      ELSE
       SET formattedaccept = trim(trim(curaccept,8))
       SET tempstr = formattedaccept
       SET valuecnt = 0
       WHILE (tempstr != notfound)
         SET valuecnt = (valuecnt+ 1)
         SET tempstr = piece(formattedaccept,",",valuecnt,notfound,3)
         IF (tempstr != notfound)
          IF (tempstr="M*")
           SET wherestr = concat(ignores->list[ignorepos].where_str,'"',tempstr,'"')
          ELSE
           SET wherestr = build2(ignores->list[ignorepos].where_str,cnvtreal(tempstr))
          ENDIF
          SET stat = validateignorevalueexists(ignorepos,wherestr)
          IF (stat=1)
           SET i = addignorevalue(ignores->list[ignorepos].name,ignores->list[ignorepos].primary_key,
            tempstr)
           IF (i=1)
            COMMIT
            CALL text(((soffrow+ 1)+ valuecnt),soffcol,build2("Added ",tempstr," to the ignore list")
             )
           ELSE
            ROLLBACK
            CALL text(((soffrow+ 1)+ valuecnt),soffcol,build2("Error adding ",tempstr,
              " to list. Changes rolled back"))
           ENDIF
          ELSE
           SET errorstr = build2(ignores->list[ignorepos].primary_key," ",tempstr," not found on ",
            ignores->list[ignorepos].table_name)
           CALL text(((soffrow+ 1)+ valuecnt),soffcol,errorstr)
          ENDIF
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
     CALL clear(quesrow,soffcol,numcols)
     IF (pick=0)
      CALL text(quesrow,soffcol,"Enter another?:")
      CALL accept(quesrow,(soffcol+ 15),"A;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="N")
       SET pick = 1
      ELSE
       FOR (i = 1 TO valuecnt)
         CALL clear(((soffrow+ 1)+ i),soffcol,numcols)
       ENDFOR
       CALL clear(quesrow,soffcol,numcols)
       CALL clear((soffrow+ 14),soffcol,numcols)
      ENDIF
     ELSE
      CALL text(quesrow,soffcol,"Continue?:")
      CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
       WHERE curaccept IN ("Y"))
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE validateignorevalueexists(ignorepos,wherestr)
   DECLARE fromstr = vc WITH protect
   DECLARE found = i2 WITH protect, noconstant(0)
   SET fromstr = ignores->list[ignorepos].table_name
   SELECT INTO "nl:"
    FROM (parser(fromstr))
    WHERE parser(wherestr)
    DETAIL
     found = 1
    WITH nocounter
   ;end select
   RETURN(found)
 END ;Subroutine
 SUBROUTINE removeignorevalues(scriptname,ignorepos,ignorevaluepos)
   CALL clear(quesrow,soffcol,numcols)
   DELETE  FROM br_name_value bnv
    WHERE (bnv.br_name_value_id=ignores->list[ignorepos].values[ignorevaluepos].br_name_value_id)
     AND bnv.br_name_value_id != 0.0
    WITH nocounter
   ;end delete
   IF (curqual=1)
    CALL text(quesrow,soffcol,"Commit?:")
    CALL accept(quesrow,(soffcol+ 8),"A;CU"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ELSE
    CALL text((soffrow+ 14),soffcol,"ERROR DELETING FROM BR_NAME_VALUE.ROLLING BACK CHANGE.")
    ROLLBACK
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
 END ;Subroutine
 SET last_mod = "002"
 DECLARE loadprefs(scriptname=vc) = i2 WITH protect
 DECLARE loadignorevalues(scriptname=vc) = null WITH protect
 SUBROUTINE loadprefs(scriptname)
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE numofprefs = i4 WITH protect, noconstant(0)
   DECLARE prefpos = i4 WITH protect
   DECLARE prefcnt = i4 WITH protect
   SET stat = initrec(prefs)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside loadPrefs")
   ENDIF
   CASE (scriptname)
    OF "AMS_PERIOP_HEALTH_CHECK":
     SET numofprefs = 3
     SET prefs->list_sz = numofprefs
     SET stat = alterlist(prefs->list,numofprefs)
     SET prefs->list[1].question = "Do you want the ops job to automatically fix errors if possible?"
     SET prefs->list[1].pref_domain = pref_domain
     SET prefs->list[1].pref_section = scriptname
     SET prefs->list[1].pref_name = "AUTO_FIX"
     SET prefs->list[1].pref_type = "YESNO"
     SET prefs->list[1].yes_value = "YES"
     SET prefs->list[1].no_value = "NO"
     SET prefs->list[1].value = ""
     SET prefs->list[2].question = "Do you want the ops job to email if no failures were found?"
     SET prefs->list[2].pref_domain = pref_domain
     SET prefs->list[2].pref_section = scriptname
     SET prefs->list[2].pref_name = "EMAIL_ON_SUCCESS"
     SET prefs->list[2].pref_type = "YESNO"
     SET prefs->list[2].yes_value = "YES"
     SET prefs->list[2].no_value = "NO"
     SET prefs->list[2].value = ""
     SET prefs->list[3].question = "Do you want the ops job to email results from this domain?"
     SET prefs->list[3].pref_domain = pref_domain
     SET prefs->list[3].pref_section = scriptname
     SET prefs->list[3].pref_name = "SEND_EMAIL_FROM_DOMAIN"
     SET prefs->list[3].pref_type = "YESNO"
     SET prefs->list[3].yes_value = trim(curdomain)
     SET prefs->list[3].no_value = "NO"
     SET prefs->list[3].value = ""
   ENDCASE
   SELECT INTO "nl:"
    dm.pref_domain, dm.pref_section, dm.pref_str,
    dm.pref_name
    FROM dm_prefs dm
    WHERE dm.pref_domain=pref_domain
     AND dm.pref_section=scriptname
     AND expand(i,1,numofprefs,dm.pref_name,prefs->list[i].pref_name)
    HEAD REPORT
     prefcnt = 0
    DETAIL
     prefcnt = (prefcnt+ 1), prefpos = locateval(i,1,prefs->list_sz,dm.pref_name,prefs->list[i].
      pref_name)
     IF (prefpos > 0)
      IF ((prefs->list[prefpos].pref_type="YESNO"))
       IF ((dm.pref_str=prefs->list[prefpos].yes_value))
        prefs->list[prefpos].value = "YES"
       ELSE
        prefs->list[prefpos].value = "NO"
       ENDIF
      ELSE
       prefs->list[prefpos].value = dm.pref_str
      ENDIF
      prefs->list[prefpos].pref_id = dm.pref_id
     ENDIF
    WITH nocounter
   ;end select
   IF (prefcnt=numofprefs)
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","After loading prefs record structure:")
    CALL echorecord(prefs,logfilename,1)
    CALL addlogmsg("INFO",build2("curqual = ",trim(cnvtstring(curqual))))
    CALL addlogmsg("INFO",build2("retVal = ",trim(cnvtstring(retval))))
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE loadignorevalues(scriptname)
   DECLARE listcnt = i4 WITH protect
   DECLARE ignpos = i4 WITH protect
   DECLARE fromstr = vc WITH protect
   DECLARE wherestr = vc WITH protect
   DECLARE fieldstr = vc WITH protect
   DECLARE numofaudits = i4 WITH protect
   SET stat = initrec(ignores)
   CASE (scriptname)
    OF "AMS_PERIOP_HEALTH_CHECK":
     SET numofaudits = 1
     SET ignores->list_sz = numofaudits
     SET stat = alterlist(ignores->list,numofaudits)
     SET ignores->list[1].description = "ANES - Revoke Blank Records Task DBA"
     SET ignores->list[1].name = concat(trim(scriptname),"|REVOKE_BLANK_RECORDS_TASK")
     SET ignores->list[1].default_audit_off_ind = 1
     SET ignores->list[1].primary_key = "APP_GROUP_CD"
     SET ignores->list[1].table_name = "CODE_VALUE"
     SET ignores->list[1].disp_field_name = "DISPLAY"
     SET ignores->list[1].where_str = "CODE_SET = 500 AND CODE_VALUE = "
   ENDCASE
   SELECT INTO "nl:"
    bnv.br_nv_key1, bnv.br_value
    FROM br_name_value bnv
    WHERE expand(i,1,ignores->list_sz,bnv.br_nv_key1,ignores->list[i].name)
    ORDER BY bnv.br_nv_key1, bnv.br_value DESC
    HEAD bnv.br_nv_key1
     ignpos = locateval(i,1,ignores->list_sz,bnv.br_nv_key1,ignores->list[i].name), ignores->list[
     ignpos].primary_key = bnv.br_name, listcnt = 0
    DETAIL
     IF (ignpos > 0)
      listcnt = (listcnt+ 1)
      IF (mod(listcnt,10)=1)
       stat = alterlist(ignores->list[ignpos].values,(listcnt+ 9))
      ENDIF
      ignores->list[ignpos].values[listcnt].id = trim(bnv.br_value), ignores->list[ignpos].values[
      listcnt].br_name_value_id = bnv.br_name_value_id
      IF (bnv.br_name="*_CD")
       ignores->list[ignpos].values[listcnt].disp = uar_get_code_display(cnvtreal(bnv.br_value))
      ENDIF
      IF (bnv.br_value="ALL")
       ignores->list[ignpos].bypass_audit = 1
      ENDIF
     ENDIF
    FOOT  bnv.br_nv_key1
     IF (mod(listcnt,10) != 0)
      stat = alterlist(ignores->list[ignpos].values,listcnt)
     ENDIF
    WITH nocounter
   ;end select
   FOR (i = 1 TO ignores->list_sz)
     IF (size(ignores->list[i].values,5)=0
      AND (ignores->list[i].default_audit_off_ind=1))
      SET ignores->list[i].bypass_audit = 1
     ENDIF
   ENDFOR
   FOR (i = 1 TO ignores->list_sz)
     FOR (listcnt = 1 TO size(ignores->list[i].values,5))
       IF ((ignores->list[i].values[listcnt].disp="")
        AND  NOT ((ignores->list[i].values[listcnt].id IN ("NONE", "ALL"))))
        SET fromstr = ignores->list[i].table_name
        IF ((ignores->list[i].primary_key IN ("*ID", "*CD", "CODE_VALUE", "*_CODE")))
         SET wherestr = build2(ignores->list[i].where_str,ignores->list[i].values[listcnt].id)
        ELSE
         SET wherestr = build2(ignores->list[i].where_str,' "',ignores->list[i].values[listcnt].id,
          '"')
        ENDIF
        SET fieldstr = build2("x.",ignores->list[i].disp_field_name)
        SELECT INTO "nl:"
         *
         FROM (parser(fromstr) x)
         WHERE parser(wherestr)
         DETAIL
          ignores->list[i].values[listcnt].disp = parser(fieldstr)
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Ignores record after being populated:")
    CALL echorecord(ignores,logfilename,1)
   ENDIF
 END ;Subroutine
 SET last_mod = "000"
 DECLARE revokeblankrecordstask(null) = i4 WITH protect
 DECLARE createfixlog(null) = i2 WITH protect
 DECLARE createeasyignorestr(nextstr=vc,lastind=i2) = null WITH protect
 DECLARE addtrackingrow(audit=vc,cnt=i4,desc=vc) = null WITH protect
 DECLARE loadpreviousresults(null) = null WITH protect
 DECLARE createoutputcsv(filename) = null WITH protect
 DECLARE clientstr = vc WITH constant(getclient(null)), protect
 DECLARE script_name = c23 WITH protect, constant("AMS_PERIOP_HEALTH_CHECK")
 DECLARE cfrom = c33 WITH protect, constant("periophealthcheck@cerner.com")
 DECLARE clogmailbox = c33 WITH protect, constant("periophealthcheck@cerner.com")
 DECLARE header_name = vc WITH protect, constant("cclsource:pharm_health_check_header.bmp")
 DECLARE vcsubject = vc WITH noconstant(build2("AMS Periop Health Check ",clientstr,": ",curdomain)),
 protect
 DECLARE vclogemailsubject = vc WITH noconstant(build2(clientstr,": ",trim(curdomain))), protect
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE linestr = c50 WITH protect, noconstant(fillstring(50,"*"))
 DECLARE logmsg = vc WITH protect
 DECLARE totalerrorcnt = i4 WITH protect
 DECLARE totalfixedcnt = i4 WITH protect
 DECLARE cclerrorstr = vc WITH protect
 DECLARE i = i4 WITH protect
 DECLARE k = i4 WITH protect
 DECLARE opsind = i2 WITH protect
 DECLARE autofixind = i2 WITH protect
 DECLARE emailind = i2 WITH protect
 DECLARE emailsuccessind = i2 WITH protect
 DECLARE buildignorestrind = i2 WITH protect
 DECLARE easyignorestr = vc WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE fixedstr = vc WITH protect, noconstant("FIXED")
 DECLARE failurestr = vc WITH protect, noconstant("FAILURE")
 DECLARE infostr = vc WITH protect, noconstant("INFO")
 DECLARE successstr = vc WITH protect, noconstant("SUCCESS")
 DECLARE errorstr = vc WITH protect, noconstant("ERROR")
 DECLARE ignoredstr = vc WITH protect, noconstant("IGNORED")
 DECLARE auditnotigneligible = vc WITH protect, noconstant(
  "Audit not eligible to create ignore strings")
 DECLARE summaryrptname = vc WITH protect
 DECLARE outputcsvname = vc WITH protect
 RECORD temp_ignores(
   1 list_sz = i4
   1 list[*]
     2 id = vc
 ) WITH protect
 RECORD audits(
   1 header_name = vc
   1 current_run_dt_tm = dq8
   1 prev_run_dt_tm = dq8
   1 pass_rate = f8
   1 current_pass_cnt = i4
   1 prev_pass_cnt = i4
   1 report_sentence = vc
   1 url = vc
   1 list[*]
     2 name = vc
     2 description = vc
     2 category = vc
     2 bypass_audit = i2
     2 prev_fail_cnt = i4
     2 current_fail_cnt = i4
     2 primary_key_type = vc
     2 results[*]
       3 status_str = vc
       3 item = vc
       3 old_value_disp = vc
       3 old_value_id = vc
       3 new_value_disp = vc
       3 new_value_id = vc
       3 primary_key = vc
       3 last_updt_prsnl = vc
       3 last_updt_dt_tm = dq8
       3 last_updt_cnt = i4
 ) WITH protect
 IF (validate(request->batch_selection,"-1")="-1")
  SET opsind = 0
  SET fixedstr = "PROPOSED FIX"
  IF (validate(reply->ops_event,"-1")="-1")
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH persistscript
  ENDIF
  IF (validate(ignorestrmode)=0)
   SET buildignorestrind = 0
  ELSE
   IF (ignorestrmode=1)
    SET buildignorestrind = 1
   ENDIF
  ENDIF
 ELSE
  SET opsind = 1
 ENDIF
 SET logfilename = concat("ams_periop_health_check_",trim(cnvtlower(curdomain)),"_",cnvtlower(format(
    cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 SET summaryrptname = concat("ams_periop_health_check_summary_rpt_",trim(cnvtlower(curdomain)),"_",
  cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".pdf")
 SET outputcsvname = concat("ams_periop_health_check_detail_log_",trim(cnvtlower(curdomain)),"_",
  cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".csv")
 SET status = "S"
 SET statusstr = "Script failed for unknown reason"
 SET reply->status_data.status = "F"
 SET reply->ops_event = statusstr
 CALL addlogmsg(infostr,linestr)
 CALL addlogmsg(infostr,"Beginning periop health check")
 CALL addlogmsg(infostr,linestr)
 CALL loadignorevalues(script_name)
 IF (loadprefs(script_name)=1)
  SET pos = locateval(i,1,prefs->list_sz,"AUTO_FIX",prefs->list[i].pref_name)
  IF ((prefs->list[i].value="YES"))
   SET autofixind = 1
  ELSE
   SET autofixind = 0
   SET fixedstr = "PROPOSED FIX"
  ENDIF
  SET pos = locateval(i,1,prefs->list_sz,"SEND_EMAIL_FROM_DOMAIN",prefs->list[i].pref_name)
  IF ((prefs->list[i].value="YES"))
   SET emailind = 1
  ELSE
   SET emailind = 0
  ENDIF
  SET pos = locateval(i,1,prefs->list_sz,"EMAIL_ON_SUCCESS",prefs->list[i].pref_name)
  IF ((prefs->list[i].value="YES"))
   SET emailsuccessind = 1
  ELSE
   SET emailsuccessind = 0
  ENDIF
 ELSE
  SET status = "F"
  SET statusstr = "Failed to load preferences"
  GO TO exit_script
 ENDIF
 CALL loadpreviousresults(null)
 IF (opsind=1)
  SET stat = deleteerrorcnt(build(script_name,"|*"))
  IF (error(statusstr,0)=1)
   SET status = "F"
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET totalerrorcnt = (totalerrorcnt+ revokeblankrecordstask(null))
 IF (buildignorestrind=0)
  IF (opsind=1
   AND autofixind=1)
   CALL addlogmsg(infostr,linestr)
   CALL addlogmsg(infostr,build2("Total number of errors fixed: ",trim(cnvtstring(totalfixedcnt))))
   CALL addlogmsg(infostr,linestr)
  ENDIF
  CALL addlogmsg(infostr,linestr)
  CALL addlogmsg(infostr,build2("Total number of errors found: ",trim(cnvtstring(totalerrorcnt))))
  CALL addlogmsg(infostr,linestr)
  IF (autofixind=0)
   SET logmsg = "All proposed fixes have not been saved due to preference setting."
   CALL addlogmsg(infostr,logmsg)
  ENDIF
  IF (opsind=0)
   SET logmsg = "All proposed fixes have not been saved because the script was executed manually."
   CALL addlogmsg(infostr,logmsg)
  ENDIF
 ENDIF
 CALL addlogmsg(infostr,"Creating output CSV file")
 CALL createoutputcsv(outputcsvname)
 CALL addlogmsg(infostr,"Creating summary report")
 SET audits->pass_rate = (cnvtreal(audits->current_pass_cnt)/ cnvtreal(size(audits->list,5)))
 EXECUTE ams_health_check_report value(summaryrptname)
 CALL addlogmsg(infostr,"Creating log file")
 CALL createlogfile(logfilename)
 SUBROUTINE revokeblankrecordstask(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("REVOKE_BLANK_RECORDS_TASK")
   DECLARE totalstr = vc WITH protect
   DECLARE dba_app_group_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2987"))
   DECLARE task_number = i4 WITH protect, constant(802819)
   SET totalstr = "Total number of DBA app groups with access to the Revoke Blank Records task: "
   RECORD app_groups(
     1 list[*]
       2 app_group_cd = f8
   ) WITH protect
   SET stat = initrec(temp_ignores)
   SET pos = locateval(i,1,ignores->list_sz,concat(script_name,"|",auditname),ignores->list[i].name)
   CALL addlogmsg(infostr,linestr)
   CALL addlogmsg(infostr,build2("Beginning test #",trim(cnvtstring(pos)),": ",ignores->list[pos].
     description))
   CALL addlogmsg(infostr,linestr)
   SET temp_ignores->list_sz = size(ignores->list[pos].values,5)
   SET stat = alterlist(temp_ignores->list,temp_ignores->list_sz)
   FOR (i = 1 TO size(ignores->list[pos].values,5))
     SET temp_ignores->list[i].id = ignores->list[pos].values[i].id
   ENDFOR
   IF ((ignores->list[pos].bypass_audit != 1))
    SELECT INTO "nl:"
     ta.app_group_cd
     FROM application_task at,
      task_access ta,
      prsnl p
     PLAN (at
      WHERE at.task_number=task_number)
      JOIN (ta
      WHERE ta.task_number=at.task_number
       AND ta.app_group_cd=dba_app_group_cd
       AND  NOT (expand(i,1,temp_ignores->list_sz,ta.app_group_cd,cnvtreal(temp_ignores->list[i].id))
      ))
      JOIN (p
      WHERE p.person_id=ta.updt_id)
     DETAIL
      IF (buildignorestrind=1)
       CALL createeasyignorestr(cnvtstring(),0)
      ELSE
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(app_groups->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,
         (errorcnt+ 9))
       ENDIF
       audits->list[pos].results[errorcnt].primary_key = cnvtstring(ta.app_group_cd), audits->list[
       pos].results[errorcnt].item = uar_get_code_display(ta.app_group_cd), audits->list[pos].
       results[errorcnt].old_value_id = "",
       audits->list[pos].results[errorcnt].old_value_disp = "Granted", audits->list[pos].results[
       errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
       last_updt_dt_tm = ta.updt_dt_tm,
       audits->list[pos].results[errorcnt].last_updt_cnt = ta.updt_cnt, audits->list[pos].results[
       errorcnt].status_str = fixedstr, audits->list[pos].results[errorcnt].new_value_id = "",
       audits->list[pos].results[errorcnt].new_value_disp = "Revoked", app_groups->list[fixedcnt].
       app_group_cd = ta.app_group_cd
      ENDIF
     FOOT REPORT
      IF (buildignorestrind=1)
       CALL createeasyignorestr("",1)
      ENDIF
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
      IF (mod(fixedcnt,10) != 0)
       stat = alterlist(app_groups->list,fixedcnt)
      ENDIF
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     SET logmsg = "No DBA app groups found with the task Revoke Blank Records granted"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       ta.task_number
       FROM (dummyt d  WITH seq = value(size(app_groups->list,5))),
        task_access ta
       PLAN (d)
        JOIN (ta
        WHERE ta.task_number=task_number
         AND (ta.app_group_cd=app_groups->list[d.seq].app_group_cd))
       WITH nocounter, forupdate(ta)
      ;end select
      DELETE  FROM (dummyt d  WITH seq = value(size(app_groups->list,5))),
        task_access ta
       SET ta.seq = 0
       PLAN (d)
        JOIN (ta
        WHERE ta.task_number=task_number
         AND (ta.app_group_cd=app_groups->list[d.seq].app_group_cd))
       WITH nocounter
      ;end delete
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2(
        "Total number of DBA app groups that had the Revoke Blank Records task revoked: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error revoking Revoke Blank Records task. See ",logfilename)
       CALL addlogmsg(errorstr,"ERROR REMOVING ROW(S) FROM TASK_ACCESS. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the app groups in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (autofixind=1
     AND opsind=1)
     CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
    ELSE
     CALL addtrackingrow(auditname,errorcnt,totalstr)
    ENDIF
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE createfixlog(null)
  DECLARE fixlogname = vc WITH protect, noconstant(cnvtlower(build2(clientstr,"_",trim(curdomain),
     "_fix_log_",format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q"),
     ".csv")))
  IF (totalfixedcnt > 0
   AND autofixind=1)
   SELECT INTO value(fixlogname)
    audit_name = substring(1,1000,audits->list[d1.seq].name), fixed_item_description = substring(1,
     1000,audits->list[d1.seq].results[d2.seq].item), fixed_item_prim_key = substring(1,1000,audits->
     list[d1.seq].primary_key_type),
    fixed_item_prim_key_value = substring(1,1000,audits->list[d1.seq].results[d2.seq].primary_key),
    new_value = substring(1,1000,audits->list[d1.seq].results[d2.seq].new_value_id), old_value =
    substring(1,1000,audits->list[d1.seq].results[d2.seq].old_value_id),
    last_person_to_updt = substring(1,1000,audits->list[d1.seq].results[d2.seq].last_updt_prsnl),
    last_updt_dt_tm = format(audits->list[d1.seq].results[d2.seq].last_updt_dt_tm,";;q"),
    last_updt_cnt = audits->list[d1.seq].results[d2.seq].last_updt_cnt
    FROM (dummyt d1  WITH seq = value(size(audits->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(audits->list[d1.seq].results,5)))
     JOIN (d2
     WHERE (audits->list[d1.seq].results[d2.seq].status_str=fixedstr))
    WITH format = stream, pcformat('"',",",1), format,
     append
   ;end select
   SET vclogemailsubject = build2(vclogemailsubject," fixed count: ",trim(cnvtstring(totalfixedcnt)))
   SET stat = emailfile(clogmailbox,cfrom,vclogemailsubject,"",fixlogname)
   IF (stat=1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE createoutputcsv(filename)
   SELECT
    IF (autofixind=1
     AND opsind=1)INTO value(filename)
     status = substring(1,1000,audits->list[d1.seq].results[d2.seq].status_str), audit = substring(1,
      1000,build2("#",trim(cnvtstring(d1.seq)),": ",audits->list[d1.seq].description)), item =
     substring(1,1000,audits->list[d1.seq].results[d2.seq].item),
     current_setting = substring(1,1000,audits->list[d1.seq].results[d2.seq].old_value_disp),
     new_setting = substring(1,1000,audits->list[d1.seq].results[d2.seq].new_value_disp),
     primary_key_type = substring(1,1000,audits->list[d1.seq].primary_key_type),
     primary_key = substring(1,1000,audits->list[d1.seq].results[d2.seq].primary_key),
     last_updt_dt_tm = format(audits->list[d1.seq].results[d2.seq].last_updt_dt_tm,";;q"),
     last_updt_person = substring(1,1000,audits->list[d1.seq].results[d2.seq].last_updt_prsnl)
    ELSE INTO value(filename)
     status = substring(1,1000,audits->list[d1.seq].results[d2.seq].status_str), audit = substring(1,
      1000,build2("#",trim(cnvtstring(d1.seq)),": ",audits->list[d1.seq].description)), item =
     substring(1,1000,audits->list[d1.seq].results[d2.seq].item),
     current_setting = substring(1,1000,audits->list[d1.seq].results[d2.seq].old_value_disp),
     proposed_setting = substring(1,1000,audits->list[d1.seq].results[d2.seq].new_value_disp),
     primary_key_type = substring(1,1000,audits->list[d1.seq].primary_key_type),
     primary_key = substring(1,1000,audits->list[d1.seq].results[d2.seq].primary_key),
     last_updt_dt_tm = format(audits->list[d1.seq].results[d2.seq].last_updt_dt_tm,";;q"),
     last_updt_person = substring(1,1000,audits->list[d1.seq].results[d2.seq].last_updt_prsnl)
    ENDIF
    FROM (dummyt d1  WITH seq = value(size(audits->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(audits->list[d1.seq].results,5)))
     JOIN (d2)
    WITH format = stream, pcformat('"',",",1), format
   ;end select
 END ;Subroutine
 SUBROUTINE createeasyignorestr(nextstr,lastind)
  SET nextstr = trim(nextstr)
  IF (lastind=0)
   IF (easyignorestr="")
    SET easyignorestr = nextstr
   ELSEIF (((textlen(easyignorestr)+ textlen(nextstr)) < 74))
    SET easyignorestr = build(easyignorestr,",",nextstr)
   ELSE
    CALL addlogmsg(infostr,easyignorestr)
    SET easyignorestr = nextstr
   ENDIF
  ELSE
   IF (textlen(nextstr) > 0)
    IF (easyignorestr="")
     SET easyignorestr = nextstr
    ELSEIF (((textlen(easyignorestr)+ textlen(nextstr)) < 74))
     SET easyignorestr = build(easyignorestr,",",nextstr)
    ELSE
     CALL addlogmsg(infostr,easyignorestr)
     SET easyignorestr = nextstr
    ENDIF
   ENDIF
   CALL addlogmsg(infostr,easyignorestr)
   SET easyignorestr = ""
  ENDIF
 END ;Subroutine
 SUBROUTINE addtrackingrow(audit,cnt,desc)
   IF (incrementerrorcnt(build(script_name,"|",audit),cnt,desc)=0)
    SET status = "F"
    SET statusstr = build2("Failed to set error count for audit: ",audit)
    GO TO exit_script
   ENDIF
   SET pos = locateval(i,1,size(audits->list,5),build(script_name,"|",audit),audits->list[i].name)
   IF (pos > 0)
    SET audits->list[pos].current_fail_cnt = cnt
   ELSE
    SET status = "F"
    SET statusstr = build2("Failed to find audit ",audit," in audits record")
    GO TO exit_script
   ENDIF
   IF (cnt=0)
    SET audits->current_pass_cnt = (audits->current_pass_cnt+ 1)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadpreviousresults(null)
   SET audits->header_name = "Periop Health Check"
   SET audits->report_sentence = build2(
    "The AMS Periop Health Check is a collection of audits that identify",
    " common errors that may cause a diminished user experience. For more information on each audit including",
    " failure criteria and resolution steps visit ")
   SET audits->current_run_dt_tm = cnvtdatetime(curdate,curtime3)
   SELECT INTO "nl:"
    d.updt_dt_tm
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=script_name
    DETAIL
     audits->prev_run_dt_tm = d.updt_dt_tm
    WITH nocounter
   ;end select
   SET stat = alterlist(audits->list,ignores->list_sz)
   FOR (i = 1 TO ignores->list_sz)
     SET audits->list[i].name = ignores->list[i].name
     SET audits->list[i].primary_key_type = ignores->list[i].primary_key
     SET audits->list[i].description = ignores->list[i].description
     SET audits->list[i].category = ignores->list[i].category
     SET audits->list[i].bypass_audit = ignores->list[i].bypass_audit
     SET stat = alterlist(audits->list[i].results,1)
     IF ((audits->prev_run_dt_tm != 0))
      SET audits->list[i].prev_fail_cnt = geterrorcnt(ignores->list[i].name)
      IF ((audits->list[i].prev_fail_cnt=0))
       SET audits->prev_pass_cnt = (audits->prev_pass_cnt+ 1)
      ENDIF
     ELSE
      SET audits->list[i].prev_fail_cnt = - (1)
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (status="S")
  SET statusstr = build2("Script completed successfully and found ",trim(cnvtstring(totalerrorcnt)),
   " errors")
  SET reply->status_data.status = "S"
  SET reply->ops_event = statusstr
  IF (opsind=1)
   IF (autofixind=1)
    IF (createfixlog(null)=0)
     SET statusstr =
     "Sending log file to AMS mailbox failed. Contact the AMS SurgiNet team to investigate."
     SET reply->status_data.status = "F"
     SET reply->ops_event = statusstr
     ROLLBACK
    ENDIF
   ENDIF
   IF (incrementerrorcnt(script_name,totalerrorcnt,
    "Total number of errors found by ops job since installation")=0)
    SET statusstr = "Incrementing error count failed. Contact the AMS SurgiNet team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
  ELSE
   ROLLBACK
  ENDIF
  IF (opsind=1
   AND emailind=1
   AND ((totalerrorcnt > 0) OR (emailsuccessind=1)) )
   SET vcsubject = concat(vcsubject," Errors found: ",trim(cnvtstring(totalerrorcnt)))
   IF (emailfile(trim(request->output_dist),cfrom,vcsubject,"",outputcsvname)=0)
    SET statusstr = "Emailing output CSV file failed. Contact the AMS SurgiNet team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
   ELSE
    SET vcsubject = build2("AMS Periop Health Check Summary Report ",clientstr,": ",curdomain)
    IF (emailfile(trim(request->output_dist),cfrom,vcsubject,"",summaryrptname)=0)
     SET statusstr = "Emailing summary report failed. Contact the AMS SurgiNet team to investigate."
     SET reply->status_data.status = "F"
     SET reply->ops_event = statusstr
    ENDIF
   ENDIF
  ENDIF
 ELSE
  ROLLBACK
  CALL createlogfile(logfilename)
  IF (opsind=1
   AND emailind=1)
   SET vcsubject = concat(vcsubject," Script failed to complete successfully")
   IF (emailfile(trim(request->output_dist),cfrom,vcsubject,"",logfilename)=0)
    SET statusstr = "Sending email failed. Contact the AMS SurgiNet team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
   ENDIF
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusstr
 ENDIF
 SET last_mod = "000"
END GO
