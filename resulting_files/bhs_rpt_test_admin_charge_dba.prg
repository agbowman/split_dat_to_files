CREATE PROGRAM bhs_rpt_test_admin_charge:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "ms_beg_dt_tm" = "SYSDATE",
  "ms_end_dt_tm" = "SYSDATE"
  WITH outdev, ms_beg_dt_tm, ms_end_dt_tm
 SELECT INTO  $OUTDEV
  o.order_id, name = trim(p.name_full_formatted), o.encntr_id,
  o.person_id, trim(ea.alias), trim(ea2.alias),
  o.order_mnemonic, dh1.dispense_dt_tm, uar_get_code_display(dh1.disp_event_type_cd),
  dh1.doses, action_type = uar_get_code_display(oa.action_type_cd), op.dose_quantity,
  cdm = mi.value, o.order_detail_display_line
  FROM dispense_hx dh1,
   order_action oa,
   orders o,
   order_product op,
   med_identifier mi,
   med_identifier mi2,
   person p,
   encntr_alias ea,
   encntr_alias ea2
  PLAN (dh1
   WHERE dh1.dispense_dt_tm BETWEEN cnvtdatetime( $MS_BEG_DT_TM) AND cnvtdatetime( $MS_END_DT_TM)
    AND  NOT ( EXISTS (
   (SELECT
    pdh.dispense_hx_id
    FROM prod_dispense_hx pdh
    WHERE dh1.dispense_hx_id=pdh.dispense_hx_id)))
    AND dh1.disp_event_type_cd=643458
    AND dh1.charge_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    rpc.order_id
    FROM rx_pending_charge rpc
    WHERE dh1.order_id=rpc.order_id))))
   JOIN (oa
   WHERE oa.order_id=dh1.order_id
    AND oa.action_type_cd=2536
    AND oa.action_sequence=dh1.action_sequence)
   JOIN (o
   WHERE o.order_id=dh1.order_id
    AND o.active_ind=1)
   JOIN (op
   WHERE op.order_id=o.order_id
    AND op.action_sequence IN (
   (SELECT
    max(oa1.action_sequence)
    FROM order_action oa1,
     order_ingredient oi1,
     order_product op1
    WHERE oa1.order_id=o.order_id
     AND oa1.action_dt_tm <= dh1.dispense_dt_tm
     AND oi1.order_id=o.order_id
     AND oi1.action_sequence=oa1.action_sequence
     AND op1.order_id=o.order_id
     AND op1.action_sequence=oa1.action_sequence
     AND op1.ingred_sequence=oi1.comp_sequence)))
   JOIN (mi
   WHERE mi.item_id=op.item_id
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=3106.00)
   JOIN (mi2
   WHERE mi2.item_id=op.item_id
    AND mi2.primary_ind=1
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=3098.00)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=1079
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ea2
   WHERE ea2.encntr_id=o.encntr_id
    AND ea2.encntr_alias_type_cd=1077
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate)
  WITH format, separator = " "
 ;end select
END GO
