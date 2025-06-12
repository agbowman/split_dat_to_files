CREATE PROGRAM bhs_gvw_ipoc_form:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_admit_dt = vc
   1 s_admit_diag = vc
   1 s_work_diag = vc
   1 s_attending_md = vc
   1 s_rovt_line = vc
   1 s_resus_line = vc
   1 s_rest_line = vc
   1 s_card_line = vc
   1 s_proxy_line = vc
   1 s_proxycontact_line = vc
   1 s_goalstoday_line = vc
   1 s_importanttoday_line = vc
   1 s_nextsteps_line = vc
   1 s_riskcriteria_line = vc
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mf_working_diag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",17,"WORKING"))
 DECLARE mf_admit_diag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",17,"ADMITTING"))
 DECLARE mf_attendingdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mf_rovt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RISKOFVENOUSTHROMBOEMBOLISM"))
 DECLARE mf_fpr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLPERIOPERATIVERESUSCITATION"))
 DECLARE mf_fr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FULLRESUSCITATION"))
 DECLARE mf_lpr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LIMITEDPERIOPERATIVERESUSCITATION"))
 DECLARE mf_lr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LIMITEDRESUSCITATION"
   ))
 DECLARE mf_npr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NOPERIOPERATIVERESUSCITATION"))
 DECLARE mf_nr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NORESUSCITATION"))
 DECLARE mf_rest_adol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSADOL"))
 DECLARE mf_rest_med_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSMEDSURG"))
 DECLARE mf_rest_psych_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSPSYCH"))
 DECLARE mf_rest_d9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSVIOLENTSELFDESTRUCAGE9"))
 DECLARE mf_rest_d917_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSVIOLENTSELFDESTRUCAGE917"))
 DECLARE mf_rest_dest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSVIOLENTSELFDESTRUCTIVE"))
 DECLARE mf_cardiacmonitor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOR"))
 DECLARE mf_cardiacmonitoredonly_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOREDONLY"))
 DECLARE mf_dta_proxy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
 DECLARE mf_dta_proxycontact_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE mf_dta_highriskscreen_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HIGHRISKCRITERIASCREEN"))
 DECLARE mf_dta_goalstoday_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTFAMILYTEAMSGOALSFORTODAY"))
 DECLARE mf_dta_importanttoday_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WHATSIMPORTANTTOTHEPTFAMILYTODAY"))
 DECLARE mf_dta_plannextsteps_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PLANNEXTSTEPS"))
 DECLARE mf_os_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE mf_os_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_od_otherreason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERREASON"))
 DECLARE ms_out = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_id=mf_encntr_id
  DETAIL
   m_rec->s_admit_dt = trim(format(cnvtdate(e.reg_dt_tm),"MM/DD/YYYY ;;D"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d
  WHERE d.encntr_id=mf_encntr_id
   AND d.active_ind=1
   AND d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND d.diag_type_cd IN (mf_working_diag_cd, mf_admit_diag_cd)
  ORDER BY d.diagnosis_id
  DETAIL
   IF (d.diag_type_cd=mf_working_diag_cd)
    IF (size(trim(m_rec->s_work_diag))=0)
     m_rec->s_work_diag = trim(d.diagnosis_display,3)
    ELSE
     m_rec->s_work_diag = concat(m_rec->s_work_diag,"; ",trim(d.diagnosis_display,3))
    ENDIF
   ELSEIF (d.diag_type_cd=mf_admit_diag_cd)
    IF (size(trim(m_rec->s_admit_diag))=0)
     m_rec->s_admit_diag = trim(d.diagnosis_display,3)
    ELSE
     m_rec->s_admit_diag = concat(m_rec->s_admit_diag,"; ",trim(d.diagnosis_display,3))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   person p
  PLAN (epr
   WHERE epr.encntr_id=mf_encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND epr.encntr_prsnl_r_cd=mf_attendingdoc_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF"
    AND p.person_id != 0)
  ORDER BY epr.beg_effective_dt_tm DESC
  HEAD REPORT
   m_rec->s_attending_md = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   person p
  PLAN (o
   WHERE o.encntr_id=mf_encntr_id
    AND o.catalog_cd IN (mf_rovt_cd, mf_fpr_cd, mf_fr_cd, mf_lpr_cd, mf_lr_cd,
   mf_npr_cd, mf_nr_cd, mf_rest_adol_cd, mf_rest_med_cd, mf_rest_psych_cd,
   mf_rest_d9_cd, mf_rest_d917_cd, mf_rest_dest_cd, mf_cardiacmonitor_cd, mf_cardiacmonitoredonly_cd)
    AND o.order_status_cd IN (mf_os_completed_cd, mf_os_ordered_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  ORDER BY o.orig_order_dt_tm DESC
  DETAIL
   IF (size(trim(m_rec->s_rovt_line,3))=0)
    IF (o.catalog_cd=mf_rovt_cd
     AND o.order_status_cd=mf_os_completed_cd)
     m_rec->s_rovt_line = concat(trim(o.ordered_as_mnemonic,3),": ",trim(o.clinical_display_line,3),
      "; ",trim(p.name_full_formatted,3))
    ENDIF
   ENDIF
   IF (size(trim(m_rec->s_resus_line,3))=0)
    IF (o.catalog_cd IN (mf_fpr_cd, mf_fr_cd, mf_lpr_cd, mf_lr_cd, mf_npr_cd,
    mf_nr_cd)
     AND o.order_status_cd=mf_os_ordered_cd)
     m_rec->s_resus_line = concat(trim(o.ordered_as_mnemonic,3),": ",trim(o.clinical_display_line,3),
      "; ",trim(p.name_full_formatted,3))
    ENDIF
   ENDIF
   IF (size(trim(m_rec->s_rest_line,3))=0)
    IF (o.catalog_cd IN (mf_rest_adol_cd, mf_rest_med_cd, mf_rest_psych_cd, mf_rest_d9_cd,
    mf_rest_d917_cd,
    mf_rest_dest_cd)
     AND o.order_status_cd=mf_os_ordered_cd)
     m_rec->s_rest_line = concat(trim(o.ordered_as_mnemonic,3),": ",trim(o.clinical_display_line,3),
      "; ",trim(p.name_full_formatted,3))
    ENDIF
   ENDIF
   IF (size(trim(m_rec->s_card_line,3))=0)
    IF (o.catalog_cd IN (mf_cardiacmonitor_cd, mf_cardiacmonitoredonly_cd)
     AND o.order_status_cd=mf_os_ordered_cd)
     m_rec->s_card_line = concat(trim(o.ordered_as_mnemonic,3),": ",trim(o.clinical_display_line,3),
      "; ",trim(p.name_full_formatted,3))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=mf_encntr_id
   AND ce.event_cd IN (mf_dta_highriskscreen_cd, mf_dta_proxy_cd, mf_dta_proxycontact_cd,
  mf_dta_goalstoday_cd, mf_dta_importanttoday_cd,
  mf_dta_plannextsteps_cd)
   AND ce.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime3)
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce.valid_from_dt_tm DESC
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_dta_highriskscreen_cd:
     m_rec->s_riskcriteria_line = trim(ce.result_val,3)
    OF mf_dta_proxy_cd:
     m_rec->s_proxy_line = trim(ce.result_val,3)
    OF mf_dta_proxycontact_cd:
     m_rec->s_proxycontact_line = trim(ce.result_val,3)
    OF mf_dta_goalstoday_cd:
     m_rec->s_goalstoday_line = trim(ce.result_val,3)
    OF mf_dta_importanttoday_cd:
     m_rec->s_importanttoday_line = trim(ce.result_val,3)
    OF mf_dta_plannextsteps_cd:
     m_rec->s_nextsteps_line = trim(ce.result_val,3)
   ENDCASE
  WITH nocounter
 ;end select
 SET ms_out = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET ms_out = concat(ms_out,"\fs18\b ","Admit Date:"," \b0 ",m_rec->s_admit_dt,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Admitting Diagnosis:"," \b0 ",m_rec->s_admit_diag,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Working Diagnosis:"," \b0 ",m_rec->s_work_diag,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Attending MD:"," \b0 ",m_rec->s_attending_md,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Contact Proxy:"," \b0 ",m_rec->s_proxy_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Proxy Phone Number:"," \b0 ",m_rec->s_proxycontact_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Cardiac Monitor:"," \b0 ",m_rec->s_card_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Risk of Venous Thromboembolism:"," \b0 ",m_rec->s_rovt_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Restraints:"," \b0 ",m_rec->s_rest_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Resuscitation orders:"," \b0 ",m_rec->s_resus_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Pt/Family's & Teams' Goals for Day:"," \b0 ",m_rec->
  s_goalstoday_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","What's important to the Pt/Family today:"," \b0 ",m_rec->
  s_importanttoday_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Plan/Next Steps:"," \b0 ",m_rec->s_nextsteps_line,
  " \line ")
 SET ms_out = concat(ms_out,"\b ","Risk Criteria:"," \b0 ",m_rec->s_riskcriteria_line,
  " \line ")
 SET reply->text = build2(ms_out,"}")
END GO
