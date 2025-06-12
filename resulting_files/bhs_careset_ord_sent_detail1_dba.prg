CREATE PROGRAM bhs_careset_ord_sent_detail1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Mnemonic (wildcard * accepted):" = ""
  WITH outdev, mnemonic
 SELECT DISTINCT INTO  $OUTDEV
  careset = uar_get_code_display(cs.catalog_cd), os.order_sentence_display_line, ocs.mnemonic
  FROM order_catalog_synonym ocs,
   cs_component cs,
   order_sentence os,
   dummyt d
  PLAN (ocs
   WHERE cnvtupper(ocs.mnemonic) IN (value(cnvtupper( $MNEMONIC))))
   JOIN (cs
   WHERE cs.comp_id=ocs.synonym_id)
   JOIN (d)
   JOIN (os
   WHERE os.oe_format_id=ocs.oe_format_id
    AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND os.parent_entity_id=ocs.synonym_id
    AND os.parent_entity2_name="ORDER_CATALOG"
    AND os.parent_entity2_id=cs.catalog_cd)
  ORDER BY careset, ocs.mnemonic, os.order_sentence_display_line
  WITH format, outerjoin = d
 ;end select
END GO
