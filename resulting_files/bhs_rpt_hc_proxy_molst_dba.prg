CREATE PROGRAM bhs_rpt_hc_proxy_molst:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Nurse Unit:" = 0,
  "Beg Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, f_facility_cd, f_unit_cd,
  s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_name_last = vc
     2 s_name_first = vc
     2 s_dob = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_room = vc
     2 s_document_name = vc
     2 s_scan_dt_tm = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY_CD))
 DECLARE mf_unit_cd = f8 WITH protect, constant(cnvtreal( $F_UNIT_CD))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_hc_proxy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEALTHCAREPROXYSCANNEDFORM"))
 DECLARE mf_molst_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORDERSFORLIFESUSTAININGTREATMENT"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_cs69_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_cs69_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION"))
 DECLARE mf_cs69_er_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY"))
 DECLARE mf_cs69_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"DAYSTAY"))
 CALL echo(build2("mf_HC_PROXY_CD: ",mf_hc_proxy_cd))
 CALL echo(build2("mf_MOLST_CD: ",mf_molst_cd))
 CALL echo(build2("mf_CS69_INPT_CD: ",mf_cs69_inpt_cd))
 CALL echo(build2("mf_CS69_OBS_CD: ",mf_cs69_obs_cd))
 CALL echo(build2("mf_CS69_ER_CD: ",mf_cs69_er_cd))
 CALL echo(build2("mf_CS69_DAYSTAY_CD: ",mf_cs69_daystay_cd))
 DECLARE ms_parser = vc WITH protect, noconstant(" ")
 IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  GO TO eixt_script
 ENDIF
 IF (mf_unit_cd=0.0)
  SET ms_parser = " 1=1 "
 ELSE
  SET ms_parser = " e.loc_nurse_unit_cd = mf_UNIT_CD"
 ENDIF
 SELECT INTO "nl:"
  ps_room = substring(1,10,trim(uar_get_code_display(e.loc_room_cd),3)), ps_pat_name = substring(1,50,
   p.name_full_formatted)
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   dummyt d,
   clinical_event ce
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.beg_effective_dt_tm > cnvtdatetime("01-jan-2020")
    AND ed.loc_facility_cd=mf_facility_cd)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.reg_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND ((e.disch_dt_tm=null) OR (e.disch_dt_tm >= cnvtdatetime(ms_beg_dt_tm)))
    AND e.encntr_type_class_cd IN (mf_cs69_inpt_cd, mf_cs69_obs_cd, mf_cs69_er_cd, mf_cs69_daystay_cd
   )
    AND e.active_ind=1
    AND e.loc_facility_cd=mf_facility_cd
    AND parser(ms_parser))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtlookbehind("18,Y",sysdate))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (d)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.event_cd IN (mf_hc_proxy_cd, mf_molst_cd)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1)
  ORDER BY ps_room, ps_pat_name, p.person_id,
   ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD e.person_id
   null
  HEAD ce.event_cd
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 20))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = e.person_id, m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->pat[pl_cnt].s_name_last = trim(p.name_last,3),
   m_rec->pat[pl_cnt].s_name_first = trim(p.name_first,3), m_rec->pat[pl_cnt].s_dob = trim(format(p
     .birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->pat[pl_cnt].s_fin = trim(ea1.alias,3), m_rec->pat[pl_cnt].s_facility = trim(
    uar_get_code_display(e.loc_facility_cd),3), m_rec->pat[pl_cnt].s_unit = trim(uar_get_code_display
    (e.loc_nurse_unit_cd),3),
   m_rec->pat[pl_cnt].s_room = trim(uar_get_code_display(e.loc_room_cd),3)
   IF (ce.event_cd > 0)
    m_rec->pat[pl_cnt].s_document_name = trim(ce.event_title_text,3), m_rec->pat[pl_cnt].s_scan_dt_tm
     = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 IF (size(m_rec->pat,5) > 0)
  SELECT INTO value( $OUTDEV)
   hospital_name = substring(1,50,m_rec->pat[d.seq].s_facility), unit_name = substring(1,50,m_rec->
    pat[d.seq].s_unit), room = substring(1,10,m_rec->pat[d.seq].s_room),
   patient_last_name = substring(1,50,m_rec->pat[d.seq].s_name_last), patient_first_name = substring(
    1,50,m_rec->pat[d.seq].s_name_first), patient_dob = m_rec->pat[d.seq].s_dob,
   mrn = substring(1,50,m_rec->pat[d.seq].s_mrn), fin = substring(1,50,m_rec->pat[d.seq].s_fin),
   document_name = substring(1,60,m_rec->pat[d.seq].s_document_name),
   scan_dt_tm = m_rec->pat[d.seq].s_scan_dt_tm
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
   ORDER BY d.seq
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
