CREATE PROGRAM ams_cleanup_iv_ord_cat:dba
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
 DECLARE additemforupdate(itemid=f8,rxmnem=vc,catalogcd=f8,medoedefid=f8) = null WITH protect
 DECLARE addsynforupdate(synid=f8,mnemonic=vc,catalogcd=f8) = null WITH protect
 DECLARE getinvalidprimaries(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE loaditemstoupdate(null) = null WITH protect
 DECLARE loadsynstoupdate(null) = null WITH protect
 DECLARE loadprimariestocleanup(null) = null WITH protect
 DECLARE createcsv(null) = i2 WITH protect
 DECLARE promptuserforoutputfile(null) = null WITH protect
 DECLARE checkforlvpswithmmdcs(null) = null WITH protect
 DECLARE updatelvpckis(null) = null WITH protect
 DECLARE removeinvalidsynonymproductlinks(null) = null WITH protect
 DECLARE setsearchckis(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                    AMS IV Order Catalog Cleanup Utility                    ")
 DECLARE detail_line = c75 WITH protect, constant(
  "        Remap products and synonyms from underneath invalid primaries       ")
 DECLARE rxmnemonic_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE desc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE system_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE domain = vc WITH protect, constant(curdomain)
 DECLARE report_mode = i2 WITH protect, constant(1)
 DECLARE update_mode = i2 WITH protect, constant(2)
 DECLARE set_cki = i2 WITH protect, constant(3)
 DECLARE from_str = vc WITH protect, constant("AMS_IV_ORD_CAT_CLEANUP@CERNER.COM")
 DECLARE dnumcnt = i4 WITH protect, noconstant(5)
 DECLARE mode = i2 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE j = i4 WITH protect
 DECLARE k = i4 WITH protect
 DECLARE l = i4 WITH protect
 DECLARE x_cki = i4 WITH protect
 DECLARE x_match = i4 WITH protect
 DECLARE x_item = i4 WITH protect
 DECLARE x_syn = i4 WITH protect
 DECLARE correctcatalogcd = f8 WITH protect
 DECLARE activeitemcnt = i4 WITH protect
 DECLARE activesyncnt = i4 WITH protect
 DECLARE updtitemcnt = i4 WITH protect
 DECLARE updtsyncnt = i4 WITH protect
 DECLARE ckicnt = i4 WITH protect
 DECLARE primcnt = i4 WITH protect
 DECLARE syncnt = i4 WITH protect
 DECLARE totalprimcnt = i4 WITH protect
 DECLARE totalitemcnt = i4 WITH protect
 DECLARE totalsyncnt = i4 WITH protect
 DECLARE itemcnt = i4 WITH protect
 DECLARE newprimcnt = i4 WITH protect
 DECLARE ckipos = i4 WITH protect
 DECLARE catpos = i4 WITH protect
 DECLARE outputfilename = vc WITH protect, noconstant(" ")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 RECORD cki_rec(
   1 cki_list[*]
     2 cki = vc
     2 standard_display = vc
     2 match_list[*]
       3 primary = vc
       3 current_catalog_cd = f8
       3 cat_synonym_id = f8
       3 clean_up_ind = i2
       3 synonym_list[*]
         4 synonym_id = f8
         4 new_prim_cki = vc
         4 syn_active_ind = i2
         4 mnemonic = vc
         4 mnemonic_type_cd = f8
         4 mnemonic_cki = vc
         4 syn_new_prim_list[*]
           5 syn_new_prim = vc
           5 syn_new_cat_cd = f8
           5 syn_new_cat_active_ind = i2
       3 item_list[*]
         4 item_id = f8
         4 new_cki = vc
         4 item_active_ind = i2
         4 rxmnemonic = vc
         4 description = vc
         4 med_oe_def_id = f8
         4 item_new_prim_list[*]
           5 item_new_prim = vc
           5 item_new_cat_cd = f8
           5 item_new_cat_active_ind = i2
 ) WITH protect
 RECORD updt_items(
   1 list[*]
     2 item_id = f8
     2 new_catalog_cd = f8
     2 med_oe_def_id = f8
 ) WITH protect
 RECORD updt_syns(
   1 list[*]
     2 synonym_id = f8
     2 new_catalog_cd = f8
 ) WITH protect
 RECORD cleanup_primaries(
   1 list_sz = i4
   1 list[*]
     2 catalog_cd = f8
     2 mnemonic = vc
 ) WITH protect
 RECORD lvps(
   1 qual_cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 primary = vc
     2 cki = vc
     2 new_cki = vc
     2 num_of_items = i4
 ) WITH protect
 CALL validatelogin(null)
 SET stat = alterlist(cki_rec->cki_list,dnumcnt)
 SET cki_rec->cki_list[1].cki = "MUL.ORD!d04128"
 SET cki_rec->cki_list[1].standard_display = "LVP solution"
 SET cki_rec->cki_list[2].cki = "MUL.ORD!d04129"
 SET cki_rec->cki_list[2].standard_display = "LVP solution with potassium"
 SET cki_rec->cki_list[3].cki = "MUL.ORD!d04130"
 SET cki_rec->cki_list[3].standard_display = "LVP solution with hypertonic saline"
 SET cki_rec->cki_list[4].cki = "MUL.ORD!d04131"
 SET cki_rec->cki_list[4].standard_display = "parenteral nutrition solution"
 SET cki_rec->cki_list[5].cki = "MUL.ORD!d04132"
 SET cki_rec->cki_list[5].standard_display = "parenteral nutrition solution w/electrolytes"
#main_menu
 SET mode = 0
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 2),(soffcol+ 21),"1 Create a report showing where")
 CALL text((soffrow+ 3),(soffcol+ 23),"synonyms and products will move")
 CALL text((soffrow+ 5),(soffcol+ 21),"2 Remap synonyms and products")
 IF ((cki_rec->cki_list[1].cki="MUL.ORD!d04128")
  AND dnumcnt=5)
  CALL text((soffrow+ 6),(soffcol+ 23),"from primaries with CKIs d04128-d04132")
 ELSE
  CALL text((soffrow+ 6),(soffcol+ 23),"from user defined primaries")
 ENDIF
 CALL text((soffrow+ 8),(soffcol+ 21),"3 Set CKIs to use in search")
 CALL text((soffrow+ 9),(soffcol+ 23),"for IV synonyms and products")
 CALL text((soffrow+ 11),(soffcol+ 21),"4 Exit")
 CALL accept((soffrow+ 16),(soffcol+ 18),"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   SET mode = report_mode
  OF 2:
   SET mode = update_mode
  OF 3:
   SET mode = set_cki
  OF 4:
   GO TO exit_script
 ENDCASE
 CALL clearscreen(null)
 IF (mode=report_mode)
  SET stat = initrec(log)
  SET outputfilename = concat("iv_cleanup_",trim(cnvtlower(getclient(null))),"_",trim(cnvtlower(
     domain)),".csv")
  CALL checkforlvpswithmmdcs(null)
  CALL getinvalidprimaries(null)
  CALL promptuserforoutputfile(null)
  GO TO main_menu
 ELSEIF (mode=update_mode)
  SET stat = initrec(log)
  SET logfilename = concat("iv_cleanup_",cnvtlower(format(cnvtdatetime(curdate,curtime3),
     "dd_mmm_yyyy_hh_mm;;q")),".log")
  CALL addlogmsg("INFO","BEGINNING IV ORDER CATALOG CLEANUP")
  CALL getinvalidprimaries(null)
  CALL loaditemstoupdate(null)
  CALL loadsynstoupdate(null)
  CALL loadprimariestocleanup(null)
  CALL performupdates(null)
 ELSEIF (mode=set_cki)
  SET stat = initrec(cki_rec)
  SET dnumcnt = 0
  CALL clearscreen(null)
  CALL setsearchckis(null)
 ENDIF
 SUBROUTINE setsearchckis(null)
   DECLARE complete = i2 WITH protect, noconstant(0)
   WHILE (complete=0)
     CALL text(soffrow,soffcol,"Enter complete CKI to use in search for IV order catalog products:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(30);C")
     SET dnumcnt = (dnumcnt+ 1)
     SET stat = alterlist(cki_rec->cki_list,dnumcnt)
     SET cki_rec->cki_list[dnumcnt].cki = trim(curaccept)
     IF (dnumcnt > 0)
      CALL text((soffrow+ 4),soffcol,"Search CKIs:")
      FOR (i = 1 TO dnumcnt)
        CALL text(((soffrow+ i)+ 4),soffcol,cki_rec->cki_list[i].cki)
      ENDFOR
     ENDIF
     CALL text((soffrow+ 2),soffcol,"Enter another CKI?:")
     CALL accept((soffrow+ 2),(soffcol+ 20),"A;CU","N"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="N")
      SET complete = 1
     ELSE
      CALL clear((soffrow+ 2),soffcol,numcols)
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE additemforupdate(itemid,rxmnem,catalogcd,medoedefid)
   SET updtitemcnt = (updtitemcnt+ 1)
   IF (mod(updtitemcnt,10)=1)
    SET stat = alterlist(updt_items->list,(updtitemcnt+ 9))
   ENDIF
   SET updt_items->list[updtitemcnt].item_id = itemid
   SET updt_items->list[updtitemcnt].new_catalog_cd = catalogcd
   IF (medoedefid=0)
    CALL addlogmsg("INFO",build2("Moving item: ",trim(rxmnem)," to primary: ",trim(
       uar_get_code_display(catalogcd))))
   ELSE
    SET updt_items->list[updtitemcnt].med_oe_def_id = medoedefid
    CALL addlogmsg("INFO",build2("Moving item: ",trim(rxmnem)," to primary: ",trim(
       uar_get_code_display(catalogcd))))
    CALL addlogmsg("INFO",build2("Removing default ordered as synonym from: ",trim(rxmnem),
      " because it was set to the primary"))
   ENDIF
 END ;Subroutine
 SUBROUTINE addsynforupdate(synid,mnemonic,catalogcd)
   SET updtsyncnt = (updtsyncnt+ 1)
   IF (mod(updtsyncnt,10)=1)
    SET stat = alterlist(updt_syns->list,(updtsyncnt+ 9))
   ENDIF
   SET updt_syns->list[updtsyncnt].synonym_id = synid
   SET updt_syns->list[updtsyncnt].new_catalog_cd = catalogcd
   CALL addlogmsg("INFO",build2("Moving synonym: ",trim(mnemonic)," to primary: ",trim(
      uar_get_code_display(catalogcd))))
 END ;Subroutine
 SUBROUTINE getinvalidprimaries(null)
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Finding primaries with invalid CKI values and products underneath them")
   CALL addlogmsg("INFO","**********************************************************")
   IF (mode=update_mode)
    CALL text(soffrow,soffcol,
     "Finding primaries with invalid CKI values and products underneath them...")
   ENDIF
   SELECT INTO "nl:"
    oc.catalog_cd, mmdc.main_multum_drug_code
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     order_catalog_item_r ocir,
     medication_definition md,
     med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     order_catalog_synonym ocs2,
     mltm_ndc_main_drug_code mmdc,
     order_catalog oc1
    PLAN (oc
     WHERE oc.activity_type_cd=pharm_act_cd
      AND expand(i,1,dnumcnt,cnvtupper(oc.cki),cnvtupper(cki_rec->cki_list[i].cki))
      AND ((oc.catalog_cd+ 0) != 0))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd
      AND ocs.mnemonic_type_cd=primary_cd)
     JOIN (ocir
     WHERE ocir.catalog_cd=oc.catalog_cd
      AND ((ocir.item_id+ 0) != 0)
      AND ((ocir.synonym_id+ 0) != 0))
     JOIN (md
     WHERE md.item_id=ocir.item_id)
     JOIN (mi
     WHERE mi.item_id=md.item_id
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND mi.primary_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=md.item_id
      AND mdf.flex_type_cd=system_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mod
     WHERE mod.med_oe_defaults_id=outerjoin(mfoi.parent_entity_id))
     JOIN (ocs2
     WHERE ocs2.synonym_id=ocir.synonym_id)
     JOIN (mmdc
     WHERE mmdc.main_multum_drug_code=outerjoin(cnvtreal(substring(12,99,md.cki))))
     JOIN (oc1
     WHERE cnvtupper(oc1.cki)=outerjoin(replace(md.cki,"FRMLTN","MMDC"))
      AND oc1.activity_type_cd=outerjoin(pharm_act_cd)
      AND oc1.cki > outerjoin(" "))
    ORDER BY oc.cki, oc.catalog_cd, md.item_id,
     oc1.catalog_cd
    HEAD REPORT
     ckicnt = 0, totalprimcnt = 0, totalitemcnt = 0
    HEAD oc.cki
     ckicnt = (ckicnt+ 1), cki_rec->cki_list[ckicnt].cki = oc.cki, primcnt = 0
    HEAD oc.catalog_cd
     totalprimcnt = (totalprimcnt+ 1), primcnt = (primcnt+ 1)
     IF (mod(primcnt,10)=1)
      stat = alterlist(cki_rec->cki_list[ckicnt].match_list,(primcnt+ 9))
     ENDIF
     cki_rec->cki_list[ckicnt].match_list[primcnt].current_catalog_cd = oc.catalog_cd, cki_rec->
     cki_list[ckicnt].match_list[primcnt].primary = oc.primary_mnemonic, cki_rec->cki_list[ckicnt].
     match_list[primcnt].cat_synonym_id = ocs.synonym_id,
     cki_rec->cki_list[ckicnt].match_list[primcnt].clean_up_ind = 1, itemcnt = 0
    HEAD md.item_id
     totalitemcnt = (totalitemcnt+ 1), itemcnt = (itemcnt+ 1)
     IF (mod(itemcnt,10)=1)
      stat = alterlist(cki_rec->cki_list[ckicnt].match_list[primcnt].item_list,(itemcnt+ 9))
     ENDIF
     cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].item_id = md.item_id, cki_rec->
     cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].item_active_ind = mdf.active_ind,
     cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].rxmnemonic = ocs2.mnemonic,
     cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].description = mi.value
     IF (mmdc.drug_identifier IN ("d04128", "d04129", "d04130", "d04131", "d04132"))
      cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].new_cki = replace(md.cki,
       "FRMLTN","MMDC")
     ELSE
      IF (mmdc.drug_identifier > " ")
       cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].new_cki = concat("MUL.ORD!",
        mmdc.drug_identifier)
      ELSE
       cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].new_cki =
       "No drug formulation"
      ENDIF
     ENDIF
     cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].med_oe_def_id =
     IF ((mod.ord_as_synonym_id=cki_rec->cki_list[ckicnt].match_list[primcnt].cat_synonym_id)) mod
      .med_oe_defaults_id
     ELSE 0
     ENDIF
     , cki_rec->cki_list[ckicnt].match_list[primcnt].clean_up_ind = 0, newprimcnt = 0
    DETAIL
     IF (oc1.catalog_cd > 0)
      newprimcnt = (newprimcnt+ 1)
      IF (mod(newprimcnt,10)=1)
       stat = alterlist(cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].
        item_new_prim_list,(newprimcnt+ 9))
      ENDIF
      cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].item_new_prim_list[newprimcnt]
      .item_new_prim = oc1.primary_mnemonic, cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[
      itemcnt].item_new_prim_list[newprimcnt].item_new_cat_cd = oc1.catalog_cd, cki_rec->cki_list[
      ckicnt].match_list[primcnt].item_list[itemcnt].item_new_prim_list[newprimcnt].
      item_new_cat_active_ind = oc1.active_ind
     ENDIF
    FOOT  md.item_id
     IF (mod(newprimcnt,10) != 0)
      stat = alterlist(cki_rec->cki_list[ckicnt].match_list[primcnt].item_list[itemcnt].
       item_new_prim_list,newprimcnt)
     ENDIF
    FOOT  oc.catalog_cd
     IF (mod(itemcnt,10) != 0)
      stat = alterlist(cki_rec->cki_list[ckicnt].match_list[primcnt].item_list,itemcnt)
     ENDIF
    FOOT  oc.cki
     IF (mod(primcnt,10) != 0)
      stat = alterlist(cki_rec->cki_list[ckicnt].match_list,primcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL addlogmsg("INFO","Found invalid CKIs")
    CALL addlogmsg("INFO",build2("CKI Count: ",trim(cnvtstring(totalprimcnt))))
    CALL addlogmsg("INFO",build2("Items under primary: ",trim(cnvtstring(totalitemcnt))))
   ELSE
    CALL addlogmsg("WARNING","Did not find any items under invalid CKIs")
   ENDIF
   IF (mode=update_mode
    AND curqual > 0)
    CALL text((soffrow+ 1),soffcol,"Found invalid CKIs")
    CALL text((soffrow+ 2),soffcol,build2("CKI Count: ",trim(cnvtstring(totalprimcnt))))
    CALL text((soffrow+ 3),soffcol,build2("Items under primary: ",trim(cnvtstring(totalitemcnt))))
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","CKI_REC AFTER POPULATING ITEM INFO")
    CALL echorecord(cki_rec,logfilename,1)
   ENDIF
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Finding primaries with invalid CKI values and synonyms underneath them")
   CALL addlogmsg("INFO","**********************************************************")
   IF (mode=update_mode)
    CALL text((soffrow+ 4),soffcol,"Now checking for synonyms under invalid primaries...")
   ENDIF
   SELECT INTO "nl:"
    oc.cki, oc.catalog_cd, ocs.mnemonic
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     mltm_order_catalog_load mocl,
     order_catalog oc2
    PLAN (oc
     WHERE oc.activity_type_cd=pharm_act_cd
      AND expand(i,1,dnumcnt,cnvtupper(oc.cki),cnvtupper(cki_rec->cki_list[i].cki))
      AND ((oc.catalog_cd+ 0) != 0))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd
      AND  NOT (ocs.mnemonic_type_cd IN (rxmnemonic_cd)))
     JOIN (mocl
     WHERE mocl.synonym_cki=outerjoin(ocs.cki))
     JOIN (oc2
     WHERE oc2.cki=outerjoin(mocl.catalog_cki))
    ORDER BY oc.cki, oc.catalog_cd, ocs.mnemonic,
     oc2.catalog_cd
    HEAD REPORT
     totalprimcnt = 0, totalsyncnt = 0, ckipos = 0,
     catpos = 0
    HEAD oc.cki
     ckipos = locateval(j,1,size(cki_rec->cki_list,5),oc.cki,cki_rec->cki_list[j].cki)
    HEAD oc.catalog_cd
     totalprimcnt = (totalprimcnt+ 1), catpos = locateval(k,1,size(cki_rec->cki_list[ckipos].
       match_list,5),oc.catalog_cd,cki_rec->cki_list[ckipos].match_list[k].current_catalog_cd),
     syncnt = 0
    HEAD ocs.mnemonic
     IF (catpos=0)
      catpos = (size(cki_rec->cki_list[ckipos].match_list,5)+ 1), stat = alterlist(cki_rec->cki_list[
       ckipos].match_list,catpos), cki_rec->cki_list[ckipos].match_list[catpos].primary = oc
      .primary_mnemonic,
      cki_rec->cki_list[ckipos].match_list[catpos].current_catalog_cd = oc.catalog_cd, cki_rec->
      cki_list[ckipos].match_list[catpos].clean_up_ind = 1
     ENDIF
     IF (ocs.mnemonic_type_cd != primary_cd)
      totalsyncnt = (totalsyncnt+ 1), cki_rec->cki_list[ckipos].match_list[catpos].clean_up_ind = 0
     ELSE
      cki_rec->cki_list[ckipos].match_list[catpos].cat_synonym_id = ocs.synonym_id
     ENDIF
     syncnt = (syncnt+ 1)
     IF (mod(syncnt,10)=1)
      stat = alterlist(cki_rec->cki_list[ckipos].match_list[catpos].synonym_list,(syncnt+ 9))
     ENDIF
     cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].synonym_id = ocs.synonym_id,
     cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].mnemonic = ocs.mnemonic,
     cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].mnemonic_type_cd = ocs
     .mnemonic_type_cd,
     cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].mnemonic_cki = ocs.cki,
     cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].syn_active_ind = ocs
     .active_ind, cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].new_prim_cki =
     mocl.catalog_cki,
     newprimcnt = 0
    DETAIL
     IF (oc2.catalog_cd > 0)
      newprimcnt = (newprimcnt+ 1)
      IF (mod(newprimcnt,10)=1)
       stat = alterlist(cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].
        syn_new_prim_list,(newprimcnt+ 9))
      ENDIF
      cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].syn_new_prim_list[newprimcnt]
      .syn_new_cat_cd = oc2.catalog_cd, cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[
      syncnt].syn_new_prim_list[newprimcnt].syn_new_prim = oc2.primary_mnemonic, cki_rec->cki_list[
      ckipos].match_list[catpos].synonym_list[syncnt].syn_new_prim_list[newprimcnt].
      syn_new_cat_active_ind = oc2.active_ind
     ENDIF
    FOOT  ocs.mnemonic
     IF (mod(newprimcnt,10) != 0)
      stat = alterlist(cki_rec->cki_list[ckipos].match_list[catpos].synonym_list[syncnt].
       syn_new_prim_list,newprimcnt)
     ENDIF
    FOOT  oc.catalog_cd
     IF (mod(syncnt,10) != 0)
      stat = alterlist(cki_rec->cki_list[ckipos].match_list[catpos].synonym_list,syncnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL addlogmsg("INFO","Found invalid CKIs")
    CALL addlogmsg("INFO",build2("CKI Count: ",trim(cnvtstring(totalprimcnt))))
    CALL addlogmsg("INFO",build2("Synonyms under primary: ",trim(cnvtstring(totalsyncnt))))
   ELSE
    CALL addlogmsg("WARNING","Did not find any synonyms under invalid CKIs")
   ENDIF
   IF (mode=update_mode
    AND curqual > 0)
    CALL text((soffrow+ 5),soffcol,build2("CKI Count: ",trim(cnvtstring(totalprimcnt))))
    CALL text((soffrow+ 6),soffcol,build2("Synonyms under primary: ",trim(cnvtstring(totalsyncnt))))
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","CKI_REC AFTER POPULATING SYNONYM INFO")
    CALL echorecord(cki_rec,logfilename,1)
   ENDIF
   SET status = "Z"
   FOR (i = 1 TO dnumcnt)
     IF (size(cki_rec->cki_list[i].match_list,5) > 0)
      SET status = "S"
     ENDIF
   ENDFOR
   IF (status="Z")
    SET statusstr = "No invalid CKIs found"
    CALL addlogmsg("WARNING",statusstr)
    CALL addlogmsg("INFO","Exiting script")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Performing Updates")
   CALL addlogmsg("INFO","**********************************************************")
   CALL text((soffrow+ 7),soffcol,"Performing updates...")
   IF (updtitemcnt > 0)
    SELECT INTO "nl:"
     ocir.catalog_cd
     FROM order_catalog_item_r ocir
     PLAN (ocir
      WHERE expand(i,1,updtitemcnt,ocir.item_id,updt_items->list[i].item_id))
     WITH nocounter, forupdate(ocir)
    ;end select
    SELECT INTO "nl:"
     ocs.catalog_cd
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE expand(i,1,updtitemcnt,ocs.item_id,updt_items->list[i].item_id))
     WITH nocounter, forupdate(ocs)
    ;end select
    SELECT INTO "nl:"
     mod.med_oe_defaults_id
     FROM med_oe_defaults mod
     PLAN (mod
      WHERE expand(i,1,updtitemcnt,mod.med_oe_defaults_id,updt_items->list[i].med_oe_def_id))
     WITH nocounter, forupdate(mod)
    ;end select
    UPDATE  FROM (dummyt d  WITH seq = value(updtitemcnt)),
      order_catalog_item_r ocir
     SET ocir.catalog_cd = updt_items->list[d.seq].new_catalog_cd, ocir.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ocir.updt_id = reqinfo->updt_id,
      ocir.updt_cnt = (ocir.updt_cnt+ 1), ocir.updt_applctx = 0, ocir.updt_task = - (267)
     PLAN (d)
      JOIN (ocir
      WHERE (ocir.item_id=updt_items->list[d.seq].item_id)
       AND ocir.item_id != 0)
     WITH nocounter
    ;end update
    IF (curqual=value(updtitemcnt))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(updtitemcnt)),
       " rows on order_catalog_item_r"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING ORDER_CATALOG_ITEM_R")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         updtitemcnt))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(size(updt_items->list,5)))
       CALL addlogmsg("ERROR",build2("Updating item_id: ",trim(cnvtstring(updt_items->list[i].item_id
           ))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check order_catalog_item_r for missing or duplicated rows using the above item_ids")
     CALL text((soffrow+ 8),soffcol,"ERROR UPDATING ORDER_CATALOG_ITEM_R ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," updtItemCnt = ",trim(cnvtstring(
        updtitemcnt)))
     GO TO exit_script
    ENDIF
    UPDATE  FROM (dummyt d  WITH seq = value(updtitemcnt)),
      order_catalog_synonym ocs
     SET ocs.catalog_cd = updt_items->list[d.seq].new_catalog_cd, ocs.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = 0, ocs.updt_task = - (267)
     PLAN (d)
      JOIN (ocs
      WHERE (ocs.item_id=updt_items->list[d.seq].item_id)
       AND ocs.item_id != 0)
     WITH nocounter
    ;end update
    IF (curqual=value(updtitemcnt))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(updtitemcnt)),
       " rows on order_catalog_synonym for items moving primaries"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING ORDER_CATALOG_SYNONYM FOR PRODUCTS")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         updtitemcnt))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(size(updt_items->list,5)))
       CALL addlogmsg("ERROR",build2("Updating item_id: ",trim(cnvtstring(updt_items->list[i].item_id
           ))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check order_catalog_synonym for missing or duplicated rows using the above item_ids")
     CALL text((soffrow+ 8),soffcol,"ERROR UPDATING ORDER_CATALOG_SYNONYM ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," updtItemCnt = ",trim(cnvtstring(
        updtitemcnt)))
     GO TO exit_script
    ENDIF
    UPDATE  FROM med_oe_defaults mod
     SET mod.ord_as_synonym_id = 0, mod.updt_dt_tm = cnvtdatetime(curdate,curtime3), mod.updt_id =
      reqinfo->updt_id,
      mod.updt_task = - (267), mod.updt_applctx = 0, mod.updt_cnt = (mod.updt_cnt+ 1)
     WHERE expand(i,1,updtitemcnt,mod.med_oe_defaults_id,updt_items->list[i].med_oe_def_id)
      AND mod.med_oe_defaults_id != 0
     WITH nocounter
    ;end update
    IF (curqual > 0)
     CALL addlogmsg("INFO",build2("Removed default ordered as synonym from ",trim(cnvtstring(curqual)
        )," products"))
    ELSE
     CALL addlogmsg("INFO","Did not remove default ordered as synonym from any products")
    ENDIF
    CALL text((soffrow+ 8),soffcol,build2("Successfully remapped ",trim(cnvtstring(updtitemcnt)),
      " items"))
   ELSE
    CALL addlogmsg("INFO","No items to move")
    CALL text((soffrow+ 8),soffcol,"No items to move")
   ENDIF
   IF (updtsyncnt > 0)
    SELECT INTO "nl:"
     ocs.catalog_cd
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE expand(i,1,updtsyncnt,ocs.synonym_id,updt_syns->list[i].synonym_id))
     WITH nocounter, forupdate(ocs)
    ;end select
    UPDATE  FROM (dummyt d  WITH seq = value(updtsyncnt)),
      order_catalog_synonym ocs
     SET ocs.catalog_cd = updt_syns->list[d.seq].new_catalog_cd, ocs.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = 0, ocs.updt_task = - (267)
     PLAN (d)
      JOIN (ocs
      WHERE (ocs.synonym_id=updt_syns->list[d.seq].synonym_id)
       AND ocs.synonym_id != 0)
     WITH nocounter
    ;end update
    IF (curqual=value(updtsyncnt))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(updtitemcnt)),
       " rows on order_catalog_synonym for synonyms moving primaries"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING ORDER_CATALOG_SYNONYM FOR SYNONYMS")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         updtsyncnt))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(size(updt_syns->list,5)))
       CALL addlogmsg("ERROR",build2("Updating synonym_id: ",trim(cnvtstring(updt_syns->list[i].
           synonym_id))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check order_catalog_synonym for missing or duplicated rows using the above synonym_ids")
     CALL text((soffrow+ 9),soffcol,"ERROR UPDATING ORDER_CATALOG_SYNONYM ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," updtSynCnt = ",trim(cnvtstring(
        updtsyncnt)))
     GO TO exit_script
    ENDIF
    CALL text((soffrow+ 9),soffcol,build2("Successfully remapped ",trim(cnvtstring(updtsyncnt)),
      " synonyms"))
   ELSE
    CALL addlogmsg("INFO","No synonyms to move")
    CALL text((soffrow+ 9),soffcol,"No synonyms to move")
   ENDIF
   CALL removeinvalidsynonymproductlinks(null)
   IF ((cleanup_primaries->list_sz > 0))
    SELECT INTO "nl:"
     oc.catalog_cd
     FROM order_catalog oc
     PLAN (oc
      WHERE expand(i,1,cleanup_primaries->list_sz,oc.catalog_cd,cleanup_primaries->list[i].catalog_cd
       ))
     WITH nocounter, forupdate(oc)
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE expand(i,1,cleanup_primaries->list_sz,cv.code_value,cleanup_primaries->list[i].catalog_cd
       )
       AND cv.code_set=200)
     WITH nocounter, forupdate(cv)
    ;end select
    SELECT INTO "nl:"
     ocs.catalog_cd
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE expand(i,1,cleanup_primaries->list_sz,ocs.catalog_cd,cleanup_primaries->list[i].
       catalog_cd)
       AND ocs.mnemonic_type_cd=primary_cd)
     WITH nocounter, forupdate(ocs)
    ;end select
    UPDATE  FROM (dummyt d1  WITH seq = value(cleanup_primaries->list_sz)),
      order_catalog oc
     SET oc.cki = "", oc.active_ind = 0, oc.primary_mnemonic = cleanup_primaries->list[d1.seq].
      mnemonic,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_cnt = (
      oc.updt_cnt+ 1),
      oc.updt_applctx = 0, oc.updt_task = - (267)
     PLAN (d1)
      JOIN (oc
      WHERE (oc.catalog_cd=cleanup_primaries->list[d1.seq].catalog_cd))
     WITH nocounter
    ;end update
    IF (curqual=value(cleanup_primaries->list_sz))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(cleanup_primaries->list_sz)
        )," rows on order_catalog"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING ORDER_CATALOG")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         cleanup_primaries->list_sz))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(cleanup_primaries->list_sz))
       CALL addlogmsg("ERROR",build2("Updating catalog_cd: ",trim(cnvtstring(cleanup_primaries->list[
           i].catalog_cd))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check code_value for missing or duplicated rows on code_set 200 using the above catalog_cds")
     CALL text((soffrow+ 8),soffcol,"ERROR UPDATING CODE_VALUE ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," cleanup_primaries size = ",trim(
       cnvtstring(cleanup_primaries->list_sz)))
     GO TO exit_script
    ENDIF
    UPDATE  FROM (dummyt d1  WITH seq = value(cleanup_primaries->list_sz)),
      code_value cv
     SET cv.cki = "", cv.display = trim(substring(1,40,cleanup_primaries->list[d1.seq].mnemonic)), cv
      .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,cleanup_primaries->list[d1.seq].
          mnemonic)))),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (
      cv.updt_cnt+ 1),
      cv.updt_applctx = 0, cv.updt_task = - (267)
     PLAN (d1)
      JOIN (cv
      WHERE (cv.code_value=cleanup_primaries->list[d1.seq].catalog_cd)
       AND cv.code_set=200)
     WITH nocounter
    ;end update
    IF (curqual=value(cleanup_primaries->list_sz))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(cleanup_primaries->list_sz)
        )," rows on code_value"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING CODE_VALUE")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         cleanup_primaries->list_sz))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(cleanup_primaries->list_sz))
       CALL addlogmsg("ERROR",build2("Updating catalog_cd: ",trim(cnvtstring(cleanup_primaries->list[
           i].catalog_cd))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check order_catalog for missing or duplicated rows using the above catalog_cds")
     CALL text((soffrow+ 8),soffcol,"ERROR UPDATING ORDER_CATALOG ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," cleanup_primaries size = ",trim(
       cnvtstring(cleanup_primaries->list_sz)))
     GO TO exit_script
    ENDIF
    UPDATE  FROM (dummyt d1  WITH seq = value(cleanup_primaries->list_sz)),
      order_catalog_synonym ocs
     SET ocs.active_ind = 0, ocs.mnemonic = cleanup_primaries->list[d1.seq].mnemonic, ocs
      .mnemonic_key_cap = cnvtupper(cleanup_primaries->list[d1.seq].mnemonic),
      ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
      ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = 0,
      ocs.updt_task = - (267)
     PLAN (d1)
      JOIN (ocs
      WHERE (ocs.catalog_cd=cleanup_primaries->list[d1.seq].catalog_cd)
       AND ocs.mnemonic_type_cd=primary_cd)
     WITH nocounter
    ;end update
    IF (curqual=value(cleanup_primaries->list_sz))
     CALL addlogmsg("INFO",build2("Successfully updated ",trim(cnvtstring(cleanup_primaries->list_sz)
        )," primary rows on order_catalog_synonym"))
    ELSE
     CALL addlogmsg("ERROR","ERROR UPDATING PRIMARY MNEMONIC ON ORDER_CATALOG_SYNONYM")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be updated: ",trim(cnvtstring(
         cleanup_primaries->list_sz))))
     CALL addlogmsg("ERROR",build2("Count of rows that were updated: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(cleanup_primaries->list_sz))
       CALL addlogmsg("ERROR",build2("Updating catalog_cd: ",trim(cnvtstring(cleanup_primaries->list[
           i].catalog_cd))))
     ENDFOR
     CALL addlogmsg("RESOLUTION",
      "Check order_catalog_synonym for missing or duplicated primary mnemonic rows using the above catalog_cds"
      )
     CALL text((soffrow+ 8),soffcol,"ERROR UPDATING ORDER_CATALOG_SYNONYM ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," cleanup_primaries size = ",trim(
       cnvtstring(cleanup_primaries->list_sz)))
     GO TO exit_script
    ENDIF
   ELSE
    CALL addlogmsg("INFO",
     "Not cleaning up any primaries because they all have products or synonyms still underneath them"
     )
   ENDIF
 END ;Subroutine
 SUBROUTINE loadsynstoupdate(null)
   DECLARE synsunderprim = i4 WITH protect
   DECLARE synsmoving = i4 WITH protect
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Determining how to move synonyms")
   CALL addlogmsg("INFO","**********************************************************")
   SET updtsyncnt = 0
   FOR (x_cki = 1 TO value(size(cki_rec->cki_list,5)))
     IF (value(size(cki_rec->cki_list[x_cki].match_list,5)) > 0)
      FOR (x_match = 1 TO value(size(cki_rec->cki_list[x_cki].match_list,5)))
        SET synsunderprim = (value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list,5))
         - 1)
        SET synsmoving = 0
        FOR (x_syn = 1 TO value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list,5)))
          IF ((cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic_type_cd !=
          primary_cd))
           IF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
             syn_new_prim_list,5))=1
            AND (cki_rec->cki_list[x_cki].match_list[x_match].current_catalog_cd != cki_rec->
           cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].
           syn_new_cat_cd))
            IF ((cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1
            ].syn_new_cat_active_ind=1))
             SET synsmoving = (synsmoving+ 1)
             CALL addsynforupdate(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
              synonym_id,cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic,
              cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].
              syn_new_cat_cd)
            ELSEIF ((cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
            syn_new_prim_list[1].syn_new_cat_active_ind=0)
             AND (cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_active_ind=0))
             SET synsmoving = (synsmoving+ 1)
             CALL addsynforupdate(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
              synonym_id,cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic,
              cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].
              syn_new_cat_cd)
            ELSE
             CALL addlogmsg("WARNING",build2("Cannot move synonym: ",trim(cki_rec->cki_list[x_cki].
                match_list[x_match].synonym_list[x_syn].mnemonic),
               " because synonym is active and matched primary is inactive: ",trim(cki_rec->cki_list[
                x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].syn_new_prim)))
            ENDIF
           ELSEIF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
             syn_new_prim_list,5)) > 1)
            SET i = value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
              syn_new_prim_list,5))
            SET activesyncnt = 0
            FOR (j = 1 TO i)
              IF ((cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
              item_new_prim_list[j].syn_new_cat_active_ind=1))
               SET activesyncnt = (activesyncnt+ 1)
               SET correctcatalogcd = cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn
               ].syn_new_prim_list[j].syn_new_cat_cd
              ENDIF
            ENDFOR
            IF (activesyncnt=1)
             SET synsmoving = (synsmoving+ 1)
             CALL addsynforupdate(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
              synonym_id,cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic,
              cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].
              syn_new_cat_cd)
            ELSEIF (activesyncnt > 1)
             CALL addlogmsg("WARNING",build2("Cannot move synonym: ",trim(cki_rec->cki_list[x_cki].
                match_list[x_match].synonym_list[x_syn].mnemonic),
               " because synonym is active and there are multiple active primaries for CKI: ",trim(
                cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].new_prim_cki)))
            ELSEIF (activesyncnt=0)
             IF ((cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_active_ind=1))
              CALL addlogmsg("WARNING",build2("Cannot move synonym: ",trim(cki_rec->cki_list[x_cki].
                 match_list[x_match].synonym_list[x_syn].mnemonic),
                " because synonym is active and there are multiple inactive primaries for CKI: ",trim
                (cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].new_prim_cki)))
             ELSE
              SET synsmoving = (synsmoving+ 1)
              CALL addsynforupdate(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
               synonym_id,cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic,
               cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].syn_new_prim_list[1].
               syn_new_cat_cd)
             ENDIF
            ENDIF
           ELSEIF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].synonym_list[x_syn].
             syn_new_prim_list,5))=0)
            CALL addlogmsg("WARNING",build2("Cannot move synonym: ",trim(cki_rec->cki_list[x_cki].
               match_list[x_match].synonym_list[x_syn].mnemonic)," because CKI: ",trim(cki_rec->
               cki_list[x_cki].match_list[x_match].synonym_list[x_syn].mnemonic_cki),
              " was not found on the mltm_order_catalog_load table"))
           ENDIF
          ENDIF
        ENDFOR
        IF (synsunderprim=synsmoving
         AND (cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind IN (0, 1)))
         SET cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind = 1
        ELSE
         SET cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind = 2
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (mod(updtsyncnt,10) != 0)
    SET stat = alterlist(updt_syns->list,updtsyncnt)
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","UPDT_SYNS REC AFTER BEING POPULATED")
    CALL echorecord(updt_syns,logfilename,1)
   ENDIF
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO",build2("Count of synonyms that are moving: ",trim(cnvtstring(updtsyncnt))))
   CALL addlogmsg("INFO",build2("Count of synonyms under primary: ",trim(cnvtstring(totalsyncnt))))
   CALL addlogmsg("INFO","**********************************************************")
 END ;Subroutine
 SUBROUTINE loaditemstoupdate(null)
   DECLARE itemsunderprim = i4 WITH protect
   DECLARE itemsmoving = i4 WITH protect
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Determining how to move items")
   CALL addlogmsg("INFO","**********************************************************")
   SET updtitemcnt = 0
   FOR (x_cki = 1 TO value(size(cki_rec->cki_list,5)))
     IF (value(size(cki_rec->cki_list[x_cki].match_list,5)) > 0)
      FOR (x_match = 1 TO value(size(cki_rec->cki_list[x_cki].match_list,5)))
        SET itemsunderprim = value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list,5))
        SET itemsmoving = 0
        FOR (x_item = 1 TO value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list,5)))
          IF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
            item_new_prim_list,5))=1)
           IF ((cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].
           item_new_cat_active_ind=1)
            AND (cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki !=
           "MUL.ORD!*"))
            SET itemsmoving = (itemsmoving+ 1)
            CALL additemforupdate(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             item_id,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].rxmnemonic,
             cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].
             item_new_cat_cd,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             med_oe_def_id)
           ELSEIF ((cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
           item_new_prim_list[1].item_new_cat_active_ind=0)
            AND (cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_active_ind=0))
            SET itemsmoving = (itemsmoving+ 1)
            CALL additemforupdate(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             item_id,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].rxmnemonic,
             cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].
             item_new_cat_cd,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             med_oe_def_id)
           ELSE
            CALL addlogmsg("WARNING",build2("Cannot move item: ",trim(cki_rec->cki_list[x_cki].
               match_list[x_match].item_list[x_item].rxmnemonic),
              " because product is active and matched primary is inactive: ",trim(cki_rec->cki_list[
               x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].item_new_prim)))
           ENDIF
          ELSEIF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
            item_new_prim_list,5)) > 1)
           SET i = value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             item_new_prim_list,5))
           SET activeitemcnt = 0
           FOR (j = 1 TO i)
             IF ((cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[j
             ].item_new_cat_active_ind=1))
              SET activeitemcnt = (activeitemcnt+ 1)
              SET correctcatalogcd = cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
              item_new_prim_list[j].item_new_cat_cd
             ENDIF
           ENDFOR
           IF (activeitemcnt=1)
            SET itemsmoving = (itemsmoving+ 1)
            CALL additemforupdate(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             item_id,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].rxmnemonic,
             cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].
             item_new_cat_cd,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
             med_oe_def_id)
           ELSEIF (activeitemcnt > 1)
            CALL addlogmsg("WARNING",build2("Cannot move item: ",trim(cki_rec->cki_list[x_cki].
               match_list[x_match].item_list[x_item].rxmnemonic),
              " because product is active and there are multiple active primaries for CKI: ",trim(
               cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki)))
           ELSEIF (activeitemcnt=0)
            IF ((cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_active_ind=1))
             CALL addlogmsg("WARNING",build2("Cannot move item: ",trim(cki_rec->cki_list[x_cki].
                match_list[x_match].item_list[x_item].rxmnemonic),
               " because product is active and there are multiple inactive primaries for CKI: ",trim(
                cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki)))
            ELSE
             SET itemsmoving = (itemsmoving+ 1)
             CALL additemforupdate(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
              item_id,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].rxmnemonic,
              cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].item_new_prim_list[1].
              item_new_cat_cd,cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
              med_oe_def_id)
            ENDIF
           ENDIF
          ELSEIF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
            item_new_prim_list,5))=0
           AND (cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki !=
          "MUL.ORD!d*"))
           CALL addlogmsg("WARNING",build2("Cannot move item: ",trim(cki_rec->cki_list[x_cki].
              match_list[x_match].item_list[x_item].rxmnemonic)," because CKI: ",trim(cki_rec->
              cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki),
             " was not found on the order_catalog table"))
          ELSEIF (value(size(cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].
            item_new_prim_list,5))=0
           AND (cki_rec->cki_list[x_cki].match_list[x_match].item_list[x_item].new_cki="MUL.ORD!d*"))
           CALL addlogmsg("WARNING",build2("Cannot move item: ",trim(cki_rec->cki_list[x_cki].
              match_list[x_match].item_list[x_item].rxmnemonic),
             " because it's correct primary has a dnum CKI"))
          ENDIF
        ENDFOR
        IF (itemsunderprim=itemsmoving
         AND (cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind IN (0, 1)))
         SET cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind = 1
        ELSE
         SET cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind = 2
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (mod(updtitemcnt,10) != 0)
    SET stat = alterlist(updt_items->list,updtitemcnt)
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","UPDT_ITEMS REC AFTER BEING POPULATED")
    CALL echorecord(updt_items,logfilename,1)
   ENDIF
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO",build2("Count of items that are moving: ",trim(cnvtstring(updtitemcnt))))
   CALL addlogmsg("INFO",build2("Count of items under primary: ",trim(cnvtstring(totalitemcnt))))
   CALL addlogmsg("INFO","**********************************************************")
 END ;Subroutine
 SUBROUTINE loadprimariestocleanup(null)
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Determining what primaries can be cleaned up")
   CALL addlogmsg("INFO","**********************************************************")
   SET totalprimcnt = 0
   FOR (x_cki = 1 TO value(size(cki_rec->cki_list,5)))
     FOR (x_match = 1 TO value(size(cki_rec->cki_list[x_cki].match_list,5)))
      SET totalprimcnt = (totalprimcnt+ 1)
      IF ((cki_rec->cki_list[x_cki].match_list[x_match].clean_up_ind=1))
       SET cleanup_primaries->list_sz = (cleanup_primaries->list_sz+ 1)
       SET stat = alterlist(cleanup_primaries->list,cleanup_primaries->list_sz)
       SET cleanup_primaries->list[cleanup_primaries->list_sz].catalog_cd = cki_rec->cki_list[x_cki].
       match_list[x_match].current_catalog_cd
       IF (cnvtupper(cki_rec->cki_list[x_cki].match_list[x_match].primary) != "ZZ*")
        SET cleanup_primaries->list[cleanup_primaries->list_sz].mnemonic = trim(substring(1,100,
          concat("zz",cki_rec->cki_list[x_cki].match_list[x_match].primary)))
       ELSE
        SET cleanup_primaries->list[cleanup_primaries->list_sz].mnemonic = trim(substring(1,100,
          cki_rec->cki_list[x_cki].match_list[x_match].primary))
       ENDIF
       CALL addlogmsg("INFO",build2(trim(cki_rec->cki_list[x_cki].match_list[x_match].primary),
         " will be inactivated, zz, and stripped of its CKI"))
      ELSE
       CALL addlogmsg("WARNING",build2(trim(cki_rec->cki_list[x_cki].match_list[x_match].primary),
         " will not be cleaned up because there are products or synonyms still under it"))
      ENDIF
     ENDFOR
   ENDFOR
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO",build2("Count of primaries that are going to be cleaned up: ",trim(
      cnvtstring(cleanup_primaries->list_sz))))
   CALL addlogmsg("INFO",build2("Count of primaries that need to be cleaned up: ",trim(cnvtstring(
       totalprimcnt))))
   CALL addlogmsg("INFO","**********************************************************")
   IF (debug_ind=1)
    CALL addlogmsg("INFO","CLEANUP_PRIMARIES RECORD AFTER BEING POPULATED")
    CALL echorecord(cleanup_primaries,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE createcsv(null)
   DECLARE outputcnt = i4
   RECORD output_rec(
     1 list[*]
       2 invalid_cki = vc
       2 current_prim = vc
       2 synonym_cki = vc
       2 synonym_type = vc
       2 primary_ind = i2
       2 synonym = vc
       2 synonym_id = f8
       2 item_id = f8
       2 item_desc = vc
       2 new_prim = vc
       2 new_prim_cki = vc
       2 current_cat = f8
       2 new_cat = f8
   ) WITH protect
   FOR (i = 1 TO value(size(cki_rec->cki_list,5)))
     FOR (j = 1 TO value(size(cki_rec->cki_list[i].match_list,5)))
      FOR (k = 1 TO value(size(cki_rec->cki_list[i].match_list[j].synonym_list,5)))
        IF ((cki_rec->cki_list[i].match_list[j].synonym_list[k].new_prim_cki != "MUL.ORD!d*"))
         IF (value(size(cki_rec->cki_list[i].match_list[j].synonym_list[k].syn_new_prim_list,5)) > 0)
          FOR (l = 1 TO value(size(cki_rec->cki_list[i].match_list[j].synonym_list[k].
            syn_new_prim_list,5)))
            SET outputcnt = (outputcnt+ 1)
            IF (mod(outputcnt,10)=1)
             SET stat = alterlist(output_rec->list,(outputcnt+ 9))
            ENDIF
            SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
            SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
            SET output_rec->list[outputcnt].synonym_cki = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic_cki
            SET output_rec->list[outputcnt].synonym_type = uar_get_code_display(cki_rec->cki_list[i].
             match_list[j].synonym_list[k].mnemonic_type_cd)
            SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic
            SET output_rec->list[outputcnt].synonym_id = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].synonym_id
            SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
            current_catalog_cd
            IF ((cki_rec->cki_list[i].match_list[j].synonym_list[k].mnemonic_type_cd=primary_cd))
             SET output_rec->list[outputcnt].primary_ind = 1
             SET output_rec->list[outputcnt].new_prim = "Not moving primary synonym"
            ELSE
             SET output_rec->list[outputcnt].new_prim = cki_rec->cki_list[i].match_list[j].
             synonym_list[k].syn_new_prim_list[l].syn_new_prim
             SET output_rec->list[outputcnt].new_cat = cki_rec->cki_list[i].match_list[j].
             synonym_list[k].syn_new_prim_list[l].syn_new_cat_cd
            ENDIF
          ENDFOR
         ELSE
          SET outputcnt = (outputcnt+ 1)
          IF (mod(outputcnt,10)=1)
           SET stat = alterlist(output_rec->list,(outputcnt+ 9))
          ENDIF
          SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
          SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
          SET output_rec->list[outputcnt].synonym_cki = cki_rec->cki_list[i].match_list[j].
          synonym_list[k].mnemonic_cki
          SET output_rec->list[outputcnt].synonym_type = uar_get_code_display(cki_rec->cki_list[i].
           match_list[j].synonym_list[k].mnemonic_type_cd)
          SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].synonym_list[k
          ].mnemonic
          SET output_rec->list[outputcnt].synonym_id = cki_rec->cki_list[i].match_list[j].
          synonym_list[k].synonym_id
          SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
          current_catalog_cd
          IF ((cki_rec->cki_list[i].match_list[j].synonym_list[k].mnemonic_type_cd=primary_cd))
           SET output_rec->list[outputcnt].primary_ind = 1
           SET output_rec->list[outputcnt].new_prim = "Not moving primary synonym"
          ELSE
           SET output_rec->list[outputcnt].new_prim =
           "Synonym CKI not found in Multum.Cannot move synonym"
          ENDIF
         ENDIF
        ELSE
         FOR (l = 1 TO value(size(cki_rec->cki_list[i].match_list[j].synonym_list[k].
           syn_new_prim_list,5)))
           IF ((cki_rec->cki_list[i].match_list[j].synonym_list[k].syn_new_prim_list[l].
           syn_new_cat_cd=cki_rec->cki_list[i].match_list[j].current_catalog_cd))
            SET outputcnt = (outputcnt+ 1)
            IF (mod(outputcnt,10)=1)
             SET stat = alterlist(output_rec->list,(outputcnt+ 9))
            ENDIF
            SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
            SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
            SET output_rec->list[outputcnt].synonym_cki = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic_cki
            SET output_rec->list[outputcnt].synonym_type = uar_get_code_display(cki_rec->cki_list[i].
             match_list[j].synonym_list[k].mnemonic_type_cd)
            SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic
            SET output_rec->list[outputcnt].synonym_id = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].synonym_id
            SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
            current_catalog_cd
            IF ((cki_rec->cki_list[i].match_list[j].synonym_list[k].mnemonic_type_cd=primary_cd))
             SET output_rec->list[outputcnt].primary_ind = 1
             SET output_rec->list[outputcnt].new_prim = "Not moving primary synonym"
            ELSE
             SET output_rec->list[outputcnt].new_prim =
             "Synonym is under correct primary based on its CKI"
            ENDIF
           ELSE
            SET outputcnt = (outputcnt+ 1)
            IF (mod(outputcnt,10)=1)
             SET stat = alterlist(output_rec->list,(outputcnt+ 9))
            ENDIF
            SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
            SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
            SET output_rec->list[outputcnt].synonym_cki = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic_cki
            SET output_rec->list[outputcnt].synonym_type = uar_get_code_display(cki_rec->cki_list[i].
             match_list[j].synonym_list[k].mnemonic_type_cd)
            SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].mnemonic
            SET output_rec->list[outputcnt].synonym_id = cki_rec->cki_list[i].match_list[j].
            synonym_list[k].synonym_id
            SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
            current_catalog_cd
            SET output_rec->list[outputcnt].new_prim = concat(
             "Synonym is under incorrect primary but the new ",
             "primary is not part of the IV order catalog so it will not move")
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      FOR (k = 1 TO value(size(cki_rec->cki_list[i].match_list[j].item_list,5)))
        IF ((cki_rec->cki_list[i].match_list[j].item_list[k].new_cki != "MUL.ORD!d*"))
         IF (value(size(cki_rec->cki_list[i].match_list[j].item_list[k].item_new_prim_list,5)) > 0)
          FOR (l = 1 TO value(size(cki_rec->cki_list[i].match_list[j].item_list[k].item_new_prim_list,
            5)))
            SET outputcnt = (outputcnt+ 1)
            IF (mod(outputcnt,10)=1)
             SET stat = alterlist(output_rec->list,(outputcnt+ 9))
            ENDIF
            SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
            SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
            SET output_rec->list[outputcnt].synonym_type = "Rx Mnemonic"
            SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].item_list[k]
            .rxmnemonic
            SET output_rec->list[outputcnt].item_id = cki_rec->cki_list[i].match_list[j].item_list[k]
            .item_id
            SET output_rec->list[outputcnt].item_desc = cki_rec->cki_list[i].match_list[j].item_list[
            k].description
            SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
            current_catalog_cd
            SET output_rec->list[outputcnt].new_prim_cki = cki_rec->cki_list[i].match_list[j].
            item_list[k].new_cki
            SET output_rec->list[outputcnt].new_prim = cki_rec->cki_list[i].match_list[j].item_list[k
            ].item_new_prim_list[l].item_new_prim
            SET output_rec->list[outputcnt].new_cat = cki_rec->cki_list[i].match_list[j].item_list[k]
            .item_new_prim_list[l].item_new_cat_cd
          ENDFOR
         ELSE
          SET outputcnt = (outputcnt+ 1)
          IF (mod(outputcnt,10)=1)
           SET stat = alterlist(output_rec->list,(outputcnt+ 9))
          ENDIF
          SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
          SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
          SET output_rec->list[outputcnt].synonym_type = "Rx Mnemonic"
          SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].item_list[k].
          rxmnemonic
          SET output_rec->list[outputcnt].item_id = cki_rec->cki_list[i].match_list[j].item_list[k].
          item_id
          SET output_rec->list[outputcnt].item_desc = cki_rec->cki_list[i].match_list[j].item_list[k]
          .description
          SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
          current_catalog_cd
          SET output_rec->list[outputcnt].new_prim =
          "Item's new primary CKI not found.Cannot move item"
          SET output_rec->list[outputcnt].new_prim_cki = cki_rec->cki_list[i].match_list[j].
          item_list[k].new_cki
         ENDIF
        ELSE
         SET outputcnt = (outputcnt+ 1)
         IF (mod(outputcnt,10)=1)
          SET stat = alterlist(output_rec->list,(outputcnt+ 9))
         ENDIF
         SET output_rec->list[outputcnt].invalid_cki = cki_rec->cki_list[i].cki
         SET output_rec->list[outputcnt].current_prim = cki_rec->cki_list[i].match_list[j].primary
         SET output_rec->list[outputcnt].synonym_type = "Rx Mnemonic"
         SET output_rec->list[outputcnt].synonym = cki_rec->cki_list[i].match_list[j].item_list[k].
         rxmnemonic
         SET output_rec->list[outputcnt].item_id = cki_rec->cki_list[i].match_list[j].item_list[k].
         item_id
         SET output_rec->list[outputcnt].item_desc = cki_rec->cki_list[i].match_list[j].item_list[k].
         description
         SET output_rec->list[outputcnt].current_cat = cki_rec->cki_list[i].match_list[j].
         current_catalog_cd
         SET output_rec->list[outputcnt].new_prim_cki = cki_rec->cki_list[i].match_list[j].item_list[
         k].new_cki
         SET output_rec->list[outputcnt].new_prim =
         "Item's new primary is not part of the IV order catalog. Item will not move"
         SET output_rec->list[outputcnt].new_cat = cki_rec->cki_list[i].match_list[j].item_list[k].
         item_new_prim_list[l].item_new_cat_cd
        ENDIF
      ENDFOR
     ENDFOR
   ENDFOR
   IF (mod(outputcnt,10) != 0)
    SET stat = alterlist(output_rec->list,outputcnt)
   ENDIF
   SELECT INTO value(outputfilename)
    invalid_cki = substring(1,20,output_rec->list[d1.seq].invalid_cki), current_primary = substring(1,
     100,output_rec->list[d1.seq].current_prim), synonym_cki = substring(1,20,output_rec->list[d1.seq
     ].synonym_cki),
    synonym_type = substring(1,20,output_rec->list[d1.seq].synonym_type), synonym = substring(1,100,
     output_rec->list[d1.seq].synonym), item_desc = substring(1,100,output_rec->list[d1.seq].
     item_desc),
    new_primary = substring(1,100,output_rec->list[d1.seq].new_prim), new_primary_cki = substring(1,
     20,output_rec->list[d1.seq].new_prim_cki), new_catalog_cd = output_rec->list[d1.seq].new_cat,
    synonym_id = output_rec->list[d1.seq].synonym_id, item_id = output_rec->list[d1.seq].item_id,
    current_catalog_cd = output_rec->list[d1.seq].current_cat
    FROM (dummyt d1  WITH seq = value(size(output_rec->list,5)))
    PLAN (d1)
    ORDER BY invalid_cki, current_primary, output_rec->list[d1.seq].primary_ind DESC,
     synonym_type, synonym
    WITH format = stream, pcformat('"',",",1), format
   ;end select
   IF (value(size(output_rec->list,5)) > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE promptuserforoutputfile(null)
   CALL text(soffrow,soffcol,"Enter filename to create in CCLUSERDIR (or MINE):")
   CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C",outputfilename)
   IF (((cnvtupper(curaccept)="*.CSV*") OR (cnvtupper(curaccept)="MINE")) )
    SET outputfilename = trim(cnvtlower(curaccept))
    CALL clear((soffrow+ 2),soffcol,numcols)
    IF (createcsv(null))
     IF (outputfilename != "mine")
      CALL text((soffrow+ 2),soffcol,"The file has successfully been created in CCLUSERDIR")
      CALL text((soffrow+ 3),soffcol,"Do you want to email the file?:")
      CALL accept((soffrow+ 3),(soffcol+ 33),"A;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       CALL text((soffrow+ 4),soffcol,"Enter recepient's email address:")
       CALL accept((soffrow+ 5),(soffcol+ 1),"P(74);C",gethnaemail(null))
       IF (emailfile(curaccept,from_str,"","",outputfilename))
        CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
       ELSE
        CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
       ENDIF
       CALL text((soffrow+ 16),soffcol,"Continue?:")
       CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
      ENDIF
     ELSE
      GO TO main_menu
     ENDIF
    ELSE
     CALL text((soffrow+ 2),soffcol,"There were no synonyms or items found that are eligible to move"
      )
     CALL text((soffrow+ 16),soffcol,"Continue?:")
     CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU","Y"
      WHERE curaccept IN ("Y"))
    ENDIF
   ELSE
    CALL text((soffrow+ 2),soffcol,"Output file must be MINE or have .csv extension")
    CALL promptuserforoutputfile(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforlvpswithmmdcs(null)
   DECLARE lvpcnt = i4 WITH protect
   DECLARE maxdisp = i4 WITH protect
   DECLARE dispcki = c16 WITH protect
   DECLARE dispprim = c37 WITH protect
   DECLARE dispcat = c12 WITH protect
   DECLARE dispitems = c10 WITH protect
   SET stat = initrec(lvps)
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic, oc.cki,
    numitems = count(ocir.item_id)
    FROM order_catalog oc,
     order_catalog_item_r ocir
    PLAN (oc
     WHERE oc.activity_type_cd=pharm_act_cd
      AND cnvtupper(oc.primary_mnemonic) IN ("LVP*", "PARENTERAL*")
      AND  NOT (oc.cki IN ("MUL.ORD!d04128", "MUL.ORD!d04129", "MUL.ORD!d04130", "MUL.ORD!d04131",
     "MUL.ORD!d04132"))
      AND oc.cki > " ")
     JOIN (ocir
     WHERE ocir.catalog_cd=outerjoin(oc.catalog_cd))
    GROUP BY oc.catalog_cd, oc.primary_mnemonic, oc.cki
    HEAD REPORT
     lvpcnt = 0
    DETAIL
     lvpcnt = (lvpcnt+ 1), stat = alterlist(lvps->qual,lvpcnt), lvps->qual[lvpcnt].catalog_cd = oc
     .catalog_cd,
     lvps->qual[lvpcnt].cki = oc.cki, lvps->qual[lvpcnt].primary = oc.primary_mnemonic, lvps->qual[
     lvpcnt].num_of_items = numitems
    FOOT REPORT
     lvps->qual_cnt = lvpcnt
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL text(soffrow,soffcol,"Found primaries with incorrect CKI values.")
    CALL text((soffrow+ 1),soffcol,
     "It is recommended you map the correct dnum CKI (d04128-d04132) to the")
    CALL text((soffrow+ 2),soffcol,
     "following primaries or change their descriptions to match their CKIs. If")
    CALL text((soffrow+ 3),soffcol,
     "you do not change their CKIs the synonyms and products underneath these")
    CALL text((soffrow+ 4),soffcol,"primaries will not be remapped.")
    IF ((lvps->qual_cnt > 9))
     SET maxdisp = 9
    ELSE
     SET maxdisp = lvps->qual_cnt
    ENDIF
    FOR (i = 1 TO maxdisp)
      IF (i=1)
       SET dispcki = "CKI"
       SET dispprim = "Primary"
       SET dispcat = "Catalog_CD"
       SET dispitems = "# Products"
       CALL text(((soffrow+ i)+ 5),soffcol,build2(dispcki,dispprim,dispcat,dispitems))
      ENDIF
      SET dispcki = substring(1,16,lvps->qual[i].cki)
      SET dispprim = substring(1,36,lvps->qual[i].primary)
      SET dispcat = substring(1,12,cnvtstring(lvps->qual[i].catalog_cd))
      SET dispitems = trim(cnvtstring(lvps->qual[i].num_of_items))
      CALL text(((soffrow+ i)+ 6),soffcol,build2(dispcki,dispprim,dispcat,dispitems))
    ENDFOR
    CALL text((soffrow+ 16),soffcol,"Do you want to assign the correct CKIs?:")
    CALL accept((soffrow+ 16),(soffcol+ 40),"A;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     CALL clearscreen(null)
     CALL updatelvpckis(null)
    ELSE
     CALL clearscreen(null)
    ENDIF
   ENDIF
   IF (debug_ind=1)
    CALL addlogmsg("INFO","LVPS RECORD AFTER BEING POPULATED")
    CALL echorecord(lvps,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE updatelvpckis(null)
   DECLARE displine = c65 WITH protect
   DECLARE dispcki = c20 WITH protect
   DECLARE dispmnemonic = c45 WITH protect
   DECLARE maxdisp = i4 WITH protect
   CALL clearscreen(null)
   IF ((lvps->qual_cnt > 6))
    SET maxdisp = 6
   ELSE
    SET maxdisp = lvps->qual_cnt
   ENDIF
   CALL text(soffrow,(soffcol+ 20),"Standard Multum CKIs and Description")
   CALL line((soffrow+ 1),(soffcol+ 9),(numcols - 20))
   FOR (i = 1 TO dnumcnt)
     SET dispcki = substring(1,20,cki_rec->cki_list[i].cki)
     SET dispmnemonic = substring(1,45,cki_rec->cki_list[i].standard_display)
     SET displine = concat(dispcki,dispmnemonic)
     CALL text(((soffrow+ 1)+ i),(soffcol+ 9),displine)
   ENDFOR
   CALL text(((soffrow+ dnumcnt)+ 3),soffcol,"Primary in order catalog: ")
   FOR (i = 1 TO value(maxdisp))
     SET dispmnemonic = substring(1,45,lvps->qual[i].primary)
     CALL text((((soffrow+ dnumcnt)+ 3)+ i),soffcol,dispmnemonic)
     CALL text((soffrow+ 16),soffcol,"Assign CKI: MUL.ORD!d041")
     CALL accept((soffrow+ 16),(soffcol+ 24),"99;"
      WHERE curaccept IN (28, 29, 30, 31, 32))
     SET lvps->qual[i].new_cki = trim(concat("MUL.ORD!d041",trim(cnvtstring(curaccept))))
     CALL text((((soffrow+ dnumcnt)+ 3)+ i),(soffcol+ 60),trim(lvps->qual[i].new_cki))
   ENDFOR
   CALL clear((soffrow+ 16),soffcol,30)
   CALL text((soffrow+ 16),soffcol,"Correct?:")
   CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SELECT INTO "nl:"
     oc.catalog_cd
     FROM order_catalog oc
     PLAN (oc
      WHERE expand(i,1,lvps->qual_cnt,oc.catalog_cd,lvps->qual[i].catalog_cd))
     WITH nocounter, forupdate(oc)
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE expand(i,1,lvps->qual_cnt,cv.code_value,lvps->qual[i].catalog_cd)
       AND cv.code_set=200)
     WITH nocounter, forupdate(cv)
    ;end select
    UPDATE  FROM (dummyt d1  WITH seq = value(lvps->qual_cnt)),
      order_catalog oc
     SET oc.cki = trim(lvps->qual[d1.seq].new_cki), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = 0, oc.updt_task = - (267)
     PLAN (d1
      WHERE (lvps->qual[d1.seq].new_cki > " "))
      JOIN (oc
      WHERE (oc.catalog_cd=lvps->qual[d1.seq].catalog_cd))
     WITH nocounter
    ;end update
    IF (curqual != value(maxdisp))
     CALL clear((soffrow+ 14),soffcol,numcols)
     CALL text((soffrow+ 14),soffcol,"ERROR UPDATING ORDER_CATALOG ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," maxDisp size = ",trim(cnvtstring
       (maxdisp)))
     ROLLBACK
     GO TO exit_script
    ENDIF
    UPDATE  FROM (dummyt d1  WITH seq = value(lvps->qual_cnt)),
      code_value cv
     SET cv.cki = trim(lvps->qual[d1.seq].new_cki), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0, cv.updt_task = - (267)
     PLAN (d1
      WHERE (lvps->qual[d1.seq].new_cki > " "))
      JOIN (cv
      WHERE (cv.code_value=lvps->qual[d1.seq].catalog_cd)
       AND cv.code_set=200)
     WITH nocounter
    ;end update
    IF (curqual=value(maxdisp))
     COMMIT
    ELSE
     CALL clear((soffrow+ 14),soffcol,numcols)
     CALL text((soffrow+ 14),soffcol,"ERROR UPDATING CODE_VALUE ROLLING BACK CHANGES")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," maxDisp size = ",trim(cnvtstring
       (maxdisp)))
     GO TO exit_script
    ENDIF
   ELSE
    CALL updatelvpckis(null)
   ENDIF
   CALL clearscreen(null)
 END ;Subroutine
 SUBROUTINE removeinvalidsynonymproductlinks(null)
   CALL addlogmsg("INFO","**********************************************************")
   CALL addlogmsg("INFO","Finding any product synonym links that are no longer valid ")
   CALL addlogmsg("INFO","**********************************************************")
   DECLARE linkscnt = i4 WITH protect
   RECORD links(
     1 list[*]
       2 synonym_id = f8
       2 item_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    sir.item_id, sir.synonym_id
    FROM synonym_item_r sir,
     order_catalog_synonym ocs,
     order_catalog_item_r ocir,
     order_catalog_synonym ocs2
    PLAN (sir
     WHERE ((expand(i,1,size(updt_items->list,5),sir.item_id,updt_items->list[i].item_id)) OR (expand
     (i,1,size(updt_syns->list,5),sir.synonym_id,updt_syns->list[i].synonym_id))) )
     JOIN (ocs
     WHERE ocs.synonym_id=sir.synonym_id)
     JOIN (ocir
     WHERE ocir.item_id=sir.item_id
      AND ocir.catalog_cd != ocs.catalog_cd)
     JOIN (ocs2
     WHERE ocs2.item_id=sir.item_id)
    HEAD REPORT
     linkscnt = 0
    DETAIL
     linkscnt = (linkscnt+ 1)
     IF (mod(linkscnt,10)=1)
      stat = alterlist(links->list,(linkscnt+ 9))
     ENDIF
     links->list[linkscnt].item_id = sir.item_id, links->list[linkscnt].synonym_id = sir.synonym_id,
     CALL addlogmsg("INFO",build2("Removing linking between synonym: ",trim(ocs.mnemonic),
      " and item: ",trim(ocs2.mnemonic)))
    FOOT REPORT
     CALL addlogmsg("INFO",build2("Total product synonym links removed: ",trim(cnvtstring(linkscnt)))
     )
     IF (mod(linkscnt,10) != 0)
      stat = alterlist(links->list,linkscnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","LINKS RECORD AFTER BEING POPULATED")
    CALL echorecord(links,logfilename,1)
   ENDIF
   IF (curqual > 0)
    DELETE  FROM synonym_item_r sir,
      (dummyt d1  WITH seq = value(size(links->list,5)))
     SET sir.seq = 1
     PLAN (d1)
      JOIN (sir
      WHERE (sir.item_id=links->list[d1.seq].item_id)
       AND (sir.synonym_id=links->list[d1.seq].synonym_id))
     WITH nocounter
    ;end delete
    IF (curqual=value(size(links->list,5)))
     CALL addlogmsg("INFO",build2("Successfully deleted ",trim(cnvtstring(linkscnt)),
       " rows on synonym_item_r"))
    ELSE
     CALL addlogmsg("ERROR","ERROR DELETING PRODUCT SYNONYM LINKS")
     CALL addlogmsg("ERROR","ERROR UPDATING ORDER_CATALOG_ITEM_R")
     CALL addlogmsg("ERROR","ROLLING BACK CHANGES")
     CALL addlogmsg("ERROR",build2("Count of rows that are supposed to be deleted: ",trim(cnvtstring(
         linkscnt))))
     CALL addlogmsg("ERROR",build2("Count of rows that were deleted: ",trim(cnvtstring(curqual))))
     FOR (i = 1 TO value(size(links->list,5)))
       CALL addlogmsg("ERROR",build2("Deleting item_id: ",trim(cnvtstring(links->list[i].item_id),
          " synonym_id: ",trim(cnvtstring(links->list[i].synonym_id)))))
     ENDFOR
     CALL addlogmsg("RESOLUTION","Check synonym_item_r for missing or duplicated rows ",
      "using the above item_ids and synonym_ids")
     SET status = "F"
     SET statusstr = build2("curqual = ",trim(cnvtstring(curqual))," linksCnt = ",trim(cnvtstring(
        linkscnt)))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (mode=update_mode)
  IF (status="F")
   CALL addlogmsg("ERROR","Script failed. Rolling back changes")
   CALL text((soffrow+ 14),soffcol,statusstr)
   ROLLBACK
   CALL text((soffrow+ 16),soffcol,"Continue?:")
   CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU","Y"
    WHERE curaccept IN ("Y"))
  ELSEIF (status="Z")
   CALL addlogmsg("WARNING","Script ran successfully but found no invalid CKIs")
   CALL text((soffrow+ 14),soffcol,statusstr)
   ROLLBACK
   CALL text((soffrow+ 16),soffcol,"Continue?:")
   CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU","Y"
    WHERE curaccept IN ("Y"))
  ELSEIF (status="S")
   CALL addlogmsg("INFO","Script completed successfully")
   CALL text((soffrow+ 14),soffcol,statusstr)
   CALL text((soffrow+ 16),soffcol,"Commit?:")
   CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
    CALL addlogmsg("INFO","Changes committed")
   ELSE
    ROLLBACK
    CALL addlogmsg("INFO","Changes rolled back")
   ENDIF
  ENDIF
  CALL createlogfile(logfilename)
  CALL text((soffrow+ 10),soffcol,build2("Log file: ",logfilename," is in CCLUSERDIR"))
  CALL text((soffrow+ 11),soffcol,"Do you want to email the file?:")
  CALL accept((soffrow+ 11),(soffcol+ 32),"A;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="Y")
   CALL text((soffrow+ 12),soffcol,"Enter recepient's email address:")
   CALL accept((soffrow+ 13),(soffcol+ 1),"P(74);C",gethnaemail(null))
   IF (emailfile(curaccept,from_str,"","",logfilename))
    CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
   ELSE
    CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
   ENDIF
   CALL text((soffrow+ 16),soffcol,"Continue?:")
   CALL accept((soffrow+ 16),(soffcol+ 10),"A;CU","Y"
    WHERE curaccept IN ("Y"))
  ENDIF
  GO TO main_menu
 ENDIF
 CALL clear(1,1)
 SET message = nowindow
 SET last_mod = "003"
END GO
