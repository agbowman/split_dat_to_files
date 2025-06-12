CREATE PROGRAM 01_njd_single_ord:dba
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
  p.name_full_formatted, p.person_id, o.order_mnemonic,
  o_order_status_disp = uar_get_code_display(o.order_status_cd), o.orig_order_dt_tm, o.person_id
  FROM orders o,
   person p
  PLAN (p)
   JOIN (o
   WHERE p.person_id=o.person_id
    AND o.order_mnemonic="CBC"
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(cnvtdate(040616),0) AND cnvtdatetime(cnvtdate(040616),
    235959))
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
