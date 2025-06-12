CREATE PROGRAM av_flag_audit:dba
 PAINT
 CALL video(n)
 CALL text(3,3,"Spreadsheet AV_FLAG_AUDIT.CSV being created in CCLUSERDIR")
 DECLARE coutfile = vc WITH constant("ccluserdir:AV_FLAG_AUDIT.CSV")
 SET cpharm = 0.0
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,cpharm)
 SET crx = 0.0
 SET stat = uar_get_meaning_by_codeset(6011,"RXMNEMONIC",1,crx)
 EXECUTE cclseclogin
 SELECT INTO value(trim(coutfile))
  catalog_cd = oc.catalog_cd, primary_mnemonic = substring(1,60,oc.primary_mnemonic), mltm_oc_flag =
  oc.ic_auto_verify_flag,
  discern_oc_flag = oc.discern_auto_verify_flag, synonym_id = ocs.synonym_id, synonym = trim(
   substring(1,60,ocs.mnemonic)),
  synonym_type = trim(substring(1,40,uar_get_code_display(ocs.mnemonic_type_cd))), os
  .order_sentence_id, display = replace(os.order_sentence_display_line,",","",0),
  mltm_os_flag = os.ic_auto_verify_flag, discern_os_flag = os.discern_auto_verify_flag
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_sentence os,
   ord_cat_sent_r ocsr,
   dummyt d,
   dummyt d1
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND  NOT (ocs.mnemonic_type_cd=crx))
   JOIN (d)
   JOIN (ocsr
   WHERE ocs.synonym_id=ocsr.synonym_id)
   JOIN (d1)
   JOIN (os
   WHERE ocsr.order_sentence_id=os.order_sentence_id
    AND os.order_sentence_id > 0)
  ORDER BY oc.primary_mnemonic, synonym_type
  HEAD REPORT
   col 0, '"AUTOVERIFICATION FLAG AUDIT"', row + 1,
   "Check flag legend: 1=no    2= no w/ clinical checking    3= yes w/ reason     4= yes", row + 1,
   col 0,
   "Catalog_cd,", "Primary_mnemonic,", "Multum check,",
   "Discern check,", "Synonym_id,", "Synonym,",
   "Synonym type,", "Order Sentence id,", "Multum check,",
   "Discern check,", "Order sentence display,", row + 1
  HEAD catalog_cd
   row + 0, col 0, catalog_cd,
   ",", col 20, primary_mnemonic,
   ",", col 90, mltm_oc_flag,
   ",", col 100, discern_oc_flag,
   ",", row + 1
  HEAD synonym_id
   col 0, ",,,,", col 125,
   ocs.synonym_id, ",", col 142,
   synonym, ",", col 205,
   synonym_type, row + 1
  DETAIL
   row + 0
   IF (os.order_sentence_id > 0)
    col 0, ",,,,,,,", col 10,
    os.order_sentence_id, ",", col 45,
    display, ",", col 25,
    mltm_os_flag, ",", col 35,
    discern_os_flag, ",", row + 1
   ENDIF
  WITH nocounter, outerjoin = d, outerjoin = d1,
   maxcol = 1000
 ;end select
END GO
