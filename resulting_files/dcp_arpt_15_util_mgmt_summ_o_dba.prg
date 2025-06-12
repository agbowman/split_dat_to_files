CREATE PROGRAM dcp_arpt_15_util_mgmt_summ_o:dba
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
 RECORD pat_record9(
   1 cnt = i2
   1 pat_data[*]
     2 r_risk_adjustment_id = f8
     2 e_encntr_id = f8
     2 ra_risk_adjustment_day_id = f8
     2 ra_cc_day = i4
     2 ra_outcome_status = i4
     2 r_icu_admit_dt_tm = dq8
     2 r_icu_disch_dt_tm = dq8
     2 r_hosp_admit_dt_tm = dq8
     2 r_hosp_disch_dt_tm = dq8
     2 ra_aps_day1 = i4
     2 ra_apache_iii_score = i4
     2 rao_equation_name = vc
     2 rao_outcome = f8
     2 r_readmit_ind = i2
     2 first_visit_ind = i2
     2 r_diedinicu_ind = i2
     2 r_diedinhospital_ind = i2
     2 r_readmit_within_24hr_ind = i2
     2 r_cc_beg_dt_tm = dq8
     2 r_cc_end_dt_tm = dq8
     2 actual_tiss_score = i4
     2 icu_los_less_4_hrs = i2
     2 admit_diagnosis = vc
 )
 RECORD arpt9_data(
   1 readmit_total = i4
   1 first_visit_total = i4
   1 los_more_4hrs_cnt = i4
   1 los_more_4hrs_icu_pred_cnt = i4
   1 los_more_4hrs_hsp_pred_cnt = i4
   1 los_more_4hrs_sim_pred_cnt = i4
   1 los_more_4hrs_sim_icu_pred_cnt = i4
   1 los_more_4hrs_sim_hsp_pred_cnt = i4
   1 los_less_4hrs_cnt = i4
   1 icu_pt_not_disch_cnt = i4
   1 icu_pt_not_disch_pred_cnt = i4
   1 pat_no_hosp_disch_cnt = i4
   1 pat_hosp_disch_cnt = i4
   1 pat_hosp_disch_pred_cnt = i4
   1 avg_aps = f8
   1 avg_ap3 = f8
   1 avg_icu_los_days = f8
   1 avg_icu_los_trunc = f8
   1 avg_sim_icu_los_trunc = f8
   1 avg_hosp_los_days = f8
   1 avg_hosp_los_trunc = f8
   1 avg_sim_hosp_los_trunc = f8
   1 non_pred_cnt = i4
   1 icu_disch_cnt = i4
   1 icu_pred_cnt_hosp_disch = i4
   1 tot_pat_with_outcome = f8
   1 tot_pat_readmit_outcome = f8
   1 tot_pat_readmit_outcome_24 = f8
   1 tot_pat_readmit_outcome_after24 = f8
   1 icu_lowrisk_ntl = f8
   1 icu_lowrisk_sim = f8
   1 hosp_lowrisk_ntl = f8
   1 hosp_lowrisk_sim = f8
   1 icu_mort_count = f8
   1 sim_icu_mort_count = f8
   1 hosp_mort_count = f8
   1 sim_hosp_mort_count = f8
   1 all_icu_mort_count = f8
   1 all_hosp_mort_count = f8
   1 ntl_icu_pred_mort = f8
   1 sim_icu_pred_mort = f8
   1 ntl_hosp_pred_mort = f8
   1 sim_hosp_pred_mort = f8
   1 avg_pred_ntl_hosp_los = f8
   1 avg_pred_sim_hosp_los = f8
   1 avg_pred_sim_icu_los = f8
   1 avg_pred_ntl_icu_los = f8
   1 ntl_icu_outliers = f8
   1 sim_icu_outliers = f8
   1 ntl_hosp_outliers = f8
   1 sim_hosp_outliers = f8
   1 icu_day_5_pred_cnt = f8
   1 icu_pred_less24 = f8
   1 ntl_icu_p_los_val = vc
   1 sim_icu_p_los_val = vc
   1 ntl_hosp_p_los_val = vc
   1 sim_hosp_p_los_val = vc
   1 p_val_icu_mort_ntl_disp = vc
   1 p_val_icu_mort_sim_disp = vc
   1 p_val_hosp_mort_ntl_disp = vc
   1 p_val_hosp_mort_sim_disp = vc
   1 tiss_day_1_pat_cnt = i4
   1 tiss_day_1_avg = f8
   1 tiss_day_1_sum = f8
   1 all_tiss_day_1_pat_cnt = i4
   1 all_tiss_day_1_avg = f8
   1 all_tiss_day_1_sum = f8
   1 tiss_day_1_ntl_sum = f8
   1 tiss_day_1_sim_sum = f8
   1 tiss_day_1_ntl_avg = f8
   1 tiss_day_1_sim_avg = f8
   1 tiss_day_1_ntl_p_value = vc
   1 tiss_day_1_sim_p_value = vc
   1 readmit_within_24hr_total = i4
 )
 SET null_date = cnvtdatetime("31-DEC-2100 00:00:00")
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 DECLARE num = i4
 SELECT INTO "nl:"
  FROM risk_adjustment r,
   encounter e,
   risk_adjustment_day ra,
   person p
  PLAN (r
   WHERE expand(num,1,risk_record->total_admit,r.risk_adjustment_id,risk_record->risk[num].risk_id)
    AND ((r.active_ind+ 0)=1))
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.active_ind=1
    AND ra.cc_day=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND ((e.active_ind+ 0)=1))
   JOIN (p
   WHERE p.person_id=r.person_id
    AND ((p.active_ind+ 0)=1))
  ORDER BY r.encntr_id, cnvtdatetime(r.icu_admit_dt_tm)
  HEAD REPORT
   cnt = 0, first_count = 0
  HEAD r.encntr_id
   first_visit_ind = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,500)=1)
    stat = alterlist(pat_record9->pat_data,(cnt+ 499))
   ENDIF
   pat_record9->pat_data[cnt].r_risk_adjustment_id = r.risk_adjustment_id, pat_record9->pat_data[cnt]
   .e_encntr_id = e.encntr_id, pat_record9->pat_data[cnt].ra_risk_adjustment_day_id = ra
   .risk_adjustment_day_id,
   pat_record9->pat_data[cnt].ra_cc_day = ra.cc_day, pat_record9->pat_data[cnt].ra_outcome_status =
   ra.outcome_status, pat_record9->pat_data[cnt].icu_los_less_4_hrs = - (1),
   pat_record9->pat_data[cnt].actual_tiss_score = - (1), pat_record9->pat_data[cnt].admit_diagnosis
    = r.admit_diagnosis, first_visit_ind = (first_visit_ind+ 1)
   IF (first_visit_ind=1)
    pat_record9->pat_data[cnt].first_visit_ind = 1, first_count = (first_count+ 1)
   ELSE
    pat_record9->pat_data[cnt].first_visit_ind = 0
   ENDIF
   IF (((r.admit_age < 16) OR (((r.admit_diagnosis IN ("BONMARTRAN", "BURN", "HEARTRAN", "HRTLNGTRAN",
   "KIDPANTRAN",
   "S-BURN", "LIVSMBTRAN", "LUNGSTRAN", "LUNGTRAN", "PANCRETRAN",
   "S-BMARTRAN", "S-HEARTRAN", "S-HTLNTRAN", "S-KIDPTRAN", "S-LSMBTRAN",
   "S-LNGSTRAN", "S-LUNGTRAN", "S-PANTRAN", "S-SMBTRAN", "S-TRANOTH",
   "SMBOWLTRAN", "TRANOTHER")) OR (r.admit_source IN ("ICU", "CHPAIN_CTR", "ICU_TO_OR"))) )) )
    arpt9_data->non_pred_cnt = (arpt9_data->non_pred_cnt+ 1)
   ENDIF
   pat_record9->pat_data[cnt].r_icu_admit_dt_tm = r.icu_admit_dt_tm, pat_record9->pat_data[cnt].
   r_icu_disch_dt_tm = r.icu_disch_dt_tm, pat_record9->pat_data[cnt].r_cc_beg_dt_tm = ra.cc_beg_dt_tm,
   pat_record9->pat_data[cnt].r_cc_end_dt_tm = ra.cc_end_dt_tm
   IF (cnvtdatetime(r.icu_disch_dt_tm)=cnvtdatetime(null_date))
    arpt9_data->icu_pt_not_disch_cnt = (arpt9_data->icu_pt_not_disch_cnt+ 1)
   ELSEIF (cnvtdatetime(r.icu_disch_dt_tm) != cnvtdatetime(null_date))
    arpt9_data->icu_disch_cnt = (arpt9_data->icu_disch_cnt+ 1)
   ENDIF
   pat_record9->pat_data[cnt].r_hosp_admit_dt_tm = r.hosp_admit_dt_tm, pat_record9->pat_data[cnt].
   r_hosp_disch_dt_tm = e.disch_dt_tm
   IF (cnvtdatetime(e.disch_dt_tm)=cnvtdatetime(null))
    arpt9_data->pat_no_hosp_disch_cnt = (arpt9_data->pat_no_hosp_disch_cnt+ 1)
   ENDIF
   pat_record9->pat_data[cnt].ra_aps_day1 = ra.aps_day1, pat_record9->pat_data[cnt].
   ra_apache_iii_score = ra.apache_iii_score, pat_record9->pat_data[cnt].r_readmit_ind = r
   .readmit_ind
   IF (r.readmit_ind=1)
    arpt9_data->readmit_total = (arpt9_data->readmit_total+ 1)
    IF (r.readmit_within_24hr_ind=1)
     arpt9_data->readmit_within_24hr_total = (arpt9_data->readmit_within_24hr_total+ 1)
    ENDIF
   ENDIF
   IF ((pat_record9->pat_data[cnt].first_visit_ind=1))
    arpt9_data->first_visit_total = (arpt9_data->first_visit_total+ 1)
   ENDIF
   pat_record9->pat_data[cnt].r_diedinicu_ind = r.diedinicu_ind, pat_record9->pat_data[cnt].
   r_readmit_within_24hr_ind = r.readmit_within_24hr_ind
   IF (r.diedinicu_ind=1)
    pat_record9->pat_data[cnt].r_diedinhospital_ind = 1
   ELSE
    IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
     pat_record9->pat_data[cnt].r_diedinhospital_ind = 1
    ELSE
     pat_record9->pat_data[cnt].r_diedinhospital_ind = 0
    ENDIF
    IF (p.deceased_dt_tm > e.reg_dt_tm
     AND p.deceased_dt_tm <= e.disch_dt_tm)
     pat_record9->pat_data[cnt].r_diedinhospital_ind = 1
    ENDIF
   ENDIF
   IF (r.diedinicu_ind=1)
    arpt9_data->all_icu_mort_count = (arpt9_data->all_icu_mort_count+ 1)
   ENDIF
   IF ((pat_record9->pat_data[cnt].r_diedinhospital_ind=1)
    AND (pat_record9->pat_data[cnt].first_visit_ind=1))
    arpt9_data->all_hosp_mort_count = (arpt9_data->all_hosp_mort_count+ 1)
   ENDIF
  FOOT REPORT
   pat_record9->cnt = cnt, stat = alterlist(pat_record9->pat_data,cnt)
  WITH nocounter
 ;end select
 SUBROUTINE patientwithprediction(predless24)
   SET cnt = 0
   DECLARE s_num = i4
   DECLARE s_num2 = i4
   SELECT
    IF (predless24=1)
     PLAN (ra
      WHERE expand(s_num,1,pat_record9->cnt,ra.risk_adjustment_day_id,pat_record9->pat_data[s_num].
       ra_risk_adjustment_day_id)
       AND ra.cc_day=1
       AND ra.active_ind=1)
      JOIN (rao
      WHERE ra.risk_adjustment_day_id=rao.risk_adjustment_day_id
       AND rao.equation_name="NTL_ICU_LOS"
       AND rao.outcome_value < 1.0
       AND rao.active_ind=1)
    ELSE
     PLAN (ra
      WHERE expand(s_num2,1,pat_record9->cnt,ra.risk_adjustment_id,pat_record9->pat_data[s_num2].
       r_risk_adjustment_id)
       AND ra.cc_day=5
       AND ra.active_ind=1)
      JOIN (rao
      WHERE ra.risk_adjustment_day_id=rao.risk_adjustment_day_id
       AND rao.equation_name="NTL_ICU_LOS"
       AND rao.active_ind=1)
    ENDIF
    INTO "nl:"
    FROM risk_adjustment_outcomes rao,
     risk_adjustment_day ra
    DETAIL
     cnt = (cnt+ 1)
    WITH nocounter
   ;end select
   RETURN(cnt)
 END ;Subroutine
 SUBROUTINE icu_p_value_calc(outcome)
   SET dratio = 0.0
   SET num_patients = 0.0
   SELECT INTO "nl:"
    local_icu_sq = ((least(datetimediff(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm,pat_record9->
      pat_data[d.seq].r_icu_admit_dt_tm,1),30.0) - rao.outcome_value)** 2), local_pred = rao
    .outcome_value, local_act_trunc = (least(datetimediff(pat_record9->pat_data[d.seq].
      r_icu_disch_dt_tm,pat_record9->pat_data[d.seq].r_icu_admit_dt_tm,1),30.0)+ least(rao.active_ind,
     0.0))
    FROM (dummyt d  WITH seq = pat_record9->cnt),
     risk_adjustment_outcomes rao
    PLAN (d
     WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0)
      AND cnvtdatetime(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm) != cnvtdatetime(null_date)
      AND cnvtdatetime(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm) >= cnvtdatetime(pat_record9->
      pat_data[d.seq].r_icu_admit_dt_tm))
     JOIN (rao
     WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
      AND trim(rao.equation_name)=trim(outcome)
      AND ((rao.outcome_value+ 0) > 0)
      AND ((rao.active_ind+ 0)=1))
    HEAD REPORT
     local_icu_sq_delta = 0.0, local_act_trunc_ilos = 0.0, local_pred_los = 0.0
    DETAIL
     local_icu_sq_delta = (local_icu_sq_delta+ local_icu_sq), local_act_trunc_ilos = (
     local_act_trunc_ilos+ local_act_trunc), local_pred_los = (local_pred_los+ local_pred),
     num_patients = (num_patients+ 1)
    FOOT REPORT
     local_std_dev = ((local_icu_sq_delta/ arpt9_data->los_more_4hrs_cnt) - (((local_act_trunc_ilos
      - local_pred_los)/ arpt9_data->los_more_4hrs_cnt)** 2)), local_los_sem = ((local_std_dev/ (
     arpt9_data->los_more_4hrs_cnt - 1))** 0.5), dratio = abs((((local_act_trunc_ilos -
      local_pred_los)/ arpt9_data->los_more_4hrs_cnt)/ local_los_sem))
    WITH nocounter
   ;end select
   IF (num_patients < 30)
    RETURN("")
   ELSEIF (num_patients BETWEEN 30 AND 59)
    IF (dratio < 2.042)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.042 AND 2.75)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.75)
     RETURN("P<.01")
    ENDIF
   ELSEIF (num_patients BETWEEN 60 AND 119)
    IF (dratio < 2.00)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.00 AND 2.66)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.66)
     RETURN("P<.01")
    ENDIF
   ELSE
    IF (dratio < 1.965)
     RETURN("")
    ELSEIF (dratio BETWEEN 1.965 AND 2.576)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.576)
     RETURN("P<.01")
    ENDIF
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE hosp_p_value_calc(outcome,hosp_pred_count)
   SET dratio = 0.0
   SET num_patients = 0.0
   SELECT INTO "nl:"
    local_hosp_sq = ((least(datetimediff(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm,pat_record9
      ->pat_data[d.seq].r_hosp_admit_dt_tm,1),50.0) - rao.outcome_value)** 2), local_pred = rao
    .outcome_value, local_act_trunc = (least(datetimediff(pat_record9->pat_data[d.seq].
      r_hosp_disch_dt_tm,pat_record9->pat_data[d.seq].r_hosp_admit_dt_tm,1),50.0)+ least(rao
     .active_ind,0.0))
    FROM (dummyt d  WITH seq = pat_record9->cnt),
     risk_adjustment_outcomes rao
    PLAN (d
     WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0)
      AND cnvtdatetime(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm) != cnvtdatetime(null)
      AND cnvtdatetime(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm) >= cnvtdatetime(pat_record9->
      pat_data[d.seq].r_hosp_admit_dt_tm))
     JOIN (rao
     WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
      AND trim(rao.equation_name)=trim(outcome)
      AND ((rao.outcome_value+ 0) > 0)
      AND ((rao.active_ind+ 0)=1))
    HEAD REPORT
     local_hosp_sq_delta = 0.0, local_act_trunc_hlos = 0.0, local_pred_los = 0.0
    DETAIL
     local_hosp_sq_delta = (local_hosp_sq_delta+ local_hosp_sq), local_act_trunc_hlos = (
     local_act_trunc_hlos+ local_act_trunc), local_pred_los = (local_pred_los+ local_pred),
     num_patients = (num_patients+ 1)
    FOOT REPORT
     local_std_dev = ((local_hosp_sq_delta/ hosp_pred_count) - (((local_act_trunc_hlos -
     local_pred_los)/ hosp_pred_count)** 2)), local_los_sem = ((local_std_dev/ (hosp_pred_count - 1))
     ** 0.5), dratio = abs((((local_act_trunc_hlos - local_pred_los)/ hosp_pred_count)/ local_los_sem
      ))
    WITH nocounter
   ;end select
   IF (num_patients < 30)
    RETURN("")
   ELSEIF (num_patients BETWEEN 30 AND 59)
    IF (dratio < 2.042)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.042 AND 2.75)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.75)
     RETURN("P<.01")
    ENDIF
   ELSEIF (num_patients BETWEEN 60 AND 119)
    IF (dratio < 2.00)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.00 AND 2.66)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.66)
     RETURN("P<.01")
    ENDIF
   ELSE
    IF (dratio < 1.965)
     RETURN("")
    ELSEIF (dratio BETWEEN 1.965 AND 2.576)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.576)
     RETURN("P<.01")
    ENDIF
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE pmortalitycalc(outcome,pat_outcome_count,death_count,type)
   SET chisqu = 0.0
   SET num_patients = 0.0
   SELECT
    IF (type="ICU")
     PLAN (d
      WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0)
       AND cnvtdatetime(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm) != cnvtdatetime(null_date))
      JOIN (rao
      WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
       AND rao.equation_name=outcome)
    ELSE
     PLAN (d
      WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0)
       AND cnvtdatetime(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm) != cnvtdatetime(null))
      JOIN (rao
      WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
       AND rao.equation_name=outcome)
    ENDIF
    INTO "nl:"
    FROM (dummyt d  WITH seq = pat_record9->cnt),
     risk_adjustment_outcomes rao
    DETAIL
     num_patients = (num_patients+ 1)
    FOOT REPORT
     IF (type="ICU")
      chisqu = ((sum((pat_record9->pat_data[d.seq].r_diedinicu_ind - rao.outcome_value))** 2)/ sum(((
       1 - rao.outcome_value) * rao.outcome_value)))
     ELSE
      chisqu = ((sum((pat_record9->pat_data[d.seq].r_diedinhospital_ind - rao.outcome_value))** 2)/
      sum(((1 - rao.outcome_value) * rao.outcome_value)))
     ENDIF
    WITH nocounter
   ;end select
   IF (num_patients >= 30
    AND death_count >= 5)
    IF (chisqu < 3.814)
     RETURN("")
    ELSEIF (chisqu >= 3.814
     AND chisqu < 6.635)
     RETURN("P<.05")
    ELSEIF (chisqu >= 6.635)
     RETURN("P<.01")
    ENDIF
   ELSE
    RETURN("")
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE tiss_p_value_calc(outcome)
   SET dratio = 0.0
   SET num_patients = 0.0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pat_record9->cnt),
     risk_adjustment_outcomes rao
    PLAN (d
     WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0)
      AND (pat_record9->pat_data[d.seq].actual_tiss_score >= 0))
     JOIN (rao
     WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
      AND trim(rao.equation_name)=trim(outcome)
      AND ((rao.active_ind+ 0)=1))
    HEAD REPORT
     local_sum_a = 0.0, local_sum_b = 0.0, local_all_pats = 0.0
    DETAIL
     local_diff = (pat_record9->pat_data[d.seq].actual_tiss_score - rao.outcome_value), local_sum_a
      = (local_sum_a+ (local_diff** 2)), local_sum_b = (local_sum_b+ local_diff),
     local_all_pats = (local_all_pats+ 1), num_patients = (num_patients+ 1)
    FOOT REPORT
     local_final_a = (local_sum_a/ local_all_pats), local_final_b = ((local_sum_b/ local_all_pats)**
     2), local_tiss_sem = (((local_final_a - local_final_b)/ (local_all_pats - 1))** 0.5)
     IF (local_tiss_sem > 0)
      dratio = abs(((local_sum_b/ local_all_pats)/ local_tiss_sem))
     ELSE
      dratio = 0.0
     ENDIF
    WITH nocounter
   ;end select
   IF (num_patients BETWEEN 30 AND 59)
    IF (dratio < 2.042)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.042 AND 2.75)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.75)
     RETURN("P<.01")
    ENDIF
   ELSEIF (num_patients BETWEEN 60 AND 119)
    IF (dratio < 2.00)
     RETURN("")
    ELSEIF (dratio BETWEEN 2.00 AND 2.66)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.66)
     RETURN("P<.01")
    ENDIF
   ELSE
    IF (dratio < 1.965)
     RETURN("")
    ELSEIF (dratio BETWEEN 1.965 AND 2.576)
     RETURN("P<.05")
    ELSEIF (dratio >= 2.576)
     RETURN("P<.01")
    ENDIF
   ENDIF
   RETURN("")
 END ;Subroutine
 DECLARE num4 = i4
 DECLARE pos = i4
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad,
   risk_adjustment_outcomes rao
  PLAN (rad
   WHERE expand(num4,1,pat_record9->cnt,rad.risk_adjustment_day_id,pat_record9->pat_data[num4].
    ra_risk_adjustment_day_id)
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND rao.active_ind=1)
  ORDER BY rad.risk_adjustment_id
  HEAD REPORT
   nate1 = 0, nate2 = 0, arpt9_data->icu_pt_not_disch_pred_cnt = 0,
   arpt9_data->pat_hosp_disch_pred_cnt = 0, val = 0, pos = 0,
   diedinicu = 0, diedinhosp = 0, sign_value = 0,
   cnt_ntl_icu_outcome = 0, ntl_icu_outcome_val = 0.0, cnt_sim_icu_outcome = 0,
   sim_icu_outcome_val = 0.0, cnt_ntl_hsp_outcome = 0, ntl_hsp_outcome_val = 0.0,
   cnt_sim_hsp_outcome = 0, sim_hsp_outcome_val = 0.0, cnt = 0,
   ap3 = 0.0, aps = 0.0, sum_los = 0.0,
   sum_los_trunc = 0.0, pat_los_cnt = 0, sim_sum_los = 0.0,
   sim_sum_los_trunc = 0.0, sim_pat_los_cnt = 0, hsp_sum_los = 0.0,
   hsp_sum_los_trunc = 0.0, hsp_cnt = 0.0, sim_hsp_sum_los = 0.0,
   sim_hsp_sum_los_trunc = 0.0, sim_hsp_cnt = 0.0
  HEAD rad.risk_adjustment_id
   pos4 = locateval(num4,1,pat_record9->cnt,rad.risk_adjustment_id,pat_record9->pat_data[num4].
    r_risk_adjustment_id), los = 0.0, los = datetimediff(pat_record9->pat_data[pos4].
    r_icu_disch_dt_tm,pat_record9->pat_data[pos4].r_icu_admit_dt_tm,3)
   IF ((pat_record9->pat_data[pos4].first_visit_ind=1)
    AND (pat_record9->pat_data[pos4].r_icu_disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00"))
    AND los >= 4.0
    AND cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
    nate2 = (nate2+ 1), arpt9_data->pat_hosp_disch_pred_cnt = (arpt9_data->pat_hosp_disch_pred_cnt+ 1
    )
   ENDIF
   IF (cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
    arpt9_data->pat_hosp_disch_cnt = (arpt9_data->pat_hosp_disch_cnt+ 1)
   ENDIF
   IF (((rao.equation_name="SIM_ICU_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )
    arpt9_data->los_more_4hrs_sim_pred_cnt = (arpt9_data->los_more_4hrs_sim_pred_cnt+ 1)
   ENDIF
   last_risk_adj_id = 0.0
  DETAIL
   nate1 = (nate1+ 1)
   IF (cnvtdatetime(pat_record9->pat_data[pos4].r_icu_disch_dt_tm) != cnvtdatetime(null_date))
    diedinicu = evaluate(pat_record9->pat_data[pos4].r_diedinicu_ind,1,1,0,0), diedinhosp = evaluate(
     pat_record9->pat_data[pos4].r_diedinhospital_ind,1,1,0,0)
    IF (rao.equation_name="NTL_1ST_TISS"
     AND cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
     arpt9_data->icu_pred_cnt_hosp_disch = (arpt9_data->icu_pred_cnt_hosp_disch+ 1)
    ENDIF
    IF (los >= 4.0)
     pat_record9->pat_data[pos4].icu_los_less_4_hrs = 0
     IF (rao.equation_name="NTL_1ST_TISS")
      arpt9_data->los_more_4hrs_cnt = (arpt9_data->los_more_4hrs_cnt+ 1), cnt = (cnt+ 1)
      IF ((pat_record9->pat_data[pos4].ra_cc_day=1))
       ap3 = (ap3+ pat_record9->pat_data[pos4].ra_apache_iii_score), aps = (aps+ pat_record9->
       pat_data[pos4].ra_aps_day1)
      ENDIF
      IF (rao.outcome_value > 0.0)
       arpt9_data->tot_pat_with_outcome = (arpt9_data->tot_pat_with_outcome+ 1)
       IF ((pat_record9->pat_data[pos4].first_visit_ind=0))
        arpt9_data->tot_pat_readmit_outcome = (arpt9_data->tot_pat_readmit_outcome+ 1)
        IF ((pat_record9->pat_data[pos4].r_readmit_within_24hr_ind=1))
         arpt9_data->tot_pat_readmit_outcome_24 = (arpt9_data->tot_pat_readmit_outcome_24+ 1)
        ELSE
         arpt9_data->tot_pat_readmit_outcome_after24 = (arpt9_data->tot_pat_readmit_outcome_after24+
         1)
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rao.equation_name="NTL_ICU_DEATH")
      arpt9_data->los_more_4hrs_icu_pred_cnt = (arpt9_data->los_more_4hrs_icu_pred_cnt+ 1)
      IF (rao.outcome_value <= 0.2
       AND diedinicu=1)
       arpt9_data->icu_lowrisk_ntl = (arpt9_data->icu_lowrisk_ntl+ 1)
      ENDIF
      IF (diedinicu=1)
       arpt9_data->icu_mort_count = (arpt9_data->icu_mort_count+ 1)
      ENDIF
      cnt_ntl_icu_outcome = (cnt_ntl_icu_outcome+ 1), ntl_icu_outcome_val = (ntl_icu_outcome_val+ rao
      .outcome_value), los_in_days = datetimediff(pat_record9->pat_data[pos4].r_icu_disch_dt_tm,
       pat_record9->pat_data[pos4].r_icu_admit_dt_tm,1),
      los_trunc_in_days = least(datetimediff(pat_record9->pat_data[pos4].r_icu_disch_dt_tm,
        pat_record9->pat_data[pos4].r_icu_admit_dt_tm,1),30.0), pat_los_cnt = (pat_los_cnt+ 1),
      sum_los = (sum_los+ los_in_days),
      sum_los_trunc = (sum_los_trunc+ los_trunc_in_days)
     ELSEIF (rao.equation_name="SIM_ICU_DEATH")
      IF (last_risk_adj_id != rad.risk_adjustment_id)
       arpt9_data->los_more_4hrs_sim_pred_cnt = (arpt9_data->los_more_4hrs_sim_pred_cnt+ 1),
       last_risk_adj_id = rad.risk_adjustment_id
      ENDIF
      arpt9_data->los_more_4hrs_sim_icu_pred_cnt = (arpt9_data->los_more_4hrs_sim_icu_pred_cnt+ 1)
      IF (rao.outcome_value <= 0.20
       AND diedinicu=1)
       arpt9_data->icu_lowrisk_sim = (arpt9_data->icu_lowrisk_sim+ 1)
      ENDIF
      IF (diedinicu=1)
       arpt9_data->sim_icu_mort_count = (arpt9_data->sim_icu_mort_count+ 1)
      ENDIF
      cnt_sim_icu_outcome = (cnt_sim_icu_outcome+ 1), sim_icu_outcome_val = (sim_icu_outcome_val+ rao
      .outcome_value), los_in_days = datetimediff(pat_record9->pat_data[pos4].r_icu_disch_dt_tm,
       pat_record9->pat_data[pos4].r_icu_admit_dt_tm,1),
      los_trunc_in_days = least(datetimediff(pat_record9->pat_data[pos4].r_icu_disch_dt_tm,
        pat_record9->pat_data[pos4].r_icu_admit_dt_tm,1),30.0), sim_pat_los_cnt = (sim_pat_los_cnt+ 1
      ), sim_sum_los = (sim_sum_los+ los_in_days),
      sim_sum_los_trunc = (sim_sum_los_trunc+ los_trunc_in_days)
     ELSEIF (rao.equation_name="NTL_HSP_DEATH")
      IF (cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
       arpt9_data->los_more_4hrs_hsp_pred_cnt = (arpt9_data->los_more_4hrs_hsp_pred_cnt+ 1)
       IF (rao.outcome_value <= 0.2
        AND diedinhosp=1)
        arpt9_data->hosp_lowrisk_ntl = (arpt9_data->hosp_lowrisk_ntl+ 1)
       ENDIF
       IF (diedinhosp=1)
        arpt9_data->hosp_mort_count = (arpt9_data->hosp_mort_count+ 1)
       ENDIF
       cnt_ntl_hsp_outcome = (cnt_ntl_hsp_outcome+ 1), ntl_hsp_outcome_val = (ntl_hsp_outcome_val+
       rao.outcome_value), hsp_los = datetimediff(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm,
        pat_record9->pat_data[pos4].r_hosp_admit_dt_tm,1),
       hsp_los_trunc = least(datetimediff(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm,pat_record9
         ->pat_data[pos4].r_hosp_admit_dt_tm,1),50.0), hsp_cnt = (hsp_cnt+ 1), hsp_sum_los = (
       hsp_sum_los+ hsp_los),
       hsp_sum_los_trunc = (hsp_sum_los_trunc+ hsp_los_trunc)
      ENDIF
     ELSEIF (rao.equation_name="SIM_HSP_DEATH")
      IF (last_risk_adj_id != rad.risk_adjustment_id)
       arpt9_data->los_more_4hrs_sim_pred_cnt = (arpt9_data->los_more_4hrs_sim_pred_cnt+ 1),
       last_risk_adj_id = rad.risk_adjustment_id
      ENDIF
      IF (cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
       IF ((pat_record9->pat_data[pos4].first_visit_ind=1))
        arpt9_data->los_more_4hrs_sim_hsp_pred_cnt = (arpt9_data->los_more_4hrs_sim_hsp_pred_cnt+ 1)
        IF (rao.outcome_value <= 0.2
         AND diedinhosp=1)
         arpt9_data->hosp_lowrisk_sim = (arpt9_data->hosp_lowrisk_sim+ 1)
        ENDIF
        IF (diedinhosp=1)
         arpt9_data->sim_hosp_mort_count = (arpt9_data->sim_hosp_mort_count+ 1)
        ENDIF
        cnt_sim_hsp_outcome = (cnt_sim_hsp_outcome+ 1), sim_hsp_outcome_val = (sim_hsp_outcome_val+
        rao.outcome_value)
        IF (cnvtdatetime(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm) != cnvtdatetime(null))
         hsp_los = datetimediff(pat_record9->pat_data[pos4].r_hosp_disch_dt_tm,pat_record9->pat_data[
          pos4].r_hosp_admit_dt_tm,1), hsp_los_trunc = least(datetimediff(pat_record9->pat_data[pos4]
           .r_hosp_disch_dt_tm,pat_record9->pat_data[pos4].r_hosp_admit_dt_tm,1),50.0), sim_hsp_cnt
          = (sim_hsp_cnt+ 1),
         sim_hsp_sum_los = (sim_hsp_sum_los+ hsp_los), sim_hsp_sum_los_trunc = (sim_hsp_sum_los_trunc
         + hsp_los_trunc)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF (rao.equation_name="NTL_1ST_TISS")
      arpt9_data->los_less_4hrs_cnt = (arpt9_data->los_less_4hrs_cnt+ 1)
     ELSEIF (rao.equation_name="ICU_LOS")
      pat_record9->pat_data[pos4].icu_los_less_4_hrs = 1
     ENDIF
    ENDIF
   ELSE
    IF (los >= 4.0
     AND cnvtdatetime(pat_record9->pat_data[pos4].r_icu_disch_dt_tm)=cnvtdatetime(null_date))
     IF (rao.equation_name="NTL_1ST_TISS")
      arpt9_data->icu_pt_not_disch_pred_cnt = (arpt9_data->icu_pt_not_disch_pred_cnt+ 1)
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   arpt9_data->ntl_icu_pred_mort = ((ntl_icu_outcome_val/ cnt_ntl_icu_outcome) * 100), arpt9_data->
   sim_icu_pred_mort = ((sim_icu_outcome_val/ cnt_sim_icu_outcome) * 100), arpt9_data->
   ntl_hosp_pred_mort = ((ntl_hsp_outcome_val/ cnt_ntl_hsp_outcome) * 100),
   arpt9_data->sim_hosp_pred_mort = ((sim_hsp_outcome_val/ cnt_sim_hsp_outcome) * 100), arpt9_data->
   avg_ap3 = (ap3/ cnt), arpt9_data->avg_aps = (aps/ cnt),
   arpt9_data->avg_icu_los_days = (sum_los/ pat_los_cnt), arpt9_data->avg_icu_los_trunc = (
   sum_los_trunc/ pat_los_cnt), arpt9_data->avg_sim_icu_los_trunc = (sim_sum_los_trunc/
   sim_pat_los_cnt),
   arpt9_data->avg_hosp_los_days = (hsp_sum_los/ hsp_cnt), arpt9_data->avg_hosp_los_trunc = (
   hsp_sum_los_trunc/ hsp_cnt), arpt9_data->avg_sim_hosp_los_trunc = (sim_hsp_sum_los_trunc/
   sim_hsp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_record9->cnt),
   risk_adjustment_outcomes rao
  PLAN (d)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name IN ("NTL_ICU_LOS", "SIM_ICU_LOS", "NTL_HSP_LOS", "SIM_HSP_LOS")
    AND rao.active_ind=1)
  HEAD PAGE
   icu_ntl_cnt = 0, icu_ntl_sum_outcome_value = 0.0, icu_sim_cnt = 0,
   icu_sim_sum_outcome_value = 0.0, hsp_ntl_cnt = 0, hsp_ntl_sum_outcome_value = 0.0,
   hsp_sim_cnt = 0, hsp_sim_sum_outcome_value = 0.0
  DETAIL
   los = datetimediff(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm,pat_record9->pat_data[d.seq].
    r_icu_admit_dt_tm,3)
   IF (cnvtdatetime(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm) != cnvtdatetime(null_date))
    IF (los >= 4)
     IF (rao.equation_name="NTL_ICU_LOS")
      icu_ntl_cnt = (icu_ntl_cnt+ 1), icu_ntl_sum_outcome_value = (rao.outcome_value+
      icu_ntl_sum_outcome_value)
      IF (rao.outcome_value != null)
       IF ((((datetimediff(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm,pat_record9->pat_data[d.seq
        ].r_icu_admit_dt_tm,1) - rao.outcome_value) - 2) >= 0.0))
        arpt9_data->ntl_icu_outliers = (arpt9_data->ntl_icu_outliers+ 1)
       ENDIF
      ENDIF
     ENDIF
     IF (rao.equation_name="SIM_ICU_LOS")
      icu_sim_cnt = (icu_sim_cnt+ 1), icu_sim_sum_outcome_value = (rao.outcome_value+
      icu_sim_sum_outcome_value)
      IF (rao.outcome_value != null)
       IF ((((datetimediff(pat_record9->pat_data[d.seq].r_icu_disch_dt_tm,pat_record9->pat_data[d.seq
        ].r_icu_admit_dt_tm,1) - rao.outcome_value) - 2) >= 0.0))
        arpt9_data->sim_icu_outliers = (arpt9_data->sim_icu_outliers+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (((rao.equation_name="NTL_HSP_LOS") OR (rao.equation_name="SIM_HSP_LOS")) )
    hsp_los = datetimediff(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm,pat_record9->pat_data[d
     .seq].r_hosp_admit_dt_tm,3)
    IF (cnvtdatetime(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm) != cnvtdatetime(null))
     IF (los >= 4)
      IF (rao.equation_name="NTL_HSP_LOS")
       hsp_ntl_cnt = (hsp_ntl_cnt+ 1), hsp_ntl_sum_outcome_value = (rao.outcome_value+
       hsp_ntl_sum_outcome_value)
       IF (rao.outcome_value != null)
        IF ((((datetimediff(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm,pat_record9->pat_data[d
         .seq].r_hosp_admit_dt_tm,1) - rao.outcome_value) - 2) >= 0.0))
         arpt9_data->ntl_hosp_outliers = (arpt9_data->ntl_hosp_outliers+ 1)
        ENDIF
       ENDIF
      ENDIF
      IF (rao.equation_name="SIM_HSP_LOS")
       hsp_sim_cnt = (hsp_sim_cnt+ 1), hsp_sim_sum_outcome_value = (rao.outcome_value+
       hsp_sim_sum_outcome_value)
       IF (rao.outcome_value != null)
        IF ((((datetimediff(pat_record9->pat_data[d.seq].r_hosp_disch_dt_tm,pat_record9->pat_data[d
         .seq].r_hosp_admit_dt_tm,1) - rao.outcome_value) - 2) >= 0.0))
         arpt9_data->sim_hosp_outliers = (arpt9_data->sim_hosp_outliers+ 1)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT PAGE
   arpt9_data->avg_pred_ntl_icu_los = (icu_ntl_sum_outcome_value/ icu_ntl_cnt), arpt9_data->
   avg_pred_sim_icu_los = (icu_sim_sum_outcome_value/ icu_sim_cnt), arpt9_data->avg_pred_ntl_hosp_los
    = (hsp_ntl_sum_outcome_value/ hsp_ntl_cnt),
   arpt9_data->avg_pred_sim_hosp_los = (hsp_sim_sum_outcome_value/ hsp_sim_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_record9->cnt),
   risk_adj_tiss rat,
   risk_adjustment_outcomes rao,
   risk_adjustment_outcomes rao2,
   code_value cv1
  PLAN (d
   WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0))
   JOIN (rat
   WHERE (rat.risk_adjustment_id=pat_record9->pat_data[d.seq].r_risk_adjustment_id)
    AND rat.tiss_beg_dt_tm <= cnvtdatetime(pat_record9->pat_data[d.seq].r_cc_end_dt_tm)
    AND rat.tiss_end_dt_tm >= cnvtdatetime(pat_record9->pat_data[d.seq].r_cc_beg_dt_tm)
    AND rat.active_ind=1)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name="SIM_1ST_TISS"
    AND rao.active_ind=1)
   JOIN (rao2
   WHERE (rao2.risk_adjustment_day_id=pat_record9->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao2.equation_name="NTL_1ST_TISS"
    AND rao2.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_set=29747
    AND cv1.code_value=rat.tiss_cd
    AND cv1.display_key != "NONE"
    AND cv1.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   last_tiss_id = 0.0, last_tiss_counter = 0
  HEAD d.seq
   last_tiss_counter = 0, arpt9_data->tiss_day_1_pat_cnt = (arpt9_data->tiss_day_1_pat_cnt+ 1),
   arpt9_data->tiss_day_1_sim_sum = (arpt9_data->tiss_day_1_sim_sum+ rao.outcome_value),
   arpt9_data->tiss_day_1_ntl_sum = (arpt9_data->tiss_day_1_ntl_sum+ rao2.outcome_value)
  DETAIL
   last_tiss_counter = (last_tiss_counter+ 1), arpt9_data->tiss_day_1_sum = (arpt9_data->
   tiss_day_1_sum+ cnvtint(substring(3,1,cv1.definition))), pat_record9->pat_data[d.seq].
   actual_tiss_score = (pat_record9->pat_data[d.seq].actual_tiss_score+ cnvtint(substring(3,1,cv1
     .definition)))
  FOOT REPORT
   arpt9_data->tiss_day_1_sim_avg = (arpt9_data->tiss_day_1_sim_sum/ arpt9_data->tiss_day_1_pat_cnt),
   arpt9_data->tiss_day_1_ntl_avg = (arpt9_data->tiss_day_1_ntl_sum/ arpt9_data->tiss_day_1_pat_cnt),
   arpt9_data->tiss_day_1_avg = (arpt9_data->tiss_day_1_sum/ arpt9_data->tiss_day_1_pat_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_record9->cnt),
   risk_adj_tiss rat,
   code_value cv1
  PLAN (d
   WHERE (pat_record9->pat_data[d.seq].icu_los_less_4_hrs=0))
   JOIN (rat
   WHERE (rat.risk_adjustment_id=pat_record9->pat_data[d.seq].r_risk_adjustment_id)
    AND rat.tiss_beg_dt_tm <= cnvtdatetime(pat_record9->pat_data[d.seq].r_cc_end_dt_tm)
    AND rat.tiss_end_dt_tm >= cnvtdatetime(pat_record9->pat_data[d.seq].r_cc_beg_dt_tm)
    AND rat.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_set=29747
    AND cv1.code_value=rat.tiss_cd
    AND cv1.display_key != "NONE"
    AND cv1.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   last_tiss_id = 0.0, last_tiss_counter = 0
  HEAD d.seq
   last_tiss_counter = 0, arpt9_data->all_tiss_day_1_pat_cnt = (arpt9_data->all_tiss_day_1_pat_cnt+ 1
   )
  DETAIL
   last_tiss_counter = (last_tiss_counter+ 1), arpt9_data->all_tiss_day_1_sum = (arpt9_data->
   all_tiss_day_1_sum+ cnvtint(substring(3,1,cv1.definition)))
  FOOT REPORT
   arpt9_data->all_tiss_day_1_avg = (arpt9_data->all_tiss_day_1_sum/ arpt9_data->
   all_tiss_day_1_pat_cnt)
  WITH nocounter
 ;end select
 SET arpt9_data->tiss_day_1_ntl_p_value = tiss_p_value_calc("NTL_1ST_TISS")
 SET arpt9_data->tiss_day_1_sim_p_value = tiss_p_value_calc("SIM_1ST_TISS")
 SET arpt9_data->ntl_icu_p_los_val = icu_p_value_calc("NTL_ICU_LOS")
 SET arpt9_data->sim_icu_p_los_val = icu_p_value_calc("SIM_ICU_LOS")
 SET arpt9_data->ntl_hosp_p_los_val = hosp_p_value_calc("NTL_HSP_LOS",arpt9_data->
  los_more_4hrs_hsp_pred_cnt)
 SET arpt9_data->sim_hosp_p_los_val = hosp_p_value_calc("SIM_HSP_LOS",arpt9_data->
  los_more_4hrs_sim_hsp_pred_cnt)
 SET arpt9_data->icu_day_5_pred_cnt = patientwithprediction(0)
 SET arpt9_data->icu_pred_less24 = patientwithprediction(1)
 SET arpt9_data->p_val_icu_mort_ntl_disp = pmortalitycalc("NTL_ICU_DEATH",arpt9_data->
  los_more_4hrs_cnt,arpt9_data->icu_mort_count,"ICU")
 SET arpt9_data->p_val_icu_mort_sim_disp = pmortalitycalc("SIM_ICU_DEATH",arpt9_data->
  los_more_4hrs_cnt,arpt9_data->sim_icu_mort_count,"ICU")
 SET arpt9_data->p_val_hosp_mort_ntl_disp = pmortalitycalc("NTL_HSP_DEATH",arpt9_data->
  pat_hosp_disch_cnt,arpt9_data->hosp_mort_count,"HSP")
 SET arpt9_data->p_val_hosp_mort_sim_disp = pmortalitycalc("SIM_HSP_DEATH",arpt9_data->
  pat_hosp_disch_cnt,arpt9_data->sim_hosp_mort_count,"HSP")
 RECORD adverse_event_record(
   1 event_cd[*]
     2 event_name = vc
     2 event_cd = f8
     2 pat_count = i4
     2 event_count = i4
   1 total_pats = i4
   1 total_events = i4
 )
 RECORD therapy_event_record(
   1 event_cd[*]
     2 event_name = vc
     2 event_cd = f8
     2 pat_count = i4
     2 event_count = i4
   1 total_pats = i4
   1 total_events = i4
 )
 SET adver_cd = meaning_code(28985,"ADVER")
 DECLARE num10 = i4
 SELECT INTO "nl:"
  FROM risk_adjustment_event rae
  PLAN (rae
   WHERE expand(num10,1,risk_record->total_admit,rae.risk_adjustment_id,risk_record->risk[num10].
    risk_id)
    AND rae.active_ind=1)
  ORDER BY rae.sentinel_event_code_cd, rae.risk_adjustment_id
  HEAD REPORT
   total_pat_count = 0, total_event_count = 0, total_pat_count2 = 0,
   total_event_count2 = 0, event_count = 0, pat_count = 0,
   curr_indx = 0, curr_indx2 = 0
  HEAD rae.sentinel_event_code_cd
   event_count = 0, pat_count = 0, event_count2 = 0,
   pat_count2 = 0
   IF (rae.sentinel_event_category_cd=adver_cd)
    curr_indx = (curr_indx+ 1)
    IF (mod(curr_indx,100)=1)
     stat = alterlist(adverse_event_record->event_cd,(curr_indx+ 99))
    ENDIF
    adverse_event_record->event_cd[curr_indx].event_cd = rae.sentinel_event_code_cd,
    adverse_event_record->event_cd[curr_indx].event_name = uar_get_code_display(rae
     .sentinel_event_code_cd)
   ELSE
    curr_indx2 = (curr_indx2+ 1)
    IF (mod(curr_indx2,100)=1)
     stat = alterlist(therapy_event_record->event_cd,(curr_indx2+ 99))
    ENDIF
    therapy_event_record->event_cd[curr_indx2].event_cd = rae.sentinel_event_code_cd,
    therapy_event_record->event_cd[curr_indx2].event_name = uar_get_code_display(rae
     .sentinel_event_code_cd)
   ENDIF
  HEAD rae.risk_adjustment_id
   IF (rae.sentinel_event_category_cd=adver_cd)
    pat_count = (pat_count+ 1), total_pat_count = (total_pat_count+ 1)
   ELSE
    pat_count2 = (pat_count2+ 1), total_pat_count2 = (total_pat_count2+ 1)
   ENDIF
  DETAIL
   event_count = (event_count+ 1), total_event_count = (total_event_count+ 1)
  FOOT  rae.sentinel_event_code_cd
   IF (rae.sentinel_event_category_cd=adver_cd)
    adverse_event_record->event_cd[curr_indx].event_count = event_count, adverse_event_record->
    event_cd[curr_indx].pat_count = pat_count
   ELSE
    therapy_event_record->event_cd[curr_indx2].event_count = event_count2, therapy_event_record->
    event_cd[curr_indx2].pat_count = pat_count2
   ENDIF
  FOOT REPORT
   adverse_event_record->total_events = total_event_count, adverse_event_record->total_pats =
   total_pat_count, therapy_event_record->total_events = total_event_count2,
   therapy_event_record->total_pats = total_pat_count2, stat = alterlist(adverse_event_record->
    event_cd,curr_indx), stat = alterlist(therapy_event_record->event_cd,curr_indx2)
  WITH nocounter
 ;end select
 DECLARE source_cd = f8
 RECORD admit_source(
   1 cnt = i4
   1 source[*]
     2 name = vc
     2 name_cdf = vc
     2 count = i4
     2 tot_hours = i4
     2 avg_hours = i4
     2 avg_days = i4
     2 min_hours = i4
     2 max_hours = i4
     2 min_days = i4
     2 max_days = i4
   1 source_tmp[*]
     2 name = vc
     2 name_cdf = vc
     2 count = i4
     2 tot_hours = i4
     2 avg_hours = i4
     2 avg_days = i4
     2 min_hours = i4
     2 max_hours = i4
     2 min_days = i4
     2 max_days = i4
 )
 SET tot_pa_line = 0
 SET tot_vent = 0
 SET new_los = 0.0
 DECLARE num15 = i4
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE expand(num15,1,risk_record->total_admit,ra.risk_adjustment_id,risk_record->risk[num15].
    risk_id)
    AND ((ra.active_ind+ 0)=1))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1
    AND rad.cc_day=1)
  ORDER BY ra.admit_source
  HEAD REPORT
   last_admit_src = "11JUNK11", counter = 0
  HEAD ra.admit_source
   IF ((risk_record->total_admit > 0))
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(admit_source->source_tmp,(counter+ 9))
    ENDIF
    admit_source->source_tmp[counter].name_cdf = ra.admit_source, rec_counter = 0
   ENDIF
  DETAIL
   rec_counter = (rec_counter+ 1), admit_source->source_tmp[counter].count = (admit_source->
   source_tmp[counter].count+ 1), los_end_dt = ra.icu_disch_dt_tm
   IF (ra.icu_disch_dt_tm < ra.icu_admit_dt_tm)
    los_end_dt = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    los_end_dt = cnvtdatetime(curdate,curtime3)
   ENDIF
   new_los = datetimediff(los_end_dt,ra.icu_admit_dt_tm,3), admit_source->source_tmp[counter].
   tot_hours = (admit_source->source_tmp[counter].tot_hours+ new_los)
   IF ((((new_los < admit_source->source_tmp[counter].min_hours)) OR (rec_counter=1)) )
    admit_source->source_tmp[counter].min_hours = new_los
   ENDIF
   IF ((((new_los > admit_source->source_tmp[counter].max_hours)) OR (rec_counter=1)) )
    admit_source->source_tmp[counter].max_hours = new_los
   ENDIF
  FOOT REPORT
   stat = alterlist(admit_source->source_tmp,counter)
  WITH nocounter
 ;end select
 SET array_size = size(admit_source->source_tmp,5)
 FOR (x = 1 TO array_size)
   SET admit_source->source_tmp[x].avg_hours = round((cnvtreal(admit_source->source_tmp[x].tot_hours)
    / cnvtreal(admit_source->source_tmp[x].count)),0)
   SET admit_source->source_tmp[x].avg_days = round((cnvtreal(admit_source->source_tmp[x].avg_hours)
    / 24),0)
   SET admit_source->source_tmp[x].min_days = round((cnvtreal(admit_source->source_tmp[x].min_hours)
    / 24),0)
   SET admit_source->source_tmp[x].max_days = round((cnvtreal(admit_source->source_tmp[x].max_hours)
    / 24),0)
 ENDFOR
 SET sort_arr_sz = size(admit_source->source_tmp,5)
 SET stat = alterlist(admit_source->source,sort_arr_sz)
 FOR (z = 1 TO sort_arr_sz)
  SET source_cd = meaning_code(28981,admit_source->source_tmp[z].name_cdf)
  SET admit_source->source_tmp[z].name = uar_get_code_display(source_cd)
 ENDFOR
 IF (sort_arr_sz > 0)
  SELECT INTO "nl:"
   name = admit_source->source_tmp[d.seq].name
   FROM (dummyt d  WITH seq = sort_arr_sz)
   ORDER BY admit_source->source_tmp[d.seq].count DESC, name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), admit_source->source[counter].name = admit_source->source_tmp[d.seq].name,
    admit_source->source[counter].name_cdf = admit_source->source_tmp[d.seq].name_cdf,
    admit_source->source[counter].count = admit_source->source_tmp[d.seq].count, admit_source->
    source[counter].tot_hours = admit_source->source_tmp[d.seq].tot_hours, admit_source->source[
    counter].avg_hours = admit_source->source_tmp[d.seq].avg_hours,
    admit_source->source[counter].avg_days = admit_source->source_tmp[d.seq].avg_days, admit_source->
    source[counter].min_hours = admit_source->source_tmp[d.seq].min_hours, admit_source->source[
    counter].max_hours = admit_source->source_tmp[d.seq].max_hours,
    admit_source->source[counter].min_days = admit_source->source_tmp[d.seq].min_days, admit_source->
    source[counter].max_days = admit_source->source_tmp[d.seq].max_days
   WITH nocounter
  ;end select
 ENDIF
 SET icu_4_hr_count = 0
 SET tot_pa_pred = 0.0
 SET tot_vent_pred = 0.0
 SET pa_pred_ratio = 0.0
 SET pa_actual_ratio = 0.0
 SET pa_ratio = 0.0
 SET pa_outlier = 0
 SET pa_outlier_ratio = 0.0
 SET num15 = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao
  PLAN (ra
   WHERE expand(num15,1,risk_record->total_admit,ra.risk_adjustment_id,risk_record->risk[num15].
    risk_id)
    AND ((ra.active_ind+ 0)=1))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1
    AND rad.cc_day=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND trim(rao.equation_name)="NTL_SWAN_GANZ"
    AND ((rao.active_ind+ 0)=1))
  HEAD REPORT
   junk = ""
  DETAIL
   IF (datetimediff(ra.icu_disch_dt_tm,ra.icu_admit_dt_tm,3) > 4.0)
    icu_4_hr_count = (icu_4_hr_count+ 1)
    IF (rad.pa_line_today_ind=1)
     tot_pa_line = (tot_pa_line+ 1)
     IF (rao.outcome_value <= 0.20)
      pa_outlier = (pa_outlier+ 1)
     ENDIF
    ENDIF
    tot_pa_pred = (tot_pa_pred+ rao.outcome_value)
   ENDIF
  FOOT REPORT
   pa_pred_ratio = ((tot_pa_pred * 100)/ icu_4_hr_count), pa_actual_ratio = ((tot_pa_line * 100)/
   icu_4_hr_count), pa_ratio = (pa_actual_ratio/ pa_pred_ratio),
   pa_outlier_ratio = ((pa_outlier * 100)/ tot_pa_line)
  WITH nocounter
 ;end select
 SET total_vent_days = 0
 SET total_trunc_vent_days = 0
 SET total_vent_pats = 0
 SET total_pred_vent = 0.0
 SET pat_outcome = 0.0
 SET pat_vent_days = 0
 SET pat_trunc_vent_days = 0
 SET total_vent_outliers = 0
 SET actual_avg_vent_days = 0.0
 SET actual_avg_trunc_vent_days = 0.0
 SET pred_avg_vent_days = 0.0
 SET vent_ratio = 0.0
 SET vent_trunc_ratio = 0.0
 SET vent_outlier_ratio = 0.0
 SET num15 = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao
  PLAN (ra
   WHERE expand(num15,1,risk_record->total_admit,ra.risk_adjustment_id,risk_record->risk[num15].
    risk_id)
    AND ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100")
    AND ((ra.active_ind+ 0)=1))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND ((rad.active_ind+ 0)=1))
   JOIN (rao
   WHERE (((rao.risk_adjustment_day_id=(rad.risk_adjustment_day_id+ 0))
    AND trim(rao.equation_name)="NTL_VENT_DAYS"
    AND ((rao.active_ind+ 0)=1)) OR (rao.risk_adjustment_outcomes_id=0.0)) )
  ORDER BY rad.risk_adjustment_id, rad.cc_day, rao.risk_adjustment_outcomes_id DESC
  HEAD REPORT
   junk = ""
  HEAD rad.risk_adjustment_id
   keep_counting_vent = "Y", pat_outcome = 0.0, pat_vent_days = 0,
   pred_patient = 0
   IF (rad.vent_today_ind=1
    AND rao.outcome_value > 0
    AND datetimediff(ra.icu_disch_dt_tm,ra.icu_admit_dt_tm,3) > 4.0)
    pred_patient = 1
   ENDIF
  HEAD rad.cc_day
   IF (pred_patient=1)
    IF (keep_counting_vent="Y")
     IF (rad.vent_today_ind=1)
      total_vent_days = (total_vent_days+ 1), pat_vent_days = (pat_vent_days+ 1)
     ELSE
      keep_counting_vent = "N"
     ENDIF
    ENDIF
    IF (rao.equation_name="NTL_VENT_DAYS")
     IF (rad.cc_day=1)
      total_pred_vent = (total_pred_vent+ rao.outcome_value), pat_outcome = rao.outcome_value,
      total_vent_pats = (total_vent_pats+ 1)
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   junkint = 0
  FOOT  rad.risk_adjustment_id
   IF (ra.admit_diagnosis IN ("S-CABG", "S-CABGREDO", "S-CABGROTH", "S-CABGWOTH"))
    pat_trunc_vent_days = least(10,pat_vent_days)
   ELSE
    pat_trunc_vent_days = least(30,pat_vent_days)
   ENDIF
   CALL echo(build(ra.risk_adjustment_id,"=PATIENT_VENT_DAYS=",pat_vent_days)), total_trunc_vent_days
    = (total_trunc_vent_days+ pat_trunc_vent_days)
   IF (((pat_vent_days - pat_outcome) >= 2))
    total_vent_outliers = (total_vent_outliers+ 1)
   ENDIF
  FOOT REPORT
   actual_avg_vent_days = cnvtreal((cnvtreal(total_vent_days)/ cnvtreal(total_vent_pats))),
   actual_avg_trunc_vent_days = cnvtreal((cnvtreal(total_trunc_vent_days)/ cnvtreal(total_vent_pats))
    ), pred_avg_vent_days = (total_pred_vent/ total_vent_pats),
   vent_ratio = cnvtreal((cnvtreal(actual_avg_vent_days)/ cnvtreal(pred_avg_vent_days))),
   vent_trunc_ratio = cnvtreal((cnvtreal(actual_avg_trunc_vent_days)/ cnvtreal(pred_avg_vent_days))),
   vent_outlier_ratio = (cnvtreal((cnvtreal(total_vent_outliers)/ cnvtreal(total_vent_pats))) * 100)
  WITH nocounter
 ;end select
 SET lastrow = 79
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   count = 1
  HEAD PAGE
   col 0, font110c, row + 1,
   col 1, rpt_params->gen_on, col 75,
   "By Module: DCP_ARPT_15_UTIL_MGMT_SUMM", row + 1,
   CALL center("*** APACHE For ICU ***",0,110),
   row + 1,
   CALL center("JCAHO REPORT",0,110), row + 1,
   col 0, font80c, row + 1,
   CALL center("Utilization Management Summary",0,80), row + 1, col 0,
   font110c, row + 1, line = fillstring(120,"-"),
   CALL center(rpt_params->date_type_range_disp,0,110), row + 1, col 1,
   line, row + 1,
   CALL center(rpt_params->org_name,0,110),
   row + 1,
   CALL center(rpt_params->unit_disp,0,110), row + 2
  DETAIL
   risk_id_cnt = 0, row + 1, col 1,
   "1. Volume Indicators", row + 2, col 2,
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
   risk_id_cnt = 0, pt_cnt = 0, non_pred_cnt = 0,
   icu_disch_cnt = 0, last_risk_id = 0.0
   FOR (z = 1 TO pat_record9->cnt)
     IF ((last_risk_id != pat_record9->pat_data[z].r_risk_adjustment_id))
      risk_id_cnt = (risk_id_cnt+ 1), last_risk_id = pat_record9->pat_data[z].r_risk_adjustment_id
     ENDIF
     pt_cnt = (pt_cnt+ 1)
     IF ((((pat_record9->pat_data[z].ra_outcome_status=- (23103))) OR ((((pat_record9->pat_data[z].
     ra_outcome_status=- (23100))) OR ((pat_record9->pat_data[z].ra_outcome_status=- (23117)))) )) )
      non_pred_cnt = (non_pred_cnt+ 1)
     ENDIF
     IF ((pat_record9->pat_data[z].r_icu_disch_dt_tm != null_date))
      icu_disch_cnt = (icu_disch_cnt+ 1)
     ENDIF
   ENDFOR
   icu_disch_no_pred_cnt = (arpt9_data->icu_disch_cnt - (arpt9_data->los_more_4hrs_cnt+ arpt9_data->
   los_less_4hrs_cnt)), icu_not_disch_no_pred_cnt = (arpt9_data->icu_pt_not_disch_cnt - arpt9_data->
   icu_pt_not_disch_pred_cnt), pt_total = pat_record9->cnt,
   readmit_total_disp = format(arpt9_data->readmit_total,"#######;r"), first_visit_disp = format(
    arpt9_data->first_visit_total,"#######;r"), subseq_visit_disp = format((pt_total - arpt9_data->
    first_visit_total),"#######;r"),
   pt_total_disp = format(pt_total,"#######;r"), non_pred_cnt_disp = format(arpt9_data->non_pred_cnt,
    "#######;r"), icu_disch_cnt_disp = format(arpt9_data->icu_disch_cnt,"#######;r"),
   los_more_4hrs_cnt_disp = format(arpt9_data->los_more_4hrs_cnt,"#######;r"),
   los_more_4hrs_icu_pred_cnt_disp = format(arpt9_data->los_more_4hrs_icu_pred_cnt,"#######;r"),
   los_more_4hrs_hsp_pred_cnt_disp = format(arpt9_data->los_more_4hrs_hsp_pred_cnt,"#######;r"),
   los_more_4hrs_sim_pred_cnt_disp = format(arpt9_data->los_more_4hrs_sim_pred_cnt,"#######;r"),
   los_less_4hrs_cnt_disp = format(arpt9_data->los_less_4hrs_cnt,"#######;r"),
   icu_disch_no_pred_cnt_disp = format(icu_disch_no_pred_cnt,"#######;r"),
   icu_not_disch_no_pred_cnt_disp = format(icu_not_disch_no_pred_cnt,"#######;r"),
   icu_pt_not_disch_pred_cnt_disp = format(arpt9_data->icu_pt_not_disch_pred_cnt,"#######;r"),
   icu_pt_not_disch_cnt_disp = format(arpt9_data->icu_pt_not_disch_cnt,"#######;r"),
   pat_no_hosp_disch_cnt_disp = format(arpt9_data->pat_no_hosp_disch_cnt,"#######;r"),
   icu_pred_cnt_hosp_disch_disp = format(arpt9_data->icu_pred_cnt_hosp_disch,"#######;r"),
   pat_hosp_disch_cnt_disp = format(arpt9_data->pat_hosp_disch_cnt,"#######;r"),
   pat_hosp_disch_pred_cnt_disp = format(arpt9_data->pat_hosp_disch_pred_cnt,"#######;r"),
   CALL echo(build("arpt9_data->pat_hosp_disch_pred_cnt=",arpt9_data->pat_hosp_disch_pred_cnt)),
   CALL echo(build("pat_hosp_disch_pred_cnt_disp=",pat_hosp_disch_pred_cnt_disp)),
   avg_ap3_disp = format(arpt9_data->avg_ap3,"#######.##;r"), avg_aps_disp = format(arpt9_data->
    avg_aps,"#######.##;r"), avg_icu_los_days_disp = format(arpt9_data->avg_icu_los_days,"#####.##;r"
    ),
   avg_icu_los_trunc_disp = format(arpt9_data->avg_icu_los_trunc,"#####.##;r"),
   avg_hosp_los_days_disp = format(arpt9_data->avg_hosp_los_days,"#####.##;r"),
   avg_hosp_los_trunc_disp = format(arpt9_data->avg_hosp_los_trunc,"#####.##;r"),
   avg_pred_ntl_icu_los_disp = format(arpt9_data->avg_pred_ntl_icu_los,"#####.##;r"),
   avg_pred_sim_icu_los_disp = format(arpt9_data->avg_pred_sim_icu_los,"#####.##;r"),
   avg_pred_ntl_hosp_los_disp = format(arpt9_data->avg_pred_ntl_hosp_los,"#####.##;r"),
   avg_pred_sim_hosp_los_disp = format(arpt9_data->avg_pred_sim_hosp_los,"#####.##;r"), ntl_icu_ratio
    = (arpt9_data->avg_icu_los_trunc/ arpt9_data->avg_pred_ntl_icu_los), ntl_icu_ratio_disp =
   fillstring(20," "),
   ntl_icu_ratio_disp = concat(format(ntl_icu_ratio,"#####.##;r")," ",arpt9_data->ntl_icu_p_los_val),
   sim_icu_ratio = (arpt9_data->avg_sim_icu_los_trunc/ arpt9_data->avg_pred_sim_icu_los),
   sim_icu_ratio_disp = fillstring(20," "),
   sim_icu_ratio_disp = concat(format(sim_icu_ratio,"#####.##;r")," ",arpt9_data->sim_icu_p_los_val),
   ntl_hosp_ratio = (arpt9_data->avg_hosp_los_trunc/ arpt9_data->avg_pred_ntl_hosp_los),
   ntl_hosp_ratio_disp = fillstring(20," "),
   ntl_hosp_ratio_disp = concat(format(ntl_hosp_ratio,"#####.##;r")," ",arpt9_data->
    ntl_hosp_p_los_val), sim_hosp_ratio = (arpt9_data->avg_sim_hosp_los_trunc/ arpt9_data->
   avg_pred_sim_hosp_los), sim_hosp_ratio_disp = fillstring(20," "),
   sim_hosp_ratio_disp = concat(format(sim_hosp_ratio,"#####.##;r")," ",arpt9_data->
    sim_hosp_p_los_val), ntl_icu_outliers_disp = format(arpt9_data->ntl_icu_outliers,"#######;r"),
   sim_icu_outliers_disp = format(arpt9_data->sim_icu_outliers,"#######;r"),
   ntl_hosp_outliers_disp = format(arpt9_data->ntl_hosp_outliers,"#######;r"), sim_hosp_outliers_disp
    = format(arpt9_data->sim_hosp_outliers,"#######;r"), icu_day_5_pred_cnt_disp = format(arpt9_data
    ->icu_day_5_pred_cnt,"#######;r"),
   icu_pred_less24_disp = format(arpt9_data->icu_pred_less24,"#######;r"), icu_actual_mort = ((
   arpt9_data->icu_mort_count/ arpt9_data->los_more_4hrs_icu_pred_cnt) * 100), sim_icu_actual_mort =
   ((arpt9_data->sim_icu_mort_count/ arpt9_data->los_more_4hrs_sim_icu_pred_cnt) * 100),
   hosp_actual_mort = ((arpt9_data->hosp_mort_count/ arpt9_data->pat_hosp_disch_pred_cnt) * 100),
   sim_hosp_actual_mort = ((arpt9_data->sim_hosp_mort_count/ arpt9_data->
   los_more_4hrs_sim_hsp_pred_cnt) * 100), icu_actual_mort_disp = format(icu_actual_mort,"###.##%;r"
    ),
   hosp_actual_mort_disp = format(hosp_actual_mort,"###.##%;r"), icu_mort_count_disp = format(
    arpt9_data->icu_mort_count,"#######;r"), hosp_mort_count_disp = format(arpt9_data->
    hosp_mort_count,"#######;r"),
   sim_icu_mort_count_disp = format(arpt9_data->sim_icu_mort_count,"#######;r"),
   sim_hosp_mort_count_disp = format(arpt9_data->sim_hosp_mort_count,"#######;r"),
   all_icu_actual_mort = ((arpt9_data->all_icu_mort_count/ arpt9_data->los_more_4hrs_cnt) * 100),
   all_hosp_actual_mort = ((arpt9_data->all_hosp_mort_count/ arpt9_data->pat_hosp_disch_cnt) * 100),
   all_icu_mort_count_disp = format(arpt9_data->all_icu_mort_count,"#######;r"),
   all_hosp_mort_count_disp = format(arpt9_data->all_hosp_mort_count,"#######;r"),
   ntl_icu_pred_mort_disp = format(arpt9_data->ntl_icu_pred_mort,"###.##%;r"),
   sim_icu_pred_mort_disp = format(arpt9_data->sim_icu_pred_mort,"###.##%;r"),
   ntl_hosp_pred_mort_disp = format(arpt9_data->ntl_hosp_pred_mort,"###.##%;r"),
   sim_hosp_pred_mort_disp = format(arpt9_data->sim_hosp_pred_mort,"###.##%;r"), icu_ntl_ratio = (
   icu_actual_mort/ arpt9_data->ntl_icu_pred_mort), icu_ntl_ratio_disp = fillstring(20," "),
   icu_ntl_ratio_disp = concat(format(icu_ntl_ratio,"###.##;r")," ",arpt9_data->
    p_val_icu_mort_ntl_disp), icu_sim_ratio = (sim_icu_actual_mort/ arpt9_data->sim_icu_pred_mort),
   icu_sim_ratio_disp = fillstring(20," "),
   icu_sim_ratio_disp = concat(format(icu_sim_ratio,"###.##;r")," ",arpt9_data->
    p_val_icu_mort_sim_disp), hosp_ntl_ratio = (hosp_actual_mort/ arpt9_data->ntl_hosp_pred_mort),
   hosp_ntl_ratio_disp = fillstring(20," "),
   hosp_ntl_ratio_disp = concat(format(hosp_ntl_ratio,"#####.##;r")," ",arpt9_data->
    p_val_hosp_mort_ntl_disp), hosp_sim_ratio = (sim_hosp_actual_mort/ arpt9_data->sim_hosp_pred_mort
   ), hosp_sim_ratio_disp = fillstring(20," "),
   hosp_sim_ratio_disp = concat(format(hosp_sim_ratio,"#####.##;r")," ",arpt9_data->
    p_val_hosp_mort_sim_disp), icu_lowrisk_ntl_disp = format(arpt9_data->icu_lowrisk_ntl,"#######;r"),
   icu_lowrisk_sim_disp = format(arpt9_data->icu_lowrisk_sim,"#######;r"),
   hosp_lowrisk_ntl_disp = format(arpt9_data->hosp_lowrisk_ntl,"#######;r"), hosp_lowrisk_sim_disp =
   format(arpt9_data->hosp_lowrisk_sim,"#######;r"), tot_pat_with_outcome_disp = format(arpt9_data->
    tot_pat_with_outcome,"#######;r"),
   tot_pat_readmit_outcome_disp = format(arpt9_data->tot_pat_readmit_outcome,"#######;r"),
   tot_pat_readmit_outcome_24_disp = format(arpt9_data->tot_pat_readmit_outcome_24,"#######;r"),
   tot_pat_readmit_outcome_after24_disp = format(arpt9_data->tot_pat_readmit_outcome_after24,
    "#######;r"),
   tot_pat_readmit_outcome_ratio = ((arpt9_data->tot_pat_readmit_outcome/ arpt9_data->
   tot_pat_with_outcome) * 100), tot_pat_readmit_outcome_ratio_24 = ((arpt9_data->
   tot_pat_readmit_outcome_24/ arpt9_data->tot_pat_readmit_outcome) * 100),
   tot_pat_readmit_outcome_ratio_after24 = ((arpt9_data->tot_pat_readmit_outcome_after24/ arpt9_data
   ->tot_pat_readmit_outcome) * 100),
   tot_pat_readmit_outcome_ratio_disp = format(tot_pat_readmit_outcome_ratio,"###.##%;r"),
   tot_pat_readmit_outcome_ratio_24_disp = format(tot_pat_readmit_outcome_ratio_24,"###.##%;r"),
   tot_pat_readmit_outcome_ratio_after24_disp = format(tot_pat_readmit_outcome_ratio_after24,
    "###.##%;r"),
   tot_pat_readmit_within_24hrs_disp = format(arpt9_data->readmit_within_24hr_total,"#######;r"),
   tot_pat_readmit_after_24hrs_cnt = (arpt9_data->readmit_total - arpt9_data->
   readmit_within_24hr_total), tot_pat_readmit_after_24hrs_disp = format(
    tot_pat_readmit_after_24hrs_cnt,"#######;r"),
   row + 2, BREAK, col 1,
   "II. Clinical Indicators", row + 1, col 3,
   "Total # ICU pts w/in Time Period Selected (all patients including readmits) ", col 90,
   pt_total_disp,
   row + 1, col 5, "# of readmissions ",
   col 90, readmit_total_disp, row + 1,
   col 5, "# of readmissions within 24 hours", col 90,
   tot_pat_readmit_within_24hrs_disp, row + 1, col 5,
   "# of readmissions after 24 hours", col 90, tot_pat_readmit_after_24hrs_disp,
   row + 1, col 5, "# of APACHE First Sub-Encounters ",
   col 90, first_visit_disp, row + 1,
   col 5, "# of APACHE Subsequent Sub-Encounters ", col 90,
   subseq_visit_disp, row + 2, col 3,
   "# Non-Predictive Patients ", col 90, non_pred_cnt_disp,
   row + 1
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 3, "# ICU Patients with ICU Discharge ", col 90,
   icu_disch_cnt_disp, row + 1, col 5,
   "ICU LOS < 4 hours with Predictions ", col 90, los_less_4hrs_cnt_disp,
   row + 1, col 5, "ICU LOS >= 4 hours with Predictions ",
   col 90, los_more_4hrs_cnt_disp, row + 1,
   col 5, "ICU LOS >= 4 hours with Predictions not discharged to another ICU", col 90,
   los_more_4hrs_icu_pred_cnt_disp, row + 1, col 5,
   "ICU LOS >= 4 hours with Predictions, initial ICU stays only", col 90,
   los_more_4hrs_hsp_pred_cnt_disp,
   row + 1, col 5, "ICU LOS >= 4 hours with Similar Predictions ",
   col 90, los_more_4hrs_sim_pred_cnt_disp, row + 1,
   col 5, "Without Predictions (Includes Non-Pred patients and those with errors on Day 1)", col 90,
   icu_disch_no_pred_cnt_disp, row + 1, col 3,
   "# ICU Patients without ICU Discharge ", col 90, icu_pt_not_disch_cnt_disp,
   row + 1, col 5, "With Predictions ",
   col 90, icu_pt_not_disch_pred_cnt_disp, row + 1,
   col 5, "Without Predictions (Includes Non-Pred patients and those with errors on Day 1)", col 90,
   icu_not_disch_no_pred_cnt_disp, row + 1, col 3,
   "# ICU Pts without Hospital Discharge ", col 90, pat_no_hosp_disch_cnt_disp,
   row + 1, col 3, "# ICU Pts with Hospital Discharge and Predictions ",
   col 90, icu_pred_cnt_hosp_disch_disp, row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 2, "A.  Average APACHE Score on ICU Day 1: ", junk = format(arpt9_data->avg_ap3,"####.##"),
   col 90, junk, junk2 = format(arpt9_data->avg_aps,"####.##"),
   row + 1, col 7, "(Sum of APACHE Scores divided by # ICU Predicted outcomes (ICU LOS >= 4 hrs)) ",
   row + 1, col 3, "    Average APS on ICU Day 1 ",
   col 90, junk2, row + 1,
   col 7, "(Sum of APS Scores divided by total # ICU predicted outcomes (ICU LOS >= 4 hrs)) ", row +
   2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 2, "B. ICU and Hospital Length of Stay ", col 75,
   "ICU ", col 90, "Hospital ",
   row + 1, col 10, "Actual ICU LOS >= 4 hours, ICU Discharged and Predictions ",
   row + 1, col 5, "# Patients with ICU Discharge ",
   col 70, los_more_4hrs_icu_pred_cnt_disp, col 90,
   pat_hosp_disch_pred_cnt_disp, row + 1, col 5,
   "Actual Average LOS Days", col 70, avg_icu_los_days_disp,
   col 90, avg_hosp_los_days_disp, row + 1,
   col 5, "Actual Average LOS truncated ", col 70,
   avg_icu_los_trunc_disp, col 90, avg_hosp_los_trunc_disp,
   row + 1, col 7, "(@30 ICU, @50 Hospital) ",
   row + 1
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 5, "National Pred in Days ", col 70,
   avg_pred_ntl_icu_los_disp, col 90, avg_pred_ntl_hosp_los_disp,
   row + 1, col 7, "Ratio = Actual Truncated Days/Pred Natl Days ",
   col 70, ntl_icu_ratio_disp, col 90,
   ntl_hosp_ratio_disp, row + 1, col 5,
   "Similar Pred in Days ", col 70, avg_pred_sim_icu_los_disp,
   col 90, avg_pred_sim_hosp_los_disp, row + 1,
   col 7, "Ratio = Actual Truncated Days/Pred Siml Days ", col 70,
   sim_icu_ratio_disp, col 90, sim_hosp_ratio_disp,
   row + 1
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 5, "OUTLIERS >= 2 days ", row + 1,
   col 7, "Actual # pts Exceeded Nat'l Prediction Day 1 ", col 70,
   ntl_icu_outliers_disp, col 90, ntl_hosp_outliers_disp,
   row + 1, col 7, "Actual # pts Exceeded Similar Prediction Day 1 ",
   col 70, sim_icu_outliers_disp, col 90,
   sim_hosp_outliers_disp, row + 1, col 5,
   "# ICU Pts with  Day 5 Predictions ", col 70, icu_day_5_pred_cnt_disp,
   row + 1, col 5, "# ICU Pts with Predicted ICU LOS <= 24*** ",
   col 70, icu_pred_less24_disp, row + 1,
   col 10, "*** does not require ICU LOS >= 4 hours", row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 2, "C.  ICU and Hospital Mortality ", col 75,
   "ICU ", col 90, "Hospital ",
   row + 1, col 10, "Actual ICU LOS >= 4 hours, ICU Discharged and Predictions ",
   row + 1, col 5, "# Patients with ICU Discharge ",
   col 70, los_more_4hrs_icu_pred_cnt_disp, col 90,
   pat_hosp_disch_pred_cnt_disp, row + 1, col 5,
   "Total # Patient Mortalities ", col 70, icu_mort_count_disp,
   col 90, hosp_mort_count_disp, row + 1,
   col 5, "Total # Patient Mortalities with Similar Predictions", col 70,
   sim_icu_mort_count_disp, col 90, sim_hosp_mort_count_disp,
   row + 1
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 5, "Actual Mortality ", col 70,
   icu_actual_mort_disp, col 90, hosp_actual_mort_disp,
   row + 1, col 5, "Total # Patient Mortalities ****",
   col 70, all_icu_mort_count_disp, col 90,
   all_hosp_mort_count_disp, row + 1, col 10,
   "***Includes Non-Preds, ICU_LOS < 4 and those with errors on Day1", row + 1, col 5,
   "National Predicted ", col 70, ntl_icu_pred_mort_disp,
   col 90, ntl_hosp_pred_mort_disp, row + 1,
   col 7, "Ratio = Actual/Pred Natl ", col 70,
   icu_ntl_ratio_disp, col 90, hosp_ntl_ratio_disp,
   row + 1, col 5, "Similar Predicted ",
   col 70, sim_icu_pred_mort_disp, col 90,
   sim_hosp_pred_mort_disp, row + 1, col 10,
   "(SMR: std Mortality Ratio) ", row + 1, col 7,
   "Ratio = Actual/Pred Similar ", col 70, icu_sim_ratio_disp,
   col 90, hosp_sim_ratio_disp, row + 1
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 5, "Low Risk Deaths (<=20% ) ", row + 1,
   col 10, "Actual #Pts Exceeded Nat'l Prediction ", col 70,
   icu_lowrisk_ntl_disp, col 90, hosp_lowrisk_ntl_disp,
   row + 1, col 10, "Actual #Pts Exceeded Sim'l Prediction ",
   col 70, icu_lowrisk_sim_disp, col 90,
   hosp_lowrisk_sim_disp
   IF (((row+ 10) > lastrow))
    BREAK
   ENDIF
   row + 2, col 2, "D. Therapeutic Intervention Scoring",
   row + 2, col 5, "# Patients 1st Day TISS Data Collected",
   col 90, arpt9_data->tiss_day_1_pat_cnt, row + 1,
   col 5, "Actual Avg 1st Day TISS", col 90,
   arpt9_data->tiss_day_1_avg, row + 1, col 5,
   "Predicted 1st Day Tiss National", col 90, arpt9_data->tiss_day_1_ntl_avg
   IF ((arpt9_data->tiss_day_1_ntl_avg > 0))
    ntl_tiss_ratio = (arpt9_data->tiss_day_1_avg/ arpt9_data->tiss_day_1_ntl_avg)
   ELSE
    ntl_tiss_ratio = 0.00
   ENDIF
   row + 1, col 5, "Ratio = Actual/Predicted Nat'l TISS",
   ntl_tiss_ratio_disp = fillstring(20," "), ntl_tiss_ratio_disp = concat(format(ntl_tiss_ratio,
     "##.##")," ",arpt9_data->tiss_day_1_ntl_p_value), col 99,
   ntl_tiss_ratio_disp, row + 1, col 5,
   "Predicted 1st Day TISS Similar", col 90, arpt9_data->tiss_day_1_sim_avg
   IF ((arpt9_data->tiss_day_1_ntl_avg > 0))
    sim_tiss_ratio = (arpt9_data->tiss_day_1_avg/ arpt9_data->tiss_day_1_sim_avg)
   ELSE
    sim_tiss_ratio = 0.00
   ENDIF
   row + 1, sim_tiss_ratio_disp = fillstring(20," "), sim_tiss_ratio_disp = concat(format(
     sim_tiss_ratio,"##.##")," ",arpt9_data->tiss_day_1_sim_p_value),
   col 5, "Ratio = Actual/Predicted Similar TISS", col 99,
   sim_tiss_ratio_disp, row + 2, col 5,
   "TISS Counts Including ICU LOS< 4 Hours, Non-Preds and Those with Day 1 Errors", row + 1, col 5,
   "# Patients 1st Day TISS Data Collected", col 90, arpt9_data->all_tiss_day_1_pat_cnt,
   row + 1, col 5, "Actual Avg 1st Day TISS",
   col 90, arpt9_data->all_tiss_day_1_avg, row + 1,
   row + 3, row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   array_size = size(adverse_event_record->event_cd,5)
   IF ((((row+ array_size)+ 8) > lastrow))
    BREAK
   ENDIF
   row + 1, col 1, "III. Events",
   row + 1, col 2, "A. Total number of Admissions (all patients, including readmissions):",
   tot_admit_disp = format(risk_record->total_admit,"####"), col 95, tot_admit_disp,
   row + 1, row + 2, col 25,
   "Total", col 35, "Total",
   col 50, "% Total", col 70,
   "Total", col 80, "Total",
   col 95, "% Total", row + 1,
   col 3, "Adverse Events", col 25,
   "Pts   /", col 35, "Admits    =",
   col 50, "Admits", col 70,
   "Occ   /", col 80, "Events   =",
   col 95, "Events", row + 1,
   col 1, line, row + 1
   FOR (x = 1 TO array_size)
     tot_pat_disp = format(adverse_event_record->event_cd[x].pat_count,"###"), ratio = ((
     adverse_event_record->event_cd[x].pat_count * 100.0)/ risk_record->total_admit), ratio_disp =
     format(ratio,"###.##%"),
     tot_event_occ_disp = format(adverse_event_record->event_cd[x].event_count,"###"), ratio2 = ((
     adverse_event_record->event_cd[x].event_count * 100.0)/ adverse_event_record->total_events),
     ratio2_disp = format(ratio2,"###.##%"),
     col 3, adverse_event_record->event_cd[x].event_name, col 25,
     tot_pat_disp, col 35, tot_admit_disp,
     col 50, ratio_disp, col 70,
     tot_event_occ_disp, tot_occ_disp = format(adverse_event_record->total_events,"###"), col 80,
     tot_occ_disp, col 95, ratio2_disp,
     row + 1
   ENDFOR
   col 1, line, row + 1,
   col 3, "Totals", total_pats_disp = format(adverse_event_record->total_pats,"###"),
   col 25, total_pats_disp, tot_occ_disp = format(adverse_event_record->total_pats,"###"),
   col 70, tot_occ_disp, array_size = size(therapy_event_record->event_cd,5)
   IF ((((row+ array_size)+ 6) > lastrow))
    BREAK
   ENDIF
   row + 3, col 2, "B. Number and Percentage of Therapeutic or Other Events",
   row + 1, col 3, "   Number of ICU patients (all patients, including readmissions):",
   tot_admit_disp = format(risk_record->total_admit,"####"), col 95, tot_admit_disp,
   row + 2, col 25, "Total",
   col 35, "Total", col 50,
   "% Total", col 70, "Total",
   col 80, "Total", col 95,
   "% Total", row + 1, col 3,
   "Event", col 25, "Pts   /",
   col 35, "Admits    =", col 50,
   "Admits", col 70, "Occ   /",
   col 80, "Events   =", col 95,
   "Events", row + 1, col 1,
   line, row + 1
   FOR (x = 1 TO array_size)
     tot_pat_disp = format(therapy_event_record->event_cd[x].pat_count,"###"), ratio = ((
     therapy_event_record->event_cd[x].pat_count * 100.0)/ risk_record->total_admit), ratio_disp =
     format(ratio,"###.##%"),
     tot_event_occ_disp = format(therapy_event_record->event_cd[x].event_count,"###"), ratio2 = ((
     therapy_event_record->event_cd[x].event_count * 100.0)/ therapy_event_record->total_events),
     ratio2_disp = format(ratio2,"###.##%"),
     col 3, therapy_event_record->event_cd[x].event_name, col 25,
     tot_pat_disp, col 35, tot_admit_disp,
     col 50, ratio_disp, col 70,
     tot_event_occ_disp, tot_occ_disp = format(therapy_event_record->total_events,"###"), col 80,
     tot_occ_disp, col 95, ratio2_disp,
     row + 1
   ENDFOR
   col 1, line, row + 1,
   col 3, "Totals", total_pats_disp = format(therapy_event_record->total_pats,"###"),
   col 25, total_pats_disp, tot_occ_disp = format(therapy_event_record->total_events,"###"),
   col 70, tot_occ_disp, row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 2, "C. Days on Ventilator", row + 1,
   col 3, "(Includes only patients with completed ICU outcomes who were", row + 1,
   col 3, "ventilated on ICU Day 1 and ICU LOS >= 4 hours)", row + 1,
   col 3, "Note - this counts consecutive vent days from ICU Day 1.  If a patient is", row + 1,
   col 3, "taken off a vent and restarted, all subsequent days are not counted.", row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 3, "Actual # Pts on Vent ICU Day 1 ", col 90,
   total_vent_pats, row + 1, col 3,
   "Actual Average Vents Days", col 90, actual_avg_vent_days,
   row + 1, col 3, "Actual Average Vent Days Truncated",
   col 90, actual_avg_trunc_vent_days, row + 1,
   col 3, "       (@10 CABG, @30 PRED)", row + 1,
   col 3, "Predicted Average Vent Days", col 90,
   pred_avg_vent_days, row + 1, col 3,
   "Ventilator Ratio = OB Truncated/PRED", col 90, vent_trunc_ratio,
   row + 2
   IF (((row+ 5) > lastrow))
    BREAK
   ENDIF
   col 3, "Vent Day Outliers", row + 1,
   col 3, "(# and % of patients receiving ventilator therapy", row + 1,
   col 3, "2 or more days than their individual prediction)", row + 1,
   col 5, "# Patient Outliers", col 90,
   total_vent_outliers, row + 1, col 5,
   "% Patients", vent_outlier_ratio_disp = format(vent_outlier_ratio,"##.##%"), col 98,
   vent_outlier_ratio_disp, row + 2, array_size = size(admit_source->source,5)
   IF ((((row+ array_size)+ 3) > lastrow))
    BREAK
   ENDIF
   col 2, "D. Admission Source", row + 1,
   col 25, "#Patients", col 40,
   "% of Total", col 64, "Avg ICU LOS",
   col 86, "Range - ICU LOS", row + 1,
   col 40, "ICU Admission", col 63,
   "Hours", col 73, "Days",
   col 85, "Hours", col 100,
   "Days", row + 1, col 1,
   line
   FOR (x = 1 TO array_size)
     row + 1, col 2, admit_source->source[x].name,
     col 25, admit_source->source[x].count, adm_ratio = 0.00,
     adm_ratio = (cnvtreal((admit_source->source[x].count * 100))/ cnvtreal(risk_record->total_admit)
     ), adm_src_ratio_disp = format(adm_ratio,"###.##%"), col 42,
     adm_src_ratio_disp, avg_hr_disp = format(admit_source->source[x].avg_hours,"######"), col 60,
     avg_hr_disp, avg_dy_disp = format(admit_source->source[x].avg_days,"#######"), col 70,
     avg_dy_disp, min_hr_disp = format(admit_source->source[x].min_hours,"#####"), col 80,
     min_hr_disp, col + 1, " - ",
     max_hr_disp = format(admit_source->source[x].max_hours,"#####"), col + 1, max_hr_disp,
     min_dy_disp = format(admit_source->source[x].min_days,"####"), col 95, min_dy_disp,
     col + 1, " - ", max_dy_disp = format(admit_source->source[x].max_days,"####"),
     col + 1, max_dy_disp
   ENDFOR
  FOOT PAGE
   page_disp = concat("--------- ",trim(cnvtstring(curpage),3)," ---------"), row lastrow,
   CALL center(page_disp,0,110)
  WITH dio = postscript, maxrow = 80, nocounter
 ;end select
END GO
