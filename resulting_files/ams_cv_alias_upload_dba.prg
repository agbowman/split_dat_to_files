CREATE PROGRAM ams_cv_alias_upload:dba
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
 DECLARE importmode(null) = null WITH protect
 DECLARE exportmode(null) = null WITH protect
 DECLARE deletemode(null) = null WITH protect
 DECLARE readinputfile(null) = null WITH protect
 DECLARE loadrequest(null) = null WITH protect
 DECLARE updateinbound(null) = null WITH protect
 DECLARE updateoutbound(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                     AMS Code Value Alias Upload Utility                    ")
 DECLARE detail_line = c75 WITH protect, constant(
  "                Updates code value aliases from a spreadsheet               ")
 DECLARE script_name = c19 WITH protect, constant("AMS_CV_ALIAS_UPLOAD")
 DECLARE alias_type_inbound = vc WITH protect, constant("Inbound")
 DECLARE alias_type_outbound = vc WITH protect, constant("Outbound")
 DECLARE action_update = vc WITH protect, constant("MODIFY")
 DECLARE action_insert = vc WITH protect, constant("ADD")
 DECLARE action_delete = vc WITH protect, constant("DELETE")
 DECLARE indatacount = i4 WITH protect
 DECLARE inaliascount = i4 WITH protect
 DECLARE totalcodevaluecount = i4 WITH protect
 DECLARE outdatacount = i4 WITH protect
 DECLARE outaliascount = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE prompt1 = vc WITH protect
 DECLARE questionanotheraudit = vc WITH protect
 DECLARE questioncommitchanges = vc WITH protect
 DECLARE questionscriptfailure = vc WITH protect
 DECLARE codesettoexport = i4 WITH protect
 DECLARE iscodesetdefined = i2 WITH protect
 DECLARE codesetdisplay = vc WITH protect
 DECLARE codesetvalue = f8 WITH protect
 DECLARE indatacount = i4 WITH protect
 DECLARE outdatacount = i4 WITH protect
 DECLARE loopcnt = i4 WITH protect
 DECLARE logfilename = vc WITH protect
 DECLARE incrementcount = i4 WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE amsemail = vc WITH protect
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE bodystr = vc WITH protect
 DECLARE filename = vc WITH protect
 DECLARE emailprompt = vc WITH protect
 DECLARE emailfileprompt = vc WITH protect
 SET logfilename = concat("ams_cv_alias_upload",cnvtlower(format(cnvtdatetime(curdate,curtime3),
    "dd_mmm_yyyy_hh_mm;;q")),".log")
 RECORD cv_alias(
   1 list[*]
     2 code_set = i4
     2 code_value = f8
     2 display = vc
     2 type = vc
     2 contributor_source_cd = f8
     2 alias = vc
     2 meaning = vc
     2 primary_ind = i2
 ) WITH protect
 RECORD import_in_cv_alias(
   1 list[*]
     2 action_type_flag = i2
     2 alias = vc
     2 old_alias = vc
     2 alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
     2 contributor_source_disp = vc
     2 old_contributor_source_cd = f8
     2 old_contributor_source_disp = vc
     2 primary_ind = i2
     2 old_alias_type_meaning = vc
 ) WITH protect
 RECORD request_in_cv_alias(
   1 inbnd_alias_list[*]
     2 action_type_flag = i2
     2 alias = vc
     2 old_alias = vc
     2 alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
     2 old_contributor_source_cd = f8
     2 primary_ind = i2
     2 old_alias_type_meaning = vc
 ) WITH protect
 RECORD import_out_cv_alias(
   1 list[*]
     2 action_type_flag = i2
     2 alias = vc
     2 old_alias = vc
     2 alias_type_meaning = vc
     2 old_alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
     2 contributor_source_disp = vc
     2 old_contributor_source_cd = f8
     2 old_contributor_source_disp = vc
 ) WITH protect
 RECORD request_out_cv_alias(
   1 outbnd_alias_list[*]
     2 action_type_flag = i2
     2 alias = vc
     2 alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
     2 old_contributor_source_cd = f8
     2 old_alias_type_meaning = vc
 ) WITH protect
 RECORD inbnd_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD outbnd_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 CALL validatelogin(null)
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_cv_alias_upload")
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 6),(soffcol+ 25),"1 Export code value aliases")
 CALL text((soffrow+ 7),(soffcol+ 25),"2 Import code value aliases")
 CALL text((soffrow+ 8),(soffcol+ 25),"3 Exit")
 CALL accept(quesrow,(soffcol+ 18),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL exportmode(null)
  OF 2:
   CALL importmode(null)
  OF 3:
   GO TO exit_script
 ENDCASE
 SUBROUTINE exportmode(null)
   SET cnt = 0
   SET indatacount = 0
   SET inaliascount = 0
   SET outdatacount = 0
   SET outaliascount = 0
   SET totalcodevaluecount = 0
   CALL clearscreen(null)
   SET iscodesetdefined = 0
   WHILE (iscodesetdefined=0)
     CALL text(soffrow,soffcol,"Which code set would you like to audit? (Shift+F5 to search)")
     SET prompt1 = "Code set:"
     CALL text((soffrow+ 1),soffcol,prompt1)
     SET help = promptmsg("Code set display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      code_set = cvs.code_set, name = cvs.display
      FROM code_value_set cvs
      WHERE cnvtupper(cvs.display) >= cnvtupper(curaccept)
       AND cvs.code_set != 0
      ORDER BY cvs.display_key
      WITH nocounter
     ;end select
     CALL accept((soffrow+ 1),(soffcol+ (textlen(prompt1)+ 1)),"9(12);CP"
      WHERE textlen(trim(curaccept)) > 0)
     SET codesettoexport = cnvtint(curaccept)
     SET help = off
     SELECT INTO "nl:"
      cvs.code_set
      FROM code_value_set cvs
      WHERE cvs.code_set != 0
       AND cvs.code_set=cnvtint(curaccept)
      DETAIL
       codesetdisplay = cvs.display, codesetvalue = cvs.code_set
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL clear((soffrow+ 2),soffcol,numcols)
      CALL text((soffrow+ 2),soffcol,concat(trim(cnvtstring(codesettoexport)),
        " is not a valid code set."))
     ELSE
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=codesetvalue
         AND cv.active_ind=1)
       HEAD REPORT
        totalcodevaluecount = 0
       DETAIL
        totalcodevaluecount = (totalcodevaluecount+ 1)
       WITH nocounter
      ;end select
      CALL clear((soffrow+ 2),soffcol,numcols)
      CALL text((soffrow+ 2),soffcol,substring(1,75,concat(trim(cnvtstring(curaccept))," - ",
         cnvtupper(trim(codesetdisplay))," has ",trim(cnvtstring(totalcodevaluecount)),
         " code values.")))
      SET iscodesetdefined = 1
     ENDIF
   ENDWHILE
   SELECT INTO "nl:"
    cv.code_set, cv.code_value, cv.display,
    cva.contributor_source_cd, cva.alias, cva.primary_ind
    FROM code_value cv,
     code_value_alias cva
    PLAN (cv
     WHERE cv.code_set=codesetvalue
      AND cv.active_ind=1)
     JOIN (cva
     WHERE cva.code_value=outerjoin(cv.code_value))
    ORDER BY cv.code_set, cnvtupper(cv.display), cnvtupper(uar_get_code_display(cva
       .contributor_source_cd)),
     cva.alias_type_meaning
    HEAD REPORT
     cnt = 0, indatacount = 0, inaliascount = 0,
     CALL text((soffrow+ 4),soffcol,concat("Inbound  alias count: ",cnvtstring(inaliascount)))
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(cv_alias->list,5))
      stat = alterlist(cv_alias->list,(cnt+ 5))
     ENDIF
     cv_alias->list[cnt].code_set = cv.code_set, cv_alias->list[cnt].code_value = cv.code_value,
     cv_alias->list[cnt].display = cv.display,
     cv_alias->list[cnt].type = alias_type_inbound, cv_alias->list[cnt].contributor_source_cd = cva
     .contributor_source_cd, cv_alias->list[cnt].alias = cva.alias,
     cv_alias->list[cnt].meaning = cva.alias_type_meaning, cv_alias->list[cnt].primary_ind = cva
     .primary_ind, indatacount = (indatacount+ 1)
     IF (cva.alias != null)
      inaliascount = (inaliascount+ 1)
     ENDIF
     CALL text((soffrow+ 4),soffcol,concat("Inbound    alias count: ",cnvtstring(inaliascount)))
    FOOT REPORT
     stat = alterlist(cv_alias->list,cnt)
    WITH nocounter
   ;end select
   CALL text((soffrow+ 4),soffcol,concat("Inbound    alias count: ",cnvtstring(inaliascount)))
   SELECT INTO "nl:"
    cv.code_set, cv.code_value, cv.display,
    contributor_source = uar_get_code_display(cvo.contributor_source_cd), cvo.alias
    FROM code_value cv,
     code_value_outbound cvo
    PLAN (cv
     WHERE cv.code_set=codesetvalue
      AND cv.active_ind=1)
     JOIN (cvo
     WHERE cvo.code_value=outerjoin(cv.code_value))
    ORDER BY cv.code_set, cnvtupper(cv.display), cnvtupper(uar_get_code_display(cvo
       .contributor_source_cd)),
     cvo.alias_type_meaning
    HEAD REPORT
     outdatacount = 0, outaliascount = 0,
     CALL text((soffrow+ 5),soffcol,concat("Outbound   alias count: ",cnvtstring(outaliascount)))
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(cv_alias->list,5))
      stat = alterlist(cv_alias->list,(cnt+ 5))
     ENDIF
     cv_alias->list[cnt].code_set = cv.code_set, cv_alias->list[cnt].code_value = cv.code_value,
     cv_alias->list[cnt].display = cv.display,
     cv_alias->list[cnt].type = alias_type_outbound, cv_alias->list[cnt].contributor_source_cd = cvo
     .contributor_source_cd, cv_alias->list[cnt].alias = cvo.alias,
     cv_alias->list[cnt].meaning = cvo.alias_type_meaning, outdatacount = (outdatacount+ 1)
     IF (cvo.alias != null)
      outaliascount = (outaliascount+ 1)
     ENDIF
     CALL text((soffrow+ 5),soffcol,concat("Outbound   alias count: ",cnvtstring(outaliascount)))
    FOOT REPORT
     stat = alterlist(cv_alias->list,cnt)
    WITH nocounter
   ;end select
   CALL text((soffrow+ 5),soffcol,concat("Outbound   alias count: ",cnvtstring(outaliascount)))
   CALL text((soffrow+ 6),soffcol,concat("Total      alias count: ",cnvtstring((outaliascount+
      inaliascount))))
   CALL text((soffrow+ 7),soffcol,concat("Total CSV record count: ",cnvtstring(cnt)))
   IF (((outdatacount+ indatacount)=0))
    CALL text((soffrow+ 8),soffcol,concat("NO CODE VALUES EXIST for code set ",trim(cnvtstring(
        codesetvalue)),"."))
   ELSE
    SET filename = cnvtlower(concat(trim(cnvtstring(codesetvalue)),"_code_set_extract.csv"))
    SET emailfileprompt = "Enter file name:"
    CALL text((soffrow+ 9),soffcol,emailfileprompt)
    CALL accept((soffrow+ 9),(soffcol+ (textlen(emailfileprompt)+ 1)),"P(58);C",filename
     WHERE cnvtupper(trim(curaccept))="*.CSV")
    SET filename = curaccept
    CALL clear((soffrow+ 9),soffcol,numcols)
    SET amsemail = ""
    SET emailprompt = "Would you like to email the file? (Y/N):"
    CALL text((soffrow+ 9),soffcol,emailprompt)
    CALL accept((soffrow+ 9),(soffcol+ (textlen(emailprompt)+ 1)),"A;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     CALL clear((soffrow+ 9),soffcol,numcols)
     SET emailprompt = "Enter email address:"
     CALL text((soffrow+ 9),soffcol,emailprompt)
     CALL accept((soffrow+ 9),(soffcol+ (textlen(emailprompt)+ 1)),"P(54);C",gethnaemail(null)
      WHERE trim(curaccept)="*@*.*")
     SET amsemail = curaccept
     SET emailind = 1
    ELSE
     SET emailind = 0
     CALL clear((soffrow+ 8),soffcol,numcols)
    ENDIF
    SELECT INTO value(filename)
     action = "", code_set = cv_alias->list[d1.seq].code_set, code_value = cv_alias->list[d1.seq].
     code_value,
     cv_display = substring(1,40,cv_alias->list[d1.seq].display), alias_type = cv_alias->list[d1.seq]
     .type, current_contrib_src_disp = substring(1,40,uar_get_code_display(cv_alias->list[d1.seq].
       contributor_source_cd)),
     current_alias = substring(1,255,cv_alias->list[d1.seq].alias), current_alias_type_meaning =
     substring(1,12,cv_alias->list[d1.seq].meaning), current_primary_ind = cv_alias->list[d1.seq].
     primary_ind,
     new_contrib_src_disp = "", new_alias = "", new_alias_type_meaning = "",
     new_primary_ind = ""
     FROM (dummyt d1  WITH seq = value(size(cv_alias->list,5)))
     WITH format = stream, pcformat('"',",",1), format(date,";;q"),
      format
    ;end select
    IF (emailind=1)
     SET recpstr = amsemail
     SET subjstr = concat(trim(curdomain),": Code Value Alias Extract ",format(cnvtdatetime(curdate,
        curtime3),"@SHORTDATETIME"))
     SET bodystr = "Code value alias extract attached."
     SET stat = emailfile(recpstr,amsemail,subjstr,bodystr,filename)
     IF (stat=1)
      CALL text((soffrow+ 10),soffcol,"File successfully emailed.")
     ELSE
      CALL text((soffrow+ 10),soffcol,"File FAILED to email.")
     ENDIF
    ENDIF
    CALL text((soffrow+ 13),soffcol,"FILE LOCATION: $CCLUSERDIR")
    CALL text((soffrow+ 14),soffcol,concat("FILE NAME    : ",filename))
   ENDIF
   SET questionanotheraudit = "Would you like to run another audit? (Y/N):"
   CALL text((soffrow+ 16),soffcol,questionanotheraudit)
   CALL accept((soffrow+ 16),(soffcol+ (textlen(questionanotheraudit)+ 1)),"A;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="N")
    GO TO main_menu
   ELSE
    CALL exportmode(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE importmode(null)
   DECLARE foundfile = i2 WITH protect
   CALL clearscreen(null)
   WHILE (foundfile=0)
     CALL text(soffrow,soffcol,"Enter filename to UPDATE aliases from:")
     CALL accept((soffrow+ 1),soffcol,"P(74);CU")
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSEIF (cnvtupper(curaccept)="*.CSV")
      SET stat = findfile(curaccept)
      IF (stat=1)
       SET foundfile = 1
       CALL clear((soffrow+ 2),soffcol,numcols)
       CALL text((soffrow+ 2),soffcol,"Reading aliases from file...")
       CALL readinputfile(curaccept)
       CALL text((soffrow+ 2),(soffcol+ 29),"Done.")
       CALL text((soffrow+ 3),soffcol,"Loading requests...")
       CALL loadrequest(curaccept)
       CALL text((soffrow+ 3),(soffcol+ 20),"Done.")
      ELSE
       CALL clear((soffrow+ 2),soffcol,numcols)
       CALL text((soffrow+ 2),soffcol,"You entered in a .CSV, but it doesn't exist.")
      ENDIF
     ELSE
      CALL clear((soffrow+ 2),soffcol,numcols)
      CALL text((soffrow+ 2),soffcol,
       "Input file not found. Include logical if file is not in CCLUSERDIR")
     ENDIF
   ENDWHILE
   SET incrementcount = 0
   IF (size(import_in_cv_alias->list,5) > 0)
    CALL text((soffrow+ 5),soffcol,concat("Starting inbound updates..."))
    IF (debug_ind=1)
     CALL addlogmsg("INFO","import_in_cv_alias record inside importMode()")
     CALL echorecord(import_in_cv_alias,logfilename,1)
    ENDIF
    CALL updateinbound(null)
    CALL text((soffrow+ 5),(soffcol+ 29),"Done.")
    CALL text((soffrow+ 6),soffcol,concat("Completed ",trim(cnvtstring(size(import_in_cv_alias->list,
         5)))," alias changes."))
    SET incrementcount = size(import_in_cv_alias->list,5)
   ELSE
    CALL text((soffrow+ 5),soffcol,"No inbound alias updates.")
   ENDIF
   IF (size(import_out_cv_alias->list,5) > 0)
    CALL text((soffrow+ 8),soffcol,concat("Starting outbound updates..."))
    IF (debug_ind=1)
     CALL addlogmsg("INFO","import_out_cv_alias record inside importMode()")
     CALL echorecord(import_out_cv_alias,logfilename,1)
    ENDIF
    CALL updateoutbound(null)
    CALL text((soffrow+ 8),(soffcol+ 29),"Done.")
    CALL text((soffrow+ 9),soffcol,concat("Completed ",trim(cnvtstring(size(import_out_cv_alias->list,
         5)))," alias changes."))
    SET incrementcount = (incrementcount+ size(import_out_cv_alias->list,5))
   ELSE
    CALL text((soffrow+ 8),soffcol,"No outbound alias updates.")
   ENDIF
   IF (incrementcount > 0)
    SET questioncommitchanges = "Commit changes? (Y/N):"
    CALL text((soffrow+ 16),soffcol,questioncommitchanges)
    CALL accept((soffrow+ 16),(soffcol+ (textlen(questioncommitchanges)+ 1)),"A;CU","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     ROLLBACK
     GO TO exit_script
    ELSE
     SET trace = nocallecho
     CALL updtdminfo(script_name,cnvtreal(incrementcount))
     SET trace = callecho
     COMMIT
     GO TO exit_script
    ENDIF
   ELSE
    SET questioncommitchanges = "No updates proposed. Exit Script. (Y):"
    CALL text((soffrow+ 16),soffcol,questioncommitchanges)
    CALL accept((soffrow+ 16),(soffcol+ (textlen(questioncommitchanges)+ 1)),"A;CU","Y"
     WHERE curaccept IN ("Y"))
    IF (curaccept="Y")
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE readinputfile(filename)
   DECLARE action_pos = i2 WITH protect, constant(1)
   DECLARE code_set_pos = i2 WITH protect, constant(2)
   DECLARE code_value_pos = i2 WITH protect, constant(3)
   DECLARE cv_display_pos = i2 WITH protect, constant(4)
   DECLARE alias_type_pos = i2 WITH protect, constant(5)
   DECLARE current_contrib_src_disp_pos = i2 WITH protect, constant(6)
   DECLARE current_alias_pos = i2 WITH protect, constant(7)
   DECLARE current_alias_type_meaning_pos = i2 WITH protect, constant(8)
   DECLARE current_primary_ind_pos = i2 WITH protect, constant(9)
   DECLARE new_contrib_src_disp_pos = i2 WITH protect, constant(10)
   DECLARE new_alias_pos = i2 WITH protect, constant(11)
   DECLARE new_alias_type_meaning_pos = i2 WITH protect, constant(12)
   DECLARE new_primary_ind_pos = i2 WITH protect, constant(13)
   DECLARE delim = vc WITH protect, constant(",")
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE str = vc WITH protect
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE cnti = i4 WITH protect
   DECLARE cnto = i4 WITH protect
   DECLARE tocnt = i4 WITH protect
   DECLARE endofcolumns = i2 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnto = 0, cnti = 0, firstrow = 1
    DETAIL
     IF (((substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
      action_insert)) OR (((substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=
     substring(1,1,action_update)) OR (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3
        )))=substring(1,1,action_delete))) )) )
      IF (substring(1,1,cnvtupper(piece(r.line,delim,alias_type_pos,notfnd,3)))=substring(1,1,
       cnvtupper(alias_type_inbound)))
       cnti = (cnti+ 1)
       IF (cnti > size(import_in_cv_alias->list,5))
        stat = alterlist(import_in_cv_alias->list,(cnti+ 5))
       ENDIF
       piecenum = 1, str = "", endofcolumns = 0
       WHILE (piecenum < 14)
         str = piece(r.line,delim,piecenum,notfnd,3)
         CASE (piecenum)
          OF action_pos:
           IF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_insert))
            import_in_cv_alias->list[cnti].action_type_flag = 1
           ELSEIF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_update))
            import_in_cv_alias->list[cnti].action_type_flag = 2
           ELSEIF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_delete))
            import_in_cv_alias->list[cnti].action_type_flag = 3
           ENDIF
          OF code_set_pos:
           import_in_cv_alias->list[cnti].code_set = cnvtint(trim(str))
          OF code_value_pos:
           import_in_cv_alias->list[cnti].code_value = cnvtreal(trim(str))
          OF current_contrib_src_disp_pos:
           import_in_cv_alias->list[cnti].old_contributor_source_disp = trim(str)
          OF current_alias_pos:
           import_in_cv_alias->list[cnti].old_alias = trim(str)
          OF current_alias_type_meaning_pos:
           import_in_cv_alias->list[cnti].old_alias_type_meaning = trim(str)
          OF new_contrib_src_disp_pos:
           import_in_cv_alias->list[cnti].contributor_source_disp = trim(str)
          OF new_alias_pos:
           import_in_cv_alias->list[cnti].alias = trim(str)
          OF new_alias_type_meaning_pos:
           import_in_cv_alias->list[cnti].alias_type_meaning = trim(str)
          OF new_primary_ind_pos:
           import_in_cv_alias->list[cnti].primary_ind = cnvtint(trim(str)),endofcolumns = 1
         ENDCASE
         piecenum = (piecenum+ 1)
       ENDWHILE
      ELSEIF (substring(1,1,cnvtupper(piece(r.line,delim,alias_type_pos,notfnd,3)))=substring(1,1,
       cnvtupper(alias_type_outbound)))
       cnto = (cnto+ 1)
       IF (cnto > size(import_out_cv_alias->list,5))
        stat = alterlist(import_out_cv_alias->list,(cnto+ 5))
       ENDIF
       piecenum = 1, str = ""
       WHILE (str != notfnd)
         str = piece(r.line,delim,piecenum,notfnd,3)
         CASE (piecenum)
          OF action_pos:
           IF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_insert))
            import_out_cv_alias->list[cnto].action_type_flag = 1
           ELSEIF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_update))
            import_out_cv_alias->list[cnto].action_type_flag = 2
           ELSEIF (substring(1,1,cnvtupper(piece(r.line,delim,action_pos,notfnd,3)))=substring(1,1,
            action_delete))
            import_out_cv_alias->list[cnto].action_type_flag = 3
           ENDIF
          OF code_set_pos:
           import_out_cv_alias->list[cnto].code_set = cnvtint(trim(str))
          OF code_value_pos:
           import_out_cv_alias->list[cnto].code_value = cnvtreal(trim(str))
          OF current_contrib_src_disp_pos:
           import_out_cv_alias->list[cnto].old_contributor_source_disp = trim(str)
          OF current_alias_type_meaning_pos:
           import_out_cv_alias->list[cnto].old_alias_type_meaning = trim(str)
          OF new_contrib_src_disp_pos:
           import_out_cv_alias->list[cnto].contributor_source_disp = trim(str)
          OF new_alias_pos:
           import_out_cv_alias->list[cnto].alias = trim(str)
          OF new_alias_type_meaning_pos:
           import_out_cv_alias->list[cnto].alias_type_meaning = trim(str)
         ENDCASE
         piecenum = (piecenum+ 1)
       ENDWHILE
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(import_in_cv_alias->list,cnti), stat = alterlist(import_out_cv_alias->list,cnto
      )
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_in_cv_alias record - inside readInputFile() after initial read")
    CALL echorecord(import_in_cv_alias,logfilename,1)
    CALL addlogmsg("INFO","import_out_cv_alias record - inside readInputFile() after intial read")
    CALL echorecord(import_out_cv_alias,logfilename,1)
   ENDIF
   IF (cnti > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(import_in_cv_alias->list,5))),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(import_in_cv_alias->list[d.seq].
        old_contributor_source_disp))
       AND cv.code_set=73
       AND cv.active_ind=1)
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_in_cv_alias->list[d.seq].old_contributor_source_disp
       ))
       import_in_cv_alias->list[d.seq].old_contributor_source_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(import_in_cv_alias->list,5))),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(import_in_cv_alias->list[d.seq].
        contributor_source_disp))
       AND cv.code_set=73
       AND cv.active_ind=1)
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_in_cv_alias->list[d.seq].contributor_source_disp))
       import_in_cv_alias->list[d.seq].contributor_source_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (cnto > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(import_out_cv_alias->list,5))),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(import_out_cv_alias->list[d.seq].
        old_contributor_source_disp))
       AND cv.code_set=73
       AND cv.active_ind=1)
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_out_cv_alias->list[d.seq].
       old_contributor_source_disp))
       import_out_cv_alias->list[d.seq].old_contributor_source_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(import_out_cv_alias->list,5))),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(import_out_cv_alias->list[d.seq].
        contributor_source_disp))
       AND cv.code_set=73
       AND cv.active_ind=1)
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_out_cv_alias->list[d.seq].contributor_source_disp))
       import_out_cv_alias->list[d.seq].contributor_source_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE loadrequest(null)
   DECLARE cnt = i4 WITH protect
   SET stat = alterlist(request_in_cv_alias->inbnd_alias_list,size(import_in_cv_alias->list,5))
   FOR (i = 1 TO size(import_in_cv_alias->list,5))
    SET request_in_cv_alias->inbnd_alias_list[i].action_type_flag = import_in_cv_alias->list[i].
    action_type_flag
    IF ((request_in_cv_alias->inbnd_alias_list[i].action_type_flag=1))
     SET request_in_cv_alias->inbnd_alias_list[i].alias = import_in_cv_alias->list[i].alias
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias = import_in_cv_alias->list[i].alias
     SET request_in_cv_alias->inbnd_alias_list[i].alias_type_meaning = import_in_cv_alias->list[i].
     alias_type_meaning
     SET request_in_cv_alias->inbnd_alias_list[i].code_set = import_in_cv_alias->list[i].code_set
     SET request_in_cv_alias->inbnd_alias_list[i].code_value = import_in_cv_alias->list[i].code_value
     SET request_in_cv_alias->inbnd_alias_list[i].contributor_source_cd = import_in_cv_alias->list[i]
     .contributor_source_cd
     SET request_in_cv_alias->inbnd_alias_list[i].old_contributor_source_cd = 0
     SET request_in_cv_alias->inbnd_alias_list[i].primary_ind = import_in_cv_alias->list[i].
     primary_ind
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias_type_meaning = import_in_cv_alias->list[i
     ].alias_type_meaning
    ELSEIF ((request_in_cv_alias->inbnd_alias_list[i].action_type_flag=2))
     SET request_in_cv_alias->inbnd_alias_list[i].alias = import_in_cv_alias->list[i].alias
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias = import_in_cv_alias->list[i].old_alias
     SET request_in_cv_alias->inbnd_alias_list[i].alias_type_meaning = import_in_cv_alias->list[i].
     alias_type_meaning
     SET request_in_cv_alias->inbnd_alias_list[i].code_set = import_in_cv_alias->list[i].code_set
     SET request_in_cv_alias->inbnd_alias_list[i].code_value = import_in_cv_alias->list[i].code_value
     SET request_in_cv_alias->inbnd_alias_list[i].contributor_source_cd = import_in_cv_alias->list[i]
     .contributor_source_cd
     SET request_in_cv_alias->inbnd_alias_list[i].old_contributor_source_cd = import_in_cv_alias->
     list[i].old_contributor_source_cd
     SET request_in_cv_alias->inbnd_alias_list[i].primary_ind = import_in_cv_alias->list[i].
     primary_ind
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias_type_meaning = import_in_cv_alias->list[i
     ].old_alias_type_meaning
    ELSEIF ((request_in_cv_alias->inbnd_alias_list[i].action_type_flag=3))
     SET request_in_cv_alias->inbnd_alias_list[i].alias = import_in_cv_alias->list[i].old_alias
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias = import_in_cv_alias->list[i].old_alias
     SET request_in_cv_alias->inbnd_alias_list[i].alias_type_meaning = import_in_cv_alias->list[i].
     old_alias_type_meaning
     SET request_in_cv_alias->inbnd_alias_list[i].code_set = import_in_cv_alias->list[i].code_set
     SET request_in_cv_alias->inbnd_alias_list[i].code_value = import_in_cv_alias->list[i].code_value
     SET request_in_cv_alias->inbnd_alias_list[i].contributor_source_cd = import_in_cv_alias->list[i]
     .old_contributor_source_cd
     SET request_in_cv_alias->inbnd_alias_list[i].old_contributor_source_cd = import_in_cv_alias->
     list[i].old_contributor_source_cd
     SET request_in_cv_alias->inbnd_alias_list[i].primary_ind = import_in_cv_alias->list[i].
     primary_ind
     SET request_in_cv_alias->inbnd_alias_list[i].old_alias_type_meaning = import_in_cv_alias->list[i
     ].old_alias_type_meaning
    ENDIF
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","inbnd_reply record inside loadRequest()")
    CALL echorecord(request_in_cv_alias,logfilename,1)
   ENDIF
   SET stat = alterlist(request_out_cv_alias->outbnd_alias_list,size(import_out_cv_alias->list,5))
   FOR (i = 1 TO size(import_out_cv_alias->list,5))
    SET request_out_cv_alias->outbnd_alias_list[i].action_type_flag = import_out_cv_alias->list[i].
    action_type_flag
    IF ((request_out_cv_alias->outbnd_alias_list[i].action_type_flag=1))
     SET request_out_cv_alias->outbnd_alias_list[i].alias = import_out_cv_alias->list[i].alias
     SET request_out_cv_alias->outbnd_alias_list[i].alias_type_meaning = import_out_cv_alias->list[i]
     .alias_type_meaning
     SET request_out_cv_alias->outbnd_alias_list[i].code_set = import_out_cv_alias->list[i].code_set
     SET request_out_cv_alias->outbnd_alias_list[i].code_value = import_out_cv_alias->list[i].
     code_value
     SET request_out_cv_alias->outbnd_alias_list[i].contributor_source_cd = import_out_cv_alias->
     list[i].contributor_source_cd
     SET request_out_cv_alias->outbnd_alias_list[i].old_contributor_source_cd = 0
     SET request_out_cv_alias->outbnd_alias_list[i].old_alias_type_meaning = import_out_cv_alias->
     list[i].alias_type_meaning
    ELSEIF ((request_out_cv_alias->outbnd_alias_list[i].action_type_flag=2))
     SET request_out_cv_alias->outbnd_alias_list[i].alias = import_out_cv_alias->list[i].alias
     SET request_out_cv_alias->outbnd_alias_list[i].alias_type_meaning = import_out_cv_alias->list[i]
     .alias_type_meaning
     SET request_out_cv_alias->outbnd_alias_list[i].code_set = import_out_cv_alias->list[i].code_set
     SET request_out_cv_alias->outbnd_alias_list[i].code_value = import_out_cv_alias->list[i].
     code_value
     SET request_out_cv_alias->outbnd_alias_list[i].contributor_source_cd = import_out_cv_alias->
     list[i].contributor_source_cd
     SET request_out_cv_alias->outbnd_alias_list[i].old_contributor_source_cd = import_out_cv_alias->
     list[i].old_contributor_source_cd
     SET request_out_cv_alias->outbnd_alias_list[i].old_alias_type_meaning = import_out_cv_alias->
     list[i].old_alias_type_meaning
    ELSEIF ((request_out_cv_alias->outbnd_alias_list[i].action_type_flag=3))
     SET request_out_cv_alias->outbnd_alias_list[i].alias = ""
     SET request_out_cv_alias->outbnd_alias_list[i].alias_type_meaning = import_out_cv_alias->list[i]
     .old_alias_type_meaning
     SET request_out_cv_alias->outbnd_alias_list[i].code_set = import_out_cv_alias->list[i].code_set
     SET request_out_cv_alias->outbnd_alias_list[i].code_value = import_out_cv_alias->list[i].
     code_value
     SET request_out_cv_alias->outbnd_alias_list[i].contributor_source_cd = import_out_cv_alias->
     list[i].old_contributor_source_cd
     SET request_out_cv_alias->outbnd_alias_list[i].old_contributor_source_cd = 0
     SET request_out_cv_alias->outbnd_alias_list[i].old_alias_type_meaning = ""
    ENDIF
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","request_out_cv_alias record inside loadRequest()")
    CALL echorecord(request_out_cv_alias,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinbound(null)
   SET trace = nocallecho
   FREE RECORD inbnd_reply
   SET trace = recpersist
   EXECUTE core_ens_inbnd_alias  WITH replace("REQUEST",request_in_cv_alias), replace("REPLY",
    inbnd_reply)
   SET trace = callecho
   IF (debug_ind=1)
    CALL addlogmsg("INFO","inbnd_reply record inside updateInbound()")
    CALL echorecord(inbnd_reply,logfilename,1)
   ENDIF
   SET trace = norecpersist
   IF ((inbnd_reply->status_data.status="F"))
    ROLLBACK
    CALL text((soffrow+ 6),soffcol,concat(
      "Script error. Changes rolled back. Check INBOUND update item ",trim(cnvtstring((inbnd_reply->
        curqual+ 1)))," on CSV."))
    CALL text((soffrow+ 7),soffcol,substring(1,75,inbnd_reply->qual[(inbnd_reply->curqual+ 1)].
      error_msg))
    CALL text((soffrow+ 8),soffcol,substring(76,75,inbnd_reply->qual[(inbnd_reply->curqual+ 1)].
      error_msg))
    CALL text((soffrow+ 9),soffcol,substring(151,75,inbnd_reply->qual[(inbnd_reply->curqual+ 1)].
      error_msg))
    CALL text((soffrow+ 10),soffcol,substring(226,75,inbnd_reply->qual[(inbnd_reply->curqual+ 1)].
      error_msg))
    SET questionscriptfailure = "Exit Script. (Y):"
    CALL text((soffrow+ 16),soffcol,questionscriptfailure)
    CALL accept((soffrow+ 16),(soffcol+ (textlen(questionscriptfailure)+ 1)),"A;CU","Y"
     WHERE curaccept IN ("Y"))
    IF (curaccept="Y")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updateoutbound(null)
   SET trace = nocallecho
   FREE RECORD outbnd_reply
   SET trace = recpersist
   EXECUTE core_ens_outbnd_alias  WITH replace("REQUEST",request_out_cv_alias), replace("REPLY",
    outbnd_reply)
   SET trace = callecho
   IF (debug_ind=1)
    CALL addlogmsg("INFO","outbnd_reply record inside updateOutbound()")
    CALL echorecord(outbnd_reply,logfilename,1)
   ENDIF
   FOR (i = 1 TO size(outbnd_reply->qual,5))
     IF ((outbnd_reply->qual[i].status=0))
      ROLLBACK
      CALL text((soffrow+ 9),soffcol,concat(
        "Script error. Changes rolled back. Check OUTBOUND update item ",trim(cnvtstring(i)),
        " on CSV."))
      CALL text((soffrow+ 10),soffcol,substring(1,75,outbnd_reply->qual[i].error_msg))
      CALL text((soffrow+ 11),soffcol,substring(76,75,outbnd_reply->qual[i].error_msg))
      CALL text((soffrow+ 12),soffcol,substring(151,75,outbnd_reply->qual[i].error_msg))
      CALL text((soffrow+ 13),soffcol,substring(226,75,outbnd_reply->qual[i].error_msg))
      SET questionscriptfailure = "Exit Script. (Y):"
      CALL text((soffrow+ 16),soffcol,questionscriptfailure)
      CALL accept((soffrow+ 16),(soffcol+ (textlen(questionscriptfailure)+ 1)),"A;CU","Y"
       WHERE curaccept IN ("Y"))
      IF (curaccept="Y")
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET trace = norecpersist
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  ROLLBACK
  CALL echo(statusstr)
 ENDIF
 IF (debug_ind=1)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "001"
END GO
