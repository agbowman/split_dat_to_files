CREATE PROGRAM dcp_arpt_16_mort_rpt:dba
 SET icu_pat_cnt = 0
 SET hosp_pat_cnt = 0
 SET stat = 0
 SET ra_cnt = 0
 SET icu_counter = 0
 SET hosp_counter = 0
 SET first_prediction_flag = 0
 SET last_name = "some junk name"
 SET last_service = 1234567890.0987321
 SET last_doc_id = 1234567890.09175643
 SET icu_enddate = 0.0
 SET icu_startdate = 0.0
 SET hosp_startdate = 0.0
 SET hosp_enddate = 0.0
 SET last_icu_id = 0.0
 SET last_hosp_id = 0.0
 SET p_result = 0
 SET array_size = 0
 SET null_date = cnvtdatetime("31-DEC-2100 00:00:00")
 SET dr_id_cd = meaning_code(320,"DOCNBR")
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
 RECORD death_record(
   1 icu_cnt = i4
   1 hosp_cnt = i4
   1 lr_cnt = i4
   1 death[*]
     2 ra_id = f8
     2 rad_id = f8
     2 first_visit = i2
     2 hosp_admit_dt_tm = dq8
     2 hosp_disch_dt_tm = dq8
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 hsp_death = f8
     2 icu_death = f8
     2 sim_hsp_death = f8
     2 sim_icu_death = f8
 )
 RECORD hosp_disease(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 tot_act_death_tot = f8
   1 tot_act_death_avg = f8
   1 tot_sim_act_death_tot = f8
   1 tot_sim_act_death_avg = f8
   1 tot_nat_death_tot = f8
   1 tot_nat_death_avg = f8
   1 tot_sim_death_tot = f8
   1 tot_sim_death_avg = f8
   1 tot_nat_out = f8
   1 tot_sim_out = f8
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
   1 type_tmp[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
 )
 RECORD icu_disease(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 tot_act_death_tot = f8
   1 tot_act_death_avg = f8
   1 tot_sim_act_death_tot = f8
   1 tot_sim_act_death_avg = f8
   1 tot_nat_death_tot = f8
   1 tot_nat_death_avg = f8
   1 tot_sim_death_tot = f8
   1 tot_sim_death_avg = f8
   1 tot_nat_out = f8
   1 tot_sim_out = f8
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
   1 type_tmp[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
 )
 RECORD hosp_service(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
   1 type_tmp[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
 )
 RECORD icu_service(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
   1 type_tmp[*]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
 )
 RECORD hosp_doctor(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 name = vc
     2 alias = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
   1 type_tmp[*]
     2 code = f8
     2 name = vc
     2 alias = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
     2 lr_death_tot = f8
     2 lr_death_avg = f8
 )
 RECORD icu_doctor(
   1 cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[*]
     2 code = f8
     2 alias = vc
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
   1 type_tmp[*]
     2 code = f8
     2 alias = vc
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
 )
 RECORD icu_risk(
   1 cnt = i4
   1 sim_cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[5]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
 )
 RECORD hosp_risk(
   1 cnt = i4
   1 sim_cnt = i4
   1 total_cnt = i4
   1 total_sim_cnt = i4
   1 nat_p_string = vc
   1 sim_p_string = vc
   1 type[5]
     2 code = f8
     2 name = vc
     2 count = f8
     2 sim_count = f8
     2 act_death_tot = f8
     2 act_death_avg = f8
     2 sim_act_death_tot = f8
     2 sim_act_death_avg = f8
     2 nat_death_tot = f8
     2 nat_death_avg = f8
     2 sim_death_tot = f8
     2 sim_death_avg = f8
     2 nat_out = f8
     2 sim_out = f8
     2 nat_p_string = vc
     2 sim_p_string = vc
 )
 SUBROUTINE calc_p_string(item_count,outcome_type,outcome,disease,service,doctor,risk)
   IF (outcome_type="ICU")
    SET factor = 30
   ELSE
    SET factor = 50
   ENDIF
   SET dratio = 0.0
   SELECT INTO "nl:"
    mdelta = (avg(least(datetimediff(death_record->death[d.seq].hosp_disch_dt_tm,death_record->death[
       d.seq].hosp_admit_dt_tm,1),factor)) - avg(rao.outcome_value)), sem = (stddev(least(
      datetimediff(death_record->death[d.seq].hosp_disch_dt_tm,death_record->death[d.seq].
       hosp_admit_dt_tm,1),factor)) - (((avg(rao.outcome_value)/ count(*))** 1)/ 2))
    FROM (dummyt d  WITH seq = death_record->icu_cnt),
     risk_adjustment_outcomes rao,
     risk_adjustment ra
    PLAN (d
     WHERE (((death_record->death[d.seq].hsp_death=risk)) OR ((death_record->death[d.seq].hsp_death=
     - (1)))) )
     JOIN (ra
     WHERE (ra.risk_adjustment_id=death_record->death[d.seq].ra_id)
      AND ((ra.disease_category_cd=disease) OR ((disease=- (1))))
      AND ((ra.med_service_cd=service) OR ((service=- (1))))
      AND ra.active_ind=1)
     JOIN (rao
     WHERE (rao.risk_adjustment_day_id=death_record->death[d.seq].rad_id)
      AND rao.equation_name=outcome
      AND cnvtdatetime(death_record->death[d.seq].hosp_disch_dt_tm) != cnvtdatetime(null_date)
      AND rao.active_ind=1)
    DETAIL
     dratio = abs((mdelta/ sem))
    WITH nocounter
   ;end select
   IF (item_count < 30)
    RETURN(4)
   ELSEIF (item_count BETWEEN 30 AND 59)
    IF (dratio < 2.042)
     RETURN(0)
    ELSEIF (dratio BETWEEN 2.042 AND 2.75)
     RETURN(1)
    ELSEIF (dratio >= 2.75)
     RETURN(2)
    ENDIF
   ELSEIF (item_count BETWEEN 60 AND 119)
    IF (dratio < 2.00)
     RETURN(0)
    ELSEIF (dratio BETWEEN 2.00 AND 2.66)
     RETURN(1)
    ELSEIF (dratio >= 2.66)
     RETURN(2)
    ENDIF
   ELSE
    IF (dratio < 1.965)
     RETURN(0)
    ELSEIF (dratio BETWEEN 1.965 AND 2.576)
     RETURN(1)
    ELSEIF (dratio >= 2.576)
     RETURN(2)
    ENDIF
   ENDIF
 END ;Subroutine
 SET num = 0
 SET pos = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao,
   encounter e
  PLAN (ra
   WHERE expand(num,1,risk_record->total_admit,ra.risk_adjustment_id,risk_record->risk[num].risk_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND rao.active_ind=1
    AND rao.equation_name="NTL_1ST_TISS")
  ORDER BY ra.encntr_id
  HEAD ra.encntr_id
   stat = nullind(e.disch_dt_tm)
   IF (stat=0)
    hosp_pat_cnt = (hosp_pat_cnt+ 1)
   ENDIF
  DETAIL
   IF (ra.icu_disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00"))
    icu_pat_cnt = (icu_pat_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao,
   encounter e,
   person p
  PLAN (ra
   WHERE expand(num,1,risk_record->total_admit,ra.risk_adjustment_id,risk_record->risk[num].risk_id)
    AND ra.icu_disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND ((rao.equation_name="NTL_1ST_TISS") OR (((rao.equation_name="NTL_HSP_DEATH") OR (((rao
   .equation_name="NTL_ICU_DEATH") OR (((rao.equation_name="SIM_HSP_DEATH") OR (rao.equation_name=
   "SIM_ICU_DEATH")) )) )) ))
    AND rao.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  ORDER BY ra.encntr_id, cnvtdatetime(ra.icu_admit_dt_tm)
  HEAD REPORT
   nate1 = 0, nate2 = 0, icu_counter = 0,
   hosp_counter = 0, death_record->lr_cnt = 0, los = 0.0
  HEAD ra.encntr_id
   first_visit = 0
  HEAD ra.icu_admit_dt_tm
   first_prediction_flag = 1
  DETAIL
   first_visit = (first_visit+ 1), los = datetimediff(ra.icu_disch_dt_tm,ra.icu_admit_dt_tm,3),
   CALL echo(build("rao.equation_name = ",rao.equation_name)),
   CALL echo(build("rao.outcome_value = ",rao.outcome_value))
   IF (los >= 4.0)
    IF (first_prediction_flag=1)
     icu_counter = (icu_counter+ 1), stat = alterlist(death_record->death,icu_counter), death_record
     ->icu_cnt = icu_counter,
     death_record->death[icu_counter].ra_id = ra.risk_adjustment_id
     IF (first_visit=1
      AND e.disch_dt_tm IS NOT null)
      death_record->death[icu_counter].first_visit = 1, nate2 = (nate2+ 1), hosp_counter = (
      hosp_counter+ 1)
     ENDIF
     death_record->death[icu_counter].rad_id = rad.risk_adjustment_day_id, death_record->death[
     icu_counter].hosp_admit_dt_tm = ra.hosp_admit_dt_tm, death_record->death[icu_counter].
     hosp_disch_dt_tm = e.disch_dt_tm,
     death_record->death[icu_counter].icu_admit_dt_tm = ra.icu_admit_dt_tm, death_record->death[
     icu_counter].icu_disch_dt_tm = ra.icu_disch_dt_tm, first_prediction_flag = 0
    ENDIF
    IF (rao.equation_name="NTL_HSP_DEATH"
     AND rao.outcome_value <= 0.2)
     IF (ra.diedinicu_ind=1)
      death_record->lr_cnt = (death_record->lr_cnt+ 1)
     ELSEIF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
      death_record->lr_cnt = (death_record->lr_cnt+ 1)
     ELSEIF (p.deceased_dt_tm > e.reg_dt_tm
      AND p.deceased_dt_tm <= e.disch_dt_tm)
      death_record->lr_cnt = (death_record->lr_cnt+ 1)
     ENDIF
    ENDIF
    CASE (rao.equation_name)
     OF "NTL_HSP_DEATH":
      IF (rao.outcome_value > 0.8)
       death_record->death[icu_counter].hsp_death = 5
      ELSEIF (rao.outcome_value > 0.6)
       death_record->death[icu_counter].hsp_death = 4
      ELSEIF (rao.outcome_value > 0.4)
       death_record->death[icu_counter].hsp_death = 3
      ELSEIF (rao.outcome_value > 0.2)
       death_record->death[icu_counter].hsp_death = 2
      ELSEIF (rao.outcome_value >= 0.0)
       death_record->death[icu_counter].hsp_death = 1
      ENDIF
     OF "NTL_ICU_DEATH":
      IF (rao.outcome_value > 0.8)
       death_record->death[icu_counter].icu_death = 5
      ELSEIF (rao.outcome_value > 0.6)
       death_record->death[icu_counter].icu_death = 4
      ELSEIF (rao.outcome_value > 0.4)
       death_record->death[icu_counter].icu_death = 3
      ELSEIF (rao.outcome_value > 0.2)
       death_record->death[icu_counter].icu_death = 2
      ELSEIF (rao.outcome_value >= 0.0)
       death_record->death[icu_counter].icu_death = 1
      ENDIF
     OF "SIM_HSP_DEATH":
      IF (rao.outcome_value > 0.8)
       death_record->death[icu_counter].sim_hsp_death = 5
      ELSEIF (rao.outcome_value > 0.6)
       death_record->death[icu_counter].sim_hsp_death = 4
      ELSEIF (rao.outcome_value > 0.4)
       death_record->death[icu_counter].sim_hsp_death = 3
      ELSEIF (rao.outcome_value > 0.2)
       death_record->death[icu_counter].sim_hsp_death = 2
      ELSEIF (rao.outcome_value >= 0.0)
       death_record->death[icu_counter].sim_hsp_death = 1
      ENDIF
     OF "SIM_ICU_DEATH":
      IF (rao.outcome_value > 0.8)
       death_record->death[icu_counter].sim_icu_death = 5
      ELSEIF (rao.outcome_value > 0.6)
       death_record->death[icu_counter].sim_icu_death = 4
      ELSEIF (rao.outcome_value > 0.4)
       death_record->death[icu_counter].sim_icu_death = 3
      ELSEIF (rao.outcome_value > 0.2)
       death_record->death[icu_counter].sim_icu_death = 2
      ELSEIF (rao.outcome_value >= 0.0)
       death_record->death[icu_counter].sim_icu_death = 1
      ENDIF
    ENDCASE
   ENDIF
  FOOT REPORT
   death_record->hosp_cnt = hosp_counter
  WITH nocounter
 ;end select
 SET last_icu_service = 0123456789.0123456789
 SET last_hosp_service = 01234567890.09123456778
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao,
   risk_adjustment ra,
   risk_adjustment_day rad,
   encounter e,
   person p
  PLAN (ra
   WHERE expand(num,1,death_record->icu_cnt,ra.risk_adjustment_id,death_record->death[num].ra_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.active_ind=1
    AND rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND ((rao.equation_name="NTL_ICU_DEATH") OR (((rao.equation_name="SIM_ICU_DEATH") OR (((rao
   .equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )) )) )
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  ORDER BY ra.med_service_cd, ra.risk_adjustment_id
  HEAD REPORT
   icu_counter = 0, hosp_counter = 0
  DETAIL
   pos = locateval(num,1,death_record->icu_cnt,rad.risk_adjustment_day_id,death_record->death[num].
    rad_id)
   IF (((rao.equation_name="NTL_ICU_DEATH") OR (rao.equation_name="SIM_ICU_DEATH")) )
    IF (last_icu_service != ra.med_service_cd)
     last_icu_service = ra.med_service_cd, icu_counter = (icu_counter+ 1), stat = alterlist(
      icu_service->type,icu_counter),
     icu_service->cnt = icu_counter, icu_service->type[icu_counter].code = ra.med_service_cd,
     icu_service->type[icu_counter].name = substring(1,20,uar_get_code_description(ra.med_service_cd)
      ),
     icu_service->type[icu_counter].count = 1, icu_service->type[icu_counter].sim_count = 0,
     last_icu_id = ra.risk_adjustment_id
    ENDIF
    IF (last_icu_id != ra.risk_adjustment_id)
     icu_service->type[icu_counter].count = (icu_service->type[icu_counter].count+ 1), last_icu_id =
     ra.risk_adjustment_id
    ENDIF
    IF (rao.equation_name="SIM_ICU_DEATH")
     icu_service->type[icu_counter].sim_count = (icu_service->type[icu_counter].sim_count+ 1)
    ENDIF
    IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
     icu_enddate = sysdate
    ELSE
     icu_enddate = ra.icu_disch_dt_tm
    ENDIF
    icu_startdate = ra.icu_admit_dt_tm
   ENDIF
   IF (((rao.equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )
    IF ((death_record->death[pos].first_visit=1))
     IF (last_hosp_service != ra.med_service_cd)
      last_hosp_service = ra.med_service_cd, hosp_counter = (hosp_counter+ 1), stat = alterlist(
       hosp_service->type,hosp_counter),
      hosp_service->cnt = hosp_counter, hosp_service->type[hosp_counter].code = ra.med_service_cd,
      hosp_service->type[hosp_counter].name = substring(1,20,uar_get_code_description(ra
        .med_service_cd)),
      hosp_service->type[hosp_counter].count = 1, hosp_service->type[hosp_counter].sim_count = 0,
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (last_hosp_id != ra.risk_adjustment_id)
      hosp_service->type[hosp_counter].count = (hosp_service->type[hosp_counter].count+ 1),
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (rao.equation_name="SIM_HSP_DEATH")
      hosp_service->type[hosp_counter].sim_count = (hosp_service->type[hosp_counter].sim_count+ 1)
     ENDIF
     IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
      hosp_enddate = (sysdate+ 1000)
     ELSE
      hosp_enddate = ra.icu_disch_dt_tm
     ENDIF
     hosp_startdate = ra.hosp_admit_dt_tm
    ENDIF
   ENDIF
   CASE (rao.equation_name)
    OF "NTL_ICU_DEATH":
     icu_service->total_cnt = (icu_service->total_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_service->type[icu_counter].act_death_tot = (icu_service->type[icu_counter].act_death_tot+ 1
      )
     ENDIF
     ,icu_service->type[icu_counter].act_death_avg = (icu_service->type[icu_counter].act_death_tot/
     icu_service->type[icu_counter].count),icu_service->type[icu_counter].nat_death_tot = (
     icu_service->type[icu_counter].nat_death_tot+ rao.outcome_value),icu_service->type[icu_counter].
     nat_death_avg = (icu_service->type[icu_counter].nat_death_tot/ icu_service->type[icu_counter].
     count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_service->type[icu_counter].nat_out = (icu_service->type[icu_counter].nat_out+ 1)
     ENDIF
    OF "SIM_ICU_DEATH":
     icu_service->total_sim_cnt = (icu_service->total_sim_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_service->type[icu_counter].sim_act_death_tot = (icu_service->type[icu_counter].
      sim_act_death_tot+ 1)
     ENDIF
     ,icu_service->type[icu_counter].sim_death_tot = (icu_service->type[icu_counter].sim_death_tot+
     rao.outcome_value),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_service->type[icu_counter].sim_out = (icu_service->type[icu_counter].sim_out+ 1)
     ENDIF
    OF "NTL_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_service->total_cnt = (hosp_service->total_cnt+ 1)
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_service->type[hosp_counter].act_death_tot = (hosp_service->type[hosp_counter].
       act_death_tot+ 1)
       IF (rao.outcome_value <= 0.2)
        hosp_service->type[hosp_counter].lr_death_tot = (hosp_service->type[hosp_counter].
        lr_death_tot+ 1)
       ENDIF
      ENDIF
      hosp_service->type[hosp_counter].act_death_avg = (hosp_service->type[hosp_counter].
      act_death_tot/ hosp_service->type[hosp_counter].count), hosp_service->type[hosp_counter].
      nat_death_tot = (hosp_service->type[hosp_counter].nat_death_tot+ rao.outcome_value),
      hosp_service->type[hosp_counter].nat_death_avg = (hosp_service->type[hosp_counter].
      nat_death_tot/ hosp_service->type[hosp_counter].count)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_service->type[hosp_counter].nat_out = (hosp_service->type[hosp_counter].nat_out+ 1)
      ENDIF
     ENDIF
    OF "SIM_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_service->total_sim_cnt = (hosp_service->total_sim_cnt+ 1)
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_service->type[hosp_counter].sim_act_death_tot = (hosp_service->type[hosp_counter].
       sim_act_death_tot+ 1)
      ENDIF
      hosp_service->type[hosp_counter].sim_death_tot = (hosp_service->type[hosp_counter].
      sim_death_tot+ rao.outcome_value)
     ENDIF
   ENDCASE
  FOOT REPORT
   icu_cnt = icu_counter, hosp_cnt = hosp_counter
   FOR (icu_counter = 1 TO icu_cnt)
    icu_service->type[icu_counter].sim_act_death_avg = (icu_service->type[icu_counter].
    sim_act_death_tot/ icu_service->type[icu_counter].sim_count),icu_service->type[icu_counter].
    sim_death_avg = (icu_service->type[icu_counter].sim_death_tot/ icu_service->type[icu_counter].
    sim_count)
   ENDFOR
   FOR (hosp_counter = 1 TO hosp_cnt)
    hosp_service->type[hosp_counter].sim_act_death_avg = (hosp_service->type[hosp_counter].
    sim_act_death_tot/ hosp_service->type[hosp_counter].sim_count),hosp_service->type[hosp_counter].
    sim_death_avg = (hosp_service->type[hosp_counter].sim_death_tot/ hosp_service->type[hosp_counter]
    .sim_count)
   ENDFOR
  WITH nocounter
 ;end select
 SET last_icu_disease = 0123456789.0123456789
 SET last_hosp_disease = 01234567890.09123456778
 SET last_hosp_ra_id = 0.0
 SET last_icu_ra_id = 0.0
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao,
   risk_adjustment ra,
   risk_adjustment_day rad,
   encounter e,
   person p
  PLAN (ra
   WHERE expand(num,1,death_record->icu_cnt,ra.risk_adjustment_id,death_record->death[num].ra_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND ((rao.equation_name="NTL_ICU_DEATH") OR (((rao.equation_name="SIM_ICU_DEATH") OR (((rao
   .equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )) ))
    AND rao.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  ORDER BY ra.disease_category_cd, ra.risk_adjustment_id
  HEAD REPORT
   icu_counter = 0, hosp_counter = 0
  DETAIL
   pos = locateval(num,1,death_record->icu_cnt,rad.risk_adjustment_day_id,death_record->death[num].
    rad_id)
   IF (((rao.equation_name="NTL_ICU_DEATH") OR (rao.equation_name="SIM_ICU_DEATH")) )
    IF (last_icu_disease != ra.disease_category_cd)
     last_icu_disease = ra.disease_category_cd, last_icu_ra_id = ra.risk_adjustment_id, icu_counter
      = (icu_counter+ 1),
     stat = alterlist(icu_disease->type,icu_counter), icu_disease->cnt = icu_counter, icu_disease->
     type[icu_counter].code = ra.disease_category_cd,
     icu_disease->type[icu_counter].name = substring(1,20,uar_get_code_description(ra
       .disease_category_cd)), icu_disease->type[icu_counter].count = 1, icu_disease->type[
     icu_counter].sim_count = 0,
     last_icu_id = ra.risk_adjustment_id
    ENDIF
    IF (last_icu_id != ra.risk_adjustment_id)
     icu_disease->type[icu_counter].count = (icu_disease->type[icu_counter].count+ 1), last_icu_id =
     ra.risk_adjustment_id
    ENDIF
    IF (rao.equation_name="SIM_ICU_DEATH")
     icu_disease->type[icu_counter].sim_count = (icu_disease->type[icu_counter].sim_count+ 1)
    ENDIF
    IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
     icu_enddate = sysdate
    ELSE
     icu_enddate = ra.icu_disch_dt_tm
    ENDIF
    icu_startdate = ra.icu_admit_dt_tm
   ENDIF
   IF (((rao.equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )
    IF ((death_record->death[pos].first_visit=1))
     IF (last_hosp_disease != ra.disease_category_cd)
      last_hosp_disease = ra.disease_category_cd, last_hosp_ra_id = ra.risk_adjustment_id,
      hosp_counter = (hosp_counter+ 1),
      stat = alterlist(hosp_disease->type,hosp_counter), hosp_disease->cnt = hosp_counter,
      hosp_disease->type[hosp_counter].code = ra.disease_category_cd,
      hosp_disease->type[hosp_counter].name = substring(1,20,uar_get_code_description(ra
        .disease_category_cd)), hosp_disease->type[hosp_counter].count = 1, hosp_disease->type[
      hosp_counter].sim_count = 0,
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (last_hosp_id != ra.risk_adjustment_id)
      hosp_disease->type[hosp_counter].count = (hosp_disease->type[hosp_counter].count+ 1),
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (rao.equation_name="SIM_HSP_DEATH")
      hosp_disease->type[hosp_counter].sim_count = (hosp_disease->type[hosp_counter].sim_count+ 1)
     ENDIF
     IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
      hosp_enddate = (sysdate+ 1000)
     ELSE
      hosp_enddate = ra.icu_disch_dt_tm
     ENDIF
     hosp_startdate = ra.hosp_admit_dt_tm
    ENDIF
   ENDIF
   CASE (rao.equation_name)
    OF "NTL_ICU_DEATH":
     icu_disease->total_cnt = (icu_disease->total_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_disease->tot_act_death_tot = (icu_disease->tot_act_death_tot+ 1)
     ENDIF
     ,icu_disease->tot_nat_death_tot = (icu_disease->tot_nat_death_tot+ rao.outcome_value),
     icu_disease->tot_nat_death_avg = (icu_disease->tot_nat_death_tot/ icu_disease->total_cnt),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_disease->tot_nat_out = (icu_disease->tot_nat_out+ 1)
     ENDIF
     ,
     IF (ra.diedinicu_ind=1)
      icu_disease->type[icu_counter].act_death_tot = (icu_disease->type[icu_counter].act_death_tot+ 1
      )
     ENDIF
     ,icu_disease->type[icu_counter].act_death_avg = (icu_disease->type[icu_counter].act_death_tot/
     icu_disease->type[icu_counter].count),icu_disease->type[icu_counter].nat_death_tot = (
     icu_disease->type[icu_counter].nat_death_tot+ rao.outcome_value),icu_disease->type[icu_counter].
     nat_death_avg = (icu_disease->type[icu_counter].nat_death_tot/ icu_disease->type[icu_counter].
     count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_disease->type[icu_counter].nat_out = (icu_disease->type[icu_counter].nat_out+ 1)
     ENDIF
    OF "SIM_ICU_DEATH":
     icu_disease->total_sim_cnt = (icu_disease->total_sim_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_disease->tot_sim_act_death_tot = (icu_disease->tot_sim_act_death_tot+ 1), icu_disease->
      type[icu_counter].sim_act_death_tot = (icu_disease->type[icu_counter].sim_act_death_tot+ 1)
     ENDIF
     ,icu_disease->tot_sim_death_tot = (icu_disease->tot_sim_death_tot+ rao.outcome_value),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_disease->tot_sim_out = (icu_disease->tot_sim_out+ 1)
     ENDIF
     ,icu_disease->type[icu_counter].sim_death_tot = (icu_disease->type[icu_counter].sim_death_tot+
     rao.outcome_value),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_disease->type[icu_counter].sim_out = (icu_disease->type[icu_counter].sim_out+ 1)
     ENDIF
    OF "NTL_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_disease->total_cnt = (hosp_disease->total_cnt+ 1), hosp_disease->tot_act_death_avg = (
      hosp_disease->tot_act_death_tot/ hosp_disease->total_cnt), hosp_disease->tot_nat_death_tot = (
      hosp_disease->tot_nat_death_tot+ rao.outcome_value),
      hosp_disease->tot_nat_death_avg = (hosp_disease->tot_nat_death_tot/ hosp_disease->total_cnt)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_disease->tot_nat_out = (hosp_disease->tot_nat_out+ 1)
      ENDIF
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_disease->tot_act_death_tot = (hosp_disease->tot_act_death_tot+ 1), hosp_disease->type[
       hosp_counter].act_death_tot = (hosp_disease->type[hosp_counter].act_death_tot+ 1)
       IF (rao.outcome_value <= 0.2)
        hosp_disease->type[hosp_counter].lr_death_tot = (hosp_disease->type[hosp_counter].
        lr_death_tot+ 1)
       ENDIF
      ENDIF
      hosp_disease->type[hosp_counter].act_death_avg = (hosp_disease->type[hosp_counter].
      act_death_tot/ hosp_disease->type[hosp_counter].count), hosp_disease->type[hosp_counter].
      nat_death_tot = (hosp_disease->type[hosp_counter].nat_death_tot+ rao.outcome_value),
      hosp_disease->type[hosp_counter].nat_death_avg = (hosp_disease->type[hosp_counter].
      nat_death_tot/ hosp_disease->type[hosp_counter].count)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_disease->type[hosp_counter].nat_out = (hosp_disease->type[hosp_counter].nat_out+ 1)
      ENDIF
     ENDIF
    OF "SIM_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_disease->total_sim_cnt = (hosp_disease->total_sim_cnt+ 1)
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_disease->tot_sim_act_death_tot = (hosp_disease->tot_sim_act_death_tot+ 1), hosp_disease->
       type[hosp_counter].sim_act_death_tot = (hosp_disease->type[hosp_counter].sim_act_death_tot+ 1)
      ENDIF
      hosp_disease->tot_sim_death_tot = (hosp_disease->tot_sim_death_tot+ rao.outcome_value)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_disease->tot_sim_out = (hosp_disease->tot_sim_out+ 1)
      ENDIF
      hosp_disease->type[hosp_counter].sim_death_tot = (hosp_disease->type[hosp_counter].
      sim_death_tot+ rao.outcome_value)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_disease->type[hosp_counter].sim_out = (hosp_disease->type[hosp_counter].sim_out+ 1)
      ENDIF
     ENDIF
   ENDCASE
  FOOT REPORT
   icu_disease->tot_act_death_avg = (icu_disease->tot_act_death_tot/ icu_disease->total_cnt),
   hosp_disease->tot_act_death_avg = (hosp_disease->tot_act_death_tot/ hosp_disease->total_cnt),
   icu_disease->tot_sim_act_death_avg = (icu_disease->tot_sim_act_death_tot/ icu_disease->
   total_sim_cnt),
   hosp_disease->tot_sim_act_death_avg = (hosp_disease->tot_sim_act_death_tot/ hosp_disease->
   total_sim_cnt), hosp_disease->tot_sim_death_avg = (hosp_disease->tot_sim_death_tot/ hosp_disease->
   total_sim_cnt), hosp_disease->tot_nat_death_avg = (hosp_disease->tot_nat_death_tot/ hosp_disease->
   total_cnt),
   icu_disease->tot_sim_death_avg = (icu_disease->tot_sim_death_tot/ icu_disease->total_sim_cnt),
   icu_disease->tot_nat_death_avg = (icu_disease->tot_nat_death_tot/ icu_disease->total_cnt), icu_cnt
    = icu_counter,
   hosp_cnt = hosp_counter
   FOR (icu_counter = 1 TO icu_cnt)
    icu_disease->type[icu_counter].sim_act_death_avg = (icu_disease->type[icu_counter].
    sim_act_death_tot/ icu_disease->type[icu_counter].sim_count),icu_disease->type[icu_counter].
    sim_death_avg = (icu_disease->type[icu_counter].sim_death_tot/ icu_disease->type[icu_counter].
    sim_count)
   ENDFOR
   FOR (hosp_counter = 1 TO hosp_cnt)
    hosp_disease->type[hosp_counter].sim_act_death_avg = (hosp_disease->type[hosp_counter].
    sim_act_death_tot/ hosp_disease->type[hosp_counter].sim_count),hosp_disease->type[hosp_counter].
    sim_death_avg = (hosp_disease->type[hosp_counter].sim_death_tot/ hosp_disease->type[hosp_counter]
    .sim_count)
   ENDFOR
  WITH nocounter
 ;end select
 SET last_icu_doctor = 0123456789.0123456789
 SET last_hosp_doctor = 01234567890.09123456778
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao,
   risk_adjustment_day rad,
   risk_adjustment ra,
   encounter e,
   person p
  PLAN (ra
   WHERE expand(num,1,death_record->icu_cnt,ra.risk_adjustment_id,death_record->death[num].ra_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND ((rao.equation_name="NTL_ICU_DEATH") OR (((rao.equation_name="SIM_ICU_DEATH") OR (((rao
   .equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )) ))
    AND rao.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  ORDER BY ra.adm_doc_id, ra.risk_adjustment_id
  HEAD REPORT
   icu_counter = 0, hosp_counter = 0
  DETAIL
   pos = locateval(num,1,death_record->icu_cnt,rad.risk_adjustment_day_id,death_record->death[num].
    rad_id)
   IF (((rao.equation_name="NTL_ICU_DEATH") OR (rao.equation_name="SIM_ICU_DEATH")) )
    IF (last_icu_doctor != ra.adm_doc_id)
     last_icu_doctor = ra.adm_doc_id, icu_counter = (icu_counter+ 1), stat = alterlist(icu_doctor->
      type,icu_counter),
     icu_doctor->cnt = icu_counter, icu_doctor->type[icu_counter].code = ra.adm_doc_id, icu_doctor->
     type[icu_counter].alias = concat("ID-",cnvtstring(ra.adm_doc_id)),
     icu_doctor->type[icu_counter].count = 1, icu_doctor->type[icu_counter].sim_count = 0,
     last_icu_id = ra.risk_adjustment_id
    ENDIF
    IF (last_icu_id != ra.risk_adjustment_id)
     icu_doctor->type[icu_counter].count = (icu_doctor->type[icu_counter].count+ 1), last_icu_id = ra
     .risk_adjustment_id
    ENDIF
    IF (rao.equation_name="SIM_ICU_DEATH")
     icu_doctor->type[icu_counter].sim_count = (icu_doctor->type[icu_counter].sim_count+ 1)
    ENDIF
    IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
     icu_enddate = sysdate
    ELSE
     icu_enddate = ra.icu_disch_dt_tm
    ENDIF
    icu_startdate = ra.icu_admit_dt_tm
   ENDIF
   IF (((rao.equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )
    IF ((death_record->death[pos].first_visit=1))
     IF (last_hosp_doctor != ra.adm_doc_id)
      last_hosp_doctor = ra.adm_doc_id, hosp_counter = (hosp_counter+ 1), stat = alterlist(
       hosp_doctor->type,hosp_counter),
      hosp_doctor->cnt = hosp_counter, hosp_doctor->type[hosp_counter].code = ra.adm_doc_id,
      hosp_doctor->type[hosp_counter].alias = concat("ID-",cnvtstring(ra.adm_doc_id)),
      hosp_doctor->type[hosp_counter].count = 1, hosp_doctor->type[hosp_counter].sim_count = 0,
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (last_hosp_id != ra.risk_adjustment_id)
      hosp_doctor->type[hosp_counter].count = (hosp_doctor->type[hosp_counter].count+ 1),
      last_hosp_id = ra.risk_adjustment_id
     ENDIF
     IF (rao.equation_name="SIM_HSP_DEATH")
      hosp_doctor->type[hosp_counter].sim_count = (hosp_doctor->type[hosp_counter].sim_count+ 1)
     ENDIF
     IF (((ra.icu_disch_dt_tm=0.0) OR (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
      hosp_enddate = (sysdate+ 1000)
     ELSE
      hosp_enddate = ra.icu_disch_dt_tm
     ENDIF
     hosp_startdate = ra.hosp_admit_dt_tm
    ENDIF
   ENDIF
   CASE (rao.equation_name)
    OF "NTL_ICU_DEATH":
     icu_doctor->total_cnt = (icu_doctor->total_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_doctor->type[icu_counter].act_death_tot = (icu_doctor->type[icu_counter].act_death_tot+ 1)
     ENDIF
     ,icu_doctor->type[icu_counter].act_death_avg = (icu_doctor->type[icu_counter].act_death_tot/
     icu_doctor->type[icu_counter].count),icu_doctor->type[icu_counter].nat_death_tot = (icu_doctor->
     type[icu_counter].nat_death_tot+ rao.outcome_value),icu_doctor->type[icu_counter].nat_death_avg
      = (icu_doctor->type[icu_counter].nat_death_tot/ icu_doctor->type[icu_counter].count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_doctor->type[icu_counter].nat_out = (icu_doctor->type[icu_counter].nat_out+ 1)
     ENDIF
    OF "SIM_ICU_DEATH":
     icu_doctor->total_sim_cnt = (icu_doctor->total_sim_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_doctor->type[icu_counter].sim_act_death_tot = (icu_doctor->type[icu_counter].
      sim_act_death_tot+ 1)
     ENDIF
     ,icu_doctor->type[icu_counter].sim_death_tot = (icu_doctor->type[icu_counter].sim_death_tot+ rao
     .outcome_value),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_doctor->type[icu_counter].sim_out = (icu_doctor->type[icu_counter].sim_out+ 1)
     ENDIF
    OF "NTL_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_doctor->total_cnt = (hosp_doctor->total_cnt+ 1)
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_doctor->type[hosp_counter].act_death_tot = (hosp_doctor->type[hosp_counter].act_death_tot
       + 1)
       IF (rao.outcome_value <= 0.2)
        hosp_doctor->type[hosp_counter].lr_death_tot = (hosp_doctor->type[hosp_counter].lr_death_tot
        + 1)
       ENDIF
      ENDIF
      hosp_doctor->type[hosp_counter].act_death_avg = (hosp_doctor->type[hosp_counter].act_death_tot
      / hosp_doctor->type[hosp_counter].count), hosp_doctor->type[hosp_counter].nat_death_tot = (
      hosp_doctor->type[hosp_counter].nat_death_tot+ rao.outcome_value), hosp_doctor->type[
      hosp_counter].nat_death_avg = (hosp_doctor->type[hosp_counter].nat_death_tot/ hosp_doctor->
      type[hosp_counter].count)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_doctor->type[hosp_counter].nat_out = (hosp_doctor->type[hosp_counter].nat_out+ 1)
      ENDIF
     ENDIF
    OF "SIM_HSP_DEATH":
     IF ((death_record->death[pos].first_visit=1))
      hosp_doctor->total_sim_cnt = (hosp_doctor->total_sim_cnt+ 1)
      IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
      .deceased_dt_tm > e.reg_dt_tm
       AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
       hosp_doctor->type[hosp_counter].sim_act_death_tot = (hosp_doctor->type[hosp_counter].
       sim_act_death_tot+ 1)
      ENDIF
      hosp_doctor->type[hosp_counter].sim_death_tot = (hosp_doctor->type[hosp_counter].sim_death_tot
      + rao.outcome_value)
      IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
       - 2) >= 0))
       hosp_doctor->type[hosp_counter].sim_out = (hosp_doctor->type[hosp_counter].sim_out+ 1)
      ENDIF
     ENDIF
   ENDCASE
  FOOT REPORT
   icu_cnt = icu_counter, hosp_cnt = hosp_counter
   FOR (icu_counter = 1 TO icu_cnt)
    icu_doctor->type[icu_counter].sim_act_death_avg = (icu_doctor->type[icu_counter].
    sim_act_death_tot/ icu_doctor->type[icu_counter].sim_count),icu_doctor->type[icu_counter].
    sim_death_avg = (icu_doctor->type[icu_counter].sim_death_tot/ icu_doctor->type[icu_counter].
    sim_count)
   ENDFOR
   FOR (hosp_counter = 1 TO hosp_cnt)
    hosp_doctor->type[hosp_counter].sim_act_death_avg = (hosp_doctor->type[hosp_counter].
    sim_act_death_tot/ hosp_doctor->type[hosp_counter].sim_count),hosp_doctor->type[hosp_counter].
    sim_death_avg = (hosp_doctor->type[hosp_counter].sim_death_tot/ hosp_doctor->type[hosp_counter].
    sim_count)
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_alias pa
  WHERE expand(num,1,icu_doctor->cnt,pa.person_id,icu_doctor->type[num].code)
   AND pa.prsnl_alias_type_cd=dr_id_cd
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   pos = locateval(num,1,icu_doctor->cnt,pa.person_id,icu_doctor->type[num].code), icu_doctor->type[
   pos].alias = pa.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_alias pa
  WHERE expand(num,1,hosp_doctor->cnt,pa.person_id,hosp_doctor->type[num].code)
   AND pa.prsnl_alias_type_cd=dr_id_cd
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   pos = locateval(num,1,hosp_doctor->cnt,pa.person_id,hosp_doctor->type[num].code), hosp_doctor->
   type[pos].alias = pa.alias
  WITH nocounter
 ;end select
 SET last_icu_disease = 0123456789.0123456789
 SET last_hosp_disease = 01234567890.09123456778
 SET last_icu_ra_id = 0.0
 SET last_hosp_ra_id = 0.0
 SET pos = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao,
   risk_adjustment ra,
   (dummyt d  WITH seq = death_record->icu_cnt),
   encounter e,
   person p
  PLAN (d)
   JOIN (ra
   WHERE (ra.risk_adjustment_id=death_record->death[d.seq].ra_id)
    AND ra.active_ind=1)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=death_record->death[d.seq].rad_id)
    AND ((rao.equation_name="NTL_ICU_DEATH") OR (((rao.equation_name="SIM_ICU_DEATH") OR (((rao
   .equation_name="NTL_HSP_DEATH") OR (rao.equation_name="SIM_HSP_DEATH")) )) ))
    AND rao.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  ORDER BY ra.disease_category_cd, ra.risk_adjustment_id
  HEAD REPORT
   icu_counter = 0, hosp_counter = 0, icu_risk->type[1].name = " 0 - 20%",
   icu_risk->type[2].name = "20 - 40%", icu_risk->type[3].name = "40 - 60%", icu_risk->type[4].name
    = "60 - 80%",
   icu_risk->type[5].name = "80 - 100%"
  DETAIL
   pos = locateval(num,1,death_record->icu_cnt,ra.risk_adjustment_id,death_record->death[num].ra_id)
   IF (rao.equation_name="NTL_ICU_DEATH")
    icu_counter = death_record->death[pos].icu_death
    IF (((last_icu_disease != ra.disease_category_cd) OR (last_icu_ra_id != ra.risk_adjustment_id)) )
     last_icu_disease = ra.disease_category_cd, last_icu_ra_id = ra.risk_adjustment_id, icu_risk->cnt
      = icu_counter,
     icu_risk->type[icu_counter].count = (icu_risk->type[icu_counter].count+ 1)
    ENDIF
   ENDIF
   IF (rao.equation_name="SIM_ICU_DEATH")
    icu_counter = death_record->death[pos].sim_icu_death, icu_risk->sim_cnt = icu_counter, icu_risk->
    type[icu_counter].sim_count = (icu_risk->type[icu_counter].sim_count+ 1)
   ENDIF
   IF (rao.equation_name="NTL_HSP_DEATH")
    hosp_counter = death_record->death[pos].hsp_death
    IF (((last_hosp_disease != ra.disease_category_cd) OR (last_hosp_ra_id != ra.risk_adjustment_id
    )) )
     last_hosp_disease = ra.disease_category_cd, last_hosp_ra_id = ra.risk_adjustment_id, hosp_risk->
     cnt = hosp_counter,
     hosp_risk->type[hosp_counter].count = (hosp_risk->type[hosp_counter].count+ 1)
    ENDIF
   ENDIF
   IF (rao.equation_name="SIM_HSP_DEATH")
    hosp_counter = death_record->death[pos].sim_hsp_death, hosp_risk->sim_cnt = hosp_counter,
    hosp_risk->type[hosp_counter].sim_count = (hosp_risk->type[hosp_counter].sim_count+ 1)
   ENDIF
   CASE (rao.equation_name)
    OF "NTL_ICU_DEATH":
     icu_risk->total_cnt = (icu_risk->total_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_risk->type[icu_counter].act_death_tot = (icu_risk->type[icu_counter].act_death_tot+ 1)
     ENDIF
     ,icu_risk->type[icu_counter].act_death_avg = (icu_risk->type[icu_counter].act_death_tot/
     icu_risk->type[icu_counter].count),icu_risk->type[icu_counter].nat_death_tot = (icu_risk->type[
     icu_counter].nat_death_tot+ rao.outcome_value),icu_risk->type[icu_counter].nat_death_avg = (
     icu_risk->type[icu_counter].nat_death_tot/ icu_risk->type[icu_counter].count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_risk->type[icu_counter].nat_out = (icu_risk->type[icu_counter].nat_out+ 1)
     ENDIF
    OF "SIM_ICU_DEATH":
     icu_risk->total_sim_cnt = (icu_risk->total_sim_cnt+ 1),
     IF (ra.diedinicu_ind=1)
      icu_risk->type[icu_counter].sim_act_death_tot = (icu_risk->type[icu_counter].sim_act_death_tot
      + 1)
     ENDIF
     ,icu_risk->type[icu_counter].sim_act_death_avg = (icu_risk->type[icu_counter].sim_act_death_tot
     / icu_risk->type[icu_counter].sim_count),icu_risk->type[icu_counter].sim_death_tot = (icu_risk->
     type[icu_counter].sim_death_tot+ rao.outcome_value),icu_risk->type[icu_counter].sim_death_avg =
     (icu_risk->type[icu_counter].sim_death_tot/ icu_risk->type[icu_counter].sim_count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      icu_risk->type[icu_counter].sim_out = (icu_risk->type[icu_counter].sim_out+ 1)
     ENDIF
    OF "NTL_HSP_DEATH":
     hosp_risk->total_cnt = (hosp_risk->total_cnt+ 1),
     IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
     .deceased_dt_tm > e.reg_dt_tm
      AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
      hosp_risk->type[hosp_counter].act_death_tot = (hosp_risk->type[hosp_counter].act_death_tot+ 1)
     ENDIF
     ,hosp_risk->type[hosp_counter].act_death_avg = (hosp_risk->type[hosp_counter].act_death_tot/
     hosp_risk->type[hosp_counter].count),hosp_risk->type[hosp_counter].nat_death_tot = (hosp_risk->
     type[hosp_counter].nat_death_tot+ rao.outcome_value),hosp_risk->type[hosp_counter].nat_death_avg
      = (hosp_risk->type[hosp_counter].nat_death_tot/ hosp_risk->type[hosp_counter].count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      hosp_risk->type[hosp_counter].nat_out = (hosp_risk->type[hosp_counter].nat_out+ 1)
     ENDIF
    OF "SIM_HSP_DEATH":
     hosp_risk->total_sim_cnt = (hosp_risk->total_sim_cnt+ 1),
     IF (((ra.diedinicu_ind=1) OR (((e.disch_disposition_cd IN (deceased_cd, expired_cd)) OR (p
     .deceased_dt_tm > e.reg_dt_tm
      AND p.deceased_dt_tm <= e.disch_dt_tm)) )) )
      hosp_risk->type[hosp_counter].sim_act_death_tot = (hosp_risk->type[hosp_counter].
      sim_act_death_tot+ 1)
     ENDIF
     ,hosp_risk->type[hosp_counter].sim_death_tot = (hosp_risk->type[hosp_counter].sim_death_tot+ rao
     .outcome_value),hosp_risk->type[hosp_counter].sim_act_death_avg = (hosp_risk->type[hosp_counter]
     .sim_act_death_tot/ hosp_risk->type[hosp_counter].sim_count),hosp_risk->type[hosp_counter].
     sim_death_avg = (hosp_risk->type[hosp_counter].sim_death_tot/ hosp_risk->type[hosp_counter].
     sim_count),
     IF ((((((cnvtdate(ra.icu_disch_dt_tm) - cnvtdate(ra.icu_admit_dt_tm))+ 1) - rao.outcome_value)
      - 2) >= 0))
      hosp_risk->type[hosp_counter].sim_out = (hosp_risk->type[hosp_counter].sim_out+ 1)
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SET p_result = calc_p_string(icu_service->total_cnt,"ICU","NTL_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_service->nat_p_string = "   "
  OF 1:
   SET icu_service->nat_p_string = "** "
  OF 2:
   SET icu_service->nat_p_string = "***"
  ELSE
   SET icu_service->nat_p_string = "   "
 ENDCASE
 SET array_size = size(icu_service->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_service->type[x].count,"ICU","NTL_ICU_DEATH",- (1),icu_service->
   type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_service->type[x].nat_p_string = "   "
   OF 1:
    SET icu_service->type[x].nat_p_string = "** "
   OF 2:
    SET icu_service->type[x].nat_p_string = "***"
   ELSE
    SET icu_service->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_disease->total_cnt,"ICU","NTL_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_disease->nat_p_string = "   "
  OF 1:
   SET icu_disease->nat_p_string = "** "
  OF 2:
   SET icu_disease->nat_p_string = "***"
  ELSE
   SET icu_disease->nat_p_string = "   "
 ENDCASE
 SET array_size = size(icu_disease->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_disease->type[x].count,"ICU","NTL_ICU_DEATH",icu_disease->type[x].
   code,- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_disease->type[x].nat_p_string = "   "
   OF 1:
    SET icu_disease->type[x].nat_p_string = "** "
   OF 2:
    SET icu_disease->type[x].nat_p_string = "***"
   ELSE
    SET icu_disease->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_service->total_sim_cnt,"SIM_ICU_DEATH","ICU",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_service->sim_p_string = "   "
  OF 1:
   SET icu_service->sim_p_string = "** "
  OF 2:
   SET icu_service->sim_p_string = "***"
  ELSE
   SET icu_service->sim_p_string = "   "
 ENDCASE
 SET array_size = size(icu_service->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_service->type[x].sim_count,"ICU","SIM_ICU_DEATH",icu_service->
   type[x].code,- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_service->type[x].sim_p_string = "   "
   OF 1:
    SET icu_service->type[x].sim_p_string = "** "
   OF 2:
    SET icu_service->type[x].sim_p_string = "***"
   ELSE
    SET icu_service->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_disease->total_sim_cnt,"SIM_ICU_DEATH","ICU",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_disease->sim_p_string = "   "
  OF 1:
   SET icu_disease->sim_p_string = "** "
  OF 2:
   SET icu_disease->sim_p_string = "***"
  ELSE
   SET icu_disease->sim_p_string = "   "
 ENDCASE
 SET array_size = size(icu_disease->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_disease->type[x].sim_count,"ICU","SIM_ICU_DEATH",icu_disease->
   type[x].code,- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_disease->type[x].sim_p_string = "   "
   OF 1:
    SET icu_disease->type[x].sim_p_string = "** "
   OF 2:
    SET icu_disease->type[x].sim_p_string = "***"
   ELSE
    SET icu_disease->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_service->total_cnt,"HOSP","NTL_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_service->nat_p_string = "   "
  OF 1:
   SET hosp_service->nat_p_string = "** "
  OF 2:
   SET hosp_service->nat_p_string = "***"
  ELSE
   SET hosp_service->nat_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_service->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_service->type[x].count,"HOSP","NTL_HOSP_DEATH",- (1),hosp_service
   ->type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_service->type[x].nat_p_string = "   "
   OF 1:
    SET hosp_service->type[x].nat_p_string = "** "
   OF 2:
    SET hosp_service->type[x].nat_p_string = "***"
   ELSE
    SET hosp_service->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_disease->total_cnt,"HOSP","NTL_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_disease->nat_p_string = "   "
  OF 1:
   SET hosp_disease->nat_p_string = "** "
  OF 2:
   SET hosp_disease->nat_p_string = "***"
  ELSE
   SET hosp_disease->nat_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_disease->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_disease->type[x].count,"HOSP","NTL_HOSP_DEATH",- (1),hosp_disease
   ->type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_disease->type[x].nat_p_string = "   "
   OF 1:
    SET hosp_disease->type[x].nat_p_string = "** "
   OF 2:
    SET hosp_disease->type[x].nat_p_string = "***"
   ELSE
    SET hosp_disease->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_service->total_sim_cnt,"SIM_HSP_DEATH","HOSP",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_service->sim_p_string = "   "
  OF 1:
   SET hosp_service->sim_p_string = "** "
  OF 2:
   SET hosp_service->sim_p_string = "***"
  ELSE
   SET hosp_service->sim_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_service->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_service->type[x].sim_count,"HOSP","SIM_HSP_DEATH",hosp_service->
   type[x].code,- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_service->type[x].sim_p_string = "   "
   OF 1:
    SET hosp_service->type[x].sim_p_string = "** "
   OF 2:
    SET hosp_service->type[x].sim_p_string = "***"
   ELSE
    SET hosp_service->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_disease->total_sim_cnt,"SIM_HSP_DEATH","HOSP",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_disease->sim_p_string = "   "
  OF 1:
   SET hosp_disease->sim_p_string = "** "
  OF 2:
   SET hosp_disease->sim_p_string = "***"
  ELSE
   SET hosp_disease->sim_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_disease->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_disease->type[x].sim_count,"HOSP","SIM_HSP_DEATH",hosp_disease->
   type[x].code,- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_disease->type[x].sim_p_string = "   "
   OF 1:
    SET hosp_disease->type[x].sim_p_string = "** "
   OF 2:
    SET hosp_disease->type[x].sim_p_string = "***"
   ELSE
    SET hosp_disease->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_doctor->total_cnt,"ICU","NTL_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_doctor->nat_p_string = "   "
  OF 1:
   SET icu_doctor->nat_p_string = "** "
  OF 2:
   SET icu_doctor->nat_p_string = "***"
  ELSE
   SET icu_doctor->nat_p_string = "   "
 ENDCASE
 SET array_size = size(icu_doctor->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_doctor->type[x].count,"ICU","NTL_ICU_DEATH",- (1),icu_doctor->
   type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_doctor->type[x].nat_p_string = "   "
   OF 1:
    SET icu_doctor->type[x].nat_p_string = "** "
   OF 2:
    SET icu_doctor->type[x].nat_p_string = "***"
   ELSE
    SET icu_doctor->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_doctor->total_sim_cnt,"ICU","SIM_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_doctor->sim_p_string = "   "
  OF 1:
   SET icu_doctor->sim_p_string = "** "
  OF 2:
   SET icu_doctor->sim_p_string = "***"
  ELSE
   SET icu_doctor->sim_p_string = "   "
 ENDCASE
 SET array_size = size(icu_doctor->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_doctor->type[x].sim_count,"ICU","SIM_ICU_DEATH",- (1),icu_doctor->
   type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET icu_doctor->type[x].sim_p_string = "   "
   OF 1:
    SET icu_doctor->type[x].sim_p_string = "** "
   OF 2:
    SET icu_doctor->type[x].sim_p_string = "***"
   ELSE
    SET icu_doctor->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_doctor->total_sim_cnt,"HOSP","SIM_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_doctor->sim_p_string = "   "
  OF 1:
   SET hosp_doctor->sim_p_string = "** "
  OF 2:
   SET hosp_doctor->sim_p_string = "***"
  ELSE
   SET hosp_doctor->sim_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_doctor->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_doctor->type[x].sim_count,"HOSP","SIM_HSP_DEATH",- (1),
   hosp_doctor->type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_doctor->type[x].sim_p_string = "   "
   OF 1:
    SET hosp_doctor->type[x].sim_p_string = "** "
   OF 2:
    SET hosp_doctor->type[x].sim_p_string = "***"
   ELSE
    SET hosp_doctor->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_doctor->total_cnt,"HOSP","NTL_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_doctor->nat_p_string = "   "
  OF 1:
   SET hosp_doctor->nat_p_string = "** "
  OF 2:
   SET hosp_doctor->nat_p_string = "***"
  ELSE
   SET hosp_doctor->nat_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_doctor->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_doctor->type[x].count,"HOSP","NTL_HSP_DEATH",- (1),hosp_doctor->
   type[x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_doctor->type[x].nat_p_string = "   "
   OF 1:
    SET hosp_doctor->type[x].nat_p_string = "** "
   OF 2:
    SET hosp_doctor->type[x].nat_p_string = "***"
   ELSE
    SET hosp_doctor->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_risk->total_cnt,"HOSP","NTL_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_risk->nat_p_string = "   "
  OF 1:
   SET hosp_risk->nat_p_string = "** "
  OF 2:
   SET hosp_risk->nat_p_string = "***"
  ELSE
   SET hosp_risk->nat_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_risk->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_risk->type[x].count,"HOSP","NTL_HSP_DEATH",- (1),- (1),
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_risk->type[x].nat_p_string = "   "
   OF 1:
    SET hosp_risk->type[x].nat_p_string = "** "
   OF 2:
    SET hosp_risk->type[x].nat_p_string = "***"
   ELSE
    SET hosp_risk->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(hosp_risk->total_sim_cnt,"HOSP","SIM_HSP_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET hosp_risk->sim_p_string = "   "
  OF 1:
   SET hosp_risk->sim_p_string = "** "
  OF 2:
   SET hosp_risk->sim_p_string = "***"
  ELSE
   SET hosp_risk->sim_p_string = "   "
 ENDCASE
 SET array_size = size(hosp_risk->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(hosp_risk->type[x].count,"HOSP","NTL_HSP_DEATH",- (1),hosp_risk->type[
   x].code,
   - (1),- (1))
  CASE (p_result)
   OF 0:
    SET hosp_risk->type[x].sim_p_string = "   "
   OF 1:
    SET hosp_risk->type[x].sim_p_string = "** "
   OF 2:
    SET hosp_risk->type[x].sim_p_string = "***"
   ELSE
    SET hosp_risk->type[x].sim_p_string = "   "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_risk->total_sim_cnt,"ICU","SIM_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_risk->sim_p_string = "   "
  OF 1:
   SET icu_risk->sim_p_string = "** "
  OF 2:
   SET icu_risk->sim_p_string = "***"
  ELSE
   SET icu_risk->sim_p_string = "   "
 ENDCASE
 SET array_size = size(icu_risk->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_risk->type[x].count,"ICU","NTL_ICU_DEATH",- (1),- (1),
   - (1),x)
  CASE (p_result)
   OF 0:
    SET icu_risk->type[x].sim_p_string = "   "
   OF 1:
    SET icu_risk->type[x].sim_p_string = "** "
   OF 2:
    SET icu_risk->type[x].sim_p_string = "***"
   ELSE
    SET icu_risk->type[x].sim_p_string = "  "
  ENDCASE
 ENDFOR
 SET p_result = calc_p_string(icu_risk->total_cnt,"ICU","NTL_ICU_DEATH",- (1),- (1),
  - (1),- (1))
 CASE (p_result)
  OF 0:
   SET icu_risk->nat_p_string = "   "
  OF 1:
   SET icu_risk->nat_p_string = "** "
  OF 2:
   SET icu_risk->nat_p_string = "***"
  ELSE
   SET icu_risk->nat_p_string = "   "
 ENDCASE
 SET array_size = size(icu_risk->type,5)
 FOR (x = 1 TO array_size)
  SET p_result = calc_p_string(icu_risk->type[x].count,"ICU","NTL_ICU_DEATH",- (1),- (1),
   - (1),x)
  CASE (p_result)
   OF 0:
    SET icu_risk->type[x].nat_p_string = "   "
   OF 1:
    SET icu_risk->type[x].nat_p_string = "** "
   OF 2:
    SET icu_risk->type[x].nat_p_string = "***"
   ELSE
    SET icu_risk->type[x].nat_p_string = "   "
  ENDCASE
 ENDFOR
 SET arr_sz1 = size(icu_disease->type,5)
 IF (arr_sz1 > 0)
  SET stat = alterlist(icu_disease->type_tmp,arr_sz1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz1)
   ORDER BY icu_disease->type[d.seq].count DESC, icu_disease->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icu_disease->type_tmp[counter].code = icu_disease->type[d.seq].code,
    icu_disease->type_tmp[counter].name = icu_disease->type[d.seq].name,
    icu_disease->type_tmp[counter].count = icu_disease->type[d.seq].count, icu_disease->type_tmp[
    counter].sim_count = icu_disease->type[d.seq].sim_count, icu_disease->type_tmp[counter].
    act_death_tot = icu_disease->type[d.seq].act_death_tot,
    icu_disease->type_tmp[counter].act_death_avg = icu_disease->type[d.seq].act_death_avg,
    icu_disease->type_tmp[counter].sim_act_death_tot = icu_disease->type[d.seq].sim_act_death_tot,
    icu_disease->type_tmp[counter].sim_act_death_avg = icu_disease->type[d.seq].sim_act_death_avg,
    icu_disease->type_tmp[counter].nat_death_tot = icu_disease->type[d.seq].nat_death_tot,
    icu_disease->type_tmp[counter].nat_death_avg = icu_disease->type[d.seq].nat_death_avg,
    icu_disease->type_tmp[counter].sim_death_tot = icu_disease->type[d.seq].sim_death_tot,
    icu_disease->type_tmp[counter].sim_death_avg = icu_disease->type[d.seq].sim_death_avg,
    icu_disease->type_tmp[counter].nat_out = icu_disease->type[d.seq].nat_out, icu_disease->type_tmp[
    counter].sim_out = icu_disease->type[d.seq].sim_out,
    icu_disease->type_tmp[counter].nat_p_string = icu_disease->type[d.seq].nat_p_string, icu_disease
    ->type_tmp[counter].sim_p_string = icu_disease->type[d.seq].sim_p_string
   WITH nocounter
  ;end select
 ENDIF
 SET arr_sz2 = size(hosp_disease->type,5)
 IF (arr_sz2 > 0)
  SET stat = alterlist(hosp_disease->type_tmp,arr_sz2)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz2)
   ORDER BY hosp_disease->type[d.seq].count DESC, hosp_disease->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), hosp_disease->type_tmp[counter].code = hosp_disease->type[d.seq].code,
    hosp_disease->type_tmp[counter].name = hosp_disease->type[d.seq].name,
    hosp_disease->type_tmp[counter].count = hosp_disease->type[d.seq].count, hosp_disease->type_tmp[
    counter].sim_count = hosp_disease->type[d.seq].sim_count, hosp_disease->type_tmp[counter].
    act_death_tot = hosp_disease->type[d.seq].act_death_tot,
    hosp_disease->type_tmp[counter].act_death_avg = hosp_disease->type[d.seq].act_death_avg,
    hosp_disease->type_tmp[counter].sim_act_death_tot = hosp_disease->type[d.seq].sim_act_death_tot,
    hosp_disease->type_tmp[counter].sim_act_death_avg = hosp_disease->type[d.seq].sim_act_death_avg,
    hosp_disease->type_tmp[counter].nat_death_tot = hosp_disease->type[d.seq].nat_death_tot,
    hosp_disease->type_tmp[counter].nat_death_avg = hosp_disease->type[d.seq].nat_death_avg,
    hosp_disease->type_tmp[counter].sim_death_tot = hosp_disease->type[d.seq].sim_death_tot,
    hosp_disease->type_tmp[counter].sim_death_avg = hosp_disease->type[d.seq].sim_death_avg,
    hosp_disease->type_tmp[counter].nat_out = hosp_disease->type[d.seq].nat_out, hosp_disease->
    type_tmp[counter].sim_out = hosp_disease->type[d.seq].sim_out,
    hosp_disease->type_tmp[counter].nat_p_string = hosp_disease->type[d.seq].nat_p_string,
    hosp_disease->type_tmp[counter].sim_p_string = hosp_disease->type[d.seq].sim_p_string,
    hosp_disease->type_tmp[counter].lr_death_tot = hosp_disease->type[d.seq].lr_death_tot
   WITH nocounter
  ;end select
 ENDIF
 SET arr_sz3 = size(icu_service->type,5)
 IF (arr_sz3 > 0)
  SET stat = alterlist(icu_service->type_tmp,arr_sz3)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz3)
   ORDER BY icu_service->type[d.seq].count DESC, icu_service->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icu_service->type_tmp[counter].code = icu_service->type[d.seq].code,
    icu_service->type_tmp[counter].name = icu_service->type[d.seq].name,
    icu_service->type_tmp[counter].count = icu_service->type[d.seq].count, icu_service->type_tmp[
    counter].sim_count = icu_service->type[d.seq].sim_count, icu_service->type_tmp[counter].
    act_death_tot = icu_service->type[d.seq].act_death_tot,
    icu_service->type_tmp[counter].act_death_avg = icu_service->type[d.seq].act_death_avg,
    icu_service->type_tmp[counter].sim_act_death_tot = icu_service->type[d.seq].sim_act_death_tot,
    icu_service->type_tmp[counter].sim_act_death_avg = icu_service->type[d.seq].sim_act_death_avg,
    icu_service->type_tmp[counter].nat_death_tot = icu_service->type[d.seq].nat_death_tot,
    icu_service->type_tmp[counter].nat_death_avg = icu_service->type[d.seq].nat_death_avg,
    icu_service->type_tmp[counter].sim_death_tot = icu_service->type[d.seq].sim_death_tot,
    icu_service->type_tmp[counter].sim_death_avg = icu_service->type[d.seq].sim_death_avg,
    icu_service->type_tmp[counter].nat_out = icu_service->type[d.seq].nat_out, icu_service->type_tmp[
    counter].sim_out = icu_service->type[d.seq].sim_out,
    icu_service->type_tmp[counter].nat_p_string = icu_service->type[d.seq].nat_p_string, icu_service
    ->type_tmp[counter].sim_p_string = icu_service->type[d.seq].sim_p_string
   WITH nocounter
  ;end select
 ENDIF
 SET arr_sz4 = size(hosp_service->type,5)
 IF (arr_sz4 > 0)
  SET stat = alterlist(hosp_service->type_tmp,arr_sz4)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz4)
   ORDER BY hosp_service->type[d.seq].count DESC, hosp_service->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), hosp_service->type_tmp[counter].code = hosp_service->type[d.seq].code,
    hosp_service->type_tmp[counter].name = hosp_service->type[d.seq].name,
    hosp_service->type_tmp[counter].count = hosp_service->type[d.seq].count, hosp_service->type_tmp[
    counter].sim_count = hosp_service->type[d.seq].sim_count, hosp_service->type_tmp[counter].
    act_death_tot = hosp_service->type[d.seq].act_death_tot,
    hosp_service->type_tmp[counter].act_death_avg = hosp_service->type[d.seq].act_death_avg,
    hosp_service->type_tmp[counter].sim_act_death_tot = hosp_service->type[d.seq].sim_act_death_tot,
    hosp_service->type_tmp[counter].sim_act_death_avg = hosp_service->type[d.seq].sim_act_death_avg,
    hosp_service->type_tmp[counter].nat_death_tot = hosp_service->type[d.seq].nat_death_tot,
    hosp_service->type_tmp[counter].nat_death_avg = hosp_service->type[d.seq].nat_death_avg,
    hosp_service->type_tmp[counter].sim_death_tot = hosp_service->type[d.seq].sim_death_tot,
    hosp_service->type_tmp[counter].sim_death_avg = hosp_service->type[d.seq].sim_death_avg,
    hosp_service->type_tmp[counter].nat_out = hosp_service->type[d.seq].nat_out, hosp_service->
    type_tmp[counter].sim_out = hosp_service->type[d.seq].sim_out,
    hosp_service->type_tmp[counter].nat_p_string = hosp_service->type[d.seq].nat_p_string,
    hosp_service->type_tmp[counter].sim_p_string = hosp_service->type[d.seq].sim_p_string,
    hosp_service->type_tmp[counter].lr_death_tot = hosp_service->type[d.seq].lr_death_tot
   WITH nocounter
  ;end select
 ENDIF
 SET arr_sz5 = size(icu_doctor->type,5)
 IF (arr_sz5 > 0)
  SET stat = alterlist(icu_doctor->type_tmp,arr_sz5)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz5)
   ORDER BY icu_doctor->type[d.seq].count DESC, icu_doctor->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), icu_doctor->type_tmp[counter].code = icu_doctor->type[d.seq].code,
    icu_doctor->type_tmp[counter].alias = icu_doctor->type[d.seq].alias,
    icu_doctor->type_tmp[counter].name = icu_doctor->type[d.seq].name, icu_doctor->type_tmp[counter].
    count = icu_doctor->type[d.seq].count, icu_doctor->type_tmp[counter].sim_count = icu_doctor->
    type[d.seq].sim_count,
    icu_doctor->type_tmp[counter].act_death_tot = icu_doctor->type[d.seq].act_death_tot, icu_doctor->
    type_tmp[counter].act_death_avg = icu_doctor->type[d.seq].act_death_avg, icu_doctor->type_tmp[
    counter].sim_act_death_tot = icu_doctor->type[d.seq].sim_act_death_tot,
    icu_doctor->type_tmp[counter].sim_act_death_avg = icu_doctor->type[d.seq].sim_act_death_avg,
    icu_doctor->type_tmp[counter].nat_death_tot = icu_doctor->type[d.seq].nat_death_tot, icu_doctor->
    type_tmp[counter].nat_death_avg = icu_doctor->type[d.seq].nat_death_avg,
    icu_doctor->type_tmp[counter].sim_death_tot = icu_doctor->type[d.seq].sim_death_tot, icu_doctor->
    type_tmp[counter].sim_death_avg = icu_doctor->type[d.seq].sim_death_avg, icu_doctor->type_tmp[
    counter].nat_out = icu_doctor->type[d.seq].nat_out,
    icu_doctor->type_tmp[counter].sim_out = icu_doctor->type[d.seq].sim_out, icu_doctor->type_tmp[
    counter].nat_p_string = icu_doctor->type[d.seq].nat_p_string, icu_doctor->type_tmp[counter].
    sim_p_string = icu_doctor->type[d.seq].sim_p_string
   WITH nocounter
  ;end select
 ENDIF
 SET arr_sz6 = size(hosp_doctor->type,5)
 IF (arr_sz6 > 0)
  SET stat = alterlist(hosp_doctor->type_tmp,arr_sz6)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = arr_sz6)
   ORDER BY hosp_doctor->type[d.seq].count DESC, hosp_doctor->type[d.seq].name
   HEAD REPORT
    counter = 0
   DETAIL
    counter = (counter+ 1), hosp_doctor->type_tmp[counter].code = hosp_doctor->type[d.seq].code,
    hosp_doctor->type_tmp[counter].alias = hosp_doctor->type[d.seq].alias,
    hosp_doctor->type_tmp[counter].name = hosp_doctor->type[d.seq].name, hosp_doctor->type_tmp[
    counter].count = hosp_doctor->type[d.seq].count, hosp_doctor->type_tmp[counter].sim_count =
    hosp_doctor->type[d.seq].sim_count,
    hosp_doctor->type_tmp[counter].act_death_tot = hosp_doctor->type[d.seq].act_death_tot,
    hosp_doctor->type_tmp[counter].act_death_avg = hosp_doctor->type[d.seq].act_death_avg,
    hosp_doctor->type_tmp[counter].sim_act_death_tot = hosp_doctor->type[d.seq].sim_act_death_tot,
    hosp_doctor->type_tmp[counter].sim_act_death_avg = hosp_doctor->type[d.seq].sim_act_death_avg,
    hosp_doctor->type_tmp[counter].nat_death_tot = hosp_doctor->type[d.seq].nat_death_tot,
    hosp_doctor->type_tmp[counter].nat_death_avg = hosp_doctor->type[d.seq].nat_death_avg,
    hosp_doctor->type_tmp[counter].sim_death_tot = hosp_doctor->type[d.seq].sim_death_tot,
    hosp_doctor->type_tmp[counter].sim_death_avg = hosp_doctor->type[d.seq].sim_death_avg,
    hosp_doctor->type_tmp[counter].nat_out = hosp_doctor->type[d.seq].nat_out,
    hosp_doctor->type_tmp[counter].sim_out = hosp_doctor->type[d.seq].sim_out, hosp_doctor->type_tmp[
    counter].nat_p_string = hosp_doctor->type[d.seq].nat_p_string, hosp_doctor->type_tmp[counter].
    sim_p_string = hosp_doctor->type[d.seq].sim_p_string,
    hosp_doctor->type_tmp[counter].lr_death_tot = hosp_doctor->type[d.seq].lr_death_tot
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   col 0, font110c, col 50,
   dio_landscape, row 2, x_pos = 0,
   y_pos = 36, row + 1, y_pos = (y_pos+ 10),
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), rpt_params->gen_on,
   CALL print(calcpos(357,y_pos)), "APACHE For ICU",
   CALL print(calcpos(600,y_pos)),
   "By Module: Dcp_Arpt_16_Mort_Rev", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(340,y_pos)), "JCAHO Report Detailed", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(339,y_pos)), "Supplemental QA Report",
   row + 1, y_pos = (y_pos+ 10), col 0,
   font80c, y_pos = (y_pos+ 15),
   CALL print(calcpos(340,y_pos)),
   "Mortality Review", row + 1, col 0,
   font110c, y_pos = (y_pos+ 15), len = 0,
   CALL print(calcpos(270,y_pos)), rpt_params->date_type_range_disp, row + 1,
   y_pos = (y_pos+ 15), line = fillstring(680,"-"),
   CALL print(calcpos(30,y_pos)),
   line, row + 1, y_pos = (y_pos+ 10),
   len = size(rpt_params->org_name,1), x_pos = (370 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->org_name, row + 1, y_pos = (y_pos+ 10),
   len = size(rpt_params->unit_disp,1), x_pos = (370 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->unit_disp, row + 1, y_pos = (y_pos+ 10),
   y_pos = (y_pos+ 10)
  DETAIL
   CALL print(calcpos(45,y_pos)), "ICU Mortality Review (% total)", row + 2,
   y_pos = (y_pos+ 15),
   CALL print(calcpos(45,y_pos)),
   "Note: Includes all ICU patients with ICU outcomes and predicted outcomes",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(60,y_pos)),
   "Total ICU patients during this time period: ", tot_pat_disp = format(icu_pat_cnt,"#####;r"), col
    + 2,
   tot_pat_disp, row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(235,y_pos)), "# Pts w/",
   CALL print(calcpos(325,y_pos)),
   "---------------ICU DEATH Ratio-------------", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(140,y_pos)), "Number in Group",
   CALL print(calcpos(235,y_pos)),
   "Similar",
   CALL print(calcpos(365,y_pos)), "(Actual/Predicted) = Ratio",
   CALL print(calcpos(630,y_pos)), "---ICU Mortality----", row + 2,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "Category",
   CALL print(calcpos(140,y_pos)), "     #      %",
   CALL print(calcpos(240,y_pos)),
   "Preds",
   CALL print(calcpos(340,y_pos)), "National",
   CALL print(calcpos(505,y_pos)), "Similar",
   CALL print(calcpos(650,y_pos)),
   "    # (Rate %)", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), line, row + 1,
   y_pos = (y_pos+ 10), cnt_disp = format(icu_disease->total_cnt,"####;r"), sim_cnt_disp = format(
    icu_disease->total_sim_cnt,"####;r"),
   cnt_rat = format("100","####%;r"), act_death_disp = format((100 * icu_disease->tot_act_death_avg),
    "####.##;r"), act_death_tot_disp = format(icu_disease->tot_act_death_tot,"####;r"),
   sim_act_death_disp = format((100 * icu_disease->tot_sim_act_death_avg),"####.##;r"),
   sim_act_death_tot_disp = format(icu_disease->tot_sim_act_death_tot,"####;r"), ntl_death_disp =
   format((100 * icu_disease->tot_nat_death_avg),"####.##;r"),
   ntl_rat_disp = format((icu_disease->tot_act_death_avg/ icu_disease->tot_nat_death_avg),"###.##;r"),
   sim_death_disp = format((100 * icu_disease->tot_sim_death_avg),"####.##;r"), sim_rat_disp = format
   ((icu_disease->tot_sim_act_death_avg/ icu_disease->tot_sim_death_avg),"###.##;r"),
   sim_out_disp = format(icu_disease->tot_sim_out,"####;r"), sim_out_rat_disp = format(((100 *
    icu_disease->tot_sim_out)/ icu_disease->total_cnt),"###.#%"), nat_out_disp = format(icu_disease
    ->tot_nat_out,"####;r"),
   nat_out_rat_disp = format(((100 * icu_disease->tot_nat_out)/ icu_disease->total_cnt),"###.#%"),
   ntl_pstring = icu_disease->nat_p_string, sim_pstring = icu_disease->sim_p_string,
   CALL print(calcpos(45,y_pos)), "OVERALL",
   CALL print(calcpos(130,y_pos)),
   CALL print(calcpos(150,y_pos)), cnt_disp,
   CALL print(calcpos(190,y_pos)),
   cnt_rat,
   CALL print(calcpos(240,y_pos)), sim_cnt_disp,
   CALL print(calcpos(290,y_pos)), act_death_disp,
   CALL print(calcpos(330,y_pos)),
   "/",
   CALL print(calcpos(325,y_pos)), ntl_death_disp,
   row + 1,
   CALL print(calcpos(370,y_pos)), "=",
   CALL print(calcpos(375,y_pos)), ntl_rat_disp,
   CALL print(calcpos(470,y_pos)),
   sim_act_death_disp,
   CALL print(calcpos(510,y_pos)), "/",
   CALL print(calcpos(505,y_pos)), sim_death_disp,
   CALL print(calcpos(550,y_pos)),
   "=", row + 1,
   CALL print(calcpos(555,y_pos)),
   sim_rat_disp,
   CALL print(calcpos(650,y_pos)), act_death_tot_disp,
   CALL print(calcpos(690,y_pos)), "(",
   CALL print(calcpos(692,y_pos)),
   act_death_disp,
   CALL print(calcpos(730,y_pos)), ")",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "SERVICE", array_size = size(icu_service->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(icu_service->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(icu_service->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      icu_service->type_tmp[x].count)/ icu_service->total_cnt),"####%"), act_death_tot_disp = format
     (icu_service->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * icu_service->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(icu_service->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * icu_service->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * icu_service->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * icu_service->type_tmp[x].sim_death_avg),"####.##;r"),
     ntl_rat_disp = format((icu_service->type_tmp[x].act_death_avg/ icu_service->type_tmp[x].
      nat_death_avg),"###.##;r"),
     ntl_pstring = icu_service->type_tmp[x].nat_p_string, sim_pstring = icu_service->type_tmp[x].
     sim_p_string, sim_rat_disp = format((icu_service->type_tmp[x].sim_act_death_avg/ icu_service->
      type_tmp[x].sim_death_avg),"###.##;r"),
     nat_out_disp = format(icu_service->type_tmp[x].nat_out,"####;r"), nat_out_rat_disp = format(((
      100 * icu_service->type_tmp[x].nat_out)/ icu_service->total_cnt),"###.#%"), sim_out_disp =
     format(icu_service->type_tmp[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * icu_service->type_tmp[x].sim_out)/ icu_service->total_cnt),
      "###.#%"), name_disp = "                    ", name_disp = icu_service->type_tmp[x].name,
     CALL print(calcpos(45,y_pos)), icu_service->type_tmp[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)),
     cnt_rat,
     CALL print(calcpos(240,y_pos)), sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)),
     "/",
     CALL print(calcpos(325,y_pos)), ntl_death_disp,
     row + 1,
     CALL print(calcpos(370,y_pos)), "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(470,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(510,y_pos)), "/",
     CALL print(calcpos(505,y_pos)), sim_death_disp,
     CALL print(calcpos(550,y_pos)),
     "=", row + 1,
     CALL print(calcpos(555,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(650,y_pos)), act_death_tot_disp,
     CALL print(calcpos(690,y_pos)), "(",
     CALL print(calcpos(692,y_pos)),
     act_death_disp,
     CALL print(calcpos(730,y_pos)), ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "DISEASE", array_size = size(icu_disease->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(icu_disease->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(icu_disease->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      icu_disease->type_tmp[x].count)/ icu_disease->total_cnt),"####%"), act_death_tot_disp = format
     (icu_disease->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * icu_disease->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(icu_disease->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * icu_disease->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * icu_disease->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * icu_disease->type_tmp[x].sim_death_avg),"####.##;r"),
     ntl_rat_disp = format((icu_disease->type_tmp[x].act_death_avg/ icu_disease->type_tmp[x].
      nat_death_avg),"###.##;r"),
     ntl_pstring = icu_disease->type_tmp[x].nat_p_string, sim_pstring = icu_disease->type_tmp[x].
     sim_p_string, sim_rat_disp = format((icu_disease->type_tmp[x].sim_act_death_avg/ icu_disease->
      type_tmp[x].sim_death_avg),"###.##;r"),
     nat_out_disp = format(icu_disease->type_tmp[x].nat_out,"####;r"), nat_out_rat_disp = format(((
      100 * icu_disease->type_tmp[x].nat_out)/ icu_disease->total_cnt),"###.#%"), sim_out_disp =
     format(icu_disease->type_tmp[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * icu_disease->type_tmp[x].sim_out)/ icu_disease->total_cnt),
      "###.#%"),
     CALL print(calcpos(45,y_pos)), icu_disease->type_tmp[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)), cnt_rat,
     CALL print(calcpos(240,y_pos)),
     sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)), "/",
     CALL print(calcpos(325,y_pos)),
     ntl_death_disp, row + 1,
     CALL print(calcpos(370,y_pos)),
     "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(470,y_pos)), sim_act_death_disp,
     CALL print(calcpos(510,y_pos)),
     "/",
     CALL print(calcpos(505,y_pos)), sim_death_disp,
     CALL print(calcpos(550,y_pos)), "=", row + 1,
     CALL print(calcpos(555,y_pos)), sim_rat_disp,
     CALL print(calcpos(650,y_pos)),
     act_death_tot_disp,
     CALL print(calcpos(690,y_pos)), "(",
     CALL print(calcpos(692,y_pos)), act_death_disp,
     CALL print(calcpos(730,y_pos)),
     ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "PHYSICIAN", array_size = size(icu_doctor->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(icu_doctor->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(icu_doctor->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      icu_doctor->type_tmp[x].count)/ icu_doctor->total_cnt),"####%"), act_death_tot_disp = format(
      icu_doctor->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * icu_doctor->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(icu_doctor->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * icu_doctor->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * icu_doctor->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * icu_doctor->type_tmp[x].sim_death_avg),"####.##;r"), ntl_rat_disp
      = format((icu_doctor->type_tmp[x].act_death_avg/ icu_doctor->type_tmp[x].nat_death_avg),
      "###.##;r"),
     ntl_pstring = icu_doctor->type_tmp[x].nat_p_string, sim_pstring = icu_doctor->type_tmp[x].
     sim_p_string, sim_rat_disp = format((icu_doctor->type_tmp[x].sim_act_death_avg/ icu_doctor->
      type_tmp[x].sim_death_avg),"###.##;r"),
     nat_out_disp = format(icu_doctor->type_tmp[x].nat_out,"####;r"), nat_out_rat_disp = format(((100
       * icu_doctor->type_tmp[x].nat_out)/ icu_doctor->total_cnt),"###.#%"), sim_out_disp = format(
      icu_doctor->type_tmp[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * icu_doctor->type_tmp[x].sim_out)/ icu_doctor->total_cnt),
      "###.#%"),
     CALL print(calcpos(45,y_pos)), icu_doctor->type_tmp[x].alias,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)), cnt_rat,
     CALL print(calcpos(240,y_pos)),
     sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)), "/",
     CALL print(calcpos(325,y_pos)),
     ntl_death_disp, row + 1,
     CALL print(calcpos(370,y_pos)),
     "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(400,y_pos)), ntl_pstring,
     CALL print(calcpos(470,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(510,y_pos)), "/",
     CALL print(calcpos(505,y_pos)), sim_death_disp,
     CALL print(calcpos(550,y_pos)),
     "=", row + 1,
     CALL print(calcpos(555,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(580,y_pos)), sim_pstring,
     CALL print(calcpos(650,y_pos)), act_death_tot_disp,
     CALL print(calcpos(690,y_pos)),
     "(",
     CALL print(calcpos(692,y_pos)), act_death_disp,
     CALL print(calcpos(730,y_pos)), ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "ICU Risk Range", array_size = size(icu_risk->type,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(icu_risk->type[x].count,"####;r"),
     sim_cnt_disp = format(icu_risk->type[x].sim_count,"####;r"), cnt_rat = format(((100 * icu_risk->
      type[x].count)/ icu_risk->total_cnt),"####%"), act_death_tot_disp = format(icu_risk->type[x].
      act_death_tot,"####;r"),
     act_death_disp = format((100 * icu_risk->type[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(icu_risk->type[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * icu_risk->type[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * icu_risk->type[x].nat_death_avg),"####.##;r"), sim_death_disp =
     format((100 * icu_risk->type[x].sim_death_avg),"####.##;r"), ntl_rat_disp = format((icu_risk->
      type[x].act_death_avg/ icu_risk->type[x].nat_death_avg),"###.##;r"),
     ntl_pstring = icu_risk->type[x].nat_p_string, sim_pstring = icu_risk->type[x].sim_p_string,
     sim_rat_disp = format((icu_risk->type[x].sim_act_death_avg/ icu_risk->type[x].sim_death_avg),
      "###.##;r"),
     nat_out_disp = format(icu_risk->type[x].nat_out,"####;r"), nat_out_rat_disp = format(((100 *
      icu_risk->type[x].nat_out)/ icu_risk->total_cnt),"###.#%"), sim_out_disp = format(icu_risk->
      type[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * icu_risk->type[x].sim_out)/ icu_risk->total_cnt),"###.#%"),
     CALL print(calcpos(45,y_pos)), icu_risk->type[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)), cnt_rat,
     CALL print(calcpos(240,y_pos)),
     sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)), "/",
     CALL print(calcpos(325,y_pos)),
     ntl_death_disp, row + 1,
     CALL print(calcpos(370,y_pos)),
     "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(400,y_pos)), ntl_pstring,
     CALL print(calcpos(470,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(510,y_pos)), "/",
     CALL print(calcpos(505,y_pos)), sim_death_disp,
     CALL print(calcpos(550,y_pos)),
     "=", row + 1,
     CALL print(calcpos(555,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(580,y_pos)), sim_pstring,
     CALL print(calcpos(650,y_pos)), act_death_tot_disp,
     CALL print(calcpos(690,y_pos)),
     "(",
     CALL print(calcpos(692,y_pos)), act_death_disp,
     CALL print(calcpos(730,y_pos)), ")"
   ENDFOR
   BREAK, row + 1,
   CALL print(calcpos(45,y_pos)),
   "Hospital Mortality Review (% total)", row + 2, y_pos = (y_pos+ 15),
   CALL print(calcpos(45,y_pos)),
   "Note: Includes all Hospital patients with Hospital outcomes and predicted outcomes", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(60,y_pos)), "Total Hospital patients during this time period: ",
   tot_pat_disp = format(risk_record->total_admit,"#####;r"), col + 2, hosp_pat_cnt,
   row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(235,y_pos)),
   "# Pts w/",
   CALL print(calcpos(315,y_pos)), "---------------Hosp DEATH Ratio-------------",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(140,y_pos)),
   "Number in Group",
   CALL print(calcpos(235,y_pos)), "Similar",
   CALL print(calcpos(355,y_pos)), "(Actual/Predicted) = Ratio",
   CALL print(calcpos(575,y_pos)),
   "---Hosp Mortality----",
   CALL print(calcpos(702,y_pos)), "Low Risk Deaths",
   row + 2, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "Category",
   CALL print(calcpos(140,y_pos)), "     #      %",
   CALL print(calcpos(240,y_pos)), "Preds",
   CALL print(calcpos(330,y_pos)),
   "National",
   CALL print(calcpos(485,y_pos)), "Similar",
   CALL print(calcpos(600,y_pos)), "# (Rate %)",
   CALL print(calcpos(710,y_pos)),
   "# (Rate %)", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), line, row + 1,
   y_pos = (y_pos+ 10), cnt_disp = format(hosp_disease->total_cnt,"####;r"), sim_cnt_disp = format(
    hosp_disease->total_sim_cnt,"####;r"),
   cnt_rat = format("100","####%"), ntl_pstring = hosp_disease->nat_p_string, sim_pstring =
   hosp_disease->sim_p_string,
   act_death_tot_disp = format(hosp_disease->tot_act_death_tot,"####;r"), act_death_disp = format((
    100 * hosp_disease->tot_act_death_avg),"####.##;r"), sim_act_death_tot_disp = format(hosp_disease
    ->tot_sim_act_death_tot,"####;r"),
   sim_act_death_disp = format((100 * hosp_disease->tot_sim_act_death_avg),"####.##;r"),
   ntl_death_disp = format((100 * hosp_disease->tot_nat_death_avg),"####.##;r"), ntl_rat_disp =
   format((hosp_disease->tot_act_death_avg/ hosp_disease->tot_nat_death_avg),"###.##;r"),
   sim_death_disp = format((100 * hosp_disease->tot_sim_death_avg),"####.##;r"), sim_rat_disp =
   format((hosp_disease->tot_sim_act_death_avg/ hosp_disease->tot_sim_death_avg),"###.##;r"),
   sim_out_disp = format(hosp_disease->tot_sim_out,"####;r"),
   sim_out_rat_disp = format(((100 * hosp_disease->tot_sim_out)/ hosp_disease->total_cnt),"###.#%"),
   nat_out_disp = format(hosp_disease->tot_nat_out,"####;r"), nat_out_rat_disp = format(((100 *
    hosp_disease->tot_nat_out)/ hosp_disease->total_cnt),"###.#%"),
   lr_death_disp = format(death_record->lr_cnt,"###;r"), lr_death_rat_disp = format(((death_record->
    lr_cnt * 100)/ hosp_disease->total_cnt),"###.#%"),
   CALL print(calcpos(45,y_pos)),
   "OVERALL",
   CALL print(calcpos(130,y_pos)),
   CALL print(calcpos(150,y_pos)),
   cnt_disp,
   CALL print(calcpos(190,y_pos)), cnt_rat,
   CALL print(calcpos(240,y_pos)), sim_cnt_disp,
   CALL print(calcpos(290,y_pos)),
   act_death_disp,
   CALL print(calcpos(330,y_pos)), "/",
   CALL print(calcpos(325,y_pos)), ntl_death_disp, row + 1,
   CALL print(calcpos(370,y_pos)), "=",
   CALL print(calcpos(375,y_pos)),
   ntl_rat_disp,
   CALL print(calcpos(400,y_pos)), ntl_pstring,
   CALL print(calcpos(440,y_pos)), sim_act_death_disp,
   CALL print(calcpos(480,y_pos)),
   "/",
   CALL print(calcpos(475,y_pos)), sim_death_disp,
   CALL print(calcpos(520,y_pos)), "=", row + 1,
   CALL print(calcpos(525,y_pos)), sim_rat_disp,
   CALL print(calcpos(550,y_pos)),
   sim_pstring,
   CALL print(calcpos(580,y_pos)), act_death_tot_disp,
   CALL print(calcpos(610,y_pos)), "(",
   CALL print(calcpos(612,y_pos)),
   act_death_disp,
   CALL print(calcpos(650,y_pos)), ")",
   CALL print(calcpos(695,y_pos)), lr_death_disp,
   CALL print(calcpos(725,y_pos)),
   "(",
   CALL print(calcpos(735,y_pos)), lr_death_rat_disp,
   CALL print(calcpos(765,y_pos)), ")", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "SERVICE",
   array_size = size(hosp_service->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(hosp_service->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(hosp_service->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      hosp_service->type_tmp[x].count)/ hosp_service->total_cnt),"####%"), act_death_tot_disp =
     format(hosp_service->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * hosp_service->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(hosp_service->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * hosp_service->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * hosp_service->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * hosp_service->type_tmp[x].sim_death_avg),"####.##;r"),
     ntl_rat_disp = format((hosp_service->type_tmp[x].act_death_avg/ hosp_service->type_tmp[x].
      nat_death_avg),"###.##;r"),
     sim_rat_disp = format((hosp_service->type_tmp[x].sim_act_death_avg/ hosp_service->type_tmp[x].
      sim_death_avg),"###.##;r"), nat_out_disp = format(hosp_service->type_tmp[x].nat_out,"####;r"),
     nat_out_rat_disp = format(((100 * hosp_service->type_tmp[x].nat_out)/ hosp_service->total_cnt),
      "###.#%"),
     sim_out_disp = format(hosp_service->type_tmp[x].sim_out,"####;r"), sim_out_rat_disp = format(((
      100 * hosp_service->type_tmp[x].sim_out)/ hosp_service->total_cnt),"###.#%"), ntl_pstring =
     hosp_service->type_tmp[x].nat_p_string,
     sim_pstring = hosp_service->type_tmp[x].sim_p_string, lr_death_tot = format(hosp_service->
      type_tmp[x].lr_death_tot,"###;r"), lr_death_rat_disp = format(((hosp_service->type_tmp[x].
      lr_death_tot * 100)/ hosp_service->type_tmp[x].count),"###.#%"),
     CALL print(calcpos(45,y_pos)), hosp_service->type_tmp[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)),
     cnt_rat,
     CALL print(calcpos(240,y_pos)), sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)),
     "/",
     CALL print(calcpos(325,y_pos)), ntl_death_disp,
     row + 1,
     CALL print(calcpos(370,y_pos)), "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(440,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(480,y_pos)), "/",
     CALL print(calcpos(475,y_pos)), sim_death_disp,
     CALL print(calcpos(520,y_pos)),
     "=", row + 1,
     CALL print(calcpos(525,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(580,y_pos)), act_death_tot_disp,
     CALL print(calcpos(610,y_pos)), "(",
     CALL print(calcpos(612,y_pos)),
     act_death_disp,
     CALL print(calcpos(650,y_pos)), ")",
     CALL print(calcpos(695,y_pos)), lr_death_tot,
     CALL print(calcpos(725,y_pos)),
     "(",
     CALL print(calcpos(735,y_pos)), lr_death_rat_disp,
     CALL print(calcpos(765,y_pos)), ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "DISEASE", array_size = size(hosp_disease->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(hosp_disease->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(hosp_disease->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      hosp_disease->type_tmp[x].count)/ hosp_disease->total_cnt),"####%"), act_death_tot_disp =
     format(hosp_disease->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * hosp_disease->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(hosp_disease->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * hosp_disease->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * hosp_disease->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * hosp_disease->type_tmp[x].sim_death_avg),"####.##;r"),
     ntl_rat_disp = format((hosp_disease->type_tmp[x].act_death_avg/ hosp_disease->type_tmp[x].
      nat_death_avg),"###.##;r"),
     sim_rat_disp = format((hosp_disease->type_tmp[x].sim_act_death_avg/ hosp_disease->type_tmp[x].
      sim_death_avg),"###.##;r"), nat_out_disp = format(hosp_disease->type_tmp[x].nat_out,"####;r"),
     nat_out_rat_disp = format(((100 * hosp_disease->type_tmp[x].nat_out)/ hosp_disease->total_cnt),
      "###.#%"),
     sim_out_disp = format(hosp_disease->type_tmp[x].sim_out,"####;r"), sim_out_rat_disp = format(((
      100 * hosp_disease->type_tmp[x].sim_out)/ hosp_disease->total_cnt),"###.#%"), ntl_pstring =
     hosp_disease->type_tmp[x].nat_p_string,
     sim_pstring = hosp_disease->type_tmp[x].sim_p_string, lr_death_tot = format(hosp_disease->
      type_tmp[x].lr_death_tot,"###;r"), lr_death_rat_disp = format(((hosp_disease->type_tmp[x].
      lr_death_tot * 100)/ hosp_disease->type_tmp[x].count),"###.#%"),
     CALL print(calcpos(45,y_pos)), hosp_disease->type_tmp[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)),
     cnt_rat,
     CALL print(calcpos(240,y_pos)), sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)),
     "/",
     CALL print(calcpos(325,y_pos)), ntl_death_disp,
     row + 1,
     CALL print(calcpos(370,y_pos)), "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(440,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(480,y_pos)), "/",
     CALL print(calcpos(475,y_pos)), sim_death_disp,
     CALL print(calcpos(520,y_pos)),
     "=", row + 1,
     CALL print(calcpos(525,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(580,y_pos)), act_death_tot_disp,
     CALL print(calcpos(610,y_pos)), "(",
     CALL print(calcpos(612,y_pos)),
     act_death_disp,
     CALL print(calcpos(650,y_pos)), ")",
     CALL print(calcpos(695,y_pos)), lr_death_tot,
     CALL print(calcpos(725,y_pos)),
     "(",
     CALL print(calcpos(735,y_pos)), lr_death_rat_disp,
     CALL print(calcpos(765,y_pos)), ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "PHYSICIAN", array_size = size(hosp_doctor->type_tmp,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(hosp_doctor->type_tmp[x].count,"####;r"),
     sim_cnt_disp = format(hosp_doctor->type_tmp[x].sim_count,"####;r"), cnt_rat = format(((100 *
      hosp_doctor->type_tmp[x].count)/ hosp_doctor->total_cnt),"####%"), act_death_tot_disp = format
     (hosp_doctor->type_tmp[x].act_death_tot,"####;r"),
     act_death_disp = format((100 * hosp_doctor->type_tmp[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(hosp_doctor->type_tmp[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * hosp_doctor->type_tmp[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * hosp_doctor->type_tmp[x].nat_death_avg),"####.##;r"),
     sim_death_disp = format((100 * hosp_doctor->type_tmp[x].sim_death_avg),"####.##;r"),
     ntl_rat_disp = format((hosp_doctor->type_tmp[x].act_death_avg/ hosp_doctor->type_tmp[x].
      nat_death_avg),"###.##;r"),
     ntl_pstring = hosp_doctor->type_tmp[x].nat_p_string, sim_pstring = hosp_doctor->type_tmp[x].
     sim_p_string, sim_rat_disp = format((hosp_doctor->type_tmp[x].sim_act_death_avg/ hosp_doctor->
      type_tmp[x].sim_death_avg),"###.##;r"),
     nat_out_disp = format(hosp_doctor->type_tmp[x].nat_out,"####;r"), nat_out_rat_disp = format(((
      100 * hosp_doctor->type_tmp[x].nat_out)/ hosp_doctor->total_cnt),"###.#%"), sim_out_disp =
     format(hosp_doctor->type_tmp[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * hosp_doctor->type_tmp[x].sim_out)/ hosp_doctor->total_cnt),
      "###.#%"), lr_death_tot = format(hosp_doctor->type_tmp[x].lr_death_tot,"###;r"),
     lr_death_rat_disp = format(((hosp_doctor->type_tmp[x].lr_death_tot * 100)/ hosp_doctor->
      type_tmp[x].count),"###.#%"),
     CALL print(calcpos(45,y_pos)), hosp_doctor->type_tmp[x].alias,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)),
     cnt_rat,
     CALL print(calcpos(240,y_pos)), sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)),
     "/",
     CALL print(calcpos(325,y_pos)), ntl_death_disp,
     row + 1,
     CALL print(calcpos(370,y_pos)), "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(440,y_pos)),
     sim_act_death_disp,
     CALL print(calcpos(480,y_pos)), "/",
     CALL print(calcpos(475,y_pos)), sim_death_disp,
     CALL print(calcpos(520,y_pos)),
     "=", row + 1,
     CALL print(calcpos(525,y_pos)),
     sim_rat_disp,
     CALL print(calcpos(580,y_pos)), act_death_tot_disp,
     CALL print(calcpos(610,y_pos)), "(",
     CALL print(calcpos(612,y_pos)),
     act_death_disp,
     CALL print(calcpos(650,y_pos)), ")",
     CALL print(calcpos(695,y_pos)), lr_death_tot,
     CALL print(calcpos(725,y_pos)),
     "(",
     CALL print(calcpos(735,y_pos)), lr_death_rat_disp,
     CALL print(calcpos(765,y_pos)), ")"
   ENDFOR
   row + 1, y_pos = (y_pos+ 10)
   IF (y_pos > 500)
    BREAK, y_pos = 161
   ENDIF
   CALL print(calcpos(30,y_pos)), "Hospital Risk Range", array_size = size(hosp_risk->type,5)
   FOR (x = 1 TO array_size)
     IF (y_pos > 500)
      BREAK, y_pos = 161
     ENDIF
     row + 1, y_pos = (y_pos+ 10), cnt_disp = format(hosp_risk->type[x].count,"####;r"),
     sim_cnt_disp = format(hosp_risk->type[x].sim_count,"####;r"), cnt_rat = format(((100 * hosp_risk
      ->type[x].count)/ hosp_risk->total_cnt),"####%"), act_death_tot_disp = format(hosp_risk->type[
      x].act_death_tot,"####;r"),
     act_death_disp = format((100 * hosp_risk->type[x].act_death_avg),"####.##;r"),
     sim_act_death_tot_disp = format(hosp_risk->type[x].sim_act_death_tot,"####;r"),
     sim_act_death_disp = format((100 * hosp_risk->type[x].sim_act_death_avg),"####.##;r"),
     ntl_death_disp = format((100 * hosp_risk->type[x].nat_death_avg),"####.##;r"), sim_death_disp =
     format((100 * hosp_risk->type[x].sim_death_avg),"####.##;r"), ntl_rat_disp = format((hosp_risk->
      type[x].act_death_avg/ hosp_risk->type[x].nat_death_avg),"###.##;r"),
     ntl_pstring = hosp_risk->type[x].nat_p_string, sim_pstring = hosp_risk->type[x].sim_p_string,
     sim_rat_disp = format((hosp_risk->type[x].sim_act_death_avg/ hosp_risk->type[x].sim_death_avg),
      "###.##;r"),
     nat_out_disp = format(hosp_risk->type[x].nat_out,"####;r"), nat_out_rat_disp = format(((100 *
      hosp_risk->type[x].nat_out)/ hosp_risk->total_cnt),"###.#%"), sim_out_disp = format(hosp_risk
      ->type[x].sim_out,"####;r"),
     sim_out_rat_disp = format(((100 * hosp_risk->type[x].sim_out)/ hosp_risk->total_cnt),"###.#%"),
     CALL print(calcpos(45,y_pos)), icu_risk->type[x].name,
     CALL print(calcpos(130,y_pos)),
     CALL print(calcpos(150,y_pos)), cnt_disp,
     CALL print(calcpos(190,y_pos)), cnt_rat,
     CALL print(calcpos(240,y_pos)),
     sim_cnt_disp,
     CALL print(calcpos(290,y_pos)), act_death_disp,
     CALL print(calcpos(330,y_pos)), "/",
     CALL print(calcpos(325,y_pos)),
     ntl_death_disp, row + 1,
     CALL print(calcpos(370,y_pos)),
     "=",
     CALL print(calcpos(375,y_pos)), ntl_rat_disp,
     CALL print(calcpos(440,y_pos)), sim_act_death_disp,
     CALL print(calcpos(480,y_pos)),
     "/",
     CALL print(calcpos(475,y_pos)), sim_death_disp,
     CALL print(calcpos(520,y_pos)), "=", row + 1,
     CALL print(calcpos(525,y_pos)), sim_rat_disp,
     CALL print(calcpos(580,y_pos)),
     act_death_tot_disp,
     CALL print(calcpos(610,y_pos)), "(",
     CALL print(calcpos(612,y_pos)), act_death_disp,
     CALL print(calcpos(650,y_pos)),
     ")"
   ENDFOR
  FOOT PAGE
   row + 1, y_pos = 510, row + 1,
   y_pos = (y_pos+ 10), p_line3 = "# Pts w/ Similar Preds -- excludes patients with CABG predictions",
   row + 1,
   y_pos = (y_pos+ 10), row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(45,y_pos)), p_line3, row + 1,
   y_pos = (y_pos+ 10), page_line = concat("----------- Page   ",trim(cnvtstring(curpage),3),
    "  ----------"),
   CALL print(calcpos(300,y_pos)),
   page_line
  WITH dio = postscript, maxcol = 910, maxrow = 800
 ;end select
END GO
