CREATE PROGRAM amtest
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ms_fac_parser = gvc WITH protect, noconstant("1")
 DECLARE f_bfmc_echo_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Echo Card"))
 DECLARE f_bfmc_ekg_ecg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC EKG/ECG"))
 DECLARE f_bfmc_nuc_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Nuc Med"))
 DECLARE f_bfmc_nutri_svcs_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Nutri Svcs"))
 DECLARE f_bfmc_pulm_funct_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Pulm Funct"))
 DECLARE f_bfmc_sleep_stud_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Sleep Stud"))
 DECLARE f_bfmc_card_stres_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Card Stres"))
 DECLARE f_neurology_f_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Neurology F"))
 DECLARE f_gnfld_fam_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Fam Med"))
 DECLARE f_gnfld_gastro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Gastro"))
 DECLARE f_gnfld_pulm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Pulm"))
 DECLARE f_bfmc_vasc_lab_cd = f8 WITH constant(458576333)
 DECLARE f_grnfld_rehabpt_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Grnfld RehabPT"))
 DECLARE f_grnfld_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Grnfld IBH"))
 DECLARE f_gnfld_wound_cr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Wound Cr"))
 DECLARE f_gnfld_rehab_ot_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab OT"))
 DECLARE f_gnfld_rehab_aud_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab Aud"))
 DECLARE f_gnfld_rehab_st_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab ST"))
 DECLARE f_gnfld_hrt_vasc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Hrt Vasc"))
 DECLARE f_plmr_bhtherapy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr BHTherapy"))
 DECLARE f_plmr_bhpsych_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr BHPsych"))
 DECLARE f_fmc_bridge_prg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*FMC Bridge Prg"))
 DECLARE f_gnfld_vac_ctr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Vac Ctr"))
 DECLARE f_bfmc_bayinf_gfd_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC BayInf Gfd"))
 DECLARE f_gnfld_midobgyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld MidOBGYN"))
 DECLARE f_gnfld_brst_spc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Brst Spc"))
 DECLARE f_gnfld_gen_surg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Gen Surg"))
 DECLARE f_gnfld_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld ID"))
 DECLARE f_gnfld_neurolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Neurolgy"))
 DECLARE f_gnfld_plst_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Plst Srg"))
 DECLARE f_gnfld_sleep_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Sleep"))
 DECLARE f_gnfld_urogyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld UroGyn"))
 DECLARE f_gnfld_urology_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Urology"))
 DECLARE f_card_rehabwellb_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Card RehabWellB"))
 DECLARE f_bmc_diab_teach_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Diab Teach"))
 DECLARE f_bmc_ekg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC EKG"))
 DECLARE f_bmc_lactation_svc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Lactation Svc")
  )
 DECLARE f_bmc_noninv_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC NonInv Card"))
 DECLARE f_bmc_csc_preadmit_ts_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC CSC Preadmit Ts"))
 DECLARE f_bmc_pulm_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Pulm Lab"))
 DECLARE f_bmc_pulm_rehab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Pulm Rehab"))
 DECLARE f_spfld_psychcon_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsychCon"))
 DECLARE f_bmc_wps_mat_fet_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC WPS Mat-Fet"))
 DECLARE f_spfld_bh_np_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH NP"))
 DECLARE f_transplant_pre_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Transplant Pre"))
 DECLARE f_transplant_post_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Transplant Post"))
 DECLARE f_spfld_gen_peds_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Peds"))
 DECLARE f_spfld_pedipulm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PediPulm"))
 DECLARE f_spfld_pedneuro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PedNeuro"))
 DECLARE f_spfld_ped_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped ID"))
 DECLARE f_spfld_trav_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Trav Med"))
 DECLARE f_spfld_hshc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC"))
 DECLARE f_spfld_wwc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld WWC"))
 DECLARE f_spfld_brhc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC"))
 DECLARE f_spfld_pain_ctr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pain Ctr"))
 DECLARE f_bmc_wound_care_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*BMC Wound Care"))
 DECLARE f_spfld_msq_tb_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ TB"))
 DECLARE f_spfld_msq_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ"))
 DECLARE f_spfld_pre_op_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pre Op"))
 DECLARE f_spfld_bh_aop_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH AOP"))
 DECLARE f_bmc_s1_5_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC S1-5 Med"))
 DECLARE f_bmc_neurosleep_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC NeuroSleep"))
 DECLARE f_spfld_pedisurg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PediSurg"))
 DECLARE f_spfld_con_care_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Con Care"))
 DECLARE f_spfld_dev_peds_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Dev Peds"))
 DECLARE f_spfld_adol_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Adol Med"))
 DECLARE f_spfld_ped_nutrn_cd = f8 WITH constant(566067849)
 DECLARE f_spfld_pcard_tst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld PCard Tst"))
 DECLARE f_spfld_3400_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld 3400 IBH"))
 DECLARE f_bmc_medical_stay_d3b_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Medical Stay D3B"))
 DECLARE f_spfld_3300_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld 3300 IBH"))
 DECLARE f_spfld_pdnrotst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PdNroTst"))
 DECLARE f_bmc_wwg_759_ivf_cd = f8 WITH constant(573532032)
 DECLARE f_spfld_np3300_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NP3300"))
 DECLARE f_spfld_op_psych_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld OP Psych"))
 DECLARE f_bmc_cont_care_nursery_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Cont Care Nursery"))
 DECLARE f_ws_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*WS IBH"))
 DECLARE f_plmr_rheum_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Rheum"))
 DECLARE f_plmr_podiatry_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Podiatry"))
 DECLARE f_plmr_nephrolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Nephrolgy"))
 DECLARE f_spfld_psynthrpy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsyNthrpy"))
 DECLARE f_bmc_medstay_ppu_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC MedStay PPU"))
 DECLARE f_spfld_geri_hc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Geri HC"))
 DECLARE f_bmc_med_stay_mob_inf_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Med Stay MOB Inf"))
 DECLARE f_spfld_brhc_gan_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC Gan"))
 DECLARE f_spfld_bh_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH WH"))
 DECLARE f_spfld_pallitve_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pallitve"))
 DECLARE f_trns_dnr_pst_srg_b_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "*Trns Dnr Pst Srg B"))
 DECLARE f_spfld_coum_cln_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Coum Cln"))
 DECLARE f_vaccine_unit_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Vaccine Unit"))
 DECLARE f_spfld_trach_cl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Trach Cl"))
 DECLARE f_spfld_msq_midw_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ MidW"))
 DECLARE f_spfld_brhc_mid_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC Mid"))
 DECLARE f_spfld_ped_hemonc_cd = f8 WITH constant(1236719827)
 DECLARE f_spfld_nroenvas_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NroEnVas"))
 DECLARE f_spfld_brhc_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC WH"))
 DECLARE f_spfld_brhc_home_cd = f8 WITH constant(1369743813)
 DECLARE f_spfld_brst_spc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Brst Spc"))
 DECLARE f_spfld_card_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Card Srg"))
 DECLARE f_spfld_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Card"))
 DECLARE f_spfld_vad_clin_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld VAD Clin"))
 DECLARE f_spfld_device_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Device C"))
 DECLARE f_spfld_hrt_fail_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Hrt Fail"))
 DECLARE f_spfld_cbh_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld CBH Main"))
 DECLARE f_spfld_mcpap_4_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP 4"))
 DECLARE f_spfld_cbh_wasn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld CBH Wasn"))
 DECLARE f_spfld_mcpap_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP C"))
 DECLARE f_spfld_endo_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Endo"))
 DECLARE f_spfld_fam_adv_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Fam Adv"))
 DECLARE f_spfld_gastro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gastro"))
 DECLARE f_spfld_gen_surg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Surg"))
 DECLARE f_spfld_gen_chst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Chst"))
 DECLARE f_spfld_gen_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Main"))
 DECLARE f_spfld_gen_wasn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Wasn"))
 DECLARE f_spfld_gyn_onc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld GYN Onc"))
 DECLARE f_spfld_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld ID"))
 DECLARE f_spfld_mid_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Mid WH"))
 DECLARE f_spfld_neurolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Neurolgy"))
 DECLARE f_spfld_neursrgm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NeurSrgM"))
 DECLARE f_spfld_ped_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped Card"))
 DECLARE f_spfld_ped_endo_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped Endo"))
 DECLARE f_spfld_pedi_gi_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pedi GI"))
 DECLARE f_spfld_pmr_birn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PMR Birn"))
 DECLARE f_spfld_plst_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Plst Srg"))
 DECLARE f_spfld_plstsg_w_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PlstSg W"))
 DECLARE f_spfld_psyadm_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsyAdm C"))
 DECLARE f_long_pulm_cd = f8 WITH constant(1370024895)
 DECLARE f_spfld_pulm_mn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pulm Mn"))
 DECLARE f_spfld_pulm_was_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pulm Was"))
 DECLARE f_spfld_sleep_ch_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Sleep Ch"))
 DECLARE f_spfld_neurdiag_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Neurdiag"))
 DECLARE f_spfld_thor_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Thor Srg"))
 DECLARE f_spfld_traumasg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld TraumaSg"))
 DECLARE f_spfld_urogyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld UroGyn"))
 DECLARE f_spfld_vas_svc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Vas Svc"))
 DECLARE f_spfld_vas_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Vas Lab"))
 DECLARE f_spfld_wh_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld WH Main"))
 DECLARE f_spfld_bh_a_3400_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld BH A 3400"))
 DECLARE f_spfld_matfet_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MatFet"))
 DECLARE f_spfld_hshccard_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHCCard"))
 DECLARE f_spfld_hshcneur_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHCNeur"))
 DECLARE f_spfld_hshc_pm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC PM"))
 DECLARE f_spfld_hshc_rnl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC Rnl"))
 DECLARE f_spfld_hshc_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC ID"))
 DECLARE f_spfld_ambpt_tst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld AmbPt Tst"))
 DECLARE f_spfld_mcpap_3_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP 3"))
 DECLARE f_spfldnicard3300_cd = f8 WITH constant(1371210367)
 DECLARE f_plmr_vas_lab_cd = f8 WITH constant(1372859467)
 DECLARE f_spfld_clintrl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld ClinTrl"))
 DECLARE f_spfld_brhc_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC IBH"))
 DECLARE f_spfld_genpedibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld GenPedIBH"))
 DECLARE f_spfld_msq_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ IBH"))
 DECLARE f_spfld_hshc_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC IBH"))
 DECLARE f_bmc_inf_plmr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Inf Plmr"))
 DECLARE f_bmc_inf_wf_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Inf WF"))
 SELECT INTO  $OUTDEV
  cv.display
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.cdf_meaning="AMBULATORY"
   AND cv.code_value IN (f_card_rehabwellb_cd, f_bmc_diab_teach_cd, f_bmc_ekg_cd,
  f_bmc_lactation_svc_cd, f_bmc_noninv_card_cd,
  f_bmc_csc_preadmit_ts_cd, f_bmc_pulm_lab_cd, f_bmc_pulm_rehab_cd, f_spfld_psychcon_cd,
  f_bmc_wps_mat_fet_cd,
  f_spfld_bh_np_cd, f_transplant_pre_cd, f_transplant_post_cd, f_spfld_gen_peds_cd,
  f_spfld_pedipulm_cd,
  f_spfld_pedneuro_cd, f_spfld_ped_id_cd, f_spfld_trav_med_cd, f_spfld_hshc_cd, f_spfld_wwc_cd,
  f_spfld_brhc_cd, f_spfld_pain_ctr_cd, f_bmc_wound_care_cd, f_spfld_msq_tb_cd, f_spfld_msq_cd,
  f_spfld_pre_op_cd, f_spfld_bh_aop_cd, f_bmc_s1_5_med_cd, f_bmc_neurosleep_cd, f_spfld_pedisurg_cd,
  f_spfld_con_care_cd, f_spfld_dev_peds_cd, f_spfld_adol_med_cd, f_spfld_ped_nutrn_cd,
  f_spfld_pcard_tst_cd,
  f_spfld_3400_ibh_cd, f_bmc_medical_stay_d3b_cd, f_spfld_3300_ibh_cd, f_spfld_pdnrotst_cd,
  f_bmc_wwg_759_ivf_cd,
  f_spfld_np3300_cd, f_spfld_op_psych_cd, f_bmc_cont_care_nursery_cd, f_ws_ibh_cd, f_plmr_rheum_cd,
  f_plmr_podiatry_cd, f_plmr_nephrolgy_cd, f_spfld_psynthrpy_cd, f_bmc_medstay_ppu_cd,
  f_spfld_geri_hc_cd,
  f_bmc_med_stay_mob_inf_cd, f_spfld_brhc_gan_cd, f_spfld_bh_wh_cd, f_spfld_pallitve_cd,
  f_trns_dnr_pst_srg_b_cd,
  f_spfld_coum_cln_cd, f_vaccine_unit_cd, f_spfld_trach_cl_cd, f_spfld_msq_midw_cd,
  f_spfld_brhc_mid_cd,
  f_spfld_ped_hemonc_cd, f_spfld_nroenvas_cd, f_spfld_brhc_wh_cd, f_spfld_brhc_home_cd,
  f_spfld_brst_spc_cd,
  f_spfld_card_srg_cd, f_spfld_card_cd, f_spfld_vad_clin_cd, f_spfld_device_c_cd, f_spfld_hrt_fail_cd,
  f_spfld_cbh_main_cd, f_spfld_mcpap_4_cd, f_spfld_cbh_wasn_cd, f_spfld_mcpap_c_cd, f_spfld_endo_cd,
  f_spfld_fam_adv_cd, f_spfld_gastro_cd, f_spfld_gen_surg_cd, f_spfld_gen_chst_cd,
  f_spfld_gen_main_cd,
  f_spfld_gen_wasn_cd, f_spfld_gyn_onc_cd, f_spfld_id_cd, f_spfld_mid_wh_cd, f_spfld_neurolgy_cd,
  f_spfld_neursrgm_cd, f_spfld_ped_card_cd, f_spfld_ped_endo_cd, f_spfld_pedi_gi_cd,
  f_spfld_pmr_birn_cd,
  f_spfld_plst_srg_cd, f_spfld_plstsg_w_cd, f_spfld_psyadm_c_cd, f_long_pulm_cd, f_spfld_pulm_mn_cd,
  f_spfld_pulm_was_cd, f_spfld_sleep_ch_cd, f_spfld_neurdiag_cd, f_spfld_thor_srg_cd,
  f_spfld_traumasg_cd,
  f_spfld_urogyn_cd, f_spfld_vas_svc_cd, f_spfld_vas_lab_cd, f_spfld_wh_main_cd, f_spfld_bh_a_3400_cd,
  f_spfld_matfet_cd, f_spfld_hshccard_cd, f_spfld_hshcneur_cd, f_spfld_hshc_pm_cd,
  f_spfld_hshc_rnl_cd,
  f_spfld_hshc_id_cd, f_spfld_ambpt_tst_cd, f_spfld_mcpap_3_cd, f_spfldnicard3300_cd,
  f_plmr_vas_lab_cd,
  f_spfld_clintrl_cd, f_spfld_brhc_ibh_cd, f_spfld_genpedibh_cd, f_spfld_msq_ibh_cd,
  f_spfld_hshc_ibh_cd,
  f_bmc_inf_plmr_cd, f_bmc_inf_wf_cd)
  ORDER BY cv.code_value
  WITH nocounter, time = 30, format
 ;end select
 CALL echo(ms_fac_parser)
END GO
