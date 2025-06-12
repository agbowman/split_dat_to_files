CREATE PROGRAM bhs_demo_disab:dba
 DECLARE mc_pat_type = vc
 DECLARE mc_disch_dt = vc
 DECLARE mc_lang_written = vc
 DECLARE mc_str = vc
 DECLARE ml_pos = i4
 DECLARE ml_pos2 = i4
 DECLARE ml_ndx = i4
 DECLARE ml_ndx2 = i4
 DECLARE ml_sogi_cnt = i4
 DECLARE ml_pat_cnt = i4
 DECLARE ml_pat_inpat_total_cnt = i4
 DECLARE ml_pat_emerg_total_cnt = i4
 DECLARE ml_pat_inpat_6yo_cnt = i4
 DECLARE ml_pat_emerg_6yo_cnt = i4
 DECLARE ml_pat_inpat_15yo_cnt = i4
 DECLARE ml_pat_emerg_15yo_cnt = i4
 DECLARE ml_pat_inpat_q1_cnt = i4
 DECLARE ml_pat_emerg_q1_cnt = i4
 DECLARE ml_pat_inpat_q2_cnt = i4
 DECLARE ml_pat_emerg_q2_cnt = i4
 DECLARE ml_pat_inpat_q3_cnt = i4
 DECLARE ml_pat_emerg_q3_cnt = i4
 DECLARE ml_pat_inpat_q4_cnt = i4
 DECLARE ml_pat_emerg_q4_cnt = i4
 DECLARE ml_pat_inpat_q5_cnt = i4
 DECLARE ml_pat_emerg_q5_cnt = i4
 DECLARE ml_pat_inpat_q6_cnt = i4
 DECLARE ml_pat_emerg_q6_cnt = i4
 DECLARE ml_utc_inpat_cnt = i4
 DECLARE ml_utc_emerg_cnt = i4
 DECLARE ml_utc_inpat_6yo_cnt = i4
 DECLARE ml_utc_emerg_6yo_cnt = i4
 DECLARE ml_utc_inpat_15yo_cnt = i4
 DECLARE ml_utc_emerg_15yo_cnt = i4
 FREE RECORD sogi
 RECORD sogi(
   1 list[*]
     2 cmrn = vc
     2 fin = vc
     2 person_id = f8
     2 age = vc
     2 pat_type = vc
     2 enc_typ_cd = f8
     2 disch_date = vc
     2 question1 = vc
     2 answer1 = vc
     2 question2 = vc
     2 answer2 = vc
     2 question3 = vc
     2 answer3 = vc
     2 question4 = vc
     2 answer4 = vc
     2 question5 = vc
     2 answer5 = vc
     2 question6 = vc
     2 answer6 = vc
 )
 FREE RECORD disch
 RECORD disch(
   1 list[*]
     2 person_id = f8
     2 enc_typ_cd = f8
 )
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   clinical_event ce,
   encntr_plan_reltn epr,
   health_plan hp,
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
    AND ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
   2152008841.00)
    AND ce.result_status_cd IN (25.00, 34.00, 35.00)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.task_assay_cd > 0)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0, 5007467.00, 11467249.00,
   18020434.00)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id, e.disch_dt_tm
  DETAIL
   ml_pos = locateval(ml_ndx,1,ml_sogi_cnt,e.person_id,sogi->list[ml_ndx].person_id,
    e.encntr_type_cd,sogi->list[ml_ndx].enc_typ_cd)
   IF (ml_pos=0)
    ml_sogi_cnt += 1, stat = alterlist(sogi->list,ml_sogi_cnt), ml_pos = ml_sogi_cnt
   ENDIF
   sogi->list[ml_pos].cmrn = pa.alias, sogi->list[ml_pos].fin = ea.alias, sogi->list[ml_pos].
   person_id = e.person_id,
   sogi->list[ml_pos].age = cnvtage(p.birth_dt_tm,cnvtdatetime("31-DEC-2024"),0), sogi->list[ml_pos].
   pat_type = uar_get_code_display(e.encntr_type_cd), sogi->list[ml_pos].enc_typ_cd = e
   .encntr_type_cd,
   sogi->list[ml_pos].disch_date = format(e.disch_dt_tm,"DD-MMM-YYYY HH:MM;;q")
   CASE (ce.event_cd)
    OF 2152008669.00:
     CASE (ce.event_tag)
      OF "Date\Time Correction":
      OF "In Error":
      OF "In Progress":
       sogi->list[ml_pos].answer1 = "Unknown"
      ELSE
       IF (ce.event_tag="Not Done*")
        sogi->list[ml_pos].answer1 = "Unknown"
       ELSE
        sogi->list[ml_pos].answer1 = ce.event_tag
       ENDIF
     ENDCASE
     ,sogi->list[ml_pos].question1 = uar_get_code_display(ce.event_cd)
    OF 2152008701.00:
     CASE (ce.event_tag)
      OF "Date\Time Correction":
      OF "In Error":
      OF "In Progress":
       sogi->list[ml_pos].answer2 = "Unknown"
      ELSE
       IF (ce.event_tag="Not Done*")
        sogi->list[ml_pos].answer2 = "Unknown"
       ELSE
        sogi->list[ml_pos].answer2 = ce.event_tag
       ENDIF
     ENDCASE
     ,sogi->list[ml_pos].question2 = uar_get_code_display(ce.event_cd)
    OF 2152008735.00:
     IF (ce.event_tag != "Not applicable by age")
      IF (p.birth_dt_tm <= cnvtlookbehind("6,Y",cnvtdatetime("31-DEC-2024")))
       CASE (ce.event_tag)
        OF "Date\Time Correction":
        OF "In Error":
        OF "In Progress":
         sogi->list[ml_pos].answer3 = "Unknown"
        ELSE
         IF (ce.event_tag="Not Done*")
          sogi->list[ml_pos].answer3 = "Unknown"
         ELSE
          sogi->list[ml_pos].answer3 = ce.event_tag
         ENDIF
       ENDCASE
       sogi->list[ml_pos].question3 = uar_get_code_display(ce.event_cd)
      ENDIF
     ENDIF
    OF 2152008771.00:
     IF (ce.event_tag != "Not applicable by age")
      IF (p.birth_dt_tm <= cnvtlookbehind("6,Y",cnvtdatetime("31-DEC-2024")))
       CASE (ce.event_tag)
        OF "Date\Time Correction":
        OF "In Error":
        OF "In Progress":
         sogi->list[ml_pos].answer4 = "Unknown"
        ELSE
         IF (ce.event_tag="Not Done*")
          sogi->list[ml_pos].answer4 = "Unknown"
         ELSE
          sogi->list[ml_pos].answer4 = ce.event_tag
         ENDIF
       ENDCASE
       sogi->list[ml_pos].question4 = uar_get_code_display(ce.event_cd)
      ENDIF
     ENDIF
    OF 2152008807.00:
     IF (ce.event_tag != "Not applicable by age")
      IF (p.birth_dt_tm <= cnvtlookbehind("6,Y",cnvtdatetime("31-DEC-2024")))
       CASE (ce.event_tag)
        OF "Date\Time Correction":
        OF "In Error":
        OF "In Progress":
         sogi->list[ml_pos].answer5 = "Unknown"
        ELSE
         IF (ce.event_tag="Not Done*")
          sogi->list[ml_pos].answer5 = "Unknown"
         ELSE
          sogi->list[ml_pos].answer5 = ce.event_tag
         ENDIF
       ENDCASE
       sogi->list[ml_pos].question5 = uar_get_code_display(ce.event_cd)
      ENDIF
     ENDIF
    OF 2152008841.00:
     IF (ce.event_tag != "Not applicable by age")
      IF (p.birth_dt_tm <= cnvtlookbehind("15,Y",cnvtdatetime("31-DEC-2024")))
       CASE (ce.event_tag)
        OF "Date\Time Correction":
        OF "In Error":
        OF "In Progress":
         sogi->list[ml_pos].answer6 = "Unknown"
        ELSE
         IF (ce.event_tag="Not Done*")
          sogi->list[ml_pos].answer6 = "Unknown"
         ELSE
          sogi->list[ml_pos].answer6 = ce.event_tag
         ENDIF
       ENDCASE
       sogi->list[ml_pos].question6 = uar_get_code_display(ce.event_cd)
      ENDIF
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 FOR (for_cnt = 1 TO ml_sogi_cnt)
   IF ((((sogi->list[for_cnt].answer1="Unable to Collect")) OR ((sogi->list[for_cnt].answer2=
   "Unable to Collect"))) )
    IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
     SET ml_utc_emerg_cnt += 1
    ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
     SET ml_utc_inpat_cnt += 1
    ENDIF
   ENDIF
   IF ((((sogi->list[for_cnt].answer3="Unable to Collect")) OR ((((sogi->list[for_cnt].answer4=
   "Unable to Collect")) OR ((sogi->list[for_cnt].answer5="Unable to Collect"))) )) )
    IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
     SET ml_utc_emerg_6yo_cnt += 1
    ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
     SET ml_utc_inpat_6yo_cnt += 1
    ENDIF
   ENDIF
   IF ((sogi->list[for_cnt].answer6="Unable to Collect"))
    IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
     SET ml_utc_emerg_15yo_cnt += 1
    ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
     SET ml_utc_inpat_15yo_cnt += 1
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer1) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer1 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q1_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q1_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer2) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer2 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q2_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q2_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer3) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer3 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q3_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q3_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer4) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer4 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q4_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q4_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer5) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer5 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q5_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q5_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(sogi->list[for_cnt].answer6) > 1)
    IF ( NOT ((sogi->list[for_cnt].answer6 IN ("Unknown", "Unable to Collect"))))
     IF ((sogi->list[for_cnt].enc_typ_cd=679658.0))
      SET ml_pat_emerg_q6_cnt += 1
     ELSEIF ((sogi->list[for_cnt].enc_typ_cd=679656.0))
      SET ml_pat_inpat_q6_cnt += 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (e
   WHERE e.disch_dt_tm >= cnvtdatetime("01-JAN-2025")
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0, 679586.0,
   679549.0, 780611679.0, 580061823.0)
    AND e.encntr_type_cd IN (679658.0, 679656.00)
    AND e.disch_disposition_cd != 637025838)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0, 5007467.00, 11467249.00,
   18020434.00)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
  HEAD REPORT
   ml_pos = 0
  DETAIL
   ml_pos = locateval(ml_ndx,1,ml_pat_cnt,e.person_id,disch->list[ml_ndx].person_id,
    e.encntr_type_cd,disch->list[ml_ndx].enc_typ_cd)
   IF (ml_pos=0)
    ml_pat_cnt += 1, stat = alterlist(disch->list,ml_pat_cnt), disch->list[ml_pat_cnt].person_id = e
    .person_id,
    disch->list[ml_pat_cnt].enc_typ_cd = e.encntr_type_cd
    IF (e.encntr_type_cd=679658.0)
     ml_pat_emerg_total_cnt += 1
    ELSEIF (e.encntr_type_cd=679656.0)
     ml_pat_inpat_total_cnt += 1
    ENDIF
    IF (p.birth_dt_tm <= cnvtlookbehind("6,Y",cnvtdatetime("31-DEC-2024")))
     IF (e.encntr_type_cd=679658.0)
      ml_pat_emerg_6yo_cnt += 1
     ELSEIF (e.encntr_type_cd=679656.0)
      ml_pat_inpat_6yo_cnt += 1
     ENDIF
    ENDIF
    IF (p.birth_dt_tm <= cnvtlookbehind("15,Y",cnvtdatetime("31-DEC-2024")))
     IF (e.encntr_type_cd=679658.0)
      ml_pat_emerg_15yo_cnt += 1
     ELSEIF (e.encntr_type_cd=679656.0)
      ml_pat_inpat_15yo_cnt += 1
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   ml_pat_emerg_total_cnt -= ml_utc_emerg_cnt, ml_pat_inpat_total_cnt -= ml_utc_inpat_cnt,
   ml_pat_emerg_6yo_cnt -= ml_utc_emerg_6yo_cnt,
   ml_pat_inpat_6yo_cnt -= ml_utc_inpat_6yo_cnt, ml_pat_emerg_15yo_cnt -= ml_utc_emerg_15yo_cnt,
   ml_pat_inpat_15yo_cnt -= ml_utc_inpat_15yo_cnt
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("mass health total pat cnt:",ml_pat_cnt))
 CALL echo(build("mass health inpatient cnt:",ml_pat_inpat_total_cnt))
 CALL echo(build("mass health emergency cnt:",ml_pat_emerg_total_cnt))
 CALL echo(build("mass health inpatient 6yo cnt:",ml_pat_inpat_6yo_cnt))
 CALL echo(build("mass health emergency 6yo cnt:",ml_pat_emerg_6yo_cnt))
 CALL echo(build("mass health inpatient 15yo cnt:",ml_pat_inpat_15yo_cnt))
 CALL echo(build("mass health emergency 15yo cnt:",ml_pat_emerg_15yo_cnt))
 CALL echo(build("mass health inpatient Q1 cnt:",ml_pat_inpat_q1_cnt))
 CALL echo(build("mass health emergency Q1 cnt:",ml_pat_emerg_q1_cnt))
 CALL echo(build("mass health inpatient Q2 cnt:",ml_pat_inpat_q2_cnt))
 CALL echo(build("mass health emergency Q2 cnt:",ml_pat_emerg_q2_cnt))
 CALL echo(build("mass health inpatient Q3 cnt:",ml_pat_inpat_q3_cnt))
 CALL echo(build("mass health emergency Q3 cnt:",ml_pat_emerg_q3_cnt))
 CALL echo(build("mass health inpatient Q4 cnt:",ml_pat_inpat_q4_cnt))
 CALL echo(build("mass health emergency Q4 cnt:",ml_pat_emerg_q4_cnt))
 CALL echo(build("mass health inpatient Q5 cnt:",ml_pat_inpat_q5_cnt))
 CALL echo(build("mass health emergency Q5 cnt:",ml_pat_emerg_q5_cnt))
 CALL echo(build("mass health inpatient Q6 cnt:",ml_pat_inpat_q6_cnt))
 CALL echo(build("mass health emergency Q6 cnt:",ml_pat_emerg_q6_cnt))
 CALL echo("---")
 FREE RECORD sogi
END GO
