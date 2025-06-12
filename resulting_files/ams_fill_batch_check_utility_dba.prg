CREATE PROGRAM ams_fill_batch_check_utility:dba
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
 DECLARE displayaudits(null) = null WITH protect
 DECLARE displaybatcheswithoutopsjobs(null) = null WITH protect
 DECLARE promptfortestbatch(null) = null WITH protect
 DECLARE testbatchschedule(batchcd=f8,rundttm=dq8) = i2 WITH protect
 DECLARE addtempignorebatch(batchcd=f8,ignoretime=dq8) = i2 WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                        AMS Fill Batch Check Utility                        ")
 DECLARE detail_line = c75 WITH protect, constant(
  "     Audit fill batch schedules and allows user to set batches to ignore    ")
 DECLARE script_name = c20 WITH protect, constant("AMS_FILL_BATCH_CHECK")
 DECLARE batch_off_sched = i2 WITH protect, constant(0)
 DECLARE batch_on_sched = i2 WITH protect, constant(1)
 DECLARE batch_not_in_sync = i2 WITH protect, constant(2)
 DECLARE batch_hist_incomplete = i2 WITH protect, constant(3)
 DECLARE batch_next_time_incorrect = i2 WITH protect, constant(4)
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE calcnextfromdttm = dq8 WITH protect
 DECLARE calcnexttodttm = dq8 WITH protect
 DECLARE actualnextfromdttm = dq8 WITH protect
 DECLARE actualnexttodttm = dq8 WITH protect
 SET logfilename = concat("ams_fill_batch_check_utility_",cnvtlower(format(cnvtdatetime(curdate,
     curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_fill_batch_check_utility")
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 IF (loadprefs(script_name)=0)
  CALL clearscreen(null)
  CALL setprefs(script_name,1)
  CALL clearscreen(null)
  CALL text(quesrow,soffcol,"Choose an option:")
 ENDIF
 CALL text((soffrow+ 4),(soffcol+ 26),"1 Run Audit")
 CALL text((soffrow+ 5),(soffcol+ 26),"2 Temporarily Ignore Batch")
 CALL text((soffrow+ 6),(soffcol+ 26),"3 View Batches Running Manually")
 CALL text((soffrow+ 7),(soffcol+ 26),"4 View/Modify Ignored Batches")
 CALL text((soffrow+ 8),(soffcol+ 26),"5 View/Modify Preferences")
 CALL text((soffrow+ 9),(soffcol+ 26),"6 Exit")
 CALL text((soffrow+ 16),(soffcol+ 42),build2("Errors found since install: ",trim(cnvtstring(
     geterrorcnt(script_name)))))
 CALL accept(quesrow,(soffcol+ 18),"9;",6
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6))
 CASE (curaccept)
  OF 1:
   CALL clear(1,1)
   EXECUTE ams_fill_batch_check
  OF 2:
   CALL promptfortestbatch(null)
  OF 3:
   CALL displaybatcheswithoutopsjobs(null)
   GO TO main_menu
  OF 4:
   CALL displayaudits(null)
  OF 5:
   CALL displayprefs(script_name)
  OF 6:
   GO TO exit_script
 ENDCASE
 SUBROUTINE displayaudits(null)
   CALL clearscreen(null)
   CALL loadignorevalues(script_name)
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND (cnt < ignores->list_sz))
     SET cnt = (cnt+ 1)
     SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ignores->list[cnt].description)," ",
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
   CALL text(soffrow,soffcol,"Choose an audit to view ignored batches")
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
        SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ignores->list[cnt].description),
         " ",
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
        SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ignores->list[cnt].description),
         " ",
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
 SUBROUTINE displaybatcheswithoutopsjobs(null)
   DECLARE batchselectstr = vc WITH constant("PHA_CALL_FILLSRVR*"), protect
   DECLARE ilookbehinddays = i2 WITH constant(10), protect
   SELECT DISTINCT
    fill_batch = substring(1,50,cv.display), cv.code_value
    FROM code_value cv,
     fill_batch_hx fbh
    PLAN (cv
     WHERE cv.code_set=4035
      AND cv.active_ind=1
      AND  NOT (cnvtstring(cv.code_value) IN (
     (SELECT
      substring(19,(textlen(ojs.batch_selection) - 20),ojs.batch_selection)
      FROM ops_job_step ojs
      WHERE cnvtupper(ojs.batch_selection)=patstring(batchselectstr)))))
     JOIN (fbh
     WHERE fbh.fill_batch_cd=cv.code_value
      AND fbh.updt_dt_tm > cnvtdatetime((curdate - ilookbehinddays),0))
    ORDER BY cv.display_key
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE promptfortestbatch(null)
   DECLARE batchdisp = vc WITH protect
   DECLARE batchcd = f8 WITH protect
   DECLARE nextrundttm = dq8 WITH protect
   CALL clearscreen(null)
   WHILE (batchcd=0)
     CALL text(soffrow,soffcol,"Enter batch to temporarily ignore:")
     SET help = promptmsg("Batch display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      display = substring(1,40,cv.display)
      FROM code_value cv
      WHERE cv.code_set=4035
       AND cv.display_key >= cnvtupper(curaccept)
       AND cv.active_ind=1
      ORDER BY cv.display_key
     ;end select
     CALL accept(soffrow,(soffcol+ 35),"P(40);CP")
     SET batchdisp = trim(cnvtalphanum(cnvtupper(curaccept)))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_set=4035
        AND cv.display_key=batchdisp
        AND cv.active_ind=1
       DETAIL
        batchcd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL text((soffrow+ 1),soffcol,"No fill batch found! Enter valid fill batch display.")
      ELSE
       CALL clear((soffrow+ 1),soffcol,numcols)
       CALL text((soffrow+ 1),soffcol,"Enter date/time to ignore batch until:")
       CALL accept((soffrow+ 1),(soffcol+ 39),"NNDCCCDNNNNDNNDNN;C",format(curdate,
         "DD-MMM-YYYY HH:MM;;D")
        WHERE cnvtdatetime(curaccept) > cnvtdatetime(curdate,curtime3))
       SET nextrundttm = cnvtdatetime(curaccept)
       SET stat = addtempignorebatch(batchcd,nextrundttm)
       IF (stat=1)
        CALL text((soffrow+ 2),soffcol,build2("Batch successfully ignored until: ",format(nextrundttm,
           "DD-MMM-YYYY HH:MM;;D")))
        CALL text(quesrow,soffcol,"Commit?:")
        CALL accept(quesrow,(soffcol+ 8),"A;CU"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         COMMIT
        ELSE
         ROLLBACK
        ENDIF
       ELSE
        CALL text((soffrow+ 1),soffcol,"Error ignoring batch!")
        ROLLBACK
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE testbatchschedule(batchcd,rundttm)
   DECLARE j = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE runpos = i4 WITH protect
   DECLARE runcnt = f8 WITH protect
   DECLARE lastfromdttime = dq8 WITH protect
   DECLARE lasttodttime = dq8 WITH protect
   DECLARE num_days = f8 WITH protect, constant((5.0/ 1440.0))
   RECORD batchtest(
     1 batchcd = f8
     1 cycle_time_in_days = f8
     1 min_fill_hx_id = f8
     1 max_fill_hx_id = f8
     1 runs[*]
       2 cnt = f8
       2 from_time = i4
       2 to_time = i4
       2 prev_to_dt_tm = dq8
       2 prev_from_dt_tm = dq8
       2 dt_tm_diff = f8
   ) WITH protect
   RECORD cascadebatches(
     1 list[*]
       2 fill_batch_cd = f8
       2 cycle_time_in_days = f8
       2 num_of_runs = i4
       2 num_of_cycles = i4
       2 temp_run_cnt = i4
   ) WITH protect
   SET stat = initrec(batchtest)
   SET batchtest->batchcd = batchcd
   SET calcnextfromdttm = 0
   SET calcnexttodttm = 0
   SET actualnextfromdttm = 0
   SET actualnexttodttm = 0
   SELECT INTO "nl:"
    f.fill_batch_cd, f.start_dt_tm, f.from_dt_tm,
    f.to_dt_tm, min_id = min(f.fill_hx_id), max_id = max(f.fill_hx_id)
    FROM fill_batch_hx f
    WHERE f.fill_batch_cd=batchcd
     AND f.start_dt_tm BETWEEN cnvtdatetime((curdate - 15),0) AND cnvtdatetime((curdate - 1),235959)
    GROUP BY f.fill_hx_id, f.fill_batch_cd, f.start_dt_tm,
     f.from_dt_tm, f.to_dt_tm
    ORDER BY f.start_dt_tm
    HEAD REPORT
     runcnt = 0
    DETAIL
     IF (cnvttime(rundttm) > cnvttime(datetimeadd(f.start_dt_tm,- (num_days)))
      AND cnvttime(rundttm) < cnvttime(datetimeadd(f.start_dt_tm,num_days)))
      runpos = locateval(i,1,size(batchtest->runs,5),cnvttime(f.from_dt_tm),batchtest->runs[i].
       from_time,
       cnvttime(f.to_dt_tm),batchtest->runs[i].to_time), runcnt = (runcnt+ 1)
      IF (runpos=0)
       runpos = (size(batchtest->runs,5)+ 1), stat = alterlist(batchtest->runs,runpos), batchtest->
       runs[runpos].cnt = (batchtest->runs[runpos].cnt+ 1),
       batchtest->runs[runpos].from_time = cnvttime(f.from_dt_tm), batchtest->runs[runpos].to_time =
       cnvttime(f.to_dt_tm), batchtest->runs[runpos].prev_to_dt_tm = f.to_dt_tm,
       batchtest->runs[runpos].prev_from_dt_tm = f.from_dt_tm, batchtest->min_fill_hx_id = min_id,
       batchtest->max_fill_hx_id = max_id
       CASE (f.cycle_unit_flag)
        OF 1:
         batchtest->cycle_time_in_days = (cnvtreal(f.cycle_time)/ 1440.0)
        OF 2:
         batchtest->cycle_time_in_days = (cnvtreal(f.cycle_time)/ 24.0)
        OF 3:
         batchtest->cycle_time_in_days = (cnvtreal(f.cycle_time)/ 1.0)
        OF 4:
         batchtest->cycle_time_in_days = (cnvtreal(f.cycle_time)/ 0.1428571429)
        OF 5:
         batchtest->cycle_time_in_days = (cnvtreal(f.cycle_time)/ 0.033333333)
       ENDCASE
      ELSE
       batchtest->runs[runpos].cnt = (batchtest->runs[runpos].cnt+ 1), batchtest->runs[runpos].
       dt_tm_diff = datetimediff(f.to_dt_tm,batchtest->runs[runpos].prev_to_dt_tm), batchtest->runs[
       runpos].prev_to_dt_tm = f.to_dt_tm,
       batchtest->runs[runpos].prev_from_dt_tm = f.from_dt_tm
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (size(batchtest->runs,5) > 0)
    FOR (i = 1 TO size(batchtest->runs,5))
      IF (((batchtest->runs[i].cnt/ runcnt) >= 0.5))
       SET calcnextfromdttm = datetimeadd(batchtest->runs[i].prev_from_dt_tm,batchtest->runs[i].
        dt_tm_diff)
       SET calcnexttodttm = datetimeadd(batchtest->runs[i].prev_to_dt_tm,batchtest->runs[i].
        dt_tm_diff)
       WHILE (calcnextfromdttm < cnvtdatetime(curdate,curtime3))
        SET calcnextfromdttm = datetimeadd(calcnextfromdttm,batchtest->runs[i].dt_tm_diff)
        SET calcnexttodttm = datetimeadd(calcnexttodttm,batchtest->runs[i].dt_tm_diff)
       ENDWHILE
      ENDIF
    ENDFOR
   ELSE
    RETURN(batch_next_time_incorrect)
   ENDIF
   IF (((calcnextfromdttm > 0) OR (calcnexttodttm > 0)) )
    SELECT DISTINCT INTO "nl:"
     fcb.fill_batch_cd, fc.from_dt_tm, fc.to_dt_tm
     FROM fill_cycle_batch fcb,
      fill_cycle fc
     PLAN (fcb
      WHERE fcb.fill_batch_cd=batchcd)
      JOIN (fc
      WHERE fc.dispense_category_cd=fcb.dispense_category_cd
       AND fc.location_cd=fcb.location_cd
       AND fc.last_operation_flag=3)
     DETAIL
      lastfromdttime = fc.from_dt_tm, lasttodttime = fc.to_dt_tm
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET actualnextfromdttm = datetimeadd(lasttodttime,(1.0/ 1440.0))
     SET actualnexttodttm = datetimeadd(actualnextfromdttm,(batchtest->cycle_time_in_days - (1.0/
      1440.0)))
     IF (actualnextfromdttm=calcnextfromdttm
      AND actualnexttodttm=calcnexttodttm)
      RETURN(batch_on_sched)
     ELSE
      SELECT DISTINCT INTO "nl:"
       fcb2.fill_batch_cd, fb.cycle_time
       FROM fill_cycle_batch fcb,
        fill_cycle_batch fcb2,
        fill_batch fb
       PLAN (fcb
        WHERE fcb.fill_batch_cd=batchcd)
        JOIN (fcb2
        WHERE fcb2.dispense_category_cd=fcb.dispense_category_cd
         AND fcb2.location_cd=fcb.location_cd
         AND fcb2.fill_batch_cd != fcb.fill_batch_cd)
        JOIN (fb
        WHERE fb.fill_batch_cd=fcb2.fill_batch_cd)
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(cascadebatches->list,cnt), cascadebatches->list[cnt].
        fill_batch_cd = fcb2.fill_batch_cd
        CASE (fb.cycle_unit_flag)
         OF 1:
          cascadebatches->list[cnt].cycle_time_in_days = (cnvtreal(fb.cycle_time)/ 1440.0)
         OF 2:
          cascadebatches->list[cnt].cycle_time_in_days = (cnvtreal(fb.cycle_time)/ 24.0)
         OF 3:
          cascadebatches->list[cnt].cycle_time_in_days = (cnvtreal(fb.cycle_time)/ 1.0)
         OF 4:
          cascadebatches->list[cnt].cycle_time_in_days = (cnvtreal(fb.cycle_time)/ 0.1428571429)
         OF 5:
          cascadebatches->list[cnt].cycle_time_in_days = (cnvtreal(fb.cycle_time)/ 0.033333333)
        ENDCASE
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SELECT INTO "nl:"
        f.fill_batch_cd
        FROM fill_batch_hx f
        WHERE ((f.fill_batch_cd=batchcd) OR (expand(i,1,size(cascadebatches->list,5),f.fill_batch_cd,
         cascadebatches->list[i].fill_batch_cd)))
         AND f.start_dt_tm BETWEEN cnvtdatetime((curdate - 15),0) AND cnvtdatetime((curdate - 1),
         235959)
         AND (f.fill_hx_id >= batchtest->min_fill_hx_id)
         AND (f.fill_hx_id <= batchtest->max_fill_hx_id)
        ORDER BY f.start_dt_tm
        HEAD REPORT
         cnt = 0
        DETAIL
         IF (f.fill_batch_cd=batchcd)
          cnt = (cnt+ 1)
          IF (cnt > 1)
           FOR (i = 1 TO size(cascadebatches->list,5))
             IF ((cascadebatches->list[i].num_of_runs=0))
              cascadebatches->list[i].num_of_runs = cascadebatches->list[i].temp_run_cnt
             ELSEIF ((cascadebatches->list[i].num_of_runs != cascadebatches->list[i].temp_run_cnt))
              cascadebatches->list[i].num_of_runs = round((((cascadebatches->list[i].num_of_cycles *
               cascadebatches->list[i].num_of_runs)+ cascadebatches->list[i].temp_run_cnt)/ (
               cascadebatches->list[i].num_of_cycles+ 1)),0)
             ENDIF
             cascadebatches->list[i].num_of_cycles = (cascadebatches->list[i].num_of_cycles+ 1),
             cascadebatches->list[i].temp_run_cnt = 0
           ENDFOR
          ENDIF
         ELSEIF (cnt > 0)
          batchpos = locateval(i,1,size(cascadebatches->list,5),f.fill_batch_cd,cascadebatches->list[
           i].fill_batch_cd), cascadebatches->list[batchpos].temp_run_cnt = (cascadebatches->list[
          batchpos].temp_run_cnt+ 1)
         ENDIF
        WITH nocounter
       ;end select
       FOR (i = 1 TO size(cascadebatches->list,5))
         FOR (j = 1 TO cascadebatches->list[i].num_of_runs)
          SET actualnextfromdttm = datetimeadd(actualnextfromdttm,cascadebatches->list[i].
           cycle_time_in_days)
          SET actualnexttodttm = datetimeadd(actualnexttodttm,cascadebatches->list[i].
           cycle_time_in_days)
         ENDFOR
       ENDFOR
       IF (actualnextfromdttm=calcnextfromdttm
        AND actualnexttodttm=calcnexttodttm)
        RETURN(batch_on_sched)
       ELSE
        RETURN(batch_off_sched)
       ENDIF
      ELSE
       RETURN(batch_off_sched)
      ENDIF
     ENDIF
    ELSE
     RETURN(batch_not_in_sync)
    ENDIF
   ELSE
    RETURN(batch_hist_incomplete)
   ENDIF
 END ;Subroutine
 SUBROUTINE addtempignorebatch(batchcd,ignoretime)
   DECLARE name_value_id = f8 WITH protect
   SELECT INTO "nl:"
    y = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_id = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (error(statusstr,0) > 0)
    RETURN(0)
   ENDIF
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = name_value_id, bnv.br_nv_key1 = "AMS_FILL_BATCH_CHECK|AHEAD_BATCHES",
     bnv.br_name = "FILL_BATCH_CD",
     bnv.br_value = trim(cnvtstring(batchcd)), bnv.default_selected_ind = 1, bnv.updt_applctx =
     reqinfo->updt_applctx,
     bnv.updt_dt_tm = cnvtdatetime(ignoretime), bnv.updt_id = reqinfo->updt_id, bnv.updt_task = - (
     267),
     bnv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (((error(statusstr,0) > 0) OR (curqual != 1)) )
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    y = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_id = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (error(statusstr,0) > 0)
    RETURN(0)
   ENDIF
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = name_value_id, bnv.br_nv_key1 = "AMS_FILL_BATCH_CHECK|BEHIND_BATCHES",
     bnv.br_name = "FILL_BATCH_CD",
     bnv.br_value = trim(cnvtstring(batchcd)), bnv.default_selected_ind = 1, bnv.updt_applctx =
     reqinfo->updt_applctx,
     bnv.updt_dt_tm = cnvtdatetime(ignoretime), bnv.updt_id = reqinfo->updt_id, bnv.updt_task = - (
     267),
     bnv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (((error(statusstr,0) > 0) OR (curqual != 1)) )
    RETURN(0)
   ENDIF
   RETURN(1)
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
 SET last_mod = "005"
END GO
