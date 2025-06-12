CREATE PROGRAM ams_mltm_updt_synonyms:dba
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
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 DECLARE getsynonymchanges(null) = i4 WITH protect
 DECLARE determineupdates(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE addignoresyn(ckipos=i4,synpos=i4) = null WITH protect
 DECLARE addasksyn(ckipos=i4,synpos=i4) = null WITH protect
 DECLARE addupdtsyn(ckipos=i4,synpos=i4,typeofupdt=vc) = null WITH protect
 DECLARE removevirtualview(synid=f8) = null WITH protect
 DECLARE getvirtualviewpref(null) = i2 WITH protect
 DECLARE createaskusercsv(filename=vc) = null WITH protect
 DECLARE createautoupdatereportcsv(filename=vc) = null WITH protect
 DECLARE readinputcsv(filename=vc) = i2 WITH protect
 DECLARE updatemode(null) = null WITH protect
 DECLARE importmode(null) = null WITH protect
 DECLARE updatesynckis(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                     AMS Multum Update Synonyms Utility                     ")
 DECLARE detail_line = c75 WITH protect, constant(
  "               Update synonyms to recommended Multum settings               ")
 DECLARE script_name = c22 WITH protect, constant("AMS_MLTM_UPDT_SYNONYMS")
 DECLARE info_str = vc WITH protect, constant("Number of times the script has updated synonyms:")
 DECLARE from_str = vc WITH protect, constant("AMS_MLTM_UPDT_SYNONYMS@CERNER.COM")
 DECLARE ask_body_str = vc WITH protect, constant(
  "Attached is the list of synonyms that need review.")
 DECLARE updt_body_str = vc WITH protect, constant(
  "Attached is the list of synonyms that were automatically updated.")
 DECLARE ask_subject_str = vc WITH protect, constant(build2("Synonyms needing review for ",trim(
    getclient(null))," ",curdomain))
 DECLARE updt_subject_str = vc WITH protect, constant(build2("Synonyms auto updated for ",trim(
    getclient(null))," ",curdomain))
 DECLARE pharm_cat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE syn_type_primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE syn_type_dcp = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DCP"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE vv_rx_pref_ind = i2 WITH protect, constant(getvirtualviewpref(null))
 DECLARE delim = c1 WITH protect, constant(",")
 DECLARE ignsyncnt = i4 WITH protect
 DECLARE updtsyncnt = i4 WITH protect
 DECLARE asksyncnt = i4 WITH protect
 DECLARE totalsyncnt = i4 WITH protect
 DECLARE logfilename = vc WITH protect
 DECLARE askusercsvfilename = vc WITH protect
 DECLARE autoupdtcsvfilename = vc WITH protect
 DECLARE inputupdtcnt = i4 WITH protect
 DECLARE inputigncnt = i4 WITH protect
 DECLARE inputerrorcnt = i4 WITH protect
 SET askusercsvfilename = trim(concat("syns_to_updt_",trim(cnvtlower(curdomain)),".csv"))
 SET autoupdtcsvfilename = trim(concat("syns_auto_updt_",trim(cnvtlower(curdomain)),".csv"))
 IF (debug_ind=1)
  SET logfilename = concat("ams_mltm_updt_synonyms_",cnvtlower(format(cnvtdatetime(curdate,curtime3),
     "dd_mmm_yyyy_hh_mm;;q")),".log")
 ENDIF
 RECORD synstomodify(
   1 cki_list[*]
     2 syn_cki = vc
     2 syn_list_cnt = i4
     2 syn_cki_cnt = i4
     2 syn_list[*]
       3 catalog_cd = f8
       3 primary = vc
       3 synonym_id = f8
       3 mltm_mnemonic = vc
       3 mnemonic = vc
       3 mltm_type = vc
       3 mltm_type_cd = f8
       3 type = vc
       3 type_cd = f8
       3 mltm_hide = i2
       3 hide = i2
       3 vv_ind = i2
       3 chg_mnemonic_ind = i2
       3 chg_type_ind = i2
       3 chg_hide_ind = i2
 ) WITH protect
 RECORD ignoresyns(
   1 syn_list[*]
     2 synonym_id = f8
     2 insert_ind = i2
 ) WITH protect
 RECORD updtsyns(
   1 syn_list[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mltm_mnemonic = vc
     2 mltm_type = vc
     2 mltm_type_cd = f8
     2 cki = vc
     2 primary = vc
     2 mnemonic = vc
     2 type = vc
     2 mltm_hide = i2
     2 hide = i2
     2 vv_ind = i2
     2 chg_mnemonic_ind = i2
     2 chg_type_ind = i2
     2 chg_hide_ind = i2
 ) WITH protect
 RECORD asksyns(
   1 syn_list[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 cki = vc
     2 needs_shorten = i2
     2 possible_dup = i2
     2 actionstr = vc
     2 primary = vc
     2 mltm_mnemonic = vc
     2 mnemonic = vc
     2 mltm_type = vc
     2 mltm_type_cd = f8
     2 type = vc
     2 type_cd = f8
     2 mltm_hide = i2
     2 hide = i2
     2 vv_ind = i2
     2 chg_mnemonic_ind = i2
     2 chg_type_ind = i2
     2 chg_hide_ind = i2
 ) WITH protect
 CALL validatelogin(null)
 SET status = "S"
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 4),(soffcol+ 26),"1 Auto Update Synonyms")
 CALL text((soffrow+ 5),(soffcol+ 26),"2 Update Synonyms from CSV")
 CALL text((soffrow+ 6),(soffcol+ 26),"3 Exit")
 CALL accept(quesrow,(soffcol+ 18),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL updatemode(null)
  OF 2:
   CALL importmode(null)
  OF 3:
   GO TO exit_script
 ENDCASE
 SUBROUTINE updatemode(null)
   DECLARE emailupdtrptind = i2 WITH protect
   DECLARE emailaskrptind = i2 WITH protect
   CALL clearscreen(null)
   CALL updatesynckis(null)
   CALL text(soffrow,soffcol,"Finding synonyms that need to be updated...")
   CALL getsynonymchanges(null)
   CALL text(soffrow,(soffcol+ 43),"done")
   CALL text((soffrow+ 1),soffcol,"Count of synonyms that need updating:")
   CALL text((soffrow+ 1),(soffcol+ 38),trim(cnvtstring(totalsyncnt)))
   CALL text((soffrow+ 3),soffcol,"Determining how to update synonyms...")
   CALL determineupdates(null)
   IF (size(asksyns->syn_list,5) > 0)
    CALL createaskusercsv(askusercsvfilename)
   ENDIF
   CALL text((soffrow+ 3),(soffcol+ 37),"done")
   CALL text((soffrow+ 4),soffcol,"Count of synonyms being auto updated:")
   CALL text((soffrow+ 4),(soffcol+ 38),trim(cnvtstring(updtsyncnt)))
   CALL text((soffrow+ 5),soffcol,"Count of synonyms being auto ignored:")
   CALL text((soffrow+ 5),(soffcol+ 38),trim(cnvtstring(ignsyncnt)))
   CALL text((soffrow+ 6),soffcol,"Count of synonyms being sent to CSV:")
   CALL text((soffrow+ 6),(soffcol+ 38),trim(cnvtstring(asksyncnt)))
   IF (((updtsyncnt > 0) OR (((ignsyncnt > 0) OR (asksyncnt > 0)) )) )
    CALL text((soffrow+ 8),soffcol,"Performing updates...")
    CALL performupdates(null)
    CALL text((soffrow+ 8),(soffcol+ 21),"done")
    IF (updtsyncnt > 0)
     CALL text((soffrow+ 10),soffcol,
      "Do you want to email the file containing synonyms that were auto updated?:")
     CALL accept((soffrow+ 10),(soffcol+ 74),"A;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET emailupdtrptind = 1
     ELSE
      SET emailupdtrptind = 0
     ENDIF
    ENDIF
    IF (asksyncnt > 0)
     CALL text((soffrow+ 11),soffcol,
      "Do you want to email the file containing synonyms that need review?:")
     CALL accept((soffrow+ 11),(soffcol+ 68),"A;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET emailaskrptind = 1
     ELSE
      SET emailaskrptind = 0
     ENDIF
    ENDIF
    IF (((emailupdtrptind=1) OR (emailaskrptind=1)) )
     CALL text((soffrow+ 12),soffcol,"Enter recipient's email address:")
     CALL accept((soffrow+ 13),(soffcol+ 1),"P(74);C",gethnaemail(null)
      WHERE curaccept > " ")
    ENDIF
    CALL text(quesrow,soffcol,"Commit?:")
    CALL accept(quesrow,(soffcol+ 8),"A;CU"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     COMMIT
     SET trace = nocallecho
     CALL updtdminfo(script_name,1.0)
     SET trace = callecho
    ELSE
     ROLLBACK
    ENDIF
    IF (emailupdtrptind=1)
     IF (emailfile(curaccept,from_str,updt_subject_str,updt_body_str,autoupdtcsvfilename))
      CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
     ELSE
      CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
     ENDIF
    ENDIF
    IF (emailaskrptind=1)
     IF (emailfile(curaccept,from_str,ask_subject_str,ask_body_str,askusercsvfilename))
      CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
     ELSE
      CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
     ENDIF
    ENDIF
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ELSE
    CALL text((soffrow+ 8),soffcol,"No synonyms found to auto update or ignore")
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE importmode(null)
   DECLARE done = i2 WITH protect
   CALL clearscreen(null)
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter filename to read synonym updates from:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C")
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET stat = findfile(curaccept)
      IF (stat=1)
       CALL clear((soffrow+ 2),soffcol,numcols)
       SET done = 1
       CALL text((soffrow+ 3),soffcol,"Reading synonyms from file...")
       SET stat = readinputcsv(curaccept)
       CALL text((soffrow+ 3),(soffcol+ 29),"done")
       CALL text((soffrow+ 4),soffcol,"Count of synonyms being updated:")
       CALL text((soffrow+ 4),(soffcol+ 33),trim(cnvtstring(inputupdtcnt)))
       CALL text((soffrow+ 5),soffcol,"Count of synonyms being ignored:")
       CALL text((soffrow+ 5),(soffcol+ 33),trim(cnvtstring(inputigncnt)))
       IF (inputerrorcnt > 0)
        CALL text((soffrow+ 6),soffcol,"Count of synonyms with errors:")
        CALL text((soffrow+ 6),(soffcol+ 33),trim(cnvtstring(inputerrorcnt)))
       ENDIF
       CALL text((soffrow+ 8),soffcol,"Performing updates...")
       CALL performupdates(null)
       CALL text((soffrow+ 8),(soffcol+ 21),"done")
       IF (stat=0)
        CALL text((soffrow+ 10),soffcol,
         "Errors were found in the import file. Common errors include not putting")
        CALL text((soffrow+ 11),soffcol,
         "Yes or No in the first column, not shortening synonyms to 100 characters")
        CALL text((soffrow+ 12),soffcol,
         "or less, choosing to update multiple synonyms that will create duplicates")
        CALL text((soffrow+ 13),soffcol,"and removing or adding columns.")
       ENDIF
       CALL text(quesrow,soffcol,"Commit?:")
       CALL accept(quesrow,(soffcol+ 8),"A;CU"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        COMMIT
        SET trace = nocallecho
        CALL updtdminfo(script_name,1.0)
        SET trace = callecho
       ELSE
        ROLLBACK
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
 SUBROUTINE getsynonymchanges(null)
   DECLARE ckicnt = i4 WITH protect
   DECLARE syncnt = i4 WITH protect
   DECLARE ckipos = i4 WITH protect
   DECLARE skipprimind = i2 WITH protect
   SET stat = initrec(synstomodify)
   SELECT DISTINCT INTO "nl:"
    mocl.mnemonic, mocl.synonym_cki, ocs.synonym_id,
    ocs.mnemonic
    FROM mltm_order_catalog_load mocl,
     code_value cv,
     order_catalog_synonym ocs,
     order_catalog oc,
     ocs_facility_r ofr,
     br_name_value bnv,
     dummyt d
    PLAN (mocl)
     JOIN (cv
     WHERE cv.cdf_meaning=mocl.mnemonic_type_mean
      AND cv.code_set=6011
      AND cv.active_ind=1)
     JOIN (ocs
     WHERE ocs.cki=mocl.synonym_cki
      AND ((trim(ocs.concept_cki)=mocl.synonym_concept_cki
      AND trim(ocs.concept_cki) > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
      AND trim(mocl.synonym_concept_cki) IN ("", " ", null)))
      AND ocs.active_ind=1
      AND ocs.mnemonic_type_cd != syn_type_dcp)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1)
     JOIN (ofr
     WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
     JOIN (bnv
     WHERE bnv.br_nv_key1=outerjoin("MLTM_IGN_SYN")
      AND bnv.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
      AND bnv.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
     JOIN (d
     WHERE ((ocs.mnemonic != mocl.mnemonic
      AND textlen(mocl.mnemonic) <= 100) OR (((cv.code_value != ocs.mnemonic_type_cd) OR (ocs
     .hide_flag != mocl.hide_ind
      AND ocs.hide_flag=0)) )) )
    ORDER BY cnvtupper(mocl.description), mocl.primary_ind, ocs.cki,
     ocs.synonym_id
    HEAD REPORT
     ckicnt = 0, syncnt = 0, totalsyncnt = 0,
     updtsyncnt = 0, ignsyncnt = 0, asksyncnt = 0,
     skipprimind = 0
    HEAD mocl.description
     skipprimind = 0
    HEAD ocs.cki
     ckipos = 0, syncnt = 0
    DETAIL
     IF (bnv.br_name_value_id=0.0
      AND skipprimind=0)
      ckipos = locateval(i,1,size(synstomodify->cki_list,5),ocs.cki,synstomodify->cki_list[i].syn_cki
       )
      IF (ckipos=0)
       ckicnt = (ckicnt+ 1), ckipos = ckicnt
       IF (mod(ckicnt,100)=1)
        stat = alterlist(synstomodify->cki_list,(ckicnt+ 99))
       ENDIF
      ENDIF
      totalsyncnt = (totalsyncnt+ 1), syncnt = (size(synstomodify->cki_list[ckipos].syn_list,5)+ 1),
      stat = alterlist(synstomodify->cki_list[ckipos].syn_list,syncnt),
      synstomodify->cki_list[ckipos].syn_cki = ocs.cki, synstomodify->cki_list[ckipos].syn_list[
      syncnt].mnemonic = ocs.mnemonic, synstomodify->cki_list[ckipos].syn_list[syncnt].synonym_id =
      ocs.synonym_id,
      synstomodify->cki_list[ckipos].syn_list[syncnt].catalog_cd = ocs.catalog_cd, synstomodify->
      cki_list[ckipos].syn_list[syncnt].primary = oc.primary_mnemonic, synstomodify->cki_list[ckipos]
      .syn_list[syncnt].hide = ocs.hide_flag,
      synstomodify->cki_list[ckipos].syn_list[syncnt].type = uar_get_code_display(ocs
       .mnemonic_type_cd), synstomodify->cki_list[ckipos].syn_list[syncnt].type_cd = ocs
      .mnemonic_type_cd, synstomodify->cki_list[ckipos].syn_list[syncnt].mltm_mnemonic = mocl
      .mnemonic,
      synstomodify->cki_list[ckipos].syn_list[syncnt].mltm_type = mocl.mnemonic_type, synstomodify->
      cki_list[ckipos].syn_list[syncnt].mltm_type_cd = cv.code_value, synstomodify->cki_list[ckipos].
      syn_list[syncnt].mltm_hide = mocl.hide_ind
      IF (ofr.synonym_id > 0)
       synstomodify->cki_list[ckipos].syn_list[syncnt].vv_ind = 1
      ELSE
       synstomodify->cki_list[ckipos].syn_list[syncnt].vv_ind = 0
      ENDIF
      IF (ocs.mnemonic != mocl.mnemonic)
       synstomodify->cki_list[ckipos].syn_list[syncnt].chg_mnemonic_ind = 1
      ENDIF
      IF (uar_get_code_meaning(ocs.mnemonic_type_cd) != mocl.mnemonic_type_mean)
       synstomodify->cki_list[ckipos].syn_list[syncnt].chg_type_ind = 1
      ENDIF
      IF (ocs.hide_flag != mocl.hide_ind)
       synstomodify->cki_list[ckipos].syn_list[syncnt].chg_hide_ind = 1
      ENDIF
     ELSEIF (bnv.br_name_value_id > 0.0
      AND ocs.mnemonic_type_cd=syn_type_primary)
      skipprimind = 1
     ENDIF
    FOOT  ocs.cki
     IF (syncnt > 0)
      synstomodify->cki_list[ckicnt].syn_list_cnt = syncnt
     ENDIF
    FOOT REPORT
     IF (mod(ckicnt,100) != 0)
      stat = alterlist(synstomodify->cki_list,ckicnt)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ckinum = count(ocs.cki), ocs.cki
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE expand(i,1,size(synstomodify->cki_list,5),ocs.cki,synstomodify->cki_list[i].syn_cki))
    GROUP BY ocs.cki
    DETAIL
     ckipos = locateval(i,1,size(synstomodify->cki_list,5),ocs.cki,synstomodify->cki_list[i].syn_cki)
     IF (ckipos > 0)
      synstomodify->cki_list[ckipos].syn_cki_cnt = ckinum
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","synsToModify record after being populated by getSynonymChanges()")
    CALL echorecord(synstomodify,logfilename,1)
   ENDIF
   RETURN(totalsyncnt)
 END ;Subroutine
 SUBROUTINE determineupdates(null)
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE k = i4 WITH protect
   DECLARE mltmtypecnt = i4 WITH protect
   SET stat = initrec(updtsyns)
   SET stat = initrec(asksyns)
   SET stat = initrec(ignoresyns)
   SELECT INTO "nl:"
    ocs.synonym_id
    FROM order_catalog_synonym ocs,
     (dummyt d1  WITH seq = value(size(synstomodify->cki_list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(synstomodify->cki_list[d1.seq].syn_list,5)))
     JOIN (d2
     WHERE (((synstomodify->cki_list[d1.seq].syn_list[d2.seq].chg_mnemonic_ind=1)) OR ((synstomodify
     ->cki_list[d1.seq].syn_list[d2.seq].chg_type_ind=1))) )
     JOIN (ocs
     WHERE ocs.catalog_type_cd=pharm_cat_cd
      AND (ocs.mnemonic=synstomodify->cki_list[d1.seq].syn_list[d2.seq].mltm_mnemonic)
      AND (ocs.mnemonic_type_cd=synstomodify->cki_list[d1.seq].syn_list[d2.seq].mltm_type_cd))
    DETAIL
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build2("Ignoring ",ocs.synonym_id," - ",trim(ocs.mnemonic),
       " because the suggested change would create a duplicate synonym"))
     ENDIF
     CALL addignoresyn(d1.seq,d2.seq), synstomodify->cki_list[d1.seq].syn_list[d2.seq].
     chg_mnemonic_ind = 0, synstomodify->cki_list[d1.seq].syn_list[d2.seq].chg_type_ind = 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(synstomodify->cki_list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(synstomodify->cki_list[d1.seq].syn_list,5)))
     JOIN (d2
     WHERE (((synstomodify->cki_list[d1.seq].syn_list[d2.seq].chg_mnemonic_ind=1)) OR ((synstomodify
     ->cki_list[d1.seq].syn_list[d2.seq].chg_type_ind=1)))
      AND (synstomodify->cki_list[d1.seq].syn_list[d2.seq].type_cd != syn_type_primary)
      AND (synstomodify->cki_list[d1.seq].syn_list[d2.seq].mltm_type_cd=syn_type_primary))
    DETAIL
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build2("Ignoring ",synstomodify->cki_list[d1.seq].syn_list[d2.seq].
       synonym_id," - ",trim(synstomodify->cki_list[d1.seq].syn_list[d2.seq].mnemonic),
       " because the synonym has a primary CKI and it is not a primary."))
     ENDIF
     CALL addignoresyn(d1.seq,d2.seq), synstomodify->cki_list[d1.seq].syn_list[d2.seq].
     chg_mnemonic_ind = 0, synstomodify->cki_list[d1.seq].syn_list[d2.seq].chg_type_ind = 0
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(synstomodify->cki_list,5))
     FOR (j = 1 TO size(synstomodify->cki_list[i].syn_list,5))
       IF (debug_ind=1)
        CALL addlogmsg("INFO","***************************************************************")
        CALL addlogmsg("INFO",build2("Determining update for ",synstomodify->cki_list[i].syn_list[j].
          synonym_id," - ",synstomodify->cki_list[i].syn_list[j].mnemonic))
       ENDIF
       IF ((synstomodify->cki_list[i].syn_list[j].chg_hide_ind=1)
        AND (synstomodify->cki_list[i].syn_list[j].chg_mnemonic_ind=0)
        AND (synstomodify->cki_list[i].syn_list[j].chg_type_ind=0))
        IF (debug_ind=1)
         CALL addlogmsg("INFO","The hide flag is the only suggested update. Ignoring the change.")
        ENDIF
        CALL addignoresyn(i,j)
       ENDIF
       IF ((synstomodify->cki_list[i].syn_list[j].chg_mnemonic_ind=1))
        IF (debug_ind=1)
         CALL addlogmsg("INFO","***Mnemonic needs to be updated.***")
         CALL addlogmsg("INFO",build2("Current: ",synstomodify->cki_list[i].syn_list[j].mnemonic))
         CALL addlogmsg("INFO",build2("Multum:  ",synstomodify->cki_list[i].syn_list[j].mltm_mnemonic
           ))
        ENDIF
        IF ( NOT ((synstomodify->cki_list[i].syn_list[j].type_cd IN (syn_type_y, syn_type_z))))
         IF (debug_ind=1)
          CALL addlogmsg("INFO","It is an inpatient synonym type.")
          CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_list[j].type)
         ENDIF
         IF ( NOT ((synstomodify->cki_list[i].syn_list[j].mltm_type_cd IN (syn_type_y, syn_type_z))))
          IF ((synstomodify->cki_list[i].syn_cki_cnt=1))
           IF (debug_ind=1)
            CALL addlogmsg("INFO","This is the only synonym with this CKI.")
            CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_cki)
           ENDIF
           IF ((synstomodify->cki_list[i].syn_list[j].vv_ind=0))
            IF (debug_ind=1)
             CALL addlogmsg("INFO","The synonym is virtual viewed off, auto-updating.")
            ENDIF
            CALL addupdtsyn(i,j,"NAME")
           ELSE
            IF (debug_ind=1)
             CALL addlogmsg("INFO","The synonym is virtual viewed on, asking user.")
            ENDIF
            CALL addasksyn(i,j)
           ENDIF
          ELSE
           IF (debug_ind=1)
            CALL addlogmsg("INFO","There are multiple synonyms with this CKI.")
            CALL addlogmsg("INFO",build2("Count: ",trim(cnvtstring(synstomodify->cki_list[i].
                syn_cki_cnt))))
            CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_cki)
           ENDIF
           SET mltmtypecnt = 0
           FOR (k = 1 TO size(synstomodify->cki_list[i].syn_list,5))
             IF ((synstomodify->cki_list[i].syn_list[k].mltm_type_cd=synstomodify->cki_list[i].
             syn_list[k].type_cd))
              SET mltmtypecnt = (mltmtypecnt+ 1)
             ENDIF
           ENDFOR
           IF (mltmtypecnt=1)
            IF (debug_ind=1)
             CALL addlogmsg("INFO","One synonym with this CKI matches the synonym type from Multum.")
            ENDIF
            IF ((synstomodify->cki_list[i].syn_list[j].mltm_type_cd=synstomodify->cki_list[i].
            syn_list[j].type_cd))
             IF (debug_ind=1)
              CALL addlogmsg("INFO","This synonym's type matches Multum.")
             ENDIF
             IF ((synstomodify->cki_list[i].syn_list[j].vv_ind=0))
              IF (debug_ind=1)
               CALL addlogmsg("INFO","The synonym is virtual viewed off, auto-updating.")
              ENDIF
              CALL addupdtsyn(i,j,"NAME")
             ELSE
              IF (debug_ind=1)
               CALL addlogmsg("INFO","The synonym is virtual viewed on, asking user.")
              ENDIF
              CALL addasksyn(i,j)
             ENDIF
            ELSE
             IF (debug_ind=1)
              CALL addlogmsg("INFO","This synonym's type does not match Multum, ignoring.")
             ENDIF
             CALL addignoresyn(i,j)
            ENDIF
           ELSEIF (mltmtypecnt > 1)
            IF (debug_ind=1)
             CALL addlogmsg("INFO",
              "Multiple synonyms with this CKI match the synonym type from Multum.")
            ENDIF
            IF ((synstomodify->cki_list[i].syn_list[j].mltm_type_cd=synstomodify->cki_list[i].
            syn_list[j].type_cd))
             IF (debug_ind=1)
              CALL addlogmsg("INFO","This synonym's type matches Multum, asking user.")
             ENDIF
             CALL addasksyn(i,j)
            ELSE
             IF (debug_ind=1)
              CALL addlogmsg("INFO","This synonym's type does not match Multum, ignoring.")
             ENDIF
             CALL addignoresyn(i,j)
            ENDIF
           ELSEIF (mltmtypecnt=0)
            IF (debug_ind=1)
             CALL addlogmsg("INFO","No synonyms with this CKI match the synonym type from Multum")
             CALL addlogmsg("INFO",build2("Total count of synonyms with this CKI: ",trim(cnvtstring(
                 synstomodify->cki_list[i].syn_cki_cnt))))
             CALL addlogmsg("INFO",build2("Count of synonyms with this CKI needing update: ",trim(
                cnvtstring(synstomodify->cki_list[i].syn_list_cnt))))
            ENDIF
            IF ((synstomodify->cki_list[i].syn_cki_cnt=synstomodify->cki_list[i].syn_list_cnt))
             IF (debug_ind=1)
              CALL addlogmsg("INFO","All synonyms with this CKI are needing update, asking user.")
             ENDIF
             CALL addasksyn(i,j)
            ELSE
             IF (debug_ind=1)
              CALL addlogmsg("INFO","One synonym with this CKI already matches Multum, ignoring.")
             ENDIF
             CALL addignoresyn(i,j)
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ELSE
         IF (debug_ind=1)
          CALL addlogmsg("INFO","It is an outpatient synonym type.")
          CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_list[j].type)
         ENDIF
         IF ((synstomodify->cki_list[i].syn_cki_cnt=1))
          IF (debug_ind=1)
           CALL addlogmsg("INFO","This is the only synonym with this CKI, updating.")
          ENDIF
          CALL addupdtsyn(i,j,"NAME")
         ELSE
          IF (debug_ind=1)
           CALL addlogmsg("INFO","There are multiple synonyms with this CKI, asking user.")
          ENDIF
          CALL addasksyn(i,j)
         ENDIF
        ENDIF
       ENDIF
       IF ((synstomodify->cki_list[i].syn_list[j].chg_type_ind=1))
        IF (debug_ind=1)
         CALL addlogmsg("INFO","***Type needs to be updated.***")
         CALL addlogmsg("INFO",build2("Current: ",synstomodify->cki_list[i].syn_list[j].type))
         CALL addlogmsg("INFO",build2("Multum:  ",synstomodify->cki_list[i].syn_list[j].mltm_type))
        ENDIF
        IF ((synstomodify->cki_list[i].syn_cki_cnt=1))
         IF (debug_ind=1)
          CALL addlogmsg("INFO","This is the only synonym with this CKI.")
          CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_cki)
         ENDIF
         IF ((synstomodify->cki_list[i].syn_list[j].type_cd IN (syn_type_y, syn_type_z))
          AND  NOT ((synstomodify->cki_list[i].syn_list[j].mltm_type_cd IN (syn_type_y, syn_type_z)))
         )
          IF (debug_ind=1)
           CALL addlogmsg("INFO","The type is changing from outpatient to inpatient, auto-updating.")
          ENDIF
          CALL addupdtsyn(i,j,"TYPE")
          IF ((synstomodify->cki_list[i].syn_list[j].vv_ind=1)
           AND vv_rx_pref_ind=0)
           IF (debug_ind=1)
            CALL addlogmsg("INFO","Removing the virtual view for this synonym.")
           ENDIF
           CALL removevirtualview(synstomodify->cki_list[i].syn_list[j].synonym_id)
          ENDIF
         ELSE
          IF (debug_ind=1)
           CALL addlogmsg("INFO",
            "The type is not changing from outpatient to inpatient, asking user.")
          ENDIF
          CALL addasksyn(i,j)
         ENDIF
        ELSE
         IF (debug_ind=1)
          CALL addlogmsg("INFO","There are multiple synonyms with this CKI, asking user.")
          CALL addlogmsg("INFO",synstomodify->cki_list[i].syn_cki)
         ENDIF
         CALL addasksyn(i,j)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(ignoresyns->syn_list,ignsyncnt)
   SET stat = alterlist(updtsyns->syn_list,updtsyncnt)
   SET stat = alterlist(asksyns->syn_list,asksyncnt)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","synsToModify record after being modified by determineUpdates()")
    CALL echorecord(synstomodify,logfilename,1)
    CALL addlogmsg("INFO","ignoreSyns record after being populated by determineUpdates()")
    CALL echorecord(ignoresyns,logfilename,1)
    CALL addlogmsg("INFO","updtSyns record after being populated by determineUpdates()")
    CALL echorecord(updtsyns,logfilename,1)
    CALL addlogmsg("INFO","askSyns record after being populated by determineUpdates()")
    CALL echorecord(asksyns,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE i = i4 WITH protect
   DECLARE num = i4 WITH protect
   IF (size(updtsyns->syn_list,5) > 0)
    CALL createautoupdatereportcsv(autoupdtcsvfilename)
   ENDIF
   IF (size(ignoresyns->syn_list,5) > 0)
    SET trace = recpersist
    RECORD br_request(
      1 br_name = vc
      1 br_value = vc
      1 br_nv_key1 = vc
    ) WITH protect
    RECORD br_reply(
      1 br_name_value_id = f8
      1 status_data
        2 status = c1
        2 subeventstatus[*]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET br_request->br_name = "ORDER_CATALOG_SYNONYM"
    SET br_request->br_nv_key1 = "MLTM_IGN_SYN"
    SELECT INTO "nl:"
     FROM br_name_value bnv
     WHERE (bnv.br_name=br_request->br_name)
      AND (bnv.br_nv_key1=br_request->br_nv_key1)
      AND expand(i,1,size(ignoresyns->syn_list,5),cnvtreal(bnv.br_value),ignoresyns->syn_list[i].
      synonym_id)
     DETAIL
      ignpos = locateval(num,1,size(ignoresyns->syn_list,5),cnvtreal(bnv.br_value),ignoresyns->
       syn_list[num].synonym_id)
      IF (ignpos > 0)
       ignoresyns->syn_list[ignpos].insert_ind = 0
      ENDIF
     WITH nocounter, expand = 1
    ;end select
    FOR (i = 1 TO size(ignoresyns->syn_list,5))
      IF ((ignoresyns->syn_list[i].insert_ind=1))
       SET br_request->br_value = trim(cnvtstring(ignoresyns->syn_list[i].synonym_id))
       EXECUTE bed_add_name_value  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
       IF ((br_reply->status_data.status="F"))
        ROLLBACK
        SET status = "F"
        SET statusstr = "Failed updating ignore values"
        GO TO exit_script
       ELSE
        SET status = "S"
       ENDIF
      ENDIF
    ENDFOR
    SET trace = norecpersist
   ENDIF
   IF (size(updtsyns->syn_list,5) > 0)
    SELECT INTO "nl:"
     FROM order_catalog oc
     WHERE expand(i,1,size(updtsyns->syn_list,5),oc.catalog_cd,updtsyns->syn_list[i].catalog_cd)
     WITH nocounter, forupdate(oc), expand = 1
    ;end select
    UPDATE  FROM order_catalog oc,
      (dummyt d  WITH seq = value(size(updtsyns->syn_list,5)))
     SET oc.primary_mnemonic = updtsyns->syn_list[d.seq].mltm_mnemonic, oc.description = updtsyns->
      syn_list[d.seq].mltm_mnemonic, oc.updt_applctx = reqinfo->updt_applctx,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id =
      reqinfo->updt_id,
      oc.updt_task = - (267)
     PLAN (d
      WHERE (updtsyns->syn_list[d.seq].mltm_type_cd=syn_type_primary))
      JOIN (oc
      WHERE (oc.catalog_cd=updtsyns->syn_list[d.seq].catalog_cd)
       AND oc.catalog_cd != 0)
     WITH nocounter
    ;end update
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE expand(i,1,size(updtsyns->syn_list,5),cv.code_value,updtsyns->syn_list[i].catalog_cd)
     WITH nocounter, forupdate(cv), expand = 1
    ;end select
    UPDATE  FROM code_value cv,
      (dummyt d  WITH seq = value(size(updtsyns->syn_list,5)))
     SET cv.display = trim(substring(1,40,updtsyns->syn_list[d.seq].mltm_mnemonic)), cv.display_key
       = trim(cnvtalphanum(cnvtupper(substring(1,40,updtsyns->syn_list[d.seq].mltm_mnemonic)))), cv
      .description = trim(substring(1,60,updtsyns->syn_list[d.seq].mltm_mnemonic)),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (
      cv.updt_cnt+ 1),
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = - (267)
     PLAN (d
      WHERE (updtsyns->syn_list[d.seq].mltm_type_cd=syn_type_primary))
      JOIN (cv
      WHERE cv.code_set=200
       AND (cv.code_value=updtsyns->syn_list[d.seq].catalog_cd))
     WITH nocounter
    ;end update
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs
     WHERE expand(i,1,size(updtsyns->syn_list,5),ocs.synonym_id,updtsyns->syn_list[i].synonym_id)
     WITH nocounter, forupdate(ocs), expand = 1
    ;end select
    UPDATE  FROM order_catalog_synonym ocs,
      (dummyt d  WITH seq = value(size(updtsyns->syn_list,5)))
     SET ocs.mnemonic = updtsyns->syn_list[d.seq].mltm_mnemonic, ocs.mnemonic_key_cap = cnvtupper(
       updtsyns->syn_list[d.seq].mltm_mnemonic), ocs.mnemonic_type_cd = updtsyns->syn_list[d.seq].
      mltm_type_cd,
      ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_task = - (267)
     PLAN (d)
      JOIN (ocs
      WHERE (ocs.synonym_id=updtsyns->syn_list[d.seq].synonym_id)
       AND ocs.synonym_id != 0)
     WITH nocounter
    ;end update
    IF (curqual != size(updtsyns->syn_list,5))
     ROLLBACK
     SET status = "F"
     SET statusstr = build2("Failed updating order_catalog_synonym. curqual =",trim(cnvtstring(
        curqual))," expected=",trim(cnvtstring(size(updtsyns->syn_list,5))))
     GO TO exit_script
    ENDIF
   ENDIF
   SET status = "S"
 END ;Subroutine
 SUBROUTINE addignoresyn(ckipos,synpos)
   DECLARE ignpos = i4 WITH protect
   DECLARE num = i4 WITH protect
   SET ignpos = locateval(num,1,ignsyncnt,synstomodify->cki_list[ckipos].syn_list[synpos].synonym_id,
    ignoresyns->syn_list[num].synonym_id)
   IF (ignpos=0)
    SET ignsyncnt = (ignsyncnt+ 1)
    IF (mod(ignsyncnt,50)=1)
     SET stat = alterlist(ignoresyns->syn_list,(ignsyncnt+ 49))
    ENDIF
    SET ignoresyns->syn_list[ignsyncnt].synonym_id = synstomodify->cki_list[ckipos].syn_list[synpos].
    synonym_id
    SET ignoresyns->syn_list[ignsyncnt].insert_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE addasksyn(ckipos,synpos)
   DECLARE updtpos = i4 WITH protect
   DECLARE askpos = i4 WITH protect
   DECLARE duppos = i4 WITH protect
   DECLARE num = i4 WITH protect
   SET updtpos = locateval(num,1,updtsyncnt,synstomodify->cki_list[ckipos].syn_list[synpos].
    synonym_id,updtsyns->syn_list[num].synonym_id)
   IF (updtpos > 0)
    SET stat = alterlist(updtsyns->syn_list,(size(updtsyns->syn_list,5) - 1),(updtpos - 1))
    SET stat = alterlist(updtsyns->syn_list,(size(updtsyns->syn_list,5)+ 1))
    SET updtsyncnt = (updtsyncnt - 1)
    SET synstomodify->cki_list[ckipos].syn_list[synpos].chg_mnemonic_ind = 1
   ENDIF
   SET askpos = locateval(num,1,asksyncnt,synstomodify->cki_list[ckipos].syn_list[synpos].synonym_id,
    asksyns->syn_list[num].synonym_id)
   IF (askpos=0)
    SET asksyncnt = (asksyncnt+ 1)
    IF (mod(asksyncnt,50)=1)
     SET stat = alterlist(asksyns->syn_list,(asksyncnt+ 49))
    ENDIF
    SET duppos = locateval(num,1,asksyncnt,synstomodify->cki_list[ckipos].syn_list[synpos].
     mltm_mnemonic,asksyns->syn_list[num].mltm_mnemonic,
     synstomodify->cki_list[ckipos].syn_list[synpos].mltm_type_cd,asksyns->syn_list[num].mltm_type_cd
     )
    IF (duppos > 0)
     SET asksyns->syn_list[duppos].possible_dup = 1
     SET asksyns->syn_list[asksyncnt].possible_dup = 1
    ENDIF
    SET asksyns->syn_list[asksyncnt].catalog_cd = synstomodify->cki_list[ckipos].syn_list[synpos].
    catalog_cd
    SET asksyns->syn_list[asksyncnt].synonym_id = synstomodify->cki_list[ckipos].syn_list[synpos].
    synonym_id
    SET asksyns->syn_list[asksyncnt].cki = synstomodify->cki_list[ckipos].syn_cki
    SET asksyns->syn_list[asksyncnt].primary = uar_get_code_display(synstomodify->cki_list[ckipos].
     syn_list[synpos].catalog_cd)
    SET asksyns->syn_list[asksyncnt].mltm_mnemonic = synstomodify->cki_list[ckipos].syn_list[synpos].
    mltm_mnemonic
    SET asksyns->syn_list[asksyncnt].mnemonic = synstomodify->cki_list[ckipos].syn_list[synpos].
    mnemonic
    SET asksyns->syn_list[asksyncnt].mltm_type = synstomodify->cki_list[ckipos].syn_list[synpos].
    mltm_type
    SET asksyns->syn_list[asksyncnt].mltm_type_cd = synstomodify->cki_list[ckipos].syn_list[synpos].
    mltm_type_cd
    SET asksyns->syn_list[asksyncnt].type = synstomodify->cki_list[ckipos].syn_list[synpos].type
    SET asksyns->syn_list[asksyncnt].type_cd = synstomodify->cki_list[ckipos].syn_list[synpos].
    type_cd
    SET asksyns->syn_list[asksyncnt].mltm_hide = synstomodify->cki_list[ckipos].syn_list[synpos].
    mltm_hide
    SET asksyns->syn_list[asksyncnt].hide = synstomodify->cki_list[ckipos].syn_list[synpos].hide
    SET asksyns->syn_list[asksyncnt].vv_ind = synstomodify->cki_list[ckipos].syn_list[synpos].vv_ind
    SET asksyns->syn_list[asksyncnt].chg_mnemonic_ind = synstomodify->cki_list[ckipos].syn_list[
    synpos].chg_mnemonic_ind
    SET asksyns->syn_list[asksyncnt].chg_type_ind = synstomodify->cki_list[ckipos].syn_list[synpos].
    chg_type_ind
    SET asksyns->syn_list[asksyncnt].chg_hide_ind = synstomodify->cki_list[ckipos].syn_list[synpos].
    chg_hide_ind
    IF (textlen(synstomodify->cki_list[ckipos].syn_list[synpos].mltm_mnemonic) > 100)
     SET asksyns->syn_list[asksyncnt].needs_shorten = 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addupdtsyn(ckipos,synpos,typeofupdt)
   DECLARE updtpos = i4 WITH protect
   DECLARE num = i4 WITH protect
   IF (textlen(synstomodify->cki_list[ckipos].syn_list[synpos].mltm_mnemonic) > 100)
    CALL addasksyn(ckipos,synpos)
   ELSE
    SET updtpos = locateval(num,1,updtsyncnt,synstomodify->cki_list[ckipos].syn_list[synpos].
     synonym_id,updtsyns->syn_list[num].synonym_id)
    IF (updtpos=0)
     SET updtsyncnt = (updtsyncnt+ 1)
     IF (mod(updtsyncnt,50)=1)
      SET stat = alterlist(updtsyns->syn_list,(updtsyncnt+ 49))
     ENDIF
     SET updtsyns->syn_list[updtsyncnt].catalog_cd = synstomodify->cki_list[ckipos].syn_list[synpos].
     catalog_cd
     SET updtsyns->syn_list[updtsyncnt].synonym_id = synstomodify->cki_list[ckipos].syn_list[synpos].
     synonym_id
     SET updtsyns->syn_list[updtsyncnt].cki = synstomodify->cki_list[ckipos].syn_cki
     SET updtsyns->syn_list[updtsyncnt].primary = synstomodify->cki_list[ckipos].syn_list[synpos].
     primary
     SET updtsyns->syn_list[updtsyncnt].mnemonic = synstomodify->cki_list[ckipos].syn_list[synpos].
     mnemonic
     SET updtsyns->syn_list[updtsyncnt].type = synstomodify->cki_list[ckipos].syn_list[synpos].type
     SET updtsyns->syn_list[updtsyncnt].mltm_hide = synstomodify->cki_list[ckipos].syn_list[synpos].
     mltm_hide
     SET updtsyns->syn_list[updtsyncnt].hide = synstomodify->cki_list[ckipos].syn_list[synpos].hide
     SET updtsyns->syn_list[updtsyncnt].vv_ind = synstomodify->cki_list[ckipos].syn_list[synpos].
     vv_ind
     IF (typeofupdt="NAME")
      SET updtsyns->syn_list[updtsyncnt].mltm_mnemonic = synstomodify->cki_list[ckipos].syn_list[
      synpos].mltm_mnemonic
      SET updtsyns->syn_list[updtsyncnt].mltm_type = synstomodify->cki_list[ckipos].syn_list[synpos].
      type
      SET updtsyns->syn_list[updtsyncnt].mltm_type_cd = synstomodify->cki_list[ckipos].syn_list[
      synpos].type_cd
      SET synstomodify->cki_list[ckipos].syn_list[synpos].chg_mnemonic_ind = 0
     ELSEIF (typeofupdt="TYPE")
      SET updtsyns->syn_list[updtsyncnt].mltm_mnemonic = synstomodify->cki_list[ckipos].syn_list[
      synpos].mnemonic
      SET updtsyns->syn_list[updtsyncnt].mltm_type = synstomodify->cki_list[ckipos].syn_list[synpos].
      mltm_type
      SET updtsyns->syn_list[updtsyncnt].mltm_type_cd = synstomodify->cki_list[ckipos].syn_list[
      synpos].mltm_type_cd
      SET synstomodify->cki_list[ckipos].syn_list[synpos].chg_type_ind = 0
     ENDIF
    ELSE
     SET updtsyns->syn_list[updtpos].mltm_type = synstomodify->cki_list[ckipos].syn_list[synpos].
     mltm_type
     SET updtsyns->syn_list[updtpos].mltm_type_cd = synstomodify->cki_list[ckipos].syn_list[synpos].
     mltm_type_cd
     SET synstomodify->cki_list[ckipos].syn_list[synpos].chg_type_ind = 0
    ENDIF
    IF ((synstomodify->cki_list[ckipos].syn_list[synpos].chg_hide_ind=1)
     AND (synstomodify->cki_list[ckipos].syn_list[synpos].chg_type_ind=0)
     AND (synstomodify->cki_list[ckipos].syn_list[synpos].chg_mnemonic_ind=0))
     CALL addignoresyn(i,j)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE removevirtualview(synid)
   DECLARE deletecnt = i4 WITH protect
   SELECT INTO "nl:"
    ofr.facility_cd, ofr.synonym_id
    FROM ocs_facility_r ofr
    PLAN (ofr
     WHERE ofr.synonym_id=synid
      AND ofr.synonym_id != 0)
    DETAIL
     deletecnt = (deletecnt+ 1)
    WITH nocounter, forupdate(ofr)
   ;end select
   DELETE  FROM ocs_facility_r ofr
    WHERE ofr.synonym_id=synid
     AND ofr.synonym_id != 0
    WITH nocounter
   ;end delete
   IF (curqual != deletecnt)
    SET status = "F"
    SET statusstr = build2("Error deleting rows on ocs_facility_r for synonym_id: ",trim(cnvtstring(
       synid)))
    GO TO exit_script
   ELSE
    IF (debug_ind=1)
     CALL addlogmsg("INFO",build2("Successfully deleted ",trim(cnvtstring(deletecnt)),
       " rows on ocs_facility_r for synonym_id: ",trim(cnvtstring(synid))))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getvirtualviewpref(null)
   DECLARE retval = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    nvp.pvc_name, nvp.pvc_value
    FROM name_value_prefs nvp,
     app_prefs ap
    PLAN (nvp
     WHERE nvp.pvc_name="RX_VIRTUAL_ORDER_CATALOG")
     JOIN (ap
     WHERE ap.app_prefs_id=nvp.parent_entity_id
      AND nvp.parent_entity_name="APP_PREFS"
      AND ap.application_number=600005
      AND ap.position_cd=0)
    DETAIL
     IF (nvp.pvc_value="PTFAC/VORC")
      retval = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE updatesynckis(null)
   DECLARE syncnt = i4 WITH protect
   RECORD updtckis(
     1 list[*]
       2 synonym_id = f8
       2 old_cki = vc
       2 new_cki = vc
       2 new_concept_cki = vc
   ) WITH protect
   SELECT INTO "nl:"
    ocs.synonym_id, mocl.catalog_cki, mocl.synonym_cki,
    mocl.description, mocl.mnemonic, ocs.mnemonic,
    ocs.cki
    FROM mltm_order_catalog_load mocl,
     code_value cv,
     order_catalog oc,
     order_catalog_synonym ocs
    PLAN (mocl
     WHERE  NOT ( EXISTS (
     (SELECT
      ocs.cki
      FROM order_catalog_synonym ocs
      WHERE ocs.cki=mocl.synonym_cki))))
     JOIN (cv
     WHERE cv.code_set=6011
      AND cv.cdf_meaning=mocl.mnemonic_type_mean)
     JOIN (oc
     WHERE oc.cki=mocl.catalog_cki)
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd
      AND ocs.mnemonic_key_cap=mocl.mnemonic_key_cap
      AND ocs.mnemonic_type_cd=cv.code_value
      AND ocs.cki != mocl.synonym_cki)
    ORDER BY mocl.catalog_cki
    HEAD REPORT
     syncnt = 0
    DETAIL
     syncnt = (syncnt+ 1), stat = alterlist(updtckis->list,syncnt), updtckis->list[syncnt].synonym_id
      = ocs.synonym_id,
     updtckis->list[syncnt].old_cki = ocs.cki, updtckis->list[syncnt].new_cki = mocl.synonym_cki,
     updtckis->list[syncnt].new_concept_cki = concat("MULTUM!",substring(8,(textlen(mocl.synonym_cki)
        - 7),mocl.synonym_cki))
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","updtCKIs record after being populated by updateSynCKIs()")
    CALL echorecord(updtckis,logfilename,1)
   ENDIF
   IF (syncnt > 0)
    UPDATE  FROM (dummyt d  WITH seq = value(size(updtckis->list,5))),
      order_catalog_synonym ocs
     SET ocs.cki = updtckis->list[d.seq].new_cki, ocs.concept_cki = updtckis->list[d.seq].
      new_concept_cki, ocs.updt_applctx = reqinfo->updt_applctx,
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id
       = reqinfo->updt_id,
      ocs.updt_task = - (267)
     PLAN (d)
      JOIN (ocs
      WHERE (ocs.synonym_id=updtckis->list[d.seq].synonym_id))
     WITH nocounter
    ;end update
    IF (curqual=syncnt)
     COMMIT
    ELSE
     ROLLBACK
     SET status = "F"
     SET statusstr = build2(
      "Failed updating existing synonym CKIs on order_catalog_synonym. curqual =",trim(cnvtstring(
        curqual))," expected=",trim(cnvtstring(size(updtckis->list,5))))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE createaskusercsv(filename)
  FOR (i = 1 TO size(asksyns->syn_list,5))
    IF ((asksyns->syn_list[i].needs_shorten=1))
     SET asksyns->syn_list[i].actionstr = "MLTM_SYNONYM needs shortening if updated."
    ENDIF
    IF ((asksyns->syn_list[i].possible_dup=1))
     IF ((asksyns->syn_list[i].actionstr > ""))
      SET asksyns->syn_list[i].actionstr = build2(asksyns->syn_list[i].actionstr," ")
     ENDIF
     SET asksyns->syn_list[i].actionstr = build2(asksyns->syn_list[i].actionstr,
      "Duplicate warning. Updating all of these synonyms will create duplicates.")
    ENDIF
    IF ((asksyns->syn_list[i].chg_type_ind=1)
     AND  NOT ((asksyns->syn_list[i].type_cd IN (syn_type_y, syn_type_z)))
     AND (asksyns->syn_list[i].mltm_type_cd IN (syn_type_y, syn_type_z)))
     IF ((asksyns->syn_list[i].actionstr > ""))
      SET asksyns->syn_list[i].actionstr = build2(asksyns->syn_list[i].actionstr," ")
     ENDIF
     SET asksyns->syn_list[i].actionstr = build2(asksyns->syn_list[i].actionstr,
      "Updating this synonym will make it no longer available for inpatient ordering.")
    ENDIF
  ENDFOR
  SELECT INTO value(filename)
   modify = " ", change = trim(build2(evaluate(asksyns->syn_list[d.seq].chg_mnemonic_ind,1,"Mnemonic",
      " "),
     IF ((asksyns->syn_list[d.seq].chg_mnemonic_ind=1)
      AND (asksyns->syn_list[d.seq].chg_type_ind=1)) ","
     ENDIF
     ,evaluate(asksyns->syn_list[d.seq].chg_type_ind,1,"Type"," ")),3), virtual_view = evaluate(
    asksyns->syn_list[d.seq].vv_ind,1,"Yes"," "),
   action_required = substring(1,150,asksyns->syn_list[d.seq].actionstr), primary = substring(1,100,
    asksyns->syn_list[d.seq].primary), synonym = substring(1,100,asksyns->syn_list[d.seq].mnemonic),
   synonym_type = substring(1,50,asksyns->syn_list[d.seq].type), multum_synonym = substring(1,150,
    asksyns->syn_list[d.seq].mltm_mnemonic), multum_synonym_type = substring(1,50,asksyns->syn_list[d
    .seq].mltm_type),
   multum_syn_type_cd = asksyns->syn_list[d.seq].mltm_type_cd, cki = substring(1,20,asksyns->
    syn_list[d.seq].cki), synonym_id = asksyns->syn_list[d.seq].synonym_id,
   catalog_cd = asksyns->syn_list[d.seq].catalog_cd
   FROM (dummyt d  WITH seq = value(size(asksyns->syn_list,5)))
   PLAN (d)
   WITH format = stream, pcformat('"',delim,1), format
  ;end select
 END ;Subroutine
 SUBROUTINE createautoupdatereportcsv(filename)
  FOR (i = 1 TO size(updtsyns->syn_list,5))
   IF ((updtsyns->syn_list[i].mltm_mnemonic != updtsyns->syn_list[i].mnemonic))
    SET updtsyns->syn_list[i].chg_mnemonic_ind = 1
   ENDIF
   IF ((updtsyns->syn_list[i].mltm_type != updtsyns->syn_list[i].type))
    SET updtsyns->syn_list[i].chg_type_ind = 1
   ENDIF
  ENDFOR
  SELECT INTO value(filename)
   change = trim(build2(evaluate(updtsyns->syn_list[d.seq].chg_mnemonic_ind,1,"Mnemonic"," "),
     IF ((updtsyns->syn_list[d.seq].chg_mnemonic_ind=1)
      AND (updtsyns->syn_list[d.seq].chg_type_ind=1)) ","
     ENDIF
     ,evaluate(updtsyns->syn_list[d.seq].chg_type_ind,1,"Type"," ")),3), virtual_view = evaluate(
    updtsyns->syn_list[d.seq].vv_ind,1,"Yes"," "), primary = substring(1,100,updtsyns->syn_list[d.seq
    ].primary),
   synonym = substring(1,100,updtsyns->syn_list[d.seq].mnemonic), synonym_type = substring(1,50,
    updtsyns->syn_list[d.seq].type), multum_synonym = substring(1,150,updtsyns->syn_list[d.seq].
    mltm_mnemonic),
   multum_synonym_type = substring(1,50,updtsyns->syn_list[d.seq].mltm_type), multum_syn_type_cd =
   updtsyns->syn_list[d.seq].mltm_type_cd, cki = substring(1,20,updtsyns->syn_list[d.seq].cki),
   synonym_id = updtsyns->syn_list[d.seq].synonym_id
   FROM (dummyt d  WITH seq = value(size(updtsyns->syn_list,5)))
   PLAN (d)
   ORDER BY cnvtupper(updtsyns->syn_list[d.seq].primary), multum_synonym_type, cnvtupper(updtsyns->
     syn_list[d.seq].mltm_mnemonic)
   WITH format = stream, pcformat('"',delim,1), format
  ;end select
 END ;Subroutine
 SUBROUTINE readinputcsv(filename)
   DECLARE retval = i2 WITH protect, noconstant(1)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE duppos = i4 WITH protect
   DECLARE dupcnt = i4 WITH protect
   DECLARE mltmmnemonic = vc WITH protect
   DECLARE mltmtypecd = f8 WITH protect
   SET stat = initrec(updtsyns)
   SET stat = initrec(ignoresyns)
   RECORD duplicates(
     1 dup_list[*]
       2 mnemonic = vc
       2 type_cd = f8
   ) WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     inputerrorcnt = 0, inputupdtcnt = 0, inputigncnt = 0,
     dupcnt = 0
    DETAIL
     IF (cnvtreal(piece(r.line,delim,12,notfnd,3)) > 0.0)
      IF (cnvtupper(trim(substring(1,1,piece(r.line,delim,1,notfnd,3))))="Y")
       inputupdtcnt = (inputupdtcnt+ 1)
       IF (mod(inputupdtcnt,10)=1)
        stat = alterlist(updtsyns->syn_list,(inputupdtcnt+ 9))
       ENDIF
       piecenum = 1, str = ""
       WHILE (str != notfnd)
         str = piece(r.line,delim,piecenum,notfnd,3)
         CASE (piecenum)
          OF 4:
           IF (cnvtupper(str)="*DUPLICATE*")
            mltmmnemonic = piece(r.line,delim,8,notfnd,3), mltmtypecd = cnvtreal(piece(r.line,delim,
              10,notfnd,3)), duppos = locateval(i,1,inputupdtcnt,mltmmnemonic,updtsyns->syn_list[i].
             mltm_mnemonic,
             mltmtypecd,updtsyns->syn_list[i].mltm_type_cd)
            IF (duppos > 0)
             inputupdtcnt = (inputupdtcnt - 2), inputerrorcnt = (inputerrorcnt+ 2), stat = alterlist(
              updtsyns->syn_list,(size(updtsyns->syn_list,5) - 1),(duppos - 1)),
             stat = alterlist(updtsyns->syn_list,(size(updtsyns->syn_list,5)+ 1)), dupcnt = (dupcnt+
             1), stat = alterlist(duplicates->dup_list,dupcnt),
             duplicates->dup_list[dupcnt].mnemonic = mltmmnemonic, duplicates->dup_list[dupcnt].
             type_cd = mltmtypecd, retval = 0,
             str = notfnd
            ELSE
             duppos = locateval(i,1,size(duplicates->dup_list,5),mltmmnemonic,duplicates->dup_list[i]
              .mnemonic,
              mltmtypecd,duplicates->dup_list[i].type_cd)
             IF (duppos > 0)
              inputupdtcnt = (inputupdtcnt - 1), inputerrorcnt = (inputerrorcnt+ 1), retval = 0,
              str = notfnd
             ENDIF
            ENDIF
           ENDIF
          OF 8:
           IF (textlen(str) > 100)
            inputupdtcnt = (inputupdtcnt - 1), inputerrorcnt = (inputerrorcnt+ 1), retval = 0,
            str = notfnd
           ELSE
            updtsyns->syn_list[inputupdtcnt].mltm_mnemonic = trim(substring(1,100,str))
           ENDIF
          OF 9:
           updtsyns->syn_list[inputupdtcnt].mltm_type = trim(substring(1,100,str))
          OF 10:
           updtsyns->syn_list[inputupdtcnt].mltm_type_cd = cnvtreal(str)
          OF 12:
           updtsyns->syn_list[inputupdtcnt].synonym_id = cnvtreal(str)
          OF 13:
           updtsyns->syn_list[inputupdtcnt].catalog_cd = cnvtreal(str)
         ENDCASE
         piecenum = (piecenum+ 1)
       ENDWHILE
      ELSEIF (cnvtupper(trim(substring(1,1,piece(r.line,delim,1,notfnd,3))))="N")
       str = piece(r.line,delim,12,notfnd,3)
       IF (str != notfnd)
        inputigncnt = (inputigncnt+ 1)
        IF (mod(inputigncnt,10)=1)
         stat = alterlist(ignoresyns->syn_list,(inputigncnt+ 9))
        ENDIF
        ignoresyns->syn_list[inputigncnt].synonym_id = cnvtreal(str), ignoresyns->syn_list[
        inputigncnt].insert_ind = 1
       ENDIF
      ELSE
       inputerrorcnt = (inputerrorcnt+ 1), retval = 0
      ENDIF
     ENDIF
    FOOT REPORT
     IF (mod(inputupdtcnt,10) != 0)
      stat = alterlist(updtsyns->syn_list,inputupdtcnt)
     ENDIF
     IF (mod(inputigncnt,10) != 0)
      stat = alterlist(ignoresyns->syn_list,inputigncnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","updtSyns record after being populated by readInputCSV()")
    CALL echorecord(updtsyns,logfilename,1)
    CALL addlogmsg("INFO","ignoreSyns record after being populated by readInputCSV()")
    CALL echorecord(ignoresyns,logfilename,1)
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (debug_ind=1)
  CALL createlogfile(logfilename)
 ENDIF
 IF (status="F")
  CALL echo("Failed executing script")
  CALL echo(statusstr)
  ROLLBACK
 ENDIF
 SET last_mod = "012"
END GO
