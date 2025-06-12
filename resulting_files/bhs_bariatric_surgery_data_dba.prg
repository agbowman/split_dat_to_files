CREATE PROGRAM bhs_bariatric_surgery_data:dba
 PROMPT
  "person_id" = 0.0
  WITH f_person_id
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 IF (mf_person_id > 0.0)
  SELECT INTO "nl:"
   ps_found = "1", ps_mrn = b.mrn, ps_education_seminar_dt_tm = trim(format(b.education_seminar_dt_tm,
     "dd-mmm-yyyy;;d")),
   ps_education_seminar_ft = b.education_seminar_ft, ps_mwm_referral_dt_tm = trim(format(b
     .mwm_referral_dt_tm,"dd-mmm-yyyy;;d")), ps_mwm_referral_ft = b.mwm_referral_ft,
   ps_labs_dt_tm = trim(format(b.labs_dt_tm,"dd-mmm-yyyy;;d")), ps_labs_ft = b.labs_ft,
   ps_h_pylori_dt_tm = trim(format(b.h_pylori_dt_tm,"dd-mmm-yyyy;;d")),
   ps_h_pylori_ft = b.h_pylori_ft, ps_treatment_completed_dt_tm = trim(format(b
     .treatment_completed_dt_tm,"dd-mmm-yyyy;;d")), ps_treatment_completed_ft = b
   .treatment_completed_ft,
   ps_bnp_nutrition_dt_tm = trim(format(b.bnp_nutrition_dt_tm,"dd-mmm-yyyy;;d")), ps_bnp_nutrition_ft
    = b.bnp_nutrition_ft, ps_bnp_pa_dt_tm = trim(format(b.bnp_pa_dt_tm,"dd-mmm-yyyy;;d")),
   ps_bnp_pa_ft = b.bnp_pa_ft, ps_bsv_dt_tm = trim(format(b.bsv_dt_tm,"dd-mmm-yyyy;;d")), ps_bsv_ft
    = b.bsv_ft,
   ps_nutrition_clearance_dt_tm = trim(format(b.nutrition_clearance_dt_tm,"dd-mmm-yyyy;;d")),
   ps_nutrition_clearance_ft = b.nutrition_clearance_ft, ps_initial_psych_visit_dt_tm = trim(format(b
     .initial_psych_visit_dt_tm,"dd-mmm-yyyy;;d")),
   ps_initial_psych_visit_ft = b.initial_psych_visit_ft, ps_psych_clearance_dt_tm = trim(format(b
     .psych_clearance_dt_tm,"dd-mmm-yyyy;;d")), ps_psych_clearance_ft = b.psych_clearance_ft,
   ps_sleep_clearance_dt_tm = trim(format(b.sleep_clearance_dt_tm,"dd-mmm-yyyy;;d")),
   ps_sleep_clearance_ft = b.sleep_clearance_ft, ps_us_dt_tm = trim(format(b.us_dt_tm,
     "dd-mmm-yyyy;;d")),
   ps_us_ft = b.us_ft, ps_barium_swallow_dt_tm = trim(format(b.barium_swallow_dt_tm,"dd-mmm-yyyy;;d")
    ), ps_barium_swallow_ft = b.barium_swallow_ft,
   ps_authorized_dt_tm = trim(format(b.authorized_dt_tm,"dd-mmm-yyyy;;d")), ps_authorized_ft = b
   .authorized_ft, ps_or_dt_tm = trim(format(b.or_dt_tm,"dd-mmm-yyyy;;d")),
   ps_or_ft = b.or_ft, ps_comments = b.comments
   FROM bhs_bariatric_surgery b
   WHERE b.person_id=mf_person_id
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, maxrec = 1
  ;end select
 ENDIF
#exit_script
END GO
