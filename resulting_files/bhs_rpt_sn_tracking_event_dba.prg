CREATE PROGRAM bhs_rpt_sn_tracking_event:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting Checkin Date" = "CURDATE",
  "Ending Checkin Date" = "CURDATE",
  "Select Surgical Area" = 0,
  "Select Additional Ten Events(MAX is 10 events)" = ""
  WITH outdev, s_start_date, s_end_date,
  f_surg_area, s_display_key
 DECLARE ms_event14 = vc WITH protect
 DECLARE ms_event15 = vc WITH protect
 DECLARE ms_event16 = vc WITH protect
 DECLARE ms_event17 = vc WITH protect
 DECLARE ms_event18 = vc WITH protect
 DECLARE ms_event19 = vc WITH protect
 DECLARE ms_event20 = vc WITH protect
 DECLARE ms_event21 = vc WITH protect
 DECLARE ms_event22 = vc WITH protect
 DECLARE ms_event23 = vc WITH protect
 DECLARE ms_event24 = vc WITH protect
 DECLARE ms_event25 = vc WITH protect
 DECLARE ms_event26 = vc WITH protect
 DECLARE ms_event27 = vc WITH protect
 DECLARE ms_event28 = vc WITH protect
 DECLARE ms_event29 = vc WITH protect
 DECLARE ms_event30 = vc WITH protect
 DECLARE ms_event31 = vc WITH protect
 DECLARE ms_event32 = vc WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE pl_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_start_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_START_DATE,
     "DD-MMM-YYYY"),0),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE ms_end_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),
    235959),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_envent_name = vc WITH protect
 DECLARE ms_event_file = vc WITH protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 RECORD events(
   1 cnt_pat = i4
   1 head0 = vc
   1 head0a = vc
   1 head1 = vc
   1 head2 = vc
   1 head3 = vc
   1 head4 = vc
   1 head4a = vc
   1 head5 = vc
   1 head5a = vc
   1 head6 = vc
   1 head7 = vc
   1 head8 = vc
   1 head9 = vc
   1 head10 = vc
   1 head11 = vc
   1 head12 = vc
   1 head13 = vc
   1 head14 = vc
   1 head15 = vc
   1 head16 = vc
   1 head17 = vc
   1 head18 = vc
   1 head19 = vc
   1 head20 = vc
   1 head21 = vc
   1 head22 = vc
   1 head23 = vc
   1 head24 = vc
   1 head25 = vc
   1 head26 = vc
   1 head27 = vc
   1 head28 = vc
   1 head29 = vc
   1 head30 = vc
   1 head31 = vc
   1 head32 = vc
   1 cases[*]
     2 tracking_grp = vc
     2 f_tracking_id = f8
     2 surg_loc = vc
     2 specialty = vc
     2 date_sched_surg = vc
     2 patient = vc
     2 date_surg = vc
     2 dob = vc
     2 fin = vc
     2 case_num = vc
     2 checkin_time = vc
     2 s_primary_surgeon = vc
     2 surgeon_arrived = vc
     2 patient_arrived = vc
     2 in_prep_op = vc
     2 time_out_pre_op = vc
     2 time_in_or = vc
     2 out_of_or = vc
     2 in_pacu = vc
     2 out_of_pacu = vc
     2 event_14 = vc
     2 event_15 = vc
     2 event_16 = vc
     2 event_17 = vc
     2 event_18 = vc
     2 event_19 = vc
     2 event_20 = vc
     2 event_21 = vc
     2 event_22 = vc
     2 event_23 = vc
     2 event_25 = vc
     2 event_26 = vc
     2 event_27 = vc
     2 event_28 = vc
     2 event_29 = vc
     2 event_30 = vc
     2 event_31 = vc
     2 event_32 = vc
 )
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_SURG_AREA),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_SURG_AREA),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_SURG_AREA),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_SURG_AREA
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All Groups"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $S_DISPLAY_KEY),0)))
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 f_cv = vc
     2 s_disp = vc
     2 s_disp_key = vc
 )
 SET gcnt = 0
 IF (lcheck="L")
  SET ms_opr_var1 = "IN"
  CALL echo(build("lcheck = ",lcheck))
  CALL echo(build("$s_display_key  = ", $S_DISPLAY_KEY))
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $S_DISPLAY_KEY),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec2->list,(gcnt+ 4))
     ENDIF
     SET grec2->list[gcnt].f_cv = parameter(parameter2( $S_DISPLAY_KEY),gcnt)
     SELECT DISTINCT INTO "nl:"
      FROM track_event te,
       code_value cv
      PLAN (te
       WHERE te.active_ind=1
        AND  NOT (te.tracking_group_cd IN (598267434.00, 598267174.00))
        AND (te.display_key=grec2->list[gcnt].f_cv))
       JOIN (cv
       WHERE cv.code_set=16370
        AND cv.active_ind=1
        AND cv.cdf_meaning="SURG"
        AND cv.code_value=te.tracking_group_cd
        AND  NOT (cv.code_value IN (598267434.00, 598267174.00)))
      ORDER BY te.display_key
      HEAD te.display_key
       grec2->list[gcnt].s_disp = trim(te.display,3), grec2->list[gcnt].s_disp_key = trim(te
        .display_key,3)
      WITH nocounter, time = 60
     ;end select
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec2->list,gcnt)
 ELSE
  CALL echo(build("$s_display_key  = ", $S_DISPLAY_KEY))
  SET stat = alterlist(grec2->list,1)
  SET gcnt = 1
  SET grec2->list[1].f_cv =  $S_DISPLAY_KEY
  SELECT DISTINCT INTO "nl:"
   te.display_key, te.display
   FROM track_event te,
    code_value cv
   PLAN (te
    WHERE te.active_ind=1
     AND  NOT (te.tracking_group_cd IN (598267434.00, 598267174.00))
     AND (te.display_key=grec2->list[1].f_cv))
    JOIN (cv
    WHERE cv.code_set=16370
     AND cv.active_ind=1
     AND cv.cdf_meaning="SURG"
     AND cv.code_value=te.tracking_group_cd
     AND  NOT (cv.code_value IN (598267434.00, 598267174.00)))
   ORDER BY te.display_key
   HEAD te.display_key
    grec2->list[1].s_disp = trim(te.display,3), grec2->list[1].s_disp_key = trim(te.display_key,3)
   WITH nocounter, time = 60
  ;end select
  SET ms_opr_var1 = "="
 ENDIF
 IF (size(grec2->list,5) <= 10)
  FOR (x = 1 TO size(grec2->list,5))
    IF (x=1)
     SET ms_event14 = grec2->list[1].f_cv
     SET events->head14 = trim(grec2->list[1].s_disp,3)
    ENDIF
    IF (x=2)
     SET ms_event15 = grec2->list[2].f_cv
     SET events->head15 = trim(grec2->list[1].s_disp,3)
    ENDIF
    IF (x=3)
     SET ms_event16 = grec2->list[3].f_cv
     SET events->head16 = trim(grec2->list[2].s_disp,3)
    ENDIF
    IF (x=4)
     SET ms_event17 = grec2->list[4].f_cv
     SET events->head17 = trim(grec2->list[3].s_disp,3)
    ENDIF
    IF (x=5)
     SET ms_event18 = grec2->list[5].f_cv
     SET events->head18 = trim(grec2->list[4].s_disp,3)
    ENDIF
    IF (x=6)
     SET ms_event19 = grec2->list[6].f_cv
     SET events->head19 = trim(grec2->list[5].s_disp,3)
    ENDIF
    IF (x=7)
     SET ms_event20 = grec2->list[7].f_cv
     SET events->head20 = trim(grec2->list[6].s_disp,3)
    ENDIF
    IF (x=8)
     SET ms_event21 = grec2->list[8].f_cv
     SET events->head21 = trim(grec2->list[6].s_disp,3)
    ENDIF
    IF (x=9)
     SET ms_event22 = grec2->list[9].f_cv
     SET events->head22 = trim(grec2->list[6].s_disp,3)
    ENDIF
    IF (x=10)
     SET ms_event23 = grec2->list[10].f_cv
     SET events->head23 = trim(grec2->list[6].s_disp,3)
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM tracking_checkin t,
    surgical_case sc,
    code_value cv,
    person p,
    encntr_alias fin,
    prsnl_group pg,
    prsnl srgn,
    surg_case_procedure scp
   PLAN (sc
    WHERE operator(sc.sched_surg_area_cd,ms_opr_var, $F_SURG_AREA)
     AND sc.sched_start_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))
    JOIN (t
    WHERE t.parent_entity_id=sc.surg_case_id
     AND t.active_ind=1
     AND t.parent_entity_name="SURGICAL_CASE")
    JOIN (scp
    WHERE scp.surg_case_id=sc.surg_case_id
     AND scp.active_ind=1)
    JOIN (srgn
    WHERE (srgn.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
    JOIN (pg
    WHERE (pg.prsnl_group_id= Outerjoin(sc.surg_specialty_id)) )
    JOIN (fin
    WHERE fin.encntr_id=sc.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
    JOIN (cv
    WHERE cv.code_set=16370
     AND cv.active_ind=1
     AND cv.cdf_meaning="SURG"
     AND cv.code_value=t.tracking_group_cd)
    JOIN (p
    WHERE p.person_id=sc.person_id)
   ORDER BY sc.sched_start_dt_tm, sc.sched_surg_area_cd, sc.surg_case_id
   HEAD REPORT
    events->head0 = "Date_Start_of_Surgery", events->head0a = "Location", events->head1 =
    "Patient_Name",
    events->head2 = "DOB", events->head3 = "Financial_Number", events->head4 = "Case_number ",
    events->head4a = "Primary_Surgeon", events->head5 = "Case_Check_in_time ", events->head5a =
    "Actual_Surgical_Start_Time",
    events->head6 = "Patient Arrived", events->head7 = "Surgeon  Arrived", events->head8 =
    "In Preop Time",
    events->head9 = "Time out of Preop", events->head10 = "Time in OR", events->head11 = "Out of OR",
    events->head12 = "In PACU", events->head13 = "Out of PACU", stat = alterlist(events->cases,10)
   HEAD sc.surg_case_id
    events->cnt_pat += 1
    IF (mod(events->cnt_pat,10)=1
     AND (events->cnt_pat > 1))
     stat = alterlist(events->cases,(events->cnt_pat+ 9))
    ENDIF
    events->cases[events->cnt_pat].patient = trim(p.name_full_formatted,3)
    IF (sc.surg_start_dt_tm != null)
     events->cases[events->cnt_pat].date_surg = format(sc.surg_start_dt_tm,"HH:MM;;M")
    ENDIF
    events->cases[events->cnt_pat].dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz
       ),1),"mm/dd/yyyy;;d"), events->cases[events->cnt_pat].fin = trim(fin.alias,2), events->cases[
    events->cnt_pat].case_num = trim(sc.surg_case_nbr_formatted,3),
    events->cases[events->cnt_pat].checkin_time = format(sc.checkin_dt_tm,"HH:MM;;M"), events->cases[
    events->cnt_pat].tracking_grp = uar_get_code_display(t.tracking_group_cd), events->cases[events->
    cnt_pat].surg_loc = uar_get_code_display(sc.sched_surg_area_cd),
    events->cases[events->cnt_pat].date_sched_surg = format(sc.sched_start_dt_tm,"mm/dd/yyyy;;d"),
    events->cases[events->cnt_pat].f_tracking_id = t.tracking_id, events->cases[events->cnt_pat].
    s_primary_surgeon = trim(srgn.name_full_formatted,3)
    IF (pg.prsnl_group_id > 0)
     events->cases[events->cnt_pat].specialty = trim(pg.prsnl_group_name,3)
    ENDIF
   FOOT REPORT
    stat = alterlist(events->cases,events->cnt_pat)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM tracking_event te,
    track_event tee
   PLAN (te
    WHERE te.active_ind=1
     AND expand(ml_num,1,size(events->cases,5),te.tracking_id,events->cases[ml_num].f_tracking_id))
    JOIN (tee
    WHERE tee.track_event_id=te.track_event_id
     AND tee.active_ind=1
     AND ((operator(tee.display_key,ms_opr_var1, $S_DISPLAY_KEY)) OR (tee.display_key IN ("INPACU",
    "OUTOFPACU", "INPREOP", "OUTOFPREOP", "PATIENTARRIVED",
    "PATIENTINOR", "PATIENTOUTOFOR", "SURGEONARRIVED"))) )
   ORDER BY te.track_event_id, te.tracking_event_id
   HEAD te.tracking_id
    ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(events->cases,5),te.tracking_id,events->
     cases[ml_numres].f_tracking_id)
   HEAD te.tracking_event_id
    IF (ml_attloc != 0)
     IF (tee.display_key="SURGEONARRIVED")
      events->cases[ml_attloc].surgeon_arrived = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="PATIENTARRIVED")
      events->cases[ml_attloc].patient_arrived = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="INPREOP")
      events->cases[ml_attloc].in_prep_op = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="OUTOFPREOP")
      events->cases[ml_attloc].time_out_pre_op = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="PATIENTINOR")
      events->cases[ml_attloc].time_in_or = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="PATIENTOUTOFOR")
      events->cases[ml_attloc].out_of_or = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="INPACU")
      events->cases[ml_attloc].in_pacu = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key="OUTOFPACU")
      events->cases[ml_attloc].out_of_pacu = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event14)
      events->cases[ml_attloc].event_14 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event15)
      events->cases[ml_attloc].event_15 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event16)
      events->cases[ml_attloc].event_16 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event17)
      events->cases[ml_attloc].event_17 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event18)
      events->cases[ml_attloc].event_18 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event19)
      events->cases[ml_attloc].event_19 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event20)
      events->cases[ml_attloc].event_20 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event21)
      events->cases[ml_attloc].event_21 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event22)
      events->cases[ml_attloc].event_22 = format(te.requested_dt_tm,"HH:MM;;M")
     ELSEIF (tee.display_key=ms_event23)
      events->cases[ml_attloc].event_23 = format(te.requested_dt_tm,"HH:MM;;M")
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO  $OUTDEV
   head0 = substring(1,30,events->head0), head0a = substring(1,60,events->head0a), head1 = substring(
    1,100,events->head1),
   head2 = substring(1,30,events->head2), head3 = substring(1,30,events->head3), head4 = substring(1,
    30,events->head4),
   head4a = substring(1,100,events->head4a), head5 = substring(1,30,events->head5), head5a =
   substring(1,30,events->head5a),
   head6 = substring(1,30,replace(replace(replace(replace(events->head6," ","_"),"-","_"),"(",""),")",
     "")), head7 = substring(1,30,replace(replace(replace(replace(events->head7," ","_"),"-","_"),"(",
      ""),")","")), head8 = substring(1,30,replace(replace(replace(replace(events->head8," ","_"),"-",
       "_"),"(",""),")","")),
   head9 = substring(1,30,replace(replace(replace(replace(events->head9," ","_"),"-","_"),"(",""),")",
     "")), head10 = substring(1,30,replace(replace(replace(replace(events->head10," ","_"),"-","_"),
      "(",""),")","")), head11 = substring(1,30,replace(replace(replace(replace(events->head11," ",
        "_"),"-","_"),"(",""),")","")),
   head12 = substring(1,30,replace(replace(replace(replace(events->head12," ","_"),"-","_"),"(",""),
     ")","")), head13 = substring(1,30,replace(replace(replace(replace(events->head13," ","_"),"-",
       "_"),"(",""),")","")), head14 = substring(1,30,replace(replace(replace(replace(events->head14,
        " ","_"),"-","_"),"(",""),")","")),
   head15 = substring(1,30,replace(replace(replace(replace(events->head15," ","_"),"-","_"),"(",""),
     ")","")), head16 = substring(1,30,replace(replace(replace(replace(events->head16," ","_"),"-",
       "_"),"(",""),")","")), head17 = substring(1,30,replace(replace(replace(replace(events->head17,
        " ","_"),"-","_"),"(",""),")","")),
   head18 = substring(1,30,replace(replace(replace(replace(events->head18," ","_"),"-","_"),"(",""),
     ")","")), head19 = substring(1,30,replace(replace(replace(replace(events->head19," ","_"),"-",
       "_"),"(",""),")","")), head20 = substring(1,30,replace(replace(replace(replace(events->head20,
        " ","_"),"-","_"),"(",""),")","")),
   head21 = substring(1,30,replace(replace(replace(replace(events->head21," ","_"),"-","_"),"(",""),
     ")","")), head22 = substring(1,30,replace(replace(replace(replace(events->head22," ","_"),"-",
       "_"),"(",""),")","")), head23 = substring(1,30,replace(replace(replace(replace(events->head23,
        " ","_"),"-","_"),"(",""),")",""))
   WITH nocounter, separator = " ", format,
    noheading
  ;end select
  SELECT INTO  $OUTDEV
   scheduled_date_surgery = substring(1,30,events->cases[d1.seq].date_sched_surg), surgical_area =
   substring(1,60,events->cases[d1.seq].surg_loc), patient = substring(1,100,events->cases[d1.seq].
    patient),
   dob = substring(1,30,events->cases[d1.seq].dob), fin = substring(1,30,events->cases[d1.seq].fin),
   case_num = substring(1,30,events->cases[d1.seq].case_num),
   s_primary_surgeon = substring(1,100,events->cases[d1.seq].s_primary_surgeon), checkin_time =
   substring(1,30,events->cases[d1.seq].checkin_time), date_start_surgery = substring(1,30,events->
    cases[d1.seq].date_surg),
   patient_arrived = substring(1,30,events->cases[d1.seq].patient_arrived), surgeon_arrived =
   substring(1,30,events->cases[d1.seq].surgeon_arrived), in_prep_op = substring(1,30,events->cases[
    d1.seq].in_prep_op),
   time_out_pre_op = substring(1,30,events->cases[d1.seq].time_out_pre_op), time_in_or = substring(1,
    30,events->cases[d1.seq].time_in_or), out_of_or = substring(1,30,events->cases[d1.seq].out_of_or),
   in_pacu = substring(1,30,events->cases[d1.seq].in_pacu), out_of_pacu = substring(1,30,events->
    cases[d1.seq].out_of_pacu), cases_event_14 = substring(1,30,events->cases[d1.seq].event_14),
   cases_event_15 = substring(1,30,events->cases[d1.seq].event_15), cases_event_16 = substring(1,30,
    events->cases[d1.seq].event_16), cases_event_17 = substring(1,30,events->cases[d1.seq].event_17),
   cases_event_18 = substring(1,30,events->cases[d1.seq].event_18), cases_event_19 = substring(1,30,
    events->cases[d1.seq].event_19), cases_event_20 = substring(1,30,events->cases[d1.seq].event_20),
   cases_event_21 = substring(1,30,events->cases[d1.seq].event_21), cases_event_22 = substring(1,30,
    events->cases[d1.seq].event_22), cases_event_23 = substring(1,30,events->cases[d1.seq].event_23)
   FROM (dummyt d1  WITH seq = size(events->cases,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format,
    noheading, append
  ;end select
 ELSEIF (size(grec2->list,5) > 10)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "You can only select a MAXIMUM of 10 Tracking Events",
    CALL print(calcpos(36,18)), msg1,
    row + 2
   WITH dio = 08
  ;end select
 ENDIF
END GO
