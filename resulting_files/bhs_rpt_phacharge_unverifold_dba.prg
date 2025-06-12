CREATE PROGRAM bhs_rpt_phacharge_unverifold:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  fin = ea.alias, last_name = p.name_last_key, first_name = p.name_first_key,
  order_date = o.orig_order_dt_tm, order_as = o.ordered_as_mnemonic, order_detail_info = o
  .order_detail_display_line,
  admin_date = rx.admin_dt_tm
  FROM rx_pending_charge rx,
   orders o,
   encntr_alias ea,
   person p
  PLAN (rx)
   JOIN (o
   WHERE rx.order_id=o.order_id
    AND ((o.active_ind+ 0)=1)
    AND ((o.need_rx_verify_ind+ 0)=1))
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (ea
   WHERE o.encntr_id=ea.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY p.name_last_key
  WITH maxrec = 8000, time = 20, nocounter,
   separator = " ", format
 ;end select
END GO
