CREATE PROGRAM bhs_wing_virtual_views:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  ofr_facility_disp = uar_get_code_display(ofr.facility_cd), oc.primary_mnemonic, oc
  .orderable_type_flag,
  oc.cki, o.mnemonic, o_mnemonic_type_disp = uar_get_code_display(o.mnemonic_type_cd),
  o.synonym_id, o.cki, ofr.facility_cd,
  o.mnemonic_type_cd, oc.catalog_cd, o.active_ind
  FROM order_catalog oc,
   order_catalog_synonym o,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.catalog_type_cd=2516.00
    AND oc.active_ind=1)
   JOIN (o
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (ofr
   WHERE o.synonym_id=ofr.synonym_id
    AND ofr.facility_cd IN (580062482, 580061823))
  ORDER BY oc.primary_mnemonic, o_mnemonic_type_disp, o.mnemonic
  WITH maxrec = 7500, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
