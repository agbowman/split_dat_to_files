CREATE PROGRAM dcp_arpt_7_unit_pt_summ_o:dba
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
 RECORD icupatientcount(
   1 total_pat = f8
   1 admit_service[*]
     2 cd = f8
     2 service = vc
     2 srv_num_pat = i2
   1 admit_service_temp[*]
     2 cd = f8
     2 service = vc
     2 srv_num_pat = i2
   1 admit_src[*]
     2 source_cdf = vc
     2 source = vc
     2 src_num_pat = i2
   1 admit_src_temp[*]
     2 source_cdf = vc
     2 source = vc
     2 src_num_pat = i2
   1 most_freq_disease[*]
     2 disease = vc
     2 disease_num_pat = i2
   1 most_freq_disease_temp[*]
     2 disease = vc
     2 disease_num_pat = i2
   1 most_freq_diag[*]
     2 diagnosis = vc
     2 dx_num_pat = i2
   1 most_freq_diag_temp[*]
     2 diagnosis = vc
     2 dx_num_pat = i2
   1 num_pat_over_65 = i2
   1 avg_age = f8
   1 min_age = i2
   1 max_age = i2
   1 avg_ap3_day1 = f8
   1 min_ap3 = i2
   1 max_ap3 = i2
   1 avg_aps_day1 = f8
   1 min_aps = i2
   1 max_aps = i2
   1 num_pat_chi = f8
   1 severe_chi[*]
     2 chi = vc
     2 tot = i2
   1 severe_chi_temp[*]
     2 chi = vc
     2 tot = i2
   1 num_pat_severe_chi = i2
   1 num_pat_more_one_chi = i2
   1 num_pat_dialysis = i2
   1 num_pat_unavail_chi = i2
   1 num_pat_no_chi = i2
   1 num_pat_diabetes = i2
   1 num_pat_copd = i2
   1 active_tx_cnt = i2
   1 hi_risk_mon_cnt = i2
   1 lo_risk_mon_cnt = i2
   1 np_non_act_cnt = i2
   1 np_act_cnt = i2
   1 therp_level_na = i2
 )
 RECORD pat_record(
   1 cnt = i2
   1 pat_data[*]
     2 risk_adjustment_id = f8
     2 encntr_id = f8
     2 loc_nurse_unit_disp = vc
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 med_service_disp = vc
     2 med_service_cd = f8
     2 admit_source = vc
     2 admitdiagnosis = vc
     2 age = i2
     2 aps_score = i2
     2 apache_iii_score = i2
     2 chronic_health_none_ind = i2
     2 chronic_health_unavail_ind = i2
     2 cirrhosis_ind = i2
     2 copd_flag = i4
     2 copd_ind = i2
     2 diabetes_ind = i2
     2 dialysis_ind = i2
     2 hepaticfailure_ind = i2
     2 immunosuppression_ind = i2
     2 leukemia_ind = i2
     2 lymphoma_ind = i2
     2 metastaticcancer_ind = i2
     2 aids_ind = i2
     2 therapy_level = i4
     2 disease_category = vc
 )
 DECLARE rpt7_source_cd = f8
 DECLARE num1 = i4
 SELECT INTO "nl:"
  FROM risk_adjustment r,
   encounter e,
   risk_adjustment_day ra
  PLAN (r
   WHERE expand(num1,1,risk_record->total_admit,r.risk_adjustment_id,risk_record->risk[num1].risk_id)
    AND r.risk_adjustment_id > 0.0
    AND ((r.active_ind+ 0)=1))
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.active_ind=1
    AND ra.cc_day=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND ((e.active_ind+ 0)=1))
  ORDER BY r.med_service_cd
  HEAD REPORT
   counter = 0, curr_index = 0, icupatientcount->num_pat_dialysis = 0,
   icupatientcount->num_pat_unavail_chi = 0, icupatientcount->num_pat_no_chi = 0, icupatientcount->
   num_pat_diabetes = 0,
   icupatientcount->num_pat_copd = 0, icupatientcount->active_tx_cnt = 0, icupatientcount->
   hi_risk_mon_cnt = 0,
   icupatientcount->lo_risk_mon_cnt = 0, icupatientcount->np_non_act_cnt = 0, icupatientcount->
   np_act_cnt = 0,
   icupatientcount->therp_level_na = 0, curr_index2 = 0, total_pat = 0
  HEAD r.med_service_cd
   total_srv = 0, curr_index = (curr_index+ 1)
   IF (mod(curr_index,10)=1)
    stat = alterlist(icupatientcount->admit_service_temp,(curr_index+ 9))
   ENDIF
   IF (r.med_service_cd > 0)
    icupatientcount->admit_service_temp[curr_index].service = uar_get_code_display(r.med_service_cd)
   ELSE
    icupatientcount->admit_service_temp[curr_index].service = "N/A"
   ENDIF
  DETAIL
   counter = (counter+ 1), total_srv = (total_srv+ 1)
   IF (mod(counter,risk_record->total_admit)=1)
    stat = alterlist(pat_record->pat_data,(counter+ risk_record->total_admit))
   ENDIF
   pat_record->pat_data[counter].risk_adjustment_id = r.risk_adjustment_id, pat_record->pat_data[
   counter].encntr_id = e.encntr_id, pat_record->pat_data[counter].icu_admit_dt_tm = r
   .icu_admit_dt_tm,
   pat_record->pat_data[counter].icu_disch_dt_tm = r.icu_disch_dt_tm, pat_record->pat_data[counter].
   disch_dt_tm = e.disch_dt_tm, pat_record->pat_data[counter].reg_dt_tm = e.reg_dt_tm,
   pat_record->pat_data[counter].med_service_cd = r.med_service_cd
   IF (r.med_service_cd > 0)
    pat_record->pat_data[counter].med_service_disp = uar_get_code_display(r.med_service_cd)
   ELSE
    pat_record->pat_data[counter].med_service_disp = "N/A"
   ENDIF
   pat_record->pat_data[counter].admit_source = r.admit_source, pat_record->pat_data[counter].
   admitdiagnosis = r.admit_diagnosis, pat_record->pat_data[counter].age = r.admit_age,
   pat_record->pat_data[counter].aps_score = ra.aps_score, pat_record->pat_data[counter].
   apache_iii_score = ra.apache_iii_score, pat_record->pat_data[counter].chronic_health_none_ind = r
   .chronic_health_none_ind
   IF (r.chronic_health_none_ind=1)
    icupatientcount->num_pat_no_chi = (icupatientcount->num_pat_no_chi+ 1)
   ENDIF
   pat_record->pat_data[counter].chronic_health_unavail_ind = r.chronic_health_unavail_ind
   IF (r.chronic_health_unavail_ind=1)
    icupatientcount->num_pat_unavail_chi = (icupatientcount->num_pat_unavail_chi+ 1)
   ENDIF
   pat_record->pat_data[counter].cirrhosis_ind = r.cirrhosis_ind, pat_record->pat_data[counter].
   copd_flag = r.copd_flag, pat_record->pat_data[counter].copd_ind = r.copd_ind,
   pat_record->pat_data[counter].diabetes_ind = r.diabetes_ind
   IF (r.diabetes_ind=1)
    icupatientcount->num_pat_diabetes = (icupatientcount->num_pat_diabetes+ 1)
   ENDIF
   IF (r.copd_ind=1)
    icupatientcount->num_pat_copd = (icupatientcount->num_pat_copd+ 1)
   ENDIF
   pat_record->pat_data[counter].dialysis_ind = r.dialysis_ind
   IF (r.dialysis_ind=1)
    icupatientcount->num_pat_dialysis = (icupatientcount->num_pat_dialysis+ 1)
   ENDIF
   pat_record->pat_data[counter].hepaticfailure_ind = r.hepaticfailure_ind, pat_record->pat_data[
   counter].immunosuppression_ind = r.immunosuppression_ind, pat_record->pat_data[counter].
   leukemia_ind = r.leukemia_ind,
   pat_record->pat_data[counter].lymphoma_ind = r.lymphoma_ind, pat_record->pat_data[counter].
   metastaticcancer_ind = r.metastaticcancer_ind, pat_record->pat_data[counter].aids_ind = r.aids_ind,
   pat_record->pat_data[counter].therapy_level = r.therapy_level
   IF (((r.admit_age < 16) OR (((r.admit_diagnosis IN ("BONMARTRAN", "BURN", "S-BURN", "HEARTRAN",
   "HRTLNGTRAN",
   "KIDPANTRAN", "LIVSMBTRAN", "LUNGSTRAN", "LUNGTRAN", "PANCRETRAN",
   "S-BMARTRAN", "S-HEARTRAN", "S-HTLNTRAN", "S-KIDPTRAN", "S-LSMBTRAN",
   "S-LNGSTRAN", "S-LUNGTRAN", "S-PANTRAN", "S-SMBTRAN", "S-TRANOTH",
   "SMBOWLTRAN", "TRANOTHER")) OR (r.admit_source IN ("ICU", "CHPAIN_CTR", "ICU_TO_OR"))) )) )
    IF (ra.activetx_ind=1)
     icupatientcount->np_act_cnt = (icupatientcount->np_act_cnt+ 1)
    ELSE
     icupatientcount->np_non_act_cnt = (icupatientcount->np_non_act_cnt+ 1)
    ENDIF
   ELSEIF (r.therapy_level=1)
    icupatientcount->active_tx_cnt = (icupatientcount->active_tx_cnt+ 1)
   ELSEIF (r.therapy_level=2)
    icupatientcount->lo_risk_mon_cnt = (icupatientcount->lo_risk_mon_cnt+ 1)
   ELSEIF (r.therapy_level=3)
    icupatientcount->hi_risk_mon_cnt = (icupatientcount->hi_risk_mon_cnt+ 1)
   ELSE
    icupatientcount->therp_level_na = (icupatientcount->therp_level_na+ 1)
   ENDIF
   pat_record->pat_data[counter].disease_category = uar_get_code_meaning(r.disease_category_cd),
   adm_src_size = size(icupatientcount->admit_src_temp,5), num = 0,
   pos = 0
   IF (adm_src_size > 0)
    pos = locateval(num,1,adm_src_size,r.admit_source,icupatientcount->admit_src_temp[num].source)
   ENDIF
   IF (pos < 1)
    curr_index2 = (curr_index2+ 1)
    IF (mod(curr_index2,10)=1)
     stat = alterlist(icupatientcount->admit_src_temp,(curr_index2+ 9))
    ENDIF
    icupatientcount->admit_src_temp[curr_index2].source = r.admit_source, icupatientcount->
    admit_src_temp[curr_index2].source_cdf = r.admit_source, icupatientcount->admit_src_temp[
    curr_index2].src_num_pat = 1
   ELSE
    icupatientcount->admit_src_temp[pos].src_num_pat = (icupatientcount->admit_src_temp[pos].
    src_num_pat+ 1)
   ENDIF
  FOOT  r.med_service_cd
   icupatientcount->admit_service_temp[curr_index].srv_num_pat = total_srv
  FOOT REPORT
   pat_record->cnt = counter, stat = alterlist(pat_record->pat_data,counter), stat = alterlist(
    icupatientcount->admit_service_temp,curr_index),
   stat = alterlist(icupatientcount->admit_src_temp,curr_index2), avg_ap3 = 0.0, avg_ap3 = avg(ra
    .apache_iii_score
    WHERE ra.apache_iii_score >= 0),
   min_ap3 = min(ra.apache_iii_score
    WHERE ra.apache_iii_score >= 0), max_ap3 = max(ra.apache_iii_score
    WHERE ra.apache_iii_score >= 0), avg_aps = 0.0,
   avg_aps = avg(ra.aps_score
    WHERE ra.aps_score >= 0), min_aps = min(ra.aps_score
    WHERE ra.aps_score >= 0), max_aps = max(ra.aps_score
    WHERE ra.aps_score >= 0),
   icupatientcount->avg_ap3_day1 = avg_ap3, icupatientcount->min_ap3 = min_ap3, icupatientcount->
   max_ap3 = max_ap3,
   icupatientcount->avg_aps_day1 = avg_aps, icupatientcount->min_aps = min_aps, icupatientcount->
   max_aps = max_aps,
   icupatientcount->total_pat = counter
  WITH nocounter
 ;end select
 SET num3 = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE expand(num3,1,pat_record->cnt,ra.risk_adjustment_id,pat_record->pat_data[num3].
    risk_adjustment_id))
  ORDER BY ra.encntr_id, ra.risk_adjustment_id
  HEAD REPORT
   age_over_65 = 0, age_total = 0.0, age_count = 0,
   chi_count = 0, mult_chi_total = 0, severe_chi_cnt = 0,
   stat = alterlist(icupatientcount->severe_chi_temp,7), icupatientcount->severe_chi_temp[1].chi =
   "CIRRHOSIS", icupatientcount->severe_chi_temp[2].chi = "HEPFAILURE",
   icupatientcount->severe_chi_temp[3].chi = "IMMUNOSUP", icupatientcount->severe_chi_temp[4].chi =
   "LEUK/MYEL", icupatientcount->severe_chi_temp[5].chi = "LYMPHOMA",
   icupatientcount->severe_chi_temp[6].chi = "OTHERIMMUN", icupatientcount->severe_chi_temp[7].chi =
   "TUMOR/METS"
  HEAD ra.encntr_id
   age_total = (age_total+ ra.admit_age), age_count = (age_count+ 1)
   IF (ra.admit_age >= 65)
    age_over_65 = (age_over_65+ 1)
   ENDIF
  HEAD ra.risk_adjustment_id
   multi_chi_cnt = 0
   IF (((ra.chronic_health_unavail_ind=0) OR (ra.chronic_health_none_ind=0)) )
    IF (((ra.aids_ind=1) OR (((ra.hepaticfailure_ind=1) OR (((ra.lymphoma_ind=1) OR (((ra
    .metastaticcancer_ind=1) OR (((ra.leukemia_ind=1) OR (((ra.immunosuppression_ind=1) OR (((ra
    .cirrhosis_ind=1) OR (((ra.copd_ind=1) OR (ra.diabetes_ind=1)) )) )) )) )) )) )) )) )
     chi_count = (chi_count+ 1)
    ENDIF
   ENDIF
   IF (((ra.chronic_health_unavail_ind=0) OR (ra.chronic_health_none_ind=0)) )
    IF (ra.aids_ind=1)
     icupatientcount->severe_chi_temp[6].tot = (icupatientcount->severe_chi_temp[6].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.hepaticfailure_ind=1)
     icupatientcount->severe_chi_temp[2].tot = (icupatientcount->severe_chi_temp[2].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.lymphoma_ind=1)
     icupatientcount->severe_chi_temp[5].tot = (icupatientcount->severe_chi_temp[5].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.metastaticcancer_ind=1)
     icupatientcount->severe_chi_temp[7].tot = (icupatientcount->severe_chi_temp[7].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.leukemia_ind=1)
     icupatientcount->severe_chi_temp[4].tot = (icupatientcount->severe_chi_temp[4].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.immunosuppression_ind=1)
     icupatientcount->severe_chi_temp[3].tot = (icupatientcount->severe_chi_temp[3].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ELSEIF (ra.cirrhosis_ind=1)
     icupatientcount->severe_chi_temp[1].tot = (icupatientcount->severe_chi_temp[1].tot+ 1),
     severe_chi_cnt = (severe_chi_cnt+ 1)
    ENDIF
   ENDIF
  DETAIL
   junk = 1
  FOOT  ra.risk_adjustment_id
   multi_chi_cnt = 0
   IF (ra.chronic_health_unavail_ind=0
    AND ra.chronic_health_none_ind=0)
    multi_chi_cnt = cnvtint(((((((((ra.aids_ind+ ra.hepaticfailure_ind)+ ra.lymphoma_ind)+ ra
     .metastaticcancer_ind)+ ra.leukemia_ind)+ ra.immunosuppression_ind)+ ra.cirrhosis_ind)+ ra
     .copd_ind)+ ra.diabetes_ind))
    IF (multi_chi_cnt > 1)
     mult_chi_total = (mult_chi_total+ 1)
    ENDIF
   ENDIF
  FOOT REPORT
   avg_age = 0.0, avg_age = (age_total/ age_count), min_age = min(ra.admit_age),
   max_age = max(ra.admit_age), icupatientcount->avg_age = avg_age, icupatientcount->min_age =
   min_age,
   icupatientcount->max_age = max_age, icupatientcount->num_pat_over_65 = age_over_65,
   icupatientcount->num_pat_chi = chi_count,
   icupatientcount->num_pat_more_one_chi = mult_chi_total, icupatientcount->num_pat_severe_chi =
   severe_chi_cnt
  WITH nocounter
 ;end select
 SET sort_arr_sz = size(icupatientcount->admit_service_temp,5)
 SET stat = alterlist(icupatientcount->admit_service,sort_arr_sz)
 IF (sort_arr_sz > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = sort_arr_sz)
   ORDER BY icupatientcount->admit_service_temp[d.seq].srv_num_pat DESC
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icupatientcount->admit_service[counter].service = icupatientcount->
    admit_service_temp[d.seq].service, icupatientcount->admit_service[counter].srv_num_pat =
    icupatientcount->admit_service_temp[d.seq].srv_num_pat
   WITH nocounter
  ;end select
 ENDIF
 SET sort_arr_sz = size(icupatientcount->admit_src_temp,5)
 SET stat = alterlist(icupatientcount->admit_src,sort_arr_sz)
 FOR (z = 1 TO sort_arr_sz)
  SET rpt7_source_cd = meaning_code(28981,nullterm(icupatientcount->admit_src_temp[z].source_cdf))
  SET icupatientcount->admit_src_temp[z].source = uar_get_code_display(rpt7_source_cd)
 ENDFOR
 IF (sort_arr_sz > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = sort_arr_sz)
   ORDER BY icupatientcount->admit_src_temp[d.seq].src_num_pat DESC
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icupatientcount->admit_src[counter].source = icupatientcount->
    admit_src_temp[d.seq].source, icupatientcount->admit_src[counter].src_num_pat = icupatientcount->
    admit_src_temp[d.seq].src_num_pat
   WITH nocounter
  ;end select
 ENDIF
 SET chi_arr_sz = size(icupatientcount->severe_chi_temp,5)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = chi_arr_sz)
  ORDER BY icupatientcount->severe_chi_temp[d.seq].tot DESC, icupatientcount->severe_chi_temp[d.seq].
   chi
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), stat = alterlist(icupatientcount->severe_chi,counter), icupatientcount->
   severe_chi[counter].tot = icupatientcount->severe_chi_temp[d.seq].tot,
   icupatientcount->severe_chi[counter].chi = icupatientcount->severe_chi_temp[d.seq].chi
  WITH nocounter
 ;end select
 SET risk_id_clause = fillstring(50000," ")
 IF ((risk_record->total_admit > 0))
  SET risk_id_clause = concat(" r.risk_adjustment_id in (",trim(cnvtstring(risk_record->risk[1].
     risk_id)))
  FOR (cnt = 2 TO risk_record->total_admit)
    SET risk_id_clause = concat(trim(risk_id_clause),",",trim(cnvtstring(risk_record->risk[cnt].
       risk_id)))
  ENDFOR
  SET risk_id_clause = concat(trim(risk_id_clause),")")
 ELSEIF ((risk_record->total_admit=0))
  SET risk_id_clause = concat(trim(risk_id_clause),"0=1")
 ENDIF
 DECLARE num2 = i4
 SELECT INTO "nl:"
  disease = uar_get_code_meaning(r.disease_category_cd)
  FROM risk_adjustment r,
   encounter e,
   risk_adjustment_day ra
  PLAN (r
   WHERE expand(num2,1,risk_record->total_admit,r.risk_adjustment_id,risk_record->risk[num2].risk_id)
    AND ((r.active_ind+ 0)=1))
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.active_ind=1
    AND ra.cc_day=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND ((e.active_ind+ 0)=1))
  ORDER BY r.disease_category_cd
  HEAD REPORT
   curr_index = 0
  HEAD r.disease_category_cd
   disease_cnt = 0, curr_index = (curr_index+ 1)
   IF (mod(curr_index,100)=1)
    stat = alterlist(icupatientcount->most_freq_disease_temp,(curr_index+ 99))
   ENDIF
  DETAIL
   disease_cnt = (disease_cnt+ 1), icupatientcount->most_freq_disease_temp[curr_index].disease =
   disease, icupatientcount->most_freq_disease_temp[curr_index].disease_num_pat = disease_cnt
  FOOT REPORT
   stat = alterlist(icupatientcount->most_freq_disease_temp,curr_index)
  WITH nocounter
 ;end select
 SET mfd_cnt = size(icupatientcount->most_freq_disease_temp,5)
 SET stat = alterlist(icupatientcount->most_freq_disease,mfd_cnt)
 IF (mfd_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = mfd_cnt)
   ORDER BY icupatientcount->most_freq_disease_temp[d.seq].disease_num_pat DESC
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icupatientcount->most_freq_disease[counter].disease = icupatientcount->
    most_freq_disease_temp[d.seq].disease, icupatientcount->most_freq_disease[counter].
    disease_num_pat = icupatientcount->most_freq_disease_temp[d.seq].disease_num_pat
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  admitdx = r.admit_diagnosis, admitdx_cnt = count(*)
  FROM risk_adjustment r,
   encounter e,
   risk_adjustment_day ra,
   (dummyt d  WITH seq = risk_record->total_admit)
  PLAN (d)
   JOIN (r
   WHERE (r.risk_adjustment_id=risk_record->risk[d.seq].risk_id)
    AND ((r.active_ind+ 0)=1))
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.active_ind=1
    AND ra.cc_day=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND ((e.active_ind+ 0)=1))
  ORDER BY r.admit_diagnosis
  HEAD REPORT
   curr_index = 0
  HEAD r.admit_diagnosis
   curr_index = (curr_index+ 1)
   IF (mod(curr_index,99)=1)
    stat = alterlist(icupatientcount->most_freq_diag_temp,(curr_index+ 99))
   ENDIF
   icupatientcount->most_freq_diag_temp[curr_index].diagnosis = admitdx, this_dx_ct = 0
  DETAIL
   this_dx_ct = (this_dx_ct+ 1)
  FOOT  r.admit_diagnosis
   icupatientcount->most_freq_diag_temp[curr_index].dx_num_pat = this_dx_ct
  FOOT REPORT
   stat = alterlist(icupatientcount->most_freq_diag_temp,curr_index)
  WITH nocounter
 ;end select
 SET mfdg_cnt = size(icupatientcount->most_freq_diag_temp,5)
 IF (mfdg_cnt > 0)
  SET stat = alterlist(icupatientcount->most_freq_diag,mfdg_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = mfdg_cnt)
   ORDER BY icupatientcount->most_freq_diag_temp[d.seq].dx_num_pat DESC
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icupatientcount->most_freq_diag[counter].diagnosis = icupatientcount->
    most_freq_diag_temp[d.seq].diagnosis, icupatientcount->most_freq_diag[counter].dx_num_pat =
    icupatientcount->most_freq_diag_temp[d.seq].dx_num_pat
   WITH nocounter
  ;end select
 ENDIF
 SET lastrow = 79
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   count = 1
  HEAD PAGE
   col 0, font110c, row + 1,
   col 1, rpt_params->gen_on, col 75,
   "By Module: DCP_ARPT_7_UNIT_PT_SUMM", row + 1,
   CALL center("*** APACHE For ICU ***",0,110),
   row + 1,
   CALL center("QA/UR REPORT",0,110), row + 1,
   col 0, font80c, row + 1,
   CALL center("Unit Patient Summary",0,80), row + 1, col 0,
   font110c, row + 1, line = fillstring(120,"-"),
   CALL center(rpt_params->date_type_range_disp,0,110), row + 1, col 1,
   line, row + 1,
   CALL center(rpt_params->org_name,0,110),
   row + 1,
   CALL center(rpt_params->unit_disp,0,110), row + 2
  DETAIL
   tot_pat_disp = format(icupatientcount->total_pat,"#####;r"), col 2,
   "Number of ICU Patients (see note):",
   col 80, tot_pat_disp, row + 1,
   col 5, "Note: Includes all patients during this time period.", risk_id_cnt = 0,
   row + 1, row + 2, col 2,
   "A. Admission By Service", row + 1, col 55,
   "# Patients", col 70, "/Total ICU Pts = % Total admissions",
   row + 1, array_size = size(icupatientcount->admit_service,5)
   FOR (x = 1 TO array_size)
     srv_num_pat_disp = format(icupatientcount->admit_service[x].srv_num_pat,"#####;r"), tot_pat_disp
      = format(icupatientcount->total_pat,"#####;r"), ratio = ((icupatientcount->admit_service[x].
     srv_num_pat/ icupatientcount->total_pat) * 100),
     ratio_disp = format(ratio,"###.##%;r"), col 5, icupatientcount->admit_service[x].service,
     col 55, srv_num_pat_disp, col 75,
     tot_pat_disp, col 95, ratio_disp,
     row + 1
   ENDFOR
   row + 2, tot_pat_disp = format(icupatientcount->total_pat,"#####;r"), active_tx_cnt_disp = format(
    icupatientcount->active_tx_cnt,"#####;r"),
   hi_risk_mon_cnt_disp = format(icupatientcount->hi_risk_mon_cnt,"#####;r"), lo_risk_mon_cnt_disp =
   format(icupatientcount->lo_risk_mon_cnt,"#####;r"), np_non_act_cnt_disp = format(icupatientcount->
    np_non_act_cnt,"#####;r"),
   np_act_cnt_disp = format(icupatientcount->np_act_cnt,"#####;r"), therp_na_disp = format(
    icupatientcount->therp_level_na,"#####;r"), active_tx_cnt_pct = ((icupatientcount->active_tx_cnt
   / icupatientcount->total_pat) * 100),
   hi_risk_mon_cnt_pct = ((icupatientcount->hi_risk_mon_cnt/ icupatientcount->total_pat) * 100),
   lo_risk_mon_cnt_pct = ((icupatientcount->lo_risk_mon_cnt/ icupatientcount->total_pat) * 100),
   np_non_act_cnt_pct = ((icupatientcount->np_non_act_cnt/ icupatientcount->total_pat) * 100),
   np_act_cnt_pct = ((icupatientcount->np_act_cnt/ icupatientcount->total_pat) * 100), therp_na_pct
    = ((icupatientcount->therp_level_na/ icupatientcount->total_pat) * 100), active_tx_cnt_pct_disp
    = format(active_tx_cnt_pct,"###.##%;r"),
   hi_risk_mon_cnt_pct_disp = format(hi_risk_mon_cnt_pct,"###.##%;r"), lo_risk_mon_cnt_pct_disp =
   format(lo_risk_mon_cnt_pct,"###.##%;r"), np_non_act_cnt_pct_disp = format(np_non_act_cnt_pct,
    "###.##%;r"),
   np_act_cnt_pct_disp = format(np_act_cnt_pct,"###.##%;r"), therp_na_pct_disp = format(therp_na_pct,
    "###.##%;r"), col 2,
   "B. Admission Therapy Level", row + 1, col 55,
   "# Patients", col 70, "/Total ICU Pts = % Total admisisons",
   row + 1, col 5, "1. Active Treatment",
   col 55, active_tx_cnt_disp, col 75,
   tot_pat_disp, col 95, active_tx_cnt_pct_disp,
   row + 1, col 5, "2. Monitor Admissions",
   row + 1, col 10, "a. High Risk Monitor",
   col 55, hi_risk_mon_cnt_disp, col 75,
   tot_pat_disp, col 95, hi_risk_mon_cnt_pct_disp,
   row + 1, col 10, "b. Low Risk Monitor",
   col 55, lo_risk_mon_cnt_disp, col 75,
   tot_pat_disp, col 95, lo_risk_mon_cnt_pct_disp,
   row + 1, col 5, "3. Non-Predictive",
   row + 1, col 10, "a. Non-Active",
   col 55, np_non_act_cnt_disp, col 75,
   tot_pat_disp, col 95, np_non_act_cnt_pct_disp,
   row + 1, col 10, "b. Active",
   col 55, np_act_cnt_disp, col 75,
   tot_pat_disp, col 95, np_act_cnt_pct_disp,
   row + 1, col 5, "4. Undetermined ",
   col 55, therp_na_disp, col 75,
   tot_pat_disp, col 95, therp_na_pct_disp,
   row + 3, array_size = size(icupatientcount->admit_src,5)
   IF ((((row+ array_size)+ 6) > lastrow))
    BREAK
   ENDIF
   col 2, "C. Admission By Source", row + 1,
   col 55, "# Patients", col 70,
   "/Total ICU Pts = % Total admissions", row + 1
   FOR (x = 1 TO array_size)
     src_num_pat_disp = format(icupatientcount->admit_src[x].src_num_pat,"#####;r"), tot_pat_disp =
     format(icupatientcount->total_pat,"#####;r"), ratio = ((icupatientcount->admit_src[x].
     src_num_pat/ icupatientcount->total_pat) * 100),
     ratio_disp = format(ratio,"###.##%;r"), col 5, icupatientcount->admit_src[x].source,
     col 55, src_num_pat_disp, col 75,
     tot_pat_disp, col 95, ratio_disp,
     row + 1
   ENDFOR
   row + 3, avg_age_disp = format(icupatientcount->avg_age,"###.##;r"), min_age_disp = format(
    icupatientcount->min_age,"###;r"),
   max_age_disp = format(icupatientcount->max_age,"###;r"), age_over_65_disp = format(icupatientcount
    ->num_pat_over_65,"####;r")
   IF (((row+ 4) > lastrow))
    BREAK
   ENDIF
   col 2, "D. Average Patient Age At Hospital Admission ", col 55,
   avg_age_disp, col 65, "Range ",
   col 77, min_age_disp, col 85,
   "-", col 96, max_age_disp,
   row + 1, col 4, "Number of Hospital Admissions Age 65 and Over ",
   col 55, age_over_65_disp, row + 3,
   avg_ap3_disp = format(icupatientcount->avg_ap3_day1,"######.##;r"), min_ap3_disp = format(
    icupatientcount->min_ap3,"####;r"), max_ap3_disp = format(icupatientcount->max_ap3,"####;r"),
   avg_aps_disp = format(icupatientcount->avg_aps_day1,"######.##;r"), min_aps_disp = format(
    icupatientcount->min_aps,"####;r"), max_aps_disp = format(icupatientcount->max_aps,"####;r")
   IF (((row+ 4) > lastrow))
    BREAK
   ENDIF
   col 2, "E. Average APACHE Score on ICU Day 1 ", col 55,
   avg_ap3_disp, col 65, "Range ",
   col 75, min_ap3_disp, col 85,
   "-", col 95, max_ap3_disp,
   row + 1, col 4, "Average APS on ICU Day 1 ",
   col 55, avg_aps_disp, col 65,
   "Range ", col 75, min_aps_disp,
   col 85, "-", col 95,
   max_aps_disp, row + 3
   IF (((row+ 9) > lastrow))
    BREAK
   ENDIF
   col 2, "F. Number of Patients with Chronic Health Items ", chi_cnt_disp = format(icupatientcount->
    num_pat_chi,"####;r"),
   col 75, chi_cnt_disp, row + 1,
   col 5, "Number of Patients who have a Severe Chronic Health Item ", severe_chi_cnt_disp = format(
    icupatientcount->num_pat_severe_chi,"####;r"),
   col 75, severe_chi_cnt_disp, row + 1,
   col 5, " (Only the most Severe Chronic Health Item is counted ", row + 1,
   col 5, "  if patient has more than one.) ", row + 2,
   col 5, "Severe Chronic Health Items ", col 55,
   "Total ", row + 1, col 5,
   "----------------------------", col 55, "------",
   chi_arr_sz = size(icupatientcount->severe_chi,5)
   FOR (x = 1 TO chi_arr_sz)
     row + 1, col 5, icupatientcount->severe_chi[x].chi,
     tot_disp = format(icupatientcount->severe_chi[x].tot,"####;r"), col 55, tot_disp
   ENDFOR
   row + 3
   IF (((row+ 6) > lastrow))
    BREAK
   ENDIF
   col 5, "Number of Patients with more than one Chronic Health Item ", multi_chi_cnt_disp = format(
    icupatientcount->num_pat_more_one_chi,"####;r"),
   col 75, multi_chi_cnt_disp, row + 1,
   col 5, "Number of Patients with Chronic Health Not Available ", unavail_cnt_disp = format(
    icupatientcount->num_pat_unavail_chi,"####;r"),
   col 75, unavail_cnt_disp, row + 1,
   col 5, "Number of Patients with No Chronic Health ", no_chi_cnt_disp = format(icupatientcount->
    num_pat_no_chi,"####;r"),
   col 75, no_chi_cnt_disp
   IF (((row+ 6) > lastrow))
    BREAK
   ENDIF
   row + 1, col 5, "Number of Patients with Diabetes ",
   diabetes_cnt_disp = format(icupatientcount->num_pat_diabetes,"####;r"), col 75, diabetes_cnt_disp,
   row + 1, col 5, "Number of Patients with COPD ",
   copd_cnt_disp = format(icupatientcount->num_pat_copd,"####;r"), col 75, copd_cnt_disp,
   row + 1, col 5, "Number of Patients with Chronic Dialysis ",
   dialy_cnt_disp = format(icupatientcount->num_pat_dialysis,"####;r"), col 75, dialy_cnt_disp,
   row + 1, col 5, "       * Chronic Dialysis is not considered a Chronic Health Item",
   row + 3
   IF (((row+ 9) > lastrow))
    BREAK
   ENDIF
   col 2, "G. Admission By 5 Most Frequent Disease Category ", row + 1,
   col 55, "# Patients", col 70,
   "/Total ICU Pts = % Total admissions", row + 1, array_size = size(icupatientcount->
    most_freq_disease,5)
   IF (array_size > 5)
    array_size = 5
   ENDIF
   FOR (x = 1 TO array_size)
     dc_num_pat_disp = format(icupatientcount->most_freq_disease[x].disease_num_pat,"####;r"),
     tot_pat_disp = format(icupatientcount->total_pat,"####;r"), ratio = ((icupatientcount->
     most_freq_disease[x].disease_num_pat/ icupatientcount->total_pat) * 100),
     ratio_disp = format(ratio,"###.##%;r"), col 5, icupatientcount->most_freq_disease[x].disease,
     col 55, dc_num_pat_disp, col 75,
     tot_pat_disp, col 95, ratio_disp,
     row + 1
   ENDFOR
   row + 3, array_size = size(icupatientcount->most_freq_diag,5)
   IF (array_size > 10)
    array_size = 10
   ENDIF
   IF ((((row+ array_size)+ 6) > lastrow))
    BREAK
   ENDIF
   col 2, "H. Admission By 10 Most Frequent Diagnosis ", row + 1,
   col 55, "# Patients", col 70,
   "/Total ICU Pts = % Total admissions", row + 1
   FOR (x = 1 TO array_size)
     src_num_pat_disp = format(icupatientcount->most_freq_diag[x].dx_num_pat,"####;r"), tot_pat_disp
      = format(icupatientcount->total_pat,"####;r"), ratio = ((icupatientcount->most_freq_diag[x].
     dx_num_pat/ icupatientcount->total_pat) * 100),
     ratio_disp = format(ratio,"###.##%;r"), col 5, icupatientcount->most_freq_diag[x].diagnosis,
     col 55, src_num_pat_disp, col 75,
     tot_pat_disp, col 95, ratio_disp,
     row + 1
   ENDFOR
  FOOT PAGE
   page_disp = concat("--------- ",trim(cnvtstring(curpage),3)," ---------"), row lastrow,
   CALL center(page_disp,0,110)
  WITH dio = postscript, maxrow = 80, nocounter
 ;end select
END GO
