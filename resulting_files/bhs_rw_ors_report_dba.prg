CREATE PROGRAM bhs_rw_ors_report:dba
 FREE RECORD work
 RECORD work(
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 person_id = f8
     2 patient_name = vc
     2 birth_dt_tm = dq8
     2 mrn = vc
     2 fin = vc
     2 create_dt_tm = dq8
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 disch_ind = i2
     2 eh_cnt = i4
     2 s_cur_nurse_unit = vc
     2 enc_hist[*]
       3 enc_loc_hist_id = f8
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 trans_dt_tm = dq8
       3 nurse_unit_cd = f8
       3 nurse_unit = vc
       3 er_loc_ind = i2
     2 r_cnt = i4
     2 reltns[*]
       3 reltn_type_cd = f8
       3 prsnl_name = vc
     2 a_cnt = i4
     2 allergies[*]
       3 allergy_id = f8
       3 allergy_instance_id = f8
       3 substance = vc
     2 v_cnt = i4
     2 vitals[*]
       3 event_end_dt_tm = dq8
       3 r_cnt = i4
       3 results[*]
         4 type = vc
         4 value = vc
     2 ord_grps[15]
       3 o_cnt = i4
       3 orders[*]
         4 order_id = f8
         4 action_seq = i4
         4 disp = vc
         4 desc = vc
         4 catalog_cd = f8
         4 type = i4
         4 order_dt_tm = dq8
         4 dept_status = vc
         4 order_status = vc
         4 med_slot = i4
         4 doc_ind = i2
         4 d_cnt = i4
         4 details[*]
           5 field = vc
           5 value = vc
     2 m_cnt = i4
     2 meds[*]
       3 o_cnt = i4
       3 orders[*]
         4 order_id = f8
       3 ord_grp = i4
       3 ivpb_end_ind = i2
       3 med_type = f8
       3 template_ind = i2
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 beg_dt_tm_disp = vc
       3 end_dt_tm_disp = vc
       3 b_cnt = i4
       3 bags[*]
         4 bag_num = i4
         4 ba_cnt = i4
         4 bag_actions[*]
           5 action_slot = i4
       3 a_cnt = i4
       3 actions[*]
         4 desc = vc
         4 dose = f8
         4 dose_unit = vc
         4 rate = f8
         4 rate_unit = vc
         4 site = vc
         4 d_cnt = i4
         4 diluents[*]
           5 event_id = f8
           5 desc = vc
           5 dose = f8
           5 dose_unit = vc
           5 volume = f8
           5 volume_unit = vc
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 beg_dt_tm_disp = vc
         4 end_dt_tm_disp = vc
         4 beg_not_done_ind = i2
         4 end_not_done_ind = i2
         4 action_dt_tm = dq8
     2 total_r_cnt = i4
     2 l_cnt = i4
     2 labs[*]
       3 catalog_cd = f8
       3 desc = vc
       3 r_cnt = i4
       3 results[*]
         4 order_id = f8
         4 event_end_dt_tm = dq8
         4 desc = vc
         4 value = vc
         4 units = vc
         4 mod_ind = i2
         4 normalcy = vc
     2 no_data_ind = i2
     2 s_cnt = i4
     2 sections[*]
       3 desc = vc
       3 type = i4
       3 c_cnt = i4
       3 columns[*]
         4 header = vc
         4 x_pos = i4
         4 last_line = i4
       3 l_cnt = i4
       3 lines[*]
         4 y_pos = i4
         4 c_cnt = i4
         4 columns[*]
           5 text = vc
 )
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
 DECLARE ord_grp_adm_disch = i4 WITH constant(15)
 DECLARE var_output = vc
 DECLARE discern_rule_ind = i2 WITH noconstant(0)
 DECLARE cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs220_er_group_cd = f8
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
 DECLARE mf_immun_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"IMMUNIZATION"))
 DECLARE mn_start_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ms_loc_fac = vc WITH protect, noconstant(" ")
 IF (((validate(trigger_encntrid,0.00) > 0.00) OR (validate(trigger_personid,0.00) > 0.00)) )
  SET discern_rule_ind = 1
  SET retval = 0
  SET log_message = fillstring(255," ")
 ENDIF
 IF (validate(request->output_device,"A")="A"
  AND validate(request->output_device,"Z")="Z")
  IF (reflect(parameter(1,0)) > " ")
   SET var_output = parameter(1,0)
  ELSE
   CALL echo("No output location found. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No output location found. Exiting Script")
   ENDIF
   GO TO exit_script
  ENDIF
  IF (reflect(parameter(2,0)) > " "
   AND cnvtreal(parameter(2,0)) > 0.00)
   SET work->e_cnt = 1
   SET stat = alterlist(work->encntrs,1)
   SET work->encntrs[1].encntr_id = cnvtreal(parameter(2,0))
  ELSE
   CALL echo("No ENCNTR_ID given. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No ENCNTR_ID given. Exiting Script")
   ENDIF
  ENDIF
  IF (discern_rule_ind=1)
   DECLARE beg_loop = c20 WITH constant(format(cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM:SS;;D"))
   DECLARE tmp_seconds = i4 WITH noconstant(0)
   DECLARE disch_ind = i2 WITH noconstant(0)
   WHILE (tmp_seconds BETWEEN 0 AND 1
    AND disch_ind=0)
     WHILE (tmp_seconds=cnvtint(datetimediff(cnvtdatetime(sysdate),cnvtdatetime(beg_loop),5)))
       SET tmp_seconds = tmp_seconds
     ENDWHILE
     SET tmp_seconds = cnvtint(datetimediff(cnvtdatetime(sysdate),cnvtdatetime(beg_loop),5))
     SELECT INTO "nl:"
      FROM encounter e
      PLAN (e
       WHERE (e.encntr_id=work->encntrs[1].encntr_id)
        AND e.disch_dt_tm != null)
      DETAIL
       disch_ind = 1
      WITH nocounter
     ;end select
   ENDWHILE
   IF (disch_ind=0)
    SET log_message = build2(trim(log_message,3)," Encounter still not discharged after ",trim(
      cnvtstring(tmp_seconds),3)," secs. Continuing program.")
   ENDIF
   FREE SET beg_loop
   FREE SET tmp_seconds
   FREE SET disch_ind
  ENDIF
 ELSE
  IF (trim(request->output_device,3) > " ")
   SET var_output = request->output_device
  ELSE
   CALL echo("No output location found. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No output location found. Exiting Script")
   ENDIF
   GO TO exit_script
  ENDIF
  FOR (e = 1 TO size(request->visit,5))
    IF ((request->visit[e].encntr_id > 0.00))
     SET work->e_cnt += 1
     SET stat = alterlist(work->encntrs,work->e_cnt)
     SET work->encntrs[work->e_cnt].encntr_id = request->visit[e].encntr_id
    ENDIF
  ENDFOR
 ENDIF
 IF ((work->e_cnt <= 0))
  SELECT INTO value(var_output)
   FROM dummyt
   DETAIL
    col 0, "{F/0}{CPI/18}{LPI/9}{PS/792 0 translate 90 rotate/}", row + 1,
    col 0,
    CALL print(build2(calcpos(18,8),"{B}ED Orders/Results Summary (ORS) Report{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(330,270),"{B}No encounters passed in. Exiting Program{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(18,552),'{B}Legend:{ENDB}  "*" = Med/IV not charted  "S" = Med/IV ',
     'series started  "C" = Completed  "DC" = Discontinued')), row + 1,
    col 0,
    CALL print(build2(calcpos(18,566),
     " {B}*** Report may not include all Downtime/Written Orders/Results ***{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(605,566),"{B}Printed On ",format(cnvtdatetime(sysdate),
      "MM/DD/YYYY HH:MM;;D"),"{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(368,566)," {B}END OF REPORT (Page 1){ENDB}"))
   WITH nocounter, dio = 8
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=work->encntrs[d.seq].encntr_id))
   JOIN (p
   WHERE (p.person_id= Outerjoin(e.person_id)) )
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(cs319_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(cs319_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY d.seq, e.encntr_id
  HEAD e.encntr_id
   CALL echo(build2("encounter location: ",uar_get_code_display(e.loc_facility_cd))), ms_loc_fac =
   trim(uar_get_code_display(e.loc_facility_cd)), work->encntrs[d.seq].person_id = e.person_id,
   work->encntrs[d.seq].patient_name = p.name_full_formatted, work->encntrs[d.seq].birth_dt_tm = p
   .birth_dt_tm, work->encntrs[d.seq].mrn = trim(ea1.alias),
   work->encntrs[d.seq].fin = trim(ea2.alias), work->encntrs[d.seq].create_dt_tm = e.create_dt_tm,
   work->encntrs[d.seq].admit_dt_tm = e.reg_dt_tm
   IF (e.disch_dt_tm != null)
    work->encntrs[d.seq].disch_ind = 1, work->encntrs[d.seq].disch_dt_tm = e.disch_dt_tm
   ELSE
    work->encntrs[d.seq].disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00;;d")
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_loc_fac="BFMC")
  CALL echo("bfmc")
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLFMC")
 ELSEIF (ms_loc_fac="BMLH")
  CALL echo("bmlh")
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLMLH")
 ELSE
  CALL echo("BMC")
  SET cs220_er_group_cd = uar_get_code_by("DISPLAYKEY",220,"ERALLBMC")
 ENDIF
 CALL echo(build2("cs220_er_group_cd: ",cs220_er_group_cd))
 SELECT INTO "nl:"
  ps_cur_loc = uar_get_code_display(e.loc_nurse_unit_cd)
  FROM encounter e
  WHERE (e.encntr_id=work->encntrs[1].encntr_id)
   AND e.active_ind=1
  DETAIL
   work->encntrs[1].s_cur_nurse_unit = ps_cur_loc
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_id
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   location_group lg1,
   encntr_loc_hist elh
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=work->encntrs[d.seq].encntr_id))
   JOIN (lg1
   WHERE (lg1.parent_loc_cd= Outerjoin(cs220_er_group_cd))
    AND (lg1.child_loc_cd= Outerjoin(e.loc_nurse_unit_cd)) )
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.loc_nurse_unit_cd > 0.00)
  ORDER BY e.encntr_id, elh.beg_effective_dt_tm
  HEAD REPORT
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD e.encntr_id
   IF (lg1.child_loc_cd <= 0.00)
    work->encntrs[d.seq].disch_ind = 2
   ENDIF
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD elh.encntr_loc_hist_id
   IF (elh.loc_nurse_unit_cd != last_nurse_unit_cd)
    eh_cnt = (work->encntrs[d.seq].eh_cnt+ 1), stat = alterlist(work->encntrs[d.seq].enc_hist,eh_cnt),
    work->encntrs[d.seq].eh_cnt = eh_cnt,
    work->encntrs[d.seq].enc_hist[eh_cnt].enc_loc_hist_id = elh.encntr_loc_hist_id, work->encntrs[d
    .seq].enc_hist[eh_cnt].beg_dt_tm = elh.beg_effective_dt_tm, work->encntrs[d.seq].enc_hist[eh_cnt]
    .end_dt_tm = elh.end_effective_dt_tm,
    work->encntrs[d.seq].enc_hist[eh_cnt].trans_dt_tm = elh.transaction_dt_tm, work->encntrs[d.seq].
    enc_hist[eh_cnt].nurse_unit_cd = elh.loc_nurse_unit_cd, work->encntrs[d.seq].enc_hist[eh_cnt].
    nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd),
    last_nurse_unit_cd = elh.loc_nurse_unit_cd
   ELSE
    work->encntrs[d.seq].enc_hist[eh_cnt].end_dt_tm = elh.end_effective_dt_tm
   ENDIF
  FOOT  e.encntr_id
   IF ((work->encntrs[d.seq].eh_cnt > 0))
    work->encntrs[d.seq].create_dt_tm = work->encntrs[d.seq].enc_hist[1].beg_dt_tm, work->encntrs[d
    .seq].admit_dt_tm = work->encntrs[d.seq].enc_hist[1].beg_dt_tm
    IF (elh.end_effective_dt_tm <= cnvtdatetime(sysdate))
     IF ((work->encntrs[d.seq].disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00;;d")))
      work->encntrs[d.seq].disch_dt_tm = elh.end_effective_dt_tm
     ENDIF
    ELSE
     IF ((work->encntrs[d.seq].disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00;;d")))
      work->encntrs[d.seq].disch_dt_tm = cnvtdatetime(sysdate)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (discern_rule_ind=1)
  SET log_message = build2(log_message," DISCH_DT_TM ",format(work->encntrs[1].disch_dt_tm,";;Q"),
   " DISCH_IND ",trim(cnvtstring(work->encntrs[1].disch_ind)))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=work->encntrs[d.seq].encntr_id)
    AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND epr.encntr_prsnl_r_cd IN (cs333_attenddoc_cd, cs333_assistant_cd, cs333_physician_cd,
   cs333_pa_cd, cs333_resident_cd))
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  ORDER BY d.seq, pr.name_full_formatted, pr.person_id
  HEAD REPORT
   r_cnt = 0
  HEAD pr.person_id
   r_cnt = (work->encntrs[d.seq].r_cnt+ 1), stat = alterlist(work->encntrs[d.seq].reltns,r_cnt), work
   ->encntrs[d.seq].r_cnt = r_cnt,
   work->encntrs[d.seq].reltns[r_cnt].reltn_type_cd = epr.encntr_prsnl_r_cd, work->encntrs[d.seq].
   reltns[r_cnt].prsnl_name = trim(pr.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=work->encntrs[d.seq].person_id)
    AND a.active_ind=1
    AND a.reaction_status_cd != cs12025_canceled_cd)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
  ORDER BY d.seq, a.beg_effective_dt_tm, a.allergy_id,
   a.end_effective_dt_tm DESC
  HEAD REPORT
   a_cnt = 0
  HEAD a.allergy_id
   a_cnt = (work->encntrs[d.seq].a_cnt+ 1), stat = alterlist(work->encntrs[d.seq].allergies,a_cnt),
   work->encntrs[d.seq].a_cnt = a_cnt,
   work->encntrs[d.seq].allergies[a_cnt].allergy_id = a.allergy_id, work->encntrs[d.seq].allergies[
   a_cnt].allergy_instance_id = a.allergy_instance_id
   IF (n.nomenclature_id > 0.00)
    work->encntrs[d.seq].allergies[a_cnt].substance = trim(substring(1,20,n.source_string),3)
   ELSEIF (trim(a.substance_ftdesc,3) > " ")
    work->encntrs[d.seq].allergies[a_cnt].substance = trim(substring(1,20,a.substance_ftdesc),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=work->encntrs[d.seq].encntr_id)
    AND ce.event_cd IN (cs72_temp_cd, cs72_pulse_cd, cs72_resp_rate_cd, cs72_systolic_bp_cd,
   cs72_diastolic_bp_cd,
   cs72_o2_sat_cd, cs72_mode_of_delivery_cd, cs72_weight_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(work->encntrs[d.seq].disch_dt_tm)
    AND ce.view_level=1
    AND ce.event_class_cd != cs53_grp_cd
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(work->encntrs[d.seq].create_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(work->encntrs[d.seq].disch_dt_tm))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD REPORT
   new_group_ind = 1, v_cnt = 0, r_cnt = 0,
   w_cnt = 0
  HEAD ce.event_end_dt_tm
   new_group_ind = 1
  DETAIL
   IF (new_group_ind=1)
    IF ((((work->encntrs[d.seq].v_cnt=0)) OR ((work->encntrs[d.seq].vitals[v_cnt].r_cnt > 0))) )
     v_cnt = (work->encntrs[d.seq].v_cnt+ 1), stat = alterlist(work->encntrs[d.seq].vitals,v_cnt),
     work->encntrs[d.seq].v_cnt = v_cnt
    ENDIF
    work->encntrs[d.seq].vitals[v_cnt].event_end_dt_tm = ce.event_end_dt_tm, r_cnt = 0, new_group_ind
     = 0
   ENDIF
   r_cnt = (work->encntrs[d.seq].vitals[v_cnt].r_cnt+ 1), stat = alterlist(work->encntrs[d.seq].
    vitals[v_cnt].results,r_cnt), work->encntrs[d.seq].vitals[v_cnt].r_cnt = r_cnt
   CASE (ce.event_cd)
    OF cs72_temp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Temp"
    OF cs72_pulse_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Pulse"
    OF cs72_resp_rate_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Respiratory Rate"
    OF cs72_systolic_bp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Systolic BP"
    OF cs72_diastolic_bp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Diastolic BP"
    OF cs72_o2_sat_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "O2 Sat"
    OF cs72_mode_of_delivery_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Mode of Delivery"
    OF cs72_weight_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Weight"
   ENDCASE
   work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].value = trim(ce.result_val,3)
  WITH nocounter
 ;end select
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
  ELSEIF (o.activity_type_cd=cs106_adt_cd) ord_grp_adm_disch
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
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   orders o,
   order_action oa
  PLAN (d1)
   JOIN (o
   WHERE (o.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
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
     AND ce.valid_until_dt_tm >= cnvtdatetime(work->encntrs[d1.seq].disch_dt_tm)
     AND ce.view_level=1)))) ) OR (((o.activity_type_cd IN (cs106_micro_cd, cs106_blood_bank_cd,
   cs106_radiology_cd, cs106_ecg_cd, cs106_neurotxprocedures_cd,
   cs106_pulmlabtxprocedures_cd, cs106_noninvasivecardiologytxprocedures_cd)) OR (((o.dcp_clin_cat_cd
    IN (cs16389_md_to_rn_cd, cs16389_consults_cd, cs16389_diet_cd, cs16389_card_pulm_cd)) OR (o
   .activity_type_cd IN (cs106_blood_bank_product_cd, cs106_restraints_cd, cs106_code_status_cd,
   cs106_adt_cd))) )) )) )) )
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm))
  ORDER BY d1.seq, order_type, o.order_mnemonic,
   o.orig_order_dt_tm, o.order_id, oa.action_sequence DESC
  HEAD REPORT
   o_cnt = 0, d_cnt = 0, m_cnt = 0,
   l_cnt = 0, tmp_l = 0, rec_ind = 0
  HEAD o.order_id
   IF (oa.order_status_cd IN (cs6004_ordered_cd, cs6004_inprocess_cd, cs6004_pending_cd,
   cs6004_pending_rev_cd, cs6004_completed_cd,
   cs6004_discontinued_cd))
    o_cnt = (work->encntrs[d1.seq].ord_grps[order_type].o_cnt+ 1), work->encntrs[d1.seq].ord_grps[
    order_type].o_cnt = o_cnt, stat = alterlist(work->encntrs[d1.seq].ord_grps[order_type].orders,
     o_cnt),
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].order_id = o.order_id, work->encntrs[d1
    .seq].ord_grps[order_type].orders[o_cnt].type = order_type, work->encntrs[d1.seq].ord_grps[
    order_type].orders[o_cnt].catalog_cd = o.catalog_cd,
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].order_status = trim(uar_get_code_display
     (o.order_status_cd),3), work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].dept_status =
    trim(uar_get_code_display(o.dept_status_cd),3), work->encntrs[d1.seq].ord_grps[order_type].
    orders[o_cnt].order_dt_tm = o.orig_order_dt_tm,
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].action_seq = oa.action_sequence
    IF (order_type=ord_grp_scripts)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3)
    ELSEIF (order_type IN (ord_grp_meds, ord_grp_iv))
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3),
     m_cnt = (work->encntrs[d1.seq].m_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].meds,m_cnt),
     work->encntrs[d1.seq].meds[m_cnt].o_cnt = 1, stat = alterlist(work->encntrs[d1.seq].meds[m_cnt].
      orders,1), work->encntrs[d1.seq].m_cnt = m_cnt,
     work->encntrs[d1.seq].meds[m_cnt].ord_grp = order_type, work->encntrs[d1.seq].meds[m_cnt].
     template_ind = o.template_order_flag, work->encntrs[d1.seq].meds[m_cnt].orders[1].order_id = o
     .order_id,
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].med_slot = m_cnt
    ELSEIF (order_type IN (ord_grp_oxygen, ord_grp_other))
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc =
     IF (trim(o.order_mnemonic,3) > " ") trim(o.order_mnemonic,3)
     ELSE trim(o.hna_order_mnemonic,3)
     ENDIF
    ELSEIF (order_type=ord_grp_lab_pend)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o
       .catalog_cd),3)
    ELSEIF (order_type=ord_grp_lab_comp)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o
       .catalog_cd),3), l_cnt = 0
     IF ((work->encntrs[d1.seq].l_cnt > 0))
      tmp_l = 0, l_cnt = locateval(tmp_l,1,work->encntrs[d1.seq].l_cnt,o.catalog_cd,work->encntrs[d1
       .seq].labs[tmp_l].catalog_cd)
      IF ((work->encntrs[d1.seq].labs[l_cnt].catalog_cd != o.catalog_cd))
       l_cnt = 0
      ENDIF
     ENDIF
     IF (l_cnt=0)
      l_cnt = (work->encntrs[d1.seq].l_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].labs,l_cnt),
      work->encntrs[d1.seq].l_cnt = l_cnt,
      work->encntrs[d1.seq].labs[l_cnt].catalog_cd = o.catalog_cd, work->encntrs[d1.seq].labs[l_cnt].
      desc = trim(work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc,3)
     ENDIF
    ELSE
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.hna_order_mnemonic,3)
    ENDIF
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].disp = trim(work->encntrs[d1.seq].
     ord_grps[order_type].orders[o_cnt].desc,3)
   ENDIF
  WITH nocounter, memsort
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_task_xref otx,
   task_discrete_r tdr,
   clinical_event ce,
   orders o
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders,5)))
   JOIN (d2)
   JOIN (otx
   WHERE (otx.catalog_cd=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].catalog_cd))
   JOIN (tdr
   WHERE tdr.reference_task_id=otx.reference_task_id
    AND ((tdr.task_assay_cd+ 0)=cs14003_ivpb_end_dt_tm_cd))
   JOIN (ce
   WHERE (ce.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND ce.event_title_text="IVPB Status"
    AND ce.view_level=1)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND (((o.order_id=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id)) OR ((o
   .template_order_id=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id))) )
  DETAIL
   work->encntrs[d1.seq].meds[work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].med_slot].
   ivpb_end_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_ingredient oi,
   order_task_xref otx,
   task_discrete_r tdr,
   clinical_event ce,
   orders o
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders,5)))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].
   med_slot].ivpb_end_ind=0))
   JOIN (oi
   WHERE (oi.order_id=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id))
   JOIN (otx
   WHERE otx.catalog_cd=oi.catalog_cd)
   JOIN (tdr
   WHERE tdr.reference_task_id=otx.reference_task_id
    AND ((tdr.task_assay_cd+ 0)=cs14003_ivpb_end_dt_tm_cd))
   JOIN (ce
   WHERE (ce.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND ce.event_title_text="IVPB Status"
    AND ce.view_level=1)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND (((o.order_id=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id)) OR ((o
   .template_order_id=work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id))) )
  DETAIL
   work->encntrs[d1.seq].meds[work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].med_slot].
   ivpb_end_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.order_id
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].meds,5)))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].template_ind=1))
   JOIN (o
   WHERE (o.template_order_id=work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id))
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (work->encntrs[d1.seq].meds[d2.seq].o_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].o_cnt =
   o_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].orders,o_cnt),
   work->encntrs[d1.seq].meds[d2.seq].orders[o_cnt].order_id = o.order_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].ord_grps,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->encntrs[d1.seq].ord_grps[d2.seq].orders,5)))
   JOIN (d3)
   JOIN (od
   WHERE (od.order_id=work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].order_id)
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE", "DURATION", "DURATIONUNIT", "SCH/PRN", "DISPENSEQTY",
   "DISPENSEQTYUNIT", "SPECINX")) OR (od.oe_field_id IN (cs16449_med_diluent_cd, cs16449_limited_cd)
   )) )
  ORDER BY d1.seq, d2.seq, d3.seq,
   od.action_sequence, od.detail_sequence
  HEAD REPORT
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d1.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d2.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d3.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  DETAIL
   detail_ind = 1
   IF (od.oe_field_meaning="STRENGTHDOSE"
    AND d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
    strength_ind = 1
   ENDIF
   IF (((d2.seq=ord_grp_iv
    AND  NOT (od.oe_field_meaning IN ("RATE", "RATEUNIT"))) OR (d2.seq != ord_grp_iv
    AND od.oe_field_meaning IN ("RATE", "RATEUNIT"))) )
    detail_ind = 0
   ENDIF
   IF (d2.seq=ord_grp_other
    AND od.oe_field_meaning="FREQ")
    detail_ind = 0
   ENDIF
   IF (detail_ind=1)
    IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt > 0))
     d_cnt = 0, d_cnt = locateval(mn_cnt,1,work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].
      d_cnt,od.oe_field_meaning,work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[mn_cnt]
      .field)
    ENDIF
    IF (((d_cnt=0) OR ((od.oe_field_meaning != work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].
    details[d_cnt].field))) )
     d_cnt = (work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt+ 1), work->encntrs[d1.seq].
     ord_grps[d2.seq].orders[d3.seq].d_cnt = d_cnt, stat = alterlist(work->encntrs[d1.seq].ord_grps[
      d2.seq].orders[d3.seq].details,d_cnt)
    ENDIF
    work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d_cnt].field = od.oe_field_meaning,
    work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d_cnt].value = trim(od
     .oe_field_display_value,3)
   ENDIF
  FOOT  d3.seq
   IF (d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_oxygen, ord_grp_other, ord_grp_blood,
   ord_grp_scripts))
    FOR (d = 1 TO work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt)
      detail_ind = 1
      IF (d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
       IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].field IN ("VOLUMEDOSE",
       "VOLUMEDOSEUNIT")))
        IF (strength_ind=0)
         work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
          ord_grps[d2.seq].orders[d3.seq].disp," ",trim(work->encntrs[d1.seq].ord_grps[d2.seq].
           orders[d3.seq].details[d].value,3))
        ENDIF
        detail_ind = 0
       ENDIF
      ENDIF
      IF (detail_ind=1
       AND (work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].field="SCH/PRN"))
       IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].value="Yes"))
        work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
         ord_grps[d2.seq].orders[d3.seq].disp," PRN")
       ENDIF
       detail_ind = 0
      ENDIF
      IF (detail_ind=1)
       work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
        ord_grps[d2.seq].orders[d3.seq].disp," ",trim(work->encntrs[d1.seq].ord_grps[d2.seq].orders[
         d3.seq].details[d].value,3))
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].l_cnt))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND (ce.catalog_cd=work->encntrs[d1.seq].labs[d2.seq].catalog_cd)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.view_level=1
    AND ce.event_reltn_cd != cs24_root_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY ce.event_end_dt_tm
  HEAD REPORT
   r_cnt = 0
  DETAIL
   r_cnt = (work->encntrs[d1.seq].labs[d2.seq].r_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    labs[d2.seq].results,r_cnt), work->encntrs[d1.seq].labs[d2.seq].r_cnt = r_cnt,
   work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].order_id = ce.order_id, work->encntrs[d1.seq].
   labs[d2.seq].results[r_cnt].event_end_dt_tm = ce.event_end_dt_tm, work->encntrs[d1.seq].labs[d2
   .seq].results[r_cnt].desc = trim(uar_get_code_display(ce.event_cd)),
   work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].value = trim(ce.result_val), work->encntrs[d1
   .seq].labs[d2.seq].results[r_cnt].units = trim(uar_get_code_display(ce.result_units_cd))
   IF (ce.result_status_cd != cs8_auth_cd)
    work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].mod_ind = 1
   ENDIF
   IF ( NOT (ce.normalcy_cd IN (0.00, cs52_normal_cd)))
    work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].normalcy = trim(uar_get_code_display(ce
      .normalcy_cd))
   ENDIF
   work->encntrs[d1.seq].total_r_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cmr1.substance_lot_number, ce1_collating_seq = cnvtint(substring(13,3,ce1.collating_seq)),
  ce2_collating_seq = cnvtint(substring(13,3,ce2.collating_seq))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   ce_med_result cmr1,
   clinical_event ce2,
   ce_med_result cmr2
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].meds,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->encntrs[d1.seq].meds[d2.seq].orders,5)))
   JOIN (d3)
   JOIN (ce1
   WHERE (ce1.order_id=work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id)
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime
   (work->encntrs[d1.seq].disch_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce1.event_title_text="IVPARENT"
    AND ce1.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cmr1
   WHERE cmr1.event_id=ce1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime
   (work->encntrs[d1.seq].disch_dt_tm)
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cmr2
   WHERE cmr2.event_id=ce2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY ce1.encntr_id, ce1.order_id, ce1.event_end_dt_tm,
   ce2.event_end_dt_tm, ce1_collating_seq, ce2_collating_seq
  HEAD REPORT
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0, tmp_ord_grp = 0
  HEAD ce1.order_id
   tmp_ord_grp = work->encntrs[d1.seq].meds[d2.seq].ord_grp, work->encntrs[d1.seq].meds[d2.seq].
   med_type = 1, tmp_o = 0,
   tmp_o = locateval(mn_cnt,1,work->encntrs[d1.seq].ord_grps[tmp_ord_grp].o_cnt,ce1.order_id,work->
    encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[mn_cnt].order_id)
   IF ((work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].order_id=ce1.order_id))
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].doc_ind = 1
   ENDIF
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0
  HEAD cmr1.substance_lot_number
   b_cnt = (work->encntrs[d1.seq].meds[d2.seq].b_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].bags,b_cnt), work->encntrs[d1.seq].meds[d2.seq].b_cnt = b_cnt,
   work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].bag_num = cnvtint(cmr1.substance_lot_number), work
   ->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
    ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"Bag # ",trim(cmr1.substance_lot_number,3))
  HEAD ce1.event_id
   ba_cnt = 0, a_cnt = 0, d_cnt = 0
  HEAD ce2.event_end_dt_tm
   a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].actions,a_cnt), work->encntrs[d1.seq].meds[d2.seq].a_cnt = a_cnt,
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = uar_get_code_display(cmr2.iv_event_cd),
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].action_dt_tm = ce2.performed_dt_tm, ba_cnt = (
   work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].ba_cnt+ 1),
   stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].bag_actions,ba_cnt), work->
   encntrs[d1.seq].meds[d2.seq].bags[b_cnt].ba_cnt = ba_cnt, work->encntrs[d1.seq].meds[d2.seq].bags[
   b_cnt].bag_actions[ba_cnt].action_slot = a_cnt
   IF (cmr2.iv_event_cd=cs180_begin_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr1.initial_volume, work->encntrs[d1
    .seq].meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr1.infused_volume_unit_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate = cmr1.infusion_rate,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate_unit = uar_get_code_display(cmr1
     .infusion_unit_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site =
    uar_get_code_display(cmr2.admin_site_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].
    beg_dt_tm = ce2.event_end_dt_tm,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A",
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),
     ": ",trim(build2(cmr1.initial_volume),3),
     " ",work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D")),
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"Site: ",trim(uar_get_code_display(cmr2
       .admin_site_cd),3))
   ELSEIF (cmr2.iv_event_cd=cs180_sitechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm, work->encntrs[
    d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A", work->encntrs[d1.seq].
    ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].ord_grps[tmp_ord_grp].
     orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),": ",trim(
      uar_get_code_display(cmr2.admin_site_cd),3),
     " @ ",format(ce2.event_end_dt_tm,"MM/DD/YYYY HH:MM;;D"))
   ELSEIF (cmr2.iv_event_cd=cs180_ratechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate = cmr1.infusion_rate, work->encntrs[d1.seq
    ].meds[d2.seq].actions[a_cnt].rate_unit = uar_get_code_display(cmr1.infusion_unit_cd), work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A",
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),
     ": ",trim(build2(cmr1.infusion_rate),3),
     " ",work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D"))
   ELSEIF (cmr2.iv_event_cd IN (cs180_infuse_cd, cs180_bolus_cd))
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr2.admin_dosage, work->encntrs[d1.seq]
    .meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr2.dosage_unit_cd), work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_start_dt_tm, work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm
    IF (((ce2.event_start_dt_tm=null) OR (((ce2.event_start_dt_tm <= 0.00) OR (ce2.event_start_dt_tm=
    ce2.event_end_dt_tm)) )) )
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}"
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_start_dt_tm,
      "MM/DD/YY HH:MM;;D")
    ENDIF
    IF (((ce2.event_end_dt_tm=null) OR (ce2.event_end_dt_tm <= 0.00)) )
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "{B}*** Missing ***{ENDB}"
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = format(ce2.event_end_dt_tm,
      "MM/DD/YY HH:MM;;D")
    ENDIF
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),
     ": ",trim(build2(cmr2.admin_dosage),3),
     " ",work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose_unit," From ",work->encntrs[d1.seq].
     meds[d2.seq].actions[a_cnt].beg_dt_tm_disp," To ",
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp)
   ELSEIF (cmr2.iv_event_cd=cs180_waste_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr2.admin_dosage, work->encntrs[d1.seq]
    .meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr2.infused_volume_unit_cd), work
    ->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm, work->encntrs[
    d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "N/A", work->encntrs[d1.seq].meds[d2.seq].
    actions[a_cnt].end_dt_tm_disp = format(ce2.event_end_dt_tm,"MM/DD/YY HH:MM;;D"),
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),
     ": ",trim(build2(cmr2.admin_dosage),3),
     " ",work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D"))
   ENDIF
  HEAD ce2.event_id
   d_cnt = (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].d_cnt+ 1), stat = alterlist(work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents,d_cnt), work->encntrs[d1.seq].meds[d2.seq].
   actions[a_cnt].d_cnt = d_cnt,
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(cmr2
    .diluent_type_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume =
   cmr2.initial_volume, work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume_unit
    = uar_get_code_display(cmr2.infused_volume_unit_cd)
   IF (cmr2.dosage_unit_cd != cmr2.infused_volume_unit_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose = cmr2.initial_dosage,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose_unit =
    uar_get_code_display(cmr2.dosage_unit_cd)
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
  FROM (dummyt d1  WITH seq = value(size(work->encntrs,5))),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   clinical_event ce2,
   ce_med_result cmr,
   orders o,
   prsnl p,
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].meds,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->encntrs[d1.seq].meds[d2.seq].orders,5))
    AND (work->encntrs[d1.seq].meds[d2.seq].med_type=0.00))
   JOIN (d3)
   JOIN (ce1
   WHERE (ce1.order_id=work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id)
    AND ((ce1.event_class_cd IN (cs53_med_cd, mf_txt_cd, mf_immun_cd)) OR (ce1.task_assay_cd=
   cs14003_ivpb_end_dt_tm_cd))
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime
   (work->encntrs[d1.seq].disch_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_not_done_cd)
    AND ce1.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (o
   WHERE o.order_id=ce1.order_id)
   JOIN (p
   WHERE p.person_id=ce1.performed_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=p.position_cd
    AND cv.active_ind=1)
   JOIN (ce2
   WHERE (ce2.parent_event_id= Outerjoin(ce1.parent_event_id))
    AND (ce2.task_assay_cd= Outerjoin(cs14003_ivpb_status_cd))
    AND (ce2.result_status_cd= Outerjoin(ce1.result_status_cd))
    AND (ce2.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (cmr
   WHERE (cmr.event_id= Outerjoin(ce1.event_id))
    AND (cmr.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY d1.seq, d2.seq, ce1_sort,
   ce1.event_id
  HEAD REPORT
   tmp_o = 0, a_cnt = 0, d_cnt = 0,
   e_cnt = 0, tmp_ord_grp = 0
  HEAD d1.seq
   tmp_o = 0, a_cnt = 0, d_cnt = 0,
   e_cnt = 0
  HEAD d2.seq
   a_cnt = 0, d_cnt = 0, e_cnt = 0,
   tmp_ord_grp = work->encntrs[d1.seq].meds[d2.seq].ord_grp
  HEAD ce1_sort
   IF ((work->encntrs[d1.seq].meds[d2.seq].a_cnt <= 0))
    a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
     = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt)
   ENDIF
   tmp_o = 0, d_cnt = 0, e_cnt = 0
  HEAD ce1.event_id
   tmp_o = 0, tmp_o = locateval(mn_cnt,1,size(work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders,5),o
    .template_order_id,work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[mn_cnt].order_id)
   IF (tmp_o=0)
    tmp_o = locateval(mn_cnt,1,size(work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders,5),ce1
     .order_id,work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[mn_cnt].order_id)
   ENDIF
   IF (tmp_o > 0)
    work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].doc_ind = 1
   ENDIF
   CALL echo(build2("order id: ",work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].order_id)),
   work->encntrs[d1.seq].meds[d2.seq].med_type = 2, a_cnt = work->encntrs[d1.seq].meds[d2.seq].a_cnt
   IF (ce1.task_assay_cd <= 0.00)
    IF ((((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm > 0.00)
     AND (ce1.event_end_dt_tm != work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm)) OR ((
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_not_done_ind=1))) )
     a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
      = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt)
    ENDIF
    IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm <= 0.00))
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = "Admin", work->encntrs[d1.seq].meds[d2
     .seq].actions[a_cnt].site = uar_get_code_display(cmr.admin_site_cd), work->encntrs[d1.seq].meds[
     d2.seq].actions[a_cnt].action_dt_tm = ce1.performed_dt_tm
     IF (ce1.result_status_cd=cs8_not_done_cd)
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_not_done_ind = 1, work->encntrs[d1.seq].
      meds[d2.seq].actions[a_cnt].end_not_done_ind = 1, ms_temp_str = trim(ce1.event_tag),
      mn_start_pos = findstring("Not Done:",ms_temp_str), mn_end_pos = (mn_start_pos+ 9)
      IF (mn_start_pos=0)
       mn_start_pos = findstring("Not Given:",ms_temp_str), mn_end_pos = (mn_start_pos+ 10)
      ENDIF
      IF (mn_end_pos > 0)
       ms_temp_str = build2("{B}",substring(1,mn_end_pos,ms_temp_str),"{ENDB}",substring((mn_end_pos
         + 1),textlen(ms_temp_str),ms_temp_str))
      ENDIF
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = build2(format(ce1
        .event_end_dt_tm,"MM/DD/YY HH:MM;;D")," :",char(10),ms_temp_str), work->encntrs[d1.seq].meds[
      d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A"
     ELSE
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce1.event_end_dt_tm, work->
      encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce1.event_end_dt_tm,
       "MM/DD/YY HH:MM;;D")
     ENDIF
    ENDIF
    d_cnt = (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].d_cnt+ 1), work->encntrs[d1.seq].meds[
    d2.seq].actions[a_cnt].d_cnt = d_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].
     actions[a_cnt].diluents,d_cnt),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].event_id = cmr.event_id, work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(ce1
     .event_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose = cmr
    .admin_dosage,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose_unit =
    uar_get_code_display(cmr.dosage_unit_cd)
    IF (cmr.dosage_unit_cd != cmr.infused_volume_unit_cd)
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume = cmr.initial_dosage,
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume_unit =
     uar_get_code_display(cmr.infused_volume_unit_cd)
    ENDIF
   ELSEIF (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd)
    IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm > 0.00)
     AND (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_not_done_ind=0))
     a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
      = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt),
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = "Admin"
    ENDIF
    IF (ce1.result_status_cd=cs8_not_done_cd)
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_not_done_ind = 1, ms_temp_str = trim(ce1
      .event_tag), mn_start_pos = findstring("Not Done:",ms_temp_str),
     mn_end_pos = (mn_start_pos+ 9)
     IF (mn_start_pos=0)
      mn_start_pos = findstring("Not Given:",ms_temp_str), mn_end_pos = (mn_start_pos+ 10)
     ENDIF
     IF (mn_end_pos > 0)
      ms_temp_str = build2("{B}",substring(1,mn_end_pos,ms_temp_str),"{ENDB}",substring((mn_end_pos+
        1),textlen(ms_temp_str),ms_temp_str))
     ENDIF
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = ms_temp_str
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(substring(7,2,ce1
       .result_val),"/",substring(9,2,ce1.result_val),"/",substring(5,2,ce1.result_val),
      " ",substring(11,2,ce1.result_val),":",substring(13,2,ce1.result_val)), work->encntrs[d1.seq].
     meds[d2.seq].actions[a_cnt].end_dt_tm = cnvtdatetime(cnvtdate2(substring(1,10,work->encntrs[d1
        .seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp),"MM/DD/YY"),cnvtint(substring(11,6,ce1
        .result_val)))
     IF (ce2.clinical_event_id > 0.00)
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(work->encntrs[d1.seq]
       .meds[d2.seq].actions[a_cnt].end_dt_tm_disp," (",trim(ce2.result_val,3),")")
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce1_sort
   d_cnt = 0, e_cnt = 0
  FOOT  d2.seq
   FOR (a = 1 TO work->encntrs[d1.seq].meds[d2.seq].a_cnt)
     IF (tmp_o > 0)
      IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_dt_tm <= 0.00)
       AND (work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_not_done_ind=0))
       work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
        ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"{B}Admin Missing{ENDB}")
      ELSE
       work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
        ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"Admin @ ",work->encntrs[d1.seq].meds[d2
        .seq].actions[a].beg_dt_tm_disp)
       IF (((cv.code_value=mf_resp_mgr_cd) OR (cv.code_value=mf_resp_ther_cd)) )
        work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq]
         .ord_grps[tmp_ord_grp].orders[tmp_o].disp," (RT)")
       ENDIF
       IF (trim(work->encntrs[d1.seq].meds[d2.seq].actions[a].site,3) > " ")
        work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq]
         .ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"Site: ",trim(work->encntrs[d1.seq].meds[
          d2.seq].actions[a].site,3))
       ENDIF
      ENDIF
      IF ((work->encntrs[d1.seq].meds[d2.seq].ivpb_end_ind=1))
       IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a].end_dt_tm <= 0.00)
        AND (work->encntrs[d1.seq].meds[d2.seq].actions[a].end_not_done_ind=0))
        work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq]
         .ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"{B}IVPB End Missing{ENDB}")
       ELSE
        work->encntrs[d1.seq].ord_grps[tmp_ord_grp].orders[tmp_o].disp = build2(work->encntrs[d1.seq]
         .ord_grps[tmp_ord_grp].orders[tmp_o].disp,char(10),"IVPB @ ",work->encntrs[d1.seq].meds[d2
         .seq].actions[a].end_dt_tm_disp)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 CALL echorecord(work)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(work->encntrs,5))),
   dummyt d2,
   dummyt d3,
   clinical_event ce,
   ce_event_note cen,
   long_blob lb,
   orders o
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].meds,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->encntrs[d1.seq].meds[d2.seq].orders,5)))
   JOIN (d3)
   JOIN (o
   WHERE (o.order_id=work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ((ce.event_class_cd IN (cs53_med_cd, mf_txt_cd, mf_grp_cd)) OR (ce.task_assay_cd=
   cs14003_ivpb_end_dt_tm_cd))
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_not_done_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cen
   WHERE cen.event_id=ce.event_id
    AND (cen.updt_cnt=
   (SELECT
    max(c.updt_cnt)
    FROM ce_event_note c
    WHERE c.event_id=ce.event_id)))
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id)
  HEAD REPORT
   pn_index = 0, pn_ord_grp = 0
  DETAIL
   pn_ord_grp = work->encntrs[d1.seq].meds[d2.seq].ord_grp
   IF (o.template_order_id=0)
    pn_index = locateval(mn_cnt,1,size(work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders,5),o
     .order_id,work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders[mn_cnt].order_id)
   ELSE
    pn_index = locateval(mn_cnt,1,size(work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders,5),o
     .template_order_id,work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders[mn_cnt].order_id)
   ENDIF
   blob_size = cnvtint(lb.blob_length), blob_out_detail = fillstring(64000," "),
   blob_compressed_trimmed = fillstring(64000," "),
   blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
   fillstring(64000," "),
   blob_compressed_trimmed = trim(lb.long_blob), blob_return_len = 0, blob_return_len2 = 0
   IF (cen.compression_cd=mf_comp_cd)
    CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
    size(blob_uncompressed),blob_return_len),
    CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
    eventval = trim(blob_rtf,3)
   ELSEIF (cen.compression_cd=mf_no_comp_cd)
    eventval = trim(lb.long_blob)
    IF (findstring("rtf",eventval) > 0)
     CALL uar_rtf2(eventval,textlen(eventval),blob_rtf,size(blob_rtf),blob_return_len2,1), eventval
      = trim(blob_rtf,3)
    ENDIF
    IF (findstring("ocf_blob",eventval) > 0)
     eventval = trim(substring(1,(findstring("ocf_blob",eventval) - 1),eventval))
    ENDIF
   ENDIF
   work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders[pn_index].disp = concat(work->encntrs[d1.seq].
    ord_grps[pn_ord_grp].orders[pn_index].disp,char(10),eventval),
   CALL echo(concat("blob id: ",cnvtstring(lb.long_blob_id))),
   CALL echo(concat("blob disp: ",work->encntrs[d1.seq].ord_grps[pn_ord_grp].orders[pn_index].disp)),
   CALL echo("blob disp end")
  WITH nocounter
 ;end select
 DECLARE s_cnt = i4
 DECLARE c_cnt = i4
 DECLARE l_cnt = i4
 DECLARE tmp_l = i4
 DECLARE tmp_c = i4
 FOR (e = 1 TO work->e_cnt)
   SET s_cnt = 0
   SET c_cnt = 0
   SET l_cnt = 0
   SET tmp_l = 0
   SET tmp_c = 0
   CALL echo(" ")
   CALL echo(build2("Begin Patient: ",work->encntrs[e].fin," (",trim(cnvtstring(e)),")"))
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "PATDATA"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 9
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Patient{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}MRN{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 166
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Acct #{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 204
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}DOB{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 248
   SET work->encntrs[e].sections[s_cnt].columns[5].header = "{B}{U}Reg Location{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = 322
   SET work->encntrs[e].sections[s_cnt].columns[6].header = "{B}{U}Reg Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[6].x_pos = 380
   SET work->encntrs[e].sections[s_cnt].columns[7].header = "{B}{U}Disch Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[7].x_pos = 452
   SET work->encntrs[e].sections[s_cnt].columns[8].header = "{B}{U}Providers{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[8].x_pos = 524
   SET work->encntrs[e].sections[s_cnt].columns[9].header = "{B}{U}Allergies{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[9].x_pos = 650
   SET l_cnt = 1
   SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
   SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[1].text = work->encntrs[e].patient_name
   SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[2].text = work->encntrs[e].mrn
   SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[3].text = work->encntrs[e].fin
   SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[4].text = concat(format(work->encntrs[e]
     .birth_dt_tm,"MM/DD/YYYY;;D")," (",trim(replace(cnvtage(work->encntrs[e].birth_dt_tm),
      "0123456789","0123456789",3),3),")")
   IF (maxval(work->encntrs[e].eh_cnt,work->encntrs[e].r_cnt,work->encntrs[e].a_cnt) > l_cnt)
    SET l_cnt = maxval(work->encntrs[e].eh_cnt,work->encntrs[e].r_cnt,work->encntrs[e].a_cnt)
    IF (l_cnt > 1)
     SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
     SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
     FOR (l = 2 TO l_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
     ENDFOR
    ENDIF
   ENDIF
   IF ((work->encntrs[e].eh_cnt <= 0))
    SET work->encntrs[e].sections[s_cnt].lines[1].columns[5].text = "{B}Non-ED Patient{ENDB}"
   ELSE
    FOR (eh = 1 TO work->encntrs[e].eh_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[eh].columns[5].text = substring(1,13,work->encntrs[e
       ].enc_hist[eh].nurse_unit)
      IF (eh=1)
       SET work->encntrs[e].sections[s_cnt].lines[eh].columns[6].text = format(work->encntrs[e].
        admit_dt_tm,"MM/DD/YYYY HH:MM;;D")
      ELSE
       SET work->encntrs[e].sections[s_cnt].lines[eh].columns[6].text = format(work->encntrs[e].
        enc_hist[eh].trans_dt_tm,"MM/DD/YYYY HH:MM;;D")
      ENDIF
      IF ((eh=work->encntrs[e].eh_cnt))
       IF ((work->encntrs[e].disch_ind=1))
        SET work->encntrs[e].sections[s_cnt].lines[eh].columns[7].text = format(work->encntrs[e].
         disch_dt_tm,"MM/DD/YYYY HH:MM;;D")
       ELSEIF ((work->encntrs[e].disch_ind=2))
        SET work->encntrs[e].sections[s_cnt].lines[eh].columns[7].text = "Current Location"
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("2")
   IF ((work->encntrs[e].r_cnt > 0))
    FOR (r = 1 TO work->encntrs[e].r_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[r].columns[8].text = work->encntrs[e].reltns[r].
      prsnl_name
    ENDFOR
   ENDIF
   CALL echo("3")
   IF ((work->encntrs[e].a_cnt > 0))
    FOR (a = 1 TO work->encntrs[e].a_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[a].columns[9].text = work->encntrs[e].allergies[a].
      substance
    ENDFOR
   ENDIF
   CALL echo("4")
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "VITALS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 7
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}Temp{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 90
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Pulse{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 126
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}Resp Rate{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 162
   SET work->encntrs[e].sections[s_cnt].columns[5].header = "{B}{U}BP{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = 216
   SET work->encntrs[e].sections[s_cnt].columns[6].header = "{B}{U}O2 Sat (Mode){ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[6].x_pos = 252
   SET work->encntrs[e].sections[s_cnt].columns[7].header = "{B}{U}Weight{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[7].x_pos = 342
   CALL echo("5")
   IF ((work->encntrs[e].v_cnt > 0))
    SET work->encntrs[e].sections[s_cnt].l_cnt = work->encntrs[e].v_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,work->encntrs[e].v_cnt)
    FOR (v = 1 TO work->encntrs[e].v_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[v].c_cnt = c_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[v].columns,c_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[v].columns[1].text = format(work->encntrs[e].vitals[
       v].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")
      FOR (r = 1 TO work->encntrs[e].vitals[v].r_cnt)
        IF ((work->encntrs[e].vitals[v].results[r].type="Temp"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[2].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Pulse"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[3].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Respiratory Rate"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[4].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Systolic BP"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[5].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(work->encntrs[e].
           vitals[v].results[r].value,"/x")
         ELSE
          IF (substring(1,2,work->encntrs[e].sections[s_cnt].lines[v].columns[5].text)="x/")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(work->encntrs[e].
            vitals[v].results[r].value,substring(2,(size(work->encntrs[e].sections[s_cnt].lines[v].
              columns[5].text) - 1),work->encntrs[e].sections[s_cnt].lines[v].columns[5].text))
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Diastolic BP"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[5].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat("x/",work->encntrs[e
           ].vitals[v].results[r].value)
         ELSE
          IF (substring((size(work->encntrs[e].sections[s_cnt].lines[v].columns[5].text) - 1),2,work
           ->encntrs[e].sections[s_cnt].lines[v].columns[5].text)="/x")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(substring(1,(size(
              work->encntrs[e].sections[s_cnt].lines[v].columns[5].text) - 1),work->encntrs[e].
             sections[s_cnt].lines[v].columns[5].text),work->encntrs[e].vitals[v].results[r].value)
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="O2 Sat"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[6].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(work->encntrs[e].
           vitals[v].results[r].value," (x)")
         ELSE
          IF (substring(1,1,work->encntrs[e].sections[s_cnt].lines[v].columns[6].text)="x")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(work->encntrs[e].
            vitals[v].results[r].value,substring(2,(size(work->encntrs[e].sections[s_cnt].lines[v].
              columns[6].text) - 1),work->encntrs[e].sections[s_cnt].lines[v].columns[6].text))
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Mode of Delivery"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[6].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat("x (",work->encntrs[
           e].vitals[v].results[r].value,")")
         ELSE
          IF (substring((size(work->encntrs[e].sections[s_cnt].lines[v].columns[6].text) - 2),3,work
           ->encntrs[e].sections[s_cnt].lines[v].columns[6].text)="(x)")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(substring(1,(size(
              work->encntrs[e].sections[s_cnt].lines[v].columns[6].text) - 2),work->encntrs[e].
             sections[s_cnt].lines[v].columns[6].text),work->encntrs[e].vitals[v].results[r].value,
            ")")
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Weight"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[7].text = work->encntrs[e].vitals[v].
         results[r].value
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "ADMT_TRANS_DISCH"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header =
   "{B}{U}Admit/Transfer/Discharge Orders{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET l_cnt = 0
   SET event_disp_len = 23
   FREE RECORD tmp
   RECORD tmp(
     1 grp[*]
       2 num = i4
   )
   SET stat = alterlist(tmp->grp,1)
   SET tmp->grp[1].num = ord_grp_adm_disch
   FOR (og = 1 TO size(tmp->grp,5))
     SET tmp_c = 0
     CALL echo("12")
     IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt > 0))
      SET l_cnt += 1
      SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
      FOR (o = 1 TO work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt)
        IF (tmp_c < c_cnt)
         SET tmp_c += 1
        ELSE
         SET tmp_c = 1
         SET l_cnt += 1
        ENDIF
        IF (tmp_c=1)
         SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
         SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
         SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
        ENDIF
        IF (size(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp) >= event_disp_len)
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
           encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
          substring(1,(event_disp_len - 3),work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp
           ),"...  ",substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status
           ))
        ELSE
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
           encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
          substring(1,event_disp_len,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp),"  ",
          substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status))
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FREE RECORD tmp
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "ORDERSGRP1"
   SET work->encntrs[e].sections[s_cnt].type = 2
   SET c_cnt = 5
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Med Orders{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}IV Fluids{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 168
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Oxygen{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 318
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}Other Orders{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 468
   SET l_cnt = 0
   SET tmp_c = 0
   FREE RECORD tmp
   RECORD tmp(
     1 grp[*]
       2 num = i4
   )
   SET stat = alterlist(tmp->grp,4)
   SET tmp->grp[1].num = ord_grp_meds
   SET tmp->grp[2].num = ord_grp_iv
   SET tmp->grp[3].num = ord_grp_oxygen
   SET tmp->grp[4].num = ord_grp_other
   FOR (og = 1 TO size(tmp->grp,5))
    IF ((tmp->grp[og].num=ord_grp_meds))
     SET tmp_c = 1
    ELSEIF ((tmp->grp[og].num=ord_grp_iv))
     SET tmp_c = 2
    ELSEIF ((tmp->grp[og].num=ord_grp_oxygen))
     SET tmp_c = 3
    ELSEIF ((tmp->grp[og].num=ord_grp_other))
     SET tmp_c = 4
    ENDIF
    FOR (o = 1 TO work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt)
      IF ((tmp->grp[og].num IN (ord_grp_meds, ord_grp_iv)))
       IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Discontinued"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("DC ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Completed"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("C  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].doc_ind != 1))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("*  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSE
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("S  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ENDIF
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,5)
      ELSEIF ((tmp->grp[og].num=ord_grp_other))
       IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Completed"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("C  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Discontinued"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("DC ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSE
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("   ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ENDIF
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,5)
      ELSE
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,2)
      ENDIF
      IF (((work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line+ wrap_return->l_cnt) > l_cnt))
       SET l_cnt = (work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line+ wrap_return->l_cnt)
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
       FOR (l = work->encntrs[e].sections[s_cnt].l_cnt TO l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
       ENDFOR
       SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      ENDIF
      FOR (l = 1 TO wrap_return->l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[(l+ work->encntrs[e].sections[s_cnt].columns[tmp_c
        ].last_line)].columns[tmp_c].text = wrap_return->lines[l].text
      ENDFOR
      SET work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line += wrap_return->l_cnt
    ENDFOR
   ENDFOR
   FREE RECORD tmp
   CALL echo("7")
   SET tmp_c = 0
   SET col_width = 150
   IF (maxval(work->encntrs[e].sections[s_cnt].columns[1].last_line,work->encntrs[e].sections[s_cnt].
    columns[2].last_line,work->encntrs[e].sections[s_cnt].columns[3].last_line,work->encntrs[e].
    sections[s_cnt].columns[4].last_line) > 1)
    FOR (c = 1 TO 4)
      IF (tmp_c=0
       AND (work->encntrs[e].sections[s_cnt].columns[c].last_line=maxval(work->encntrs[e].sections[
       s_cnt].columns[1].last_line,work->encntrs[e].sections[s_cnt].columns[2].last_line,work->
       encntrs[e].sections[s_cnt].columns[3].last_line,work->encntrs[e].sections[s_cnt].columns[4].
       last_line)))
       SET tmp_c = c
      ENDIF
    ENDFOR
    IF (tmp_c > 0)
     IF (mod(l_cnt,2)=0)
      SET tmp_l = (cnvtint((l_cnt/ 2))+ 1)
     ELSE
      SET tmp_l = (cnvtint((l_cnt/ 2))+ 2)
     ENDIF
     FOR (c = 1 TO 4)
       IF (c != tmp_c
        AND (tmp_l < work->encntrs[e].sections[s_cnt].columns[c].last_line))
        SET tmp_l = (work->encntrs[e].sections[s_cnt].columns[c].last_line+ 1)
       ENDIF
     ENDFOR
     CALL echo(build("TMP_L:",tmp_l))
     CALL echo(build("L_CNT:",l_cnt))
     CALL echo(build("***",work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text))
     CALL echo(build("size:",textlen(work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].
        text)))
     SET temp_l1 = tmp_l
     WHILE (temp_l1 < l_cnt)
      IF (substring(1,1,work->encntrs[e].sections[s_cnt].lines[temp_l1].columns[tmp_c].text)=" ")
       SET temp_l1 += 1
      ELSE
       SET tmp_l = temp_l1
       SET temp_l1 = l_cnt
      ENDIF
      CALL echo(build("while tmp_l:",tmp_l,"while temp_l1:",temp_l1))
     ENDWHILE
     CALL echo(build("tmp_l:",tmp_l))
     IF (tmp_l <= l_cnt)
      IF (substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text) != " ")
       SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = (work->encntrs[e].sections[s_cnt].
       columns[tmp_c].x_pos+ col_width)
       FOR (c = (tmp_c+ 1) TO 4)
         SET work->encntrs[e].sections[s_cnt].columns[c].x_pos += col_width
       ENDFOR
       FOR (l = tmp_l TO l_cnt)
         SET work->encntrs[e].sections[s_cnt].lines[((l - tmp_l)+ 1)].columns[5].text = work->
         encntrs[e].sections[s_cnt].lines[l].columns[tmp_c].text
       ENDFOR
       SET l_cnt = (tmp_l - 1)
       SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
       SET work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line = l_cnt
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("8")
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "LABRESULTS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Laboratory Results{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   IF ((work->encntrs[e].total_r_cnt > 0))
    SET l_cnt = 0
    IF (mod((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].total_r_cnt),c_cnt)
     > 0)
     SET l_cnt = (cnvtint(((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].
      total_r_cnt)/ c_cnt))+ 1)
    ELSE
     SET l_cnt = cnvtint(((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].
      total_r_cnt)/ c_cnt))
    ENDIF
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    FOR (l = 1 TO l_cnt)
     SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
     SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
    ENDFOR
    SET tmp_l = 0
    SET tmp_c = 1
    SET event_disp_len = 18
    FOR (l = 1 TO work->encntrs[e].l_cnt)
      IF ((work->encntrs[e].labs[l].r_cnt > 0))
       IF (tmp_l < l_cnt)
        SET tmp_l += 1
       ELSE
        SET tmp_l = 1
        SET tmp_c += 1
       ENDIF
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = concat("{U}",work->
        encntrs[e].labs[l].desc,"{ENDU}")
       FOR (r = 1 TO work->encntrs[e].labs[l].r_cnt)
         IF (tmp_l < l_cnt)
          SET tmp_l += 1
         ELSE
          SET tmp_l = 1
          SET tmp_c += 1
         ENDIF
         IF (size(work->encntrs[e].labs[l].results[r].desc) > event_disp_len)
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work
            ->encntrs[e].labs[l].results[r].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",substring(1,(
            event_disp_len - 3),work->encntrs[e].labs[l].results[r].desc),"...  ",work->encntrs[e].
           labs[l].results[r].value,
           " ",work->encntrs[e].labs[l].results[r].units," ")
         ELSE
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work
            ->encntrs[e].labs[l].results[r].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",substring(1,
            event_disp_len,work->encntrs[e].labs[l].results[r].desc),"  ",work->encntrs[e].labs[l].
           results[r].value,
           " ",work->encntrs[e].labs[l].results[r].units," ")
         ENDIF
         IF ((work->encntrs[e].labs[l].results[r].mod_ind=1))
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(work->
           encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text," (m)")
         ENDIF
         IF (size(work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text) > 60)
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(substring(1,
            57,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text),"...")
         ENDIF
         IF ((work->encntrs[e].labs[l].results[r].normalcy > " "))
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2("{B}",work->
           encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text," ",work->encntrs[e].labs[l].
           results[r].normalcy,"{ENDB}")
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("10")
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "PENDINGLABS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Pending Labs{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET event_disp_len = 23
   IF ((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt > 0))
    SET l_cnt = 0
    IF (mod(work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt,c_cnt) > 0)
     SET l_cnt = (cnvtint((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt/ c_cnt))+ 1)
    ELSE
     SET l_cnt = cnvtint((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt/ c_cnt))
    ENDIF
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    SET tmp_l = 0
    SET tmp_c = 1
    FOR (o = 1 TO work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt)
      IF (tmp_l < l_cnt)
       SET tmp_l += 1
      ELSE
       SET tmp_l = 1
       SET tmp_c += 1
      ENDIF
      IF (tmp_c=1)
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].c_cnt = c_cnt
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[tmp_l].columns,c_cnt)
      ENDIF
      IF (size(work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp) >= event_disp_len)
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work->
         encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
        substring(1,(event_disp_len - 3),work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp),
        "...  ",substring(1,13,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].dept_status))
      ELSE
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work->
         encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
        substring(1,event_disp_len,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp),"  ",
        substring(1,13,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].dept_status))
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("11")
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "ORDERSGRP2"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header =
   "{B}{U}All Other Ancillary Orders (Radiology, Micro, ECG, Blood Bank, etc.){ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET l_cnt = 0
   SET event_disp_len = 23
   FREE RECORD tmp
   RECORD tmp(
     1 grp[*]
       2 num = i4
   )
   SET stat = alterlist(tmp->grp,7)
   SET tmp->grp[1].num = ord_grp_rad
   SET tmp->grp[2].num = ord_grp_micro
   SET tmp->grp[3].num = ord_grp_ecg
   SET tmp->grp[4].num = ord_grp_blood
   SET tmp->grp[5].num = ord_grp_neuro
   SET tmp->grp[6].num = ord_grp_pulm
   SET tmp->grp[7].num = ord_grp_card
   FOR (og = 1 TO size(tmp->grp,5))
     SET tmp_c = 0
     CALL echo("12")
     IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt > 0))
      SET l_cnt += 1
      SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
      FOR (o = 1 TO work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt)
        IF (tmp_c < c_cnt)
         SET tmp_c += 1
        ELSE
         SET tmp_c = 1
         SET l_cnt += 1
        ENDIF
        IF (tmp_c=1)
         SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
         SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
         SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
        ENDIF
        IF (size(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp) >= event_disp_len)
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
           encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
          substring(1,(event_disp_len - 3),work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp
           ),"...  ",substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status
           ))
        ELSE
         SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
           encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
          substring(1,event_disp_len,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp),"  ",
          substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status))
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FREE RECORD tmp
   CALL echo("13")
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "SCRIPTS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Prescriptions Written{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET l_cnt = 0
   IF ((work->encntrs[e].ord_grps[ord_grp_scripts].o_cnt > 0))
    FOR (o = 1 TO work->encntrs[e].ord_grps[ord_grp_scripts].o_cnt)
      CALL rw_wrap(work->encntrs[e].ord_grps[ord_grp_scripts].orders[o].disp,55,2)
      IF (((work->encntrs[e].sections[s_cnt].columns[1].last_line+ wrap_return->l_cnt) > l_cnt))
       SET l_cnt = (work->encntrs[e].sections[s_cnt].columns[1].last_line+ wrap_return->l_cnt)
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
       FOR (l = work->encntrs[e].sections[s_cnt].l_cnt TO l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
       ENDFOR
       SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      ENDIF
      FOR (l = 1 TO wrap_return->l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[(l+ work->encntrs[e].sections[s_cnt].columns[1].
        last_line)].columns[1].text = wrap_return->lines[l].text
      ENDFOR
      SET work->encntrs[e].sections[s_cnt].columns[1].last_line += wrap_return->l_cnt
    ENDFOR
    FOR (c = 1 TO (c_cnt - 1))
      SET tmp_l = 0
      SET work->encntrs[e].sections[s_cnt].columns[c].last_line = l_cnt
      IF (l_cnt > 1)
       IF (mod(l_cnt,((c_cnt - c)+ 1))=0)
        SET tmp_l = (cnvtint((l_cnt/ ((c_cnt - c)+ 1)))+ 1)
       ELSE
        SET tmp_l = (cnvtint((l_cnt/ ((c_cnt - c)+ 1)))+ 2)
       ENDIF
       WHILE (substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[c].text)=" "
        AND tmp_l < l_cnt)
         SET tmp_l += 1
       ENDWHILE
       IF (tmp_l <= l_cnt
        AND substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[c].text) != " ")
        FOR (l = tmp_l TO l_cnt)
         SET work->encntrs[e].sections[s_cnt].lines[((l - tmp_l)+ 1)].columns[(c+ 1)].text = work->
         encntrs[e].sections[s_cnt].lines[l].columns[c].text
         SET work->encntrs[e].sections[s_cnt].lines[l].columns[c].text = ""
        ENDFOR
        SET work->encntrs[e].sections[s_cnt].columns[c].last_line = (tmp_l - 1)
        SET l_cnt = ((l_cnt - tmp_l)+ 1)
       ENDIF
      ENDIF
    ENDFOR
    SET l_cnt = maxval(work->encntrs[e].sections[s_cnt].columns[1].last_line,work->encntrs[e].
     sections[s_cnt].columns[2].last_line,work->encntrs[e].sections[s_cnt].columns[3].last_line)
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
   ENDIF
 ENDFOR
 FREE SET s_cnt
 FREE SET l_cnt
 FREE SET c_cnt
 FREE SET tmp_l
 FREE SET tmp_c
 CALL echo("15")
 SELECT INTO value(var_output)
  FROM dummyt d
  HEAD REPORT
   tmp_x = 0, tmp_y = 0, rotate_ind = 0,
   new_rpt = 0, tmp_pg_cnt = 0, col 0,
   "{F/0}{CPI/18}{LPI/9}{PS/792 0 translate 90 rotate/}", row + 1
  HEAD PAGE
   IF (rotate_ind=1)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   tmp_y = 8, col 0,
   CALL print(build2(calcpos(18,tmp_y),"{B}ED Orders/Results Summary (ORS) Report{ENDB}")),
   row + 1, tmp_y += 8
   IF ((e <= work->e_cnt))
    col 0,
    CALL print(build2(calcpos(504,8),"{B}All Orders/Results from ",format(work->encntrs[e].
      create_dt_tm,"MM/DD/YYYY HH:MM;;D")," to ",format(work->encntrs[e].disch_dt_tm,
      "MM/DD/YYYY HH:MM;;D"),
     "{ENDB}")), row + 1
   ENDIF
   IF (new_rpt=0
    AND (e <= work->e_cnt))
    FOR (tmp_s = 1 TO work->encntrs[e].s_cnt)
      IF ((work->encntrs[e].sections[tmp_s].desc="PATDATA"))
       tmp_y += 8
       FOR (tmp_c = 1 TO work->encntrs[e].sections[tmp_s].c_cnt)
         IF ((work->encntrs[e].sections[tmp_s].columns[tmp_c].header > " "))
          tmp_x = work->encntrs[e].sections[tmp_s].columns[tmp_c].x_pos, col 0,
          CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[tmp_s].columns[tmp_c].
           header)),
          row + 1
         ENDIF
       ENDFOR
       tmp_y += 8
       FOR (tmp_l = 1 TO work->encntrs[e].sections[tmp_s].l_cnt)
        FOR (tmp_c = 1 TO work->encntrs[e].sections[tmp_s].c_cnt)
          IF ((work->encntrs[e].sections[tmp_s].lines[tmp_l].columns[tmp_c].text > " "))
           tmp_x = work->encntrs[e].sections[tmp_s].columns[tmp_c].x_pos, col 0,
           CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[tmp_s].lines[tmp_l].
            columns[tmp_c].text)),
           row + 1
          ENDIF
        ENDFOR
        ,tmp_y += 8
       ENDFOR
      ENDIF
    ENDFOR
    tmp_y += 8
   ENDIF
   rotate_ind = 1
  DETAIL
   FOR (e = 1 TO work->e_cnt)
     IF (e > 1)
      BREAK, new_rpt = 0
     ENDIF
     tmp_pg_cnt = 0, col 0,
     CALL print(build2(calcpos(504,8),"{B}All Orders/Results from ",format(work->encntrs[e].
       create_dt_tm,"MM/DD/YYYY HH:MM;;D")," to ",format(work->encntrs[e].disch_dt_tm,
       "MM/DD/YYYY HH:MM;;D"),
      "{ENDB}")),
     row + 1
     FOR (s = 1 TO work->encntrs[e].s_cnt)
       IF (tmp_y < 526)
        tmp_y += 8
       ELSE
        BREAK
       ENDIF
       FOR (c = 1 TO work->encntrs[e].sections[s].c_cnt)
         IF ((work->encntrs[e].sections[s].columns[c].header > " "))
          tmp_x = work->encntrs[e].sections[s].columns[c].x_pos, col 0,
          CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].columns[c].header)),
          row + 1
         ENDIF
       ENDFOR
       IF (tmp_y < 534)
        tmp_y += 8
       ELSE
        BREAK
       ENDIF
       FOR (l = 1 TO work->encntrs[e].sections[s].l_cnt)
        FOR (c = 1 TO work->encntrs[e].sections[s].c_cnt)
          IF ((work->encntrs[e].sections[s].lines[l].columns[c].text > " "))
           tmp_x = work->encntrs[e].sections[s].columns[c].x_pos, col 0,
           CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].lines[l].columns[c].
            text)),
           row + 1
          ENDIF
        ENDFOR
        ,
        IF (tmp_y < 534)
         tmp_y += 8
        ELSE
         BREAK
         FOR (c2 = 1 TO work->encntrs[e].sections[s].c_cnt)
           IF ((work->encntrs[e].sections[s].columns[c2].header > " "))
            tmp_x = work->encntrs[e].sections[s].columns[c2].x_pos, col 0,
            CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].columns[c2].header)),
            row + 1
           ENDIF
         ENDFOR
         tmp_y += 8
        ENDIF
       ENDFOR
     ENDFOR
     new_rpt = 1
   ENDFOR
  FOOT PAGE
   tmp_pg_cnt += 1, col 0,
   CALL print(build2(calcpos(18,552),'{B}Legend:{ENDB}  "*" = Med/IV not charted  "S" = Med/IV ',
    'series started  "C" = Completed  "DC" = Discontinued')),
   row + 1, col 0,
   CALL print(build2(calcpos(18,566),
    " {B}*** Report may not include all Downtime/Written Orders/Results ***{ENDB}")),
   row + 1, col 0,
   CALL print(build2(calcpos(605,566),"{B}Printed On ",format(cnvtdatetime(sysdate),
     "MM/DD/YYYY HH:MM;;D"),"{ENDB}")),
   row + 1
   IF (new_rpt=1)
    col 0,
    CALL print(build2(calcpos(368,566)," {B}END OF REPORT (Page ",trim(cnvtstring(tmp_pg_cnt),3),
     "){ENDB}"))
   ELSE
    col 0,
    CALL print(build2(calcpos(380,566)," {B}Page ",trim(cnvtstring(tmp_pg_cnt),3),"{ENDB}")), row + 1
   ENDIF
  WITH nocounter, maxcol = 1000, maxrow = 10000,
   format = variable, dio = 08
 ;end select
 IF (discern_rule_ind=1)
  SET retval = 100
  SET log_message = build2(trim(log_message,3)," Report printed successfully")
  CALL echo(build2("LOG_MESSAGE: ",log_message))
 ENDIF
 CALL echorecord(work,"ryan_ors_report.rs")
 SUBROUTINE (rw_wrap(orig_str=vc,line_len=i4,indent_size=i4) =null)
   FREE SET temp_str
   FREE SET beg_pos
   FREE SET end_pos
   FREE RECORD wrap_return
   SET temp_str = trim(orig_str,1)
   SET beg_pos = 1
   SET end_pos = 0
   RECORD wrap_return(
     1 l_cnt = i4
     1 lines[*]
       2 text = vc
   ) WITH persist
   WHILE (beg_pos > 0
    AND beg_pos <= size(temp_str))
     IF (findstring(char(10),substring(beg_pos,line_len,temp_str),1,0) > 0)
      SET end_pos = findstring(char(10),substring(beg_pos,line_len,temp_str),1,0)
     ELSEIF (substring((beg_pos+ line_len),1,temp_str)=" ")
      SET end_pos = (line_len+ 1)
     ELSEIF (findstring(" ",substring(beg_pos,line_len,temp_str),1,1)=0)
      SET end_pos = line_len
     ELSE
      SET end_pos = findstring(" ",substring(beg_pos,line_len,temp_str),1,1)
     ENDIF
     SET wrap_return->l_cnt += 1
     SET stat = alterlist(wrap_return->lines,wrap_return->l_cnt)
     IF (beg_pos=1)
      SET wrap_return->lines[wrap_return->l_cnt].text = trim(substring(beg_pos,end_pos,temp_str))
      SET line_len -= indent_size
     ELSE
      SET wrap_return->lines[wrap_return->l_cnt].text = build2(fillstring(value(indent_size)," "),
       trim(substring(beg_pos,end_pos,temp_str)))
     ENDIF
     SET beg_pos += end_pos
   ENDWHILE
 END ;Subroutine
#exit_script
 FREE RECORD wrap_return
 FREE RECORD work
 FREE SET cs220_er_group_cd
 FREE SET cs319_mrn_cd
 FREE SET cs319_fin_cd
 FREE SET cs333_attenddoc_cd
 FREE SET cs333_associate_cd
 FREE SET cs333_physician_cd
 FREE SET cs333_pa_cd
 FREE SET cs333_resident_cd
 FREE SET cs12025_canceled_cd
 FREE SET cs72_temp_cd
 FREE SET cs72_pulse_cd
 FREE SET cs72_resp_rate_cd
 FREE SET cs72_systolic_bp_cd
 FREE SET cs72_diastolic_bp_cd
 FREE SET cs72_o2_sat_cd
END GO
