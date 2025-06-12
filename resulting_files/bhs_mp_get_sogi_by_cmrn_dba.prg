CREATE PROGRAM bhs_mp_get_sogi_by_cmrn:dba
 PROMPT
  "CMRN:" = ""
  WITH s_cmrn
 FREE RECORD sogi_data
 RECORD sogi_data(
   1 hnemembernbr = vc
   1 masshealthid = vc
   1 cmrn = vc
   1 person_id = f8
   1 race1 = vc
   1 race1_updt_dt = vc
   1 race2 = vc
   1 race2_updt_dt = vc
   1 race3 = vc
   1 race3_updt_dt = vc
   1 race4 = vc
   1 race4_updt_dt = vc
   1 race5 = vc
   1 race5_updt_dt = vc
   1 ethnicity = vc
   1 ethnicity_updt_dt = vc
   1 ethnicgrp1 = vc
   1 ethnicgrp1_updt_dt = vc
   1 ethnicgrp2 = vc
   1 ethnicgrp2_updt_dt = vc
   1 lang_spoken = vc
   1 lang_spoken_updt_dt = vc
   1 lang_read = vc
   1 lang_read_updt_dt = vc
   1 lang_prof = vc
   1 lang_prof_updt_dt = vc
   1 gender_ident = vc
   1 gender_ident_updt_dt = vc
   1 sexual_orient = vc
   1 sexual_orient_updt_dt = vc
   1 pronoun = vc
   1 pronoun_updt_dt = vc
   1 disability1 = vc
   1 disability1_updt_dt = vc
   1 disability2 = vc
   1 disability2_updt_dt = vc
   1 disability3 = vc
   1 disability3_updt_dt = vc
   1 disability4 = vc
   1 disability4_updt_dt = vc
   1 disability5 = vc
   1 disability5_updt_dt = vc
   1 disability6 = vc
   1 disability6_updt_dt = vc
   1 email_addr = vc
   1 email_addr_updt_dt = vc
   1 prim_phone = vc
   1 prim_phone_updt_dt = vc
   1 sec_phone = vc
   1 sec_phone_updt_dt = vc
   1 pref_contact = vc
   1 pref_contact_updt_dt = vc
   1 reg_ver_dt_tm = vc
 ) WITH protect
 DECLARE ms_cmrn = vc WITH protect, constant(trim( $S_CMRN,3))
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
 DECLARE mf_cs356_lang_prof = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEPROFICIENCY"))
 DECLARE mf_cs356_lang_read = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEREAD"))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_facility = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
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
   pl_cnt += 1, sogi_data->person_id = p.person_id, sogi_data->cmrn = ms_cmrn,
   sogi_data->ethnicity = cva2.alias
   IF (textlen_cva2_alias > 0)
    sogi_data->ethnicity_updt_dt = format(p.updt_dt_tm,"YYYYMMDD")
   ENDIF
   sogi_data->lang_spoken = cva3.alias
   IF (textlen_cva3_alias > 0)
    sogi_data->lang_spoken_updt_dt = format(p.updt_dt_tm,"YYYYMMDD")
   ENDIF
  DETAIL
   CASE (pi.info_sub_type_cd)
    OF mf_cs356_race1:
     IF (textlen_cva_alias=1)
      sogi_data->race1 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->race1_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race2:
     IF (textlen_cva_alias=1)
      sogi_data->race2 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->race2_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race3:
     IF (textlen_cva_alias=1)
      sogi_data->race3 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->race3_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race4:
     IF (textlen_cva_alias=1)
      sogi_data->race4 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->race4_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_race5:
     IF (textlen_cva_alias=1)
      sogi_data->race5 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->race5_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 614555093.0:
     IF (textlen_cva_alias <= 6)
      sogi_data->ethnicgrp1 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->ethnicgrp1_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 614555392.0:
     IF (textlen_cva_alias <= 6)
      sogi_data->ethnicgrp2 = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->ethnicgrp2_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF mf_cs356_lang_prof:
     sogi_data->lang_prof = cva.alias,
     IF (textlen_cva_alias > 0)
      sogi_data->lang_prof_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF mf_cs356_lang_read:
     IF (textlen_cva_alias=2)
      sogi_data->lang_read = cva.alias
      IF (textlen_cva_alias > 0)
       sogi_data->lang_read_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
      ENDIF
     ENDIF
    OF 633825796.0:
     sogi_data->reg_ver_dt_tm = format(pi.value_dt_tm,"YYYYMMDD")
    OF 1171478023.00:
     sogi_data->pref_contact = cva.alias,
     IF (textlen_cva_alias > 0)
      sogi_data->pref_contact_updt_dt = format(pi.updt_dt_tm,"YYYYMMDD")
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
   AND (ph.parent_entity_id=sogi_data->person_id)
   AND ph.phone_type_cd IN (170.0, 158598878.00)
   AND ph.active_ind=1
  DETAIL
   CASE (ph.phone_type_cd)
    OF 170.0:
     sogi_data->prim_phone = ph.phone_num,
     IF (textlen_ph_phone_num > 0)
      sogi_data->prim_phone_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF 158598878.0:
     sogi_data->sec_phone = ph.phone_num,
     IF (textlen_ph_phone_num > 0)
      sogi_data->sec_phone_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  textlen_ph_phone_num = textlen(ph.phone_num)
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON_PATIENT"
   AND (ph.parent_entity_id=sogi_data->person_id)
   AND ph.phone_type_cd=170
   AND ph.active_ind=1
  DETAIL
   sogi_data->email_addr = ph.phone_num
   IF (textlen_ph_phone_num > 0)
    sogi_data->email_addr_updt_dt = format(ph.updt_dt_tm,"YYYYMMDD")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE (ce.person_id=sogi_data->person_id)
   AND ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
  2152008841.00)
  ORDER BY ce.clinical_event_id
  DETAIL
   IF (ce.event_tag IN ("Yes", "No", "Choose Not to Answer", "Don't know", "Unable to Collect",
   "Unknown"))
    CASE (ce.event_cd)
     OF 2152008669.0:
      sogi_data->disability1 = ce.event_tag,sogi_data->disability1_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
     OF 2152008701.0:
      sogi_data->disability2 = ce.event_tag,sogi_data->disability2_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
     OF 2152008735.0:
      sogi_data->disability3 = ce.event_tag,sogi_data->disability3_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
     OF 2152008771.0:
      sogi_data->disability4 = ce.event_tag,sogi_data->disability4_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
     OF 2152008807.0:
      sogi_data->disability5 = ce.event_tag,sogi_data->disability5_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
     OF 2152008841.0:
      sogi_data->disability6 = ce.event_tag,sogi_data->disability6_updt_dt = format(ce.updt_dt_tm,
       "YYYYMMDD")
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n
  PLAN (s
   WHERE (s.person_id=sogi_data->person_id))
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd IN (567878076.0, 563829548.0, 567878112.0))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND n.nomenclature_id > 0)
  ORDER BY n.nomenclature_id
  HEAD n.nomenclature_id
   CASE (sr.task_assay_cd)
    OF 567878076.0:
     IF (n.source_string IN ("Identifies as male", "Identifies as female",
     "Male-to-Female (MTF)/ Transgender Female/Trans Woman",
     "Female-to-Male (FTM)/ Transgender Male/Trans Man", "Genderqueer",
     "Addl gender category or other", "Choose not to disclose"))
      IF (textlen(sogi_data->gender_ident)=0)
       sogi_data->gender_ident = n.source_string
      ELSE
       sogi_data->gender_ident = build(sogi_data->gender_ident,";",n.source_string)
      ENDIF
      sogi_data->gender_ident_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF 563829548.0:
     IF (n.source_string IN ("Lesbian, gay or homosexual", "Straight or heterosexual", "Bisexual",
     "Don't know", "Choose not to disclose",
     "Something else, please describe (by selecting Other)"))
      IF (textlen(sogi_data->sexual_orient)=0)
       sogi_data->sexual_orient = n.source_string
      ELSE
       sogi_data->sexual_orient = build(sogi_data->sexual_orient,";",n.source_string)
      ENDIF
      sogi_data->sexual_orient_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
     ENDIF
    OF 567878112.0:
     IF (textlen(sogi_data->pronoun)=0)
      sogi_data->pronoun = n.source_string
     ELSE
      sogi_data->pronoun = build(sogi_data->pronoun,";",n.source_string)
     ENDIF
     ,sogi_data->pronoun_updt_dt = format(s.updt_dt_tm,"YYYYMMDD")
   ENDCASE
  WITH nocounter
 ;end select
 SET _memory_reply_string = cnvtrectojson(sogi_data)
 CALL echo("**")
 CALL echo(_memory_reply_string)
#exit_program
 FREE RECORD sogi_data
END GO
