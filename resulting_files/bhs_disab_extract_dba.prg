CREATE PROGRAM bhs_disab_extract:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 list_cnt = i4
   1 list[*]
     2 cmrn = vc
     2 person_id = f8
     2 encntr_id = f8
     2 fin_nbr = vc
     2 person_name = vc
     2 encntr_loc = vc
     2 encntr_type = vc
     2 disability1 = vc
     2 disability1_updt_dt = vc
     2 disability2 = vc
     2 disability2_updt_dt = vc
     2 disability3 = vc
     2 disability3_updt_dt = vc
     2 disability4 = vc
     2 disability4_updt_dt = vc
     2 disability5 = vc
     2 disability5_updt_dt = vc
     2 disability6 = vc
     2 disability6_updt_dt = vc
     2 sexual_orient = vc
     2 sexual_orient_updt_dt = vc
     2 gender_ident = vc
     2 gender_ident_updt_dt = vc
 ) WITH protect
 DECLARE rec_pos = i4 WITH protect, noconstant(0)
 DECLARE ndx1 = i4 WITH protect, noconstant(0)
 DECLARE ndx2 = i4 WITH protect, noconstant(0)
 DECLARE ndx3 = i4 WITH protect, noconstant(0)
 DECLARE mc_event_tag = vc WITH protect, noconstant("")
 DECLARE ms_str = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (ce
   WHERE ce.updt_dt_tm BETWEEN cnvtdatetime("01-FEB-2025 00:00:00") AND cnvtdatetime(
    "31-FEB-2025 23:59:59")
    AND ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
   2152008841.00))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (679656.00, 679658.0, 679659.00)
    AND e.disch_dt_tm >= cnvtdatetime("01-OCT-2024 00:00:00"))
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY ce.clinical_event_id
  HEAD REPORT
   rec_pos = 0
  DETAIL
   rec_pos = locateval(ndx1,1,m_rec->list_cnt,ce.person_id,m_rec->list[ndx1].person_id)
   IF (rec_pos=0)
    m_rec->list_cnt += 1, stat = alterlist(m_rec->list,m_rec->list_cnt), rec_pos = m_rec->list_cnt
   ENDIF
   m_rec->list[rec_pos].person_id = p.person_id, m_rec->list[rec_pos].encntr_id = e.encntr_id, m_rec
   ->list[rec_pos].person_name = p.name_full_formatted,
   m_rec->list[rec_pos].cmrn = pa.alias, m_rec->list[rec_pos].fin_nbr = format(ea.alias,
    "##########;p0"), m_rec->list[rec_pos].encntr_loc = uar_get_code_display(e.loc_facility_cd)
   CASE (e.encntr_type_cd)
    OF 309308.0:
    OF 679656.0:
    OF 679657.0:
     m_rec->list[rec_pos].encntr_type = "I"
    OF 309310.0:
    OF 679658.0:
    OF 679670.0:
     m_rec->list[rec_pos].encntr_type = "E"
    OF 309312.0:
    OF 679659.0:
    OF 679677.0:
     m_rec->list[rec_pos].encntr_type = "O"
   ENDCASE
   IF (ce.event_tag IN ("Not applicable by age", "In Progress", "In Error", "Not Done*"))
    mc_event_tag = "UNK"
   ELSE
    mc_event_tag = ce.event_tag
   ENDIF
   CASE (ce.event_cd)
    OF 2152008669.0:
     m_rec->list[rec_pos].disability1 = mc_event_tag,m_rec->list[rec_pos].disability1_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
    OF 2152008701.0:
     m_rec->list[rec_pos].disability2 = mc_event_tag,m_rec->list[rec_pos].disability2_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
    OF 2152008735.0:
     m_rec->list[rec_pos].disability3 = mc_event_tag,m_rec->list[rec_pos].disability3_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
    OF 2152008771.0:
     m_rec->list[rec_pos].disability4 = mc_event_tag,m_rec->list[rec_pos].disability4_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
    OF 2152008807.0:
     m_rec->list[rec_pos].disability5 = mc_event_tag,m_rec->list[rec_pos].disability5_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
    OF 2152008841.0:
     m_rec->list[rec_pos].disability6 = mc_event_tag,m_rec->list[rec_pos].disability6_updt_dt =
     evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n,
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (s
   WHERE s.updt_dt_tm BETWEEN cnvtdatetime("01-FEB-2025 00:00:00") AND cnvtdatetime(
    "31-FEB-2025 23:59:59"))
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd IN (567878076.0, 563829548.0, 567878112.0))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.nomenclature_id> Outerjoin(0)) )
   JOIN (e
   WHERE e.encntr_id=s.originating_encntr_id
    AND e.encntr_type_cd IN (679658.00, 679656.0, 679659.0, 309310.0, 679670.0,
   679657.00, 679677.0, 309308.0, 309312.0)
    AND e.disch_dt_tm >= cnvtdatetime("01-OCT-2024 00:00:00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id, n.nomenclature_id
  HEAD REPORT
   rec_pos = 0
  HEAD n.nomenclature_id
   rec_pos = locateval(ndx3,1,m_rec->list_cnt,s.person_id,m_rec->list[ndx3].person_id)
   IF (rec_pos=0)
    m_rec->list_cnt += 1, stat = alterlist(m_rec->list,m_rec->list_cnt), rec_pos = m_rec->list_cnt,
    m_rec->list[rec_pos].person_id = p.person_id, m_rec->list[rec_pos].encntr_id = e.encntr_id, m_rec
    ->list[rec_pos].person_name = p.name_full_formatted,
    m_rec->list[rec_pos].cmrn = pa.alias, m_rec->list[rec_pos].fin_nbr = format(ea.alias,
     "##########;p0"), m_rec->list[rec_pos].encntr_loc = uar_get_code_display(e.loc_facility_cd)
    CASE (e.encntr_type_cd)
     OF 309308.0:
     OF 679656.0:
     OF 679657.0:
      m_rec->list[rec_pos].encntr_type = "I"
     OF 309310.0:
     OF 679658.0:
     OF 679670.0:
      m_rec->list[rec_pos].encntr_type = "E"
     OF 309312.0:
     OF 679659.0:
     OF 679677.0:
      m_rec->list[rec_pos].encntr_type = "O"
    ENDCASE
   ENDIF
   CASE (sr.task_assay_cd)
    OF 567878076.0:
     IF (n.source_string IN ("Identifies as male", "Identifies as female",
     "Male-to-Female (MTF)/ Transgender Female/Trans Woman",
     "Female-to-Male (FTM)/ Transgender Male/Trans Man", "Genderqueer",
     "Addl gender category or other", "Choose not to disclose"))
      IF (textlen(m_rec->list[rec_pos].gender_ident)=0)
       m_rec->list[rec_pos].gender_ident = n.source_string
      ELSE
       m_rec->list[rec_pos].gender_ident = build(m_rec->list[rec_pos].gender_ident,";",n
        .source_string)
      ENDIF
      m_rec->list[rec_pos].gender_ident_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF 563829548.0:
     IF (n.source_string IN ("Lesbian, gay or homosexual", "Straight or heterosexual", "Bisexual",
     "Don't know", "Choose not to disclose",
     "Something else, please describe (by selecting Other)"))
      IF (textlen(m_rec->list[rec_pos].sexual_orient)=0)
       m_rec->list[rec_pos].sexual_orient = n.source_string
      ELSE
       m_rec->list[rec_pos].sexual_orient = build(m_rec->list[rec_pos].sexual_orient,";",n
        .source_string)
      ENDIF
      m_rec->list[rec_pos].sexual_orient_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "bhs_disab_test.txt"
  FROM (dummyt d  WITH seq = value(m_rec->list_cnt))
  HEAD REPORT
   ms_str = build("FIN","|","ENCNTR_LOC","|","ENCNTR_TYPE",
    "|","DISABILITY1","|","DISABILITY1_UPDT_DT","|",
    "DISABILITY2","|","DISABILITY2_UPDT_DT","|","DISABILITY3",
    "|","DISABILITY3_UPDT_DT","|","DISABILITY4","|",
    "DISABILITY4_UPDT_DT","|","DISABILITY5","|","DISABILITY5_UPDT_DT",
    "|","DISABILITY6","|","DISABILITY6_UPDT_DT","|",
    "SEXUAL_ORIENT","|","SEXUAL_ORIENT_UPDT_DT","|","GENDER_IDENT",
    "|","GENDER_IDENT_UPDT_DT"), col 0, ms_str,
   row + 1
  DETAIL
   ms_str = build(m_rec->list[d.seq].fin_nbr,"|",m_rec->list[d.seq].encntr_loc,"|",m_rec->list[d.seq]
    .encntr_type,
    "|",m_rec->list[d.seq].disability1,"|",m_rec->list[d.seq].disability1_updt_dt,"|",
    m_rec->list[d.seq].disability2,"|",m_rec->list[d.seq].disability2_updt_dt,"|",m_rec->list[d.seq].
    disability3,
    "|",m_rec->list[d.seq].disability3_updt_dt,"|",m_rec->list[d.seq].disability4,"|",
    m_rec->list[d.seq].disability4_updt_dt,"|",m_rec->list[d.seq].disability5,"|",m_rec->list[d.seq].
    disability5_updt_dt,
    "|",m_rec->list[d.seq].disability6,"|",m_rec->list[d.seq].disability6_updt_dt,"|",
    m_rec->list[d.seq].sexual_orient,"|",m_rec->list[d.seq].sexual_orient_updt_dt,"|",m_rec->list[d
    .seq].gender_ident,
    "|",m_rec->list[d.seq].gender_ident_updt_dt), col 0, ms_str,
   row + 1
  WITH nocounter, format = variable, maxcol = 2000,
   formfeed = none
 ;end select
 CALL echo("***")
 CALL echo(m_rec->list_cnt)
 CALL echo("--")
 FREE RECORD m_rec
END GO
