CREATE PROGRAM dcp_arpt_10_unit_event_summ_o:dba
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
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD PAGE
   x_pos = 0, y_pos = 36, col 0,
   font110c, row + 1,
   CALL print(calcpos(30,y_pos)),
   rpt_params->gen_on,
   CALL print(calcpos(280,y_pos)), "APACHE For ICU",
   CALL print(calcpos(400,y_pos)), "By Module: dcp_arpt_10_unit_event_summ", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(285,y_pos)), "QA/UR Report",
   row + 1, y_pos = (y_pos+ 15), col 0,
   font80c, row + 1,
   CALL print(calcpos(210,y_pos)),
   "Unit Adverse Events Summary", row + 1, y_pos = (y_pos+ 15),
   col 0, font110c, row + 1,
   CALL print(calcpos(170,y_pos)), rpt_params->date_type_range_disp, row + 1,
   y_pos = (y_pos+ 15), line = fillstring(180,"-"),
   CALL print(calcpos(30,y_pos)),
   line, row + 1, y_pos = (y_pos+ 15),
   len = size(rpt_params->org_name,1), x_pos = (300 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->org_name, row + 1, y_pos = (y_pos+ 10),
   len = size(rpt_params->unit_disp,1), x_pos = (300 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->unit_disp
  DETAIL
   row + 1, y_pos = (y_pos+ 25),
   CALL print(calcpos(30,y_pos)),
   "Total number of Admissions (which include readmissions):", tot_admit_disp = format(risk_record->
    total_admit,"######"),
   CALL print(calcpos(400,y_pos)),
   tot_admit_disp, row + 1, y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "Number of Readmissions:", tot_readmit_disp = format(risk_record->
    total_readmit,"######"),
   CALL print(calcpos(400,y_pos)), tot_readmit_disp, row + 2,
   y_pos = (y_pos+ 20),
   CALL print(calcpos(110,y_pos)), "Total",
   CALL print(calcpos(160,y_pos)), "Total",
   CALL print(calcpos(220,y_pos)),
   "% Total",
   CALL print(calcpos(320,y_pos)), "Total",
   CALL print(calcpos(370,y_pos)), "Total",
   CALL print(calcpos(440,y_pos)),
   "% Total", y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "Event",
   CALL print(calcpos(110,y_pos)), " Pts  /",
   CALL print(calcpos(160,y_pos)), "Admits  =",
   CALL print(calcpos(220,y_pos)),
   " Admits",
   CALL print(calcpos(320,y_pos)), " Occ   /",
   CALL print(calcpos(370,y_pos)), "Events   =",
   CALL print(calcpos(440,y_pos)),
   " Events", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), line, row + 1,
   y_pos = (y_pos+ 10), array_size = size(adverse_event_record->event_cd,5)
   FOR (x = 1 TO array_size)
     tot_pat_disp = format(adverse_event_record->event_cd[x].pat_count,"######"), ratio = ((
     adverse_event_record->event_cd[x].pat_count * 100.0)/ risk_record->total_admit), ratio_disp =
     format(ratio,"####.##%"),
     tot_event_occ_disp = format(adverse_event_record->event_cd[x].event_count,"######"),
     tot_occ_disp = format(adverse_event_record->total_events,"######"), ratio2 = ((
     adverse_event_record->event_cd[x].event_count * 100.0)/ adverse_event_record->total_events),
     ratio2_disp = format(ratio2,"####.##%"),
     CALL print(calcpos(30,y_pos)), adverse_event_record->event_cd[x].event_name,
     CALL print(calcpos(100,y_pos)), tot_pat_disp,
     CALL print(calcpos(150,y_pos)),
     tot_admit_disp,
     CALL print(calcpos(220,y_pos)), ratio_disp,
     CALL print(calcpos(300,y_pos)), tot_event_occ_disp,
     CALL print(calcpos(350,y_pos)),
     tot_occ_disp,
     CALL print(calcpos(440,y_pos)), ratio2_disp,
     row + 1, y_pos = (y_pos+ 10)
   ENDFOR
   CALL print(calcpos(30,y_pos)), line, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "Totals",
   total_pats_disp = format(adverse_event_record->total_pats,"######"),
   CALL print(calcpos(100,y_pos)), total_pats_disp,
   CALL print(calcpos(300,y_pos)), tot_occ_disp
  WITH dio = postscript, maxrow = 75, maxcol = 600,
   nocounter
 ;end select
END GO
