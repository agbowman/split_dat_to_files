CREATE PROGRAM ams_pharm_health_check:dba
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
 DECLARE sortignoresrec(null) = null WITH protect
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
    OF "AMS_PHARM_HEALTH_CHECK":
     SET numofprefs = 5
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
     SET prefs->list[4].question = "What is the maximum number of unverified orders before failing?"
     SET prefs->list[4].pref_domain = pref_domain
     SET prefs->list[4].pref_section = scriptname
     SET prefs->list[4].pref_name = "MAX_NUM_UNVERIFIED_ORDERS"
     SET prefs->list[4].pref_type = "NUMERIC"
     SET prefs->list[4].min_value = 0
     SET prefs->list[4].max_value = 999999
     SET prefs->list[4].value = ""
     SET prefs->list[5].question = "What is the maximum number of pending charges before failing?"
     SET prefs->list[5].pref_domain = pref_domain
     SET prefs->list[5].pref_section = scriptname
     SET prefs->list[5].pref_name = "MAX_NUM_PENDING_CHARGES"
     SET prefs->list[5].pref_type = "NUMERIC"
     SET prefs->list[5].min_value = 0
     SET prefs->list[5].max_value = 999999
     SET prefs->list[5].value = ""
    OF "AMS_FILL_BATCH_CHECK":
     SET numofprefs = 1
     SET prefs->list_sz = numofprefs
     SET stat = alterlist(prefs->list,numofprefs)
     SET prefs->list[1].question = "Do you want the ops job to email failures from this domain?"
     SET prefs->list[1].pref_domain = pref_domain
     SET prefs->list[1].pref_section = scriptname
     SET prefs->list[1].pref_name = "SEND_EMAIL_FROM_DOMAIN"
     SET prefs->list[1].pref_type = "YESNO"
     SET prefs->list[1].yes_value = trim(curdomain)
     SET prefs->list[1].no_value = "NO"
     SET prefs->list[1].value = ""
    OF "AMS_EMAIL_FILE":
     SET numofprefs = 1
     SET prefs->list_sz = numofprefs
     SET stat = alterlist(prefs->list,numofprefs)
     SET prefs->list[1].question = "Do you want to send the file as the body of the email?"
     SET prefs->list[1].pref_domain = pref_domain
     SET prefs->list[1].pref_section = scriptname
     SET prefs->list[1].pref_name = "SEND_FILE_AS_BODY"
     SET prefs->list[1].pref_type = "YESNO"
     SET prefs->list[1].yes_value = "YES"
     SET prefs->list[1].no_value = "NO"
     SET prefs->list[1].value = ""
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
    OF "AMS_PHARM_HEALTH_CHECK":
     SET numofaudits = 35
     SET ignores->list_sz = numofaudits
     SET stat = alterlist(ignores->list,numofaudits)
     SET ignores->list[1].description = "Primaries with an invalid CKI"
     SET ignores->list[1].name = concat(trim(scriptname),"|INVALID_CKIS")
     SET ignores->list[1].category = "Order Catalog - Orderables"
     SET ignores->list[1].category_alias = "OCO"
     SET ignores->list[1].default_audit_off_ind = 1
     SET ignores->list[1].primary_key = "CATALOG_CD"
     SET ignores->list[1].table_name = "ORDER_CATALOG"
     SET ignores->list[1].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[1].where_str = "CATALOG_CD = "
     SET ignores->list[2].description = "Synonyms without an OEF"
     SET ignores->list[2].name = concat(trim(scriptname),"|SYNONYMS_WITHOUT_OEF")
     SET ignores->list[2].category = "Order Catalog - Synonyms"
     SET ignores->list[2].category_alias = "OCS"
     SET ignores->list[2].default_audit_off_ind = 1
     SET ignores->list[2].primary_key = "SYNONYM_ID"
     SET ignores->list[2].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[2].disp_field_name = "MNEMONIC"
     SET ignores->list[2].where_str = "SYNONYM_ID = "
     SET ignores->list[3].description = "Synonyms without an rx mask"
     SET ignores->list[3].name = concat(trim(scriptname),"|SYNONYMS_WITHOUT_RX_MASK")
     SET ignores->list[3].category = "Order Catalog - Synonyms"
     SET ignores->list[3].category_alias = "OCS"
     SET ignores->list[3].default_audit_off_ind = 1
     SET ignores->list[3].primary_key = "SYNONYM_ID"
     SET ignores->list[3].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[3].disp_field_name = "MNEMONIC"
     SET ignores->list[3].where_str = "SYNONYM_ID = "
     SET ignores->list[4].description = "Synonyms in Multum that are not in the order catalog"
     SET ignores->list[4].name = concat(trim(scriptname),"|MISSING_MLTM_SYNS")
     SET ignores->list[4].category = "Order Catalog - Synonyms"
     SET ignores->list[4].category_alias = "OCS"
     SET ignores->list[4].default_audit_off_ind = 1
     SET ignores->list[4].primary_key = "CKI"
     SET ignores->list[4].table_name = "MLTM_ORDER_CATALOG_LOAD"
     SET ignores->list[4].disp_field_name = "MNEMONIC"
     SET ignores->list[4].where_str = "SYNONYM_CKI = "
     SET ignores->list[5].description = "Primaries without a task"
     SET ignores->list[5].name = concat(trim(scriptname),"|PRIMARIES_WITHOUT_TASK")
     SET ignores->list[5].category = "Order Catalog - Orderables"
     SET ignores->list[5].category_alias = "OCO"
     SET ignores->list[5].default_audit_off_ind = 1
     SET ignores->list[5].primary_key = "CATALOG_CD"
     SET ignores->list[5].table_name = "ORDER_CATALOG"
     SET ignores->list[5].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[5].where_str = "CATALOG_CD = "
     SET ignores->list[6].description = "Primaries without an event code"
     SET ignores->list[6].name = concat(trim(scriptname),"|PRIMARIES_WITHOUT_EC")
     SET ignores->list[6].category = "Order Catalog - Orderables"
     SET ignores->list[6].category_alias = "OCO"
     SET ignores->list[6].default_audit_off_ind = 1
     SET ignores->list[6].primary_key = "CATALOG_CD"
     SET ignores->list[6].table_name = "ORDER_CATALOG"
     SET ignores->list[6].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[6].where_str = "CATALOG_CD = "
     SET ignores->list[7].description = "Rows on fill_print_hx with a run_type_cd = 0 or UNKNOWN"
     SET ignores->list[7].name = concat(trim(scriptname),"|RUN_TYPE_CD_ZERO")
     SET ignores->list[7].category = "Purges"
     SET ignores->list[7].category_alias = "P"
     SET ignores->list[7].default_audit_off_ind = 1
     SET ignores->list[7].primary_key = "RUN_ID"
     SET ignores->list[7].table_name = "FILL_PRINT_HX"
     SET ignores->list[7].disp_field_name = "RUN_ID"
     SET ignores->list[7].where_str = "RUN_ID = "
     SET ignores->list[8].description = "Rows on fill_print_ord_hx older than purge settings"
     SET ignores->list[8].name = concat(trim(scriptname),"|FPOH_AGING_ROWS")
     SET ignores->list[8].category = "Purges"
     SET ignores->list[8].category_alias = "P"
     SET ignores->list[8].default_audit_off_ind = 1
     SET ignores->list[8].primary_key = "RUN_ID"
     SET ignores->list[8].table_name = "FILL_PRINT_HX"
     SET ignores->list[8].disp_field_name = "RUN_ID"
     SET ignores->list[8].where_str = "RUN_ID = "
     SET ignores->list[9].description = "Orders that are pending verification"
     SET ignores->list[9].name = concat(trim(scriptname),"|UNVERIFIED_ORDERS")
     SET ignores->list[9].category = "Usability"
     SET ignores->list[9].category_alias = "U"
     SET ignores->list[9].default_audit_off_ind = 1
     SET ignores->list[9].primary_key = "ORDER_ID"
     SET ignores->list[9].table_name = "ORDER_DISPENSE"
     SET ignores->list[9].disp_field_name = "ORDER_ID"
     SET ignores->list[9].where_str = "ORDER_ID = "
     SET ignores->list[10].description = "Charges that are pending review"
     SET ignores->list[10].name = concat(trim(scriptname),"|PENDING_CHARGES")
     SET ignores->list[10].category = "Usability"
     SET ignores->list[10].category_alias = "U"
     SET ignores->list[10].default_audit_off_ind = 1
     SET ignores->list[10].primary_key = "RX_PENDING_CHARGE_ID"
     SET ignores->list[10].table_name = "RX_PENDING_CHARGE"
     SET ignores->list[10].disp_field_name = "RX_PENDING_CHARGE_ID"
     SET ignores->list[10].where_str = "RX_PENDING_CHARGE_ID = "
     SET ignores->list[11].description = "Primaries with a duplicated CKI"
     SET ignores->list[11].name = concat(trim(scriptname),"|DUPLICATE_DNUMS")
     SET ignores->list[11].category = "Order Catalog - Orderables"
     SET ignores->list[11].category_alias = "OCO"
     SET ignores->list[11].default_audit_off_ind = 1
     SET ignores->list[11].primary_key = "CKI"
     SET ignores->list[11].table_name = "ORDER_CATALOG"
     SET ignores->list[11].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[11].where_str = "CKI = "
     SET ignores->list[12].description = "Primaries with incorrect order review settings"
     SET ignores->list[12].name = concat(trim(scriptname),"|ORD_CAT_REVIEW")
     SET ignores->list[12].category = "Order Catalog - Orderables"
     SET ignores->list[12].category_alias = "OCO"
     SET ignores->list[12].default_audit_off_ind = 1
     SET ignores->list[12].primary_key = "CATALOG_CD"
     SET ignores->list[12].table_name = "ORDER_CATALOG"
     SET ignores->list[12].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[12].where_str = "CATALOG_CD = "
     SET ignores->list[13].description = "Primaries with incorrect discontinue days settings"
     SET ignores->list[13].name = concat(trim(scriptname),"|ORD_CAT_DC_DAYS")
     SET ignores->list[13].category = "Order Catalog - Orderables"
     SET ignores->list[13].category_alias = "OCO"
     SET ignores->list[13].default_audit_off_ind = 1
     SET ignores->list[13].primary_key = "CATALOG_CD"
     SET ignores->list[13].table_name = "ORDER_CATALOG"
     SET ignores->list[13].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[13].where_str = "CATALOG_CD = "
     SET ignores->list[14].description = "Primaries with incorrect clinical categories"
     SET ignores->list[14].name = concat(trim(scriptname),"|ORD_CAT_CLINICAL_CAT")
     SET ignores->list[14].category = "Order Catalog - Orderables"
     SET ignores->list[14].category_alias = "OCO"
     SET ignores->list[14].default_audit_off_ind = 1
     SET ignores->list[14].primary_key = "CATALOG_CD"
     SET ignores->list[14].table_name = "ORDER_CATALOG"
     SET ignores->list[14].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[14].where_str = "CATALOG_CD = "
     SET ignores->list[15].description = "Primaries with incorrect pharmacy auto-verify settings"
     SET ignores->list[15].name = concat(trim(scriptname),"|ORD_CAT_AUTO_VERIFY")
     SET ignores->list[15].category = "Order Catalog - Orderables"
     SET ignores->list[15].category_alias = "OCO"
     SET ignores->list[15].default_audit_off_ind = 1
     SET ignores->list[15].primary_key = "CATALOG_CD"
     SET ignores->list[15].table_name = "ORDER_CATALOG"
     SET ignores->list[15].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[15].where_str = "CATALOG_CD = "
     SET ignores->list[16].description = "Primaries with incorrect stop type settings"
     SET ignores->list[16].name = concat(trim(scriptname),"|ORD_CAT_STOP_TYPE")
     SET ignores->list[16].category = "Order Catalog - Orderables"
     SET ignores->list[16].category_alias = "OCO"
     SET ignores->list[16].default_audit_off_ind = 1
     SET ignores->list[16].primary_key = "CATALOG_CD"
     SET ignores->list[16].table_name = "ORDER_CATALOG"
     SET ignores->list[16].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[16].where_str = "CATALOG_CD = "
     SET ignores->list[17].description = "Primaries with incorrect print requisition settings"
     SET ignores->list[17].name = concat(trim(scriptname),"|ORD_CAT_PRINT_REQ")
     SET ignores->list[17].category = "Order Catalog - Orderables"
     SET ignores->list[17].category_alias = "OCO"
     SET ignores->list[17].default_audit_off_ind = 1
     SET ignores->list[17].primary_key = "CATALOG_CD"
     SET ignores->list[17].table_name = "ORDER_CATALOG"
     SET ignores->list[17].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[17].where_str = "CATALOG_CD = "
     SET ignores->list[18].description = "Primaries with incorrect miscellaneous indicators settings"
     SET ignores->list[18].name = concat(trim(scriptname),"|ORD_CAT_MISC_INDICATORS")
     SET ignores->list[18].category = "Order Catalog - Orderables"
     SET ignores->list[18].category_alias = "OCO"
     SET ignores->list[18].default_audit_off_ind = 1
     SET ignores->list[18].primary_key = "CATALOG_CD"
     SET ignores->list[18].table_name = "ORDER_CATALOG"
     SET ignores->list[18].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[18].where_str = "CATALOG_CD = "
     SET ignores->list[19].description =
     "Primaries with an incorrect continuing order indicator setting"
     SET ignores->list[19].name = concat(trim(scriptname),"|ORD_CAT_CONT_ORD_IND")
     SET ignores->list[19].category = "Order Catalog - Orderables"
     SET ignores->list[19].category_alias = "OCO"
     SET ignores->list[19].default_audit_off_ind = 1
     SET ignores->list[19].primary_key = "CATALOG_CD"
     SET ignores->list[19].table_name = "ORDER_CATALOG"
     SET ignores->list[19].disp_field_name = "PRIMARY_MNEMONIC"
     SET ignores->list[19].where_str = "CATALOG_CD = "
     SET ignores->list[20].description = "Tasks with incorrect indicator settings"
     SET ignores->list[20].name = concat(trim(scriptname),"|TASK_INDICATORS")
     SET ignores->list[20].category = "Tasks"
     SET ignores->list[20].category_alias = "T"
     SET ignores->list[20].default_audit_off_ind = 1
     SET ignores->list[20].primary_key = "REFERENCE_TASK_ID"
     SET ignores->list[20].table_name = "ORDER_TASK"
     SET ignores->list[20].disp_field_name = "TASK_DESCRIPTION"
     SET ignores->list[20].where_str = "REFERENCE_TASK_ID = "
     SET ignores->list[21].description = "Tasks with incorrect type settings"
     SET ignores->list[21].name = concat(trim(scriptname),"|TASK_TYPE")
     SET ignores->list[21].category = "Tasks"
     SET ignores->list[21].category_alias = "T"
     SET ignores->list[21].default_audit_off_ind = 1
     SET ignores->list[21].primary_key = "REFERENCE_TASK_ID"
     SET ignores->list[21].table_name = "ORDER_TASK"
     SET ignores->list[21].disp_field_name = "TASK_DESCRIPTION"
     SET ignores->list[21].where_str = "REFERENCE_TASK_ID = "
     SET ignores->list[22].description = "Tasks with incorrect reschedule or grace period settings"
     SET ignores->list[22].name = concat(trim(scriptname),"|TASK_RESCHEDULE")
     SET ignores->list[22].category = "Tasks"
     SET ignores->list[22].category_alias = "T"
     SET ignores->list[22].default_audit_off_ind = 1
     SET ignores->list[22].primary_key = "REFERENCE_TASK_ID"
     SET ignores->list[22].table_name = "ORDER_TASK"
     SET ignores->list[22].disp_field_name = "TASK_DESCRIPTION"
     SET ignores->list[22].where_str = "REFERENCE_TASK_ID = "
     SET ignores->list[23].description = "Tasks with incorrect positions to chart settings"
     SET ignores->list[23].name = concat(trim(scriptname),"|TASK_POS_TO_CHART")
     SET ignores->list[23].category = "Tasks"
     SET ignores->list[23].category_alias = "T"
     SET ignores->list[23].default_audit_off_ind = 1
     SET ignores->list[23].primary_key = "REFERENCE_TASK_ID"
     SET ignores->list[23].table_name = "ORDER_TASK"
     SET ignores->list[23].disp_field_name = "TASK_DESCRIPTION"
     SET ignores->list[23].where_str = "REFERENCE_TASK_ID = "
     SET ignores->list[24].description =
     "Synonyms that are not hidden and belong to multiple DRC groupers"
     SET ignores->list[24].name = concat(trim(scriptname),"|SYNONYMS_MULTIPLE_GROUPERS")
     SET ignores->list[24].category = "Order Catalog - Synonyms"
     SET ignores->list[24].category_alias = "OCS"
     SET ignores->list[24].default_audit_off_ind = 1
     SET ignores->list[24].primary_key = "SYNONYM_ID"
     SET ignores->list[24].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[24].disp_field_name = "MNEMONIC"
     SET ignores->list[24].where_str = "SYNONYM_ID = "
     SET ignores->list[25].description = "Routes and forms with an invalid authentication status"
     SET ignores->list[25].name = concat(trim(scriptname),"|UNAUTH_CODE_VALUES")
     SET ignores->list[25].category = "Code Sets"
     SET ignores->list[25].category_alias = "CS"
     SET ignores->list[25].default_audit_off_ind = 1
     SET ignores->list[25].primary_key = "CODE_VALUE"
     SET ignores->list[25].table_name = "CODE_VALUE"
     SET ignores->list[25].disp_field_name = "DISPLAY"
     SET ignores->list[25].where_str = "CODE_SET IN (4001, 4002) AND CODE_VALUE = "
     SET ignores->list[26].description =
     "Routes, forms, and units of measure with an invalid Multum alias"
     SET ignores->list[26].name = concat(trim(scriptname),"|INVALID_MULTUM_ALIASES")
     SET ignores->list[26].category = "Code Sets"
     SET ignores->list[26].category_alias = "CS"
     SET ignores->list[26].default_audit_off_ind = 1
     SET ignores->list[26].primary_key = "CODE_VALUE"
     SET ignores->list[26].table_name = "CODE_VALUE"
     SET ignores->list[26].disp_field_name = "DISPLAY"
     SET ignores->list[26].where_str = "CODE_SET IN (54, 4001, 4002) AND CODE_VALUE = "
     SET ignores->list[27].description = "Unmapped Multum aliases for units of measure"
     SET ignores->list[27].name = concat(trim(scriptname),"|UNMAPPED_UOM_ALIASES")
     SET ignores->list[27].category = "Code Sets"
     SET ignores->list[27].category_alias = "CS"
     SET ignores->list[27].default_audit_off_ind = 1
     SET ignores->list[27].primary_key = "UNIT_ID"
     SET ignores->list[27].table_name = "MLTM_UNITS"
     SET ignores->list[27].disp_field_name = "UNIT_DESCRIPTION"
     SET ignores->list[27].where_str = "UNIT_ID = "
     SET ignores->list[28].description = "Unmapped Multum aliases for routes"
     SET ignores->list[28].name = concat(trim(scriptname),"|UNMAPPED_ROUTE_ALIASES")
     SET ignores->list[28].category = "Code Sets"
     SET ignores->list[28].category_alias = "CS"
     SET ignores->list[28].default_audit_off_ind = 1
     SET ignores->list[28].primary_key = "ROUTE_CODE"
     SET ignores->list[28].table_name = "MLTM_PRODUCT_ROUTE"
     SET ignores->list[28].disp_field_name = "ROUTE_DESCRIPTION"
     SET ignores->list[28].where_str = "ROUTE_CODE = "
     SET ignores->list[29].description = "Unmapped Multum aliases for forms"
     SET ignores->list[29].name = concat(trim(scriptname),"|UNMAPPED_FORM_ALIASES")
     SET ignores->list[29].category = "Code Sets"
     SET ignores->list[29].category_alias = "CS"
     SET ignores->list[29].default_audit_off_ind = 1
     SET ignores->list[29].primary_key = "DOSE_FORM_CODE"
     SET ignores->list[29].table_name = "MLTM_DOSE_FORM"
     SET ignores->list[29].disp_field_name = "DOSE_FORM_DESCRIPTION"
     SET ignores->list[29].where_str = "DOSE_FORM_CODE = "
     SET ignores->list[30].description = "Unmapped Multum aliases for PRN reasons"
     SET ignores->list[30].name = concat(trim(scriptname),"|UNMAPPED_PRN_ALIASES")
     SET ignores->list[30].category = "Code Sets"
     SET ignores->list[30].category_alias = "CS"
     SET ignores->list[30].default_audit_off_ind = 1
     SET ignores->list[30].primary_key = "CODE_VALUE"
     SET ignores->list[30].table_name = "CODE_VALUE"
     SET ignores->list[30].disp_field_name = "DISPLAY"
     SET ignores->list[30].where_str = "CODE_SET IN (4005) AND CODE_VALUE = "
     SET ignores->list[31].description = "Synonyms with an incorrect rx mask"
     SET ignores->list[31].name = concat(trim(scriptname),"|SYNONYMS_INCORRECT_RX_MASK")
     SET ignores->list[31].category = "Order Catalog - Synonyms"
     SET ignores->list[31].category_alias = "OCS"
     SET ignores->list[31].default_audit_off_ind = 1
     SET ignores->list[31].primary_key = "SYNONYM_ID"
     SET ignores->list[31].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[31].disp_field_name = "MNEMONIC"
     SET ignores->list[31].where_str = "SYNONYM_ID = "
     SET ignores->list[32].description = "Product identifiers with invalid characters"
     SET ignores->list[32].name = concat(trim(scriptname),"|PRODUCTS_INVALID_CHARS")
     SET ignores->list[32].category = "Formulary"
     SET ignores->list[32].category_alias = "F"
     SET ignores->list[32].default_audit_off_ind = 1
     SET ignores->list[32].primary_key = "MED_IDENTIFIER_ID"
     SET ignores->list[32].table_name = "MED_IDENTIFIER"
     SET ignores->list[32].disp_field_name = "VALUE"
     SET ignores->list[32].where_str = "MED_IDENTIFIER_ID = "
     SET ignores->list[33].description = "Inactive products in active sets"
     SET ignores->list[33].name = concat(trim(scriptname),"|INACT_PRODUCTS_ACT_SETS")
     SET ignores->list[33].category = "Formulary"
     SET ignores->list[33].category_alias = "F"
     SET ignores->list[33].default_audit_off_ind = 1
     SET ignores->list[33].primary_key = "ITEM_ID"
     SET ignores->list[33].table_name = "MED_IDENTIFIER"
     SET ignores->list[33].disp_field_name = "VALUE"
     SET ignores->list[33].where_str = build2(
      "MED_IDENTIFIER_TYPE_CD = DESC_TYPE_CD AND PRIMARY_IND = 1",
      " AND MED_PRODUCT_ID = 0.0 AND ITEM_ID = ")
     SET ignores->list[34].description = "Synonyms with incorrect product linking"
     SET ignores->list[34].name = concat(trim(scriptname),"|SYNONYMS_INCORRECT_LINKING")
     SET ignores->list[34].category = "Order Catalog - Synonyms"
     SET ignores->list[34].category_alias = "OCS"
     SET ignores->list[34].default_audit_off_ind = 1
     SET ignores->list[34].primary_key = "SYNONYM_ID"
     SET ignores->list[34].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[34].disp_field_name = "MNEMONIC"
     SET ignores->list[34].where_str = "SYNONYM_ID = "
     SET ignores->list[35].description = "Synonyms with incorrect titrateable setting"
     SET ignores->list[35].name = concat(trim(scriptname),"|SYNONYMS_INCORRECT_TITRATE")
     SET ignores->list[35].category = "Order Catalog - Synonyms"
     SET ignores->list[35].category_alias = "OCS"
     SET ignores->list[35].default_audit_off_ind = 1
     SET ignores->list[35].primary_key = "SYNONYM_ID"
     SET ignores->list[35].table_name = "ORDER_CATALOG_SYNONYM"
     SET ignores->list[35].disp_field_name = "MNEMONIC"
     SET ignores->list[35].where_str = "SYNONYM_ID = "
    OF "AMS_FILL_BATCH_CHECK":
     SET numofaudits = 2
     SET ignores->list_sz = numofaudits
     SET stat = alterlist(ignores->list,numofaudits)
     SET ignores->list[1].description = "Batches behind schedule"
     SET ignores->list[1].name = concat(trim(scriptname),"|BEHIND_BATCHES")
     SET ignores->list[1].default_audit_off_ind = 0
     SET ignores->list[1].primary_key = "FILL_BATCH_CD"
     SET ignores->list[1].table_name = "CODE_VALUE"
     SET ignores->list[1].disp_field_name = "DISPLAY"
     SET ignores->list[1].where_str = "CODE_SET = 4035 AND CODE_VALUE = "
     SET ignores->list[2].description = "Batches ahead of schedule"
     SET ignores->list[2].name = concat(trim(scriptname),"|AHEAD_BATCHES")
     SET ignores->list[2].default_audit_off_ind = 0
     SET ignores->list[2].primary_key = "FILL_BATCH_CD"
     SET ignores->list[2].table_name = "CODE_VALUE"
     SET ignores->list[2].disp_field_name = "DISPLAY"
     SET ignores->list[2].where_str = "CODE_SET = 4035 AND CODE_VALUE = "
   ENDCASE
   CALL sortignoresrec(null)
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
 SUBROUTINE sortignoresrec(null)
   DECLARE igncnt = i4 WITH protect
   DECLARE valuecnt = i4 WITH protect
   DECLARE auditcnt = i4 WITH protect
   RECORD temp(
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
   SET stat = alterlist(temp->list,ignores->list_sz)
   SELECT INTO "nl:"
    name = ignores->list[d1.seq].name, category = ignores->list[d1.seq].category
    FROM (dummyt d1  WITH seq = value(size(ignores->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(ignores->list[d1.seq].values,5)))
     JOIN (d2)
    ORDER BY category, d1.seq
    HEAD category
     auditcnt = 0
    HEAD d1.seq
     auditcnt = (auditcnt+ 1), igncnt = (igncnt+ 1), stat = alterlist(temp->list[igncnt].values,size(
       ignores->list[d1.seq].values,5)),
     temp->list[igncnt].bypass_audit = ignores->list[d1.seq].bypass_audit, temp->list[igncnt].
     category = ignores->list[d1.seq].category, temp->list[igncnt].audit_num = auditcnt,
     temp->list[igncnt].default_audit_off_ind = ignores->list[d1.seq].default_audit_off_ind, temp->
     list[igncnt].description = ignores->list[d1.seq].description, temp->list[igncnt].disp_field_name
      = ignores->list[d1.seq].disp_field_name,
     temp->list[igncnt].name = ignores->list[d1.seq].name, temp->list[igncnt].primary_key = ignores->
     list[d1.seq].primary_key, temp->list[igncnt].category_alias = ignores->list[d1.seq].
     category_alias,
     temp->list[igncnt].table_name = ignores->list[d1.seq].table_name, temp->list[igncnt].where_str
      = ignores->list[d1.seq].where_str, temp->list_sz = ignores->list_sz,
     valuecnt = 0
    DETAIL
     IF ((ignores->list[d1.seq].values[d2.seq].br_name_value_id > 0.0))
      valuecnt = (valuecnt+ 1), temp->list[igncnt].values[valuecnt].br_name_value_id = ignores->list[
      d1.seq].values[d2.seq].br_name_value_id, temp->list[igncnt].values[valuecnt].disp = ignores->
      list[d1.seq].values[d2.seq].disp,
      temp->list[igncnt].values[valuecnt].id = ignores->list[d1.seq].values[d2.seq].id
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
   SET stat = initrec(ignores)
   SET ignores->list_sz = temp->list_sz
   SET stat = alterlist(ignores->list,ignores->list_sz)
   FOR (igncnt = 1 TO temp->list_sz)
     SET stat = alterlist(ignores->list[igncnt].values,size(temp->list[igncnt].values,5))
     SET ignores->list[igncnt].bypass_audit = temp->list[igncnt].bypass_audit
     SET ignores->list[igncnt].category = temp->list[igncnt].category
     SET ignores->list[igncnt].audit_num = temp->list[igncnt].audit_num
     SET ignores->list[igncnt].default_audit_off_ind = temp->list[igncnt].default_audit_off_ind
     SET ignores->list[igncnt].description = temp->list[igncnt].description
     SET ignores->list[igncnt].disp_field_name = temp->list[igncnt].disp_field_name
     SET ignores->list[igncnt].name = temp->list[igncnt].name
     SET ignores->list[igncnt].primary_key = temp->list[igncnt].primary_key
     SET ignores->list[igncnt].category_alias = temp->list[igncnt].category_alias
     SET ignores->list[igncnt].table_name = temp->list[igncnt].table_name
     SET ignores->list[igncnt].where_str = temp->list[igncnt].where_str
     FOR (valuecnt = 1 TO size(temp->list[igncnt].values,5))
       SET ignores->list[igncnt].values[valuecnt].br_name_value_id = temp->list[igncnt].values[
       valuecnt].br_name_value_id
       SET ignores->list[igncnt].values[valuecnt].disp = temp->list[igncnt].values[valuecnt].disp
       SET ignores->list[igncnt].values[valuecnt].id = temp->list[igncnt].values[valuecnt].id
     ENDFOR
   ENDFOR
   FREE RECORD temp
 END ;Subroutine
 SET last_mod = "010"
 DECLARE invalidckis(null) = i4 WITH protect
 DECLARE synonymswithoutoef(null) = i4 WITH protect
 DECLARE synonymswithoutrxmask(null) = i4 WITH protect
 DECLARE missingmultumsynonyms(null) = i4 WITH protect
 DECLARE primarieswithouttask(null) = i4 WITH protect
 DECLARE primarieswithouteventcode(null) = i4 WITH protect
 DECLARE fillprintruntypecdzero(null) = i4 WITH protect
 DECLARE fillprintordhxagingrows(null) = i4 WITH protect
 DECLARE unverifiedorders(null) = i4 WITH protect
 DECLARE pendingcharges(null) = i4 WITH protect
 DECLARE duplicatednums(null) = i4 WITH protect
 DECLARE ordercatalogreviewsettings(null) = i4 WITH protect
 DECLARE ordercatalogdcdayssettings(null) = i4 WITH protect
 DECLARE ordercatalogclinicalcategory(null) = i4 WITH protect
 DECLARE ordercatalogautoverifysettings(null) = i4 WITH protect
 DECLARE ordercatalogstoptypesettings(null) = i4 WITH protect
 DECLARE ordercatalogprintreqsettings(null) = i4 WITH protect
 DECLARE ordercatalogmiscindicators(null) = i4 WITH protect
 DECLARE ordercatalogcontinuingorderind(null) = i4 WITH protect
 DECLARE taskindicatorsettings(null) = i4 WITH protect
 DECLARE tasktypesettings(null) = i4 WITH protect
 DECLARE taskreschedsettings(null) = i4 WITH protect
 DECLARE taskpositiontochart(null) = i4 WITH protect
 DECLARE synonymswithmultiplegroupers(null) = i4 WITH protect
 DECLARE unauthroutesandforms(null) = i4 WITH protect
 DECLARE invalidmultumaliases(null) = i4 WITH protect
 DECLARE unmappeduomaliases(null) = i4 WITH protect
 DECLARE unmappedroutealiases(null) = i4 WITH protect
 DECLARE unmappedformaliases(null) = i4 WITH protect
 DECLARE unmappedprnaliases(null) = i4 WITH protect
 DECLARE synonymsincorrectrxmask(null) = i4 WITH protect
 DECLARE productswithinvalididentifiers(null) = i4 WITH protect
 DECLARE inactiveproductsinactivesets(null) = i4 WITH protect
 DECLARE synonymsincorrectlinking(null) = i4 WITH protect
 DECLARE synonymsincorrecttitrateflag(null) = i4 WITH protect
 DECLARE createfixlog(null) = i2 WITH protect
 DECLARE loadtestcatvalues(null) = i2 WITH protect
 DECLARE loadtesttaskvalues(testcatalogcd=f8) = i2 WITH protect
 DECLARE addtrackingrow(audit=vc,cnt=i4,desc=vc) = null WITH protect
 DECLARE loadpreviousresults(null) = null WITH protect
 DECLARE createoutputcsv(filename) = null WITH protect
 DECLARE updatefixedtracking(null) = null WITH protect
 DECLARE getusernamefullformatted(null) = vc WITH protect
 DECLARE pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE pharm_cat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE syn_type_primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE sys_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE system_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE orderable_flex_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,
   "ORDERABLE"))
 DECLARE desc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE clientstr = vc WITH constant(getclient(null)), protect
 DECLARE script_name = c22 WITH protect, constant("AMS_PHARM_HEALTH_CHECK")
 DECLARE cfrom = c33 WITH protect, constant("ams_pharm_health_check@cerner.com")
 DECLARE clogmailbox = c33 WITH protect, constant("ams_pharm_health_check@cerner.com")
 DECLARE test_catalog_name = vc WITH protect, constant("MLTMAutoTest")
 DECLARE test_cat_loaded = i2 WITH protect, constant(1)
 DECLARE test_cat_failed = i2 WITH protect, constant(2)
 DECLARE test_task_failed = i2 WITH protect, constant(3)
 DECLARE header_name = vc WITH protect, constant("cclsource:pharm_health_check_header.bmp")
 DECLARE user_name_full = vc WITH protect, constant(getusernamefullformatted(null))
 DECLARE body_str = vc WITH protect, constant(build2("File attached. Ran by: ",user_name_full))
 DECLARE vcsubject = vc WITH noconstant(build2("AMS Pharmacy Health Check ",clientstr,": ",curdomain)
  ), protect
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
 DECLARE maxunverifiedorderscnt = i4 WITH protect
 DECLARE maxpendingchargescnt = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE fixedstr = vc WITH protect, noconstant("FIXED")
 DECLARE failurestr = vc WITH protect, noconstant("FAILURE")
 DECLARE infostr = vc WITH protect, noconstant("INFO")
 DECLARE successstr = vc WITH protect, noconstant("SUCCESS")
 DECLARE errorstr = vc WITH protect, noconstant("ERROR")
 DECLARE ignoredstr = vc WITH protect, noconstant("IGNORED")
 DECLARE testcatloadedind = i2 WITH protect
 DECLARE summaryrptname = vc WITH protect
 DECLARE outputcsvname = vc WITH protect
 RECORD temp_ignores(
   1 list_sz = i4
   1 list[*]
     2 id = vc
 ) WITH protect
 RECORD cat_test_values(
   1 test_catalog_cd = f8
   1 primary_mnemonic = vc
   1 description = vc
   1 auto_cancel_ind = i2
   1 bill_only_ind = i2
   1 complete_upon_order_ind = i2
   1 consent_form_format_cd = f8
   1 consent_form_ind = i2
   1 consent_form_routing_cd = f8
   1 cont_order_method_flag = i2
   1 disable_order_comment_ind = i2
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 discern_auto_verify_flag = i2
   1 ic_auto_verify_flag = i2
   1 orderable_type_flag = i2
   1 print_req_ind = i2
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 stop_duration = i4
   1 stop_duration_unit_cd = f8
   1 stop_type_cd = f8
   1 review_settings[*]
     2 action_type_cd = f8
     2 action_type_disp = vc
     2 nurse_review_flag = i2
     2 doctor_cosign_flag = i2
     2 rx_verify_flag = i2
     2 cosign_required_ind = i2
     2 review_required_ind = i2
 ) WITH protect
 RECORD task_test_values(
   1 reference_task_id = f8
   1 task_description = vc
   1 allpositionchart_ind = i2
   1 capture_bill_info_ind = i2
   1 grace_period_mins = i4
   1 ignore_req_ind = i2
   1 overdue_min = i4
   1 overdue_units = i4
   1 quick_chart_done_ind = i2
   1 quick_chart_ind = i2
   1 reschedule_time = i4
   1 retain_time = i4
   1 retain_units = i4
   1 task_activity_cd = f8
   1 task_type_cd = f8
   1 position_chart_list[*]
     2 position_cd = f8
     2 position_name = vc
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
     2 category_alias = c3
     2 audit_num = i4
     2 bypass_audit = i2
     2 prev_fail_cnt = i4
     2 current_fail_cnt = i4
     2 primary_key_type = vc
     2 fixed_cnt = i4
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
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
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
 ELSE
  SET opsind = 1
 ENDIF
 SET logfilename = concat("ams_pharm_health_check_",trim(cnvtlower(curdomain)),"_",cnvtlower(format(
    cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 SET summaryrptname = concat("ams_pharm_health_check_summary_rpt_",trim(cnvtlower(curdomain)),"_",
  cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".pdf")
 SET outputcsvname = concat("ams_pharm_health_check_detail_log_",trim(cnvtlower(curdomain)),"_",
  cnvtlower(format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".csv")
 SET status = "S"
 SET statusstr = "Script failed for unknown reason"
 SET reply->status_data.status = "F"
 SET reply->ops_event = statusstr
 CALL addlogmsg(infostr,linestr)
 CALL addlogmsg(infostr,"Beginning pharmacy health check")
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
  SET pos = locateval(i,1,prefs->list_sz,"MAX_NUM_UNVERIFIED_ORDERS",prefs->list[i].pref_name)
  SET maxunverifiedorderscnt = cnvtint(prefs->list[i].value)
  SET pos = locateval(i,1,prefs->list_sz,"MAX_NUM_PENDING_CHARGES",prefs->list[i].pref_name)
  SET maxpendingchargescnt = cnvtint(prefs->list[i].value)
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
 SET totalerrorcnt = (totalerrorcnt+ invalidckis(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymswithoutoef(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymswithoutrxmask(null))
 SET totalerrorcnt = (totalerrorcnt+ missingmultumsynonyms(null))
 SET totalerrorcnt = (totalerrorcnt+ primarieswithouttask(null))
 SET totalerrorcnt = (totalerrorcnt+ primarieswithouteventcode(null))
 SET totalerrorcnt = (totalerrorcnt+ fillprintruntypecdzero(null))
 SET totalerrorcnt = (totalerrorcnt+ fillprintordhxagingrows(null))
 SET totalerrorcnt = (totalerrorcnt+ unverifiedorders(null))
 SET totalerrorcnt = (totalerrorcnt+ pendingcharges(null))
 SET totalerrorcnt = (totalerrorcnt+ duplicatednums(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogreviewsettings(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogdcdayssettings(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogclinicalcategory(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogautoverifysettings(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogstoptypesettings(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogprintreqsettings(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogmiscindicators(null))
 SET totalerrorcnt = (totalerrorcnt+ ordercatalogcontinuingorderind(null))
 SET totalerrorcnt = (totalerrorcnt+ taskindicatorsettings(null))
 SET totalerrorcnt = (totalerrorcnt+ tasktypesettings(null))
 SET totalerrorcnt = (totalerrorcnt+ taskreschedsettings(null))
 SET totalerrorcnt = (totalerrorcnt+ taskpositiontochart(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymswithmultiplegroupers(null))
 SET totalerrorcnt = (totalerrorcnt+ unauthroutesandforms(null))
 SET totalerrorcnt = (totalerrorcnt+ invalidmultumaliases(null))
 SET totalerrorcnt = (totalerrorcnt+ unmappeduomaliases(null))
 SET totalerrorcnt = (totalerrorcnt+ unmappedroutealiases(null))
 SET totalerrorcnt = (totalerrorcnt+ unmappedformaliases(null))
 SET totalerrorcnt = (totalerrorcnt+ unmappedprnaliases(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymsincorrectrxmask(null))
 SET totalerrorcnt = (totalerrorcnt+ productswithinvalididentifiers(null))
 SET totalerrorcnt = (totalerrorcnt+ inactiveproductsinactivesets(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymsincorrectlinking(null))
 SET totalerrorcnt = (totalerrorcnt+ synonymsincorrecttitrateflag(null))
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
 CALL addlogmsg(infostr,"Creating output CSV file")
 CALL createoutputcsv(outputcsvname)
 CALL addlogmsg(infostr,"Creating summary report")
 SET audits->pass_rate = (cnvtreal(audits->current_pass_cnt)/ cnvtreal(size(audits->list,5)))
 EXECUTE ams_health_check_report value(summaryrptname)
 CALL addlogmsg(infostr,"Creating log file")
 CALL createlogfile(logfilename)
 SUBROUTINE updatefixedtracking(null)
   DECLARE dminfostr = vc WITH protect
   SET trace = nocallecho
   FOR (i = 1 TO size(audits->list,5))
     IF ((audits->list[i].fixed_cnt > 0))
      SET dminfostr = trim(concat(script_name,"|",fixedstr,"|",substring((findstring("|",audits->
          list[i].name)+ 1),textlen(audits->list[i].name),audits->list[i].name)))
      CALL updtdminfo(dminfostr,cnvtreal(audits->list[i].fixed_cnt))
     ENDIF
   ENDFOR
   SET trace = callecho
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
   SET stat = emailfile(clogmailbox,cfrom,vclogemailsubject,body_str,fixlogname)
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
     status = substring(1,1000,audits->list[d1.seq].results[d2.seq].status_str), category = substring
     (1,1000,audits->list[d1.seq].category), audit = substring(1,1000,build2(trim(audits->list[d1.seq
        ].category_alias),".",trim(cnvtstring(audits->list[d1.seq].audit_num)),": ",audits->list[d1
       .seq].description)),
     item = substring(1,1000,audits->list[d1.seq].results[d2.seq].item), current_setting = substring(
      1,1000,audits->list[d1.seq].results[d2.seq].old_value_disp), new_setting = substring(1,1000,
      audits->list[d1.seq].results[d2.seq].new_value_disp),
     primary_key_type = substring(1,1000,audits->list[d1.seq].primary_key_type), primary_key =
     substring(1,1000,audits->list[d1.seq].results[d2.seq].primary_key), last_updt_dt_tm = format(
      audits->list[d1.seq].results[d2.seq].last_updt_dt_tm,";;q"),
     last_updt_person = substring(1,1000,audits->list[d1.seq].results[d2.seq].last_updt_prsnl)
    ELSE INTO value(filename)
     status = substring(1,1000,audits->list[d1.seq].results[d2.seq].status_str), category = substring
     (1,1000,audits->list[d1.seq].category), audit = substring(1,1000,build2(trim(audits->list[d1.seq
        ].category_alias),".",trim(cnvtstring(audits->list[d1.seq].audit_num)),": ",audits->list[d1
       .seq].description)),
     item = substring(1,1000,audits->list[d1.seq].results[d2.seq].item), current_setting = substring(
      1,1000,audits->list[d1.seq].results[d2.seq].old_value_disp), proposed_setting = substring(1,
      1000,audits->list[d1.seq].results[d2.seq].new_value_disp),
     primary_key_type = substring(1,1000,audits->list[d1.seq].primary_key_type), primary_key =
     substring(1,1000,audits->list[d1.seq].results[d2.seq].primary_key), last_updt_dt_tm = format(
      audits->list[d1.seq].results[d2.seq].last_updt_dt_tm,";;q"),
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
 SUBROUTINE getusernamefullformatted(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.name_full_formatted)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE invalidckis(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("INVALID_CKIS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with an invalid CKI: "
   RECORD cats(
     1 list[*]
       2 catalog_cd = f8
       2 new_cki = vc
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
     oc.cki, oc.primary_mnemonic, oc.catalog_cd
     FROM order_catalog oc,
      prsnl p
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.activity_type_cd=pharm_act_cd
       AND  NOT (trim(oc.cki) IN ("IGNORE", "MUL.MMDC!*", "MUL.ORD!d*"))
       AND oc.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id))))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
     ORDER BY cnvtupper(oc.primary_mnemonic)
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].
      results[errorcnt].item = oc.primary_mnemonic, audits->list[pos].results[errorcnt].old_value_id
       = oc.cki,
      audits->list[pos].results[errorcnt].old_value_disp = oc.cki, audits->list[pos].results[errorcnt
      ].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].last_updt_dt_tm
       = oc.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = oc.updt_cnt
      IF (cnvtupper(oc.cki)="*IGNORE*")
       audits->list[pos].results[errorcnt].new_value_id = "IGNORE", audits->list[pos].results[
       errorcnt].new_value_disp = "IGNORE", audits->list[pos].results[errorcnt].status_str = fixedstr,
       fixedcnt = (fixedcnt+ 1)
       IF (mod(fixedcnt,10)=1)
        stat = alterlist(cats->list,(fixedcnt+ 9))
       ENDIF
       cats->list[fixedcnt].catalog_cd = oc.catalog_cd, cats->list[fixedcnt].new_cki = "IGNORE"
      ELSE
       audits->list[pos].results[errorcnt].status_str = failurestr
      ENDIF
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
      IF (mod(fixedcnt,10) != 0)
       stat = alterlist(cats->list,fixedcnt)
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
     SET logmsg = "All pharmacy primaries that are active have a valid CKI"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       oc.catalog_cd
       FROM (dummyt d  WITH seq = value(size(cats->list,5))),
        order_catalog oc
       PLAN (d
        WHERE (cats->list[d.seq].new_cki > ""))
        JOIN (oc
        WHERE (oc.catalog_cd=cats->list[d.seq].catalog_cd))
       WITH nocounter, forupdate(oc)
      ;end select
      SELECT INTO "nl:"
       cv.code_value
       FROM (dummyt d  WITH seq = value(size(cats->list,5))),
        code_value cv
       PLAN (d
        WHERE (cats->list[d.seq].new_cki > ""))
        JOIN (cv
        WHERE (cv.code_value=cats->list[d.seq].catalog_cd)
         AND cv.code_set=200)
       WITH nocounter, forupdate(cv)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = value(size(cats->list,5))),
        order_catalog oc
       SET oc.cki = cats->list[d.seq].new_cki, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt
         = (oc.updt_cnt+ 1),
        oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
         = - (267)
       PLAN (d
        WHERE (cats->list[d.seq].new_cki > ""))
        JOIN (oc
        WHERE (oc.catalog_cd=cats->list[d.seq].catalog_cd))
       WITH nocounter
      ;end update
      UPDATE  FROM (dummyt d  WITH seq = value(size(cats->list,5))),
        code_value cv
       SET cv.cki = "", cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1),
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = - (267)
       PLAN (d
        WHERE (cats->list[d.seq].new_cki > ""))
        JOIN (cv
        WHERE (cv.code_value=cats->list[d.seq].catalog_cd)
         AND cv.code_set=200)
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of primaries that were assigned an IGNORE CKI: ",trim(format
         (fixedcnt,";,;"),3))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating CKI to IGNORE. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG TO SET THE CKI TO IGNORE. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
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
 SUBROUTINE synonymswithoutoef(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_WITHOUT_OEF")
   DECLARE synpos = i4 WITH protect
   DECLARE oefid = f8 WITH protect
   DECLARE sameoefind = i2 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synonyms without an OEF: "
   SET stat = initrec(temp_ignores)
   RECORD syns(
     1 list_sz = i4
     1 list[*]
       2 synonym_id = f8
       2 mltm_oef = vc
       2 mltm_oef_id = f8
   ) WITH protect
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
     primary = uar_get_code_display(ocs.catalog_cd), ocs.synonym_id, ocs.mnemonic,
     ocs.updt_dt_tm, p.name_full_formatted
     FROM order_catalog_synonym ocs,
      prsnl p,
      mltm_order_catalog_load mocl,
      order_entry_format_parent oefp
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.active_ind=1
       AND ocs.oe_format_id=0
       AND  NOT (ocs.orderable_type_flag IN (2, 6, 8, 11))
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
      JOIN (mocl
      WHERE mocl.synonym_cki=outerjoin(ocs.cki))
      JOIN (oefp
      WHERE oefp.oe_format_name=outerjoin(mocl.order_entry_format)
       AND oefp.catalog_type_cd=outerjoin(pharm_cat_cd))
     ORDER BY primary, ocs.mnemonic_key_cap
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(syns->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
        errorcnt+ 9))
      ENDIF
      syns->list[errorcnt].synonym_id = ocs.synonym_id, syns->list[errorcnt].mltm_oef = mocl
      .order_entry_format, syns->list[errorcnt].mltm_oef_id = oefp.oe_format_id,
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = ocs.mnemonic, audits->list[pos].results[errorcnt].old_value_id = "0",
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = cnvtstring(oefp.oe_format_id), audits->list[
      pos].results[errorcnt].new_value_disp = mocl.order_entry_format, audits->list[pos].results[
      errorcnt].status_str = failurestr
     FOOT REPORT
      syns->list_sz = errorcnt
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(syns->list,errorcnt), stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All pharmacy synonyms that are active have an OEF"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SELECT INTO "nl:"
      ocs.synonym_id, ocs.mnemonic
      FROM order_catalog_synonym ocs,
       order_catalog_synonym ocs2,
       order_entry_format_parent oefp
      PLAN (ocs
       WHERE expand(i,1,syns->list_sz,ocs.synonym_id,syns->list[i].synonym_id))
       JOIN (ocs2
       WHERE ocs2.catalog_cd=ocs.catalog_cd
        AND ocs2.active_ind=1
        AND ocs2.oe_format_id != 0)
       JOIN (oefp
       WHERE oefp.oe_format_id=ocs2.oe_format_id)
      ORDER BY ocs.synonym_id
      HEAD ocs.synonym_id
       sameoefind = 1, oefid = 0
      DETAIL
       IF (oefid=0)
        oefid = ocs2.oe_format_id
       ELSE
        IF (oefid != ocs2.oe_format_id)
         sameoefind = 0
        ENDIF
       ENDIF
      FOOT  ocs.synonym_id
       IF (sameoefind=1)
        synpos = locateval(num,1,syns->list_sz,ocs.synonym_id,syns->list[num].synonym_id), syns->
        list[synpos].mltm_oef_id = oefid, syns->list[synpos].mltm_oef = oefp.oe_format_name,
        audits->list[pos].results[synpos].new_value_id = cnvtstring(oefid), audits->list[pos].
        results[synpos].new_value_disp = oefp.oe_format_name
       ENDIF
      WITH nocounter, expand = 1
     ;end select
     SET fixedcnt = 0
     FOR (i = 1 TO syns->list_sz)
       IF ((syns->list[i].mltm_oef_id > 0))
        SET fixedcnt = (fixedcnt+ 1)
        SET audits->list[pos].results[i].status_str = fixedstr
       ENDIF
     ENDFOR
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       ocs.synonym_id
       FROM (dummyt d  WITH seq = syns->list_sz),
        order_catalog_synonym ocs
       PLAN (d
        WHERE (syns->list[d.seq].mltm_oef_id > 0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter, forupdate(ocs)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = syns->list_sz),
        order_catalog_synonym ocs
       SET ocs.oe_format_id = syns->list[d.seq].mltm_oef_id, ocs.updt_applctx = reqinfo->updt_applctx,
        ocs.updt_cnt = (ocs.updt_cnt+ 1),
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
        .updt_task = - (267)
       PLAN (d
        WHERE (syns->list[d.seq].mltm_oef_id > 0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of synonyms that were assigned an OEF: ",trim(cnvtstring(
          fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating order entry formats on synonyms. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG_SYNONYM TO SET THE OE_FORMAT_ID. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the synonyms in the output CSV with a fixed status that were supposed to be updated")
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE synonymswithoutrxmask(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_WITHOUT_RX_MASK")
   DECLARE synpos = i4 WITH protect
   DECLARE rxmask = i4 WITH protect
   DECLARE samemaskind = i2 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synonyms without an rx mask: "
   SET stat = initrec(temp_ignores)
   RECORD syns(
     1 list_sz = i4
     1 list[*]
       2 synonym_id = f8
       2 mltm_mask = i4
   ) WITH protect
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
     primary = uar_get_code_display(ocs.catalog_cd), ocs.synonym_id, ocs.mnemonic,
     ocs.updt_dt_tm, p.name_full_formatted
     FROM order_catalog_synonym ocs,
      prsnl p,
      mltm_order_catalog_load mocl
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_y, syn_type_z))
       AND ocs.active_ind=1
       AND ocs.rx_mask=0
       AND  NOT (ocs.orderable_type_flag IN (2, 6, 8))
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
      JOIN (mocl
      WHERE mocl.synonym_cki=outerjoin(ocs.cki))
     ORDER BY primary, ocs.mnemonic_key_cap
     HEAD REPORT
      errorcnt = 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(syns->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
        errorcnt+ 9))
      ENDIF
      syns->list[errorcnt].synonym_id = ocs.synonym_id
      IF (mocl.rx_mask_nbr > 0)
       fixedcnt = (fixedcnt+ 1), syns->list[errorcnt].mltm_mask = mocl.rx_mask_nbr
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = ocs.mnemonic, audits->list[pos].results[errorcnt].old_value_id = "0",
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = cnvtstring(mocl.rx_mask_nbr), audits->list[
      pos].results[errorcnt].new_value_disp =
      IF (mocl.rx_mask_nbr > 0) cnvtstring(mocl.rx_mask_nbr)
      ENDIF
      , audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      syns->list_sz = errorcnt
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(syns->list,errorcnt), stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All pharmacy synonyms that are active have an rx mask"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SELECT INTO "nl:"
      ocs.synonym_id, ocs.mnemonic
      FROM order_catalog_synonym ocs,
       order_catalog_synonym ocs2
      PLAN (ocs
       WHERE expand(i,1,syns->list_sz,ocs.synonym_id,syns->list[i].synonym_id)
        AND ocs.mnemonic_type_cd != syn_type_rx)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=ocs.catalog_cd
        AND ocs2.mnemonic_type_cd != syn_type_rx
        AND ocs2.active_ind=1
        AND ocs2.rx_mask != 0)
      ORDER BY ocs.synonym_id
      HEAD ocs.synonym_id
       samemaskind = 1, rxmask = 0
      DETAIL
       IF (rxmask=0)
        rxmask = ocs2.rx_mask
       ELSE
        IF (rxmask != ocs2.rx_mask)
         samemaskind = 0
        ENDIF
       ENDIF
      FOOT  ocs.synonym_id
       IF (samemaskind=1)
        synpos = locateval(num,1,syns->list_sz,ocs.synonym_id,syns->list[num].synonym_id)
        IF ((syns->list[synpos].mltm_mask=0))
         syns->list[synpos].mltm_mask = rxmask, fixedcnt = (fixedcnt+ 1), audits->list[pos].results[
         synpos].new_value_id = cnvtstring(rxmask),
         audits->list[pos].results[synpos].new_value_disp = cnvtstring(rxmask), audits->list[pos].
         results[synpos].status_str = fixedstr
        ENDIF
       ENDIF
      WITH nocounter, expand = 1
     ;end select
     SELECT INTO "nl:"
      ocs.synonym_id, ocs.mnemonic
      FROM order_catalog_synonym ocs,
       med_dispense md
      PLAN (ocs
       WHERE expand(i,1,syns->list_sz,ocs.synonym_id,syns->list[i].synonym_id)
        AND ocs.mnemonic_type_cd=syn_type_rx)
       JOIN (md
       WHERE md.item_id=ocs.item_id)
      ORDER BY ocs.synonym_id
      HEAD ocs.synonym_id
       rxmask = 0
      DETAIL
       IF (md.continuous_filter_ind=1
        AND md.intermittent_filter_ind=0
        AND md.med_filter_ind=0)
        rxmask = 1
       ELSEIF (md.continuous_filter_ind=0
        AND md.intermittent_filter_ind=0
        AND md.med_filter_ind=1)
        rxmask = 4
       ELSEIF (((md.continuous_filter_ind=1) OR (((md.intermittent_filter_ind=1) OR (md
       .med_filter_ind=1)) )) )
        rxmask = 6
       ENDIF
      FOOT  ocs.synonym_id
       IF (rxmask > 0)
        synpos = locateval(num,1,syns->list_sz,ocs.synonym_id,syns->list[num].synonym_id)
        IF ((syns->list[synpos].mltm_mask=0))
         syns->list[synpos].mltm_mask = rxmask, fixedcnt = (fixedcnt+ 1), audits->list[pos].results[
         synpos].new_value_id = cnvtstring(rxmask),
         audits->list[pos].results[synpos].new_value_disp = cnvtstring(rxmask), audits->list[pos].
         results[synpos].status_str = fixedstr
        ENDIF
       ENDIF
      WITH nocounter, expand = 1
     ;end select
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       ocs.synonym_id
       FROM (dummyt d  WITH seq = syns->list_sz),
        order_catalog_synonym ocs
       PLAN (d
        WHERE (syns->list[d.seq].mltm_mask > 0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter, forupdate(ocs)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = syns->list_sz),
        order_catalog_synonym ocs
       SET ocs.rx_mask = syns->list[d.seq].mltm_mask, ocs.updt_applctx = reqinfo->updt_applctx, ocs
        .updt_cnt = (ocs.updt_cnt+ 1),
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
        .updt_task = - (267)
       PLAN (d
        WHERE (syns->list[d.seq].mltm_mask > 0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of synonyms that were assigned an rx mask: ",trim(cnvtstring
         (fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating rx masks on synonyms. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG_SYNONYM TO SET THE RX_MASK. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the synonyms in the output CSV with a fixed status that were supposed to be updated")
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE missingmultumsynonyms(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("MISSING_MLTM_SYNS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synonyms in Multum that are not in the order catalog: "
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
     mocl.synonym_cki, mocl.mnemonic
     FROM mltm_order_catalog_load mocl
     PLAN (mocl
      WHERE  NOT ( EXISTS (
      (SELECT
       ocs.cki
       FROM order_catalog_synonym ocs
       WHERE ocs.cki=mocl.synonym_cki)))
       AND  NOT (expand(i,1,temp_ignores->list_sz,mocl.synonym_cki,temp_ignores->list[i].id)))
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = mocl.synonym_cki, audits->list[pos].results[
      errorcnt].item = mocl.mnemonic, audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All synonyms in Multum are in the order catalog"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE primarieswithouttask(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("PRIMARIES_WITHOUT_TASK")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries without a task: "
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
     oc.catalog_cd, oc.primary_mnemonic
     FROM order_catalog oc,
      prsnl p
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.activity_type_cd=pharm_act_cd
       AND oc.active_ind=1
       AND  NOT (oc.orderable_type_flag IN (2, 6, 8))
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       AND  NOT ( EXISTS (
      (SELECT
       otx.catalog_cd
       FROM order_task_xref otx
       WHERE otx.catalog_cd=oc.catalog_cd))))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
     ORDER BY cnvtupper(oc.primary_mnemonic)
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].
      results[errorcnt].item = oc.primary_mnemonic, audits->list[pos].results[errorcnt].
      last_updt_prsnl = p.name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[
      errorcnt].last_updt_cnt = oc.updt_cnt, audits->list[pos].results[errorcnt].status_str =
      failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All active primaries have an associated task"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE primarieswithouteventcode(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("PRIMARIES_WITHOUT_EC")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries without an event code: "
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
     oc.catalog_cd, oc.primary_mnemonic
     FROM order_catalog oc,
      prsnl p
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.activity_type_cd=pharm_act_cd
       AND oc.active_ind=1
       AND  NOT (oc.orderable_type_flag IN (2, 6, 8))
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       AND  NOT ( EXISTS (
      (SELECT
       cvr.parent_cd
       FROM code_value_event_r cvr
       WHERE cvr.parent_cd=oc.catalog_cd))))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
     ORDER BY cnvtupper(oc.primary_mnemonic)
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].
      results[errorcnt].item = oc.primary_mnemonic, audits->list[pos].results[errorcnt].
      last_updt_prsnl = p.name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[
      errorcnt].last_updt_cnt = oc.updt_cnt, audits->list[pos].results[errorcnt].status_str =
      failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All active primaries have an event code"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE fillprintruntypecdzero(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("RUN_TYPE_CD_ZERO")
   DECLARE userdefinedtypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"UDR"))
   DECLARE totalstr = vc WITH protect
   DECLARE unknowntypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"UNKNOWN"))
   SET totalstr = "Total number of rows on fill_print_hx with a run_type_cd = 0 or UNKNOWN: "
   SET stat = initrec(temp_ignores)
   RECORD runs(
     1 list_sz = i4
     1 list[*]
       2 run_id = f8
       2 run_type_cd = f8
       2 desc = vc
       2 updt_dt_tm = dq8
       2 person = vc
       2 updt_cnt = i4
   ) WITH protect
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
     fx.run_id
     FROM fill_print_hx fx,
      prsnl p
     PLAN (fx
      WHERE fx.run_type_cd IN (0, unknowntypecd)
       AND fx.run_id != 0
       AND  NOT (expand(i,1,temp_ignores->list_sz,fx.run_id,cnvtreal(temp_ignores->list[i].id))))
      JOIN (p
      WHERE p.person_id=fx.updt_id)
     ORDER BY fx.run_id
     HEAD REPORT
      errorcnt = 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(runs->list,(errorcnt+ 9))
      ENDIF
      runs->list[errorcnt].run_id = fx.run_id, runs->list[errorcnt].run_type_cd = fx.run_type_cd,
      runs->list[errorcnt].desc = trim(fx.batch_description),
      runs->list[errorcnt].updt_cnt = fx.updt_cnt, runs->list[errorcnt].updt_dt_tm = fx.updt_dt_tm,
      runs->list[errorcnt].person = p.name_full_formatted
     FOOT REPORT
      runs->list_sz = errorcnt
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(runs->list,errorcnt)
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
     SET logmsg = "No rows found on fill_print_hx with a run_type_cd = 0 or UNKNOWN"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SET fixedcnt = size(runs->list,5)
     SET audits->list[pos].results[1].old_value_id = "0"
     SET audits->list[pos].results[1].old_value_disp = "0"
     SET audits->list[pos].results[1].new_value_id = cnvtstring(userdefinedtypecd)
     SET audits->list[pos].results[1].new_value_disp = uar_get_code_display(userdefinedtypecd)
     SET audits->list[pos].results[1].status_str = fixedstr
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       fx.run_id
       FROM fill_print_hx fx
       PLAN (fx
        WHERE expand(i,1,size(runs->list,5),fx.run_id,runs->list[i].run_id))
       WITH nocounter, forupdate(fx), expand = 1
      ;end select
      UPDATE  FROM fill_print_hx fx
       SET fx.run_type_cd = userdefinedtypecd, fx.updt_cnt = (fx.updt_cnt+ 1), fx.updt_task = - (267),
        fx.updt_applctx = reqinfo->updt_applctx, fx.updt_id = reqinfo->updt_id
       WHERE expand(i,1,size(runs->list,5),fx.run_id,runs->list[i].run_id)
        AND fx.run_id != 0
       WITH nocounter, expand = 1
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ 1)
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of rows on fill_print_hx that were assigned a run_type_cd: ",
        trim(format(fixedcnt,";,;"),3))
       CALL addlogmsg(fixedstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating run_type_cd on fill_print_hx. See ",logfilename)
       CALL addlogmsg(errorstr,build2("ERROR UPDATING FILL_PRINT_HX TO SET THE RUN_TYPE_CD TO ",trim(
          cnvtstring(userdefinedtypecd)),". ROLLING BACK ALL CHANGES."))
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ELSE
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(format(errorcnt,";,;"),3))
      CALL addlogmsg(fixedstr,logmsg)
      SET audits->list[pos].results[1].status_str = fixedstr
      SET audits->list[pos].results[1].item = logmsg
     ENDIF
    ENDIF
    IF (autofixind=1
     AND opsind=1)
     CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
    ELSE
     CALL addtrackingrow(auditname,errorcnt,totalstr)
    ENDIF
    IF (errorcnt > 0)
     SET errorcnt = 1
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
 SUBROUTINE fillprintordhxagingrows(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE totalcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("FPOH_AGING_ROWS")
   DECLARE totalstr = vc WITH protect
   DECLARE msgcnt = i4 WITH protect
   SET totalstr = "Total number of rows on fill_print_ord_hx older than purge settings: "
   DECLARE filllistdays = i4 WITH protect
   DECLARE ambulatorydays = i4 WITH protect
   DECLARE mardays = i4 WITH protect
   DECLARE orderlabeldays = i4 WITH protect
   DECLARE pmpdays = i4 WITH protect
   DECLARE sordays = i4 WITH protect
   DECLARE udrdays = i4 WITH protect
   DECLARE maxdays = i4 WITH protect
   DECLARE filllistcnt = i4 WITH protect
   DECLARE ambulatorycnt = i4 WITH protect
   DECLARE marcnt = i4 WITH protect
   DECLARE orderlabelcnt = i4 WITH protect
   DECLARE pmpcnt = i4 WITH protect
   DECLARE sorcnt = i4 WITH protect
   DECLARE udrcnt = i4 WITH protect
   DECLARE zerocnt = i4 WITH protect
   DECLARE unknowncnt = i4 WITH protect
   DECLARE template_nbr = i4 WITH protect, constant(110)
   DECLARE fill_list_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FILL"))
   DECLARE order_label_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"ORD"))
   DECLARE mar_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"MAR"))
   DECLARE pmp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PMP"))
   DECLARE sor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"ASO"))
   DECLARE claim_trans_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"CLM"))
   DECLARE control_sub_batch_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"CSB"))
   DECLARE detail_rx_log_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"DPL"))
   DECLARE disp_sum_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"DSR"))
   DECLARE future_refill_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FRR"))
   DECLARE retail_fin_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FIN"))
   DECLARE partial_refill_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PRR"))
   DECLARE patient_trans_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PTR"))
   DECLARE pcl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PCL"))
   DECLARE udr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"UDR"))
   DECLARE unknown_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"UNKNOWN"))
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
     dmt.token_str, dmt.value
     FROM dm_purge_job dj,
      dm_purge_job_token dmt
     PLAN (dj
      WHERE dj.template_nbr=template_nbr)
      JOIN (dmt
      WHERE dmt.job_id=dj.job_id)
     DETAIL
      IF (cnvtint(dmt.value) > maxdays)
       maxdays = cnvtint(dmt.value)
      ENDIF
      CASE (dmt.token_str)
       OF "AMB_DAYS":
        ambulatorydays = cnvtint(dmt.value)
       OF "ASO_DAYS":
        sordays = cnvtint(dmt.value)
       OF "FILL_DAYS":
        filllistdays = cnvtint(dmt.value)
       OF "MAR_DAYS":
        mardays = cnvtint(dmt.value)
       OF "ORD_DAYS":
        orderlabeldays = cnvtint(dmt.value)
       OF "PMP_DAYS":
        pmpdays = cnvtint(dmt.value)
       OF "UDR_DAYS":
        udrdays = cnvtint(dmt.value)
      ENDCASE
     WITH nocounter
    ;end select
    IF (ambulatorydays=0)
     SET logmsg = "Ambulatory report days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ENDIF
    IF (sordays=0)
     SET logmsg = "Stop order report days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ENDIF
    IF (filllistdays=0)
     SET logmsg = "Fill list days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ELSEIF (filllistdays < 3)
     SET filllistdays = 3
    ENDIF
    IF (mardays=0)
     SET logmsg = "MAR report days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ELSEIF (mardays < 3)
     SET mardays = 3
    ENDIF
    IF (orderlabeldays=0)
     SET logmsg = "Order entry label days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ENDIF
    IF (pmpdays=0)
     SET logmsg = "PMP report days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ENDIF
    IF (udrdays=0)
     SET logmsg = "User defined report days setting in DMPurgeJobMgr is 0 or not set."
     SET msgcnt = (msgcnt+ 1)
     IF (mod(msgcnt,10)=1)
      SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
     ENDIF
     SET audits->list[pos].results[msgcnt].status_str = failurestr
     SET audits->list[pos].results[msgcnt].item = logmsg
    ENDIF
    SELECT INTO "nl:"
     fx.run_id
     FROM fill_print_hx fx,
      fill_print_ord_hx fpoh
     PLAN (fx
      WHERE fx.run_id != 0
       AND  NOT (expand(i,1,temp_ignores->list_sz,fx.run_id,cnvtreal(temp_ignores->list[i].id)))
       AND ((fx.run_type_cd=fill_list_cd
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (filllistdays+ 1)),0)
       AND filllistdays > 0) OR (((fx.run_type_cd=sor_cd
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (sordays+ 1)),0)
       AND sordays > 0) OR (((fx.run_type_cd IN (claim_trans_cd, control_sub_batch_cd,
      detail_rx_log_cd, disp_sum_rpt_cd, future_refill_rpt_cd,
      retail_fin_rpt_cd, partial_refill_rpt_cd, patient_trans_rpt_cd)
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (ambulatorydays+ 1)),0)
       AND ambulatorydays > 0) OR (((fx.run_type_cd=mar_cd
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (mardays+ 1)),0)
       AND mardays > 0) OR (((fx.run_type_cd IN (order_label_cd, pcl_cd)
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (orderlabeldays+ 1)),0)
       AND orderlabeldays > 0) OR (((fx.run_type_cd=pmp_cd
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (pmpdays+ 1)),0)
       AND pmpdays > 0) OR (fx.run_type_cd IN (udr_cd, unknown_cd, 0.0)
       AND fx.updt_dt_tm < cnvtdatetime((curdate - (udrdays+ 1)),0)
       AND udrdays > 0)) )) )) )) )) )) )
      JOIN (fpoh
      WHERE fpoh.run_id=fx.run_id)
     HEAD REPORT
      errorcnt = 0, filllistcnt = 0, ambulatorycnt = 0,
      marcnt = 0, orderlabelcnt = 0, pmpcnt = 0,
      sorcnt = 0, udrcnt = 0, zerocnt = 0,
      unknowncnt = 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      CASE (fx.run_type_cd)
       OF fill_list_cd:
        filllistcnt = (filllistcnt+ 1)
       OF order_label_cd:
        orderlabelcnt = (orderlabelcnt+ 1)
       OF mar_cd:
        marcnt = (marcnt+ 1)
       OF pmp_cd:
        pmpcnt = (pmpcnt+ 1)
       OF sor_cd:
        sorcnt = (sorcnt+ 1)
       OF claim_trans_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF control_sub_batch_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF detail_rx_log_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF disp_sum_rpt_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF future_refill_rpt_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF retail_fin_rpt_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF partial_refill_rpt_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF patient_trans_rpt_cd:
        ambulatorycnt = (ambulatorycnt+ 1)
       OF pcl_cd:
        orderlabelcnt = (orderlabelcnt+ 1)
       OF udr_cd:
        udrcnt = (udrcnt+ 1)
       OF unknown_cd:
        unknowncnt = (unknowncnt+ 1)
       OF 0.0:
        zerocnt = (zerocnt+ 1)
      ENDCASE
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     strandedcnt = count(fpoh.run_id)
     FROM fill_print_ord_hx fpoh
     PLAN (fpoh
      WHERE fpoh.updt_dt_tm < cnvtdatetime((curdate - (maxdays+ 1)),0)
       AND fpoh.run_id != 0.0)
     DETAIL
      errorcnt = (errorcnt+ strandedcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     rowcnt = count(fpoh.run_id)
     FROM fill_print_ord_hx fpoh
     PLAN (fpoh
      WHERE fpoh.run_id != 0)
     DETAIL
      totalcnt = rowcnt
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     CALL addlogmsg(infostr,"Current settings:")
     CALL addlogmsg(infostr,build2("Fill list days: ",trim(cnvtstring(filllistdays))))
     CALL addlogmsg(infostr,build2("Ambulatory report days: ",trim(cnvtstring(ambulatorydays))))
     CALL addlogmsg(infostr,build2("MAR report days: ",trim(cnvtstring(mardays))))
     CALL addlogmsg(infostr,build2("Order entry label days: ",trim(cnvtstring(orderlabeldays))))
     CALL addlogmsg(infostr,build2("PMP report days: ",trim(cnvtstring(pmpdays))))
     CALL addlogmsg(infostr,build2("Stop order report days: ",trim(cnvtstring(sordays))))
     CALL addlogmsg(infostr,build2("User defined report days: ",trim(cnvtstring(udrdays))))
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2("Total number of rows on fill_print_ord_hx: ",trim(format(totalcnt,";,;"),3)
      )
     CALL addlogmsg(infostr,logmsg)
     SET logmsg = build2(
      "No rows found older than purge settings defined in DMPurgeJobMgr. Total number of rows: ",trim
      (format(totalcnt,";,;"),3))
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (ambulatorycnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging ambulatory report rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(ambulatorycnt,";,;"),3)
     ENDIF
     IF (sorcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging stop order report rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(sorcnt,";,;"),3)
     ENDIF
     IF (filllistcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging fill list rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(filllistcnt,";,;"),3)
     ENDIF
     IF (marcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging MAR rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(marcnt,";,;"),3)
     ENDIF
     IF (orderlabelcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging order entry label rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(orderlabelcnt,";,;"),3)
     ENDIF
     IF (pmpcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging PMP rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(pmpcnt,";,;"),3)
     ENDIF
     IF (udrcnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging user defined report rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(udrcnt,";,;"),3)
     ENDIF
     IF (unknowncnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging unknown rows:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(unknowncnt,";,;"),3)
     ENDIF
     IF (zerocnt > 0)
      SET msgcnt = (msgcnt+ 1)
      IF (mod(msgcnt,10)=1)
       SET stat = alterlist(audits->list[pos].results,(msgcnt+ 9))
      ENDIF
      SET audits->list[pos].results[msgcnt].status_str = failurestr
      SET audits->list[pos].results[msgcnt].item = "Number of aging rows without a run_type_cd:"
      SET audits->list[pos].results[msgcnt].old_value_disp = trim(format(zerocnt,";,;"),3)
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
     CALL addlogmsg(failurestr,build2("Total number of rows on fill_print_ord_hx: ",trim(cnvtstring(
         totalcnt))))
     IF (mod(msgcnt,10) != 0)
      SET stat = alterlist(audits->list[pos].results,msgcnt)
     ENDIF
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
    IF (errorcnt > 0)
     SET errorcnt = 1
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
 SUBROUTINE unverifiedorders(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNVERIFIED_ORDERS")
   DECLARE nurseunitcnt = i4 WITH protect
   DECLARE ordercnt = i4 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of orders needing verification: "
   RECORD ord_counts(
     1 list[*]
       2 facility_cd = f8
       2 facility_disp = vc
       2 nurse_unit_cd = f8
       2 nurse_unit_disp = vc
       2 num_orders = i4
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
     facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
      .loc_nurse_unit_cd), num_orders = count(o.order_id)
     FROM order_dispense od,
      orders o,
      encounter e
     PLAN (od
      WHERE od.need_rx_verify_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,od.order_id,cnvtreal(temp_ignores->list[i].id))))
      JOIN (o
      WHERE od.order_id=o.order_id)
      JOIN (e
      WHERE od.encntr_id=e.encntr_id)
     GROUP BY e.loc_facility_cd, e.loc_nurse_unit_cd
     ORDER BY num_orders DESC
     HEAD REPORT
      ordercnt = 0, nurseunitcnt = 0
     DETAIL
      nurseunitcnt = (nurseunitcnt+ 1), ordercnt = (ordercnt+ num_orders)
      IF (mod(nurseunitcnt,10)=1)
       stat = alterlist(ord_counts->list,(nurseunitcnt+ 9))
      ENDIF
      ord_counts->list[nurseunitcnt].facility_cd = e.loc_facility_cd, ord_counts->list[nurseunitcnt].
      facility_disp = facility, ord_counts->list[nurseunitcnt].nurse_unit_cd = e.loc_nurse_unit_cd,
      ord_counts->list[nurseunitcnt].nurse_unit_disp = nurse_unit, ord_counts->list[nurseunitcnt].
      num_orders = num_orders
     FOOT REPORT
      IF (mod(nurseunitcnt,10) != 0)
       stat = alterlist(ord_counts->list,nurseunitcnt)
      ENDIF
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (ordercnt < maxunverifiedorderscnt)
     SET logmsg = build2("Less than ",trim(format(maxunverifiedorderscnt,";,;"),3),
      " orders need verification. ","Total number of orders: ",trim(format(ordercnt,";,;"),3))
     CALL addlogmsg(successstr,logmsg)
     CALL addlogmsg(infostr,linestr)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SET errorcnt = ordercnt
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2("More than ",trim(format(maxunverifiedorderscnt,";,;"),3),
      " orders need verification. Count by nurse unit:")
     CALL addlogmsg(failurestr,logmsg)
     SET stat = alterlist(audits->list[pos].results,(nurseunitcnt+ 1))
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     SET audits->list[pos].results[1].old_value_disp = trim(format(ordercnt,";,;"),3)
     FOR (i = 1 TO nurseunitcnt)
       SET logmsg = build2(ord_counts->list[i].facility_disp," - ",ord_counts->list[i].
        nurse_unit_disp)
       SET audits->list[pos].results[(i+ 1)].status_str = failurestr
       SET audits->list[pos].results[(i+ 1)].item = logmsg
       SET audits->list[pos].results[(i+ 1)].old_value_disp = trim(format(ord_counts->list[i].
         num_orders,";,;"),3)
     ENDFOR
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(format(ordercnt,";,;"),3))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
    IF (errorcnt > 0)
     SET errorcnt = 1
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
 SUBROUTINE pendingcharges(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("PENDING_CHARGES")
   DECLARE chargecnt = i4 WITH protect
   DECLARE facilitycnt = i4 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of charges needing review: "
   SET stat = initrec(temp_ignores)
   RECORD charge_counts(
     1 list[*]
       2 facility_cd = f8
       2 facility_disp = vc
       2 num_charges = i4
   ) WITH protect
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
     facility = uar_get_code_display(e.loc_facility_cd), num_charges = count(rpc.rx_pending_charge_id
      )
     FROM rx_pending_charge rpc,
      orders o,
      encounter e
     PLAN (rpc
      WHERE rpc.rx_pending_charge_id != 0
       AND  NOT (expand(i,1,temp_ignores->list_sz,rpc.rx_pending_charge_id,cnvtreal(temp_ignores->
        list[i].id))))
      JOIN (o
      WHERE o.order_id=rpc.order_id)
      JOIN (e
      WHERE e.encntr_id=o.encntr_id)
     GROUP BY e.loc_facility_cd
     ORDER BY num_charges DESC, facility
     HEAD REPORT
      chargecnt = 0, facilitycnt = 0
     DETAIL
      chargecnt = (chargecnt+ num_charges), facilitycnt = (facilitycnt+ 1)
      IF (mod(facilitycnt,10)=1)
       stat = alterlist(charge_counts->list,(facilitycnt+ 9))
      ENDIF
      charge_counts->list[facilitycnt].facility_cd = e.loc_facility_cd, charge_counts->list[
      facilitycnt].facility_disp = facility, charge_counts->list[facilitycnt].num_charges =
      num_charges
     FOOT REPORT
      IF (mod(facilitycnt,10) != 0)
       stat = alterlist(charge_counts->list,facilitycnt)
      ENDIF
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (chargecnt < maxpendingchargescnt)
     SET logmsg = build2("Less than ",trim(format(maxpendingchargescnt,";,;"),3),
      " charges need review. ","Total number of charges: ",trim(format(chargecnt,";,;"),3))
     CALL addlogmsg(successstr,logmsg)
     CALL addlogmsg(infostr,linestr)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SET errorcnt = chargecnt
     SET logmsg = build2("More than ",trim(format(maxpendingchargescnt,";,;"),3),
      " charges need review. Count by facility:")
     SET stat = alterlist(audits->list[pos].results,(facilitycnt+ 1))
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     SET audits->list[pos].results[1].old_value_disp = trim(format(chargecnt,";,;"),3)
     FOR (i = 1 TO facilitycnt)
       SET audits->list[pos].results[(i+ 1)].status_str = failurestr
       SET audits->list[pos].results[(i+ 1)].item = charge_counts->list[i].facility_disp
       SET audits->list[pos].results[(i+ 1)].old_value_disp = trim(format(charge_counts->list[i].
         num_charges,";,;"),3)
     ENDFOR
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(chargecnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
    IF (errorcnt > 0)
     SET errorcnt = 1
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
 SUBROUTINE duplicatednums(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("DUPLICATE_DNUMS")
   DECLARE ckicnt = i4 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of duplicated CKIs: "
   SET stat = initrec(temp_ignores)
   RECORD cki_cats(
     1 list_sz = i4
     1 list[*]
       2 catalog_cd = f8
       2 active_ind = i2
   ) WITH protect
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
     oc.cki, oc.primary_mnemonic, activestr = evaluate(oc.active_ind,1,"ACTIVE","INACTIVE"),
     cnt_primaries_w_cki = cki.cnt, oc.catalog_cd
     FROM (
      (
      (SELECT
       oc.cki, cnt = count(oc.cki)
       FROM order_catalog oc
       WHERE oc.cki > " "
        AND oc.cki != "IGNORE"
       GROUP BY oc.cki
       HAVING count(oc.cki) > 1
       WITH sqltype("vc","i4")))
      cki),
      order_catalog oc,
      prsnl p
     PLAN (cki)
      JOIN (oc
      WHERE oc.cki=cki.cki
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.cki,temp_ignores->list[i].id)))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
     ORDER BY oc.cki, cnvtupper(oc.primary_mnemonic)
     HEAD REPORT
      ckicnt = 0
     DETAIL
      errorcnt = (errorcnt+ 1), ckicnt = (ckicnt+ 1)
      IF (mod(ckicnt,10)=1)
       stat = alterlist(cki_cats->list,(ckicnt+ 9)), stat = alterlist(audits->list[pos].results,(
        ckicnt+ 9))
      ENDIF
      cki_cats->list[ckicnt].catalog_cd = oc.catalog_cd, cki_cats->list[ckicnt].active_ind = oc
      .active_ind, audits->list[pos].results[ckicnt].primary_key = oc.cki,
      audits->list[pos].results[ckicnt].item = build2(trim(oc.primary_mnemonic)," is ",activestr),
      audits->list[pos].results[ckicnt].old_value_id = oc.cki, audits->list[pos].results[ckicnt].
      old_value_disp = oc.cki,
      audits->list[pos].results[ckicnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[ckicnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[ckicnt].
      last_updt_cnt = oc.updt_cnt,
      audits->list[pos].results[ckicnt].status_str = failurestr
      IF (oc.active_ind=0)
       fixedcnt = (fixedcnt+ 1), audits->list[pos].results[ckicnt].status_str = fixedstr, audits->
       list[pos].results[ckicnt].new_value_id = "0",
       audits->list[pos].results[ckicnt].new_value_disp = "Remove CKI"
      ENDIF
     FOOT REPORT
      cki_cats->list_sz = ckicnt
      IF (mod(ckicnt,10) != 0)
       stat = alterlist(cki_cats->list,ckicnt)
      ENDIF
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "No order_catalog CKIs are duplicated"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       oc.catalog_cd
       FROM (dummyt d  WITH seq = value(size(cki_cats->list,5))),
        order_catalog oc
       PLAN (d
        WHERE (cki_cats->list[d.seq].active_ind=0))
        JOIN (oc
        WHERE (oc.catalog_cd=cki_cats->list[d.seq].catalog_cd))
       WITH nocounter, forupdate(oc)
      ;end select
      SELECT INTO "nl:"
       cv.code_value
       FROM (dummyt d  WITH seq = value(size(cki_cats->list,5))),
        code_value cv
       PLAN (d
        WHERE (cki_cats->list[d.seq].active_ind=0))
        JOIN (cv
        WHERE (cv.code_value=cki_cats->list[d.seq].catalog_cd)
         AND cv.code_set=200)
       WITH nocounter, forupdate(cv)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = value(size(cki_cats->list,5))),
        order_catalog oc
       SET oc.cki = "", oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc.updt_cnt+ 1),
        oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
         = - (267)
       PLAN (d
        WHERE (cki_cats->list[d.seq].active_ind=0))
        JOIN (oc
        WHERE (oc.catalog_cd=cki_cats->list[d.seq].catalog_cd))
       WITH nocounter
      ;end update
      UPDATE  FROM (dummyt d  WITH seq = value(size(cki_cats->list,5))),
        code_value cv
       SET cv.cki = "", cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1),
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = - (267)
       PLAN (d
        WHERE (cki_cats->list[d.seq].active_ind=0))
        JOIN (cv
        WHERE (cv.code_value=cki_cats->list[d.seq].catalog_cd)
         AND cv.code_set=200)
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of CKIs removed from primaries: ",trim(cnvtstring(fixedcnt))
        )
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error removing CKI from order_catalog. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG TO SET THE CKI TO NULL. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE ordercatalogreviewsettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE updtcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_REVIEW")
   DECLARE actionpos = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE adddr = i2 WITH protect
   DECLARE addnurse = i2 WITH protect
   DECLARE addrx = i2 WITH protect
   DECLARE removedr = i2 WITH protect
   DECLARE removenurse = i2 WITH protect
   DECLARE removerx = i2 WITH protect
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of incorrect order review settings: "
   SET stat = initrec(temp_ignores)
   RECORD ocr_cats(
     1 list_sz = i4
     1 list[*]
       2 catalog_cd = f8
       2 primary_mnemonic = vc
       2 action_type_cd = f8
       2 doctor_cosign_flag = i2
       2 nurse_review_flag = i2
       2 rx_verify_flag = i2
       2 new_doctor_cosign_flag = i2
       2 new_nurse_review_flag = i2
       2 new_rx_verify_flag = i2
       2 delete_ind = i2
       2 insert_ind = i2
       2 updt_dt_tm = dq8
       2 updt_person = vc
       2 updt_cnt = i4
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT DISTINCT INTO "nl:"
      oc.primary_mnemonic, oc.catalog_cd, ocr.action_type_cd,
      action_type_disp = uar_get_code_display(ocr.action_type_cd), ocr.*
      FROM order_catalog oc,
       order_catalog_review ocrtst,
       order_catalog_review ocr,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (ocrtst
       WHERE (ocrtst.catalog_cd=cat_test_values->test_catalog_cd))
       JOIN (ocr
       WHERE ocr.catalog_cd=oc.catalog_cd
        AND ((ocr.action_type_cd=ocrtst.action_type_cd
        AND ((ocr.doctor_cosign_flag != ocrtst.doctor_cosign_flag) OR (((ocr.nurse_review_flag !=
       ocrtst.nurse_review_flag) OR (ocr.rx_verify_flag != ocrtst.rx_verify_flag)) )) ) OR ( NOT (
       expand(i,1,size(cat_test_values->review_settings,5),ocr.action_type_cd,cat_test_values->
        review_settings[i].action_type_cd)))) )
       JOIN (p
       WHERE p.person_id=ocr.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic), oc.catalog_cd, action_type_disp,
       ocr.action_type_cd
      DETAIL
       errorcnt = (errorcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(ocr_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       ocr_cats->list[errorcnt].action_type_cd = ocr.action_type_cd, ocr_cats->list[errorcnt].
       catalog_cd = oc.catalog_cd, ocr_cats->list[errorcnt].doctor_cosign_flag = ocr
       .doctor_cosign_flag,
       ocr_cats->list[errorcnt].nurse_review_flag = ocr.nurse_review_flag, ocr_cats->list[errorcnt].
       primary_mnemonic = oc.primary_mnemonic, ocr_cats->list[errorcnt].rx_verify_flag = ocr
       .rx_verify_flag,
       ocr_cats->list[errorcnt].updt_cnt = ocr.updt_cnt, ocr_cats->list[errorcnt].updt_dt_tm = ocr
       .updt_dt_tm, ocr_cats->list[errorcnt].updt_person = p.name_full_formatted,
       ocr_cats->list[errorcnt].new_doctor_cosign_flag = ocrtst.doctor_cosign_flag, ocr_cats->list[
       errorcnt].new_nurse_review_flag = ocrtst.nurse_review_flag, ocr_cats->list[errorcnt].
       new_rx_verify_flag = ocrtst.rx_verify_flag,
       audits->list[pos].results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos]
       .results[errorcnt].item = build2(trim(oc.primary_mnemonic)," | ",action_type_disp), audits->
       list[pos].results[errorcnt].old_value_id = build(ocr.nurse_review_flag,",",ocr
        .doctor_cosign_flag,",",ocr.rx_verify_flag),
       logmsg = build2(evaluate(ocr.nurse_review_flag,0,"None",1,"Ordering Location",
         2,"Patient Location",3,"Order Detail Provider",4,
         "Order Detail Location"),",",evaluate(ocr.doctor_cosign_flag,0,"None",1,"Ordering Physician",
         2,"Attending Physician",3,"Order Detail Physician"),",",evaluate(ocr.rx_verify_flag,0,"None",
         2,"Required")), audits->list[pos].results[errorcnt].old_value_disp = logmsg, audits->list[
       pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted,
       audits->list[pos].results[errorcnt].last_updt_dt_tm = ocr.updt_dt_tm, audits->list[pos].
       results[errorcnt].last_updt_cnt = ocr.updt_cnt, audits->list[pos].results[errorcnt].status_str
        = fixedstr,
       fixedcnt = (fixedcnt+ 1), actionpos = locateval(cnt,1,size(cat_test_values->review_settings,5),
        ocr.action_type_cd,cat_test_values->review_settings[cnt].action_type_cd)
       IF (actionpos > 0)
        audits->list[pos].results[errorcnt].new_value_id = build(ocrtst.nurse_review_flag,",",ocrtst
         .doctor_cosign_flag,",",ocrtst.rx_verify_flag), logmsg = build2(evaluate(ocrtst
          .nurse_review_flag,0,"None",1,"Ordering Location",
          2,"Patient Location",3,"Order Detail Provider",4,
          "Order Detail Location"),",",evaluate(ocrtst.doctor_cosign_flag,0,"None",1,
          "Ordering Physician",
          2,"Attending Physician",3,"Order Detail Physician"),",",evaluate(ocrtst.rx_verify_flag,0,
          "None",2,"Required")), audits->list[pos].results[errorcnt].new_value_disp = logmsg
       ELSE
        ocr_cats->list[errorcnt].delete_ind = 1, audits->list[pos].results[errorcnt].new_value_id =
        "0,0,0", audits->list[pos].results[errorcnt].new_value_disp = "None,None,None"
       ENDIF
      FOOT REPORT
       ocr_cats->list_sz = errorcnt
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(ocr_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
       ENDIF
      WITH nocounter
     ;end select
     IF (error(cclerrorstr,0) > 0)
      CALL addlogmsg(errorstr,cclerrorstr)
      SET status = "F"
      SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
      GO TO exit_script
     ENDIF
     SELECT DISTINCT INTO "nl:"
      oc.primary_mnemonic, oc.catalog_cd, ocrtst.action_type_cd,
      action_type_disp = uar_get_code_display(ocrtst.action_type_cd)
      FROM order_catalog oc,
       prsnl p,
       order_catalog_review ocrtst,
       order_catalog_review ocr
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13))
       JOIN (p
       WHERE p.person_id=oc.updt_id)
       JOIN (ocrtst
       WHERE (ocrtst.catalog_cd=cat_test_values->test_catalog_cd))
       JOIN (ocr
       WHERE ocr.catalog_cd=oc.catalog_cd
        AND  NOT ( EXISTS (
       (SELECT
        ocr2.action_type_cd
        FROM order_catalog_review ocr2
        WHERE ocr2.catalog_cd=ocr.catalog_cd
         AND ocr2.action_type_cd=ocrtst.action_type_cd))))
      ORDER BY cnvtupper(oc.primary_mnemonic), oc.catalog_cd, action_type_disp,
       ocrtst.action_type_cd
      DETAIL
       IF (((ocrtst.doctor_cosign_flag > 0) OR (((ocrtst.nurse_review_flag > 0) OR (ocrtst
       .rx_verify_flag > 0)) )) )
        errorcnt = (errorcnt+ 1)
        IF (size(ocr_cats->list,5) < errorcnt)
         stat = alterlist(ocr_cats->list,(size(ocr_cats->list,5)+ 10)), stat = alterlist(audits->
          list[pos].results,(size(audits->list[pos].results,5)+ 10))
        ENDIF
        ocr_cats->list[errorcnt].action_type_cd = ocrtst.action_type_cd, ocr_cats->list[errorcnt].
        catalog_cd = oc.catalog_cd, ocr_cats->list[errorcnt].doctor_cosign_flag = 0,
        ocr_cats->list[errorcnt].nurse_review_flag = 0, ocr_cats->list[errorcnt].primary_mnemonic =
        oc.primary_mnemonic, ocr_cats->list[errorcnt].rx_verify_flag = 0,
        ocr_cats->list[errorcnt].insert_ind = 1, ocr_cats->list[errorcnt].updt_cnt = 0, ocr_cats->
        list[errorcnt].updt_dt_tm = oc.updt_dt_tm,
        ocr_cats->list[errorcnt].updt_person = p.name_full_formatted, ocr_cats->list[errorcnt].
        new_doctor_cosign_flag = ocrtst.doctor_cosign_flag, ocr_cats->list[errorcnt].
        new_nurse_review_flag = ocrtst.nurse_review_flag,
        ocr_cats->list[errorcnt].new_rx_verify_flag = ocrtst.rx_verify_flag, audits->list[pos].
        results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt
        ].item = build2(trim(oc.primary_mnemonic)," | ",action_type_disp),
        audits->list[pos].results[errorcnt].old_value_id = build(ocr.nurse_review_flag,",",ocr
         .doctor_cosign_flag,",",ocr.rx_verify_flag), logmsg = build2(evaluate(ocr.nurse_review_flag,
          0,"None",1,"Ordering Location",
          2,"Patient Location",3,"Order Detail Provider",4,
          "Order Detail Location"),",",evaluate(ocr.doctor_cosign_flag,0,"None",1,
          "Ordering Physician",
          2,"Attending Physician",3,"Order Detail Physician"),",",evaluate(ocr.rx_verify_flag,0,
          "None",2,"Required")), audits->list[pos].results[errorcnt].old_value_disp = logmsg,
        audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos
        ].results[errorcnt].last_updt_dt_tm = ocr.updt_dt_tm, audits->list[pos].results[errorcnt].
        last_updt_cnt = ocr.updt_cnt,
        fixedcnt = (fixedcnt+ 1), audits->list[pos].results[errorcnt].new_value_id = build(ocrtst
         .nurse_review_flag,",",ocrtst.doctor_cosign_flag,",",ocrtst.rx_verify_flag), logmsg = build2
        (evaluate(ocrtst.nurse_review_flag,0,"None",1,"Ordering Location",
          2,"Patient Location",3,"Order Detail Provider",4,
          "Order Detail Location"),",",evaluate(ocrtst.doctor_cosign_flag,0,"None",1,
          "Ordering Physician",
          2,"Attending Physician",3,"Order Detail Physician"),",",evaluate(ocrtst.rx_verify_flag,0,
          "None",2,"Required")),
        audits->list[pos].results[errorcnt].new_value_disp = logmsg, audits->list[pos].results[
        errorcnt].status_str = fixedstr
       ENDIF
      FOOT REPORT
       ocr_cats->list_sz = errorcnt
       IF (size(ocr_cats->list,5) != errorcnt)
        stat = alterlist(ocr_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
       ENDIF
      WITH nocounter, outerjoin = d2
     ;end select
     IF (error(cclerrorstr,0) > 0)
      CALL addlogmsg(errorstr,cclerrorstr)
      SET status = "F"
      SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
      GO TO exit_script
     ENDIF
     IF (errorcnt=0)
      SET logmsg = "All pharmacy primaries that are active have correct order review settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog_review ocr
        PLAN (ocr
         WHERE expand(i,1,ocr_cats->list_sz,ocr.catalog_cd,ocr_cats->list[i].catalog_cd,
          ocr.action_type_cd,ocr_cats->list[i].action_type_cd))
        WITH nocounter, forupdate(ocr), expand = 1
       ;end select
       UPDATE  FROM (dummyt d  WITH seq = value(ocr_cats->list_sz)),
         order_catalog_review ocr
        SET ocr.doctor_cosign_flag = ocr_cats->list[d.seq].new_doctor_cosign_flag, ocr
         .nurse_review_flag = ocr_cats->list[d.seq].new_nurse_review_flag, ocr.rx_verify_flag =
         ocr_cats->list[d.seq].new_rx_verify_flag,
         ocr.updt_applctx = reqinfo->updt_applctx, ocr.updt_cnt = (ocr.updt_cnt+ 1), ocr.updt_dt_tm
          = cnvtdatetime(curdate,curtime3),
         ocr.updt_id = reqinfo->updt_id, ocr.updt_task = - (267)
        PLAN (d
         WHERE (ocr_cats->list[d.seq].delete_ind=0)
          AND (ocr_cats->list[d.seq].insert_ind=0))
         JOIN (ocr
         WHERE (ocr.catalog_cd=ocr_cats->list[d.seq].catalog_cd)
          AND (ocr.action_type_cd=ocr_cats->list[d.seq].action_type_cd))
        WITH nocounter
       ;end update
       SET updtcnt = (updtcnt+ curqual)
       IF (error(cclerrorstr,0) > 0)
        CALL addlogmsg(errorstr,cclerrorstr)
        CALL addlogmsg(errorstr,"Error updating order_catalog_review")
        CALL addlogmsg(errorstr,build2("updtCnt: ",updtcnt))
        CALL addlogmsg(errorstr,build2("curqual: ",curqual))
       ENDIF
       DELETE  FROM (dummyt d  WITH seq = value(ocr_cats->list_sz)),
         order_catalog_review ocr
        SET ocr.seq = 0
        PLAN (d
         WHERE (ocr_cats->list[d.seq].delete_ind=1))
         JOIN (ocr
         WHERE (ocr.catalog_cd=ocr_cats->list[d.seq].catalog_cd)
          AND (ocr.action_type_cd=ocr_cats->list[d.seq].action_type_cd))
        WITH nocounter
       ;end delete
       SET updtcnt = (updtcnt+ curqual)
       IF (error(cclerrorstr,0) > 0)
        CALL addlogmsg(errorstr,cclerrorstr)
        CALL addlogmsg(errorstr,"Error deleting order_catalog_review")
        CALL addlogmsg(errorstr,build2("updtCnt: ",updtcnt))
        CALL addlogmsg(errorstr,build2("curqual: ",curqual))
       ENDIF
       INSERT  FROM (dummyt d  WITH seq = value(ocr_cats->list_sz)),
         order_catalog_review ocr
        SET ocr.action_type_cd = ocr_cats->list[d.seq].action_type_cd, ocr.catalog_cd = ocr_cats->
         list[d.seq].catalog_cd, ocr.doctor_cosign_flag = ocr_cats->list[d.seq].
         new_doctor_cosign_flag,
         ocr.nurse_review_flag = ocr_cats->list[d.seq].new_nurse_review_flag, ocr.rx_verify_flag =
         ocr_cats->list[d.seq].new_rx_verify_flag, ocr.updt_applctx = reqinfo->updt_applctx,
         ocr.updt_cnt = 0, ocr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocr.updt_id = reqinfo->
         updt_id,
         ocr.updt_task = - (267)
        PLAN (d
         WHERE (ocr_cats->list[d.seq].insert_ind=1))
         JOIN (ocr)
        WITH nocounter
       ;end insert
       SET updtcnt = (updtcnt+ curqual)
       IF (error(cclerrorstr,0) > 0)
        CALL addlogmsg(errorstr,cclerrorstr)
        CALL addlogmsg(errorstr,"Error inserting into order_catalog_review")
        CALL addlogmsg(errorstr,build2("updtCnt: ",updtcnt))
        CALL addlogmsg(errorstr,build2("curqual: ",curqual))
       ENDIF
       IF (updtcnt=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of order review settings that were updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2(
         "Error updating order review settings to match standard settings. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG_REVIEW TO SET THE ORDER REVIEW SETTINGS. ROLLING BACK ALL CHANGES."
         )
        CALL addlogmsg(errorstr,build2(
          "Review the catalog_cds and action_type_cds in the output CSV with a fixed status",
          " that were supposed to be updated"))
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," updtCnt = ",trim(
           cnvtstring(updtcnt))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogdcdayssettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_DC_DAYS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect discontinue days settings: "
   RECORD dc_cats(
     1 list[*]
       2 catalog_cd = f8
       2 dc_display_days = i4
       2 dc_interaction_days = i4
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      oc.catalog_cd, oc.primary_mnemonic, oc.dc_display_days,
      oc.dc_interaction_days
      FROM order_catalog oc,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND (((oc.dc_display_days != cat_test_values->dc_display_days)) OR ((oc.dc_interaction_days
        != cat_test_values->dc_interaction_days)))
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (p
       WHERE p.person_id=oc.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic)
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(dc_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       dc_cats->list[errorcnt].catalog_cd = oc.catalog_cd, dc_cats->list[errorcnt].dc_display_days =
       oc.dc_display_days, dc_cats->list[errorcnt].dc_interaction_days = oc.dc_interaction_days,
       audits->list[pos].results[errorcnt].primary_key = cnvtstring(oc.catalog_cd), audits->list[pos]
       .results[errorcnt].item = oc.primary_mnemonic, audits->list[pos].results[errorcnt].
       old_value_id = concat(trim(cnvtstring(oc.dc_display_days)),",",trim(cnvtstring(oc
          .dc_interaction_days))),
       logmsg = build2("Display for ",trim(cnvtstring(oc.dc_display_days)),
        " days, include in alerts for ",trim(cnvtstring(oc.dc_interaction_days))," days"), audits->
       list[pos].results[errorcnt].old_value_disp = logmsg, audits->list[pos].results[errorcnt].
       last_updt_prsnl = p.name_full_formatted,
       audits->list[pos].results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].
       results[errorcnt].last_updt_cnt = oc.updt_cnt, logmsg = build2("Display for ",trim(cnvtstring(
          cat_test_values->dc_display_days))," days, include in alerts for ",trim(cnvtstring(
          cat_test_values->dc_interaction_days))," days"),
       audits->list[pos].results[errorcnt].new_value_id = concat(trim(cnvtstring(cat_test_values->
          dc_display_days)),",",trim(cnvtstring(cat_test_values->dc_interaction_days))), audits->
       list[pos].results[errorcnt].new_value_disp = logmsg, audits->list[pos].results[errorcnt].
       status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(dc_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,errorcnt
         )
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
      SET logmsg =
      "All pharmacy primaries that are active have the correct discontinue days settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE expand(i,1,size(dc_cats->list,5),oc.catalog_cd,dc_cats->list[i].catalog_cd))
        WITH nocounter, forupdate(oc), expand = 1
       ;end select
       UPDATE  FROM order_catalog oc
        SET oc.dc_display_days = cat_test_values->dc_display_days, oc.dc_interaction_days =
         cat_test_values->dc_interaction_days, oc.updt_applctx = reqinfo->updt_applctx,
         oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id
          = reqinfo->updt_id,
         oc.updt_task = - (267)
        PLAN (oc
         WHERE expand(i,1,size(dc_cats->list,5),oc.catalog_cd,dc_cats->list[i].catalog_cd))
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of primaries that had DC days settings updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating discontinue days settings to ",build(cnvtstring(
           cat_test_values->dc_display_days),",",cnvtstring(cat_test_values->dc_interaction_days)),
         ". See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG TO SET THE DC DAYS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogclinicalcategory(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_CLINICAL_CAT")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect clinical categories: "
   RECORD clin_cats(
     1 list[*]
       2 catalog_cd = f8
       2 mltm_clin_cat_cd = f8
       2 update_ind = i2
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
     oc.catalog_cd, oc.primary_mnemonic, oc.dcp_clin_cat_cd,
     mocl.dcp_clin_cat_mean
     FROM order_catalog oc,
      prsnl p,
      code_value cv,
      mltm_order_catalog_load mocl,
      code_value cv2
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.activity_type_cd=pharm_act_cd
       AND oc.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id))))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
      JOIN (cv
      WHERE cv.code_value=outerjoin(oc.dcp_clin_cat_cd)
       AND cv.code_set=outerjoin(16389))
      JOIN (mocl
      WHERE mocl.catalog_cki=outerjoin(oc.cki)
       AND mocl.mnemonic_type_mean=outerjoin("PRIMARY"))
      JOIN (cv2
      WHERE cv2.code_set=outerjoin(16389)
       AND cv2.cdf_meaning=outerjoin(mocl.dcp_clin_cat_mean))
     ORDER BY cnvtupper(oc.primary_mnemonic)
     DETAIL
      IF (((oc.dcp_clin_cat_cd=0.0) OR (mocl.dcp_clin_cat_mean > " "
       AND cv.cdf_meaning != mocl.dcp_clin_cat_mean)) )
       errorcnt = (errorcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(clin_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       clin_cats->list[errorcnt].catalog_cd = oc.catalog_cd, clin_cats->list[errorcnt].
       mltm_clin_cat_cd = cv2.code_value, audits->list[pos].results[errorcnt].primary_key =
       cnvtstring(oc.catalog_cd),
       audits->list[pos].results[errorcnt].item = oc.primary_mnemonic, audits->list[pos].results[
       errorcnt].old_value_id = cnvtstring(oc.dcp_clin_cat_cd), audits->list[pos].results[errorcnt].
       old_value_disp = trim(uar_get_code_display(oc.dcp_clin_cat_cd)),
       audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos]
       .results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[errorcnt].
       last_updt_cnt = oc.updt_cnt,
       audits->list[pos].results[errorcnt].status_str = failurestr
       IF (((oc.dcp_clin_cat_cd=0
        AND cv2.code_value > 0) OR (oc.dcp_clin_cat_cd != cv2.code_value)) )
        fixedcnt = (fixedcnt+ 1), clin_cats->list[errorcnt].update_ind = 1, audits->list[pos].
        results[errorcnt].new_value_id = cnvtstring(cv2.code_value),
        audits->list[pos].results[errorcnt].new_value_disp = cv2.display, audits->list[pos].results[
        errorcnt].status_str = fixedstr
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(clin_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
        errorcnt)
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
     SET logmsg = "All pharmacy primaries that are active have the correct clinical category"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM order_catalog oc
       PLAN (oc
        WHERE expand(i,1,size(clin_cats->list,5),oc.catalog_cd,clin_cats->list[i].catalog_cd))
       WITH nocounter, forupdate(oc), expand = 1
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = value(size(clin_cats->list,5))),
        order_catalog oc
       SET oc.dcp_clin_cat_cd = clin_cats->list[d.seq].mltm_clin_cat_cd, oc.updt_applctx = reqinfo->
        updt_applctx, oc.updt_cnt = (oc.updt_cnt+ 1),
        oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
         = - (267)
       PLAN (d
        WHERE (clin_cats->list[d.seq].update_ind=1))
        JOIN (oc
        WHERE (oc.catalog_cd=clin_cats->list[d.seq].catalog_cd))
       WITH nocounter, expand = 1
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of primaries that had a clinical category updated: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating clinical categories to Multum settings. See ",
        logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG TO SET THE DCP_CLIN_CAT_CD. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE ordercatalogautoverifysettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_AUTO_VERIFY")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect pharmacy auto-verify settings: "
   RECORD av_cats(
     1 list[*]
       2 catalog_cd = f8
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      oc.catalog_cd, oc.primary_mnemonic, oc.dc_display_days,
      oc.dc_interaction_days
      FROM order_catalog oc,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND (((oc.ic_auto_verify_flag != cat_test_values->ic_auto_verify_flag)) OR ((oc
       .discern_auto_verify_flag != cat_test_values->discern_auto_verify_flag)))
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (p
       WHERE p.person_id=oc.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic)
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(av_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       av_cats->list[errorcnt].catalog_cd = oc.catalog_cd, audits->list[pos].results[errorcnt].
       primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt].item = oc
       .primary_mnemonic,
       audits->list[pos].results[errorcnt].old_value_id = concat(trim(cnvtstring(oc
          .ic_auto_verify_flag)),",",trim(cnvtstring(oc.discern_auto_verify_flag))), logmsg = build2(
        "Multum: ",evaluate(oc.ic_auto_verify_flag,0,"No Setting",1,"No",
         2,"No w/Clinical Checking",3,"Yes w/Reason",4,
         "Yes"),", Discern: ",evaluate(oc.discern_auto_verify_flag,0,"No Setting",1,"No",
         2,"No w/Clinical Checking",3,"Yes w/Reason",4,
         "Yes")), audits->list[pos].results[errorcnt].old_value_disp = logmsg,
       audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos]
       .results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[errorcnt].
       last_updt_cnt = oc.updt_cnt,
       logmsg = build2("Multum: ",evaluate(cat_test_values->ic_auto_verify_flag,0,"No Setting",1,"No",
         2,"No w/Clinical Checking",3,"Yes w/Reason",4,
         "Yes"),", Discern: ",evaluate(cat_test_values->discern_auto_verify_flag,0,"No Setting",1,
         "No",
         2,"No w/Clinical Checking",3,"Yes w/Reason",4,
         "Yes")), audits->list[pos].results[errorcnt].new_value_id = concat(trim(cnvtstring(
          cat_test_values->ic_auto_verify_flag)),",",trim(cnvtstring(cat_test_values->
          discern_auto_verify_flag))), audits->list[pos].results[errorcnt].new_value_disp = logmsg,
       audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(av_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,errorcnt
         )
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
      SET logmsg =
      "All pharmacy primaries that are active have the correct pharmacy auto-verify settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE expand(i,1,size(av_cats->list,5),oc.catalog_cd,av_cats->list[i].catalog_cd))
        WITH nocounter, forupdate(oc), expand = 1
       ;end select
       UPDATE  FROM order_catalog oc
        SET oc.ic_auto_verify_flag = cat_test_values->ic_auto_verify_flag, oc
         .discern_auto_verify_flag = cat_test_values->discern_auto_verify_flag, oc.updt_applctx =
         reqinfo->updt_applctx,
         oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id
          = reqinfo->updt_id,
         oc.updt_task = - (267)
        PLAN (oc
         WHERE expand(i,1,size(av_cats->list,5),oc.catalog_cd,av_cats->list[i].catalog_cd))
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2(
         "Total number of primaries that had pharmacy auto-verify settings updated: ",trim(cnvtstring
          (fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating auto-verify flag on primaries. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG TO SET THE AV FLAGS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogstoptypesettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_STOP_TYPE")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect stop type settings: "
   RECORD stop_cats(
     1 list[*]
       2 catalog_cd = f8
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      oc.catalog_cd, oc.primary_mnemonic, oc.stop_duration,
      oc.stop_duration_unit_cd, oc.stop_type_cd
      FROM order_catalog oc,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND (((oc.stop_duration != cat_test_values->stop_duration)) OR ((((oc.stop_duration_unit_cd
        != cat_test_values->stop_duration_unit_cd)) OR ((oc.stop_type_cd != cat_test_values->
       stop_type_cd))) ))
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (p
       WHERE p.person_id=oc.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic)
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(stop_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       stop_cats->list[errorcnt].catalog_cd = oc.catalog_cd, audits->list[pos].results[errorcnt].
       primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt].item = oc
       .primary_mnemonic,
       audits->list[pos].results[errorcnt].old_value_id = build(oc.stop_duration,",",trim(cnvtstring(
          oc.stop_duration_unit_cd,12,1)),",",trim(cnvtstring(oc.stop_type_cd,12,1))), logmsg =
       build2("Stop Type: ",trim(uar_get_code_display(oc.stop_type_cd)),", ","Stop Duration: ",trim(
         cnvtstring(oc.stop_duration)),
        ", ","Stop Duration Unit: ",trim(uar_get_code_display(oc.stop_duration_unit_cd))), audits->
       list[pos].results[errorcnt].old_value_disp = logmsg,
       audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos]
       .results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[errorcnt].
       last_updt_cnt = oc.updt_cnt,
       audits->list[pos].results[errorcnt].new_value_id = build(cat_test_values->stop_duration,",",
        trim(cnvtstring(cat_test_values->stop_duration_unit_cd,12,1)),",",trim(cnvtstring(
          cat_test_values->stop_type_cd,12,1))), logmsg = build2("Stop Type: ",trim(
         uar_get_code_display(cat_test_values->stop_type_cd)),", ","Stop Duration: ",trim(cnvtstring(
          cat_test_values->stop_duration)),
        ", ","Stop Duration Unit: ",trim(uar_get_code_display(cat_test_values->stop_duration_unit_cd)
         )), audits->list[pos].results[errorcnt].new_value_disp = logmsg,
       audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(stop_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
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
      SET logmsg = "All pharmacy primaries that are active have the correct stop type settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE expand(i,1,size(stop_cats->list,5),oc.catalog_cd,stop_cats->list[i].catalog_cd))
        WITH nocounter, forupdate(oc), expand = 1
       ;end select
       UPDATE  FROM order_catalog oc
        SET oc.stop_duration = cat_test_values->stop_duration, oc.stop_duration_unit_cd =
         cat_test_values->stop_duration_unit_cd, oc.stop_type_cd = cat_test_values->stop_type_cd,
         oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         oc.updt_id = reqinfo->updt_id, oc.updt_task = - (267)
        PLAN (oc
         WHERE expand(i,1,size(stop_cats->list,5),oc.catalog_cd,stop_cats->list[i].catalog_cd))
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of primaries that had stop type settings updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating stop type settings on primaries. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG TO SET THE STOP TYPE SETTINGS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogprintreqsettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_PRINT_REQ")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect print requisition settings: "
   RECORD print_cats(
     1 list[*]
       2 catalog_cd = f8
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      oc.catalog_cd, oc.primary_mnemonic, oc.print_req_ind,
      oc.requisition_format_cd, oc.requisition_routing_cd
      FROM order_catalog oc,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND (((oc.print_req_ind != cat_test_values->print_req_ind)) OR ((((oc.requisition_format_cd
        != cat_test_values->requisition_format_cd)) OR ((oc.requisition_routing_cd != cat_test_values
       ->requisition_routing_cd))) ))
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (p
       WHERE p.person_id=oc.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic)
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(print_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,
         (errorcnt+ 9))
       ENDIF
       print_cats->list[errorcnt].catalog_cd = oc.catalog_cd, audits->list[pos].results[errorcnt].
       primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt].item = oc
       .primary_mnemonic,
       audits->list[pos].results[errorcnt].old_value_id = build(oc.print_req_ind,",",trim(cnvtstring(
          oc.requisition_format_cd,12,1)),",",trim(cnvtstring(oc.requisition_routing_cd,12,1))),
       audits->list[pos].results[errorcnt].old_value_disp = evaluate(oc.print_req_ind,1,build2(
         "Format: ",trim(uar_get_code_display(oc.requisition_format_cd))," Routing: ",trim(
          uar_get_code_display(oc.requisition_routing_cd)))), audits->list[pos].results[errorcnt].
       last_updt_prsnl = p.name_full_formatted,
       audits->list[pos].results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].
       results[errorcnt].last_updt_cnt = oc.updt_cnt, audits->list[pos].results[errorcnt].
       new_value_id = build(cat_test_values->print_req_ind,",",trim(cnvtstring(cat_test_values->
          requisition_format_cd,12,1)),",",trim(cnvtstring(cat_test_values->requisition_routing_cd,12,
          1))),
       audits->list[pos].results[errorcnt].new_value_disp = evaluate(cat_test_values->print_req_ind,1,
        build2("Format: ",trim(uar_get_code_display(cat_test_values->requisition_format_cd)),
         " Routing: ",trim(uar_get_code_display(cat_test_values->requisition_routing_cd)))), audits->
       list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(print_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
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
      SET logmsg =
      "All pharmacy primaries that are active have the correct print requisition settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE expand(i,1,size(print_cats->list,5),oc.catalog_cd,print_cats->list[i].catalog_cd))
        WITH nocounter, forupdate(oc), expand = 1
       ;end select
       UPDATE  FROM order_catalog oc
        SET oc.print_req_ind = cat_test_values->print_req_ind, oc.requisition_format_cd =
         cat_test_values->requisition_format_cd, oc.requisition_routing_cd = cat_test_values->
         requisition_routing_cd,
         oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         oc.updt_id = reqinfo->updt_id, oc.updt_task = - (267)
        PLAN (oc
         WHERE expand(i,1,size(print_cats->list,5),oc.catalog_cd,print_cats->list[i].catalog_cd))
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of primaries that had print requisition settings updated: ",
         trim(cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating print requisition settings on primaries. See ",
         logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG TO SET THE PRINT REQUISITION SETTINGS. ROLLING BACK ALL CHANGES."
         )
        CALL addlogmsg(errorstr,
         "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogmiscindicators(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_MISC_INDICATORS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with incorrect miscellaneous indicator settings: "
   RECORD misc_cats(
     1 list[*]
       2 catalog_cd = f8
   ) WITH protect
   IF (testcatloadedind=0)
    SET testcatloadedind = loadtestcatvalues(null)
   ENDIF
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      oc.catalog_cd, oc.primary_mnemonic, oc.complete_upon_order_ind,
      oc.auto_cancel_ind, oc.disable_order_comment_ind, oc.bill_only_ind
      FROM order_catalog oc,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1
        AND oc.orderable_type_flag IN (0, 1, 10, 13)
        AND (((oc.complete_upon_order_ind != cat_test_values->complete_upon_order_ind)) OR ((((oc
       .auto_cancel_ind != cat_test_values->auto_cancel_ind)) OR ((((oc.disable_order_comment_ind !=
       cat_test_values->disable_order_comment_ind)) OR ((oc.bill_only_ind != cat_test_values->
       bill_only_ind))) )) ))
        AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id)))
       )
       JOIN (p
       WHERE p.person_id=oc.updt_id)
      ORDER BY cnvtupper(oc.primary_mnemonic)
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(misc_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       misc_cats->list[errorcnt].catalog_cd = oc.catalog_cd, audits->list[pos].results[errorcnt].
       primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt].item = oc
       .primary_mnemonic,
       logmsg = build(oc.complete_upon_order_ind,",",oc.auto_cancel_ind,",",oc
        .disable_order_comment_ind,
        ",",oc.bill_only_ind), audits->list[pos].results[errorcnt].old_value_id = logmsg, logmsg =
       build2(evaluate(oc.complete_upon_order_ind,1,"Complete On Order "," "),evaluate(oc
         .auto_cancel_ind,1,"Cancel Order Upon Discharge "," "),evaluate(oc.disable_order_comment_ind,
         1,"Disable Order Comment "," "),evaluate(oc.bill_only_ind,1,"Bill Only Orderable "," ")),
       audits->list[pos].results[errorcnt].old_value_disp = logmsg, audits->list[pos].results[
       errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
       last_updt_dt_tm = oc.updt_dt_tm,
       audits->list[pos].results[errorcnt].last_updt_cnt = oc.updt_cnt, logmsg = build(
        cat_test_values->complete_upon_order_ind,",",cat_test_values->auto_cancel_ind,",",
        cat_test_values->disable_order_comment_ind,
        ",",cat_test_values->bill_only_ind), audits->list[pos].results[errorcnt].new_value_id =
       logmsg,
       logmsg = build2(evaluate(cat_test_values->complete_upon_order_ind,1,"Complete On Order "," "),
        evaluate(cat_test_values->auto_cancel_ind,1,"Cancel Order Upon Discharge "," "),evaluate(
         cat_test_values->disable_order_comment_ind,1,"Disable Order Comment "," "),evaluate(
         cat_test_values->bill_only_ind,1,"Bill Only Orderable "," ")), audits->list[pos].results[
       errorcnt].new_value_disp = logmsg, audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(misc_cats->list,
         errorcnt)
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
      SET logmsg =
      "All pharmacy primaries that are active have the correct miscellaneous indicator settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE expand(i,1,size(misc_cats->list,5),oc.catalog_cd,misc_cats->list[i].catalog_cd))
        WITH nocounter, forupdate(oc), expand = 1
       ;end select
       UPDATE  FROM order_catalog oc
        SET oc.complete_upon_order_ind = cat_test_values->complete_upon_order_ind, oc.auto_cancel_ind
          = cat_test_values->auto_cancel_ind, oc.disable_order_comment_ind = cat_test_values->
         disable_order_comment_ind,
         oc.bill_only_ind = cat_test_values->bill_only_ind, oc.updt_applctx = reqinfo->updt_applctx,
         oc.updt_cnt = (oc.updt_cnt+ 1),
         oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
          = - (267)
        PLAN (oc
         WHERE expand(i,1,size(misc_cats->list,5),oc.catalog_cd,misc_cats->list[i].catalog_cd))
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of primaries that had miscellaneous indicators updated: ",
         trim(cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating miscellaneous indicators on primaries. See ",
         logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_CATALOG TO SET THE MISC INDICATORS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE ordercatalogcontinuingorderind(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("ORD_CAT_CONT_ORD_IND")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of primaries with an incorrect continuing order indicator: "
   RECORD cont_cats(
     1 list[*]
       2 catalog_cd = f8
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
     oc.catalog_cd, oc.primary_mnemonic, oc.cont_order_method_flag
     FROM order_catalog oc,
      prsnl p
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.activity_type_cd=pharm_act_cd
       AND oc.active_ind=1
       AND oc.orderable_type_flag IN (0, 1, 10, 13)
       AND oc.cont_order_method_flag != 2
       AND  NOT (expand(i,1,temp_ignores->list_sz,oc.catalog_cd,cnvtreal(temp_ignores->list[i].id))))
      JOIN (p
      WHERE p.person_id=oc.updt_id)
     ORDER BY cnvtupper(oc.primary_mnemonic)
     DETAIL
      errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(cont_cats->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
        errorcnt+ 9))
      ENDIF
      cont_cats->list[errorcnt].catalog_cd = oc.catalog_cd, audits->list[pos].results[errorcnt].
      primary_key = cnvtstring(oc.catalog_cd), audits->list[pos].results[errorcnt].item = oc
      .primary_mnemonic,
      audits->list[pos].results[errorcnt].old_value_id = cnvtstring(oc.cont_order_method_flag),
      audits->list[pos].results[errorcnt].old_value_disp =
      IF (oc.cont_order_method_flag=1) "Task Based"
      ENDIF
      , audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = oc.updt_dt_tm, audits->list[pos].results[
      errorcnt].last_updt_cnt = oc.updt_cnt, audits->list[pos].results[errorcnt].new_value_id = "2",
      audits->list[pos].results[errorcnt].new_value_disp = "Pharmacy Based", audits->list[pos].
      results[errorcnt].status_str = fixedstr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(cont_cats->list,errorcnt), stat = alterlist(audits->list[pos].results,
        errorcnt)
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
     SET logmsg =
     "All pharmacy primaries that are active have the correct continuing order indicator setting"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM order_catalog oc
       PLAN (oc
        WHERE expand(i,1,size(cont_cats->list,5),oc.catalog_cd,cont_cats->list[i].catalog_cd))
       WITH nocounter, forupdate(oc), expand = 1
      ;end select
      UPDATE  FROM order_catalog oc
       SET oc.cont_order_method_flag = 2, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc
        .updt_cnt+ 1),
        oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
         = - (267)
       PLAN (oc
        WHERE expand(i,1,size(cont_cats->list,5),oc.catalog_cd,cont_cats->list[i].catalog_cd))
       WITH nocounter, expand = 1
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2(
        "Total number of primaries that were updated to pharmacy based continuing order: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating continuing order indicator to pharmacy based. See ",
        logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG TO SET THE CONTINUING ORDER INDICATOR TO 2. ROLLING BACK ALL CHANGES."
        )
       CALL addlogmsg(errorstr,
        "Review the catalog_cds in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE taskindicatorsettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("TASK_INDICATORS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of tasks with incorrect indicator settings: "
   RECORD ind_tasks(
     1 list[*]
       2 reference_task_id = f8
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      ot.reference_task_id
      FROM order_catalog oc,
       order_task_xref otx,
       order_task ot,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1)
       JOIN (otx
       WHERE otx.catalog_cd=oc.catalog_cd)
       JOIN (ot
       WHERE ot.reference_task_id=otx.reference_task_id
        AND ot.active_ind=1
        AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[i
         ].id)))
        AND (((ot.capture_bill_info_ind != task_test_values->capture_bill_info_ind)) OR ((((ot
       .ignore_req_ind != task_test_values->ignore_req_ind)) OR ((((ot.quick_chart_done_ind !=
       task_test_values->quick_chart_done_ind)) OR ((((ot.quick_chart_ind != task_test_values->
       quick_chart_ind)) OR ((((ot.overdue_min != task_test_values->overdue_min)) OR ((((ot
       .overdue_units != task_test_values->overdue_units)) OR ((((ot.retain_time != task_test_values
       ->retain_time)) OR ((ot.retain_units != task_test_values->retain_units))) )) )) )) )) )) )) )
       JOIN (p
       WHERE p.person_id=ot.updt_id)
      ORDER BY ot.task_description_key
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(ind_tasks->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
         errorcnt+ 9))
       ENDIF
       ind_tasks->list[errorcnt].reference_task_id = ot.reference_task_id, audits->list[pos].results[
       errorcnt].primary_key = cnvtstring(ot.reference_task_id), audits->list[pos].results[errorcnt].
       item = ot.task_description,
       logmsg = build(ot.capture_bill_info_ind,",",ot.ignore_req_ind,",",ot.quick_chart_done_ind,
        ",",ot.quick_chart_ind,",",ot.overdue_min,",",
        ot.overdue_units,",",ot.retain_time,",",ot.retain_units), audits->list[pos].results[errorcnt]
       .old_value_id = logmsg, logmsg = trim(build2(trim(
          IF (ot.capture_bill_info_ind=1) "Capture Billing Info, "
          ENDIF
          ,3),trim(
          IF (ot.ignore_req_ind=1) "Ignore Req Fields on Adhoc Charting, "
          ENDIF
          ,3),trim(
          IF (ot.quick_chart_done_ind=1) "Chart as Done, "
          ENDIF
          ,3),trim(
          IF (ot.quick_chart_ind=1) "Quick Chart, "
          ENDIF
          ,3),trim(
          IF (ot.quick_chart_done_ind=0
           AND ot.quick_chart_ind=0) "Neither, "
          ENDIF
          ,3),
         "Overdue Time: ",trim(cnvtstring(ot.overdue_min)),evaluate(ot.overdue_units,2," Hours, ",
          " Minutes, "),"Retained Time: ",trim(cnvtstring(ot.retain_time)),
         evaluate(ot.retain_units,1," Minutes ",2," Hours ",
          3," Days ",4," Weeks ",5,
          " Months ",trim(" "))),3),
       audits->list[pos].results[errorcnt].old_value_disp = logmsg, audits->list[pos].results[
       errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
       last_updt_dt_tm = ot.updt_dt_tm,
       audits->list[pos].results[errorcnt].last_updt_cnt = ot.updt_cnt, logmsg = build(
        task_test_values->capture_bill_info_ind,",",task_test_values->ignore_req_ind,",",
        task_test_values->quick_chart_done_ind,
        ",",task_test_values->quick_chart_ind,",",task_test_values->overdue_min,",",
        task_test_values->overdue_units,",",task_test_values->retain_time,",",task_test_values->
        retain_units), audits->list[pos].results[errorcnt].new_value_id = logmsg,
       logmsg = trim(build2(trim(
          IF ((task_test_values->capture_bill_info_ind=1)) "Capture Billing Info, "
          ENDIF
          ,3),trim(
          IF ((task_test_values->ignore_req_ind=1)) "Ignore Req Fields on Adhoc Charting, "
          ENDIF
          ,3),trim(
          IF ((task_test_values->quick_chart_done_ind=1)) "Chart as Done, "
          ENDIF
          ,3),trim(
          IF ((task_test_values->quick_chart_ind=1)) "Quick Chart, "
          ENDIF
          ,3),trim(
          IF ((task_test_values->quick_chart_done_ind=0)
           AND (task_test_values->quick_chart_ind=0)) "Neither, "
          ENDIF
          ,3),
         "Overdue Time: ",trim(cnvtstring(task_test_values->overdue_min)),evaluate(task_test_values->
          overdue_units,2," Hours, "," Minutes, "),"Retained Time: ",trim(cnvtstring(task_test_values
           ->retain_time)),
         evaluate(task_test_values->retain_units,1," Minutes ",2," Hours ",
          3," Days ",4," Weeks ",5,
          " Months ",trim(" "))),3), audits->list[pos].results[errorcnt].new_value_disp = logmsg,
       audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(ind_tasks->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
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
      SET logmsg = "All pharmacy tasks that are active have the correct indicator settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_task ot
        PLAN (ot
         WHERE expand(i,1,size(ind_tasks->list,5),ot.reference_task_id,ind_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, forupdate(ot), expand = 1
       ;end select
       UPDATE  FROM order_task ot
        SET ot.capture_bill_info_ind = task_test_values->capture_bill_info_ind, ot.ignore_req_ind =
         task_test_values->ignore_req_ind, ot.quick_chart_done_ind = task_test_values->
         quick_chart_done_ind,
         ot.quick_chart_ind = task_test_values->quick_chart_ind, ot.overdue_min = task_test_values->
         overdue_min, ot.overdue_units = task_test_values->overdue_units,
         ot.retain_time = task_test_values->retain_time, ot.retain_units = task_test_values->
         retain_units, ot.updt_applctx = reqinfo->updt_applctx,
         ot.updt_cnt = (ot.updt_cnt+ 1), ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id
          = reqinfo->updt_id,
         ot.updt_task = - (267)
        PLAN (ot
         WHERE expand(i,1,size(ind_tasks->list,5),ot.reference_task_id,ind_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of tasks that had their indicator settings updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating indicator settings on tasks. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_TASK TO SET THE INDICATOR SETTINGS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the reference_task_ids in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE tasktypesettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("TASK_TYPE")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of tasks with incorrect type settings: "
   RECORD type_tasks(
     1 list[*]
       2 reference_task_id = f8
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      ot.reference_task_id
      FROM order_catalog oc,
       order_task_xref otx,
       order_task ot,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1)
       JOIN (otx
       WHERE otx.catalog_cd=oc.catalog_cd)
       JOIN (ot
       WHERE ot.reference_task_id=otx.reference_task_id
        AND ot.active_ind=1
        AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[i
         ].id)))
        AND (((ot.task_activity_cd != task_test_values->task_activity_cd)) OR ((ot.task_type_cd !=
       task_test_values->task_type_cd))) )
       JOIN (p
       WHERE p.person_id=ot.updt_id)
      ORDER BY ot.task_description_key
      DETAIL
       errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(type_tasks->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,
         (errorcnt+ 9))
       ENDIF
       type_tasks->list[errorcnt].reference_task_id = ot.reference_task_id, audits->list[pos].
       results[errorcnt].primary_key = cnvtstring(ot.reference_task_id), audits->list[pos].results[
       errorcnt].item = ot.task_description,
       audits->list[pos].results[errorcnt].old_value_id = build(trim(cnvtstring(ot.task_type_cd,12,1)
         ),",",trim(cnvtstring(ot.task_activity_cd,12,1))), logmsg = build2(trim(uar_get_code_display
         (ot.task_type_cd))," and ",trim(uar_get_code_display(ot.task_activity_cd))), audits->list[
       pos].results[errorcnt].old_value_disp = logmsg,
       audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos]
       .results[errorcnt].last_updt_dt_tm = ot.updt_dt_tm, audits->list[pos].results[errorcnt].
       last_updt_cnt = ot.updt_cnt,
       audits->list[pos].results[errorcnt].new_value_id = cnvtstring(ot.reference_task_id), logmsg =
       build2(trim(uar_get_code_display(task_test_values->task_type_cd))," and ",trim(
         uar_get_code_display(task_test_values->task_activity_cd))), audits->list[pos].results[
       errorcnt].new_value_disp = logmsg,
       audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(type_tasks->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
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
      SET logmsg = "All pharmacy tasks that are active have the correct type settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_task ot
        PLAN (ot
         WHERE expand(i,1,size(type_tasks->list,5),ot.reference_task_id,type_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, forupdate(ot), expand = 1
       ;end select
       UPDATE  FROM order_task ot
        SET ot.task_type_cd = task_test_values->task_type_cd, ot.task_activity_cd = task_test_values
         ->task_activity_cd, ot.updt_cnt = (ot.updt_cnt+ 1),
         ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task
          = - (267)
        PLAN (ot
         WHERE expand(i,1,size(type_tasks->list,5),ot.reference_task_id,type_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of tasks that had their type settings updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating task type settings. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_TASK TO SET THE TYPE SETTINGS. ROLLING BACK ALL CHANGES.")
        CALL addlogmsg(errorstr,
         "Review the reference_task_ids in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE taskreschedsettings(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("TASK_RESCHEDULE")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of tasks with incorrect reschedule or grace period settings: "
   RECORD resched_tasks(
     1 list[*]
       2 reference_task_id = f8
       2 desc = vc
       2 reschedule_time = i4
       2 grace_period_mins = i4
       2 updt_dt_tm = dq8
       2 updt_person = vc
       2 updt_cnt = i4
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
    IF (testcatloadedind=test_cat_loaded)
     SELECT INTO "nl:"
      ot.reference_task_id
      FROM order_catalog oc,
       order_task_xref otx,
       order_task ot,
       prsnl p
      PLAN (oc
       WHERE oc.catalog_type_cd=pharm_cat_cd
        AND oc.activity_type_cd=pharm_act_cd
        AND oc.active_ind=1)
       JOIN (otx
       WHERE otx.catalog_cd=oc.catalog_cd)
       JOIN (ot
       WHERE ot.reference_task_id=otx.reference_task_id
        AND ot.active_ind=1
        AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[i
         ].id)))
        AND (((ot.grace_period_mins != task_test_values->grace_period_mins)) OR ((ot.reschedule_time
        != task_test_values->reschedule_time))) )
       JOIN (p
       WHERE p.person_id=ot.updt_id)
      ORDER BY ot.task_description_key
      DETAIL
       fixedcnt = (fixedcnt+ 1), errorcnt = (errorcnt+ 1)
       IF (mod(errorcnt,10)=1)
        stat = alterlist(resched_tasks->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].
         results,(errorcnt+ 9))
       ENDIF
       resched_tasks->list[errorcnt].reference_task_id = ot.reference_task_id, audits->list[pos].
       results[errorcnt].primary_key = cnvtstring(ot.reference_task_id), audits->list[pos].results[
       errorcnt].item = ot.task_description,
       audits->list[pos].results[errorcnt].old_value_id = build(ot.reschedule_time,",",ot
        .grace_period_mins), logmsg = build2("Reschedule: ",trim(cnvtstring(ot.reschedule_time)),
        " hours and Grace Period: ",trim(cnvtstring(ot.grace_period_mins))," minutes"), audits->list[
       pos].results[errorcnt].old_value_disp = logmsg,
       audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos]
       .results[errorcnt].last_updt_dt_tm = ot.updt_dt_tm, audits->list[pos].results[errorcnt].
       last_updt_cnt = ot.updt_cnt,
       audits->list[pos].results[errorcnt].new_value_id = build(task_test_values->reschedule_time,",",
        task_test_values->grace_period_mins), logmsg = build2("Reschedule: ",trim(cnvtstring(
          task_test_values->reschedule_time))," hours and Grace Period: ",trim(cnvtstring(
          task_test_values->grace_period_mins))," minutes"), audits->list[pos].results[errorcnt].
       new_value_disp = logmsg,
       audits->list[pos].results[errorcnt].status_str = fixedstr
      FOOT REPORT
       IF (mod(errorcnt,10) != 0)
        stat = alterlist(resched_tasks->list,errorcnt), stat = alterlist(audits->list[pos].results,
         errorcnt)
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
      SET logmsg =
      "All pharmacy tasks that are active have the correct reschedule and grace period settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_task ot
        PLAN (ot
         WHERE expand(i,1,size(resched_tasks->list,5),ot.reference_task_id,resched_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, forupdate(ot), expand = 1
       ;end select
       UPDATE  FROM order_task ot
        SET ot.reschedule_time = task_test_values->reschedule_time, ot.grace_period_mins =
         task_test_values->grace_period_mins, ot.updt_cnt = (ot.updt_cnt+ 1),
         ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task
          = - (267)
        PLAN (ot
         WHERE expand(i,1,size(resched_tasks->list,5),ot.reference_task_id,resched_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, expand = 1
       ;end update
       IF (curqual=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2(
         "Total number of tasks that had their reschedule or grace period settings updated: ",trim(
          cnvtstring(fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating reschedule and grace period settings on tasks. See ",
         logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_TASK TO SET THE RESCHEDULE AND GRACE PERIOD. ROLLING BACK ALL CHANGES."
         )
        CALL addlogmsg(errorstr,
         "Review the reference_task_ids in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
           cnvtstring(curqual))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE taskpositiontochart(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("TASK_POS_TO_CHART")
   DECLARE totalstr = vc WITH protect
   DECLARE poscnt = i4 WITH protect
   DECLARE taskcnt = i4 WITH protect
   DECLARE taskpos = i4 WITH protect
   DECLARE updtcnt = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE outputcnt = i4 WITH protect
   SET totalstr = "Total number of position to chart errors on tasks: "
   RECORD pos_tasks(
     1 list[*]
       2 reference_task_id = f8
       2 allpositionchart_ind = i2
       2 pos_list[*]
         3 position_cd = f8
         3 position_disp = vc
         3 insert_ind = i2
         3 delete_ind = i2
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
    IF (testcatloadedind=test_cat_loaded)
     IF ((task_test_values->allpositionchart_ind=1))
      SELECT INTO "nl:"
       ot.reference_task_id
       FROM order_catalog oc,
        order_task_xref otx,
        order_task ot,
        prsnl p
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.activity_type_cd=pharm_act_cd
         AND oc.active_ind=1)
        JOIN (otx
        WHERE otx.catalog_cd=oc.catalog_cd)
        JOIN (ot
        WHERE ot.reference_task_id=otx.reference_task_id
         AND ot.active_ind=1
         AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[
          i].id)))
         AND ot.allpositionchart_ind != 1)
        JOIN (p
        WHERE p.person_id=ot.updt_id)
       ORDER BY ot.task_description_key
       DETAIL
        errorcnt = (errorcnt+ 1), taskcnt = (taskcnt+ 1), fixedcnt = (fixedcnt+ 1),
        outputcnt = (outputcnt+ 1)
        IF (mod(taskcnt,10)=1)
         stat = alterlist(pos_tasks->list,(taskcnt+ 9))
        ENDIF
        IF (mod(outputcnt,10)=1)
         stat = alterlist(audits->list[pos].results,(outputcnt+ 9))
        ENDIF
        pos_tasks->list[taskcnt].reference_task_id = ot.reference_task_id, pos_tasks->list[taskcnt].
        allpositionchart_ind = ot.allpositionchart_ind, audits->list[pos].results[outputcnt].
        primary_key = cnvtstring(ot.reference_task_id),
        audits->list[pos].results[outputcnt].item = ot.task_description, audits->list[pos].results[
        outputcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[outputcnt].
        last_updt_dt_tm = ot.updt_dt_tm,
        audits->list[pos].results[outputcnt].last_updt_cnt = ot.updt_cnt, audits->list[pos].results[
        outputcnt].new_value_id = "1", audits->list[pos].results[outputcnt].new_value_disp =
        "All positions",
        audits->list[pos].results[outputcnt].status_str = fixedstr
       FOOT REPORT
        IF (mod(taskcnt,10) != 0)
         stat = alterlist(pos_tasks->list,taskcnt)
        ENDIF
        IF (mod(outputcnt,10) != 0)
         stat = alterlist(audits->list[pos].results,outputcnt)
        ENDIF
       WITH nocounter
      ;end select
     ELSE
      SELECT DISTINCT INTO "nl:"
       position = trim(substring(1,100,uar_get_code_display(otptst.position_cd))), ot
       .task_description, ot.reference_task_id
       FROM order_catalog oc,
        order_task_xref otx,
        order_task ot,
        prsnl p,
        order_task_position_xref otptst,
        order_task_position_xref otp
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.activity_type_cd=pharm_act_cd
         AND oc.active_ind=1)
        JOIN (otx
        WHERE otx.catalog_cd=oc.catalog_cd)
        JOIN (ot
        WHERE ot.reference_task_id=otx.reference_task_id
         AND ot.active_ind=1
         AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[
          i].id))))
        JOIN (p
        WHERE p.person_id=ot.updt_id)
        JOIN (otptst
        WHERE (otptst.reference_task_id=task_test_values->reference_task_id))
        JOIN (otp
        WHERE otp.reference_task_id=ot.reference_task_id
         AND  NOT ( EXISTS (
        (SELECT
         otp2.position_cd
         FROM order_task_position_xref otp2
         WHERE otp2.reference_task_id=otp.reference_task_id
          AND otp2.position_cd=otptst.position_cd))))
       ORDER BY ot.task_description_key, ot.reference_task_id, position,
        otptst.position_cd
       HEAD ot.reference_task_id
        taskcnt = (taskcnt+ 1)
        IF (mod(taskcnt,10)=1)
         stat = alterlist(pos_tasks->list,(taskcnt+ 9))
        ENDIF
        pos_tasks->list[taskcnt].reference_task_id = ot.reference_task_id
        IF (ot.allpositionchart_ind=1)
         errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
        ENDIF
        poscnt = 0
       DETAIL
        errorcnt = (errorcnt+ 1), poscnt = (poscnt+ 1), outputcnt = (outputcnt+ 1)
        IF (mod(poscnt,10)=1)
         stat = alterlist(pos_tasks->list[taskcnt].pos_list,(poscnt+ 9))
        ENDIF
        IF (mod(outputcnt,10)=1)
         stat = alterlist(audits->list[pos].results,(outputcnt+ 9))
        ENDIF
        pos_tasks->list[taskcnt].pos_list[poscnt].position_cd = otptst.position_cd, pos_tasks->list[
        taskcnt].pos_list[poscnt].position_disp = position, pos_tasks->list[taskcnt].pos_list[poscnt]
        .insert_ind = 1,
        pos_tasks->list[taskcnt].allpositionchart_ind = ot.allpositionchart_ind, audits->list[pos].
        results[outputcnt].primary_key = cnvtstring(ot.reference_task_id), audits->list[pos].results[
        outputcnt].item = ot.task_description,
        audits->list[pos].results[outputcnt].old_value_id = "0", audits->list[pos].results[outputcnt]
        .last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[outputcnt].
        last_updt_dt_tm = ot.updt_dt_tm,
        audits->list[pos].results[outputcnt].last_updt_cnt = ot.updt_cnt, audits->list[pos].results[
        outputcnt].new_value_id = cnvtstring(otptst.position_cd), audits->list[pos].results[outputcnt
        ].new_value_disp = position,
        audits->list[pos].results[outputcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
        IF (ot.allpositionchart_ind=1)
         audits->list[pos].results[outputcnt].old_value_id = "1", audits->list[pos].results[outputcnt
         ].old_value_id = "All positions"
        ENDIF
       FOOT  ot.reference_task_id
        IF (mod(poscnt,10) != 0)
         stat = alterlist(pos_tasks->list[taskcnt].pos_list,poscnt)
        ENDIF
       FOOT REPORT
        IF (mod(taskcnt,10) != 0)
         stat = alterlist(pos_tasks->list,taskcnt)
        ENDIF
        IF (mod(outputcnt,10) != 0)
         stat = alterlist(audits->list[pos].results,outputcnt)
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       ot.task_description, ot.reference_task_id
       FROM order_catalog oc,
        order_task_xref otx,
        order_task ot,
        prsnl p
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.activity_type_cd=pharm_act_cd
         AND oc.active_ind=1)
        JOIN (otx
        WHERE otx.catalog_cd=oc.catalog_cd)
        JOIN (ot
        WHERE ot.reference_task_id=otx.reference_task_id
         AND ot.active_ind=1
         AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[
          i].id)))
         AND  NOT ( EXISTS (
        (SELECT
         otp.reference_task_id
         FROM order_task_position_xref otp
         WHERE otp.reference_task_id=ot.reference_task_id))))
        JOIN (p
        WHERE p.person_id=ot.updt_id)
       ORDER BY ot.task_description_key, ot.reference_task_id
       DETAIL
        taskcnt = (taskcnt+ 1)
        IF (size(pos_tasks->list,5) < taskcnt)
         stat = alterlist(pos_tasks->list,(taskcnt+ 10))
        ENDIF
        pos_tasks->list[taskcnt].reference_task_id = ot.reference_task_id, pos_tasks->list[taskcnt].
        allpositionchart_ind = ot.allpositionchart_ind, stat = alterlist(pos_tasks->list[taskcnt].
         pos_list,size(task_test_values->position_chart_list,5)),
        poscnt = 0
        FOR (j = 1 TO size(task_test_values->position_chart_list,5))
          errorcnt = (errorcnt+ 1), poscnt = (poscnt+ 1), outputcnt = (outputcnt+ 1)
          IF (size(audits->list[pos].results,5) < outputcnt)
           stat = alterlist(audits->list[pos].results,(outputcnt+ 9))
          ENDIF
          pos_tasks->list[taskcnt].pos_list[poscnt].position_cd = task_test_values->
          position_chart_list[j].position_cd, pos_tasks->list[taskcnt].pos_list[poscnt].position_disp
           = task_test_values->position_chart_list[j].position_name, pos_tasks->list[taskcnt].
          pos_list[poscnt].insert_ind = 1,
          fixedcnt = (fixedcnt+ 1), audits->list[pos].results[outputcnt].primary_key = cnvtstring(ot
           .reference_task_id), audits->list[pos].results[outputcnt].item = ot.task_description,
          audits->list[pos].results[outputcnt].old_value_id = "0", audits->list[pos].results[
          outputcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[outputcnt].
          last_updt_dt_tm = ot.updt_dt_tm,
          audits->list[pos].results[outputcnt].last_updt_cnt = ot.updt_cnt, audits->list[pos].
          results[outputcnt].new_value_id = cnvtstring(task_test_values->position_chart_list[j].
           position_cd), audits->list[pos].results[outputcnt].new_value_disp = task_test_values->
          position_chart_list[j].position_name,
          audits->list[pos].results[outputcnt].status_str = fixedstr
          IF (ot.allpositionchart_ind=1)
           audits->list[pos].results[outputcnt].old_value_id = "1", audits->list[pos].results[
           outputcnt].old_value_disp = "All positions"
          ENDIF
        ENDFOR
        IF (ot.allpositionchart_ind=1)
         errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
        ENDIF
       FOOT REPORT
        stat = alterlist(pos_tasks->list,taskcnt), stat = alterlist(audits->list[pos].results,
         outputcnt)
       WITH nocounter
      ;end select
      SELECT DISTINCT INTO "nl:"
       position = trim(substring(1,100,uar_get_code_display(otp.position_cd))), ot.task_description,
       ot.reference_task_id
       FROM order_catalog oc,
        order_task_xref otx,
        order_task ot,
        prsnl p,
        order_task_position_xref otp,
        order_task_position_xref otptst
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.activity_type_cd=pharm_act_cd
         AND oc.active_ind=1)
        JOIN (otx
        WHERE otx.catalog_cd=oc.catalog_cd)
        JOIN (ot
        WHERE ot.reference_task_id=otx.reference_task_id
         AND ot.active_ind=1
         AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[
          i].id))))
        JOIN (p
        WHERE p.person_id=ot.updt_id)
        JOIN (otp
        WHERE otp.reference_task_id=ot.reference_task_id)
        JOIN (otptst
        WHERE (otptst.reference_task_id=task_test_values->reference_task_id)
         AND  NOT ( EXISTS (
        (SELECT
         otp2.position_cd
         FROM order_task_position_xref otp2
         WHERE otp2.reference_task_id=otptst.reference_task_id
          AND otp2.position_cd=otp.position_cd))))
       ORDER BY ot.task_description_key, ot.reference_task_id, position,
        otp.position_cd
       HEAD ot.reference_task_id
        taskpos = locateval(j,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[j].
         reference_task_id)
        IF (taskpos=0)
         taskcnt = (taskcnt+ 1), taskpos = taskcnt
         IF (size(pos_tasks->list,5) < taskcnt)
          stat = alterlist(pos_tasks->list,(taskcnt+ 10))
         ENDIF
         pos_tasks->list[taskpos].reference_task_id = ot.reference_task_id
         IF (ot.allpositionchart_ind=1)
          errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
         ENDIF
         poscnt = 0
        ELSE
         poscnt = size(pos_tasks->list[taskpos].pos_list,5)
        ENDIF
       DETAIL
        errorcnt = (errorcnt+ 1), poscnt = (poscnt+ 1), outputcnt = (outputcnt+ 1),
        stat = alterlist(pos_tasks->list[taskpos].pos_list,poscnt)
        IF (size(audits->list[pos].results,5) < outputcnt)
         stat = alterlist(audits->list[pos].results,(outputcnt+ 9))
        ENDIF
        pos_tasks->list[taskpos].pos_list[poscnt].position_cd = otp.position_cd, pos_tasks->list[
        taskpos].pos_list[poscnt].position_disp = position, pos_tasks->list[taskpos].pos_list[poscnt]
        .delete_ind = 1,
        pos_tasks->list[taskpos].allpositionchart_ind = ot.allpositionchart_ind, audits->list[pos].
        results[outputcnt].primary_key = cnvtstring(ot.reference_task_id), audits->list[pos].results[
        outputcnt].item = ot.task_description,
        audits->list[pos].results[outputcnt].old_value_id = cnvtstring(otp.position_cd), audits->
        list[pos].results[outputcnt].old_value_disp = position, audits->list[pos].results[outputcnt].
        last_updt_prsnl = p.name_full_formatted,
        audits->list[pos].results[outputcnt].last_updt_dt_tm = ot.updt_dt_tm, audits->list[pos].
        results[outputcnt].last_updt_cnt = ot.updt_cnt, audits->list[pos].results[outputcnt].
        new_value_id = "0",
        audits->list[pos].results[outputcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
       FOOT REPORT
        stat = alterlist(pos_tasks->list,taskcnt), stat = alterlist(audits->list[pos].results,
         outputcnt)
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       ot.task_description, ot.reference_task_id
       FROM order_catalog oc,
        order_task_xref otx,
        order_task ot,
        prsnl p
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.activity_type_cd=pharm_act_cd
         AND oc.active_ind=1)
        JOIN (otx
        WHERE otx.catalog_cd=oc.catalog_cd)
        JOIN (ot
        WHERE ot.reference_task_id=otx.reference_task_id
         AND ot.active_ind=1
         AND ot.allpositionchart_ind=1
         AND  NOT (expand(i,1,temp_ignores->list_sz,ot.reference_task_id,cnvtreal(temp_ignores->list[
          i].id)))
         AND  NOT (expand(num,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[num].
         reference_task_id)))
        JOIN (p
        WHERE p.person_id=ot.updt_id)
       ORDER BY ot.task_description_key, ot.reference_task_id
       DETAIL
        errorcnt = (errorcnt+ 1), taskcnt = (taskcnt+ 1), outputcnt = (outputcnt+ 1)
        IF (size(pos_tasks->list,5) < taskcnt)
         stat = alterlist(pos_tasks->list,(taskcnt+ 9))
        ENDIF
        IF (size(audits->list[pos].results,5) < outputcnt)
         stat = alterlist(audits->list[pos].results,(outputcnt+ 9))
        ENDIF
        pos_tasks->list[taskcnt].reference_task_id = ot.reference_task_id, pos_tasks->list[taskcnt].
        allpositionchart_ind = ot.allpositionchart_ind, audits->list[pos].results[outputcnt].
        primary_key = cnvtstring(ot.reference_task_id),
        audits->list[pos].results[outputcnt].item = ot.task_description, audits->list[pos].results[
        outputcnt].old_value_id = "1", audits->list[pos].results[outputcnt].old_value_disp =
        "All positions",
        audits->list[pos].results[outputcnt].last_updt_prsnl = p.name_full_formatted, audits->list[
        pos].results[outputcnt].last_updt_dt_tm = ot.updt_dt_tm, audits->list[pos].results[outputcnt]
        .last_updt_cnt = ot.updt_cnt,
        audits->list[pos].results[outputcnt].new_value_id = "0", audits->list[pos].results[outputcnt]
        .new_value_disp = "Selected positions", audits->list[pos].results[outputcnt].status_str =
        fixedstr,
        fixedcnt = (fixedcnt+ 1)
       FOOT REPORT
        stat = alterlist(pos_tasks->list,taskcnt), stat = alterlist(audits->list[pos].results,
         outputcnt)
       WITH nocounter
      ;end select
     ENDIF
     IF (error(cclerrorstr,0) > 0)
      CALL addlogmsg(errorstr,cclerrorstr)
      SET status = "F"
      SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
      GO TO exit_script
     ENDIF
     IF (errorcnt=0)
      SET logmsg = "All pharmacy tasks that are active have the correct positions to chart settings"
      CALL addlogmsg(successstr,logmsg)
      SET audits->list[pos].results[1].status_str = successstr
      SET audits->list[pos].results[1].item = logmsg
     ELSE
      IF (autofixind=1
       AND opsind=1
       AND fixedcnt > 0)
       SELECT INTO "nl:"
        FROM order_task_position_xref otp
        PLAN (otp
         WHERE expand(i,1,size(pos_tasks->list,5),otp.reference_task_id,pos_tasks->list[i].
          reference_task_id)
          AND otp.reference_task_id != 0.0)
        WITH nocounter, forupdate(otp), expand = 1
       ;end select
       SELECT INTO "nl:"
        FROM order_task ot
        PLAN (ot
         WHERE expand(i,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[i].
          reference_task_id)
          AND ot.reference_task_id != 0.0)
        WITH nocounter, forupdate(ot), expand = 1
       ;end select
       IF ((task_test_values->allpositionchart_ind=1))
        UPDATE  FROM order_task ot
         SET ot.allpositionchart_ind = 1, ot.updt_cnt = ot.updt_cnt, ot.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          ot.updt_id = reqinfo->updt_id, ot.updt_task = - (267)
         PLAN (ot
          WHERE expand(i,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[i].
           reference_task_id)
           AND ot.reference_task_id != 0.0)
         WITH nocounter, forupdate(ot), expand = 1
        ;end update
        SET updtcnt = curqual
        DELETE  FROM order_task_position_xref otp
         PLAN (otp
          WHERE expand(i,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[i].
           reference_task_id)
           AND ot.reference_task_id != 0.0)
         WITH nocounter
        ;end delete
       ELSE
        UPDATE  FROM order_task ot
         SET ot.allpositionchart_ind = 0, ot.updt_cnt = ot.updt_cnt, ot.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          ot.updt_id = reqinfo->updt_id, ot.updt_task = - (267)
         PLAN (ot
          WHERE expand(i,1,size(pos_tasks->list,5),ot.reference_task_id,pos_tasks->list[i].
           reference_task_id,
           ot.allpositionchart_ind,1)
           AND ot.reference_task_id != 0.0)
         WITH nocounter, expand = 1
        ;end update
        SET updtcnt = curqual
        DELETE  FROM (dummyt d1  WITH seq = value(size(pos_tasks->list,5))),
          (dummyt d2  WITH seq = 1),
          order_task_position_xref otp
         SET otp.seq = 0
         PLAN (d1
          WHERE maxrec(d2,size(pos_tasks->list[d1.seq].pos_list,5)))
          JOIN (d2
          WHERE (pos_tasks->list[d1.seq].pos_list[d2.seq].delete_ind=1))
          JOIN (otp
          WHERE (otp.reference_task_id=pos_tasks->list[d1.seq].reference_task_id)
           AND (otp.position_cd=pos_tasks->list[d1.seq].pos_list[d2.seq].position_cd)
           AND otp.reference_task_id != 0.0)
         WITH nocounter
        ;end delete
        SET updtcnt = (updtcnt+ curqual)
        INSERT  FROM (dummyt d1  WITH seq = value(size(pos_tasks->list,5))),
          (dummyt d2  WITH seq = 1),
          order_task_position_xref otp
         SET otp.reference_task_id = pos_tasks->list[d1.seq].reference_task_id, otp.position_cd =
          pos_tasks->list[d1.seq].pos_list[d2.seq].position_cd, otp.updt_cnt = 0,
          otp.updt_dt_tm = cnvtdatetime(curdate,curtime3), otp.updt_id = reqinfo->updt_id, otp
          .updt_task = - (267)
         PLAN (d1
          WHERE maxrec(d2,size(pos_tasks->list[d1.seq].pos_list,5)))
          JOIN (d2
          WHERE (pos_tasks->list[d1.seq].pos_list[d2.seq].insert_ind=1))
          JOIN (otp)
         WITH nocounter
        ;end insert
        SET updtcnt = (updtcnt+ curqual)
       ENDIF
       IF (updtcnt=fixedcnt
        AND error(cclerrorstr,0)=0)
        SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
        SET audits->list[pos].fixed_cnt = fixedcnt
        CALL addlogmsg(infostr,linestr)
        SET logmsg = build2("Total number of positions to chart errors fixed: ",trim(cnvtstring(
           fixedcnt)))
        CALL addlogmsg(successstr,logmsg)
       ELSE
        SET status = "F"
        SET statusstr = build2("Error updating postions to chart on tasks. See ",logfilename)
        CALL addlogmsg(errorstr,
         "ERROR UPDATING ORDER_TASK_POSITION_XREF TO SET THE POSITIONS TO CHART. ROLLING BACK ALL CHANGES."
         )
        CALL addlogmsg(errorstr,
         "Review the reference_task_ids in the output CSV with a fixed status that were supposed to be updated"
         )
        CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," updtCnt = ",trim(
           cnvtstring(updtcnt))))
        CALL addlogmsg(errorstr,cclerrorstr)
        GO TO exit_script
       ENDIF
      ENDIF
      CALL addlogmsg(infostr,linestr)
      SET logmsg = build2(totalstr,trim(cnvtstring(fixedcnt)))
      CALL addlogmsg(failurestr,logmsg)
     ENDIF
     IF (autofixind=1
      AND opsind=1)
      CALL addtrackingrow(auditname,(errorcnt - fixedcnt),totalstr)
     ELSE
      CALL addtrackingrow(auditname,errorcnt,totalstr)
     ENDIF
    ELSEIF (testcatloadedind=test_cat_failed)
     SET logmsg = build2(test_catalog_name,
      " primary could not be loaded. Ensure primary exists and is active.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
    ELSEIF (testcatloadedind=test_task_failed)
     SET logmsg = build2(test_catalog_name,
      " task could not be loaded. Ensure task exists and is linked to orderable.")
     CALL addlogmsg(failurestr,logmsg)
     SET audits->list[pos].results[1].status_str = failurestr
     SET audits->list[pos].results[1].item = logmsg
     CALL addtrackingrow(auditname,- (1),totalstr)
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
 SUBROUTINE synonymswithmultiplegroupers(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_MULTIPLE_GROUPERS")
   DECLARE totalstr = vc WITH protect
   DECLARE cclsql_to_number(p1) = f8
   SET totalstr = "Total number of unhidden synonyms belonging to multiple active DRC groupers: "
   RECORD drc_syns(
     1 list[*]
       2 synonym_id = f8
       2 vv_ind = i2
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
     ocs.mnemonic, ocs.synonym_id, ofr.synonym_id,
     ocs.updt_cnt, ocs.updt_dt_tm, p.name_full_formatted,
     drc_cnt = count(drc.dose_range_check_id)
     FROM mltm_order_catalog_load mocl,
      order_catalog_synonym ocs,
      prsnl p,
      ocs_facility_r ofr,
      drc_group_reltn dgr,
      drc_form_reltn dfr,
      dose_range_check drc
     PLAN (mocl
      WHERE mocl.hide_ind=1)
      JOIN (ocs
      WHERE ocs.cki=mocl.synonym_cki
       AND ocs.cki > " "
       AND ocs.hide_flag=0
       AND ocs.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
      JOIN (ofr
      WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
      JOIN (dgr
      WHERE dgr.drug_synonym_id=cclsql_to_number(substring(13,10,ocs.cki)))
      JOIN (dfr
      WHERE dfr.drc_group_id=dgr.drc_group_id)
      JOIN (drc
      WHERE drc.dose_range_check_id=dfr.dose_range_check_id
       AND drc.active_ind=1)
     GROUP BY ocs.mnemonic, ocs.synonym_id, ofr.synonym_id,
      ocs.updt_cnt, ocs.updt_dt_tm, p.name_full_formatted
     HAVING count(drc.dose_range_check_id) > 1
     ORDER BY cnvtupper(ocs.mnemonic)
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(drc_syns->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
        errorcnt+ 9))
      ENDIF
      drc_syns->list[errorcnt].synonym_id = ocs.synonym_id, audits->list[pos].results[errorcnt].
      primary_key = cnvtstring(ocs.synonym_id), audits->list[pos].results[errorcnt].old_value_id =
      "0",
      audits->list[pos].results[errorcnt].old_value_disp = "Unhidden", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = ocs.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = ocs.updt_cnt, audits->list[pos].results[
      errorcnt].status_str = failurestr
      IF (ofr.synonym_id > 0)
       drc_syns->list[errorcnt].vv_ind = 1, logmsg = build2(trim(ocs.mnemonic),
        " is virtual viewed on"), audits->list[pos].results[errorcnt].item = logmsg
      ELSE
       fixedcnt = (fixedcnt+ 1), logmsg = build2(trim(ocs.mnemonic)," is NOT virtual viewed on"),
       audits->list[pos].results[errorcnt].item = logmsg,
       audits->list[pos].results[errorcnt].new_value_id = "1", audits->list[pos].results[errorcnt].
       new_value_disp = "Hidden", audits->list[pos].results[errorcnt].status_str = fixedstr
      ENDIF
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(drc_syns->list,errorcnt), stat = alterlist(audits->list[pos].results,errorcnt
        )
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
     SET logmsg = "All active synonyms belonging to multiple DRC groupers are hidden"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs
       WHERE expand(i,1,size(drc_syns->list,5),ocs.synonym_id,drc_syns->list[i].synonym_id,
        0,drc_syns->list[i].vv_ind)
       WITH nocounter, forupdate(ocs), expand = 1
      ;end select
      UPDATE  FROM order_catalog_synonym ocs
       SET ocs.hide_flag = 1, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt
        + 1),
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
        .updt_task = - (267)
       WHERE expand(i,1,size(drc_syns->list,5),ocs.synonym_id,drc_syns->list[i].synonym_id,
        0,drc_syns->list[i].vv_ind)
        AND ocs.synonym_id != 0.0
       WITH nocounter, expand = 1
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of synonyms that had their hide flag set: ",trim(cnvtstring(
          fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating synonym hide_flag to 1. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG_SYNONYM TO SET THE HIDE_FLAG TO 1. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the synonym_ids in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE unauthroutesandforms(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNAUTH_CODE_VALUES")
   DECLARE totalstr = vc WITH protect
   DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
   SET totalstr = "Total number of code_values with invalid authentication statuses: "
   RECORD unauth_cvs(
     1 list[*]
       2 code_value = f8
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
     cv.code_value
     FROM code_value cv,
      prsnl p
     PLAN (cv
      WHERE cv.code_set IN (4001, 4002)
       AND cv.active_ind=1
       AND cv.data_status_cd=0
       AND  NOT (expand(i,1,temp_ignores->list_sz,cv.code_value,cnvtreal(temp_ignores->list[i].id))))
      JOIN (p
      WHERE p.person_id=cv.updt_id)
     ORDER BY cv.code_set, cv.display_key
     DETAIL
      errorcnt = (errorcnt+ 1), fixedcnt = (fixedcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(unauth_cvs->list,(errorcnt+ 9)), stat = alterlist(audits->list[pos].results,(
        errorcnt+ 9))
      ENDIF
      unauth_cvs->list[errorcnt].code_value = cv.code_value, audits->list[pos].results[errorcnt].
      primary_key = cnvtstring(cv.code_value), logmsg = build2(evaluate(cv.code_set,4001,"Route: ",
        4002,"Form: "),cv.display),
      audits->list[pos].results[errorcnt].item = logmsg, audits->list[pos].results[errorcnt].
      old_value_id = "0", audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = cv.updt_dt_tm, audits->list[pos].results[
      errorcnt].last_updt_cnt = cv.updt_cnt, audits->list[pos].results[errorcnt].new_value_id =
      cnvtstring(auth_cd),
      audits->list[pos].results[errorcnt].new_value_disp = uar_get_code_display(auth_cd), audits->
      list[pos].results[errorcnt].status_str = fixedstr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(unauth_cvs->list,errorcnt), stat = alterlist(audits->list[pos].results,
        errorcnt)
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
     SET logmsg = "All active routes and forms are authenticated"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE expand(i,1,size(unauth_cvs->list,5),cv.code_value,unauth_cvs->list[i].code_value)
       WITH nocounter, forupdate(cv)
      ;end select
      UPDATE  FROM code_value cv
       SET cv.data_status_cd = auth_cd, cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cv
        .updt_applctx = reqinfo->updt_applctx,
        cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id =
        reqinfo->updt_id,
        cv.updt_task = - (267)
       WHERE expand(i,1,size(unauth_cvs->list,5),cv.code_value,unauth_cvs->list[i].code_value)
        AND cv.code_set IN (4001, 4002)
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of code_values that were updated to authenticated: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating code_values to authenticated status. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING CODE_VALUE TO SET THE DATA_STATUS_CD TO AUTH. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the code_values in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE invalidmultumaliases(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("INVALID_MULTUM_ALIASES")
   DECLARE totalstr = vc WITH protect
   DECLARE multum_contrib_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"MULTUM"))
   SET totalstr = "Total number of invalid Multum aliases: "
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
     cv.code_value, cv.display, cva.alias
     FROM code_value cv,
      code_value_alias cva,
      prsnl p
     PLAN (cv
      WHERE cv.code_set=54
       AND cv.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,cv.code_value,cnvtreal(temp_ignores->list[i].id))))
      JOIN (cva
      WHERE cva.code_value=cv.code_value
       AND cva.alias_type_meaning="UNIT"
       AND cva.contributor_source_cd=multum_contrib_cd
       AND  NOT ( EXISTS (
      (SELECT
       m.unit_abbr
       FROM mltm_units m
       WHERE m.unit_abbr=cva.alias))))
      JOIN (p
      WHERE p.person_id=cva.updt_id)
     ORDER BY cv.display_key
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(cv.code_value), logmsg = build2(
       "Unit of measure: ",cv.display), audits->list[pos].results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].old_value_id = cva.alias, audits->list[pos].results[
      errorcnt].old_value_disp = cva.alias, audits->list[pos].results[errorcnt].last_updt_prsnl = p
      .name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = cva.updt_dt_tm, audits->list[pos].
      results[errorcnt].last_updt_cnt = cva.updt_cnt, audits->list[pos].results[errorcnt].status_str
       = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value, cv.display, cva.alias
     FROM code_value cv,
      code_value_alias cva,
      prsnl p
     PLAN (cv
      WHERE cv.code_set=4001
       AND cv.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,cv.code_value,cnvtreal(temp_ignores->list[i].id))))
      JOIN (cva
      WHERE cva.code_value=cv.code_value
       AND cva.alias_type_meaning="ROUTE"
       AND cva.contributor_source_cd=multum_contrib_cd
       AND  NOT ( EXISTS (
      (SELECT
       r.route_abbr
       FROM mltm_product_route r
       WHERE r.route_abbr=cva.alias))))
      JOIN (p
      WHERE p.person_id=cva.updt_id)
     ORDER BY cv.display_key
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (size(audits->list[pos].results,5) < errorcnt)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(cv.code_value), logmsg = build2(
       "Route: ",cv.display), audits->list[pos].results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].old_value_id = cva.alias, audits->list[pos].results[
      errorcnt].old_value_disp = cva.alias, audits->list[pos].results[errorcnt].last_updt_prsnl = p
      .name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = cva.updt_dt_tm, audits->list[pos].
      results[errorcnt].last_updt_cnt = cva.updt_cnt, audits->list[pos].results[errorcnt].status_str
       = failurestr
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value, cv.display, cva.alias
     FROM code_value cv,
      code_value_alias cva,
      prsnl p
     PLAN (cv
      WHERE cv.code_set=4002
       AND cv.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,cv.code_value,cnvtreal(temp_ignores->list[i].id))))
      JOIN (cva
      WHERE cva.code_value=cv.code_value
       AND cva.alias_type_meaning="FORM"
       AND cva.contributor_source_cd=multum_contrib_cd
       AND  NOT ( EXISTS (
      (SELECT
       f.dose_form_abbr
       FROM mltm_dose_form f
       WHERE f.dose_form_abbr=cva.alias))))
      JOIN (p
      WHERE p.person_id=cva.updt_id)
     ORDER BY cv.display_key
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (size(audits->list[pos].results,5) < errorcnt)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(cv.code_value), logmsg = build2(
       "Form: ",cv.display), audits->list[pos].results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].old_value_id = cva.alias, audits->list[pos].results[
      errorcnt].old_value_disp = cva.alias, audits->list[pos].results[errorcnt].last_updt_prsnl = p
      .name_full_formatted,
      audits->list[pos].results[errorcnt].last_updt_dt_tm = cva.updt_dt_tm, audits->list[pos].
      results[errorcnt].last_updt_cnt = cva.updt_cnt, audits->list[pos].results[errorcnt].status_str
       = failurestr
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt)
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     SET logmsg = "All routes, forms, and units of measure have a valid Multum alias"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE unmappeduomaliases(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNMAPPED_UOM_ALIASES")
   DECLARE totalstr = vc WITH protect
   DECLARE multum_contrib_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"MULTUM"))
   SET totalstr = "Total number of unmapped Multum aliases for units of measure: "
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
     m.unit_abbr
     FROM mltm_units m
     PLAN (m
      WHERE  NOT ( EXISTS (
      (SELECT
       cva.alias
       FROM code_value cv,
        code_value_alias cva
       WHERE cv.code_set=54
        AND cv.active_ind=1
        AND cva.code_value=cv.code_value
        AND cva.alias_type_meaning="UNIT"
        AND cva.contributor_source_cd=multum_contrib_cd
        AND cva.alias=m.unit_abbr)))
       AND  NOT (expand(i,1,temp_ignores->list_sz,m.unit_id,cnvtreal(temp_ignores->list[i].id))))
     ORDER BY m.unit_abbr
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(m.unit_id), logmsg = build2(
       "Alias ",trim(m.unit_abbr)," for unit of measure ",trim(m.unit_description)), audits->list[pos
      ].results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All Multum aliases for units of measure have been mapped"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE unmappedroutealiases(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNMAPPED_ROUTE_ALIASES")
   DECLARE totalstr = vc WITH protect
   DECLARE multum_contrib_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"MULTUM"))
   SET totalstr = "Total number of unmapped Multum aliases for routes: "
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
     r.route_abbr
     FROM mltm_product_route r
     PLAN (r
      WHERE  NOT ( EXISTS (
      (SELECT
       cva.alias
       FROM code_value cv,
        code_value_alias cva
       WHERE cv.code_set=4001
        AND cv.active_ind=1
        AND cva.code_value=cv.code_value
        AND cva.alias_type_meaning="ROUTE"
        AND cva.contributor_source_cd=multum_contrib_cd
        AND cva.alias=r.route_abbr)))
       AND  NOT (expand(i,1,temp_ignores->list_sz,r.route_code,cnvtint(temp_ignores->list[i].id))))
     ORDER BY r.route_abbr
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(r.route_code), logmsg = build2(
       "Alias ",trim(r.route_abbr)," for the route of ",trim(r.route_description)), audits->list[pos]
      .results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All Multum aliases for routes have been mapped"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE unmappedformaliases(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNMAPPED_FORM_ALIASES")
   DECLARE totalstr = vc WITH protect
   DECLARE multum_contrib_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"MULTUM"))
   SET totalstr = "Total number of unmapped Multum aliases for forms: "
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
     f.dose_form_abbr
     FROM mltm_dose_form f
     PLAN (f
      WHERE  NOT ( EXISTS (
      (SELECT
       cva.alias
       FROM code_value cv,
        code_value_alias cva
       WHERE cv.code_set=4002
        AND cv.active_ind=1
        AND cva.code_value=cv.code_value
        AND cva.alias_type_meaning="FORM"
        AND cva.contributor_source_cd=multum_contrib_cd
        AND cva.alias=f.dose_form_abbr)))
       AND  NOT (expand(i,1,temp_ignores->list_sz,f.dose_form_code,cnvtint(temp_ignores->list[i].id))
      ))
     ORDER BY f.dose_form_abbr
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(f.dose_form_code), logmsg = build2
      ("Alias ",trim(f.dose_form_abbr)," for the form of ",trim(f.dose_form_description)), audits->
      list[pos].results[errorcnt].item = logmsg,
      audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All Multum aliases for forms have been mapped"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE unmappedprnaliases(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("UNMAPPED_PRN_ALIASES")
   DECLARE totalstr = vc WITH protect
   DECLARE reasoncnt = i4 WITH protect
   DECLARE aliascnt = i4 WITH protect
   DECLARE multum_contrib_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"MULTUM"))
   DECLARE plainaliasind = i2 WITH protect
   DECLARE foraliasind = i2 WITH protect
   DECLARE asneededaliasind = i2 WITH protect
   SET totalstr = "Total number of unmapped Multum aliases for PRN reasons: "
   RECORD reasons(
     1 list[*]
       2 code_value = f8
       2 display = vc
       2 aliases[*]
         3 alias = vc
       2 updt_dt_tm = dq8
       2 updt_person = vc
       2 updt_cnt = i4
   ) WITH protect
   RECORD temp_updts(
     1 list[*]
       2 code_value = f8
       2 alias = vc
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
     reason =
     IF (findstring("FOR ",cnvtupper(cki.description))) substring(15,(textlen(cki.description) - 14),
       cki.description)
     ELSEIF (findstring("TO ",cnvtupper(cki.description))) substring(14,(textlen(cki.description) -
       13),cki.description)
     ENDIF
     , cv.code_value, cv.display,
     cva.alias
     FROM code_value cv,
      mltm_cern_rxb_dict_map cki,
      code_value_alias cva,
      prsnl p
     PLAN (cv
      WHERE cv.code_set=4005
       AND cv.active_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,cv.code_value,cnvtreal(temp_ignores->list[i].id))))
      JOIN (cki
      WHERE cki.code_set=cv.code_set
       AND cki.code_cki=cv.cki)
      JOIN (cva
      WHERE cva.code_value=outerjoin(cv.code_value)
       AND cva.contributor_source_cd=outerjoin(multum_contrib_cd))
      JOIN (p
      WHERE p.person_id=cv.updt_id)
     ORDER BY cv.display_key, cv.code_value
     HEAD REPORT
      reasoncnt = 0
     HEAD cv.code_value
      plainaliasind = 0, foraliasind = 0, asneededaliasind = 0
     DETAIL
      IF (cva.alias=cnvtupper(reason))
       plainaliasind = 1
      ENDIF
      IF (cva.alias=build2("FOR ",cnvtupper(reason)))
       foraliasind = 1
      ELSEIF (cva.alias=build2("TO ",cnvtupper(reason)))
       foraliasind = 1
      ENDIF
      IF (cva.alias=build2("AS NEEDED FOR ",cnvtupper(reason)))
       asneededaliasind = 1
      ELSEIF (cva.alias=build2("AS NEEDED TO ",cnvtupper(reason)))
       asneededaliasind = 1
      ENDIF
     FOOT  cv.code_value
      aliascnt = 0
      IF (((plainaliasind=0) OR (((foraliasind=0) OR (asneededaliasind=0)) )) )
       reasoncnt = (reasoncnt+ 1)
       IF (mod(reasoncnt,10)=1)
        stat = alterlist(reasons->list,(reasoncnt+ 9))
       ENDIF
       reasons->list[reasoncnt].code_value = cv.code_value, reasons->list[reasoncnt].display = cv
       .display, reasons->list[reasoncnt].updt_cnt = cv.updt_cnt,
       reasons->list[reasoncnt].updt_dt_tm = cv.updt_dt_tm, reasons->list[reasoncnt].updt_person = p
       .name_full_formatted
      ENDIF
      IF (plainaliasind=0)
       errorcnt = (errorcnt+ 1), aliascnt = (aliascnt+ 1), stat = alterlist(reasons->list[reasoncnt].
        aliases,aliascnt),
       reasons->list[reasoncnt].aliases[aliascnt].alias = cnvtupper(reason)
      ENDIF
      IF (foraliasind=0)
       errorcnt = (errorcnt+ 1), aliascnt = (aliascnt+ 1), stat = alterlist(reasons->list[reasoncnt].
        aliases,aliascnt)
       IF (findstring("FOR ",cnvtupper(cki.description)))
        reasons->list[reasoncnt].aliases[aliascnt].alias = build2("FOR ",cnvtupper(reason))
       ELSEIF (findstring("TO ",cnvtupper(cki.description)))
        reasons->list[reasoncnt].aliases[aliascnt].alias = build2("TO ",cnvtupper(reason))
       ENDIF
      ENDIF
      IF (asneededaliasind=0)
       errorcnt = (errorcnt+ 1), aliascnt = (aliascnt+ 1), stat = alterlist(reasons->list[reasoncnt].
        aliases,aliascnt)
       IF (findstring("FOR ",cnvtupper(cki.description)))
        reasons->list[reasoncnt].aliases[aliascnt].alias = build2("AS NEEDED FOR ",cnvtupper(reason))
       ELSEIF (findstring("TO ",cnvtupper(cki.description)))
        reasons->list[reasoncnt].aliases[aliascnt].alias = build2("AS NEEDED TO ",cnvtupper(reason))
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(reasoncnt,10) != 0)
       stat = alterlist(reasons->list,reasoncnt)
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
     SET logmsg = "All Multum aliases for PRN reasons have been mapped"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     SET fixedcnt = 0
     FOR (reasoncnt = 1 TO size(reasons->list,5))
      SET stat = alterlist(temp_updts->list,errorcnt)
      FOR (aliascnt = 1 TO size(reasons->list[reasoncnt].aliases,5))
        SET fixedcnt = (fixedcnt+ 1)
        IF (mod(fixedcnt,10)=1)
         SET stat = alterlist(audits->list[pos].results,(fixedcnt+ 9))
        ENDIF
        SET temp_updts->list[fixedcnt].code_value = reasons->list[reasoncnt].code_value
        SET temp_updts->list[fixedcnt].alias = reasons->list[reasoncnt].aliases[aliascnt].alias
        SET audits->list[pos].results[fixedcnt].primary_key = cnvtstring(reasons->list[reasoncnt].
         code_value)
        SET audits->list[pos].results[fixedcnt].item = reasons->list[reasoncnt].display
        SET audits->list[pos].results[fixedcnt].last_updt_prsnl = reasons->list[reasoncnt].
        updt_person
        SET audits->list[pos].results[fixedcnt].last_updt_dt_tm = reasons->list[reasoncnt].updt_dt_tm
        SET audits->list[pos].results[fixedcnt].last_updt_cnt = reasons->list[reasoncnt].updt_cnt
        SET audits->list[pos].results[fixedcnt].new_value_id = reasons->list[reasoncnt].aliases[
        aliascnt].alias
        SET audits->list[pos].results[fixedcnt].new_value_disp = reasons->list[reasoncnt].aliases[
        aliascnt].alias
        SET audits->list[pos].results[fixedcnt].status_str = fixedstr
      ENDFOR
     ENDFOR
     IF (mod(fixedcnt,10) != 0)
      SET stat = alterlist(audits->list[pos].results,fixedcnt)
     ENDIF
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      INSERT  FROM code_value_alias cva,
        (dummyt d1  WITH seq = value(size(temp_updts->list,5)))
       SET cva.alias = trim(substring(1,255,temp_updts->list[d1.seq].alias)), cva.code_set = 4005,
        cva.code_value = temp_updts->list[d1.seq].code_value,
        cva.contributor_source_cd = multum_contrib_cd, cva.primary_ind = 0, cva.updt_applctx =
        reqinfo->updt_applctx,
        cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->
        updt_id,
        cva.updt_task = - (267)
       PLAN (d1)
        JOIN (cva)
       WITH nocounter
      ;end insert
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of PRN alias that were created: ",trim(cnvtstring(fixedcnt))
        )
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error inserting PRN aliases. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR INSERTING INTO CODE_VALUE_ALIAS TO CREATE THE PRN ALIASES. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the code_values in the output CSV with a fixed status that were supposed to be updated"
        )
       CALL addlogmsg(errorstr,build2("fixedCnt = ",trim(cnvtstring(fixedcnt))," curqual = ",trim(
          cnvtstring(curqual))))
       CALL addlogmsg(errorstr,cclerrorstr)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
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
 SUBROUTINE synonymsincorrectrxmask(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_INCORRECT_RX_MASK")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synonyms with an incorrect rx mask: "
   RECORD syns(
     1 list[*]
       2 synonym_id = f8
       2 rx_mask = i4
       2 updt_dt_tm = dq8
       2 updt_person = vc
       2 updt_cnt = i4
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
    SELECT DISTINCT INTO "nl:"
     ocs.rx_mask, description = des.value, md.item_id
     FROM medication_definition md,
      order_catalog_synonym ocs,
      prsnl p,
      med_dispense med,
      med_def_flex mdf,
      med_flex_object_idx mfoi,
      med_identifier des
     PLAN (md
      WHERE md.med_type_flag=0)
      JOIN (ocs
      WHERE ocs.item_id=md.item_id
       AND ocs.rx_mask != 0
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
      JOIN (med
      WHERE med.item_id=md.item_id
       AND med.intermittent_filter_ind=1
       AND med.oe_format_flag != 2
       AND  NOT ( EXISTS (
      (SELECT
       ocs2.item_id
       FROM order_catalog_synonym ocs2
       WHERE ocs2.item_id=med.item_id
        AND ((band(ocs2.rx_mask,2) > 0) OR (band(ocs2.rx_mask,4) > 0))
        AND  NOT (band(ocs2.rx_mask,1) > 0)))))
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.active_status_cd=active_status_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.flex_type_cd=sys_pkg_type_cd)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=orderable_flex_type_cd)
      JOIN (des
      WHERE des.item_id=md.item_id
       AND des.med_identifier_type_cd=desc_type_cd
       AND des.med_product_id=0
       AND des.active_ind=1
       AND des.primary_ind=1
       AND des.pharmacy_type_cd=inpatient_type_cd)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, des.value_key,
      des.item_id, 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2(trim(ocs.mnemonic),
       "'s product is marked as intermittent but it has a mask of "), audits->list[pos].results[
      errorcnt].old_value_id = cnvtstring(ocs.rx_mask),
      logmsg = trim(build2(trim(
         IF (band(ocs.rx_mask,1) > 0) "Diluent,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,2) > 0) "Additive,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,4) > 0) "Med,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,8) > 0) "TPN,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,16) > 0) "Sliding Scale,"
         ENDIF
         ,3),
        trim(
         IF (band(ocs.rx_mask,32) > 0) "Tapering Dose,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,64) > 0) "PCA Pump,"
         ENDIF
         ,3))), logmsg = substring(1,(textlen(logmsg) - 1),logmsg), audits->list[pos].results[
      errorcnt].old_value_disp = logmsg,
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs2.synonym_id, ocs2.rx_mask
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      order_catalog_synonym ocs2,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=md.item_id
       AND mis.strength=0.0
       AND mis.strength_unit_cd=0.0)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id)
      JOIN (ocs2
      WHERE ocs2.catalog_cd=ocs.catalog_cd
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs2.synonym_id,cnvtreal(temp_ignores->list[i].id))
      )
       AND ocs2.mnemonic_type_cd=syn_type_primary
       AND ocs2.rx_mask != 1)
      JOIN (p
      WHERE p.person_id=ocs2.updt_id)
     ORDER BY ocs2.mnemonic_key_cap, ocs.mnemonic_key_cap, ocs2.synonym_id,
      ocs2.rx_mask, 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs2.synonym_id), audits->list[pos
      ].results[errorcnt].item = build2("The primary synonym ",trim(ocs2.mnemonic),
       " does not have a mask of diluent. The associated rx mnemonic ",trim(ocs.mnemonic),
       "  is in use as the diluent within a premix"), audits->list[pos].results[errorcnt].
      old_value_id = cnvtstring(ocs2.rx_mask),
      logmsg = trim(build2(trim(
         IF (band(ocs2.rx_mask,1) > 0) "Diluent,"
         ENDIF
         ,3),trim(
         IF (band(ocs2.rx_mask,2) > 0) "Additive,"
         ENDIF
         ,3),trim(
         IF (band(ocs2.rx_mask,4) > 0) "Med,"
         ENDIF
         ,3),trim(
         IF (band(ocs2.rx_mask,8) > 0) "TPN,"
         ENDIF
         ,3),trim(
         IF (band(ocs2.rx_mask,16) > 0) "Sliding Scale,"
         ENDIF
         ,3),
        trim(
         IF (band(ocs2.rx_mask,32) > 0) "Tapering Dose,"
         ENDIF
         ,3),trim(
         IF (band(ocs2.rx_mask,64) > 0) "PCA Pump,"
         ENDIF
         ,3))), logmsg = substring(1,(textlen(logmsg) - 1),logmsg), audits->list[pos].results[
      errorcnt].old_value_disp = logmsg,
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs2.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs2.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = "1", audits->list[pos].results[errorcnt].
      new_value_disp = "Diluent", audits->list[pos].results[errorcnt].status_str = fixedstr,
      fixedcnt = (fixedcnt+ 1)
      IF (fixedcnt > size(syns->list,5))
       stat = alterlist(syns->list,(fixedcnt+ 10))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs2.synonym_id, syns->list[fixedcnt].rx_mask = 1
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs.synonym_id, ocs.rx_mask
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=md.item_id
       AND mis.strength=0.0
       AND mis.strength_unit_cd=0.0)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND ocs.rx_mask != 1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, ocs.rx_mask,
      0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2("The rx mnemonic ",trim(ocs.mnemonic),
       " is a diluent within a premix and it does not have a mask of diluent"), audits->list[pos].
      results[errorcnt].old_value_id = cnvtstring(ocs.rx_mask),
      logmsg = trim(build2(trim(
         IF (band(ocs.rx_mask,1) > 0) "Diluent,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,2) > 0) "Additive,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,4) > 0) "Med,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,8) > 0) "TPN,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,16) > 0) "Sliding Scale,"
         ENDIF
         ,3),
        trim(
         IF (band(ocs.rx_mask,32) > 0) "Tapering Dose,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,64) > 0) "PCA Pump,"
         ENDIF
         ,3))), logmsg = substring(1,(textlen(logmsg) - 1),logmsg), audits->list[pos].results[
      errorcnt].old_value_disp = logmsg,
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = "1", audits->list[pos].results[errorcnt].
      new_value_disp = "Diluent", audits->list[pos].results[errorcnt].status_str = fixedstr,
      fixedcnt = (fixedcnt+ 1)
      IF (fixedcnt > size(syns->list,5))
       stat = alterlist(syns->list,(fixedcnt+ 10))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs.synonym_id, syns->list[fixedcnt].rx_mask = 1
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs.synonym_id, ocs.rx_mask
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=md.item_id
       AND mis.strength != 0.0
       AND mis.strength_unit_cd != 0.0)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND  NOT (ocs.rx_mask IN (2, 6))
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, ocs.rx_mask,
      0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2("The rx mnemonic ",trim(ocs.mnemonic),
       " is an additive within a premix and it does not have a mask of additive"), audits->list[pos].
      results[errorcnt].old_value_id = cnvtstring(ocs.rx_mask),
      logmsg = trim(build2(trim(
         IF (band(ocs.rx_mask,1) > 0) "Diluent,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,2) > 0) "Additive,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,4) > 0) "Med,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,8) > 0) "TPN,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,16) > 0) "Sliding Scale,"
         ENDIF
         ,3),
        trim(
         IF (band(ocs.rx_mask,32) > 0) "Tapering Dose,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,64) > 0) "PCA Pump,"
         ENDIF
         ,3))), logmsg = substring(1,(textlen(logmsg) - 1),logmsg), audits->list[pos].results[
      errorcnt].old_value_disp = logmsg,
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = "2", audits->list[pos].results[errorcnt].
      new_value_disp = "Additive", audits->list[pos].results[errorcnt].status_str = fixedstr,
      fixedcnt = (fixedcnt+ 1)
      IF (fixedcnt > size(syns->list,5))
       stat = alterlist(syns->list,(fixedcnt+ 10))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs.synonym_id, syns->list[fixedcnt].rx_mask = 2
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs.synonym_id, ocs.rx_mask
     FROM medication_definition md,
      med_def_flex mdf,
      order_catalog_synonym ocs,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (ocs
      WHERE ocs.item_id=md.item_id
       AND  NOT (ocs.rx_mask IN (2, 6))
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, ocs.rx_mask,
      0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2("The rx mnemonic ",trim(ocs.mnemonic),
       " is a premix and it does not have a mask of additive"), audits->list[pos].results[errorcnt].
      old_value_id = cnvtstring(ocs.rx_mask),
      logmsg = trim(build2(trim(
         IF (band(ocs.rx_mask,1) > 0) "Diluent,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,2) > 0) "Additive,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,4) > 0) "Med,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,8) > 0) "TPN,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,16) > 0) "Sliding Scale,"
         ENDIF
         ,3),
        trim(
         IF (band(ocs.rx_mask,32) > 0) "Tapering Dose,"
         ENDIF
         ,3),trim(
         IF (band(ocs.rx_mask,64) > 0) "PCA Pump,"
         ENDIF
         ,3))), logmsg = substring(1,(textlen(logmsg) - 1),logmsg), audits->list[pos].results[
      errorcnt].old_value_disp = logmsg,
      audits->list[pos].results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].
      results[errorcnt].last_updt_dt_tm = ocs.updt_dt_tm, audits->list[pos].results[errorcnt].
      last_updt_cnt = ocs.updt_cnt,
      audits->list[pos].results[errorcnt].new_value_id = "2", audits->list[pos].results[errorcnt].
      new_value_disp = "Additive", audits->list[pos].results[errorcnt].status_str = fixedstr,
      fixedcnt = (fixedcnt+ 1)
      IF (fixedcnt > size(syns->list,5))
       stat = alterlist(syns->list,(fixedcnt+ 10))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs.synonym_id, syns->list[fixedcnt].rx_mask = 2
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     SET logmsg = "All pharmacy synonyms that are active have the correct rx mask"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs
       WHERE expand(i,1,fixedcnt,ocs.synonym_id,syns->list[i].synonym_id)
       WITH nocounter, forupdate(ocs)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = value(size(syns->list,5))),
        order_catalog_synonym ocs
       SET ocs.rx_mask = syns->list[d.seq].rx_mask, ocs.updt_applctx = reqinfo->updt_applctx, ocs
        .updt_cnt = (ocs.updt_cnt+ 1),
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
        .updt_task = - (267)
       PLAN (d
        WHERE (syns->list[d.seq].synonym_id != 0.0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of synonyms that were updated to have the correct rx mask: ",
        trim(cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating rx masks. See ",logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG_SYNONYM TO SET THE RX MASK. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the synonyms in the output CSV with a fixed status that were supposed to be updated")
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
 SUBROUTINE productswithinvalididentifiers(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("PRODUCTS_INVALID_CHARS")
   DECLARE totalstr = vc WITH protect
   DECLARE itemcnt = i4 WITH protect
   DECLARE identcnt = i4 WITH protect
   SET totalstr = "Total number of identifiers with invalid characters: "
   RECORD br_request(
     1 items[*]
       2 item_id = f8
       2 identifiers[*]
         3 action_flag = i2
         3 identifier_id = f8
         3 ident_type_code_value = f8
         3 value = vc
   ) WITH protect
   RECORD br_reply(
     1 error_msg = vc
     1 items_not_saved[*]
       2 item_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
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
     mi.med_identifier_id, fixed_value = replace(replace(mi.value,char(13),""),char(10),""),
     fixed_value_key = cnvtupper(cnvtalphanum(replace(replace(mi.value_key,char(13),""),char(10),""))
      ),
     p.name_full_formatted
     FROM med_identifier mi,
      prsnl p
     PLAN (mi
      WHERE ((findstring(char(13),mi.value_key) > 0) OR (((findstring(char(10),mi.value_key) > 0) OR
      (((findstring(char(13),mi.value) > 0) OR (findstring(char(10),mi.value) > 0)) )) ))
       AND mi.active_ind=1
       AND  EXISTS (
      (SELECT
       mi.item_id
       FROM order_catalog_item_r ocir
       WHERE ocir.item_id=mi.item_id))
       AND  NOT (expand(i,1,temp_ignores->list_sz,mi.med_identifier_id,cnvtreal(temp_ignores->list[i]
        .id))))
      JOIN (p
      WHERE p.person_id=mi.updt_id)
     ORDER BY mi.item_id, fixed_value_key, mi.med_identifier_id,
      p.person_id
     HEAD REPORT
      fixedcnt = 0, itemcnt = 0
     HEAD mi.item_id
      itemcnt = (itemcnt+ 1), identcnt = 0
      IF (mod(itemcnt,10)=1)
       stat = alterlist(br_request->items,(itemcnt+ 9))
      ENDIF
      br_request->items[itemcnt].item_id = mi.item_id
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(mi.med_identifier_id), audits->
      list[pos].results[errorcnt].item = mi.value, audits->list[pos].results[errorcnt].old_value_id
       = cnvtstring(mi.med_identifier_id),
      audits->list[pos].results[errorcnt].old_value_disp = mi.value, audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = mi.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = mi.updt_cnt, audits->list[pos].results[
      errorcnt].new_value_id = fixed_value, audits->list[pos].results[errorcnt].new_value_disp =
      fixed_value,
      audits->list[pos].results[errorcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1), identcnt
       = (identcnt+ 1)
      IF (mod(identcnt,10)=1)
       stat = alterlist(br_request->items[itemcnt].identifiers,(identcnt+ 9))
      ENDIF
      br_request->items[itemcnt].identifiers[identcnt].action_flag = 2, br_request->items[itemcnt].
      identifiers[identcnt].ident_type_code_value = mi.med_identifier_type_cd, br_request->items[
      itemcnt].identifiers[identcnt].identifier_id = mi.med_identifier_id,
      br_request->items[itemcnt].identifiers[identcnt].value = fixed_value
     FOOT  mi.item_id
      IF (mod(identcnt,10) != 0)
       stat = alterlist(br_request->items[itemcnt].identifiers,identcnt)
      ENDIF
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
      IF (mod(itemcnt,10) != 0)
       stat = alterlist(br_request->items,itemcnt)
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
     SET logmsg = "All active identifiers do not have invalid characters"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      EXECUTE ams_bed_ens_pharm_identifiers
      IF ((br_reply->status_data.status="S"))
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of identifiers that were fixed: ",trim(cnvtstring(fixedcnt))
        )
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating identifiers within ams_bed_ens_pharm_identifiers. See ",
        logfilename)
       CALL addlogmsg(errorstr,
        "ERROR WITHIN AMS_BED_ENS_PHARM_IDENTIFIERS. ROLLING BACK ALL CHANGES.")
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
 SUBROUTINE inactiveproductsinactivesets(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("INACT_PRODUCTS_ACT_SETS")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of inactive products within an active set: "
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
     mis.child_item_id
     FROM med_ingred_set mis,
      med_def_flex mdf,
      med_def_flex mdf2,
      med_identifier mi,
      med_identifier mi2,
      prsnl p
     PLAN (mis
      WHERE  NOT (expand(i,1,temp_ignores->list_sz,mis.child_item_id,cnvtreal(temp_ignores->list[i].
        id))))
      JOIN (mdf
      WHERE mdf.item_id=mis.parent_item_id
       AND mdf.active_ind=1
       AND mdf.flex_type_cd=system_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd)
      JOIN (mdf2
      WHERE mdf2.item_id=mis.child_item_id
       AND mdf2.active_ind=0
       AND mdf2.flex_type_cd=system_type_cd
       AND mdf2.pharmacy_type_cd=inpatient_type_cd)
      JOIN (mi
      WHERE mi.item_id=mis.parent_item_id
       AND mi.med_identifier_type_cd=desc_type_cd
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.med_product_id=0)
      JOIN (mi2
      WHERE mi2.item_id=mis.child_item_id
       AND mi2.med_identifier_type_cd=desc_type_cd
       AND mi2.primary_ind=1
       AND mi2.med_product_id=0)
      JOIN (p
      WHERE p.person_id=mdf2.updt_id)
     ORDER BY mi2.value_key, mi.value_key
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(mis.child_item_id), audits->list[
      pos].results[errorcnt].item = build2(trim(mi2.value)," is within ",trim(mi.value)), audits->
      list[pos].results[errorcnt].old_value_id = "0",
      audits->list[pos].results[errorcnt].old_value_disp = "Inactive", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = mdf2.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = mdf2.updt_cnt, audits->list[pos].results[
      errorcnt].status_str = failurestr
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
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
     SET logmsg = "All active sets do not have any inactive products"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     CALL addlogmsg(infostr,linestr)
     SET logmsg = build2(totalstr,trim(cnvtstring(errorcnt)))
     CALL addlogmsg(failurestr,logmsg)
    ENDIF
    CALL addtrackingrow(auditname,errorcnt,totalstr)
   ELSE
    SET logmsg = "Not performing check because it has been ignored"
    CALL addlogmsg(ignoredstr,logmsg)
    SET audits->list[pos].results[1].status_str = ignoredstr
    SET audits->list[pos].results[1].item = logmsg
    CALL addtrackingrow(auditname,- (1),totalstr)
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE synonymsincorrectlinking(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_INCORRECT_LINKING")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synonyms with incorrect linking: "
   RECORD syns(
     1 list[*]
       2 synonym_id = f8
       2 item_id = f8
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
     mi.item_id, ocs.mnemonic_key_cap, ocs.synonym_id,
     ocs.rx_mask
     FROM medication_definition md,
      med_def_flex mdf,
      med_identifier mi,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      order_catalog_synonym ocs2,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=mdf.item_id)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND band(ocs.rx_mask,2) > 0)
      JOIN (ocs2
      WHERE ocs2.item_id=mis.parent_item_id
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs2.synonym_id,cnvtreal(temp_ignores->list[i].id))
      )
       AND  NOT ( EXISTS (
      (SELECT
       sir.synonym_id
       FROM synonym_item_r sir
       WHERE sir.synonym_id=ocs2.synonym_id
        AND sir.item_id=ocs.item_id))))
      JOIN (mi
      WHERE mi.item_id=ocs.item_id
       AND mi.med_identifier_type_cd=desc_type_cd
       AND mi.pharmacy_type_cd=inpatient_type_cd
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.med_product_id=0)
      JOIN (p
      WHERE p.person_id=md.updt_id)
     ORDER BY ocs2.mnemonic_key_cap, mi.value_key
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs2.synonym_id), audits->list[pos
      ].results[errorcnt].item = build2("The product ",trim(mi.value),
       " is an additive within a premix and is not linked to the premix's rx mnemonic ",trim(ocs2
        .mnemonic)), audits->list[pos].results[errorcnt].old_value_id = "",
      audits->list[pos].results[errorcnt].old_value_disp = "Not linked", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = md.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = 0, audits->list[pos].results[errorcnt].
      new_value_id = concat(trim(cnvtstring(ocs2.synonym_id)),"|",trim(cnvtstring(mi.item_id))),
      audits->list[pos].results[errorcnt].new_value_disp = "Linked",
      audits->list[pos].results[errorcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
      IF (fixedcnt > size(syns->list,5))
       stat = alterlist(syns->list,(fixedcnt+ 10))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs2.synonym_id, syns->list[fixedcnt].item_id = mi.item_id
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
      IF (mod(fixedcnt,10) != 0)
       stat = alterlist(syns->list,fixedcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     mi.value_key, mi.item_id, ocs.mnemonic
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      med_identifier mi,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=mdf.item_id)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND band(ocs.rx_mask,2) > 0
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
       AND  NOT ( EXISTS (
      (SELECT
       sir.synonym_id
       FROM synonym_item_r sir,
        order_catalog_synonym ocs2
       WHERE sir.item_id=ocs.item_id
        AND ocs2.synonym_id=sir.synonym_id
        AND ocs2.mnemonic_type_cd != syn_type_rx
        AND ocs2.active_ind=1
        AND  EXISTS (
       (SELECT
        cc.comp_id
        FROM cs_component cc,
         order_catalog_synonym ocs3,
         order_catalog oc
        WHERE cc.comp_id=ocs2.synonym_id
         AND ocs3.synonym_id=cc.comp_id
         AND ocs3.active_ind=1
         AND band(ocs3.rx_mask,2) > 0
         AND oc.catalog_cd=cc.catalog_cd
         AND oc.active_ind=1))))))
      JOIN (mi
      WHERE mi.item_id=ocs.item_id
       AND mi.med_identifier_type_cd=desc_type_cd
       AND mi.pharmacy_type_cd=inpatient_type_cd
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.med_product_id=0)
      JOIN (p
      WHERE p.person_id=md.updt_id)
     ORDER BY mi.value_key, mi.item_id, ocs.mnemonic_key_cap,
      0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2("The product ",trim(mi.value),
       " is an additive within a premix and is not linked to an additive synonym within a CPOE IV set"
       ), audits->list[pos].results[errorcnt].old_value_id = "",
      audits->list[pos].results[errorcnt].old_value_disp = "Not linked", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = md.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = 0, audits->list[pos].results[errorcnt].
      status_str = failurestr
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt)
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     mi.value_key, mi.item_id, ocs.mnemonic
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      med_identifier mi,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=mdf.item_id)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND ocs.rx_mask=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
       AND  NOT ( EXISTS (
      (SELECT
       sir.synonym_id
       FROM synonym_item_r sir,
        order_catalog_synonym ocs2
       WHERE sir.item_id=ocs.item_id
        AND ocs2.synonym_id=sir.synonym_id
        AND ocs2.mnemonic_type_cd != syn_type_rx
        AND ocs2.active_ind=1
        AND  EXISTS (
       (SELECT
        cc.comp_id
        FROM cs_component cc,
         order_catalog_synonym ocs3,
         order_catalog oc
        WHERE cc.comp_id=ocs2.synonym_id
         AND ocs3.synonym_id=cc.comp_id
         AND ocs3.active_ind=1
         AND band(ocs3.rx_mask,1) > 0
         AND oc.catalog_cd=cc.catalog_cd
         AND oc.active_ind=1))))))
      JOIN (mi
      WHERE mi.item_id=ocs.item_id
       AND mi.med_identifier_type_cd=desc_type_cd
       AND mi.pharmacy_type_cd=inpatient_type_cd
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.med_product_id=0)
      JOIN (p
      WHERE p.person_id=md.updt_id)
     ORDER BY mi.value_key, mi.item_id, ocs.mnemonic_key_cap,
      0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (errorcnt > size(audits->list[pos].results,5))
       stat = alterlist(audits->list[pos].results,(errorcnt+ 20))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2("The product ",trim(mi.value),
       " is a diluent within a premix and is not linked to a diluent synonym within a CPOE IV set"),
      audits->list[pos].results[errorcnt].old_value_id = "",
      audits->list[pos].results[errorcnt].old_value_disp = "Not linked", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = md.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = 0, audits->list[pos].results[errorcnt].
      status_str = failurestr
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt)
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     SET logmsg = "No incorrect product synonym linking found"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      INSERT  FROM (dummyt d  WITH seq = value(size(syns->list,5))),
        synonym_item_r sir
       SET sir.item_id = syns->list[d.seq].item_id, sir.synonym_id = syns->list[d.seq].synonym_id,
        sir.updt_applctx = reqinfo->updt_applctx,
        sir.updt_cnt = 0, sir.updt_dt_tm = cnvtdatetime(curdate,curtime3), sir.updt_id = reqinfo->
        updt_id,
        sir.updt_task = - (267)
       PLAN (d
        WHERE (syns->list[d.seq].synonym_id != 0.0))
        JOIN (sir)
       WITH nocounter
      ;end insert
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of product synonym links that were created: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error inserting product synonym links. See ",logfilename)
       CALL addlogmsg(errorstr,"ERROR INSERTING INTO SYNONYM_ITEM_R. ROLLING BACK ALL CHANGES.")
       CALL addlogmsg(errorstr,
        "Review the synonyms in the output CSV with a fixed status that were supposed to be updated")
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
 SUBROUTINE synonymsincorrecttitrateflag(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE fixedcnt = i4 WITH protect
   DECLARE auditname = vc WITH protect, constant("SYNONYMS_INCORRECT_TITRATE")
   DECLARE totalstr = vc WITH protect
   SET totalstr = "Total number of synoyms with incorrect titrate setting: "
   RECORD syns(
     1 list[*]
       2 synonym_id = f8
       2 titrate_ind = i2
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
     ocs.mnemonic
     FROM medication_definition md,
      med_def_flex mdf,
      order_catalog_synonym ocs,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (ocs
      WHERE ocs.item_id=md.item_id
       AND ocs.ingredient_rate_conversion_ind != 1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (mod(errorcnt,10)=1)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2(trim(ocs.mnemonic),
       " is a premix and is not marked as titrateable"), audits->list[pos].results[errorcnt].
      old_value_id = trim(cnvtstring(ocs.ingredient_rate_conversion_ind)),
      audits->list[pos].results[errorcnt].old_value_disp = "Not titrateable", audits->list[pos].
      results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = ocs.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = ocs.updt_cnt, audits->list[pos].results[
      errorcnt].new_value_id = "1", audits->list[pos].results[errorcnt].new_value_disp =
      "Titrateable",
      audits->list[pos].results[errorcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
      IF (mod(fixedcnt,10)=1)
       stat = alterlist(syns->list,(fixedcnt+ 9))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs.synonym_id, syns->list[fixedcnt].titrate_ind = 1
     FOOT REPORT
      IF (mod(errorcnt,10) != 0)
       stat = alterlist(audits->list[pos].results,errorcnt)
      ENDIF
      IF (mod(fixedcnt,10) != 0)
       stat = alterlist(syns->list,fixedcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs.mnemonic
     FROM medication_definition md,
      med_def_flex mdf,
      med_ingred_set mis,
      order_catalog_synonym ocs,
      prsnl p
     PLAN (md
      WHERE md.premix_ind=1)
      JOIN (mdf
      WHERE mdf.item_id=md.item_id
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.active_status_cd=active_status_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mis
      WHERE mis.parent_item_id=mdf.item_id)
      JOIN (ocs
      WHERE ocs.item_id=mis.child_item_id
       AND ocs.active_ind=1
       AND band(ocs.rx_mask,1) > 0
       AND ocs.ingredient_rate_conversion_ind=1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs.synonym_id,cnvtreal(temp_ignores->list[i].id)))
      )
      JOIN (p
      WHERE p.person_id=ocs.updt_id)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (size(audits->list[pos].results,5) < errorcnt)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs.synonym_id), audits->list[pos]
      .results[errorcnt].item = build2(trim(ocs.mnemonic),
       " is a diluent within a premix and is incorrectly marked as titrateable"), audits->list[pos].
      results[errorcnt].old_value_id = trim(cnvtstring(ocs.ingredient_rate_conversion_ind)),
      audits->list[pos].results[errorcnt].old_value_disp = "Titrateable", audits->list[pos].results[
      errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = ocs.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = ocs.updt_cnt, audits->list[pos].results[
      errorcnt].new_value_id = "0", audits->list[pos].results[errorcnt].new_value_disp =
      "Not titrateable",
      audits->list[pos].results[errorcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
      IF (size(syns->list,5) < fixedcnt)
       stat = alterlist(syns->list,(fixedcnt+ 9))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs.synonym_id, syns->list[fixedcnt].titrate_ind = 0
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ocs2.mnemonic
     FROM order_catalog_synonym ocs,
      synonym_item_r sir,
      order_catalog_synonym ocs2,
      med_dispense md,
      prsnl p
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.active_ind=1
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
       AND ocs.ingredient_rate_conversion_ind=1)
      JOIN (sir
      WHERE sir.synonym_id=ocs.synonym_id)
      JOIN (ocs2
      WHERE ocs2.item_id=sir.item_id
       AND ocs2.mnemonic_type_cd=syn_type_rx
       AND ocs2.ingredient_rate_conversion_ind != 1
       AND  NOT (expand(i,1,temp_ignores->list_sz,ocs2.synonym_id,cnvtreal(temp_ignores->list[i].id))
      ))
      JOIN (md
      WHERE md.item_id=ocs2.item_id
       AND md.continuous_filter_ind=1)
      JOIN (p
      WHERE p.person_id=ocs2.updt_id)
     ORDER BY ocs2.mnemonic_key_cap, ocs2.synonym_id, 0
     DETAIL
      errorcnt = (errorcnt+ 1)
      IF (size(audits->list[pos].results,5) < errorcnt)
       stat = alterlist(audits->list[pos].results,(errorcnt+ 9))
      ENDIF
      audits->list[pos].results[errorcnt].primary_key = cnvtstring(ocs2.synonym_id), audits->list[pos
      ].results[errorcnt].item = build2(trim(ocs2.mnemonic),"'s product is linked to ",trim(ocs
        .mnemonic)," which is titrateable but ",trim(ocs2.mnemonic),
       " is not titrateable"), audits->list[pos].results[errorcnt].old_value_id = trim(cnvtstring(
        ocs2.ingredient_rate_conversion_ind)),
      audits->list[pos].results[errorcnt].old_value_disp = "Not titrateable", audits->list[pos].
      results[errorcnt].last_updt_prsnl = p.name_full_formatted, audits->list[pos].results[errorcnt].
      last_updt_dt_tm = ocs2.updt_dt_tm,
      audits->list[pos].results[errorcnt].last_updt_cnt = ocs2.updt_cnt, audits->list[pos].results[
      errorcnt].new_value_id = "1", audits->list[pos].results[errorcnt].new_value_disp =
      "Titrateable",
      audits->list[pos].results[errorcnt].status_str = fixedstr, fixedcnt = (fixedcnt+ 1)
      IF (size(syns->list,5) < fixedcnt)
       stat = alterlist(syns->list,(fixedcnt+ 9))
      ENDIF
      syns->list[fixedcnt].synonym_id = ocs2.synonym_id, syns->list[fixedcnt].titrate_ind = 1
     FOOT REPORT
      stat = alterlist(audits->list[pos].results,errorcnt), stat = alterlist(syns->list,fixedcnt)
     WITH nocounter
    ;end select
    IF (error(cclerrorstr,0) > 0)
     CALL addlogmsg(errorstr,cclerrorstr)
     SET status = "F"
     SET statusstr = build2("Error in audit ",trim(cnvtstring(pos)),". See ",logfilename)
     GO TO exit_script
    ENDIF
    IF (errorcnt=0)
     SET logmsg = "All pharmacy synonyms have correct titrate setting"
     CALL addlogmsg(successstr,logmsg)
     SET audits->list[pos].results[1].status_str = successstr
     SET audits->list[pos].results[1].item = logmsg
    ELSE
     IF (autofixind=1
      AND opsind=1
      AND fixedcnt > 0)
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs
       PLAN (ocs
        WHERE expand(i,1,size(syns->list,5),ocs.synonym_id,syns->list[i].synonym_id))
       WITH nocounter, forupdate(ocs)
      ;end select
      UPDATE  FROM (dummyt d  WITH seq = value(size(syns->list,5))),
        order_catalog_synonym ocs
       SET ocs.ingredient_rate_conversion_ind = syns->list[d.seq].titrate_ind, ocs.updt_applctx =
        reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1),
        ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
        .updt_task = - (267)
       PLAN (d
        WHERE (syns->list[d.seq].synonym_id != 0.0))
        JOIN (ocs
        WHERE (ocs.synonym_id=syns->list[d.seq].synonym_id))
       WITH nocounter
      ;end update
      IF (curqual=fixedcnt
       AND error(cclerrorstr,0)=0)
       SET totalfixedcnt = (totalfixedcnt+ fixedcnt)
       SET audits->list[pos].fixed_cnt = fixedcnt
       CALL addlogmsg(infostr,linestr)
       SET logmsg = build2("Total number of synonyms that had their titrate setting updated: ",trim(
         cnvtstring(fixedcnt)))
       CALL addlogmsg(successstr,logmsg)
      ELSE
       SET status = "F"
       SET statusstr = build2("Error updating ORDER_CATALOG_SYNONYM to set titrate indicator. See ",
        logfilename)
       CALL addlogmsg(errorstr,
        "ERROR UPDATING ORDER_CATALOG_SYNONYM TO SET THE TITRATE INDICATOR. ROLLING BACK ALL CHANGES."
        )
       CALL addlogmsg(errorstr,
        "Review the synonyms in the output CSV with a fixed status that were supposed to be updated")
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
 SUBROUTINE loadtestcatvalues(null)
   DECLARE retval = i2 WITH protect, noconstant(test_cat_failed)
   DECLARE reviewactcnt = i4 WITH protect
   SELECT INTO "nl:"
    FROM order_catalog oc,
     order_catalog_review ocr
    PLAN (oc
     WHERE oc.primary_mnemonic=test_catalog_name
      AND oc.catalog_type_cd=pharm_cat_cd)
     JOIN (ocr
     WHERE oc.catalog_cd=ocr.catalog_cd
      AND ocr.action_type_cd != 0)
    ORDER BY oc.catalog_cd, ocr.action_type_cd
    HEAD oc.catalog_cd
     reviewactcnt = 0, cat_test_values->test_catalog_cd = oc.catalog_cd, cat_test_values->
     primary_mnemonic = oc.primary_mnemonic,
     cat_test_values->description = oc.description, cat_test_values->auto_cancel_ind = oc
     .auto_cancel_ind, cat_test_values->bill_only_ind = oc.bill_only_ind,
     cat_test_values->complete_upon_order_ind = oc.complete_upon_order_ind, cat_test_values->
     consent_form_format_cd = oc.consent_form_format_cd, cat_test_values->consent_form_ind = oc
     .consent_form_ind,
     cat_test_values->consent_form_routing_cd = oc.consent_form_routing_cd, cat_test_values->
     cont_order_method_flag = 2, cat_test_values->disable_order_comment_ind = oc
     .disable_order_comment_ind,
     cat_test_values->dc_display_days = oc.dc_display_days, cat_test_values->dc_interaction_days = oc
     .dc_interaction_days, cat_test_values->discern_auto_verify_flag = oc.discern_auto_verify_flag,
     cat_test_values->ic_auto_verify_flag = oc.ic_auto_verify_flag, cat_test_values->
     orderable_type_flag = 1, cat_test_values->print_req_ind = oc.print_req_ind,
     cat_test_values->requisition_format_cd = oc.requisition_format_cd, cat_test_values->
     requisition_routing_cd = oc.requisition_routing_cd, cat_test_values->stop_duration = oc
     .stop_duration,
     cat_test_values->stop_duration_unit_cd = oc.stop_duration_unit_cd, cat_test_values->stop_type_cd
      = oc.stop_type_cd
    DETAIL
     retval = test_cat_loaded, reviewactcnt = (reviewactcnt+ 1)
     IF (mod(reviewactcnt,20)=1)
      stat = alterlist(cat_test_values->review_settings,(reviewactcnt+ 19))
     ENDIF
     cat_test_values->review_settings[reviewactcnt].action_type_cd = ocr.action_type_cd,
     cat_test_values->review_settings[reviewactcnt].action_type_disp = uar_get_code_display(ocr
      .action_type_cd), cat_test_values->review_settings[reviewactcnt].cosign_required_ind = ocr
     .cosign_required_ind,
     cat_test_values->review_settings[reviewactcnt].doctor_cosign_flag = ocr.doctor_cosign_flag,
     cat_test_values->review_settings[reviewactcnt].nurse_review_flag = ocr.nurse_review_flag,
     cat_test_values->review_settings[reviewactcnt].review_required_ind = ocr.review_required_ind,
     cat_test_values->review_settings[reviewactcnt].rx_verify_flag = ocr.rx_verify_flag
    FOOT  oc.catalog_cd
     stat = alterlist(cat_test_values->review_settings,reviewactcnt)
    WITH nocounter
   ;end select
   IF (retval=test_cat_loaded)
    SET retval = loadtesttaskvalues(cat_test_values->test_catalog_cd)
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE loadtesttaskvalues(testcatalogcd)
   DECLARE retval = i2 WITH protect, noconstant(test_task_failed)
   DECLARE tasklinkcnt = i4 WITH protect
   DECLARE poschartcnt = i4 WITH protect
   SET tasklinkcnt = 0
   SELECT INTO "nl:"
    ot.reference_task_id, position = uar_get_code_display(otp.position_cd)
    FROM order_task_xref otx,
     order_task ot,
     order_task_position_xref otp
    PLAN (otx
     WHERE otx.catalog_cd=testcatalogcd)
     JOIN (ot
     WHERE ot.reference_task_id=otx.reference_task_id)
     JOIN (otp
     WHERE otp.reference_task_id=outerjoin(ot.reference_task_id))
    ORDER BY ot.reference_task_id, position
    HEAD REPORT
     tasklinkcnt = 0
    HEAD ot.reference_task_id
     poschartcnt = 0, tasklinkcnt = (tasklinkcnt+ 1), task_test_values->reference_task_id = ot
     .reference_task_id,
     task_test_values->task_description = ot.task_description, task_test_values->allpositionchart_ind
      = ot.allpositionchart_ind, task_test_values->capture_bill_info_ind = ot.capture_bill_info_ind,
     task_test_values->grace_period_mins = ot.grace_period_mins, task_test_values->ignore_req_ind =
     ot.ignore_req_ind, task_test_values->overdue_min = ot.overdue_min,
     task_test_values->overdue_units = ot.overdue_units, task_test_values->quick_chart_done_ind = ot
     .quick_chart_done_ind, task_test_values->quick_chart_ind = ot.quick_chart_ind,
     task_test_values->reschedule_time = ot.reschedule_time, task_test_values->retain_time = ot
     .retain_time, task_test_values->retain_units = ot.retain_units,
     task_test_values->task_activity_cd = ot.task_activity_cd, task_test_values->task_type_cd = ot
     .task_type_cd
    DETAIL
     poschartcnt = (poschartcnt+ 1)
     IF (poschartcnt > size(task_test_values->position_chart_list,5))
      stat = alterlist(task_test_values->position_chart_list,(poschartcnt+ 20))
     ENDIF
     task_test_values->position_chart_list[poschartcnt].position_cd = otp.position_cd,
     task_test_values->position_chart_list[poschartcnt].position_name = uar_get_code_display(otp
      .position_cd)
    FOOT  ot.reference_task_id
     stat = alterlist(task_test_values->position_chart_list,poschartcnt)
    WITH nocounter
   ;end select
   IF ((((task_test_values->reference_task_id=0)) OR (tasklinkcnt != 1)) )
    SET retval = test_task_failed
   ELSE
    SET retval = test_cat_loaded
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE loadpreviousresults(null)
   SET audits->header_name = "Pharmacy Health Check"
   SET audits->report_sentence = build2(
    "The AMS Pharmacy Health Check is a collection of audits that identify",
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
     SET audits->list[i].category_alias = ignores->list[i].category_alias
     SET audits->list[i].audit_num = ignores->list[i].audit_num
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
     "Sending log file to AMS mailbox failed. Contact AMS Pharmacy team to investigate."
     SET reply->status_data.status = "F"
     SET reply->ops_event = statusstr
     ROLLBACK
    ENDIF
   ENDIF
   IF (incrementerrorcnt(script_name,totalerrorcnt,
    "Total number of errors found by ops job since installation")=0)
    SET statusstr = "Incrementing error count failed. Contact AMS Pharmacy team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
    ROLLBACK
   ELSE
    COMMIT
    CALL updatefixedtracking(null)
   ENDIF
  ELSE
   ROLLBACK
  ENDIF
  IF (opsind=1
   AND emailind=1
   AND ((totalerrorcnt > 0) OR (emailsuccessind=1)) )
   SET vcsubject = concat(vcsubject," Errors found: ",trim(cnvtstring(totalerrorcnt)))
   IF (emailfile(trim(request->output_dist),cfrom,vcsubject,body_str,outputcsvname)=0)
    SET statusstr = "Emailing output CSV file failed. Contact AMS Pharmacy team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
   ELSE
    SET vcsubject = build2("AMS Pharmacy Health Check Summary Report ",clientstr,": ",curdomain)
    IF (emailfile(trim(request->output_dist),cfrom,vcsubject,body_str,summaryrptname)=0)
     SET statusstr = "Emailing summary report failed. Contact AMS Pharmacy team to investigate."
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
   IF (emailfile(trim(request->output_dist),cfrom,vcsubject,body_str,logfilename)=0)
    SET statusstr = "Sending email failed. Contact AMS Pharmacy team to investigate."
    SET reply->status_data.status = "F"
    SET reply->ops_event = statusstr
   ENDIF
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusstr
 ENDIF
 SET last_mod = "022"
END GO
