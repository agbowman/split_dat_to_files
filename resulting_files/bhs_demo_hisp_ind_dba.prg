CREATE PROGRAM bhs_demo_hisp_ind:dba
 DECLARE mc_pat_type = vc
 DECLARE mc_disch_dt = vc
 DECLARE mc_hisp_ind = vc
 DECLARE mc_str = vc
 DECLARE ml_pos = i4
 DECLARE ml_pos2 = i4
 DECLARE ml_ndx = i4
 DECLARE ml_ndx2 = i4
 DECLARE ml_pat_cnt = i4
 DECLARE ml_pat_inpat_hisp_ind_cnt = i4
 DECLARE ml_pat_emerg_hisp_ind_cnt = i4
 DECLARE ml_pat_inpat_total_cnt = i4
 DECLARE ml_pat_emerg_total_cnt = i4
 DECLARE ml_utc_inpat_hisp_ind_cnt = i4
 DECLARE ml_utc_emerg_hisp_ind_cnt = i4
 FREE RECORD sogi
 RECORD sogi(
   1 sogi_cnt = i4
   1 list[*]
     2 cmrn = vc
     2 person_id = f8
     2 pat_type = vc
     2 enc_typ_cd = f8
     2 disch_date = vc
     2 hisp_ind = vc
 )
 FREE RECORD disch
 RECORD disch(
   1 list[*]
     2 person_id = f8
     2 enc_typ_cd = f8
 )
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   health_plan hp,
   encntr_plan_reltn epr,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm > cnvtdatetime("01-JAN-2025")
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0, 679586.0,
   679549.0, 780611679.0, 580061823.0)
    AND e.encntr_type_cd IN (679658.0, 679656.00)
    AND e.disch_disposition_cd != 637025838)
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
   ml_pos = locateval(ml_ndx,1,sogi->sogi_cnt,e.person_id,sogi->list[ml_ndx].person_id,
    e.encntr_type_cd,sogi->list[ml_ndx].enc_typ_cd)
   IF (ml_pos=0)
    sogi->sogi_cnt += 1, stat = alterlist(sogi->list,sogi->sogi_cnt), ml_pos = sogi->sogi_cnt
    IF (p.ethnic_grp_cd=2008714289.0)
     IF (e.encntr_type_cd=679658.0)
      ml_utc_emerg_hisp_ind_cnt += 1
     ELSEIF (e.encntr_type_cd=679656.0)
      ml_utc_inpat_hisp_ind_cnt += 1
     ENDIF
    ENDIF
    IF ( NOT (p.ethnic_grp_cd IN (312508.0, 2008714289.0)))
     IF (e.encntr_type_cd=679658.0)
      ml_pat_emerg_hisp_ind_cnt += 1
     ELSEIF (e.encntr_type_cd=679656.0)
      ml_pat_inpat_hisp_ind_cnt += 1
     ENDIF
    ENDIF
   ENDIF
   sogi->list[ml_pos].cmrn = pa.alias, sogi->list[ml_pos].person_id = p.person_id, sogi->list[ml_pos]
   .pat_type = uar_get_code_display(e.encntr_type_cd),
   sogi->list[ml_pos].enc_typ_cd = e.encntr_type_cd, sogi->list[ml_pos].disch_date = format(e
    .disch_dt_tm,"DD-MMM-YYYY HH:MM;;q"), sogi->list[ml_pos].hisp_ind = uar_get_code_display(p
    .ethnic_grp_cd)
   CASE (sogi->list[ml_pos].hisp_ind)
    OF "English":
    OF "Punjabi":
    OF "Spanish":
    OF "UT":
     sogi->list[ml_pos].hisp_ind = ""
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (e
   WHERE e.disch_dt_tm >= cnvtdatetime("01-JAN-2025")
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0, 679586.0,
   679549.0, 780611679.0, 580061823.0)
    AND e.encntr_type_cd IN (679658.0, 679656.00)
    AND e.disch_disposition_cd != 637025838)
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
   ENDIF
  FOOT REPORT
   ml_pat_emerg_total_cnt -= ml_utc_emerg_hisp_ind_cnt, ml_pat_inpat_total_cnt -=
   ml_utc_inpat_hisp_ind_cnt
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("mass health total pat cnt:",ml_pat_cnt))
 CALL echo(build("mass health inpatient cnt:",ml_pat_inpat_total_cnt))
 CALL echo(build("mass health inpatient hisp_ind cnt:",ml_pat_inpat_hisp_ind_cnt))
 CALL echo(build("mass health emergency cnt:",ml_pat_emerg_total_cnt))
 CALL echo(build("mass health emergency hisp_ind cnt:",ml_pat_emerg_hisp_ind_cnt))
 CALL echo("---")
 FREE RECORD sogi
END GO
