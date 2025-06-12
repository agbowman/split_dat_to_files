CREATE PROGRAM bhs_charge_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 s_name = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_encntr_type = vc
     2 s_facility = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_primary_ins = vc
     2 s_secondary_ins = vc
     2 f_bill_item_id = f8
     2 f_bill_item_mod_id = f8
     2 s_key6 = vc
     2 s_key7 = vc
     2 f_dispense_hx_id = f8
     2 f_order_id = f8
     2 s_order_disp_line = vc
     2 s_order_mnemonic = vc
     2 s_order_dt_tm = vc
     2 s_action_type = vc
     2 s_disp_dt_tm = vc
     2 s_cdm = vc
     2 f_doses = f8
     2 s_dose_quantity = vc
     2 s_disp_event = vc
 )
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT)," 23:59:59"))
 SELECT INTO "nl:"
  FROM dispense_hx dh1,
   order_action oa,
   orders o,
   order_product op,
   med_identifier mi,
   med_identifier mi2,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   encounter e
  PLAN (dh1
   WHERE dh1.dispense_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
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
    AND mi.med_identifier_type_cd=3106)
   JOIN (mi2
   WHERE mi2.item_id=op.item_id
    AND mi2.primary_ind=1
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=3098)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
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
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->list,5))
    stat = alterlist(m_rec->list,(pl_cnt+ 20))
   ENDIF
   m_rec->list[pl_cnt].s_name = trim(p.name_full_formatted), m_rec->list[pl_cnt].f_encntr_id = o
   .encntr_id, m_rec->list[pl_cnt].f_person_id = o.person_id,
   m_rec->list[pl_cnt].s_mrn = trim(ea.alias), m_rec->list[pl_cnt].s_fin = trim(ea2.alias), m_rec->
   list[pl_cnt].f_dispense_hx_id = dh1.dispense_hx_id,
   m_rec->list[pl_cnt].f_order_id = o.order_id, m_rec->list[pl_cnt].s_order_disp_line = trim(o
    .order_detail_display_line), m_rec->list[pl_cnt].s_order_mnemonic = trim(o.order_mnemonic),
   m_rec->list[pl_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec
   ->list[pl_cnt].s_disp_dt_tm = trim(format(dh1.dispense_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec->
   list[pl_cnt].s_disp_event = uar_get_code_display(dh1.disp_event_type_cd),
   m_rec->list[pl_cnt].s_action_type = uar_get_code_display(oa.action_type_cd), m_rec->list[pl_cnt].
   s_cdm = trim(mi.value), m_rec->list[pl_cnt].f_doses = dh1.doses,
   m_rec->list[pl_cnt].s_dose_quantity = trim(cnvtstring(op.dose_quantity)), m_rec->list[pl_cnt].
   s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)), m_rec->list[pl_cnt].s_facility =
   trim(uar_get_code_display(e.loc_facility_cd))
  FOOT REPORT
   stat = alterlist(m_rec->list,pl_cnt)
  WITH nocounter, format, separator = " "
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->list,5))),
   encounter e,
   encntr_plan_reltn epr,
   person pe,
   person_alias pa,
   health_plan h,
   organization org
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=m_rec->list[d.seq].f_encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (pe
   WHERE pe.person_id=epr.person_id)
   JOIN (pa
   WHERE pa.person_id=epr.person_id
    AND pa.active_ind=1)
   JOIN (h
   WHERE h.health_plan_id=epr.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE org.organization_id=outerjoin(e.organization_id))
  ORDER BY epr.encntr_plan_reltn_id
  DETAIL
   IF (epr.priority_seq=1)
    m_rec->list[d.seq].s_primary_ins = trim(h.plan_name)
   ELSEIF (epr.priority_seq=2)
    m_rec->list[d.seq].s_secondary_ins = trim(h.plan_name)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  fin = m_rec->list[d.seq].s_fin, mrn = m_rec->list[d.seq].s_mrn, name = m_rec->list[d.seq].s_name,
  encntr_type = m_rec->list[d.seq].s_encntr_type, encntr_id = m_rec->list[d.seq].f_encntr_id,
  facility = m_rec->list[d.seq].s_facility,
  person_id = m_rec->list[d.seq].f_person_id, mnemonic = m_rec->list[d.seq].s_order_mnemonic,
  dispense_dt_tm = m_rec->list[d.seq].s_disp_dt_tm,
  dispense_event_type = m_rec->list[d.seq].s_disp_event, doses = m_rec->list[d.seq].f_doses,
  action_type = m_rec->list[d.seq].s_action_type,
  dose_quantity = m_rec->list[d.seq].s_dose_quantity, cdm = m_rec->list[d.seq].s_cdm,
  order_detail_disp_line = m_rec->list[d.seq].s_order_disp_line,
  order_id = m_rec->list[d.seq].f_order_id, ins_primary = m_rec->list[d.seq].s_primary_ins,
  ins_secondary = m_rec->list[d.seq].s_secondary_ins
  FROM (dummyt d  WITH seq = value(size(m_rec->list,5)))
  PLAN (d)
  WITH nocounter, format, separator = " "
 ;end select
#exit_script
END GO
