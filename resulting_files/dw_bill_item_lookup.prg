CREATE PROGRAM dw_bill_item_lookup
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
  oc.active_ind, oc_activity_type_disp = uar_get_code_display(oc.activity_type_cd), oc
  .primary_mnemonic,
  p.name_full_formatted
  FROM orders o,
   order_catalog oc,
   person p
  PLAN (o
   WHERE o.order_id IN (4786121, 4786124, 4744571, 4744574, 4757735,
   4757738, 4781507, 4764473, 4764476, 4788225,
   4788228, 4761596, 4761599))
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
   JOIN (p
   WHERE o.person_id=p.person_id)
  ORDER BY p.name_full_formatted, oc.primary_mnemonic
  WITH maxrec = 100000, format, time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
