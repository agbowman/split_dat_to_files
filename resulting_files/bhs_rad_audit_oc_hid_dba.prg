CREATE PROGRAM bhs_rad_audit_oc_hid:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  ocs.mnemonic, ocs.hide_flag, ocs.catalog_cd
  FROM order_catalog_synonym ocs
  WHERE ocs.catalog_type_cd=2517
   AND ocs.hide_flag=1
  ORDER BY ocs.mnemonic
  WITH nocounter, format, separator = " "
 ;end select
END GO
