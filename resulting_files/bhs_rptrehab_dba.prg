CREATE PROGRAM bhs_rptrehab:dba
 PROMPT
  "error print to" = "MINE",
  "Output to File/Printer/MINE" = "MINE",
  "Begin date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Rehab Facility" = 0,
  "Rehab Unit" = 0
  WITH printonerror, outdev, beg_dt,
  end_dt, facility, unit
 DECLARE mf_completed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED")), protect
 DECLARE mf_perform_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM")), protect
 DECLARE mf_sign_var = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN")), protect
 DECLARE mf_finnbr_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_ocfcomp = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE mf_remf_scheduled_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"RESCHEDULED")),
 protect
 DECLARE mf_pending_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"PENDING")), protect
 DECLARE mf_scheduled_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"SCHEDULED")), protect
 DECLARE mf_appointment_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"APPOINTMENT")),
 protect
 DECLARE mf_finalized_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"FINALIZED")), protect
 DECLARE mf_confirmed_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"CONFIRMED")), protect
 DECLARE mf_arrived_var = f8 WITH constant(uar_get_code_by("MEANING",14233,"CHECKED IN")), protect
 DECLARE mf_notdone_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE")), protect
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE mf_pharmacy_cattyp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE mf_allergy_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED")),
 protect
 DECLARE mf_snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE mf_sensitive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"SENSITIVE"))
 DECLARE mf_active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,
   "ACTIVE"))
 DECLARE mf_pendingreview_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE")),
 protect
 DECLARE mf_pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDING")), protect
 DECLARE mf_inprocess_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE mf_incomplete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE")),
 protect
 DECLARE mf_ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE mf_pulse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE mf_systolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_diastolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_remainingvisits_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"REMAININGVISITS")
  ), protect
 DECLARE mf_visitsapproved_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"VISITSAPPROVED")),
 protect
 DECLARE mf_insurancerehab_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"INSURANCEREHAB")),
 protect
 DECLARE mf_pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE mf_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_speechtherapyforms_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPEECHTHERAPYFORMS")), protect
 DECLARE mf_speechtherapynote_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPEECHTHERAPYNOTE")), protect
 DECLARE mf_occupationaltherapyforms_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OCCUPATIONALTHERAPYFORMS")), protect
 DECLARE mf_occupationaltherapynote_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OCCUPATIONALTHERAPYNOTE")), protect
 DECLARE mf_physicaltherapynote_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHYSICALTHERAPYNOTE")), protect
 DECLARE mf_physicaltherapyforms_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHYSICALTHERAPYFORMS")), protect
 CALL echo(build("time diff ^^^^ =",datetimediff(cnvtdatetime( $END_DT),cnvtdatetime( $BEG_DT))))
 DECLARE ml_out_of_range = i4 WITH noconstant(0), protect
 DECLARE ml_cnt_sch = i4 WITH protect, noconstant(0)
 DECLARE ml_al = i4 WITH protect, noconstant(0)
 DECLARE ml_prob_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_v_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_i_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_n_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt_pat = i4 WITH protect, noconstant(0)
 DECLARE ms_stop_dt = vc WITH protect
 DECLARE ms_start_dt = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_tempname = vc WITH protect
 DECLARE ms_var_output = vc WITH protect
 DECLARE mf_remain_space = f8 WITH protect
 DECLARE mf_amb_unit = f8 WITH protect
 DECLARE mf_page_size = f8 WITH noconstant(10.0), protect
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE md_select_endtime = dq8
 DECLARE md_select_starttime = dq8
 DECLARE md_selecttime = dq8
 DECLARE mn_operations = i2 WITH protect, noconstant(0)
 DECLARE mn_x = i2 WITH protect, noconstant(0)
 DECLARE mn_y = i2 WITH protect, noconstant(0)
 DECLARE becont = i2
 SET ml_out_of_range = 0
 IF (datetimediff(cnvtdatetime( $END_DT),cnvtdatetime( $BEG_DT)) > 1.0)
  SET ml_out_of_range = 1
  SELECT INTO  $PRINTONERROR
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Greater than one day .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $END_DT),cnvtdatetime( $BEG_DT)) < 0.0)
  SET ml_out_of_range = 1
  SELECT INTO  $PRINTONERROR
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ENDIF
 IF (validate(request->batch_selection))
  SET ms_start_dt = cnvtdatetime2(curdate,0)
  SET ms_stop_dt = cnvtdatetime2(curdate,235959)
  SET mn_operations = 1
  SET ms_tempname = replace(trim(uar_get_code_display(cnvtreal( $UNIT)))," ","_",0)
  SET ms_tempname = replace(trim(ms_tempname),"/","",0)
  SET ms_tempname = replace(trim(ms_tempname),"-","",0)
  SET ms_tempname = replace(trim(ms_tempname),"&","",0)
  SET ms_tempname = replace(trim(ms_tempname),"__","_",0)
  SET ms_tempname = substring(2,30,cnvtlower(ms_tempname))
  SET ms_var_output = trim(ms_tempname,3)
  SET mf_amb_unit =  $UNIT
  SET ms_var_output = build(ms_var_output,".ps")
  CALL echo(ms_var_output)
 ELSE
  SET mf_amb_unit =  $UNIT
  CALL echo(build("mf_amb_unit_menu = ",mf_amb_unit))
  SET ms_start_dt =  $BEG_DT
  SET ms_stop_dt =  $END_DT
  CALL echo(build("$outdev = ", $OUTDEV))
  IF (( $OUTDEV="MINE"))
   SET ms_var_output =  $PRINTONERROR
  ELSE
   SET ms_var_output =  $OUTDEV
   SELECT INTO  $PRINTONERROR
    FROM dummyt
    HEAD REPORT
     msg1 = concat("Report sent to printer ", $OUTDEV), col 0, y_pos = 18,
     row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))),
     msg1, row + 1
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ENDIF
 RECORD dlrec(
   1 encntr_total = i4
   1 location = f8
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 sch_event_id = f8
     2 resource = vc
     2 location = vc
     2 location_cd = f8
     2 name_full_formatted = vc
     2 appt_description = vc
     2 ms_last_appt_dt = dq8
     2 age = c12
     2 f_sex_cd = f8
     2 s_fin = vc
     2 l_age_in_yrs = i4
     2 birth_dt_tm = vc
     2 pcpdoc_name = vc
     2 measurements[*]
       3 wt_result = c15
       3 wt_dt_tm = c18
       3 pulse_result = c20
       3 pulse_dt_tm = c18
       3 systolic_result = c3
       3 diastolic_result = c3
       3 bp_dt_tm = c18
       3 bp_display = vc
       3 s_bmi = vc
       3 s_bmi_dt_tm = vc
     2 allergy[*]
       3 source_identifier = vc
       3 source_string = vc
       3 severity = vc
       3 type_source_string = vc
       3 allergy_dt_tm = vc
       3 diag_dt_tm = vc
       3 substance_type_disp = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
       3 reaction_display = vc
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
       3 full_text = vc
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 ordered_as_mnemonic = vc
       3 freq = c30
       3 freq_cnt = i2
       3 dose = c30
       3 dose_cnt = i2
       3 doseunit = c30
       3 doseunit_cnt = i2
       3 order_comment_ind = i2
       3 volume = vc
       3 route = vc
       3 route_cnt = i2
       3 volume_unit = vc
       3 volume_unit_cnt = i2
       3 volume_dose = vc
       3 volume_dose_cnt = i2
       3 strength_dose = vc
       3 strength_dose_cnt = i2
       3 strength_unit = vc
       3 strength_unit_cnt = i2
       3 free_text = vc
       3 free_text_cnt = i2
     2 ms_insu_desc = vc
     2 ms_insu_approved = vc
     2 ms_insu_remaining = vc
     2 note[*]
       3 note_name = vc
       3 note_date = vc
       3 note_content = vc
 )
 SET dlrec->encntr_total = 0
 SET md_select_starttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  sa_appt_location_disp = uar_get_code_display(sa.appt_location_cd), sa1_resource_disp =
  uar_get_code_display(sa1.resource_cd)
  FROM sch_appt sa,
   code_value cv,
   sch_appt sa1
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(ms_start_dt) AND (cnvtdatetime(ms_stop_dt)+ 0)
    AND sa.appt_location_cd=mf_amb_unit
    AND ((sa.encntr_id+ 0) > 0)
    AND sa.sch_state_cd IN (mf_remf_scheduled_sch, mf_pending_sch, mf_scheduled_sch,
   mf_appointment_sch, mf_finalized_sch,
   mf_confirmed_sch))
   JOIN (sa1
   WHERE sa.schedule_id=sa1.schedule_id
    AND ((sa1.primary_role_ind+ 0)=1))
   JOIN (cv
   WHERE cv.code_value=sa.appt_location_cd)
  ORDER BY sa.sch_event_id, sa.updt_dt_tm DESC
  HEAD REPORT
   ml_cnt_sch = 0, stat = alterlist(dlrec->seq,10)
  HEAD sa.sch_event_id
   IF (sa.sch_state_cd IN (mf_remf_scheduled_sch, mf_pending_sch, mf_scheduled_sch,
   mf_appointment_sch, mf_finalized_sch,
   mf_confirmed_sch))
    ml_cnt_sch += 1
    IF (mod(ml_cnt_sch,10)=1
     AND ml_cnt_sch != 1)
     stat = alterlist(dlrec->seq,(ml_cnt_sch+ 9))
    ENDIF
    dlrec->seq[ml_cnt_sch].encntr_id = sa.encntr_id, dlrec->seq[ml_cnt_sch].resource =
    sa1_resource_disp, dlrec->seq[ml_cnt_sch].location = cv.description,
    dlrec->seq[ml_cnt_sch].location_cd = sa.appt_location_cd, dlrec->seq[ml_cnt_sch].person_id = sa
    .person_id, dlrec->seq[ml_cnt_sch].sch_event_id = sa.sch_event_id
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,ml_cnt_sch), dlrec->encntr_total = ml_cnt_sch
  WITH nocounter
 ;end select
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build("Demographic Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl:"
   FROM sch_event s,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (s
    WHERE (s.sch_event_id=dlrec->seq[d1.seq].sch_event_id))
   ORDER BY d1.seq, s.updt_dt_tm DESC
   HEAD d1.seq
    dlrec->seq[d1.seq].appt_description = s.appt_reason_free
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=dlrec->seq[d1.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mf_finnbr_var
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY d1.seq
   HEAD d1.seq
    dlrec->seq[d1.seq].s_fin = trim(ea.alias)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl:"
   FROM sch_appt sa,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (sa
    WHERE (sa.person_id=dlrec->seq[d1.seq].person_id)
     AND sa.beg_dt_tm < cnvtdatetime(ms_start_dt)
     AND sa.sch_state_cd=mf_arrived_var)
   ORDER BY d1.seq, sa.beg_dt_tm DESC
   HEAD d1.seq
    dlrec->seq[d1.seq].ms_last_appt_dt = sa.beg_dt_tm,
    CALL echo(build("last appt= ",concat(cnvtstring(dlrec->seq[d1.seq].person_id)," ",format(dlrec->
       seq[d1.seq].ms_last_appt_dt,";;q"))))
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("&&&&&& select one end &&&&&&")
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl:"
   seq_person_id = dlrec->seq[d1.seq].person_id
   FROM person p,
    person_prsnl_reltn ppr,
    prsnl pr,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=dlrec->seq[d1.seq].person_id))
    JOIN (ppr
    WHERE (ppr.person_id= Outerjoin(p.person_id))
     AND (ppr.person_prsnl_r_cd= Outerjoin(mf_pcp_cd))
     AND (ppr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(ppr.prsnl_person_id))
     AND (pr.physician_ind= Outerjoin(1)) )
   ORDER BY d1.seq
   HEAD REPORT
    consultdoc_cnt = 0
   HEAD d1.seq
    dlrec->encntr_total = 1, dlrec->seq[d1.seq].name_full_formatted = p.name_full_formatted, dlrec->
    seq[d1.seq].age = cnvtage(p.birth_dt_tm),
    dlrec->seq[d1.seq].l_age_in_yrs = cnvtint((datetimediff(sysdate,p.birth_dt_tm,1)/ 365)), dlrec->
    seq[d1.seq].f_sex_cd = p.sex_cd, dlrec->seq[d1.seq].birth_dt_tm = format(p.birth_dt_tm,
     "MM/DD/YYYY ;;q"),
    dlrec->seq[d1.seq].pcpdoc_name = pr.name_full_formatted
   WITH nocounter, outerjoin = d2
  ;end select
 ENDIF
 CALL echo("&&&&&& -Patient info- &&&&&&")
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build("Demographic Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 IF (size(dlrec->seq,5) > 0)
  SELECT DISTINCT INTO "nl:"
   short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
      .substance_ftdesc))), substance_type_disp =
   IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
   ELSE "Other "
   ENDIF
   , seq_person_id = dlrec->seq[d1.seq].person_id
   FROM allergy a,
    nomenclature n,
    nomenclature n2,
    reaction r,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (a
    WHERE (a.person_id=dlrec->seq[d1.seq].person_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ((a.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (a.end_effective_dt_tm=null))
     AND a.reaction_status_cd != mf_allergy_canceled_cd)
    JOIN (n
    WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
    JOIN (r
    WHERE (r.allergy_id= Outerjoin(a.allergy_id)) )
    JOIN (n2
    WHERE (n2.nomenclature_id= Outerjoin(r.reaction_nom_id)) )
   ORDER BY d1.seq, substance_type_disp, short_source_string
   HEAD a.person_id
    ml_al = 0
   DETAIL
    ml_al += 1, stat = alterlist(dlrec->seq[d1.seq].allergy,ml_al), dlrec->seq[d1.seq].allergy[ml_al]
    .source_string = short_source_string,
    dlrec->seq[d1.seq].allergy[ml_al].substance_type_disp = substance_type_disp, dlrec->seq[d1.seq].
    allergy[ml_al].type_source_string = concat(build(substance_type_disp,": ")," ",
     short_source_string), dlrec->seq[d1.seq].allergy[ml_al].source_string = short_source_string,
    dlrec->seq[d1.seq].allergy[ml_al].severity = uar_get_code_display(a.severity_cd), dlrec->seq[d1
    .seq].allergy[ml_al].substance_type_disp = substance_type_disp, dlrec->seq[d1.seq].allergy[ml_al]
    .allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,"@SHORTDATE;;Q"))
    IF (r.reaction_ftdesc > " ")
     dlrec->seq[d1.seq].allergy[ml_al].reaction_display = trim(r.reaction_ftdesc)
    ELSE
     dlrec->seq[d1.seq].allergy[ml_al].reaction_display = trim(n2.source_string)
    ENDIF
   FOOT  d1.seq
    stat = alterlist(dlrec->seq[d1.seq].allergy,ml_al), ml_al = 0
   WITH nocounter
  ;end select
 ENDIF
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build("Allergy Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl"
   p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
   FROM problem p,
    nomenclature n,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=dlrec->seq[d1.seq].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ((p.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (p.end_effective_dt_tm=null))
     AND p.classification_cd != mf_sensitive_cd
     AND p.life_cycle_status_cd=mf_active_life_cycle_cd)
    JOIN (n
    WHERE (n.nomenclature_id= Outerjoin(p.nomenclature_id))
     AND n.source_vocabulary_cd=mf_snmct_cd)
   ORDER BY d1.seq, p.problem_id DESC
   HEAD d1.seq
    ml_prob_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].problem,10),
    CALL echo(build("ml_prob_cnt problems header = ",ml_prob_cnt))
   HEAD p.problem_id
    IF (((n.source_string > " ") OR (p.problem_ftdesc > " "))
     AND p.problem_id > 0)
     ml_prob_cnt += 1,
     CALL echo(build("p.person_id problems in TOP details = ",p.person_id)),
     CALL echo(build("ml_prob_cnt top details size = ",size(dlrec->seq[d1.seq].problem,5))),
     CALL echo(build("ml_prob_cnt problems in top details = ",ml_prob_cnt))
     IF (mod(ml_prob_cnt,10)=1
      AND ml_prob_cnt != 1)
      stat = alterlist(dlrec->seq[d1.seq].problem,(ml_prob_cnt+ 9))
     ENDIF
     IF (p.nomenclature_id > 0)
      dlrec->seq[d1.seq].problem[ml_prob_cnt].text = n.source_string
     ELSE
      dlrec->seq[d1.seq].problem[ml_prob_cnt].text = p.problem_ftdesc
     ENDIF
     dlrec->seq[d1.seq].problem[ml_prob_cnt].status = uar_get_code_display(p.life_cycle_status_cd),
     dlrec->seq[d1.seq].problem[ml_prob_cnt].beg_effective_dt_tm = substring(1,14,format(p
       .beg_effective_dt_tm,"@SHORTDATE;;Q")), dlrec->seq[d1.seq].problem[ml_prob_cnt].full_text =
     build(dlrec->seq[d1.seq].problem[ml_prob_cnt].status,": ",dlrec->seq[d1.seq].problem[ml_prob_cnt
      ].text)
    ENDIF
    CALL echo(build("ml_prob_cnt problems in botttom details = ",ml_prob_cnt)),
    CALL echo(build("p.person_id problems in botttom details = ",p.person_id)),
    CALL echo(build("ml_prob_cnt bottom details size = ",size(dlrec->seq[d1.seq].problem,5)))
   FOOT  d1.seq
    CALL echo(build("ml_prob_cnt problems in foot = ",ml_prob_cnt)), stat = alterlist(dlrec->seq[d1
     .seq].problem,ml_prob_cnt), ml_prob_cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build("Problem Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 IF (size(dlrec->seq,5) > 0)
  SELECT INTO "nl:"
   FROM orders o,
    order_detail od,
    order_comment oc,
    long_text lt,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (o
    WHERE (o.person_id=dlrec->seq[d1.seq].person_id)
     AND o.catalog_type_cd=mf_pharmacy_cattyp_cd
     AND o.order_status_cd IN (mf_incomplete_cd, mf_inprocess_cd, mf_ordered_cd, mf_pending_cd,
    mf_pendingreview_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.orig_ord_as_flag IN (1, 2, 3))
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
    "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RXROUTE"))
    JOIN (oc
    WHERE (oc.order_id= Outerjoin(o.order_id)) )
    JOIN (lt
    WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
     AND ((lt.parent_entity_id+ 0)= Outerjoin(oc.order_id))
     AND ((lt.active_ind+ 0)= Outerjoin(1))
     AND (trim(lt.parent_entity_name)= Outerjoin("ORDER_COMMENT")) )
   ORDER BY d1.seq, o.order_id, od.detail_sequence
   HEAD REPORT
    ml_cnt = 0
   HEAD d1.seq
    ml_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].meds,10),
    CALL echo("%%%%%% 1")
   HEAD o.order_id
    ml_cnt += 1, stat = alterlist(dlrec->seq[d1.seq].meds,ml_cnt),
    CALL echo("%%%%%% 2"),
    CALL echo(build2("med select ml_cnt:",trim(build2(ml_cnt),3))),
    CALL echo(build("person_id in head orders = ",o.person_id)),
    CALL echo(build("o.order_id in head orders = ",o.order_id)),
    dlrec->seq[d1.seq].meds[ml_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
    CALL echo("%%%%%% 2.1")
    IF (o.order_comment_ind=1)
     dlrec->seq[d1.seq].meds[ml_cnt].comments = replace(trim(lt.long_text),
      "Refer to Reference Text for Black Box Warning"," ",0),
     CALL echo("%%%%%% 2.11")
    ENDIF
    dlrec->seq[d1.seq].meds[ml_cnt].free_text_cnt = 0, dlrec->seq[d1.seq].meds[ml_cnt].
    volume_dose_cnt = 0, dlrec->seq[d1.seq].meds[ml_cnt].volume_unit_cnt = 0,
    dlrec->seq[d1.seq].meds[ml_cnt].route_cnt = 0, dlrec->seq[d1.seq].meds[ml_cnt].free_text_cnt = 0,
    dlrec->seq[d1.seq].meds[ml_cnt].dose_cnt = 0,
    dlrec->seq[d1.seq].meds[ml_cnt].doseunit_cnt = 0, dlrec->seq[d1.seq].meds[ml_cnt].
    strength_dose_cnt = 0, dlrec->seq[d1.seq].meds[ml_cnt].strength_unit_cnt = 0
   HEAD od.detail_sequence
    IF (od.oe_field_meaning="FREQ")
     CALL echo(build2(" 1 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     freq = od.oe_field_display_value, dlrec->seq[d1.seq].meds[ml_cnt].free_text_cnt = 1,
     CALL echo("%%%%%% 2.12")
    ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
     CALL echo(build2(" 2 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     volume_dose = od.oe_field_display_value, dlrec->seq[d1.seq].meds[ml_cnt].volume_dose_cnt = 1
    ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
     CALL echo(build2(" 3 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     volume_unit = od.oe_field_display_value, dlrec->seq[d1.seq].meds[ml_cnt].volume_unit_cnt = 1
    ELSEIF (od.oe_field_meaning="RXROUTE")
     CALL echo(build2(" 4 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     route = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].route_cnt = 1
    ELSEIF (od.oe_field_meaning="FREETXTDOSE")
     CALL echo(build2(" 5 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     free_text = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].free_text_cnt = 1,
     CALL echo(build2(" 6 med select cnt:",trim(build2(ml_cnt),3)))
    ELSEIF (od.oe_field_meaning="DOSE")
     CALL echo(build2(" 7 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     dose = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].dose_cnt = 1
    ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
     CALL echo(build2("8 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_dose = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_dose_cnt = 0
    ELSEIF (od.oe_field_meaning="DOSEUNIT")
     CALL echo(build2("9 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     doseunit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].doseunit_cnt = 1
    ELSEIF (od.oe_field_meaning="STRENGTHUNIT")
     CALL echo(build2("10 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_unit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_unit_cnt = 1
    ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
     CALL echo(build2("11 med select cnt:",trim(build2(ml_cnt),3))), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_unit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[ml_cnt].
     strength_unit_cnt = 1
    ENDIF
    CALL echo("%%%%%% 2.9"),
    CALL echo(build2("detail size(dlrec->seq[d1.seq]->meds,5",size(dlrec->seq[d1.seq].meds,5))),
    CALL echo(build("detail d.seq =",d1.seq))
   FOOT  o.order_id
    CALL echo(build2("foot 1 med select cnt:",trim(build2(ml_cnt),3))),
    CALL echo("%%%%%% 3"),
    CALL echo(build2("foot 2 med select cnt:",trim(build2(ml_cnt),3))),
    row + 1,
    CALL echo(build2("footsize(dlrec->seq[d1.seq]->meds,5",size(dlrec->seq[d1.seq].meds,5))),
    CALL echo(build("foot d.seq =",d1.seq)),
    CALL echo(build2("dlrec->seq[d1.seq]->meds[ml_cnt].dose_cnt:",trim(build2(dlrec->seq[d1.seq].
       meds[ml_cnt].dose_cnt),3)))
    IF ((dlrec->seq[d1.seq].meds[ml_cnt].dose_cnt=1)
     AND (dlrec->seq[d1.seq].meds[ml_cnt].doseunit_cnt=1))
     CALL echo("%%%%%% 3.111"), dlrec->seq[d1.seq].meds[ml_cnt].dose = concat(trim(dlrec->seq[
       d1.seq].meds[ml_cnt].dose)," ",trim(dlrec->seq[d1.seq].meds[ml_cnt].doseunit)), row + 1
    ENDIF
    CALL echo("%%%%%% 3.112")
    IF ((dlrec->seq[d1.seq].meds[ml_cnt].volume_dose > " "))
     CALL echo("%%%%%% 3.1"), dlrec->seq[d1.seq].meds[ml_cnt].dose = concat(dlrec->seq[d1.seq].
      meds[ml_cnt].volume_dose," ",dlrec->seq[d1.seq].meds[ml_cnt].volume_unit)
    ELSEIF ((dlrec->seq[d1.seq].meds[ml_cnt].strength_dose > " ")
     AND (dlrec->seq[d1.seq].meds[ml_cnt].strength_unit > " "))
     CALL echo("%%%%%% 3.2"), dlrec->seq[d1.seq].meds[ml_cnt].dose = concat(dlrec->seq[d1.seq].
      meds[ml_cnt].strength_dose," ",dlrec->seq[d1.seq].meds[ml_cnt].strength_unit)
    ELSEIF ((dlrec->seq[d1.seq].meds[ml_cnt].free_text > " "))
     CALL echo("%%%%%% 3.3"), dlrec->seq[d1.seq].meds[ml_cnt].dose = dlrec->seq[d1.seq].meds[
     ml_cnt].free_text
    ENDIF
   FOOT  d1.seq
    CALL echo("%%%%%% 4")
    IF (ml_cnt > 0)
     dlrec->seq[d1.seq].number_of_meds = ml_cnt, stat = alterlist(dlrec->seq[d1.seq].meds,ml_cnt)
    ENDIF
   FOOT REPORT
    col + 0
   WITH nocounter, maxcol = 2000, format = variable
  ;end select
 ENDIF
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build(" Meds Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 CALL echo("get vitals")
 IF (size(dlrec->seq,5) > 0)
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event c,
    ce_date_result cdr,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.person_id=dlrec->seq[d1.seq].person_id)
     AND ((c.event_cd+ 0) IN (mf_weight_cd, mf_systolic_bp_cd, mf_diastolic_bp_cd, mf_pulse_cd,
    mf_bmi_cd))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (mf_inerror_cd, mf_notdone_cd))
     AND c.event_tag > " ")
    JOIN (cdr
    WHERE (cdr.event_id= Outerjoin(c.event_id))
     AND (c.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-dec-2100,00:00:00"))) )
   ORDER BY d1.seq, c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
   HEAD REPORT
    ml_v_cnt = 0
   HEAD d1.seq
    ml_v_cnt += 1, stat = alterlist(dlrec->seq[d1.seq].measurements,ml_v_cnt)
   HEAD c.event_cd
    CASE (c.event_cd)
     OF mf_weight_cd:
      dlrec->seq[d1.seq].measurements[ml_v_cnt].wt_result = concat(trim(c.result_val),
       uar_get_code_display(c.result_units_cd)),dlrec->seq[d1.seq].measurements[ml_v_cnt].wt_dt_tm =
      substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
     OF mf_pulse_cd:
      dlrec->seq[d1.seq].measurements[ml_v_cnt].pulse_result = trim(c.result_val),dlrec->seq[d1.seq].
      measurements[ml_v_cnt].pulse_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
     OF mf_systolic_bp_cd:
      dlrec->seq[d1.seq].measurements[ml_v_cnt].systolic_result = trim(c.result_val)
     OF mf_diastolic_bp_cd:
      dlrec->seq[d1.seq].measurements[ml_v_cnt].diastolic_result = trim(c.result_val),dlrec->seq[d1
      .seq].measurements[ml_v_cnt].bp_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
     OF mf_bmi_cd:
      dlrec->seq[d1.seq].measurements[ml_v_cnt].s_bmi = trim(c.result_val),dlrec->seq[d1.seq].
      measurements[ml_v_cnt].s_bmi_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
    ENDCASE
    dlrec->seq[d1.seq].measurements[ml_v_cnt].bp_display = concat(dlrec->seq[d1.seq].measurements[
     ml_v_cnt].systolic_result,"/",dlrec->seq[d1.seq].measurements[ml_v_cnt].diastolic_result)
   FOOT  d1.seq
    stat = alterlist(dlrec->seq[d1.seq].measurements,ml_v_cnt), ml_v_cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 SET md_select_endtime = cnvtdatetime(sysdate)
 SET md_selecttime = datetimediff(cnvtdatetime(md_select_endtime),cnvtdatetime(md_select_starttime),5
  )
 CALL echo(build("Vitals Time Info	 = ",md_selecttime))
 SET md_select_starttime = cnvtdatetime(sysdate)
 CALL echo("get Insurance from DTAs")
 IF (size(dlrec->seq,5) > 0)
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(dlrec->seq,5))),
    dcp_forms_activity dfa,
    dcp_forms_activity_comp dfac,
    clinical_event ce1,
    clinical_event ce2,
    clinical_event ce3
   PLAN (d1)
    JOIN (dfa
    WHERE (dfa.encntr_id=dlrec->seq[d1.seq].encntr_id)
     AND trim(dfa.description)="Rehabilitation Communication")
    JOIN (dfac
    WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
     AND trim(dfac.parent_entity_name)="CLINICAL_EVENT")
    JOIN (ce1
    WHERE ce1.event_id=dfac.parent_entity_id
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (ce3
    WHERE ce3.parent_event_id=ce2.event_id
     AND ce3.event_cd IN (mf_remainingvisits_var, mf_visitsapproved_var, mf_insurancerehab_var)
     AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce3.result_status_cd IN (mf_altered, mf_modified, mf_auth)
     AND ce3.event_tag != "In Error")
   ORDER BY dfa.person_id, dfa.form_dt_tm, ce3.parent_event_id,
    ce3.event_cd, ce3.event_end_dt_tm
   HEAD ce3.event_cd
    CASE (ce3.event_cd)
     OF mf_remainingvisits_var:
      dlrec->seq[d1.seq].ms_insu_remaining = trim(ce3.result_val)
     OF mf_visitsapproved_var:
      dlrec->seq[d1.seq].ms_insu_approved = trim(ce3.result_val)
     OF mf_insurancerehab_var:
      dlrec->seq[d1.seq].ms_insu_desc = concat(trim(ce3.result_val)," ",substring(1,14,format(ce3
         .event_end_dt_tm,"@SHORTDATE")))
    ENDCASE
   WITH nocounter
  ;end select
 ENDIF
 IF (size(dlrec->seq,5) > 0)
  SELECT DISTINCT INTO "nl:"
   person_id = dlrec->seq[d1.seq].person_id
   FROM (dummyt d1  WITH seq = value(size(dlrec->seq,5))),
    clinical_event ce,
    ce_event_prsnl cep,
    ce_blob cb
   PLAN (d1)
    JOIN (ce
    WHERE (ce.person_id=dlrec->seq[d1.seq].person_id)
     AND ce.event_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=72
      AND ((cv.display_key IN ("AUDIOLOGY*", "HEARING*", "PHYSICALTHERAPY*")) OR (cv.display_key IN (
     "SPEECHTHERAPY*", "OCCUPATIONALTHERAPY*"))) ))
     AND ce.result_status_cd IN (mf_altered, mf_modified, mf_auth)
     AND ce.valid_until_dt_tm > sysdate
     AND ce.event_tag != "In Error")
    JOIN (cep
    WHERE cep.person_id=ce.person_id
     AND cep.event_id=ce.event_id
     AND cep.action_dt_tm <= cnvtdatetime(ms_start_dt)
     AND cep.action_dt_tm >= cnvtdatetime(cnvtdate(dlrec->seq[d1.seq].ms_last_appt_dt),0)
     AND cep.action_status_cd=mf_completed_var
     AND cep.action_type_cd IN (mf_sign_var, mf_perform_var)
     AND cep.valid_until_dt_tm > sysdate)
    JOIN (cb
    WHERE cb.event_id=cep.event_id
     AND cb.valid_until_dt_tm > sysdate)
   ORDER BY person_id, cep.event_id, cep.action_dt_tm DESC
   HEAD person_id
    ml_n_cnt = 0
   HEAD cep.event_id
    ml_n_cnt += 1, stat = alterlist(dlrec->seq[d1.seq].note,ml_n_cnt), dlrec->seq[d1.seq].note[
    ml_n_cnt].note_date = format(cep.action_dt_tm,";;q"),
    dlrec->seq[d1.seq].note[ml_n_cnt].note_name = concat(cnvtstring(ce.event_id),uar_get_code_display
     (ce.event_cd))
    IF (cb.compression_cd=mf_ocfcomp)
     blob_compressed_trimmed = fillstring(64000," "), blob_uncompressed = fillstring(64000," "),
     blob_return_len = 0,
     blob_out = fillstring(64000," "), blob_compressed_trimmed = trim(cb.blob_contents,3),
     CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
     size(blob_uncompressed),blob_return_len),
     blob_out = replace(blob_uncompressed,"ocf_blob","",0)
    ELSE
     blob_out = blob_compressed_trimmed
    ENDIF
    blob_out = replace(blob_out,"fs2","fs3"), blob_out = replace(blob_out,"fs1","fs2"),
    CALL echo(blob_out),
    inbuffer = fillstring(32000," "), outbufferlen = 0, bfl = 0,
    bfl2 = 1, outbuffer = fillstring(32000," ")
    IF (findstring("{\rtf",trim(blob_out,3)))
     inbuffer = trim(blob_out),
     CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,bfl), blob_out =
     outbuffer
    ENDIF
    dlrec->seq[d1.seq].note[ml_n_cnt].note_content = trim(blob_out,3),
    CALL echo(build("last appt. = ",concat(dlrec->seq[d1.seq].s_fin," ",format(dlrec->seq[d1.seq].
       ms_last_appt_dt,";;q"))))
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(dlrec)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remcondition = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontactive_conditions = i2 WITH noconstant(0), protect
 DECLARE _remallergy = i4 WITH noconstant(1), protect
 DECLARE _remreaction = i4 WITH noconstant(1), protect
 DECLARE _bcontallergies = i2 WITH noconstant(0), protect
 DECLARE _remprocedure = i4 WITH noconstant(1), protect
 DECLARE _bcontprocedures = i2 WITH noconstant(0), protect
 DECLARE _remmedication = i4 WITH noconstant(1), protect
 DECLARE _bcontmedtitle = i2 WITH noconstant(0), protect
 DECLARE _reminstructions = i4 WITH noconstant(1), protect
 DECLARE _bcontmedinstructions = i2 WITH noconstant(0), protect
 DECLARE _remweight_result = i4 WITH noconstant(1), protect
 DECLARE _remheart_rate_result = i4 WITH noconstant(1), protect
 DECLARE _rembp_result = i4 WITH noconstant(1), protect
 DECLARE _remweight_date = i4 WITH noconstant(1), protect
 DECLARE _remheart_rate_date = i4 WITH noconstant(1), protect
 DECLARE _rembp_date = i4 WITH noconstant(1), protect
 DECLARE _rembmi_result = i4 WITH noconstant(1), protect
 DECLARE _rembmi_date = i4 WITH noconstant(1), protect
 DECLARE _bcontmeasurements = i2 WITH noconstant(0), protect
 DECLARE _reminsurance = i4 WITH noconstant(1), protect
 DECLARE _remapproved = i4 WITH noconstant(1), protect
 DECLARE _remvisits = i4 WITH noconstant(1), protect
 DECLARE _bcontinsurance = i2 WITH noconstant(0), protect
 DECLARE _remnotecontent = i4 WITH noconstant(1), protect
 DECLARE _bcontnote = i2 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c255 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (no_appt(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_apptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (no_apptabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   DECLARE __loc_name = vc WITH noconstant(build2(uar_get_code_description( $UNIT),char(0))), protect
   DECLARE __reqeusted_dt = vc WITH noconstant(build2(format(cnvtdatetime(ms_start_dt),
      "DD-MMM-YYYY;;D"),char(0))), protect
   IF ( NOT (size(dlrec->seq,5)=0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 2.775
    SET rptsd->m_height = 0.233
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Appointments Found for Location:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 4.067
    SET rptsd->m_height = 0.233
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__loc_name)
    SET rptsd->m_y = (offsety+ 0.067)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 3.167
    SET rptsd->m_height = 0.233
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqeusted_dt)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.067)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 2.608
    SET rptsd->m_height = 0.233
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("For the Requested Date:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (date_outofrange(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = date_outofrangeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (date_outofrangeabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.790000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.275)
    SET rptsd->m_x = (offsetx+ 0.025)
    SET rptsd->m_width = 5.042
    SET rptsd->m_height = 0.258
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Your date range is larger than 1 day.",char(0)))
    SET rptsd->m_y = (offsety+ 0.575)
    SET rptsd->m_x = (offsetx+ 0.033)
    SET rptsd->m_width = 5.033
    SET rptsd->m_height = 0.258
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c255)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PLEASE RETRY",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpage(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpageabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   DECLARE __reqeusted_dt = vc WITH noconstant(build2(format(cnvtdatetime(ms_start_dt),
      "DD-MMM-YYYY;;D"),char(0))), protect
   DECLARE __loc_name = vc WITH noconstant(build2(uar_get_code_description( $UNIT),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.317)
    SET rptsd->m_width = 3.067
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Health Summary",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.813),(offsetx+ 7.250),(offsety+
     0.813))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 5.942)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed on: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.942)
    SET rptsd->m_width = 1.483
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("All Appointments for :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.317)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 3.442
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqeusted_dt)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt. Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.442)
    SET rptsd->m_width = 4.067
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__loc_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (patinfo(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patinfoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (patinfoabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.790000), private
   DECLARE __name = vc WITH noconstant(build2(dlrec->seq[cnt_pat].name_full_formatted,char(0))),
   protect
   DECLARE __dob = vc WITH noconstant(build2(dlrec->seq[cnt_pat].birth_dt_tm,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(dlrec->seq[cnt_pat].age,char(0))), protect
   DECLARE __pcp = vc WITH noconstant(build2(dlrec->seq[cnt_pat].pcpdoc_name,char(0))), protect
   DECLARE __resources = vc WITH noconstant(build2(dlrec->seq[cnt_pat].resource,char(0))), protect
   DECLARE __reason_for_appt = vc WITH noconstant(build2(dlrec->seq[cnt_pat].appt_description,char(0)
     )), protect
   DECLARE __fin = vc WITH noconstant(build2(dlrec->seq[cnt_pat].s_fin,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.067)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.192
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.192)
    SET rptsd->m_x = (offsetx+ 1.067)
    SET rptsd->m_width = 0.692
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.067)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp)
    SET rptsd->m_y = (offsety+ 0.192)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 1.467
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__resources)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.942
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.192)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.817
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.525
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.442)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Care Physician:",char(0)))
    SET rptsd->m_y = (offsety+ 0.192)
    SET rptsd->m_x = (offsetx+ 3.442)
    SET rptsd->m_width = 1.575
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Assign Resource:",char(0)))
    SET rptsd->m_y = (offsety+ 0.567)
    SET rptsd->m_x = (offsetx+ - (0.008))
    SET rptsd->m_width = 1.075
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Appt. :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.567)
    SET rptsd->m_x = (offsetx+ 1.192)
    SET rptsd->m_width = 6.250
    SET rptsd->m_height = 0.192
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reason_for_appt)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.442)
    SET rptsd->m_width = 1.575
    SET rptsd->m_height = 0.192
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 0.692
    SET rptsd->m_height = 0.192
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (no_active_conditions(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_active_conditionsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (no_active_conditionsabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.817
    SET rptsd->m_height = 0.192
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Active Conditions(problems)",char(
       0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (page_foot1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_foot1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (page_foot1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.040000), private
   IF ( NOT (curendreport != 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (active_conditions_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditions_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (active_conditions_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.163),(offsetx+ 7.250),(offsety+
     0.163))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.317
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Conditions",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (active_conditions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (active_conditionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_condition = f8 WITH noconstant(0.0), private
   DECLARE __condition = vc WITH noconstant(build2(dlrec->seq[cnt_pat].problem[x].text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remcondition = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcondition = _remcondition
   IF (_remcondition > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcondition,((size(
        __condition) - _remcondition)+ 1),__condition)))
    SET drawheight_condition = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcondition = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcondition,((size(__condition) -
       _remcondition)+ 1),__condition)))))
     SET _remcondition += rptsd->m_drawlength
    ELSE
     SET _remcondition = 0
    ENDIF
    SET growsum += _remcondition
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_condition
   IF (ncalc=rpt_render
    AND _holdremcondition > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcondition,((size(
        __condition) - _holdremcondition)+ 1),__condition)))
   ELSE
    SET _remcondition = _holdremcondition
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (allergies_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergies_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (allergies_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.692
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.942)
    SET rptsd->m_width = 3.067
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.163),(offsetx+ 7.250),(offsety+
     0.163))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (allergies(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergiesabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (allergiesabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.180000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_allergy = f8 WITH noconstant(0.0), private
   DECLARE drawheight_reaction = f8 WITH noconstant(0.0), private
   DECLARE __allergy = vc WITH noconstant(build2(dlrec->seq[cnt_pat].allergy[x].source_string,char(0)
     )), protect
   DECLARE __reaction = vc WITH noconstant(build2(dlrec->seq[cnt_pat].allergy[x].reaction_display,
     char(0))), protect
   IF (bcontinue=0)
    SET _remallergy = 1
    SET _remreaction = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.692
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremallergy = _remallergy
   IF (_remallergy > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergy,((size(
        __allergy) - _remallergy)+ 1),__allergy)))
    SET drawheight_allergy = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remallergy = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergy,((size(__allergy) -
       _remallergy)+ 1),__allergy)))))
     SET _remallergy += rptsd->m_drawlength
    ELSE
     SET _remallergy = 0
    ENDIF
    SET growsum += _remallergy
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 3.067
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremreaction = _remreaction
   IF (_remreaction > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remreaction,((size(
        __reaction) - _remreaction)+ 1),__reaction)))
    SET drawheight_reaction = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remreaction = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remreaction,((size(__reaction) -
       _remreaction)+ 1),__reaction)))))
     SET _remreaction += rptsd->m_drawlength
    ELSE
     SET _remreaction = 0
    ENDIF
    SET growsum += _remreaction
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.692
   SET rptsd->m_height = drawheight_allergy
   IF (ncalc=rpt_render
    AND _holdremallergy > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergy,((size(
        __allergy) - _holdremallergy)+ 1),__allergy)))
   ELSE
    SET _remallergy = _holdremallergy
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 3.067
   SET rptsd->m_height = drawheight_reaction
   IF (ncalc=rpt_render
    AND _holdremreaction > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremreaction,((size(
        __reaction) - _holdremreaction)+ 1),__reaction)))
   ELSE
    SET _remreaction = _holdremreaction
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (no_allergy(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_allergyabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (no_allergyabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.817
    SET rptsd->m_height = 0.192
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("no allergy data",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (procedures_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = procedures_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (procedures_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Procedure",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.205),(offsetx+ 7.250),(offsety+
     0.205))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.733
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedures",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (procedures(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = proceduresabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (proceduresabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_procedure = f8 WITH noconstant(0.0), private
   DECLARE __procedure = vc WITH noconstant(build2(dlrec->seq[cnt_pat].procedure[x].proc_name,char(0)
     )), protect
   DECLARE __procedure_date = vc WITH noconstant(build2(dlrec->seq[cnt_pat].procedure[x].proc_dt_tm,
     char(0))), protect
   DECLARE __procedure_provider = vc WITH noconstant(build2(dlrec->seq[cnt_pat].procedure[x].
     proc_provider,char(0))), protect
   IF (bcontinue=0)
    SET _remprocedure = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprocedure = _remprocedure
   IF (_remprocedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprocedure,((size(
        __procedure) - _remprocedure)+ 1),__procedure)))
    SET drawheight_procedure = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprocedure = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprocedure,((size(__procedure) -
       _remprocedure)+ 1),__procedure)))))
     SET _remprocedure += rptsd->m_drawlength
    ELSE
     SET _remprocedure = 0
    ENDIF
    SET growsum += _remprocedure
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_procedure
   IF (ncalc=rpt_render
    AND _holdremprocedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprocedure,((size(
        __procedure) - _holdremprocedure)+ 1),__procedure)))
   ELSE
    SET _remprocedure = _holdremprocedure
   ENDIF
   SET rptsd->m_flags = 8
   SET rptsd->m_y = (offsety+ 0.067)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.442
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__procedure_date)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.983
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__procedure_provider)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (medication_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medication_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (medication_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Medications",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.196),(offsetx+ 7.250),(offsety+
     0.196))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (medtitle(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medtitleabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (medtitleabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_medication = f8 WITH noconstant(0.0), private
   DECLARE __medication = vc WITH noconstant(build2(dlrec->seq[cnt_pat].meds[x].ordered_as_mnemonic,
     char(0))), protect
   IF (bcontinue=0)
    SET _remmedication = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.442
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmedication = _remmedication
   IF (_remmedication > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedication,((size(
        __medication) - _remmedication)+ 1),__medication)))
    SET drawheight_medication = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedication = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedication,((size(__medication) -
       _remmedication)+ 1),__medication)))))
     SET _remmedication += rptsd->m_drawlength
    ELSE
     SET _remmedication = 0
    ENDIF
    SET growsum += _remmedication
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.442
   SET rptsd->m_height = drawheight_medication
   IF (ncalc=rpt_render
    AND _holdremmedication > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedication,((size(
        __medication) - _holdremmedication)+ 1),__medication)))
   ELSE
    SET _remmedication = _holdremmedication
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (medications(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medicationsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (medicationsabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __dose = vc WITH noconstant(build2(dlrec->seq[cnt_pat].meds[x].dose,char(0))), protect
   DECLARE __freq = vc WITH noconstant(build2(dlrec->seq[cnt_pat].meds[x].freq,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.692)
    SET rptsd->m_width = 2.817
    SET rptsd->m_height = 0.250
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dose)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.192
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__freq)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Dose:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.317
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Freq:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (medinstructions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medinstructionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (medinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_instructions = f8 WITH noconstant(0.0), private
   DECLARE __instructions = vc WITH noconstant(build2(dlrec->seq[cnt_pat].meds[x].comments,char(0))),
   protect
   IF (bcontinue=0)
    SET _reminstructions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.192)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdreminstructions = _reminstructions
   IF (_reminstructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminstructions,((size(
        __instructions) - _reminstructions)+ 1),__instructions)))
    SET drawheight_instructions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminstructions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminstructions,((size(__instructions) -
       _reminstructions)+ 1),__instructions)))))
     SET _reminstructions += rptsd->m_drawlength
    ELSE
     SET _reminstructions = 0
    ENDIF
    SET growsum += _reminstructions
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.192)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = drawheight_instructions
   IF (ncalc=rpt_render
    AND _holdreminstructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminstructions,((
       size(__instructions) - _holdreminstructions)+ 1),__instructions)))
   ELSE
    SET _reminstructions = _holdreminstructions
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.192
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Instructions",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (immun_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immun_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (immun_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunizations",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunization Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.230),(offsetx+ 7.250),(offsety+
     0.230))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (immun(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immunabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (immunabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __immunization = vc WITH noconstant(build2(dlrec->seq[1].immunization[x].name,char(0))),
   protect
   DECLARE __immunization_date = vc WITH noconstant(build2(dlrec->seq[1].immunization[x].given_date,
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.025)
    SET rptsd->m_width = 3.983
    SET rptsd->m_height = 0.283
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.258
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization_date)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (measurements_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurements_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (measurements_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Last Result",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.179),(offsetx+ 7.250),(offsety+
     0.179))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.233
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Measurements",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Result",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (measurements(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurementsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (measurementsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_weight_result = f8 WITH noconstant(0.0), private
   DECLARE drawheight_heart_rate_result = f8 WITH noconstant(0.0), private
   DECLARE drawheight_bp_result = f8 WITH noconstant(0.0), private
   DECLARE drawheight_weight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_heart_rate_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_bp_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_bmi_result = f8 WITH noconstant(0.0), private
   DECLARE drawheight_bmi_date = f8 WITH noconstant(0.0), private
   DECLARE __weight_result = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[x].wt_result,
     char(0))), protect
   DECLARE __heart_rate_result = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[x].
     pulse_result,char(0))), protect
   DECLARE __bp_result = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[1].bp_display,
     char(0))), protect
   DECLARE __weight_date = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[x].wt_dt_tm,
     char(0))), protect
   DECLARE __heart_rate_date = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[x].
     pulse_dt_tm,char(0))), protect
   DECLARE __bp_date = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[x].bp_dt_tm,char(0)
     )), protect
   DECLARE __bmi_result = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[1].s_bmi,char(0)
     )), protect
   DECLARE __bmi_date = vc WITH noconstant(build2(dlrec->seq[cnt_pat].measurements[1].s_bmi_dt_tm,
     char(0))), protect
   IF (bcontinue=0)
    SET _remweight_result = 1
    SET _remheart_rate_result = 1
    SET _rembp_result = 1
    SET _remweight_date = 1
    SET _remheart_rate_date = 1
    SET _rembp_date = 1
    SET _rembmi_result = 1
    SET _rembmi_date = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremweight_result = _remweight_result
   IF (_remweight_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweight_result,((size(
        __weight_result) - _remweight_result)+ 1),__weight_result)))
    SET drawheight_weight_result = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweight_result = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweight_result,((size(__weight_result)
        - _remweight_result)+ 1),__weight_result)))))
     SET _remweight_result += rptsd->m_drawlength
    ELSE
     SET _remweight_result = 0
    ENDIF
    SET growsum += _remweight_result
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.200)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremheart_rate_result = _remheart_rate_result
   IF (_remheart_rate_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remheart_rate_result,((
       size(__heart_rate_result) - _remheart_rate_result)+ 1),__heart_rate_result)))
    SET drawheight_heart_rate_result = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remheart_rate_result = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remheart_rate_result,((size(
        __heart_rate_result) - _remheart_rate_result)+ 1),__heart_rate_result)))))
     SET _remheart_rate_result += rptsd->m_drawlength
    ELSE
     SET _remheart_rate_result = 0
    ENDIF
    SET growsum += _remheart_rate_result
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrembp_result = _rembp_result
   IF (_rembp_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rembp_result,((size(
        __bp_result) - _rembp_result)+ 1),__bp_result)))
    SET drawheight_bp_result = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rembp_result = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rembp_result,((size(__bp_result) -
       _rembp_result)+ 1),__bp_result)))))
     SET _rembp_result += rptsd->m_drawlength
    ELSE
     SET _rembp_result = 0
    ENDIF
    SET growsum += _rembp_result
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.233
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremweight_date = _remweight_date
   IF (_remweight_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweight_date,((size(
        __weight_date) - _remweight_date)+ 1),__weight_date)))
    SET drawheight_weight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweight_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweight_date,((size(__weight_date) -
       _remweight_date)+ 1),__weight_date)))))
     SET _remweight_date += rptsd->m_drawlength
    ELSE
     SET _remweight_date = 0
    ENDIF
    SET growsum += _remweight_date
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.200)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremheart_rate_date = _remheart_rate_date
   IF (_remheart_rate_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remheart_rate_date,((size
       (__heart_rate_date) - _remheart_rate_date)+ 1),__heart_rate_date)))
    SET drawheight_heart_rate_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remheart_rate_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remheart_rate_date,((size(
        __heart_rate_date) - _remheart_rate_date)+ 1),__heart_rate_date)))))
     SET _remheart_rate_date += rptsd->m_drawlength
    ELSE
     SET _remheart_rate_date = 0
    ENDIF
    SET growsum += _remheart_rate_date
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrembp_date = _rembp_date
   IF (_rembp_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rembp_date,((size(
        __bp_date) - _rembp_date)+ 1),__bp_date)))
    SET drawheight_bp_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rembp_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rembp_date,((size(__bp_date) -
       _rembp_date)+ 1),__bp_date)))))
     SET _rembp_date += rptsd->m_drawlength
    ELSE
     SET _rembp_date = 0
    ENDIF
    SET growsum += _rembp_date
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.567)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrembmi_result = _rembmi_result
   IF (_rembmi_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rembmi_result,((size(
        __bmi_result) - _rembmi_result)+ 1),__bmi_result)))
    SET drawheight_bmi_result = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rembmi_result = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rembmi_result,((size(__bmi_result) -
       _rembmi_result)+ 1),__bmi_result)))))
     SET _rembmi_result += rptsd->m_drawlength
    ELSE
     SET _rembmi_result = 0
    ENDIF
    SET growsum += _rembmi_result
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.567)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrembmi_date = _rembmi_date
   IF (_rembmi_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rembmi_date,((size(
        __bmi_date) - _rembmi_date)+ 1),__bmi_date)))
    SET drawheight_bmi_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rembmi_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rembmi_date,((size(__bmi_date) -
       _rembmi_date)+ 1),__bmi_date)))))
     SET _rembmi_date += rptsd->m_drawlength
    ELSE
     SET _rembmi_date = 0
    ENDIF
    SET growsum += _rembmi_date
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.025)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.200)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.258
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Heart Rate",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.375)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.317
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Pressure",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_weight_result
   IF (ncalc=rpt_render
    AND _holdremweight_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweight_result,((
       size(__weight_result) - _holdremweight_result)+ 1),__weight_result)))
   ELSE
    SET _remweight_result = _holdremweight_result
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.200)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_heart_rate_result
   IF (ncalc=rpt_render
    AND _holdremheart_rate_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremheart_rate_result,
       ((size(__heart_rate_result) - _holdremheart_rate_result)+ 1),__heart_rate_result)))
   ELSE
    SET _remheart_rate_result = _holdremheart_rate_result
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_bp_result
   IF (ncalc=rpt_render
    AND _holdrembp_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrembp_result,((size(
        __bp_result) - _holdrembp_result)+ 1),__bp_result)))
   ELSE
    SET _rembp_result = _holdrembp_result
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.025)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.233
   SET rptsd->m_height = drawheight_weight_date
   IF (ncalc=rpt_render
    AND _holdremweight_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweight_date,((size
       (__weight_date) - _holdremweight_date)+ 1),__weight_date)))
   ELSE
    SET _remweight_date = _holdremweight_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.200)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_heart_rate_date
   IF (ncalc=rpt_render
    AND _holdremheart_rate_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremheart_rate_date,((
       size(__heart_rate_date) - _holdremheart_rate_date)+ 1),__heart_rate_date)))
   ELSE
    SET _remheart_rate_date = _holdremheart_rate_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_bp_date
   IF (ncalc=rpt_render
    AND _holdrembp_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrembp_date,((size(
        __bp_date) - _holdrembp_date)+ 1),__bp_date)))
   ELSE
    SET _rembp_date = _holdrembp_date
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.567)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.317
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMI",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.567)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_bmi_result
   IF (ncalc=rpt_render
    AND _holdrembmi_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrembmi_result,((size(
        __bmi_result) - _holdrembmi_result)+ 1),__bmi_result)))
   ELSE
    SET _rembmi_result = _holdrembmi_result
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.567)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_bmi_date
   IF (ncalc=rpt_render
    AND _holdrembmi_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrembmi_date,((size(
        __bmi_date) - _holdrembmi_date)+ 1),__bmi_date)))
   ELSE
    SET _rembmi_date = _holdrembmi_date
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (insurance_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insurance_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (insurance_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.233
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Visits Approved",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.192
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Remaining Visits",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.171),(offsetx+ 7.250),(offsety+
     0.171))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (insurance(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insuranceabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (insuranceabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.180000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_insurance = f8 WITH noconstant(0.0), private
   DECLARE drawheight_approved = f8 WITH noconstant(0.0), private
   DECLARE drawheight_visits = f8 WITH noconstant(0.0), private
   DECLARE __insurance = vc WITH noconstant(build2(dlrec->seq[cnt_pat].ms_insu_desc,char(0))),
   protect
   DECLARE __approved = vc WITH noconstant(build2(dlrec->seq[cnt_pat].ms_insu_approved,char(0))),
   protect
   DECLARE __visits = vc WITH noconstant(build2(dlrec->seq[cnt_pat].ms_insu_remaining,char(0))),
   protect
   IF (bcontinue=0)
    SET _reminsurance = 1
    SET _remapproved = 1
    SET _remvisits = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.442
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdreminsurance = _reminsurance
   IF (_reminsurance > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminsurance,((size(
        __insurance) - _reminsurance)+ 1),__insurance)))
    SET drawheight_insurance = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminsurance = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminsurance,((size(__insurance) -
       _reminsurance)+ 1),__insurance)))))
     SET _reminsurance += rptsd->m_drawlength
    ELSE
     SET _reminsurance = 0
    ENDIF
    SET growsum += _reminsurance
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremapproved = _remapproved
   IF (_remapproved > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remapproved,((size(
        __approved) - _remapproved)+ 1),__approved)))
    SET drawheight_approved = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remapproved = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remapproved,((size(__approved) -
       _remapproved)+ 1),__approved)))))
     SET _remapproved += rptsd->m_drawlength
    ELSE
     SET _remapproved = 0
    ENDIF
    SET growsum += _remapproved
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremvisits = _remvisits
   IF (_remvisits > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvisits,((size(__visits
        ) - _remvisits)+ 1),__visits)))
    SET drawheight_visits = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvisits = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvisits,((size(__visits) - _remvisits)
       + 1),__visits)))))
     SET _remvisits += rptsd->m_drawlength
    ELSE
     SET _remvisits = 0
    ENDIF
    SET growsum += _remvisits
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.442
   SET rptsd->m_height = drawheight_insurance
   IF (ncalc=rpt_render
    AND _holdreminsurance > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminsurance,((size(
        __insurance) - _holdreminsurance)+ 1),__insurance)))
   ELSE
    SET _reminsurance = _holdreminsurance
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_approved
   IF (ncalc=rpt_render
    AND _holdremapproved > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremapproved,((size(
        __approved) - _holdremapproved)+ 1),__approved)))
   ELSE
    SET _remapproved = _holdremapproved
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_visits
   IF (ncalc=rpt_render
    AND _holdremvisits > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvisits,((size(
        __visits) - _holdremvisits)+ 1),__visits)))
   ELSE
    SET _remvisits = _holdremvisits
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (notenametitle(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = notenametitleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (notenametitleabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.350000), private
   DECLARE __notename = vc WITH noconstant(build2(concat(dlrec->seq[cnt_pat].note[mn_y].note_name," ",
      dlrec->seq[cnt_pat].note[mn_y].note_date),char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.304),(offsetx+ 7.250),(offsety+
     0.304))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.067)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.442
    SET rptsd->m_height = 0.192
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__notename)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (note(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = noteabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (noteabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_notecontent = f8 WITH noconstant(0.0), private
   DECLARE __notecontent = vc WITH noconstant(build2(dlrec->seq[cnt_pat].note[mn_y].note_content,char
     (0))), protect
   IF (bcontinue=0)
    SET _remnotecontent = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremnotecontent = _remnotecontent
   IF (_remnotecontent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnotecontent,((size(
        __notecontent) - _remnotecontent)+ 1),__notecontent)))
    SET drawheight_notecontent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnotecontent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnotecontent,((size(__notecontent) -
       _remnotecontent)+ 1),__notecontent)))))
     SET _remnotecontent += rptsd->m_drawlength
    ELSE
     SET _remnotecontent = 0
    ENDIF
    SET growsum += _remnotecontent
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_notecontent
   IF (ncalc=rpt_render
    AND _holdremnotecontent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnotecontent,((size
       (__notecontent) - _holdremnotecontent)+ 1),__notecontent)))
   ELSE
    SET _remnotecontent = _holdremnotecontent
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (page_foot(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (page_footabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.040000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPTREHAB"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 42:
       _outputtype = rpt_zebra300,_xdiv = 300,_ydiv = 300
      OF 43:
       _outputtype = rpt_zebra600,_xdiv = 600,_ydiv = 600
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _diotype = cnvtint(p_printer_type_cdf), _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = rpt_red
   SET _pen14s0c255 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SUBROUTINE (sub_head_page(beg_report=i2) =null)
  SET d0 = headpage(rpt_render)
  SET d0 = patinfo(rpt_render)
 END ;Subroutine
 SUBROUTINE (sub_head_page1(beg_report=i2) =null)
   SET d0 = headpage(rpt_render)
 END ;Subroutine
 SUBROUTINE (sub_foot_page(end_report=i2) =null)
  SET d0 = page_foot(rpt_render)
  IF (end_report=0)
   SET d0 = pagebreak(0)
  ENDIF
 END ;Subroutine
 SET d0 = initializereport(0)
 FOR (cnt_pat = 1 TO size(dlrec->seq,5))
   SET d0 = sub_head_page(0)
   IF ((((_yoffset+ active_conditions_head(rpt_calcheight))+ 1) > mf_page_size))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = active_conditions_head(rpt_render)
   IF (size(dlrec->seq[cnt_pat].problem,5) > 0)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].problem,5))
      SET mf_remain_space = (mf_page_size - _yoffset)
      SET mf_remain_space = (mf_page_size - _yoffset)
      IF (((_yoffset+ active_conditions(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
       SET d0 = active_conditions_head(rpt_render)
      ENDIF
      WHILE (becont=1)
        SET d0 = page_foot(rpt_render)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
        SET continued = "(continued)"
        SET d0 = active_conditions_head(rpt_render)
        SET continued = ""
        SET mf_remain_space = (mf_page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = active_conditions(rpt_render,mf_remain_space,becont)
    ENDFOR
   ELSE
    SET d0 = no_active_conditions(rpt_render)
   ENDIF
   IF (((_yoffset+ allergies_head(rpt_calcheight)) > mf_page_size))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = allergies_head(rpt_render)
   IF (size(dlrec->seq[cnt_pat].allergy,5) > 0)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].allergy,5))
      SET mf_remain_space = (mf_page_size - _yoffset)
      IF (((_yoffset+ allergies(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
       SET d0 = allergies_head(rpt_render)
      ENDIF
      WHILE (becont=1)
        SET d0 = page_foot(rpt_render)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
        SET continued = "(continued)"
        SET d0 = allergies_head(rpt_render)
        SET continued = ""
        SET mf_remain_space = (mf_page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = allergies(rpt_render,mf_remain_space,becont)
    ENDFOR
   ELSE
    SET d0 = no_allergy(rpt_render)
   ENDIF
   IF (size(dlrec->seq[cnt_pat].meds,5) > 0)
    IF (((_yoffset+ medication_head(rpt_calcheight)) > mf_page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDIF
    SET d0 = medication_head(rpt_render)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].meds,5))
      SET mf_remain_space = (mf_page_size - _yoffset)
      IF (((_yoffset+ medtitle(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
       SET d0 = medication_head(rpt_render)
      ENDIF
      WHILE (becont=1)
        SET d0 = page_foot(rpt_render)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
        SET continued = "(continued)"
        SET d0 = medication_head(rpt_render)
        SET continued = ""
        SET mf_remain_space = (mf_page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = medtitle(rpt_render,mf_remain_space,becont)
    ENDFOR
   ENDIF
   IF (size(dlrec->seq[cnt_pat].measurements,5) > 0)
    IF (((_yoffset+ measurements_head(rpt_calcheight)) > mf_page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDIF
    SET d0 = measurements_head(rpt_render)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].measurements,5))
      SET mf_remain_space = (mf_page_size - _yoffset)
      IF (((_yoffset+ measurements(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
       SET d0 = measurements_head(rpt_render)
      ENDIF
      WHILE (becont=1)
        SET d0 = page_foot(rpt_render)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
        SET continued = "(continued)"
        SET d0 = measurements_head(rpt_render)
        SET continued = ""
        SET mf_remain_space = (mf_page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = measurements(rpt_render,mf_remain_space,becont)
    ENDFOR
   ENDIF
   IF (size(dlrec->seq[cnt_pat],5) > 0
    AND textlen(dlrec->seq[cnt_pat].ms_insu_desc) > 0)
    IF (((_yoffset+ insurance_head(rpt_calcheight)) > mf_page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDIF
    SET d0 = insurance_head(rpt_render)
    SET mf_remain_space = (mf_page_size - _yoffset)
    IF (((_yoffset+ insurance(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
     SET d0 = insurance_head(rpt_render)
    ENDIF
    WHILE (becont=1)
      SET d0 = page_foot(rpt_render)
      SET _yoffset = 10.18
      SET d0 = pagebreak(0)
      SET continued = "(continued)"
      SET d0 = insurance_head(rpt_render)
      SET continued = ""
      SET mf_remain_space = (mf_page_size - _yoffset)
      SET becont = 0
    ENDWHILE
    SET d0 = insurance(rpt_render,mf_remain_space,becont)
   ENDIF
   IF (size(dlrec->seq[cnt_pat].note,5) > 0)
    FOR (mn_y = 1 TO size(dlrec->seq[cnt_pat].note,5))
      IF (((_yoffset+ notenametitle(rpt_calcheight)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
      ENDIF
      SET d0 = notenametitle(rpt_render)
      SET mf_remain_space = (mf_page_size - _yoffset)
      IF (((_yoffset+ note(rpt_calcheight,mf_remain_space,becont)) > mf_page_size))
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
       SET d0 = notenametitle(rpt_render)
      ENDIF
      WHILE (becont=1)
        SET d0 = page_foot(rpt_render)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
        SET continued = "(continued)"
        SET d0 = sub_head_page1(0)
        SET d0 = notenametitle(rpt_render)
        SET continued = ""
        SET mf_remain_space = (mf_page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = note(rpt_render,mf_remain_space,becont)
    ENDFOR
   ENDIF
   SET d0 = page_foot(rpt_render)
   SET d0 = page_foot1(rpt_render)
   SET _yoffset = 10.50
 ENDFOR
 CALL echo(build("ms_var_output(finalize)  = ",ms_var_output))
 SET d0 = no_appt(rpt_render)
 SET d0 = finalizereport(ms_var_output)
 IF (mn_operations=1)
  SET spool value(ms_var_output) value( $OUTDEV) WITH nodeleted
 ENDIF
 CALL echo("End Record")
#exit_prg
END GO
