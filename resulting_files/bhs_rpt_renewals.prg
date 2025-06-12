CREATE PROGRAM bhs_rpt_renewals
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 DECLARE delivered_cv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",3401,"DELIVERED"))
 SELECT INTO  $OUTDEV
  refill_primary_id = ibr.ib_rx_req_id, created_dt_tm = format(ibr.create_dt_tm,"MM/DD/YYYY HH:MM;;d"
   ), prescriber = prsnl1.name_full_formatted,
  user_whom_matched = prsnl2.name_full_formatted, action_status = uar_get_code_display(ibra
   .req_status_cd), action_dt_tm = ibra.action_dt_tm,
  proposed_patient_last_name = ibrpd.last_name, proposed_patient_gender = uar_get_code_display(ibrpd
   .gender_cd), proposed_patient_city = ibrpd.city_name,
  proposed_patient_state = ibrpd.state_name, matched_patient_last_name = p.name_last,
  matched_patient_gender = uar_get_code_display(p.sex_cd),
  matched_patient = ibra.proposed_person_id, matched_encntr_id = ibra.proposed_encntr_id,
  trans_id_match_to_si_audit = ibr.trans_identifier,
  pharm_id = ibr.pharm_identifier, drug_description = substring(1,255,ibr.drug_description_txt),
  drug_id_match_type = uar_get_code_display(ibr.prod_ident_type_cd),
  drug_id = ibr.product_identifier, sig = substring(1,255,ibr.special_instructions_txt), dispense =
  ibr.dispense_qty,
  dispense_unit = uar_get_code_display(ibr.dispense_qty_unit_cd), days_supply = ibr.days_supply_nbr,
  daw = uar_get_code_display(ibr.dispense_as_written_cd),
  remain_refill = ibr.remaining_refill_qty, prn = ibr.prn_ind, pharmacy_note = substring(1,255,ibr
   .pharm_comment_txt),
  emr_order_id = o.order_id, emr_drug_name = o.ordered_as_mnemonic, emr_display_line = o
  .clinical_display_line,
  delivery_status_msg = substring(1,300,lt.long_text), patient_id = p.person_id, encounter_id = o
  .encntr_id,
  order_id = o.order_id, prsnl_id = prsnl1.person_id
  FROM ib_rx_req ibr,
   ib_rx_req_action ibra,
   ib_rx_req_person_demog ibrpd,
   prsnl prsnl1,
   prsnl prsnl2,
   person p,
   orders o,
   messaging_audit ma,
   long_text lt,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5
  PLAN (ibra
   WHERE ibra.ib_rx_req_action_id != 0)
   JOIN (ibr
   WHERE ibr.ib_rx_req_id=ibra.ib_rx_req_id
    AND ibr.create_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND ibr.create_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (ibrpd
   WHERE ibrpd.ib_rx_req_person_demog_id=ibr.ib_rx_req_person_demog_id)
   JOIN (prsnl1
   WHERE ibr.to_prsnl_id=prsnl1.person_id)
   JOIN (d1)
   JOIN (prsnl2
   WHERE ibra.action_prsnl_id=prsnl2.person_id)
   JOIN (d2)
   JOIN (p
   WHERE p.person_id=ibra.proposed_person_id)
   JOIN (d3)
   JOIN (ma
   WHERE ma.ref_trans_identifier=ibr.trans_identifier
    AND ((ma.order_id+ 0) > 0)
    AND ma.status_cd=delivered_cv)
   JOIN (d4)
   JOIN (o
   WHERE ma.order_id=o.order_id)
   JOIN (d5)
   JOIN (lt
   WHERE lt.long_text_id=ma.msg_text_id)
  ORDER BY refill_primary_id, action_dt_tm DESC
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d4,
   outerjoin = d4, nocounter, format,
   separator = " "
 ;end select
END GO
