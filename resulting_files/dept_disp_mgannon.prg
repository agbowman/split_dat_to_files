CREATE PROGRAM dept_disp_mgannon
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 30
 ENDIF
 SELECT INTO  $OUTDEV
  o.dept_display_name, o.primary_mnemonic, o_catalog_type_disp = uar_get_code_display(o
   .catalog_type_cd)
  FROM order_catalog o
  PLAN (o
   WHERE o.catalog_type_cd=2513
    AND o.primary_mnemonic != o.dept_display_name
    AND o.dept_display_name > " ")
  ORDER BY o_catalog_type_disp
  WITH time = value(maxsecs), format, skipreport = 1
 ;end select
END GO
