CREATE PROGRAM dcp_arpt_19_icu_death_rev:dba
 RECORD rpt_params(
   1 output_device = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 date_type = i2
   1 org_id = f8
   1 unit = f8
   1 unit_str = f8
   1 bed = vc
   1 ids[*]
     2 person_id = f8
     2 risk_id = f8
     2 bed_id = f8
     2 room_id = f8
     2 bed_desc = vc
     2 room_desc = vc
   1 icu_day = i2
   1 icu_admit_dt_tm = dq8
   1 beg_dt_disp = vc
   1 end_dt_disp = vc
   1 today = vc
   1 now = vc
   1 gen_on = vc
   1 date_type_disp = vc
   1 date_type_range_disp = vc
   1 unit_disp = vc
   1 org_name = vc
 )
 DECLARE meaning_code(p1,p1) = f8
 IF (isnumeric( $1))
  SET rpt_params->output_device = "MINE"
 ELSE
  SET rpt_params->output_device =  $1
 ENDIF
 IF (isnumeric( $2))
  SET rpt_params->beg_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->beg_dt_tm = cnvtdatetime( $2)
 ENDIF
 IF (isnumeric( $3))
  SET rpt_params->end_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->end_dt_tm = cnvtdatetime( $3)
 ENDIF
 IF (isnumeric( $4))
  SET rpt_params->date_type =  $4
 ELSE
  SET rpt_params->date_type = 1
 ENDIF
 IF (isnumeric( $5))
  SET rpt_params->org_id =  $5
 ELSE
  SET rpt_params->org_id = - (1)
 ENDIF
 IF (isnumeric( $7)=1)
  SET rpt_params->bed = "-1"
 ELSE
  SET rpt_params->bed =  $7
 ENDIF
 IF (trim(rpt_params->bed,3)="")
  SET rpt_params->bed = "-1"
 ENDIF
 IF (isnumeric( $9))
  SET rpt_params->icu_day =  $9
 ELSE
  SET rpt_params->icu_day = - (1)
 ENDIF
 IF (isnumeric( $10))
  SET rpt_params->icu_admit_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->icu_admit_dt_tm = cnvtdatetime( $10)
 ENDIF
 SET rpt_params->beg_dt_disp = format(rpt_params->beg_dt_tm,"DD-MMM-YYYY;;D")
 SET rpt_params->end_dt_disp = format(rpt_params->end_dt_tm,"DD-MMM-YYYY;;D")
 SET rpt_params->today = format(curdate,"mm/dd/yyyy ;;d")
 SET rpt_params->now = format(curtime,"hh:mm ;;m")
 SET rpt_params->gen_on = concat("Report generated on: ",rpt_params->today," ",rpt_params->now)
 IF ((rpt_params->date_type=3))
  SET rpt_params->date_type_disp = "For Hospital Admission Dates from "
 ELSEIF ((rpt_params->date_type=4))
  SET rpt_params->date_type_disp = "For Hospital Discharge Dates from "
 ELSEIF ((rpt_params->date_type=1))
  SET rpt_params->date_type_disp = "For ICU Admission Dates from "
 ELSE
  SET rpt_params->date_type_disp = "For ICU Discharge Dates from "
 ENDIF
 SET rpt_params->date_type_range_disp = concat(rpt_params->date_type_disp," ",rpt_params->beg_dt_disp,
  " to ",rpt_params->end_dt_disp)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_value= $6)
   AND ((c.code_set+ 0)=220)
   AND ((c.active_ind+ 0)=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt=1)
    rpt_params->unit_disp = c.display
   ELSE
    rpt_params->unit_disp = build(trim(rpt_params->unit_disp),", ",c.description)
   ENDIF
  FOOT REPORT
   cnt = 0
  WITH nocounter
 ;end select
 IF ((rpt_params->org_id=- (1)))
  SET rpt_params->org_name = "All Organizations"
 ELSE
  SELECT INTO "nl:"
   FROM organization o
   WHERE (o.organization_id=rpt_params->org_id)
    AND ((o.organization_id+ 0) != - (1))
    AND ((o.active_ind+ 0)=1)
   DETAIL
    rpt_params->org_name = trim(o.org_name,3)
   WITH nocounter
  ;end select
 ENDIF
 SET font80c = "{COLOR/0}{F/1}{CPI/10^}{LPI/6^}"
 SET font80 = "{COLOR/0}{F/9}{CPI/10^}{LPI/6^}"
 SET font110c = "{COLOR/0}{F/0}{CPI/14^}{LPI/8^}"
 SET font110 = "{COLOR/0}{F/8}{CPI/14^}{LPI/8^}"
 SET font140 = "{COLOR/0}{F/8}{CPI/16^}{LPI/10^}"
 SET dio_landscape = "{ps/792 0 translate 90 rotate/}"
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 RECORD units(
   1 cnt = i4
   1 tot_bed_count = i4
   1 unit[*]
     2 code = f8
     2 name = vc
     2 bed_count = i4
 )
 SELECT
  IF ((rpt_params->unit=- (1)))
   PLAN (rar
    WHERE rar.active_ind=1
     AND (rar.organization_id=rpt_params->org_id))
    JOIN (l
    WHERE l.organization_id=rar.organization_id
     AND l.icu_ind=1
     AND l.icu_ind=1)
    JOIN (l1
    WHERE ((l1.active_ind+ 0)=1)
     AND l1.parent_loc_cd=l.location_cd
     AND l1.root_loc_cd=0)
    JOIN (l2
    WHERE ((l2.active_ind+ 0)=1)
     AND l2.parent_loc_cd=l1.child_loc_cd
     AND l2.root_loc_cd=0)
  ELSE
   PLAN (rar
    WHERE rar.active_ind=1
     AND (rar.organization_id=rpt_params->org_id))
    JOIN (l
    WHERE l.organization_id=rar.organization_id
     AND (l.location_cd= $6)
     AND ((l.active_ind+ 0)=1)
     AND l.icu_ind=1)
    JOIN (l1
    WHERE ((l1.active_ind+ 0)=1)
     AND l1.parent_loc_cd=l.location_cd
     AND ((l1.root_loc_cd+ 0)=0))
    JOIN (l2
    WHERE ((l2.active_ind+ 0)=1)
     AND l2.parent_loc_cd=l1.child_loc_cd
     AND ((l2.root_loc_cd+ 0)=0))
  ENDIF
  INTO "nl:"
  FROM risk_adjustment_ref rar,
   location l,
   location_group l1,
   location_group l2
  ORDER BY rar.organization_id, l.location_cd
  HEAD REPORT
   unit_cnt = 0, tot_bed_cnt = 0, unit_bed_cnt = 0
  HEAD l.location_cd
   unit_cnt = (unit_cnt+ 1)
   IF (mod(unit_cnt,10)=1)
    stat = alterlist(units->unit,(unit_cnt+ 9))
   ENDIF
   units->unit[unit_cnt].code = l.location_cd, units->unit[unit_cnt].name = uar_get_code_display(l
    .location_cd), unit_bed_cnt = 0
  DETAIL
   tot_bed_cnt = (tot_bed_cnt+ 1), unit_bed_cnt = (unit_bed_cnt+ 1)
  FOOT  l.location_cd
   units->unit[unit_cnt].bed_count = unit_bed_cnt
  FOOT REPORT
   units->tot_bed_count = tot_bed_cnt, units->cnt = unit_cnt, stat = alterlist(units->unit,unit_cnt)
  WITH nocounter
 ;end select
 SET transfer_buffer_minutes = 1500
 RECORD risk_record(
   1 total_admit = i4
   1 total_readmit = i4
   1 risk[*]
     2 risk_id = f8
     2 icu_cd = f8
 )
 RECORD location_dt_tm(
   1 start_date = dq8
   1 end_date = dq8
 )
 SET admit_loc_in_clause = fillstring(5000," ")
 IF ((units->cnt > 0))
  SET admit_loc_in_clause = concat(" ra.admit_icu_cd in (",trim(cnvtstring(units->unit[1].code)))
  FOR (cnt = 2 TO units->cnt)
    SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),",",trim(cnvtstring(units->unit[cnt].
       code)))
  ENDFOR
  SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),")")
 ELSEIF ((units->cnt=0))
  SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),"0=0")
 ENDIF
 SELECT
  IF ((rpt_params->date_type=4))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND ra.icu_disch_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE ra.encntr_id=e.encntr_id
     AND ((e.disch_dt_tm+ 0) >= cnvtdatetime(rpt_params->beg_dt_tm))
     AND ((e.disch_dt_tm+ 0) <= cnvtdatetime(rpt_params->end_dt_tm))
     AND ((ra.active_ind+ 0)=1))
  ELSEIF ((rpt_params->date_type=1))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND ((e.active_ind+ 0)=1))
  ELSEIF ((rpt_params->date_type=2))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND ra.icu_disch_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.icu_disch_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND ((e.active_ind+ 0)=1))
  ELSE
   PLAN (ra
    WHERE ra.icu_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.hosp_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.hosp_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE ra.encntr_id=e.encntr_id
     AND ((ra.active_ind+ 0)=1))
  ENDIF
  INTO "nl:"
  FROM risk_adjustment ra,
   encounter e
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,500)=1)
    stat = alterlist(risk_record->risk,(counter+ 499))
   ENDIF
   risk_record->risk[counter].risk_id = ra.risk_adjustment_id, risk_record->total_admit = (
   risk_record->total_admit+ 1), risk_record->risk[counter].icu_cd = ra.admit_icu_cd
   IF (ra.readmit_ind=1)
    risk_record->total_readmit = (risk_record->total_readmit+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(risk_record->risk,counter)
  WITH nocounter
 ;end select
 RECORD surg_death(
   1 cnt = i2
   1 data[*]
     2 last_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 mrn = vc
     2 doc_id = f8
     2 doc_srv = vc
     2 age = i4
     2 admit_dx = vc
     2 icu_admit_dt = dq8
     2 disch_date = dq8
     2 icu_outcome = f8
     2 hosp_outcome = f8
     2 chi = vc
 )
 RECORD readmit_death(
   1 cnt = i2
   1 data[*]
     2 last_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 mrn = vc
     2 doc_id = f8
     2 doc_srv = vc
     2 age = i4
     2 admit_dx = vc
     2 icu_admit_dt = dq8
     2 disch_date = dq8
     2 icu_outcome = f8
     2 hosp_outcome = f8
     2 chi = vc
 )
 RECORD low_risk_death(
   1 cnt = i2
   1 data[*]
     2 last_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 mrn = vc
     2 doc_id = f8
     2 doc_srv = vc
     2 age = i4
     2 admit_dx = vc
     2 icu_admit_dt = dq8
     2 disch_date = dq8
     2 icu_outcome = f8
     2 hosp_outcome = f8
     2 chi = vc
 )
 RECORD pat_record(
   1 cnt = i2
   1 pat_data[*]
     2 r_risk_adjustment_id = f8
     2 e_encntr_id = f8
     2 r_person_id = f8
     2 ra_risk_adjustment_day_id = f8
     2 ra_cc_day = i4
     2 ra_outcome_status = i4
     2 r_icu_admit_dt_tm = dq8
     2 r_icu_disch_dt_tm = dq8
     2 r_hosp_admit_dt_tm = dq8
     2 r_hosp_disch_dt_tm = dq8
     2 e_name_last = vc
     2 r_admitdiagnosis = vc
     2 r_adm_doc_id = f8
     2 e_med_service_cd = vc
     2 r_age = i4
     2 r_chronic_health_none_ind = i2
     2 r_chronic_health_unavail_ind = i2
     2 r_cirrhosis_ind = i2
     2 r_copd_flag = i4
     2 r_copd_ind = i2
     2 r_diabetes_ind = i2
     2 r_dialysis_ind = i2
     2 r_hepaticfailure_ind = i2
     2 r_immunosuppression_ind = i2
     2 r_leukemia_ind = i2
     2 r_lymphoma_ind = i2
     2 r_metastaticcancer_ind = i2
     2 r_aids_ind = i2
     2 r_diedinhospital_ind = i2
     2 r_diedinicu_ind = i2
     2 r_readmit_ind = i2
 )
 SET mrn_cd = meaning_code(319,"MRN")
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = risk_record->total_admit),
   risk_adjustment r,
   encounter e,
   risk_adjustment_day ra,
   person p
  PLAN (d)
   JOIN (r
   WHERE (r.risk_adjustment_id=risk_record->risk[d.seq].risk_id)
    AND r.active_ind=1)
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY r.encntr_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pat_record->pat_data,cnt), pat_record->pat_data[cnt].
   r_risk_adjustment_id = r.risk_adjustment_id,
   pat_record->pat_data[cnt].e_encntr_id = e.encntr_id, pat_record->pat_data[cnt].
   ra_risk_adjustment_day_id = ra.risk_adjustment_day_id, pat_record->pat_data[cnt].ra_cc_day = ra
   .cc_day,
   pat_record->pat_data[cnt].ra_outcome_status = ra.outcome_status, pat_record->pat_data[cnt].
   r_icu_admit_dt_tm = r.icu_admit_dt_tm, pat_record->pat_data[cnt].r_icu_disch_dt_tm = r
   .icu_disch_dt_tm,
   pat_record->pat_data[cnt].r_hosp_admit_dt_tm = r.hosp_admit_dt_tm, pat_record->pat_data[cnt].
   r_hosp_disch_dt_tm = e.disch_dt_tm, pat_record->pat_data[cnt].e_name_last = p.name_last,
   pat_record->pat_data[cnt].r_admitdiagnosis = r.admit_diagnosis, pat_record->pat_data[cnt].
   r_adm_doc_id = r.adm_doc_id, pat_record->pat_data[cnt].e_med_service_cd = uar_get_code_display(r
    .med_service_cd),
   pat_record->pat_data[cnt].r_age = r.admit_age, pat_record->pat_data[cnt].r_chronic_health_none_ind
    = r.chronic_health_none_ind, pat_record->pat_data[cnt].r_chronic_health_unavail_ind = r
   .chronic_health_unavail_ind,
   pat_record->pat_data[cnt].r_cirrhosis_ind = r.cirrhosis_ind, pat_record->pat_data[cnt].r_copd_flag
    = r.copd_flag, pat_record->pat_data[cnt].r_copd_ind = r.copd_ind,
   pat_record->pat_data[cnt].r_diabetes_ind = r.diabetes_ind, pat_record->pat_data[cnt].
   r_dialysis_ind = r.dialysis_ind, pat_record->pat_data[cnt].r_hepaticfailure_ind = r
   .hepaticfailure_ind,
   pat_record->pat_data[cnt].r_immunosuppression_ind = r.immunosuppression_ind, pat_record->pat_data[
   cnt].r_leukemia_ind = r.leukemia_ind, pat_record->pat_data[cnt].r_lymphoma_ind = r.lymphoma_ind,
   pat_record->pat_data[cnt].r_metastaticcancer_ind = r.metastaticcancer_ind, pat_record->pat_data[
   cnt].r_aids_ind = r.aids_ind, pat_record->pat_data[cnt].r_person_id = r.person_id
   IF (r.diedinicu_ind=1)
    pat_record->pat_data[cnt].r_diedinhospital_ind = 1
   ELSE
    IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
     pat_record->pat_data[cnt].r_diedinhospital_ind = 1
    ELSE
     pat_record->pat_data[cnt].r_diedinhospital_ind = 0
    ENDIF
    IF (p.deceased_dt_tm > e.reg_dt_tm
     AND p.deceased_dt_tm <= e.disch_dt_tm)
     pat_record->pat_data[cnt].r_diedinhospital_ind = 1
    ENDIF
   ENDIF
   pat_record->pat_data[cnt].r_diedinicu_ind = r.diedinicu_ind, pat_record->pat_data[cnt].
   r_readmit_ind = r.readmit_ind
  FOOT REPORT
   pat_record->cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  risk_id = pat_record->pat_data[d.seq].r_risk_adjustment_id
  FROM (dummyt d  WITH seq = pat_record->cnt),
   risk_adjustment_outcomes rao
  PLAN (d
   WHERE (((pat_record->pat_data[d.seq].r_diedinhospital_ind=1)) OR ((pat_record->pat_data[d.seq].
   r_diedinicu_ind=1)))
    AND (pat_record->pat_data[d.seq].r_admitdiagnosis="S-*"))
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name IN ("NTL_HSP_DEATH", "NTL_ICU_DEATH")
    AND rao.active_ind=1)
  HEAD REPORT
   cnt = 0
  HEAD risk_id
   cnt = (cnt+ 1), stat = alterlist(surg_death->data,cnt), surg_death->data[cnt].hosp_outcome = - (1),
   surg_death->data[cnt].icu_outcome = - (1), surg_death->data[cnt].last_name = pat_record->pat_data[
   d.seq].e_name_last, surg_death->data[cnt].encntr_id = pat_record->pat_data[d.seq].e_encntr_id,
   surg_death->data[cnt].person_id = pat_record->pat_data[d.seq].r_person_id, surg_death->data[cnt].
   doc_id = pat_record->pat_data[d.seq].r_adm_doc_id, surg_death->data[cnt].doc_srv = pat_record->
   pat_data[d.seq].e_med_service_cd,
   surg_death->data[cnt].age = pat_record->pat_data[d.seq].r_age, surg_death->data[cnt].admit_dx =
   pat_record->pat_data[d.seq].r_admitdiagnosis, surg_death->data[cnt].icu_admit_dt = pat_record->
   pat_data[d.seq].r_icu_admit_dt_tm
   IF ((pat_record->pat_data[d.seq].r_diedinicu_ind=1))
    surg_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_icu_disch_dt_tm
   ELSE
    surg_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_hosp_disch_dt_tm
   ENDIF
   IF ((pat_record->pat_data[d.seq].r_aids_ind=1))
    surg_death->data[cnt].chi = "OTHERIMMUN"
   ELSEIF ((pat_record->pat_data[d.seq].r_hepaticfailure_ind=1))
    surg_death->data[cnt].chi = "HEPFAILURE"
   ELSEIF ((pat_record->pat_data[d.seq].r_lymphoma_ind=1))
    surg_death->data[cnt].chi = "LYMPHOMA"
   ELSEIF ((pat_record->pat_data[d.seq].r_metastaticcancer_ind=1))
    surg_death->data[cnt].chi = "TUMOR/METS"
   ELSEIF ((pat_record->pat_data[d.seq].r_leukemia_ind=1))
    surg_death->data[cnt].chi = "LEUK/MYEL"
   ELSEIF ((pat_record->pat_data[d.seq].r_immunosuppression_ind=1))
    surg_death->data[cnt].chi = "IMMUNOSUP"
   ELSEIF ((pat_record->pat_data[d.seq].r_cirrhosis_ind=1))
    surg_death->data[cnt].chi = "CIRRHOSIS"
   ELSEIF ((pat_record->pat_data[d.seq].r_copd_ind=1))
    IF ((pat_record->pat_data[d.seq].r_copd_flag=2))
     surg_death->data[cnt].chi = "COPD_SEV"
    ELSEIF ((pat_record->pat_data[d.seq].r_copd_flag=1))
     surg_death->data[cnt].chi = "COPD_MOD"
    ELSE
     surg_death->data[cnt].chi = "COPD_NOLIM"
    ENDIF
   ELSEIF ((pat_record->pat_data[d.seq].r_diabetes_ind=1))
    surg_death->data[cnt].chi = "DIABETES"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_unavail_ind=1))
    surg_death->data[cnt].chi = "UNAVAILABLE"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_none_ind=1))
    surg_death->data[cnt].chi = "NONE"
   ENDIF
  DETAIL
   IF (rao.equation_name="NTL_HSP_DEATH")
    surg_death->data[cnt].hosp_outcome = (rao.outcome_value * 100)
   ENDIF
   IF (rao.equation_name="NTL_ICU_DEATH")
    surg_death->data[cnt].icu_outcome = (rao.outcome_value * 100)
   ENDIF
  FOOT  risk_id
   surg_death->cnt = cnt
  WITH nocounter
 ;end select
 IF ((surg_death->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = surg_death->cnt),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=surg_death->data[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mrn_cd
     AND ea.active_ind=1)
   DETAIL
    surg_death->data[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  risk_id = pat_record->pat_data[d.seq].r_risk_adjustment_id
  FROM (dummyt d  WITH seq = pat_record->cnt),
   risk_adjustment_outcomes rao
  PLAN (d
   WHERE (((pat_record->pat_data[d.seq].r_diedinhospital_ind=1)) OR ((pat_record->pat_data[d.seq].
   r_diedinicu_ind=1)))
    AND (pat_record->pat_data[d.seq].r_readmit_ind=1))
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name IN ("NTL_HSP_DEATH", "NTL_ICU_DEATH")
    AND rao.active_ind=1)
  HEAD REPORT
   cnt = 0
  HEAD risk_id
   cnt = (cnt+ 1), stat = alterlist(readmit_death->data,cnt), readmit_death->data[cnt].hosp_outcome
    = - (1),
   readmit_death->data[cnt].icu_outcome = - (1), readmit_death->data[cnt].last_name = pat_record->
   pat_data[d.seq].e_name_last, readmit_death->data[cnt].encntr_id = pat_record->pat_data[d.seq].
   e_encntr_id,
   readmit_death->data[cnt].person_id = pat_record->pat_data[d.seq].r_person_id, readmit_death->data[
   cnt].doc_id = pat_record->pat_data[d.seq].r_adm_doc_id, readmit_death->data[cnt].doc_srv =
   pat_record->pat_data[d.seq].e_med_service_cd,
   readmit_death->data[cnt].age = pat_record->pat_data[d.seq].r_age, readmit_death->data[cnt].
   admit_dx = pat_record->pat_data[d.seq].r_admitdiagnosis, readmit_death->data[cnt].icu_admit_dt =
   pat_record->pat_data[d.seq].r_icu_admit_dt_tm
   IF ((pat_record->pat_data[d.seq].r_diedinicu_ind=1))
    readmit_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_icu_disch_dt_tm
   ELSE
    readmit_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_hosp_disch_dt_tm
   ENDIF
   IF ((pat_record->pat_data[d.seq].r_aids_ind=1))
    readmit_death->data[cnt].chi = "OTHERIMMUN"
   ELSEIF ((pat_record->pat_data[d.seq].r_hepaticfailure_ind=1))
    readmit_death->data[cnt].chi = "HEPFAILURE"
   ELSEIF ((pat_record->pat_data[d.seq].r_lymphoma_ind=1))
    readmit_death->data[cnt].chi = "LYMPHOMA"
   ELSEIF ((pat_record->pat_data[d.seq].r_metastaticcancer_ind=1))
    readmit_death->data[cnt].chi = "TUMOR/METS"
   ELSEIF ((pat_record->pat_data[d.seq].r_leukemia_ind=1))
    readmit_death->data[cnt].chi = "LEUK/MYEL"
   ELSEIF ((pat_record->pat_data[d.seq].r_immunosuppression_ind=1))
    readmit_death->data[cnt].chi = "IMMUNOSUP"
   ELSEIF ((pat_record->pat_data[d.seq].r_cirrhosis_ind=1))
    readmit_death->data[cnt].chi = "CIRRHOSIS"
   ELSEIF ((pat_record->pat_data[d.seq].r_copd_ind=1))
    IF ((pat_record->pat_data[d.seq].r_copd_flag=2))
     readmit_death->data[cnt].chi = "COPD_SEV"
    ELSEIF ((pat_record->pat_data[d.seq].r_copd_flag=1))
     readmit_death->data[cnt].chi = "COPD_MOD"
    ELSE
     readmit_death->data[cnt].chi = "COPD_NOLIM"
    ENDIF
   ELSEIF ((pat_record->pat_data[d.seq].r_diabetes_ind=1))
    readmit_death->data[cnt].chi = "DIABETES"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_unavail_ind=1))
    readmit_death->data[cnt].chi = "UNAVAILABLE"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_none_ind=1))
    readmit_death->data[cnt].chi = "NONE"
   ENDIF
  DETAIL
   IF (rao.equation_name="NTL_HSP_DEATH")
    readmit_death->data[cnt].hosp_outcome = (rao.outcome_value * 100)
   ENDIF
   IF (rao.equation_name="NTL_ICU_DEATH")
    readmit_death->data[cnt].icu_outcome = (rao.outcome_value * 100)
   ENDIF
  FOOT REPORT
   readmit_death->cnt = cnt
  WITH nocounter
 ;end select
 IF ((readmit_death->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = readmit_death->cnt),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=readmit_death->data[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mrn_cd
     AND ea.active_ind=1)
   DETAIL
    readmit_death->data[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  risk_id = pat_record->pat_data[d.seq].r_risk_adjustment_id
  FROM (dummyt d  WITH seq = pat_record->cnt),
   risk_adjustment_outcomes rao,
   risk_adjustment_outcomes rao1
  PLAN (d
   WHERE (((pat_record->pat_data[d.seq].r_diedinhospital_ind=1)) OR ((pat_record->pat_data[d.seq].
   r_diedinicu_ind=1))) )
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name IN ("NTL_HSP_DEATH", "NTL_ICU_DEATH")
    AND rao.active_ind=1)
   JOIN (rao1
   WHERE (rao1.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao1.equation_name="NTL_HSP_DEATH"
    AND rao1.outcome_value <= 0.2
    AND rao1.active_ind=1)
  HEAD REPORT
   cnt = 0
  HEAD risk_id
   cnt = (cnt+ 1), stat = alterlist(low_risk_death->data,cnt), low_risk_death->data[cnt].icu_outcome
    = - (1),
   low_risk_death->data[cnt].hosp_outcome = - (1), low_risk_death->data[cnt].last_name = pat_record->
   pat_data[d.seq].e_name_last, low_risk_death->data[cnt].encntr_id = pat_record->pat_data[d.seq].
   e_encntr_id,
   low_risk_death->data[cnt].person_id = pat_record->pat_data[d.seq].r_person_id, low_risk_death->
   data[cnt].doc_id = pat_record->pat_data[d.seq].r_adm_doc_id, low_risk_death->data[cnt].doc_srv =
   pat_record->pat_data[d.seq].e_med_service_cd,
   low_risk_death->data[cnt].age = pat_record->pat_data[d.seq].r_age, low_risk_death->data[cnt].
   admit_dx = pat_record->pat_data[d.seq].r_admitdiagnosis, low_risk_death->data[cnt].icu_admit_dt =
   pat_record->pat_data[d.seq].r_icu_admit_dt_tm
   IF ((pat_record->pat_data[d.seq].r_diedinicu_ind=1))
    low_risk_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_icu_disch_dt_tm
   ELSE
    low_risk_death->data[cnt].disch_date = pat_record->pat_data[d.seq].r_hosp_disch_dt_tm
   ENDIF
   IF ((pat_record->pat_data[d.seq].r_aids_ind=1))
    low_risk_death->data[cnt].chi = "OTHERIMMUN"
   ELSEIF ((pat_record->pat_data[d.seq].r_hepaticfailure_ind=1))
    low_risk_death->data[cnt].chi = "HEPFAILURE"
   ELSEIF ((pat_record->pat_data[d.seq].r_lymphoma_ind=1))
    low_risk_death->data[cnt].chi = "LYMPHOMA"
   ELSEIF ((pat_record->pat_data[d.seq].r_metastaticcancer_ind=1))
    low_risk_death->data[cnt].chi = "TUMOR/METS"
   ELSEIF ((pat_record->pat_data[d.seq].r_leukemia_ind=1))
    low_risk_death->data[cnt].chi = "LEUK/MYEL"
   ELSEIF ((pat_record->pat_data[d.seq].r_immunosuppression_ind=1))
    low_risk_death->data[cnt].chi = "IMMUNOSUP"
   ELSEIF ((pat_record->pat_data[d.seq].r_cirrhosis_ind=1))
    low_risk_death->data[cnt].chi = "CIRRHOSIS"
   ELSEIF ((pat_record->pat_data[d.seq].r_copd_ind=1))
    IF ((pat_record->pat_data[d.seq].r_copd_flag=2))
     low_risk_death->data[cnt].chi = "COPD_SEV"
    ELSEIF ((pat_record->pat_data[d.seq].r_copd_flag=1))
     low_risk_death->data[cnt].chi = "COPD_MOD"
    ELSE
     low_risk_death->data[cnt].chi = "COPD_NOLIM"
    ENDIF
   ELSEIF ((pat_record->pat_data[d.seq].r_diabetes_ind=1))
    low_risk_death->data[cnt].chi = "DIABETES"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_unavail_ind=1))
    low_risk_death->data[cnt].chi = "UNAVAILABLE"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_none_ind=1))
    low_risk_death->data[cnt].chi = "NONE"
   ENDIF
  DETAIL
   IF (rao.equation_name="NTL_ICU_DEATH")
    low_risk_death->data[cnt].icu_outcome = (rao.outcome_value * 100)
   ENDIF
   IF (rao.equation_name="NTL_HSP_DEATH")
    low_risk_death->data[cnt].hosp_outcome = (rao.outcome_value * 100)
   ENDIF
  FOOT REPORT
   low_risk_death->cnt = cnt
  WITH nocounter
 ;end select
 IF ((low_risk_death->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = low_risk_death->cnt),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=low_risk_death->data[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mrn_cd
     AND ea.active_ind=1)
   DETAIL
    low_risk_death->data[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   title_text = fillstring(30," "), title_text = "Surgical Deaths"
  HEAD PAGE
   col 0, dio_landscape, col 50,
   font110c, doc_id_disp = fillstring(15," "), icu_outcome_disp = fillstring(7," "),
   hosp_outcome_disp = fillstring(7," "), disch_date_disp = fillstring(13," "), ftot_admit = 0.0,
   ftot_admit = risk_record->total_admit, break_pos = 520, row + 2,
   y_pos = 30, x_pos = 0, count = 1,
   line = fillstring(370,"-"), date_full_disp = fillstring(70," "),
   CALL print(calcpos(15,y_pos)),
   rpt_params->gen_on,
   CALL print(calcpos(575,y_pos)), "By Module: dcp_aprt_19_icu_death_rev",
   CALL print(calcpos(348,y_pos)), "APACHE For ICU", row + 1,
   y_pos = (y_pos+ 10), col 0, font80c,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(325,y_pos)),
   "ICU Death Review", row + 1, col 0,
   font110c, row + 1, y_pos = (y_pos+ 15),
   len = size(rpt_params->date_type_range_disp,1), x_pos = (400 - (len * 2.25)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->date_type_range_disp, row + 1, y_pos = (y_pos+ 15),
   line = fillstring(100,"-"),
   CALL print(calcpos(155,y_pos)), line,
   row + 1, y_pos = (y_pos+ 15), len = size(rpt_params->org_name,1),
   x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->org_name,
   row + 1, y_pos = (y_pos+ 10), len = size(rpt_params->unit_disp,1),
   x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->unit_disp,
   y_pos = (y_pos+ 30), row + 1, line2 = fillstring(300,"-"),
   row + 1,
   CALL print(calcpos(350,y_pos)), title_text,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(575,y_pos)),
   "% Risk of",
   CALL print(calcpos(640,y_pos)), "% Risk of",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)),
   "Patient",
   CALL print(calcpos(80,y_pos)), "Patient",
   CALL print(calcpos(340,y_pos)), "Chronic",
   CALL print(calcpos(400,y_pos)),
   "ICU Admit",
   CALL print(calcpos(490,y_pos)), "ICU Admit",
   CALL print(calcpos(595,y_pos)), "ICU",
   CALL print(calcpos(640,y_pos)),
   "Hospital",
   CALL print(calcpos(710,y_pos)), "Date of",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)),
   "Name",
   CALL print(calcpos(80,y_pos)), "ID",
   CALL print(calcpos(180,y_pos)), "Physician",
   CALL print(calcpos(250,y_pos)),
   "Service",
   CALL print(calcpos(310,y_pos)), "Age",
   CALL print(calcpos(340,y_pos)), "Health",
   CALL print(calcpos(400,y_pos)),
   "Diagnosis",
   CALL print(calcpos(490,y_pos)), "Date",
   CALL print(calcpos(575,y_pos)), "Death Ntl",
   CALL print(calcpos(640,y_pos)),
   "Death Ntl",
   CALL print(calcpos(710,y_pos)), "Death",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)),
   line2
  DETAIL
   count = size(surg_death->data,5), count_disp = format(count,"###")
   FOR (x = 1 TO count)
     row + 1, y_pos = (y_pos+ 10)
     IF (y_pos > break_pos
      AND x < count)
      BREAK
     ENDIF
     IF ((surg_death->data[x].doc_id=- (1)))
      doc_id_disp = "  N/A"
     ELSE
      doc_id_disp = format(surg_death->data[x].doc_id,"###########;l")
     ENDIF
     age_disp = format(surg_death->data[x].age,"###;l"), icu_admit_dt_disp = format(surg_death->data[
      x].icu_admit_dt,"dd-mmm-yyyy ;;d"), disch_date_disp = format(surg_death->data[x].disch_date,
      "dd-mmm-yyyy ;;d")
     IF ((surg_death->data[x].icu_outcome=- (1)))
      icu_outcome_disp = "  N/A"
     ELSE
      icu_outcome_disp = format(surg_death->data[x].icu_outcome,"###.##%;r")
     ENDIF
     IF ((surg_death->data[x].hosp_outcome=- (1)))
      hosp_outcome_disp = "  N/A"
     ELSE
      hosp_outcome_disp = format(surg_death->data[x].hosp_outcome,"###.##%;r")
     ENDIF
     srv = substring(1,6,surg_death->data[x].doc_srv),
     CALL print(calcpos(15,y_pos)), surg_death->data[x].last_name,
     CALL print(calcpos(80,y_pos)), surg_death->data[x].mrn,
     CALL print(calcpos(180,y_pos)),
     doc_id_disp,
     CALL print(calcpos(250,y_pos)), srv,
     CALL print(calcpos(310,y_pos)), age_disp,
     CALL print(calcpos(340,y_pos)),
     surg_death->data[x].chi,
     CALL print(calcpos(400,y_pos)), surg_death->data[x].admit_dx,
     CALL print(calcpos(485,y_pos)), icu_admit_dt_disp,
     CALL print(calcpos(580,y_pos)),
     icu_outcome_disp,
     CALL print(calcpos(640,y_pos)), hosp_outcome_disp,
     CALL print(calcpos(705,y_pos)), disch_date_disp
   ENDFOR
   row + 3, y_pos = (y_pos+ 30)
   IF (((y_pos+ 40) > break_pos))
    BREAK
   ENDIF
   CALL print(calcpos(15,y_pos)), "Flagged patients.........................:", surg_cnt = format(
    surg_death->cnt,"#######;l"),
   CALL print(calcpos(250,y_pos)), surg_cnt, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Total number of patients(see note):",
   pat_cnt = format(risk_record->total_admit,"#######;l"),
   CALL print(calcpos(250,y_pos)), pat_cnt,
   row + 1, y_pos = (y_pos+ 10), col 5,
   "Note: Includes all ICU patients during this time period.", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Percentage...............................:", pct_ratio = ((
   surg_death->cnt/ ftot_admit) * 100),
   pct_disp = format(pct_ratio,"###.##%;l"),
   CALL print(calcpos(250,y_pos)), pct_disp,
   row + 3, y_pos = (y_pos+ 30), title_text = "Readmission Deaths",
   BREAK
   FOR (x = 1 TO readmit_death->cnt)
     row + 1, y_pos = (y_pos+ 10)
     IF (y_pos > break_pos
      AND (x < readmit_death->cnt))
      BREAK
     ENDIF
     IF ((readmit_death->data[x].doc_id=- (1)))
      doc_id_disp = "  N/A"
     ELSE
      doc_id_disp = format(readmit_death->data[x].doc_id,"###########;l")
     ENDIF
     age_disp = format(readmit_death->data[x].age,"###;l"), icu_admit_dt_disp = format(readmit_death
      ->data[x].icu_admit_dt,"dd-mmm-yyyy ;;d"), disch_date_disp = format(readmit_death->data[x].
      disch_date,"dd-mmm-yyyy ;;d")
     IF ((readmit_death->data[x].icu_outcome=- (1)))
      icu_outcome_disp = "  N/A"
     ELSE
      icu_outcome_disp = format(readmit_death->data[x].icu_outcome,"###.##%;r")
     ENDIF
     IF ((readmit_death->data[x].hosp_outcome=- (1)))
      hosp_outcome_disp = "  N/A"
     ELSE
      hosp_outcome_disp = format(readmit_death->data[x].hosp_outcome,"###.##%;r")
     ENDIF
     srv = substring(1,6,readmit_death->data[x].doc_srv),
     CALL print(calcpos(15,y_pos)), readmit_death->data[x].last_name,
     CALL print(calcpos(80,y_pos)), readmit_death->data[x].mrn,
     CALL print(calcpos(180,y_pos)),
     doc_id_disp,
     CALL print(calcpos(250,y_pos)), srv,
     CALL print(calcpos(310,y_pos)), age_disp,
     CALL print(calcpos(340,y_pos)),
     readmit_death->data[x].chi,
     CALL print(calcpos(400,y_pos)), readmit_death->data[x].admit_dx,
     CALL print(calcpos(485,y_pos)), icu_admit_dt_disp,
     CALL print(calcpos(580,y_pos)),
     icu_outcome_disp,
     CALL print(calcpos(640,y_pos)), hosp_outcome_disp,
     CALL print(calcpos(705,y_pos)), disch_date_disp
   ENDFOR
   row + 3, y_pos = (y_pos+ 30)
   IF (((y_pos+ 40) > break_pos))
    BREAK
   ENDIF
   CALL print(calcpos(15,y_pos)), "Flagged patients.........................:", surg_cnt = format(
    readmit_death->cnt,"#######;l"),
   CALL print(calcpos(250,y_pos)), surg_cnt, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Total number of patients(see note):",
   pat_cnt = format(risk_record->total_admit,"#######;l"),
   CALL print(calcpos(250,y_pos)), pat_cnt,
   row + 1, y_pos = (y_pos+ 10), col 5,
   "Note: Includes all ICU patients during this time period.", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Percentage...............................:", pct_ratio = ((
   readmit_death->cnt/ ftot_admit) * 100),
   pct_disp = format(pct_ratio,"###.##%;l"),
   CALL print(calcpos(250,y_pos)), pct_disp,
   row + 3, y_pos = (y_pos+ 30), title_text = "Low Risk ICU Deaths (<=20%)",
   BREAK
   FOR (x = 1 TO low_risk_death->cnt)
     row + 1, y_pos = (y_pos+ 10)
     IF (y_pos > break_pos
      AND (x < low_risk_death->cnt))
      BREAK
     ENDIF
     IF ((low_risk_death->data[x].doc_id=- (1)))
      doc_id_disp = "  N/A"
     ELSE
      doc_id_disp = format(low_risk_death->data[x].doc_id,"###########;l")
     ENDIF
     age_disp = format(low_risk_death->data[x].age,"###;l"), icu_admit_dt_disp = format(
      low_risk_death->data[x].icu_admit_dt,"dd-mmm-yyyy ;;d"), disch_date_disp = format(
      low_risk_death->data[x].disch_date,"dd-mmm-yyyy ;;d")
     IF ((low_risk_death->data[x].icu_outcome=- (1)))
      icu_outcome_disp = "  N/A"
     ELSE
      icu_outcome_disp = format(low_risk_death->data[x].icu_outcome,"###.##%;r")
     ENDIF
     IF ((low_risk_death->data[x].hosp_outcome=- (1)))
      hosp_outcome_disp = "  N/A"
     ELSE
      hosp_outcome_disp = format(low_risk_death->data[x].hosp_outcome,"###.##%;r")
     ENDIF
     srv = substring(1,6,low_risk_death->data[x].doc_srv),
     CALL print(calcpos(15,y_pos)), low_risk_death->data[x].last_name,
     CALL print(calcpos(80,y_pos)), low_risk_death->data[x].mrn,
     CALL print(calcpos(180,y_pos)),
     doc_id_disp,
     CALL print(calcpos(250,y_pos)), srv,
     CALL print(calcpos(310,y_pos)), age_disp,
     CALL print(calcpos(340,y_pos)),
     low_risk_death->data[x].chi,
     CALL print(calcpos(400,y_pos)), low_risk_death->data[x].admit_dx,
     CALL print(calcpos(485,y_pos)), icu_admit_dt_disp,
     CALL print(calcpos(580,y_pos)),
     icu_outcome_disp,
     CALL print(calcpos(640,y_pos)), hosp_outcome_disp,
     CALL print(calcpos(705,y_pos)), disch_date_disp
   ENDFOR
   row + 3, y_pos = (y_pos+ 30)
   IF (((y_pos+ 40) > break_pos))
    BREAK
   ENDIF
   CALL print(calcpos(15,y_pos)), "Flagged patients.........................:", surg_cnt = format(
    low_risk_death->cnt,"#######;l"),
   CALL print(calcpos(250,y_pos)), surg_cnt, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Total number of patients(see note):",
   pat_cnt = format(risk_record->total_admit,"#######;l"),
   CALL print(calcpos(250,y_pos)), pat_cnt,
   row + 1, y_pos = (y_pos+ 10), col 5,
   "Note: Includes all ICU patients during this time period.", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Percentage...............................:", pct_ratio = ((
   low_risk_death->cnt/ ftot_admit) * 100),
   pct_disp = format(pct_ratio,"###.##%;l"),
   CALL print(calcpos(250,y_pos)), pct_disp
  FOOT PAGE
   row + 1, curr_page = format(curpage,"###"), page_disp = concat("------  Page ",trim(curr_page),
    "  ------"),
   CALL print(calcpos(330,540)), page_disp
  WITH dio = postscript, maxrow = 81, maxcol = 800
 ;end select
END GO
