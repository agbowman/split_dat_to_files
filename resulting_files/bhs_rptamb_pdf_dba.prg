CREATE PROGRAM bhs_rptamb_pdf:dba
 PROMPT
  "error print to" = "MINE",
  "Output to File/Printer/MINE" = "MINE",
  "Begin date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Facility" = 0,
  "Ambulatory Unit" = 0
  WITH printonerror, outdev, beg_dt,
  end_dt, facility, unit
 DECLARE stop_dt = vc WITH protect
 DECLARE start_dt = vc WITH protect
 DECLARE out_of_range = i1 WITH noconstant(0), protect
 DECLARE remain_space = f8 WITH protect
 SET becont = 0
 DECLARE page_size = f8 WITH noconstant(10.0), protect
 DECLARE rescheduled_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"RESCHEDULED")), protect
 DECLARE pending_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"PENDING")), protect
 DECLARE scheduled_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"SCHEDULED")), protect
 DECLARE appointment_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"APPOINTMENT")), protect
 DECLARE finalized_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"FINALIZED")), protect
 DECLARE confirmed_sch = f8 WITH constant(uar_get_code_by("MEANING",14233,"CONFIRMED")), protect
 DECLARE notdone_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE")), protect
 DECLARE inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE pendingreview_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE")),
 protect
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDING")), protect
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE")), protect
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE pharmacy_cattyp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE allergy_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED")), protect
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE scd_data_cd = f8 WITH public, constant(uar_get_code_by("MEANING",15752,"DATA"))
 DECLARE sensitive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"SENSITIVE"))
 DECLARE active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,"ACTIVE")
  )
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE consultdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"CONSULTDOC"))
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE pulse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_fu_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FOLLOWUPAPPOINTMENT"))
 DECLARE mf_pat_care_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE mn_diab_ind = i2 WITH protect, noconstant(0)
 SET operations = 0
 CALL echo(build("time diff ^^^^ =",datetimediff(cnvtdatetime( $END_DT),cnvtdatetime( $BEG_DT))))
 SET out_of_range = 0
 IF (datetimediff(cnvtdatetime( $END_DT),cnvtdatetime( $BEG_DT)) > 1.0)
  SET out_of_range = 1
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
  SET out_of_range = 1
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
  SET start_dt = cnvtdatetime2(curdate,0)
  SET stop_dt = cnvtdatetime2(curdate,235959)
  SET operations = 1
  SET tempname = replace(trim(uar_get_code_display(cnvtreal( $FACILITY)))," ","_",0)
  SET tempname = replace(trim(tempname),"/","",0)
  SET tempname = replace(trim(tempname),"-","",0)
  SET tempname = replace(trim(tempname),"&","",0)
  SET tempname = replace(trim(tempname),"__","_",0)
  SET tempname = substring(1,30,tempname)
  SET var_output = trim(tempname,3)
  SET var_output = build(var_output,".ps")
  CALL echo(var_output)
 ELSE
  SET start_dt =  $BEG_DT
  SET stop_dt =  $END_DT
  CALL echo(build("$outdev = ", $OUTDEV))
  IF (( $OUTDEV="MINE"))
   SET var_output =  $PRINTONERROR
  ELSE
   SET var_output =  $OUTDEV
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
     2 disch_date = dq8
     2 person_id = f8
     2 sch_event_id = f8
     2 resource = vc
     2 location = vc
     2 location_cd = f8
     2 name_full_formatted = vc
     2 appt_description = vc
     2 age = c12
     2 f_sex_cd = f8
     2 l_age_in_yrs = i4
     2 birth_dt_tm = vc
     2 pcpdoc_name = vc
     2 consult_doc[*]
       3 consult_name = vc
     2 immunization[*]
       3 n_type = i2
       3 name = vc
       3 given_date = vc
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
     2 diagnosis[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = c16
       3 diag_type_desc = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
       3 full_text = vc
     2 procedure_total = i4
     2 procedure[*]
       3 proc_name = vc
       3 proc_dt_tm = c20
       3 proc_provider = vc
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 date = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 display_line = vc
       3 long_text = vc
       3 freq = c30
       3 freq_cnt = i2
       3 dose = c30
       3 dose_cnt = i2
       3 doseunit = c30
       3 doseunit_cnt = i2
       3 next_dose_dt_tm = c14
       3 order_comment_ind = i2
       3 order_person = vc
       3 order_doctor = vc
       3 need_rx_verify_ind = i2
       3 need_rx_verify_str = vc
       3 mso = i2
       3 ioi = i2
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
     2 hm_cnt = i4
     2 hm[*]
       3 step_desc = vc
       3 last_satisfied_dt_tm = vc
       3 overdue_ind = i2
       3 s_mammo_due_dt_tm = vc
       3 n_mammo_overdue = i2
       3 s_cervical_due_dt_tm = vc
       3 n_cervical_overdue = i2
       3 s_colo_due_dt_tm = vc
       3 n_colo_overdue = i2
       3 s_diab_ret_due_dt_tm = vc
       3 n_diab_ret_overdue = i2
       3 s_diab_hba1c_result = vc
       3 s_diab_hba1c_due_dt_tm = vc
       3 s_diab_microalb_result = vc
       3 s_diab_microalb_due_dt_tm = vc
       3 s_ldl_result = vc
       3 s_ldl_due_dt_tm = vc
     2 pat_inst_cnt = i4
     2 pat_inst[*]
       3 text = vc
     2 req_ords[*]
       3 f_order_id = f8
       3 s_name = vc
       3 s_ord_desc = vc
     2 fu_ords[*]
       3 f_order_id = f8
       3 s_name = vc
       3 s_ord_desc = vc
 )
 SET dlrec->encntr_total = 0
 SET select_starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  sa_appt_location_disp = uar_get_code_display(sa.appt_location_cd), sa1_resource_disp =
  uar_get_code_display(sa1.resource_cd)
  FROM sch_appt sa,
   code_value cv,
   sch_appt sa1
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(start_dt) AND (cnvtdatetime(stop_dt)+ 0)
    AND (sa.appt_location_cd= $UNIT)
    AND ((sa.encntr_id+ 0) > 0)
    AND sa.sch_state_cd IN (rescheduled_sch, pending_sch, scheduled_sch, appointment_sch,
   finalized_sch,
   confirmed_sch))
   JOIN (sa1
   WHERE sa.schedule_id=sa1.schedule_id
    AND ((sa1.primary_role_ind+ 0)=1))
   JOIN (cv
   WHERE cv.code_value=sa.appt_location_cd)
  ORDER BY sa.sch_event_id, sa.updt_dt_tm DESC
  HEAD REPORT
   cnt_sch = 0, stat = alterlist(dlrec->seq,10)
  HEAD sa.sch_event_id
   IF (sa.sch_state_cd IN (rescheduled_sch, pending_sch, scheduled_sch, appointment_sch,
   finalized_sch,
   confirmed_sch))
    cnt_sch = (cnt_sch+ 1)
    IF (mod(cnt_sch,10)=1
     AND cnt_sch != 1)
     stat = alterlist(dlrec->seq,(cnt_sch+ 9))
    ENDIF
    dlrec->seq[cnt_sch].encntr_id = sa.encntr_id, dlrec->seq[cnt_sch].resource = sa1_resource_disp,
    dlrec->seq[cnt_sch].location = cv.description,
    dlrec->seq[cnt_sch].location_cd = sa.appt_location_cd, dlrec->seq[cnt_sch].person_id = sa
    .person_id, dlrec->seq[cnt_sch].sch_event_id = sa.sch_event_id
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt_sch), dlrec->encntr_total = cnt_sch
  WITH nocounter
 ;end select
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Demographic Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
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
 CALL echorecord(dlrec)
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
    WHERE ppr.person_id=outerjoin(p.person_id)
     AND ppr.person_prsnl_r_cd=outerjoin(pcp_cd)
     AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (pr
    WHERE pr.person_id=outerjoin(ppr.prsnl_person_id)
     AND pr.physician_ind=outerjoin(1))
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
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Demographic Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
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
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
     AND a.reaction_status_cd != allergy_canceled_cd)
    JOIN (n
    WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
    JOIN (r
    WHERE r.allergy_id=outerjoin(a.allergy_id))
    JOIN (n2
    WHERE n2.nomenclature_id=outerjoin(r.reaction_nom_id))
   ORDER BY d1.seq, substance_type_disp, short_source_string
   HEAD a.person_id
    al = 0, stat = alterlist(dlrec->seq[d1.seq].allergy,10)
   DETAIL
    al = (al+ 1)
    IF (mod(al,10)=1
     AND al != 1)
     stat = alterlist(dlrec->seq[d1.seq].allergy,(al+ 9))
    ENDIF
    dlrec->seq[d1.seq].allergy[al].source_string = short_source_string, dlrec->seq[d1.seq].allergy[al
    ].substance_type_disp = substance_type_disp, dlrec->seq[d1.seq].allergy[al].type_source_string =
    concat(build(substance_type_disp,": ")," ",short_source_string),
    dlrec->seq[d1.seq].allergy[al].source_string = short_source_string, dlrec->seq[d1.seq].allergy[al
    ].severity = uar_get_code_display(a.severity_cd), dlrec->seq[d1.seq].allergy[al].
    substance_type_disp = substance_type_disp,
    dlrec->seq[d1.seq].allergy[al].allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,"@SHORTDATE;;Q"
      ))
    IF (r.reaction_ftdesc > " ")
     dlrec->seq[d1.seq].allergy[al].reaction_display = trim(r.reaction_ftdesc)
    ELSE
     dlrec->seq[d1.seq].allergy[al].reaction_display = trim(n2.source_string)
    ENDIF
   FOOT  d1.seq
    stat = alterlist(dlrec->seq[d1.seq].allergy,al), al = 0
   WITH nocounter
  ;end select
 ENDIF
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Allergy Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
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
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
     AND p.classification_cd != sensitive_cd
     AND p.life_cycle_status_cd=active_life_cycle_cd)
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
     AND n.source_vocabulary_cd=snmct_cd)
   ORDER BY d1.seq, p.problem_id DESC
   HEAD d1.seq
    prob_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].problem,10),
    CALL echo(build("prob_cnt problems header = ",prob_cnt))
   HEAD p.problem_id
    IF (((n.source_string > " ") OR (p.problem_ftdesc > " "))
     AND p.problem_id > 0)
     prob_cnt = (prob_cnt+ 1),
     CALL echo(build("p.person_id problems in TOP details = ",p.person_id)),
     CALL echo(build("prob_cnt top details size = ",size(dlrec->seq[d1.seq].problem,5))),
     CALL echo(build("prob_cnt problems in top details = ",prob_cnt))
     IF (mod(prob_cnt,10)=1
      AND prob_cnt != 1)
      stat = alterlist(dlrec->seq[d1.seq].problem,(prob_cnt+ 9))
     ENDIF
     IF (p.nomenclature_id > 0)
      dlrec->seq[d1.seq].problem[prob_cnt].text = n.source_string
     ELSE
      dlrec->seq[d1.seq].problem[prob_cnt].text = p.problem_ftdesc
     ENDIF
     dlrec->seq[d1.seq].problem[prob_cnt].status = uar_get_code_display(p.life_cycle_status_cd),
     dlrec->seq[d1.seq].problem[prob_cnt].beg_effective_dt_tm = substring(1,14,format(p
       .beg_effective_dt_tm,"@SHORTDATE;;Q")), dlrec->seq[d1.seq].problem[prob_cnt].full_text = build
     (dlrec->seq[d1.seq].problem[prob_cnt].status,": ",dlrec->seq[d1.seq].problem[prob_cnt].text)
    ENDIF
    CALL echo(build("prob_cnt problems in botttom details = ",prob_cnt)),
    CALL echo(build("p.person_id problems in botttom details = ",p.person_id)),
    CALL echo(build("prob_cnt bottom details size = ",size(dlrec->seq[d1.seq].problem,5)))
   FOOT  d1.seq
    CALL echo(build("prob_cnt problems in foot = ",prob_cnt)), stat = alterlist(dlrec->seq[d1.seq].
     problem,prob_cnt), prob_cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Problem Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
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
     AND o.catalog_type_cd=pharmacy_cattyp_cd
     AND o.order_status_cd IN (incomplete_cd, inprocess_cd, ordered_cd, pending_cd, pendingreview_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.orig_ord_as_flag IN (1, 2, 3))
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
    "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RXROUTE"))
    JOIN (oc
    WHERE oc.order_id=outerjoin(o.order_id))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(oc.long_text_id)
     AND ((lt.parent_entity_id+ 0)=outerjoin(oc.order_id))
     AND ((lt.active_ind+ 0)=outerjoin(1))
     AND trim(lt.parent_entity_name)=outerjoin("ORDER_COMMENT"))
   ORDER BY d1.seq, o.order_id, od.detail_sequence
   HEAD REPORT
    cnt = 0
   HEAD d1.seq
    cnt = 0, stat = alterlist(dlrec->seq[d1.seq].meds,10),
    CALL echo("%%%%%% 1")
   HEAD o.order_id
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[d1.seq].meds,cnt),
    CALL echo("%%%%%% 2"),
    CALL echo(build2("med select cnt:",trim(build2(cnt),3))),
    CALL echo(build("person_id in head orders = ",o.person_id)),
    CALL echo(build("o.order_id in head orders = ",o.order_id)),
    dlrec->seq[d1.seq].meds[cnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
    CALL echo("%%%%%% 2.1")
    IF (o.order_comment_ind=1)
     dlrec->seq[d1.seq].meds[cnt].comments = replace(trim(lt.long_text),
      "Refer to Reference Text for Black Box Warning"," ",0),
     CALL echo("%%%%%% 2.11")
    ENDIF
    dlrec->seq[d1.seq].meds[cnt].free_text_cnt = 0, dlrec->seq[d1.seq].meds[cnt].volume_dose_cnt = 0,
    dlrec->seq[d1.seq].meds[cnt].volume_unit_cnt = 0,
    dlrec->seq[d1.seq].meds[cnt].route_cnt = 0, dlrec->seq[d1.seq].meds[cnt].free_text_cnt = 0, dlrec
    ->seq[d1.seq].meds[cnt].dose_cnt = 0,
    dlrec->seq[d1.seq].meds[cnt].doseunit_cnt = 0, dlrec->seq[d1.seq].meds[cnt].strength_dose_cnt = 0,
    dlrec->seq[d1.seq].meds[cnt].strength_unit_cnt = 0
   HEAD od.detail_sequence
    IF (od.oe_field_meaning="FREQ")
     CALL echo(build2(" 1 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].freq
      = od.oe_field_display_value, dlrec->seq[d1.seq].meds[cnt].free_text_cnt = 1,
     CALL echo("%%%%%% 2.12")
    ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
     CALL echo(build2(" 2 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     volume_dose = od.oe_field_display_value, dlrec->seq[d1.seq].meds[cnt].volume_dose_cnt = 1
    ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
     CALL echo(build2(" 3 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     volume_unit = od.oe_field_display_value, dlrec->seq[d1.seq].meds[cnt].volume_unit_cnt = 1
    ELSEIF (od.oe_field_meaning="RXROUTE")
     CALL echo(build2(" 4 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].route
      = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].route_cnt = 1
    ELSEIF (od.oe_field_meaning="FREETXTDOSE")
     CALL echo(build2(" 5 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     free_text = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].free_text_cnt = 1,
     CALL echo(build2(" 6 med select cnt:",trim(build2(cnt),3)))
    ELSEIF (od.oe_field_meaning="DOSE")
     CALL echo(build2(" 7 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].dose
      = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].dose_cnt = 1
    ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
     CALL echo(build2("8 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     strength_dose = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].strength_dose_cnt
      = 0
    ELSEIF (od.oe_field_meaning="DOSEUNIT")
     CALL echo(build2("9 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     doseunit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].doseunit_cnt = 1
    ELSEIF (od.oe_field_meaning="STRENGTHUNIT")
     CALL echo(build2("10 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     strength_unit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].strength_unit_cnt
      = 1
    ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
     CALL echo(build2("11 med select cnt:",trim(build2(cnt),3))), dlrec->seq[d1.seq].meds[cnt].
     strength_unit = trim(od.oe_field_display_value), dlrec->seq[d1.seq].meds[cnt].strength_unit_cnt
      = 1
    ENDIF
    CALL echo("%%%%%% 2.9"),
    CALL echo(build2("detail size(dlrec->seq[d1.seq]->meds,5",size(dlrec->seq[d1.seq].meds,5))),
    CALL echo(build("detail d.seq =",d1.seq))
   FOOT  o.order_id
    CALL echo(build2("foot 1 med select cnt:",trim(build2(cnt),3))),
    CALL echo("%%%%%% 3"),
    CALL echo(build2("foot 2 med select cnt:",trim(build2(cnt),3))),
    row + 1,
    CALL echo(build2("footsize(dlrec->seq[d1.seq]->meds,5",size(dlrec->seq[d1.seq].meds,5))),
    CALL echo(build("foot d.seq =",d1.seq)),
    CALL echo(build2("dlrec->seq[d1.seq]->meds[cnt].dose_cnt:",trim(build2(dlrec->seq[d1.seq].meds[
       cnt].dose_cnt),3)))
    IF ((dlrec->seq[d1.seq].meds[cnt].dose_cnt=1)
     AND (dlrec->seq[d1.seq].meds[cnt].doseunit_cnt=1))
     CALL echo("%%%%%% 3.111"), dlrec->seq[d1.seq].meds[cnt].dose = concat(trim(dlrec->seq[d1
       .seq].meds[cnt].dose)," ",trim(dlrec->seq[d1.seq].meds[cnt].doseunit)), row + 1
    ENDIF
    CALL echo("%%%%%% 3.112")
    IF ((dlrec->seq[d1.seq].meds[cnt].volume_dose > " "))
     CALL echo("%%%%%% 3.1"), dlrec->seq[d1.seq].meds[cnt].dose = concat(dlrec->seq[d1.seq].
      meds[cnt].volume_dose," ",dlrec->seq[d1.seq].meds[cnt].volume_unit)
    ELSEIF ((dlrec->seq[d1.seq].meds[cnt].strength_dose > " ")
     AND (dlrec->seq[d1.seq].meds[cnt].strength_unit > " "))
     CALL echo("%%%%%% 3.2"), dlrec->seq[d1.seq].meds[cnt].dose = concat(dlrec->seq[d1.seq].
      meds[cnt].strength_dose," ",dlrec->seq[d1.seq].meds[cnt].strength_unit)
    ELSEIF ((dlrec->seq[d1.seq].meds[cnt].free_text > " "))
     CALL echo("%%%%%% 3.3"), dlrec->seq[d1.seq].meds[cnt].dose = dlrec->seq[d1.seq].meds[cnt].
     free_text
    ENDIF
   FOOT  d1.seq
    CALL echo("%%%%%% 4")
    IF (cnt > 0)
     dlrec->seq[d1.seq].number_of_meds = cnt, stat = alterlist(dlrec->seq[d1.seq].meds,cnt)
    ENDIF
   FOOT REPORT
    col + 0
   WITH nocounter, maxcol = 2000, format = variable
  ;end select
 ENDIF
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build(" Meds Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
 CALL echo("get vitals")
 IF (size(dlrec->seq,5) > 0)
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event c,
    ce_date_result cdr,
    (dummyt d1  WITH seq = value(size(dlrec->seq,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.person_id=dlrec->seq[d1.seq].person_id)
     AND ((c.event_cd+ 0) IN (weight_cd, systolic_bp_cd, diastolic_bp_cd, pulse_cd, mf_bmi_cd))
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
     AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
     AND c.event_tag > " ")
    JOIN (cdr
    WHERE outerjoin(c.event_id)=cdr.event_id
     AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
   ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
   HEAD REPORT
    cnt = 0
   HEAD d1.seq
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[d1.seq].measurements,cnt)
   HEAD c.event_cd
    CASE (c.event_cd)
     OF weight_cd:
      dlrec->seq[d1.seq].measurements[cnt].wt_result = concat(trim(c.result_val),uar_get_code_display
       (c.result_units_cd)),dlrec->seq[d1.seq].measurements[cnt].wt_dt_tm = substring(1,14,format(c
        .event_end_dt_tm,"@SHORTDATE"))
     OF pulse_cd:
      dlrec->seq[d1.seq].measurements[cnt].pulse_result = trim(c.result_val),dlrec->seq[d1.seq].
      measurements[cnt].pulse_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
     OF systolic_bp_cd:
      dlrec->seq[d1.seq].measurements[cnt].systolic_result = trim(c.result_val)
     OF diastolic_bp_cd:
      dlrec->seq[d1.seq].measurements[cnt].diastolic_result = trim(c.result_val),dlrec->seq[d1.seq].
      measurements[cnt].bp_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
     OF mf_bmi_cd:
      dlrec->seq[d1.seq].measurements[cnt].s_bmi = trim(c.result_val),dlrec->seq[d1.seq].
      measurements[cnt].s_bmi_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
    ENDCASE
    dlrec->seq[d1.seq].measurements[cnt].bp_display = concat(dlrec->seq[d1.seq].measurements[cnt].
     systolic_result,"/",dlrec->seq[d1.seq].measurements[cnt].diastolic_result)
   FOOT  d1.seq
    stat = alterlist(dlrec->seq[d1.seq].measurements,cnt), cnt = 0
   WITH nocounter
  ;end select
 ENDIF
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Vitals Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
 CALL echorecord(dlrec)
 SET select_endtime = cnvtdatetime(curdate,curtime3)
 SET selecttime = datetimediff(cnvtdatetime(select_endtime),cnvtdatetime(select_starttime),5)
 CALL echo(build("Instructions section of Powernote Time Info	 = ",selecttime))
 SET select_starttime = cnvtdatetime(curdate,curtime3)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE no_appt(ncalc=i2) = f8 WITH protect
 DECLARE no_apptabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE date_outofrange(ncalc=i2) = f8 WITH protect
 DECLARE date_outofrangeabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpage(ncalc=i2) = f8 WITH protect
 DECLARE headpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patinfo(ncalc=i2) = f8 WITH protect
 DECLARE patinfoabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE no_active_conditions(ncalc=i2) = f8 WITH protect
 DECLARE no_active_conditionsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_foot1(ncalc=i2) = f8 WITH protect
 DECLARE page_foot1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE active_conditions_head(ncalc=i2) = f8 WITH protect
 DECLARE active_conditions_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE active_conditions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE active_conditionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE allergies_head(ncalc=i2) = f8 WITH protect
 DECLARE allergies_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergies(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE allergiesabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE no_allergy(ncalc=i2) = f8 WITH protect
 DECLARE no_allergyabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE procedures_head(ncalc=i2) = f8 WITH protect
 DECLARE procedures_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE procedures(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE proceduresabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE medication_head(ncalc=i2) = f8 WITH protect
 DECLARE medication_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medtitle(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medtitleabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medications(ncalc=i2) = f8 WITH protect
 DECLARE medicationsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medinstructions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE immun_head(ncalc=i2) = f8 WITH protect
 DECLARE immun_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE immun(ncalc=i2) = f8 WITH protect
 DECLARE immunabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE measurements_head(ncalc=i2) = f8 WITH protect
 DECLARE measurements_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE measurements(ncalc=i2) = f8 WITH protect
 DECLARE measurementsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_foot(ncalc=i2) = f8 WITH protect
 DECLARE page_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
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
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times10bu0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c255 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
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
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE no_appt(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_apptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE no_apptabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.570000), private
   DECLARE __loc_name = vc WITH noconstant(build2(uar_get_code_description( $UNIT),char(0))), protect
   DECLARE __reqeusted_dt = vc WITH noconstant(build2(format(cnvtdatetime(start_dt),"DD-MMM-YYYY;;D"),
     char(0))), protect
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
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 2.771
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Appointments Found for Location:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 4.062
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__loc_name)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 3.167
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqeusted_dt)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 2.604
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("For the Requested Date:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE date_outofrange(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = date_outofrangeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE date_outofrangeabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.820000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 5.042
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Your date range is larger than 1 day.",char(0)))
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 0.031)
    SET rptsd->m_width = 5.031
    SET rptsd->m_height = 0.260
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c255)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PLEASE RETRY",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   DECLARE __reqeusted_dt = vc WITH noconstant(build2(format(cnvtdatetime(start_dt),"DD-MMM-YYYY;;D"),
     char(0))), protect
   DECLARE __loc_name = vc WITH noconstant(build2(uar_get_code_description( $UNIT),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Health Summary",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.813),(offsetx+ 7.250),(offsety+
     0.813))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed on: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 1.479
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("All Appointments for :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 3.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqeusted_dt)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt. Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 4.062
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__loc_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patinfo(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patinfoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patinfoabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.810000), private
   DECLARE __name = vc WITH noconstant(build2(dlrec->seq[cnt_pat].name_full_formatted,char(0))),
   protect
   DECLARE __dob = vc WITH noconstant(build2(dlrec->seq[cnt_pat].birth_dt_tm,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(dlrec->seq[cnt_pat].age,char(0))), protect
   DECLARE __pcp = vc WITH noconstant(build2(dlrec->seq[cnt_pat].pcpdoc_name,char(0))), protect
   DECLARE __resources = vc WITH noconstant(build2(dlrec->seq[cnt_pat].resource,char(0))), protect
   DECLARE __reason_for_appt = vc WITH noconstant(build2(dlrec->seq[cnt_pat].appt_description,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp)
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 1.469
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__resources)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Care Physician:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 1.573
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Assign Resource:",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 1.073
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Appt. :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 6.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reason_for_appt)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE no_active_conditions(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_active_conditionsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE no_active_conditionsabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Active Conditions(problems)",char(
       0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_foot1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_foot1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_foot1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF ( NOT (curendreport != 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE active_conditions_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditions_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE active_conditions_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.161),(offsetx+ 7.250),(offsety+
     0.161))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Conditions",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE active_conditions(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE active_conditionsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
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
     SET _remcondition = (_remcondition+ rptsd->m_drawlength)
    ELSE
     SET _remcondition = 0
    ENDIF
    SET growsum = (growsum+ _remcondition)
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
 SUBROUTINE allergies_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergies_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergies_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.161),(offsetx+ 7.250),(offsety+
     0.161))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergies(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergiesabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergiesabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
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
   SET rptsd->m_width = 3.688
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
     SET _remallergy = (_remallergy+ rptsd->m_drawlength)
    ELSE
     SET _remallergy = 0
    ENDIF
    SET growsum = (growsum+ _remallergy)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 3.063
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
     SET _remreaction = (_remreaction+ rptsd->m_drawlength)
    ELSE
     SET _remreaction = 0
    ENDIF
    SET growsum = (growsum+ _remreaction)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.688
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
   SET rptsd->m_width = 3.063
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
 SUBROUTINE no_allergy(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_allergyabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE no_allergyabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("no allergy data",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE procedures_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = procedures_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE procedures_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedures",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Procedure",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.270),(offsetx+ 7.250),(offsety+
     0.270))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.729
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE procedures(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = proceduresabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE proceduresabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
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
    SET rptsd->m_y = (offsety+ 0.021)
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
     SET _remprocedure = (_remprocedure+ rptsd->m_drawlength)
    ELSE
     SET _remprocedure = 0
    ENDIF
    SET growsum = (growsum+ _remprocedure)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.021)
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
   SET rptsd->m_y = (offsety+ 0.021)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__procedure_date)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.979
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
 SUBROUTINE medication_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medication_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medication_headabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Medications",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.193),(offsetx+ 7.250),(offsety+
     0.193))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medtitle(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medtitleabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medtitleabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
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
   SET rptsd->m_width = 7.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10bu0)
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
     SET _remmedication = (_remmedication+ rptsd->m_drawlength)
    ELSE
     SET _remmedication = 0
    ENDIF
    SET growsum = (growsum+ _remmedication)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.438
   SET rptsd->m_height = drawheight_medication
   IF (ncalc=rpt_render
    AND _holdremmedication > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedication,((size(
        __medication) - _holdremmedication)+ 1),__medication)))
   ELSE
    SET _remmedication = _holdremmedication
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
 SUBROUTINE medications(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medicationsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medicationsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
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
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.250
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dose)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.188
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
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Freq:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medinstructions(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medinstructionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medinstructionsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
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
    SET rptsd->m_y = (offsety+ 0.188)
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
     SET _reminstructions = (_reminstructions+ rptsd->m_drawlength)
    ELSE
     SET _reminstructions = 0
    ENDIF
    SET growsum = (growsum+ _reminstructions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.188)
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
   SET rptsd->m_height = 0.188
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
 SUBROUTINE immun_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immun_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE immun_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunizations",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunization Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.349),(offsetx+ 7.250),(offsety+
     0.349))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE immun(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immunabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE immunabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
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
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 3.979
    SET rptsd->m_height = 0.281
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization_date)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE measurements_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurements_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE measurements_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
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
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Last Result",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.240),(offsetx+ 7.250),(offsety+
     0.240))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Measurements",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Result",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE measurements(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurementsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE measurementsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.790000), private
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
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight",char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.260
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Heart Rate",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Pressure",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight_result)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__heart_rate_result)
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bp_result)
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight_date)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__heart_rate_date)
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bp_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMI",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bmi_result)
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bmi_date)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.070000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPTAMB_PDF"
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
   SET rptfont->m_underline = rpt_on
   SET _times10bu0 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE becont = i2
 DECLARE sub_head_page(beg_report=i2) = null
 DECLARE sub_foot_page(end_report=i2) = null
 SUBROUTINE sub_head_page(beg_report)
  SET d0 = headpage(rpt_render)
  SET d0 = patinfo(rpt_render)
 END ;Subroutine
 SUBROUTINE sub_foot_page(end_report)
  SET d0 = page_foot(rpt_render)
  IF (end_report=0)
   SET d0 = pagebreak(0)
  ENDIF
 END ;Subroutine
 SET d0 = initializereport(0)
 FOR (cnt_pat = 1 TO size(dlrec->seq,5))
   SET d0 = sub_head_page(0)
   IF ((((_yoffset+ active_conditions_head(rpt_calcheight))+ 1) > page_size))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = active_conditions_head(rpt_render)
   IF (size(dlrec->seq[cnt_pat].problem,5) > 0)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].problem,5))
      SET remain_space = (page_size - _yoffset)
      SET remain_space = (page_size - _yoffset)
      IF (((_yoffset+ active_conditions(rpt_calcheight,remain_space,becont)) > page_size))
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
        SET remain_space = (page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = active_conditions(rpt_render,remain_space,becont)
    ENDFOR
   ELSE
    SET d0 = no_active_conditions(rpt_render)
   ENDIF
   IF (((_yoffset+ allergies_head(rpt_calcheight)) > page_size))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = allergies_head(rpt_render)
   IF (size(dlrec->seq[cnt_pat].allergy,5) > 0)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].allergy,5))
      SET remain_space = (page_size - _yoffset)
      IF (((_yoffset+ allergies(rpt_calcheight,remain_space,becont)) > page_size))
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
        SET remain_space = (page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = allergies(rpt_render,remain_space,becont)
    ENDFOR
   ELSE
    SET d0 = no_allergy(rpt_render)
   ENDIF
   IF (size(dlrec->seq[cnt_pat].meds,5) > 0)
    IF (((_yoffset+ medication_head(rpt_calcheight)) > page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDIF
    SET d0 = medication_head(rpt_render)
    FOR (x = 1 TO size(dlrec->seq[cnt_pat].meds,5))
      SET remain_space = (page_size - _yoffset)
      IF (((_yoffset+ medtitle(rpt_calcheight,remain_space,becont)) > page_size))
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
        SET remain_space = (page_size - _yoffset)
        SET becont = 0
      ENDWHILE
      SET d0 = medtitle(rpt_render,remain_space,becont)
    ENDFOR
   ENDIF
   IF (((_yoffset+ measurements_head(rpt_calcheight)) > page_size))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = measurements_head(rpt_render)
   FOR (x = 1 TO size(dlrec->seq[cnt_pat].measurements,5))
    IF (((_yoffset+ measurements(rpt_calcheight)) > page_size))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
     SET d0 = measurements_head(rpt_render)
    ENDIF
    SET d0 = measurements(rpt_render)
   ENDFOR
   SET d0 = page_foot(rpt_render)
   SET d0 = page_foot1(rpt_render)
   SET _yoffset = 10.50
 ENDFOR
 CALL echo(build("var_output(finalize)  = ",var_output))
 SET d0 = no_appt(rpt_render)
 SET d0 = finalizereport(var_output)
 IF (operations=1)
  SET spool value(var_output) value( $OUTDEV) WITH deleted
 ENDIF
 CALL echo("End Record")
#exit_prg
END GO
