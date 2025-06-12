CREATE PROGRAM bhs_rpt_him_dictation
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Date Type:" = 0,
  "Start Date/Time" = "CURDATE",
  "End Date/Time" = "CURDATE"
  WITH outdev, n_date_type, s_start_dt_tm,
  s_end_dt_tm
 DECLARE mf_modified_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"MODIFIED")), protect
 DECLARE mf_authverified_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")),
 protect
 DECLARE mf_preliminary_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"PRELIMINARY")), protect
 DECLARE mf_primarycarephysician_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "PRIMARYCAREPHYSICIAN")), protect
 DECLARE mf_mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_finnbr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_requested_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"REQUESTED")), protect
 DECLARE mf_completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED")), protect
 DECLARE mf_order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"ORDER")), protect
 DECLARE mf_transcribe_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"TRANSCRIBE")), protect
 DECLARE mf_sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN")), protect
 DECLARE mf_perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM")), protect
 DECLARE mf_modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"MODIFY")), protect
 DECLARE mf_nuance_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"NUANCE")), protect
 DECLARE mf_inerror1_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror2_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerror3_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_inerror4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_unauth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_inlab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE mf_rejected_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE mf_unknown_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE ms_start_dt_tm = vc WITH protect, constant(trim(concat( $S_START_DT_TM," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(concat( $S_END_DT_TM," 23:59:59")))
 DECLARE ms_dictation_start_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_dictation_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_transcribed_start_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_transcribed_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mf_event_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE pl_cnt = i4 WITH public, noconstant(0)
 DECLARE pl_cnt1 = i4 WITH public, noconstant(0)
 FREE RECORD m_him
 RECORD m_him(
   1 pat[*]
     2 s_name = vc
     2 s_pat_type = vc
     2 s_pat_loc = vc
     2 s_pat_fac = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_pcp = vc
     2 s_admit_dt_tm = vc
     2 s_disch_dt_tm = vc
     2 s_service_dt_tm = vc
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 event[*]
       3 f_event_id = f8
       3 s_doc_type = vc
       3 s_doc_type1 = vc
       3 s_doc_id = vc
       3 s_ord_id = vc
       3 s_ord_dt_tm = vc
       3 s_ord_phy_name = vc
       3 s_dic_dt_tm = vc
       3 s_dic_phys_name = vc
       3 s_trans_dt_tm = vc
       3 s_trans_phys_name = vc
       3 s_sign_dt_tm = vc
       3 s_sign_phys_name = vc
       3 s_cosign_phys_name = vc
       3 s_mod_dt_tm = vc
       3 s_mod_name = vc
 )
 IF (( $N_DATE_TYPE=1))
  SET ms_dictation_start_dt_tm = ms_start_dt_tm
  SET ms_dictation_end_dt_tm = ms_end_dt_tm
 ELSEIF (( $N_DATE_TYPE=2))
  SET ms_transcribed_start_dt_tm = ms_start_dt_tm
  SET ms_transcribed_end_dt_tm = ms_end_dt_tm
 ENDIF
 CALL echo(build("ms_dictation_start_dt_tm = ",format(cnvtdatetime(ms_dictation_start_dt_tm),
    "mm/dd/yyyy hh:mm")))
 CALL echo(build("ms_dictation_end_dt_tm = ",format(cnvtdatetime(ms_dictation_end_dt_tm),
    "mm/dd/yyyy hh:mm")))
 CALL echo(build("ms_transcribed_start_dt_tm = ",format(cnvtdatetime(ms_transcribed_start_dt_tm),
    "mm/dd/yyyy hh:mm")))
 CALL echo(build("ms_transcribed_end_dt_tm = ",format(cnvtdatetime(ms_transcribed_end_dt_tm),
    "mm/dd/yyyy hh:mm")))
 SET ms_output_dest =  $OUTDEV
 IF (( $N_DATE_TYPE=1))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    ce_event_prsnl cep
   PLAN (ce
    WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(ms_dictation_start_dt_tm) AND cnvtdatetime(
     ms_dictation_end_dt_tm)
     AND ce.contributor_system_cd=mf_nuance_cd
     AND ce.view_level=1
     AND ce.valid_until_dt_tm > sysdate
     AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
    mf_inprogress_cd,
    mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
    mf_unknown_cd))
     AND ce.event_tag != "In Error")
    JOIN (cep
    WHERE cep.event_id=ce.event_id
     AND cep.action_type_cd=mf_perform_cd
     AND cep.valid_until_dt_tm > sysdate)
   ORDER BY ce.encntr_id, ce.event_id
   HEAD REPORT
    pl_cnt = 0
   HEAD ce.encntr_id
    pl_cnt1 = 0, pl_cnt = (pl_cnt+ 1), stat = alterlist(m_him->pat,pl_cnt),
    m_him->pat[pl_cnt].f_encntr_id = ce.encntr_id, m_him->pat[pl_cnt].f_person_id = ce.person_id
   HEAD ce.event_id
    pl_cnt1 = (pl_cnt1+ 1), stat = alterlist(m_him->pat[pl_cnt].event,pl_cnt1), m_him->pat[pl_cnt].
    event[pl_cnt1].f_event_id = ce.event_id,
    m_him->pat[pl_cnt].event[pl_cnt1].s_doc_type = ce.event_title_text, m_him->pat[pl_cnt].event[
    pl_cnt1].s_doc_type1 = uar_get_code_display(ce.event_cd), m_him->pat[pl_cnt].event[pl_cnt1].
    s_doc_id = trim(ce.accession_nbr,3)
   WITH nocounter
  ;end select
 ELSEIF (( $N_DATE_TYPE=2))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    ce_event_prsnl cep
   PLAN (cep
    WHERE cep.person_id > 0
     AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_transcribed_start_dt_tm) AND cnvtdatetime(
     ms_transcribed_end_dt_tm)
     AND cep.action_status_cd IN (mf_requested_cd, mf_completed_cd)
     AND cep.action_type_cd=mf_transcribe_cd
     AND cep.valid_until_dt_tm > sysdate)
    JOIN (ce
    WHERE ce.event_id=cep.event_id
     AND ce.valid_until_dt_tm > sysdate
     AND ce.contributor_system_cd=mf_nuance_cd
     AND ce.view_level=1
     AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
    mf_inprogress_cd,
    mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
    mf_unknown_cd))
     AND ce.event_tag != "In Error")
   HEAD REPORT
    pl_cnt = 0
   HEAD ce.encntr_id
    pl_cnt1 = 0, pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > size(m_him->pat,5))
     stat = alterlist(m_him->pat,pl_cnt)
    ENDIF
    m_him->pat[pl_cnt].f_encntr_id = ce.encntr_id, m_him->pat[pl_cnt].f_person_id = ce.person_id
   HEAD ce.event_id
    pl_cnt1 = (pl_cnt1+ 1), stat = alterlist(m_him->pat[pl_cnt].event,pl_cnt1), m_him->pat[pl_cnt].
    event[pl_cnt1].f_event_id = ce.event_id,
    m_him->pat[pl_cnt].event[pl_cnt1].s_doc_type = ce.event_title_text, m_him->pat[pl_cnt].event[
    pl_cnt1].s_doc_type1 = uar_get_code_display(ce.event_cd), m_him->pat[pl_cnt].event[pl_cnt1].
    s_doc_id = trim(ce.accession_nbr,3)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_him->pat,5))),
   (dummyt d2  WITH seq = 1),
   ce_event_prsnl cep,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(m_him->pat[d1.seq].event,5)))
   JOIN (d2)
   JOIN (cep
   WHERE (cep.event_id=m_him->pat[d1.seq].event[d2.seq].f_event_id)
    AND cep.action_status_cd IN (mf_requested_cd, mf_completed_cd)
    AND cep.action_type_cd IN (mf_transcribe_cd, mf_perform_cd, mf_sign_cd, mf_modify_cd)
    AND cep.valid_until_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id)
  ORDER BY cep.person_id, cep.action_type_cd, cep.action_dt_tm DESC
  DETAIL
   IF (cep.action_type_cd=mf_transcribe_cd)
    m_him->pat[d1.seq].event[d2.seq].s_trans_phys_name = p.name_full_formatted, m_him->pat[d1.seq].
    event[d2.seq].s_trans_dt_tm = format(cep.action_dt_tm,";;q")
   ELSEIF (cep.action_type_cd=mf_perform_cd)
    m_him->pat[d1.seq].event[d2.seq].s_dic_phys_name = p.name_full_formatted, m_him->pat[d1.seq].
    event[d2.seq].s_dic_dt_tm = format(cep.action_dt_tm,";;q")
   ELSEIF (cep.action_type_cd=mf_sign_cd)
    IF (cep.action_status_cd=mf_completed_cd)
     m_him->pat[d1.seq].event[d2.seq].s_cosign_phys_name = p.name_full_formatted
    ENDIF
    m_him->pat[d1.seq].event[d2.seq].s_sign_phys_name = p.name_full_formatted, m_him->pat[d1.seq].
    event[d2.seq].s_sign_dt_tm = format(cep.action_dt_tm,";;q")
   ELSEIF (cep.action_type_cd=mf_modify_cd)
    m_him->pat[d1.seq].event[d2.seq].s_mod_name = p.name_full_formatted, m_him->pat[d1.seq].event[d2
    .seq].s_mod_dt_tm = format(cep.action_dt_tm,";;q")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_him->pat,5))),
   person p,
   encounter e,
   encntr_alias ea,
   prsnl pr,
   encntr_prsnl_reltn epr
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=m_him->pat[d1.seq].f_person_id))
   JOIN (e
   WHERE (e.encntr_id=m_him->pat[d1.seq].f_encntr_id)
    AND e.person_id=p.person_id
    AND e.end_effective_dt_tm > sysdate)
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(mf_primarycarephysician_cd))
   JOIN (pr
   WHERE outerjoin(epr.prsnl_person_id)=pr.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (mf_finnbr_cd, mf_mrn_cd))
  DETAIL
   m_him->pat[d1.seq].s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm"), m_him->pat[d1.seq].
   s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm"), m_him->pat[d1.seq].s_name = p
   .name_full_formatted,
   m_him->pat[d1.seq].s_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd), m_him->pat[d1.seq].
   s_pat_fac = uar_get_code_display(e.loc_facility_cd), m_him->pat[d1.seq].s_pat_type =
   uar_get_code_display(e.encntr_type_class_cd),
   m_him->pat[d1.seq].s_pcp = pr.name_full_formatted
   IF (ea.encntr_alias_type_cd=mf_finnbr_cd)
    m_him->pat[d1.seq].s_fin = ea.alias
   ELSEIF (ea.encntr_alias_type_cd=mf_mrn_cd)
    m_him->pat[d1.seq].s_mrn = ea.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_him->pat,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce,
   orders o,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,size(m_him->pat[d1.seq].event,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.event_id=m_him->pat[d1.seq].event[d2.seq].f_event_id))
   JOIN (o
   WHERE o.order_id=cnvtreal(substring(1,10,ce.reference_nbr)))
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
  DETAIL
   m_him->pat[d1.seq].event[d2.seq].s_ord_id = cnvtstring(o.order_id), m_him->pat[d1.seq].event[d2
   .seq].s_ord_dt_tm = format(o.current_start_dt_tm,";;q"), m_him->pat[d1.seq].event[d2.seq].
   s_ord_phy_name = pr.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO value(ms_output_dest)
  patient_name = substring(1,50,m_him->pat[d1.seq].s_name), mrn = substring(1,15,m_him->pat[d1.seq].
   s_mrn), fin = substring(1,15,m_him->pat[d1.seq].s_fin),
  patient_type = substring(1,15,m_him->pat[d1.seq].s_pat_type), patient_facility = substring(1,30,
   m_him->pat[d1.seq].s_pat_fac), patient_loc = substring(1,30,m_him->pat[d1.seq].s_pat_loc),
  patient_pcp = substring(1,50,m_him->pat[d1.seq].s_pcp), admit_dt_tm = substring(1,30,m_him->pat[d1
   .seq].s_admit_dt_tm), discharge_dt_tm = substring(1,30,m_him->pat[d1.seq].s_disch_dt_tm),
  dictated_work_title = substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_doc_type),
  dictated_work_type = substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_doc_type1), dictated_id =
  substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_doc_id),
  dictation_dt_tm = substring(1,30,m_him->pat[d1.seq].event[d2.seq].s_dic_dt_tm), dictation_by =
  substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_dic_phys_name), transcribed_dt_tm = substring(1,
   30,m_him->pat[d1.seq].event[d2.seq].s_trans_dt_tm),
  transcribed_by = substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_trans_phys_name), signed_dt_tm
   = substring(1,30,m_him->pat[d1.seq].event[d2.seq].s_sign_dt_tm), signed_by = substring(1,50,m_him
   ->pat[d1.seq].event[d2.seq].s_sign_phys_name),
  cosign_phy_name = substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_cosign_phys_name), order_id =
  substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_ord_id), order_date = substring(1,50,m_him->pat[
   d1.seq].event[d2.seq].s_ord_dt_tm),
  ordering_phy_name = substring(1,50,m_him->pat[d1.seq].event[d2.seq].s_ord_phy_name)
  FROM (dummyt d1  WITH seq = value(size(m_him->pat,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_him->pat[d1.seq].event,5)))
   JOIN (d2)
  ORDER BY patient_name, m_him->pat[d1.seq].event[d2.seq].s_dic_dt_tm DESC
  WITH separator = " ", format, skipreport = 1
 ;end select
 CALL echorecord(m_him)
#exit_script
END GO
