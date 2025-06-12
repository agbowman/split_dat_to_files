CREATE PROGRAM bhs_rad_ordaudit_chgrpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_rad_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"RADIOLOGY"))
 SELECT DISTINCT INTO  $OUTDEV
  ord_cat_desc = oc.description, oc.catalog_cd, ocs.mnemonic,
  synonym_code = uar_get_code_display(ocs.mnemonic_type_cd), clinical_description = bi
  .ext_description, cdm = bim.key6,
  charge_description = bim.key7
  FROM bill_item bi,
   bill_item_modifier bim,
   order_catalog oc,
   order_catalog_synonym ocs
  PLAN (bim
   WHERE bim.key6 != " "
    AND  NOT (bim.key6="-*"))
   JOIN (bi
   WHERE bi.bill_item_id=bim.bill_item_id
    AND bi.ext_owner_cd=mf_rad_cd
    AND bi.ext_parent_reference_id > 0.00)
   JOIN (oc
   WHERE oc.catalog_cd=bi.ext_parent_reference_id)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd)
  ORDER BY bim.key6, ord_cat_desc DESC
  WITH nocounter, separator = " ", format
 ;end select
END GO
