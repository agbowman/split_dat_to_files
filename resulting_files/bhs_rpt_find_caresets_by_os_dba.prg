CREATE PROGRAM bhs_rpt_find_caresets_by_os:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Catalog Type" = 0,
  "Order Sentence Search String" = ""
  WITH outdev, f_cat_type_cd, s_search
 DECLARE mf_cat_typ_cd = f8 WITH protect, constant(cnvtreal( $F_CAT_TYPE_CD))
 DECLARE ms_search = vc WITH protect, constant(build2('"*',cnvtlower(trim( $S_SEARCH,3)),'*"'))
 SELECT DISTINCT INTO value( $OUTDEV)
  careset = oc.primary_mnemonic, order_name = ocs.mnemonic, oe.oe_format_name,
  catalogtype = uar_get_code_display(ocs.catalog_type_cd), os.order_sentence_display_line
  FROM order_catalog oc,
   cs_component cc,
   order_catalog_synonym ocs,
   order_sentence os,
   order_entry_format oe
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.orderable_type_flag=6)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd
    AND cc.comp_id > 0)
   JOIN (ocs
   WHERE ocs.synonym_id=cc.comp_id
    AND ocs.catalog_type_cd=mf_cat_typ_cd)
   JOIN (os
   WHERE os.order_sentence_id=cc.order_sentence_id
    AND cnvtlower(os.order_sentence_display_line)=parser(ms_search))
   JOIN (oe
   WHERE oe.oe_format_id=ocs.oe_format_id)
  ORDER BY careset
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
END GO
