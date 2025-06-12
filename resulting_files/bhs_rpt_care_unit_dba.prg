CREATE PROGRAM bhs_rpt_care_unit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter beginning date:" = "CURDATE",
  "Enter end date:" = "CURDATE",
  "Enter email:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email_adr
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_form_cntr = i4
   1 form[*]
     2 s_event_end_dt_tm = vc
     2 s_pat_name = vc
     2 f_person_id = f8
     2 s_fin = vc
     2 s_attendmd = vc
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_room = vc
     2 f_encntr_id = f8
     2 s_reason_f_visit = vc
     2 s_prologn_stay = vc
     2 s_preadm_tm = vc
     2 s_preproced_tm = vc
     2 s_post_intv_tm = vc
     2 s_prm_recov_tm = vc
     2 s_scnd_recov_tm = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_reason_for_visit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREUNITREASONFORVISITCHG"))
 DECLARE mf_prlgn_stay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREUNITPROLONGEDSTAYCHG"))
 DECLARE mf_pr_procdr_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPREPROCEDURETIMECHG"))
 DECLARE mf_pt_intrv_rec_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPOSTINTERVENTIONRECOVERYTIMECHG"))
 DECLARE mf_prm_rec_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPRIMARYRECOVERYTIMECHG"))
 DECLARE mf_sec_rec_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARESECONDARYRECOVERYTIMECHG"))
 DECLARE mf_pradm_eval_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPREADMISSIONEVALTIMECHG"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_preadmit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMIT"))
 DECLARE mf_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_preadmitip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE gf_inerror1_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE gf_inerror2_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE gf_inerror3_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE gf_inerror4_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE gf_inprogress_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE gf_unauth_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE gf_not_done_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE gf_anticipated_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
 DECLARE gf_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE gf_c_transcribe_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"C_TRANSCRIBE"))
 DECLARE gf_in_lab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE gf_rejected_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE gf_superseded_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"SUPERSEDED"))
 DECLARE gf_unknown_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE gf_dictated_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"DICTATED"))
 DECLARE gf_transcribed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"TRANSCRIBED"))
 DECLARE gf_placeholder_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE mf_attendmd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_care_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"CARE"))
 DECLARE mf_clin_event_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT")
  )
 DECLARE ms_output_file = vc WITH protect, constant(concat("rpt_care_unit",cnvtstring(sysdate),".csv"
   ))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE mf_forms_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_email_cmd = vc WITH protect, noconstant(" ")
 DECLARE ml_email_cmd_size = i4 WITH protect, noconstant(0)
 DECLARE ml_email_status = i4 WITH protect, noconstant(0)
 DECLARE ms_email_title = vc WITH protect, noconstant(" ")
 DECLARE ms_email_address = vc WITH protect, noconstant(trim( $S_EMAIL_ADR))
 DECLARE ml_fcnt = i4 WITH protect, noconstant(0)
 DECLARE ms_temp_str = vc WITH protect, noconstant(" ")
 DECLARE pd_output_sort_date = dq8 WITH private, noconstant(0)
 IF (validate(request->batch_selection))
  SET ms_beg_dt_tm = concat(trim(format(cnvtlookbehind("8,D",sysdate),"dd-mmm-yyyy;;d"))," 00:00:00")
  SET ms_end_dt_tm = concat(trim(format(cnvtlookbehind("1,D",sysdate),"dd-mmm-yyyy;;d"))," 23:59:59")
  SET ms_email_address = "Grace.LaValley@baystatehealth.org, Kimberly.Gamache@baystatehealth.org"
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.description="CARE Unit Charge Guide"
   AND dfr.active_ind=1
   AND dfr.end_effective_dt_tm > sysdate
  DETAIL
   mf_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce1,
   encounter e,
   clinical_event ce2
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_forms_ref_id
    AND dfa.active_ind=1
    AND dfa.form_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND  NOT (dfa.form_status_cd IN (gf_inerror1_cd, gf_inerror2_cd, gf_inerror3_cd, gf_inerror4_cd,
   gf_unauth_cd,
   gf_not_done_cd, gf_anticipated_cd, gf_cancelled_cd, gf_c_transcribe_cd, gf_in_lab_cd,
   gf_inprogress_cd, gf_rejected_cd, gf_superseded_cd, gf_unknown_cd, gf_dictated_cd,
   gf_transcribed_cd)))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=mf_clin_event_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=dfac.parent_entity_id
    AND ce1.valid_until_dt_tm > sysdate
    AND ce1.encntr_id=dfa.encntr_id)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id
    AND e.encntr_type_cd IN (mf_daystay_cd, mf_inpatient_cd, mf_observation_cd, mf_preadmit_cd,
   mf_preadmitdaystay_cd,
   mf_preadmitip_cd, mf_dischdaystay_cd, mf_dischip_cd, mf_dischobv_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.view_level=1
    AND ce2.event_class_cd != gf_placeholder_cd
    AND  NOT (ce2.result_status_cd IN (gf_inerror1_cd, gf_inerror2_cd, gf_inerror3_cd, gf_inerror4_cd,
   gf_inprogress_cd,
   gf_unauth_cd, gf_not_done_cd, gf_anticipated_cd, gf_cancelled_cd, gf_c_transcribe_cd,
   gf_in_lab_cd, gf_inprogress_cd, gf_rejected_cd, gf_superseded_cd, gf_unknown_cd))
    AND ce2.event_cd IN (mf_reason_for_visit_cd, mf_prlgn_stay_cd, mf_pr_procdr_tm_cd,
   mf_pt_intrv_rec_cd, mf_prm_rec_tm_cd,
   mf_sec_rec_tm_cd, mf_pradm_eval_tm_cd))
  ORDER BY ce1.parent_event_id, ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   m_rec->l_form_cntr = 0
  HEAD ce1.parent_event_id
   m_rec->l_form_cntr += 1, stat = alterlist(m_rec->form,m_rec->l_form_cntr), m_rec->form[m_rec->
   l_form_cntr].f_encntr_id = ce1.encntr_id,
   m_rec->form[m_rec->l_form_cntr].s_event_end_dt_tm = trim(format(dfa.form_dt_tm,
     "DD-MMM-YYYY HH:MM:SS ;;d"),3)
  DETAIL
   CASE (ce2.event_cd)
    OF mf_reason_for_visit_cd:
     m_rec->form[m_rec->l_form_cntr].s_reason_f_visit = trim(ce2.result_val,3)
    OF mf_prlgn_stay_cd:
     m_rec->form[m_rec->l_form_cntr].s_prologn_stay = trim(ce2.result_val,3)
    OF mf_pr_procdr_tm_cd:
     m_rec->form[m_rec->l_form_cntr].s_preproced_tm = trim(ce2.result_val,3)
    OF mf_pt_intrv_rec_cd:
     m_rec->form[m_rec->l_form_cntr].s_post_intv_tm = trim(ce2.result_val,3)
    OF mf_prm_rec_tm_cd:
     m_rec->form[m_rec->l_form_cntr].s_prm_recov_tm = trim(ce2.result_val,3)
    OF mf_sec_rec_tm_cd:
     m_rec->form[m_rec->l_form_cntr].s_scnd_recov_tm = trim(ce2.result_val,3)
    OF mf_pradm_eval_tm_cd:
     m_rec->form[m_rec->l_form_cntr].s_preadm_tm = trim(ce2.result_val,3)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->form,5))),
   encounter e,
   encntr_alias ea,
   person p
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=m_rec->form[d.seq].f_encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_id=e.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.name_full_formatted
  DETAIL
   m_rec->form[d.seq].s_pat_name = trim(p.name_full_formatted,3), m_rec->form[d.seq].s_fin = trim(ea
    .alias,3), m_rec->form[d.seq].f_person_id = p.person_id,
   m_rec->form[d.seq].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->form[d.seq].
   s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)), m_rec->form[d.seq].s_room = trim(
    uar_get_code_display(e.loc_room_cd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->form,5))),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=m_rec->form[d.seq].f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_attendmd_cd
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  ORDER BY d.seq, epr.end_effective_dt_tm DESC
  DETAIL
   IF (epr.encntr_prsnl_r_cd=mf_attendmd_cd
    AND trim(m_rec->form[d.seq].s_attendmd) <= " ")
    m_rec->form[d.seq].s_attendmd = substring(1,30,pr.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(ms_output_file)
  pd_output_sort_date = cnvtdatetime(m_rec->form[d.seq].s_event_end_dt_tm)
  FROM (dummyt d  WITH seq = value(size(m_rec->form,5)))
  PLAN (d)
  ORDER BY pd_output_sort_date
  HEAD REPORT
   col 0, ms_temp_str = concat('"CARE Unit Patient Statistics (',ms_beg_dt_tm," - ",ms_end_dt_tm,')"'
    ), ms_temp_str,
   row + 2, ms_temp_str = concat(
    '"DATE/TIME","PATIENT NAME","ATTENDING MD","LOCATION","REASON FOR VISIT",'), ms_temp_str = concat
   (ms_temp_str,'"PROLONGED CARE UNIT STAY","PREADMISSION EVALUATION TIME",'),
   ms_temp_str = concat(ms_temp_str,'"PRE PROCEDURE TIME","POST INTERVENTION TIME",'), ms_temp_str =
   concat(ms_temp_str,'"PRIMARY RECOVERY TIME","SECONDARY RECOVERY TIME"'), ms_temp_str
  DETAIL
   row + 1, col 0, ms_temp_str = concat('"',trim(m_rec->form[d.seq].s_event_end_dt_tm),'",'),
   ms_temp_str = concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_pat_name),'",'), ms_temp_str =
   concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_attendmd),'",'), ms_temp_str = concat(ms_temp_str,
    '"',trim(m_rec->form[d.seq].s_facility),"/",trim(m_rec->form[d.seq].s_nurse_unit),
    "/",trim(m_rec->form[d.seq].s_room),'",'),
   ms_temp_str = concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_reason_f_visit),'",'), ms_temp_str
    = concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_prologn_stay),'",'), ms_temp_str = concat(
    ms_temp_str,'"',trim(m_rec->form[d.seq].s_preadm_tm),'",'),
   ms_temp_str = concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_preproced_tm),'",'), ms_temp_str =
   concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_post_intv_tm),'",'), ms_temp_str = concat(
    ms_temp_str,'"',trim(m_rec->form[d.seq].s_prm_recov_tm),'",'),
   ms_temp_str = concat(ms_temp_str,'"',trim(m_rec->form[d.seq].s_scnd_recov_tm),'"'), ms_temp_str
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 500
 ;end select
 SET ms_email_title = concat('"','"CARE Unit Patient Statistics (',ms_beg_dt_tm," - ",ms_end_dt_tm,
  ')"','"')
 EXECUTE bhs_ma_email_file
 CALL emailfile(value(ms_output_file),ms_output_file,ms_email_address,ms_email_title,1)
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 = concat("Report has been emailed to: ",ms_email_address), col 0,
   "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1
  WITH dio = 08
 ;end select
 CALL echo(build("******* forms found: ",m_rec->l_form_cntr))
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
