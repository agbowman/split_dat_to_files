CREATE PROGRAM bhs_sogi_disab_extract:dba
 PROMPT
  "CMRN:" = "MINE",
  "HEATHMEMBERID:" = "",
  "MASSHEALTHID:" = "",
  "File Name" = ""
  WITH s_cmrn, s_healthmemberid, s_masshealthid,
  s_file_name
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 hnemembernbr = vc
     2 masshealthid = vc
     2 cmrn = vc
     2 person_id = f8
     2 race1 = vc
     2 race1_updt_dt = vc
     2 race2 = vc
     2 race2_updt_dt = vc
     2 race3 = vc
     2 race3_updt_dt = vc
     2 race4 = vc
     2 race4_updt_dt = vc
     2 race5 = vc
     2 race5_updt_dt = vc
     2 ethnicity = vc
     2 ethnicity_updt_dt = vc
     2 ethnicgroup1 = vc
     2 ethnicgroup1_updt_dt = vc
     2 ethnicgroup2 = vc
     2 ethnicgroup2_updt_dt = vc
     2 langspoken = vc
     2 langspoken_updt_dt = vc
     2 langread = vc
     2 langread_updt_dt = vc
     2 langprof = vc
     2 langprof_updt_dt = vc
     2 gender_ident = vc
     2 gender_ident_updt_dt = vc
     2 sexual_orient = vc
     2 sexual_orient_updt_dt = vc
     2 pronoun = vc
     2 pronoun_updt_dt = vc
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
     2 email_address = vc
     2 email_address_updt_dt = vc
     2 pripphonenumber = vc
     2 pripphonenumber_updt_dt = vc
     2 secphonenumber = vc
     2 secphonenumber_updt_dt = vc
     2 preferred_contact = vc
     2 preferred_contact_updt_dt = vc
     2 reg_ver_dt_tm = vc
 ) WITH protect
 DECLARE ms_cmrn = vc WITH protect, constant(trim( $S_CMRN,3))
 DECLARE ms_healthmemberid = vc WITH protect, constant(trim( $S_HEALTHMEMBERID,3))
 DECLARE ms_masshealthid = vc WITH protect, constant(trim( $S_MASSHEALTHID,3))
 DECLARE ms_file_name = vc WITH protect, constant(trim( $S_FILE_NAME,3))
 DECLARE mf_cs4_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2623"))
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs356_ethnicity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"ETHNICITY")
  )
 DECLARE mf_cs356_langprof = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEPROFICIENCY"))
 DECLARE mf_cs356_langread = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEREAD"))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_facility = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE rec_pos = i4 WITH protect, noconstant(0)
 DECLARE ndx = i4 WITH protect, noconstant(0)
 DECLARE ndx2 = i4 WITH protect, noconstant(0)
 DECLARE pl_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  textlen_cva2_alias = textlen(cva2.alias), textlen_cva3_alias = textlen(cva3.alias),
  textlen_cva_alias = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias), textlen_cva_alias
   = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias), textlen_cva_alias
   = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias), textlen_cva_alias
   = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias), textlen_cva_alias
   = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias), textlen_cva_alias
   = textlen(cva.alias),
  textlen_cva_alias = textlen(cva.alias), textlen_cva_alias = textlen(cva.alias)
  FROM person_alias pa,
   person p,
   person_info pi,
   code_value_outbound cva,
   code_value_outbound cva2,
   code_value_outbound cva3
  PLAN (pa
   WHERE pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cs4_cmrn
    AND pa.end_effective_dt_tm > sysdate
    AND pa.alias=cnvtstring(cnvtint(ms_cmrn)))
   JOIN (p
   WHERE p.person_id=pa.person_id)
   JOIN (pi
   WHERE (pi.person_id= Outerjoin(p.person_id))
    AND (pi.active_ind= Outerjoin(1))
    AND (pi.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (cva
   WHERE (cva.code_value= Outerjoin(pi.value_cd))
    AND (cva.contributor_source_cd= Outerjoin(673943.00)) )
   JOIN (cva2
   WHERE (cva2.code_value= Outerjoin(p.ethnic_grp_cd))
    AND (cva2.contributor_source_cd= Outerjoin(673943.00))
    AND (textlen(cva2.alias)= Outerjoin(1)) )
   JOIN (cva3
   WHERE (cva3.code_value= Outerjoin(p.language_cd))
    AND (cva3.contributor_source_cd= Outerjoin(673943.00))
    AND (textlen(cva3.alias)= Outerjoin(2)) )
  HEAD REPORT
   pl_cnt = 0, pl_cnt += 1, stat = alterlist(m_rec->list,pl_cnt),
   m_rec->list[pl_cnt].person_id = p.person_id, m_rec->list[pl_cnt].cmrn = ms_cmrn, m_rec->list[
   pl_cnt].hnemembernbr = trim(ms_healthmemberid,3),
   m_rec->list[pl_cnt].masshealthid = trim(ms_masshealthid,3), m_rec->list[pl_cnt].ethnicity = cva2
   .alias
   IF (textlen_cva2_alias > 0)
    m_rec->list[pl_cnt].ethnicity_updt_dt = format(p.updt_dt_tm,"YYYYMMDD")
   ENDIF
   m_rec->list[pl_cnt].langspoken = cva3.alias
   IF (textlen_cva3_alias > 0)
    m_rec->list[pl_cnt].langspoken_updt_dt = format(p.updt_dt_tm,"YYYYMMDD")
   ENDIF
  DETAIL
   CASE (pi.info_sub_type_cd)
    OF mf_cs356_race1:
     IF (textlen_cva_alias=1)
      m_rec->list[pl_cnt].race1 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].race1_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race2:
     IF (textlen_cva_alias=1)
      m_rec->list[pl_cnt].race2 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].race2_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race3:
     IF (textlen_cva_alias=1)
      m_rec->list[pl_cnt].race3 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].race3_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race4:
     IF (textlen_cva_alias=1)
      m_rec->list[pl_cnt].race4 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].race4_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race5:
     IF (textlen_cva_alias=1)
      m_rec->list[pl_cnt].race5 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].race5_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 614555093.0:
     IF (textlen_cva_alias <= 6)
      m_rec->list[pl_cnt].ethnicgroup1 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].ethnicgroup1_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 614555392.0:
     IF (textlen_cva_alias <= 6)
      m_rec->list[pl_cnt].ethnicgroup2 = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].ethnicgroup2_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_langprof:
     m_rec->list[pl_cnt].langprof = cva.alias,
     IF (textlen_cva_alias > 0)
      m_rec->list[pl_cnt].langprof_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF mf_cs356_langread:
     IF (textlen_cva_alias=2)
      m_rec->list[pl_cnt].langread = cva.alias
      IF (textlen_cva_alias > 0)
       m_rec->list[pl_cnt].langread_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 633825796.0:
     m_rec->list[pl_cnt].reg_ver_dt_tm = format(pi.value_dt_tm,"YYYYMMDD")
    OF 1171478023.00:
     m_rec->list[pl_cnt].preferred_contact = cva.alias,
     IF (textlen_cva_alias > 0)
      m_rec->list[pl_cnt].preferred_contact_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  textlen_ph_phone_num = textlen(ph.phone_num), textlen_ph_phone_num = textlen(ph.phone_num)
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND expand(ndx,1,pl_cnt,ph.parent_entity_id,m_rec->list[ndx].person_id)
   AND ph.phone_type_cd IN (170.0, 158598878.00)
   AND ph.active_ind=1
  DETAIL
   rec_pos = locateval(ndx2,1,pl_cnt,ph.parent_entity_id,m_rec->list[ndx2].person_id)
   IF (rec_pos > 0)
    CASE (ph.phone_type_cd)
     OF 170.0:
      m_rec->list[rec_pos].pripphonenumber = ph.phone_num,
      IF (textlen_ph_phone_num > 0)
       m_rec->list[rec_pos].pripphonenumber_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
      ENDIF
     OF 158598878.0:
      m_rec->list[rec_pos].secphonenumber = ph.phone_num,
      IF (textlen_ph_phone_num > 0)
       m_rec->list[rec_pos].secphonenumber_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
      ENDIF
    ENDCASE
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  textlen_ph_phone_num = textlen(ph.phone_num)
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON_PATIENT"
   AND expand(ndx,1,pl_cnt,ph.parent_entity_id,m_rec->list[ndx].person_id)
   AND ph.phone_type_cd=170
   AND ph.active_ind=1
  HEAD REPORT
   rec_pos = 0
  DETAIL
   rec_pos = locateval(ndx2,1,pl_cnt,ph.parent_entity_id,m_rec->list[ndx2].person_id)
   IF (rec_pos > 0)
    m_rec->list[rec_pos].email_address = ph.phone_num
    IF (textlen_ph_phone_num > 0)
     m_rec->list[rec_pos].email_address_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE expand(ndx,1,pl_cnt,ce.person_id,m_rec->list[ndx].person_id)
   AND ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
  2152008841.00)
  ORDER BY ce.clinical_event_id
  HEAD REPORT
   rec_pos = 0
  DETAIL
   rec_pos = locateval(ndx2,1,pl_cnt,ce.person_id,m_rec->list[ndx2].person_id)
   IF (rec_pos > 0)
    IF (ce.event_tag IN ("Yes", "No", "Choose Not to Answer", "Don't know", "Unable to Collect",
    "Unknown"))
     CASE (ce.event_cd)
      OF 2152008669.0:
       m_rec->list[rec_pos].disability1 = ce.event_tag,m_rec->list[rec_pos].disability1_updt_dt =
       evaluate(ce.event_tag,"Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
      OF 2152008701.0:
       m_rec->list[rec_pos].disability2 = evaluate(ce.event_tag,"Not applicable by age",null,ce
        .event_tag),m_rec->list[rec_pos].disability2_updt_dt = evaluate(ce.event_tag,
        "Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
      OF 2152008735.0:
       m_rec->list[rec_pos].disability3 = evaluate(ce.event_tag,"Not applicable by age",null,ce
        .event_tag),m_rec->list[rec_pos].disability3_updt_dt = evaluate(ce.event_tag,
        "Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
      OF 2152008771.0:
       m_rec->list[rec_pos].disability4 = evaluate(ce.event_tag,"Not applicable by age",null,ce
        .event_tag),m_rec->list[rec_pos].disability4_updt_dt = evaluate(ce.event_tag,
        "Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
      OF 2152008807.0:
       m_rec->list[rec_pos].disability5 = evaluate(ce.event_tag,"Not applicable by age",null,ce
        .event_tag),m_rec->list[rec_pos].disability5_updt_dt = evaluate(ce.event_tag,
        "Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
      OF 2152008841.0:
       m_rec->list[rec_pos].disability6 = evaluate(ce.event_tag,"Not applicable by age",null,ce
        .event_tag),m_rec->list[rec_pos].disability6_updt_dt = evaluate(ce.event_tag,
        "Not applicable by age",null,format(ce.updt_dt_tm,"YYYYMMDD"))
     ENDCASE
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n
  PLAN (s
   WHERE expand(ndx,1,pl_cnt,s.person_id,m_rec->list[ndx].person_id))
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd IN (567878076.0, 563829548.0, 567878112.0))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.nomenclature_id> Outerjoin(0)) )
  ORDER BY n.nomenclature_id
  HEAD REPORT
   rec_pos = 0
  HEAD n.nomenclature_id
   rec_pos = locateval(ndx2,1,pl_cnt,s.person_id,m_rec->list[ndx2].person_id)
   IF (rec_pos > 0)
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
     OF 567878112.0:
      IF (textlen(m_rec->list[rec_pos].pronoun)=0)
       m_rec->list[rec_pos].pronoun = n.source_string
      ELSE
       m_rec->list[rec_pos].pronoun = build(m_rec->list[rec_pos].pronoun,";",n.source_string)
      ENDIF
      ,m_rec->list[rec_pos].pronoun_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
    ENDCASE
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value(ms_file_name)
  FROM (dummyt d  WITH seq = value(pl_cnt))
  DETAIL
   ms_str = build(m_rec->list[d.seq].hnemembernbr,"|",m_rec->list[d.seq].masshealthid,"|",m_rec->
    list[d.seq].cmrn,
    "|",m_rec->list[d.seq].race1,"|",m_rec->list[d.seq].race1_updt_dt,"|",
    m_rec->list[d.seq].race2,"|",m_rec->list[d.seq].race2_updt_dt,"|",m_rec->list[d.seq].race3,
    "|",m_rec->list[d.seq].race3_updt_dt,"|",m_rec->list[d.seq].race4,"|",
    m_rec->list[d.seq].race4_updt_dt,"|",m_rec->list[d.seq].race5,"|",m_rec->list[d.seq].
    race5_updt_dt,
    "|",m_rec->list[d.seq].ethnicity,"|",m_rec->list[d.seq].ethnicity_updt_dt,"|",
    m_rec->list[d.seq].ethnicgroup1,"|",m_rec->list[d.seq].ethnicgroup1_updt_dt,"|",m_rec->list[d.seq
    ].ethnicgroup2,
    "|",m_rec->list[d.seq].ethnicgroup2_updt_dt,"|",m_rec->list[d.seq].langspoken,"|",
    m_rec->list[d.seq].langspoken_updt_dt,"|",m_rec->list[d.seq].langread,"|",m_rec->list[d.seq].
    langread_updt_dt,
    "|",m_rec->list[d.seq].langprof,"|",m_rec->list[d.seq].langprof_updt_dt,"|",
    m_rec->list[d.seq].gender_ident,"|",m_rec->list[d.seq].gender_ident_updt_dt,"|",m_rec->list[d.seq
    ].sexual_orient,
    "|",m_rec->list[d.seq].sexual_orient_updt_dt,"|",m_rec->list[d.seq].pronoun,"|",
    m_rec->list[d.seq].pronoun_updt_dt,"|",m_rec->list[d.seq].disability1,"|",m_rec->list[d.seq].
    disability1_updt_dt,
    "|",m_rec->list[d.seq].disability2,"|",m_rec->list[d.seq].disability2_updt_dt,"|",
    m_rec->list[d.seq].disability3,"|",m_rec->list[d.seq].disability3_updt_dt,"|",m_rec->list[d.seq].
    disability4,
    "|",m_rec->list[d.seq].disability4_updt_dt,"|",m_rec->list[d.seq].disability5,"|",
    m_rec->list[d.seq].disability5_updt_dt,"|",m_rec->list[d.seq].disability6,"|",m_rec->list[d.seq].
    disability6_updt_dt,
    "|",m_rec->list[d.seq].email_address,"|",m_rec->list[d.seq].email_address_updt_dt,"|",
    m_rec->list[d.seq].pripphonenumber,"|",m_rec->list[d.seq].pripphonenumber_updt_dt,"|",m_rec->
    list[d.seq].secphonenumber,
    "|",m_rec->list[d.seq].secphonenumber_updt_dt,"|",m_rec->list[d.seq].preferred_contact,"|",
    m_rec->list[d.seq].preferred_contact_updt_dt,"|",m_rec->list[d.seq].reg_ver_dt_tm), col 0, ms_str,
   row + 1
  WITH nocounter, append, format = variable,
   maxcol = 2000
 ;end select
 CALL echo("-- file written --")
#exit_program
END GO
