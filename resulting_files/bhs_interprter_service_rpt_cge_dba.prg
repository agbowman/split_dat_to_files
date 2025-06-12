CREATE PROGRAM bhs_interprter_service_rpt_cge:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
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
     2 encntr_t = vc
   1 encntr_cnt = i4
   1 encntr_qual[*]
     2 encntr_id = f8
     2 encntr_t = vc
     2 ce_cnt = i4
     2 ce_qual[*]
       3 language = vc
       3 interpreter = vc
       3 unit = vc
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
       3 inp_cnt = i4
       3 outp_cnt = i4
       3 e_type = vc
   1 max_ce_cnt = i4
   1 english_cnt = i4
   1 inpatient_cnt = i4
   1 outpatient_cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE inter_start_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATIONSTARTDATETIME"))
 DECLARE inter_end_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATATIONENDDATETIME"))
 DECLARE language_spoken_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKENV001"))
 DECLARE inter_agency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "AGENCYPROVIDINGINTERPRETATION"))
 DECLARE encntr_type = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ENCOUNTERTYPE"))
 DECLARE start_date_string = vc
 DECLARE end_date_string = vc
 DECLARE email_list = vc
 DECLARE t_line = vc
 DECLARE l_line = vc
 SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
 SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (20))
 SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
 SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
 SET email_list = "clemente.gilbert-espada@baystatehealth.org"
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
     AND ce.event_cd=inter_start_tm_cd
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
 SELECT INTO TABLE t_encntrs
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
  end_min = substring(13,2,ce1.result_val), ce3_null = nullind(ce3.clinical_event_id)
  FROM t_encntrs t,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   clinical_event ce4,
   encntr_loc_hist elh,
   prsnl p
  PLAN (t)
   JOIN (ce
   WHERE ce.encntr_id=t.encntr_id
    AND ce.event_cd=inter_start_tm_cd
    AND ce.event_tag != "In Error")
   JOIN (ce1
   WHERE ce1.encntr_id=ce.encntr_id
    AND ((ce1.parent_event_id+ 0)=ce.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.event_cd=inter_end_tm_cd
    AND ce1.event_tag != "In Error")
   JOIN (ce2
   WHERE ce2.encntr_id=ce.encntr_id
    AND ((ce2.parent_event_id+ 0)=ce.parent_event_id)
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce2.event_cd=language_spoken_cd
    AND ce2.result_val > ""
    AND ce2.event_tag != "In Error")
   JOIN (ce3
   WHERE ce3.encntr_id=outerjoin(ce.encntr_id)
    AND ((ce3.parent_event_id+ 0)=outerjoin(ce.parent_event_id))
    AND ce3.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce3.event_cd=outerjoin(inter_agency_cd)
    AND ce3.result_val > outerjoin("")
    AND ce3.event_tag != outerjoin("In Error"))
   JOIN (ce4
   WHERE ce4.encntr_id=outerjoin(ce.encntr_id)
    AND ((ce4.parent_event_id+ 0)=outerjoin(ce.parent_event_id))
    AND ce4.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce4.event_cd=outerjoin(encntr_type)
    AND ce4.result_val > outerjoin("")
    AND ce4.event_tag != outerjoin("In Error"))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND ((nullind(ce3.clinical_event_id) != 1) OR (p.active_ind=1
    AND ((p.end_effective_dt_tm > cnvtdatetime(t_record->beg_date)) OR (p.active_status_cd=188))
    AND p.position_cd IN (227466043, 227463714, 227464173, 227479880, 227479598,
   227479357, 227478988, 227479223))) )
  ORDER BY ce.encntr_id, ce.clinical_event_id, elh.encntr_loc_hist_id
  HEAD ce.encntr_id
   t_record->encntr_cnt = (t_record->encntr_cnt+ 1)
   IF (mod(t_record->encntr_cnt,100)=1)
    stat = alterlist(t_record->encntr_qual,(t_record->encntr_cnt+ 99))
   ENDIF
   idx = t_record->encntr_cnt, t_record->encntr_qual[idx].encntr_id = ce.encntr_id, t_record->
   encntr_qual[idx].encntr_t = ce.event_tag
  HEAD ce.clinical_event_id
   start_date_string = concat(start_day,"-",start_month,"-",start_year,
    " ",start_hour,":",start_min), end_date_string = concat(end_day,"-",end_month,"-",end_year,
    " ",end_hour,":",end_min), t_record->encntr_qual[idx].ce_cnt = (t_record->encntr_qual[idx].ce_cnt
   + 1)
   IF (mod(t_record->encntr_qual[idx].ce_cnt,10)=1)
    stat = alterlist(t_record->encntr_qual[idx].ce_qual,(t_record->encntr_qual[idx].ce_cnt+ 9))
   ENDIF
   idx2 = t_record->encntr_qual[idx].ce_cnt, t_record->encntr_qual[idx].ce_qual[idx2].language = ce2
   .result_val
   IF (ce2.result_val="English")
    t_record->english_cnt = (t_record->english_cnt+ 1)
   ENDIF
   t_record->encntr_qual[idx].ce_qual[idx2].start_dt_tm = cnvtdatetime(start_date_string), t_record->
   encntr_qual[idx].ce_qual[idx2].end_dt_tm = cnvtdatetime(end_date_string)
   IF (ce3_null=1)
    t_record->encntr_qual[idx].ce_qual[idx2].interpreter = p.name_full_formatted
   ELSE
    t_record->encntr_qual[idx].ce_qual[idx2].interpreter = ce3.result_val
   ENDIF
   IF (ce4.result_val="Inpatient")
    t_record->encntr_qual[idx].ce_qual[idx2].inp_cnt = (t_record->encntr_qual[idx].ce_qual[idx2].
    inp_cnt+ 1)
   ELSEIF (ce4.result_val="Outpatient")
    t_record->encntr_qual[idx].ce_qual[idx2].outp_cnt = (t_record->encntr_qual[idx].ce_qual[idx2].
    outp_cnt+ 1)
   ENDIF
   t_record->encntr_qual[idx].ce_qual[idx2].e_type = trim(ce4.event_tag)
  HEAD elh.encntr_loc_hist_id
   IF (elh.beg_effective_dt_tm <= cnvtdatetime(start_date_string)
    AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(end_date_string)))
    t_record->encntr_qual[idx].ce_qual[idx2].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
   ENDIF
  FOOT  ce.encntr_id
   stat = alterlist(t_record->encntr_qual[idx].ce_qual,t_record->encntr_qual[idx].ce_cnt)
   IF ((idx2 > t_record->max_ce_cnt))
    t_record->max_ce_cnt = idx2
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->encntr_qual,t_record->encntr_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(t_record)
 SELECT INTO "language_per_unit.xls"
  language = t_record->encntr_qual[d.seq].ce_qual[d1.seq].language, unit = substring(1,200,t_record->
   encntr_qual[d.seq].ce_qual[d1.seq].unit), type =
  IF ((t_record->encntr_qual[d.seq].ce_qual[d1.seq].e_type="Inpatient")) "1"
  ELSEIF ((t_record->encntr_qual[d.seq].ce_qual[d1.seq].e_type="Outpatient")) "2"
  ELSE "3"
  ENDIF
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   (dummyt d1  WITH seq = t_record->max_ce_cnt)
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= t_record->encntr_qual[d.seq].ce_cnt)
    AND (t_record->encntr_qual[d.seq].ce_qual[d1.seq].language != "English"))
  ORDER BY language, unit, d.seq,
   d1.seq
  HEAD REPORT
   t_line = concat("Interpreter Services",char(9)), col 0, t_line,
   t_line = concat("Language / Unit ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Language",char(9),"Unit",char(9),"Inpatient",
    char(9),"Outpatient",char(9),"Patients",char(9),
    "Sessions",char(9),"Minutes",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_inpt_cnt = 0, total_outp_cnt = 0, inpt_cnt = 0,
   outp_cnt = 0
  HEAD language
   l_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].language),char(9))
  HEAD unit
   patient_cnt = 0, sessions_cnt = 0, minutes_cnt = 0,
   inpt_cnt = 0, outp_cnt = 0, t_line = concat(l_line,trim(unit),char(9))
  HEAD d.seq
   patient_cnt = (patient_cnt+ 1)
   IF (type="1")
    inpt_cnt = (inpt_cnt+ 1)
   ELSEIF (type="2")
    outp_cnt = (outp_cnt+ 1)
   ENDIF
  HEAD d1.seq
   sessions_cnt = (sessions_cnt+ 1), minutes_cnt = (minutes_cnt+ datetimediff(t_record->encntr_qual[d
    .seq].ce_qual[d1.seq].end_dt_tm,t_record->encntr_qual[d.seq].ce_qual[d1.seq].start_dt_tm,4))
  FOOT  unit
   t_line = concat(t_line,cnvtstring(inpt_cnt),char(9),cnvtstring(outp_cnt),char(9),
    trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(9),trim(cnvtstring(
      minutes_cnt)),
    char(9)), row + 1, col 0,
   t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
   total_sessions_cnt+ sessions_cnt),
   total_minutes_cnt = (total_minutes_cnt+ minutes_cnt), total_inpt_cnt = (total_inpt_cnt+ inpt_cnt),
   total_outp_cnt = (total_outp_cnt+ outp_cnt)
  FOOT REPORT
   t_line = concat("Totals",char(9),char(9),cnvtstring(total_inpt_cnt),char(9),
    cnvtstring(total_outp_cnt),char(9),trim(cnvtstring(total_patient_cnt)),char(9),trim(cnvtstring(
      total_sessions_cnt)),
    char(9),trim(cnvtstring(total_minutes_cnt)),char(9)), row + 1, col 0,
   t_line
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 SELECT INTO "patients_per_interpreter.xls"
  interpreter = t_record->encntr_qual[d.seq].ce_qual[d1.seq].interpreter, type =
  IF ((t_record->encntr_qual[d.seq].ce_qual[d1.seq].e_type="Inpatient")) "1"
  ELSEIF ((t_record->encntr_qual[d.seq].ce_qual[d1.seq].e_type="Outpatient")) "2"
  ELSE "3"
  ENDIF
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   (dummyt d1  WITH seq = t_record->max_ce_cnt)
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= t_record->encntr_qual[d.seq].ce_cnt)
    AND (t_record->encntr_qual[d.seq].ce_qual[d1.seq].language != "English"))
  ORDER BY interpreter, d.seq, d1.seq
  HEAD REPORT
   t_line = concat("Interpreter Services",char(9)), col 0, t_line,
   t_line = concat("Patients / Interpreter ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Interpreter",char(9),"Patients",char(9),"Inpatient",
    char(9),"Outpatient",char(9),"Sessions",char(9),
    "0000 - 0200",char(9),"0200 - 0400",char(9),"0400 - 0600",
    char(9),"0600 - 0800",char(9),"0800 - 1000",char(9),
    "1000 - 1200",char(9),"1200 - 1400",char(9),"1400 - 1600",
    char(9),"1600 - 1800",char(9),"1800 - 2000",char(9),
    "2000 - 2200",char(9),"2200 - 2400",char(9),"Minutes",
    char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_0_hour = 0, total_2_hour = 0, total_4_hour = 0,
   total_6_hour = 0, total_8_hour = 0, total_10_hour = 0,
   total_12_hour = 0, total_14_hour = 0, total_16_hour = 0,
   total_18_hour = 0, total_20_hour = 0, total_22_hour = 0
  HEAD interpreter
   t_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].interpreter),char(9)),
   patient_cnt = 0, sessions_cnt = 0,
   minutes_cnt = 0, 0_hour = 0, 2_hour = 0,
   4_hour = 0, 6_hour = 0, 8_hour = 0,
   10_hour = 0, 12_hour = 0, 14_hour = 0,
   16_hour = 0, 18_hour = 0, 20_hour = 0,
   22_hour = 0, inpt_cnt = 0, outp_cnt = 0
  HEAD d.seq
   patient_cnt = (patient_cnt+ 1)
   IF (type="1")
    inpt_cnt = (inpt_cnt+ 1)
   ELSEIF (type="2")
    outp_cnt = (outp_cnt+ 1)
   ENDIF
  HEAD d1.seq
   t_st_tm = t_record->encntr_qual[d.seq].ce_qual[d1.seq].start_dt_tm, t_minutes = datetimediff(
    t_record->encntr_qual[d.seq].ce_qual[d1.seq].end_dt_tm,t_record->encntr_qual[d.seq].ce_qual[d1
    .seq].start_dt_tm,4), sessions_cnt = (sessions_cnt+ 1),
   minutes_cnt = (minutes_cnt+ t_minutes)
   IF (hour(t_st_tm) >= 0
    AND hour(t_st_tm) < 2)
    0_hour = (0_hour+ t_minutes), total_0_hour = (total_0_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 2
    AND hour(t_st_tm) < 4)
    2_hour = (2_hour+ t_minutes), total_2_hour = (total_2_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 4
    AND hour(t_st_tm) < 6)
    4_hour = (4_hour+ t_minutes), total_4_hour = (total_4_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 6
    AND hour(t_st_tm) < 8)
    6_hour = (6_hour+ t_minutes), total_6_hour = (total_6_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 8
    AND hour(t_st_tm) < 10)
    8_hour = (8_hour+ t_minutes), total_8_hour = (total_8_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 10
    AND hour(t_st_tm) < 12)
    10_hour = (10_hour+ t_minutes), total_10_hour = (total_10_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 12
    AND hour(t_st_tm) < 14)
    12_hour = (12_hour+ t_minutes), total_12_hour = (total_12_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 14
    AND hour(t_st_tm) < 16)
    14_hour = (14_hour+ t_minutes), total_14_hour = (total_14_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 16
    AND hour(t_st_tm) < 18)
    16_hour = (16_hour+ t_minutes), total_16_hour = (total_16_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 18
    AND hour(t_st_tm) < 20)
    18_hour = (18_hour+ t_minutes), total_18_hour = (total_18_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 20
    AND hour(t_st_tm) < 22)
    20_hour = (20_hour+ t_minutes), total_20_hour = (total_20_hour+ t_minutes)
   ELSEIF (hour(t_st_tm) >= 22
    AND hour(t_st_tm) < 24)
    22_hour = (22_hour+ t_minutes), total_22_hour = (total_22_hour+ t_minutes)
   ENDIF
  FOOT  interpreter
   t_line = concat(t_line,trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(inpt_cnt)),char(9),
    trim(cnvtstring(outp_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(9),trim(cnvtstring(0_hour)
     ),
    char(9),trim(cnvtstring(2_hour)),char(9),trim(cnvtstring(4_hour)),char(9),
    trim(cnvtstring(6_hour)),char(9),trim(cnvtstring(8_hour)),char(9),trim(cnvtstring(10_hour)),
    char(9),trim(cnvtstring(12_hour)),char(9),trim(cnvtstring(14_hour)),char(9),
    trim(cnvtstring(16_hour)),char(9),trim(cnvtstring(18_hour)),char(9),trim(cnvtstring(20_hour)),
    char(9),trim(cnvtstring(22_hour)),char(9),trim(cnvtstring(minutes_cnt)),char(9)), row + 1, col 0,
   t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
   total_sessions_cnt+ sessions_cnt),
   total_minutes_cnt = (total_minutes_cnt+ minutes_cnt)
  FOOT REPORT
   t_line = concat("Totals",char(9),trim(cnvtstring(total_patient_cnt)),char(9),trim(cnvtstring(
      total_sessions_cnt)),
    char(9),trim(cnvtstring(total_0_hour)),char(9),trim(cnvtstring(total_2_hour)),char(9),
    trim(cnvtstring(total_4_hour)),char(9),trim(cnvtstring(total_6_hour)),char(9),trim(cnvtstring(
      total_8_hour)),
    char(9),trim(cnvtstring(total_10_hour)),char(9),trim(cnvtstring(total_12_hour)),char(9),
    trim(cnvtstring(total_14_hour)),char(9),trim(cnvtstring(total_16_hour)),char(9),trim(cnvtstring(
      total_18_hour)),
    char(9),trim(cnvtstring(total_20_hour)),char(9),trim(cnvtstring(total_22_hour)),char(9),
    trim(cnvtstring(total_minutes_cnt)),char(9)), row + 1, col 0,
   t_line, unique_pats = (t_record->encntr_cnt - t_record->english_cnt), t_line = concat(
    "Unique Patient Count",char(9),trim(cnvtstring(unique_pats)),char(9)),
   row + 1, row + 1, col 0,
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 IF ((t_record->english_cnt=0))
  SELECT INTO "english_per_interpreter.xls"
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    t_line = concat("Interpreter Services",char(9)), col 0, t_line,
    t_line = concat("English / Interpreter ",char(9)), row + 1, col 0,
    t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
      end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
    col 0, t_line, t_line = "No English Interpreted",
    row + 1, col 0, t_line
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "english_per_interpreter.xls"
   interpreter = t_record->encntr_qual[d.seq].ce_qual[d1.seq].interpreter
   FROM (dummyt d  WITH seq = t_record->encntr_cnt),
    (dummyt d1  WITH seq = t_record->max_ce_cnt)
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= t_record->encntr_qual[d.seq].ce_cnt)
     AND (t_record->encntr_qual[d.seq].ce_qual[d1.seq].language="English"))
   ORDER BY interpreter, d.seq, d1.seq
   HEAD REPORT
    t_line = concat("Interpreter Services",char(9)), col 0, t_line,
    t_line = concat("English / Interpreter ",char(9)), row + 1, col 0,
    t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
      end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
    col 0, t_line, t_line = concat("Interpreter",char(9),"Patients",char(9),"Sessions",
     char(9),"Minutes",char(9)),
    row + 1, col 0, t_line,
    total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0
   HEAD interpreter
    t_line = concat(trim(t_record->encntr_qual[d.seq].ce_qual[d1.seq].interpreter),char(9)),
    patient_cnt = 0, sessions_cnt = 0,
    minutes_cnt = 0
   HEAD d.seq
    patient_cnt = (patient_cnt+ 1)
   HEAD d1.seq
    t_st_tm = t_record->encntr_qual[d.seq].ce_qual[d1.seq].start_dt_tm, t_minutes = datetimediff(
     t_record->encntr_qual[d.seq].ce_qual[d1.seq].end_dt_tm,t_record->encntr_qual[d.seq].ce_qual[d1
     .seq].start_dt_tm,4), sessions_cnt = (sessions_cnt+ 1),
    minutes_cnt = (minutes_cnt+ t_minutes)
   FOOT  interpreter
    t_line = concat(t_line,trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(
      9),
     trim(cnvtstring(minutes_cnt)),char(9)), row + 1, col 0,
    t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
    total_sessions_cnt+ sessions_cnt),
    total_minutes_cnt = (total_minutes_cnt+ minutes_cnt)
   FOOT REPORT
    t_line = concat("Totals",char(9),trim(cnvtstring(total_patient_cnt)),char(9),trim(cnvtstring(
       total_sessions_cnt)),
     char(9),trim(cnvtstring(total_minutes_cnt)),char(9)), row + 1, col 0,
    t_line, t_line = concat("Unique Patient Count",char(9),trim(cnvtstring(t_record->english_cnt)),
     char(9)), row + 1,
    row + 1, col 0, t_line
   WITH nocounter, maxcol = 1000
  ;end select
 ENDIF
 IF (findfile("language_per_unit.xls")=1
  AND findfile("patients_per_interpreter.xls")=1
  AND findfile("english_per_interpreter.xls")=1)
  SET subject_line = concat("Interpreter Reports ",format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",
   format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat("(uuencode language_per_unit.xls language_per_unit.xls; ",
   "uuencode patients_per_interpreter.xls patients_per_interpreter.xls; ",
   "uuencode english_per_interpreter.xls english_per_interpreter.xls;) "," | mailx -s ",'"',
   subject_line,'" ',email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("language_per_unit.xls")
  SET stat = remove("patients_per_interpreter.xls")
  SET stat = remove("english_per_interpreter.xls")
 ENDIF
 DROP TABLE t_encntrs
 SET dclcom = "rm -f t_encntrs*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
#exit_script
 SET reply->status_data[1].status = "S"
END GO
