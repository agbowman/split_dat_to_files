CREATE PROGRAM dept_display_audit
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  o.primary_mnemonic, o.dept_display_name, o_catalog_type_disp = uar_get_code_display(o
   .catalog_type_cd)
  FROM order_catalog o
  PLAN (o
   WHERE o.catalog_type_cd != 2516
    AND o.active_ind=1
    AND o.primary_mnemonic != o.dept_display_name
    AND o.dept_display_name > "  ")
  ORDER BY o_catalog_type_disp
  DETAIL
   primary_mnemonic1 = substring(1,40,o.primary_mnemonic), dept_display_name1 = substring(1,50,o
    .dept_display_name), col 2,
   primary_mnemonic1, col 57, dept_display_name1,
   row + 1
  WITH maxrec = 20000, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
