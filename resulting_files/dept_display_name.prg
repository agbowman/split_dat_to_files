CREATE PROGRAM dept_display_name
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.dept_display_name, o.active_ind,
  o.primary_mnemonic
  FROM order_catalog o
  PLAN (o
   WHERE o.catalog_type_cd != 2516
    AND o.active_ind=1
    AND o.dept_display_name != o.primary_mnemonic
    AND o.dept_display_name > " ")
  ORDER BY o_catalog_type_disp
  WITH time = value(maxsecs), format, skipreport = 1
 ;end select
END GO
