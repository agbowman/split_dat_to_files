CREATE PROGRAM bhs_rad_audit_oc_inact:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  oc.primary_mnemonic, oc.catalog_cd, oc.active_ind
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=2517
   AND oc.active_ind=0
  ORDER BY oc.primary_mnemonic
  WITH nocounter, format, separator = " "
 ;end select
END GO
