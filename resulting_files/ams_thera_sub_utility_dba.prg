CREATE PROGRAM ams_thera_sub_utility:dba
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
 DECLARE extractcodesetsmode(null) = null WITH protect
 DECLARE extracttherasubsmode(null) = null WITH protect
 DECLARE readinputfile(filename=vc) = null WITH protect
 DECLARE getcodevalues(null) = i4 WITH protect
 DECLARE loadrequest(null) = null WITH protect
 DECLARE createduplicatecsv(filename=vc) = null WITH protect
 DECLARE createerrorcsv(filename=vc) = null WITH protect
 DECLARE getformularystatusindicators(null) = null WITH protect
 DECLARE getvirtualviews(null) = null WITH protect
 DECLARE setformularystatusindicator(null) = null WITH protect
 DECLARE setvirtualview(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE validatedata(null) = i4 WITH protect
 DECLARE rollbackchanges(null) = null WITH protect
 DECLARE createcodevalueextracts(null) = null WITH protect
 DECLARE createtherasubextract(filename=vc) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                    AMS Therapeutic Substitution Utility                    ")
 DECLARE detail_line = c75 WITH protect, constant(
  "             Create synonym to synonym therapeutic substitutions            ")
 DECLARE script_name = c21 WITH protect, constant("AMS_THERA_SUB_UTILITY")
 DECLARE volume_dose = i2 WITH protect, constant(1)
 DECLARE strength_dose = i2 WITH protect, constant(2)
 DECLARE pharm_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE syn_type_rx_mnem_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC")
  )
 DECLARE syn_type_y_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE from_table_exists = i2 WITH protect, constant(checkdic("RX_THERAP_SBSTTN_FROM","T",0))
 DECLARE to_table_exists = i2 WITH protect, constant(checkdic("RX_THERAP_SBSTTN_TO","T",0))
 DECLARE formulary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4512,"FORMULARY"))
 DECLARE non_formulary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4512,"NONFORMULARY"))
 DECLARE from_str = vc WITH protect, constant("ams_thera_sub_utility@cerner.com")
 DECLARE syns_extract_file = vc WITH protect, constant("sub_syns.csv")
 DECLARE routes_extract_file = vc WITH protect, constant("sub_routes.csv")
 DECLARE forms_extract_file = vc WITH protect, constant("sub_forms.csv")
 DECLARE uoms_extract_file = vc WITH protect, constant("sub_uoms.csv")
 DECLARE freqs_extract_file = vc WITH protect, constant("sub_freqs.csv")
 DECLARE facs_extract_file = vc WITH protect, constant("sub_facilities.csv")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE therasubextractfilename = vc WITH protect, noconstant(" ")
 DECLARE newmodelind = i2 WITH protect
 DECLARE addcnt = i4 WITH protect
 DECLARE cclerror = vc WITH protect
 DECLARE emailfailstr = vc WITH protect, constant("Email failed. Manually grab file from CCLUSERDIR")
 SET logfilename = concat("ams_thera_sub_utility",cnvtlower(format(cnvtdatetime(curdate,curtime3),
    "dd_mmm_yyyy_hh_mm;;q")),".log")
 SET therasubextractfilename = cnvtlower(concat(getclient(null),"_",trim(curdomain),"_thera_subs.csv"
   ))
 RECORD import_data(
   1 list[*]
     2 therap_sbsttn_from_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 error_ind = i2
     2 error_str = vc
     2 from_syn_disp = vc
     2 from_syn_id = f8
     2 from_syn_cat_cd = f8
     2 from_syn_primary_disp = vc
     2 from_syn_formulary_status_cd = f8
     2 from_virtual_view_ind = i2
     2 from_multi_syn_ind = i2
     2 from_route_disp = vc
     2 from_route_cd = f8
     2 from_form_disp = vc
     2 from_form_cd = f8
     2 from_dose_type_ind = i2
     2 from_dose = f8
     2 from_dose_unit_disp = vc
     2 from_dose_unit_cd = f8
     2 from_freq_disp = vc
     2 from_freq_cd = f8
     2 to_multi_syn_ind = i2
     2 to_list[*]
       3 therap_sbsttn_to_id = f8
       3 to_syn_disp = vc
       3 to_syn_id = f8
       3 to_syn_cat_cd = f8
       3 to_syn_formulary_status_cd = f8
       3 to_virtual_view_ind = i2
       3 to_route_disp = vc
       3 to_route_cd = f8
       3 to_form_disp = vc
       3 to_form_cd = f8
       3 to_dose_type_ind = i2
       3 to_dose = f8
       3 to_dose_unit_disp = vc
       3 to_dose_unit_cd = f8
       3 to_freq_disp = vc
       3 to_freq_cd = f8
     2 required_ind = i2
     2 retain_det_ind = i2
     2 comments = vc
     2 facility_disp = vc
     2 facility_cd = f8
 ) WITH protect
 RECORD duplicate_syns(
   1 list[*]
     2 from_multi_syn_ind = i2
     2 to_multi_syn_ind = i2
     2 from_syn_disp = vc
     2 from_route_disp = vc
     2 from_form_disp = vc
     2 from_dose = f8
     2 from_dose_unit_disp = vc
     2 from_freq_disp = vc
     2 to_list[*]
       3 to_syn_disp = vc
       3 to_route_disp = vc
       3 to_form_disp = vc
       3 to_dose = f8
       3 to_dose_unit_disp = vc
       3 to_freq_disp = vc
     2 required_ind = i2
     2 retain_det_ind = i2
     2 comments = vc
     2 facility_disp = vc
 ) WITH protect
 RECORD tsub_ids(
   1 id_qual[*]
     2 therap_sbsttn_id = f8
 ) WITH protect
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 RECORD sub_reply(
   1 substitution_list[*]
     2 internal_id = i4
     2 therap_sbsttn_id = f8
     2 action_flag = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD vv_updts(
   1 list[*]
     2 synonym_id = f8
     2 facility_cd = f8
 ) WITH protect
 RECORD status_updts(
   1 list[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 formulary_status = f8
     2 updt_ind = i2
 ) WITH protect
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 RECORD sub_request(
   1 add_cnt = i2
   1 upd_cnt = i2
   1 substitution_list[*]
     2 internal_id = i4
     2 therap_sbsttn_id = f8
     2 action_flag = i4
     2 from_catalog_cd = f8
     2 from_synonym_id = f8
     2 from_item_id = f8
     2 facility_cd = f8
     2 venue_cd = f8
     2 from_str = f8
     2 from_str_unit_cd = f8
     2 from_vol = f8
     2 from_vol_unit_cd = f8
     2 from_route_cd = f8
     2 from_freq_cd = f8
     2 substitution_toitems_list[*]
       3 to_catalog_cd = f8
       3 to_synonym_id = f8
       3 to_item_id = f8
       3 to_str = f8
       3 to_str_unit_cd = f8
       3 to_vol = f8
       3 to_vol_unit_cd = f8
       3 to_route_cd = f8
       3 to_freq_cd = f8
       3 to_form_cd = f8
     2 substitution_action_flag = f8
     2 comment_text = vc
     2 active_ind = i4
     2 retain_details_ind = i4
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 from_form_cd = f8
     2 to_order_sentence_id = f8
 ) WITH protect
 IF (from_table_exists > 1
  AND to_table_exists > 1)
  SET newmodelind = 1
 ELSE
  SET newmodelind = 0
 ENDIF
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_thera_sub_utility")
  CALL addlogmsg("INFO",build2("newModelInd = ",newmodelind))
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 4),(soffcol+ 26),"1 Import therapeutic substitutions")
 CALL text((soffrow+ 5),(soffcol+ 26),"2 Create data collection extracts")
 CALL text((soffrow+ 6),(soffcol+ 26),"3 Extract therapeutic substitutions")
 CALL text((soffrow+ 7),(soffcol+ 26),"4 Exit")
 CALL accept(quesrow,(soffcol+ 18),"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   CALL importmode(null)
  OF 2:
   CALL extractcodesetsmode(null)
  OF 3:
   CALL extracttherasubsmode(null)
  OF 4:
   GO TO exit_script
 ENDCASE
 SUBROUTINE importmode(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE done = i2 WITH protect
   DECLARE dupfilename = vc WITH protect, noconstant(trim(concat("dup_syns_",trim(cnvtlower(curdomain
        )),".csv")))
   DECLARE invalidfilename = vc WITH protect, noconstant(trim(concat("invalid_subs_",trim(cnvtlower(
        curdomain)),".csv")))
   CALL clearscreen(null)
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter filename to read substitutions from:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C")
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET stat = findfile(curaccept)
      IF (stat=1)
       CALL clear((soffrow+ 2),soffcol,numcols)
       SET done = 1
       CALL text((soffrow+ 2),soffcol,"Reading substitutions from file...")
       CALL readinputfile(curaccept)
       CALL text((soffrow+ 2),(soffcol+ 34),"done")
       CALL text((soffrow+ 3),soffcol,"Checking for duplicate synonyms...")
       SET errorcnt = getcodevalues(null)
       CALL loadrequest(null)
       IF (errorcnt=0)
        CALL text((soffrow+ 3),(soffcol+ 34),"done")
        CALL text((soffrow+ 4),soffcol,"Checking for invalid substitutions...")
        SET errorcnt = validatedata(null)
        IF (errorcnt=0)
         CALL text((soffrow+ 4),(soffcol+ 37),"done")
         CALL text((soffrow+ 5),soffcol,"Importing substitutions...")
         CALL performupdates(null)
         CALL text(quesrow,soffcol,"Commit?:")
         CALL accept(quesrow,(soffcol+ 8),"A;CU"
          WHERE curaccept IN ("Y", "N"))
         IF (curaccept="Y")
          COMMIT
          SET trace = nocallecho
          CALL updtdminfo(script_name,cnvtreal(addcnt))
          SET trace = callecho
         ELSE
          ROLLBACK
          CALL rollbackchanges(null)
         ENDIF
        ELSE
         CALL text((soffrow+ 5),soffcol,
          "Invalid substitutions found. At least one of the substitutions in the file")
         CALL text((soffrow+ 6),soffcol,"has data integrity issues.")
         SET done = 0
         WHILE (done=0)
           CALL text((soffrow+ 7),soffcol,"Enter filename to export invalid substitutions to:")
           CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",invalidfilename)
           IF (cnvtupper(curaccept)="*.CSV*")
            CALL clear((soffrow+ 9),soffcol,numcols)
            SET done = 1
            SET invalidfilename = trim(cnvtlower(curaccept))
            CALL createerrorcsv(invalidfilename)
            CALL text((soffrow+ 9),soffcol,"Do you want to email the file?:")
            CALL accept((soffrow+ 9),(soffcol+ 31),"A;CU","Y"
             WHERE curaccept IN ("Y", "N"))
            IF (curaccept="Y")
             CALL text((soffrow+ 10),soffcol,"Enter recepient's email address:")
             CALL accept((soffrow+ 11),(soffcol+ 1),"P(74);C",gethnaemail(null)
              WHERE trim(curaccept)="*@*.*")
             IF (emailfile(curaccept,from_str,"","",invalidfilename))
              CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
             ELSE
              CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
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
        CALL text((soffrow+ 4),soffcol,
         "Duplicate synonym(s) found. At least one of the synonyms in the file has a")
        CALL text((soffrow+ 5),soffcol,
         "mnemonic that exists more than once in the domain. You must specify")
        CALL text((soffrow+ 6),soffcol,
         "synonym_ids for these synonyms in the last two columns of the import file.")
        SET done = 0
        WHILE (done=0)
          CALL text((soffrow+ 7),soffcol,"Enter filename to export duplicate synonyms to:")
          CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",dupfilename)
          IF (cnvtupper(curaccept)="*.CSV*")
           CALL clear((soffrow+ 9),soffcol,numcols)
           SET done = 1
           SET dupfilename = trim(cnvtlower(curaccept))
           CALL createduplicatecsv(dupfilename)
           CALL text((soffrow+ 9),soffcol,"Do you want to email the file?:")
           CALL accept((soffrow+ 9),(soffcol+ 31),"A;CU","Y"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            CALL text((soffrow+ 10),soffcol,"Enter recepient's email address:")
            CALL accept((soffrow+ 11),(soffcol+ 1),"P(74);C",gethnaemail(null)
             WHERE trim(curaccept)="*@*.*")
            IF (emailfile(curaccept,from_str,"","",dupfilename))
             CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
            ELSE
             CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
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
 SUBROUTINE extractcodesetsmode(null)
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Creating extract files...")
   CALL createcodevalueextracts(null)
   CALL text(soffrow,(soffcol+ 25),"done")
   CALL text((soffrow+ 1),soffcol,"Do you want to email the files?:")
   CALL accept((soffrow+ 1),(soffcol+ 32),"A;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text((soffrow+ 2),soffcol,"Enter recepient's email address:")
    CALL accept((soffrow+ 3),(soffcol+ 1),"P(74);C",gethnaemail(null)
     WHERE trim(curaccept)="*@*.*")
    IF (emailfile(curaccept,from_str,"","",syns_extract_file))
     IF (emailfile(curaccept,from_str,"","",routes_extract_file))
      IF (emailfile(curaccept,from_str,"","",forms_extract_file))
       IF (emailfile(curaccept,from_str,"","",uoms_extract_file))
        IF (emailfile(curaccept,from_str,"","",freqs_extract_file))
         IF (emailfile(curaccept,from_str,"","",facs_extract_file))
          CALL text((soffrow+ 14),soffcol,"Emailed files successfully")
         ELSE
          CALL text((soffrow+ 14),soffcol,emailfailstr)
         ENDIF
        ELSE
         CALL text((soffrow+ 14),soffcol,emailfailstr)
        ENDIF
       ELSE
        CALL text((soffrow+ 14),soffcol,emailfailstr)
       ENDIF
      ELSE
       CALL text((soffrow+ 14),soffcol,emailfailstr)
      ENDIF
     ELSE
      CALL text((soffrow+ 14),soffcol,emailfailstr)
     ENDIF
    ELSE
     CALL text((soffrow+ 14),soffcol,emailfailstr)
    ENDIF
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE extracttherasubsmode(null)
   DECLARE finished = i2 WITH protect
   CALL clearscreen(null)
   WHILE (finished=0)
     CALL text(soffrow,soffcol,"Enter filename to create in CCLUSERDIR (or MINE):")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C",therasubextractfilename)
     IF (((cnvtupper(curaccept)="*.CSV") OR (cnvtupper(curaccept)="MINE")) )
      SET therasubextractfilename = trim(cnvtlower(curaccept))
      CALL clear((soffrow+ 2),soffcol,numcols)
      CALL createtherasubextract(therasubextractfilename)
      IF (therasubextractfilename != "mine")
       CALL text((soffrow+ 2),soffcol,"The file has successfully been created in CCLUSERDIR")
       CALL text((soffrow+ 3),soffcol,"Do you want to email the file?:")
       CALL accept((soffrow+ 3),(soffcol+ 31),"A;CU","Y"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        CALL text((soffrow+ 4),soffcol,"Enter recepient's email address:")
        CALL accept((soffrow+ 5),(soffcol+ 1),"P(74);C",gethnaemail(null)
         WHERE trim(curaccept)="*@*.*")
        IF (emailfile(curaccept,from_str,"","",therasubextractfilename))
         CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
        ELSE
         CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
        ENDIF
        CALL text(quesrow,soffcol,"Continue?:")
        CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
         WHERE curaccept IN ("Y"))
        SET finished = 1
       ELSE
        SET finished = 1
       ENDIF
      ELSE
       GO TO main_menu
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text((soffrow+ 2),soffcol,"Output file must be MINE or have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE readinputfile(filename)
   DECLARE from_syn_pos = i2 WITH protect, constant(1)
   DECLARE from_route_pos = i2 WITH protect, constant(2)
   DECLARE from_form_pos = i2 WITH protect, constant(3)
   DECLARE from_dose_pos = i2 WITH protect, constant(4)
   DECLARE from_dose_unit_pos = i2 WITH protect, constant(5)
   DECLARE from_freq_pos = i2 WITH protect, constant(6)
   DECLARE to_syn_pos = i2 WITH protect, constant(7)
   DECLARE to_route_pos = i2 WITH protect, constant(8)
   DECLARE to_form_pos = i2 WITH protect, constant(9)
   DECLARE to_dose_pos = i2 WITH protect, constant(10)
   DECLARE to_dose_unit_pos = i2 WITH protect, constant(11)
   DECLARE to_freq_pos = i2 WITH protect, constant(12)
   DECLARE required_ind_pos = i2 WITH protect, constant(13)
   DECLARE retain_det_ind_pos = i2 WITH protect, constant(14)
   DECLARE comments_pos = i2 WITH protect, constant(15)
   DECLARE facility_pos = i2 WITH protect, constant(16)
   DECLARE from_syn_id_pos = i2 WITH protect, constant(17)
   DECLARE to_syn_id_pos = i2 WITH protect, constant(18)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE tocnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0, firstrow = 1
    DETAIL
     IF (firstrow != 1
      AND trim(piece(r.line,delim,from_syn_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,from_syn_pos,notfnd,3))) > 0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(import_data->list,(cnt+ 99))
      ENDIF
      stat = alterlist(import_data->list[cnt].to_list,1), piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF from_syn_pos:
          import_data->list[cnt].from_syn_disp = trim(str)
         OF from_route_pos:
          import_data->list[cnt].from_route_disp = trim(str)
         OF from_form_pos:
          import_data->list[cnt].from_form_disp = trim(str)
         OF from_dose_pos:
          import_data->list[cnt].from_dose = cnvtreal(str)
         OF from_dose_unit_pos:
          import_data->list[cnt].from_dose_unit_disp = trim(str)
         OF from_freq_pos:
          import_data->list[cnt].from_freq_disp = trim(str)
         OF to_syn_pos:
          import_data->list[cnt].to_list[1].to_syn_disp = trim(str)
         OF to_route_pos:
          import_data->list[cnt].to_list[1].to_route_disp = trim(str)
         OF to_form_pos:
          import_data->list[cnt].to_list[1].to_form_disp = trim(str)
         OF to_dose_pos:
          import_data->list[cnt].to_list[1].to_dose = cnvtreal(str)
         OF to_dose_unit_pos:
          import_data->list[cnt].to_list[1].to_dose_unit_disp = trim(str)
         OF to_freq_pos:
          import_data->list[cnt].to_list[1].to_freq_disp = trim(str)
         OF required_ind_pos:
          IF (cnvtupper(trim(str))="YES")
           import_data->list[cnt].required_ind = 1
          ENDIF
         OF retain_det_ind_pos:
          IF (cnvtupper(trim(str))="YES")
           import_data->list[cnt].retain_det_ind = 1
          ENDIF
         OF comments_pos:
          import_data->list[cnt].comments = trim(str)
         OF facility_pos:
          import_data->list[cnt].facility_disp = trim(str)
         OF from_syn_id_pos:
          import_data->list[cnt].from_syn_id = cnvtreal(str)
         OF to_syn_id_pos:
          import_data->list[cnt].to_list[1].to_syn_id = cnvtreal(str)
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSEIF (firstrow=1
      AND trim(piece(r.line,delim,from_syn_pos,notfnd,3)) > " ")
      firstrow = 0
     ELSEIF (firstrow=0
      AND textlen(trim(piece(r.line,delim,from_syn_pos,notfnd,3)))=0
      AND trim(piece(r.line,delim,to_syn_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,to_syn_pos,notfnd,3))) > 0)
      tocnt = (size(import_data->list[cnt].to_list,5)+ 1), stat = alterlist(import_data->list[cnt].
       to_list,tocnt), piecenum = to_syn_pos,
      str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF to_syn_pos:
          import_data->list[cnt].to_list[tocnt].to_syn_disp = trim(str)
         OF to_route_pos:
          import_data->list[cnt].to_list[tocnt].to_route_disp = trim(str)
         OF to_form_pos:
          import_data->list[cnt].to_list[tocnt].to_form_disp = trim(str)
         OF to_dose_pos:
          import_data->list[cnt].to_list[tocnt].to_dose = cnvtreal(str)
         OF to_dose_unit_pos:
          import_data->list[cnt].to_list[tocnt].to_dose_unit_disp = trim(str)
         OF to_freq_pos:
          import_data->list[cnt].to_list[tocnt].to_freq_disp = trim(str)
         OF to_syn_id_pos:
          import_data->list[cnt].to_list[tocnt].to_syn_id = cnvtreal(str)
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
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
 SUBROUTINE getcodevalues(null)
   DECLARE dupcnt = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE num = i4 WITH protect
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Starting getCodeValues()")
   ENDIF
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.catalog_cd
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
     (dummyt d2  WITH seq = 1),
     order_catalog_synonym ocs
    PLAN (d1
     WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
     JOIN (d2)
     JOIN (ocs
     WHERE ocs.catalog_type_cd=pharm_cat_type_cd
      AND ocs.active_ind=1
      AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx_mnem_cd, syn_type_y_cd, syn_type_z_cd))
      AND (((ocs.synonym_id=import_data->list[d1.seq].from_syn_id)
      AND ocs.mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].from_syn_disp)) OR ((ocs
     .synonym_id=import_data->list[d1.seq].to_list[d2.seq].to_syn_id)
      AND ocs.mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_syn_disp))) )
    DETAIL
     IF ((ocs.synonym_id=import_data->list[d1.seq].from_syn_id))
      import_data->list[d1.seq].from_syn_cat_cd = ocs.catalog_cd
     ELSEIF ((ocs.synonym_id=import_data->list[d1.seq].to_list[d2.seq].to_syn_id))
      import_data->list[d1.seq].to_list[d2.seq].to_syn_cat_cd = ocs.catalog_cd
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ocs.mnemonic_key_cap, syn_cnt = count(ocs.synonym_id)
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
     (dummyt d2  WITH seq = 1),
     order_catalog_synonym ocs
    PLAN (d1
     WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5))
      AND (import_data->list[d1.seq].from_syn_id=0.0))
     JOIN (d2
     WHERE (import_data->list[d1.seq].to_list[d2.seq].to_syn_id=0.0))
     JOIN (ocs
     WHERE ocs.catalog_type_cd=pharm_cat_type_cd
      AND ocs.active_ind=1
      AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx_mnem_cd, syn_type_y_cd, syn_type_z_cd))
      AND ((ocs.mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].from_syn_disp)) OR (ocs
     .mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_syn_disp))) )
    GROUP BY ocs.mnemonic_key_cap
    HAVING count(ocs.synonym_id) > 1
    DETAIL
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build2("duplicate mnemonic: ",ocs.mnemonic_key_cap))
     ENDIF
     dupcnt = (dupcnt+ 1), num = locateval(i,1,size(import_data->list,5),ocs.mnemonic_key_cap,
      cnvtupper(import_data->list[i].from_syn_disp),
      0.0,import_data->list[i].from_syn_id)
     WHILE (num > 0)
       import_data->list[num].from_multi_syn_ind = 1, num = (num+ 1), num = locateval(i,num,size(
         import_data->list,5),ocs.mnemonic_key_cap,cnvtupper(import_data->list[i].from_syn_disp),
        0.0,import_data->list[i].from_syn_id)
     ENDWHILE
     FOR (i = 1 TO size(import_data->list,5))
      num = locateval(j,1,size(import_data->list[i].to_list,5),ocs.mnemonic_key_cap,cnvtupper(
        import_data->list[i].to_list[j].to_syn_disp),
       0.0,import_data->list[i].to_list[j].to_syn_id),
      IF (num > 0)
       import_data->list[i].to_multi_syn_ind = 1
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build2("dupCnt = ",dupcnt))
    CALL addlogmsg("INFO","import_data record after looking for duplicates")
    CALL echorecord(import_data,logfilename,1)
   ENDIF
   IF (dupcnt=0)
    SELECT INTO "nl:"
     ocs.mnemonic, ocs.synonym_id, ocs.catalog_cd
     FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
      (dummyt d2  WITH seq = 1),
      order_catalog_synonym ocs
     PLAN (d1
      WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
      JOIN (d2)
      JOIN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_type_cd
       AND ocs.active_ind=1
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx_mnem_cd))
       AND ((ocs.mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].from_syn_disp)) OR (ocs
      .mnemonic_key_cap=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_syn_disp))) )
     DETAIL
      IF (cnvtupper(import_data->list[d1.seq].from_syn_disp)=cnvtupper(ocs.mnemonic))
       import_data->list[d1.seq].from_syn_id = ocs.synonym_id, import_data->list[d1.seq].
       from_syn_cat_cd = ocs.catalog_cd
      ELSEIF (cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_syn_disp)=cnvtupper(ocs.mnemonic
       ))
       import_data->list[d1.seq].to_list[d2.seq].to_syn_id = ocs.synonym_id, import_data->list[d1.seq
       ].to_list[d2.seq].to_syn_cat_cd = ocs.catalog_cd
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
      (dummyt d2  WITH seq = 1),
      code_value cv
     PLAN (d1
      WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
      JOIN (d2)
      JOIN (cv
      WHERE cv.code_set=4001
       AND cv.active_ind=1
       AND ((cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].from_route_disp))) OR (
      cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].to_list[d2.seq].to_route_disp))
      )) )
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].from_route_disp))
       import_data->list[d1.seq].from_route_cd = cv.code_value
      ENDIF
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_route_disp))
       import_data->list[d1.seq].to_list[d2.seq].to_route_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
      (dummyt d2  WITH seq = 1),
      code_value cv
     PLAN (d1
      WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
      JOIN (d2)
      JOIN (cv
      WHERE cv.code_set=4002
       AND cv.active_ind=1
       AND ((cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].from_form_disp))) OR (cv
      .display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].to_list[d2.seq].to_form_disp))))
      )
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].from_form_disp))
       import_data->list[d1.seq].from_form_cd = cv.code_value
      ENDIF
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_form_disp))
       import_data->list[d1.seq].to_list[d2.seq].to_form_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
      (dummyt d2  WITH seq = 1),
      code_value cv,
      code_value_extension cve
     PLAN (d1
      WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
      JOIN (d2)
      JOIN (cv
      WHERE cv.code_set=54
       AND cv.active_ind=1
       AND ((cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].from_dose_unit_disp)))
       OR (cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].to_list[d2.seq].
        to_dose_unit_disp)))) )
      JOIN (cve
      WHERE cve.code_value=cv.code_value
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].from_dose_unit_disp))
       import_data->list[d1.seq].from_dose_unit_cd = cv.code_value
       IF (band(cnvtint(cve.field_value),2) > 0)
        import_data->list[d1.seq].from_dose_type_ind = volume_dose
       ELSEIF (band(cnvtint(cve.field_value),1) > 0)
        import_data->list[d1.seq].from_dose_type_ind = strength_dose
       ENDIF
      ENDIF
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_dose_unit_disp
       ))
       import_data->list[d1.seq].to_list[d2.seq].to_dose_unit_cd = cv.code_value
       IF (band(cnvtint(cve.field_value),2) > 0)
        import_data->list[d1.seq].to_list[d2.seq].to_dose_type_ind = volume_dose
       ELSEIF (band(cnvtint(cve.field_value),1) > 0)
        import_data->list[d1.seq].to_list[d2.seq].to_dose_type_ind = strength_dose
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
      (dummyt d2  WITH seq = 1),
      code_value cv
     PLAN (d1
      WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
      JOIN (d2)
      JOIN (cv
      WHERE cv.code_set=4003
       AND cv.active_ind=1
       AND ((cv.display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].from_freq_disp))) OR (cv
      .display_key=cnvtupper(cnvtalphanum(import_data->list[d1.seq].to_list[d2.seq].to_freq_disp))))
      )
     DETAIL
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].from_freq_disp))
       import_data->list[d1.seq].from_freq_cd = cv.code_value
      ENDIF
      IF (cnvtupper(cv.display)=cnvtupper(import_data->list[d1.seq].to_list[d2.seq].to_freq_disp))
       import_data->list[d1.seq].to_list[d2.seq].to_freq_cd = cv.code_value
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=220
       AND cv.cdf_meaning="FACILITY"
       AND cv.active_ind=1
       AND expand(i,1,size(import_data->list,5),cv.display_key,cnvtupper(cnvtalphanum(import_data->
         list[i].facility_disp))))
     DETAIL
      num = locateval(i,1,size(import_data->list,5),cnvtupper(cv.display),cnvtupper(import_data->
        list[i].facility_disp))
      WHILE (num > 0)
        import_data->list[num].facility_cd = cv.code_value, num = (num+ 1), num = locateval(i,num,
         size(import_data->list,5),cnvtupper(cv.display),cnvtupper(import_data->list[i].facility_disp
          ))
      ENDWHILE
     WITH nocounter
    ;end select
    IF (debug_ind=1)
     CALL addlogmsg("INFO","import_data record after finding code values")
     CALL echorecord(import_data,logfilename,1)
    ENDIF
   ENDIF
   RETURN(dupcnt)
 END ;Subroutine
 SUBROUTINE loadrequest(null)
   DECLARE cnt = i4 WITH protect
   DECLARE dupcnt = i4 WITH protect
   DECLARE tocnt = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE rtfstr1 = vc WITH protect, constant(build2("{\rtf1\ansi\ansicpg1252\uc0\deff0{\fonttbl",
     char(13),char(10),"{\f0\fswiss\fcharset0\fprq2 Arial;}",char(13),
     char(10),"{\f1\froman\fcharset2\fprq2 Symbol;}}",char(13),char(10),
     "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}",
     char(13),char(10),"{\*\generator TX_RTF32 10.1.323.501;}",char(13),char(10),
     "\deftab1134\pard\plain\f0\fs24"))
   DECLARE rtfstr2 = vc WITH protect, constant("\par }")
   DECLARE inpatient_venue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",54732,"INPATIENT"
     ))
   SET addcnt = size(import_data->list,5)
   EXECUTE dm2_dar_get_bulk_seq "tsub_ids->id_qual", addcnt, "therap_sbsttn_id",
   1, "pharmacy_seq"
   FOR (i = 1 TO size(import_data->list,5))
     IF ((import_data->list[i].from_multi_syn_ind=0)
      AND (import_data->list[i].to_multi_syn_ind=0))
      SET cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       SET stat = alterlist(sub_request->substitution_list,(cnt+ 99))
      ENDIF
      SET sub_request->add_cnt = addcnt
      SET sub_request->substitution_list[cnt].therap_sbsttn_id = tsub_ids->id_qual[i].
      therap_sbsttn_id
      SET sub_request->substitution_list[cnt].action_flag = 1
      SET sub_request->substitution_list[cnt].from_catalog_cd = import_data->list[i].from_syn_cat_cd
      SET sub_request->substitution_list[cnt].from_synonym_id = import_data->list[i].from_syn_id
      SET sub_request->substitution_list[cnt].facility_cd = import_data->list[i].facility_cd
      SET sub_request->substitution_list[cnt].venue_cd = inpatient_venue_cd
      IF ((import_data->list[i].from_dose_type_ind=strength_dose))
       SET sub_request->substitution_list[cnt].from_str = import_data->list[i].from_dose
       SET sub_request->substitution_list[cnt].from_str_unit_cd = import_data->list[i].
       from_dose_unit_cd
      ELSEIF ((import_data->list[i].from_dose_type_ind=volume_dose))
       SET sub_request->substitution_list[cnt].from_vol = import_data->list[i].from_dose
       SET sub_request->substitution_list[cnt].from_vol_unit_cd = import_data->list[i].
       from_dose_unit_cd
      ENDIF
      SET sub_request->substitution_list[cnt].from_route_cd = import_data->list[i].from_route_cd
      SET sub_request->substitution_list[cnt].from_freq_cd = import_data->list[i].from_freq_cd
      SET sub_request->substitution_list[cnt].substitution_action_flag = import_data->list[i].
      required_ind
      IF (textlen(trim(import_data->list[i].comments)) > 0)
       IF (findstring("{rtf",import_data->list[i].comments) > 0)
        SET sub_request->substitution_list[cnt].comment_text = trim(import_data->list[i].comments)
       ELSE
        SET sub_request->substitution_list[cnt].comment_text = build2(trim(rtfstr1)," ",trim(
          import_data->list[i].comments),rtfstr2)
       ENDIF
      ENDIF
      SET sub_request->substitution_list[cnt].active_ind = 1
      SET sub_request->substitution_list[cnt].retain_details_ind = import_data->list[i].
      retain_det_ind
      SET sub_request->substitution_list[cnt].begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
      SET sub_request->substitution_list[cnt].end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 23:59:59")
      SET sub_request->substitution_list[cnt].updt_cnt = 0
      SET sub_request->substitution_list[cnt].from_form_cd = import_data->list[i].from_form_cd
      SET tocnt = size(import_data->list[i].to_list,5)
      SET stat = alterlist(sub_request->substitution_list[cnt].substitution_toitems_list,tocnt)
      FOR (j = 1 TO size(import_data->list[i].to_list,5))
        SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_catalog_cd =
        import_data->list[i].to_list[j].to_syn_cat_cd
        SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_synonym_id =
        import_data->list[i].to_list[j].to_syn_id
        IF ((import_data->list[i].to_list[j].to_dose_type_ind=volume_dose))
         SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_vol = import_data->
         list[i].to_list[j].to_dose
         SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_vol_unit_cd =
         import_data->list[i].to_list[j].to_dose_unit_cd
        ELSEIF ((import_data->list[i].to_list[j].to_dose_type_ind=strength_dose))
         SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_str = import_data->
         list[i].to_list[j].to_dose
         SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_str_unit_cd =
         import_data->list[i].to_list[j].to_dose_unit_cd
        ENDIF
        SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_route_cd =
        import_data->list[i].to_list[j].to_route_cd
        SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_freq_cd = import_data
        ->list[i].to_list[j].to_freq_cd
        SET sub_request->substitution_list[cnt].substitution_toitems_list[j].to_form_cd = import_data
        ->list[i].to_list[j].to_form_cd
      ENDFOR
     ELSE
      SET addcnt = (addcnt - 1)
      SET sub_request->add_cnt = addcnt
      SET dupcnt = (dupcnt+ 1)
      SET tocnt = size(import_data->list[i].to_list,5)
      SET stat = alterlist(duplicate_syns->list,dupcnt)
      SET stat = alterlist(duplicate_syns->list[dupcnt].to_list,tocnt)
      SET duplicate_syns->list[dupcnt].from_multi_syn_ind = import_data->list[i].from_multi_syn_ind
      SET duplicate_syns->list[dupcnt].to_multi_syn_ind = import_data->list[i].to_multi_syn_ind
      SET duplicate_syns->list[dupcnt].from_syn_disp = import_data->list[i].from_syn_disp
      SET duplicate_syns->list[dupcnt].from_route_disp = import_data->list[i].from_route_disp
      SET duplicate_syns->list[dupcnt].from_form_disp = import_data->list[i].from_form_disp
      SET duplicate_syns->list[dupcnt].from_dose = import_data->list[i].from_dose
      SET duplicate_syns->list[dupcnt].from_dose_unit_disp = import_data->list[i].from_dose_unit_disp
      SET duplicate_syns->list[dupcnt].from_freq_disp = import_data->list[i].from_freq_disp
      FOR (j = 1 TO tocnt)
        SET duplicate_syns->list[dupcnt].to_list[j].to_syn_disp = import_data->list[i].to_list[j].
        to_syn_disp
        SET duplicate_syns->list[dupcnt].to_list[j].to_route_disp = import_data->list[i].to_list[j].
        to_route_disp
        SET duplicate_syns->list[dupcnt].to_list[j].to_form_disp = import_data->list[i].to_list[j].
        to_form_disp
        SET duplicate_syns->list[dupcnt].to_list[j].to_dose = import_data->list[i].to_list[j].to_dose
        SET duplicate_syns->list[dupcnt].to_list[j].to_dose_unit_disp = import_data->list[i].to_list[
        j].to_dose_unit_disp
        SET duplicate_syns->list[dupcnt].to_list[j].to_freq_disp = import_data->list[i].to_list[j].
        to_freq_disp
      ENDFOR
      SET duplicate_syns->list[dupcnt].required_ind = import_data->list[i].required_ind
      SET duplicate_syns->list[dupcnt].retain_det_ind = import_data->list[i].retain_det_ind
      SET duplicate_syns->list[dupcnt].comments = import_data->list[i].comments
      SET duplicate_syns->list[dupcnt].facility_disp = import_data->list[i].facility_disp
     ENDIF
   ENDFOR
   SET stat = alterlist(sub_request->substitution_list,cnt)
 END ;Subroutine
 SUBROUTINE createduplicatecsv(filename)
  SELECT INTO value(filename)
   DETAIL
    row 0, col 0,
    "At least one of the synonyms in each substitution below is duplicated in the domain.",
    row + 1, col 0,
    "Review the duplicates and add the correct synonym_id to the import sheet before running the import again."
   WITH pcformat('"',delim), maxcol = 20000, maxrow = 1
  ;end select
  SELECT INTO value(filename)
   error_message =
   IF ((duplicate_syns->list[d1.seq].from_multi_syn_ind=1))
    "Multiple synonyms exist with same name as FROM synonym."
   ELSEIF ((duplicate_syns->list[d1.seq].to_multi_syn_ind=1))
    "Multiple synonyms exist with same name as TO synonym."
   ENDIF
   , from_synonym = substring(1,100,duplicate_syns->list[d1.seq].from_syn_disp), from_route =
   substring(1,100,duplicate_syns->list[d1.seq].from_route_disp),
   from_dosage_form = substring(1,100,duplicate_syns->list[d1.seq].from_form_disp), from_dose =
   duplicate_syns->list[d1.seq].from_dose, from_dose_unit = substring(1,100,duplicate_syns->list[d1
    .seq].from_dose_unit_disp),
   from_freq = substring(1,100,duplicate_syns->list[d1.seq].from_freq_disp), to_synonym = substring(1,
    100,duplicate_syns->list[d1.seq].to_list[d2.seq].to_syn_disp), to_route = substring(1,100,
    duplicate_syns->list[d1.seq].to_list[d2.seq].to_route_disp),
   to_dosage_form = substring(1,100,duplicate_syns->list[d1.seq].to_list[d2.seq].to_form_disp),
   to_dose = duplicate_syns->list[d1.seq].to_list[d2.seq].to_dose, to_dose_unit = substring(1,100,
    duplicate_syns->list[d1.seq].to_list[d2.seq].to_dose_unit_disp),
   to_freq = substring(1,100,duplicate_syns->list[d1.seq].to_list[d2.seq].to_freq_disp), required =
   evaluate(duplicate_syns->list[d1.seq].required_ind,1,"Yes","No"), retain_details = evaluate(
    duplicate_syns->list[d1.seq].retain_det_ind,1,"Yes","No"),
   comments = substring(1,1000,duplicate_syns->list[d1.seq].comments), facility = substring(1,100,
    duplicate_syns->list[d1.seq].facility_disp), from_synonym_id = " ",
   to_synonym_id = " "
   FROM (dummyt d1  WITH seq = value(size(duplicate_syns->list,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(duplicate_syns->list[d1.seq].to_list,5)))
    JOIN (d2)
   WITH format = stream, pcformat('"',delim,1), format
  ;end select
 END ;Subroutine
 SUBROUTINE createerrorcsv(filename)
  SELECT INTO value(filename)
   DETAIL
    row 0, col 0, "The substitutions below are invalid",
    row + 1, col 0,
    "Review the error message and update the import sheet accordingly before running the import again"
   WITH pcformat('"',delim), maxcol = 20000, maxrow = 1
  ;end select
  SELECT INTO value(filename)
   error_message = substring(1,1000,import_data->list[d1.seq].error_str), from_synonym = substring(1,
    100,import_data->list[d1.seq].from_syn_disp), from_route = substring(1,100,import_data->list[d1
    .seq].from_route_disp),
   from_dosage_form = substring(1,100,import_data->list[d1.seq].from_form_disp), from_dose =
   import_data->list[d1.seq].from_dose, from_dose_unit = substring(1,100,import_data->list[d1.seq].
    from_dose_unit_disp),
   from_freq = substring(1,100,import_data->list[d1.seq].from_freq_disp), to_synonym = substring(1,
    100,import_data->list[d1.seq].to_list[d2.seq].to_syn_disp), to_route = substring(1,100,
    import_data->list[d1.seq].to_list[d2.seq].to_route_disp),
   to_dosage_form = substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_form_disp), to_dose
    = import_data->list[d1.seq].to_list[d2.seq].to_dose, to_dose_unit = substring(1,100,import_data->
    list[d1.seq].to_list[d2.seq].to_dose_unit_disp),
   to_freq = substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_freq_disp), required =
   evaluate(import_data->list[d1.seq].required_ind,1,"Yes","No"), retain_details = evaluate(
    import_data->list[d1.seq].retain_det_ind,1,"Yes","No"),
   comments = substring(1,1000,import_data->list[d1.seq].comments), facility = substring(1,100,
    import_data->list[d1.seq].facility_disp)
   FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5))
     AND (import_data->list[d1.seq].error_ind=1))
    JOIN (d2)
   WITH format = stream, pcformat('"',delim,1), format,
    append
  ;end select
 END ;Subroutine
 SUBROUTINE getformularystatusindicators(null)
   SELECT INTO "nl:"
    offr.synonym_id
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
     (dummyt d2  WITH seq = 1),
     ocs_facility_formulary_r offr
    PLAN (d1
     WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
     JOIN (d2)
     JOIN (offr
     WHERE (((offr.synonym_id=import_data->list[d1.seq].from_syn_id)) OR ((offr.synonym_id=
     import_data->list[d1.seq].to_list[d2.seq].to_syn_id)))
      AND offr.facility_cd IN (0.0, import_data->list[d1.seq].facility_cd))
    DETAIL
     IF ((offr.synonym_id=import_data->list[d1.seq].to_list[d2.seq].to_syn_id))
      import_data->list[d1.seq].to_list[d2.seq].to_syn_formulary_status_cd = offr
      .inpatient_formulary_status_cd
     ELSEIF ((offr.synonym_id=import_data->list[d1.seq].from_syn_id))
      import_data->list[d1.seq].from_syn_formulary_status_cd = offr.inpatient_formulary_status_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getvirtualviews(null)
   SELECT INTO "nl:"
    ofr.synonym_id
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
     (dummyt d2  WITH seq = 1),
     ocs_facility_r ofr
    PLAN (d1
     WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
     JOIN (d2)
     JOIN (ofr
     WHERE (((ofr.synonym_id=import_data->list[d1.seq].from_syn_id)) OR ((ofr.synonym_id=import_data
     ->list[d1.seq].to_list[d2.seq].to_syn_id)))
      AND ofr.facility_cd IN (0.0, import_data->list[d1.seq].facility_cd))
    DETAIL
     IF ((ofr.synonym_id=import_data->list[d1.seq].to_list[d2.seq].to_syn_id))
      import_data->list[d1.seq].to_list[d2.seq].to_virtual_view_ind = 1
     ELSEIF ((ofr.synonym_id=import_data->list[d1.seq].from_syn_id))
      import_data->list[d1.seq].from_virtual_view_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE setformularystatusindicator(null)
   UPDATE  FROM ocs_facility_formulary_r offr,
     (dummyt d  WITH seq = value(size(status_updts->list,5)))
    SET offr.inpatient_formulary_status_cd = status_updts->list[d.seq].formulary_status, offr
     .updt_applctx = reqinfo->updt_applctx, offr.updt_cnt = (offr.updt_cnt+ 1),
     offr.updt_dt_tm = cnvtdatetime(curdate,curtime3), offr.updt_id = reqinfo->updt_id, offr
     .updt_task = - (267)
    PLAN (d
     WHERE (status_updts->list[d.seq].updt_ind=1))
     JOIN (offr
     WHERE (offr.facility_cd=status_updts->list[d.seq].facility_cd)
      AND (offr.synonym_id=status_updts->list[d.seq].synonym_id)
      AND offr.synonym_id != 0.0)
    WITH nocounter
   ;end update
   IF (error(cclerror,0) != 0)
    SET status = "F"
    SET statusmsg = "Error updating ocs_facility_formulary_r"
    GO TO exit_script
   ENDIF
   INSERT  FROM ocs_facility_formulary_r offr,
     (dummyt d  WITH seq = value(size(status_updts->list,5)))
    SET offr.facility_cd = status_updts->list[d.seq].facility_cd, offr.inpatient_formulary_status_cd
      = status_updts->list[d.seq].formulary_status, offr.synonym_id = status_updts->list[d.seq].
     synonym_id,
     offr.ocs_facility_formulary_r_id = seq(reference_seq,nextval), offr
     .outpatient_formulary_status_cd = 0.0, offr.updt_applctx = reqinfo->updt_applctx,
     offr.updt_cnt = 0, offr.updt_dt_tm = cnvtdatetime(curdate,curtime3), offr.updt_id = reqinfo->
     updt_id,
     offr.updt_task = - (267)
    PLAN (d
     WHERE (status_updts->list[d.seq].updt_ind=0)
      AND (status_updts->list[d.seq].synonym_id > 0.0))
     JOIN (offr)
    WITH nocounter
   ;end insert
   IF (error(cclerror,0) != 0)
    SET status = "F"
    SET statusmsg = "Error inserting into ocs_facility_formulary_r"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE setvirtualview(null)
  INSERT  FROM ocs_facility_r ofr,
    (dummyt d  WITH seq = value(size(vv_updts->list,5)))
   SET ofr.facility_cd = vv_updts->list[d.seq].facility_cd, ofr.synonym_id = vv_updts->list[d.seq].
    synonym_id, ofr.updt_applctx = reqinfo->updt_applctx,
    ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->updt_id,
    ofr.updt_task = - (267)
   PLAN (d
    WHERE (vv_updts->list[d.seq].synonym_id > 0.0))
    JOIN (ofr)
   WITH nocounter
  ;end insert
  IF (error(cclerror,0) != 0)
   SET status = "F"
   SET statusmsg = "Error inserting into ocs_facility_r"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE j = i4 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE statuscnt = i4 WITH protect
   DECLARE statuspos = i4 WITH protect
   DECLARE vvcnt = i4 WITH protect
   DECLARE vvpos = i4 WITH protect
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Starting performUpdates()")
    CALL addlogmsg("INFO","sub_request before calling rx_maintain_thera_sub")
    CALL echorecord(sub_request,logfilename,1)
   ENDIF
   SET trace = nocallecho
   EXECUTE rx_maintain_thera_sub  WITH replace("REQUEST",sub_request), replace("REPLY",sub_reply)
   SET trace = callecho
   IF (debug_ind=1)
    CALL addlogmsg("INFO","sub_reply after calling rx_maintain_thera_sub")
    CALL echorecord(sub_reply,logfilename,1)
   ENDIF
   IF ((sub_reply->status_data.status="S"))
    CALL text((soffrow+ 5),(soffcol+ 26),"done")
    SET status = "S"
    CALL getformularystatusindicators(null)
    CALL getvirtualviews(null)
    FOR (i = 1 TO size(import_data->list,5))
      IF ((import_data->list[i].from_syn_formulary_status_cd=0.0))
       SET statuspos = locateval(num,1,size(status_updts->list,5),import_data->list[i].facility_cd,
        status_updts->list[num].facility_cd,
        import_data->list[i].from_syn_id,status_updts->list[num].synonym_id)
       IF (statuspos=0)
        SET statuscnt = (statuscnt+ 1)
        IF (mod(statuscnt,100)=1)
         SET stat = alterlist(status_updts->list,(statuscnt+ 99))
        ENDIF
        SET status_updts->list[statuscnt].facility_cd = import_data->list[i].facility_cd
        SET status_updts->list[statuscnt].formulary_status = non_formulary_cd
        SET status_updts->list[statuscnt].synonym_id = import_data->list[i].from_syn_id
       ENDIF
      ELSEIF ((import_data->list[i].from_syn_formulary_status_cd != non_formulary_cd))
       SET statuspos = locateval(num,1,size(status_updts->list,5),import_data->list[i].facility_cd,
        status_updts->list[num].facility_cd,
        import_data->list[i].from_syn_id,status_updts->list[num].synonym_id)
       IF (statuspos=0)
        SET statuscnt = (statuscnt+ 1)
        IF (mod(statuscnt,100)=1)
         SET stat = alterlist(status_updts->list,(statuscnt+ 99))
        ENDIF
        SET status_updts->list[statuscnt].facility_cd = import_data->list[i].facility_cd
        SET status_updts->list[statuscnt].formulary_status = non_formulary_cd
        SET status_updts->list[statuscnt].synonym_id = import_data->list[i].from_syn_id
        SET status_updts->list[statuscnt].updt_ind = 1
       ENDIF
      ENDIF
      IF ((import_data->list[i].from_virtual_view_ind=0))
       SET vvpos = locateval(num,1,size(vv_updts->list,5),import_data->list[i].facility_cd,vv_updts->
        list[num].facility_cd,
        import_data->list[i].from_syn_id,vv_updts->list[num].synonym_id)
       IF (vvpos=0)
        SET vvcnt = (vvcnt+ 1)
        IF (mod(vvcnt,100)=1)
         SET stat = alterlist(vv_updts->list,(vvcnt+ 99))
        ENDIF
        SET vv_updts->list[vvcnt].facility_cd = import_data->list[i].facility_cd
        SET vv_updts->list[vvcnt].synonym_id = import_data->list[i].from_syn_id
       ENDIF
      ENDIF
      FOR (j = 1 TO size(import_data->list[i].to_list,5))
       IF ((import_data->list[i].to_list[j].to_syn_formulary_status_cd=0.0))
        SET statuspos = locateval(num,1,size(status_updts->list,5),import_data->list[i].facility_cd,
         status_updts->list[num].facility_cd,
         import_data->list[i].to_list[j].to_syn_id,status_updts->list[num].synonym_id)
        IF (statuspos=0)
         SET statuscnt = (statuscnt+ 1)
         IF (mod(statuscnt,100)=1)
          SET stat = alterlist(status_updts->list,(statuscnt+ 99))
         ENDIF
         SET status_updts->list[statuscnt].facility_cd = import_data->list[i].facility_cd
         SET status_updts->list[statuscnt].formulary_status = formulary_cd
         SET status_updts->list[statuscnt].synonym_id = import_data->list[i].to_list[j].to_syn_id
        ENDIF
       ELSEIF ((import_data->list[i].to_list[j].to_syn_formulary_status_cd != formulary_cd))
        SET statuspos = locateval(num,1,size(status_updts->list,5),import_data->list[i].facility_cd,
         status_updts->list[num].facility_cd,
         import_data->list[i].to_list[j].to_syn_id,status_updts->list[num].synonym_id)
        IF (statuspos=0)
         SET statuscnt = (statuscnt+ 1)
         IF (mod(statuscnt,100)=1)
          SET stat = alterlist(status_updts->list,(statuscnt+ 99))
         ENDIF
         SET status_updts->list[statuscnt].facility_cd = import_data->list[i].facility_cd
         SET status_updts->list[statuscnt].formulary_status = formulary_cd
         SET status_updts->list[statuscnt].synonym_id = import_data->list[i].to_list[j].to_syn_id
         SET status_updts->list[statuscnt].updt_ind = 1
        ENDIF
       ENDIF
       IF ((import_data->list[i].to_list[j].to_virtual_view_ind=0))
        SET vvpos = locateval(num,1,size(vv_updts->list,5),import_data->list[i].facility_cd,vv_updts
         ->list[num].facility_cd,
         import_data->list[i].to_list[j].to_syn_id,vv_updts->list[num].synonym_id)
        IF (vvpos=0)
         SET vvcnt = (vvcnt+ 1)
         IF (mod(vvcnt,100)=1)
          SET stat = alterlist(vv_updts->list,(vvcnt+ 99))
         ENDIF
         SET vv_updts->list[vvcnt].facility_cd = import_data->list[i].facility_cd
         SET vv_updts->list[vvcnt].synonym_id = import_data->list[i].to_list[j].to_syn_id
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(status_updts->list,statuscnt)
    SET stat = alterlist(vv_updts->list,vvcnt)
    IF (statuscnt > 0)
     CALL text((soffrow+ 6),soffcol,"Setting formulary status indicators...")
     CALL setformularystatusindicator(null)
     CALL text((soffrow+ 6),(soffcol+ 38),"done")
    ENDIF
    IF (vvcnt > 0)
     CALL text((soffrow+ 7),soffcol,"Setting virtual views...")
     CALL setvirtualview(null)
     CALL text((soffrow+ 7),(soffcol+ 24),"done")
    ENDIF
   ELSE
    SET status = "F"
    SET statusmsg = "Error encountered in rx_maintain_thera_sub"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE validatedata(null)
   DECLARE j = i4 WITH protect
   DECLARE errorcnt = i4 WITH protect
   DECLARE errorstr = vc WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE fromcatcd = f8 WITH protect
   DECLARE tocatcd = f8 WITH protect
   DECLARE num = i4 WITH protect
   IF (newmodelind=0)
    SELECT INTO "nl:"
     r.therap_sbsttn_id
     FROM rx_therap_sbsttn r
     PLAN (r
      WHERE expand(i,1,size(import_data->list,5),r.facility_cd,import_data->list[i].facility_cd,
       r.from_item_id,0.0,r.from_synonym_id,import_data->list[i].from_syn_id,r.from_catalog_cd,
       import_data->list[i].from_syn_cat_cd,r.from_rte_cd,import_data->list[i].from_route_cd,r
       .from_freq_cd,import_data->list[i].from_freq_cd,
       r.from_drug_form_cd,import_data->list[i].from_form_cd))
     DETAIL
      pos = locateval(j,1,size(import_data->list,5),r.facility_cd,import_data->list[j].facility_cd,
       r.from_synonym_id,import_data->list[j].from_syn_id,r.from_catalog_cd,import_data->list[j].
       from_syn_cat_cd,r.from_rte_cd,
       import_data->list[j].from_route_cd,r.from_freq_cd,import_data->list[j].from_freq_cd,r
       .from_drug_form_cd,import_data->list[j].from_form_cd)
      WHILE (pos != 0)
       IF ((((import_data->list[pos].from_dose_type_ind=volume_dose)
        AND (import_data->list[pos].from_dose_unit_cd=r.from_volume_unit_cd)
        AND (import_data->list[pos].from_dose=r.from_volume_value)) OR ((((import_data->list[pos].
       from_dose_type_ind=strength_dose)
        AND (import_data->list[pos].from_dose_unit_cd=r.from_strength_unit_cd)
        AND (import_data->list[pos].from_dose=r.from_strength_value)) OR ((import_data->list[pos].
       from_dose_type_ind=0)
        AND r.from_strength_unit_cd=0.0
        AND r.from_strength_value=0.0
        AND r.from_volume_unit_cd=0.0
        AND r.from_volume_value=0.0)) )) )
        errorcnt = (errorcnt+ 1), import_data->list[pos].error_ind = 1, errorstr = concat(
         "FROM substitution already exists.",
         "Remove row from sheet and modify substitution manually if required."),
        import_data->list[pos].error_str = errorstr
       ENDIF
       ,pos = locateval(j,(pos+ 1),size(import_data->list,5),r.facility_cd,import_data->list[j].
        facility_cd,
        r.from_synonym_id,import_data->list[j].from_syn_id,r.from_catalog_cd,import_data->list[j].
        from_syn_cat_cd,r.from_rte_cd,
        import_data->list[j].from_route_cd,r.from_freq_cd,import_data->list[j].from_freq_cd,r
        .from_drug_form_cd,import_data->list[j].from_form_cd)
      ENDWHILE
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     r.therap_sbsttn_from_id
     FROM rx_therap_sbsttn_from r
     PLAN (r
      WHERE expand(i,1,size(import_data->list,5),r.facility_cd,import_data->list[i].facility_cd,
       r.from_item_id,0.0,r.from_synonym_id,import_data->list[i].from_syn_id,r.from_catalog_cd,
       import_data->list[i].from_syn_cat_cd,r.from_rte_cd,import_data->list[i].from_route_cd,r
       .from_freq_cd,import_data->list[i].from_freq_cd,
       r.from_drug_form_cd,import_data->list[i].from_form_cd))
     DETAIL
      pos = locateval(j,1,size(import_data->list,5),r.facility_cd,import_data->list[j].facility_cd,
       r.from_synonym_id,import_data->list[j].from_syn_id,r.from_catalog_cd,import_data->list[j].
       from_syn_cat_cd,r.from_rte_cd,
       import_data->list[j].from_route_cd,r.from_freq_cd,import_data->list[j].from_freq_cd,r
       .from_drug_form_cd,import_data->list[j].from_form_cd)
      WHILE (pos != 0)
       IF ((((import_data->list[pos].from_dose_type_ind=volume_dose)
        AND (import_data->list[pos].from_dose_unit_cd=r.from_volume_unit_cd)
        AND (import_data->list[pos].from_dose=r.from_volume_value)) OR ((((import_data->list[pos].
       from_dose_type_ind=strength_dose)
        AND (import_data->list[pos].from_dose_unit_cd=r.from_strength_unit_cd)
        AND (import_data->list[pos].from_dose=r.from_strength_value)) OR ((import_data->list[pos].
       from_dose_type_ind=0)
        AND r.from_strength_unit_cd=0.0
        AND r.from_strength_value=0.0
        AND r.from_volume_unit_cd=0.0
        AND r.from_volume_value=0.0)) )) )
        errorcnt = (errorcnt+ 1), import_data->list[pos].error_ind = 1, errorstr = concat(
         "FROM substitution already exists.",
         "Remove row from sheet and modify substitution manually if required."),
        import_data->list[pos].error_str = errorstr
       ENDIF
       ,pos = locateval(j,(pos+ 1),size(import_data->list,5),r.facility_cd,import_data->list[j].
        facility_cd,
        r.from_synonym_id,import_data->list[j].from_syn_id,r.from_catalog_cd,import_data->list[j].
        from_syn_cat_cd,r.from_rte_cd,
        import_data->list[j].from_route_cd,r.from_freq_cd,import_data->list[j].from_freq_cd,r
        .from_drug_form_cd,import_data->list[j].from_form_cd)
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
   FOR (i = 1 TO size(import_data->list,5))
     IF ((((import_data->list[i].from_syn_id=0.0)) OR ((import_data->list[i].from_syn_cat_cd=0.0))) )
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      IF (textlen(import_data->list[i].from_syn_disp) > 0)
       SET errorstr = concat(import_data->list[i].error_str,"FROM synonym not found.")
      ELSE
       SET errorstr = concat(import_data->list[i].error_str,"FROM synonym must be specified.")
      ENDIF
      SET import_data->list[i].error_str = errorstr
     ENDIF
     IF (textlen(import_data->list[i].from_route_disp) > 0
      AND (import_data->list[i].from_route_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      SET errorstr = concat(import_data->list[i].error_str,"FROM route not found.")
      SET import_data->list[i].error_str = errorstr
     ENDIF
     IF (textlen(import_data->list[i].from_form_disp) > 0
      AND (import_data->list[i].from_form_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      SET errorstr = concat(import_data->list[i].error_str,"FROM form not found.")
      SET import_data->list[i].error_str = errorstr
     ENDIF
     IF (textlen(import_data->list[i].from_dose_unit_disp) > 0
      AND (import_data->list[i].from_dose_unit_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      SET errorstr = concat(import_data->list[i].error_str,"FROM dose unit not found.")
      SET import_data->list[i].error_str = errorstr
     ENDIF
     IF (textlen(import_data->list[i].from_freq_disp) > 0
      AND (import_data->list[i].from_freq_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      SET errorstr = concat(import_data->list[i].error_str,"FROM frequency not found.")
      SET import_data->list[i].error_str = errorstr
     ENDIF
     IF ((import_data->list[i].facility_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_ind = 1
      IF (textlen(import_data->list[i].facility_disp) > 0)
       SET errorstr = concat(import_data->list[i].error_str,"Facility not found.")
      ELSE
       SET errorstr = concat(import_data->list[i].error_str,"Facility must be specified.")
      ENDIF
      SET import_data->list[i].error_str = errorstr
     ENDIF
     FOR (j = 1 TO size(import_data->list[i].to_list,5))
       IF ((((import_data->list[i].to_list[j].to_syn_id=0.0)) OR ((import_data->list[i].to_list[j].
       to_syn_cat_cd=0.0))) )
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        IF (textlen(import_data->list[i].to_list[j].to_syn_disp) > 0)
         SET errorstr = concat(import_data->list[i].error_str,"TO synonym not found.")
        ELSE
         SET errorstr = concat(import_data->list[i].error_str,"TO synonym must be specified.")
        ENDIF
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF (textlen(import_data->list[i].to_list[j].to_route_disp) > 0
        AND (import_data->list[i].to_list[j].to_route_cd=0.0))
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO route not found.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF (textlen(import_data->list[i].to_list[j].to_form_disp) > 0
        AND (import_data->list[i].to_list[j].to_form_cd=0.0))
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO form not found.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF (textlen(import_data->list[i].to_list[j].to_dose_unit_disp) > 0
        AND (import_data->list[i].to_list[j].to_dose_unit_cd=0.0))
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO dose unit not found.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF (textlen(import_data->list[i].to_list[j].to_freq_disp) > 0
        AND (import_data->list[i].to_list[j].to_freq_cd=0.0))
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO frequency not found.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].to_list[j].to_route_cd=0.0)
        AND textlen(import_data->list[i].to_list[j].to_route_disp)=0
        AND (import_data->list[i].from_route_cd > 0.0))
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO route must be specified.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].from_route_cd=0.0)
        AND textlen(import_data->list[i].from_route_disp)=0)
        IF ((import_data->list[i].to_list[j].to_route_cd > 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "TO route cannot be specified without FROM route.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((((import_data->list[i].to_list[j].to_form_cd != 0.0)) OR ((import_data->list[i].
        from_form_cd != 0.0))) )
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM form cannot be specified without a FROM route.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((((import_data->list[i].to_list[j].to_dose != 0.0)) OR ((import_data->list[i].from_dose
         != 0.0))) )
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM dose cannot be specified without a FROM route.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((((import_data->list[i].to_list[j].to_dose_unit_cd != 0.0)) OR ((import_data->list[i].
        from_dose_unit_cd != 0.0))) )
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM dose unit cannot be specified without a FROM route.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((((import_data->list[i].to_list[j].to_freq_cd != 0.0)) OR ((import_data->list[i].
        from_freq_cd != 0.0))) )
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM freq cannot be specified without a FROM route.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
       ENDIF
       IF ((import_data->list[i].from_form_cd > 0.0)
        AND (import_data->list[i].to_list[j].to_form_cd=0.0)
        AND textlen(import_data->list[i].to_list[j].to_form_disp)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO form must be specified.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].to_list[j].to_form_cd > 0.0)
        AND (import_data->list[i].from_form_cd=0.0)
        AND textlen(import_data->list[i].from_form_disp)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"FROM form must be specified.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].from_dose != 0.0))
        IF ((import_data->list[i].from_dose_unit_cd=0.0)
         AND textlen(import_data->list[i].from_dose_unit_disp)=0)
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,"FROM dose unit must be specified.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].to_list[j].to_dose=0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,"TO dose must be specified.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].to_list[j].to_dose_unit_cd=0.0)
         AND textlen(import_data->list[i].to_list[j].to_dose_unit_disp)=0)
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,"TO dose unit must be specified.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
       ELSE
        IF ((import_data->list[i].from_dose_unit_cd != 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM dose unit cannot be specified without a FROM dose.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].to_list[j].to_dose != 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "TO dose cannot be specified without a FROM dose.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].to_list[j].to_dose_unit_cd != 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "TO dose unit cannot be specified without a FROM dose.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].from_freq_cd != 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "FROM freq cannot be specified without a FROM dose.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
        IF ((import_data->list[i].to_list[j].to_freq_cd != 0.0))
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_ind = 1
         SET errorstr = concat(import_data->list[i].error_str,
          "TO freq cannot be specified without a FROM dose.")
         SET import_data->list[i].error_str = errorstr
        ENDIF
       ENDIF
       IF ((((import_data->list[i].from_dose < 0.0)) OR ((import_data->list[i].to_list[j].to_dose <
       0.0))) )
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"Dose must be greater than zero.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].from_freq_cd > 0.0)
        AND (import_data->list[i].to_list[j].to_freq_cd=0.0)
        AND textlen(import_data->list[i].to_list[j].to_freq_disp)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"TO freq must be specified.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
       IF ((import_data->list[i].to_list[j].to_freq_cd > 0.0)
        AND (import_data->list[i].from_freq_cd=0.0)
        AND textlen(import_data->list[i].from_freq_disp)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_ind = 1
        SET errorstr = concat(import_data->list[i].error_str,"FROM freq must be specified.")
        SET import_data->list[i].error_str = errorstr
       ENDIF
     ENDFOR
     IF (newmodelind=0)
      SET fromcatcd = import_data->list[i].from_syn_cat_cd
      SET tocatcd = import_data->list[i].to_list[1].to_syn_cat_cd
      IF (tocatcd > 0
       AND fromcatcd > 0)
       SET pos = locateval(num,1,size(import_data->list,5),fromcatcd,import_data->list[num].
        from_syn_cat_cd)
       WHILE (pos > 0)
         FOR (j = 1 TO size(import_data->list[pos].to_list,5))
           IF ((import_data->list[pos].to_list[j].to_syn_cat_cd != tocatcd)
            AND findstring("FROM synonym's primary (",import_data->list[pos].error_str)=0)
            SET errorcnt = (errorcnt+ 1)
            SET import_data->list[pos].error_ind = 1
            SET errorstr = concat(import_data->list[pos].error_str,"FROM synonym's primary (",trim(
              uar_get_code_display(import_data->list[pos].from_syn_cat_cd)),
             ") is specified to substitute to different TO primaries (",trim(uar_get_code_display(
               import_data->list[pos].to_list[j].to_syn_cat_cd)),
             ").")
            SET import_data->list[pos].error_str = errorstr
           ENDIF
         ENDFOR
         SET pos = (pos+ 1)
         SET pos = locateval(num,pos,size(import_data->list,5),fromcatcd,import_data->list[num].
          from_syn_cat_cd)
       ENDWHILE
      ENDIF
     ENDIF
     SET pos = locateval(num,1,size(import_data->list,5),import_data->list[i].facility_cd,import_data
      ->list[num].facility_cd,
      import_data->list[i].from_syn_id,import_data->list[num].from_syn_id,import_data->list[i].
      from_form_cd,import_data->list[num].from_form_cd,import_data->list[i].from_dose,
      import_data->list[num].from_dose,import_data->list[i].from_dose_unit_cd,import_data->list[num].
      from_dose_unit_cd,import_data->list[i].from_route_cd,import_data->list[num].from_route_cd,
      import_data->list[i].from_freq_cd,import_data->list[num].from_freq_cd)
     WHILE (pos > 0)
       IF (pos != i
        AND findstring("Multiple rows exist with",import_data->list[pos].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[pos].error_ind = 1
        SET errorstr = concat(import_data->list[pos].error_str,
         "Multiple rows exist with same FROM data.")
        SET import_data->list[pos].error_str = errorstr
       ENDIF
       SET pos = (pos+ 1)
       SET pos = locateval(num,pos,size(import_data->list,5),import_data->list[i].facility_cd,
        import_data->list[num].facility_cd,
        import_data->list[i].from_syn_id,import_data->list[num].from_syn_id,import_data->list[i].
        from_form_cd,import_data->list[num].from_form_cd,import_data->list[i].from_dose,
        import_data->list[num].from_dose,import_data->list[i].from_dose_unit_cd,import_data->list[num
        ].from_dose_unit_cd,import_data->list[i].from_route_cd,import_data->list[num].from_route_cd,
        import_data->list[i].from_freq_cd,import_data->list[num].from_freq_cd)
     ENDWHILE
   ENDFOR
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE rollbackchanges(null)
   IF (newmodelind=0)
    DELETE  FROM rx_therap_sbsttn r,
      (dummyt d  WITH seq = value(size(sub_reply->substitution_list,5)))
     SET r.seq = 0
     PLAN (d)
      JOIN (r
      WHERE (r.therap_sbsttn_id=sub_reply->substitution_list[d.seq].therap_sbsttn_id)
       AND r.therap_sbsttn_id != 0.0)
     WITH nocounter
    ;end delete
    IF (((curqual != size(sub_reply->substitution_list,5)) OR (error(cclerror,0) != 0)) )
     SET status = "F"
     SET statusstr = build2(
      "Error rolling back changes. Rows have been inserted into rx_therap_sbsttn",
      " and long_text_reference that will need to be manually deleted.")
     GO TO exit_script
    ENDIF
   ELSE
    DELETE  FROM rx_therap_sbsttn_from r,
      (dummyt d  WITH seq = value(size(sub_reply->substitution_list,5)))
     SET r.seq = 0
     PLAN (d)
      JOIN (r
      WHERE (r.therap_sbsttn_from_id=sub_reply->substitution_list[d.seq].therap_sbsttn_id)
       AND r.therap_sbsttn_from_id != 0.0)
     WITH nocounter
    ;end delete
    IF (((curqual != size(sub_reply->substitution_list,5)) OR (error(cclerror,0) != 0)) )
     SET status = "F"
     SET statusstr = build2(
      "Error rolling back changes. Rows have been inserted into rx_therap_sbsttn_from and",
      " rx_therap_sbsttn_to and long_text_reference that will need to be manually deleted.")
     GO TO exit_script
    ENDIF
    DELETE  FROM rx_therap_sbsttn_to r,
      (dummyt d  WITH seq = value(size(sub_reply->substitution_list,5)))
     SET r.seq = 0
     PLAN (d)
      JOIN (r
      WHERE (r.therap_sbsttn_from_id=sub_reply->substitution_list[d.seq].therap_sbsttn_id)
       AND r.therap_sbsttn_from_id != 0.0)
     WITH nocounter
    ;end delete
    IF (error(cclerror,0) != 0)
     SET status = "F"
     SET statusstr = build2(
      "Error rolling back changes. Rows have been inserted into rx_therap_sbsttn_from and",
      " rx_therap_sbsttn_to and long_text_reference that will need to be manually deleted.")
     GO TO exit_script
    ENDIF
   ENDIF
   DELETE  FROM long_text_reference ltr,
     (dummyt d  WITH seq = value(size(sub_reply->substitution_list,5)))
    SET ltr.seq = 0
    PLAN (d)
     JOIN (ltr
     WHERE (ltr.parent_entity_id=sub_reply->substitution_list[d.seq].therap_sbsttn_id)
      AND ltr.parent_entity_name="RX_THERAP_SBSTTN"
      AND ltr.long_text_id != 0.0)
    WITH nocounter
   ;end delete
   IF (error(cclerror,0) != 0)
    SET status = "F"
    SET statusstr = build2(
     "Error rolling back changes. Rows have been inserted into rx_therap_sbsttn",
     " tables and long_text_reference that will need to be manually deleted.")
    GO TO exit_script
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE createcodevalueextracts(null)
   DECLARE building_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
   DECLARE facility_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
   SELECT INTO value(syns_extract_file)
    ocs.mnemonic, ocs.synonym_id
    FROM order_catalog_synonym ocs,
     order_catalog oc
    PLAN (ocs
     WHERE ocs.catalog_type_cd=pharm_cat_type_cd
      AND ocs.active_ind=1
      AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx_mnem_cd, syn_type_y_cd, syn_type_z_cd))
      AND textlen(trim(ocs.mnemonic)) > 0)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1)
    ORDER BY cnvtupper(ocs.mnemonic)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   SELECT INTO value(routes_extract_file)
    cv.display, cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4001
      AND cv.active_ind=1)
    ORDER BY cv.display_key
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   SELECT INTO value(forms_extract_file)
    cv.display, cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4002
      AND cv.active_ind=1)
    ORDER BY cv.display_key
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   SELECT INTO value(uoms_extract_file)
    cv.display, cv.code_value
    FROM code_value cv,
     code_value_extension cve,
     dummyt d
    PLAN (cv
     WHERE cv.code_set=54
      AND cv.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=cv.code_value
      AND cve.code_set=54
      AND cve.field_name="PHARM_UNIT")
     JOIN (d
     WHERE ((band(cnvtint(cve.field_value),1) > 0) OR (band(cnvtint(cve.field_value),2))) )
    ORDER BY cv.display_key
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   SELECT INTO value(freqs_extract_file)
    cv.display, cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4003
      AND cv.active_ind=1)
    ORDER BY cv.display_key
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   SELECT DISTINCT INTO value(facs_extract_file)
    cv2.display, cv2.code_value
    FROM code_value cv,
     location_group lg,
     location_group lg2,
     code_value cv2
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.cdf_meaning="PHARM"
      AND cv.active_ind=1)
     JOIN (lg
     WHERE lg.child_loc_cd=cv.code_value
      AND lg.location_group_type_cd=building_type_cd
      AND lg.active_ind=1
      AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND lg.root_loc_cd=0.0)
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg.parent_loc_cd
      AND lg2.location_group_type_cd=facility_type_cd
      AND lg2.active_ind=1
      AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND lg2.root_loc_cd=0.0)
     JOIN (cv2
     WHERE cv2.code_value=lg2.parent_loc_cd
      AND cv2.code_set=220
      AND cv2.cdf_meaning="FACILITY"
      AND cv2.active_ind=1)
    ORDER BY cv2.display_key
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
 SUBROUTINE createtherasubextract(filename)
   DECLARE commentout = c32000 WITH protect
   DECLARE outidx = i4 WITH protect
   SET stat = initrec(import_data)
   IF (newmodelind=0)
    SELECT INTO "nl:"
     FROM rx_therap_sbsttn r,
      order_catalog_synonym ocs,
      order_catalog oc,
      order_catalog_synonym ocs2,
      long_text_reference ltr
     PLAN (r
      WHERE r.therap_sbsttn_id != 0.0
       AND r.from_synonym_id != 0.0
       AND r.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=r.from_synonym_id)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
      JOIN (ocs2
      WHERE ocs2.synonym_id=r.to_synonym_id)
      JOIN (ltr
      WHERE ltr.long_text_id=outerjoin(r.comment_long_text_id))
     ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic)
     HEAD REPORT
      i = 0
     DETAIL
      i = (i+ 1)
      IF (mod(i,100)=1)
       stat = alterlist(import_data->list,(i+ 99))
      ENDIF
      stat = alterlist(import_data->list[i].to_list,1), import_data->list[i].action_flag = r
      .active_ind, import_data->list[i].beg_effective_dt_tm = r.begin_effective_dt_tm,
      import_data->list[i].end_effective_dt_tm = r.end_effective_dt_tm, import_data->list[i].
      facility_cd = r.facility_cd, import_data->list[i].facility_disp = uar_get_code_display(r
       .facility_cd),
      commentout = "", stat = uar_rtf(ltr.long_text,textlen(ltr.long_text),commentout,32000,outidx,
       1), import_data->list[i].comments = trim(commentout),
      import_data->list[i].retain_det_ind = r.retain_details_ind, import_data->list[i].required_ind
       = r.sbsttn_actn_flag, import_data->list[i].from_freq_cd = r.from_freq_cd,
      import_data->list[i].from_freq_disp = uar_get_code_display(r.from_freq_cd), import_data->list[i
      ].from_dose_unit_cd = evaluate(r.from_strength_unit_cd,0.0,r.from_volume_unit_cd,r
       .from_strength_unit_cd), import_data->list[i].from_dose_unit_disp = uar_get_code_display(
       import_data->list[i].from_dose_unit_cd),
      import_data->list[i].from_dose = evaluate(r.from_strength_unit_cd,0.0,r.from_volume_value,r
       .from_strength_value), import_data->list[i].from_form_cd = r.from_drug_form_cd, import_data->
      list[i].from_form_disp = uar_get_code_display(r.from_drug_form_cd),
      import_data->list[i].from_route_cd = r.from_rte_cd, import_data->list[i].from_route_disp =
      uar_get_code_display(r.from_rte_cd), import_data->list[i].from_syn_disp = ocs.mnemonic,
      import_data->list[i].from_syn_primary_disp = oc.primary_mnemonic, import_data->list[i].to_list[
      1].to_freq_cd = r.to_freq_cd, import_data->list[i].to_list[1].to_freq_disp =
      uar_get_code_display(r.to_freq_cd),
      import_data->list[i].to_list[1].to_dose_unit_cd = evaluate(r.to_strength_unit_cd,0.0,r
       .to_volume_unit_cd,r.to_strength_unit_cd), import_data->list[i].to_list[1].to_dose_unit_disp
       = uar_get_code_display(import_data->list[i].to_list[1].to_dose_unit_cd), import_data->list[i].
      to_list[1].to_dose = evaluate(r.to_strength_unit_cd,0.0,r.to_volume_value,r.to_strength_value),
      import_data->list[i].to_list[1].to_form_cd = r.to_drug_form_cd, import_data->list[i].to_list[1]
      .to_form_disp = uar_get_code_display(r.to_drug_form_cd), import_data->list[i].to_list[1].
      to_route_cd = r.to_rte_cd,
      import_data->list[i].to_list[1].to_route_disp = uar_get_code_display(r.to_rte_cd), import_data
      ->list[i].to_list[1].to_syn_disp = ocs2.mnemonic
     FOOT REPORT
      IF (mod(i,100) != 0)
       stat = alterlist(import_data->list,i)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (newmodelind=1)
    SELECT INTO "nl:"
     route_disp = cnvtupper(uar_get_code_display(rf.from_rte_cd)), form_disp = cnvtupper(
      uar_get_code_display(rf.from_drug_form_cd))
     FROM rx_therap_sbsttn_from rf,
      rx_therap_sbsttn_to rt,
      order_catalog_synonym ocs,
      order_catalog oc,
      order_catalog_synonym ocs2,
      long_text_reference ltr
     PLAN (rf
      WHERE rf.therap_sbsttn_from_id != 0.0
       AND rf.from_synonym_id != 0.0
       AND rf.active_ind=1)
      JOIN (rt
      WHERE rt.therap_sbsttn_from_id=rf.therap_sbsttn_from_id
       AND rt.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=rf.from_synonym_id)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
      JOIN (ocs2
      WHERE ocs2.synonym_id=rt.to_synonym_id)
      JOIN (ltr
      WHERE ltr.long_text_id=outerjoin(rf.comment_long_text_id))
     ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic), rf.therap_sbsttn_from_id,
      route_disp, form_disp, rf.from_strength_value,
      rf.from_volume_value, cnvtupper(ocs2.mnemonic)
     HEAD REPORT
      i = 0
     HEAD rf.therap_sbsttn_from_id
      i = (i+ 1)
      IF (mod(i,100)=1)
       stat = alterlist(import_data->list,(i+ 99))
      ENDIF
      stat = alterlist(import_data->list[i].to_list,1), import_data->list[i].therap_sbsttn_from_id =
      rf.therap_sbsttn_from_id, import_data->list[i].action_flag = rf.active_ind,
      import_data->list[i].beg_effective_dt_tm = rf.begin_effective_dt_tm, import_data->list[i].
      end_effective_dt_tm = rf.end_effective_dt_tm, import_data->list[i].facility_cd = rf.facility_cd,
      import_data->list[i].facility_disp = uar_get_code_display(rf.facility_cd), commentout = "",
      stat = uar_rtf(ltr.long_text,textlen(ltr.long_text),commentout,32000,outidx,
       1),
      import_data->list[i].comments = trim(commentout), import_data->list[i].retain_det_ind = rf
      .retain_details_ind, import_data->list[i].required_ind = rf.sbsttn_actn_flag,
      import_data->list[i].from_freq_cd = rf.from_freq_cd, import_data->list[i].from_freq_disp =
      uar_get_code_display(rf.from_freq_cd), import_data->list[i].from_dose_unit_cd = evaluate(rf
       .from_strength_unit_cd,0.0,rf.from_volume_unit_cd,rf.from_strength_unit_cd),
      import_data->list[i].from_dose_unit_disp = uar_get_code_display(import_data->list[i].
       from_dose_unit_cd), import_data->list[i].from_dose = evaluate(rf.from_strength_unit_cd,0.0,rf
       .from_volume_value,rf.from_strength_value), import_data->list[i].from_form_cd = rf
      .from_drug_form_cd,
      import_data->list[i].from_form_disp = uar_get_code_display(rf.from_drug_form_cd), import_data->
      list[i].from_route_cd = rf.from_rte_cd, import_data->list[i].from_route_disp =
      uar_get_code_display(rf.from_rte_cd),
      import_data->list[i].from_syn_disp = ocs.mnemonic, import_data->list[i].from_syn_primary_disp
       = oc.primary_mnemonic, j = 0
     DETAIL
      j = (j+ 1), stat = alterlist(import_data->list[i].to_list,j), import_data->list[i].to_list[j].
      therap_sbsttn_to_id = rt.therap_sbsttn_to_id,
      import_data->list[i].to_list[j].to_freq_cd = rt.to_freq_cd, import_data->list[i].to_list[j].
      to_freq_disp = uar_get_code_display(rt.to_freq_cd), import_data->list[i].to_list[j].
      to_dose_unit_cd = evaluate(rt.to_strength_unit_cd,0.0,rt.to_volume_unit_cd,rt
       .to_strength_unit_cd),
      import_data->list[i].to_list[j].to_dose_unit_disp = uar_get_code_display(import_data->list[i].
       to_list[j].to_dose_unit_cd), import_data->list[i].to_list[j].to_dose = evaluate(rt
       .to_strength_unit_cd,0.0,rt.to_volume_value,rt.to_strength_value), import_data->list[i].
      to_list[j].to_form_cd = rt.to_drug_form_cd,
      import_data->list[i].to_list[j].to_form_disp = uar_get_code_display(rt.to_drug_form_cd),
      import_data->list[i].to_list[j].to_route_cd = rt.to_rte_cd, import_data->list[i].to_list[j].
      to_route_disp = uar_get_code_display(rt.to_rte_cd),
      import_data->list[i].to_list[j].to_syn_disp = ocs2.mnemonic
     FOOT REPORT
      IF (mod(i,100) != 0)
       stat = alterlist(import_data->list,i)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record in createTheraSubExtract() after being populated")
    CALL echorecord(import_data,logfilename,1)
   ENDIF
   SELECT INTO value(filename)
    from_synonym = evaluate(d2.seq,1,substring(1,100,import_data->list[d1.seq].from_syn_disp),""),
    from_route = evaluate(d2.seq,1,substring(1,100,import_data->list[d1.seq].from_route_disp),""),
    from_dosage_form = evaluate(d2.seq,1,substring(1,100,import_data->list[d1.seq].from_form_disp),""
     ),
    from_dose =
    IF ((import_data->list[d1.seq].from_dose > 0.0)) evaluate(d2.seq,1,cnvtstring(import_data->list[
       d1.seq].from_dose,99,4),"")
    ENDIF
    , from_dose_unit = evaluate(d2.seq,1,substring(1,100,import_data->list[d1.seq].
      from_dose_unit_disp),""), from_freq = evaluate(d2.seq,1,substring(1,100,import_data->list[d1
      .seq].from_freq_disp),""),
    to_synonym = substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_syn_disp), to_route =
    substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_route_disp), to_dosage_form =
    substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_form_disp),
    to_dose =
    IF ((import_data->list[d1.seq].to_list[d2.seq].to_dose > 0.0)) cnvtstring(import_data->list[d1
      .seq].to_list[d2.seq].to_dose,99,4)
    ENDIF
    , to_dose_unit = substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_dose_unit_disp),
    to_freq = substring(1,100,import_data->list[d1.seq].to_list[d2.seq].to_freq_disp),
    required = substring(1,100,evaluate(import_data->list[d1.seq].required_ind,1,"Yes","No")), retain
     = substring(1,100,evaluate(import_data->list[d1.seq].retain_det_ind,1,"Yes","No")), comments =
    substring(1,32000,import_data->list[d1.seq].comments),
    facility = substring(1,100,import_data->list[d1.seq].facility_disp)
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(import_data->list[d1.seq].to_list,5)))
     JOIN (d2)
    ORDER BY cnvtupper(import_data->list[d1.seq].facility_disp), cnvtupper(import_data->list[d1.seq].
      from_syn_primary_disp), import_data->list[d1.seq].therap_sbsttn_from_id,
     d2.seq, import_data->list[d1.seq].to_list[d2.seq].therap_sbsttn_to_id
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  ROLLBACK
  CALL echo(statusstr)
  CALL echo(cclerror)
 ENDIF
 IF (debug_ind=1)
  CALL createlogfile(logfilename)
 ENDIF
 ROLLBACK
 SET last_mod = "007"
END GO
