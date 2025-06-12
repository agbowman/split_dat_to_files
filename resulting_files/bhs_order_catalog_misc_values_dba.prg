CREATE PROGRAM bhs_order_catalog_misc_values:dba
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
  o.primary_mnemonic, o_dcp_clin_cat_disp = uar_get_code_display(o.dcp_clin_cat_cd), o
  .dcp_clin_cat_cd,
  o.dc_display_days, o.dc_interaction_days, o.discern_auto_verify_flag,
  o.ic_auto_verify_flag, o.stop_duration, o_stop_duration_unit_disp = uar_get_code_display(o
   .stop_duration_unit_cd),
  o.stop_duration_unit_cd, o_stop_type_disp = uar_get_code_display(o.stop_type_cd), o.stop_type_cd,
  o.cki
  FROM order_catalog o
  WHERE o.cki IN ("MUL.ORD!d08114", "MUL.MMDC!9263", "MUL.ORD!d00929", "MUL.ORD!d07705",
  "MUL.ORD!d03180",
  "MUL.ORD!d04220", "MUL.ORD!d07705", "MUL.ORD!d00389", "MUL.ORD!d00391", "MUL.ORD!d07740",
  "MUL.ORD!d08125", "MUL.ORD!d03181", "MUL.ORD!d07640", "MUL.ORD!d07640", "MUL.ORD!d00293",
  "MUL.ORD!d01406", "MUL.ORD!d06297", "MUL.ORD!d06297", "MUL.ORD!d06297", "MUL.ORD!d06297",
  "MUL.ORD!d00215", "MUL.ORD!d04523", "MUL.ORD!d00181", "MUL.ORD!d00181", "MUL.ORD!d03808",
  "MUL.ORD!d03804", "MUL.ORD!d08114", "MUL.ORD!d04825", "MUL.ORD!d04825", "MUL.ORD!d00699",
  "MUL.ORD!d04772", "MUL.ORD!d00027", "MUL.ORD!d04240", "MUL.ORD!d04240", "MUL.ORD!d05357")
  ORDER BY o.primary_mnemonic
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
