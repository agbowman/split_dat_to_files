CREATE PROGRAM ams_ndc_matching_audit:dba
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
 DECLARE readinputfile(filename=vc) = i4 WITH protect
 DECLARE createoutputcsv(filename=vc) = null WITH protect
 DECLARE findbestmatch(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                           AMS NDC Matching Audit                           ")
 DECLARE detail_line = c75 WITH protect, constant(
  "               Determine the best product to stack an NDC to                ")
 DECLARE script_name = c24 WITH protect, constant("AMS_NDC_MATCHING_AUDIT")
 DECLARE from_str = vc WITH protect, constant("ams_ndc_matching_audit@cerner.com")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE emailfailstr = vc WITH protect, constant("Email failed. Manually grab file from CCLUSERDIR")
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE ndc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE desc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE rxmisc3_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC3"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE sys_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE multiple_matches = i2 WITH protect, constant(1)
 DECLARE non_reference = i2 WITH protect, constant(2)
 DECLARE no_eligible_match = i2 WITH protect, constant(3)
 DECLARE single_match_pack_sz_mismatch = i2 WITH protect, constant(4)
 DECLARE single_match = i2 WITH protect, constant(5)
 DECLARE already_exists = i2 WITH protect, constant(6)
 DECLARE done = i2 WITH protect
 DECLARE ndccnt = i4 WITH protect
 DECLARE ndcmessage = vc WITH protect
 DECLARE outputfile = vc WITH protect
 DECLARE checkallfacind = i2 WITH protect
 DECLARE facilitydisp = vc WITH protect
 DECLARE facilitycd = f8 WITH protect
 SET logfilename = concat("ams_ndc_matching_audit",cnvtlower(format(cnvtdatetime(curdate,curtime3),
    "dd_mmm_yyyy_hh_mm;;q")),".log")
 SET outputfile = cnvtlower(concat(getclient(null),"_",trim(curdomain),"_ndcs_to_stack.csv"))
 RECORD ndcs(
   1 list[*]
     2 ndc = vc
     2 formatted_ndc = vc
     2 inner_ndc = vc
     2 formatted_inner_ndc = vc
     2 exists_ind = i2
     2 inner_ind = i2
     2 inner_package_size = f8
     2 status = i2
     2 options[*]
       3 output_str = vc
       3 item_id = f8
       3 desc = vc
 ) WITH protect
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_ndc_matching_audit")
 ENDIF
#main_menu
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,title_line)
 CALL text((soffrow - 3),soffcol,detail_line)
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 WHILE (facilitycd=0
  AND checkallfacind=0)
   CALL text(soffrow,soffcol,"Fill in facility display (or ALL) (Shift+F5 to select facility).")
   SET question1 = "Facility display:"
   CALL text((soffrow+ 1),soffcol,question1)
   SET help = promptmsg("Facility display starts with:")
   SET help = pos(3,1,15,80)
   SET help =
   SELECT DISTINCT INTO "nl:"
    facility = cv.display
    FROM code_value cv,
     med_flex_object_idx mfoi
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.active_ind=1
      AND cv.cdf_meaning="FACILITY"
      AND cnvtupper(cv.display) >= cnvtupper(curaccept))
     JOIN (mfoi
     WHERE mfoi.parent_entity_id=cv.code_value
      AND mfoi.parent_entity_name="CODE_VALUE")
    ORDER BY cv.display_key
    WITH nocounter
   ;end select
   CALL accept((soffrow+ 1),(soffcol+ (textlen(question1)+ 1)),"P(40);CP","ALL"
    WHERE textlen(trim(curaccept)) > 0)
   SET facilitydisp = trim(cnvtupper(curaccept))
   SET help = off
   IF (cnvtupper(curaccept)="ALL")
    SET checkallfacind = 1
    SET facilitydisp = "All Facilities"
   ELSEIF (cnvtupper(curaccept)="QUIT")
    GO TO exit_script
   ELSE
    SELECT INTO "nl:"
     facility = cv.display
     FROM code_value cv
     WHERE cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.active_ind=1
      AND cv.display_key=cnvtalphanum(cnvtupper(facilitydisp))
      AND cv.code_value != 0
     DETAIL
      facilitycd = cv.code_value, facilitydisp = cv.display
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 1),soffcol,numcols)
     CALL clear((soffrow+ 2),soffcol,numcols)
     CALL text((soffrow+ 2),soffcol,concat(facilitydisp," is not a valid facility display."))
    ELSE
     CALL clear((soffrow+ 2),soffcol,numcols)
    ENDIF
   ENDIF
 ENDWHILE
 WHILE (done=0)
   CALL clear(quesrow,soffcol,numcols)
   CALL text((soffrow+ 2),soffcol,"Enter filename to read NDCs from:")
   CALL accept((soffrow+ 3),(soffcol+ 1),"P(74);C")
   IF (cnvtupper(curaccept)="*.CSV*")
    CALL clear((soffrow+ 4),soffcol,numcols)
    SET stat = findfile(curaccept)
    IF (stat=1)
     CALL clear((soffrow+ 4),soffcol,numcols)
     SET done = 1
     SET ndccnt = readinputfile(curaccept)
     IF (ndccnt > 0)
      SET ndcmessage = build2("Finding best product for ",trim(cnvtstring(ndccnt))," NDCs...")
      CALL text((soffrow+ 4),soffcol,ndcmessage)
      CALL findbestmatch(null)
      CALL text((soffrow+ 4),(soffcol+ textlen(ndcmessage)),"done")
      SET done = 0
      WHILE (done=0)
        CALL text((soffrow+ 5),soffcol,"Enter filename for output report:")
        CALL accept((soffrow+ 6),(soffcol+ 1),"P(74);C",outputfile)
        IF (cnvtupper(curaccept)="*.CSV*")
         CALL clear((soffrow+ 7),soffcol,numcols)
         SET done = 1
         SET outputfile = trim(cnvtlower(curaccept))
         CALL createoutputcsv(outputfile)
         CALL text((soffrow+ 7),soffcol,"Do you want to email the file?:")
         CALL accept((soffrow+ 7),(soffcol+ 31),"A;CU","Y"
          WHERE curaccept IN ("Y", "N"))
         IF (curaccept="Y")
          CALL text((soffrow+ 8),soffcol,"Enter recepient's email address:")
          CALL accept((soffrow+ 9),(soffcol+ 1),"P(74);C",gethnaemail(null)
           WHERE trim(curaccept)="*@*.*")
          IF (emailfile(curaccept,from_str,"","",outputfile))
           CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
          ELSE
           CALL text((soffrow+ 14),soffcol,emailfailstr)
          ENDIF
         ENDIF
         CALL text(quesrow,soffcol,"Continue?:")
         CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
          WHERE curaccept IN ("Y"))
        ELSEIF (cnvtupper(curaccept)="QUIT")
         GO TO main_menu
        ELSE
         CALL text((soffrow+ 7),soffcol,"File must have .csv extension")
        ENDIF
      ENDWHILE
     ELSE
      CALL text((soffrow+ 4),soffcol,
       "No NDCs found in file. Ensure file is a one column with one NDC per row.")
     ENDIF
    ELSE
     CALL text((soffrow+ 4),soffcol,
      "File not found. Make sure file exists in CCLUSERDIR or include logical.")
    ENDIF
   ELSEIF (cnvtupper(curaccept)="QUIT")
    GO TO exit_script
   ELSE
    CALL text((soffrow+ 4),soffcol,"File must have .csv extension")
   ENDIF
 ENDWHILE
 SUBROUTINE findbestmatch(null)
   DECLARE k = i4 WITH protect
   DECLARE ndcpos = i4 WITH protect
   DECLARE itemcnt = i4 WITH protect
   DECLARE packcnt = i4 WITH protect
   SELECT INTO "nl:"
    FROM mltm_ndc_outer_inner_map mn
    PLAN (mn
     WHERE expand(cnt,1,size(ndcs->list,5),mn.inner_ndc_code,ndcs->list[cnt].ndc)
      AND mn.inner_ndc_code != mn.outer_ndc_code
      AND ((mn.obsolete_date=null) OR (mn.obsolete_date >= cnvtdatetime(curdate,curtime3))) )
    DETAIL
     ndcpos = locateval(i,1,size(ndcs->list,5),mn.inner_ndc_code,ndcs->list[i].ndc)
     IF (ndcpos > 0)
      ndcs->list[ndcpos].inner_ind = 1, ndcs->list[ndcpos].options[1].output_str =
      "NDC found as inner, replaced with outer", ndcs->list[ndcpos].inner_ndc = ndcs->list[ndcpos].
      ndc,
      ndcs->list[ndcpos].formatted_inner_ndc = ndcs->list[ndcpos].formatted_ndc, ndcs->list[ndcpos].
      ndc = mn.outer_ndc_code, ndcs->list[ndcpos].formatted_ndc = format(mn.outer_ndc_code,
       "#####-####-##")
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    mi.item_id
    FROM med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_identifier mi2
    PLAN (mi
     WHERE mi.med_identifier_type_cd=ndc_type_cd
      AND mi.active_ind=1
      AND mi.pharmacy_type_cd=inpatient_type_cd
      AND expand(cnt,1,size(ndcs->list,5),mi.value_key,ndcs->list[cnt].ndc))
     JOIN (mdf
     WHERE mdf.item_id=mi.item_id
      AND mdf.flex_type_cd=sys_pkg_type_cd
      AND mdf.active_status_cd=active_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=orderable_type_cd
      AND mfoi.parent_entity_name="CODE_VALUE"
      AND ((mfoi.parent_entity_id IN (0.0, facilitycd)) OR (checkallfacind=1)) )
     JOIN (mi2
     WHERE mi2.item_id=mi.item_id
      AND mi2.active_ind=1
      AND mi2.med_product_id=0
      AND mi2.pharmacy_type_cd=inpatient_type_cd
      AND mi2.med_identifier_type_cd=desc_type_cd)
    DETAIL
     ndcpos = locateval(i,1,size(ndcs->list,5),mi.value_key,ndcs->list[i].ndc)
     IF (ndcpos > 0)
      ndcs->list[ndcpos].options[1].output_str = build2("NDC already exists on product: ",mi2.value),
      ndcs->list[ndcpos].exists_ind = 1, ndcs->list[ndcpos].status = already_exists
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    mncd.ndc_code
    FROM mltm_ndc_core_description mncd,
     (left JOIN mltm_units mu ON mu.unit_id=cnvtreal(mncd.inner_package_desc_code)),
     (left JOIN medication_definition md ON md.cki=concat("MUL.FRMLTN!",cnvtstring(mncd
       .main_multum_drug_code))),
     (left JOIN med_identifier mi ON mi.item_id=md.item_id
      AND mi.pharmacy_type_cd=inpatient_type_cd
      AND mi.med_product_id=0
      AND mi.med_identifier_type_cd=desc_type_cd
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND  EXISTS (
     (SELECT
      mdf.item_id
      FROM med_def_flex mdf,
       med_flex_object_idx mfoi
      WHERE mdf.item_id=mi.item_id
       AND mdf.flex_type_cd=sys_pkg_type_cd
       AND mdf.active_status_cd=active_type_cd
       AND mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=orderable_type_cd
       AND mfoi.parent_entity_name="CODE_VALUE"
       AND ((mfoi.parent_entity_id IN (0.0, facilitycd)) OR (checkallfacind=1)) )))
    PLAN (mncd
     WHERE expand(cnt,1,size(ndcs->list,5),mncd.ndc_code,ndcs->list[cnt].ndc,
      0,ndcs->list[cnt].exists_ind))
     JOIN (mu)
     JOIN (md)
     JOIN (mi)
    ORDER BY mncd.ndc_code, mi.med_identifier_id
    HEAD mncd.ndc_code
     itemcnt = 0, k = 0
    DETAIL
     IF (mi.med_identifier_id > 0)
      itemcnt = (itemcnt+ 1), ndcpos = locateval(i,1,size(ndcs->list,5),mncd.ndc_code,ndcs->list[i].
       ndc)
      IF (ndcpos > 0)
       k = (k+ 1), stat = alterlist(ndcs->list[ndcpos].options,k), ndcs->list[ndcpos].options[k].
       output_str = "Single product available",
       ndcs->list[ndcpos].inner_package_size = mncd.inner_package_size, ndcs->list[ndcpos].options[k]
       .desc = mi.value, ndcs->list[ndcpos].options[k].item_id = mi.item_id,
       ndcs->list[ndcpos].status = single_match
       IF (itemcnt > 1)
        ndcs->list[ndcpos].options[1].output_str = build2("Multiple products available. ",
         "None match Multum's package size: ",trim(format(mncd.inner_package_size,"########.##;T(1)"),
          3)," ",mu.unit_abbr), ndcs->list[ndcpos].status = multiple_matches, ndcs->list[ndcpos].
        options[k].output_str = build2("Multiple products available. ",
         "None match Multum's package size: ",trim(format(mncd.inner_package_size,"########.##;T(1)"),
          3)," ",mu.unit_abbr)
       ENDIF
      ENDIF
     ENDIF
    FOOT  mncd.ndc_code
     ndcpos = locateval(i,1,size(ndcs->list,5),mncd.ndc_code,ndcs->list[i].ndc)
     IF (ndcpos > 0)
      IF (itemcnt=0)
       ndcs->list[ndcpos].options[1].output_str = "No eligible product found.", ndcs->list[ndcpos].
       status = no_eligible_match
      ENDIF
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_flex_object_idx mfoi2,
     med_product mp,
     package_type pt
    PLAN (mi
     WHERE expand(cnt,1,size(ndcs->list,5),mi.item_id,ndcs->list[cnt].options[1].item_id,
      0,ndcs->list[cnt].exists_ind,single_match,ndcs->list[cnt].status)
      AND mi.med_identifier_type_cd=ndc_type_cd
      AND mi.pharmacy_type_cd=inpatient_type_cd
      AND mi.active_ind=1
      AND mi.primary_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=mi.item_id
      AND mdf.flex_type_cd=sys_pkg_type_cd
      AND mdf.active_status_cd=active_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=orderable_type_cd
      AND mfoi.parent_entity_name="CODE_VALUE"
      AND ((mfoi.parent_entity_id IN (0.0, facilitycd)) OR (checkallfacind=1)) )
     JOIN (mfoi2
     WHERE mfoi2.parent_entity_id=mi.med_product_id
      AND mfoi2.parent_entity_name="MED_PRODUCT"
      AND mfoi2.sequence=1)
     JOIN (mp
     WHERE mp.med_product_id=mfoi2.parent_entity_id)
     JOIN (pt
     WHERE pt.item_id=mp.manf_item_id
      AND pt.package_type_id=mp.inner_pkg_type_id)
    ORDER BY mi.item_id
    HEAD mi.item_id
     ndcpos = 0
    DETAIL
     ndcpos = locateval(i,1,size(ndcs->list,5),mi.item_id,ndcs->list[i].options[1].item_id)
     WHILE (ndcpos > 0)
      IF ((pt.qty=ndcs->list[ndcpos].inner_package_size))
       ndcs->list[ndcpos].options[1].output_str = build2("Single product available. ",
        "Package size matches Multum: ",trim(format(pt.qty,"########.##;T(1)"),3)," ",trim(
         uar_get_code_display(pt.uom_cd))), ndcs->list[ndcpos].status = single_match
      ELSE
       ndcs->list[ndcpos].options[1].output_str = build2("Single product available. ",
        "Package size does not match. Product: ",trim(format(pt.qty,"########.##;T(1)"),3)," ",trim(
         uar_get_code_display(pt.uom_cd)),
        " Multum: ",trim(format(ndcs->list[ndcpos].inner_package_size,"########.##;T(1)"),3)), ndcs->
       list[ndcpos].status = single_match_pack_sz_mismatch
      ENDIF
      ,ndcpos = locateval(i,(ndcpos+ 1),size(ndcs->list,5),mi.item_id,ndcs->list[i].options[1].
       item_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    ndc = ndcs->list[d1.seq].ndc
    FROM (dummyt d1  WITH seq = value(size(ndcs->list,5))),
     (dummyt d2  WITH seq = 1),
     med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_flex_object_idx mfoi2,
     med_product mp,
     package_type pt
    PLAN (d1
     WHERE maxrec(d2,size(ndcs->list[d1.seq].options,5))
      AND size(ndcs->list[d1.seq].options,5) > 1)
     JOIN (d2)
     JOIN (mi
     WHERE (mi.item_id=ndcs->list[d1.seq].options[d2.seq].item_id)
      AND mi.med_identifier_type_cd=ndc_type_cd
      AND mi.pharmacy_type_cd=inpatient_type_cd
      AND mi.active_ind=1
      AND mi.primary_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=mi.item_id
      AND mdf.flex_type_cd=sys_pkg_type_cd
      AND mdf.active_status_cd=active_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=orderable_type_cd
      AND mfoi.parent_entity_name="CODE_VALUE"
      AND ((mfoi.parent_entity_id IN (0.0, facilitycd)) OR (checkallfacind=1)) )
     JOIN (mfoi2
     WHERE mfoi2.parent_entity_id=mi.med_product_id
      AND mfoi2.parent_entity_name="MED_PRODUCT"
      AND mfoi2.sequence=1)
     JOIN (mp
     WHERE mp.med_product_id=mfoi2.parent_entity_id)
     JOIN (pt
     WHERE pt.item_id=mp.manf_item_id
      AND pt.package_type_id=mp.inner_pkg_type_id
      AND (pt.qty=ndcs->list[d1.seq].inner_package_size))
    ORDER BY ndcs->list[d1.seq].ndc, mi.item_id
    HEAD ndc
     packcnt = 0
    DETAIL
     packcnt = (packcnt+ 1)
    FOOT  ndc
     IF (packcnt=1)
      ndcs->list[d1.seq].options[d2.seq].output_str = build2("Multiple products available. ",
       "Suggested match based on package size: ",trim(format(pt.qty,"########.##;T(1)"),3)," ",trim(
        uar_get_code_display(pt.uom_cd)))
      FOR (i = 1 TO size(ndcs->list[d1.seq].options,5))
        IF (i != d2.seq)
         ndcs->list[d1.seq].options[i].output_str = build2("Multiple products available. ",
          "Not suggested match based on package size.")
        ENDIF
      ENDFOR
     ELSEIF (packcnt > 1)
      FOR (i = 1 TO size(ndcs->list[d1.seq].options,5))
        ndcs->list[d1.seq].options[i].output_str = build2("Multiple products available. ",
         "Multiple match Multum's package size: ",trim(format(pt.qty,"########.##;T(1)"),3)," ",trim(
          uar_get_code_display(pt.uom_cd)))
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE readinputfile(filename)
   DECLARE ndc_pos = i2 WITH protect, constant(1)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE ndccnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build2("Starting to read input file: ",filename))
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     ndccnt = 0, firstrow = 1
    DETAIL
     IF (firstrow != 1
      AND trim(piece(r.line,delim,ndc_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,ndc_pos,notfnd,3))) > 0)
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF ndc_pos:
          ndcpos = locateval(i,1,ndccnt,trim(cnvtalphanum(str)),ndcs->list[i].ndc),
          IF (ndcpos=0)
           ndccnt = (ndccnt+ 1)
           IF (mod(ndccnt,100)=1)
            stat = alterlist(ndcs->list,(ndccnt+ 99))
           ENDIF
           stat = alterlist(ndcs->list[ndccnt].options,1), ndcs->list[ndccnt].options[1].output_str
            = "Non-reference NDC.", ndcs->list[ndccnt].status = non_reference,
           ndcs->list[ndccnt].ndc = trim(cnvtalphanum(str))
           IF (cnvtreal(trim(cnvtalphanum(str))) > 0)
            ndcs->list[ndccnt].formatted_ndc = format(trim(cnvtalphanum(str)),"#####-####-##")
           ELSE
            ndcs->list[ndccnt].formatted_ndc = trim(str)
           ENDIF
           ndcs->list[ndccnt].exists_ind = 0
          ENDIF
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSEIF (firstrow=1
      AND trim(piece(r.line,delim,ndc_pos,notfnd,3)) > " ")
      firstrow = 0
     ENDIF
    FOOT REPORT
     IF (mod(ndccnt,100) != 0)
      stat = alterlist(ndcs->list,ndccnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","ndcs record after being loaded by readInputFile()")
    CALL echorecord(ndcs,logfilename,1)
   ENDIF
   RETURN(ndccnt)
 END ;Subroutine
 SUBROUTINE createoutputcsv(filename)
   SELECT INTO value(filename)
    search_string = substring(1,1000,evaluate(ndcs->list[d1.seq].options[d2.seq].item_id,0.0,"",
      build2("x ",trim(cnvtstring(ndcs->list[d1.seq].options[d2.seq].item_id))))), ndc_to_stack =
    substring(1,1000,ndcs->list[d1.seq].formatted_ndc), description = substring(1,1000,ndcs->list[d1
     .seq].options[d2.seq].desc),
    original_ndc = substring(1,1000,ndcs->list[d1.seq].formatted_inner_ndc), message = substring(1,
     1000,ndcs->list[d1.seq].options[d2.seq].output_str)
    FROM (dummyt d1  WITH seq = value(size(ndcs->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(ndcs->list[d1.seq].options,5)))
     JOIN (d2)
    ORDER BY ndcs->list[d1.seq].status, evaluate(ndcs->list[d1.seq].status,multiple_matches,ndcs->
      list[d1.seq].formatted_ndc,already_exists,ndcs->list[d1.seq].options[d2.seq].output_str,
      substring(1,200,cnvtupper(ndcs->list[d1.seq].options[d2.seq].desc)))
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (debug_ind=1)
  CALL addlogmsg("ERROR",statusstr)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "000"
END GO
