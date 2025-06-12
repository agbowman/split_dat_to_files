CREATE PROGRAM bhs_rpt_ob_pitocin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_deliv_cnt = i4
   1 l_elect_deliv_cnt = i4
   1 l_deliv_37pls_cnt = i4
   1 l_trans_cnt = i4
   1 preg[*]
     2 f_person_id = f8
     2 s_preg_beg_dt_tm = vc
     2 s_preg_end_dt_tm = vc
     2 s_method = vc
   1 l_ind_num_cnt = i4
   1 l_ind_den_cnt = i4
   1 ind[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_labor_onset = vc
     2 s_events = vc
     2 l_event_cnt = i4
   1 l_aug_num_cnt = i4
   1 l_aug_den_cnt = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim( $S_BEG_DT,3)," 00:00:00;;d")
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim( $S_END_DT,3)," 23:59:59;;d")
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs4002119_vag_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!12610742"
   ))
 DECLARE mf_cs4002119_vag_for_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!12610743"))
 DECLARE mf_cs4002119_vag_for_vac_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4100275821"))
 DECLARE mf_cs4002119_vag_vac_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!12610744"))
 DECLARE mf_cs72_rsn_c_sec_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORCSECTION"))
 DECLARE mf_cs72_labor_onset_meth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LABORONSETMETHODS"))
 DECLARE mf_cs72_induc_meth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INDUCTIONMETHODS"))
 DECLARE mf_cs72_gest_age_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GESTATIONALAGE"))
 DECLARE mf_cs72_interp_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATIONCATEGORY"))
 DECLARE mf_cs72_ad_pelv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADEQUATEPELVIMETRYFORVAGINALDELIVERY"))
 DECLARE mf_cs72_nbr_contr_10_min_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFCONTRACTIONSPER10MINUTES"))
 DECLARE mf_cs72_aug_meth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "AUGMENTATIONMETHODS"))
 DECLARE ms_cs72_est_fet_wt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDFETALWEIGHT"))
 DECLARE ms_cs72_trans_to_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Transferred To:"))
 CALL echo(build2("mf_CS4002119_VAG_CD: ",mf_cs4002119_vag_cd))
 CALL echo(build2("mf_CS4002119_VAG_FOR_CD: ",mf_cs4002119_vag_for_cd))
 CALL echo(build2("mf_CS4002119_VAG_FOR_VAC_CD: ",mf_cs4002119_vag_for_vac_cd))
 CALL echo(build2("mf_CS4002119_VAG_VAC_CD: ",mf_cs4002119_vag_vac_cd))
 CALL echo(build2("mf_CS72_RSN_C_SEC_CD: ",mf_cs72_rsn_c_sec_cd))
 CALL echo(build2("mf_CS72_LABOR_ONSET_METH_CD: ",mf_cs72_labor_onset_meth_cd))
 CALL echo(build2("mf_CS72_INDUC_METH_CD: ",mf_cs72_induc_meth_cd))
 CALL echo(build2("mf_CS72_GEST_AGE_CD: ",mf_cs72_gest_age_cd))
 CALL echo(build2("mf_CS72_INTERP_CAT_CD: ",mf_cs72_interp_cat_cd))
 CALL echo(build2("mf_CS72_AD_PELV_CD: ",mf_cs72_ad_pelv_cd))
 CALL echo(build2("mf_CS72_NBR_CONTR_10_MIN_CD: ",mf_cs72_nbr_contr_10_min_cd))
 CALL echo(build2("mf_CS72_AUG_METH_CD: ",mf_cs72_aug_meth_cd))
 CALL echo(build2("ms_CS72_EST_FET_WT_CD: ",ms_cs72_est_fet_wt_cd))
 CALL echo(build2("ms_CS72_TRANS_TO_CD: ",ms_cs72_trans_to_cd))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_rpt_ob_pitocin_",format(sysdate,
    "mmddyyyy;;q"),".csv"))
 CALL echo(ms_filename)
 SELECT INTO "nl:"
  FROM pregnancy_child pc,
   pregnancy_instance pi,
   dummyt d1,
   clinical_event ce1
  PLAN (pc
   WHERE pc.pregnancy_id=pc.pregnancy_id
    AND pc.active_ind=1
    AND pc.gestation_age > 259
    AND pc.delivery_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (pi
   WHERE pi.active_ind=1
    AND pi.historical_ind=0)
   JOIN (d1)
   JOIN (ce1
   WHERE ce1.person_id=pi.person_id
    AND ce1.event_end_dt_tm BETWEEN pi.preg_start_dt_tm AND pi.preg_end_dt_tm
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
    AND ce1.event_cd IN (mf_cs72_rsn_c_sec_cd, ms_cs72_trans_to_cd))
  ORDER BY pi.person_id, pi.pregnancy_id, pc.delivery_dt_tm DESC,
   ce1.event_cd
  HEAD REPORT
   pl_cnt = 0
  HEAD pi.pregnancy_id
   IF (pc.gestation_age BETWEEN 259 AND 273)
    m_rec->l_deliv_cnt += 1, m_rec->l_deliv_37pls_cnt += 1
    IF (pc.delivery_method_cd IN (mf_cs4002119_vag_cd, mf_cs4002119_vag_for_cd,
    mf_cs4002119_vag_for_vac_cd, mf_cs4002119_vag_vac_cd))
     m_rec->l_elect_deliv_cnt += 1
    ENDIF
   ELSE
    m_rec->l_deliv_37pls_cnt += 1
   ENDIF
  HEAD ce1.event_cd
   IF (ce1.event_cd=mf_cs72_rsn_c_sec_cd)
    IF ( NOT (pc.delivery_method_cd IN (mf_cs4002119_vag_cd, mf_cs4002119_vag_for_cd,
    mf_cs4002119_vag_for_vac_cd, mf_cs4002119_vag_vac_cd))
     AND ce1.result_val="Elective*")
     m_rec->l_elect_deliv_cnt += 1
    ENDIF
   ELSEIF (ce1.event_cd=ms_cs72_trans_to_cd)
    IF (trim(cnvtlower(ce1.result_val),3) IN ("nicu", "special care nursery"))
     CALL echo(build2("person_id: ",pi.person_id,"preg_id: ",pi.pregnancy_id)), m_rec->l_trans_cnt
      += 1
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   person p,
   encntr_alias ea,
   dummyt d,
   clinical_event ce2
  PLAN (ce1
   WHERE ce1.event_cd=mf_cs72_labor_onset_meth_cd
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
    AND trim(cnvtlower(ce1.result_val),3)="induced"
    AND  EXISTS (
   (SELECT
    ce3.event_cd
    FROM clinical_event ce3
    WHERE ce3.encntr_id=ce1.encntr_id
     AND ce3.event_cd=mf_cs72_induc_meth_cd
     AND ce3.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
     AND trim(cnvtlower(ce3.result_val),3)="pitocin")))
   JOIN (p
   WHERE p.person_id=ce1.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ce1.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (d)
   JOIN (ce2
   WHERE ce2.encntr_id=ce1.encntr_id
    AND ce2.event_cd IN (mf_cs72_gest_age_cd, mf_cs72_interp_cat_cd, mf_cs72_ad_pelv_cd,
   mf_cs72_nbr_contr_10_min_cd)
    AND ce2.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd))
  ORDER BY ce1.encntr_id, ce1.event_cd, ce1.event_end_dt_tm DESC,
   ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0, pl_add = 0, pl_gest = 0,
   pl_int = 0, pl_pelv = 0, pl_contr = 0
  HEAD ce1.encntr_id
   pl_cnt += 1, m_rec->l_ind_den_cnt += 1, pl_add = 0,
   pl_gest = 0, pl_int = 0, pl_pelv = 0,
   pl_contr = 0
   IF (pl_cnt > size(m_rec->ind,5))
    CALL alterlist(m_rec->ind,(pl_cnt+ 10))
   ENDIF
   m_rec->ind[pl_cnt].f_encntr_id = ce1.encntr_id, m_rec->ind[pl_cnt].f_person_id = ce1.person_id,
   m_rec->ind[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->ind[pl_cnt].s_fin = trim(ea.alias,3), m_rec->ind[pl_cnt].s_labor_onset = trim(ce1
    .result_val,3)
  DETAIL
   pl_add = 0
   IF (ce2.event_cd=mf_cs72_gest_age_cd
    AND pl_gest=0)
    pl_gest = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_interp_cat_cd
    AND pl_int=0)
    pl_int = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_ad_pelv_cd
    AND pl_pelv=0)
    pl_pelv = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_nbr_contr_10_min_cd
    AND pl_contr=0)
    pl_contr = 1, pl_add = 1
   ENDIF
   IF (pl_add=1)
    IF (textlen(trim(m_rec->ind[pl_cnt].s_events,3)) > 0)
     m_rec->ind[pl_cnt].s_events = concat(m_rec->ind[pl_cnt].s_events,", ",trim(uar_get_code_display(
        ce2.event_cd),3))
    ELSE
     m_rec->ind[pl_cnt].s_events = concat(m_rec->ind[pl_cnt].s_events,trim(uar_get_code_display(ce2
        .event_cd),3))
    ENDIF
   ENDIF
  FOOT  ce1.encntr_id
   IF (((((pl_gest+ pl_int)+ pl_pelv)+ pl_contr)=4))
    m_rec->l_ind_num_cnt += 1
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->ind,pl_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   person p,
   encntr_alias ea,
   dummyt d,
   clinical_event ce2
  PLAN (ce1
   WHERE ce1.event_cd=mf_cs72_labor_onset_meth_cd
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
    AND trim(cnvtlower(ce1.result_val),3)="augmented"
    AND  EXISTS (
   (SELECT
    ce3.event_cd
    FROM clinical_event ce3
    WHERE ce3.encntr_id=ce1.encntr_id
     AND ce3.event_cd=mf_cs72_aug_meth_cd
     AND ce3.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
     AND trim(cnvtlower(ce3.result_val),3)="oxytocin infusion")))
   JOIN (p
   WHERE p.person_id=ce1.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ce1.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (d)
   JOIN (ce2
   WHERE ce2.encntr_id=ce1.encntr_id
    AND ce2.event_cd IN (ms_cs72_est_fet_wt_cd, mf_cs72_interp_cat_cd, mf_cs72_ad_pelv_cd,
   mf_cs72_nbr_contr_10_min_cd)
    AND ce2.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd))
  ORDER BY ce1.encntr_id, ce1.event_cd, ce1.event_end_dt_tm DESC,
   ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = size(m_rec->ind,5), pl_add = 0, pl_wt = 0,
   pl_int = 0, pl_pelv = 0, pl_contr = 0
  HEAD ce1.encntr_id
   pl_cnt += 1, m_rec->l_aug_den_cnt += 1, pl_add = 0,
   pl_wt = 0, pl_int = 0, pl_pelv = 0,
   pl_contr = 0
   IF (pl_cnt > size(m_rec->ind,5))
    CALL alterlist(m_rec->ind,(pl_cnt+ 10))
   ENDIF
   m_rec->ind[pl_cnt].f_encntr_id = ce1.encntr_id, m_rec->ind[pl_cnt].f_person_id = ce1.person_id,
   m_rec->ind[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->ind[pl_cnt].s_fin = trim(ea.alias,3), m_rec->ind[pl_cnt].s_labor_onset = trim(ce1
    .result_val,3)
  DETAIL
   pl_add = 0
   IF (ce2.event_cd=ms_cs72_est_fet_wt_cd
    AND pl_wt=0)
    pl_wt = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_interp_cat_cd
    AND pl_int=0)
    pl_int = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_ad_pelv_cd
    AND pl_pelv=0)
    pl_pelv = 1, pl_add = 1
   ELSEIF (ce2.event_cd=mf_cs72_nbr_contr_10_min_cd
    AND pl_contr=0)
    pl_contr = 1, pl_add = 1
   ENDIF
   IF (pl_add=1)
    IF (textlen(trim(m_rec->ind[pl_cnt].s_events,3)) > 0)
     m_rec->ind[pl_cnt].s_events = concat(m_rec->ind[pl_cnt].s_events,", ",trim(uar_get_code_display(
        ce2.event_cd),3))
    ELSE
     m_rec->ind[pl_cnt].s_events = concat(m_rec->ind[pl_cnt].s_events,trim(uar_get_code_display(ce2
        .event_cd),3))
    ENDIF
   ENDIF
  FOOT  ce1.encntr_id
   IF (((((pl_wt+ pl_int)+ pl_pelv)+ pl_contr)=4))
    m_rec->l_aug_num_cnt += 1
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->ind,pl_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("CCLIO")
 SET frec->file_name = ms_filename
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build2('"SUMMARY:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"% elective deliveries",')
 IF ((m_rec->l_elect_deliv_cnt=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_rec->l_deliv_cnt)/
     cnvtreal(m_rec->l_elect_deliv_cnt)) * 100),3,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build2('"% elective induction",')
 IF ((m_rec->l_ind_den_cnt=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_rec->l_ind_num_cnt)/
     cnvtreal(m_rec->l_ind_den_cnt)) * 100),3,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build2('"% augmentation",')
 IF ((m_rec->l_aug_den_cnt=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_rec->l_aug_num_cnt)/
     cnvtreal(m_rec->l_aug_den_cnt)) * 100),3,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build2('"% neonates transfered",')
 IF ((m_rec->l_deliv_37pls_cnt=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_rec->l_trans_cnt)/
     cnvtreal(m_rec->l_deliv_37pls_cnt)) * 100),3,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"Patient Name","FIN","Labor Onset Method","Events Charted"',char(13))
 SET stat = cclio("WRITE",frec)
 FOR (ml_loop = 1 TO size(m_rec->ind,5))
  SET frec->file_buf = concat('"',m_rec->ind[ml_loop].s_pat_name,'",','"',m_rec->ind[ml_loop].s_fin,
   '",','"',m_rec->ind[ml_loop].s_labor_onset,'",','"',
   m_rec->ind[ml_loop].s_events,'"',char(13))
  SET stat = cclio("WRITE",frec)
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 IF (findstring("@",ms_email) > 0)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("PCM OB Pitocin Report: ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
  IF (( $OUTDEV != "OPS"))
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
     "{F/1}{CPI/7}", "Report finished and file was sent to provided e-mail.", row + 2,
     ms_email, row + 2, "Filename:",
     frec->file_name
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
    "{F/1}{CPI/7}", "Invalid e-mail.", row + 2,
    "File saved to backend.", row + 2, frec->file_name
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
