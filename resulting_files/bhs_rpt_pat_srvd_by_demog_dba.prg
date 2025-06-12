CREATE PROGRAM bhs_rpt_pat_srvd_by_demog:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 nu[*]
     2 f_cd = f8
     2 s_disp = vc
   1 hisp[*]
     2 f_cd = f8
     2 s_disp = vc
     2 s_group = vc
   1 race[*]
     2 f_cd = f8
     2 s_disp = vc
     2 s_group = vc
   1 l_tot_pat = i4
   1 l_tot_eth = i4
   1 l_tot_hisp = i4
   1 l_tot_nothisp = i4
   1 l_tot_hisp_unk = i4
   1 l_tot_race = i4
   1 l_tot_alaskan = i4
   1 l_tot_asian = i4
   1 l_tot_black = i4
   1 l_tot_white = i4
   1 l_tot_hawaiian = i4
   1 l_tot_none = i4
   1 l_tot_multi = i4
   1 l_tot_other = i4
   1 l_ed = i4
   1 l_ed_eth = i4
   1 l_ed_hisp = i4
   1 l_ed_nothisp = i4
   1 l_ed_hisp_unk = i4
   1 l_ed_race = i4
   1 l_ed_alaskan = i4
   1 l_ed_asian = i4
   1 l_ed_black = i4
   1 l_ed_white = i4
   1 l_ed_hawaiian = i4
   1 l_ed_none = i4
   1 l_ed_multi = i4
   1 l_ed_other = i4
   1 l_inpat = i4
   1 l_inpat_eth = i4
   1 l_inpat_hisp = i4
   1 l_inpat_nothisp = i4
   1 l_inpat_hisp_unk = i4
   1 l_inpat_race = i4
   1 l_inpat_alaskan = i4
   1 l_inpat_asian = i4
   1 l_inpat_black = i4
   1 l_inpat_white = i4
   1 l_inpat_hawaiian = i4
   1 l_inpat_none = i4
   1 l_inpat_multi = i4
   1 l_inpat_other = i4
   1 l_outpat = i4
   1 l_outpat_eth = i4
   1 l_outpat_hisp = i4
   1 l_outpat_nothisp = i4
   1 l_outpat_hisp_unk = i4
   1 l_outpat_race = i4
   1 l_outpat_alaskan = i4
   1 l_outpat_asian = i4
   1 l_outpat_black = i4
   1 l_outpat_white = i4
   1 l_outpat_hawaiian = i4
   1 l_outpat_none = i4
   1 l_outpat_multi = i4
   1 l_outpat_other = i4
   1 pat[*]
     2 f_person_id = f8
     2 n_inpat = i2
     2 n_ed = i2
     2 n_outpat = i2
     2 s_race = vc
     2 s_hispanic = vc
   1 out[11]
     2 col1 = vc
     2 col2 = vc
     2 col3 = vc
     2 col4 = vc
     2 col5 = vc
     2 col6 = vc
     2 col7 = vc
     2 col8 = vc
     2 col9 = vc
     2 col10 = vc
     2 col11 = vc
 ) WITH protect
 DECLARE mf_cs69_ed = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17005"))
 DECLARE mf_cs69_inpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_outpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17007"))
 CALL echo(build2("mf_CS69_ED: ",mf_cs69_ed))
 CALL echo(build2("mf_CS69_INPAT: ",mf_cs69_inpat))
 CALL echo(build2("mf_CS69_OUTPAT: ",mf_cs69_outpat))
 DECLARE mf_cs355_user_def = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED"
   ))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_ethnicity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"ETHNICITY")
  )
 DECLARE mf_bmc_fac = f8 WITH protect, noconstant(0.0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mf_tmp = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_hisp = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_race = vc WITH protect, noconstant(" ")
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx_eth = i4 WITH protect, noconstant(0)
 DECLARE ml_idx_race = i4 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
  SET ms_log = "Both dates must be filled out"
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
  SET ms_log = "End date must be greater than Beg date"
  GO TO exit_script
 ENDIF
 SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
 SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key="BMC"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning="FACILITY"
  HEAD cv.code_value
   mf_bmc_fac = cv.code_value,
   CALL echo(build2("mf_bmc_fac: ",mf_bmc_fac))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   AND ((cv.display="\*BBHA Adult") OR (((cv.display="BBHA ADULT") OR (((cv.display=
  "\*Adol Med Wason") OR (((cv.display="Baystate Brightwood") OR (((cv.display="\*Bayst Brightwood")
   OR (((cv.display="\*Bayst Card Surg") OR (((cv.display="\*Baystate Cardiology1") OR (((cv.display=
  "Bayst Cardiology") OR (((cv.display="\*Device Clinic") OR (((cv.display="Device Clinic") OR (((cv
  .display="\*Heart Failure Clinic") OR (((cv.display="\*VAD Clinic") OR (((cv.display=
  "Byst Behav Dev Ped") OR (((cv.display="\*Byst Develop Peds") OR (((cv.display=
  "\*Baystate Endocrine") OR (((cv.display="Bayst Endo Diab") OR (((cv.display="Bayst Adult Med") OR
  (((cv.display="\*Bayst High St Adlt") OR (((cv.display="\*Bayst High St Pedi") OR (((cv.display=
  "Bayst High St Peds") OR (((cv.display="\*Baystate Mason Sq") OR (((cv.display="Baystate Mason Sq")
   OR (((cv.display="Baystate Midwifery") OR (((cv.display="\*Bayst Mid GYN NON") OR (((cv.display=
  "\*Bayst Mid OBS Global") OR (((cv.display="Baystate Neuro") OR (((cv.display=
  "\*Baystate Neurology") OR (((cv.display="\*Baystate Neurosrg") OR (((cv.display=
  "\*Baystate Ped Card") OR (((cv.display="Baystate Ped Card") OR (((cv.display="\*Baystate Ped Endo"
  ) OR (((cv.display="Baystate Ped Endo") OR (((cv.display="\*Baystate Peds ID") OR (((cv.display=
  "\*Bayst Peds Neuro") OR (((cv.display="Pedi Neuro Testing") OR (((cv.display=
  "\*Byst Pedi Pulm Med") OR (((cv.display="\*360 Bernie OP Rhb") OR (((cv.display=
  "Baystate Pulmonary") OR (((cv.display="\*Bayst Pulmonary") OR (((cv.display=
  "\*Spfld Pulm Wason BMC") OR (((cv.display="\*Bayst Repro Med") OR (((cv.display=
  "\*BVS Lab 3500 Main St") OR (((cv.display="\*WW Clinic Gyn") OR (((cv.display="WW Clinic-Gyn") OR
  (((cv.display="WW Clinic OB") OR (((cv.display="\*WW Clinic Obs") OR (((cv.display=
  "\*Bayst WWG OB/GYN") OR (((cv.display="\*Bayst WW Grp UroGyn") OR (((cv.display=
  "Bayst WW Grp UroGyn") OR (((cv.display="\*Bayst Genetics") OR (((cv.display=
  "\*Genetics Damour Ctr") OR (((cv.display="\*Genetics Wason") OR (((cv.display="GENWASON") OR (((cv
  .display="\*Bayst GYN Oncology") OR (((cv.display="\*Bayst Pedi GI and Nutr Spfld") OR (((cv
  .display="Pedi Gastro") OR (((cv.display="\*BBHA Child") OR (((cv.display="BBHA CHILD") OR (((cv
  .display="\*Heme/Onc Adult") OR (((cv.display="\*FAM ADVO") OR (((cv.display="Baystate Mat Fet")
   OR (((cv.display="\*Mat Fetal Cons") OR (((cv.display="\*Mat Fetal Med") OR (((cv.display=
  "Pedi Cardio Testing") OR (((cv.display="Pedi CardioTstg") OR (((cv.display="\*Wesson Sleep Clinic"
  ) OR (cv.display="Wesson Sleep Clinic")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) ))
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->nu,pl_cnt), m_rec->nu[pl_cnt].f_cd = cv.code_value,
   m_rec->nu[pl_cnt].s_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT
  *
  FROM code_value cv
  WHERE cv.code_set=27
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("HISPANIC", "NOTHISPANIC", "CHOOSENOTTOANSWER", "DONTKNOW",
  "UNABLETOCOLLECT",
  "UNKNOWN", "UNKNOWNNOTSPECIFIED")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->hisp,pl_cnt), m_rec->hisp[pl_cnt].f_cd = cv.code_value,
   m_rec->hisp[pl_cnt].s_disp = trim(cv.display,3)
   IF (cv.display_key IN ("CHOOSENOTTOANSWER", "DONTKNOW", "UNABLETOCOLLECT", "UNKNOWN",
   "UNKNOWNNOTSPECIFIED"))
    m_rec->hisp[pl_cnt].s_group = "none"
   ELSEIF (cv.display_key="HISPANIC")
    m_rec->hisp[pl_cnt].s_group = "hispanic"
   ELSEIF (cv.display_key="NOTHISPANIC")
    m_rec->hisp[pl_cnt].s_group = "nothispanic"
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->hisp,(pl_cnt+ 4)), m_rec->hisp[(pl_cnt+ 1)].f_cd = 0.0, m_rec->hisp[(pl_cnt
   + 1)].s_disp = "U",
   m_rec->hisp[(pl_cnt+ 1)].s_group = "none", m_rec->hisp[(pl_cnt+ 2)].f_cd = 0.0, m_rec->hisp[(
   pl_cnt+ 2)].s_disp = "R",
   m_rec->hisp[(pl_cnt+ 2)].s_group = "none", m_rec->hisp[(pl_cnt+ 3)].f_cd = 0.0, m_rec->hisp[(
   pl_cnt+ 3)].s_disp = "Y",
   m_rec->hisp[(pl_cnt+ 3)].s_group = "hispanic", m_rec->hisp[(pl_cnt+ 4)].f_cd = 0.0, m_rec->hisp[(
   pl_cnt+ 4)].s_disp = "N",
   m_rec->hisp[(pl_cnt+ 4)].s_group = "nothispanic"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=282
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("AMERICANINDIANALASKANATIVE", "ASIAN", "ASIANINDIAN", "CHINESE", "FILIPINO",
  "JAPANESE", "KOREAN", "VIETNAMESE", "BLACKORAFRICANAMERICAN", "WHITE",
  "NATIVEHAWAIIAN", "GUAMANIANORCHAMORRO", "SAMOAN", "OTHERPACIFICISLANDER", "CHOOSENOTTOANSWER",
  "UNABLETOCOLLECT", "UNKNOWN")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->race,pl_cnt), m_rec->race[pl_cnt].f_cd = cv.code_value,
   m_rec->race[pl_cnt].s_disp = trim(cv.display,3)
   IF (cv.display_key="AMERICANINDIANALASKANATIVE")
    m_rec->race[pl_cnt].s_group = "alaskan"
   ELSEIF (cv.display_key IN ("ASIAN", "ASIANINDIAN", "CHINESE", "FILIPINO", "JAPANESE",
   "KOREAN", "VIETNAMESE"))
    m_rec->race[pl_cnt].s_group = "asian"
   ELSEIF (cv.display_key="BLACKORAFRICANAMERICAN")
    m_rec->race[pl_cnt].s_group = "black"
   ELSEIF (cv.display_key="WHITE")
    m_rec->race[pl_cnt].s_group = "white"
   ELSEIF (cv.display_key IN ("NATIVEHAWAIIAN", "GUAMANIANORCHAMORRO", "SAMOAN",
   "OTHERPACIFICISLANDER"))
    m_rec->race[pl_cnt].s_group = "hawaiian"
   ELSEIF (cv.display_key IN ("CHOOSENOTTOANSWER", "UNABLETOCOLLECT", "UNKNOWN"))
    m_rec->race[pl_cnt].s_group = "none"
   ELSEIF (cv.display_key="MULTI*")
    m_rec->race[pl_cnt].s_group = "multi"
   ELSE
    m_rec->race[pl_cnt].s_group = "other"
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_info pi1,
   person_info pi2,
   bhs_demographics bd1,
   bhs_demographics bd2
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.active_ind=1
    AND e.encntr_id > 0.0
    AND ((e.encntr_type_class_cd IN (mf_cs69_ed, mf_cs69_inpat)
    AND e.loc_facility_cd=mf_bmc_fac) OR (e.encntr_type_class_cd=mf_cs69_outpat
    AND expand(ml_exp,1,size(m_rec->nu,5),e.loc_nurse_unit_cd,m_rec->nu[ml_exp].f_cd))) )
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pi1
   WHERE (pi1.person_id= Outerjoin(p.person_id))
    AND (pi1.active_ind= Outerjoin(1))
    AND (pi1.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pi1.info_type_cd= Outerjoin(mf_cs355_user_def))
    AND (pi1.info_sub_type_cd= Outerjoin(mf_cs356_ethnicity)) )
   JOIN (pi2
   WHERE (pi2.person_id= Outerjoin(p.person_id))
    AND (pi2.active_ind= Outerjoin(1))
    AND (pi2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pi2.info_type_cd= Outerjoin(mf_cs355_user_def))
    AND (pi2.info_sub_type_cd= Outerjoin(mf_cs356_race1)) )
   JOIN (bd1
   WHERE (bd1.person_id= Outerjoin(p.person_id))
    AND (bd1.end_effective_dt_tm> Outerjoin(sysdate))
    AND (bd1.active_ind= Outerjoin(1))
    AND (bd1.description= Outerjoin("hispanic ind")) )
   JOIN (bd2
   WHERE (bd2.person_id= Outerjoin(p.person_id))
    AND (bd2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (bd2.active_ind= Outerjoin(1))
    AND (bd2.description= Outerjoin("race 1")) )
  ORDER BY p.person_id, e.encntr_type_class_cd
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 50))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = e.person_id
   IF (p.ethnic_grp_cd > 0.0
    AND locateval(ml_loc,1,size(m_rec->hisp,5),p.ethnic_grp_cd,m_rec->hisp[ml_loc].f_cd) > 0)
    ms_tmp_hisp = trim(uar_get_code_display(p.ethnic_grp_cd),3), m_rec->l_tot_eth += 1
   ELSEIF (pi1.value_cd > 0.0)
    ms_tmp_hisp = trim(uar_get_code_display(pi1.value_cd),3), m_rec->l_tot_eth += 1
   ELSEIF ( NOT (bd1.display IN (null, " ", "")))
    CALL echo(build2("bd hisp: ",trim(bd1.display,3)," ",trim(cnvtstring(p.person_id),3))),
    ms_tmp_hisp = trim(bd1.display,3), m_rec->l_tot_eth += 1
   ENDIF
   m_rec->pat[pl_cnt].s_hispanic = ms_tmp_hisp, ml_idx = locateval(ml_loc,1,size(m_rec->hisp,5),
    ms_tmp_hisp,m_rec->hisp[ml_loc].s_disp)
   IF (ml_idx > 0)
    IF ((m_rec->hisp[ml_idx].s_group="hispanic"))
     m_rec->l_tot_hisp += 1
    ELSEIF ((m_rec->hisp[ml_idx].s_group="nothispanic"))
     m_rec->l_tot_nothisp += 1
    ELSEIF ((m_rec->hisp[ml_idx].s_group="none"))
     m_rec->l_tot_hisp_unk += 1
    ENDIF
   ENDIF
   IF (p.race_cd > 0.0)
    ms_tmp_race = trim(uar_get_code_display(p.race_cd),3)
   ELSEIF (pi2.value_cd > 0.0)
    ms_tmp_race = trim(uar_get_code_display(pi2.value_cd),3)
   ENDIF
   IF (((textlen(trim(ms_tmp_race,3))=0) OR (ms_tmp_race="multi"))
    AND bd2.code_value > 0.0)
    CALL echo(build2("bd race: ",trim(uar_get_code_display(bd2.code_value),3),trim(cnvtstring(p
       .person_id),3))), ms_tmp_race = trim(uar_get_code_display(bd2.code_value),3)
   ENDIF
   m_rec->pat[pl_cnt].s_race = ms_tmp_race, m_rec->l_tot_race += 1, ml_idx = locateval(ml_loc,1,size(
     m_rec->race,5),pi2.value_cd,m_rec->race[ml_loc].f_cd)
   IF (ml_idx > 0)
    IF ((m_rec->race[ml_idx].s_group="alaskan"))
     m_rec->l_tot_alaskan += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="asian"))
     m_rec->l_tot_asian += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="black"))
     m_rec->l_tot_black += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="white"))
     m_rec->l_tot_white += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="hawaiian"))
     m_rec->l_tot_hawaiian += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="none"))
     m_rec->l_tot_none += 1
    ELSEIF ((m_rec->race[ml_idx].s_group="multi"))
     m_rec->l_tot_multi += 1
    ELSE
     m_rec->l_tot_other += 1
    ENDIF
   ENDIF
  HEAD e.encntr_id
   IF (e.encntr_type_class_cd=mf_cs69_ed)
    m_rec->l_ed += 1, m_rec->pat[pl_cnt].n_ed = 1
    IF (textlen(trim(m_rec->pat[pl_cnt].s_hispanic,3)) > 0)
     m_rec->l_ed_eth += 1, ml_idx = locateval(ml_loc,1,size(m_rec->hisp,5),ms_tmp_hisp,m_rec->hisp[
      ml_loc].s_disp)
     IF (ml_idx > 0)
      IF ((m_rec->hisp[ml_idx].s_group="hispanic"))
       m_rec->l_ed_hisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="nothispanic"))
       m_rec->l_ed_nothisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="none"))
       m_rec->l_ed_hisp_unk += 1
      ENDIF
     ENDIF
    ENDIF
    IF (textlen(trim(m_rec->pat[pl_cnt].s_race,3)) > 0)
     m_rec->l_ed_race += 1, ml_idx = locateval(ml_loc,1,size(m_rec->race,5),pi2.value_cd,m_rec->race[
      ml_loc].f_cd)
     IF (ml_idx > 0)
      IF ((m_rec->race[ml_idx].s_group="alaskan"))
       m_rec->l_ed_alaskan += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="asian"))
       m_rec->l_ed_asian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="black"))
       m_rec->l_ed_black += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="white"))
       m_rec->l_ed_white += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="hawaiian"))
       m_rec->l_ed_hawaiian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="none"))
       m_rec->l_ed_none += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="multi"))
       m_rec->l_ed_multi += 1
      ELSE
       m_rec->l_ed_other += 1
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (e.encntr_type_class_cd=mf_cs69_inpat)
    m_rec->l_inpat += 1, m_rec->pat[pl_cnt].n_inpat = 1
    IF (textlen(trim(m_rec->pat[pl_cnt].s_hispanic,3)) > 0)
     m_rec->l_inpat_eth += 1, ml_idx = locateval(ml_loc,1,size(m_rec->hisp,5),ms_tmp_hisp,m_rec->
      hisp[ml_loc].s_disp)
     IF (ml_idx > 0)
      IF ((m_rec->hisp[ml_idx].s_group="hispanic"))
       m_rec->l_inpat_hisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="nothispanic"))
       m_rec->l_inpat_nothisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="none"))
       m_rec->l_inpat_hisp_unk += 1
      ENDIF
     ENDIF
    ENDIF
    IF (textlen(trim(m_rec->pat[pl_cnt].s_race,3)) > 0)
     m_rec->l_inpat_race += 1, ml_idx = locateval(ml_loc,1,size(m_rec->race,5),pi2.value_cd,m_rec->
      race[ml_loc].f_cd)
     IF (ml_idx > 0)
      IF ((m_rec->race[ml_idx].s_group="alaskan"))
       m_rec->l_inpat_alaskan += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="asian"))
       m_rec->l_inpat_asian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="black"))
       m_rec->l_inpat_black += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="white"))
       m_rec->l_inpat_white += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="hawaiian"))
       m_rec->l_inpat_hawaiian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="none"))
       m_rec->l_inpat_none += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="multi"))
       m_rec->l_inpat_multi += 1
      ELSE
       m_rec->l_inpat_other += 1
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (e.encntr_type_class_cd=mf_cs69_outpat)
    m_rec->l_outpat += 1, m_rec->pat[pl_cnt].n_outpat = 1
    IF (textlen(trim(m_rec->pat[pl_cnt].s_hispanic,3)) > 0)
     m_rec->l_outpat_eth += 1, ml_idx = locateval(ml_loc,1,size(m_rec->hisp,5),ms_tmp_hisp,m_rec->
      hisp[ml_loc].s_disp)
     IF (ml_idx > 0)
      IF ((m_rec->hisp[ml_idx].s_group="hispanic"))
       m_rec->l_outpat_hisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="nothispanic"))
       m_rec->l_outpat_nothisp += 1
      ELSEIF ((m_rec->hisp[ml_idx].s_group="none"))
       m_rec->l_outpat_hisp_unk += 1
      ENDIF
     ENDIF
    ENDIF
    IF (textlen(trim(m_rec->pat[pl_cnt].s_race,3)) > 0)
     m_rec->l_outpat_race += 1, ml_idx = locateval(ml_loc,1,size(m_rec->race,5),pi2.value_cd,m_rec->
      race[ml_loc].f_cd)
     IF (ml_idx > 0)
      IF ((m_rec->race[ml_idx].s_group="alaskan"))
       m_rec->l_outpat_alaskan += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="asian"))
       m_rec->l_outpat_asian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="black"))
       m_rec->l_outpat_black += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="white"))
       m_rec->l_outpat_white += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="hawaiian"))
       m_rec->l_outpat_hawaiian += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="none"))
       m_rec->l_outpat_none += 1
      ELSEIF ((m_rec->race[ml_idx].s_group="multi"))
       m_rec->l_outpat_multi += 1
      ELSE
       m_rec->l_outpat_other += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt), m_rec->l_tot_pat = pl_cnt
  WITH nocounter
 ;end select
 SET m_rec->out[1].col1 = "Race"
 SET m_rec->out[2].col1 = " "
 SET m_rec->out[2].col2 = "Alaskan"
 SET m_rec->out[2].col3 = "Asian"
 SET m_rec->out[2].col4 = "Black"
 SET m_rec->out[2].col5 = "Hawaiian"
 SET m_rec->out[2].col6 = "White"
 SET m_rec->out[2].col7 = "Multi"
 SET m_rec->out[2].col8 = "Other"
 SET m_rec->out[2].col9 = "None"
 SET m_rec->out[2].col10 = "Total Qualified Patients"
 SET m_rec->out[2].col11 = "Total Patients Answered"
 SET m_rec->out[3].col1 = "BMC All Patients"
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_alaskan)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_asian)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_black)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col4 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_hawaiian)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col5 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_white)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col6 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_multi)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col7 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_other)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col8 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_none)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[3].col9 = ms_tmp
 SET m_rec->out[3].col10 = trim(cnvtstring(m_rec->l_tot_pat),3)
 SET m_rec->out[3].col11 = trim(cnvtstring(m_rec->l_tot_race),3)
 SET m_rec->out[4].col1 = "BMC Inpatients"
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_alaskan)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_asian)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_black)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col4 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_hawaiian)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col5 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_white)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col6 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_multi)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col7 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_other)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col8 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_none)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[4].col9 = ms_tmp
 SET m_rec->out[4].col10 = trim(cnvtstring(m_rec->l_inpat),3)
 SET m_rec->out[4].col11 = trim(cnvtstring(m_rec->l_inpat_race),3)
 SET m_rec->out[5].col1 = "BMC Outpatients"
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_alaskan)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_asian)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_black)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col4 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_hawaiian)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col5 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_white)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col6 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_multi)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col7 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_other)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col8 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_none)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[5].col9 = ms_tmp
 SET m_rec->out[5].col10 = trim(cnvtstring(m_rec->l_outpat),3)
 SET m_rec->out[5].col11 = trim(cnvtstring(m_rec->l_outpat_race),3)
 SET m_rec->out[7].col1 = "Hispanic Ethnicity"
 SET m_rec->out[8].col1 = " "
 SET m_rec->out[8].col2 = "Hispanic or Latino"
 SET m_rec->out[8].col3 = "Not Hispanic or Latino"
 SET m_rec->out[8].col4 = "Unknown"
 SET m_rec->out[8].col5 = "Total Patients Qualified"
 SET m_rec->out[8].col6 = "Total Patients Answered"
 SET m_rec->out[9].col1 = "BMC All Patients"
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_hisp)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[9].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_nothisp)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[9].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_tot_hisp_unk)/ cnvtreal(m_rec->l_tot_pat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[9].col4 = ms_tmp
 SET m_rec->out[9].col5 = trim(cnvtstring(m_rec->l_tot_pat),3)
 SET m_rec->out[9].col6 = trim(cnvtstring(m_rec->l_tot_eth),3)
 SET m_rec->out[10].col1 = "BMC Inpatients"
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_hisp)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[10].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_nothisp)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[10].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_inpat_hisp_unk)/ cnvtreal(m_rec->l_inpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[10].col4 = ms_tmp
 SET m_rec->out[10].col5 = trim(cnvtstring(m_rec->l_inpat),3)
 SET m_rec->out[10].col6 = trim(cnvtstring(m_rec->l_inpat_eth),3)
 SET m_rec->out[11].col1 = "BMC Outpatients"
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_hisp)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[11].col2 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_nothisp)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[11].col3 = ms_tmp
 SET mf_tmp = ((cnvtreal(m_rec->l_outpat_hisp_unk)/ cnvtreal(m_rec->l_outpat)) * 100)
 SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
 SET m_rec->out[11].col4 = ms_tmp
 SET m_rec->out[11].col5 = trim(cnvtstring(m_rec->l_outpat),3)
 SET m_rec->out[11].col6 = trim(cnvtstring(m_rec->l_outpat_eth),3)
 SELECT INTO value( $OUTDEV)
  substring(1,50,m_rec->out[d.seq].col1), substring(1,50,m_rec->out[d.seq].col2), substring(1,50,
   m_rec->out[d.seq].col3),
  substring(1,50,m_rec->out[d.seq].col4), substring(1,50,m_rec->out[d.seq].col5), substring(1,50,
   m_rec->out[d.seq].col6),
  substring(1,50,m_rec->out[d.seq].col7), substring(1,50,m_rec->out[d.seq].col8), substring(1,50,
   m_rec->out[d.seq].col9),
  substring(1,50,m_rec->out[d.seq].col10), substring(1,50,m_rec->out[d.seq].col11)
  FROM (dummyt d  WITH seq = value(size(m_rec->out,5)))
  PLAN (d)
  ORDER BY d.seq
  WITH nocounter, format, separator = " "
 ;end select
 CALL echo(build2("l_tot_pat: ",m_rec->l_tot_pat))
 CALL echo(build2("l_tot_race: ",m_rec->l_tot_race))
 CALL echo(build2("l_tot_eth: ",m_rec->l_tot_eth))
 CALL echo(build2("l_tot_eth: ",m_rec->l_tot_eth))
 CALL echo(build2("l_ed: ",m_rec->l_ed))
 CALL echo(build2("l_ed_race: ",m_rec->l_ed_race))
 CALL echo(build2("l_ed_eth: ",m_rec->l_ed_eth))
 CALL echo(build2("l_inpat: ",m_rec->l_inpat))
 CALL echo(build2("l_inpat_race: ",m_rec->l_inpat_race))
 CALL echo(build2("l_inpat_eth: ",m_rec->l_inpat_eth))
 CALL echo(build2("l_outpat: ",m_rec->l_outpat))
 CALL echo(build2("l_outpat_race: ",m_rec->l_outpat_race))
 CALL echo(build2("l_outpat_eth: ",m_rec->l_outpat_eth))
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
