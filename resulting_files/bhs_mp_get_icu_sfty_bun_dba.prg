CREATE PROGRAM bhs_mp_get_icu_sfty_bun:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_data
 RECORD m_data(
   1 pat[*]
     2 l_print_order = i4
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_sex_cd = f8
     2 s_name_full = vc
     2 s_fin_nbr = vc
     2 f_height_in = f8
     2 f_height_cm = f8
     2 f_ibw_kg = f8
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_room_bed = vc
     2 s_icu_beg_dt_tm = vc
     2 f_icu_days = f8
     2 n_sed_vac = i2
     2 n_oral_swab = i2
     2 n_rdy_wean = i2
     2 n_stress_ulcer = i2
     2 n_dvt = i2
     2 n_sedation = i2
     2 n_pain_control = i2
     2 n_nm_block = i2
     2 n_tidal_vol = i2
     2 f_tidal_val = f8
     2 s_tidal_units = vc
     2 f_vt_ibw = f8
     2 l_f_vt = i4
     2 f_resp_rt = f8
     2 s_resp_rt_units = vc
     2 n_eol_addr = i2
     2 n_glu_cnt = i2
     2 l_glu_min = i4
     2 l_glu_max = i4
     2 f_glu_per = f8
     2 n_nutrition = i2
     2 s_vent_mode = vc
     2 n_score = i2
     2 n_hob_90_per = i2
     2 hob[*]
       3 n_hob_30 = i2
       3 s_hob_val = vc
 )
 FREE RECORD m_info
 RECORD m_info(
   1 recs[*]
     2 s_display = vc
     2 s_value = vc
     2 s_font_color = vc
 )
 DECLARE mf_encntr_id = f8 WITH protect, constant( $F_ENCNTR_ID)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FIN NBR"))
 DECLARE mf_icu_a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUA"))
 DECLARE mf_icu_b_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUB"))
 DECLARE mf_icu_c_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUC"))
 DECLARE mf_cvcu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"CVCU"))
 DECLARE mf_pcu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"PCU"))
 DECLARE mf_hvcc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"HVCC"))
 DECLARE mf_sicu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"SICU"))
 DECLARE mf_niu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NIU"))
 DECLARE mf_d5a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"D5A"))
 DECLARE mf_micu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MICU"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_sed_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SEDATIONVACATION"
   ))
 DECLARE mf_oral_swab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHLORHEXIDINETOPICAL"))
 DECLARE mf_rdy_wean_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"READINESSTOWEAN"
   ))
 DECLARE mf_hob_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"VAPPRECAUTIONS"))
 DECLARE mf_tidal_vol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIDALVOLUMEDELIVERED"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_resp_rt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE")
  )
 DECLARE mf_glu_poc1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"Glucose (POC)"))
 DECLARE mf_glu_poc2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"Glucose, POC"))
 DECLARE mf_glu_level_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE mf_tube_cont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TUBEFEEDINGCONTINUOUS"))
 DECLARE mf_ent_feed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ENTERALFEEDINGS"
   ))
 DECLARE mf_tube_feed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENTERALTUBEFEEDINGS"))
 DECLARE mf_nutrn_int_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUTRITIONINTERVENTIONS"))
 DECLARE mf_tpn_1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA55D14L3ACETLYTES"))
 DECLARE mf_tpn_2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA55D14L3STANDLYTES"))
 DECLARE mf_tpn_3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D15"))
 DECLARE mf_tpn_4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D18L3ACETLYTES"))
 DECLARE mf_tpn_5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D18L3STANDLYTES"))
 DECLARE mf_tpn_6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALCUSTOM"))
 DECLARE mf_vent_mode_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"VENTILATORMODE"
   ))
 DECLARE mf_wean_indx = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WEANINGRAPIDSHALLOWBREATHINGINDEX"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mf_dfr_id = f8 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 CALL echo("get BMC facility cd")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key="BMC"
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  DETAIL
   mf_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo("get patient/encntr info")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ed.loc_facility_cd=mf_facility_cd
    AND ed.loc_nurse_unit_cd IN (mf_icu_a_cd, mf_icu_b_cd, mf_icu_c_cd, mf_cvcu_cd, mf_pcu_cd,
   mf_hvcc_cd, mf_sicu_cd, mf_niu_cd, mf_d5a_cd, mf_micu_cd)
    AND ed.active_ind=1
    AND ed.encntr_id=mf_encntr_id)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd=ed.loc_nurse_unit_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY ed.loc_nurse_unit_cd, p.name_last_key
  HEAD REPORT
   pl_cnt = 0
  HEAD elh.encntr_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_data->pat,5))
    stat = alterlist(m_data->pat,(pl_cnt+ 10))
   ENDIF
   m_data->pat[pl_cnt].f_encntr_id = e.encntr_id, m_data->pat[pl_cnt].f_person_id = p.person_id,
   m_data->pat[pl_cnt].s_name_full = trim(p.name_full_formatted),
   m_data->pat[pl_cnt].f_sex_cd = p.sex_cd, m_data->pat[pl_cnt].s_nurse_unit = trim(
    uar_get_code_display(ed.loc_nurse_unit_cd)), m_data->pat[pl_cnt].s_room = trim(
    uar_get_code_display(ed.loc_room_cd)),
   m_data->pat[pl_cnt].s_bed = trim(uar_get_code_display(ed.loc_bed_cd)), m_data->pat[pl_cnt].
   s_room_bed = trim(concat(m_data->pat[pl_cnt].s_room,m_data->pat[pl_cnt].s_bed)), ms_tmp = ""
   FOR (pn_loop_cnt = 1 TO textlen(m_data->pat[pl_cnt].s_room_bed))
     IF (isnumeric(substring(pn_loop_cnt,1,m_data->pat[pl_cnt].s_room_bed)) > 0)
      ms_tmp = concat(ms_tmp,substring(pn_loop_cnt,1,m_data->pat[pl_cnt].s_room_bed))
     ENDIF
   ENDFOR
   m_data->pat[pl_cnt].s_room_bed = trim(ms_tmp,3), m_data->pat[pl_cnt].s_icu_beg_dt_tm = trim(format
    (elh.beg_effective_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_data->pat[pl_cnt].f_icu_days = datetimediff(
    sysdate,elh.beg_effective_dt_tm)
  FOOT REPORT
   stat = alterlist(m_data->pat,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL echo(build2("no encounter info found: ",mf_encntr_id))
  GO TO exit_script
 ENDIF
 CALL echo("get clinical events")
 SELECT INTO "nl:"
  e.encntr_id, ce.result_val
  FROM (dummyt d  WITH seq = value(size(m_data->pat,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=m_data->pat[d.seq].f_encntr_id)
    AND (ce.person_id=m_data->pat[d.seq].f_person_id)
    AND ce.event_cd IN (mf_sed_vac_cd, mf_oral_swab_cd, mf_rdy_wean_cd, mf_hob_cd, mf_tidal_vol_cd,
   mf_height_cd, mf_resp_rt_cd, mf_glu_poc1_cd, mf_glu_poc2_cd, mf_glu_level_cd,
   mf_tube_cont_cd, mf_ent_feed_cd, mf_tube_feed_cd, mf_nutrn_int_cd, mf_tpn_1_cd,
   mf_tpn_2_cd, mf_tpn_3_cd, mf_tpn_4_cd, mf_tpn_5_cd, mf_tpn_6_cd,
   mf_vent_mode_cd, mf_wean_indx)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd)
    AND ce.view_level=1)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD ce.encntr_id
   pl_hob_cnt = 0, pl_hob_30_cnt = 0, pl_glu_cnt = 0,
   pl_glu_good_cnt = 0
  DETAIL
   IF (ce.encntr_id=57018507
    AND ce.event_cd IN (mf_nutrn_int_cd, mf_tube_cont_cd))
    ms_tmp = uar_get_code_display(ce.event_cd),
    CALL echo(build2(m_data->pat[d.seq].s_name_full," encntr:",trim(cnvtstring(ce.encntr_id)),
     " event_cd:",trim(cnvtstring(ce.event_cd)),
     " event:",trim(ms_tmp)," result:",ce.result_val))
   ENDIF
   CASE (ce.event_cd)
    OF mf_sed_vac_cd:
     m_data->pat[d.seq].n_sed_vac = 1
    OF mf_oral_swab_cd:
     IF (ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      m_data->pat[d.seq].n_oral_swab = 1
     ENDIF
    OF mf_rdy_wean_cd:
     m_data->pat[d.seq].n_rdy_wean = 1
    OF mf_hob_cd:
     IF (ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_hob_cnt = (pl_hob_cnt+ 1)
      IF (pl_hob_cnt > size(m_data->pat[d.seq].hob,5))
       stat = alterlist(m_data->pat[d.seq].hob,(pl_hob_cnt+ 5))
      ENDIF
      m_data->pat[d.seq].hob[pl_hob_cnt].s_hob_val = trim(ce.result_val)
      IF (((findstring("HOB AT 80 DEGREES",cnvtupper(trim(ce.result_val))) > 0) OR (findstring(
       "HOB 30-45 DEGREES",cnvtupper(trim(ce.result_val))) > 0)) )
       m_data->pat[d.seq].hob[pl_hob_cnt].n_hob_30 = 1, pl_hob_30_cnt = (pl_hob_30_cnt+ 1)
      ENDIF
     ENDIF
    OF mf_tidal_vol_cd:
     m_data->pat[d.seq].n_tidal_vol = 1,m_data->pat[d.seq].f_tidal_val = cnvtreal(ce.result_val),
     m_data->pat[d.seq].s_tidal_units = trim(uar_get_code_display(ce.result_units_cd))
    OF mf_height_cd:
     IF (cnvtupper(trim(uar_get_code_display(ce.result_units_cd)))="CM")
      m_data->pat[d.seq].f_height_cm = cnvtreal(ce.result_val), m_data->pat[d.seq].f_height_in = (
      cnvtreal(ce.result_val) * 0.3937)
     ELSEIF (cnvtupper(trim(uar_get_code_display(ce.result_units_cd)))="IN")
      m_data->pat[d.seq].f_height_in = cnvtreal(ce.result_val), m_data->pat[d.seq].f_height_cm = (
      cnvtreal(ce.result_val) * 2.54)
     ENDIF
     ,
     IF ((m_data->pat[d.seq].f_sex_cd=mf_male_cd))
      m_data->pat[d.seq].f_ibw_kg = (50+ (2.3 * (m_data->pat[d.seq].f_height_in - 60)))
     ELSEIF ((m_data->pat[d.seq].f_sex_cd=mf_female_cd))
      m_data->pat[d.seq].f_ibw_kg = (45.5+ (2.3 * (m_data->pat[d.seq].f_height_in - 60)))
     ENDIF
    OF mf_resp_rt_cd:
     m_data->pat[d.seq].f_resp_rt = cnvtreal(ce.result_val),m_data->pat[d.seq].s_resp_rt_units = trim
     (uar_get_code_display(ce.result_units_cd))
    OF mf_glu_poc1_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_data->pat[d.seq].l_glu_max))
       m_data->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_data->pat[d.seq].l_glu_min)) OR ((m_data->pat[d.seq].
      l_glu_min=0))) )
       m_data->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_glu_poc2_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_data->pat[d.seq].l_glu_max))
       m_data->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_data->pat[d.seq].l_glu_min)) OR ((m_data->pat[d.seq].
      l_glu_min=0))) )
       m_data->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_glu_level_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_data->pat[d.seq].l_glu_max))
       m_data->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_data->pat[d.seq].l_glu_min)) OR ((m_data->pat[d.seq].
      l_glu_min=0))) )
       m_data->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_tube_cont_cd:
     IF ((m_data->pat[d.seq].n_nutrition=0))
      m_data->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_ent_feed_cd:
     IF ((m_data->pat[d.seq].n_nutrition=0))
      m_data->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_tube_feed_cd:
     IF ((m_data->pat[d.seq].n_nutrition=0))
      m_data->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_nutrn_int_cd:
     IF (findstring("OTHER: TPN",cnvtupper(ce.result_val),1) > 0)
      m_data->pat[d.seq].n_nutrition = 2
     ENDIF
    OF mf_tpn_1_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_tpn_2_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_tpn_3_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_tpn_4_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_tpn_5_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_tpn_6_cd:
     m_data->pat[d.seq].n_nutrition = 2
    OF mf_vent_mode_cd:
     m_data->pat[d.seq].s_vent_mode = trim(ce.result_val)
    OF mf_wean_indx:
     m_data->pat[d.seq].l_f_vt = cnvtint(ce.result_val)
   ENDCASE
  FOOT  ce.encntr_id
   stat = alterlist(m_data->pat[d.seq].hob,pl_hob_cnt), m_data->pat[d.seq].n_glu_cnt = pl_glu_cnt
   IF (pl_hob_30_cnt > 0)
    IF (((cnvtreal(pl_hob_30_cnt)/ cnvtreal(size(m_data->pat[d.seq].hob,5))) >= 0.90))
     m_data->pat[d.seq].n_hob_90_per = 1
    ENDIF
   ENDIF
   IF (pl_glu_good_cnt > 0)
    m_data->pat[d.seq].f_glu_per = ((cnvtreal(pl_glu_good_cnt)/ cnvtreal(pl_glu_cnt)) * 100)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_data->pat,5))),
   orders o,
   order_catalog oc
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_data->pat[d.seq].f_encntr_id)
    AND o.active_ind=1
    AND o.template_order_flag IN (0, 1))
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=o.catalog_cd
    AND ((cnvtupper(oc.primary_mnemonic) IN ("ESOMAPRAZOLE", "FAMOTIDINE", "PANTOPRAZOLE")) OR (((
   cnvtupper(oc.primary_mnemonic)="ARGATROBAN*") OR (((cnvtupper(oc.primary_mnemonic)="DESIRUDIN*")
    OR (((cnvtupper(oc.primary_mnemonic)="ENOXAPARIN*") OR (((cnvtupper(oc.primary_mnemonic)=
   "FONDAPARINUX*") OR (((cnvtupper(oc.primary_mnemonic)="HEPARIN*") OR (((cnvtupper(oc
    .primary_mnemonic)="WARFARIN*") OR (((cnvtupper(oc.primary_mnemonic)="ATIVAN*") OR (((cnvtupper(
    oc.primary_mnemonic)="DIAZEPAM*") OR (((cnvtupper(oc.primary_mnemonic)="LORAZEPAM*") OR (((
   cnvtupper(oc.primary_mnemonic)="MIDEZOLAM*") OR (((cnvtupper(oc.primary_mnemonic)="PROPOFOL*") OR
   (((cnvtupper(oc.primary_mnemonic)="VERSED*") OR (((cnvtupper(oc.primary_mnemonic)="FENTANYL*") OR
   (((cnvtupper(oc.primary_mnemonic)="HYDROMORPHONE*") OR (((cnvtupper(oc.primary_mnemonic)=
   "MORPHINE*") OR (((cnvtupper(oc.primary_mnemonic)="CISATRACURIUM*") OR (((cnvtupper(oc
    .primary_mnemonic)="PANCURONIUM*") OR (cnvtupper(oc.primary_mnemonic)="VECURONIUM*")) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  DETAIL
   CASE (cnvtupper(oc.primary_mnemonic))
    OF "ESOMAPRAZOLE":
     m_data->pat[d.seq].n_stress_ulcer = 1
    OF "FAMOTIDINE":
     m_data->pat[d.seq].n_stress_ulcer = 1
    OF "PANTOPRAZOLE":
     m_data->pat[d.seq].n_stress_ulcer = 1
    OF "ARGATROBAN*":
     m_data->pat[d.seq].n_dvt = 1
    OF "DESIRUDIN*":
     m_data->pat[d.seq].n_dvt = 1
    OF "ENOXAPARIN*":
     m_data->pat[d.seq].n_dvt = 1
    OF "FONDAPARINUX*":
     m_data->pat[d.seq].n_dvt = 1
    OF "HEPARIN*":
     m_data->pat[d.seq].n_dvt = 1
    OF "WARFARIN*":
     m_data->pat[d.seq].n_dvt = 1
    OF "ATIVAN*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "DIAZEPAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "LORAZEPAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "MIDEZOLAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "PROPOFOL*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "VERSED*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_data->pat[d.seq].n_sedation = 1
     ENDIF
    OF "FENTANYL*":
     m_data->pat[d.seq].n_pain_control = 1
    OF "HYDROMORPHONE*":
     m_data->pat[d.seq].n_pain_control = 1
    OF "MORPHINE*":
     m_data->pat[d.seq].n_pain_control = 1
    OF "CISATRACURIUM*":
     m_data->pat[d.seq].n_nm_block = 1
    OF "PANCURONIUM*":
     m_data->pat[d.seq].n_nm_block = 1
    OF "VECURONIUM*":
     m_data->pat[d.seq].n_nm_block = 1
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("check for EOL form")
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=1
   AND dfr.description="ICU Communication and Palliative Care"
  DETAIL
   mf_dfr_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfa.encntr_id
  FROM (dummyt d  WITH seq = value(size(m_data->pat,5))),
   dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (d)
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dfr_id
    AND dfa.active_ind=1
    AND (dfa.encntr_id=m_data->pat[d.seq].f_encntr_id)
    AND (dfa.person_id=m_data->pat[d.seq].f_person_id)
    AND dfa.form_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd, mf_active_cd, mf_final_cd))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.active_ind=1)
  HEAD dfa.encntr_id
   m_data->pat[d.seq].n_eol_addr = 1
  WITH nocounter
 ;end select
 CALL echo("calculate values")
 FOR (ml_loop_cnt = 1 TO size(m_data->pat,5))
   IF ((m_data->pat[ml_loop_cnt].f_ibw_kg > 0)
    AND (m_data->pat[ml_loop_cnt].f_tidal_val > 0))
    SET m_data->pat[ml_loop_cnt].f_vt_ibw = (m_data->pat[ml_loop_cnt].f_tidal_val/ m_data->pat[
    ml_loop_cnt].f_ibw_kg)
   ENDIF
   SET m_data->pat[ml_loop_cnt].n_score = 9
   IF ((m_data->pat[ml_loop_cnt].n_dvt=0))
    SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
   ENDIF
   IF ((m_data->pat[ml_loop_cnt].f_glu_per < 75))
    SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
   ENDIF
   IF (trim(m_data->pat[ml_loop_cnt].s_vent_mode) > " ")
    IF ((m_data->pat[ml_loop_cnt].l_f_vt <= 0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_data->pat[ml_loop_cnt].n_stress_ulcer=0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_data->pat[ml_loop_cnt].n_oral_swab=0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_data->pat[ml_loop_cnt].n_hob_90_per=0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_data->pat[ml_loop_cnt].n_sedation=1)
     AND (m_data->pat[ml_loop_cnt].n_sed_vac=0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_data->pat[ml_loop_cnt].n_nutrition=0))
     SET m_data->pat[ml_loop_cnt].n_score = (m_data->pat[ml_loop_cnt].n_score - 1)
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(m_info->recs,16)
 SET m_info->recs[1].s_display = "Vent"
 SET m_info->recs[1].s_value = m_data->pat[1].s_vent_mode
 SET m_info->recs[2].s_display = "f/Vt"
 SET m_info->recs[2].s_value = trim(cnvtstring(m_data->pat[1].l_f_vt))
 SET m_info->recs[3].s_display = "Vt/IBW"
 IF (trim(m_data->pat[1].s_vent_mode) > " ")
  SET m_info->recs[3].s_value = trim(cnvtstring(m_data->pat[1].f_vt_ibw))
 ENDIF
 SET m_info->recs[4].s_display = "Stress"
 IF (trim(m_data->pat[1].s_vent_mode) > " ")
  IF ((m_data->pat[1].n_stress_ulcer=1))
   SET m_info->recs[4].s_value = "Y"
  ELSE
   SET m_info->recs[4].s_value = "N"
  ENDIF
 ELSEIF ((m_data->pat[1].n_stress_ulcer=1))
  SET m_info->recs[4].s_value = "Y"
 ENDIF
 SET m_info->recs[5].s_display = "NM Block"
 IF (trim(m_data->pat[1].s_vent_mode) > " ")
  IF ((m_data->pat[1].n_nm_block=1))
   SET m_info->recs[5].s_value = "Y"
  ELSE
   SET m_info->recs[5].s_value = "N"
  ENDIF
 ELSEIF ((m_data->pat[1].n_nm_block=1))
  SET m_info->recs[5].s_value = "Y"
 ENDIF
 SET m_info->recs[6].s_display = "Oral"
 IF (trim(m_data->pat[1].s_vent_mode) > " ")
  IF ((m_data->pat[1].n_oral_swab=1))
   SET m_info->recs[6].s_value = "Y"
  ELSE
   SET m_info->recs[6].s_value = "N"
  ENDIF
 ELSEIF ((m_data->pat[1].n_oral_swab=1))
  SET m_info->recs[6].s_value = "Y"
 ENDIF
 SET m_info->recs[7].s_display = "HOB"
 IF ((m_data->pat[1].n_hob_90_per=1))
  SET m_info->recs[7].s_value = "Y"
 ELSE
  SET m_info->recs[7].s_value = "N"
 ENDIF
 SET m_info->recs[8].s_display = "DVT"
 IF ((m_data->pat[1].n_dvt=1))
  SET m_info->recs[8].s_value = "Y"
 ELSE
  SET m_info->recs[8].s_value = "N"
 ENDIF
 SET m_info->recs[9].s_display = "24hr Glu"
 IF ((m_data->pat[1].l_glu_min > 0)
  AND (m_data->pat[1].l_glu_max > 0))
  SET m_info->recs[9].s_value = concat(trim(cnvtstring(m_data->pat[1].l_glu_min)),"; ",trim(
    cnvtstring(m_data->pat[1].l_glu_max)))
 ELSEIF ((m_data->pat[1].l_glu_max > 0))
  SET m_info->recs[9].s_value = trim(cnvtstring(m_data->pat[1].l_glu_max))
 ELSE
  SET m_info->recs[9].s_value = "N/A"
 ENDIF
 SET m_info->recs[10].s_display = "Sedation"
 IF ((m_data->pat[1].n_sedation=1))
  SET m_info->recs[10].s_value = "Y"
 ELSE
  SET m_info->recs[10].s_value = "N"
 ENDIF
 SET m_info->recs[11].s_display = "% Glu"
 SET m_info->recs[11].s_value = trim(cnvtstring(m_data->pat[1].f_glu_per))
 IF (cnvtreal(m_info->recs[11].s_value) BETWEEN 50 AND 180)
  SET m_info->recs[11].s_font_color = "green"
 ELSE
  SET m_info->recs[11].s_font_color = "red"
 ENDIF
 SET m_info->recs[12].s_display = "Sed Vac"
 IF ((m_data->pat[1].n_sed_vac=1))
  SET m_info->recs[12].s_value = "Y"
 ELSE
  SET m_info->recs[12].s_value = "N"
 ENDIF
 SET m_info->recs[13].s_display = "Pain"
 IF ((m_data->pat[1].n_pain_control=1))
  SET m_info->recs[13].s_value = "Y"
 ELSE
  SET m_info->recs[13].s_value = "N"
 ENDIF
 SET m_info->recs[14].s_display = "Nutrn"
 IF ((m_data->pat[1].n_nutrition=1))
  SET m_info->recs[14].s_value = "EN"
 ELSEIF ((m_data->pat[1].n_nutrition=2))
  SET m_info->recs[14].s_value = "TN"
 ELSE
  SET m_info->recs[14].s_value = "R"
 ENDIF
 SET m_info->recs[15].s_display = "EOL"
 IF ((m_data->pat[1].n_eol_addr=1))
  SET m_info->recs[15].s_value = "Y"
 ELSE
  SET m_info->recs[15].s_value = "N"
 ENDIF
 SET m_info->recs[16].s_display = "Score"
 SET m_info->recs[16].s_value = trim(cnvtstring(m_data->pat[1].n_score))
 CALL echo("rectojson")
 CALL echo(cnvtrectojson(m_info))
 CALL echo("echojson")
 CALL echojson(m_info, $OUTDEV)
 CALL echorecord(m_info)
#exit_script
 FREE RECORD m_info
 FREE RECORD m_data
 FREE RECORD recs
END GO
