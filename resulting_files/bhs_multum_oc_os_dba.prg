CREATE PROGRAM bhs_multum_oc_os:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
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
   ord_cat_sent_r ocsr
  PLAN (oc
   WHERE oc.catalog_type_cd=2516
    AND oc.orderable_type_flag IN (0, 1))
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND  NOT (ocs.mnemonic_type_cd=2584))
   JOIN (ocsr
   WHERE ocsr.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(ocsr.order_sentence_id)
    AND os.order_sentence_id > outerjoin(0))
  ORDER BY oc.primary_mnemonic, synonym_type
  WITH nocounter, format, variable
 ;end select
END GO
