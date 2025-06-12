CREATE PROGRAM ams_inactivate_orderable_util:dba
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
 DECLARE incrementimportcount(inccnt=i4) = i2 WITH protect
 DECLARE readinputfile(filename=vc) = null WITH protect
 DECLARE validatedata(null) = i4 WITH protect
 DECLARE createerrorcsv(filename=vc) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE blankfilemode(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                      AMS Inactivate Orderable Utility                      ")
 DECLARE detail_line = c75 WITH protect, constant(
  "                      Inactivate and rename orderables                      ")
 DECLARE script_name = c29 WITH protect, constant("AMS_INACTIVATE_ORDERABLE_UTIL")
 DECLARE from_str = vc WITH protect, constant("ams_inactivate_orderable_util@cerner.com")
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE primary_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE errorfilename = vc WITH protect, noconstant(" ")
 DECLARE errorcnt = i4 WITH protect
 DECLARE emailfailstr = vc WITH protect, constant("Email failed. Manually grab file from CCLUSERDIR")
 DECLARE error_orderable_dup = vc WITH protect, constant("New orderable name already exists. ")
 DECLARE error_orderable_not_found = vc WITH protect, constant("Current orderable name not found. ")
 DECLARE error_orderable_dup_sheet = vc WITH protect, constant(
  "New orderable name exists multiple times in import sheet. ")
 SET logfilename = concat("ams_inactivate_orderable_util_",cnvtlower(format(cnvtdatetime(curdate,
     curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 SET errorfilename = cnvtlower(concat(getclient(null),"_",trim(curdomain),"_orderable_errors.csv"))
 RECORD import_data(
   1 list[*]
     2 error_str = vc
     2 curr_primary_mnem = vc
     2 new_primary_mnem = vc
     2 duplicate_ind = i2
     2 dup_catalog_cd = f8
     2 catalog_cd = f8
     2 dept_name = c100
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 procedure_type_cd = f8
 ) WITH protect
 RECORD bed_request(
   1 olist[*]
     2 catalog_cd = f8
     2 description = c100
     2 primary_mnemonic = c100
     2 dept_name = c100
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 active_ind = i2
     2 procedure_type_cd = f8
 ) WITH protect
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_inactivate_orderable_util")
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 5),(soffcol+ 26),"1 Import orderables to inactivate")
 CALL text((soffrow+ 6),(soffcol+ 26),"2 Create blank import file")
 CALL text((soffrow+ 7),(soffcol+ 26),"3 Exit")
 CALL accept(quesrow,(soffcol+ 18),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL importmode(null)
  OF 2:
   CALL blankfilemode(null)
  OF 3:
   GO TO exit_script
 ENDCASE
 SUBROUTINE importmode(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE done = i2 WITH protect
   CALL clearscreen(null)
   SET stat = initrec(import_data)
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter filename to read orderables from:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C")
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET stat = findfile(curaccept)
      IF (stat=1)
       CALL clear((soffrow+ 2),soffcol,numcols)
       SET done = 1
       CALL text((soffrow+ 2),soffcol,"Reading orderables from file...")
       CALL readinputfile(curaccept)
       CALL text((soffrow+ 2),(soffcol+ 31),"done")
       CALL text((soffrow+ 3),soffcol,"Checking for duplicate orderables...")
       SET errorcnt = validatedata(null)
       IF (errorcnt=0)
        CALL text((soffrow+ 3),(soffcol+ 36),"done")
        CALL text((soffrow+ 4),soffcol,"Inactivating orderables...")
        CALL performupdates(null)
        CALL text((soffrow+ 4),(soffcol+ 26),"done")
        CALL text(quesrow,soffcol,"Commit?:")
        CALL accept(quesrow,(soffcol+ 8),"A;CU"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         COMMIT
        ELSE
         ROLLBACK
        ENDIF
       ELSE
        CALL text((soffrow+ 3),soffcol,
         "Error(s) found. At least one of the orderables in the file has an error.")
        SET done = 0
        WHILE (done=0)
          CALL text((soffrow+ 5),soffcol,"Enter filename to export errors to:")
          CALL accept((soffrow+ 6),(soffcol+ 1),"P(74);C",errorfilename)
          IF (cnvtupper(curaccept)="*.CSV*")
           CALL clear((soffrow+ 7),soffcol,numcols)
           SET done = 1
           SET errorfilename = trim(cnvtlower(curaccept))
           CALL createerrorcsv(errorfilename)
           CALL text((soffrow+ 7),soffcol,"Do you want to email the file?:")
           CALL accept((soffrow+ 7),(soffcol+ 31),"A;CU","Y"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            CALL text((soffrow+ 8),soffcol,"Enter recepient's email address:")
            CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",gethnaemail(null)
             WHERE trim(curaccept)="*@*.*")
            IF (emailfile(curaccept,from_str,"","",errorfilename))
             CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
            ELSE
             CALL text((soffrow+ 14),soffcol,emailfailstr)
            ENDIF
            CALL text(quesrow,soffcol,"Continue?:")
            CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
             WHERE curaccept IN ("Y"))
           ENDIF
          ELSEIF (cnvtupper(curaccept)="QUIT")
           GO TO main_menu
          ELSE
           CALL text((soffrow+ 9),soffcol,"File must have .csv extension")
          ENDIF
        ENDWHILE
       ENDIF
      ELSE
       CALL text((soffrow+ 2),soffcol,
        "File not found. Make sure file exists in CCLUSERDIR or include logical.")
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text((soffrow+ 2),soffcol,"File must have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE blankfilemode(null)
   DECLARE blankfilename = vc WITH protect, noconstant("inactivate_orderables_template.csv")
   CALL clearscreen(null)
   SET done = 0
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter blank template filename:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C",blankfilename)
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET done = 1
      SET blankfilename = trim(cnvtlower(curaccept))
      SELECT INTO value(blankfilename)
       current_orderable_name = "", new_orderable_name = ""
       FROM (dummyt d1  WITH seq = 1)
       PLAN (d1)
       WITH format = stream, pcformat('"',delim,1), format
      ;end select
      CALL text((soffrow+ 2),soffcol,"Do you want to email the file?:")
      CALL accept((soffrow+ 2),(soffcol+ 31),"A;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       CALL text((soffrow+ 3),soffcol,"Enter recepient's email address:")
       CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C",gethnaemail(null)
        WHERE trim(curaccept)="*@*.*")
       IF (emailfile(curaccept,from_str,"","",blankfilename))
        CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
       ELSE
        CALL text((soffrow+ 14),soffcol,emailfailstr)
       ENDIF
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text((soffrow+ 9),soffcol,"File must have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE validatedata(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE orderpos = i4 WITH protect
   SELECT INTO "nl:"
    oc.catalog_cd
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_catalog oc,
     service_directory sd
    PLAN (d)
     JOIN (oc
     WHERE (oc.primary_mnemonic=import_data->list[d.seq].curr_primary_mnem))
     JOIN (sd
     WHERE sd.catalog_cd=outerjoin(oc.catalog_cd))
    DETAIL
     import_data->list[d.seq].activity_subtype_cd = oc.activity_subtype_cd, import_data->list[d.seq].
     activity_type_cd = oc.activity_type_cd, import_data->list[d.seq].catalog_cd = oc.catalog_cd,
     import_data->list[d.seq].catalog_type_cd = oc.catalog_type_cd, import_data->list[d.seq].
     dept_name = oc.dept_display_name, import_data->list[d.seq].procedure_type_cd = sd
     .bb_processing_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    oc.catalog_cd
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_catalog oc
    PLAN (d)
     JOIN (oc
     WHERE (oc.primary_mnemonic=import_data->list[d.seq].new_primary_mnem))
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].duplicate_ind = 1, import_data->list[d.seq].
     dup_catalog_cd = oc.catalog_cd,
     import_data->list[d.seq].error_str = error_orderable_dup
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ocs.synonym_id
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_catalog_synonym ocs
    PLAN (d)
     JOIN (ocs
     WHERE ocs.mnemonic_key_cap=trim(cnvtupper(import_data->list[d.seq].new_primary_mnem))
      AND ocs.mnemonic_type_cd=primary_type_cd)
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].duplicate_ind = 1, import_data->list[d.seq].
     dup_catalog_cd = ocs.catalog_cd,
     import_data->list[d.seq].error_str = error_orderable_dup
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(import_data->list,5))
     IF ((import_data->list[i].catalog_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
       error_orderable_not_found)
     ENDIF
     SET orderpos = i
     WHILE (orderpos > 0)
      SET orderpos = locateval(cnt,(orderpos+ 1),size(import_data->list,5),import_data->list[i].
       new_primary_mnem,import_data->list[cnt].new_primary_mnem)
      IF (orderpos > 0)
       IF (findstring(error_orderable_dup_sheet,import_data->list[i].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
         error_orderable_dup_sheet)
       ENDIF
       IF (findstring(error_orderable_dup_sheet,import_data->list[orderpos].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[orderpos].error_str = build2(import_data->list[orderpos].error_str,
         error_orderable_dup_sheet)
       ENDIF
      ENDIF
     ENDWHILE
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record after being filled out by validateData()")
    CALL echorecord(import_data,logfilename,1)
    CALL addlogmsg("INFO",build2("Returning errorCnt = ",trim(cnvtstring(errorcnt)),
      " in validateData()"))
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE ordercnt = i4 WITH protect
   SET stat = initrec(bed_request)
   SET stat = alterlist(bed_request->olist,size(import_data->list,5))
   FOR (ordercnt = 1 TO size(import_data->list,5))
     SET bed_request->olist[ordercnt].active_ind = 0
     SET bed_request->olist[ordercnt].activity_subtype_cd = import_data->list[ordercnt].
     activity_subtype_cd
     SET bed_request->olist[ordercnt].activity_type_cd = import_data->list[ordercnt].activity_type_cd
     SET bed_request->olist[ordercnt].catalog_cd = import_data->list[ordercnt].catalog_cd
     SET bed_request->olist[ordercnt].catalog_type_cd = import_data->list[ordercnt].catalog_type_cd
     SET bed_request->olist[ordercnt].dept_name = import_data->list[ordercnt].new_primary_mnem
     SET bed_request->olist[ordercnt].description = import_data->list[ordercnt].new_primary_mnem
     SET bed_request->olist[ordercnt].primary_mnemonic = import_data->list[ordercnt].new_primary_mnem
     SET bed_request->olist[ordercnt].procedure_type_cd = import_data->list[ordercnt].
     procedure_type_cd
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","bed_request record after being loaded by performUpdates()")
    CALL echorecord(bed_request,logfilename,1)
   ENDIF
   SET trace = recpersist
   SET trace = nocallecho
   EXECUTE bed_ens_oc_gen_info  WITH replace("REQUEST",bed_request), replace("REPLY",bed_reply)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","bed_reply record after bed_ens_oc_gen_info in performUpdates()")
    CALL echorecord(bed_reply,logfilename,1)
   ENDIF
   IF ((bed_reply->status_data.status != "S"))
    SET status = "F"
    SET statusstr = "Error encountered in bed_ens_oc_gen_info"
    GO TO exit_script
   ENDIF
   SET trace = norecpersist
   SET trace = callecho
   SET stat = incrementimportcount(size(import_data->list,5))
   IF (stat=0)
    SET status = "F"
    SET statusstr = "Error encountered in incrementImportCount() incrementing count"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE createerrorcsv(filename)
   SELECT INTO value(filename)
    error_message = substring(1,1000,import_data->list[d.seq].error_str), current_orderable_name =
    substring(1,1000,import_data->list[d.seq].curr_primary_mnem), new_orderable_name = substring(1,
     1000,import_data->list[d.seq].new_primary_mnem)
    FROM (dummyt d  WITH seq = value(size(import_data->list,5)))
    PLAN (d)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
 SUBROUTINE readinputfile(filename)
   DECLARE current_orderable_pos = i2 WITH protect, constant(1)
   DECLARE new_orderable_pos = i2 WITH protect, constant(2)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build2("Starting to read input file: ",filename))
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0, firstrow = 1
    DETAIL
     IF (firstrow != 1
      AND trim(piece(r.line,delim,current_orderable_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,current_orderable_pos,notfnd,3))) > 0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(import_data->list,(cnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF current_orderable_pos:
          import_data->list[cnt].curr_primary_mnem = trim(str)
         OF new_orderable_pos:
          import_data->list[cnt].new_primary_mnem = trim(substring(1,100,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSEIF (firstrow=1
      AND trim(piece(r.line,delim,current_orderable_pos,notfnd,3)) > " ")
      firstrow = 0
     ENDIF
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(import_data->list,cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record after being loaded by readInputFile()")
    CALL echorecord(import_data,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE incrementimportcount(inccnt)
   DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   DECLARE infodetail = vc WITH protect, constant(
    "Total number of orderables inactivated by program:")
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=script_name
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = pref_domain, d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
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
    UPDATE  FROM dm_info d
     SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WHERE d.info_domain=pref_domain
      AND d.info_name=script_name
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  ROLLBACK
  CALL echo(statusstr)
 ENDIF
 IF (debug_ind=1)
  CALL addlogmsg("ERROR",statusstr)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "000"
END GO
