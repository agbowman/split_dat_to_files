CREATE PROGRAM bhs_spiritual_services_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 action_dt_tm = dq8
   1 t_beg_date = dq8
   1 t_end_date = dq8
   1 t_encntr_cnt = i4
   1 t_encntr_qual[*]
     2 encntr_id = f8
   1 encntr_cnt = i4
   1 encntr_qual[*]
     2 encntr_id = f8
     2 ce_cnt = i4
     2 ce_qual[*]
       3 ce_parent_id = f8
       3 religion = vc
       3 staff = vc
       3 unit = vc
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
       3 order_id = f8
   1 max_ce_cnt = i4
   1 dta1_cnt = i4
   1 dta2_cnt = i4
   1 dta3_cnt = i4
   1 dta4_cnt = i4
   1 dta5_cnt = i4
   1 dta6_cnt = i4
   1 dta7_cnt = i4
   1 dta8_cnt = i4
   1 dta9_cnt = i4
   1 dta10_cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE spir_serv_start_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STARTTIMESPIRITUALSERVICE"))
 DECLARE spir_serv_end_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENDTIMESPIRITUALSERVICE"))
 DECLARE spir_family_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FAMILYOTHERSPRESENTSPIRITUALSERVICE"))
 DECLARE religious_affil_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSAFFILIATION"))
 DECLARE spir_staff_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STAFFPRESENTSPIRITUALSERVICE"))
 DECLARE consult_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORSPIRITUALREFERRALCONSULT"))
 DECLARE source_spirit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SOURCESOFSPIRITUALSUPPORT"))
 DECLARE spirit_concerns_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALCONCERNS"))
 DECLARE spirit_intervention_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERVENTIONSPIRITUALSERVICES"))
 DECLARE spirit_sacrements_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSACRAMENTALRESOURCES"))
 DECLARE spirit_visit_summary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VISITSUMMARYSPIRITUALSERVICES"))
 DECLARE spirit_future_plan_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FUTUREPASTORALPLAN"))
 DECLARE spirit_add_request_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALCONTACTREQUEST"))
 DECLARE spirit_add_resources_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALRELIGIOUSRESOURCES"))
 DECLARE start_date_string = vc
 DECLARE end_date_string = vc
 DECLARE email_list = vc
 DECLARE r_line = vc
 DECLARE s_line = vc
 DECLARE t_line = vc
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (15))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list = trim( $1)
 ENDIF
 SET days_cnt = ceil(datetimediff(t_record->end_date,t_record->beg_date))
 SET t_record->t_beg_date = t_record->beg_date
 FOR (i = 1 TO days_cnt)
  IF (i=1)
   SET t_record->t_end_date = datetimefind(t_record->beg_date,"D","E","E")
  ELSE
   SET t_record->t_beg_date = cnvtdatetime(datetimeadd(t_record->t_beg_date,1))
   SET t_record->t_end_date = cnvtdatetime(datetimefind(t_record->t_beg_date,"D","E","E"))
  ENDIF
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->t_beg_date)
     AND ce.clinsig_updt_dt_tm <= cnvtdatetime(t_record->t_end_date)
     AND ce.event_cd=spir_serv_start_tm_cd
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.event_tag != "In Error")
   ORDER BY ce.encntr_id
   HEAD ce.encntr_id
    t_record->t_encntr_cnt = (t_record->t_encntr_cnt+ 1)
    IF (mod(t_record->t_encntr_cnt,1000)=1)
     stat = alterlist(t_record->t_encntr_qual,(t_record->t_encntr_cnt+ 999))
    ENDIF
    t_record->t_encntr_qual[t_record->t_encntr_cnt].encntr_id = ce.encntr_id
   WITH nocounter
  ;end select
 ENDFOR
 SET stat = alterlist(t_record->t_encntr_qual,t_record->t_encntr_cnt)
 SELECT INTO TABLE t_encntrs2
  encntr_id = t_record->t_encntr_qual[d.seq].encntr_id
  FROM (dummyt d  WITH seq = t_record->t_encntr_cnt)
  PLAN (d)
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->t_encntr_qual,0)
 SELECT INTO "nl:"
  start_year = substring(3,4,ce.result_val), start_month =
  IF (cnvtint(substring(7,2,ce.result_val))=1) "JAN"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=2) "FEB"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=3) "MAR"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=4) "APR"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=5) "MAY"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=6) "JUN"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=7) "JUL"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=8) "AUG"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=9) "SEP"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=10) "OCT"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=11) "NOV"
  ELSEIF (cnvtint(substring(7,2,ce.result_val))=12) "DEC"
  ENDIF
  , start_day = substring(9,2,ce.result_val),
  start_hour = substring(11,2,ce.result_val), start_min = substring(13,2,ce.result_val), end_year =
  substring(3,4,ce1.result_val),
  end_month =
  IF (cnvtint(substring(7,2,ce1.result_val))=1) "JAN"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=2) "FEB"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=3) "MAR"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=4) "APR"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=5) "MAY"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=6) "JUN"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=7) "JUL"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=8) "AUG"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=9) "SEP"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=10) "OCT"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=11) "NOV"
  ELSEIF (cnvtint(substring(7,2,ce1.result_val))=12) "DEC"
  ENDIF
  , end_day = substring(9,2,ce1.result_val), end_hour = substring(11,2,ce1.result_val),
  end_min = substring(13,2,ce1.result_val)
  FROM t_encntrs2 t,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   encntr_loc_hist elh,
   person p
  PLAN (t)
   JOIN (ce
   WHERE ce.encntr_id=t.encntr_id
    AND ce.event_cd=spir_serv_start_tm_cd
    AND ce.event_tag != "In Error")
   JOIN (ce1
   WHERE ce1.encntr_id=ce.encntr_id
    AND ((ce1.parent_event_id+ 0)=ce.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.event_cd=spir_serv_end_tm_cd
    AND ce1.event_tag != "In Error")
   JOIN (ce2
   WHERE ce2.encntr_id=ce.encntr_id
    AND ((ce2.parent_event_id+ 0)=ce.parent_event_id)
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce2.event_cd=religious_affil_cd
    AND ce2.event_tag != "In Error")
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND p.active_ind=1)
  ORDER BY ce.encntr_id, ce.clinical_event_id, elh.encntr_loc_hist_id
  HEAD ce.encntr_id
   t_record->encntr_cnt = (t_record->encntr_cnt+ 1), stat = alterlist(t_record->encntr_qual,t_record
    ->encntr_cnt), idx = t_record->encntr_cnt,
   t_record->encntr_qual[idx].encntr_id = ce.encntr_id
  HEAD ce.clinical_event_id
   start_date_string = concat(start_day,"-",start_month,"-",start_year,
    " ",start_hour,":",start_min), end_date_string = concat(end_day,"-",end_month,"-",end_year,
    " ",end_hour,":",end_min), t_record->encntr_qual[idx].ce_cnt = (t_record->encntr_qual[idx].ce_cnt
   + 1),
   stat = alterlist(t_record->encntr_qual[idx].ce_qual,t_record->encntr_qual[idx].ce_cnt), idx2 =
   t_record->encntr_qual[idx].ce_cnt, t_record->encntr_qual[idx].ce_qual[idx2].ce_parent_id = ce
   .parent_event_id,
   t_record->encntr_qual[idx].ce_qual[idx2].religion = ce2.result_val, t_record->encntr_qual[idx].
   ce_qual[idx2].start_dt_tm = cnvtdatetime(start_date_string), t_record->encntr_qual[idx].ce_qual[
   idx2].end_dt_tm = cnvtdatetime(end_date_string),
   t_record->encntr_qual[idx].ce_qual[idx2].staff = p.name_full_formatted, t_record->encntr_qual[idx]
   .ce_qual[idx2].order_id = ce.order_id
  HEAD elh.encntr_loc_hist_id
   IF (elh.beg_effective_dt_tm <= cnvtdatetime(start_date_string)
    AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(end_date_string)))
    t_record->encntr_qual[idx].ce_qual[idx2].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
   ENDIF
  FOOT  ce.encntr_id
   IF ((idx2 > t_record->max_ce_cnt))
    t_record->max_ce_cnt = idx2
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "staff_per_unit_and_religion.xls"
  religion = t_record->encntr_qual[d.seq].ce_qual[d1.seq].religion, unit = substring(1,200,t_record->
   encntr_qual[d.seq].ce_qual[d1.seq].unit), staff = t_record->encntr_qual[d.seq].ce_qual[d1.seq].
  staff,
  ce_null = nullind(ce.clinical_event_id), ce1_null = nullind(ce1.clinical_event_id)
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   (dummyt d1  WITH seq = t_record->max_ce_cnt),
   encounter e,
   clinical_event ce,
   clinical_event ce1
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= t_record->encntr_qual[d.seq].ce_cnt))
   JOIN (e
   WHERE (e.encntr_id=t_record->encntr_qual[d.seq].encntr_id))
   JOIN (ce
   WHERE ce.encntr_id=outerjoin(e.encntr_id)
    AND ce.parent_event_id=outerjoin(t_record->encntr_qual[d.seq].ce_qual[d1.seq].ce_parent_id)
    AND ce.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce.event_cd=outerjoin(spir_family_cd)
    AND ce.event_tag != outerjoin("In Error"))
   JOIN (ce1
   WHERE ce1.encntr_id=outerjoin(e.encntr_id)
    AND ce1.parent_event_id=outerjoin(t_record->encntr_qual[d.seq].ce_qual[d1.seq].ce_parent_id)
    AND ce1.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce1.event_cd=outerjoin(spir_staff_cd)
    AND ce1.event_tag != outerjoin("In Error"))
  ORDER BY staff, religion, unit,
   d.seq, d1.seq
  HEAD REPORT
   t_line = concat("Spiritual Services",char(9)), col 0, t_line,
   t_line = concat("Staff / Religion and Unit",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Staff Member",char(9),"Religion",char(9),"Unit",
    char(9),"Patients",char(9),"Sessions",char(9),
    "Minutes",char(9),"Average Family Present",char(9),"Average Staff Present",
    char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_family_cnt = 0, total_staff_cnt = 0
  HEAD staff
   s_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].staff),char(9))
  HEAD religion
   r_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].religion),char(9))
  HEAD unit
   patient_cnt = 0, sessions_cnt = 0, minutes_cnt = 0,
   t_line = concat(s_line,r_line,trim(unit),char(9)), family_cnt = 0, staff_cnt = 0
  HEAD d.seq
   patient_cnt = (patient_cnt+ 1)
  HEAD d1.seq
   sessions_cnt = (sessions_cnt+ 1), t_minutes = datetimediff(t_record->encntr_qual[d.seq].ce_qual[d1
    .seq].end_dt_tm,t_record->encntr_qual[d.seq].ce_qual[d1.seq].start_dt_tm,4), minutes_cnt = (
   minutes_cnt+ t_minutes)
   IF (ce_null=0)
    family_cnt = (family_cnt+ cnvtint(ce.result_val))
   ENDIF
   IF (ce1_null=0)
    staff_cnt = (staff_cnt+ cnvtint(ce1.result_val))
   ENDIF
  FOOT  unit
   ave_family = 0, ave_staff = 0
   IF (family_cnt > 0)
    ave_family = cnvtint((family_cnt/ sessions_cnt))
   ENDIF
   IF (staff_cnt > 0)
    ave_staff = cnvtint((staff_cnt/ sessions_cnt))
   ENDIF
   t_line = concat(t_line,trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(9
     ),
    trim(cnvtstring(minutes_cnt)),char(9),trim(cnvtstring(ave_family)),char(9),trim(cnvtstring(
      ave_staff)),
    char(9)), row + 1, col 0,
   t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
   total_sessions_cnt+ sessions_cnt),
   total_minutes_cnt = (total_minutes_cnt+ minutes_cnt), total_family_cnt = (total_family_cnt+
   family_cnt), total_staff_cnt = (total_staff_cnt+ staff_cnt)
  FOOT REPORT
   total_family_ave = cnvtint((total_family_cnt/ total_sessions_cnt)), total_staff_ave = cnvtint((
    total_staff_cnt/ total_sessions_cnt)), t_line = concat("Totals",char(9),char(9),char(9),trim(
     cnvtstring(total_patient_cnt)),
    char(9),trim(cnvtstring(total_sessions_cnt)),char(9),trim(cnvtstring(total_minutes_cnt)),char(9),
    trim(cnvtstring(total_family_ave)),char(9),trim(cnvtstring(total_staff_ave)),char(9)),
   row + 1, col 0, t_line
  WITH format = variable, maxcol = 1000, formfeed = none
 ;end select
 SELECT INTO "patients_per_staff.xls"
  staff = t_record->encntr_qual[d.seq].ce_qual[d1.seq].staff
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   (dummyt d1  WITH seq = t_record->max_ce_cnt)
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= t_record->encntr_qual[d.seq].ce_cnt))
  ORDER BY staff, d.seq, d1.seq
  HEAD REPORT
   t_line = concat("Spiritual Services",char(9)), col 0, t_line,
   t_line = concat("Patients / Staff Member ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Staff Member",char(9),"Patients",char(9),"Sessions",
    char(9),"0000 - 0400",char(9),"0400 - 0800",char(9),
    "0800 - 1200",char(9),"1200 - 1600",char(9),"1600 - 2000",
    char(9),"2000 - 2400",char(9),"Minutes",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_0_hour = 0, total_4_hour = 0, total_8_hour = 0,
   total_12_hour = 0, total_16_hour = 0, total_20_hour = 0,
   total_order_cnt = 0
  HEAD staff
   t_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].staff),char(9)), patient_cnt = 0,
   sessions_cnt = 0,
   minutes_cnt = 0, 0_hour = 0, 4_hour = 0,
   8_hour = 0, 12_hour = 0, 16_hour = 0,
   20_hour = 0
  HEAD d.seq
   patient_cnt = (patient_cnt+ 1)
  HEAD d1.seq
   t_st_tm = t_record->encntr_qual[d.seq].ce_qual[d1.seq].start_dt_tm, t_minutes = datetimediff(
    t_record->encntr_qual[d.seq].ce_qual[d1.seq].end_dt_tm,t_record->encntr_qual[d.seq].ce_qual[d1
    .seq].start_dt_tm,4), sessions_cnt = (sessions_cnt+ 1),
   minutes_cnt = (minutes_cnt+ t_minutes)
   IF (hour(t_st_tm) >= 0
    AND hour(t_st_tm) < 4)
    0_hour = (0_hour+ t_minutes), total_0_hour = (total_0_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 4
    AND hour(t_st_tm) < 8)
    4_hour = (4_hour+ t_minutes), total_4_hour = (total_4_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 8
    AND hour(t_st_tm) < 12)
    8_hour = (8_hour+ t_minutes), total_8_hour = (total_8_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 12
    AND hour(t_st_tm) < 16)
    12_hour = (12_hour+ t_minutes), total_12_hour = (total_12_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 16
    AND hour(t_st_tm) < 20)
    16_hour = (16_hour+ t_minutes), total_16_hour = (total_16_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 20
    AND hour(t_st_tm) < 24)
    20_hour = (20_hour+ t_minutes), total_20_hour = (total_20_hour+ t_minutes)
   ENDIF
   IF ((t_record->encntr_qual[d.seq].ce_qual[d1.seq].order_id > 0))
    total_order_cnt = (total_order_cnt+ 1)
   ENDIF
  FOOT  staff
   t_line = concat(t_line,trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(9
     ),
    trim(cnvtstring(0_hour)),char(9),trim(cnvtstring(4_hour)),char(9),trim(cnvtstring(8_hour)),
    char(9),trim(cnvtstring(12_hour)),char(9),trim(cnvtstring(16_hour)),char(9),
    trim(cnvtstring(20_hour)),char(9),trim(cnvtstring(minutes_cnt)),char(9)), row + 1, col 0,
   t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
   total_sessions_cnt+ sessions_cnt),
   total_minutes_cnt = (total_minutes_cnt+ minutes_cnt)
  FOOT REPORT
   t_line = concat("Totals",char(9),trim(cnvtstring(total_patient_cnt)),char(9),trim(cnvtstring(
      total_sessions_cnt)),
    char(9),trim(cnvtstring(total_0_hour)),char(9),trim(cnvtstring(total_4_hour)),char(9),
    trim(cnvtstring(total_8_hour)),char(9),trim(cnvtstring(total_12_hour)),char(9),trim(cnvtstring(
      total_16_hour)),
    char(9),trim(cnvtstring(total_20_hour)),char(9),trim(cnvtstring(total_minutes_cnt)),char(9)), row
    + 1, col 0,
   t_line, row + 1, row + 1,
   t_line = concat("Total Sessions from an order ",trim(cnvtstring(total_order_cnt))), col 0, t_line
  WITH format = variable, maxcol = 1000, formfeed = none
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=religious_affil_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta1_cnt = (t_record->dta1_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=consult_reason_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta2_cnt = (t_record->dta2_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=source_spirit_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta3_cnt = (t_record->dta3_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_concerns_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta4_cnt = (t_record->dta4_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_intervention_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta5_cnt = (t_record->dta5_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_sacrements_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta6_cnt = (t_record->dta6_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_visit_summary_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta7_cnt = (t_record->dta7_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_future_plan_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta8_cnt = (t_record->dta8_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_add_request_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta9_cnt = (t_record->dta9_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND (ce.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_cd=spirit_add_resources_cd
    AND ce.event_tag != "In Error")
  DETAIL
   t_record->dta10_cnt = (t_record->dta10_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "totals.xls"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   t_line = concat("Spiritual Services",char(9)), col 0, t_line,
   t_line = concat("Category Totals ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Category",char(9),"Count",char(9)),
   row + 1, col 0, t_line,
   t_line = concat("Religious Affiliation",char(9),trim(cnvtstring(t_record->dta1_cnt)),char(9)), row
    + 1, col 0,
   t_line, t_line = concat("Reason for Spiritual Referral/Consult",char(9),trim(cnvtstring(t_record->
      dta2_cnt)),char(9)), row + 1,
   col 0, t_line, t_line = concat("Sources of Spiritual Support",char(9),trim(cnvtstring(t_record->
      dta3_cnt)),char(9)),
   row + 1, col 0, t_line,
   t_line = concat("Spiritual Concerns",char(9),trim(cnvtstring(t_record->dta4_cnt)),char(9)), row +
   1, col 0,
   t_line, t_line = concat("Intervention Spiritual Services",char(9),trim(cnvtstring(t_record->
      dta5_cnt)),char(9)), row + 1,
   col 0, t_line, t_line = concat("Spiritual /Sacramental Resources",char(9),trim(cnvtstring(t_record
      ->dta6_cnt)),char(9)),
   row + 1, col 0, t_line,
   t_line = concat("Visit Summary Spiritual Services",char(9),trim(cnvtstring(t_record->dta7_cnt)),
    char(9)), row + 1, col 0,
   t_line, t_line = concat("Future Pastoral Plan",char(9),trim(cnvtstring(t_record->dta8_cnt)),char(9
     )), row + 1,
   col 0, t_line, t_line = concat("Additional Contact Request",char(9),trim(cnvtstring(t_record->
      dta9_cnt)),char(9)),
   row + 1, col 0, t_line,
   t_line = concat("Additional Religious Resources",char(9),trim(cnvtstring(t_record->dta10_cnt)),
    char(9)), row + 1, col 0,
   t_line
  WITH format = variable, maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("staff_per_unit_and_religion.xls")=1
  AND findfile("patients_per_staff.xls")=1
  AND findfile("totals.xls")=1)
  SET subject_line = concat("Spiritual Reports ",format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",
   format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ',
   '-a "staff_per_unit_and_religion.xls" ','-a "patients_per_staff.xls" ',
   '-a "totals.xls" ',email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("staff_per_unit_and_religion.xls")
  SET stat = remove("patients_per_staff.xls")
  SET stat = remove("totals.xls")
 ENDIF
 DROP TABLE t_encntrs2
 SET dclcom = "rm -f t_encntrs2*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
#exit_script
 SET reply->status_data[1].status = "S"
END GO
