CREATE PROGRAM bhs_careset_ord_sent_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Mnemonic (wildcard * accepted):" = ""
  WITH outdev, mnemonic
 SELECT DISTINCT INTO  $OUTDEV
  careset = uar_get_code_display(cs.catalog_cd), ocs.mnemonic, os.order_sentence_display_line
  FROM order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   cs_component cs,
   order_sentence os,
   dummyt d
  PLAN (ocs
   WHERE cnvtupper(ocs.mnemonic) IN (value(cnvtupper( $MNEMONIC)))
    AND ocs.active_ind=1)
   JOIN (cs
   WHERE cs.comp_id=ocs.synonym_id)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=cs.catalog_cd
    AND ocs2.active_ind=1)
   JOIN (d)
   JOIN (os
   WHERE os.order_sentence_id=cs.order_sentence_id
    AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND os.parent_entity_id=ocs.synonym_id
    AND ((os.parent_entity2_name="ORDER_CATALOG"
    AND os.parent_entity2_id=cs.catalog_cd) OR (os.parent_entity2_name="ORDER_CATALOG"
    AND os.parent_entity2_id=ocs.catalog_cd)) )
  ORDER BY careset, ocs.mnemonic, os.order_sentence_display_line
  WITH format, outerjoin = d
 ;end select
END GO
