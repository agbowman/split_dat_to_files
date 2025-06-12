CREATE PROGRAM bhs_rpt_bariatric_surgery:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search by" = "",
  "MRN" = "",
  "Select Patient" = 0,
  "Beg Date:" = "CURDATE",
  "End Date" = "CURDATE",
  "Rows to return" = 999,
  "Education Seminar" = 0,
  "Apply Dates?" = 0,
  "MWM Referral" = 0,
  "Apply Dates?" = 0,
  "Labs" = 0,
  "Apply Dates?" = 0,
  "H Pylori" = 0,
  "Apply Dates?" = 0,
  "Treatment Completed" = 0,
  "Apply Dates?" = 0,
  "BNP Nutrition" = 0,
  "Apply Dates?" = 0,
  "BNP PA" = 0,
  "Apply Dates?" = 0,
  "BSV" = 0,
  "Apply Dates?" = 0,
  "Nutrition Clearance" = 0,
  "Apply Dates?" = 0,
  "Initial Psych Visit" = 0,
  "Apply Dates?" = 0,
  "Psych Clearance" = 0,
  "Apply Dates?" = 0,
  "Sleep Clearance" = 0,
  "Apply Dates?" = 0,
  "US" = 0,
  "Apply Dates?" = 0,
  "Barium Swallow" = 0,
  "Apply Dates?" = 0,
  "Authorized" = 0,
  "Apply Dates?" = 0,
  "OR" = 0,
  "Apply Dates?" = 0
  WITH outdev, n_search_type, s_mrn,
  f_patient_id, s_beg_dt, s_end_dt,
  n_rows_to_ret, n_edu, n_edu_dt,
  n_mwm, n_mwm_dt, n_labs,
  n_labs_dt, n_h_pylori, n_h_pylori_dt,
  n_treat, n_treat_dt, n_bnpn,
  n_bnpn_dt, n_bnppa, n_bnppa_dt,
  n_bsv, n_bsv_dt, n_nut_clear,
  n_nut_clear_dt, n_psych_vis, n_psych_vis_dt,
  n_psych_clear, n_psych_clear_dt, n_sleep,
  n_sleep_dt, n_us, n_us_dt,
  n_barium, n_barium_dt, n_auth,
  n_auth_dt, n_or, n_or_dt
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mn_search_type = i2 WITH protect, constant(cnvtint( $N_SEARCH_TYPE))
 DECLARE mf_pat_id = f8 WITH protect, constant(cnvtreal( $F_PATIENT_ID))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $S_END_DT," 23:59:59"))
 DECLARE mn_rows_to_ret = i2 WITH protect, constant(cnvtint( $N_ROWS_TO_RET))
 DECLARE mn_edu = i2 WITH protect, constant(cnvtint( $N_EDU))
 DECLARE mn_edu_dt = i2 WITH protect, constant(cnvtint( $N_EDU))
 DECLARE mn_mwm = i2 WITH protect, constant(cnvtint( $N_MWM))
 DECLARE mn_mwm_dt = i2 WITH protect, constant(cnvtint( $N_MWM))
 DECLARE mn_labs = i2 WITH protect, constant(cnvtint( $N_LABS))
 DECLARE mn_labs_dt = i2 WITH protect, constant(cnvtint( $N_LABS))
 DECLARE mn_h_pylori = i2 WITH protect, constant(cnvtint( $N_H_PYLORI))
 DECLARE mn_h_pylori_dt = i2 WITH protect, constant(cnvtint( $N_H_PYLORI))
 DECLARE mn_treat = i2 WITH protect, constant(cnvtint( $N_TREAT))
 DECLARE mn_treat_dt = i2 WITH protect, constant(cnvtint( $N_TREAT))
 DECLARE mn_bnpn = i2 WITH protect, constant(cnvtint( $N_BNPN))
 DECLARE mn_bnpn_dt = i2 WITH protect, constant(cnvtint( $N_BNPN))
 DECLARE mn_bnppa = i2 WITH protect, constant(cnvtint( $N_BNPPA))
 DECLARE mn_bnppa_dt = i2 WITH protect, constant(cnvtint( $N_BNPPA))
 DECLARE mn_bsv = i2 WITH protect, constant(cnvtint( $N_BSV))
 DECLARE mn_bsv_dt = i2 WITH protect, constant(cnvtint( $N_BSV))
 DECLARE mn_nut_clear = i2 WITH protect, constant(cnvtint( $N_NUT_CLEAR))
 DECLARE mn_nut_clear_dt = i2 WITH protect, constant(cnvtint( $N_NUT_CLEAR))
 DECLARE mn_psych_vis = i2 WITH protect, constant(cnvtint( $N_PSYCH_VIS))
 DECLARE mn_psych_vis_dt = i2 WITH protect, constant(cnvtint( $N_PSYCH_VIS))
 DECLARE mn_psych_clear = i2 WITH protect, constant(cnvtint( $N_PSYCH_CLEAR))
 DECLARE mn_psych_clear_dt = i2 WITH protect, constant(cnvtint( $N_PSYCH_CLEAR))
 DECLARE mn_sleep = i2 WITH protect, constant(cnvtint( $N_SLEEP))
 DECLARE mn_sleep_dt = i2 WITH protect, constant(cnvtint( $N_SLEEP))
 DECLARE mn_us = i2 WITH protect, constant(cnvtint( $N_US))
 DECLARE mn_us_dt = i2 WITH protect, constant(cnvtint( $N_US))
 DECLARE mn_barium = i2 WITH protect, constant(cnvtint( $N_BARIUM))
 DECLARE mn_barium_dt = i2 WITH protect, constant(cnvtint( $N_BARIUM))
 DECLARE mn_auth = i2 WITH protect, constant(cnvtint( $N_AUTH))
 DECLARE mn_auth_dt = i2 WITH protect, constant(cnvtint( $N_AUTH))
 DECLARE mn_or = i2 WITH protect, constant(cnvtint( $N_OR))
 DECLARE mn_or_dt = i2 WITH protect, constant(cnvtint( $N_OR))
 DECLARE ms_sel = vc WITH protect, noconstant(" ")
 CALL echo(concat("mn_search_type: ",trim(cnvtstring(mn_search_type))))
 CALL echo(concat("s_mrn: ",trim(cnvtstring( $S_MRN))))
 CALL echo(concat("mf_pat_id: ",trim(cnvtstring(mf_pat_id))))
 CALL echo(concat("ms_beg_dt_tm: ",ms_beg_dt_tm," ms_end_dt_tm: ",ms_end_dt_tm))
 CALL echo(concat("mn_rows_to_ret: ",trim(cnvtstring(mn_rows_to_ret))))
 CALL echo(concat("mn_edu: ",trim(cnvtstring(mn_edu))," mn_edu_dt: ",trim(cnvtstring(mn_edu_dt))))
 CALL echo(concat("mn_mwm: ",trim(cnvtstring(mn_mwm))," mn_mwm_dt: ",trim(cnvtstring(mn_mwm_dt))))
 CALL echo(concat("mn_labs: ",trim(cnvtstring(mn_labs)),"mn_labs_dt: ",trim(cnvtstring(mn_labs_dt))))
 CALL echo(concat("mn_h_pylori: ",trim(cnvtstring(mn_h_pylori))," mn_h_pylori_dt: ",trim(cnvtstring(
     mn_h_pylori_dt))))
 CALL echo(concat("mn_treat: ",trim(cnvtstring(mn_treat))," mn_treat_dt: ",trim(cnvtstring(
     mn_treat_dt))))
 CALL echo(concat("mn_bnpn: ",trim(cnvtstring(mn_bnpn))," mn_bnpn_dt: ",trim(cnvtstring(mn_bnpn_dt)))
  )
 CALL echo(concat("mn_bnppa: ",trim(cnvtstring(mn_bnppa))," mn_bnppa_dt: ",trim(cnvtstring(
     mn_bnppa_dt))))
 CALL echo(concat("mn_bsv: ",trim(cnvtstring(mn_bsv))," mn_bsv_dt: ",trim(cnvtstring(mn_bsv_dt))))
 CALL echo(concat("mn_nut_clear: ",trim(cnvtstring(mn_nut_clear))," mn_nut_clear_dt: ",trim(
    cnvtstring(mn_nut_clear_dt))))
 CALL echo(concat("mn_psych_vis: ",trim(cnvtstring(mn_psych_vis))," mn_psych_vis_dt: ",trim(
    cnvtstring(mn_psych_vis_dt))))
 CALL echo(concat("mn_psych_clear: ",trim(cnvtstring(mn_psych_clear))," mn_psych_clear_dt: ",trim(
    cnvtstring(mn_psych_clear_dt))))
 CALL echo(concat("mn_sleep: ",trim(cnvtstring(mn_sleep))," mn_sleep_dt: ",trim(cnvtstring(
     mn_sleep_dt))))
 CALL echo(concat("mn_us: ",trim(cnvtstring(mn_us))," mn_us_dt: ",trim(cnvtstring(mn_us_dt))))
 CALL echo(concat("mn_barium: ",trim(cnvtstring(mn_barium))," mn_barium_dt: ",trim(cnvtstring(
     mn_barium_dt))))
 CALL echo(concat("mn_auth: ",trim(cnvtstring(mn_auth))," mn_auth_dt: ",trim(cnvtstring(mn_auth_dt)))
  )
 CALL echo(concat("mn_or: ",trim(cnvtstring(mn_or))," mn_or_dt: ",trim(cnvtstring(mn_or_dt))))
 DECLARE sbr_chk_field(ps_field,pn_val,pn_dt_val) = null
 IF (mn_search_type=1)
  CALL echo("patient search")
  SELECT INTO value(ms_output)
   patient = p.name_full_formatted, mrn = b.mrn, education_seminar_dt = trim(format(b
     .education_seminar_dt_tm,"dd-mmm-yyyy;;d")),
   education_seminar = trim(b.education_seminar_ft), mwm_referral_dt = trim(format(b
     .mwm_referral_dt_tm,"dd-mmm-yyyy;;d")), mwm_referral = trim(b.mwm_referral_ft),
   labs_dt = trim(format(b.labs_dt_tm,"dd-mmm-yyyy;;d")), labs = trim(b.labs_ft), h_pylori_dt = trim(
    format(b.h_pylori_dt_tm,"dd-mmm-yyyy;;d")),
   h_pylori = trim(b.h_pylori_ft), treatment_completed_dt = trim(format(b.treatment_completed_dt_tm,
     "dd-mmm-yyyy;;d")), treatment_completed = trim(b.treatment_completed_ft),
   bnp_nutrition_dt = trim(format(b.bnp_nutrition_dt_tm,"dd-mmm-yyyy;;d")), bnp_nutrition = trim(b
    .bnp_nutrition_ft), bnp_pa_dt = trim(format(b.bnp_pa_dt_tm,"dd-mmm-yyyy;;d")),
   bnp_pa = trim(b.bnp_pa_ft), bsv_dt = trim(format(b.bsv_dt_tm,"dd-mmm-yyyy;;d")), bsv = trim(b
    .bsv_ft),
   nutrition_clearance_dt = trim(format(b.nutrition_clearance_dt_tm,"dd-mmm-yyyy;;d")),
   nutrition_clearance = trim(b.nutrition_clearance_ft), initial_psych_visit_dt = trim(format(b
     .initial_psych_visit_dt_tm,"dd-mmm-yyyy;;d")),
   initial_psych_visit = trim(b.initial_psych_visit_ft), psych_clearance_dt = trim(format(b
     .psych_clearance_dt_tm,"dd-mmm-yyyy;;d")), psych_clearance = trim(b.psych_clearance_ft),
   sleep_clearance_dt = trim(format(b.sleep_clearance_dt_tm,"dd-mmm-yyyy;;d")), sleep_clearance =
   trim(b.sleep_clearance_ft), us_dt = trim(format(b.us_dt_tm,"dd-mmm-yyyy;;d")),
   us = trim(b.us_ft), barium_swallow_dt = trim(format(b.barium_swallow_dt_tm,"dd-mmm-yyyy;;d")),
   barium_swallow = trim(b.barium_swallow_ft),
   authorized_dt = trim(format(b.authorized_dt_tm,"dd-mmm-yyyy;;d")), authorized = trim(b
    .authorized_ft), or_dt = trim(format(b.or_dt_tm,"dd-mmm-yyyy;;d")),
   or_ = trim(b.or_ft), comments_dt = trim(b.comments)
   FROM bhs_bariatric_surgery b,
    person p
   PLAN (b
    WHERE b.person_id=mf_pat_id)
    JOIN (p
    WHERE p.person_id=b.person_id)
   ORDER BY p.name_full_formatted
   WITH nocounter, skipreport = 1, maxrow = 1,
    format, separator = " "
  ;end select
 ELSE
  CALL sbr_chk_field("education_seminar",mn_edu,mn_edu_dt)
  CALL sbr_chk_field("mwm_referral",mn_mwm,mn_mwm_dt)
  CALL sbr_chk_field("labs",mn_labs,mn_labs_dt)
  CALL sbr_chk_field("h_pylori",mn_h_pylori,mn_h_pylori_dt)
  CALL sbr_chk_field("treatment_completed",mn_treat,mn_treat_dt)
  CALL sbr_chk_field("bnp_nutrition",mn_bnpn,mn_bnpn_dt)
  CALL sbr_chk_field("bnp_pa",mn_bnppa,mn_bnppa_dt)
  CALL sbr_chk_field("bsv",mn_bsv,mn_bsv_dt)
  CALL sbr_chk_field("nutrition_clearance",mn_nut_clear,mn_nut_clear_dt)
  CALL sbr_chk_field("initial_psych_visit",mn_psych_vis,mn_psych_vis_dt)
  CALL sbr_chk_field("psych_clearance",mn_psych_clear,mn_psych_clear)
  CALL sbr_chk_field("sleep_clearance",mn_sleep,mn_sleep_dt)
  CALL sbr_chk_field("us",mn_us,mn_us_dt)
  CALL sbr_chk_field("barium",mn_barium,mn_barium_dt)
  CALL sbr_chk_field("authorized",mn_auth,mn_auth_dt)
  CALL sbr_chk_field("or",mn_or,mn_or_dt)
  IF (trim(ms_sel) <= " ")
   SET ms_sel = " 1=1 "
  ENDIF
  SELECT INTO value(ms_output)
   patient = p.name_full_formatted, mrn = b.mrn, education_seminar_dt = trim(format(b
     .education_seminar_dt_tm,"dd-mmm-yyyy;;d")),
   education_seminar = trim(b.education_seminar_ft), mwm_referral_dt = trim(format(b
     .mwm_referral_dt_tm,"dd-mmm-yyyy;;d")), mwm_referral = trim(b.mwm_referral_ft),
   labs_dt = trim(format(b.labs_dt_tm,"dd-mmm-yyyy;;d")), labs = trim(b.labs_ft), h_pylori_dt = trim(
    format(b.h_pylori_dt_tm,"dd-mmm-yyyy;;d")),
   h_pylori = trim(b.h_pylori_ft), treatment_completed_dt = trim(format(b.treatment_completed_dt_tm,
     "dd-mmm-yyyy;;d")), treatment_completed = trim(b.treatment_completed_ft),
   bnp_nutrition_dt = trim(format(b.bnp_nutrition_dt_tm,"dd-mmm-yyyy;;d")), bnp_nutrition = trim(b
    .bnp_nutrition_ft), bnp_pa_dt = trim(format(b.bnp_pa_dt_tm,"dd-mmm-yyyy;;d")),
   bnp_pa = trim(b.bnp_pa_ft), bsv_dt = trim(format(b.bsv_dt_tm,"dd-mmm-yyyy;;d")), bsv = trim(b
    .bsv_ft),
   nutrition_clearance_dt = trim(format(b.nutrition_clearance_dt_tm,"dd-mmm-yyyy;;d")),
   nutrition_clearance = trim(b.nutrition_clearance_ft), initial_psych_visit_dt = trim(format(b
     .initial_psych_visit_dt_tm,"dd-mmm-yyyy;;d")),
   initial_psych_visit = trim(b.initial_psych_visit_ft), psych_clearance_dt = trim(format(b
     .psych_clearance_dt_tm,"dd-mmm-yyyy;;d")), psych_clearance = trim(b.psych_clearance_ft),
   sleep_clearance_dt = trim(format(b.sleep_clearance_dt_tm,"dd-mmm-yyyy;;d")), sleep_clearance =
   trim(b.sleep_clearance_ft), us_dt = trim(format(b.us_dt_tm,"dd-mmm-yyyy;;d")),
   us = trim(b.us_ft), barium_swallow_dt = trim(format(b.barium_swallow_dt_tm,"dd-mmm-yyyy;;d")),
   barium_swallow = trim(b.barium_swallow_ft),
   authorized_dt = trim(format(b.authorized_dt_tm,"dd-mmm-yyyy;;d")), authorized = trim(b
    .authorized_ft), or_dt = trim(format(b.or_dt_tm,"dd-mmm-yyyy;;d")),
   or_ = trim(b.or_ft), comments_dt = trim(b.comments)
   FROM bhs_bariatric_surgery b,
    person p
   PLAN (b
    WHERE b.active_ind=1
     AND parser(ms_sel))
    JOIN (p
    WHERE p.person_id=b.person_id)
   ORDER BY p.name_full_formatted
   WITH nocounter, skipreport = 1, maxrow = 1,
    format, separator = " "
  ;end select
 ENDIF
 SUBROUTINE sbr_chk_field(ps_field,pn_val,pn_dt_val)
   IF (pn_val IN (1, 2))
    IF (trim(ms_sel) > " ")
     SET ms_sel = concat(ms_sel," and ")
    ENDIF
   ENDIF
   IF (pn_val=1)
    SET ms_sel = concat(ms_sel," b.",ps_field,"_ft = null")
   ELSEIF (pn_val=2)
    SET ms_sel = concat(ms_sel," b.",ps_field,"_ft not in ('', ' ', null)")
   ENDIF
   IF (pn_dt_val=1)
    IF (trim(ms_sel) > " ")
     SET ms_sel = concat(ms_sel," and ")
    ENDIF
    SET ms_sel = concat(ms_sel," b.",ps_field,"_dt_tm between cnvtdatetime('",ms_beg_dt_tm,
     "') and cnvtdatetime('",ms_end_dt_tm,"')")
   ENDIF
   CALL echo(ms_sel)
 END ;Subroutine
#exit_script
END GO
