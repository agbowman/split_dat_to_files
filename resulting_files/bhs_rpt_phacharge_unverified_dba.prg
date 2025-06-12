CREATE PROGRAM bhs_rpt_phacharge_unverified:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ms_temp = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SELECT INTO value( $OUTDEV)
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
   HEAD REPORT
    ms_temp = concat("FIN,","Last_Name,","First_Name,","order_date,","order_as,",
     "order_detail_info"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build2('"',ea.alias,'",','"',p.name_last_key,
     '",','"',p.name_first_key,'",','"',
     o.orig_order_dt_tm,'",','"',o.ordered_as_mnemonic,'",',
     '"',o.order_detail_display_line,'"'), col 0,
    ms_temp
   WITH nocounter, format = variable, maxrow = 1,
    maxcol = 5000, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   fin = ea.alias, last_name = p.name_last_key, first_name = p.name_first_key,
   order_date = o.orig_order_dt_tm, order_as = o.ordered_as_mnemonic, order_detail_info = o
   .order_detail_display_line
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
 ENDIF
END GO
