CREATE PROGRAM dcp_arpt_6_mon_unit_util:dba
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
 RECORD risk_record(
   1 risk[*]
     2 ra_id = f8
 )
 RECORD source(
   1 adm_src[*]
     2 location = vc
     2 location_long = vc
     2 pat_cnt = f8
   1 adm_src_final[*]
     2 location = vc
     2 location_long = vc
     2 pat_cnt = f8
 )
 SET operation_count = 0
 SET elective_op = 0
 SET non_elect_op = 0
 SET non_op_count = 0
 SET readmit_count = 0
 SET non_pred_count = 0
 SET last_source = "some junk last source field"
 SET array_count = 0
 SET pat_count = 0
 SET day_count = 0
 SET temp_start = concat(trim(concat(format(month(rpt_params->beg_dt_tm),"##;P0"),"01")),format(year(
    rpt_params->beg_dt_tm),"####;P0"))
 SET temp_month_end = month(rpt_params->beg_dt_tm)
 SET temp_year_end = year(rpt_params->beg_dt_tm)
 IF (temp_month_end=12)
  SET temp_month_end = 1
  SET temp_year_end = (temp_year_end+ 1)
 ELSE
  SET temp_month_end = (temp_month_end+ 1)
 ENDIF
 SET temp_end = concat(trim(concat(format(temp_month_end,"##;P0"),"01")),format(temp_year_end,
   "####;P0"))
 SET rpt_start_dt = cnvtdatetime(cnvtdate2(temp_start,"MMDDYYYY"),0)
 SET temp_end2 = cnvtdatetime(cnvtdate2(temp_end,"MMDDYYYY"),235959)
 SET rpt_end_dt = datetimeadd(cnvtdatetime(temp_end2),- (1))
 SET start_date_disp = format(rpt_start_dt,"mm/dd/yyyy;;d")
 SET end_date_disp = format(rpt_end_dt,"mm/dd/yyyy;;d")
 SET start_date = cnvtdatetime(rpt_start_dt)
 SET end_date = cnvtdatetime(rpt_end_dt)
 SET num_days = datetimediff(rpt_end_dt,rpt_start_dt,1)
 SET bed_count = 0
 SET tmp_start_date = rpt_start_dt
 SET tmp_end_dt = rpt_end_dt
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   (dummyt d  WITH seq = units->cnt)
  PLAN (ra
   WHERE ra.icu_disch_dt_tm >= cnvtdatetime(start_date)
    AND ra.icu_admit_dt_tm <= cnvtdatetime(end_date)
    AND ra.active_ind=1)
   JOIN (d
   WHERE (uar_get_code_display(ra.admit_icu_cd)=units->unit[d.seq].name))
  ORDER BY ra.admit_source DESC
  HEAD REPORT
   array_count = 0, last_source = fillstring(20," ")
  DETAIL
   IF (ra.icu_admit_dt_tm < cnvtdatetime(rpt_start_dt))
    tmp_start_dt = cnvtdatetime(rpt_start_dt)
   ELSE
    tmp_start_dt = cnvtdatetime(ra.icu_admit_dt_tm)
   ENDIF
   IF (ra.icu_disch_dt_tm > cnvtdatetime(rpt_end_dt))
    tmp_end_dt = cnvtdatetime(rpt_end_dt)
   ELSE
    tmp_end_dt = cnvtdatetime(ra.icu_disch_dt_tm)
   ENDIF
   this_day_count = 0, this_day_count = (day(cnvtdatetime(tmp_end_dt)) - day(cnvtdatetime(
     tmp_start_dt)))
   IF (((this_day_count > 0) OR (day(cnvtdatetime(tmp_end_dt))=1)) )
    IF (last_source != ra.admit_source)
     array_count = (array_count+ 1), stat = alterlist(source->adm_src,array_count), source->adm_src[
     array_count].location = ra.admit_source,
     last_source = ra.admit_source
    ENDIF
    pat_count = (pat_count+ 1), stat = alterlist(risk_record->risk,pat_count), risk_record->risk[
    pat_count].ra_id = ra.risk_adjustment_id
    IF (ra.readmit_ind=1)
     readmit_count = (readmit_count+ 1)
    ENDIF
    day_count = (day_count+ this_day_count)
    IF (cnvtdatetime(tmp_start_dt)=cnvtdatetime(rpt_start_dt))
     day_count = (day_count+ 1)
    ENDIF
    IF (((ra.admit_source="RR") OR (ra.admit_source="OR")) )
     operation_count = (operation_count+ 1)
     IF (ra.electivesurgery_ind=1)
      elective_op = (elective_op+ 1)
     ELSE
      non_elect_op = (non_elect_op+ 1)
     ENDIF
    ELSE
     non_op_count = (non_op_count+ 1)
    ENDIF
    source->adm_src[array_count].pat_cnt = (source->adm_src[array_count].pat_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET source_array_size = size(source->adm_src,5)
 FOR (x = 1 TO source_array_size)
   SET source_cd = 0.0
   SET source_cd = meaning_code(28981,source->adm_src[x].location)
   SET source->adm_src[x].location_long = uar_get_code_display(source_cd)
 ENDFOR
 SET non_pred_count = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   (dummyt d  WITH seq = units->cnt)
  PLAN (ra
   WHERE ra.icu_disch_dt_tm >= cnvtdatetime(start_date)
    AND ra.icu_admit_dt_tm <= cnvtdatetime(end_date)
    AND ra.active_ind=1)
   JOIN (d
   WHERE (uar_get_code_display(ra.admit_icu_cd)=units->unit[d.seq].name))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   IF ((((rad.outcome_status=- (23117))) OR ((((rad.outcome_status=- (23100))) OR ((rad
   .outcome_status=- (23103)))) )) )
    non_pred_count = (non_pred_count+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET source_array_size = size(source->adm_src,5)
 SET stat = alterlist(source->adm_src_final,source_array_size)
 FOR (x = 1 TO source_array_size)
   SET source_cd = 0.0
   SET source_cd = meaning_code(28981,source->adm_src[x].location)
   SET source->adm_src[x].location_long = uar_get_code_display(source_cd)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = source_array_size)
  ORDER BY source->adm_src[d.seq].pat_cnt DESC
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), stat = alterlist(source->adm_src_final,counter), source->adm_src_final[
   counter].location = source->adm_src[d.seq].location,
   source->adm_src_final[counter].location_long = source->adm_src[d.seq].location_long, source->
   adm_src_final[counter].pat_cnt = source->adm_src[d.seq].pat_cnt
  WITH nocounter
 ;end select
 SET font60c = "{COLOR/0}{F/0}{CPI/16^}{LPI/9^}"
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD PAGE
   col 0, font110c, row 2,
   x_pos = 0, y_pos = 36, row + 1,
   y_pos = (y_pos+ 10), gen_on = "                                                      ",
   CALL print(calcpos(30,y_pos)),
   rpt_params->gen_on,
   CALL print(calcpos(280,y_pos)), "APACHE For ICU",
   CALL print(calcpos(410,y_pos)), "By module: dcp_arpt_6_mon_unit_util", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(285,y_pos)), "QA/UR Report",
   row + 1, col 0, font80c,
   y_pos = (y_pos+ 15),
   CALL print(calcpos(230,y_pos)), "Monthly Unit Utilization",
   row + 1, col 0, font110c,
   y_pos = (y_pos+ 15), gen_on = concat(start_date_disp," to ",end_date_disp),
   CALL print(calcpos(255,y_pos)),
   gen_on, row + 1, y_pos = (y_pos+ 15),
   line = fillstring(180,"-"),
   CALL print(calcpos(30,y_pos)), line,
   row + 1, y_pos = (y_pos+ 15), len = size(rpt_params->org_name,1),
   x_pos = (300 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->org_name,
   row + 1, y_pos = (y_pos+ 10), len = size(rpt_params->unit_disp,1),
   x_pos = (300 - (len * 1.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->unit_disp,
   row + 1, y_pos = (y_pos+ 10)
  DETAIL
   col 1, row + 1, y_pos = (y_pos+ 10),
   pat_count_disp = format(pat_count,"#########"), day_count_disp = format(day_count,"#########"),
   row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "Number of ICU patients:",
   CALL print(calcpos(400,y_pos)), pat_count_disp, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "    Includes all ICU patients occupying an ICU bed at midnight",
   row + 1, y_pos = (y_pos+ 10), col 0,
   font60c,
   CALL print(calcpos(30,y_pos)),
   "(includes readmissions but does NOT include patients who were admitted and discharged ",
   CALL print(calcpos(418,y_pos)), "within the same calendar day)", row + 2,
   col 0, font110c, y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "Total Patient Days:",
   CALL print(calcpos(400,y_pos)),
   day_count_disp, row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "     Sum of pts in a bed at midnight for the month", row + 2,
   y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "Number of Beds in Unit:",
   bed_disp = format(units->tot_bed_count,"#########"),
   CALL print(calcpos(400,y_pos)), bed_disp,
   row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(420,y_pos)),
   "Total ICU",
   CALL print(calcpos(510,y_pos)), "%Total ICU",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(270,y_pos)),
   "# Patients",
   CALL print(calcpos(350,y_pos)), "/",
   CALL print(calcpos(420,y_pos)), "Patients",
   CALL print(calcpos(480,y_pos)),
   "=",
   CALL print(calcpos(510,y_pos)), "Admissions",
   row + 1, y_pos = (y_pos+ 10), line2 = fillstring(150,"-"),
   CALL print(calcpos(270,y_pos)), line2, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "A. Admission Source",
   array_size = size(source->adm_src_final,5)
   FOR (x = 1 TO array_size)
     row + 1, y_pos = (y_pos+ 10), row_disp = format(x,"####"),
     CALL print(calcpos(30,y_pos)), row_disp,
     CALL print(calcpos(55,y_pos)),
     source->adm_src_final[x].location_long, count_disp = format(source->adm_src_final[x].pat_cnt,
      "####"),
     CALL print(calcpos(270,y_pos)),
     count_disp,
     CALL print(calcpos(400,y_pos)), pat_count_disp,
     ratio_disp = format(((source->adm_src_final[x].pat_cnt * 100)/ pat_count),"###.##%"),
     CALL print(calcpos(510,y_pos)), ratio_disp
   ENDFOR
   row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)),
   "B. Operative", op_count_disp = format(operation_count,"####"),
   CALL print(calcpos(270,y_pos)),
   op_count_disp,
   CALL print(calcpos(400,y_pos)), pat_count_disp,
   ratio_disp = format(((operation_count * 100)/ pat_count),"###.##%"),
   CALL print(calcpos(510,y_pos)), ratio_disp,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "   1. Elective Surgery", count_disp = format(elective_op,"####"),
   CALL print(calcpos(270,y_pos)),
   count_disp,
   CALL print(calcpos(400,y_pos)), pat_count_disp,
   ratio_disp = format(((elective_op * 100)/ pat_count),"###.##%"),
   CALL print(calcpos(510,y_pos)), ratio_disp,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)),
   "   % Total op pts ",
   CALL print(calcpos(120,y_pos)), count_disp,
   CALL print(calcpos(140,y_pos)), "/",
   CALL print(calcpos(150,y_pos)),
   op_count_disp, op_ratio_disp = format(((elective_op * 100)/ operation_count),"###.##%"),
   CALL print(calcpos(180,y_pos)),
   op_ratio_disp, row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "   2. Emergency Surgery", count_disp = format(non_elect_op,"####"),
   CALL print(calcpos(270,y_pos)), count_disp,
   CALL print(calcpos(400,y_pos)),
   pat_count_disp, ratio_disp = format(((non_elect_op * 100)/ pat_count),"###.##%"),
   CALL print(calcpos(510,y_pos)),
   ratio_disp, row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "   % Total op pts ",
   CALL print(calcpos(120,y_pos)),
   count_disp,
   CALL print(calcpos(140,y_pos)), "/",
   CALL print(calcpos(150,y_pos)), op_count_disp, op_ratio_disp = format(((non_elect_op * 100)/
    operation_count),"###.##%"),
   CALL print(calcpos(180,y_pos)), op_ratio_disp, row + 2,
   y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "C. Non-Operative",
   count_disp = format(non_op_count,"####"),
   CALL print(calcpos(270,y_pos)), count_disp,
   CALL print(calcpos(400,y_pos)), pat_count_disp, ratio_disp = format(((non_op_count * 100)/
    pat_count),"###.##%"),
   CALL print(calcpos(510,y_pos)), ratio_disp, row + 2,
   y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "D. Readmissions",
   count_disp = format(readmit_count,"####"),
   CALL print(calcpos(270,y_pos)), count_disp,
   row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)),
   "E. Non Predictive Patients", count_disp = format(non_pred_count,"####"),
   CALL print(calcpos(270,y_pos)),
   count_disp, row + 2, y_pos = (y_pos+ 20),
   CALL print(calcpos(30,y_pos)), "F. Occupancy By Month (Patients in a bed at Midnight)", row + 2,
   y_pos = (y_pos+ 20),
   CALL print(calcpos(300,y_pos)), "# Beds x",
   CALL print(calcpos(450,y_pos)), "Average", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(200,y_pos)), "Total",
   CALL print(calcpos(300,y_pos)), "Days in",
   CALL print(calcpos(450,y_pos)),
   "Occupancy", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), "Month And Year",
   CALL print(calcpos(200,y_pos)),
   "# Pt Days",
   CALL print(calcpos(300,y_pos)), "Month",
   CALL print(calcpos(450,y_pos)), "Rate", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), line,
   date_disp = format(start_date,"MMMMMMMMM YYYY;;d"), row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(30,y_pos)), date_disp,
   CALL print(calcpos(180,y_pos)),
   day_count_disp, days_disp = concat(format(num_days,"##")," ="), tot_days = (num_days * units->
   tot_bed_count),
   tot_days_disp = format(tot_days,"######"), days_disp_full = concat(bed_disp," x ",days_disp),
   CALL print(calcpos(260,y_pos)),
   days_disp_full, ratio_disp = format(((day_count * 100)/ tot_days),"###.##%"),
   CALL print(calcpos(450,y_pos)),
   ratio_disp, row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(290,y_pos)), tot_days_disp
  FOOT PAGE
   page_string = format(curpage,"###")
  WITH dio = postscript, maxcol = 600
 ;end select
END GO
