CREATE PROGRAM bhs_rad_audit_orders_in_cset:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  oc.primary_mnemonic, ocs.mnemonic, cs.comp_seq
  FROM order_catalog_synonym ocs,
   cs_component cs,
   order_catalog oc,
   long_text lt
  PLAN (ocs
   WHERE ocs.catalog_type_cd=2517)
   JOIN (cs
   WHERE ocs.synonym_id=cs.comp_id)
   JOIN (oc
   WHERE cs.catalog_cd=oc.catalog_cd)
   JOIN (lt
   WHERE oc.ord_com_template_long_text_id=lt.long_text_id)
  ORDER BY oc.primary_mnemonic, cs.comp_seq
  WITH nocounter, separator = " ", format
 ;end select
END GO
