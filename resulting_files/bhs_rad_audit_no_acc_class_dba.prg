CREATE PROGRAM bhs_rad_audit_no_acc_class:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE"
  WITH prompt1
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET rad_var = 0.0
 SET stat = uar_get_meaning_by_codeset(106,"RADIOLOGY",1,rad_var)
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $1
  o.catalog_cd, o_catalog_disp = uar_get_code_display(o.catalog_cd)
  FROM order_catalog o,
   procedure_specimen_type p,
   dummyt d1
  PLAN (o
   WHERE o.activity_type_cd=rad_var
    AND o.active_ind=1)
   JOIN (d1)
   JOIN (p
   WHERE o.catalog_cd=p.catalog_cd)
  ORDER BY o.primary_mnemonic
  WITH format, time = value(maxsecs), outerjoin = d1,
   dontexist
 ;end select
END GO
