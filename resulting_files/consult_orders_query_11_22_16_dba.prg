CREATE PROGRAM consult_orders_query_11_22_16:dba
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
  SET maxsecs = 120
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.primary_mnemonic,
  ord_order_status_disp = uar_get_code_display(ord.order_status_cd),
  ord.orig_order_dt_tm, e.active_ind, e.encntr_id,
  e_encntr_status_disp = uar_get_code_display(e.encntr_status_cd), p.name_full_formatted
  FROM order_catalog o,
   orders ord,
   encounter e,
   person p
  PLAN (o
   WHERE o.catalog_type_cd=636063
    AND o.active_ind=1)
   JOIN (ord
   WHERE ord.catalog_type_cd=o.catalog_type_cd
    AND ord.order_status_cd IN (2543, 2550))
   JOIN (e
   WHERE e.encntr_id=ord.encntr_id
    AND e.encntr_status_cd=854)
   JOIN (p
   WHERE p.person_id=e.person_id)
  WITH maxrec = 10000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
