CREATE PROGRAM 01_njd_jan_orders:dba
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
  o.order_mnemonic, o_order_status_disp = uar_get_code_display(o.order_status_cd), o.orig_order_dt_tm
  FROM orders o
  WHERE o.order_mnemonic="CBC"
   AND o.orig_order_dt_tm BETWEEN cnvtdatetime(cnvtdate(020117),0) AND cnvtdatetime(cnvtdate(022817),
   0)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
