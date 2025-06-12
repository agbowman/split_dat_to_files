CREATE PROGRAM ams_batch_tallman_products:dba
 SET modify = predeclare
 DECLARE include_combo_drug = i2 WITH constant(request->combo_ind), protect
 DECLARE ignore_mismatch_warn = i2 WITH constant(request->ignore_mismatch_ind), protect
 DECLARE regex_combo_drug = cv WITH constant(request->regex_chars), protect
 DECLARE tallman_file = vc WITH constant(request->tman_filename), protect
 DECLARE delim = vc WITH constant(","), protect
 DECLARE script_mode = i2 WITH protect
 DECLARE eexport_mode = i2 WITH constant(1), protect
 DECLARE eupdate_mode = i2 WITH constant(2), protect
 DECLARE output_csv_file = vc WITH protect
 DECLARE input_csv_file = vc WITH protect
 DECLARE debug_ind = i2 WITH constant(request->debug_ind), protect
 DECLARE cdpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cdtyperxmnem = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC_SHORT")), protect
 DECLARE cdinpatient = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE cdretail = f8 WITH constant(uar_get_code_by("MEANING",4500,"RETAIL")), protect
 DECLARE cdmeddefitem = f8 WITH constant(uar_get_code_by("MEANING",11001,"MED_DEF")), protect
 DECLARE cdmanfitem = f8 WITH constant(uar_get_code_by("MEANING",11001,"ITEM_MANF")), protect
 DECLARE last_mod = vc WITH protect
 DECLARE ident_mismatch_cnt = i4 WITH protect
 DECLARE procure_ident_mismatch_cnt = i4 WITH protect
 DECLARE cinv_at_drug_level = i2 WITH constant(0), protect
 DECLARE cinv_at_manf_level = i2 WITH constant(1), protect
 DECLARE gicurinvpreflevelinp = i2 WITH noconstant(0), protect
 DECLARE gicurinvpreflevelret = i2 WITH noconstant(0), protect
 DECLARE giidentsyncpref = i2 WITH noconstant(0), protect
 DECLARE cidentsynctypepref = f8 WITH protect
 DECLARE procureidentcnt = i4 WITH protect
 DECLARE identifiersloaded = i2 WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_BATCH_TALLMAN_PRODUCTS")
 DECLARE loadtallmanfile(sfilename=vc) = i2 WITH protect
 DECLARE getidentifiermatches(null) = i4 WITH protect
 DECLARE gettallmanidentifier(stallmanstr=vc,sorigidentifier=vc) = vc WITH protect
 DECLARE writeidentstocsv(sfilename=vc) = null WITH protect
 DECLARE readupdatedidentsfromcsv(sfilename=vc) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE checkforidentifiermismatches(null) = i4 WITH protect
 DECLARE chcekforprocureidentifiermismatches(null) = i4 WITH protect
 DECLARE getprocureprefs(null) = i2 WITH protect
 DECLARE getprocureidentifiermatches(null) = null WITH protect
 FREE RECORD tman
 RECORD tman(
   1 search_list_sz = i4
   1 search_list[*]
     2 tallman_str = vc
     2 tallman_str_cap = vc
     2 tallman_str_search = vc
     2 ident_list[*]
       3 primary_mnemonic = vc
       3 item_id = f8
       3 med_produt_id = f8
       3 pharm_type_cd = f8
       3 med_identifier_id = f8
       3 identifier_type_cd = f8
       3 primary_ind = i2
       3 orig_identifier = vc
       3 proposed_identifier = vc
 )
 FREE RECORD updt_rec
 RECORD updt_rec(
   1 ident_list[*]
     2 med_identifier_id = f8
     2 item_id = f8
     2 primary_ind = i2
     2 med_product_id = f8
     2 pharm_type_cd = f8
     2 identifier_type_cd = f8
     2 new_identifier = vc
 )
 FREE RECORD procure_updt_rec
 RECORD procure_updt_rec(
   1 procure_ident_list[*]
     2 identifier_id = f8
     2 new_identifier = vc
 )
 FREE RECORD tmp_med_def_updt
 RECORD tmp_med_def_updt(
   1 med_def_list[*]
     2 item_id = f8
     2 ident_list[*]
       3 identifier_type_cd = f8
       3 pharm_type_cd = f8
       3 new_identifier = vc
 )
 FREE RECORD tmp_manf_updt
 RECORD tmp_manf_updt(
   1 manf_list[*]
     2 med_prod_id = f8
     2 ident_list[*]
       3 identifier_type_cd = f8
       3 pharm_type_cd = f8
       3 new_identifier = vc
 )
 FREE RECORD ident_rec
 RECORD ident_rec(
   1 qual[*]
     2 ident_id = f8
     2 proposed_ident = vc
 )
 IF (debug_ind=1)
  CALL echo("Debug Mode Enabled")
 ELSE
  SET trace = callecho
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET message = noinformation
  SET trace = nocost
 ENDIF
 SET script_mode = request->mode
 IF (script_mode=eexport_mode)
  CALL echo("Export Mode")
  SET output_csv_file = request->filename
 ELSEIF (script_mode=eupdate_mode)
  CALL echo("Update Mode")
  SET input_csv_file = request->filename
 ELSE
  CALL echo("Mode is not valid. Exiting")
  GO TO exit_script
 ENDIF
 IF ((request->filename=""))
  CALL echo("Filename not valid. Exiting")
  GO TO exit_script
 ENDIF
 IF (script_mode=eexport_mode)
  IF (loadtallmanfile(tallman_file) <= 0)
   CALL echo(build("No tallman strings loaded. Check that the file exists in CCLUSERDIR: ",
     tallman_file))
   GO TO exit_script
  ENDIF
  IF (getidentifiermatches(null) > 0)
   IF (debug_ind=1)
    CALL echo("tallman record after mi select")
    CALL echorecord(tman)
   ENDIF
   CALL writeidentstocsv(output_csv_file)
  ENDIF
 ELSEIF (script_mode=eupdate_mode)
  IF (getprocureprefs(null) <= 0)
   CALL echo("Error loading preferences. Exiting")
   GO TO exit_script
  ENDIF
  SET identifiersloaded = readupdatedidentsfromcsv(input_csv_file)
  IF (identifiersloaded <= 0)
   CALL echo("No identifiers loaded from CSV for update")
   GO TO exit_script
  ENDIF
  IF (giidentsyncpref=1)
   CALL getprocureidentifiermatches(null)
  ELSE
   CALL echo("Not updating procure identifiers due to preference setting")
  ENDIF
  IF (debug_ind=1)
   CALL echo("procure_updt_rec after being loaded")
   CALL echorecord(procure_updt_rec)
  ENDIF
  CALL performupdates(null)
 ENDIF
 SUBROUTINE loadtallmanfile(sfilename)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE beg_index = i4 WITH protect
   DECLARE end_index = i4 WITH protect
   DECLARE tstrlen = i4 WITH protect
   CALL echo(build("Reading tallman identifiers from file: ",sfilename))
   FREE DEFINE rtl
   DEFINE rtl sfilename
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WHERE  NOT (r.line IN (" ", null))
    HEAD REPORT
     tcnt = 0
    DETAIL
     beg_index = 1, end_index = 0, tcnt = (tcnt+ 1)
     IF (mod(tcnt,100)=1)
      stat = alterlist(tman->search_list,(tcnt+ 99))
     ENDIF
     end_index = findstring(delim,r.line,beg_index), tstrlen = (end_index - beg_index)
     IF (end_index > 0)
      tman->search_list[tcnt].tallman_str = substring(beg_index,tstrlen,r.line)
     ELSE
      tman->search_list[tcnt].tallman_str = r.line
     ENDIF
     tman->search_list[tcnt].tallman_str_cap = cnvtupper(tman->search_list[tcnt].tallman_str), tman->
     search_list[tcnt].tallman_str_search = build("*",cnvtalphanum(cnvtupper(tman->search_list[tcnt].
        tallman_str)),"*"), beg_index = (end_index+ 1)
    FOOT REPORT
     IF (mod(tcnt,100) != 0)
      stat = alterlist(tman->search_list,tcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET tman->search_list_sz = size(tman->search_list,5)
   RETURN(evaluate(tman->search_list_sz,0,0,1))
 END ;Subroutine
 SUBROUTINE getidentifiermatches(null)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE exportcnt = i4 WITH protect
   DECLARE tallman_identifier = vc WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE idx = i4
   DECLARE x = i4
   DECLARE y = i4
   DECLARE pos = i4
   FOR (i = 1 TO tman->search_list_sz)
    CALL echo(build("checking tallman record:",i,":",tman->search_list[i].tallman_str))
    SELECT INTO "nl:"
     FROM med_identifier mi,
      order_catalog_item_r ocir,
      order_catalog oc
     PLAN (mi
      WHERE mi.value_key=patstring(tman->search_list[i].tallman_str_search)
       AND  NOT (mi.med_identifier_type_cd IN (cdtyperxmnem))
       AND mi.active_ind=1)
      JOIN (ocir
      WHERE ocir.item_id=mi.item_id)
      JOIN (oc
      WHERE oc.catalog_cd=ocir.catalog_cd)
     ORDER BY cnvtupper(oc.primary_mnemonic), mi.item_id, mi.pharmacy_type_cd,
      mi.med_product_id
     HEAD REPORT
      tcnt = 0
     DETAIL
      combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
        tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
        .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug)
       ), combodrug = bor(combodrugprefix,combodrugsuffix),
      partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
        search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic),
       "REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
       partialdrugprefix,partialdrugsuffix)
      IF (debug_ind=1)
       CALL echo("*****************************************"),
       CALL echo(oc.primary_mnemonic),
       CALL echo(mi.value),
       CALL echo(build("ComboDrug: ",combodrug)),
       CALL echo(build("ComboDrugPrefix: ",combodrugprefix)),
       CALL echo(build("ComboDrugSuffix: ",combodrugsuffix)),
       CALL echo(build("PartialDrug: ",partialdrug)),
       CALL echo(build("PartialDrugPrefix: ",partialdrugprefix)),
       CALL echo(build("PartialDrugSuffix: ",partialdrugsuffix))
      ENDIF
      FOR (idx = 1 TO size(ident_rec->qual,5))
        IF ((mi.med_identifier_id=ident_rec->qual[idx].ident_id)
         AND partialdrug=0)
         tallman_identifier = gettallmanidentifier(tman->search_list[i].tallman_str,ident_rec->qual[
          idx].proposed_ident), ident_rec->qual[idx].proposed_ident = tallman_identifier
         FOR (x = 1 TO tman->search_list_sz)
          pos = locateval(y,1,size(tman->search_list[x].ident_list,5),mi.med_identifier_id,tman->
           search_list[x].ident_list[y].med_identifier_id),
          IF (pos > 0)
           tman->search_list[x].ident_list[pos].proposed_identifier = tallman_identifier
          ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF (tallman_identifier="")
       tallman_identifier = gettallmanidentifier(tman->search_list[i].tallman_str,mi.value)
      ENDIF
      IF (tallman_identifier != mi.value
       AND partialdrug=0
       AND ((combodrug=0) OR (include_combo_drug=1)) )
       exportcnt = (exportcnt+ 1), tcnt = (tcnt+ 1)
       IF (mod(tcnt,100)=1)
        stat = alterlist(tman->search_list[i].ident_list,(tcnt+ 99))
       ENDIF
       tman->search_list[i].ident_list[tcnt].primary_mnemonic = oc.primary_mnemonic, tman->
       search_list[i].ident_list[tcnt].item_id = mi.item_id, tman->search_list[i].ident_list[tcnt].
       med_produt_id = mi.med_product_id,
       tman->search_list[i].ident_list[tcnt].pharm_type_cd = mi.pharmacy_type_cd, tman->search_list[i
       ].ident_list[tcnt].med_identifier_id = mi.med_identifier_id, tman->search_list[i].ident_list[
       tcnt].identifier_type_cd = mi.med_identifier_type_cd,
       tman->search_list[i].ident_list[tcnt].primary_ind = mi.primary_ind, tman->search_list[i].
       ident_list[tcnt].orig_identifier = mi.value, tman->search_list[i].ident_list[tcnt].
       proposed_identifier = tallman_identifier,
       stat = alterlist(ident_rec->qual,exportcnt), ident_rec->qual[exportcnt].ident_id = mi
       .med_identifier_id, ident_rec->qual[exportcnt].proposed_ident = tallman_identifier
      ELSE
       CALL echo(build("Skipping identifier: ",mi.value))
      ENDIF
      tallman_identifier = ""
     FOOT REPORT
      IF (mod(tcnt,100) != 0)
       stat = alterlist(tman->search_list[i].ident_list,tcnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   CALL echo(build2("Exporting ",trim(cnvtstring(exportcnt))," identifiers to CSV file: ",trim(
      output_csv_file)))
   RETURN(exportcnt)
 END ;Subroutine
 SUBROUTINE writeidentstocsv(sfilename)
   DECLARE j = i4 WITH protect
   IF (debug_ind=1)
    CALL echo("Inside writeIdentsToCSV")
   ENDIF
   SELECT INTO value(sfilename)
    DETAIL
     row 0, col 0,
     "The upload process will use the 'proposed identifier' column to update identifiers",
     row + 1, col 0,
     "Delete any ROWS for which you do not want to update that identifier prior to upload",
     row + 1, col 0,
     "Do not reorder or remove any COLUMNS. You may insert columns only after the last column",
     row + 1, col 0,
     "CAUTION: med_identifier_id's may differ between domains. Extract/Import should be performed separately in each"
    WITH pcformat('"',delim), maxcol = 20000, format = variable,
     noformfeed, landscape, maxrow = 1
   ;end select
   SELECT INTO value(sfilename)
    tallmanstr = substring(1,50,tman->search_list[d1.seq].tallman_str), primary = substring(1,100,
     tman->search_list[d1.seq].ident_list[d2.seq].primary_mnemonic), origidentifier = substring(1,200,
     tman->search_list[d1.seq].ident_list[d2.seq].orig_identifier),
    proposedidentifier = substring(1,200,tman->search_list[d1.seq].ident_list[d2.seq].
     proposed_identifier), primaryind = tman->search_list[d1.seq].ident_list[d2.seq].primary_ind,
    itemid = tman->search_list[d1.seq].ident_list[d2.seq].item_id,
    medproductid = tman->search_list[d1.seq].ident_list[d2.seq].med_produt_id, pharmtypecd = tman->
    search_list[d1.seq].ident_list[d2.seq].pharm_type_cd, pharmtype = uar_get_code_display(tman->
     search_list[d1.seq].ident_list[d2.seq].pharm_type_cd),
    medidentifierid = tman->search_list[d1.seq].ident_list[d2.seq].med_identifier_id,
    medidentifiertypecd = tman->search_list[d1.seq].ident_list[d2.seq].identifier_type_cd,
    medidentifiertype = uar_get_code_display(tman->search_list[d1.seq].ident_list[d2.seq].
     identifier_type_cd)
    FROM (dummyt d1  WITH seq = value(tman->search_list_sz)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(tman->search_list[d1.seq].ident_list,5)))
     JOIN (d2)
    ORDER BY cnvtupper(tman->search_list[d1.seq].tallman_str), primary
    WITH format = stream, pcformat('"',delim,1), format,
     append
   ;end select
 END ;Subroutine
 SUBROUTINE gettallmanidentifier(stallmanstr,sorigidentifier)
   DECLARE startpos = i4 WITH protect
   DECLARE endpos = i4 WITH protect
   DECLARE final_str = vc WITH protect
   DECLARE prefix = vc WITH protect
   DECLARE suffix = vc WITH protect
   SET startpos = 1
   SET endpos = findstring(cnvtupper(stallmanstr),cnvtupper(sorigidentifier))
   SET prefix = notrim(substring(startpos,(endpos - 1),sorigidentifier))
   IF (endpos > 0)
    SET startpos = (endpos+ textlen(stallmanstr))
    SET endpos = ((textlen(sorigidentifier) - startpos)+ 1)
    SET suffix = substring(startpos,endpos,sorigidentifier)
    SET final_str = concat(prefix,stallmanstr,suffix)
   ELSE
    SET final_str = sorigidentifier
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("sTallmanStr: ",stallmanstr))
    CALL echo(build("sOrigIdentifier: ",sorigidentifier))
    CALL echo(build("final_str: ",final_str))
   ENDIF
   RETURN(final_str)
 END ;Subroutine
 SUBROUTINE readupdatedidentsfromcsv(sfilename)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE meditempos = i4 WITH protect
   DECLARE manfitempos = i4 WITH protect
   DECLARE medidentpos = i4 WITH protect
   DECLARE manfidentpos = i4 WITH protect
   CALL echo(build("Loading identifiers from CSV file: ",input_csv_file))
   FREE DEFINE rtl2
   DEFINE rtl2 sfilename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0
    DETAIL
     IF (cnvtreal(piece(r.line,delim,10,notfnd,3)) > 0.0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(updt_rec->ident_list,(cnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        IF (debug_ind=1)
         CALL echo(build("piece",piecenum,"=",str))
        ENDIF
        CASE (piecenum)
         OF 4:
          updt_rec->ident_list[cnt].new_identifier = str,
          CALL echo(build("Loading new identifier from CSV file: ",str))
         OF 5:
          updt_rec->ident_list[cnt].primary_ind = cnvtreal(str)
         OF 6:
          updt_rec->ident_list[cnt].item_id = cnvtreal(str)
         OF 7:
          updt_rec->ident_list[cnt].med_product_id = cnvtreal(str)
         OF 8:
          updt_rec->ident_list[cnt].pharm_type_cd = cnvtreal(str)
         OF 10:
          updt_rec->ident_list[cnt].med_identifier_id = cnvtreal(str)
         OF 11:
          updt_rec->ident_list[cnt].identifier_type_cd = cnvtreal(str)
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSE
      IF (debug_ind=1)
       CALL echo(build("skipping line: ",r.line))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(updt_rec->ident_list,cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("updt_rec after reading from CSV file")
    CALL echorecord(updt_rec)
   ENDIF
   SELECT INTO "nl:"
    item = updt_rec->ident_list[d1.seq].item_id, med_prod = updt_rec->ident_list[d1.seq].
    med_product_id, ident_id = updt_rec->ident_list[d1.seq].med_identifier_id,
    ident_type = updt_rec->ident_list[d1.seq].identifier_type_cd, pharm_type = updt_rec->ident_list[
    d1.seq].pharm_type_cd, new_ident = updt_rec->ident_list[d1.seq].new_identifier,
    primary = updt_rec->ident_list[d1.seq].primary_ind
    FROM (dummyt d1  WITH seq = value(size(updt_rec->ident_list,5)))
    PLAN (d1)
    ORDER BY med_prod, primary DESC, item
    HEAD REPORT
     meditempos = 0, manfitempos = 0, procureidentcnt = 0
    HEAD med_prod
     IF (med_prod > 0
      AND primary > 0)
      manfitempos = (manfitempos+ 1)
      IF (mod(manfitempos,100)=1)
       stat = alterlist(tmp_manf_updt->manf_list,(manfitempos+ 99))
      ENDIF
      tmp_manf_updt->manf_list[manfitempos].med_prod_id = med_prod, manfidentpos = 0
     ENDIF
    HEAD item
     IF (med_prod=0
      AND primary > 0)
      meditempos = (meditempos+ 1)
      IF (mod(meditempos,100)=1)
       stat = alterlist(tmp_med_def_updt->med_def_list,(meditempos+ 99))
      ENDIF
      tmp_med_def_updt->med_def_list[meditempos].item_id = item, medidentpos = 0
     ENDIF
    DETAIL
     IF (med_prod > 0
      AND primary > 0)
      procureidentcnt = (procureidentcnt+ 1), manfidentpos = (manfidentpos+ 1), stat = alterlist(
       tmp_manf_updt->manf_list[manfitempos].ident_list,manfidentpos),
      tmp_manf_updt->manf_list[manfitempos].ident_list[manfidentpos].identifier_type_cd = ident_type,
      tmp_manf_updt->manf_list[manfitempos].ident_list[manfidentpos].pharm_type_cd = pharm_type,
      tmp_manf_updt->manf_list[manfitempos].ident_list[manfidentpos].new_identifier = updt_rec->
      ident_list[d1.seq].new_identifier
     ELSEIF (med_prod=0
      AND primary > 0)
      procureidentcnt = (procureidentcnt+ 1), medidentpos = (medidentpos+ 1), stat = alterlist(
       tmp_med_def_updt->med_def_list[meditempos].ident_list,medidentpos),
      tmp_med_def_updt->med_def_list[meditempos].ident_list[medidentpos].identifier_type_cd =
      ident_type, tmp_med_def_updt->med_def_list[meditempos].ident_list[medidentpos].pharm_type_cd =
      pharm_type, tmp_med_def_updt->med_def_list[meditempos].ident_list[medidentpos].new_identifier
       = updt_rec->ident_list[d1.seq].new_identifier
     ENDIF
    FOOT REPORT
     IF (mod(manfitempos,100) != 0)
      stat = alterlist(tmp_manf_updt->manf_list,manfitempos)
     ENDIF
     IF (mod(meditempos,100) != 0)
      stat = alterlist(tmp_med_def_updt->med_def_list,meditempos)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("tmp_med_def_updt record after parsing through updt_rec")
    CALL echorecord(tmp_med_def_updt)
    CALL echo("tmp_manf_updt record after parsing through updt_rec")
    CALL echorecord(tmp_manf_updt)
   ENDIF
   RETURN(evaluate(size(updt_rec->ident_list,5),0,0,1))
 END ;Subroutine
 SUBROUTINE performupdates(null)
   CALL echo("Checking for identifier mismatches between CSV and med_identifier")
   CALL checkforidentifiermismatches(null)
   IF (giidentsyncpref=1
    AND evaluate(size(procure_updt_rec->procure_ident_list),0,0,1)=1)
    CALL echo("Checking for procure identifier mismatches between med_identifier and procure tables")
    CALL checkforprocureidentifiermismatches(null)
   ENDIF
   IF (((ident_mismatch_cnt > 0) OR (procure_ident_mismatch_cnt > 0))
    AND ignore_mismatch_warn=0)
    GO TO exit_script
   ENDIF
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "MED_IDENTIFIER", medidentid = mi.med_identifier_id,
    newdisplay = updt_rec->ident_list[d1.seq].new_identifier, currentdisplay = mi.value, mi.value_key,
    mi.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->ident_list,5))),
     med_identifier mi
    PLAN (d1
     WHERE (updt_rec->ident_list[d1.seq].med_identifier_id > 0))
     JOIN (mi
     WHERE (mi.med_identifier_id=updt_rec->ident_list[d1.seq].med_identifier_id))
    WITH nocounter, forupdate(mi)
   ;end select
   IF ((request->commit_ind=1))
    CALL echo("Updating med_identifier")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->ident_list,5))),
      med_identifier mi
     SET mi.value = trim(substring(1,200,updt_rec->ident_list[d1.seq].new_identifier)), mi.value_key
       = trim(cnvtalphanum(cnvtupper(substring(1,200,updt_rec->ident_list[d1.seq].new_identifier)))),
      mi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      mi.updt_id = reqinfo->updt_id, mi.updt_cnt = (mi.updt_cnt+ 1), mi.updt_applctx = 0,
      mi.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->ident_list[d1.seq].med_identifier_id > 0))
      JOIN (mi
      WHERE (mi.med_identifier_id=updt_rec->ident_list[d1.seq].med_identifier_id))
    ;end update
   ENDIF
   IF (giidentsyncpref=1
    AND evaluate(size(procure_updt_rec->procure_ident_list),0,0,1)=1)
    SELECT
     IF ((request->commit_ind=1))INTO "nl:"
     ELSE
     ENDIF
     d1.seq, updatetable = "IDENTIFIER", identid = i.identifier_id,
     newdisplay = procure_updt_rec->procure_ident_list[d1.seq].new_identifier, currentdisplay = i
     .value, i.value_key,
     i.updt_dt_tm
     FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
      identifier i
     PLAN (d1
      WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
      JOIN (i
      WHERE (i.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id))
     WITH nocounter, forupdate(i)
    ;end select
    SELECT
     IF ((request->commit_ind=1))INTO "nl:"
     ELSE
     ENDIF
     d1.seq, updatetable = "OBJECT_IDENTIFIER", identid = oi.identifier_id,
     newdisplay = procure_updt_rec->procure_ident_list[d1.seq].new_identifier, oi.updt_dt_tm
     FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
      object_identifier oi
     PLAN (d1
      WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
      JOIN (oi
      WHERE (oi.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id))
     WITH nocounter, forupdate(oi)
    ;end select
    SELECT
     IF ((request->commit_ind=1))INTO "nl:"
     ELSE
     ENDIF
     d1.seq, updatetable = "OBJECT_IDENTIFIER_INDEX", identid = oii.identifier_id,
     newdisplay = procure_updt_rec->procure_ident_list[d1.seq].new_identifier, currentdisplay = oii
     .value, oii.value_key,
     oii.updt_dt_tm
     FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
      object_identifier_index oii
     PLAN (d1
      WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
      JOIN (oii
      WHERE (oii.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id)
       AND oii.object_type_cd > 0)
     WITH nocounter, forupdate(oii)
    ;end select
    IF ((request->commit_ind=1))
     CALL echo("Updating identifier")
     UPDATE  FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
       identifier i
      SET i.value = trim(substring(1,255,procure_updt_rec->procure_ident_list[d1.seq].new_identifier)
        ), i.value_key = trim(cnvtalphanum(cnvtupper(substring(1,255,procure_updt_rec->
           procure_ident_list[d1.seq].new_identifier)))), i.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt+ 1), i.updt_applctx = 0,
       i.updt_task = - (267)
      PLAN (d1
       WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
       JOIN (i
       WHERE (i.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id))
      WITH nocounter
     ;end update
     CALL echo("Updating object_identifier")
     UPDATE  FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
       object_identifier oi
      SET oi.updt_dt_tm = cnvtdatetime(curdate,curtime3), oi.updt_id = reqinfo->updt_id, oi.updt_cnt
        = (oi.updt_cnt+ 1),
       oi.updt_applctx = 0, oi.updt_task = - (267)
      PLAN (d1
       WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
       JOIN (oi
       WHERE (oi.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id))
      WITH nocounter
     ;end update
     CALL echo("Updating object_identifier_identifier")
     UPDATE  FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
       object_identifier_index oii
      SET oii.value = trim(substring(1,255,procure_updt_rec->procure_ident_list[d1.seq].
         new_identifier)), oii.value_key = trim(cnvtalphanum(cnvtupper(substring(1,255,
           procure_updt_rec->procure_ident_list[d1.seq].new_identifier)))), oii.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       oii.updt_id = reqinfo->updt_id, oii.updt_cnt = (oii.updt_cnt+ 1), oii.updt_applctx = 0,
       oii.updt_task = - (267)
      PLAN (d1
       WHERE (procure_updt_rec->procure_ident_list[d1.seq].identifier_id > 0))
       JOIN (oii
       WHERE (oii.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id))
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforidentifiermismatches(null)
  SELECT INTO "nl: "
   mi.med_identifier_id, newidentifier = updt_rec->ident_list[d1.seq].new_identifier, origidentifier
    = mi.value
   FROM (dummyt d1  WITH seq = value(size(updt_rec->ident_list,5))),
    med_identifier mi
   PLAN (d1)
    JOIN (mi
    WHERE (mi.med_identifier_id=updt_rec->ident_list[d1.seq].med_identifier_id)
     AND  NOT (((mi.med_identifier_type_cd+ 0) IN (cdtyperxmnem)))
     AND mi.value_key != cnvtalphanum(cnvtupper(updt_rec->ident_list[d1.seq].new_identifier)))
   ORDER BY d1.seq
   HEAD REPORT
    ident_mismatch_cnt = 0
   DETAIL
    ident_mismatch_cnt = (ident_mismatch_cnt+ 1),
    CALL echo("WARNING: Identifier Mismatch found between upload CSV and med_identifier"),
    CALL echo(build("med_identifier_id: ",mi.med_identifier_id)),
    CALL echo(build("CSV Identifier: ",cnvtalphanum(cnvtupper(updt_rec->ident_list[d1.seq].
       new_identifier)))),
    CALL echo(build("MI Identifier: ",mi.value_key)),
    CALL echo("*******************************************")
   WITH nocounter
  ;end select
  RETURN(ident_mismatch_cnt)
 END ;Subroutine
 SUBROUTINE checkforprocureidentifiermismatches(null)
   SELECT INTO "nl:"
    i.value
    FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
     identifier i
    PLAN (d1)
     JOIN (i
     WHERE (i.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id)
      AND i.value_key != cnvtalphanum(cnvtupper(procure_updt_rec->procure_ident_list[d1.seq].
       new_identifier)))
    ORDER BY d1.seq
    DETAIL
     procure_ident_mismatch_cnt = (procure_ident_mismatch_cnt+ 1),
     CALL echo("WARNING: Procure identifier mismatch found"),
     CALL echo("table: IDENTIFIER"),
     CALL echo(build("identifier_id:",i.identifier_id)),
     CALL echo(build("Calculated new identifier:",cnvtalphanum(cnvtupper(procure_updt_rec->
        procure_ident_list[d1.seq].new_identifier)))),
     CALL echo(build("Exisiting identifier:",i.value_key)),
     CALL echo("*******************************************")
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    oii.value
    FROM (dummyt d1  WITH seq = value(size(procure_updt_rec->procure_ident_list,5))),
     object_identifier_index oii
    PLAN (d1)
     JOIN (oii
     WHERE (oii.identifier_id=procure_updt_rec->procure_ident_list[d1.seq].identifier_id)
      AND oii.value_key != cnvtalphanum(cnvtupper(procure_updt_rec->procure_ident_list[d1.seq].
       new_identifier)))
    ORDER BY d1.seq
    DETAIL
     procure_ident_mismatch_cnt = (procure_ident_mismatch_cnt+ 1),
     CALL echo("WARNING: Procure identifier mismatch found"),
     CALL echo("table: OBJECT_IDENTIFIER_INDEX"),
     CALL echo(build("identifier_id:",oii.identifier_id)),
     CALL echo(build("Calculated new identifier:",cnvtalphanum(cnvtupper(procure_updt_rec->
        procure_ident_list[d1.seq].new_identifier)))),
     CALL echo(build("Exisiting identifier:",oii.value_key)),
     CALL echo("*******************************************")
    WITH nocounter
   ;end select
   RETURN(procure_ident_mismatch_cnt)
 END ;Subroutine
 SUBROUTINE getprocureprefs(null)
   DECLARE ireturn = i2 WITH protect
   SET ireturn = 1
   CALL echo("Loading procure preferences")
   SELECT INTO "nl:"
    dm.pref_nbr
    FROM dm_prefs dm
    WHERE dm.application_nbr=300000
     AND dm.person_id=0.0
     AND dm.pref_domain="PHARMNET"
     AND dm.pref_section="FORMULARY"
     AND dm.pref_name="IDENTSYNC"
    DETAIL
     giidentsyncpref = dm.pref_nbr
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("IDENTSYNC pref not set. Not syncing Procure identifiers")
    SET giidentsyncpref = 0
   ENDIF
   IF (giidentsyncpref > 0)
    SELECT INTO "nl:"
     dm.pref_cd
     FROM dm_prefs dm
     WHERE dm.application_nbr=300000
      AND dm.person_id=0.0
      AND dm.pref_domain="PHARMNET"
      AND dm.pref_section="FORMULARY"
      AND dm.pref_name="IDENTSYNCRXTYPE"
     DETAIL
      cidentsynctypepref = dm.pref_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Error loading IDENTSYNCRXTYPE pref. Set pref in phadbtools.")
     SET ireturn = 0
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dm.pref_nbr
    FROM dm_prefs dm
    WHERE dm.application_nbr=300000
     AND dm.person_id=0.0
     AND dm.pref_section="FORMULARY"
     AND dm.pref_name="PROCURE"
    DETAIL
     IF (dm.pref_domain="PHARMNET-INPATIENT")
      gicurinvpreflevelinp = dm.pref_nbr
     ELSEIF (dm.pref_domain="PHARMENT-RETAIL")
      gicurinvpreflevelret = dm.pref_nbr
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("Error loading PROCURE tracking level pref. Set pref in phadbtools.")
    SET ireturn = 0
   ENDIF
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE getprocureidentifiermatches(null)
   DECLARE cnt = i4 WITH protect
   DECLARE i = i4 WITH protect
   SELECT INTO "nl:"
    id.item_id, id.item_level_flag, id.pha_type_flag,
    i.identifier_id, i.identifier_type_cd, i.value,
    i.value_key
    FROM (dummyt d1  WITH seq = value(size(tmp_med_def_updt->med_def_list,5))),
     (dummyt d2  WITH seq = 1),
     item_definition id,
     identifier i
    PLAN (d1
     WHERE maxrec(d2,size(tmp_med_def_updt->med_def_list[d1.seq].ident_list,5)))
     JOIN (d2)
     JOIN (id
     WHERE (id.item_id=tmp_med_def_updt->med_def_list[d1.seq].item_id)
      AND id.item_type_cd=cdmeddefitem)
     JOIN (i
     WHERE i.parent_entity_id=id.item_id
      AND i.parent_entity_name="ITEM_DEFINITION"
      AND (i.identifier_type_cd=tmp_med_def_updt->med_def_list[d1.seq].ident_list[d2.seq].
     identifier_type_cd))
    DETAIL
     i = (i+ 1),
     CALL echo(build2("Searching for Procure identifier: ",trim(cnvtstring(i))," of ",trim(cnvtstring
       (procureidentcnt))))
     IF ((((tmp_med_def_updt->med_def_list[d1.seq].ident_list[d2.seq].pharm_type_cd=cdinpatient)
      AND ((id.pha_type_flag=1) OR (id.pha_type_flag=3
      AND cidentsynctypepref=cdinpatient)) ) OR ((tmp_med_def_updt->med_def_list[d1.seq].ident_list[
     d2.seq].pharm_type_cd=cdretail)
      AND ((id.pha_type_flag=2) OR (id.pha_type_flag=3
      AND cidentsynctypepref=cdretail)) )) )
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(procure_updt_rec->procure_ident_list,(cnt+ 99))
      ENDIF
      procure_updt_rec->procure_ident_list[cnt].identifier_id = i.identifier_id, procure_updt_rec->
      procure_ident_list[cnt].new_identifier = tmp_med_def_updt->med_def_list[d1.seq].ident_list[d2
      .seq].new_identifier
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    id.item_id, id.item_level_flag, id.pha_type_flag,
    i.identifier_id, i.identifier_type_cd, i.value,
    i.value_key
    FROM (dummyt d1  WITH seq = value(size(tmp_manf_updt->manf_list,5))),
     (dummyt d2  WITH seq = 1),
     med_product mp,
     item_definition id,
     identifier i
    PLAN (d1
     WHERE maxrec(d2,size(tmp_manf_updt->manf_list[d1.seq].ident_list,5)))
     JOIN (d2)
     JOIN (mp
     WHERE (mp.med_product_id=tmp_manf_updt->manf_list[d1.seq].med_prod_id))
     JOIN (id
     WHERE id.item_id=mp.manf_item_id
      AND id.item_type_cd=cdmanfitem)
     JOIN (i
     WHERE i.parent_entity_id=id.item_id
      AND i.parent_entity_name="ITEM_DEFINITION"
      AND (i.identifier_type_cd=tmp_manf_updt->manf_list[d1.seq].ident_list[d2.seq].
     identifier_type_cd))
    DETAIL
     i = (i+ 1),
     CALL echo(build("Searching for Procure identifier: ",trim(cnvtstring(i))," of ",trim(cnvtstring(
        procureidentcnt)))), cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(procure_updt_rec->procure_ident_list,(cnt+ 99))
     ENDIF
     procure_updt_rec->procure_ident_list[cnt].identifier_id = i.identifier_id, procure_updt_rec->
     procure_ident_list[cnt].new_identifier = tmp_manf_updt->manf_list[d1.seq].ident_list[d2.seq].
     new_identifier
    WITH nocounter
   ;end select
   IF (mod(cnt,100) != 0)
    SET stat = alterlist(procure_updt_rec->procure_ident_list,cnt)
   ENDIF
   IF (debug_ind=1)
    CALL echo("procure_updt_rec after loading med_def and manf identifiers")
    CALL echorecord(procure_updt_rec)
   ENDIF
 END ;Subroutine
#exit_script
 IF (ident_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",trim(cnvtstring(ident_mismatch_cnt)),
    " identifier mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (procure_ident_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",trim(cnvtstring(procure_ident_mismatch_cnt)),
    " procure identifier mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (script_mode=eupdate_mode
  AND (request->commit_ind=1)
  AND ((ident_mismatch_cnt=0
  AND procure_ident_mismatch_cnt=0) OR (ignore_mismatch_warn=1))
  AND identifiersloaded=1)
  CALL echo("Committing changes")
  COMMIT
  EXECUTE ams_define_toolkit_common
  CALL updtdminfo(script_name,cnvtreal(size(updt_rec->ident_list,5)))
 ELSEIF (script_mode=eupdate_mode)
  CALL echo("Rolling back changes")
  ROLLBACK
 ENDIF
 CALL echo("All Done")
 SET last_mod = "002"
END GO
