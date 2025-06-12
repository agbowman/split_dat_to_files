CREATE PROGRAM bhs_rpt_amb_med_rec:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Location" = 999999,
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, f_location_cd, s_begin_date,
  s_end_date, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 amb[*]
     2 f_location_cd = f8
   1 prsnl[*]
     2 f_prsnl_id = f8
     2 l_notes_total = i4
     2 l_notes_complete = i4
     2 l_rec_total = i4
     2 l_rec_incomplete = i4
     2 l_rec_complete = i4
     2 s_location = vc
     2 s_provider = vc
     2 s_position = vc
   1 prsnl_sorted[*]
     2 l_notes_total = i4
     2 l_notes_incomplete = i4
     2 l_notes_complete = i4
     2 l_rec_total = i4
     2 l_rec_incomplete = i4
     2 l_rec_complete = i4
     2 s_location = vc
     2 s_provider = vc
     2 s_position = vc
     2 s_department = vc
     2 s_complete_note_pct = vc
     2 s_complete_rec_pct = vc
   1 enc[*]
     2 f_encntr_id = f8
     2 f_attending_id = f8
     2 notes[*]
       3 f_prsnl_id = f8
 ) WITH protect
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE mf_rec_complete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4002695,
   "COMPLETE"))
 DECLARE mf_rec_partial_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4002695,"PARTIAL"
   ))
 DECLARE mf_checkedin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14233,"ARRIVED"))
 DECLARE mf_attendingphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_reproductivemednote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REPRODUCTIVEMEDICINENOTEOFFICE"))
 DECLARE mf_adolescentnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADOLESCENTNOTEOFFICE"))
 DECLARE mf_allergyimmunnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALLERGYIMMUNOLOGYNOTEOFFICE"))
 DECLARE mf_anesthesiologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANESTHESIOLOGYNOTEOFFICE"))
 DECLARE mf_anticoagulationnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTICOAGULATIONNOTEOFFICE"))
 DECLARE mf_maternalfetalmednote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MATERNALFETALMEDICINENOTEOFFICE"))
 DECLARE mf_bariatricsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BARIATRICSURGERYNOTEOFFICE"))
 DECLARE mf_cardiologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIOLOGYNOTEOFFICE"))
 DECLARE mf_cardpulmrehabnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIOPULMONARYREHABNOTEOFFICE"))
 DECLARE mf_breastwellnessnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BREASTANDWELLNESSNOTEOFFICE"))
 DECLARE mf_dentaloralsurgnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DENTALORALSURGERYNOTEOFFICE"))
 DECLARE mf_dermatologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DERMATOLOGYNOTEOFFICE"))
 DECLARE mf_endocrinologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENDOCRINOLOGYNOTEOFFICE"))
 DECLARE mf_gastroenterologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GASTROENTEROLOGYNOTEOFFICE"))
 DECLARE mf_generalmedicinenote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENERALMEDICINENOTEOFFICE"))
 DECLARE mf_generalsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENERALSURGERYNOTEOFFICE"))
 DECLARE mf_geriatricnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GERIATRICNOTEOFFICE"))
 DECLARE mf_gynecologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNECOLOGYNOTEOFFICE"))
 DECLARE mf_hematologyoncnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMATOLOGYONCOLOGYNOTEOFFICE"))
 DECLARE mf_infectdiseasenote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIOUSDISEASENOTEOFFICE"))
 DECLARE mf_neurologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEUROLOGYNOTEOFFICE"))
 DECLARE mf_neurosurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEUROSURGERYNOTEOFFICE"))
 DECLARE mf_painmanagementnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PAINMANAGEMENTNOTEOFFICE"))
 DECLARE mf_geneticsnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENETICSNOTEOFFICE"))
 DECLARE mf_plasticsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PLASTICSURGERYNOTEOFFICE"))
 DECLARE mf_pulmonarynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYNOTEOFFICE"))
 DECLARE mf_radoncologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RADIATIONONCOLOGYNOTEOFFICE"))
 DECLARE mf_physicalmedrehabnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHYSICALMEDREHABNOTEOFFICE"))
 DECLARE mf_surgicaloncologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SURGICALONCOLOGYNOTEOFFICE"))
 DECLARE mf_thoracicsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "THORACICSURGERYNOTEOFFICE"))
 DECLARE mf_transservicesnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSPLANTSERVICESNOTEOFFICE"))
 DECLARE mf_vascularsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VASCULARSURGERYNOTEOFFICE"))
 DECLARE mf_woundcarehbonote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDCAREHBONOTEOFFICE"))
 DECLARE mf_cardiacsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACSURGERYNOTEOFFICE"))
 DECLARE mf_urologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "UROLOGYNOTEOFFICE"))
 DECLARE mf_entnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ENTNOTEOFFICE"))
 DECLARE mf_occhealthnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OCCUPATIONALHEALTHNOTEOFFICE"))
 DECLARE mf_ophthalmologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OPHTHALMOLOGYNOTEOFFICE"))
 DECLARE mf_orthopedicnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORTHOPEDICNOTEOFFICE"))
 DECLARE mf_genpedinote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENERALPEDIATRICSNOTEOFFICE"))
 DECLARE mf_podiatrynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PODIATRYNOTEOFFICE"))
 DECLARE mf_rheumatologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RHEUMATOLOGYNOTEOFFICE"))
 DECLARE mf_gensurgtraumanote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENERALSURGTRAUMASURGOFFICENOTE"))
 DECLARE mf_urogynecologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "UROGYNECOLOGYNOTEOFFICE"))
 DECLARE mf_growthnutritionnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GROWTHANDNUTRITIONNOTEOFFICE"))
 DECLARE mf_neuropsychologynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEUROPSYCHOLOGYNOTEOFFICE"))
 DECLARE mf_endocrinesurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENDOCRINESURGERYNOTEOFFICE"))
 DECLARE mf_restrictedgennote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESTRICTEDGENETICSOFFICENOTE"))
 DECLARE mf_pediatricsurgerynote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIATRICSURGERYOFFICENOTE"))
 DECLARE mf_colorectalofficenote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COLORECTALOFFICENOTE"))
 DECLARE mf_irofficeinitialnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "IROFFICEINITIALNOTE"))
 DECLARE mf_irofficefollowupnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "IROFFICEFOLLOWUPNOTE"))
 DECLARE mf_gynoncnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNECOLOGYONCOLOGYNOTEOFFICE"))
 DECLARE mf_nephrologynote_cd = f8 WITH protect, constant(139638010.00)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt4 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt5 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx4 = i4 WITH protect, noconstant(0)
 DECLARE ml_auth_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_expand = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_location_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_AMB_MED_REC"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 IF (( $F_LOCATION_CD=999999))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="AMBULATORY"
    AND cv.active_ind=1
    AND cv.active_type_cd=mf_active_cd
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display="*\**"
   HEAD REPORT
    ml_cnt = 0
   HEAD cv.code_value
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->amb,5))
     CALL alterlist(m_rec->amb,(ml_cnt+ 99))
    ENDIF
    m_rec->amb[ml_cnt].f_location_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(m_rec->amb,ml_cnt)
   WITH nocounter
  ;end select
  SET ms_location_p =
  "expand(ml_expand, 1, size(m_rec->amb, 5), sa.appt_location_cd, m_rec->amb[ml_expand].f_location_cd)"
 ELSE
  SET ms_location_p = concat("sa.appt_location_cd = ",trim(cnvtstring( $F_LOCATION_CD),3))
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt sa,
   encntr_prsnl_reltn epr,
   prsnl pr,
   order_recon orn,
   prsnl pr2
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND parser(ms_location_p)
    AND sa.sch_state_cd=mf_checkedin_cd
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1)
   JOIN (epr
   WHERE epr.encntr_id=sa.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_attendingphysician_cd
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id
    AND pr.physician_ind=1)
   JOIN (orn
   WHERE (orn.encntr_id= Outerjoin(sa.encntr_id))
    AND (orn.recon_type_flag= Outerjoin(3)) )
   JOIN (pr2
   WHERE (pr2.person_id= Outerjoin(orn.performed_prsnl_id))
    AND (pr2.physician_ind= Outerjoin(1)) )
  ORDER BY sa.sch_appt_id, sa.encntr_id
  HEAD REPORT
   ml_cnt = 0, ml_cnt2 = 0, ml_cnt3 = 0,
   ml_idx = 0, ml_idx2 = 0
  HEAD sa.sch_appt_id
   ml_idx = locateval(ml_cnt,1,size(m_rec->prsnl,5),pr.person_id,m_rec->prsnl[ml_cnt].f_prsnl_id)
   IF (ml_idx=0)
    ml_idx = (size(m_rec->prsnl,5)+ 1),
    CALL alterlist(m_rec->prsnl,ml_idx), m_rec->prsnl[ml_idx].f_prsnl_id = pr.person_id,
    m_rec->prsnl[ml_idx].s_position = trim(uar_get_code_display(pr.position_cd),3), m_rec->prsnl[
    ml_idx].s_provider = pr.name_full_formatted, m_rec->prsnl[ml_idx].s_location = trim(
     uar_get_code_display(sa.appt_location_cd),3),
    m_rec->prsnl[ml_idx].l_notes_total = 0, m_rec->prsnl[ml_idx].l_notes_complete = 0, m_rec->prsnl[
    ml_idx].l_rec_total = 0,
    m_rec->prsnl[ml_idx].l_rec_complete = 0, m_rec->prsnl[ml_idx].l_rec_incomplete = 0
   ENDIF
   m_rec->prsnl[ml_idx].l_rec_total += 1, m_rec->prsnl[ml_idx].l_notes_total += 1
   IF (orn.recon_status_cd=mf_rec_complete_cd)
    m_rec->prsnl[ml_idx].l_rec_complete += 1
   ELSE
    m_rec->prsnl[ml_idx].l_rec_incomplete += 1
   ENDIF
   IF ( NOT (pr2.person_id IN (0.00, pr.person_id)))
    ml_idx2 = locateval(ml_cnt,1,size(m_rec->prsnl,5),pr2.person_id,m_rec->prsnl[ml_cnt].f_prsnl_id)
    IF (ml_idx2=0)
     ml_idx2 = (size(m_rec->prsnl,5)+ 1),
     CALL alterlist(m_rec->prsnl,ml_idx2), m_rec->prsnl[ml_idx2].f_prsnl_id = pr2.person_id,
     m_rec->prsnl[ml_idx2].s_position = trim(uar_get_code_display(pr2.position_cd),3), m_rec->prsnl[
     ml_idx2].s_provider = pr2.name_full_formatted, m_rec->prsnl[ml_idx2].s_location = trim(
      uar_get_code_display(sa.appt_location_cd),3),
     m_rec->prsnl[ml_idx2].l_notes_total = 0, m_rec->prsnl[ml_idx2].l_notes_complete = 0, m_rec->
     prsnl[ml_idx2].l_rec_total = 0,
     m_rec->prsnl[ml_idx2].l_rec_complete = 0, m_rec->prsnl[ml_idx2].l_rec_incomplete = 0
    ENDIF
    m_rec->prsnl[ml_idx2].l_rec_total += 1
    IF (orn.recon_status_cd=mf_rec_complete_cd)
     m_rec->prsnl[ml_idx2].l_rec_complete += 1
    ELSE
     m_rec->prsnl[ml_idx2].l_rec_incomplete += 1
    ENDIF
   ENDIF
  HEAD sa.encntr_id
   ml_cnt3 += 1
   IF (ml_cnt3 > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(ml_cnt3+ 99))
   ENDIF
   m_rec->enc[ml_cnt3].f_encntr_id = sa.encntr_id, m_rec->enc[ml_cnt3].f_attending_id = pr.person_id
  FOOT REPORT
   CALL alterlist(m_rec->enc,ml_cnt3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl pr,
   sch_appt sa
  PLAN (ce
   WHERE expand(ml_cnt,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_cnt].f_encntr_id)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd)
    AND ce.event_cd IN (mf_reproductivemednote_cd, mf_nephrologynote_cd, mf_adolescentnote_cd,
   mf_allergyimmunnote_cd, mf_anesthesiologynote_cd,
   mf_anticoagulationnote_cd, mf_maternalfetalmednote_cd, mf_bariatricsurgerynote_cd,
   mf_cardiologynote_cd, mf_cardpulmrehabnote_cd,
   mf_breastwellnessnote_cd, mf_dentaloralsurgnote_cd, mf_dermatologynote_cd, mf_endocrinologynote_cd,
   mf_gastroenterologynote_cd,
   mf_generalmedicinenote_cd, mf_generalsurgerynote_cd, mf_geriatricnote_cd, mf_gynecologynote_cd,
   mf_hematologyoncnote_cd,
   mf_infectdiseasenote_cd, mf_neurologynote_cd, mf_neurosurgerynote_cd, mf_painmanagementnote_cd,
   mf_geneticsnote_cd,
   mf_plasticsurgerynote_cd, mf_pulmonarynote_cd, mf_radoncologynote_cd, mf_physicalmedrehabnote_cd,
   mf_surgicaloncologynote_cd,
   mf_thoracicsurgerynote_cd, mf_transservicesnote_cd, mf_vascularsurgerynote_cd,
   mf_woundcarehbonote_cd, mf_cardiacsurgerynote_cd,
   mf_urologynote_cd, mf_entnote_cd, mf_occhealthnote_cd, mf_ophthalmologynote_cd,
   mf_orthopedicnote_cd,
   mf_genpedinote_cd, mf_podiatrynote_cd, mf_rheumatologynote_cd, mf_gensurgtraumanote_cd,
   mf_urogynecologynote_cd,
   mf_growthnutritionnote_cd, mf_neuropsychologynote_cd, mf_endocrinesurgerynote_cd,
   mf_restrictedgennote_cd, mf_pediatricsurgerynote_cd,
   mf_colorectalofficenote_cd, mf_irofficeinitialnote_cd, mf_irofficefollowupnote_cd,
   mf_gynoncnote_cd)
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd)
    AND textlen(trim(ce.event_title_text,3)) > 0)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id
    AND pr.physician_ind=1)
   JOIN (sa
   WHERE sa.encntr_id=ce.encntr_id
    AND sa.sch_state_cd=mf_checkedin_cd
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1)
  ORDER BY ce.encntr_id, ce.event_id
  HEAD REPORT
   ml_idx = 0, ml_idx2 = 0, ml_idx3 = 0,
   ml_idx4 = 0, ml_cnt2 = 0, ml_cnt3 = 0,
   ml_cnt4 = 0, ml_cnt5 = 0
  HEAD ce.encntr_id
   ml_idx = locateval(ml_cnt2,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_cnt2].f_encntr_id),
   ml_idx2 = locateval(ml_cnt3,1,size(m_rec->prsnl,5),m_rec->enc[ml_idx].f_attending_id,m_rec->prsnl[
    ml_cnt3].f_prsnl_id), m_rec->prsnl[ml_idx2].l_notes_complete += 1
  HEAD ce.event_id
   IF ((ce.performed_prsnl_id != m_rec->enc[ml_idx].f_attending_id))
    ml_idx3 = locateval(ml_cnt4,1,size(m_rec->enc[ml_idx].notes,5),ce.performed_prsnl_id,m_rec->enc[
     ml_idx].notes[ml_cnt4].f_prsnl_id)
    IF (ml_idx3=0)
     ml_auth_cnt = (size(m_rec->enc[ml_idx].notes,5)+ 1),
     CALL alterlist(m_rec->enc[ml_idx].notes,ml_auth_cnt), m_rec->enc[ml_idx].notes[ml_auth_cnt].
     f_prsnl_id = ce.performed_prsnl_id,
     ml_idx4 = locateval(ml_cnt5,1,size(m_rec->prsnl,5),ce.performed_prsnl_id,m_rec->prsnl[ml_cnt5].
      f_prsnl_id)
     IF (ml_idx4=0)
      ml_idx4 = (size(m_rec->prsnl,5)+ 1),
      CALL alterlist(m_rec->prsnl,ml_idx4), m_rec->prsnl[ml_idx4].f_prsnl_id = pr.person_id,
      m_rec->prsnl[ml_idx4].s_position = trim(uar_get_code_display(pr.position_cd),3), m_rec->prsnl[
      ml_idx4].s_provider = pr.name_full_formatted, m_rec->prsnl[ml_idx4].s_location = trim(
       uar_get_code_display(sa.appt_location_cd),3),
      m_rec->prsnl[ml_idx4].l_notes_total = 0, m_rec->prsnl[ml_idx4].l_notes_complete = 0, m_rec->
      prsnl[ml_idx4].l_rec_total = 0,
      m_rec->prsnl[ml_idx4].l_rec_complete = 0, m_rec->prsnl[ml_idx4].l_rec_incomplete = 0
     ENDIF
     m_rec->prsnl[ml_idx4].l_notes_total += 1, m_rec->prsnl[ml_idx4].l_notes_complete += 1
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (size(m_rec->prsnl,5)=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  provider = m_rec->prsnl[d.seq].s_provider
  FROM (dummyt d  WITH seq = size(m_rec->prsnl,5))
  PLAN (d)
  ORDER BY provider
  HEAD REPORT
   ml_cnt = 0
  HEAD d.seq
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->prsnl_sorted,5))
    CALL alterlist(m_rec->prsnl_sorted,ml_cnt)
   ENDIF
   m_rec->prsnl_sorted[ml_cnt].s_provider = m_rec->prsnl[d.seq].s_provider, m_rec->prsnl_sorted[
   ml_cnt].s_position = m_rec->prsnl[d.seq].s_position, m_rec->prsnl_sorted[ml_cnt].s_location =
   m_rec->prsnl[d.seq].s_location,
   m_rec->prsnl_sorted[ml_cnt].l_rec_total = m_rec->prsnl[d.seq].l_rec_total, m_rec->prsnl_sorted[
   ml_cnt].l_rec_incomplete = m_rec->prsnl[d.seq].l_rec_incomplete, m_rec->prsnl_sorted[ml_cnt].
   l_rec_complete = m_rec->prsnl[d.seq].l_rec_complete,
   m_rec->prsnl_sorted[ml_cnt].l_notes_total = m_rec->prsnl[d.seq].l_notes_total, m_rec->
   prsnl_sorted[ml_cnt].l_notes_complete = m_rec->prsnl[d.seq].l_notes_complete, m_rec->prsnl_sorted[
   ml_cnt].l_notes_incomplete = (m_rec->prsnl[d.seq].l_notes_total - m_rec->prsnl[d.seq].
   l_notes_complete)
   IF ((m_rec->prsnl[d.seq].l_rec_total=0))
    m_rec->prsnl_sorted[ml_cnt].s_complete_rec_pct = "-"
   ELSE
    m_rec->prsnl_sorted[ml_cnt].s_complete_rec_pct = trim(format(((cnvtreal(m_rec->prsnl[d.seq].
       l_rec_complete)/ cnvtreal(m_rec->prsnl[d.seq].l_rec_total)) * 100),"###.##%;R"),3)
   ENDIF
   IF ((m_rec->prsnl[d.seq].l_notes_total=0))
    m_rec->prsnl_sorted[ml_cnt].s_complete_note_pct = "-"
   ELSE
    m_rec->prsnl_sorted[ml_cnt].s_complete_note_pct = trim(format(((cnvtreal(m_rec->prsnl[d.seq].
       l_notes_complete)/ cnvtreal(m_rec->prsnl[d.seq].l_notes_total)) * 100),"###.##%;R"),3)
   ENDIF
   CASE (m_rec->prsnl[d.seq].s_position)
    OF "BHS Associate Professional":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Shared"
    OF "BHS Anesthesiology MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Anesthesiology"
    OF "BHS Reference Physician":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Non-Baystate Employed"
    OF "BHS Cardiac Surgery MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Cardiovascular"
    OF "BHS ED Medicine MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Emergency"
    OF "BHS Physician (General Medicine)":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Hospitalist, Endocrinologist"
    OF "BHS Cardiology MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Critical Care MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Endoscopy MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS GI MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Infectious Disease MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Neurology MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Oncology MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Physiatry MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Pulmonary MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Renal MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Medicine"
    OF "BHS Physician -Physician Practices":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Ambulatory/Shared"
    OF "BHS Midwife":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Obstetrics/Gynecology"
    OF "BHS OB Resident":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Obstetrics/Gynecology"
    OF "BHS OB/GYN MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Obstetrics/Gynecology"
    OF "BHS General Pediatrics MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Pediatrics"
    OF "BHS Neonatal MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Pediatrics"
    OF "BHS BH Associate Professional":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Psychiatry"
    OF "BHS BH Resident":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Psychiatry"
    OF "BHS Psychiatry MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Psychiatry"
    OF "BHS General Surgery MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery"
    OF "BHS Orthopedics MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery"
    OF "BHS Thoracic MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery"
    OF "BHS Trauma MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery"
    OF "BHS Urology MD":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery"
    OF "BHS Resident":
     m_rec->prsnl_sorted[ml_cnt].s_department = "Surgery, Medicine, Pediatric, ED"
    ELSE
     m_rec->prsnl_sorted[ml_cnt].s_department = "Other"
   ENDCASE
  WITH nocounter
 ;end select
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build("bhs_rpt_amb_med_rec_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),".csv")
  SET ms_subject = build2("Ambulatory Medication Reconciliation Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PROVIDER",','"POSITION",','"LOCATION",','"DEPARTMENT",',
   '"NOTES INCOMPLETE",',
   '"NOTES COMPLETE",','"NOTES COMPLETION PCT",','"MED RECS INCOMPLETE",','"MED RECS COMPLETE",',
   '"MED RECS COMPLETION PCT",',
   char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(m_rec->prsnl_sorted,5))
   SET frec->file_buf = build('"',trim(m_rec->prsnl_sorted[ml_cnt].s_provider,3),'","',trim(m_rec->
     prsnl_sorted[ml_cnt].s_position,3),'","',
    trim(m_rec->prsnl_sorted[ml_cnt].s_location,3),'","',trim(m_rec->prsnl_sorted[ml_cnt].
     s_department,3),'","',trim(cnvtstring(m_rec->prsnl_sorted[ml_cnt].l_notes_incomplete),3),
    '","',trim(cnvtstring(m_rec->prsnl_sorted[ml_cnt].l_notes_complete),3),'","',trim(m_rec->
     prsnl_sorted[ml_cnt].s_complete_note_pct,3),'","',
    trim(cnvtstring(m_rec->prsnl_sorted[ml_cnt].l_rec_incomplete),3),'","',trim(cnvtstring(m_rec->
      prsnl_sorted[ml_cnt].l_rec_complete),3),'","',trim(m_rec->prsnl_sorted[ml_cnt].
     s_complete_rec_pct,3),
    '"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   provider = substring(1,50,m_rec->prsnl_sorted[d.seq].s_provider), position = substring(1,50,m_rec
    ->prsnl_sorted[d.seq].s_position), location = substring(1,50,m_rec->prsnl_sorted[d.seq].
    s_location),
   department = substring(1,50,m_rec->prsnl_sorted[d.seq].s_department), notes_incomplete = m_rec->
   prsnl_sorted[d.seq].l_notes_incomplete, notes_complete = m_rec->prsnl_sorted[d.seq].
   l_notes_complete,
   notes_completion_pct = m_rec->prsnl_sorted[d.seq].s_complete_note_pct, medrecs_incomplete = m_rec
   ->prsnl_sorted[d.seq].l_rec_incomplete, medrecs_complete = m_rec->prsnl_sorted[d.seq].
   l_rec_complete,
   medrecs_completion_pct = m_rec->prsnl_sorted[d.seq].s_complete_rec_pct
   FROM (dummyt d  WITH seq = size(m_rec->prsnl_sorted,5))
   PLAN (d)
   ORDER BY provider
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
