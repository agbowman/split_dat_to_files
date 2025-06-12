CREATE PROGRAM ams_periop_health_check_util:dba
 PAINT
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
 DECLARE displayaudits(null) = null WITH protect
 DECLARE runaudits(null) = null WITH protect
 DECLARE turnonallaudits(null) = null WITH protect
 DECLARE turnoffallaudits(null) = null WITH protect
 DECLARE buildignorestrings(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                   AMS Perioperative Health Check Utility                   ")
 DECLARE detail_line = c75 WITH protect, constant(
  "     Perform audits of perioperative build and output results to a file     ")
 DECLARE from_str = vc WITH protect, constant("ams_periop_health_check@cerner.com")
 DECLARE script_name = c23 WITH protect, constant("AMS_PERIOP_HEALTH_CHECK")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE i = i4 WITH protect
 DECLARE ignorestrmode = i2 WITH protect
 SET logfilename = concat("ams_periop_health_check_utility_",cnvtlower(format(cnvtdatetime(curdate,
     curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_periop_health_check_utility")
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 IF (loadprefs(script_name)=0)
  CALL clearscreen(null)
  CALL setprefs(script_name,1)
  CALL clearscreen(null)
  CALL text(quesrow,soffcol,"Choose an option:")
 ENDIF
 CALL text((soffrow+ 4),(soffcol+ 29),"1 Run Audits")
 CALL text((soffrow+ 5),(soffcol+ 29),"2 View/Modify Ignored Items")
 CALL text((soffrow+ 6),(soffcol+ 29),"3 Turn On All Audits")
 CALL text((soffrow+ 7),(soffcol+ 29),"4 Turn Off All Audits")
 CALL text((soffrow+ 8),(soffcol+ 29),"5 View/Modify Preferences")
 CALL text((soffrow+ 9),(soffcol+ 29),"6 Create Ignore Strings")
 CALL text((soffrow+ 10),(soffcol+ 29),"7 Exit")
 CALL text(quesrow,(soffcol+ 37),build2("Errors found since install: ",trim(format(geterrorcnt(
      script_name),";,;"),3)))
 CALL accept(quesrow,(soffcol+ 17),"9;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 CASE (curaccept)
  OF 1:
   CALL runaudits(null)
  OF 2:
   CALL displayaudits(null)
  OF 3:
   CALL turnonallaudits(null)
  OF 4:
   CALL turnoffallaudits(null)
  OF 5:
   CALL displayprefs(script_name)
  OF 6:
   CALL buildignorestrings(null)
  OF 7:
   GO TO exit_script
 ENDCASE
 SUBROUTINE runaudits(null)
   DECLARE logfilename = vc WITH protect
   DECLARE summaryrptname = vc WITH protect
   DECLARE outputcsvname = vc WITH protect
   SET logfilename = concat("ams_periop_health_check_",trim(cnvtlower(curdomain)),"_",cnvtlower(
     format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
   SET summaryrptname = concat("ams_periop_health_check_summary_rpt_",trim(cnvtlower(curdomain)),"_",
    cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".pdf")
   SET outputcsvname = concat("ams_periop_health_check_detail_log_",trim(cnvtlower(curdomain)),"_",
    cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".csv")
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Running audits...")
   SET message = window
   EXECUTE ams_periop_health_check
   IF (ignorestrmode=0)
    CALL text((soffrow+ 1),soffcol,reply->ops_event)
   ELSE
    CALL text((soffrow+ 1),soffcol,"Ignore strings created")
   ENDIF
   CALL text(soffrow,(soffcol+ 17),"done")
   CALL text((soffrow+ 2),soffcol,"Files:")
   CALL text((soffrow+ 3),soffcol,logfilename)
   CALL text((soffrow+ 4),soffcol,summaryrptname)
   CALL text((soffrow+ 5),soffcol,outputcsvname)
   CALL text((soffrow+ 7),soffcol,"Do you want to email the files?:")
   CALL accept((soffrow+ 7),(soffcol+ 32),"A;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text((soffrow+ 8),soffcol,"Enter recepient's email address:")
    CALL accept((soffrow+ 9),(soffcol+ 1),"P(74);C",trim(gethnaemail(null))
     WHERE trim(curaccept)="*@*.*")
    IF (emailfile(curaccept,from_str,"","",summaryrptname))
     IF (emailfile(curaccept,from_str,"","",outputcsvname))
      CALL text((soffrow+ 10),soffcol,"Emailed files successfully")
     ELSE
      CALL text((soffrow+ 10),soffcol,
       "Email failed for CSV file. Manually grab files from CCLUSERDIR")
     ENDIF
    ELSE
     CALL text((soffrow+ 10),soffcol,
      "Email failed for summary report. Manually grab files from CCLUSERDIR")
    ENDIF
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
   SET ignorestrmode = 0
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE buildignorestrings(null)
  SET ignorestrmode = 1
  CALL runaudits(null)
 END ;Subroutine
 SUBROUTINE displayaudits(null)
   CALL clearscreen(null)
   CALL loadignorevalues(script_name)
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND (cnt < ignores->list_sz))
     SET cnt = (cnt+ 1)
     SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,61,ignores->list[cnt].description),
      "  ",
      IF ((ignores->list[cnt].bypass_audit=1)) "ALL"
      ELSEIF (size(ignores->list[cnt].values,5)=1)
       IF ((ignores->list[cnt].values[1].id="NONE")) "0"
       ELSE "1"
       ENDIF
      ELSE trim(cnvtstring(size(ignores->list[cnt].values,5)))
      ENDIF
      )
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text(soffrow,soffcol,"Choose an audit to view ignored values")
   CALL text((soffrow+ 1),(soffcol+ 5),"Audit")
   CALL text((soffrow+ 1),(soffcol+ 60),"Num ignored")
   WHILE (pick=0)
     CALL text(quesrow,soffcol,"Continue?:")
     CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="Y")
        CALL displayignorevalues(script_name,cnt)
       ELSE
        GO TO main_menu
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < ignores->list_sz))
        SET cnt = (cnt+ 1)
        SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,61,ignores->list[cnt].description),
         "  ",
         IF ((ignores->list[cnt].bypass_audit=1)) "ALL"
         ELSEIF (size(ignores->list[cnt].values,5)=1)
          IF ((ignores->list[cnt].values[1].id="NONE")) "0"
          ELSE "1"
          ENDIF
         ELSE trim(cnvtstring(size(ignores->list[cnt].values,5)))
         ENDIF
         )
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,61,ignores->list[cnt].description),
         "  ",
         IF ((ignores->list[cnt].bypass_audit=1)) "ALL"
         ELSEIF (size(ignores->list[cnt].values,5)=1)
          IF ((ignores->list[cnt].values[1].id="NONE")) "0"
          ELSE "1"
          ENDIF
         ELSE trim(cnvtstring(size(ignores->list[cnt].values,5)))
         ENDIF
         )
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE turnonallaudits(null)
   DECLARE ignorecnt = i4 WITH protect
   DECLARE auditcnt = i4 WITH protect
   CALL clearscreen(null)
   CALL loadignorevalues(script_name)
   CALL text(soffrow,soffcol,"Turning on all audits")
   FOR (i = 1 TO ignores->list_sz)
     IF (((size(ignores->list[i].values,5)=0) OR (size(ignores->list[i].values,5)=1
      AND (ignores->list[i].values[1].id="ALL"))) )
      SET stat = addignorevalue(ignores->list[i].name,ignores->list[i].primary_key,"NONE")
      IF (stat=1)
       SET auditcnt = (auditcnt+ 1)
      ELSE
       ROLLBACK
       CALL text((soffrow+ 14),soffcol,build2("Error turning on ",ignores->list[i].name,
         ". Changes rolled back"))
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
       GO TO main_menu
      ENDIF
      IF (size(ignores->list[i].values,5) > 0)
       DELETE  FROM br_name_value bnv
        WHERE (bnv.br_name_value_id=ignores->list[i].values[1].br_name_value_id)
         AND bnv.br_name_value_id != 0.0
        WITH nocounter
       ;end delete
       IF (curqual != 1)
        ROLLBACK
        CALL text((soffrow+ 14),soffcol,build2("Error removing All from ",ignores->list[i].name,
          ". Changes rolled back"))
        CALL text(quesrow,soffcol,"Continue?:")
        CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
         WHERE curaccept IN ("Y"))
        GO TO main_menu
       ENDIF
      ENDIF
     ELSE
      FOR (ignorecnt = 1 TO size(ignores->list[i].values,5))
        IF ((ignores->list[i].values[ignorecnt].id="ALL"))
         SET auditcnt = (auditcnt+ 1)
         DELETE  FROM br_name_value bnv
          WHERE (bnv.br_name_value_id=ignores->list[i].values[ignorecnt].br_name_value_id)
           AND bnv.br_name_value_id != 0.0
          WITH nocounter
         ;end delete
         IF (curqual != 1)
          ROLLBACK
          CALL text((soffrow+ 14),soffcol,build2("Error removing All from ",ignores->list[i].name,
            ". Changes rolled back"))
          CALL text(quesrow,soffcol,"Continue?:")
          CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
           WHERE curaccept IN ("Y"))
          GO TO main_menu
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL text((soffrow+ 14),soffcol,build2("Successfully turned on ",trim(cnvtstring(auditcnt)),
     " audits"))
   CALL text(quesrow,soffcol,"Commit?:")
   CALL accept(quesrow,(soffcol+ 8),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE turnoffallaudits(null)
   DECLARE ignorecnt = i4 WITH protect
   DECLARE auditcnt = i4 WITH protect
   DECLARE nonefound = i2 WITH protect
   DECLARE allfound = i2 WITH protect
   DECLARE k = i4 WITH protect
   CALL clearscreen(null)
   CALL loadignorevalues(script_name)
   CALL text(soffrow,soffcol,"Turning off all audits")
   FOR (i = 1 TO ignores->list_sz)
     SET nonefound = 0
     SET allfound = 0
     FOR (k = 1 TO size(ignores->list[i].values,5))
       IF ((ignores->list[i].values[k].id="ALL"))
        SET allfound = 1
       ELSEIF ((ignores->list[i].values[k].id="NONE"))
        SET nonefound = 1
       ENDIF
     ENDFOR
     IF (size(ignores->list[i].values,5) > 0
      AND allfound=0
      AND nonefound=0)
      SET auditcnt = (auditcnt+ 1)
      SET stat = addignorevalue(ignores->list[i].name,ignores->list[i].primary_key,"ALL")
      IF (stat != 1)
       ROLLBACK
       CALL text((soffrow+ 14),soffcol,build2("Error adding All to ",ignores->list[i].name,
         ". Changes rolled back"))
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
       GO TO main_menu
      ENDIF
     ENDIF
     IF ((ignores->list[i].values[1].id="NONE"))
      SET auditcnt = (auditcnt+ 1)
      DELETE  FROM br_name_value bnv
       WHERE (bnv.br_name_value_id=ignores->list[i].values[1].br_name_value_id)
        AND bnv.br_name_value_id != 0.0
       WITH nocounter
      ;end delete
      IF (curqual != 1)
       ROLLBACK
       CALL text((soffrow+ 14),soffcol,build2("Error removing None from ",ignores->list[i].name,
         ". Changes rolled back"))
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
       GO TO main_menu
      ENDIF
     ENDIF
   ENDFOR
   CALL text((soffrow+ 14),soffcol,build2("Successfully turned off ",trim(cnvtstring(auditcnt)),
     " audits"))
   CALL text(quesrow,soffcol,"Commit?:")
   CALL accept(quesrow,(soffcol+ 8),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
   GO TO main_menu
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  CALL echo(statusstr)
 ENDIF
 IF (debug_ind=1)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "000"
END GO
