CREATE PROGRAM bhs_demo_sogi:dba
 DECLARE mc_pat_type = vc
 DECLARE mc_disch_dt = vc
 DECLARE mc_lang_written = vc
 DECLARE mc_str = vc
 DECLARE ml_pos = i4
 DECLARE ml_pos2 = i4
 DECLARE ml_ndx = i4
 DECLARE ml_ndx2 = i4
 DECLARE ml_sogi_cnt = i4
 FREE RECORD sogi
 RECORD sogi(
   1 list[*]
     2 cmrn = vc
     2 fin = vc
     2 age = vc
     2 pat_type = vc
     2 enc_typ_cd = f8
     2 disch_date = vc
     2 sex_orient_quest = vc
     2 sex_orient_ans = vc
     2 gender_ident_quest = vc
     2 gender_ident_ans = vc
 )
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n,
   person p,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm > cnvtdatetime("01-JAN-2025")
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0, 679586.0,
   679549.0, 780611679.0, 580061823.0)
    AND e.encntr_type_cd IN (679658.0, 679656.00)
    AND e.disch_disposition_cd != 637025838)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (s
   WHERE s.person_id=e.person_id)
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd IN (563829548.0, 567878076.0))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.nomenclature_id> Outerjoin(0)) )
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  ORDER BY e.disch_dt_tm
  DETAIL
   ml_pos = locateval(ml_ndx,1,ml_sogi_cnt,pa.alias,sogi->list[ml_ndx].cmrn,
    e.encntr_type_cd,sogi->list[ml_ndx].enc_typ_cd), ml_pos2 = locateval(ml_ndx2,1,ml_sogi_cnt,ea
    .alias,sogi->list[ml_ndx2].fin)
   IF (ml_pos=0
    AND ml_pos2=0)
    ml_sogi_cnt += 1, stat = alterlist(sogi->list,ml_sogi_cnt), ml_pos = ml_sogi_cnt
   ENDIF
   sogi->list[ml_pos].cmrn = pa.alias, sogi->list[ml_pos].fin = ea.alias, sogi->list[ml_pos].age =
   cnvtage(p.birth_dt_tm,cnvtdatetime("31-DEC-2024"),0),
   sogi->list[ml_pos].pat_type = uar_get_code_display(e.encntr_type_cd), sogi->list[ml_pos].
   enc_typ_cd = e.encntr_type_cd, sogi->list[ml_pos].disch_date = format(e.disch_dt_tm,
    "DD-MMM-YYYY HH:MM;;q")
   CASE (sr.task_assay_cd)
    OF 563829548.0:
     CASE (n.source_string)
      OF "Choose not to disclose":
       sogi->list[ml_pos].sex_orient_ans = "Choose Not to Answer "
      OF "Heterosexual":
       sogi->list[ml_pos].sex_orient_ans = "Straight or heterosexual"
      OF "Homosexual":
      OF "Lesbian, gay or homosexual":
       sogi->list[ml_pos].sex_orient_ans = "Lesbian or Gay"
      OF "Something else, please describe (by selecting Other)":
       sogi->list[ml_pos].sex_orient_ans = "Not listed"
      ELSE
       sogi->list[ml_pos].sex_orient_ans = n.source_string
     ENDCASE
     ,sogi->list[ml_pos].sex_orient_quest = uar_get_code_display(sr.task_assay_cd)
    OF 567878076.0:
     CASE (n.source_string)
      OF "Addl gender category or other, please specify (select Other)":
       sogi->list[ml_pos].gender_ident_ans = "Not listed"
      OF "Choose not to disclose":
       sogi->list[ml_pos].gender_ident_ans = "Choose Not to Answer"
      OF "Female-to-Male (FTM)/ Transgender Male/Trans Man":
      OF "Transgender male (female to male)":
       sogi->list[ml_pos].gender_ident_ans = "Transgender man/trans man"
      OF "Identifies as female":
       sogi->list[ml_pos].gender_ident_ans = "Female"
      OF "Identifies as male":
       sogi->list[ml_pos].gender_ident_ans = "Male"
      OF "Male-to-Female (MTF)/ Transgender Female/Trans Woman":
      OF "Transgender female (male to female)":
       sogi->list[ml_pos].gender_ident_ans = "Transgender woman/trans woman"
      ELSE
       sogi->list[ml_pos].gender_ident_ans = n.source_string
     ENDCASE
     ,sogi->list[ml_pos].gender_ident_quest = uar_get_code_display(sr.task_assay_cd)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   clinical_event ce,
   person p,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm >= cnvtdatetime("01-JAN-2025")
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0, 679586.0,
   679549.0, 780611679.0, 580061823.0)
    AND e.encntr_type_cd IN (679658.0, 679656.00)
    AND e.disch_disposition_cd != 637025838)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd IN (2337616897.00, 2337633303.00)
    AND ce.result_status_cd IN (25.00, 34.00, 35.00)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.task_assay_cd > 0)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  ORDER BY e.disch_dt_tm
  DETAIL
   ml_pos = locateval(ml_ndx,1,ml_sogi_cnt,pa.alias,sogi->list[ml_ndx].cmrn,
    e.encntr_type_cd,sogi->list[ml_ndx].enc_typ_cd), ml_pos2 = locateval(ml_ndx2,1,ml_sogi_cnt,ea
    .alias,sogi->list[ml_ndx2].fin)
   IF (ml_pos=0
    AND ml_pos2=0)
    ml_sogi_cnt += 1, stat = alterlist(sogi->list,ml_sogi_cnt), ml_pos = ml_sogi_cnt
   ENDIF
   sogi->list[ml_pos].cmrn = pa.alias, sogi->list[ml_pos].fin = ea.alias, sogi->list[ml_pos].age =
   cnvtage(p.birth_dt_tm,cnvtdatetime("31-DEC-2024"),0),
   sogi->list[ml_pos].pat_type = uar_get_code_display(e.encntr_type_cd), sogi->list[ml_pos].
   enc_typ_cd = e.encntr_type_cd, sogi->list[ml_pos].disch_date = format(e.disch_dt_tm,
    "DD-MMM-YYYY HH:MM;;q")
   CASE (ce.event_cd)
    OF 2337616897.0:
     CASE (ce.event_tag)
      OF "Choose not to disclose":
       sogi->list[ml_pos].sex_orient_ans = "Choose Not to Answer "
      OF "Heterosexual":
       sogi->list[ml_pos].sex_orient_ans = "Straight or heterosexual"
      OF "Homosexual":
      OF "Lesbian, gay or homosexual":
       sogi->list[ml_pos].sex_orient_ans = "Lesbian or Gay"
      OF "Something else, please describe (by selecting Other)":
       sogi->list[ml_pos].sex_orient_ans = "Not listed"
      ELSE
       sogi->list[ml_pos].sex_orient_ans = ce.event_tag
     ENDCASE
     ,sogi->list[ml_pos].sex_orient_quest = uar_get_code_display(ce.event_cd)
    OF 2337633303.0:
     CASE (ce.event_tag)
      OF "Addl gender category or other, please specify (select Other)":
       sogi->list[ml_pos].gender_ident_ans = "Not listed"
      OF "Choose not to disclose":
       sogi->list[ml_pos].gender_ident_ans = "Choose Not to Answer"
      OF "Female-to-Male (FTM)/ Transgender Male/Trans Man":
      OF "Transgender male (female to male)":
       sogi->list[ml_pos].gender_ident_ans = "Transgender man/trans man"
      OF "Identifies as female":
       sogi->list[ml_pos].gender_ident_ans = "Female"
      OF "Identifies as male":
       sogi->list[ml_pos].gender_ident_ans = "Male"
      OF "Male-to-Female (MTF)/ Transgender Female/Trans Woman":
      OF "Transgender female (male to female)":
       sogi->list[ml_pos].gender_ident_ans = "Transgender woman/trans woman"
      ELSE
       sogi->list[ml_pos].gender_ident_ans = ce.event_tag
     ENDCASE
     ,sogi->list[ml_pos].gender_ident_quest = uar_get_code_display(ce.event_cd)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "bhs_demo_sogi.csv"
  FROM (dummyt d  WITH seq = value(ml_sogi_cnt))
  PLAN (d)
  HEAD REPORT
   col 0,
   "cmrn|fin|age|patient_type|disch_date|sex_orient_question|sex_orient_answer|gender_ident_question|gender_ident_answer",
   row + 1
  DETAIL
   mc_str = build(sogi->list[d.seq].cmrn,"|",sogi->list[d.seq].fin,"|",sogi->list[d.seq].age,
    "|",sogi->list[d.seq].pat_type,"|",sogi->list[d.seq].disch_date,"|",
    sogi->list[d.seq].sex_orient_quest,"|",sogi->list[d.seq].sex_orient_ans,"|",sogi->list[d.seq].
    gender_ident_quest,
    "|",sogi->list[d.seq].gender_ident_ans), col 0, mc_str,
   row + 1
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 500
 ;end select
 FREE RECORD sogi
END GO
