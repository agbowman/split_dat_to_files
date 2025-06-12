CREATE PROGRAM bhs_gvw_meds:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 39823772.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 DECLARE ms_displays = vc WITH protect, noconstant("")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_wr = vc WITH protect, constant("\f0 \fs18 \cb2 ")
 DECLARE ms_wb = vc WITH protect, constant("{\b\cb2")
 DECLARE ms_uf = vc WITH protect, constant(" }")
 DECLARE cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs220_er_group_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loc_fac = vc WITH protect, noconstant("BMC")
 FREE RECORD m_info
 RECORD m_info(
   1 encntr_id = f8
   1 person_id = f8
   1 patient_name = vc
   1 birth_dt_tm = dq8
   1 mrn = vc
   1 fin = vc
   1 create_dt_tm = dq8
   1 admit_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 disch_ind = i2
   1 eh_cnt = i4
   1 enc_hist[*]
     2 enc_loc_hist_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 trans_dt_tm = dq8
     2 nurse_unit_cd = f8
     2 nurse_unit = vc
     2 er_loc_ind = i2
   1 ord_grps[14]
     2 o_cnt = i4
     2 orders[*]
       3 order_id = f8
       3 action_seq = i4
       3 disp = vc
       3 desc = vc
       3 catalog_cd = f8
       3 type = i4
       3 order_dt_tm = dq8
       3 dept_status = vc
       3 order_status = vc
       3 med_slot = i4
       3 doc_ind = i2
       3 d_cnt = i4
       3 details[*]
         4 field = vc
         4 value = vc
   1 m_cnt = i4
   1 meds[*]
     2 o_cnt = i4
     2 orders[*]
       3 order_id = f8
     2 ord_grp = i4
     2 ivpb_end_ind = i2
     2 med_type = f8
     2 template_ind = i2
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 beg_dt_tm_disp = vc
     2 end_dt_tm_disp = vc
     2 b_cnt = i4
     2 bags[*]
       3 bag_num = i4
       3 ba_cnt = i4
       3 bag_actions[*]
         4 action_slot = i4
     2 a_cnt = i4
     2 actions[*]
       3 desc = vc
       3 dose = f8
       3 dose_unit = vc
       3 rate = f8
       3 rate_unit = vc
       3 site = vc
       3 d_cnt = i4
       3 diluents[*]
         4 event_id = f8
         4 desc = vc
         4 dose = f8
         4 dose_unit = vc
         4 volume = f8
         4 volume_unit = vc
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 beg_dt_tm_disp = vc
       3 end_dt_tm_disp = vc
       3 beg_not_done_ind = i2
       3 end_not_done_ind = i2
       3 action_dt_tm = dq8
   1 total_r_cnt = i4
   1 no_data_ind = i2
 ) WITH protect
 DECLARE ord_grp_meds = i4 WITH constant(01)
 DECLARE ord_grp_iv = i4 WITH constant(02)
 DECLARE ord_grp_oxygen = i4 WITH constant(03)
 DECLARE ord_grp_other = i4 WITH constant(04)
 DECLARE ord_grp_lab_comp = i4 WITH constant(05)
 DECLARE ord_grp_lab_pend = i4 WITH constant(06)
 DECLARE ord_grp_rad = i4 WITH constant(07)
 DECLARE ord_grp_micro = i4 WITH constant(08)
 DECLARE ord_grp_ecg = i4 WITH constant(09)
 DECLARE ord_grp_blood = i4 WITH constant(10)
 DECLARE ord_grp_neuro = i4 WITH constant(11)
 DECLARE ord_grp_pulm = i4 WITH constant(12)
 DECLARE ord_grp_card = i4 WITH constant(13)
 DECLARE ord_grp_scripts = i4 WITH constant(14)
 DECLARE var_output = vc
 DECLARE discern_rule_ind = i2 WITH noconstant(0)
 DECLARE cs333_attenddoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE cs333_assistant_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "EDPHYSICIANASSISTANT"))
 DECLARE cs333_physician_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDPHYSICIAN"))
 DECLARE cs333_pa_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDPHYSICIANASSISTANT"))
 DECLARE cs333_resident_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDRESIDENT"))
 DECLARE cs12025_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE cs72_temp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE cs72_pulse_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE cs72_resp_rate_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE"))
 DECLARE cs72_systolic_bp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE cs72_diastolic_bp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE cs72_o2_sat_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION"))
 DECLARE cs72_mode_of_delivery_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 DECLARE cs72_weight_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cs53_grp_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6004_pending_rev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE cs6000_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE cs6000_resp_therapy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE cs106_gen_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE cs106_micro_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE cs106_blood_bank_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE cs106_blood_bank_product_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE cs106_radiology_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE cs106_restraints_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE cs106_code_status_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE cs106_adt_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ADMITTRANSFERDISCHARGE"))
 DECLARE cs106_ecg_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ECG"))
 DECLARE cs106_neurotxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "NEUROTXPROCEDURES"))
 DECLARE cs106_pulmlabtxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "PULMLABTXPROCEDURES"))
 DECLARE cs106_noninvasivecardiologytxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE cs16389_md_to_rn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"MDTORN"))
 DECLARE cs16389_consults_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"CONSULTS"))
 DECLARE cs16389_diet_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"DIET"))
 DECLARE cs16389_ivsolutions_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE cs16389_laboratory_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"LABORATORY"))
 DECLARE cs16389_card_pulm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"CARDIOPULMONARY"
   ))
 DECLARE cs18309_iv_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18309,"IV"))
 DECLARE cs18309_intermittent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"
   ))
 DECLARE cs16449_med_diluent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "MEDICATIONDILUENT"))
 DECLARE cs16449_limited_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"LIMITATIONS"))
 DECLARE cs14003_ivpb_end_dt_tm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "IVPBENDORTRANSFERDATETIME"))
 DECLARE cs14003_ivpb_status_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"IVPBSTATUS"))
 DECLARE cs24_root_cd = f8 WITH constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE cs52_normal_cd = f8 WITH constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE cs53_med_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE cs53_placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE cs72_ivparent_cd = f8 WITH constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cs180_begin_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE cs180_bolus_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE cs180_infuse_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE cs180_ratechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE cs180_sitechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"SITECHG"))
 DECLARE cs180_waste_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"WASTE"))
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_resp_mgr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSRESPIRATORYMGR"))
 DECLARE mf_resp_ther_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSRESPTHERAPIST"))
 DECLARE mf_txt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"TXT"))
 DECLARE mf_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"GRP"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mn_start_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 CALL echo("here 1")
 CALL echo(build("cs319_mrn_cd: ",cs319_mrn_cd))
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=outerjoin(e.person_id))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(cs319_mrn_cd)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(cs319_fin_cd)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_info->encntr_id = request->visit[1].encntr_id, m_info->person_id = e.person_id, m_info->
   patient_name = p.name_full_formatted,
   m_info->birth_dt_tm = p.birth_dt_tm, m_info->mrn = trim(ea1.alias), m_info->fin = trim(ea2.alias),
   m_info->create_dt_tm = e.create_dt_tm, m_info->admit_dt_tm = e.reg_dt_tm
   IF (e.disch_dt_tm != null)
    m_info->disch_ind = 1, m_info->disch_dt_tm = e.disch_dt_tm
   ELSE
    m_info->disch_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("here 2")
 IF (loc_fac="BFMC")
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLBFMC")
 ELSEIF (loc_fac="BMLH")
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLBMLH")
 ELSE
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLBMC")
 ENDIF
 CALL echo("here 3")
 IF ((m_info->encntr_id=0))
  GO TO exit_script
 ENDIF
 CALL echo("here 4")
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   location_group lg1,
   encntr_loc_hist elh
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (lg1
   WHERE lg1.parent_loc_cd=outerjoin(cs220_er_group_cd)
    AND lg1.child_loc_cd=outerjoin(e.loc_nurse_unit_cd))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.loc_nurse_unit_cd > 0.00
    AND  EXISTS (
   (SELECT
    lg2.child_loc_cd
    FROM location_group lg2
    WHERE lg2.parent_loc_cd=cs220_er_group_cd
     AND elh.loc_nurse_unit_cd=lg2.child_loc_cd)))
  ORDER BY e.encntr_id, elh.beg_effective_dt_tm
  HEAD REPORT
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD e.encntr_id
   IF (lg1.child_loc_cd <= 0.00)
    m_info->disch_ind = 2
   ENDIF
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD elh.encntr_loc_hist_id
   IF (elh.loc_nurse_unit_cd != last_nurse_unit_cd)
    eh_cnt = (m_info->eh_cnt+ 1), stat = alterlist(m_info->enc_hist,eh_cnt), m_info->eh_cnt = eh_cnt,
    m_info->enc_hist[eh_cnt].enc_loc_hist_id = elh.encntr_loc_hist_id, m_info->enc_hist[eh_cnt].
    beg_dt_tm = elh.beg_effective_dt_tm, m_info->enc_hist[eh_cnt].end_dt_tm = elh.end_effective_dt_tm,
    m_info->enc_hist[eh_cnt].trans_dt_tm = elh.transaction_dt_tm, m_info->enc_hist[eh_cnt].
    nurse_unit_cd = elh.loc_nurse_unit_cd, m_info->enc_hist[eh_cnt].nurse_unit = uar_get_code_display
    (elh.loc_nurse_unit_cd),
    last_nurse_unit_cd = elh.loc_nurse_unit_cd
   ELSE
    m_info->enc_hist[eh_cnt].end_dt_tm = elh.end_effective_dt_tm
   ENDIF
  FOOT  e.encntr_id
   IF ((m_info->eh_cnt > 0))
    m_info->create_dt_tm = m_info->enc_hist[1].beg_dt_tm, m_info->admit_dt_tm = m_info->enc_hist[1].
    beg_dt_tm
    IF (elh.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
     m_info->disch_dt_tm = elh.end_effective_dt_tm
    ELSE
     m_info->disch_dt_tm = cnvtdatetime(curdate,curtime3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("here 4")
 SELECT INTO "nl:"
  order_type =
  IF (o.orig_ord_as_flag=1) ord_grp_scripts
  ELSEIF (((o.med_order_type_cd=cs18309_iv_cd) OR (o.dcp_clin_cat_cd=cs16389_ivsolutions_cd)) )
   ord_grp_iv
  ELSEIF (o.catalog_type_cd=cs6000_pharmacy_cd) ord_grp_meds
  ELSEIF (o.catalog_type_cd=cs6000_resp_therapy_cd) ord_grp_oxygen
  ELSEIF (o.dcp_clin_cat_cd=cs16389_md_to_rn_cd) ord_grp_other
  ELSEIF (o.activity_type_cd=cs106_radiology_cd) ord_grp_rad
  ELSEIF (o.activity_type_cd=cs106_micro_cd) ord_grp_micro
  ELSEIF (o.activity_type_cd=cs106_ecg_cd) ord_grp_ecg
  ELSEIF (o.activity_type_cd IN (cs106_blood_bank_cd, cs106_blood_bank_product_cd)) ord_grp_blood
  ELSEIF (o.activity_type_cd=cs106_neurotxprocedures_cd) ord_grp_neuro
  ELSEIF (o.activity_type_cd=cs106_pulmlabtxprocedures_cd) ord_grp_pulm
  ELSEIF (((o.activity_type_cd=cs106_noninvasivecardiologytxprocedures_cd) OR (o.dcp_clin_cat_cd=
  cs16389_card_pulm_cd)) ) ord_grp_card
  ELSEIF (((o.activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
   AND o.order_status_cd=cs6004_completed_cd) ord_grp_lab_comp
  ELSEIF (((o.activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
   AND o.order_status_cd != cs6004_completed_cd) ord_grp_lab_pend
  ELSE ord_grp_other
  ENDIF
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(m_info->create_dt_tm) AND cnvtdatetime(m_info->
    disch_dt_tm)
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag IN (0, 2, 8, 32)
    AND ((o.catalog_type_cd IN (cs6000_pharmacy_cd, cs6000_resp_therapy_cd)) OR (((((o
   .activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
    AND ((o.order_status_cd != cs6004_completed_cd) OR (o.order_status_cd=cs6004_completed_cd
    AND o.order_id IN (
   (SELECT
    ce.order_id
    FROM clinical_event ce
    WHERE o.encntr_id=ce.encntr_id
     AND o.order_id=ce.order_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(m_info->disch_dt_tm)
     AND ce.view_level=1)))) ) OR (((o.activity_type_cd IN (cs106_micro_cd, cs106_blood_bank_cd,
   cs106_radiology_cd, cs106_ecg_cd, cs106_neurotxprocedures_cd,
   cs106_pulmlabtxprocedures_cd, cs106_noninvasivecardiologytxprocedures_cd)) OR (((o.dcp_clin_cat_cd
    IN (cs16389_md_to_rn_cd, cs16389_consults_cd, cs16389_diet_cd, cs16389_card_pulm_cd)) OR (o
   .activity_type_cd IN (cs106_blood_bank_product_cd, cs106_restraints_cd, cs106_code_status_cd,
   cs106_adt_cd))) )) )) )) )
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(m_info->create_dt_tm) AND cnvtdatetime(m_info->
    disch_dt_tm))
  ORDER BY order_type, o.order_mnemonic, o.orig_order_dt_tm,
   o.order_id, oa.action_sequence DESC
  HEAD REPORT
   o_cnt = 0, d_cnt = 0, m_cnt = 0,
   tmp_l = 0, rec_ind = 0
  HEAD o.order_id
   IF (oa.order_status_cd IN (cs6004_ordered_cd, cs6004_inprocess_cd, cs6004_pending_cd,
   cs6004_pending_rev_cd, cs6004_completed_cd,
   cs6004_discontinued_cd))
    o_cnt = (m_info->ord_grps[order_type].o_cnt+ 1), m_info->ord_grps[order_type].o_cnt = o_cnt, stat
     = alterlist(m_info->ord_grps[order_type].orders,o_cnt),
    m_info->ord_grps[order_type].orders[o_cnt].order_id = o.order_id, m_info->ord_grps[order_type].
    orders[o_cnt].type = order_type, m_info->ord_grps[order_type].orders[o_cnt].catalog_cd = o
    .catalog_cd,
    m_info->ord_grps[order_type].orders[o_cnt].order_status = trim(uar_get_code_display(o
      .order_status_cd),3), m_info->ord_grps[order_type].orders[o_cnt].dept_status = trim(
     uar_get_code_display(o.dept_status_cd),3), m_info->ord_grps[order_type].orders[o_cnt].
    order_dt_tm = o.orig_order_dt_tm,
    m_info->ord_grps[order_type].orders[o_cnt].action_seq = oa.action_sequence
    IF (order_type=ord_grp_scripts)
     m_info->ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3)
    ELSEIF (order_type IN (ord_grp_meds, ord_grp_iv))
     m_info->ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3), m_cnt = (m_info
     ->m_cnt+ 1), stat = alterlist(m_info->meds,m_cnt),
     m_info->meds[m_cnt].o_cnt = 1, stat = alterlist(m_info->meds[m_cnt].orders,1), m_info->m_cnt =
     m_cnt,
     m_info->meds[m_cnt].ord_grp = order_type, m_info->meds[m_cnt].template_ind = o
     .template_order_flag, m_info->meds[m_cnt].orders[1].order_id = o.order_id,
     m_info->ord_grps[order_type].orders[o_cnt].med_slot = m_cnt
    ELSEIF (order_type IN (ord_grp_oxygen, ord_grp_other))
     m_info->ord_grps[order_type].orders[o_cnt].desc =
     IF (trim(o.order_mnemonic,3) > " ") trim(o.order_mnemonic,3)
     ELSE trim(o.hna_order_mnemonic,3)
     ENDIF
    ELSEIF (order_type=ord_grp_lab_pend)
     m_info->ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o.catalog_cd),3)
    ELSEIF (order_type=ord_grp_lab_comp)
     m_info->ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o.catalog_cd),3)
    ELSE
     m_info->ord_grps[order_type].orders[o_cnt].desc = trim(o.hna_order_mnemonic,3)
    ENDIF
    m_info->ord_grps[order_type].orders[o_cnt].disp = trim(m_info->ord_grps[order_type].orders[o_cnt]
     .desc,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("here 5")
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d  WITH seq = value(size(m_info->meds,5))),
   orders o
  PLAN (d
   WHERE (m_info->meds[d.seq].template_ind=1))
   JOIN (o
   WHERE (o.template_order_id=m_info->meds[d.seq].orders[1].order_id))
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (m_info->meds[d.seq].o_cnt+ 1), m_info->meds[d.seq].o_cnt = o_cnt, stat = alterlist(m_info
    ->meds[d.seq].orders,o_cnt),
   m_info->meds[d.seq].orders[o_cnt].order_id = o.order_id
  WITH nocounter
 ;end select
 CALL echo("here 6")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_info->ord_grps,5))),
   dummyt d2,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,size(m_info->ord_grps[d1.seq].orders,5)))
   JOIN (d2)
   JOIN (od
   WHERE (od.order_id=m_info->ord_grps[d1.seq].orders[d2.seq].order_id)
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE", "DURATION", "DURATIONUNIT", "SCH/PRN", "DISPENSEQTY",
   "DISPENSEQTYUNIT", "SPECINX")) OR (od.oe_field_id IN (cs16449_med_diluent_cd, cs16449_limited_cd)
   )) )
  ORDER BY d1.seq, d2.seq, od.action_sequence,
   od.detail_sequence
  HEAD REPORT
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d1.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d2.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  DETAIL
   detail_ind = 1
   IF (od.oe_field_meaning="STRENGTHDOSE"
    AND d1.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
    strength_ind = 1
   ENDIF
   IF (((d1.seq=ord_grp_iv
    AND  NOT (od.oe_field_meaning IN ("RATE", "RATEUNIT"))) OR (d1.seq != ord_grp_iv
    AND od.oe_field_meaning IN ("RATE", "RATEUNIT"))) )
    detail_ind = 0
   ENDIF
   IF (d1.seq=ord_grp_other
    AND od.oe_field_meaning="FREQ")
    detail_ind = 0
   ENDIF
   IF (detail_ind=1)
    IF ((m_info->ord_grps[d1.seq].orders[d2.seq].d_cnt > 0))
     d_cnt = 0, d_cnt = locateval(mn_cnt,1,m_info->ord_grps[d1.seq].orders[d2.seq].d_cnt,od
      .oe_field_meaning,m_info->ord_grps[d1.seq].orders[d2.seq].details[mn_cnt].field)
    ENDIF
    IF (((d_cnt=0) OR ((od.oe_field_meaning != m_info->ord_grps[d1.seq].orders[d2.seq].details[d_cnt]
    .field))) )
     d_cnt = (m_info->ord_grps[d1.seq].orders[d2.seq].d_cnt+ 1), m_info->ord_grps[d1.seq].orders[d2
     .seq].d_cnt = d_cnt, stat = alterlist(m_info->ord_grps[d1.seq].orders[d2.seq].details,d_cnt)
    ENDIF
    m_info->ord_grps[d1.seq].orders[d2.seq].details[d_cnt].field = od.oe_field_meaning, m_info->
    ord_grps[d1.seq].orders[d2.seq].details[d_cnt].value = trim(od.oe_field_display_value,3)
   ENDIF
  FOOT  d2.seq
   IF (d1.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_oxygen, ord_grp_other, ord_grp_blood,
   ord_grp_scripts))
    FOR (d = 1 TO m_info->ord_grps[d1.seq].orders[d2.seq].d_cnt)
      detail_ind = 1
      IF (d1.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
       IF ((m_info->ord_grps[d1.seq].orders[d2.seq].details[d].field IN ("VOLUMEDOSE",
       "VOLUMEDOSEUNIT")))
        IF (strength_ind=0)
         m_info->ord_grps[d1.seq].orders[d2.seq].disp = build2(m_info->ord_grps[d1.seq].orders[d2.seq
          ].disp," ",trim(m_info->ord_grps[d1.seq].orders[d2.seq].details[d].value,3)),
         CALL echo(concat("strength ind = 0, disp: ",m_info->ord_grps[d1.seq].orders[d2.seq].disp))
        ENDIF
        detail_ind = 0
       ENDIF
      ENDIF
      IF (detail_ind=1
       AND (m_info->ord_grps[d1.seq].orders[d2.seq].details[d].field="SCH/PRN"))
       IF ((m_info->ord_grps[d1.seq].orders[d2.seq].details[d].value="Yes"))
        m_info->ord_grps[d1.seq].orders[d2.seq].disp = build2(m_info->ord_grps[d1.seq].orders[d2.seq]
         .disp," PRN"),
        CALL echo(concat("detail_ind = 1 SCHPRN, disp: ",m_info->ord_grps[d1.seq].orders[d2.seq].disp
         ))
       ENDIF
       detail_ind = 0
      ENDIF
      IF (detail_ind=1)
       m_info->ord_grps[d1.seq].orders[d2.seq].disp = build2(m_info->ord_grps[d1.seq].orders[d2.seq].
        disp," ",trim(m_info->ord_grps[d1.seq].orders[d2.seq].details[d].value,3)),
       CALL echo(concat("detail_ind = 1 SCHPRN, disp: ",m_info->ord_grps[d1.seq].orders[d2.seq].disp)
       )
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("here 7")
 SELECT INTO "nl:"
  cmr1.substance_lot_number, ce1_collating_seq = cnvtint(substring(13,3,ce1.collating_seq)),
  ce2_collating_seq = cnvtint(substring(13,3,ce2.collating_seq))
  FROM (dummyt d2  WITH seq = value(size(m_info->meds,5))),
   dummyt d3,
   clinical_event ce1,
   ce_med_result cmr1,
   clinical_event ce2,
   ce_med_result cmr2
  PLAN (d2
   WHERE maxrec(d3,size(m_info->meds[d2.seq].orders,5)))
   JOIN (d3)
   JOIN (ce1
   WHERE (ce1.order_id=m_info->meds[d2.seq].orders[d3.seq].order_id)
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(m_info->create_dt_tm) AND cnvtdatetime(m_info->
    disch_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce1.event_title_text="IVPARENT"
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr1
   WHERE cmr1.event_id=ce1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.event_end_dt_tm BETWEEN cnvtdatetime(m_info->create_dt_tm) AND cnvtdatetime(m_info->
    disch_dt_tm)
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr2
   WHERE cmr2.event_id=ce2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ce1.encntr_id, ce1.order_id, ce1.event_end_dt_tm,
   ce2.event_end_dt_tm, ce1_collating_seq, ce2_collating_seq
  HEAD REPORT
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0, tmp_ord_grp = 0
  HEAD ce1.order_id
   tmp_ord_grp = m_info->meds[d2.seq].ord_grp, m_info->meds[d2.seq].med_type = 1, tmp_o = 0,
   tmp_o = locateval(mn_cnt,1,m_info->ord_grps[tmp_ord_grp].o_cnt,ce1.order_id,m_info->ord_grps[
    tmp_ord_grp].orders[mn_cnt].order_id)
   IF ((m_info->ord_grps[tmp_ord_grp].orders[tmp_o].order_id=ce1.order_id))
    m_info->ord_grps[tmp_ord_grp].orders[tmp_o].doc_ind = 1
   ENDIF
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0
  HEAD cmr1.substance_lot_number
   b_cnt = (m_info->meds[d2.seq].b_cnt+ 1), stat = alterlist(m_info->meds[d2.seq].bags,b_cnt), m_info
   ->meds[d2.seq].b_cnt = b_cnt,
   m_info->meds[d2.seq].bags[b_cnt].bag_num = cnvtint(cmr1.substance_lot_number), m_info->ord_grps[
   tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),
    "Bag # ",trim(cmr1.substance_lot_number,3)),
   CALL echo(concat("disp1: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
  HEAD ce1.event_id
   ba_cnt = 0, a_cnt = 0, d_cnt = 0
  HEAD ce2.event_end_dt_tm
   a_cnt = (m_info->meds[d2.seq].a_cnt+ 1), stat = alterlist(m_info->meds[d2.seq].actions,a_cnt),
   m_info->meds[d2.seq].a_cnt = a_cnt,
   m_info->meds[d2.seq].actions[a_cnt].desc = uar_get_code_display(cmr2.iv_event_cd), m_info->meds[d2
   .seq].actions[a_cnt].action_dt_tm = ce2.performed_dt_tm, ba_cnt = (m_info->meds[d2.seq].bags[b_cnt
   ].ba_cnt+ 1),
   stat = alterlist(m_info->meds[d2.seq].bags[b_cnt].bag_actions,ba_cnt), m_info->meds[d2.seq].bags[
   b_cnt].ba_cnt = ba_cnt, m_info->meds[d2.seq].bags[b_cnt].bag_actions[ba_cnt].action_slot = a_cnt
   IF (cmr2.iv_event_cd=cs180_begin_cd)
    m_info->meds[d2.seq].actions[a_cnt].dose = cmr1.initial_volume, m_info->meds[d2.seq].actions[
    a_cnt].dose_unit = uar_get_code_display(cmr1.infused_volume_unit_cd), m_info->meds[d2.seq].
    actions[a_cnt].rate = cmr1.infusion_rate,
    m_info->meds[d2.seq].actions[a_cnt].rate_unit = uar_get_code_display(cmr1.infusion_unit_cd),
    m_info->meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd), m_info->
    meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm,
    m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A", m_info->
    ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[tmp_o].
     disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(build2(cmr1
       .initial_volume),3),
     " ",m_info->meds[d2.seq].actions[a_cnt].dose_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D")),
    CALL echo(concat("disp3: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp)), m_info->ord_grps[
    tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10
      ),"Site: ",trim(uar_get_code_display(cmr2.admin_site_cd),3)),
    CALL echo(concat("disp4: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
   ELSEIF (cmr2.iv_event_cd=cs180_sitechg_cd)
    m_info->meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd), m_info->
    meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm, m_info->meds[d2.seq].actions[a_cnt].
    beg_dt_tm_disp = format(ce2.event_end_dt_tm,"MM/DD/YY HH:MM;;D"),
    m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A", m_info->ord_grps[tmp_ord_grp].orders[
    tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),trim(
      uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(uar_get_code_display(cmr2.admin_site_cd),3),
     " @ ",format(ce2.event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")),
    CALL echo(concat("disp5: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
   ELSEIF (cmr2.iv_event_cd=cs180_ratechg_cd)
    m_info->meds[d2.seq].actions[a_cnt].rate = cmr1.infusion_rate, m_info->meds[d2.seq].actions[a_cnt
    ].rate_unit = uar_get_code_display(cmr1.infusion_unit_cd), m_info->meds[d2.seq].actions[a_cnt].
    beg_dt_tm = ce2.event_end_dt_tm,
    m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A", m_info->
    ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[tmp_o].
     disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(build2(cmr1.infusion_rate
       ),3),
     " ",m_info->meds[d2.seq].actions[a_cnt].rate_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D")),
    CALL echo(concat("disp6: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
   ELSEIF (cmr2.iv_event_cd IN (cs180_infuse_cd, cs180_bolus_cd))
    m_info->meds[d2.seq].actions[a_cnt].dose = cmr2.admin_dosage, m_info->meds[d2.seq].actions[a_cnt]
    .dose_unit = uar_get_code_display(cmr2.dosage_unit_cd), m_info->meds[d2.seq].actions[a_cnt].site
     = uar_get_code_display(cmr2.admin_site_cd),
    m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_start_dt_tm, m_info->meds[d2.seq].
    actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm
    IF (((ce2.event_start_dt_tm=null) OR (((ce2.event_start_dt_tm <= 0.00) OR (ce2.event_start_dt_tm=
    ce2.event_end_dt_tm)) )) )
     m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}"
    ELSE
     m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_start_dt_tm,
      "MM/DD/YY HH:MM;;D")
    ENDIF
    IF (((ce2.event_end_dt_tm=null) OR (ce2.event_end_dt_tm <= 0.00)) )
     m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "{B}*** Missing ***{ENDB}"
    ELSE
     m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = format(ce2.event_end_dt_tm,
      "MM/DD/YY HH:MM;;D")
    ENDIF
    m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[
     tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(build2(cmr2
       .admin_dosage),3),
     " ",m_info->meds[d2.seq].actions[a_cnt].dose_unit," From ",m_info->meds[d2.seq].actions[a_cnt].
     beg_dt_tm_disp," To ",
     m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp),
    CALL echo(concat("disp7: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
   ELSEIF (cmr2.iv_event_cd=cs180_waste_cd)
    m_info->meds[d2.seq].actions[a_cnt].dose = cmr2.admin_dosage, m_info->meds[d2.seq].actions[a_cnt]
    .dose_unit = uar_get_code_display(cmr2.infused_volume_unit_cd), m_info->meds[d2.seq].actions[
    a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    m_info->meds[d2.seq].actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm, m_info->meds[d2.seq].
    actions[a_cnt].beg_dt_tm_disp = "N/A", m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp =
    format(ce2.event_end_dt_tm,"MM/DD/YY HH:MM;;D"),
    m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].orders[
     tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(build2(cmr2
       .admin_dosage),3),
     " ",m_info->meds[d2.seq].actions[a_cnt].dose_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D")),
    CALL echo(concat("disp8: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
   ENDIF
  HEAD ce2.event_id
   d_cnt = (m_info->meds[d2.seq].actions[a_cnt].d_cnt+ 1), stat = alterlist(m_info->meds[d2.seq].
    actions[a_cnt].diluents,d_cnt), m_info->meds[d2.seq].actions[a_cnt].d_cnt = d_cnt,
   m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(cmr2
    .diluent_type_cd), m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume = cmr2
   .initial_volume, m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume_unit =
   uar_get_code_display(cmr2.infused_volume_unit_cd)
   IF (cmr2.dosage_unit_cd != cmr2.infused_volume_unit_cd)
    m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose = cmr2.initial_dosage, m_info->meds[d2
    .seq].actions[a_cnt].diluents[d_cnt].dose_unit = uar_get_code_display(cmr2.dosage_unit_cd)
   ENDIF
  FOOT  cmr1.substance_lot_number
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce1.event_id, ce1_sort =
  IF (ce1.task_assay_cd=0.00
   AND ce1.event_start_dt_tm != null) format(ce1.event_start_dt_tm,"YYYYMMDDHHMMSSCC;;D")
  ELSEIF (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd
   AND ce1.result_status_cd != cs8_not_done_cd) substring(3,16,ce1.result_val)
  ELSE format(ce1.event_end_dt_tm,"YYYYMMDDHHMMSSCC;;D")
  ENDIF
  FROM (dummyt d2  WITH seq = value(size(m_info->meds,5))),
   dummyt d3,
   clinical_event ce1,
   clinical_event ce2,
   ce_med_result cmr,
   orders o,
   prsnl p,
   code_value cv
  PLAN (d2
   WHERE maxrec(d3,size(m_info->meds[d2.seq].orders,5))
    AND (m_info->meds[d2.seq].med_type=0.00))
   JOIN (d3)
   JOIN (ce1
   WHERE (ce1.order_id=m_info->meds[d2.seq].orders[d3.seq].order_id)
    AND ((ce1.event_class_cd IN (cs53_med_cd, mf_txt_cd)) OR (ce1.task_assay_cd=
   cs14003_ivpb_end_dt_tm_cd))
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(m_info->create_dt_tm) AND cnvtdatetime(m_info->
    disch_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_not_done_cd)
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.order_id=ce1.order_id)
   JOIN (p
   WHERE p.person_id=ce1.performed_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=p.position_cd
    AND cv.active_ind=1)
   JOIN (ce2
   WHERE ce2.parent_event_id=outerjoin(ce1.parent_event_id)
    AND ce2.task_assay_cd=outerjoin(cs14003_ivpb_status_cd)
    AND ce2.result_status_cd=outerjoin(ce1.result_status_cd)
    AND ce2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (cmr
   WHERE cmr.event_id=outerjoin(ce1.event_id)
    AND cmr.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY 1, d2.seq, ce1_sort,
   ce1.event_id
  HEAD REPORT
   tmp_o = 0, a_cnt = 0, d_cnt = 0,
   e_cnt = 0, tmp_ord_grp = 0
  HEAD d2.seq
   a_cnt = 0, d_cnt = 0, e_cnt = 0,
   tmp_ord_grp = m_info->meds[d2.seq].ord_grp
  HEAD ce1_sort
   IF ((m_info->meds[d2.seq].a_cnt <= 0))
    a_cnt = (m_info->meds[d2.seq].a_cnt+ 1), m_info->meds[d2.seq].a_cnt = a_cnt, stat = alterlist(
     m_info->meds[d2.seq].actions,a_cnt)
   ENDIF
   tmp_o = 0, d_cnt = 0, e_cnt = 0
  HEAD ce1.event_id
   tmp_o = 0, tmp_o = locateval(mn_cnt,1,size(m_info->ord_grps[tmp_ord_grp].orders,5),o
    .template_order_id,m_info->ord_grps[tmp_ord_grp].orders[mn_cnt].order_id)
   IF (tmp_o=0)
    tmp_o = locateval(mn_cnt,1,size(m_info->ord_grps[tmp_ord_grp].orders,5),ce1.order_id,m_info->
     ord_grps[tmp_ord_grp].orders[mn_cnt].order_id)
   ENDIF
   IF (tmp_o > 0)
    m_info->ord_grps[tmp_ord_grp].orders[tmp_o].doc_ind = 1
   ENDIF
   m_info->meds[d2.seq].med_type = 2, a_cnt = m_info->meds[d2.seq].a_cnt
   IF (ce1.task_assay_cd <= 0.00)
    IF ((((m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm > 0.00)
     AND (ce1.event_end_dt_tm != m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm)) OR ((m_info->meds[d2
    .seq].actions[a_cnt].beg_not_done_ind=1))) )
     a_cnt = (m_info->meds[d2.seq].a_cnt+ 1), m_info->meds[d2.seq].a_cnt = a_cnt, stat = alterlist(
      m_info->meds[d2.seq].actions,a_cnt)
    ENDIF
    IF ((m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm <= 0.00))
     m_info->meds[d2.seq].actions[a_cnt].desc = "Admin", m_info->meds[d2.seq].actions[a_cnt].site =
     uar_get_code_display(cmr.admin_site_cd), m_info->meds[d2.seq].actions[a_cnt].action_dt_tm = ce1
     .performed_dt_tm
     IF (ce1.result_status_cd=cs8_not_done_cd)
      m_info->meds[d2.seq].actions[a_cnt].beg_not_done_ind = 1, m_info->meds[d2.seq].actions[a_cnt].
      end_not_done_ind = 1, ms_temp_str = trim(ce1.event_tag),
      mn_start_pos = findstring("Not Done:",ms_temp_str), mn_end_pos = (mn_start_pos+ 9)
      IF (mn_start_pos=0)
       mn_start_pos = findstring("Not Given:",ms_temp_str), mn_end_pos = (mn_start_pos+ 10)
      ENDIF
      IF (mn_end_pos > 0)
       ms_temp_str = build2("{B}",substring(1,mn_end_pos,ms_temp_str),"{ENDB}",substring((mn_end_pos
         + 1),textlen(ms_temp_str),ms_temp_str))
      ENDIF
      m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = build2(format(ce1.event_end_dt_tm,
        "MM/DD/YY HH:MM;;D")," :",char(10),ms_temp_str), m_info->meds[d2.seq].actions[a_cnt].
      end_dt_tm_disp = "N/A"
     ELSE
      m_info->meds[d2.seq].actions[a_cnt].beg_dt_tm = ce1.event_end_dt_tm, m_info->meds[d2.seq].
      actions[a_cnt].beg_dt_tm_disp = format(ce1.event_end_dt_tm,"MM/DD/YY HH:MM;;D")
     ENDIF
    ENDIF
    d_cnt = (m_info->meds[d2.seq].actions[a_cnt].d_cnt+ 1), m_info->meds[d2.seq].actions[a_cnt].d_cnt
     = d_cnt, stat = alterlist(m_info->meds[d2.seq].actions[a_cnt].diluents,d_cnt),
    m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].event_id = cmr.event_id, m_info->meds[d2.seq]
    .actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(ce1.event_cd), m_info->meds[d2.seq].
    actions[a_cnt].diluents[d_cnt].dose = cmr.admin_dosage,
    m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose_unit = uar_get_code_display(cmr
     .dosage_unit_cd)
    IF (cmr.dosage_unit_cd != cmr.infused_volume_unit_cd)
     m_info->meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume = cmr.initial_dosage, m_info->meds[d2
     .seq].actions[a_cnt].diluents[d_cnt].volume_unit = uar_get_code_display(cmr
      .infused_volume_unit_cd)
    ENDIF
   ELSEIF (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd)
    IF ((m_info->meds[d2.seq].actions[a_cnt].end_dt_tm > 0.00)
     AND (m_info->meds[d2.seq].actions[a_cnt].end_not_done_ind=0))
     a_cnt = (m_info->meds[d2.seq].a_cnt+ 1), m_info->meds[d2.seq].a_cnt = a_cnt, stat = alterlist(
      m_info->meds[d2.seq].actions,a_cnt),
     m_info->meds[d2.seq].actions[a_cnt].desc = "Admin"
    ENDIF
    IF (ce1.result_status_cd=cs8_not_done_cd)
     m_info->meds[d2.seq].actions[a_cnt].end_not_done_ind = 1, ms_temp_str = trim(ce1.event_tag),
     mn_start_pos = findstring("Not Done:",ms_temp_str),
     mn_end_pos = (mn_start_pos+ 9)
     IF (mn_start_pos=0)
      mn_start_pos = findstring("Not Given:",ms_temp_str), mn_end_pos = (mn_start_pos+ 10)
     ENDIF
     IF (mn_end_pos > 0)
      ms_temp_str = build2("{B}",substring(1,mn_end_pos,ms_temp_str),"{ENDB}",substring((mn_end_pos+
        1),textlen(ms_temp_str),ms_temp_str))
     ENDIF
     m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = ms_temp_str
    ELSE
     m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(substring(7,2,ce1.result_val),"/",
      substring(9,2,ce1.result_val),"/",substring(5,2,ce1.result_val),
      " ",substring(11,2,ce1.result_val),":",substring(13,2,ce1.result_val)), m_info->meds[d2.seq].
     actions[a_cnt].end_dt_tm = cnvtdatetime(cnvtdate2(substring(1,10,m_info->meds[d2.seq].actions[
        a_cnt].end_dt_tm_disp),"MM/DD/YY"),cnvtint(substring(11,6,ce1.result_val)))
     IF (ce2.clinical_event_id > 0.00)
      m_info->meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(m_info->meds[d2.seq].actions[a_cnt]
       .end_dt_tm_disp," (",trim(ce2.result_val,3),")")
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce1_sort
   d_cnt = 0, e_cnt = 0
  FOOT  d2.seq
   FOR (a = 1 TO m_info->meds[d2.seq].a_cnt)
     IF (tmp_o > 0)
      IF ((m_info->meds[d2.seq].actions[a].beg_dt_tm <= 0.00)
       AND (m_info->meds[d2.seq].actions[a].beg_not_done_ind=0))
       m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
        orders[tmp_o].disp,char(10),"{B}Admin Missing{ENDB}")
      ELSE
       m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
        orders[tmp_o].disp,char(10),"Admin @ ",m_info->meds[d2.seq].actions[a].beg_dt_tm_disp),
       CALL echo(concat("disp10: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
       IF (((cv.code_value=mf_resp_mgr_cd) OR (cv.code_value=mf_resp_ther_cd)) )
        m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
         orders[tmp_o].disp," (RT)"),
        CALL echo(concat("disp11: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
       ENDIF
       IF (trim(m_info->meds[d2.seq].actions[a].site,3) > " ")
        m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
         orders[tmp_o].disp,char(10),"Site: ",trim(m_info->meds[d2.seq].actions[a].site,3)),
        CALL echo(concat("disp12: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
       ENDIF
      ENDIF
      IF ((m_info->meds[d2.seq].ivpb_end_ind=1))
       IF ((m_info->meds[d2.seq].actions[a].end_dt_tm <= 0.00)
        AND (m_info->meds[d2.seq].actions[a].end_not_done_ind=0))
        m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
         orders[tmp_o].disp,char(10),"{B}IVPB End Missing{ENDB}"),
        CALL echo(concat("disp13: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
       ELSE
        m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(m_info->ord_grps[tmp_ord_grp].
         orders[tmp_o].disp,char(10),"IVPB @ ",m_info->meds[d2.seq].actions[a].end_dt_tm_disp),
        CALL echo(concat("disp14: ",m_info->ord_grps[tmp_ord_grp].orders[tmp_o].disp))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET ms_displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 DECLARE mn_med_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_ord_grp = i2 WITH protect, noconstant(0)
 DECLARE mn_med_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 SET reply->text = build2(ms_displays)
 FOR (mn_med_cnt = 1 TO size(m_info->meds,5))
  SET mn_ord_grp = m_info->meds[mn_med_cnt].ord_grp
  FOR (mn_med_ord_cnt = 1 TO size(m_info->meds[mn_med_cnt].orders,5))
    FOR (mn_ord_cnt = 1 TO size(m_info->ord_grps[mn_ord_grp].orders,5))
      IF ((m_info->ord_grps[mn_ord_grp].orders[mn_ord_cnt].order_id=m_info->meds[mn_med_cnt].orders[
      mn_med_ord_cnt].order_id))
       SET ms_tmp_str = m_info->ord_grps[mn_ord_grp].orders[mn_ord_cnt].disp
       CALL echo(concat("disp: ",ms_tmp_str))
       IF (findstring("Admin @",ms_tmp_str)=0
        AND findstring("Begin Bag",ms_tmp_str)=0)
        SET ms_tmp_str = concat(ms_tmp_str,char(10),"NO DOCUMENTATION")
       ENDIF
       SET ms_tmp_str = replace(ms_tmp_str,char(10),concat(" ",ms_reol," "),0)
       SET ms_tmp_str = replace(ms_tmp_str,concat(" ",ms_reol," Site")," Site",0)
       SET ms_tmp_str = build2(ms_wr,ms_tmp_str,ms_reol,ms_reol)
       SET reply->text = build2(reply->text,ms_tmp_str)
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
 SET reply->text = build2(reply->text,"}}")
 CALL echo(build2("reply->text: ",reply->text))
 CALL echorecord(m_info)
 FREE RECORD m_info
#exit_script
END GO
