CREATE PROGRAM bhs_bs_interpreter_rpt3:dba
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 inter_cnt = i4
   1 inter_qual[*]
     2 encntr_id = f8
   1 spirit_cnt = i4
   1 spirit_qual[*]
     2 encntr_id = f8
 )
 DECLARE inter_min_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOTALMINUTESINTERPRETERSERVICE"))
 DECLARE language_spoken_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKENV001"))
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
 DECLARE indx = i4
 DECLARE loc_pos = i4
 DECLARE e_indx = i2 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 DECLARE t_line = vc
 DECLARE l_line = vc
 DECLARE start_date_string = vc
 DECLARE end_date_string = vc
 DECLARE email = vc
 SET t_record->beg_date = cnvtdatetime("06-Jul-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("10-Jul-2007 23:59:00")
 SET days = ceil(datetimediff(t_record->end_date,t_record->beg_date))
 SET t_day_start = t_record->beg_date
 SET t_day_end = t_record->end_date
 DECLARE small_min = f8
 DECLARE big_max = f8
 SET small_min = 459405460
 SET big_max = 470688646
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinical_event_id >= small_min
    AND ce.clinical_event_id <= big_max
    AND ce.event_cd IN (inter_min_cd, spir_serv_start_tm_cd)
    AND ce.event_tag != "In Error")
  ORDER BY ce.encntr_id
  DETAIL
   IF (ce.event_cd=inter_min_cd)
    loc_pos = 0, loc_pos = locateval(indx,1,t_record->inter_cnt,ce.encntr_id,t_record->inter_qual[
     indx].encntr_id)
    IF (loc_pos=0)
     t_record->inter_cnt = (t_record->inter_cnt+ 1)
     IF (mod(t_record->inter_cnt,10)=1)
      stat = alterlist(t_record->inter_qual,(t_record->inter_cnt+ 9))
     ENDIF
     idx = t_record->inter_cnt
    ELSE
     idx = loc_pos
    ENDIF
    t_record->inter_qual[idx].encntr_id = ce.encntr_id
   ENDIF
   IF (ce.event_cd=spir_serv_start_tm_cd)
    loc_pos = 0, loc_pos = locateval(indx,1,t_record->spirit_cnt,ce.encntr_id,t_record->spirit_qual[
     indx].encntr_id)
    IF (loc_pos=0)
     t_record->spirit_cnt = (t_record->spirit_cnt+ 1)
     IF (mod(t_record->spirit_cnt,10)=1)
      stat = alterlist(t_record->spirit_qual,(t_record->spirit_cnt+ 9))
     ENDIF
     idx = t_record->spirit_cnt
    ELSE
     idx = loc_pos
    ENDIF
    t_record->spirit_qual[idx].encntr_id = ce.encntr_id
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->inter_qual,t_record->inter_cnt), stat = alterlist(t_record->spirit_qual,
    t_record->spirit_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(t_record)
 SET nsize = t_record->inter_cnt
 SET nbucketsize = 200
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->inter_qual,ntotal)
 FOR (i = (nsize+ 1) TO ntotal)
   SET t_record->inter_qual[i].encntr_id = t_record->inter_qual[nsize].encntr_id
 ENDFOR
 SELECT INTO "interpreter_language_per_unit.xls"
  unit = uar_get_code_display(elh.loc_nurse_unit_cd)
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   clinical_event ce1,
   encntr_loc_hist elh
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(e_indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->inter_qual[e_indx].
    encntr_id)
    AND ce.event_cd=inter_min_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((ce.clinsig_updt_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
    AND ce.event_tag != "In Error")
   JOIN (ce1
   WHERE ce1.encntr_id=ce.encntr_id
    AND ((ce1.parent_event_id+ 0)=ce.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.event_cd=language_spoken_cd
    AND ce1.result_val != "English"
    AND ce1.result_val > ""
    AND ce1.event_tag != "In Error")
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.beg_effective_dt_tm <= ce.clinsig_updt_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) > ce.clinsig_updt_dt_tm))
  ORDER BY ce1.result_val, unit, ce.encntr_id,
   ce.clinical_event_id
  HEAD REPORT
   t_line = concat("Interpreter Services",char(9)), col 0, t_line,
   t_line = concat("Language / Unit ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Language",char(9),"Unit",char(9),"Patients",
    char(9),"Sessions",char(9),"Minutes",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0
  HEAD ce1.result_val
   l_line = concat(trim(ce1.result_val),char(9))
  HEAD unit
   patient_cnt = 0, sessions_cnt = 0, minutes_cnt = 0,
   t_line = concat(l_line,trim(unit),char(9))
  HEAD ce.encntr_id
   patient_cnt = (patient_cnt+ 1)
  HEAD ce.clinical_event_id
   sessions_cnt = (sessions_cnt+ 1), minutes_cnt = (minutes_cnt+ cnvtint(ce.result_val))
  FOOT  unit
   t_line = concat(t_line,trim(cnvtstring(patient_cnt)),char(9),trim(cnvtstring(sessions_cnt)),char(9
     ),
    trim(cnvtstring(minutes_cnt)),char(9)), row + 1, col 0,
   t_line, total_patient_cnt = (total_patient_cnt+ patient_cnt), total_sessions_cnt = (
   total_sessions_cnt+ sessions_cnt),
   total_minutes_cnt = (total_minutes_cnt+ minutes_cnt)
  FOOT REPORT
   t_line = concat("Totals",char(9),char(9),trim(cnvtstring(total_patient_cnt)),char(9),
    trim(cnvtstring(total_sessions_cnt)),char(9),trim(cnvtstring(total_minutes_cnt)),char(9)), row +
   1, col 0,
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 SELECT INTO "interpreter_patients_per_interpreter.xls"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   clinical_event ce1,
   prsnl pr,
   person p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(e_indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->inter_qual[e_indx].
    encntr_id)
    AND ce.event_cd=inter_min_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((ce.clinsig_updt_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
    AND ce.event_tag != "In Error")
   JOIN (ce1
   WHERE ce1.encntr_id=ce.encntr_id
    AND ((ce1.parent_event_id+ 0)=ce.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.event_cd=language_spoken_cd
    AND ce1.result_val != "English"
    AND ce1.result_val > ""
    AND ce1.event_tag != "In Error")
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id
    AND pr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1)
  ORDER BY p.name_full_formatted, p.person_id, ce.encntr_id,
   ce.clinical_event_id
  HEAD REPORT
   t_line = concat("Interpreter Services",char(9)), col 0, t_line,
   t_line = concat("Patients / Interpreter ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Interpreter",char(9),"Patients",char(9),"Sessions",
    char(9),"0000 - 0400",char(9),"0400 - 0800",char(9),
    "0800 - 1200",char(9),"1200 - 1600",char(9),"1600 - 2000",
    char(9),"2000 - 2400",char(9),"Minutes",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_0_hour = 0, total_4_hour = 0, total_8_hour = 0,
   total_12_hour = 0, total_16_hour = 0, total_20_hour = 0
  HEAD p.person_id
   t_line = concat(trim(p.name_full_formatted),char(9)), patient_cnt = 0, sessions_cnt = 0,
   minutes_cnt = 0, 0_hour = 0, 4_hour = 0,
   8_hour = 0, 12_hour = 0, 16_hour = 0,
   20_hour = 0
  HEAD ce.encntr_id
   patient_cnt = (patient_cnt+ 1)
  HEAD ce.clinical_event_id
   sessions_cnt = (sessions_cnt+ 1), minutes_cnt = (minutes_cnt+ cnvtint(ce.result_val))
   IF (hour(ce.clinsig_updt_dt_tm) >= 0
    AND hour(ce.clinsig_updt_dt_tm) < 4)
    0_hour = (0_hour+ cnvtint(ce.result_val)), total_0_hour = (total_0_hour+ cnvtint(ce.result_val))
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 4
    AND hour(ce.clinsig_updt_dt_tm) < 8)
    4_hour = (4_hour+ cnvtint(ce.result_val)), total_4_hour = (total_4_hour+ cnvtint(ce.result_val))
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 8
    AND hour(ce.clinsig_updt_dt_tm) < 12)
    8_hour = (8_hour+ cnvtint(ce.result_val)), total_8_hour = (total_8_hour+ cnvtint(ce.result_val))
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 12
    AND hour(ce.clinsig_updt_dt_tm) < 16)
    12_hour = (12_hour+ cnvtint(ce.result_val)), total_12_hour = (total_12_hour+ cnvtint(ce
     .result_val))
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 16
    AND hour(ce.clinsig_updt_dt_tm) < 20)
    16_hour = (16_hour+ cnvtint(ce.result_val)), total_16_hour = (total_16_hour+ cnvtint(ce
     .result_val))
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 20
    AND hour(ce.clinsig_updt_dt_tm) < 24)
    20_hour = (20_hour+ cnvtint(ce.result_val)), total_20_hour = (total_20_hour+ cnvtint(ce
     .result_val))
   ENDIF
  FOOT  p.person_id
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
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 SET nsize = t_record->spirit_cnt
 SET nbucketsize = 40
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->spirit_qual,ntotal)
 FOR (i = (nsize+ 1) TO ntotal)
   SET t_record->spirit_qual[i].encntr_id = t_record->spirit_qual[nsize].encntr_id
 ENDFOR
 SELECT INTO "spiritual_patients_per_personnel.xls"
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
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   clinical_event ce1,
   prsnl pr,
   person p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(e_indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->spirit_qual[e_indx].
    encntr_id)
    AND ce.event_cd=spir_serv_start_tm_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((ce.clinsig_updt_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
    AND ce.event_tag != "In Error")
   JOIN (ce1
   WHERE ce1.encntr_id=ce.encntr_id
    AND ((ce1.parent_event_id+ 0)=ce.parent_event_id)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.event_cd=spir_serv_end_tm_cd
    AND ce1.event_tag != "In Error")
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id
    AND pr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1)
  ORDER BY p.name_full_formatted, p.person_id, ce.encntr_id,
   ce.clinical_event_id
  HEAD REPORT
   t_line = concat("Spiritual Services",char(9)), col 0, t_line,
   t_line = concat("Patients / Spiritual Services Personnel",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Spiritual Personnel",char(9),"Patients",char(9),"Sessions",
    char(9),"0000 - 0400",char(9),"0400 - 0800",char(9),
    "0800 - 1200",char(9),"1200 - 1600",char(9),"1600 - 2000",
    char(9),"2000 - 2400",char(9),"Minutes",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_0_hour = 0, total_4_hour = 0, total_8_hour = 0,
   total_12_hour = 0, total_16_hour = 0, total_20_hour = 0
  HEAD p.person_id
   t_line = concat(trim(p.name_full_formatted),char(9)), patient_cnt = 0, sessions_cnt = 0,
   minutes_cnt = 0, 0_hour = 0, 4_hour = 0,
   8_hour = 0, 12_hour = 0, 16_hour = 0,
   20_hour = 0
  HEAD ce.encntr_id
   patient_cnt = (patient_cnt+ 1)
  HEAD ce.clinical_event_id
   start_date_string = concat(start_day,"-",start_month,"-",start_year,
    " ",start_hour,":",start_min), end_date_string = concat(end_day,"-",end_month,"-",end_year,
    " ",end_hour,":",end_min), sessions_cnt = (sessions_cnt+ 1),
   t_minutes = datetimediff(cnvtdatetime(end_date_string),cnvtdatetime(start_date_string),4),
   minutes_cnt = (minutes_cnt+ t_minutes)
   IF (hour(ce.clinsig_updt_dt_tm) >= 0
    AND hour(ce.clinsig_updt_dt_tm) < 4)
    0_hour = (0_hour+ t_minutes), total_0_hour = (total_0_hour+ t_minutes)
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 4
    AND hour(ce.clinsig_updt_dt_tm) < 8)
    4_hour = (4_hour+ t_minutes), total_4_hour = (total_4_hour+ t_minutes)
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 8
    AND hour(ce.clinsig_updt_dt_tm) < 12)
    8_hour = (8_hour+ t_minutes), total_8_hour = (total_8_hour+ t_minutes)
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 12
    AND hour(ce.clinsig_updt_dt_tm) < 16)
    12_hour = (12_hour+ t_minutes), total_12_hour = (total_12_hour+ t_minutes)
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 16
    AND hour(ce.clinsig_updt_dt_tm) < 20)
    16_hour = (16_hour+ t_minutes), total_16_hour = (total_16_hour+ t_minutes)
   ELSEIF (hour(ce.clinsig_updt_dt_tm) >= 20
    AND hour(ce.clinsig_updt_dt_tm) < 24)
    20_hour = (20_hour+ t_minutes), total_20_hour = (total_20_hour+ t_minutes)
   ENDIF
  FOOT  p.person_id
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
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 SELECT INTO "spiritual_religion_per_unit.xls"
  unit = uar_get_code_display(elh.loc_nurse_unit_cd), start_year = substring(3,4,ce.result_val),
  start_month =
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
  ,
  start_day = substring(9,2,ce.result_val), start_hour = substring(11,2,ce.result_val), start_min =
  substring(13,2,ce.result_val),
  end_year = substring(3,4,ce1.result_val), end_month =
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
  , end_day = substring(9,2,ce1.result_val),
  end_hour = substring(11,2,ce1.result_val), end_min = substring(13,2,ce1.result_val), ce3_null =
  nullind(ce3.clinical_event_id),
  ce4_null = nullind(ce4.clinical_event_id)
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   clinical_event ce4,
   encntr_loc_hist elh
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(e_indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->spirit_qual[e_indx].
    encntr_id)
    AND ce.event_cd=spir_serv_start_tm_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ((ce.clinsig_updt_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((ce.clinsig_updt_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
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
   JOIN (ce3
   WHERE ce3.encntr_id=outerjoin(ce.encntr_id)
    AND ((ce3.parent_event_id+ 0)=outerjoin(ce.parent_event_id))
    AND ce3.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce3.event_cd=outerjoin(spir_family_cd)
    AND ce3.event_tag != outerjoin("In Error"))
   JOIN (ce4
   WHERE ce4.encntr_id=outerjoin(ce.encntr_id)
    AND ((ce4.parent_event_id+ 0)=outerjoin(ce.parent_event_id))
    AND ce4.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))
    AND ce4.event_cd=outerjoin(spir_staff_cd)
    AND ce4.event_tag != outerjoin("In Error"))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.beg_effective_dt_tm <= ce.clinsig_updt_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) > ce.clinsig_updt_dt_tm))
  ORDER BY ce2.result_val, unit, ce.encntr_id,
   ce.clinical_event_id
  HEAD REPORT
   t_line = concat("Spiritual Services",char(9)), col 0, t_line,
   t_line = concat("Religion / Unit ",char(9)), row + 1, col 0,
   t_line, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), row + 1,
   col 0, t_line, t_line = concat("Religion",char(9),"Unit",char(9),"Patients",
    char(9),"Sessions",char(9),"Minutes",char(9),
    "Average Family Present",char(9),"Average Staff Present",char(9)),
   row + 1, col 0, t_line,
   total_patient_cnt = 0, total_sessions_cnt = 0, total_minutes_cnt = 0,
   total_family_cnt = 0, total_staff_cnt = 0
  HEAD ce2.result_val
   l_line = concat(trim(ce2.result_val),char(9))
  HEAD unit
   patient_cnt = 0, sessions_cnt = 0, minutes_cnt = 0,
   t_line = concat(l_line,trim(unit),char(9)), family_cnt = 0, staff_cnt = 0
  HEAD ce.encntr_id
   patient_cnt = (patient_cnt+ 1)
  HEAD ce.clinical_event_id
   start_date_string = concat(start_day,"-",start_month,"-",start_year,
    " ",start_hour,":",start_min), end_date_string = concat(end_day,"-",end_month,"-",end_year,
    " ",end_hour,":",end_min), sessions_cnt = (sessions_cnt+ 1),
   minutes_cnt = (minutes_cnt+ datetimediff(cnvtdatetime(end_date_string),cnvtdatetime(
     start_date_string),4))
   IF (ce3_null=0)
    family_cnt = (family_cnt+ cnvtint(ce3.result_val))
   ENDIF
   IF (ce4_null=0)
    staff_cnt = (staff_cnt+ cnvtint(ce4.result_val))
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
    total_staff_cnt/ total_sessions_cnt)), t_line = concat("Totals",char(9),char(9),trim(cnvtstring(
      total_patient_cnt)),char(9),
    trim(cnvtstring(total_sessions_cnt)),char(9),trim(cnvtstring(total_minutes_cnt)),char(9),trim(
     cnvtstring(total_family_ave)),
    char(9),trim(cnvtstring(total_staff_ave)),char(9)),
   row + 1, col 0, t_line
  WITH nocounter, maxcol = 1000
 ;end select
 SET subject_line = concat("Interpreter and Spiritual Reports ",format(t_record->beg_date,
   "DD-MMM-YYYY;;Q")," to ",format(t_record->end_date,"DD-MMM-YYYY;;Q"))
 SET dclcom = concat(
  "(uuencode interpreter_language_per_unit.xls interpreter_language_per_unit.xls; ",
  "uuencode interpreter_patients_per_interpreter.xls interpreter_patients_per_interpreter.xls; ",
  "uuencode spiritual_religion_per_unit.xls spiritual_religion_per_unit.xls; ",
  "uuencode spiritual_patients_per_personnel.xls spiritual_patients_per_personnel.xls;) ",
  " | mailx -s ",
  '"',subject_line,'" ',"anthony.jacobson@bhs.org")
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
 IF (findfile("interpreter_language_per_unit.xls")=1)
  SET stat = remove("interpreter_language_per_unit.xls")
 ENDIF
 IF (findfile("interpreter_patients_per_interpreter.xls")=1)
  SET stat = remove("interpreter_patients_per_interpreter.xls")
 ENDIF
 IF (findfile("spiritual_religion_per_unit.xls")=1)
  SET stat = remove("spiritual_religion_per_unit.xls")
 ENDIF
 IF (findfile("spiritual_patients_per_personnel.xls")=1)
  SET stat = remove("spiritual_patients_per_personnel.xls")
 ENDIF
END GO
