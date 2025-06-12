CREATE PROGRAM bhs_ems_trans_smry_encntr_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter for Person" = ""
  WITH outdev, lstencounter
 FREE RECORD m_info
 RECORD m_info(
   1 f_encntr_id = f8
   1 s_fin_nbr = vc
   1 s_med_rec_nbr = vc
   1 f_person_id = f8
   1 s_facility = vc
   1 s_last_nurse_unit = vc
   1 s_name_full = vc
   1 s_dob = vc
   1 s_address = vc
   1 s_home_nbr = vc
   1 s_cell_nbr = vc
   1 s_work_nbr = vc
   1 s_employer = vc
   1 s_occupation = vc
   1 s_provider = vc
   1 s_weight = vc
   1 s_weight_dt_tm = vc
   1 s_temp = vc
   1 s_temp_dt_tm = vc
   1 s_heart_rate = vc
   1 s_heart_rate_dt_tm = vc
   1 s_resp_rate = vc
   1 s_resp_rate_dt_tm = vc
   1 s_systolic_bp = vc
   1 s_systolic_bp_dt_tm = vc
   1 s_diastolic_bp = vc
   1 s_diastolic_bp_dt_tm = vc
   1 s_transport_dt = vc
   1 s_transport_from = vc
   1 s_transport_to = vc
   1 s_med_trans_necessity = vc
   1 s_trans_condition = vc
   1 s_med_explanation = vc
   1 s_med_attestation = vc
   1 s_charted_by = vc
   1 s_med_nec_by = vc
   1 s_med_nec_dt = vc
   1 s_credentials = vc
   1 s_attending_md = vc
   1 s_xfer_reason = vc
   1 s_trans_need = vc
   1 s_form_name = vc
   1 allergies[*]
     2 f_allergy_id = f8
     2 s_allergy_desc = vc
     2 reactions[*]
       3 s_reaction_desc = vc
   1 resuscitations[*]
     2 s_resus_name = vc
     2 s_resus_desc = vc
   1 diags[*]
     2 s_diag_name = vc
   1 problems[*]
     2 s_problem_name = vc
   1 meds[*]
     2 f_order_id = f8
     2 s_name = vc
     2 s_dose = vc
     2 s_dose_unit = vc
     2 s_route = vc
     2 s_freq = vc
     2 s_date = vc
     2 l_template_flag = i4
   1 labs[*]
     2 f_lab_order_id = f8
     2 s_lab_name = vc
     2 results[*]
       3 s_display = vc
       3 s_value = vc
       3 s_date = vc
   1 blood[*]
     2 s_blood_name = vc
     2 s_blood_desc = vc
   1 oxygen[*]
     2 s_oxy_name = vc
     2 s_oxy_desc = vc
   1 vents[*]
     2 s_vent_name = vc
     2 s_vent_desc = vc
   1 insurance[*]
     2 s_ins_name = vc
     2 s_hp_name = vc
     2 s_plan_type = vc
     2 s_contract_nbr = vc
     2 s_group_nbr = vc
     2 s_sub_name = vc
     2 f_sub_person_id = f8
     2 s_sub_dob = vc
     2 s_sub_sex = vc
     2 s_sub_employer = vc
     2 s_sub_occupation = vc
 ) WITH protect
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE mf_grp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE mf_meds_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16389,"MEDICATIONS"))
 DECLARE mf_iv_solutions_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"
   ))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"ORDERED"))
 DECLARE mf_normal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE mf_home_addr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_cell_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE mf_home_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_work_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE mf_org_empl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",338,"EMPLOYER"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_string = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE mn_max_print_len = i4 WITH protect, noconstant(80)
 DECLARE mn_space_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_tmp_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_rem_len = i4 WITH protect, noconstant(0)
 DECLARE ml_event_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_patient_care_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCARE"))
 DECLARE mf_resp_therapy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "RESPIRATORYTHERAPY"))
 DECLARE mf_laboratory_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY")
  )
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_code_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS")
  )
 DECLARE mf_vent_invasive_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONINVASIVE"))
 DECLARE mf_vent_noninv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONNONINVASIVE"))
 DECLARE mf_general_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB")
  )
 DECLARE mf_rttxprocedures_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "RTTXPROCEDURES"))
 DECLARE mf_bloodbank_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE mf_bloodbank_mlh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKMLH"))
 DECLARE mf_bloodbank_prod_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE mf_bloodbank_donor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONOR"))
 DECLARE mf_bloodbank_donor_prod_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONORPRODUCT"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_temp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE mf_heart_rate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE mf_resp_rate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE"))
 DECLARE mf_systolic_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_diastolic_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_trans_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TRANSPORTDATE"))
 DECLARE mf_trans_from_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSPORTATIONFROM"))
 DECLARE mf_trans_to_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TRANSPORTTO"))
 DECLARE mf_med_trans_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYFORTRANSPORTATION"))
 DECLARE mf_med_expl_van_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EXPLANATIONMEDICALNECESSITYCHAIRVAN"))
 DECLARE mf_condition_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTCONDITIONATTIMEOFTRANSPORT"))
 DECLARE mf_med_expl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EXPLANATIONOFMEDICALNECESSITY"))
 DECLARE mf_med_attest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYATTESTATION"))
 DECLARE mf_charted_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHARTEDBY"))
 DECLARE mf_mednec_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYVERIFIEDBY"))
 DECLARE mf_credentials_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CREDENTIALS")
  )
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_trans_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERFACILITYTRANSFERREASON"))
 DECLARE mf_trans_needed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSPORTNEEDED"))
 DECLARE mf_med_attest2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYATTESTATIONCHAIRVAN"))
 DECLARE mf_vanform_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYFORCHAIRVANFORM"))
 DECLARE mf_ambform_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALNECESSITYFORAMBULANCEFORM"))
 CALL echo(build2("trans from cd:",mf_trans_from_cd))
 SET m_info->f_encntr_id = cnvtreal( $LSTENCOUNTER)
 IF ((m_info->f_encntr_id <= 0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    row 0, col 0, "EMS Transfer Summary",
    row + 1, col 0, "Please select one encounter."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 CALL echo("Get account number (FIN)")
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=mf_fin_cd
    AND (ea.encntr_id=m_info->f_encntr_id))
  DETAIL
   m_info->s_fin_nbr = ea.alias
  WITH nocounter
 ;end select
 CALL echo(concat("ms_output: ",ms_output))
 CALL echo(concat("FIN: ",m_info->s_fin_nbr))
 CALL echo(concat("encntr_id: ",trim(cnvtstring(m_info->f_encntr_id))))
 CALL echo("get encounter info")
 SELECT INTO "nl:"
  e.encntr_id
  FROM (dummyt d  WITH seq = 1),
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=m_info->f_encntr_id))
   JOIN (p
   WHERE (p.person_id= Outerjoin(e.person_id)) )
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_info->f_person_id = e.person_id, m_info->s_name_full = p.name_full_formatted, m_info->s_dob =
   format(p.birth_dt_tm,"dd-mmm-yyyy"),
   m_info->s_med_rec_nbr = trim(ea1.alias), m_info->s_facility = uar_get_code_display(e
    .loc_facility_cd)
   IF (e.loc_nurse_unit_cd > 0)
    m_info->s_last_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(m_info->s_last_nurse_unit)=0)
  SELECT INTO "nl:"
   FROM encntr_loc_hist e
   WHERE (e.encntr_id=m_info->f_encntr_id)
    AND (e.encntr_loc_hist_id=
   (SELECT
    max(e1.encntr_loc_hist_id)
    FROM encntr_loc_hist e1
    WHERE e1.encntr_id=e.encntr_id
     AND e1.beg_effective_dt_tm != e1.end_effective_dt_tm))
   DETAIL
    m_info->s_last_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("get pcp")
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=m_info->f_person_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm >= sysdate
    AND ppr.person_prsnl_r_cd=mf_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  DETAIL
   m_info->s_provider = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL echo("get address info")
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE (a.parent_entity_id=m_info->f_person_id)
    AND a.active_ind=1
    AND a.end_effective_dt_tm >= sysdate
    AND a.address_type_cd=mf_home_addr_cd)
  DETAIL
   IF (trim(a.street_addr) > "")
    m_info->s_address = trim(a.street_addr)
   ENDIF
   IF (trim(a.street_addr2) > "")
    m_info->s_address = concat(m_info->s_address," ",trim(a.street_addr2))
   ENDIF
   IF (trim(a.street_addr3) > "")
    m_info->s_address = concat(m_info->s_address," ",trim(a.street_addr3))
   ENDIF
   IF (trim(a.street_addr4) > "")
    m_info->s_address = concat(m_info->s_address," ",trim(a.street_addr4))
   ENDIF
   m_info->s_address = concat(m_info->s_address," ",trim(a.city)," ",trim(a.state),
    " ",trim(a.zipcode))
  WITH nocounter
 ;end select
 CALL echo("get phone info")
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=m_info->f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate
    AND p.phone_type_cd IN (mf_cell_phone_cd, mf_home_phone_cd, mf_work_phone_cd))
  DETAIL
   CASE (p.phone_type_cd)
    OF mf_cell_phone_cd:
     m_info->s_cell_nbr = trim(p.phone_num)
    OF mf_home_phone_cd:
     m_info->s_home_nbr = trim(p.phone_num)
    OF mf_work_phone_cd:
     m_info->s_work_nbr = trim(p.phone_num)
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("get employer")
 SELECT INTO "nl:"
  o.org_name, po.empl_occupation_text
  FROM person_org_reltn po,
   organization o
  PLAN (po
   WHERE (po.person_id=m_info->f_person_id)
    AND po.person_org_reltn_cd=mf_org_empl_cd
    AND po.end_effective_dt_tm >= sysdate
    AND po.active_ind=1)
   JOIN (o
   WHERE o.organization_id=po.organization_id)
  ORDER BY po.person_id, po.updt_dt_tm DESC
  HEAD po.person_id
   m_info->s_employer = o.org_name, m_info->s_occupation = po.empl_occupation_text
  WITH nocounter
 ;end select
 CALL echo("get insurance info")
 SELECT INTO "nl:"
  FROM encntr_plan_reltn e,
   person pe,
   person_alias pa,
   health_plan h,
   organization org
  PLAN (e
   WHERE e.encntr_id=50538881
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(e.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(18))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE (org.organization_id= Outerjoin(e.organization_id)) )
  ORDER BY e.encntr_plan_reltn_id
  HEAD REPORT
   pn_ins_cnt = 0
  DETAIL
   pn_ins_cnt += 1
   IF (pn_ins_cnt > size(m_info->insurance,5))
    stat = alterlist(m_info->insurance,(pn_ins_cnt+ 10))
   ENDIF
   m_info->insurance[pn_ins_cnt].s_ins_name = trim(org.org_name), m_info->insurance[pn_ins_cnt].
   s_hp_name = trim(h.plan_name), m_info->insurance[pn_ins_cnt].s_plan_type = trim(
    uar_get_code_display(h.plan_type_cd)),
   m_info->insurance[pn_ins_cnt].s_contract_nbr = trim(e.member_nbr), m_info->insurance[pn_ins_cnt].
   s_group_nbr = trim(e.group_nbr), m_info->insurance[pn_ins_cnt].s_sub_name = trim(pe
    .name_full_formatted),
   m_info->insurance[pn_ins_cnt].f_sub_person_id = pe.person_id, m_info->insurance[pn_ins_cnt].
   s_sub_dob = trim(format(pe.birth_dt_tm,"mm/dd/yyyy;;d")), m_info->insurance[pn_ins_cnt].s_sub_sex
    = trim(uar_get_code_display(pe.sex_cd))
  FOOT REPORT
   stat = alterlist(m_info->insurance,pn_ins_cnt)
  WITH nocounter
 ;end select
 CALL echo("get subscriber employee info")
 IF (size(m_info->insurance,5) > 0)
  SELECT INTO "nl:"
   o.org_name, po.empl_occupation_text
   FROM (dummyt d  WITH seq = value(size(m_info->insurance,5))),
    person_org_reltn po,
    organization o
   PLAN (d)
    JOIN (po
    WHERE (po.person_id=m_info->insurance[d.seq].f_sub_person_id)
     AND po.person_org_reltn_cd=mf_org_empl_cd
     AND po.end_effective_dt_tm >= sysdate
     AND po.active_ind=1)
    JOIN (o
    WHERE o.organization_id=po.organization_id)
   ORDER BY po.person_id, po.updt_dt_tm DESC
   HEAD po.person_id
    m_info->insurance[d.seq].s_sub_employer = o.org_name, m_info->insurance[d.seq].s_sub_occupation
     = po.empl_occupation_text
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("get clinical event info")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=m_info->f_encntr_id))
  ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm
  DETAIL
   ps_date = format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
   CALL echo(build2("event: ",uar_get_code_display(ce.event_cd)))
   CASE (ce.event_cd)
    OF mf_weight_cd:
     m_info->s_weight = trim(ce.result_val),m_info->s_weight_dt_tm = ps_date
    OF mf_temp_cd:
     m_info->s_temp = trim(ce.result_val),m_info->s_temp_dt_tm = ps_date
    OF mf_heart_rate_cd:
     m_info->s_heart_rate = trim(ce.result_val),m_info->s_heart_rate_dt_tm = ps_date
    OF mf_resp_rate_cd:
     m_info->s_resp_rate = trim(ce.result_val),m_info->s_resp_rate_dt_tm = ps_date
    OF mf_systolic_bp_cd:
     m_info->s_systolic_bp = trim(ce.result_val),m_info->s_systolic_bp_dt_tm = ps_date
    OF mf_diastolic_bp_cd:
     m_info->s_diastolic_bp = trim(ce.result_val),m_info->s_diastolic_bp_dt_tm = ps_date
   ENDCASE
  WITH nocounter
 ;end select
 SELECT
  ce3.*
  FROM clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3
  PLAN (ce1
   WHERE (ce1.encntr_id=m_info->f_encntr_id)
    AND ce1.event_cd IN (mf_vanform_cd, mf_ambform_cd)
    AND ce1.valid_until_dt_tm > sysdate)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm > sysdate)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.valid_until_dt_tm > sysdate
    AND ce3.event_cd IN (mf_trans_reason_cd, mf_attending_cd, mf_credentials_cd, mf_mednec_by_cd,
   mf_med_attest_cd,
   mf_med_expl_cd, mf_condition_cd, mf_med_trans_cd, mf_trans_to_cd, mf_trans_from_cd,
   mf_trans_dt_cd, mf_trans_needed_cd, mf_med_attest2_cd, mf_charted_by_cd, mf_med_expl_van_cd))
  ORDER BY ce1.clinsig_updt_dt_tm DESC, ce3.parent_event_id
  HEAD REPORT
   ml_event_cnt = 0
  HEAD ce3.parent_event_id
   ml_event_cnt += 1
   IF (ml_event_cnt=1)
    m_info->s_form_name = ce1.event_title_text
   ENDIF
  DETAIL
   IF (ml_event_cnt=1)
    CASE (ce3.event_cd)
     OF mf_trans_dt_cd:
      ms_tmp = trim(substring(3,16,ce3.result_val)),ms_tmp = concat(substring(5,2,ms_tmp),"/",
       substring(7,2,ms_tmp),"/",substring(1,4,ms_tmp)),m_info->s_transport_dt = ms_tmp
     OF mf_trans_from_cd:
      m_info->s_transport_from = trim(ce3.result_val),
      CALL echo(build2("trans from: ",m_info->s_transport_from))
     OF mf_trans_to_cd:
      m_info->s_transport_to = trim(ce3.result_val)
     OF mf_med_trans_cd:
      m_info->s_med_trans_necessity = trim(ce3.result_val)
     OF mf_condition_cd:
      m_info->s_trans_condition = trim(ce3.result_val)
     OF mf_med_expl_cd:
      m_info->s_med_explanation = trim(ce3.result_val)
     OF mf_med_expl_van_cd:
      m_info->s_med_explanation = trim(ce3.result_val)
     OF mf_med_attest_cd:
      m_info->s_med_attestation = trim(ce3.result_val)
     OF mf_med_attest2_cd:
      m_info->s_med_attestation = trim(ce3.result_val)
     OF mf_mednec_by_cd:
      m_info->s_med_nec_by = trim(ce3.result_val),m_info->s_med_nec_dt = format(ce3
       .clinsig_updt_dt_tm,";;q")
     OF mf_credentials_cd:
      m_info->s_credentials = trim(ce3.result_val)
     OF mf_attending_cd:
      m_info->s_attending_md = trim(ce3.result_val)
     OF mf_trans_reason_cd:
      m_info->s_xfer_reason = trim(ce3.result_val)
     OF mf_trans_needed_cd:
      m_info->s_trans_need = trim(ce3.result_val)
     OF mf_charted_by_cd:
      m_info->s_charted_by = trim(ce3.result_val)
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get allergies")
 SELECT INTO "nl:"
  FROM dummyt d,
   allergy a,
   reaction r,
   nomenclature n1,
   nomenclature n2
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=m_info->f_person_id)
    AND a.active_ind=1
    AND a.reaction_status_cd != mf_cancelled_cd)
   JOIN (r
   WHERE (r.allergy_id= Outerjoin(a.allergy_id))
    AND (r.active_ind= Outerjoin(1)) )
   JOIN (n1
   WHERE (n1.nomenclature_id= Outerjoin(a.substance_nom_id)) )
   JOIN (n2
   WHERE (n2.nomenclature_id= Outerjoin(r.reaction_nom_id)) )
  ORDER BY a.beg_effective_dt_tm, a.allergy_id, a.end_effective_dt_tm DESC
  HEAD REPORT
   pn_allergy_cnt = 0
  HEAD a.allergy_id
   pn_allergy_cnt += 1
   IF (pn_allergy_cnt > size(m_info->allergies,5))
    stat = alterlist(m_info->allergies,(pn_allergy_cnt+ 10))
   ENDIF
   m_info->allergies[pn_allergy_cnt].f_allergy_id = a.allergy_id
   IF (n1.nomenclature_id > 0)
    m_info->allergies[pn_allergy_cnt].s_allergy_desc = trim(substring(1,20,n1.source_string))
   ELSEIF (textlen(trim(a.substance_ftdesc)) > 0)
    m_info->allergies[pn_allergy_cnt].s_allergy_desc = trim(substring(1,20,a.substance_ftdesc))
   ENDIF
   pn_reaction_cnt = 0
  DETAIL
   IF (r.reaction_id > 0)
    pn_reaction_cnt += 1
    IF (pn_reaction_cnt > size(m_info->allergies[pn_allergy_cnt].reactions,5))
     stat = alterlist(m_info->allergies[pn_allergy_cnt].reactions,(pn_reaction_cnt+ 10))
    ENDIF
    IF (n2.nomenclature_id > 0)
     m_info->allergies[pn_allergy_cnt].reactions[pn_reaction_cnt].s_reaction_desc = trim(substring(1,
       20,n2.source_string))
    ELSEIF (textlen(trim(r.reaction_ftdesc)) > 0)
     m_info->allergies[pn_allergy_cnt].reactions[pn_reaction_cnt].s_reaction_desc = trim(substring(1,
       20,r.reaction_ftdesc))
    ENDIF
   ENDIF
  FOOT  a.allergy_id
   stat = alterlist(m_info->allergies[pn_allergy_cnt].reactions,pn_reaction_cnt)
  FOOT REPORT
   stat = alterlist(m_info->allergies,pn_allergy_cnt)
  WITH nocounter
 ;end select
 CALL echo("get resus/labs/vents")
 SELECT INTO "nl:"
  FROM dummyt d,
   orders o,
   code_value cv
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_info->f_encntr_id)
    AND o.catalog_type_cd IN (mf_patient_care_cd, mf_resp_therapy_cd, mf_laboratory_cd)
    AND o.activity_type_cd IN (mf_code_status_cd, mf_vent_invasive_cd, mf_vent_noninv_cd,
   mf_general_lab_cd, mf_rttxprocedures_cd,
   mf_bloodbank_cd, mf_bloodbank_mlh_cd, mf_bloodbank_prod_cd, mf_bloodbank_donor_cd,
   mf_bloodbank_donor_prod_cd))
   JOIN (cv
   WHERE cv.code_value=o.catalog_cd)
  HEAD REPORT
   pn_resus_cnt = 0, pn_lab_cnt = 0, pn_vent_cnt = 0,
   pn_oxy_cnt = 0, pn_blood_cnt = 0
  DETAIL
   IF (o.catalog_type_cd=mf_patient_care_cd
    AND o.activity_type_cd=mf_code_status_cd)
    pn_resus_cnt += 1
    IF (pn_resus_cnt > size(m_info->resuscitations,5))
     stat = alterlist(m_info->resuscitations,(pn_resus_cnt+ 10))
    ENDIF
    m_info->resuscitations[pn_resus_cnt].s_resus_name = trim(cv.display), m_info->resuscitations[
    pn_resus_cnt].s_resus_desc = trim(o.clinical_display_line)
   ELSEIF (o.catalog_type_cd=mf_resp_therapy_cd
    AND ((o.activity_type_cd=mf_vent_invasive_cd) OR (o.activity_type_cd=mf_vent_noninv_cd)) )
    IF (o.dept_status_cd=mf_ordered_cd)
     pn_vent_cnt += 1
     IF (pn_vent_cnt > size(m_info->vents,5))
      stat = alterlist(m_info->vents,(pn_vent_cnt+ 10))
     ENDIF
     m_info->vents[pn_vent_cnt].s_vent_name = trim(cv.display), m_info->vents[pn_vent_cnt].
     s_vent_desc = trim(o.clinical_display_line)
    ENDIF
   ELSEIF (o.catalog_type_cd=mf_resp_therapy_cd
    AND trim(cv.display_key) IN ("OXYGEN", "OXYGENVIACANNULA", "OXYGENVIAHIFLOW", "OXYGENVIAHOOD",
   "OXYGENVIAMASK",
   "OXYGENVIAMISTTENT", "OXYGENVIANONREBREATHER", "OXYGENVIAPARTIALREBREATHER", "OXYGENVIATPIECE",
   "OXYGENVIAVENTIMASK"))
    pn_oxy_cnt += 1,
    CALL echo(build("order_id: ",o.order_id)),
    CALL echo(build("display: ",cv.display_key)),
    CALL echo(build("mnemonic: ",o.order_mnemonic))
    IF (pn_oxy_cnt > size(m_info->oxygen,5))
     stat = alterlist(m_info->oxygen,(pn_oxy_cnt+ 10))
    ENDIF
    m_info->oxygen[pn_oxy_cnt].s_oxy_name = trim(cv.display), m_info->oxygen[pn_oxy_cnt].s_oxy_desc
     = trim(o.clinical_display_line)
   ELSEIF (o.activity_type_cd IN (mf_bloodbank_cd, mf_bloodbank_mlh_cd, mf_bloodbank_prod_cd,
   mf_bloodbank_donor_cd, mf_bloodbank_donor_prod_cd))
    pn_blood_cnt += 1
    IF (pn_blood_cnt > size(m_info->blood,5))
     stat = alterlist(m_info->blood,(pn_blood_cnt+ 10))
    ENDIF
    m_info->blood[pn_blood_cnt].s_blood_name = trim(cv.display), m_info->blood[pn_blood_cnt].
    s_blood_desc = trim(o.clinical_display_line)
   ELSEIF (o.catalog_type_cd=mf_laboratory_cd
    AND o.activity_type_cd=mf_general_lab_cd)
    pn_lab_cnt += 1
    IF (pn_lab_cnt > size(m_info->labs,5))
     stat = alterlist(m_info->labs,(pn_lab_cnt+ 10))
    ENDIF
    m_info->labs[pn_lab_cnt].f_lab_order_id = o.order_id, m_info->labs[pn_lab_cnt].s_lab_name = trim(
     cv.display)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_info->resuscitations,pn_resus_cnt), stat = alterlist(m_info->vents,pn_vent_cnt),
   stat = alterlist(m_info->labs,pn_lab_cnt),
   stat = alterlist(m_info->oxygen,pn_oxy_cnt), stat = alterlist(m_info->blood,pn_blood_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->labs,5) > 0)
  CALL echo("get lab results - abnormal only")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_info->labs,5))),
    clinical_event ce,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (ce
    WHERE (ce.order_id=m_info->labs[d.seq].f_lab_order_id)
     AND ce.view_level=1
     AND ce.normalcy_cd != mf_normal_cd
     AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
    JOIN (cv1
    WHERE cv1.code_value=ce.event_cd)
    JOIN (cv2
    WHERE cv2.code_value=ce.result_units_cd)
   HEAD d.seq
    pn_result_cnt = 0
   DETAIL
    pn_result_cnt += 1
    IF (pn_result_cnt > size(m_info->labs[d.seq].results,5))
     stat = alterlist(m_info->labs[d.seq].results,(pn_result_cnt+ 10))
    ENDIF
    m_info->labs[d.seq].results[pn_result_cnt].s_display = trim(cv1.display), m_info->labs[d.seq].
    results[pn_result_cnt].s_value = concat(trim(ce.result_val)," ",trim(cv2.display)), m_info->labs[
    d.seq].results[pn_result_cnt].s_date = format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
   FOOT  d.seq
    stat = alterlist(m_info->labs[d.seq].results,pn_result_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("get meds")
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.encntr_id=m_info->f_encntr_id)
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag IN (0, 2, 8, 32)
    AND o.orig_ord_as_flag=0
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.dcp_clin_cat_cd IN (mf_meds_cd, mf_iv_solutions_cd)
    AND o.dept_status_cd=mf_ordered_cd)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning IN ("RXROUTE", "FREQ", "STRENGTHDOSE", "STRENGTHDOSEUNIT", "REQSTARTDTTM"
   ))
  ORDER BY od.updt_dt_tm
  HEAD REPORT
   pn_med_cnt = 0
  HEAD o.order_id
   pn_med_cnt += 1
   IF (pn_med_cnt > size(m_info->meds,5))
    stat = alterlist(m_info->meds,(pn_med_cnt+ 10))
   ENDIF
   m_info->meds[pn_med_cnt].f_order_id = o.order_id, m_info->meds[pn_med_cnt].s_name = trim(o
    .hna_order_mnemonic)
   IF (o.template_order_flag > 0)
    m_info->meds[pn_med_cnt].l_template_flag = 1
   ELSE
    m_info->meds[pn_med_cnt].l_template_flag = 0
   ENDIF
  DETAIL
   CASE (od.oe_field_meaning)
    OF "RXROUTE":
     m_info->meds[pn_med_cnt].s_route = trim(od.oe_field_display_value)
    OF "FREQ":
     m_info->meds[pn_med_cnt].s_freq = trim(od.oe_field_display_value)
    OF "STRENGTHDOSE":
     m_info->meds[pn_med_cnt].s_dose = trim(od.oe_field_display_value)
    OF "STRENGTHDOSEUNIT":
     m_info->meds[pn_med_cnt].s_dose_unit = trim(od.oe_field_display_value)
   ENDCASE
  FOOT REPORT
   stat = alterlist(m_info->meds,pn_med_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->meds,5) > 0)
  SELECT INTO "nl:"
   ce.event_end_dt_tm, ce.order_id
   FROM (dummyt d  WITH seq = value(size(m_info->meds,5))),
    clinical_event ce
   PLAN (d
    WHERE (m_info->meds[d.seq].l_template_flag=0))
    JOIN (ce
    WHERE (ce.order_id=m_info->meds[d.seq].f_order_id)
     AND ce.result_status_cd=mf_auth_cd
     AND ce.valid_until_dt_tm > sysdate
     AND ce.catalog_cd > 0)
   ORDER BY ce.order_id, ce.event_end_dt_tm DESC
   HEAD ce.order_id
    m_info->meds[d.seq].s_date = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")),
    CALL echo(build2("Inside Non-Template Order: ",m_info->meds[d.seq].s_name,": ",m_info->meds[d.seq
     ].s_date))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ce.event_end_dt_tm, ce.order_id
   FROM (dummyt d  WITH seq = value(size(m_info->meds,5))),
    orders o,
    clinical_event ce
   PLAN (d
    WHERE (m_info->meds[d.seq].l_template_flag=1))
    JOIN (o
    WHERE (o.template_order_id=m_info->meds[d.seq].f_order_id))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.result_status_cd=mf_auth_cd
     AND ce.valid_until_dt_tm > sysdate
     AND ce.catalog_cd > 0)
   ORDER BY o.template_order_id, ce.event_end_dt_tm DESC
   HEAD o.template_order_id
    m_info->meds[d.seq].s_date = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")),
    CALL echo(build2("Inside Template Order: ",m_info->meds[d.seq].s_name,": ",m_info->meds[d.seq].
     s_date))
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("get diagnoses")
 SELECT INTO "nl:"
  FROM diagnosis d
  PLAN (d
   WHERE (d.encntr_id=m_info->f_encntr_id)
    AND d.active_ind=1
    AND d.end_effective_dt_tm > sysdate)
  HEAD REPORT
   pn_diag_cnt = 0
  DETAIL
   pn_diag_cnt += 1
   IF (pn_diag_cnt > size(m_info->diags,5))
    stat = alterlist(m_info->diags,(pn_diag_cnt+ 10))
   ENDIF
   m_info->diags[pn_diag_cnt].s_diag_name = trim(d.diagnosis_display)
  FOOT REPORT
   stat = alterlist(m_info->diags,pn_diag_cnt)
  WITH nocounter
 ;end select
 CALL echo("get problems")
 SELECT INTO "nl:"
  FROM problem p
  PLAN (p
   WHERE (p.person_id=m_info->f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  HEAD REPORT
   pn_prob_cnt = 0
  DETAIL
   pn_prob_cnt += 1
   IF (pn_prob_cnt > size(m_info->problems,5))
    stat = alterlist(m_info->problems,(pn_prob_cnt+ 10))
   ENDIF
   m_info->problems[pn_prob_cnt].s_problem_name = trim(p.annotated_display)
  FOOT REPORT
   stat = alterlist(m_info->problems,pn_prob_cnt)
  WITH nocounter
 ;end select
 CALL echo(concat("sending report to: ",ms_output))
 SELECT INTO value(ms_output)
  FROM dummyt d
  HEAD REPORT
   MACRO (print_text)
    mn_max_print_len = pn_max_len, mn_space_pos = 0, mn_tmp_pos = 0,
    mn_end_pos = 0, mn_beg_pos = 1, mn_rem_len = 0
    IF (textlen(ms_string) < mn_max_print_len
     AND textlen(trim(ms_string)) > 0)
     col pn_col, ms_string
    ELSEIF (textlen(ms_string) > 0)
     mn_rem_len = textlen(ms_string)
     WHILE (mn_rem_len >= mn_max_print_len)
       mn_tmp_pos = mn_beg_pos, mn_space_pos = 0
       WHILE (mn_space_pos < mn_max_print_len)
        mn_space_pos = findstring(" ",ms_string,mn_tmp_pos),
        IF (mn_space_pos > 0
         AND mn_space_pos <= mn_max_print_len)
         mn_tmp_pos = (mn_space_pos+ 1)
        ELSEIF (((mn_space_pos=0) OR (mn_space_pos > mn_max_print_len)) )
         IF (mn_tmp_pos=mn_beg_pos)
          mn_tmp_pos = mn_max_print_len
         ENDIF
         mn_space_pos = (mn_max_print_len+ 1)
        ENDIF
       ENDWHILE
       mn_space_pos = mn_tmp_pos
       IF (textlen(trim(ms_tmp_str)) > 0)
        row + 1
       ENDIF
       ms_tmp_str = trim(substring(mn_beg_pos,(mn_space_pos - mn_beg_pos),ms_string)), col pn_col,
       ms_tmp_str,
       mn_beg_pos = mn_space_pos, ms_string = substring(mn_beg_pos,((textlen(ms_string) - mn_beg_pos)
        + 1),ms_string), mn_beg_pos = 1,
       mn_rem_len = (textlen(ms_string) - mn_beg_pos)
       IF (mn_rem_len <= mn_max_print_len)
        ms_tmp_str = ms_string, row + 1, col pn_col,
        ms_tmp_str
       ENDIF
     ENDWHILE
    ENDIF
    ms_tmp_str = ""
   ENDMACRO
   , pn_tmp_ind = 0, pn_col = 0,
   pn_max_len = 0, col 0, "{F/0}{CPI/10}{LPI/6}",
   row 2, col 0, "{B}BaystateHealth Medical Necessity for Transportation/EMS Transfer Summary{ENDB}",
   row + 3
  DETAIL
   col 0, "{F/0}{CPI/12}{LPI/6}", row + 1,
   col + 12, "{U}{B}Patient Name", col + 14,
   "Date of Birth", col + 2, "Age",
   col + 6, "Primary Care Provider", col 0,
   "{ENDB}{ENDU}", row + 1, col 0,
   m_info->s_name_full, col 26, m_info->s_dob,
   ps_age = trim(cnvtage(cnvtdatetime(m_info->s_dob)),3), col 41, ps_age,
   col 52, m_info->s_provider, row + 2,
   col 0, "{U}{B}Home Address", col + 38,
   "Phone Numbers{ENDU}{ENDB}", row + 1, col 0,
   m_info->s_address
   IF (trim(m_info->s_home_nbr) > "")
    pn_tmp_ind = 1, col 50, "Home: ",
    m_info->s_home_nbr
   ENDIF
   IF (trim(m_info->s_cell_nbr) > "")
    IF (pn_tmp_ind=1)
     row + 1
    ELSE
     pn_tmp_ind = 1
    ENDIF
    col 50, "Cell: ", m_info->s_cell_nbr
   ENDIF
   IF (trim(m_info->s_work_nbr) > "")
    IF (pn_tmp_ind=1)
     row + 1
    ENDIF
    col 50, "Work: ", m_info->s_work_nbr
   ENDIF
   row + 2, col 0, "{U}{B}MR #",
   col + 14, "Account #{ENDU}{ENDB}", row + 1,
   col 0, m_info->s_med_rec_nbr, col 18,
   m_info->s_fin_nbr, row + 2, col 0,
   "{B}Facility:{ENDB}", col 20, m_info->s_facility,
   row + 1, col 0, "{B}Last Unit:{ENDB}",
   col 20, m_info->s_last_nurse_unit
   IF (size(trim(m_info->s_form_name)) != 0)
    ms_string = concat("{U}{B}",m_info->s_form_name," Transportation{ENDU}{ENDB}"), row + 2, col 0,
    ms_string, pn_col = 5, pn_max_len = 75
    IF (size(trim(m_info->s_transport_dt)) != 0)
     row + 1, col 0, "Transportation Date:",
     row + 1, col 5, m_info->s_transport_dt
    ENDIF
    IF (size(trim(m_info->s_transport_from)) != 0)
     row + 1, col 0, "Transportation From:",
     ms_string = m_info->s_transport_from, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_transport_to)) != 0)
     row + 1, col 0, "Transport To:",
     ms_string = m_info->s_transport_to, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_attending_md)) != 0)
     row + 1, col 0, "Attending Physician:",
     ms_string = m_info->s_attending_md, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_med_trans_necessity)) != 0)
     row + 1, col 0, "Medical Necessity for Transportation:",
     ms_string = m_info->s_med_trans_necessity, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_trans_condition)) != 0)
     row + 1, col 0, "Patient Condition at Time of Transport:",
     ms_string = m_info->s_trans_condition, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_med_explanation)) != 0)
     row + 1, col 0, "Explanation of Medical Necessity:",
     ms_string = m_info->s_med_explanation, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_trans_need)) != 0)
     row + 1, col 0, "Transport Needed:",
     ms_string = m_info->s_trans_need, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_xfer_reason)) != 0)
     row + 1, col 0, "Interfacility Transfer Reason:",
     ms_string = m_info->s_xfer_reason, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_med_attestation)) != 0)
     row + 1, col 0, "Medical Necessity Attestation:",
     ms_string = m_info->s_med_attestation, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_charted_by)) != 0)
     row + 1, col 0, "Charted by:",
     ms_string = m_info->s_charted_by, row + 1, print_text
    ENDIF
    IF (size(trim(m_info->s_med_nec_by)) != 0)
     row + 1, col 0, "Medical Necessity Verified By:",
     ms_string = concat(trim(m_info->s_med_nec_by)," -- ",trim(m_info->s_med_nec_dt)), row + 1,
     print_text
    ENDIF
    IF (size(trim(m_info->s_credentials)) != 0)
     row + 1, col 0, "Credentials:",
     ms_string = m_info->s_credentials, row + 1, print_text
    ENDIF
   ENDIF
   row + 2, col 0, "{B}{U}Allergies",
   col + 12, "Reaction{ENDB}{ENDU}"
   FOR (pn_allergy_cnt = 1 TO size(m_info->allergies,5))
     row + 1, col 0, m_info->allergies[pn_allergy_cnt].s_allergy_desc
     FOR (pn_reaction_cnt = 1 TO size(m_info->allergies[pn_allergy_cnt].reactions,5))
       ms_string = m_info->allergies[pn_allergy_cnt].reactions[pn_reaction_cnt].s_reaction_desc,
       pn_col = 21, pn_max_len = 59,
       print_text
       IF (pn_reaction_cnt < size(m_info->allergies[pn_allergy_cnt].reactions,5))
        row + 1
       ENDIF
     ENDFOR
   ENDFOR
   row + 2, col 0, "{B}{U}Resuscitation Status{ENDB}{ENDU}"
   FOR (pn_resus_cnt = 1 TO size(m_info->resuscitations,5))
     row + 1, ms_string = trim(concat(m_info->resuscitations[pn_resus_cnt].s_resus_name," ",m_info->
       resuscitations[pn_resus_cnt].s_resus_desc))
     IF (textlen(ms_string) > 90)
      col 0, m_info->resuscitations[pn_resus_cnt].s_resus_name, row + 1,
      col 10, m_info->resuscitations[pn_resus_cnt].s_resus_desc
     ELSE
      col 0, ms_string
     ENDIF
   ENDFOR
   row + 2, col 0, "{B}{U}Active Diagnosis and Problems{ENDB}{ENDU}"
   FOR (pn_diag_cnt = 1 TO size(m_info->diags,5))
     row + 1, col 0, m_info->diags[pn_diag_cnt].s_diag_name
   ENDFOR
   FOR (pn_prob_cnt = 1 TO size(m_info->problems,5))
     row + 1, col 0, m_info->problems[pn_prob_cnt].s_problem_name
   ENDFOR
   row + 2, col 0, "{B}{U}Medications/IV's",
   col + 16, "Dose", col + 4,
   "Route", col + 10, "Frequency",
   col + 7, "Last Given{ENDB}{ENDU}", " (active orders)"
   FOR (pn_med_cnt = 1 TO size(m_info->meds,5))
     row + 1, col 0, m_info->meds[pn_med_cnt].s_name
     IF (textlen(trim(m_info->meds[pn_med_cnt].s_name)) > 30)
      row + 1
     ENDIF
     col 32, m_info->meds[pn_med_cnt].s_dose, " ",
     m_info->meds[pn_med_cnt].s_dose_unit, col 40, m_info->meds[pn_med_cnt].s_route,
     col 55, m_info->meds[pn_med_cnt].s_freq, col 71,
     m_info->meds[pn_med_cnt].s_date
   ENDFOR
   row + 2, col 0, "{B}{U}Blood{ENDB}{ENDU}"
   FOR (pn_blood_cnt = 1 TO size(m_info->blood,5))
     row + 1, col 0, m_info->blood[pn_blood_cnt].s_blood_name,
     ms_string = m_info->blood[pn_blood_cnt].s_blood_desc, pn_col = (textlen(m_info->blood[
      pn_blood_cnt].s_blood_name)+ 2), pn_max_len = (90 - pn_col),
     print_text
   ENDFOR
   row + 2, col 0, "{B}{U}Measurements",
   col + 15, "Result", col + 12,
   "Date/Time of Last Result{ENDB}{ENDU}", row + 1, col 0,
   "Weight", col 27, m_info->s_weight,
   " kg", col 45, m_info->s_weight_dt_tm,
   row + 1, col 0, "Temperature",
   col 27, m_info->s_temp, col 45,
   m_info->s_temp_dt_tm, row + 1, col 0,
   "Heart Rate", col 27, m_info->s_heart_rate,
   col 45, m_info->s_heart_rate_dt_tm, row + 1,
   col 0, "Respiratory Rate", col 27,
   m_info->s_resp_rate, col 45, m_info->s_resp_rate_dt_tm,
   row + 1, col 0, "Blood Pressure",
   ms_string = concat(m_info->s_systolic_bp,"/",m_info->s_diastolic_bp)
   IF (trim(ms_string)="/")
    ms_string = ""
   ENDIF
   col 27, ms_string, col 45,
   m_info->s_diastolic_bp_dt_tm, row + 2, col 0,
   "{B}{U}Lab", col + 25, "Result",
   col + 21, "Date/Time{ENDB}{ENDU}", " (Abnormal results last 24 hours)"
   FOR (pn_lab_cnt = 1 TO size(m_info->labs,5))
     IF (size(m_info->labs[pn_lab_cnt].results,5) > 0)
      row + 1, col 0, m_info->labs[pn_lab_cnt].s_lab_name
      FOR (pn_result_cnt = 1 TO size(m_info->labs[pn_lab_cnt].results,5))
        row + 1, ms_string = substring(1,25,m_info->labs[pn_lab_cnt].results[pn_result_cnt].s_display
         ), col 2,
        ms_string, ms_string = substring(1,25,m_info->labs[pn_lab_cnt].results[pn_result_cnt].s_value
         ), col 28,
        ms_string, col 55, m_info->labs[pn_lab_cnt].results[pn_result_cnt].s_date
      ENDFOR
     ENDIF
   ENDFOR
   row + 2, col 0, "{B}{U}Vent Settings{ENDB}{ENDU}",
   " (Only if ordered)"
   FOR (pn_vent_cnt = 1 TO size(m_info->vents,5))
     row + 1, col 0, m_info->vents[pn_vent_cnt].s_vent_name,
     ms_string = m_info->vents[pn_vent_cnt].s_vent_desc, pn_col = (textlen(m_info->vents[pn_vent_cnt]
      .s_vent_name)+ 2), pn_max_len = (90 - pn_col),
     print_text
   ENDFOR
   row + 2, col 0, "{B}{U}Oxygen{ENDB}{ENDU}"
   FOR (pn_oxy_cnt = 1 TO size(m_info->oxygen,5))
     row + 1, col 0, m_info->oxygen[pn_oxy_cnt].s_oxy_name,
     ms_string = m_info->oxygen[pn_oxy_cnt].s_oxy_desc, pn_col = (textlen(m_info->oxygen[pn_oxy_cnt].
      s_oxy_name)+ 2), pn_max_len = (90 - pn_col),
     print_text
   ENDFOR
   row + 2, col 0, "{B}Employer: {ENDB}",
   m_info->s_employer, col 44, "{B}Occupation: {ENDB}",
   m_info->s_occupation, ms_string = fillstring(80,"-")
   IF (size(m_info->insurance,5)=0)
    row + 1, col 0, ms_string,
    row + 1, col 0, "No Insurance Information Found"
   ELSE
    FOR (pn_ins_cnt = 1 TO size(m_info->insurance,5))
      row + 1, ms_string = fillstring(80,"-"), col 0,
      ms_string, row + 1, ms_string = trim(concat("Insurance:      ",m_info->insurance[pn_ins_cnt].
        s_ins_name," / ",m_info->insurance[pn_ins_cnt].s_hp_name," / ",
        m_info->insurance[pn_ins_cnt].s_plan_type)),
      col 0, ms_string, row + 1,
      col 0, "Contract#:      ", m_info->insurance[pn_ins_cnt].s_contract_nbr,
      col 60, "Group:  ", m_info->insurance[pn_ins_cnt].s_group_nbr,
      row + 1, col 0, "Subscriber:     ",
      m_info->insurance[pn_ins_cnt].s_sub_name, row + 1, col 0,
      "Sub DOB:        ", m_info->insurance[pn_ins_cnt].s_sub_dob, col 60,
      "Sub Sex:  ", m_info->insurance[pn_ins_cnt].s_sub_sex, row + 1,
      col 0, "Sub Employer:   ", m_info->insurance[pn_ins_cnt].s_sub_employer,
      row + 1, col 0, "Sub Occupation: ",
      m_info->insurance[pn_ins_cnt].s_sub_occupation
    ENDFOR
   ENDIF
  WITH nocounter, dio = 08, maxcol = 500
 ;end select
 CALL echorecord(m_info)
#exit_script
END GO
